{% from "saemref/map.jinja" import saemref with context %}

include:
  - saemref

cubicweb-db-create:
  cmd.run:
    - name: cubicweb-ctl db-create -a {{ saemref.instance.name }}
    - user: {{ saemref.instance.user }}
    - env:
        CW_MODE: user
