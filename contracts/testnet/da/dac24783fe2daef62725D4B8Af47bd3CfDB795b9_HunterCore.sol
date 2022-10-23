/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

/**
 *Submitted for verification at hecoinfo.com on 2022-06-24
*/

pragma solidity ^0.5.17;


interface IERC20 {
    function totalSupply() external view returns (uint256);

    
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
   
    
    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
  address payable public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);




  modifier onlyOwner() {
    require(msg.sender == owner,'Must contract owner');
    _;
  }

  function transferOwnership(address payable newOwner) public onlyOwner {
    require(newOwner != address(0),'Must contract owner');
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }


  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;

    return c;
  }


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract HunterFactory is Ownable {

  using SafeMath for uint256;

  event NewHunter(uint hunterId, string name,uint256 types,uint256 level,uint256 battle);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint public cooldownTime = 1 days;
  uint public hunterPrice = 0.01 ether;
  uint public hunterCount = 0;



  struct Hunter {
    string name;//名字
    uint256 types;//类型：1猎人./,2.马
    uint256 level;//级别
    uint256 battle;//战斗力
    uint256 capacity;//容量
    uint256 status;//状态：1正常可浏览可交易课加入部落./,2.已经加入部落/3.已经在挂卖状态
    uint256 readyTime;
  }

  Hunter[] public hunters;

  mapping (uint => address) public hunterToOwner;
  mapping (address => uint256) ownerHunterCount;
  mapping (uint => uint) public hunterFeedTimes;



  function _createHunter(string memory _name,uint256 types,uint256 level,uint256 battle,uint256 capacity) internal {
    uint256 id = hunters.push(Hunter(_name, types, level, battle, 0, 1,uint32(block.timestamp))) - 1;
    hunterToOwner[id] = msg.sender;
    ownerHunterCount[msg.sender] = ownerHunterCount[msg.sender].add(1);
    hunterCount = hunterCount.add(1);
    emit NewHunter(id, _name,types,level,battle);
  }

  function _generateRandomDna(string memory _str) private view returns (uint) {
    return uint(keccak256(abi.encodePacked(_str,now))) % dnaModulus;
  }

  function createHunter(string memory _name) public{
    //require(ownerHunterCount[msg.sender] == 0);
    uint256 randGailvs = _generateRandomDna('123');

    string memory name;
    uint256 randGailv = _generateRandomDna('randGailvs');
    randGailv = randGailv - randGailv % 1000;
    uint256 _level;
    uint256 _zhandouli = 0;
     
    if(randGailv<10){
        _level = 5;
        _zhandouli = _generateRandomDna('randGailv');
        _zhandouli = _zhandouli % 5000 + 1000;
        name = 'Elf';
    }   
    if(randGailv<70&&randGailv>=10){
        _level = 4;
        _zhandouli = _generateRandomDna('randGailv');
        _zhandouli = _zhandouli % 1000 + 500;
        name = 'shooter';
    }   
    if(randGailv<140&&randGailv>=70){
        _level = 3;
        _zhandouli = _generateRandomDna('randGailv');
        _zhandouli = _zhandouli % 500 + 200;
        name = 'warrior';
    }   
    if(randGailv<280&&randGailv>=1400){
        _level = 2;
        _zhandouli = _generateRandomDna('randGailv');
        _zhandouli = _zhandouli % 200 + 100;
        name = 'gunman';
    }   
    if(randGailv>=280){
        _level = 1;
        _zhandouli = _generateRandomDna('randGailv');
        _zhandouli = _zhandouli % 100 ;
        name = 'villagers';
    }  
    
//_createHunter(string memory _name,uint16 types,uint32 level,uint256 battle)
    _createHunter(_name,1,_level,_zhandouli,0);
  }

  function setHunterPrice(uint256 _price) external onlyOwner {
    hunterPrice = _price;
  }
}


