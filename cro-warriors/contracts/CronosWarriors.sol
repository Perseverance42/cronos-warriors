pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract CronosWarriors is ERC721Enumerable  {
    
    uint256 public decimalsEth = 18;
    uint256 public decimalsEp = 8; 
    uint256 public epScale = 10**decimalsEp;
    uint256 public epS1 = 10**(decimalsEth-decimalsEp);
    uint256 public epS1Root = sqrt(epS1);

    struct Stats {
        uint256 battlesWon;
        uint256 battlesLost;
        uint256 pointsSpend;
    }
    
    struct Skills {
        uint256 attack;
        uint256 defense;
        uint256 stamina;
    }
    
    address private _admin;
    uint256 private _mintFee;
    
    mapping (uint256 => uint256) private _wrExperience;
    mapping (uint256 => string)  private _wrNames;
    mapping (uint256 => Skills)  private _wrSkills;
    mapping (uint256 => Stats)   private _wrStats;
    
    constructor() ERC721( "Cronos Warriors", "WAR" ) {
        _mintFee = (10**decimalsEth); //1CRO
        _admin = msg.sender;
    }

    function mint(string memory name) public payable {
        require(msg.value == _mintFee, 'Invalid mint fee!');
        uint id = totalSupply() + 1;
        _safeMint(msg.sender, id );
        _wrNames[id] = name;
        _wrExperience[id] = msg.value;
        
        _wrSkills[id]= Skills(1,1,1);
        _wrStats[id] = Stats(0,0,0);
    }
    
    function mintFee() external view returns (uint256){
        return _mintFee;
    }
    
    function warriorPointsAvailable(uint256 id) external view returns(uint256){
        assert(_exists(id));
        
        return _warriorLevel(id) - _wrStats[id].pointsSpend;
    }
    
    function warriorSkills(uint256 id) external view returns(uint256, uint256, uint256){
        assert(_exists(id));
        Skills memory s = _wrSkills[id];
        return (s.attack, s.defense, s.stamina);
    }
    
    function warriorStats(uint256 id) external view returns(uint256, uint256, uint256){
        assert(_exists(id));
        Stats memory s = _wrStats[id];
        return (s.battlesWon, s.battlesLost, s.pointsSpend);
    }
    
    function warriorName(uint256 id) external view returns(string memory){
        require(_exists(id), 'unkown warrior');
        return _wrNames[id];
    }
    
    function damage(uint256 w1, uint256 w2) external view returns (uint256){
        require(_exists(w1), 'Warrior 1 does not exist');
        require(_exists(w1), 'Warrior 2 does not exist');
        return _damage(w1, w2);
    }
    
    function _damage(uint256 w1, uint256 w2) internal view returns(uint256) {
        uint256 dmg = (2 * _warriorLevel(w1) + 10) * 10000000000;
        uint256 def = (_wrSkills[w1].attack * 10000000000) / (_wrSkills[w2].defense * 10000000000);
        dmg = dmg / 2;
        dmg = dmg * def;
        dmg = dmg / 10000000000;
        return dmg;
    }
    
    function _experienceToSwap(uint256 w1, uint256 w2) internal view returns (uint256){
        uint256 exp = _wrExperience[w1] + _wrExperience[w2];
        exp = exp / 2;
        exp = exp / 10;
        return exp;
    }
    
    function _subExperienceSafe(uint256 id, uint256 amount) internal {
        uint256 ep = _wrExperience[id];
        ep = ep - amount;
        if( ep > _wrExperience[id] ){ //underflow check
            revert('To much ep lost!');
        }
        _wrExperience[id] = ep;
    }
    
    function _addExperienceSafe(uint256 id, uint amount) internal {
        uint256 ep = _wrExperience[id];
        ep = ep + amount;
        if(ep < _wrExperience[id]){
            revert('To much ep gained!');
        }
        _wrExperience[id] = ep;
    }
    
    function fight(uint256 w1, uint256 w2) external returns(uint256){
        require(_exists(w1), 'Warrior 1 does not exist');
        require(_exists(w1), 'Warrior 2 does not exist');
        uint256 h1 = _warriorHealth(w1);
        uint256 h2 = _warriorHealth(w2);
        bool fighting = true;
        uint256 winner = w2;
        uint256 looser = w1; 
        uint256 dmg;
        while(fighting){
            dmg = _damage(w2, w1);
            if(dmg<h1){
                h1 = h1 - dmg;
                
                //opponent dmg
                dmg = _damage(w1, w2);
                if(dmg<h2){
                    h2=h2-dmg;
                }else{
                    fighting = false;
                    winner = w1;
                    looser = w2;
                }
            }else{
                fighting = false;
            }
        }
        //calculate experience swap
        uint256 expToSwap = _experienceToSwap(w1, w2);
        _subExperienceSafe(looser, expToSwap);
        _addExperienceSafe(winner, expToSwap);
        return winner;
    }
    
    function increaseAttack(uint256 id) external {
        require(ownerOf(id) == msg.sender, 'Only the owner can do this');
        require(_warriorLevel(id) - _wrStats[id].pointsSpend > 0, 'No spendable points');
        _wrSkills[id].attack = _wrSkills[id].attack + 1;
        _wrStats[id].pointsSpend = _wrStats[id].pointsSpend + 1;
    }
    
    function increaseDefense(uint256 id) external {
        require(ownerOf(id) == msg.sender, 'Only the owner can do this');
        require(_warriorLevel(id) - _wrStats[id].pointsSpend > 0, 'No spendable points');
        _wrSkills[id].defense = _wrSkills[id].defense + 1;
        _wrStats[id].pointsSpend = _wrStats[id].pointsSpend + 1;
    }
    
    function increaseStamina(uint256 id) external {
        require(ownerOf(id) == msg.sender, 'Only the owner can do this');
        require(_warriorLevel(id) - _wrStats[id].pointsSpend > 0, 'No spendable points');
        _wrSkills[id].stamina = _wrSkills[id].stamina + 1;
        _wrStats[id].pointsSpend = _wrStats[id].pointsSpend + 1;
    }
    
    function _warriorLevel(uint256 id) internal view returns(uint256){
        uint256 lvl = _secureMinus(_wrExperience[id], _mintFee);
        lvl = lvl/epScale;
        lvl = lvl*10;
        lvl = sqrt(lvl);
        lvl = lvl/epS1Root + 1;
        return lvl;
    }
    
    function _secureMinus(uint256 a, uint256 b) internal pure returns(uint256){
        if(b>=a){
            return 0;
        }else{
            return a-b;
        }
    }
    
    function warriorLevel(uint256 id) external view returns(uint256){
        assert(_exists(id));
        return _warriorLevel(id);
    }
    
    function warriorExperience(uint256 id) external view returns(uint256){
        assert(_exists(id));
        return _wrExperience[id];
    }
    
    function _warriorHealth(uint256 id) internal view returns(uint256){
        return 10 * (_warriorLevel(id) + _wrSkills[id].stamina);
    }
    
    function warriorHealth(uint256 id) external view returns(uint256){
        assert(_exists(id));
        return _warriorHealth(id);
    }
    
    function sqrt(uint x) internal pure returns (uint y) {
        if(x==0){
            return 0;
        }
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}