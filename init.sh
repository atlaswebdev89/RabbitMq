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

# Запускаем cluster
# Проверяем переменную которая содежит название ноды к которой надо подключиться
hostname=$(hostname);
# Тернарный оператор
RABBITMQ_NODENAME=${RABBITMQ_NODENAME:-rabbit};

if [[ -n ${CLUSTER_WITH} && ${CLUSTER_WITH} != false ]]
then
    echo "Running as clustered server"
    /opt/rabbitmq/sbin/rabbitmq-server -detached

    #сделать задержку т.к. rabbitmq-server включается с задержкой 
    # Можно проверить 
    # $(rabbitmqctl status | grep Runtime | wc -l)

    count=0;
    while [[ $(rabbitmqctl status  2>/dev/null | grep Runtime | wc -l) -eq 0 ]]
    do  
        echo "$count";
        echo "Wait Running as RabbitMq server";
        # икремент
        ((count++));
        sleep 2;
        if [[ count -gt 20 ]]
        then
           echo "RabbitMq server not running! Failed! Stoping script";
        exit; 
        fi
    done

    if [[ $(rabbitmqctl status | grep Runtime | wc -l) -gt 0 ]]
    then
        echo "RabbitMq server running done!"
    else
        echo "RabbitMq server not running! Failed! Stoping script";
        exit;
    fi

    rabbitmqctl stop_app
    # Добавляем в cluster
    echo "Joining cluster $CLUSTER_WITH"
    rabbitmqctl join_cluster ${RABBITMQ_NODENAME}@${CLUSTER_WITH}
    # Запускаем
    rabbitmqctl start_app
    
    # Включаем репликацию очередей между всеми нодами
    if [[ ${HA} == true ]]
    then
        rabbitmqctl set_policy ha-all "" '{"ha-mode":"all","ha-sync-mode":"automatic"}';
    fi
    # Tail to keep the a foreground process active..
    tail -f /var/log/bootstrap.log
else
    echo "Running as single server"
    /opt/rabbitmq/sbin/rabbitmq-server
fi


