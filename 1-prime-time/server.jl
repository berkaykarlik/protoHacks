using Sockets
using JSON


function if_j_then_j(s)
    j = missing
    try
        j = JSON.parse(s)
    catch e
        return false, j
    end
    return true, j
end


function check_fields(j)
    method_val = get(j,"method",missing)
    if ismissing(method_val)
        return false
    end

    number_val = get(j,"number",missing)
    if ismissing(number_val)
        return false
    end

    if method_val != "isPrime"
        return false
    # bool isa Number in julia so thats my hacky check
    elseif !(number_val isa Number && !(number_val isa Bool))
        return false
    end

    return true
end


function is_prime(n)
    if !(n isa Integer)
        return false
    elseif n < 2
        return false
    end

    for i in 2:sqrt(n)
        if (n % i) == 0
            return false
        end
    end
    return true
end


function fail(sock)
    write(sock,"lol\n") #invalid response to invalid request
    close(sock)
end


function log(name,s)
    f =  open("$(name).txt","a")
    write(f,s) * write(f,"\n")
    close(f)
end


function process_sock_req(sock)
    while isopen(sock)
        data = readline(sock)

        if ismissing(data)
            fail(sock)
            errormonitor(@async log("missing",data)) # debug all missing requests
            break
        end

        is_valid_j, j = if_j_then_j(data)

        if !(is_valid_j)
            fail(sock)
            errormonitor(@async log("invalid",data)) # debug all invalid requests
            break
        end

        is_valid_req = check_fields(j)

        if !(is_valid_req)
            fail(sock)
            errormonitor(@async log("missing_req",data * " | " * JSON.json(j) )) # debug all missing key requests
            break
        end

        res_json = JSON.json(Dict("method" => "isPrime","prime" => is_prime(j["number"]))) * "\n"
        errormonitor(@async log("conforming",data * " | " * JSON.json(j) )) # debug all conforming requests
        write(sock,res_json)

    end
end


begin
    server = listen(IPv4(0),5000)
    while true
        sock = accept(server)
        errormonitor(@async process_sock_req(sock) )
    end
end
