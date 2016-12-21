# coding: utf-8
from __future__ import unicode_literals

import re

import pytest

wait_supervisord_started = pytest.mark.usefixtures("_wait_supervisord_started")
wait_datalocale_started = pytest.mark.usefixtures("_wait_datalocale_started")


def test_package_postgresclient(Package, SystemInfo):
    if SystemInfo.distribution == "centos":
        name = "postgresql94"
    else:  # Debian
        name = "postgresql-client"

    pkg = Package(name)
    assert pkg.is_installed
    assert pkg.version.startswith("9.4")


@pytest.mark.parametrize("name, version", [
    ("cubicweb", "3.23.2"),
    ("cubicweb-datalocale", "0.3.0"),
    ("cubicweb-datacat", "0.8.5"),
])
def test_package_install(Package, name, version):
    pkg = Package(name)
    assert pkg.is_installed
    assert pkg.version.startswith(version)

def test_package_cubicweb(Package, SystemInfo):
    if SystemInfo.distribution == "centos":
        name = "cubicweb"
    else:  # Debian
        name = "cubicweb-server"

    cubicweb = Package(name)
    assert cubicweb.is_installed
    assert cubicweb.version.startswith("3.23")
    assert map(int, cubicweb.version.split('.')) >= [3, 23, 2]


@pytest.mark.parametrize("name, version", [
    ("cubicweb", "3.23.2"),
    ("cubicweb-datalocale", "0.3.0"),
    ("cubicweb-datacat", "0.8.5"),
])
def test_devinstall(Command, name, version):
    cmd = "/home/datalocale/venv/bin/cubicweb-ctl list cubes"
    out = Command.check_output(cmd)
    m = re.search(r'\* {0}( )+{1}'.format(name, version), out)
    assert m, out


@wait_supervisord_started
@pytest.mark.parametrize("state, exclude", [
    ("datalocale", [
        # FIXME: Contain container IP...
        "/home/datalocale/etc/cubicweb.d/datalocale/all-in-one.conf",
        # Has 'ignore_installed: true', so would re-run unconditionally.
        "cubicweb in venv",
    ]),
    ("datalocale.supervisor", [
        # Has 'ignore_installed: true', so would re-run unconditionally.
        "cubicweb in venv",
    ]),
])
@pytest.mark.destructive()
def test_idempotence(Salt, state, exclude):
    result = Salt("state.sls", state)
    for item in result.values():
        assert item["result"] is True, item
        if item["__id__"] in exclude:
            continue
        assert item["changes"] == {}


@wait_datalocale_started
def test_datalocale_running(Process, Service, Socket, Command, is_centos6, supervisor_service_name):
    assert Service(supervisor_service_name).is_enabled

    supervisord = Process.get(comm="supervisord")

    if is_centos6:
        assert supervisord.user == "datalocale"
        assert supervisord.group == "datalocale"
    else:
        assert supervisord.user == "root"
        assert supervisord.group == "root"

    cubicweb = Process.get(ppid=supervisord.pid)

    assert cubicweb.user == "datalocale"
    assert cubicweb.group == "datalocale"

    assert Socket("tcp://0.0.0.0:8080").is_listening

    html = Command.check_output("curl http://localhost:8080")
    assert 'http://www.cubicweb.org' in html

    if not is_centos6:
        assert cubicweb.comm == "uwsgi"
        # Should have 2 worker process with 8 thread each and 1 http proccess with one thread
        child_threads = sorted([c.nlwp for c in Process.filter(ppid=cubicweb.pid)])
        assert child_threads == [1, 8, 8]
    else:
        # twisted
        assert cubicweb.comm == "cubicweb-ctl"
