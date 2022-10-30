using Sockets


db = Dict("version" => "Ken's Key-Value Store 1.0")

function process_msg(m::String,
                     sock::UDPSocket,
                     sender::Union{Sockets.InetAddr{IPv4},Sockets.InetAddr{IPv6}}
                    )
    delim = '='

    if delim ∈ m
        key, value = split(m, delim; limit=2, keepempty=true)
        if key == "version"
            return
        end
        println(key," <=> ",value)
        db[key] = value
    else
        println("retrive ",m)
        var = get(db,m,"")
        send(sock, sender.host, sender.port, "$(m)=$(var)")
    end
end


socket = Sockets.UDPSocket()
bind(socket, ip"0.0.0.0", 5000)

while true
    hostport, packet = Sockets.recvfrom(socket)
    errormonitor(@async process_msg(String(packet),socket,hostport))
end
