module test_recieve;

private import Log;
private import std.c.string;
private import std.c.stdlib;
private import std.thread;

private import libzmq_headers;
private import mq_client;
private import zmq_point_to_poin_client;

void main(char[][] args)
{
	mq_client client = null;

	char* bind_to = "tcp://127.0.0.1:5556".ptr;
	client = new zmq_point_to_poin_client(bind_to);

	client.set_callback(&get_message);

	Thread thread = new Thread(&client.listener);

	printf("log=%p\n", log);

	log.trace("start new Thread %p", &thread);
	thread.start();
	thread.wait();
}

int count = 0;

void get_message(byte* message, int message_size, mq_client from_client)
{
	count++;
	printf("[%i] data: %s\n", count, cast(char*) message);

	from_client.send("", "test message", false);
	return;
}
