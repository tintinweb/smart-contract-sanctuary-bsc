/**
 *Submitted for verification at BscScan.com on 2022-08-15
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
  uint public MaCount = 0;
  
  address public uniswapV2Pair;
  IERC20 tokenn;
  IERC20 usdt ;
  IERC20 usdt2 ;
  uint256 public decimals;
  uint256 public usdtdecimals;

  uint256 public HunterPrice;
  uint256 public HorsePrice;
  uint256 public TribePrice;

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
  mapping (address => uint256) ownerMaCount;
  mapping (uint => uint) public hunterFeedTimes;

  mapping (address => address) public inviter;
  mapping(address => uint256) public mybonus;
  mapping(address => uint256) public tixiantime;


  function _createHunter(address _owner,string memory _name,uint256 types,uint256 level,uint256 battle,uint256 capacity) internal {
    uint256 id = hunters.push(Hunter(_name, types, level, battle, capacity, 1,uint32(block.timestamp))) - 1;
    hunterToOwner[id] = _owner;
    if(types==1){
        ownerHunterCount[_owner] = ownerHunterCount[_owner].add(1);
        hunterCount = hunterCount.add(1);
    }
    if(types==2){
        ownerMaCount[_owner] = ownerMaCount[_owner].add(1);
        MaCount = MaCount.add(1);
    }
    
    
    emit NewHunter(id, _name,types,level,battle);
  }

  function _generateRandomDna(string memory _str) private view returns (uint) {
    return uint(keccak256(abi.encodePacked(_str,now))) % dnaModulus;
  }
  function _generateRandomDnas(uint  _str) private view returns (uint) {
    return uint(keccak256(abi.encodePacked(_str,now))) % dnaModulus;
  }

  function createHunter(address fatheraddr) public{
    //require(ownerHunterCount[msg.sender] == 0);
    require(fatheraddr!=msg.sender,"The recommended address cannot be your own");
    if (inviter[msg.sender] == address(0)) {
        inviter[msg.sender] = fatheraddr;
    }
    require(tokenn.balanceOf(msg.sender)>=HunterPrice/getprice()*10**decimals,"USDT balance too low");
    tokenn.transferFrom(msg.sender,address(this), HunterPrice/getprice()*10**decimals);
    mybonus[fatheraddr]=mybonus[fatheraddr]+HunterPrice*10**decimals/(getprice()*10);
    uint256 randGailvs = _generateRandomDna('123');

    string memory name;
    uint256 randGailv = _generateRandomDnas(randGailvs);
    randGailv = randGailv - randGailv % 1000;
    uint256 _level;
    uint256 _zhandouli = 0;
    if(randGailv>998){
        _level = 6;
        _zhandouli = _generateRandomDna('randGailv');
        _zhandouli = _zhandouli % 50000 + 10000;
        name = 'Paladin';
    }    
    if(randGailv<=998&&randGailv>=990){
        _level = 5;
        _zhandouli = _generateRandomDna('randGailv');
        _zhandouli = _zhandouli % 4000 + 1000;
        name = 'Elf';
    }   
    if(randGailv<=990&&randGailv>=930){
        _level = 4;
        _zhandouli = _generateRandomDna('randGailv');
        _zhandouli = _zhandouli % 3000 + 1000;
        name = 'shooter';
    }   
    if(randGailv<1930&&randGailv>=860){
        _level = 3;
        _zhandouli = _generateRandomDna('randGailv');
        _zhandouli = _zhandouli % 2000 + 1000;
        name = 'warrior';
    }   
    if(randGailv<860&&randGailv>=720){
        _level = 2;
        _zhandouli = _generateRandomDna('randGailv');
        _zhandouli = _zhandouli % 500 + 500;
        name = 'gunman';
    }   
    if(randGailv<720){
        _level = 1;
        _zhandouli = _generateRandomDna('randGailv');
        _zhandouli = _zhandouli % 500 + 500;
        name = 'villagers';
    }  
    
//_createHunter(string memory _name,uint16 types,uint32 level,uint256 battle)
    _createHunter(msg.sender,name,1,_level,_zhandouli,0);
  }

  function createHorse(address fatheraddr) public{
    //require(ownerHunterCount[msg.sender] == 0);
    require(fatheraddr!=msg.sender,"The recommended address cannot be your own");
    if (inviter[msg.sender] == address(0)) {
        inviter[msg.sender] = fatheraddr;
    }
    require(tokenn.balanceOf(msg.sender)>=HorsePrice/getprice()*10**decimals,"USDT balance too low");
    tokenn.transferFrom(msg.sender,address(this), HorsePrice/getprice()*10**decimals);
    mybonus[fatheraddr]=mybonus[fatheraddr]+HorsePrice*10**decimals/(getprice()*10);
    uint256 randGailvs = _generateRandomDna('235');
    string memory name;
    uint256 randGailv = _generateRandomDnas(randGailvs);
    randGailv = randGailv - randGailv % 1000;
    uint256 _level;
    uint256 _capacity;//容量
    if(randGailv>998){
        _level = 6;
        _capacity = 1;
        name = 'Nether Dragon';
    }    
    if(randGailv<=998&&randGailv>=990){
        _level = 5;
        _capacity = 2;
        name = 'Ghost Dragon';
    }   
    if(randGailv<990&&randGailv>=930){
        _level = 4;
        _capacity = 3;
        name = 'ice lion';
    }   
    if(randGailv<930&&randGailv>=860){
        _level = 3;
        _capacity = 4;
        name = 'Sombra';
    }   
    if(randGailv<860&&randGailv>=720){
        _level = 2;
        _capacity = 5;
        name = 'Cerberus';
    }   
    if(randGailv<720){
        _level = 1;
        _capacity = 20;
        name = 'Fire Shoes';
    }  
   

    _createHunter(msg.sender,name,2,_level,0,_capacity);
  }

  function buyHunter(string memory _name) public payable{
 //   require(ownerHunterCount[msg.sender] > 0);
 //   require(msg.value >= hunterPrice);
    uint256 randDna = _generateRandomDna(_name);
    randDna = randDna - randDna % 10 + 1;
 //   _createHunter(_name);
  }

  function setHunterPrice(uint256 _price) external onlyOwner {
    hunterPrice = _price;
  }

    function setusdtaddress(IERC20 address3,uint256 _decimals) public onlyOwner(){
        usdt = address3;
        usdtdecimals=_decimals;
    }

    function setuniswapV2Pairaddress(address address3) public onlyOwner(){
        uniswapV2Pair = address3;
    }
    function setHorsePrice(uint256 price) public onlyOwner(){
        HorsePrice = price;
    }
    function setTribePrice(uint256 price) public onlyOwner(){
        TribePrice = price;
    }

    function settokenaddress(IERC20 address3,uint256 _decimals) public onlyOwner(){
        tokenn = address3;
        decimals=_decimals;
    }



    function  transferOuttokenn(address toaddress,uint256 amount,uint256 decimals2)  external onlyOwner {
        tokenn.transfer(toaddress, amount*10**decimals2);
    }

    function  transferOutusdt(address toaddress,uint256 amount,uint256 decimals2)  external onlyOwner {
        usdt.transfer(toaddress, amount*10**decimals2);
    }

    function getprice() public view returns (uint256 _price) {
        uint256 lpusdtamount=usdt.balanceOf(uniswapV2Pair);
        uint256 lptokenamount=tokenn.balanceOf(uniswapV2Pair);
        _price=lpusdtamount*10**18/lptokenamount;
        
    }
    
    function  tixian(uint256 num)  external returns (bool) {
        bool Limited = tixiantime[msg.sender] !=0;
        require(Limited,"Exchange interval is too short.");
        uint256 lasttimehei = uint32((block.timestamp - tixiantime[msg.sender])/86400 );   
        if(lasttimehei<1){
            lasttimehei=1;
        }  
        uint256 shui;
        if(lasttimehei<=15){
            shui = 30-(lasttimehei*2);
        }else{
            shui = 0;
        }
        uint256 _swapprice=getprice();
        mybonus[msg.sender]=mybonus[msg.sender]-num;//增加转账额度
        tixiantime[msg.sender] = block.timestamp;
        tokenn.transferFrom(msg.sender,msg.sender, num*10**18/_swapprice);//基金钱包
      return true;
    }



}


contract TribeFactory is HunterFactory {

  using SafeMath for uint256;

  event NewTribe(uint tribeId, string name, uint horse,uint256 people,uint16 battle,uint contract_day);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint public cooldownTime = 1 days;
  uint public tribePrice = 0.01 ether;
  uint public tribeCount = 0;



  struct Tribe {
    string name;//名字

    uint256 horse_num;//马数量
    uint256 capacity_num;//容量
    uint256 people_num;//人数量
    uint256 battle_all;//战斗力
    uint256 contract_day;//合同天数
    uint256 status;//状态：1正常可浏览可交易课加入部落./,2.已经加入部落/3.已经在挂卖状态
    uint256 readyTime;
  }

  Tribe[] public tribes;

  mapping (uint => address) public tribeToOwner;
  mapping (address => uint) ownerTribeCount;
  mapping (uint => uint) public tribeFeedTimes;
  
  function _createTribe(address _owner,string memory _name) internal {
    uint id = tribes.push(Tribe(_name, 0, 0,0,0,1,0,uint32(block.timestamp))) - 1;
    tribeToOwner[id] = _owner;
    ownerTribeCount[_owner] = ownerTribeCount[_owner].add(1);
    tribeCount = tribeCount.add(1);
    emit NewTribe(id, _name, 0, 0,0,0);
  }
 
function createTribea(string memory _name,address fatheraddr) public {
  require(fatheraddr!=msg.sender,"The recommended address cannot be your own");
    if (inviter[msg.sender] == address(0)) {
        inviter[msg.sender] = fatheraddr;
    }
    require(tokenn.balanceOf(msg.sender)>=TribePrice/getprice()*10**decimals,"USDT balance too low");

    tokenn.transferFrom(msg.sender,address(this), TribePrice/getprice()*10**decimals);
    mybonus[fatheraddr]=mybonus[fatheraddr]+HorsePrice*10**decimals/(getprice()*10);

  _createTribe(msg.sender,_name);
  }
    function setRename(string memory _name,uint256 id) public {
        require(tribeToOwner[id]!=msg.sender,"is not yours");
        tribes[id].name = _name;
    }
    

}
 




contract HunterHelper is TribeFactory {

  uint public levelUpFee = 0.001 ether;
  uint public day_price =  2;
  uint public day7_price = 7;
  uint public day14_price = 14;
  uint public day28_price = 28;
  uint public join_price = 40;

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(hunters[_zombieId].level >= _level,'Level is not sufficient');
    _;
  }
  modifier onlyOwnerOf(uint _hunterId) {
    require(msg.sender == hunterToOwner[_hunterId],'hunter is not yours');
    _;
  }

  modifier onlyOwnerOfTribe(uint _tribeId) {
    require(msg.sender == tribeToOwner[_tribeId],'tribe is not yours');
    _;
  }
//hunterJoinTribe

  //签合同
  function signContract( uint256 _tribeId, uint256 day) public  onlyOwnerOfTribe(_tribeId) {
      uint256 day_price;
      if(day==1){
        day_price=day_price;
      }
      if(day==7){
        day_price=day7_price;
      }
      if(day==14){
        day_price=day14_price;
      }
      if(day==28){
        day_price=day28_price;
      }
      uint256 renshu = tribes[_tribeId].people_num;
      require(tokenn.balanceOf(msg.sender)>=renshu*day_price/getprice()*10**decimals,"USDT balance too low");
      tokenn.transferFrom(msg.sender,address(this), renshu*day_price/getprice()*10**decimals);
      if (tribeToOwner[_tribeId] == msg.sender) {
        tribes[_tribeId].contract_day=tribes[_tribeId].contract_day+day;//  
      }
  }

  
  function hunterJoinTribe( uint256 _tribeId, uint256[] memory _hunterId) public  onlyOwnerOfTribe(_tribeId) {
      uint256 buchong = tribes[_tribeId].contract_day;
      uint256 rongliang = tribes[_tribeId].capacity_num;
      require(tribes[_tribeId].people_num+_hunterId.length<=rongliang,'Your peolpl more then capacity');
  
      uint countera = 0;
      for (uint i = 0; i < _hunterId.length; i++) {
        if (hunterToOwner[i] == msg.sender) {
          hunters[_hunterId[i]].status=2;
          countera++;
      }
    }
    uint256 renshu = countera;
    if(buchong!=0){
      require(tokenn.balanceOf(msg.sender)>=renshu*buchong*day_price/getprice()*10**decimals,"USDT balance too low");
      tokenn.transferFrom(msg.sender,address(this), renshu*buchong*day_price/getprice()*10**decimals);
    }
      
    uint counter = 0;
      for (uint i = 0; i < _hunterId.length; i++) {
        if (hunterToOwner[i] == msg.sender) {
          hunters[_hunterId[i]].status=2;
          tribes[_tribeId].people_num=tribes[_tribeId].people_num+1;//  增加部落人数
          tribes[_tribeId].battle_all=tribes[_tribeId].battle_all+hunters[_hunterId[i]].battle;//  增加部落战斗力
          counter++;
      }
    }
  }

  function horseJoinTribe( uint256 _tribeId, uint256[] memory _hunterId) public  onlyOwnerOfTribe(_tribeId) {
      uint256 rongliang = 5-tribes[_tribeId].horse_num;
      require(_hunterId.length<=rongliang,'Your horse more then 5');
    uint counter = 0;
    for (uint i = 0; i < _hunterId.length; i++) {
      if (hunterToOwner[i] == msg.sender) {
        hunters[_hunterId[i]].status=2;
        tribes[_tribeId].horse_num=tribes[_tribeId].horse_num+1;//  增加部落里马数量
        tribes[_tribeId].capacity_num=tribes[_tribeId].capacity_num+hunters[_hunterId[i]].capacity;//  增加部落里容量
        counter++;
      }
    }
    tribes[_tribeId].horse_num=tribes[_tribeId].horse_num+counter;
  }

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

  function changeTribeName(uint _Id, string calldata _newName) external   onlyOwnerOf(_Id) {
    tribes[_Id].name = _newName;
  }

  function getTribesByOwner(address  _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerTribeCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < tribes.length; i++) {
      if (tribeToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

  function getByOwner(address  _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerHunterCount[_owner]);
    //uint[] memory result;
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
    uint[] memory result = new uint[](getHuntersByOwnergeshu(_owner));
    //uint[] memory result;
    uint counter = 0;
    for (uint i = 0; i < hunters.length; i++) {
      if (hunterToOwner[i] == _owner&&hunters[i].status==1&&hunters[i].types==1) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }
    function getHuntersByOwnergeshu(address  _owner) public view returns(uint counter) {
    uint[] memory result = new uint[](ownerHunterCount[_owner]);
    //uint[] memory result;
      counter = 0;
    for (uint i = 0; i < hunters.length; i++) {
      if (hunterToOwner[i] == _owner&&hunters[i].status==1&&hunters[i].types==1) {
        result[counter] = i;
        counter++;
      }
    }
    return counter;
  }
  
   function getMaByOwner(address  _owner) external view returns(uint[] memory) {
    uint[] memory result=new uint[](getMaByOwnergeshu(_owner));
    uint counter = 0;
    for (uint i = 0; i < hunters.length; i++) {
      if (hunterToOwner[i] == _owner&&hunters[i].status==1&&hunters[i].types==2) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }
  function getMaByOwnergeshu(address  _owner) public view returns(uint counter) {
    uint[] memory result=new uint[](ownerMaCount[_owner]);
      counter = 0;
    for (uint i = 0; i < hunters.length; i++) {
      if (hunterToOwner[i] == _owner&&hunters[i].status==1&&hunters[i].types==2) {
        result[counter] = i;
        counter++;
      }
    }
    return counter;
  }

  function getTribesOwnermessage(uint id) external view returns(string memory a,uint256 b,uint256 c,uint256 d,uint256 e,uint256 f,uint256 g,uint256 h) {
   
    a=tribes[id].name;
    b=tribes[id].horse_num;
    c=tribes[id].capacity_num;
    d=tribes[id].people_num;
    e=tribes[id].battle_all;
    f=tribes[id].contract_day;
    g=tribes[id].status;
    h=tribes[id].readyTime;
  }
  function getHunterOwnermessage(uint id) external view returns(string memory a,uint256 b,uint256 c,uint256 d,uint256 e,uint256 f,uint256 g) {
  
    a=hunters[id].name;
    b=hunters[id].types;
    c=hunters[id].level;
    d=hunters[id].battle;
    e=hunters[id].capacity;
    f=hunters[id].status;
    g=hunters[id].readyTime;
  }


  function _triggerCooldown(Hunter storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime) - uint32((now + cooldownTime) % 1 days);
  }

  function _isReady(Tribe storage _tribe) internal view returns (bool) {
      return (_tribe.readyTime <= now);
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
    uint public di25 = 1;
    
    string[] Monster = ['Bat','Wereshark','Rhinark','Lacodon','Oliphant','Ogre','Werewolf','Orc','Cyclops','Gargoyle','Golem','Land dragon','Chimera','Earthworm','Hydra','Rancor','Cerberus','Titan','Forest dragon','Ice dragon','Undead dragon','Volcano dragon','Fire demon','Invisible','best'];
    uint[] Percentage = [85,82,78,75,72,68,65,62,59,55,52,49,45,42,41,41,41,39,39,39,37,35,30,15];
    uint[] ap_requirement = [2000,5000,8000,10000,13000,17000,20000,22000,25000,28000,31000,34000,37000,40000,42000,47000,50000,53000,56000,60000,150000,250000,300000,60000];
    uint[] bonus = [10,18,26,32,44,60,74,85,101,121,141,162,190,215,245,295,325,380,430,490,1285,2300,3300,15000,16000];
    
    function randMod(uint _modulus) internal returns(uint){
        randNonce++;
        return uint(keccak256(abi.encodePacked(now,msg.sender,randNonce))) % _modulus;
    }
    
    function setAttackVictoryProbability(uint _attackVictoryProbability)public onlyOwner{
        attackVictoryProbability = _attackVictoryProbability;
    }

    function getHuntsList() external view returns(uint[] memory) {
        
        uint changdu ;
        if(di25==1){
            changdu = 25;
        }else{
            changdu = 24;
        }
        uint[] memory result = new uint[](changdu);
        uint counter = 0;
        for (uint i = 0; i < changdu; i++) {
                result[counter] = i;
                counter++;
        }
        return result;
    }
  function getHuntsOne(uint id) external view returns(string memory a,uint b,uint c,uint d) {
    a=Monster[id];
    b=Percentage[id];
    c=ap_requirement[id];
    d=bonus[id];

  }

  function attackAll()external  {

  }


    function attackMonster(uint256 _tribeId,uint _monsterId)external onlyOwnerOfTribe(_tribeId) returns(uint){
        Tribe storage myTribe = tribes[_tribeId];
        require(_isReady(myTribe),'Your Tribe is not ready!');

        uint battle_need;
        uint battle = tribes[_tribeId].battle_all;
        require(battle>=battle_need,'Your battle is too low!');
        uint rand = randMod(100);
        uint zhenshizhandou;
        if(_monsterId<=20){
            uint zhandouli = tribes[_tribeId].battle_all;
            zhandouli = ((zhandouli - ap_requirement[_monsterId])/1000)%1;
             zhenshizhandou = ap_requirement[_monsterId]+zhandouli;
        }else{
             zhenshizhandou = ap_requirement[_monsterId];
        }
        if(rand<=zhenshizhandou){
            tribes[_tribeId].contract_day=tribes[_tribeId].contract_day-1;
            mybonus[msg.sender]+=bonus[_monsterId];
            tribes[_tribeId].battle_all=tribes[_tribeId].battle_all.mul(jianshao).div(100);
            return bonus[_monsterId];
        }else{
            return 0;
        }
    }


}
contract ERC721 {
  event Transfertribe(address indexed _from, address indexed _to, uint256 _tokenId);
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
  //tribe

  function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    _transfer(msg.sender, _to, _tokenId);
  }
  function _transfertribe(address _from, address _to, uint256 _tokenId) internal {
    ownerTribeCount[_to] = ownerTribeCount[_to].add(1);
    ownerTribeCount[_from] = ownerTribeCount[_from].sub(1);
    tribeToOwner[_tokenId] = _to;
    emit Transfertribe(_from, _to, _tokenId);
  }
  //tribe

  function transfertribe(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    _transfertribe(msg.sender, _to, _tokenId);
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
    struct hunterSales{
        address payable seller;
        uint price;
    }
    struct tribeSales{
        address  seller;
        uint price;
    }
    mapping(uint=>hunterSales) public hunterShop;
    uint shopHunterCount;
    uint public tax = 1 finney;
    uint public minPrice = 1 finney;

    mapping(uint=>tribeSales) public tribeShop;
    uint shopTribeCount;
 

    event SaleHunter(uint indexed hunterId,address indexed seller);
    event BuyShopHunter(uint indexed hunterId,address indexed buyer,address indexed seller);

    event SaleTribe(uint indexed tribeId,address indexed seller);
    event BuyShopTribe(uint indexed tribeId,address indexed buyer,address indexed seller);

    function getShopHunteryesno(uint _hunterId) public view returns(uint yesno) {
        uint counter = 0;
        for (uint i = 0; i < hunters.length; i++) {
            if (hunterShop[i].price != 0 && i==_hunterId) {
                counter=1;
                break;
            }
        }
        return counter;
    }
//
    function saleMyTribe(uint _tribeId,uint _price)public onlyOwnerOfTribe(_tribeId){
        require(tribes[_tribeId].status == 0,"pople is already online");

        tribeShop[_tribeId] = tribeSales(msg.sender,_price);
        tribes[_tribeId].status=3;
        shopTribeCount = shopTribeCount.add(1);
        emit SaleTribe(_tribeId,msg.sender);
    }

    function getShopTribes() external view returns(uint[] memory) {
        uint[] memory result = new uint[](shopTribeCount);
        uint counter = 0;
        for (uint i = 0; i < tribes.length; i++) {
            if (tribeShop[i].price != 0) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
    function buyShopTribe(uint _tribeId)public payable{
        _transfertribe(tribeShop[_tribeId].seller,msg.sender, _tribeId);
        delete tribeShop[_tribeId];
        shopTribeCount = shopTribeCount.sub(1);
        tribes[_tribeId].status=0;
    }
    function saleMyHunter(uint _hunterId,uint _price)public onlyOwnerOf(_hunterId){
        require(hunters[_hunterId].status == 1,"pople is already online");
        hunterShop[_hunterId] = hunterSales(msg.sender,_price);
        hunters[_hunterId].status=3;
        shopHunterCount = shopHunterCount.add(1);
        emit SaleHunter(_hunterId,msg.sender);
    }
    function getShopHunters() external view returns(uint[] memory) {
        uint[] memory result = new uint[](shopHunterCount);
        uint counter = 0;
        for (uint i = 0; i < hunters.length; i++) {
            if (hunterShop[i].price != 0&&hunters[i].types==1) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
    function getShopHorse() external view returns(uint[] memory) {
        uint[] memory result = new uint[](shopHunterCount);
        uint counter = 0;
        for (uint i = 0; i < hunters.length; i++) {
            if (hunterShop[i].price != 0&&hunters[i].types==2) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
    function buyShopHunter(uint _hunterId)public payable{
        _transfer(hunterShop[_hunterId].seller,msg.sender, _hunterId);
        delete hunterShop[_hunterId];
        shopHunterCount = shopHunterCount.sub(1);
        hunters[_hunterId].status=1;
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
    constructor() public {
   
       owner = msg.sender;
    }

    function() external payable {
    }

    function withdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    function checkBalance() external view onlyOwner returns(uint) {
        return address(this).balance;
    }

}