import { useState } from "react"

export function Login({ onSubmit }) {
    const [username, setUsername] = useState("");
    const [roomCode, setRoomCode] = useState("");
    return (
        <>




        <h1>Skool'd</h1>

            <p>Join a game!</p>
                <form
                    onSubmit={(e) => {
                        e.preventDefault()
                        onSubmit(roomCode, username)
                    }}
                >
                <input
                    type="text"
                    value={username}
                    placeholder="NAME"
                    id="username"
                    autocapitalize="off"
                    autocorrect="off"
                    autocomplete="off"
                    maxlength="12"
                    onChange={(e) => setUsername(e.target.value)}
                />
                <br></br>
                <input
                    type="text"
                    value={roomCode}
                    placeholder="ROOM CODE"
                    id="roomCode"
                    autocapitalize="on"
                    autocorrect="off"
                    autocomplete="off"
                    maxlength="4"
                    onChange={(e) => setRoomCode(e.target.value)}
                />
                <br></br>
                <input type="submit" />
                </form>

        </>
    )
}