import Wallet from './wallet.js';

const warriors = {
    loadWarriorByOwnerIndex(address, index){
        return new Promise(function(resolve, reject) {
            if(Wallet.$web3 == null) reject(new Error('No Wallet'));  
        
            Wallet.loadContract("CronosWarriors").then(contractInstance=>{
                contractInstance.methods.tokenOfOwnerByIndex(address, index).call().then(result=>{
                    console.log("CronosWarriors tokenOfOwnerByIndex: ", result);
                    resolve(result);
                }).catch(e=>{
                    console.error("CronosWarriors tokenOfOwnerByIndex: ", e);
                    reject(e);
                });
            }).catch(e=>{
                reject(e);
            });
        });
    },
    balanceOfAddr(address){
        return new Promise(function(resolve, reject){
            if(Wallet.$web3 == null) reject(new Error('No Wallet')); 
            
            Wallet.loadContract("CronosWarriors").then(contractInstance=>{
                contractInstance.methods.balanceOf(address).call().then(result=>{
                    console.log("CronosWarriors balanceOf: ", result);
                    resolve(result);
                }).catch(e=>{
                    console.error("CronosWarriors balanceOf: ", e)
                    reject(e);
                });
            }).catch(e=>{
                console.error("CronosWarriors balanceOf: ", e)
                reject(e);
            });
        });
    },
    loadArmyByAddr(address){
        return new Promise(function(resolve, reject){
            if(Wallet.$web3 == null) reject(new Error('No Wallet')); 
            warriors.balanceOfAddr(address).then(count=>{
                let armySize = parseInt(count);
                let army = new Array();
                for(let i=0;i<armySize;i++){
                    warriors.loadWarriorByOwnerIndex(address, i).then(id=>{
                        army[i] = id;
                        if(i==armySize-1){
                            resolve(army);
                        }
                    }).catch(e=>{
                        reject(e);
                    });
                }
            }).catch(e=>{
                reject(e);
            });
        });
    },
    ownerOf(warriorID){
        return new Promise(function(resolve, reject){
            if(Wallet.$web3 == null) reject(new Error('No Wallet')); 
            
            Wallet.loadContract("CronosWarriors").then(contractInstance=>{
                contractInstance.methods.ownerOf(warriorID).call().then(result=>{
                    console.log("CronosWarriors ownerOf: ", result);
                    resolve(result);
                }).catch(e=>{
                    console.error("CronosWarriors ownerOf: ", e)
                    reject(e);
                });
            }).catch(e=>{
                console.error("CronosWarriors ownerOf: ", e)
                reject(e);
            });
        });
    }
}

export default warriors;