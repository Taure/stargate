-module(stargate_main_controller).
-export([
         index/1
        ]).

-include_lib("nova/include/nova.hrl").

index(#{method := Method,
        path := Path} = Req) ->
    {ok, BackendCalls} = stargate_routes:lookup(Path, Method),
    [Key] = maps:keys(BackendCalls),
    #{data := Data} = maps:get(Key, BackendCalls, []),
    logger:debug("Backend: ~p", [Data]),
    Responses = do_request(Data, Req),
    logger:debug("Responses: ~p", [Responses]),
    {json, 200, #{}, Responses}.

do_request([], _) ->
   [];
do_request([#{<<"url_pattern">> := Url,
              <<"method">> := Method,
              <<"host">> := Host} | T], Req) ->
   AtomMethod = to_function(Method),
   #{body := Response} = shttpc:AtomMethod([Host, "/", Url], opts()),
   [json:decode(Response, [maps])] ++ do_request(T, Req).

opts() ->
   opts(undefined).
opts(undefined) ->
   #{headers => #{'Content-Type' => <<"application/json">>}, close => true}.

to_function(<<"GET">>) -> get.