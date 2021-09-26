pragma solidity ^0.8.0;

library StatsLib {
    struct Stats {
        uint256 battlesWon;
        uint256 battlesLost;
        //since init state is zero on all fields we need a flag to ensure the struct exists within a mapping
        bool _exists;
    }
    
    function isNull(Stats memory stats) public pure returns (bool){
        return !stats._exists;
    }
}