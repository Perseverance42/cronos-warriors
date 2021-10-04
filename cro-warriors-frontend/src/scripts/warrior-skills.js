import Wallet from './wallet.js';

const contractKey = "WarriorSkills";

const warriorSkills = {
    increaseAttack(warriorID){
        return new Promise(function(resolve, reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  
            Wallet.loadContract(contractKey).then(contract=>{
                contract.methods.increaseAttack(warriorID).send({from: Wallet.$currentWalletAddr}).then(result=>{
                    resolve(result);
                }).catch(e=>{
                    reject(e);
                });
            }).catch(e=>{
                reject(e);
            })
        });
    },
    increaseDefense(warriorID){
        return new Promise(function(resolve, reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  
            Wallet.loadContract(contractKey).then(contract=>{
                contract.methods.increaseDefense(warriorID).send({from: Wallet.$currentWalletAddr}).then(result=>{
                    resolve(result);
                }).catch(e=>{
                    reject(e);
                });
            }).catch(e=>{
                reject(e);
            })
        });
    },
    increaseStamina(warriorID){
        return new Promise(function(resolve, reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  
            Wallet.loadContract(contractKey).then(contract=>{
                contract.methods.increaseStamina(warriorID).send({from: Wallet.$currentWalletAddr}).then(result=>{
                    resolve(result);
                }).catch(e=>{
                    reject(e);
                });
            }).catch(e=>{
                reject(e);
            })
        });
    },
    increaseDexterity(warriorID){
        return new Promise(function(resolve, reject){
            if(!Wallet.isReady()) reject(new Error('No Wallet'));  
            Wallet.loadContract(contractKey).then(contract=>{
                contract.methods.increaseDexterity(warriorID).send({from: Wallet.$currentWalletAddr}).then(result=>{
                    resolve(result);
                }).catch(e=>{
                    reject(e);
                });
            }).catch(e=>{
                reject(e);
            })
        });
    },
    increaseSkill(warriorID, skill){
        switch(skill){
            case 'attack':
                return warriorSkills.increaseAttack(warriorID);
            case 'defense':
                return warriorSkills.increaseDefense(warriorID);
            case 'stamina':
                return warriorSkills.increaseStamina(warriorID);
            case 'dexterity':
                    return warriorSkills.increaseDexterity(warriorID);
            default:
                return new Error('Invalid');
        }
    }
}
export default warriorSkills;