import { useState } from "react";

export function ChipChoosing({ murderer, onSubmit, playerList, tokens }) {
    const [selectedPlayers, setSelectedPlayers] = useState([]);
    const maxSelections = murderer?tokens:Math.floor(tokens/2);

    const handleCheckboxChange = (player) => {
        setSelectedPlayers((prevSelectedPlayers) => {
            if (prevSelectedPlayers.includes(player)) {
                return prevSelectedPlayers.filter((p) => p !== player);
            } else if (prevSelectedPlayers.length < maxSelections) {
                return [...prevSelectedPlayers, player];
            }
            return prevSelectedPlayers;
        });
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        onSubmit(selectedPlayers);
    };
    
    return (
        <>
            <h2>Select who to {murderer ? "kill" : "protect"}. Or... just do nothing.</h2>
            <h3>You have {tokens} token{tokens!=1 ? "s" : ""}, so you can {murderer ? "kill" : "protect"} up to {maxSelections} player{maxSelections!=1 ? "s" : ""}.</h3>
            
            
            <form onSubmit={handleSubmit}>
                {playerList.map((player) => (
                    <div key={player}>
                        <label>
                            <input
                                type="checkbox"
                                value={player}
                                checked={selectedPlayers.includes(player)}
                                onChange={() => handleCheckboxChange(player)}
                                disabled={!selectedPlayers.includes(player) && selectedPlayers.length >= maxSelections}
                            />
                            {player}
                        </label>
                    </div>
                ))}
                <input type="submit" value="OK" />
            </form>
        </>
    );
}
