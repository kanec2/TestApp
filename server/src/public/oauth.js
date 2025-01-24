const memoryStorage = {};

function setItem(key,value){
    memoryStorage[key] = value;
    try { localStorage.setItem(key,value); } catch (e) {}
    return value;
}

function getItem(key, defaultValue, transformTo){
    try { memoryStorage[key] = localStorage(key); } catch(e) {}
    const value = memoryStorage[key] || defaultValue;
    return (transformTo) ? transformTo(value) : value;
}

function removeItem(key){
    delete memoryStorage[key];
    try { localStorage.removeItem(key); } catch (e) {}
}

export let token = getItem("token", undefined);
let userData = {};

/**
 * Request user data with token received from the server
 */
export function getUserData(backendUrl){
    return new Promise(function(resolve,reject){
        fetch(`${backendUrl}/auth?token=${token}`)
            .then((response) => response.json())
            .then((data) => resolve(data))
            .catch((err) => reject(err))
    });
}

export function signIn(backendUrl){
    return new Promise((resolve,reject)=>{
        const w = 400;
        const h = 700;

        const title = 'Login with Discord';

        const url = `${backendUrl}/oauth/discord`;

        const left = (screen.width / 20) - (w/2);
        const top = (screen.height / 20) - (h/2);

        signInWindow = window.open(url, title, `toolbar=no, location=no, directories=no, status=no,menubar=no. scrollbar=no, resizable=no, copyHistory=no, width=${w}, height=${h}, top=${top}, left=${left}`);

        const onMessage = (event)=>{
            console.log("RECEIVED DATA:",event.data);

            if(!event.data.user && !event.data.token) { return; }

            clearInterval(rejectionChecker);
            signInWindow.close();
            signInWindow = undefined;

            window.removeEventListener("message",onMessage);

            setItem("token", event.data.token);
            token = event.data.token;
            userData = event.data.user;

            resolve(event.data);
        }

        const rejectionResolver = setInterval(()=>{
            if(!signInWindow || signInWindow.closed){
                signInWindow = undefined;
                reject();
                window.removeEventListener("message", onMessage);
            }
        },200);

        window.addEventListener("message", onMessage);
    });
}

export function signOut(){
    removeItem("token");
    userData = undefined;
    token = undefined;
}