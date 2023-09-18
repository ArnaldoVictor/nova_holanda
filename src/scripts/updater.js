const axios = require('axios')
const { JSDOM } = require('jsdom')
const fs = require('fs')

const baseUrl = 'https://www.ntoultimate.com.br'
const uriNovaHolanda = `${baseUrl}/guilds.php?name=NoVa%20HoLaNDa`
const uriSideBySide = `${baseUrl}/guilds.php?name=Side%20by%20Side`


const getMembersFrom = async (guild) => {
    return await axios
        .get(guild)
        .then((res) => {
            const html = res.data
    
            const dom = new JSDOM(html, {
                runScripts: "dangerously",
                resources: "usable"
            })
    
            const document = dom.window.document
            
            const members = document.querySelectorAll("#guildViewTable td a")
            
            const updatedMemberList = []
    
            members.forEach((member) => {
                updatedMemberList.push(member.innerHTML)
            })
    
            return updatedMemberList

        })
        .catch((err)=>{
            console.log(err)
        })

}

const getAllFriends = async () => {
    const novaHolandaMembers =  await getMembersFrom(uriNovaHolanda)
    const sideBySideMembers =  await getMembersFrom(uriSideBySide)
    const data = fs.readFileSync('./src/data/friends.json')

    const makers = JSON.parse(data.toString()).makers

    const friends = {
        novaHolanda: novaHolandaMembers,
        sideBySide: sideBySideMembers,
        makers: makers
    }

    return friends

}


const updateFriendsFile = async () => {
    
    const friends = await getAllFriends()

    const jsonOject = JSON.stringify(friends, null, 4)

    fs.writeFile('./src/data/friends.json', jsonOject, 'utf8', (err) => {
        if (err)
            console.log(err)
    })

}

updateFriendsFile()
