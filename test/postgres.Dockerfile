FROM postgres:9.6

RUN apt-get -qqy update && apt-get -qqy install postgresql-plpython-9.6
