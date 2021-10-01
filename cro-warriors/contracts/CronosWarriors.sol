// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

/**
 * CronosWarriors is "only" used to manage ownership of warriors and make them tradeable on all ER721 enabled marketplaces
 **/
contract CronosWarriors is ERC721Enumerable, AccessControl  {
    
    /* Access control */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    constructor() ERC721( "Cronos Warriors", "WAR" ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(uint256 id) public onlyRole(MINTER_ROLE) {
        _safeMint(tx.origin, id);
    }
    
    function burn(uint256 id) public onlyRole(MINTER_ROLE){
        _burn(id);
    }
    
    /* Getters */
    
    function exists(uint256 id) external view returns(bool){
        return _exists(id);
    }
    
    function supportsInterface(bytes4 interfaceId) override(AccessControl, ERC721Enumerable) public pure returns(bool) {
        return  interfaceId == type(IERC721Enumerable).interfaceId || 
                interfaceId == type(IAccessControl).interfaceId;
    }
}
