# coding: utf-8

import os

import pytest

DUMPS_DIR = os.path.join(os.path.abspath(os.path.dirname(__file__)), "dumps")
DUMPS = [fname for fname in os.listdir(DUMPS_DIR) if fname.endswith(".tar.gz")]


@pytest.mark.parametrize("dump", DUMPS)
@pytest.mark.docker_addopts("-v", "{0}:/dumps".format(DUMPS_DIR))
@pytest.mark.use_postgres
@pytest.mark.destructive
def test_migration(Salt, Command, dump):
    run = Command.check_output
    db_host = Salt("environ.get", "POSTGRES_PORT_5432_TCP_ADDR")
    db_port = Salt("environ.get", "POSTGRES_PORT_5432_TCP_PORT")
    config = "/home/saemref/etc/cubicweb.d/saemref/sources"
    bin_env = "/home/saemref/venv/bin/"
    run("sed -ri %s %s", "s@^db-driver=.*$@db-driver=postgres@", config)
    run("sed -ri %s %s", "s@^db-user=.*$@db-user=postgres@", config)
    run("sed -ri %s %s", "s@^db-name=.*$@db-name=saemref@", config)
    run("sed -ri %s %s", "s@^db-host=.*$@db-host={0}@".format(db_host), config)
    run("sed -ri %s %s", "s@^db-port=.*$@db-port={0}@".format(db_port), config)
    run("createdb -h {0} -p {1} -U postgres saemref".format(db_host, db_port))
    env = 'CW_MODE=user'

    def sucmd(cmd):
        return "su - saemref -c '{0} {1}'".format(env, cmd)

    run(sucmd('{0}/cubicweb-ctl db-restore saemref /dumps/{1}'.format(bin_env, dump)))
    out = Command(sucmd('{0}/cubicweb-ctl upgrade -v 0 --force --backup-db=n saemref'.format(bin_env)))
    # upgrade exit 0 even if a migration failed
    assert out.rc == 0
    assert "-> instance migrated." in out.stdout, "STDOUT:\n\n%s\n\nSTDERR:\n\n%s" % (out.stdout, out.stderr)
