{% if grains['os_family'] == 'Debian' %}

{% elif grains['os_family'] == 'RedHat' %}

include:
  - epel
  - postgres.upstream

logilab repository:
  pkgrepo.managed:
    - humanname: Logilab free software repository $releasever $basearch
    - baseurl: http://download.logilab.org/rpms/acceptance/epel-$releasever-$basearch
    - gpgcheck: 0
{% endif %}
