// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../CronosWarriors.sol';
import './Math.sol';

library Compute {
    
    uint8   constant public difficultyScale = 10; 
    uint8   constant public healthScale = 10;
    
    //used fore scaling experience (cro) down
    uint256 constant public decimalsEth = 18;
    uint256 constant public decimalsEp = 8; 
    uint256 constant public critScale = 10**decimalsEth;
    uint256 constant public epScale = 10**decimalsEp;
    
    //uint256 public epS1 = 10**(decimalsEth-decimalsEp);
    uint256 constant public epS1Root = 100000;
    uint256 constant public mintFee = 10**decimalsEth;
    
    function warriorLevel(uint256 experience) public pure returns(uint256){
        uint256 lvl = Math.secMinus(experience, mintFee);
        lvl = lvl/epScale;
        lvl = lvl*difficultyScale;
        lvl = Math.sqrt(lvl);
        lvl = lvl/epS1Root + 1;
        return lvl;
    }
    
    function warriorHealth(uint256 experience, uint256 stamina) public pure returns(uint256){
        return healthScale * (warriorLevel(experience) + stamina);
    }
    
    function damage(uint256 attackerEp, uint256 attack, uint256 defense, bool crit) internal pure returns(uint256) {
        uint256 dmg = (2 * warriorLevel(attackerEp) + 10) * 10000000000;
        uint256 def = (attack * 10000000000) / (defense * 10000000000);
        dmg = dmg / 2;
        dmg = dmg * def;
        dmg = dmg / 10000000000;
        if(crit){
            dmg = dmg * 15 / 10; 
        }
        return dmg;
    }
    
    function critRate(uint256 experience, uint256 dexterity) public pure returns(uint256){
        return (dexterity * critScale) / ( ( ( warriorLevel(experience)+10) * critScale ) / 1000);
    }
    
    function experienceToSwap(uint256 ep1, uint256 ep2) public pure returns (uint256){
        uint256 exp = ep1 + ep2;
        exp = exp / 2;
        exp = exp / 10;
        return exp;
    }
    
}