-module(test).
-export([start/0, stop/0, send/1]).

%%-----------------------------------------------------------------------------
%% public API

start() ->
    spawn(fun start_port/0).

stop() ->
    ?MODULE ! quit.

send(Msg) ->
    ?MODULE ! {send, Msg}.


%%-----------------------------------------------------------------------------

start_port() ->
    register(?MODULE, self()),
    process_flag(trap_exit, true),
    Pgm = handle_find_exe_result(os:find_executable("python")),
    Port = open_port({spawn_executable, Pgm}, open_port_params()),
    loop(Port).

handle_find_exe_result(false) -> error(python_not_found);
handle_find_exe_result(Pgm) -> Pgm.

open_port_params() ->
    [
        use_stdio,
        stream,
        hide,
        {line, 80},
        {args, ["-u", "test.py"]}
    ].

loop(Port) ->
    receive
        quit ->
            log("self", "quitting on user request"),
            true = port_close(Port),
            loop(Port);

        {send, Msg} ->
            port_command(Port, Msg ++ [10]),
            loop(Port);

        {'EXIT', Port, _} ->
            log("self", "port closed");

        Msg ->
            log("ext", Msg),
            loop(Port)
    end.

log(Msg, Args) ->
    io:format("[~s]: ~p~n", [Msg, Args]).
