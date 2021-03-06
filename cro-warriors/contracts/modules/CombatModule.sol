// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import '../Treasury.sol';
import '../WarriorSkills.sol';
import '../WarriorStats.sol';
import '../lib/Compute.sol';

contract CombatModule is AccessControl{
    
    /* Access control */
    bytes32 public constant COMBAT_ROLE = keccak256("COMBAT_ROLE");
    
    event FightDone(uint256 indexed winner, uint256 indexed loser, uint256 epSwapped);
    
    /* Modules which get accessed */
    WarriorSkills public warriorSkills;
    WarriorStats  public warriorStats;
    Treasury      public treasury;
    
    /* Properties */
    mapping(uint256=>bool) private _activeFights; //intended as reentrancyguard
    
    constructor(address warriorSkillsAddr, address warriorStatsAddr, address treasuryAddr){
        warriorSkills   = WarriorSkills(warriorSkillsAddr);
        warriorStats    = WarriorStats(warriorStatsAddr);
        treasury        = Treasury(treasuryAddr);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    function fight(uint256 w1, uint256 w2) external onlyRole(COMBAT_ROLE) {
        require(!_activeFights[w1], 'already fighting');
        require(!_activeFights[w2], 'already fighting');
        
        SkillsLib.Skills[2] memory skills;
        skills[0] = warriorSkills.skills(w1);
        skills[1] = warriorSkills.skills(w2);
        
        uint256[2] memory exp;
        exp[0] = treasury.experience(w1);
        exp[1] = treasury.experience(w2);
        
        uint256[2] memory critRates;
        critRates[0] = Compute.critRate(exp[0], skills[0].dexterity)-1; //scale up to match scaling of Math.random() (0-999)
        critRates[1] = Compute.critRate(exp[1], skills[1].dexterity)-1;
        
        //combat state
        bool fighting = true;
        uint256 dmg;
        
        //health map
        uint256[2] memory health;
        health[0] = Compute.warriorHealth(exp[0], skills[0].stamina); //could be replaced with treasury.warriorHealth(w1); but current implementation should save gas
        health[1] = Compute.warriorHealth(exp[1], skills[1].stamina);
    
        _activeFights[w1] = true;
        _activeFights[w2] = true;
        
        //combat starting state
        uint256 r = Math.rand();
        
        uint256 attacker = skills[0].dexterity > skills[1].dexterity ? 0 : 1;
        if(skills[0].dexterity == skills[1].dexterity){
            attacker = r < 499 ? 0 : 1;
        }
        uint256 defender = 1-attacker;
        
        //combat loop iterates until health of one fighter is 0
        while(fighting){
            uint256 h = health[attacker];
            dmg = Compute.damage(exp[attacker], skills[attacker].attack, skills[defender].defense, r < critRates[attacker]);
            if(dmg < h){
                health[defender] = h - dmg;
                
                attacker = 1-attacker;
                defender = 1-defender;
                r = Math.rand();
            }else{
                fighting = false; 
                //current defender is the loser
            }
        }
        //switch from indexes to ids
        attacker = attacker == 0 ? w1 : w2;
        defender = defender == 0 ? w1 : w2; 

        //do experience swap in treasury
        uint256 epSwapped = treasury.swapExperienceFor(attacker, defender);
        warriorStats.increaseBattleStats(attacker, defender);
        
        delete _activeFights[w1];
        delete _activeFights[w2];
        emit FightDone(attacker, defender, epSwapped);
    }
}