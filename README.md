# stargate

This is a small PoC for a gateway API using Khepri as a database.

in .priv/routes we have a json file that specify incomming routes and outgoing routes.

```json
[{"prefix": "",
  "security": false,
  "routes": [
             {
              "endpoint": "/petapi",
              "method": "GET",
              "module": "stargate_main_controller",
              "function": "index",
              "backend": [
                          {
                          "url_pattern": "/pet",
                          "method": "GET",
                          "host": "http://localhost:8080"
                          }
                        ]
             }
          ]
  }
]
```

prefix is if we want to have say an version of the incomming api for the endpoint value in routes. Example "prefix:"v1" would endup in "v1/petapi".
security is either a boolean false, that we don't have one. Or a json with value module, funciton. Example {"module":"mysecuritymodule", "function":"mysecurityfunctioninmodule"}.
routes is a list ov json that specify what method and ingoing endpoint match to what backend.

## start

```erlang
rebar3 shell --sname NODENAME
```

