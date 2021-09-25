// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './CronosWarriors.sol';
import './modules/Modular.sol';
import './lib/structs/SkillsLib.sol';

contract WarriorSkills is Modular {
    
    CronosWarriors private _cronosWarriors;
    mapping(uint256 => SkillsLib.Skills) private _skills;
    
    modifier warriorOwnerOnly(uint256 id){
        require(_cronosWarriors.ownerOf(id)==msg.sender, 'Only the owner can do this!');
        _;
    }
    
    modifier pointsAvailable(uint256 id){
        //TODO check if points are available from compute Lib
        _;
    }
    
    constructor(){
        _cronosWarriors = CronosWarriors(msg.sender);
        setModule(msg.sender, true);
    }
    
    function _exists(uint256 id) internal view returns(bool){
        return SkillsLib.isNull(_skills[id]);
    }
    
    function mint(uint256 id) external onlyModules() {
        assert(!_exists(id));
        _skills[id] = SkillsLib.Skills(1,1,1,0);
    }
    
    function burn(uint256 id) external onlyModules(){
        delete _skills[id];
    }
    
    /** Getters **/
    
    function skills(uint256 id) external view returns (SkillsLib.Skills memory){
        return _skills[id];
    }
    
    /** Setters **/
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