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
import "./Treasury.sol";

contract CronosWarriors is ERC721Enumerable, Modular  {
    
    uint256 public decimalsEth = 18;
    uint256 public decimalsEp = 8; 
    uint256 public epScale = 10**decimalsEp;
    uint256 public epS1 = 10**(decimalsEth-decimalsEp);
    uint256 public epS1Root = Math.sqrt(epS1);
    uint256 public battleRequestTimeout = 500;
    
    event Mint(uint256 id);
    event Burn(uint256 id);

    modifier onlyOwnerOf(uint256 id) {
        require(msg.sender==ownerOf(id), 'Only the owner can do this!');
        _;
    }

    WarriorSkills public warriorSkills;
    WarriorStats  public warriorStats;
    Treasury      public treasury;
    BattleBoard   public battleBoard;
    
    constructor() ERC721( "Cronos Warriors", "WAR" ) {
        treasury = new Treasury();
        warriorSkills = new WarriorSkills();
        warriorStats = new WarriorStats();
        battleBoard = new BattleBoard(address(warriorSkills), address(warriorStats), address(treasury));
        
        address bbAddr = address(battleBoard);
        treasury.setModule(bbAddr, true);
        treasury.transferOwnership(msg.sender);
        
        warriorSkills.setModule(bbAddr,  true);
        warriorSkills.transferOwnership(msg.sender);
        
        warriorStats.setModule(bbAddr,  true);
    }

    function mint(string memory name) public payable {
        require(msg.value == Compute.mintFee, 'Invalid mint fee!');
        uint id = totalSupply() + 1;
        
        warriorSkills.mint(id);
        warriorStats.mint(id);
        treasury.addExperience{value:msg.value}(id); //transfer 
        
        _safeMint(msg.sender, id );
        emit Mint(id);
    }
    
    function burn(uint256 id) public onlyOwnerOf(id) {
        require(_exists(id), 'Warrior does not exist');
        
        warriorSkills.burn(id);
        warriorStats.burn(id);
        _burn(id);
        
        treasury.withdrawExperience(id, payable(msg.sender));
        
        emit Burn(id);
    }
    
    function exists(uint256 id) external view returns(bool){
        return _exists(id);
    }
}