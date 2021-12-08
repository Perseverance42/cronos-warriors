import Wallet from './wallet.js';
import Treasury from './treasury.js';
import Compute from './compute.js';

const contractKey = "WarriorFactory";

const factory = {
    mintWarrior(warriorName){
        return new Promise(function(resolve,reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  

            Wallet.loadContract(contractKey).then(contractInstance=>{
                contractInstance.methods.mint(warriorName).send({from: Wallet.$currentWalletAddr, value: "50000000000000000000"}).then(result=>{
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
    },
    burnWarrior(warriorID, recipient){
        return new Promise(function(resolve,reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  

            Wallet.loadContract(contractKey).then(contractInstance=>{
                contractInstance.methods.burn(warriorID, recipient).send({from: Wallet.$currentWalletAddr}).then(result=>{
                    console.log("WarriorFactory burn: ", result);
                    resolve(result);
                }).catch(e=>{
                    console.error("WarriorFactory burn: ", e);
                    reject(e);
                });
            }).catch(e=>{
                console.error("WarriorFactory burn: ", e);
                reject(e);
            });
        });
    },
    replenishWarrior(warriorID){
        return new Promise(function(resolve,reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));
            
            Treasury.experience(warriorID).then(ep=>{
                const replenishFee = Compute.mintFee.sub(new Compute.BN(ep));
                console.log("replenish fee is ", replenishFee);
                Wallet.loadContract(contractKey).then(contractInstance=>{
                    contractInstance.methods.replenish(warriorID).send({from: Wallet.$currentWalletAddr, value: replenishFee}).then(result=>{
                        console.log("WarriorFactory replenish: ", result);
                        resolve(result);
                    }).catch(e=>{
                        console.error("WarriorFactory replenish: ", e);
                        reject(e);
                    });
                }).catch(e=>{
                    console.error("WarriorFactory replenish: ", e);
                    reject(e);
                });
            }).catch(e=>{
                console.error("WarriorFactory replenish: ", e);
                reject(e);
            })
        });
    },
}
export default factory;