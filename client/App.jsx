import { useEffect, useState } from 'react'
import { Login } from './components/Login'
import { Home } from './Home'
import { RoleReveal } from './components/RoleReveal'
import { QuestionAnswer } from './components/QuestionAnswer'
import { ChipChoosing } from './components/ChipChoosing'
import { Voting } from './components/Voting'

import useWebSocket from 'react-use-websocket'

function App() {
  const [gameState, setGameState] = useState("loginScreen");
  const [username, setUsername] = useState('');
  const [roomCode, setRoomCode] = useState('');
  const [murdererStatus, setMurdererStatus] = useState(false);
  const [uuid, setUuid] = useState('');
  const [currQuestion, setCurrQuestion] = useState()
  const [playerList, setPlayerList] = useState([])
  const [voteList, setVoteList] = useState([])
  const [tokens, setTokens] = useState(0);
  
  const [ws, setWs] = useState(null);

  // const wsUrl = 'ws://XXX.XXX.XXX:8000';

  const { sendJsonMessage, lastMessage, readyState } = useWebSocket(wsUrl, {
    onOpen: () => console.log('WebSocket connection established'),
    onClose: () => console.log('WebSocket connection closed'),
    onError: (error) => console.log(`WebSocket error: ${error.message}`),

    shouldReconnect: (closeEvent) => true, // Automatically attempt to reconnect
  });

  useEffect(() => {
    if (lastMessage !== null) {
      const message = JSON.parse(lastMessage.data);
      handleMessage(message);
    }
  }, [lastMessage]);

  //recieving messages from server
  const handleMessage = (message) => {
    switch (message.type) {
      case 'role_info':
        setUuid(message.uuid);
        setMurdererStatus(message.murderer);
        setGameState("confirmRoles");
        break;
      case 'send_question':
        setCurrQuestion(message)
        setGameState("answeringQuestion")
        break;
      case 'chip_choose_info':
        setGameState("chipChoosing")
        setPlayerList(message.choosingList)
        setTokens(message.tokens)
        break;
      case 'send_to_home':
        setGameState("inLobby")
        break;
      case 'send_vote_now':
        setVoteList(message.voteList)
        setGameState("voting")
        break;
      default:
        console.log('Unhandled message type:', message.type);
    }
  }

  const establishInfoMessage = (roomCode, username) => {
    sendJsonMessage({ 
      "type": "establish_info", 
      "roomCode": roomCode, 
      "username": username, 
      "hosting": false
    });
      setUsername(username);
      setRoomCode(roomCode);
      setGameState("inLobby");
  };
  const roleConfirmationMessage = () => {
    sendJsonMessage({ 
      "type": "confirm_role", 
      "uuid": uuid
    });
      setGameState("inLobby");
  }
  const answerSubmitMessage = (ansLetter) => {
    sendJsonMessage({
        "type": 'send_my_answer',
        'roomCode': roomCode,
        "ansLetter": ansLetter,
        'uuid': uuid
    });
    setGameState("inLobby")
  }
  const chipSubmitMessage = (playersPicked) => {
    sendJsonMessage({
        "type": 'send_my_cc',
        'roomCode': roomCode,
        'playersPicked': playersPicked,
        'victim': murdererStatus, // true if killing, false if shielding
        'uuid': uuid
    });
    setGameState("inLobby")
    console.log("send msg!")
  }
  const voteSubmitMessage = (playerPicked) => {
    sendJsonMessage({
        "type": 'send_my_vote',
        'roomCode': roomCode,
        'playerPicked': playerPicked,
        'uuid': uuid
    });
    setGameState("inLobby")
    console.log("voted!")
  }

  if(gameState=="loginScreen")
    return <Login onSubmit={establishInfoMessage} />;
  else if(gameState=="inLobby")
    return <Home roomCode={roomCode} username={username} />;
  else if(gameState=="confirmRoles")
    return <RoleReveal murderer={murdererStatus} onSubmit={roleConfirmationMessage} />
  else if(gameState=="answeringQuestion")
    return <QuestionAnswer questionM={currQuestion} onSubmit={answerSubmitMessage}/>
  else if(gameState=="chipChoosing")
    return <ChipChoosing murderer={murdererStatus} playerList={playerList} tokens={tokens} onSubmit={chipSubmitMessage}/>
  else if(gameState=="voting")
    return <Voting playerList={voteList} onSubmit={voteSubmitMessage}/>
  
}

export default App
