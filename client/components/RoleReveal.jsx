import { useState } from "react"

export function RoleReveal({ murderer, onSubmit }) {
    return (
        <>
        <h2>Shh!! You are</h2>
        <h1>{murderer?"a murderer":"innocent"}!</h1>

        <form
                onSubmit={(e) => {
                    e.preventDefault()
                    onSubmit()
                }}
            >
            <input type="submit" value="OK"/>
            </form>
        </>
    )
}