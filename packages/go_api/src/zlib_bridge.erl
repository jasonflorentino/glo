-module(zlib_bridge).
-export([gunzip/1]).

gunzip(Data) ->
    try
        Decompressed = zlib:gunzip(Data),
        {ok, Decompressed}
    catch
        _:_ ->
            {error, <<"Failed to decompress data">>}
    end.
