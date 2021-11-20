-module(stargate_main_controller).
-export([
         index/1
        ]).

-include_lib("nova/include/nova.hrl").

index(#{method := Method,
        path := Path} = Req) ->
    BackendCalls = stargate_routes:lookup(Path, Method),
    logger:debug("Backend: ~p", [BackendCalls]),
    {ok, Responses} = do_request(BackendCalls, Req),
    {json, 200, #{}, Responses}.

do_request([], _) ->
   [];
do_request([#{<<"url_pattern">> := Url,
              <<"method">> := Method,
              <<"host">> := Host} | T], Req) ->
   AtomMethod = binary_to_atom(Method),
   Response = shttpc:AtomMethod([Host, "/", Url], opts()),
   [Response] ++ do_request(T, Req).

opts() ->
   opts(undefined).
opts(undefined) ->
   #{headers => #{'Content-Type' => <<"application/json">>}, close => true}.