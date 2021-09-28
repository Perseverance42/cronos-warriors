import Wallet from './wallet.js';

const contractKey = "Treasury";

const battleBoard = {
    loadExperience(warriorID){
        return new Promise(function(resolve,reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  

            Wallet.loadContract(contractKey).then(contractInstance=>{
                contractInstance.methods.experience(warriorID).call().then(result=>{
                    console.log("Treasury experience: ", result);
                    resolve(result);
                }).catch(e=>{
                    console.error("Treasury experience: ", e);
                    reject(e);
                });
            }).catch(e=>{
                console.error("Treasury experience: ", e);
                reject(e);
            });
        });
    }
}
export default battleBoard;