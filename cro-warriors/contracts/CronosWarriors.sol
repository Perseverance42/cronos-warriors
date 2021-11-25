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

    mapping(uint256 => string) private _tokenURI;
    
    /* Access control */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant URI_ROLE = keccak256("URI_SETTER");
    
    constructor() ERC721( "Cronos Warriors", "WAR" ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(uint256 id) public onlyRole(MINTER_ROLE) {
        _safeMint(tx.origin, id);
    }
    
    function burn(uint256 id) public onlyRole(MINTER_ROLE){
        _burn(id);
        delete _tokenURI[id];
    }

    function setTokenURI(uint256 tokenID, string memory uri) external onlyRole(URI_ROLE){
        _tokenURI[tokenID] = uri;
    }

    function tokenURI(uint256 tokenID) public view virtual override returns (string memory) {
        require(_exists(tokenID), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURI[tokenID];
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
