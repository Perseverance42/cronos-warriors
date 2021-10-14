import Wallet from './wallet.js';

const contractKey = "WarriorVisuals";

const warriorVisuals = {
    warriorName(warriorID){
        return new Promise(function(resolve,reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  

            Wallet.loadContract(contractKey).then(contractInstance=>{
                contractInstance.methods.warriorName(warriorID).call().then(result=>{
                    console.log("WarriorVisuals name: ", result);
                    resolve(result);
                }).catch(e=>{
                    console.error("WarriorVisuals name: ", e);
                    reject(e);
                });
            }).catch(e=>{
                console.error("WarriorVisuals name: ", e);
                reject(e);
            });
        });
    },
    warriorDNA(warriorID){
        return new Promise(function(resolve,reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  

            Wallet.loadContract(contractKey).then(contractInstance=>{
                contractInstance.methods.warriorDNA(warriorID).call().then(result=>{
                    console.log("WarriorVisuals dna: ", result);
                    resolve(result);
                }).catch(e=>{
                    console.error("WarriorVisuals dna: ", e);
                    reject(e);
                });
            }).catch(e=>{
                console.error("WarriorVisuals dna: ", e);
                reject(e);
            });
        });
    }
}
export default warriorVisuals;