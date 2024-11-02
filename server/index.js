const http = require('http');
const {WebSocketServer} = require('ws');

const server = http.createServer();
const wsServer = new WebSocketServer( {server });

const uuidv4 = require('uuid').v4;
const url = require('url')
const port = 8000;

const connections = {};
const users = {};
const rooms = {}; //rooms of uuid [XXXX] = {a1,2,3,4}

// Function to notify the host about the players in the room
const notifyHost = (roomCode) => {
    const room = rooms[roomCode];
    if (room) {
        const host = room.find(uuid => users[uuid].hosting);
        if (host) {
            const hostConnection = connections[host];
            const players = room.filter(uuid => !users[uuid].hosting).map(uuid => users[uuid]);
            hostConnection.send(JSON.stringify({
                type: 'room_info',
                players: players
            }));
        }
    }
};

//SENDING
const tellHost = (roomCode, message) => {
    const room = rooms[roomCode];
    if (room) {
        const host = room.find(uuid => users[uuid].hosting);
        if (host) {
            const hostConnection = connections[host];
            hostConnection.send(JSON.stringify(message));
        }
    }
}

//RECIEVING
const handleMessage = (bytes, uuid) => {
    const message = JSON.parse(bytes.toString());

    switch (message.type) {
        case 'establish_info':
            handleEstablishInfoMessage(message, uuid);
            break;
        case 'role_info':
            handleSimpleMessage(message);
            break;
        case 'confirm_role':
            tellHost(users[message.uuid].roomCode, message);
            break;
        case 'send_question':
            handleSimpleMessage(message);
            break;
        case 'send_my_answer':
            tellHost(users[message.uuid].roomCode, message);
            break;
        case 'chip_choose_info':
            handleSimpleMessage(message);
            break;
        case 'send_my_cc':
            tellHost(users[message.uuid].roomCode, message);
            break;
        case 'send_to_home':
            handleSimpleMessage(message);
            break;
        case 'send_vote_now':
            handleSimpleMessage(message);
            break;
        case 'send_my_vote':
            tellHost(users[message.uuid].roomCode, message);
            break;
        default:
            // Handle unknown message type, if necessary
            console.log('Unknown message type:', message.type);
            break;
    }
    
}

const handleClose = uuid => {
    const user = users[uuid];
    if (user) {
        console.log(`${user.username} disconnected`);
        const roomCode = user.roomCode;
        delete connections[uuid];
        delete users[uuid];

        const room = rooms[roomCode];
        if (room) {
            rooms[roomCode] = room.filter(id => id !== uuid);
            if (rooms[roomCode].length === 0) {
                delete rooms[roomCode];
            } 
        }
        notifyHost(roomCode);
    } else {
        console.log(`${uuid} disconnected`);
    }
};


wsServer.on("connection", (connection, request) => {
    const uuid = uuidv4();

    console.log(uuid);

    connections[uuid] = connection;

    connection.on("message", message => handleMessage(message, uuid));
    connection.on("close", () => handleClose(uuid));
})

const handleEstablishInfoMessage = (message, uuid) => {
    users[uuid] = {
        roomCode: message.roomCode,
        username: message.username,
        hosting: message.hosting,
        uuid: uuid
    };

    if (!rooms[message.roomCode]) {
        rooms[message.roomCode] = [];
    }
    rooms[message.roomCode].push(uuid);

    console.log(`${users[uuid].username} has joined room ${users[uuid].roomCode} as a ${users[uuid].hosting?"host":"player"}!`)

    notifyHost(message.roomCode);
}

const handleSimpleMessage = (message) => {
    const playerConnect = connections[message.uuid];
    playerConnect.send(JSON.stringify(message));
}


server.listen(port, () => {
    console.log(`Server is running on port ${port}!`);
})