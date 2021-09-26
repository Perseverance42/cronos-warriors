// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CombatModule.sol";

contract BattleBoard { 
    
    event FightRequested(uint256 attacker, uint256 defender);
    event FightRequestResponded(uint256 attacker, uint256 defender, bool accepted);
    event FightRequestWithdrawn(uint256 attacker, uint256 defender);
    
    uint256 private _battleRequestTimeout = 500;
    
    //battle requests
    mapping (uint256 => mapping(uint256 => uint256)) _offensiveBattleRequests; //maps attacker to defender
    mapping (uint256 => mapping(uint256 => uint256)) _defensiveBattleRequests; //maps defneder to attacker
    
    CronosWarriors public cronosWarriors;
    CombatModule   public combatModule;

    modifier onlyOwnerOf(uint256 id){
        require(cronosWarriors.ownerOf(id)==msg.sender, 'Only owner can do this!');
        _;
    }
    
    constructor (address cronosWarriorsAddr, address combatModuleAddr){
        cronosWarriors = CronosWarriors(cronosWarriorsAddr);
        combatModule   = CombatModule(combatModuleAddr);
    }

    function _createBattleRequest(uint256 attacker, uint256 defender) internal {
        uint256 timeout = block.number + _battleRequestTimeout;
        _offensiveBattleRequests[attacker][defender] = timeout;
        _defensiveBattleRequests[defender][attacker] = timeout;
        emit FightRequested(attacker, defender);
    }
    
    function _deleteBattleRequest(uint256 attacker, uint256 defender) internal {
        delete _offensiveBattleRequests[attacker][defender];
        delete _defensiveBattleRequests[defender][attacker];
    }
    
    function doesBattleRequestExist(uint256 attacker, uint256 defender) external view returns(bool){
        return _doesBattleRequestExist(attacker, defender);   
    }
    
    function _doesBattleRequestExist(uint256 attacker, uint256 defender) internal view returns(bool){
        return _offensiveBattleRequests[attacker][defender] != 0;
    }
    
    function battleRequestTimeout() external view returns(uint256){
        return _battleRequestTimeout;
    }
    
    function challangeWarrior(uint256 attacker, uint256 defender) external onlyOwnerOf(attacker) {
        require(attacker!=defender, "Attacker can not attack itself!");
        _createBattleRequest(attacker, defender);
    }
    
    function denyBattleRequest(uint256 defender, uint256 attacker) external onlyOwnerOf(defender) {
        require(_doesBattleRequestExist(attacker, defender), 'This battle does not exist');
        _deleteBattleRequest(attacker, defender);
        emit FightRequestResponded(attacker, defender, false);
    }
    
    function acceptBattleRequest(uint256 defender, uint256 attacker) external onlyOwnerOf(defender){
        require(_doesBattleRequestExist(attacker, defender), 'This battle was not requested!');
        require(_offensiveBattleRequests[attacker][defender] > block.number, 'Battle request timed out');
        
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