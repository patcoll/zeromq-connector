module libzmq_client;

private import mom_client;
private import Log;
private import libzmq_headers;
private import std.c.string;
private import std.c.stdlib;

class libzmq_client: mom_client
{
	void* context = null;
	void* soc_rep;

	bool isSend = false;

	void function(byte* txt, ulong size, mom_client from_client) message_acceptor;

	this(char* bind_to)
	{
		context = zmq_init(1);
		soc_rep = zmq_socket(context, soc_type.ZMQ_REP);

		printf("libzmq_client: listen: %s\n", bind_to);
		int rc = zmq_bind(soc_rep, bind_to);
		if(rc != 0)
		{
			printf("error in zmq_bind: %s\n", zmq_strerror(zmq_errno()));
			return;
		}

	}

	~this()
	{
		//		printf("libzmq_client:destroy\n");

		//		printf("libzmq_client:#0\n");
		//		printf("libzmq_client:#a\n");
		//		if (soc_rep !is null)
		{
			//		printf("libzmq_client:#1\n");
			//		printf("libzmq_client:zmq_close, soc_rep=%p\n", soc_rep);
			//		zmq_close(soc_rep);
		}
		//		zmq_close(soc_rep);
		//		printf("libzmq_client:zmq_term\n");
		//		zmq_term(context);
	}

	void set_callback(void function(byte* txt, ulong size, mom_client from_client) _message_acceptor)
	{
		message_acceptor = _message_acceptor;
	}

	int send(char* routingkey, char* messagebody, bool send_more)
	{
		zmq_msg_t msg;

		//		Stdout.format("#send").newline;
		int message_size = strlen(messagebody);

		int rc = zmq_msg_init_size(&msg, message_size);
		if(rc != 0)
		{
			printf("error in zmq_msg_init_size: %s\n", zmq_strerror(zmq_errno()));
			return -1;
		}

		memcpy(zmq_msg_data(&msg), messagebody, message_size);

		int send_param = 0;

		if(send_more)
			send_param = send_recv_opt.ZMQ_SNDMORE;

		rc = zmq_send(soc_rep, &msg, send_param);
		if(rc != 0)
		{
			printf("libzmq_client.send:zmq_send: {}\n", zmq_strerror(zmq_errno()));
			return -1;
		}
		isSend = true;

		//		Stdout.format("#send is ok").newline;
		return 0;
	}

	char* get_message()
	{
		return null;
	}

	int listener()
	{

		while(true)
		{
			zmq_msg_t msg;

			int rc = zmq_msg_init(&msg);
			if(rc != 0)
			{
				printf("error in zmq_msg_init_size: %s\n", zmq_strerror(zmq_errno()));
				return -1;
			}

			if(isSend == false)
			{
				rc = zmq_msg_init_size(&msg, 1);
				if(rc != 0)
				{
					printf("error in zmq_msg_init_size: %s\n", zmq_strerror(zmq_errno()));
					return -2;
				}

				rc = zmq_send(soc_rep, &msg, 0);
			}

			rc = zmq_recv(soc_rep, &msg, 0);
			if(rc != 0)
			{
				printf("error in zmq_recv: %s\n", zmq_strerror(zmq_errno()));
				return -3;
			}
			else
			{
				isSend = false;

				byte* data = cast(byte*) zmq_msg_data(&msg);
				int len = strlen(cast(char*) data);
				char* result = null;
				try
				{
					//					Stdout.format("call message acceptor").newline;
					message_acceptor(data, len, this);
					//					Stdout.format("ok").newline;
				} catch(Exception ex)
				{
					//					Stdout.format("exception").newline;
					//					send("", "");
				}
			}
		}
	}

	public char[] getInfo()
	{
		return "zeromq";
	}

}
