// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './CronosWarriors.sol';
import './Treasury.sol';
import './modules/Modular.sol';
import './lib/Compute.sol';
import './lib/structs/SkillsLib.sol';

contract WarriorSkills is Modular {
    
    /* Modules which get accessed */
    CronosWarriors public cronosWarriors;
    Treasury       public treasury;
    
    mapping(uint256 => SkillsLib.Skills) private _skills;
    
    modifier warriorOwnerOnly(uint256 id){
        require(cronosWarriors.ownerOf(id)==msg.sender, 'Only the owner can do this!');
        _;
    }
    
    modifier pointsAvailable(uint256 id){
        //TODO check if points are available from compute Lib
        _;
    }
    
    constructor(address cronosWarriorsAddr, address treasuryAddr){
        cronosWarriors = CronosWarriors(cronosWarriorsAddr);
        treasury = Treasury(treasuryAddr);
    }
    
    function _exists(uint256 id) internal view returns(bool){
        return !SkillsLib.isNull(_skills[id]);
    }
    
    function mint(uint256 id) external onlyModules() {
        assert(!_exists(id));
        _skills[id] = SkillsLib.Skills(1,1,1,0);
    }
    
    function burn(uint256 id) external onlyModules(){
        delete _skills[id];
    }
    
    /* Getters */
    
    function skills(uint256 id) external view returns (SkillsLib.Skills memory){
        return _skills[id];
    }
    
    function warriorSkills(uint256 id) external view returns (uint256, uint256, uint256){
        SkillsLib.Skills memory s = _skills[id];
        return ( s.attack, s.defense, s.stamina );
    }
    
    /* Computed views */
    
    function warriorHealth(uint256 id) external view returns(uint256){
        return Compute.warriorHealth(warriorExperience(id), _skills[id].stamina);
    }
    
    function warriorLevel(uint256 id) external view returns(uint256){
        return Compute.warriorLevel(warriorExperience(id));
    }
    
    function warriorExperience(uint256 id) public view returns(uint256){
        return treasury.experience(id);
    }
    
    /* Setters */
    function _increasePointsSpend(uint256 id) internal {
        _skills[id].pointsSpend = _skills[id].pointsSpend + 1;
    }
    
    function increaseAttack(uint256 id) external warriorOwnerOnly(id) pointsAvailable(id){
        _skills[id].attack = _skills[id].attack + 1;
        _increasePointsSpend(id);
    }
    
    function increaseDefense(uint256 id) external warriorOwnerOnly(id) pointsAvailable(id){
        _skills[id].defense = _skills[id].defense + 1;
        _increasePointsSpend(id);
    }
    
    function increaseStamina(uint256 id) external warriorOwnerOnly(id) pointsAvailable(id){
        _skills[id].stamina = _skills[id].stamina + 1;
        _increasePointsSpend(id);
    }
}