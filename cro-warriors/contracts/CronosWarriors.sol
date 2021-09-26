// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./lib/Math.sol";
import "./lib/Compute.sol";
import "./modules/Modular.sol";
import "./modules/BattleBoard.sol";
import "./WarriorSkills.sol";
import "./WarriorStats.sol";
import "./WarriorVisuals.sol";
import "./Treasury.sol";

contract CronosWarriors is ERC721Enumerable, Modular  {
    
    event Minted(uint256 id);
    event Burned(uint256 id);

    modifier onlyOwnerOf(uint256 id) {
        require(msg.sender==ownerOf(id), 'Only the owner can do this!');
        _;
    }

    WarriorSkills  public warriorSkills;
    WarriorStats   public warriorStats;
    WarriorVisuals public warriorVisuals;
    Treasury       public treasury;
    BattleBoard    public battleBoard;
    
    constructor() ERC721( "Cronos Warriors", "WAR" ) {
        //TODO move entire construction of contracts and and module linking into deployment scripts
        treasury = new Treasury();
        warriorSkills = new WarriorSkills();
        warriorStats = new WarriorStats();
        warriorVisuals = new WarriorVisuals();
        battleBoard = new BattleBoard(address(warriorSkills), address(warriorStats), address(treasury));
        
        address bbAddr = address(battleBoard);
        treasury.setModule(bbAddr, true);
        treasury.transferOwnership(msg.sender);
        
        warriorSkills.setModule(bbAddr,  true);
        warriorSkills.transferOwnership(msg.sender);
        
        warriorStats.setModule(bbAddr,  true);
    }

    //TODO move payable tx into treasury
    function mint(string memory name) public payable {
        require(msg.value == Compute.mintFee, 'Invalid mint fee!');
        uint id = totalSupply() + 1;
        
        warriorSkills.mint(id);
        warriorStats.mint(id);
        warriorVisuals.mint(id, name);
        treasury.addExperience{value:msg.value}(id); //transfer 
        
        _safeMint(msg.sender, id );
        emit Minted(id);
    }
    
    function burn(uint256 id) public onlyOwnerOf(id) {
        require(_exists(id), 'Warrior does not exist');
        
        warriorSkills.burn(id);
        warriorStats.burn(id);
        warriorVisuals.burn(id);
        _burn(id);
        
        treasury.withdrawExperience(id, payable(msg.sender));
        
        emit Burned(id);
    }
    
    /** Getters **/
    
    function exists(uint256 id) external view returns(bool){
        return _exists(id);
    }
}