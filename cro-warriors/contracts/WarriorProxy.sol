// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import './CronosWarriors.sol';
import './Treasury.sol';
import './WarriorFactory.sol';
import './WarriorSkills.sol';
import './WarriorStats.sol';
import './WarriorVisuals.sol';

contract WarriorProxy is Ownable {
    CronosWarriors  public warriors;
    Treasury        public treasury;
    WarriorFactory  public factory;
    WarriorSkills   public skills;
    WarriorStats    public stats;
    WarriorVisuals  public visuals;
    
    struct Warrior{
        address owner;
        uint256 experience;
        uint256 level;
        uint256 health;
        SkillsLib.Skills skills;
        StatsLib.Stats stats;
        VisualsLib.Visuals visuals;
    }
    
    event WarriorFetched( Warrior _warrior );
    
    constructor(
        address warriorsAddr,
        address treasuryAddr,
        address factoryAddr,
        address skillsAddr,
        address statsAddr,
        address visualsAddr
        ) Ownable(){
        warriors = CronosWarriors(warriorsAddr);
        treasury = Treasury(treasuryAddr);
        factory  = WarriorFactory(factoryAddr);
        skills   = WarriorSkills(skillsAddr);
        stats    = WarriorStats(statsAddr);
        visuals  = WarriorVisuals(visualsAddr);
    }
    
    /* Warrior views */
    function warriorData(uint256 id) external view returns(address, uint256, uint256, uint256, uint256, uint256, uint256, uint256){
        if(!warriors.exists(id)){
            return (address(0),0,0,0,0,0,0,0);
        }else{
            SkillsLib.Skills   memory sk = skills.skills(id);
            StatsLib.Stats     memory st = stats.stats(id);
            return (
                warriors.ownerOf(id),
                treasury.experience(id),
                sk.attack,
                sk.defense,
                sk.stamina,
                sk.pointsSpend,
                st.battlesWon,
                st.battlesLost
            );
        }
    }
}