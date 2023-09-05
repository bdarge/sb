# sb


## How to build

- git submodule update --init

- `./build.sh -p` for production or `./build.sh`

## Database
generate migration script
```console
migrate create -ext sql -dir db/migrations add_account_table
```