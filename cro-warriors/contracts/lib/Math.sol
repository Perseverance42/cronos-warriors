// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Math {
    function sqrt(uint x) public pure returns (uint y) {
        if(x==0){
            return 0;
        }
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
    
    function rand() public view returns(uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));
        return (seed - ((seed / 1000) * 1000));
    }
    
    function secMinus(uint256 a, uint256 b) public pure returns(uint256){
        if(b>=a){
            return 0;
        }else{
            return a-b;
        }
    }
}