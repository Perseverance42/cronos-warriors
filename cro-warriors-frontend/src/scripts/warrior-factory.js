import Wallet from './wallet.js';

const contractKey = "WarriorFactory";

const factory = {
    mintWarrior(warriorName){
        return new Promise(function(resolve,reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  

            Wallet.loadContract(contractKey).then(contractInstance=>{
                contractInstance.methods.mint(warriorName).send({from: Wallet.$currentWalletAddr, value: "1000000000000000000"}).then(result=>{
                    console.log("WarriorFactory mint: ", result);
                    resolve(result);
                }).catch(e=>{
                    console.error("WarriorFactory mint: ", e);
                    reject(e);
                });
            }).catch(e=>{
                console.error("WarriorFactory mint: ", e);
                reject(e);
            });
        });
    }
}
export default factory;