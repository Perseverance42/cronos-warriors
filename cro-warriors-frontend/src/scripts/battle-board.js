import Wallet from './wallet.js';

const contractKey = "BattleBoard";

const battleBoard = {
    challangeWarrior(attackerID, defenderID){
        return new Promise(function(resolve,reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  

            Wallet.loadContract(contractKey).then(contractInstance=>{
                contractInstance.methods.challangeWarrior(attackerID, defenderID).send({from: Wallet.$currentWalletAddr}).then(result=>{
                    console.log("BattleBoard challangeWarrior: ", result);
                    resolve(result);
                }).catch(e=>{
                    console.error("BattleBoard challangeWarrior: ", e);
                    reject(e);
                });
            }).catch(e=>{
                console.error("BattleBoard challangeWarrior: ", e);
                reject(e);
            });
        });
    },
    confirmBattleRequest(attackerID, defenderID){
        return new Promise(function(resolve,reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  

            Wallet.loadContract(contractKey).then(contractInstance=>{
                contractInstance.methods.acceptBattleRequest(attackerID, defenderID).send({from: Wallet.$currentWalletAddr}).then(result=>{
                    console.log("BattleBoard acceptBattleRequest: ", result);
                    resolve(result);
                }).catch(e=>{
                    console.error("BattleBoard acceptBattleRequest: ", e);
                    reject(e);
                });
            }).catch(e=>{
                console.error("BattleBoard acceptBattleRequest: ", e);
                reject(e);
            });
        });
    },
    denyBattleRequest(defenderID, attackerID){
        return new Promise(function(resolve,reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  
            Wallet.loadContract(contractKey).then(contractInstance=>{
                    contractInstance.methods.denyBattleRequest(defenderID, attackerID).send({from: Wallet.$currentWalletAddr}).then(result=>{
                        resolve(result);
                        console.log("BattleBoard denyBattleRequest: ", result);
                    }).catch(e=>{
                        console.error("BattleBoard denyBattleRequest: ", e);
                        reject(e);
                    })
            }).catch(e=>{  
                console.error("BattleBoard denyBattleRequest: ", e);
                reject(e);
            });
        });
    },
    withdrawBattleRequest(attackerID, defenderID){
        return new Promise(function(resolve,reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  
            Wallet.loadContract(contractKey).then(contractInstance=>{
                console.log(contractInstance);
                    contractInstance.methods.withdrawBattleRequest(attackerID, defenderID).send({from: Wallet.$currentWalletAddr}).then(result=>{
                        resolve(result);
                        console.log("BattleBoard withdrawBattleRequest: ", result);
                    }).catch(e=>{
                        console.error("BattleBoard withdrawBattleRequest: ", e);
                        reject(e);
                    })
            }).catch(e=>{  
                console.error("BattleBoard withdrawBattleRequest: ", e);
                reject(e);
            });
        });
    },
    isBattleRequestValid(attackerID, defenderID){
        return new Promise(function(resolve,reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  
            Wallet.loadContract(contractKey).then(contractInstance=>{
                contractInstance.methods.isBattleRequestValid(attackerID, defenderID).then(result=>{
                    resolve(result);
                }).catch(e=>{
                    console.error("BattleBoard isBattleRequestValid: ", e);
                    reject(e);
                })
            }).catch(e=>{
                console.error("BattleBoard withdrawBattleRequest: ", e);
                reject(e);
            });
        });
    }
}
export default battleBoard;