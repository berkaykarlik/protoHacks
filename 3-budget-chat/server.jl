using Sockets


users = Dict{String,Channel}()

function is_valid_username(s::String)
    if isempty(s) || length(s) > 16 || s ∈ keys(users)
        return false
    end
        return true
end

function msg_all(sender::String, s::String)
    for user in keys(users)
        if sender != user
        put!(users[user],s)
        end
    end
end

function session(sock)
    println("client connected")

    function inform_user()
        write(sock, "* The room contains:")
        for user in keys(users)
            write(sock,"$(user),")
        end
        write(sock,'\n')
    end

    function get_notifications()
        while true
            notification = take!(users[username])
            println("notifying ", username," with ",notification)
            write(sock,notification)
        end
    end

    write(sock,"Welcome to budgetchat! What shall I call you?\n")

    username = readline(sock)
    is_valid = is_valid_username(username)
    if is_valid == false
        write(sock,"username should consist of more than 1 and less than 16 character, duplicates are not allowed\n")
        close(sock)
    end

    msg_all(username,"* $(username) has entered the room\n")
    inform_user()
    users[username] = Channel(Inf)

    try
        @async get_notifications()
        while true
            if isopen(sock) == false
                break
            end
            msg = readline(sock)
            if isempty(msg) || length(msg) > 1000
                continue
            end
            msg_all(username,"[$(username)] $(msg)\n")
        end
    catch e
        println("$(username) disconnected $(e)")
    end

    delete!(users, username)
    msg_all(username,"* [$(username)] has left the room\n")
end


begin
    server = listen(IPv4(0),5000)
    while true
        sock = accept(server)
        errormonitor(@async session(sock))
    end
end
