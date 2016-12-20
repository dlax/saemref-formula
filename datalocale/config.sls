{% from "datalocale/map.jinja" import datalocale with context %}

include:
  - datalocale.install

{% for filename in ('sources', 'all-in-one.conf') %}
/home/{{ datalocale.instance.user }}/etc/cubicweb.d/{{ datalocale.instance.name }}/{{ filename }}:
  file.managed:
    - source: salt://datalocale/files/{{ filename }}.j2
    - template: jinja
{% endfor %}

{% if datalocale.instance.wsgi %}
/home/{{ datalocale.instance.user }}/etc/cubicweb.d/{{ datalocale.instance.name }}/pyramid.ini:
  file.managed:
    - source: salt://datalocale/files/pyramid.ini
    - template: jinja
    - user: {{ datalocale.instance.user }}
    - group: {{ datalocale.instance.user }}

/home/{{ datalocale.instance.user }}/etc/cubicweb.d/{{ datalocale.instance.name }}/uwsgi.ini:
  file.managed:
    - source: salt://datalocale/files/uwsgi.ini
    - template: jinja
    - user: {{ datalocale.instance.user }}
    - group: {{ datalocale.instance.user }}

# HINT: This file is managed by cubicweb package on debian (and missing on centos)
/etc/logrotate.d/cubicweb-ctl:
  file.managed:
    - source: salt://datalocale/files/logrotate.conf
    - template: jinja

CW_MODE=user cubicweb-ctl source-sync --loglevel error {{ datalocale.instance.name }}:
  cron.present:
    - user: {{ datalocale.instance.user }}
    - hour: "*/1"
{% endif %}
