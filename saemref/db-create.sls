{% from "saemref/map.jinja" import saemref, cubicweb_ctl with context %}

include:
  - saemref

cubicweb-db-create:
  cmd.run:
    - name: {{ cubicweb_ctl }} db-create -a {{ saemref.instance.name }}
    - user: {{ saemref.instance.user }}
    - env:
        CW_MODE: user
