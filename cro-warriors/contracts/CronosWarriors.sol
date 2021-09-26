// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./modules/Modular.sol";

/**
 * CronosWarriors is "only" used to manage ownership of warriors and make them tradeable on all ER721 enabled marketplaces
 **/
contract CronosWarriors is ERC721Enumerable, Modular  {
    
    constructor() ERC721( "Cronos Warriors", "WAR" ) {
    }

    function mint(uint256 id) public onlyModules() {
        _safeMint(tx.origin, id);
    }
    
    function burn(uint256 id) public onlyModules(){
        _burn(id);
    }
    
    /* Getters */
    
    function exists(uint256 id) external view returns(bool){
        return _exists(id);
    }
}