// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CombatModule.sol";
import "../lib/imported/StructuredLinkedList.sol";

contract BattleBoard { 
    using StructuredLinkedList for StructuredLinkedList.List;
    
    uint8 private constant maxOffensiveRequests = 15;
    uint8 private constant maxDefensiveRequests = 20;

    /* Events */
    event FightRequested(uint256 indexed attacker, uint256 indexed defender);
    event FightRequestResponded(uint256 indexed attacker, uint256 indexed defender, bool accepted);
    event FightRequestWithdrawn(uint256 indexed attacker, uint256 indexed defender);
    
    /* Modules which get accessed */
    CronosWarriors public cronosWarriors;
    CombatModule   public combatModule;
    WarriorSkills  public warriorSkills;

    /* Battle request queue */
    mapping (uint256 => mapping(uint256=>uint256))  _battleRequests; //stores points skilled of the defender
    mapping (uint256 => StructuredLinkedList.List ) _offensiveBattleRequests; //maps attacker to defender
    mapping (uint256 => StructuredLinkedList.List ) _defensiveBattleRequests; //maps defneder to attacker
    
    modifier onlyOwnerOf(uint256 id){
        require(cronosWarriors.ownerOf(id)==msg.sender, 'Only owner can do this!');
        _;
    }
    
    constructor (address cronosWarriorsAddr, address combatModuleAddr, address warriorSkillsAddr){
        cronosWarriors = CronosWarriors(cronosWarriorsAddr);
        combatModule   = CombatModule(combatModuleAddr);
        warriorSkills  = WarriorSkills(warriorSkillsAddr);
    }

    /** Getters **/
    function doesBattleRequestExist(uint256 attacker, uint256 defender) external view returns(bool){
        return _doesBattleRequestExist(attacker, defender);   
    }
    
    function _doesBattleRequestExist(uint256 attacker, uint256 defender) internal view returns(bool){
        return _battleRequests[attacker][defender] != 0;
    }

    function isBattleRequestValid(uint256 attacker, uint256 defender) public view returns(bool){
        return warriorSkills.skills(defender).pointsSpend + 1 == _battleRequests[attacker][defender];
    }
    
    function defensiveRequestOf(uint256 id, uint256 start, uint8 pageSize) external view returns(uint256[] memory){
        uint256 requestCount = _defensiveBattleRequests[id].sizeOf();
        if(requestCount<1)
            return new uint256[](0);
        
        if(start == 0){
            start = _defensiveBattleRequests[id].getFirst();
        }
        requestCount = pageSize < requestCount ? pageSize : requestCount; //limit request size
        
        uint256[] memory requests = new uint256[](requestCount);
        bool exists;
        uint256 next;
        for(uint8 i=0;i<requestCount;i++){
           (exists, ,next) = _defensiveBattleRequests[id].getNode(start); //does return exists, previous, next
            
           if(exists){
                requests[i] = start;
                start = next;
           }else{
               break;
           }
        }
        return requests;
    }

    function offensiveRequestOf(uint256 id, uint256 start, uint8 pageSize) external view returns(uint256[] memory){
        uint256 requestCount = _offensiveBattleRequests[id].sizeOf();
        if(requestCount<1)
            return new uint256[](0);
        
        if(start == 0){
            start = _offensiveBattleRequests[id].getFirst();
        }
        requestCount = pageSize < requestCount ? pageSize : requestCount; //limit request size
        
        uint256[] memory requests = new uint256[](requestCount);
        bool exists;
        uint256 next;
        for(uint8 i=0;i<requestCount;i++){
           (exists, ,next) = _offensiveBattleRequests[id].getNode(start); //does return exists, previous, next
            
           if(exists){
                requests[i] = start;
                start = next;
           }else{
               break;
           }
        }
        return requests;
    }
    
    /** Setters */

    function _createBattleRequest(uint256 attacker, uint256 defender) internal {
        require(attacker!=defender, "Attacker can not attack itself!");
        if(_doesBattleRequestExist(attacker, defender)){
            _deleteBattleRequest(attacker, defender);
        }
        
        _offensiveBattleRequests[attacker].pushFront(defender);
        _defensiveBattleRequests[defender].pushFront(attacker);
        
        _battleRequests[attacker][defender] = warriorSkills.skills(defender).pointsSpend + 1; //0 is reserved for non existing requests
        emit FightRequested(attacker, defender);
    }

    function _deleteBattleRequest(uint256 attacker, uint256 defender) internal {
        require(_doesBattleRequestExist(attacker, defender), 'Request does not exist');
         _offensiveBattleRequests[attacker].remove(defender);
         _defensiveBattleRequests[defender].remove(attacker);
         delete _battleRequests[attacker][defender];
    }
    
    function challengeWarrior(uint256 attacker, uint256 defender) external onlyOwnerOf(attacker) {
        _createBattleRequest(attacker, defender);
    }
    
    function denyBattleRequest(uint256 defender, uint256 attacker) external onlyOwnerOf(defender) {
        require(_doesBattleRequestExist(attacker, defender), 'This battle does not exist');
        _deleteBattleRequest(attacker, defender);
        emit FightRequestResponded(attacker, defender, false);
    }
    
    function acceptBattleRequest(uint256 defender, uint256 attacker) external onlyOwnerOf(defender){
        require(_doesBattleRequestExist(attacker, defender), 'This battle was not requested!');
        require(isBattleRequestValid(attacker, defender), 'This Battle Request is invalid!');
        
        _deleteBattleRequest(attacker, defender);
        emit FightRequestResponded(attacker, defender, true);
        combatModule.fight(attacker, defender);
    }
    
    function withdrawBattleRequest(uint256 attacker, uint256 defender) external onlyOwnerOf(attacker){
        require(_doesBattleRequestExist(attacker, defender), 'This battle does not exist');
        _deleteBattleRequest(attacker, defender);
        emit FightRequestWithdrawn(attacker, defender);
    }
}