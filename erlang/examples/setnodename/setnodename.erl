%%%
%%% A convinient script to set nodename.
%%%
-module(setnodename).
-export([start/1]).
-export([stop/0]).
-export([setname/2]).

start(_Args=[LongNodeName, Cookie]) ->
    %% Note that LongNodeName and Cookie are passed as atom
    setname(LongNodeName, Cookie).

stop() ->
    net_kernel:stop(),
    io:format("de-registered from epmd.~n").

setname(LongNodeName, Cookie) ->
    {ok, _Pid} = net_kernel:start([LongNodeName, longnames]),
    true = erlang:set_cookie(node(), Cookie),
    io:format("Successfully set node name ~w~n", [node()]).
