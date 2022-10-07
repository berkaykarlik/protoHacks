using Sockets
using JSON

clientside = connect(5000)

test1 = JSON.json(Dict("method" => "isPrime","number" => 8)) * "\n"
test2 = JSON.json(Dict("method" => "isPrime","number" => 7)) * "\n"
test3 = JSON.json(Dict("number" => 7)) * "\n"
test4 = JSON.json(Dict("lol" => "lol")) * "\n"
test5 = JSON.json(Dict("method" => "lol")) * "\n"

function test_thread(test)
    function test_func()
        write(clientside, test)
        write(stdout,readline(clientside))
    end
    clientside = connect(5000)
    errormonitor(@async test_func())
end

test_thread(test1)
test_thread(test2)
test_thread(test3)
test_thread(test4)
test_thread(test5)

while true
    sleep(1)
end