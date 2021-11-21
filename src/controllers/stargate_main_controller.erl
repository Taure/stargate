-module(stargate_main_controller).
-export([
         index/1
        ]).

-include_lib("nova/include/nova.hrl").

index(#{method := <<"POST">> = Method,
        path := Path,
        body := Body} = Req) when Method =:= <<"POST">> orelse
                                  Method =:= <<"PUT">> ->
   logger:debug("Path: ~p Method: ~p Body: ~p", [Path, Method, Body]),
   {ok, BackendCalls} = stargate_routes:lookup(Path, Method),
   Data = get_data(BackendCalls),
   Responses = do_body_request(Data, Req, Body),
   {json, 200, #{}, Responses};
index(#{method := Method,
        path := Path} = Req) ->
    {ok, BackendCalls} = stargate_routes:lookup(Path, Method),
    Data = get_data(BackendCalls),
    Responses = do_request(Data, Req),
    {json, 200, #{}, Responses}.

do_request([], _) ->
   [];
do_request([#{<<"url_pattern">> := Url,
              <<"method">> := Method,
              <<"host">> := Host} | T], Req) ->
   AtomMethod = to_function(Method),
   #{body := Response} = shttpc:AtomMethod([Host, "/", Url], opts()),
   [json:decode(Response, [maps])] ++ do_request(T, Req).

do_body_request([], _, _) ->
   [];
do_body_request([#{<<"url_pattern">> := Url,
              <<"method">> := Method,
              <<"host">> := Host} | T], Req, Body) ->
   AtomMethod = to_function(Method),
   #{body := Response} = shttpc:AtomMethod([Host, "/", Url], Body, opts()),
   [json:decode(Response, [maps])] ++ do_body_request(T, Req, Body).


opts() ->
   opts(undefined).
opts(undefined) ->
   #{headers => #{'Content-Type' => <<"application/json">>}, close => true}.

to_function(<<"GET">>) -> get;
to_function(<<"POST">>) -> post;
to_function(<<"PUT">>) -> put;
to_function(<<"DELETE">>) -> delete.

get_data(BackendCalls) ->
   [Key] = maps:keys(BackendCalls),
    #{data := Data} = maps:get(Key, BackendCalls, []),
    Data.