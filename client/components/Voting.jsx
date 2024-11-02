import { useState } from "react";

export function Voting({ onSubmit, playerList }) {
    return (
        <>
            <h2>Vote for who you think is the killer...</h2>

            
            {playerList.map((player) => (
                <div>
                    <button onClick={() => onSubmit(player)}>{player}</button>
                    <br/>
                </div>
            ))}
            <button onClick={() => onSubmit("vote_skip")}>SKIP VOTE</button>
        </>
    );
}
