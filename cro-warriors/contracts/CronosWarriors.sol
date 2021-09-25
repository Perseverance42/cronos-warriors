pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./lib/Math.sol";
import "./lib/Compute.sol";

contract CronosWarriors is ERC721Enumerable  {
    
    uint256 public decimalsEth = 18;
    uint256 public decimalsEp = 8; 
    uint256 public epScale = 10**decimalsEp;
    uint256 public epS1 = 10**(decimalsEth-decimalsEp);
    uint256 public epS1Root = Math.sqrt(epS1);
    uint256 public battleRequestTimeout = 500;
    
    event Mint(uint256 id);
    event Burn(uint256 id, uint256 released);

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
        bool inFight;
    }
    
    modifier isOwner(uint256 id) {
        require(msg.sender==ownerOf(id), 'Only the owner can do this!');
        _;
    }
    
    modifier isAdmin() {
        require(msg.sender==_admin, 'Only the admin can do this!');
        _;
    }
    
    modifier moduleCall(){
        require(_modules[msg.sender], 'only modules can do this');
        _;
    }
    
    address private _admin;
    uint256 private _strategicReserve;
    
    mapping (address => bool) private _modules;
    mapping (uint256 => Warrior) private _warriors;

    constructor() ERC721( "Cronos Warriors", "WAR" ) {
        _admin = msg.sender;
    }
    
    function setModule(address addr, bool allow) external isAdmin(){
        if(!allow){
            delete _modules[addr];   
        }else{
            _modules[addr] = true;    
        }
    }

    function mint(string memory name) public payable {
        require(msg.value == Compute.mintFee, 'Invalid mint fee!');
        uint id = totalSupply() + 1;
        _safeMint(msg.sender, id );
        
        Stats  memory s1 = Stats(0,0,0);
        Skills memory s2 = Skills(1,1,1);
        _warriors[id] = Warrior(s1, s2, name, msg.value, false);
        emit Mint(id);
    }
    
    function burn(uint256 id) public isOwner(id) {
        require(_exists(id), 'Warrior does not exist');
        uint256 balance = _warriors[id].experience;
        delete _warriors[id].skills;
        delete _warriors[id].stats;
        delete _warriors[id];
        _burn(id);
        payable(msg.sender).transfer(balance);
        emit Burn(id, balance);
    }
    
    function warriorPointsAvailable(uint256 id) external view returns(uint256){
        assert(_exists(id));
        return Compute.warriorLevel(_warriors[id].experience) - _warriors[id].stats.pointsSpend;
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
    
    function subExperienceSafe(uint256 id, uint256 amount) external moduleCall() {
        uint256 ep = _warriors[id].experience;
        ep = ep - amount;
        if( ep > _warriors[id].experience ){ //underflow check
            revert('To much ep lost!');
        }
        _warriors[id].experience = ep;
    }
    
    function addExperienceSafe(uint256 id, uint amount) external moduleCall() {
        uint256 ep = _warriors[id].experience;
        ep = ep + amount;
        if(ep < _warriors[id].experience){
            revert('To much ep gained!');
        }
        _warriors[id].experience = ep;
    }
    
    function warrior(uint256 id) external view returns(Warrior memory){
        return _warriors[id];
    }
    
    function increaseAttack(uint256 id) external isOwner(id){
        require(Compute.warriorLevel(_warriors[id].experience) - _warriors[id].stats.pointsSpend > 0, 'No spendable points');
        _warriors[id].skills.attack = _warriors[id].skills.attack + 1;
        _warriors[id].stats.pointsSpend = _warriors[id].stats.pointsSpend + 1;
    }
    
    function increaseDefense(uint256 id) external isOwner(id){
        require(Compute.warriorLevel(_warriors[id].experience) - _warriors[id].stats.pointsSpend > 0, 'No spendable points');
        _warriors[id].skills.defense = _warriors[id].skills.defense + 1;
        _warriors[id].stats.pointsSpend = _warriors[id].stats.pointsSpend + 1;
    }
    
    function increaseStamina(uint256 id) external isOwner(id){
        require(Compute.warriorLevel(_warriors[id].experience) - _warriors[id].stats.pointsSpend > 0, 'No spendable points');
        _warriors[id].skills.stamina = _warriors[id].skills.stamina + 1;
        _warriors[id].stats.pointsSpend = _warriors[id].stats.pointsSpend + 1;
    }
    
    function warriorLevel(uint256 id) external view returns(uint256){
        assert(_exists(id));
        return Compute.warriorLevel(_warriors[id].experience);
    }
    
    function warriorExperience(uint256 id) external view returns(uint256){
        assert(_exists(id));
        return _warriors[id].experience;
    }
    
    function warriorHealth(uint256 id) external view returns(uint256){
        assert(_exists(id));
        return Compute.warriorHealth(_warriors[id].experience, _warriors[id].skills.stamina);
    }
    
    function withdrawFromReserve(address payable to, uint256 amount) external{
        assert(msg.sender==_admin);
        require(amount <= _strategicReserve, 'amount to high');
        to.transfer(amount);
    }
    
    function strategicReserve() external view returns(uint256){
        return _strategicReserve;
    }
    
    function increaseReserve(uint256 amount) public moduleCall(){
        _strategicReserve = _strategicReserve + amount;
    }
    
    function exists(uint256 id) external view returns(bool){
        return _exists(id);
    }
    
    function admin() external view returns(address){
        return _admin;
    }
    
    
}