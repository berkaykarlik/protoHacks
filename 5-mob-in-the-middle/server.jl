using Sockets



function alter_boguscoin(m::String)::String
    pattern = r"(^|(?<=\s))(7\w{25,35})((?=\s)|$)"
    m = replace(m, pattern => "7YWHMfk9JZe0LM0g1ZauHuiSxhI")
    return m
end

function flow_one_way(down_stream::TCPSocket,up_stream::TCPSocket)
    try
        while true
            if isopen(down_stream) == false
                break
            end
            msg = readline(down_stream,keep=true)
            altered_msg = alter_boguscoin(msg)
            if isopen(up_stream) == false
                break
            end
            write(up_stream,altered_msg)
        end
    catch e
        println("$(username) disconnected $(e)")
    end
    close(up_stream)
    close(down_stream)
end

function session(down_stream::TCPSocket)
    println("client connected")

    up_stream = connect("chat.protohackers.com",16963)

    errormonitor(@async flow_one_way(down_stream,up_stream))
    errormonitor(@async flow_one_way(up_stream,down_stream))

end


begin
    server = listen(IPv4(0),5000)
    while true
        sock = accept(server)
        errormonitor(@async session(sock))
    end
end
