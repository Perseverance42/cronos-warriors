// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import './CronosWarriors.sol';
import './lib/structs/VisualsLib.sol';

contract WarriorVisuals is AccessControl {
    
    /* Access control */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    /* Modules which get accessed */
    CronosWarriors public cronosWarriors;
    
    mapping(uint256 => VisualsLib.Visuals) private _visuals;
    
    constructor(address cronosWarriorsAddr){
        cronosWarriors = CronosWarriors(cronosWarriorsAddr);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    function _exists(uint256 id) internal view returns(bool){
        return !VisualsLib.isNull(_visuals[id]);
    }
    
    function mint(uint256 id, string memory name) external onlyRole(MINTER_ROLE) {
        assert(!_exists(id));
        require(VisualsLib.isValidName(name), 'Name is not valid');
        uint256 dna = VisualsLib.randomDNA(name, cronosWarriors.totalSupply());
        _visuals[id] = VisualsLib.Visuals(name, dna);
    }
    
    function burn(uint256 id) external onlyRole(MINTER_ROLE){
        delete _visuals[id];
    }
    
    /* Getters */
    function visuals(uint256 id) external view returns (VisualsLib.Visuals memory){
        return _visuals[id];
    }

    function warriorName(uint256 id) external view returns (string memory){
        return _visuals[id].name;
    }
    
    function warriorDNA(uint256 id) external view returns (uint256){
        return _visuals[id].dna;
    }
    
    /* Setters */
}