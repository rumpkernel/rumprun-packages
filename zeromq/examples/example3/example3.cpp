#include <zmq.h>

#include <cassert>
#include <cstring>
#include <iostream>
#include <chrono>
#include <ctime>
#include <future>

///=========================================================================
// string
///=========================================================================
auto snd_string (void *context, int type, const char * endpoint, const std::string ch) noexcept -> int 
{
    int ind{0}, size{0}; 

    const char * ch_data = ch.c_str();

    void *socket = zmq_socket (context, type);
    ind = zmq_connect (socket, endpoint);
    assert (ind == 0);

    zmq_msg_t message;

    ind = zmq_msg_init_size (&message, strlen(ch_data)+1);
    assert (ind == 0);
 
    memcpy(zmq_msg_data(&message), ch_data, strlen(ch_data)+1 );  

    size = zmq_msg_send (&message, socket, 0);
    assert (size > 0);

    ind = zmq_close (socket);
    assert (ind == 0);

    return size;
}

auto rcv_string (void *context, int type, const char * endpoint) noexcept -> std::string
{
    int ind{0}; 

    void *socket = zmq_socket (context, type);
    ind = zmq_bind (socket, endpoint);
    assert (ind == 0);

    zmq_msg_t message;

    ind = zmq_msg_init (&message);
    assert (ind == 0);
    ind = zmq_msg_recv (&message, socket, 0);
    assert (ind != -1);

    std::string ch(static_cast<char const*>(zmq_msg_data(&message)));

    ind = zmq_msg_close (&message);
    assert (ind == 0);

    ind = zmq_close (socket);
    assert (ind == 0);

    return ch;
}

auto main(int argc, char *argv[]) noexcept -> int
{
    int ind{0};  

    std::string sout{"alpha and beta"}; 

    std::chrono::time_point<std::chrono::system_clock> start, end;
    start = std::chrono::system_clock::now();

    void *cont_req = zmq_ctx_new ();
    assert (cont_req != NULL);    

	auto handle_snd = std::async(std::launch::async, snd_string, cont_req, ZMQ_DEALER, "tcp://localhost:5590", sout);
    std::cout << "=======================" << std::endl;
    std::cout <<" Message snd: " << sout << std::endl;

    ///=========================================================================
    void *cont_rep = zmq_ctx_new ();
    assert (cont_rep != NULL);  

	auto handle_rcv = std::async(std::launch::async, rcv_string, cont_rep, ZMQ_DEALER, "tcp://*:5590");

    std::cout <<" Message rcv: " << handle_rcv.get() << std::endl;
    std::cout << "=======================" << std::endl;
    ind = zmq_ctx_destroy (cont_rep);
    assert (ind == 0);

    end = std::chrono::system_clock::now();
    std::chrono::duration<double> elapsed_seconds = end-start;
    std::time_t end_time = std::chrono::system_clock::to_time_t(end);

    std::cout << "Elapsed time = " << elapsed_seconds.count() << " sec\n";

    return 0;
}