{% from "datalocale/map.jinja" import datalocale with context %}

include:
  - datalocale

cubicweb-db-create:
  cmd.run:
    - name: cubicweb-ctl db-create -a {{ datalocale.instance.name }}
    - user: {{ datalocale.instance.user }}
    - env:
        CW_MODE: user
