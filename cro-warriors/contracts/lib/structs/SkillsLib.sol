// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SkillsLib {
    struct Skills {
        uint256 pointsSpend;
        uint256 attack;
        uint256 defense;
        uint256 stamina;
        uint256 dexterity;
    }
    
    function isNull(Skills memory skills) public pure returns (bool){
        return skills.attack == 0 || skills.defense == 0 || skills.stamina == 0 || skills.dexterity == 0;
    }
}