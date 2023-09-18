import { updateFriendsFile } from './scripts/updater.js'

const startServer = () => {

    console.log("Server Started!")

    updateFriendsFile()
    
    setInterval(
        () => updateFriendsFile(),
    1000*60*60)
}

startServer()
