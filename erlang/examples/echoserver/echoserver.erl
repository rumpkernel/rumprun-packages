%%%
%%% A simple echo server
%%%
-module(echoserver).
-author('Neeraj Sharma <neeraj.sharma@alumni.iitg.ernet.in>').
-export([start/0]).

-define(OPTIONS, [{active, false}, {reuseaddr, true}, {packet, 0}]).
-define(PORT, 8080).


start() ->
    {ok, Socket} = gen_tcp:listen(?PORT, ?OPTIONS),
    ListenHandler = spawn(fun() -> accept_a_connection(Socket) end),
    gen_tcp:controlling_process(Socket, ListenHandler),
    io:format("Echo server started~n").

accept_a_connection(Socket) ->
    {ok, ClientSocket} = gen_tcp:accept(Socket),
    ChildPid = spawn(fun() -> handle_client_data(ClientSocket) end),
    gen_tcp:controlling_process(ClientSocket, ChildPid),
    accept_a_connection(Socket).

handle_client_data(ClientSocket) ->
    loop(ClientSocket).

loop(ClientSocket) ->
    case gen_tcp:recv(ClientSocket, 0) of
        {ok, Data} -> handle_client_data(ClientSocket, Data),
                      loop(ClientSocket);
        {error, closed} -> ok
    end.

handle_client_data(ClientSocket, Data) ->
    gen_tcp:send(ClientSocket, Data).
