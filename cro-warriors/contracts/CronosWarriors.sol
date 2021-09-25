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
    
    struct Warrior {
        Stats stats;
        Skills skills;
        string name;
        uint256 experience;
    }
    
    address private _admin;
    uint256 private _mintFee;
    
    mapping (uint256 => Warrior) private _warriors;
    
    constructor() ERC721( "Cronos Warriors", "WAR" ) {
        _mintFee = (10**decimalsEth); //1CRO
        _admin = msg.sender;
    }

    function mint(string memory name) public payable {
        require(msg.value == _mintFee, 'Invalid mint fee!');
        uint id = totalSupply() + 1;
        _safeMint(msg.sender, id );
        
        Stats  memory s1 = Stats(0,0,0);
        Skills memory s2 = Skills(1,1,1);
        _warriors[id] = Warrior(s1, s2, name, msg.value);
    }
    
    function mintFee() external view returns (uint256){
        return _mintFee;
    }
    
    function warriorPointsAvailable(uint256 id) external view returns(uint256){
        assert(_exists(id));
        
        return _warriorLevel(id) - _warriors[id].stats.pointsSpend;
    }
    
    function warriorSkills(uint256 id) external view returns(uint256, uint256, uint256){
        assert(_exists(id));
        Skills memory s = _warriors[id].skills;
        return (s.attack, s.defense, s.stamina);
    }
    
    function warriorStats(uint256 id) external view returns(uint256, uint256, uint256){
        assert(_exists(id));
        Stats memory s = _warriors[id].stats;
        return (s.battlesWon, s.battlesLost, s.pointsSpend);
    }
    
    function warriorName(uint256 id) external view returns(string memory){
        require(_exists(id), 'unkown warrior');
        return _warriors[id].name;
    }
    
    function damage(uint256 w1, uint256 w2) external view returns (uint256){
        require(_exists(w1), 'Warrior 1 does not exist');
        require(_exists(w1), 'Warrior 2 does not exist');
        return _damage(w1, w2);
    }
    
    function _damage(uint256 w1, uint256 w2) internal view returns(uint256) {
        uint256 dmg = (2 * _warriorLevel(w1) + 10) * 10000000000;
        uint256 def = (_warriors[w1].skills.attack * 10000000000) / (_warriors[w2].skills.defense * 10000000000);
        dmg = dmg / 2;
        dmg = dmg * def;
        dmg = dmg / 10000000000;
        return dmg;
    }
    
    function _experienceToSwap(uint256 w1, uint256 w2) internal view returns (uint256){
        uint256 exp = _warriors[w1].experience + _warriors[w2].experience;
        exp = exp / 2;
        exp = exp / 10;
        return exp;
    }
    
    function _subExperienceSafe(uint256 id, uint256 amount) internal {
        uint256 ep = _warriors[id].experience;
        ep = ep - amount;
        if( ep > _warriors[id].experience ){ //underflow check
            revert('To much ep lost!');
        }
        _warriors[id].experience = ep;
    }
    
    function _addExperienceSafe(uint256 id, uint amount) internal {
        uint256 ep = _warriors[id].experience;
        ep = ep + amount;
        if(ep < _warriors[id].experience){
            revert('To much ep gained!');
        }
        _warriors[id].experience = ep;
    }
    
    function fight(uint256 w1, uint256 w2) external {
        require(_exists(w1), 'Warrior 1 does not exist');
        require(_exists(w1), 'Warrior 2 does not exist');
        require(w1!=w2, 'Warrior can nor fight itself!');
        
        //health map
        uint256[2] memory health;
        health[0] = _warriorHealth(w1);
        health[1] = _warriorHealth(w2);
        
        //combat state
        bool fighting = true;
        uint256 dmg;
        
        //combat starting state
        uint256 r = rand();
        
        uint256 attacker = r < 499 ? w1 : w2;
        uint256 defender = r < 499 ? w2 : w1;
        
        //combat loop iterates until health of on fighter is 0
        while(fighting){
            uint256 h = health[ w1==attacker ? 1 : 0 ];
            dmg = _damage(attacker, defender);
            if(dmg < h){
                health[w1==attacker ? 1 : 0] = h - dmg;
                
                attacker = w1 == attacker ? defender : attacker;
                defender = w1 == defender ? attacker : defender;
            }else{
                fighting = false; 
                //current defender is the loser
            }
        }
        //calculate experience swap
        uint256 expToSwap = _experienceToSwap(w1, w2);
        _subExperienceSafe(attacker, expToSwap);
        _addExperienceSafe(defender, expToSwap);
        
    }
    
    function increaseAttack(uint256 id) external {
        require(ownerOf(id) == msg.sender, 'Only the owner can do this');
        require(_warriorLevel(id) - _warriors[id].stats.pointsSpend > 0, 'No spendable points');
        _warriors[id].skills.attack = _warriors[id].skills.attack + 1;
        _warriors[id].stats.pointsSpend = _warriors[id].stats.pointsSpend + 1;
    }
    
    function increaseDefense(uint256 id) external {
        require(ownerOf(id) == msg.sender, 'Only the owner can do this');
        require(_warriorLevel(id) - _warriors[id].stats.pointsSpend > 0, 'No spendable points');
        _warriors[id].skills.defense = _warriors[id].skills.defense + 1;
        _warriors[id].stats.pointsSpend = _warriors[id].stats.pointsSpend + 1;
    }
    
    function increaseStamina(uint256 id) external {
        require(ownerOf(id) == msg.sender, 'Only the owner can do this');
        require(_warriorLevel(id) - _warriors[id].stats.pointsSpend > 0, 'No spendable points');
        _warriors[id].skills.stamina = _warriors[id].skills.stamina + 1;
        _warriors[id].stats.pointsSpend = _warriors[id].stats.pointsSpend + 1;
    }
    
    function _warriorLevel(uint256 id) internal view returns(uint256){
        uint256 lvl = _secureMinus(_warriors[id].experience, _mintFee);
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
        return _warriors[id].experience;
    }
    
    function _warriorHealth(uint256 id) internal view returns(uint256){
        return 10 * (_warriorLevel(id) + _warriors[id].skills.stamina);
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
    
    function rand() public view returns(uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));
        return (seed - ((seed / 1000) * 1000));
    }
}