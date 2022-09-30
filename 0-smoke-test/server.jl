#use julia v1.8.2+, 1.6.7 wasn't supporting half-duplex sockets which failed the code.
using Sockets

function process(sock)
    data = UInt8[]
    while true
        c = read(sock,1024)
        if isempty(c)
            break
        end
        data = vcat(data,c)
    end
    write(sock,data)
    close(sock)
end


begin
    server = listen(IPv4(0),5000)
    while true
        sock = accept(server)
        errormonitor(@async process(sock))
    end
end
