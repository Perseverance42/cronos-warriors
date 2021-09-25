pragma solidity ^0.8.0;

import '../CronosWarriors.sol';

contract Module {

    CronosWarriors private _warriorContract;
    address private _parentContract;
    
    constructor(address parentContractAddr, address warriorContractAddr){
        _warriorContract = CronosWarriors(warriorContractAddr);
        _parentContract = parentContractAddr;
    }
    
    modifier calledByParent(){
        assert(msg.sender == _parentContract);
        _;
    }
    
    function warriorContract() public view returns(CronosWarriors){
        return _warriorContract;
    }
}