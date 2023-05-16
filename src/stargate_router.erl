-module(stargate_router).

-export([create_routes/1,
         lookup/2]).

create_routes(App) ->
    PrivDir = code:priv_dir(App),
    {ok, FileBin} = file:read_file(PrivDir ++ "/routes/endpoints.json"),
    Routes = json:decode(FileBin, [maps]),
    GenRoutes = generate_routes(Routes),
    logger:debug("GenRoutes: ~p", [GenRoutes]),
    GenRoutes.

generate_routes([]) ->
    [];
generate_routes([#{<<"prefix">> := Prefix,
                   <<"security">> := Security,
                   <<"routes">> := Routes} | Tail]) ->
    Security2 = case Security of
                     false -> false;
                     #{<<"module">> := SecModule,
                       <<"function">> := SecFunction} -> {binary_to_atom(SecModule), binary_to_atom(SecFunction)}
                end,
    GenRoutes = insert_routes(Routes),
    [#{prefix => binary_to_list(Prefix),
       security => Security2,
       routes => GenRoutes}] ++ generate_routes(Tail).

insert_routes([]) ->
    [];
insert_routes([#{<<"endpoint">> := Endpoint,
                 <<"method">> := Method,
                 <<"module">> := Module,
                 <<"function">> := Function,
                 <<"backend">> := Backend}| T]) ->
    Path = binary_to_list(Endpoint),
    AtomMethod = binary_to_atom(Method),
    Key = binary_to_list(<<Endpoint/binary, ".", Method/binary>>),
    AtomModule = binary_to_atom(Module),
    AtomFunction = binary_to_atom(Function),
    ok = persistent_term:put(Key, Backend),
    [{Path, {AtomModule, AtomFunction}, #{methods => [AtomMethod]}}] ++ insert_routes(T).

lookup(Path, Method) ->
    Key = binary_to_list(<<Path/binary, ".", Method/binary>>),
    persistent_term:get(Key).