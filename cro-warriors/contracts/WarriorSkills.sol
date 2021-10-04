// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import './CronosWarriors.sol';
import './Treasury.sol';
import './lib/Compute.sol';
import './lib/structs/SkillsLib.sol';

contract WarriorSkills is AccessControl {
    
    /* Access control */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    /* Modules which get accessed */
    CronosWarriors public cronosWarriors;
    Treasury       public treasury;
    
    mapping(uint256 => SkillsLib.Skills) private _skills;
    
    modifier warriorOwnerOnly(uint256 id){
        require(cronosWarriors.ownerOf(id)==msg.sender, 'Only the owner can do this!');
        _;
    }
    
    modifier hasSpendablePoints(uint256 id){
        require(pointsAvailable(id)>0, 'No skillpoints available!');
        _;
    }
    
    constructor(address cronosWarriorsAddr, address treasuryAddr){
        cronosWarriors = CronosWarriors(cronosWarriorsAddr);
        treasury = Treasury(treasuryAddr);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    function _exists(uint256 id) internal view returns(bool){
        return !SkillsLib.isNull(_skills[id]);
    }
    
    function mint(uint256 id) external onlyRole(MINTER_ROLE) {
        assert(!_exists(id));
        _skills[id] = SkillsLib.Skills(0,1,1,1,1);
    }
    
    function burn(uint256 id) external onlyRole(MINTER_ROLE){
        delete _skills[id];
    }
    
    /* Getters */
    
    function skills(uint256 id) external view returns (SkillsLib.Skills memory){
        return _skills[id];
    }
    
    function warriorSkills(uint256 id) external view returns (uint256, uint256, uint256, uint256, uint256){
        SkillsLib.Skills memory s = _skills[id];
        return (s.pointsSpend, s.attack, s.defense, s.stamina, s.dexterity );
    }
    
    /* Computed views */
    
    function warriorHealth(uint256 id) external view returns(uint256){
        return Compute.warriorHealth(warriorExperience(id), _skills[id].stamina);
    }
    
    function warriorLevel(uint256 id) public view returns(uint256){
        return Compute.warriorLevel(warriorExperience(id));
    }
    
    function warriorExperience(uint256 id) public view returns(uint256){
        return treasury.experience(id);
    }
    
    function pointsAvailable(uint256 id) public view returns(uint256){
        return Math.secMinus(warriorLevel(id),_skills[id].pointsSpend);
    }
    
    /* Setters */
    function _increasePointsSpend(uint256 id) internal {
        _skills[id].pointsSpend = _skills[id].pointsSpend + 1;
    }
    
    function increaseAttack(uint256 id) external warriorOwnerOnly(id) hasSpendablePoints(id){
        _skills[id].attack = _skills[id].attack + 1;
        _increasePointsSpend(id);
    }
    
    function increaseDefense(uint256 id) external warriorOwnerOnly(id) hasSpendablePoints(id){
        _skills[id].defense = _skills[id].defense + 1;
        _increasePointsSpend(id);
    }
    
    function increaseStamina(uint256 id) external warriorOwnerOnly(id) hasSpendablePoints(id){
        _skills[id].stamina = _skills[id].stamina + 1;
        _increasePointsSpend(id);
    }
    
    function increaseDexterity(uint256 id) external warriorOwnerOnly(id) hasSpendablePoints(id){
        _skills[id].dexterity = _skills[id].dexterity + 1;
        _increasePointsSpend(id);
    }
}