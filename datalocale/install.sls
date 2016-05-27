# -*- coding: utf-8 -*-
{% from "datalocale/map.jinja" import datalocale with context %}

include:
  - datalocale.logilab-repo

cubicweb-datalocale:
  pkg.latest:
    - require:
      - pkgrepo: logilab_extranet

create-user:
  user.present:
    - name: {{ datalocale.instance.user }}

cubicweb-create:
  cmd.run:
    - name: cubicweb-ctl create --no-db-create -a datalocale {{ datalocale.instance.name }}
    - creates: /home/{{ datalocale.instance.user }}/etc/cubicweb.d/{{ datalocale.instance.name }}
    - user: {{ datalocale.instance.user }}
    - env:
        CW_MODE: user
    - require:
        - pkg: cubicweb-datalocale
        - user: {{ datalocale.instance.user }}
