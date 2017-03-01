saemref:
  lookup:
    instance:
      name: saemref
      user: saemref
      # http port
      port: 8080
      # Anonymous user
      anonymous_user: "john"
      anonymous_password: "secret"

      # wsgi settings
      # 2 * 8 = can handle 16 concurrent request
      # and will use 16 database connections.
      wsgi: true
      wsgi_workers: 2
      wsgi_threads: 8

      # Secret keys for encrypting session/cookies data and authentication They
      # are MANDATORY and should not be the same.
      sessions_secret: SETME
      authtk_session_secret: SETME1
      authtk_persistent_secret: SETME2

      # Pool size must be equal to wsgi_threads when using wsgi
      pool_size: 8

      # Run in test mode: will replace some data files to create the instance faster
      test_mode: true
    db:
      driver: postgres
      host: ""
      port: ""
      name: saemref
      user: saemref
      pass: saemref
    admin:
      login: admin
      pass: admin

postgres:
  version: 9.4