contract TribeFactory is HunterFactory {

  using SafeMath for uint256;

  //event NewTribe(uint tribeId, string name, uint horse,uint256 people,uint16 battle,uint contract_day);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint public cooldownTime = 1 days;
  uint public tribePrice = 0.01 ether;
  uint public tribeCount = 0;

  mapping (uint => address) public tribeToOwner;
  mapping (uint => uint) public tribeFeedTimes;

  mapping (address => uint256) public lock1ToOwner;
  mapping (address => uint256) public lock2ToOwner;
  mapping (address => uint256) public lock3ToOwner;
  mapping (address => uint256) public lock4ToOwner;
  mapping (address => uint256) public lock5ToOwner;

  mapping (address => uint256) public lock1ToOwnerid;
  mapping (address => uint256) public lock2ToOwnerid;
  mapping (address => uint256) public lock3ToOwnerid;
  mapping (address => uint256) public lock4ToOwnerid;
  mapping (address => uint256) public lock5ToOwnerid;

  mapping (address => uint256) public locknumToOwner;

  
  function hunterJoinTribe1( uint256 _id) public   {
    require(lock1ToOwner[msg.sender] == 0,'yijingyoule!');
    require(hunters[_id].status == 1,'yijingyoule!');
    hunters[_id].status=2;
    lock1ToOwner[msg.sender] = 1;
    lock1ToOwnerid[msg.sender] = _id;
    locknumToOwner[msg.sender]=locknumToOwner[msg.sender].add(1);//  增加部落人数
  }
  function hunterOutTribe1( uint256 _id) public   {
    require(lock1ToOwner[msg.sender] == 1,'yijingyoule!');
    require(hunters[_id].status == 2,'yijingyoule!');
    hunters[_id].status=1;
    lock1ToOwner[msg.sender] = 0;
    locknumToOwner[msg.sender]=locknumToOwner[msg.sender].mul(1);//  增加部落人数
  }

  function hunterJoinTribe2( uint256 _id) public   {
    require(lock2ToOwner[msg.sender] == 0,'yijingyoule!');
    require(hunters[_id].status == 1,'yijingyoule!');
    hunters[_id].status=2;
    lock2ToOwner[msg.sender] = 1;
    lock2ToOwnerid[msg.sender] = _id;
    locknumToOwner[msg.sender]=locknumToOwner[msg.sender].add(1);//  增加部落人数
  }
  function hunterOutTribe2( uint256 _id) public   {
    require(lock2ToOwner[msg.sender] == 1,'yijingyoule!');
    require(hunters[_id].status == 2,'yijingyoule!');
    hunters[_id].status=1;
    lock2ToOwner[msg.sender] = 0;
    locknumToOwner[msg.sender]=locknumToOwner[msg.sender].mul(1);//  增加部落人数
  }
  function hunterJoinTribe3( uint256 _id) public   {
    require(lock3ToOwner[msg.sender] == 0,'yijingyoule!');
    require(hunters[_id].status == 1,'yijingyoule!');
    hunters[_id].status=2;
    lock3ToOwner[msg.sender] = 1;
    lock3ToOwnerid[msg.sender] = _id;
    locknumToOwner[msg.sender]=locknumToOwner[msg.sender].add(1);//  增加部落人数
  }
  function hunterOutTribe3( uint256 _id) public   {
    require(lock3ToOwner[msg.sender] == 1,'yijingyoule!');
    require(hunters[_id].status == 2,'yijingyoule!');
    hunters[_id].status=1;
    lock3ToOwner[msg.sender] = 0;
    locknumToOwner[msg.sender]=locknumToOwner[msg.sender].mul(1);//  增加部落人数
  }
  function hunterJoinTribe4( uint256 _id) public   {
    require(lock4ToOwner[msg.sender] == 0,'yijingyoule!');
    require(hunters[_id].status == 1,'yijingyoule!');
    hunters[_id].status=2;
    lock4ToOwner[msg.sender] = 1;
    lock4ToOwnerid[msg.sender] = _id;
    locknumToOwner[msg.sender]=locknumToOwner[msg.sender].add(1);//  增加部落人数
  }
  function hunterOutTribe4( uint256 _id) public   {
    require(lock4ToOwner[msg.sender] == 1,'yijingyoule!');
    require(hunters[_id].status == 2,'yijingyoule!');
    hunters[_id].status=1;
    lock4ToOwner[msg.sender] = 0;
    locknumToOwner[msg.sender]=locknumToOwner[msg.sender].mul(1);//  增加部落人数
  }
  function hunterJoinTribe5( uint256 _id) public   {
    require(lock5ToOwner[msg.sender] == 0,'yijingyoule!');
    require(hunters[_id].status == 1,'yijingyoule!');
    hunters[_id].status=2;
    lock5ToOwner[msg.sender] = 1;
    lock5ToOwnerid[msg.sender] = _id;
    locknumToOwner[msg.sender]=locknumToOwner[msg.sender].add(1);//  增加部落人数
  }
  function hunterOutTribe5( uint256 _id) public   {
    require(lock5ToOwner[msg.sender] == 1,'yijingyoule!');
    require(hunters[_id].status == 2,'yijingyoule!');
    hunters[_id].status=1;
    lock5ToOwner[msg.sender] = 0;
    locknumToOwner[msg.sender]=locknumToOwner[msg.sender].mul(1);//  增加部落人数
  }




}
 




