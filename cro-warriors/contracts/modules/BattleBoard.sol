// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CombatModule.sol";
import "solidity-linked-list/contracts/StructuredLinkedList.sol";

contract BattleBoard { 
    using StructuredLinkedList for StructuredLinkedList.List;
    
    uint8 private constant maxOffensiveRequests = 15;
    uint8 private constant maxDefensiveRequests = 20;

    /* Events */
    event FightRequested(uint256 attacker, uint256 defender);
    event FightRequestResponded(uint256 attacker, uint256 defender, bool accepted);
    event FightRequestWithdrawn(uint256 attacker, uint256 defender);
    
    /* Modules which get accessed */
    CronosWarriors public cronosWarriors;
    CombatModule   public combatModule;
    
    uint256 private _battleRequestTimeout = 500;
    
    /* Battle request queue */
    mapping (uint256 => mapping(uint256=>uint256)) _requestTimeouts;
    mapping (uint256 => StructuredLinkedList.List ) _offensiveBattleRequests; //maps attacker to defender
    mapping (uint256 => StructuredLinkedList.List ) _defensiveBattleRequests; //maps defneder to attacker
    
    modifier onlyOwnerOf(uint256 id){
        require(cronosWarriors.ownerOf(id)==msg.sender, 'Only owner can do this!');
        _;
    }
    
    constructor (address cronosWarriorsAddr, address combatModuleAddr){
        cronosWarriors = CronosWarriors(cronosWarriorsAddr);
        combatModule   = CombatModule(combatModuleAddr);
    }

    /** Getters **/
    function doesBattleRequestExist(uint256 attacker, uint256 defender) external view returns(bool){
        return _doesBattleRequestExist(attacker, defender);   
    }
    
    function _doesBattleRequestExist(uint256 attacker, uint256 defender) internal view returns(bool){
        return _offensiveBattleRequests[attacker].nodeExists(defender);
    }

    function isBattleRequestTimedOut(uint256 attacker, uint256 defender) public view returns(bool){
        return _requestTimeouts[attacker][defender] == 0 || _requestTimeouts[attacker][defender] <= block.number;
    }
    
    function battleRequestTimeout() external view returns(uint256){
        return _battleRequestTimeout;
    }
    
    function defensiveRequestOf(uint256 id, uint256 start, uint8 pageSize) external view returns(uint256[] memory){
        assert(_defensiveBattleRequests[id].listExists());
        uint256 requestCount = _defensiveBattleRequests[id].sizeOf();
        assert(requestCount>0);
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
    
    /** Setters */

    function _createBattleRequest(uint256 attacker, uint256 defender) internal {
        require(!_doesBattleRequestExist(attacker,defender), 'Request already exists!');
        require(attacker!=defender, "Attacker can not attack itself!");
        
        _offensiveBattleRequests[attacker].pushFront(defender);
        _defensiveBattleRequests[defender].pushFront(attacker);
        
        _requestTimeouts[attacker][defender] = block.number + _battleRequestTimeout;
        emit FightRequested(attacker, defender);
    }

    function _deleteBattleRequest(uint256 attacker, uint256 defender) internal {
        require(_doesBattleRequestExist(attacker, defender), 'Request does not exist');
         _offensiveBattleRequests[attacker].remove(defender);
         _defensiveBattleRequests[defender].remove(attacker);
    }
    
    function challangeWarrior(uint256 attacker, uint256 defender) external onlyOwnerOf(attacker) {
        _createBattleRequest(attacker, defender);
    }
    
    function denyBattleRequest(uint256 defender, uint256 attacker) external onlyOwnerOf(defender) {
        require(_doesBattleRequestExist(attacker, defender), 'This battle does not exist');
        _deleteBattleRequest(attacker, defender);
        emit FightRequestResponded(attacker, defender, false);
    }
    
    function acceptBattleRequest(uint256 defender, uint256 attacker) external onlyOwnerOf(defender){
        require(_doesBattleRequestExist(attacker, defender), 'This battle was not requested!');
        require(!isBattleRequestTimedOut(attacker, defender), 'This request timed out');
        
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