// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import './WarriorFactory.sol';
import './lib/Compute.sol';
import './lib/Math.sol';

contract Treasury is AccessControl  {
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
        require(msg.value == Compute.mintFee, 'Invalid mint fee!');
        
        _experience[id] = msg.value;
        emit FundsAdded(id, _experience[id]);
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
        return expToSwap;
    }
    
    //gets accessed by WarriorFactory
    function withdrawExperience(uint256 id, address payable receiver) external onlyRole(MINTER_ROLE) {
        uint256 exp = _experience[id];
        assert(exp>0);
        receiver.transfer(exp);
        delete _experience[id];
        emit FundsWithdrawn(receiver, id, exp);
    }
    
    function withdrawFromReserve(address payable receiver, uint256 amount) external onlyRole(DISTRIBUTION_ROLE) {
        assert(amount>0);
        assert(amount<=_reserve);
        receiver.transfer(amount);
        emit FundsWithdrawn(receiver, 0, amount);
    }
}