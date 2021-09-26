// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './CronosWarriors.sol';
import './modules/Modular.sol';
import './lib/structs/VisualsLib.sol';

contract WarriorVisuals is Modular {
    
    mapping(uint256 => VisualsLib.Visuals) private _visuals;
    
    constructor(){
    }
    
    function _exists(uint256 id) internal view returns(bool){
        return !VisualsLib.isNull(_visuals[id]);
    }
    
    function mint(uint256 id, string memory name) external onlyModules() {
        assert(!_exists(id));
        require(VisualsLib.isValidName(name), 'Name is not valid');
        _visuals[id] = VisualsLib.Visuals(name);
    }
    
    function burn(uint256 id) external onlyModules(){
        delete _visuals[id];
    }
    
    /* Getters */
    function visuals(uint256 id) external view returns (VisualsLib.Visuals memory){
        return _visuals[id];
    }

    function warriorName(uint256 id) external view returns (string memory){
        return _visuals[id].name;
    }
    
    /* Setters */

}