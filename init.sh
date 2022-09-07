#!/usr/bin/env bash

# Установим куки для связи между серверами в кластере
# Она передана в переменную окуржения RABBITMQ_ERLANG_COOKIE

if [[ ${RABBITMQ_ERLANG_COOKIE} ]]; then
     ERLANG_TOKEN=${RABBITMQ_ERLANG_COOKIE};
else 
     ERLANG_TOKEN='secret';
fi

if [[ -e /var/lib/rabbitmq/.erlang.cookie ]]
then
    echo ${ERLANG_TOKEN} > /var/lib/rabbitmq/.erlang.cookie;
else
    touch /var/lib/rabbitmq/.erlang.cookie;
    chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie;
    chmod 400 /var/lib/rabbitmq/.erlang.cookie;
    echo ${ERLANG_TOKEN} > /var/lib/rabbitmq/.erlang.cookie;
fi

/opt/rabbitmq/sbin/rabbitmq-server