contract HunterHelper is TribeFactory {

  uint public levelUpFee = 0.001 ether;
  uint public day_price =  5;
  uint public day10_price = 40;
  uint public join_price = 40;

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(hunters[_zombieId].level >= _level,'Level is not sufficient');
    _;
  }
  modifier onlyOwnerOf(uint _hunterId) {
    require(msg.sender == hunterToOwner[_hunterId],'Zombie is not yours');
    _;
  }

  modifier onlyOwnerOfTribe(uint _hunterId) {
    require(msg.sender == tribeToOwner[_hunterId],'Zombie is not yours');
    _;
  }
//hunterJoinTribe



 


  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function levelUp(uint _zombieId) external payable onlyOwnerOf(_zombieId){
    require(msg.value == levelUpFee,'No enough money');
    hunters[_zombieId].level++;
  }
/*
  function changeName(uint _zombieId, string calldata _newName) external  aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
    hunters[_zombieId].name = _newName;
  }
*/


  function getTribesByOwner(address  _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerHunterCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < hunters.length; i++) {
      if (hunterToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

  function getHuntersByOwner(address  _owner) external view returns(uint[] memory) {
    //uint[] memory result = new uint[](ownerTribeCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < hunters.length; i++) {
      if (hunterToOwner[i] == _owner) {
   //     result[counter] = i;
        counter++;
      }
    }
 //   return result;
  }

  function _triggerCooldown(Hunter storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime) - uint32((now + cooldownTime) % 1 days);
  }



/*
  function multiply(uint _zombieId, uint _targetDna) internal onlyOwnerOf(_zombieId) {
    Hunter storage myZombie = hunters[_zombieId];
    require(_isReady(myZombie),'Zombie is not ready');
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    newDna = newDna - newDna % 10 + 9;
    _createZombie("NoName", newDna);
    _triggerCooldown(myZombie);
  }
*/

}


contract HunterFeeding is HunterHelper {

  function feed(uint _zombieId) public onlyOwnerOf(_zombieId){
    Hunter storage myZombie = hunters[_zombieId];
//    require(_isReady(myZombie));
    hunterFeedTimes[_zombieId] = hunterFeedTimes[_zombieId].add(1);
    _triggerCooldown(myZombie);
    if(hunterFeedTimes[_zombieId] % 10 == 0){
//        uint newDna = myZombie.dna - myZombie.dna % 10 + 8;
 //       _createZombie("zombie's son", newDna);
    }
  }
}

