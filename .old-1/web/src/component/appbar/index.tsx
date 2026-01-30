import { useLocation, useNavigate } from "react-router-dom"

interface Props {
    title: string
}

export const Appbar = (props: Props) => {
    const location = useLocation()
    const navigate = useNavigate()

    const handleGoBack = () => {
        navigate(-1)
    }

    return (
        <>
            <div className="w3-top">
                <div className="w3-bar w3-black">
                    {location.pathname != '/events' && <button className="w3-bar-item w3-button w3-black" onClick={handleGoBack}>
                        &#8592;
                    </button>}
                    <div className="w3-bar-item">
                        {props.title}
                    </div>
                </div>
            </div>
            <br/>
            <br/>
        </>
    )
}
