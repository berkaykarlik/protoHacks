import socket
from threading import Thread

def echo(sock):
    with sock:
        while True:
            data = sock.recv(1024)
            if not data:
                break
            sock.sendall(data)
    return 1

serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
serversocket.bind((socket.gethostname(), 5000))

serversocket.listen(5)

while True:
    # accept connections from outside
    (clientsocket, address) = serversocket.accept()
    ct = Thread(target=echo,args=(clientsocket,))
    ct.run()
    print(f"accepted conn from {address}")
