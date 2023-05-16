-module(stargate_main_controller).
-export([
         index/1
        ]).

index(#{method := <<"POST">> = Method,
        path := Path,
        body := Body} = Req) ->
   logger:debug("Path: ~p Method: ~p Body: ~p", [Path, Method, Body]),
   BackendCalls = stargate_router:lookup(Path, Method),
   Responses = do_request(BackendCalls, Req, Body, []),
   {json, 200, #{}, Responses};
index(#{method := Method,
        path := Path} = Req) ->
    BackendCalls = stargate_router:lookup(Path, Method),
    Responses = do_request(BackendCalls, Req, undefined, []),
    ResponseBody = parse_response(Responses),
    {status, 200, #{}, ResponseBody}.

do_request([], _, _, Response) ->
   Response;
do_request([#{<<"url_pattern">> := Url,
              <<"method">> := Method,
              <<"host">> := Host} | T], Req, Body, Response) ->
   AtomMethod = to_function(Method),
   RequestResponse = case Body of
                          undefined -> shttpc:AtomMethod([Host, Url], opts(Method));
                          Body -> shttpc:AtomMethod([Host, Url], Body, opts(Method))
                     end,
   do_request(T, Req, Body, [RequestResponse|Response]).

parse_response([#{body := Body}]) ->
   Body.

opts(<<"GET">>) ->
   #{headers => #{}, close => true};
opts(_) ->
   #{headers => #{'Content-Type' => <<"application/json">>}, close => true}.


to_function(<<"GET">>) -> get;
to_function(<<"POST">>) -> post;
to_function(<<"PUT">>) -> put;
to_function(<<"DELETE">>) -> delete.