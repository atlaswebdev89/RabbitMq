<?php

//Файл с исходным кодом лежит в /application/hello-world, поэтому нужно спуститься на два уровня
//прежде, чем подключить vendor
require_once __DIR__ . '/vendor/autoload.php';

//Подключаем нужный класс
use PhpAmqpLib\Connection\AMQPStreamConnection;

//Создаем соединение
$connection = new AMQPStreamConnection('localhost', 5672, 'guest', 'guest');

//Берем канал и декларируем в нем очередь, важно чтобы названия очередей совпадали
$channel = $connection->channel();
$channel->queue_declare('hello', false, false, false, false);

echo ' [*] Waiting for messages. To exit press CTRL+C', "\n";

//Функция, которая будет обрабатывать данные, полученные из очереди
$callback = function($msg) {
    echo " [x] Received ", $msg->body, "\n";
};

//Уходим слушать сообщения из очереди в бесконечный цикл
$channel->basic_consume('hello', '', false, true, false, false, $callback);

while(count($channel->callbacks)) {
    $channel->wait();
}

//Не забываем закрыть соединение и канал
$channel->close();
$connection->close();

?>