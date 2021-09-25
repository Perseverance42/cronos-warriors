// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './modules/Modular.sol';
import './lib/Compute.sol';
import './lib/Math.sol';

contract Treasury is Modular {
    
    event FundsAdded(uint256 id, uint256 amount);
    event FundsWithdrawn(uint256 id, uint256 amount);
    
    uint256 private _reserve;
    mapping (uint256 => uint256) private _experience;
    
    constructor(){
        setModule(msg.sender, true);
    }
    
    /** Getters **/
    function experience(uint256 id) external view returns (uint256){
        return _experience[id];
    }
    
    /** Setters **/
    function _increaseReserve(uint256 amount) internal {
        _reserve = _reserve + amount;
    }
    
    function swapExperienceFor(uint256 winner, uint256 loser) external onlyModules(){
        uint256 expToSwap = Compute.experienceToSwap(_experience[winner], _experience[loser]);
        uint256 battleTax = expToSwap >= 1000 ? expToSwap / 1000 : 0; //TODO check if this is required. if (x < 1000)/1000 = 0 then it is not ...
        
        //make sure the ep swapped is actually collataralized!!!
        require(expToSwap > _experience[loser], 'this swap is illegal!');
        
        expToSwap = Math.secMinus(expToSwap, battleTax);
        require(expToSwap > 0, 'No ep to swap');
        require(battleTax < expToSwap, 'math error');
        _increaseReserve(battleTax);
        _experience[winner] = _experience[winner] + expToSwap;
        _experience[loser]  = _experience[loser]  - expToSwap;
    }
    
    function addExperience(uint256 id) external payable onlyModules() {
        uint256 exp = _experience[id];
        exp = exp + msg.value;
        _experience[id] = exp;
        emit FundsAdded(id, msg.value);
    }
    
    function withdrawExperience(uint256 id, address payable receiver) external onlyModules() {
        uint256 exp = _experience[id];
        assert(exp>0);
        receiver.transfer(exp);
        emit FundsWithdrawn(id, exp);
    }
    
    function withdrawFromReserve(address payable receiver, uint256 amount) external onlyOwner() {
        assert(amount>0);
        assert(amount<=_reserve);
        receiver.transfer(amount);
    }
}