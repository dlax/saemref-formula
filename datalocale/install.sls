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
      - cubicweb-saem-ref
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

{% if datalocale.install.dev %}
dev dependencies:
  pkg.installed:
    - pkgs:
      - python-pip
      - python-virtualenv
      - mercurial
  pip.installed:
    - name: setuptools
    - ignore_installed: true

venv:
  virtualenv.managed:
    - name: /home/{{ datalocale.instance.user }}/venv
    - system_site_packages: true
    - user: {{ datalocale.instance.user }}
    - require:
      - pkg: dev dependencies

cubicweb in venv:
  pip.installed:
    - name: cubicweb
    - no_deps: true
    - ignore_installed: true
    - bin_env: /home/{{ datalocale.instance.user }}/venv
    - user: {{ datalocale.instance.user }}
    - require:
      - virtualenv: venv

cubicweb-saem_ref from hg:
  pip.installed:
    - name: hg+http://hg.logilab.org/review/cubes/saem_ref#egg=cubicweb-saem_ref
    - user: {{ datalocale.instance.user }}
    - bin_env: /home/{{ datalocale.instance.user }}/venv
    - require:
      - pkg: dev dependencies
      - pip: dev dependencies
      - pip: cubicweb in venv
      - user: {{ datalocale.instance.user }}
      - virtualenv: venv

{% endif %}

cubicweb-create:
  cmd.run:
    - name: cubicweb-ctl create --no-db-create -a saem_ref {{ datalocale.instance.name }}
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
