FROM rabbitmq:management
MAINTAINER atlas <doroshuk33@yandex.by>

ENV RABBITMQ_ERLANG_COOKIE=test
ENV CLUSTER_WITH=rabbit1
ENV HA=true

WORKDIR "/home/scripts/"
COPY init.sh /home/scripts/init.sh

CMD /home/scripts/init.sh


