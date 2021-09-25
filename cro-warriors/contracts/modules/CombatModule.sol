pragma solidity ^0.8.0;

import './Module.sol';
import '../lib/Compute.sol';

contract CombatModule is Module{
    
    event FightStarted(uint256 attacker, uint256 defender);
    event FightDone(uint256 winner, uint256 loser);
    
    mapping(uint256=>bool) private _activeFights;
    
    constructor(address battleBoardContract, address warriorContract) Module(battleBoardContract,warriorContract){
    }
    
    function fight(uint256 w1, uint256 w2) external calledByParent(){
        require(warriorContract().exists(w1), 'does not exist');
        require(warriorContract().exists(w2), 'does not exist');
        require(w1!=w2, 'can not fight itself!');
        require(!_activeFights[w1], 'already fighting');
        require(!_activeFights[w2], 'already fighting');
        
        CronosWarriors.Warrior[2] memory fighters;
        fighters[0] = warriorContract().warrior(w1);
        fighters[1] = warriorContract().warrior(w2);
        
        //combat state
        bool fighting = true;
        uint256 dmg;
        
        //health map
        uint256[2] memory health;
        health[0] = Compute.warriorHealth(fighters[0].experience, fighters[0].skills.stamina);
        health[1] = Compute.warriorHealth(fighters[1].experience, fighters[1].skills.stamina);
    
        _activeFights[w1] = true;
        _activeFights[w2] = true;
        
        emit FightStarted(w1, w2);
        
        //combat starting state
        uint256 r = Math.rand();
        
        uint256 attacker = r < 499 ? 0 : 1;
        uint256 defender = 1-attacker;
        
        //combat loop iterates until health of one fighter is 0
        while(fighting){
            uint256 h = health[attacker];
            dmg = Compute.damage(fighters[attacker].experience, fighters[attacker].skills.attack, fighters[defender].skills
            .defense);
            if(dmg < h){
                health[defender] = h - dmg;
                
                attacker = 1-attacker;
                defender = 1-defender;
            }else{
                fighting = false; 
                //current defender is the loser
            }
        }
        //calculate experience swap
        uint256 expToSwap = Compute.experienceToSwap(fighters[0].experience, fighters[1].experience);
        uint256 battleTax = expToSwap >= 1000 ? expToSwap / 1000 : 0;
        expToSwap = Math.secMinus(expToSwap, battleTax);
        require(expToSwap > 0, 'No ep to swap in this fight');
        require(battleTax < expToSwap, 'math error');
        
        warriorContract().increaseReserve(battleTax);
        warriorContract().addExperienceSafe(attacker == 0 ? w1 : w2, expToSwap);
        warriorContract().subExperienceSafe(attacker == 0 ? w2 : w1, expToSwap);
        /*
        _warriors[attacker].stats.battlesWon = _warriors[attacker].stats.battlesWon + 1;
        _warriors[defender].stats.battlesLost = _warriors[defender].stats.battlesLost + 1;
        */
        delete _activeFights[w1];
        delete _activeFights[w2];
        emit FightDone(attacker, defender);
    }
}