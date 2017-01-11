#include <zmq.h>

#include <cassert>
#include <cstring>
#include <iostream>
#include <chrono>
#include <ctime>
///=========================================================================
// double
///=========================================================================
auto snd_double (void *context, int type, const char * endpoint, const double db) -> void
{
    int ind{0}; 

    void *socket = zmq_socket (context, type);
    ind = zmq_connect (socket, endpoint);
    assert (ind == 0);

    zmq_msg_t message;

    ind = zmq_msg_init_size (&message, sizeof(db));
    assert (ind == 0);
 
    std::memcpy(zmq_msg_data(&message), &db, sizeof(double) );  

    ind = zmq_msg_send (&message, socket, 0);
    assert (ind > 0);

    ind = zmq_close (socket);
    assert (ind == 0);
}
//
auto rcv_double (void *context, int type, const char * endpoint) -> double
{
    int ind{0}; 
    double d{0};

    void *socket = zmq_socket (context, type);
    ind = zmq_bind (socket, endpoint);
    assert (ind == 0);

    zmq_msg_t message;

    ind = zmq_msg_init (&message);
    assert (ind == 0);
    ind = zmq_msg_recv (&message, socket, 0);
    assert (ind != -1);

    d = *static_cast<double *>(zmq_msg_data(&message));

    ind = zmq_msg_close (&message);
    assert (ind == 0);

    ind = zmq_close (socket);
    assert (ind == 0);

    return d;
}
//
int main(int argc, char *argv[])
{
    int ind{0};  

    double dout{47.393476422873754}; 

    std::chrono::time_point<std::chrono::system_clock> start, end;
    start = std::chrono::system_clock::now();

    void *context = zmq_ctx_new ();
    assert (context != NULL);    

    snd_double(context, ZMQ_REQ, "tcp://localhost:5580", dout);
    std::cout << "=======================" << std::endl;
    std::cout <<" Message snd: " << dout << std::endl;
    ///=========================================================================

    decltype( dout ) din;

    ///=========================================================================
    void *cont_rep = zmq_ctx_new ();
    din = rcv_double (context, ZMQ_REP, "tcp://*:5580");
    std::cout <<" Message rcv: " << din << std::endl;
    std::cout << "=======================" << std::endl;
    ind = zmq_ctx_destroy (context);
    assert (ind == 0);

    end = std::chrono::system_clock::now();
    std::chrono::duration<double> elapsed_seconds = end-start;
    std::time_t end_time = std::chrono::system_clock::to_time_t(end);

    std::cout << "Elapsed time = " << elapsed_seconds.count() << " sec\n";

    return 0;
}