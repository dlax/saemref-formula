# -*- coding: utf-8 -*-
{% from "datalocale/map.jinja" import datalocale with context %}

include:
  - datalocale.logilab-repo
{% if grains['os_family'] == 'RedHat' %}
  - epel
  - postgres.upstream
{% endif %}


cube-packages:
  pkg.latest:
    - pkgs:
      - cubicweb-datalocale
    {% if grains['os_family'] == 'Debian' %}
      - cubicweb-ctl
      - cubicweb-server
      - cubicweb-twisted
      - postgresql-client
    - require:
      - pkgrepo: logilab-public-acceptance
    {% else %}{# RedHat #}
      - postgresql94
    - require:
      - pkgrepo: logilab_extranet
    {% endif %}

create-datalocale-user:
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
        - pkg: cube-packages
        - user: {{ datalocale.instance.user }}

{% if datalocale.instance.wsgi %}

wsgi-packages:
  pkg.installed:
    - pkgs:
      - pyramid-cubicweb
      - uwsgi
      - uwsgi-plugin-python
    {% if grains['os_family'] == 'Debian' %}
    - require:
      - pkgrepo: logilab-backports
      - pkgrepo: backports
    {% else %}{# RedHat #}
      - crontabs
    - require:
      - pkgrepo: logilab_extranet
    {% endif %}

{% endif %}
