<?php
//Establish connection to AMQP
$connection = new AMQPConnection();
$connection->setHost('127.0.0.1');
$connection->setLogin('guest');
$connection->setPassword('guest');
$connection->connect();
//Create and declare channel
$channel = new AMQPChannel($connection);
//AMQPC Exchange is the publishing mechanism
$exchange = new AMQPExchange($channel);


//название цепочки
$routing_key = 'hello';


//это важно при отсутствии цепочки с именем hello
$queue = new AMQPQueue($channel);
$queue->setName($routing_key);
$queue->setFlags(AMQP_NOPARAM);
$queue->declareQueue();


//тут уже просто размещение сообщения
$message = 'test '.microtime();
$exchange->publish($message, $routing_key);

//а тут отключение
$connection->disconnect();