contract HunterAttack is HunterHelper{
    
    uint randNonce = 0;
    uint public attackVictoryProbability = 70;
    uint public jianshao = 2;
    mapping(address => uint256) public mybonus;
    uint[] Monster = [1,2,3,4,5];
    uint[] Percentage = [60,55,50,45,40];
    uint[] ap_requirement = [40,45,50,55,60];
    uint[] bonus = [10,10,10,10,10];
    
    function randMod(uint _modulus) internal returns(uint){
        randNonce++;
        return uint(keccak256(abi.encodePacked(now,msg.sender,randNonce))) % _modulus;
    }
    
    function setAttackVictoryProbability(uint _attackVictoryProbability)public onlyOwner{
        attackVictoryProbability = _attackVictoryProbability;
    }

    
    
    function attackMonster(uint256 _heroId,uint _monsterId)external  returns(uint){
 //       require(msg.sender != hunterToOwner[_targetId],'The target zombie is yours!');
    //    Tribe storage myTribe = tribes[_tribeId];
    //    require(_isReady(myTribe),'Your Tribe is not ready!');
        uint rand = randMod(100);
    //    uint battle = tribes[_tribeId].battle_all;
        uint battle_need = ap_requirement[_monsterId];
    //    require(battle>=battle_need,'Your battle is too low!');
        uint gailv_need = Percentage[_monsterId];

        if(rand<=gailv_need){
    //        tribes[_tribeId].contract_day=tribes[_tribeId].contract_day-1;
    //        mybonus[msg.sender]+=bonus[_monsterId];
     //       tribes[_tribeId].battle_all=tribes[_tribeId].battle_all.mul(jianshao).div(100);
//            myZombie.winCount++;
//            myZombie.level++;
 //           enemyZombie.lossCount++;
 //           multiply(_zombieId,enemyZombie.dna);
     //       return _zombieId;
        }else{
 //           myZombie.lossCount++;
//            enemyZombie.winCount++;
  //        _triggerCooldown(myZombie);
   //         return _targetId;
        }
    }
    
    
  /* 
    function attack(uint _zombieId,uint _targetId)external onlyOwnerOf(_zombieId) returns(uint){
        require(msg.sender != hunterToOwner[_targetId],'The target zombie is yours!');
        Hunter storage myZombie = hunters[_zombieId];
        require(_isReady(myZombie),'Your zombie is not ready!');
        Hunter storage enemyZombie = hunters[_targetId];
        uint rand = randMod(100);
        if(rand<=attackVictoryProbability){
//            myZombie.winCount++;
//            myZombie.level++;
 //           enemyZombie.lossCount++;
 //           multiply(_zombieId,enemyZombie.dna);
            return _zombieId;
        }else{
 //           myZombie.lossCount++;
//            enemyZombie.winCount++;
            _triggerCooldown(myZombie);
            return _targetId;
        }
    }
  */   
}
contract ERC721 {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function transfer(address _to, uint256 _tokenId) public;
  function approve(address _to, uint256 _tokenId) public;
  function takeOwnership(uint256 _tokenId) public;
}

contract HunterOwnership is HunterHelper, ERC721 {

  mapping (uint => address) zombieApprovals;

  function balanceOf(address _owner) public view returns (uint256 _balance) {
    return ownerHunterCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return hunterToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    ownerHunterCount[_to] = ownerHunterCount[_to].add(1);
    ownerHunterCount[_from] = ownerHunterCount[_from].sub(1);
    hunterToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    _transfer(msg.sender, _to, _tokenId);
  }

  function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    zombieApprovals[_tokenId] = _to;
    emit Approval(msg.sender, _to, _tokenId);
  }

  function takeOwnership(uint256 _tokenId) public {
    require(zombieApprovals[_tokenId] == msg.sender);
    address owner = ownerOf(_tokenId);
    _transfer(owner, msg.sender, _tokenId);
  }
}




contract HunterMarket is HunterOwnership {
    struct zombieSales{
        address payable seller;
        uint price;
    }
    mapping(uint=>zombieSales) public zombieShop;
    uint shopZombieCount;
    uint public tax = 1 finney;
    uint public minPrice = 1 finney;

    event SaleZombie(uint indexed zombieId,address indexed seller);
    event BuyShopZombie(uint indexed zombieId,address indexed buyer,address indexed seller);

    function saleMyZombie(uint _zombieId,uint _price)public onlyOwnerOf(_zombieId){
        require(_price>=minPrice+tax,'Your price must > minPrice+tax');
        zombieShop[_zombieId] = zombieSales(msg.sender,_price);
        shopZombieCount = shopZombieCount.add(1);
        emit SaleZombie(_zombieId,msg.sender);
    }
    function buyShopZombie(uint _zombieId)public payable{
        require(msg.value >= zombieShop[_zombieId].price,'No enough money');
        _transfer(zombieShop[_zombieId].seller,msg.sender, _zombieId);
        zombieShop[_zombieId].seller.transfer(msg.value - tax);
        delete zombieShop[_zombieId];
        shopZombieCount = shopZombieCount.sub(1);
        emit BuyShopZombie(_zombieId,msg.sender,zombieShop[_zombieId].seller);
    }
    function getShopZombies() external view returns(uint[] memory) {
        uint[] memory result = new uint[](shopZombieCount);
        uint counter = 0;
        for (uint i = 0; i < hunters.length; i++) {
            if (zombieShop[i].price != 0) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function setTax(uint _value)public onlyOwner{
        tax = _value;
    }
    function setMinPrice(uint _value)public onlyOwner{
        minPrice = _value;
    }
}



contract HunterCore is HunterMarket,HunterFeeding,HunterAttack {

    string public constant name = "HunterGuild";
    string public constant symbol = "HunterGuild";

    function() external payable {
    }

    function withdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    function checkBalance() external view onlyOwner returns(uint) {
        return address(this).balance;
    }

}