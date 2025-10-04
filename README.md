# Wreckfest Dedicated Server

Docker image to run Wreckfest dedicated server. Game requries about 6Gb of space.

## Env Variables

All are optional

| Name                 | Default                  | Description                                                                           |
| -------------------- | ------------------------ | ------------------------------------------------------------------------------------- |
| `WF_SERVER_NAME`     | wreckfest private server | Server name                                                                           |
| `WF_PASSWORD`        | password                 | Password for the server                                                               |
| `WF_ADMINS`          |                          | List of SteamID64 separated by comma which automatically will be recognised as admins |
| `WF_OWNER_DISABLED`  | 1                        | Give owner privileges to the first user who joins, 0 - yes, 1 - no                    |
| `WF_STEAM_PORT`      | 27015                    | Steam port, range 27015-27050                                                         |
| `WF_QUERY_PORT`      | 27016                    | Game query port, range 27015-27020 and 26900-26905                                    |
| `WF_GAME_PORT`       | 33540                    | Game port                                                                             |
| `WF_ADDITIONAL_ARGS` |                          | Additional params for server start command                                            |
