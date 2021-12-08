// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./lib/imported/StructuredLinkedList.sol";
import './lib/Compute.sol';
import './lib/Math.sol';

contract Treasury is AccessControl  {
    using StructuredLinkedList for StructuredLinkedList.List;

    /* Access control */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant EXCHANGE_ROLE = keccak256("EXCHANGE_ROLE");
    bytes32 public constant DISTRIBUTION_ROLE = keccak256("DISTRIBUTION_ROLE");
        
    /* Events */
    event FundsAdded(uint256 indexed id, uint256 amount);
    event FundsWithdrawn(address indexed receiver, uint256 id, uint256 amount);
    
    /* Properties */
    uint256 private _reserve;
    mapping (uint256 => uint256) private _experience;

    uint8 public constant LEADERBOARD_LENGTH = 50;
    StructuredLinkedList.List          private _leaderboard;
    
    constructor(){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    /* Getters */
    function experience(uint256 id) external view returns (uint256){
        return _experience[id];
    }
    
    function reserve() external view returns(uint256){
        return _reserve;
    }
    
    /* Setters */
    function _increaseReserve(uint256 amount) internal {
        _reserve = _reserve + amount;
    }
    
    //gets accessed by WarriorFactory
    function mint(uint256 id) payable external onlyRole(MINTER_ROLE){
        assert(_experience[id] == 0);
        require(msg.value == Compute.mintFee + Compute.mintCost, 'Invalid mint fee!');
        
        _experience[id] = Compute.mintFee;
        _reserve = _reserve + Compute.mintCost;
        emit FundsAdded(id, _experience[id]);
    }

    function replenish(uint256 id) payable external onlyRole(MINTER_ROLE){
        uint256 ep = _experience[id];
        assert(ep < Compute.mintFee);
        uint256 replenishFee = Compute.mintFee - ep;
        require(msg.value == replenishFee, 'Invalid replenishment value!');
        _experience[id] = _experience[id] + msg.value;
        assert(_experience[id] == Compute.mintFee); //sanity check
    }

    //gets accessed by CombatModule
    function swapExperienceFor(uint256 winner, uint256 loser) external onlyRole(EXCHANGE_ROLE) returns(uint256){
        uint256 expToSwap = Compute.experienceToSwap(_experience[winner], _experience[loser]);
        uint256 battleTax = expToSwap / 1000; //TODO check if this works for small numbers. if (x < 1000)/1000 = 0 then it is fine ...
        
        //make sure the ep swapped is actually collataralized!!!
        require(expToSwap < _experience[loser], 'this swap is illegal!');
        
        expToSwap = Math.secMinus(expToSwap, battleTax);
        require(expToSwap > 0, 'No ep to swap');
        require(battleTax < expToSwap, 'math error');
        _increaseReserve(battleTax);
        _experience[winner] = _experience[winner] + expToSwap;
        _experience[loser]  = _experience[loser]  - expToSwap;
        _updateLeaderboard(winner);
        _updateLeaderboard(loser);
        return expToSwap;
    }
    
    //gets accessed by WarriorFactory
    function withdrawExperience(uint256 id, address payable receiver) external onlyRole(MINTER_ROLE) {
        uint256 exp = _experience[id];
        assert(exp>0);
        receiver.transfer(exp);
        delete _experience[id];
        _removeFromLeaderboard(id);
        emit FundsWithdrawn(receiver, id, exp);
    }
    
    function withdrawFromReserve(address payable receiver, uint256 amount) external onlyRole(DISTRIBUTION_ROLE) {
        assert(amount>0);
        assert(amount<=_reserve);
        receiver.transfer(amount);
        _reserve = _reserve - amount;
        emit FundsWithdrawn(receiver, 0, amount);
    }

        /* Leaderboard functions */
    
    function _updateLeaderboard(uint256 id) internal{
        (bool exists, , uint256 next) = _leaderboard.getNode(id);
        if(exists){
            if(next > 0 && _experience[id] > _experience[next]){
                _leaderboard.remove(id);
                _leaderboard.insertAfter(next, id);
            }
        }else{
            if(_experience[id] > _experience[_leaderboard.first]){
               _leaderboard.insertAfter(_leaderboard.first, id);
            }else if(_leaderboard.size<LEADERBOARD_LENGTH){
                _leaderboard.insertBefore(_leaderboard.first, id);
            }
        }
        if(_leaderboard.size>LEADERBOARD_LENGTH){
            _leaderboard.remove(_leaderboard.first);
        }
    }

    function _removeFromLeaderboard(uint256 id) internal{
        (bool exists, , ) = _leaderboard.getNode(id);
        if(exists){
            _leaderboard.remove(id);
        }
    }
    
    function leaderboard(uint256 start, uint8 size) external view returns(uint256[] memory){
        if(start==0) start = _leaderboard.last;
        size = size <= _leaderboard.size ? size : uint8(_leaderboard.size);
        uint256[] memory res = new uint256[](size);
        bool exists;
        uint256 previous;
        for(uint8 i=0;i<size;i++){
           (exists, previous,) = _leaderboard.getNode(start); //does return exists, previous, next
            
           if(exists){
                res[i] = start;
                start = previous;
           }else{
               break;
           }
        }
        return res;
    }
}