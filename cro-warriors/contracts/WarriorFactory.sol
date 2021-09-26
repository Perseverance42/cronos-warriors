// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './CronosWarriors.sol';
import "./modules/BattleBoard.sol";
import "./WarriorSkills.sol";
import "./WarriorStats.sol";
import "./WarriorVisuals.sol";
import "./Treasury.sol";
import './modules/Modular.sol';

/**
 * The WarriorFactory does control minting new warriors and buring all reference when the main NFT gets burned
 **/

contract WarriorFactory is Modular {
    
    /* Event */
    event WarriorMinted(uint256 id, address owner);
    event WarriorBurned(uint256 id, address recipient);
    
    /* Modules which get accessed */
    CronosWarriors public cronosWarriors;
    WarriorSkills  public warriorSkills;
    WarriorStats   public warriorStats;
    WarriorVisuals public warriorVisuals;
    Treasury       public treasury;
    
    uint256 private maxId;
    
    constructor(address cronosWarriorsAddr, address warriorSkillsAddr, address warriorStatsAddr, address warriorVisualsAddr, address treasuryAddr){
        cronosWarriors = CronosWarriors(cronosWarriorsAddr);
        warriorSkills  = WarriorSkills(warriorSkillsAddr);
        warriorStats   = WarriorStats(warriorStatsAddr);
        warriorVisuals = WarriorVisuals(warriorVisualsAddr);
        treasury       = Treasury(treasuryAddr);
        maxId = 0;
    }
    
    /* Users mit their warriors here */
    function mint(string memory name) external payable returns(uint256){
        uint256 newId = maxId = maxId + 1;
        assert(!cronosWarriors.exists(newId));
        
        treasury.mint{value:msg.value}(newId);
        
        warriorVisuals.mint(newId, name);
        warriorSkills.mint(newId);
        warriorStats.mint(newId);
        cronosWarriors.mint(newId);
        emit WarriorMinted(newId, msg.sender);
        return newId;
    }
    
    function burn(uint256 id, address recipient) external {
        require(msg.sender==cronosWarriors.ownerOf(id), 'Only owner can do this!');
        
        warriorSkills.burn(id);
        warriorStats.burn(id);
        warriorVisuals.burn(id);
        treasury.withdrawExperience(id, payable(recipient));
        cronosWarriors.burn(id);
        emit WarriorBurned(id, recipient);
    }
}