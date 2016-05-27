{% from "datalocale/map.jinja" import datalocale with context %}

include:
  - datalocale

cubicweb-db-init:
  cmd.run:
    - name: cubicweb-ctl db-init -a {{ datalocale.instance.name }}
    - user: {{ datalocale.instance.user }}
    - env:
        CW_MODE: user

