using Sockets
using JSON

# clientside = connect(5000)

test1 = [0x49,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01]

function test_thread(test)
    function test_func()
        write(clientside, test)
        write(stdout,readline(clientside))
    end
    clientside = connect(5000)
    errormonitor(@async test_func())
end

test_thread(test1)
# test_thread(test2)


while true
    sleep(1)
end