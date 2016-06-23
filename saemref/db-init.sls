{% from "saemref/map.jinja" import saemref, cubicweb_ctl with context %}

include:
  - saemref

cubicweb-db-init:
  cmd.run:
    - name: {{ cubicweb_ctl }} db-init -a {{ saemref.instance.name }}
    - user: {{ saemref.instance.user }}
    - env:
        CW_MODE: user

