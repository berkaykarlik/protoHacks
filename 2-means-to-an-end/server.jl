using Sockets

function check_msg_type(s::Vector{UInt8})::Union{String, Nothing}
    if isempty(s)
        return nothing
    elseif Char(s[1]) == 'I'
        return "insertion"
    elseif Char(s[1]) == 'Q'
        return "query"
    else
        return nothing
    end
end

function bytes_to_int32(s::Vector{UInt8})::Int32
    num =   Int32(s[end])
    num |=  Int32(s[end-1]) << 8
    num |=  Int32(s[end-2]) << 16
    num |=  Int32(s[end-3]) << 24
    return num
end

function int32_to_bytes(i::Int32)::Vector{UInt8}
    mask = UInt8(255)
    ui8_1 = UInt8(i & mask)
    ui8_2 = UInt8(i >> 8 & mask)
    ui8_3 = UInt8(i >> 16 & mask)
    ui8_4 = UInt8(i >> 24 & mask)
    return [ui8_4,ui8_3,ui8_2,ui8_1]
end

function session(sock::Sockets.TCPSocket)
    db = Vector{Tuple{Int32,Int32}}()

    function insert(time::Int32,price::Int32)
        if isempty(db)
            insert!(db,1,(time,Int64(price)))
            return
        end

        for n in eachindex(db)
            if db[n][1] == time
                return false
            end
            if db[n][1] > time
                insert!(db,n,(time,Int64(price)))
                return true
            end
        end
        push!(db,(time,price))
    end

    function query(min::Int32,max::Int32)::Int32
        if min > max
            return 0
        end
        excluded_lower=filter(x-> x[1] >= min, db)
        valid_range=filter(x-> x[1] <= max, excluded_lower)

        if isempty(valid_range)
            return 0
        end

        total_sum=mapreduce(x -> x[2] ,+,valid_range)
        return Int32(floor(total_sum / length(valid_range)))
    end

    while true
        c = read(sock,9)
        msg_type = check_msg_type(c)

        if isnothing(msg_type)
            break
        end

        st = bytes_to_int32(c[2:5])
        nd = bytes_to_int32(c[6:9])

        if msg_type == "insertion"
            is_inserted = insert(st,nd)
            if is_inserted == false
                break
            end
        elseif msg_type == "query"
            mean_price = query(st,nd)
            response = int32_to_bytes(mean_price)
            write(sock,response)
        end

    end
    close(sock)
end


begin
    server = listen(IPv4(0),5000)
    while true
        sock = accept(server)
        errormonitor(@async session(sock))
    end
end
