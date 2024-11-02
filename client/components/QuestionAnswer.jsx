export function QuestionAnswer({ questionM, onSubmit }) {
    return (
        <>
        
        <p>{questionM.question}</p>

        <button onClick={() => onSubmit("A")}>{questionM.A}</button>
        <br></br>
        <button onClick={() => onSubmit("B")}>{questionM.B}</button>
        <br/>
        <button onClick={() => onSubmit("C")}>{questionM.C}</button>
        <br/>
        <button onClick={() => onSubmit("D")}>{questionM.D}</button>
        </>
    )
}