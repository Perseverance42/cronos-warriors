// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './CronosWarriors.sol';
import './modules/Modular.sol';
import './lib/structs/StatsLib.sol';

contract WarriorStats is Modular { //is owned by warrior contract for now (no admin access needed)
    
    mapping(uint256 => StatsLib.Stats) private _stats;
    
    constructor(){
        setModule(msg.sender,true);
    }
    
    function _exists(uint256 id) internal view returns(bool){
        return StatsLib.isNull(_stats[id]);
    }
    
    function mint(uint256 id) external onlyModules() {
        assert(!_exists(id));
        _stats[id] = StatsLib.Stats(0,0,true);
    }
    
    function burn(uint256 id) external onlyModules(){
        delete _stats[id];
    }
    
    /** Getters **/
    function stats(uint256 id) external view returns (StatsLib.Stats memory){
        return _stats[id];
    }
    
    /** Setters **/
    function increaseBattleStats(uint256 winner, uint256 loser) external onlyModules(){
        _stats[winner].battlesWon = _stats[winner].battlesWon + 1;
        _stats[loser].battlesLost = _stats[loser].battlesLost + 1;
    }
}