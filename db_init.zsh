#!/usr/bin/env zsh


function env_file () {
export DB_USER="dev_user"
export DB_PASSWORD="password"
export DB_NAME="baby_shark"
export DB_HOST="dev_postgres"
export DB_DATA="my_dbdata:/var/lib/postgresql/data"
export HOST_PORT=54320
export CON_PORT=5432
export DB_PORT=$( echo $HOST_PORT $CON_PORT | sed "s/ /:/g" )
export DB_FILE_PATH="$HOME/SOURCE/docker/postgres_dev_db"
export ENV_FILE_PATH="$DB_FILE_PATH/.env"

function clear_env_file () {
    :> "$ENV_FILE_PATH"
}

function write_env_file () {
    clear_env_file
    echo "DB_USER=$DB_USER" >> $ENV_FILE_PATH
    echo "DB_PASSWORD=$DB_PASSWORD" >> $ENV_FILE_PATH
    echo "DB_NAME=$DB_NAME" >> $ENV_FILE_PATH
    echo "DB_HOST=$DB_HOST" >> $ENV_FILE_PATH
    echo "DB_DATA=$DB_DATA" >> $ENV_FILE_PATH
    echo "HOST_PORT=$HOST_PORT" >> $ENV_FILE_PATH
    echo "CON_PORT=$CON_PORT" >> $ENV_FILE_PATH
    echo "DB_PORT=$DB_PORT" >> $ENV_FILE_PATH
    echo "DOCKER_IP=$DOCKER_IP" >> $ENV_FILE_PATH
    echo "DB_FILE_PATH=$DB_FILE_PATH" >> $ENV_FILE_PATH
}

write_env_file
}

env_file


function log_dock () {
    docker logs -f "$DB_NAME"
    }


function ls_docker () {
    docker ps -a
    }


function kill_docks () {
    docker container stop $(docker container ls -aq)
    docker system prune -a -f
    clear_env_file
    }


function run_bash () {
    docker-compose run database bash
    }


function pg_login () {
    psql --host="$DB_HOST" --username="$DB_USER" --dbname="$DB_NAME"
    }


function pg_on () {
    env_file
    pushd "$DB_FILE_PATH"
    docker-compose up -d
    clear
    ls_docker
    popd
    export DOCKER_IP=$( docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" "$DB_HOST" )
    export PG_DEV_URI="postgres://$DOCKER_IP:$DB_PORT"
    echo "PG_DEV_URI=$PG_DEV_URI" >> $ENV_FILE_PATH
    cat
    }


alias pg_off="kill_docks"
alias docker_ls="ls_docker"
