{% from "datalocale/map.jinja" import datalocale with context %}

include:
  - datalocale.install

{% for filename in ('sources', 'all-in-one.conf') %}
/home/{{ datalocale.instance.user }}/etc/cubicweb.d/{{ datalocale.instance.name }}/{{ filename }}:
  file.managed:
    - source: salt://datalocale/files/{{ filename }}.j2
    - template: jinja
{% endfor %}
