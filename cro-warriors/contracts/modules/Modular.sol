// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '../CronosWarriors.sol';

contract Modular is Ownable {

    mapping (address => bool) private _modules;

    modifier onlyModules(){
        require(_modules[msg.sender], 'only modules can do this');
        _;
    }
    
    function setModule(address addr, bool allow) public onlyOwner(){
        if(!allow){
            delete _modules[addr];   
        }else{
            _modules[addr] = true;    
        }
    }
}