// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./lib/imported/StructuredLinkedList.sol";
import './CronosWarriors.sol';
import './lib/structs/StatsLib.sol';

contract WarriorStats is AccessControl {
    using StructuredLinkedList for StructuredLinkedList.List;
    
    /* Access control */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant CHANGE_ROLE = keccak256("CHANGE_ROLE");
    
    mapping(uint256 => StatsLib.Stats) private _stats;
    
    uint8 public constant LEADERBOARD_LENGTH = 50;
    StructuredLinkedList.List          private _leaderboard;
    
    constructor(){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    function _exists(uint256 id) internal view returns(bool){
        return !StatsLib.isNull(_stats[id]);
    }
    
    function mint(uint256 id) external onlyRole(MINTER_ROLE) {
        assert(!_exists(id));
        _stats[id] = StatsLib.Stats(0,0,true);
    }
    
    function burn(uint256 id) external onlyRole(MINTER_ROLE){
        _removeFromLeaderboard(id);
        delete _stats[id];
    }
    
    /* Getters */
    function stats(uint256 id) external view returns (StatsLib.Stats memory){
        return _stats[id];
    }
    
    function warriorStats(uint256 id) external view returns(uint256, uint256){
        return (_stats[id].battlesWon, _stats[id].battlesLost);
    }

    /* Setters */
    function increaseBattleStats(uint256 winner, uint256 loser) external onlyRole(CHANGE_ROLE){
        _stats[winner].battlesWon = _stats[winner].battlesWon + 1;
        _stats[loser].battlesLost = _stats[loser].battlesLost + 1;
        _updateLeaderboard(winner);
    }
    
    /* Leaderboard functions */
    
    function _updateLeaderboard(uint256 id) internal{
        (bool exists, , uint256 next) = _leaderboard.getNode(id);
        if(exists){
            if(next > 0 && _stats[id].battlesWon > _stats[next].battlesWon){
                _leaderboard.remove(id);
                _leaderboard.insertAfter(next, id);
            }
        }else{
            if(_stats[id].battlesWon > _stats[_leaderboard.first].battlesWon){
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