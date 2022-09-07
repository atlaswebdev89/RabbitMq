FROM rabbitmq:management
MAINTAINER atlas <doroshuk33@yandex.by>

ENV RABBITMQ_ERLANG_COOKIE=123fsd123dfbqb
ENV CLUSTER_WITH=false
ENV CLUSTER_MASTER=false
ENV HA=true

WORKDIR "/home/scripts/"
COPY init.sh /home/scripts/init.sh

CMD /home/scripts/init.sh


