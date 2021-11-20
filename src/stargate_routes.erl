-module(stargate_routes).

-export([start/0,
         lookup/2]).

start() ->
    PrivDir = code:priv_dir(stargate),
    {ok, FileBin} = file:read_file(PrivDir ++ "/routes/endpoints.json"),
    #{<<"endpoints">> := Endpoints} = json:decode(FileBin, [maps]),
    insert_routes(Endpoints).

insert_routes([]) ->
    ok;
insert_routes([#{<<"endpoint">> := Endpoint,
                 <<"method">> := Method,
                 <<"backend">> := Backend}| T]) ->
    Key = binary_to_list(<<Endpoint/binary, ".", Method/binary>>),
    logger:debug("insert key: ~p", [Key]),
    logger:debug("backend: ~p", [Backend]),
    Response = khepri:insert(Key, Backend),
    logger:debug("response: ~p", [Response]),
    insert_routes(T).

lookup(Path, Method) ->
    Key = binary_to_list(<<Path/binary, ".", Method/binary>>),
    khepri:get(Key).