{% from "datalocale/map.jinja" import datalocale, supervisor_confdir, supervisor_conffile with context %}

include:
  - datalocale.install

{% if grains['os_family'] == 'RedHat' and grains['osmajorrelease'] == '6' %}

python-pip:
  pkg:
    - installed

supervisor:
  pip.installed:
    - user: {{ datalocale.instance.user }}
    - install_options:
      - "--user"
    - require:
      - user: {{ datalocale.instance.user }}
      - pkg: python-pip

{% for fname in ('supervisorctl', 'supervisord') %}
/home/{{ datalocale.instance.user }}/bin/{{ fname }}:
  file.symlink:
    - target: /home/{{ datalocale.instance.user }}/.local/bin/{{ fname }}
    - user: {{ datalocale.instance.user }}
    - makedirs: true
    - require:
      - pip: supervisor
{% endfor %}

supervisor_confdir:
  file.directory:
    - name: {{ supervisor_confdir }}
    - user: {{ datalocale.instance.user }}
    - require:
      - user: {{ datalocale.instance.user }}

/home/{{ datalocale.instance.user }}/etc/supervisord.conf:
  file.managed:
    - source: salt://datalocale/files/supervisord.conf
    - template: jinja
    - user: {{ datalocale.instance.user }}


/etc/init.d/supervisord:
  file.managed:
    - source: salt://datalocale/files/supervisord.init
    - template: jinja
    - mode: 755

{% else %}

supervisor:
  pkg:
    - installed

supervisor_confdir:
  file.directory:
    - name: {{ supervisor_confdir }}
    - require:
      - pkg: supervisor


{% endif %}


{{ supervisor_conffile }}:
  file.managed:
    - source: salt://datalocale/files/datalocale-supervisor.conf
    - template: jinja
    {% if grains['os_family'] != 'Debian' %}
    - user: {{ datalocale.instance.user }}
    {% endif %}
    - require:
      - file: supervisor_confdir

supervisor-service-running:
  service.running:
    - name: supervisord
    - enable: true
