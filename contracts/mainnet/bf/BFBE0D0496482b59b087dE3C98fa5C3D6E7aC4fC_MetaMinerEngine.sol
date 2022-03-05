/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

pragma solidity 0.5.16;

interface IBEP20 {
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function decimals() external view returns (uint8);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  constructor () internal { }
  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }
  function _msgData() internal view returns (bytes memory) {
    this;
    return msg.data;
  }
}

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract MetaMinerEngine is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => uint256) private _chest;
  mapping (address => uint256) private _pickaxe;
  mapping (address => uint256) private _minerId;
  mapping (address => uint256) private _mining;
  mapping (address => uint256) private _coral;
  mapping (address => uint256) private _balancesNFT;
  mapping (address => uint256) public _claimedRed;
  mapping (address => uint256) public _claimedWhite;

  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (uint256 => uint256) public _enumrarity;
  mapping (uint256 => uint256) private _chancerarity;
  mapping (uint256 => uint256) public _enummrate;
  mapping (uint256 => uint256) private _chancemrate;
  mapping (uint256 => uint256) public _raritypower;

  uint256 public _mintfee_chest;
  uint256 public _mintfee_pickaxe;
  uint256 public _mintfee_miner;
  uint256 public _mintfee_uplevel;
  uint256 public _mintfee_market;
  uint256 public _mintfee_TokenEquip;
  uint256 public _maxlevel;
  uint256 public _maxCollect;
  uint256 public _maxCollectPickaxe;
  uint256 public _maxCollectChest;
  uint256 public _rewardrate;
  uint256 public _goldmintrate;
  uint256 public _chestcap;
  uint256 public _minimalclaim;
  uint256 private _rarity;
  uint256 private _mrate;
  uint256 private _count;
  uint256 private nonce;

  uint8 private _decimals;
  string private _symbol;
  string private _name;

  address public _tokencontract;
  address public _packcontract1;
  address public _packcontract2;
  address public _operatorcontract;

  bool public _ready;
  bool public _goldmintable;
  bool public _marketplace;
  bool public _packevent;
  uint256 public _MinerCount;

  mapping (uint256 => uint256) private _Struct_Miner_Rarity;
  mapping (uint256 => uint256) private _Struct_Miner_Power;
  mapping (uint256 => address) private _Struct_Miner_Owner;
  mapping (uint256 => uint256) private _Struct_Miner_Age;
  mapping (uint256 => uint256) private _Struct_Miner_PickaxeLv;
  mapping (uint256 => uint256) private _Struct_Miner_PickaxeUp;
  mapping (uint256 => uint256) private _Struct_Miner_Durability;
  mapping (uint256 => uint256) private _Struct_Miner_Price;
  mapping (uint256 => uint256) private _Struct_Miner_TAX;
  mapping (uint256 => uint256) private _Struct_Miner_Layer_1;
  mapping (uint256 => uint256) private _Struct_Miner_Layer_2;
  mapping (uint256 => uint256) private _Struct_Miner_Layer_3;
  mapping (uint256 => uint256) private _Struct_Miner_Layer_4;
  
  constructor() public {
    _name = "Meta-Miner Gold";
    _symbol = "$Gold";
    _decimals = 0;
    //setup mint fee//
    _mintfee_chest = 200;
    _mintfee_pickaxe = 30;
    _mintfee_miner = 100;
    _mintfee_uplevel = 40;
    _mintfee_market = 150;
    _mintfee_TokenEquip = 0;
    _maxlevel = 5;
    _maxCollect = 10;
    _rewardrate = 1120;
    _goldmintrate = 285;
    _chestcap = 2000;
    _minimalclaim = 100;
    _maxCollectPickaxe = 20;
    _maxCollectChest = 15;
    //setup rarity chance//
    _count = 1;
    _chancerarity[_count] = 32;
    _chancemrate[_count] = 1;
    _raritypower[_count] = 5;
    _count = 2;
    _chancerarity[_count] = 16;
    _chancemrate[_count] = 3;
    _raritypower[_count] = 10;
    _count = 3;
    _chancerarity[_count] = 8;
    _chancemrate[_count] = 4;
    _raritypower[_count] = 15;
    _count = 4;
    _chancerarity[_count] = 4;
    _chancemrate[_count] = 2;
    _raritypower[_count] = 20;
    _count = 5;
    _chancerarity[_count] = 2;
    _chancemrate[_count] = 1;
    _raritypower[_count] = 30;
    _count = 6;
    _chancerarity[_count] = 1;
    _raritypower[_count] = 40;
  }

  function mintChest(bool ingot,uint256 num) public returns (bool) {
    require( _chest[msg.sender].add(num) <= _maxCollectChest, "BEP20: revert by max investion");
    require( _ready == true,"BEP20: contract does not setup");
    require( num > 0,"BEP20: please insert amount of mint");
    uint256 mintcost0 = _mintfee_chest * 10 ** 18;
    uint256 mintcost1 = _mintfee_chest.mul(_goldmintrate).div(100);
    mintcost0 = mintcost0.mul(num);
    mintcost1 = mintcost1.mul(num);
    IBEP20 a = IBEP20(_tokencontract);
    if ( _goldmintable == false ) { ingot = true; }
    if ( ingot == true ) {
        require(a.balanceOf(msg.sender) >= mintcost0,"BEP20: not enough $INGOT");
        a.transferFrom(msg.sender,address(this),mintcost0);
    } else {
        require(_balances[msg.sender] >= mintcost1,"BEP20: not enough $GOLD");
        _balances[msg.sender] = _balances[msg.sender].sub(mintcost1);
    }
    _previousCoral(msg.sender);
    _chest[msg.sender] = _chest[msg.sender].add(num);
    if ( _chest[msg.sender] == 1 ) {
        _newMiner(0,msg.sender);
        _minerId[msg.sender] = _MinerCount;
    }
    return true;
  }

  function mintPickaxe(bool ingot,uint256 num) public returns (bool) {
    require( _pickaxe[msg.sender].add(num) <= _maxCollectPickaxe, "BEP20: revert by max investion");
    require( _ready == true,"BEP20: contract does not setup");
    require( num > 0,"BEP20: please insert amount of mint");
    require( _chest[msg.sender] > 0,"BEP20 : require to mint chest first");
    uint256 mintcost0 = _mintfee_pickaxe * 10 ** 18;
    uint256 mintcost1 = _mintfee_pickaxe.mul(_goldmintrate).div(100);
    mintcost0 = mintcost0.mul(num);
    mintcost1 = mintcost1.mul(num);
    IBEP20 a = IBEP20(_tokencontract);
    if ( _goldmintable == false ) { ingot = true; }
    if ( ingot == true ) {
        require(a.balanceOf(msg.sender) >= mintcost0,"BEP20: not enough $INGOT");
        a.transferFrom(msg.sender,address(this),mintcost0);
    } else {
        require(_balances[msg.sender] >= mintcost1,"BEP20: not enough $GOLD");
        _balances[msg.sender] = _balances[msg.sender].sub(mintcost1);
    }
        _previousCoral(msg.sender);
        _pickaxe[msg.sender] = _pickaxe[msg.sender].add(num);
    return true;
  }

  function uplevel() public returns (bool) {
    require( _ready == true,"BEP20: contract does not setup");
    require( _Struct_Miner_PickaxeUp[_minerId[msg.sender]] < _maxlevel + 1,"BEP20 : pickaxe level was max");
    require( _minerId[msg.sender] != 0,"BEP20 : not found miner");
    uint256 mintcost = _mintfee_uplevel * _Struct_Miner_PickaxeUp[_minerId[msg.sender]];
    require(_balances[msg.sender] >= mintcost,"BEP20: not enough $GOLD");
    _balances[msg.sender] = _balances[msg.sender].sub(mintcost);
    uint256 ran = random(1,100);
    uint256 base = 115;
    if ( ran <= base.sub(_Struct_Miner_PickaxeUp[_minerId[msg.sender]].mul(15)) ) {
    uint256 afterup = _Struct_Miner_PickaxeUp[_minerId[msg.sender]].add(1);
    _Struct_Miner_PickaxeUp[_minerId[msg.sender]] = afterup;
    return true;
    } else { return false; }
  }

  function mintMiner(bool ingot) public returns (uint256) {
    require( _ready == true,"BEP20: contract does not setup");
    require( _chest[msg.sender] > 0,"BEP20 : require to mint chest first");
    uint256 mintcost0 = _mintfee_miner * 10 ** 18;
    uint256 mintcost1 = _mintfee_miner.mul(_goldmintrate).div(100);
    IBEP20 a = IBEP20(_tokencontract);
    if ( _goldmintable == false ) { ingot = true; }
    if ( ingot == true ) {
        require(a.balanceOf(msg.sender) >= mintcost0,"BEP20: not enough $INGOT");
        a.transferFrom(msg.sender,address(this),mintcost0);
    } else {
        require(_balances[msg.sender] >= mintcost1,"BEP20: not enough $GOLD");
        _balances[msg.sender] = _balances[msg.sender].sub(mintcost1);
    }   
        _previousCoral(msg.sender);
        _getrarity();
        _newMiner(_rarity,msg.sender);
        _minerId[msg.sender] = _MinerCount;
        return _MinerCount;
  }

  function claimRedPack() public returns (uint256) {
    require( _ready == true,"BEP20: contract does not setup");
    require( _chest[msg.sender] > 0,"BEP20 : require to mint chest first");
    require( _packevent == true );
    IBEP20 a = IBEP20(_packcontract1);
    require( a.balanceOf(msg.sender) > _claimedRed[msg.sender] ,"BEP20: packs is out of amount");
    _claimedRed[msg.sender] = _claimedRed[msg.sender].add(1);
    uint256 ran = random(1,31);
    if ( ran == 1 ) { _rarity = 6; }
    else if ( ran <= 3 ) { _rarity = 5; }
    else if ( ran <= 7 ) { _rarity = 4; }
    else if ( ran <= 15 ) { _rarity = 3; }
    else if ( ran > 15 ) { _rarity = 2; }
    _previousCoral(msg.sender);
    _enumrarity[_rarity] = _enumrarity[_rarity].add(1);
    _newMiner(_rarity,msg.sender);
    _minerId[msg.sender] = _MinerCount;
    return _MinerCount;
  }

  function claimWhitePack() public returns (uint256) {
    require( _ready == true,"BEP20: contract does not setup");
    require( _chest[msg.sender] > 0,"BEP20 : require to mint chest first");
    require( _packevent == true );
    IBEP20 a = IBEP20(_packcontract2);
    require( a.balanceOf(msg.sender) > _claimedWhite[msg.sender] ,"BEP20: packs is out of amount");
    _claimedWhite[msg.sender] = _claimedWhite[msg.sender].add(1);
    uint256 ran = random(1,7);
    if ( ran == 1 ) { _rarity = 6; }
    else if ( ran <= 3 ) { _rarity = 5; }
    else if ( ran > 3 ) { _rarity = 4; }
    _previousCoral(msg.sender);
    _enumrarity[_rarity] = _enumrarity[_rarity].add(1);
    _newMiner(_rarity,msg.sender);
    _minerId[msg.sender] = _MinerCount;
    return _MinerCount;
  }

  function mining() public returns (bool) {
    require( _ready == true,"BEP20: contract does not setup");
    require( _minerId[msg.sender] != 0,"BEP20 : not found miner");
    require( _pickaxe[msg.sender] > 0,"BEP20 : pickaxe is gone,buy new one.");
    uint256 col = _currentcoral(msg.sender);
    uint256 ran = random(101,110);
    uint256 durMax = _Struct_Miner_Rarity[_minerId[msg.sender]].add(8);
    uint256 dur = _Struct_Miner_Durability[_minerId[msg.sender]];
    if ( dur == 1 ) {
        _pickaxe[msg.sender] = _pickaxe[msg.sender].sub(1);
        _Struct_Miner_Durability[_minerId[msg.sender]] = durMax;
    } else {
        _Struct_Miner_Durability[_minerId[msg.sender]] = dur.sub(1);
    }
    require( col > ran,"BEP20: coral are too low");
    uint256 mine = col.div(ran);
    _balances[msg.sender] = _balances[msg.sender].add(mine);
    _mining[msg.sender] = block.timestamp;
    _coral[msg.sender] = 0;
    return true;
  }

  function claim() public returns (bool) {
    require( _ready == true,"BEP20: contract does not setup");
    require( _balances[msg.sender] > _minimalclaim ,"BEP20: revert by minimal claim");
    IBEP20 a = IBEP20(_tokencontract);
    uint256 claimtoken = _balances[msg.sender] * 10 ** 18;
    uint256 tax = _Struct_Miner_TAX[_minerId[msg.sender]];
    claimtoken = claimtoken.div(3);
    tax = claimtoken.mul(tax).div(1000);
    claimtoken = claimtoken.sub(tax);
    require(a.balanceOf(address(this)) > claimtoken,"BEP20: revert by reward pool");
    a.transfer(msg.sender,claimtoken);
    _balances[msg.sender] = 0;
  }

  function updateLimitInvesion(uint256 txPickaxe,uint256 txChest) public onlyOwner returns (bool) {
    _maxCollectPickaxe = txPickaxe;
    _maxCollectChest = txChest;
    return true;
  }

  function updateTokenContract(address input,bool ready) public onlyOwner returns (bool) {
    _tokencontract = input;
    _ready = ready;
    return true;
  }

  function updateOperatorContract(address input) public onlyOwner returns (bool) {
    _operatorcontract = input;
    return true;
  }

  function updatePackContract(address input1, address input2, bool openmint) public onlyOwner returns (bool) {
    _packcontract1 = input1;
    _packcontract2 = input2;
    _packevent = openmint;
    return true;
  }

  function updateGameEcosystem(uint256 chest,uint256 pickaxe,uint256 miner,uint256 uplv,uint256 marketfee,uint256 equip,uint256 lv,uint256 rw,uint256 goldbuyrate,bool mintable,uint256 cap,bool market,uint256 minclaim) public onlyOwner returns (bool) {
    _mintfee_chest = chest; //200
    _mintfee_pickaxe = pickaxe; //30
    _mintfee_miner = miner; //100
    _mintfee_uplevel = uplv; //40
    _mintfee_market = marketfee; //150(15%)
    _mintfee_TokenEquip = equip; //0 ingot
    _maxlevel = lv; //5
    _rewardrate = rw; //1120 (112%)
    _goldmintrate = goldbuyrate; // 285 (discost 5%)
    _goldmintable = mintable; // canmint buy gold
    _chestcap = cap; // 2000
    _marketplace = market; //false
    _minimalclaim = minclaim; //50 gold
    return true;
  }

  function getOwner() external view returns (address) {
    return owner();
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }
  

  function coralOf(address account) external view returns (uint256) {
    return _currentcoral(account);
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  function pickaxeOf(address account) external view returns (uint256) {
    return _pickaxe[account];
  }

  function chestOf(address account) external view returns (uint256) {
    return _chest[account];
  }

  function minerIdOf(address account) external view returns (uint256) {
    return _minerId[account];
  }

  function rarityOf(uint256 id) external view returns (uint256) {
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    return _Struct_Miner_Rarity[id];
  }

  function powerOf(uint256 id) external view returns (uint256) {
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    return _Struct_Miner_Power[id];
  }

  function minerOwner(uint256 id) external view returns (address) {
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    return _Struct_Miner_Owner[id];
  }

  function ageOf(uint256 id) external view returns (uint256) {
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    return _Struct_Miner_Age[id];
  }

  function pickaxeLvOf(uint256 id) external view returns (uint256) {
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    return _Struct_Miner_PickaxeLv[id];
  }

  function pickaxeUpOf(uint256 id) external view returns (uint256) {
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    return _Struct_Miner_PickaxeUp[id];
  }

  function durOf(uint256 id) external view returns (uint256) {
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    return _Struct_Miner_Durability[id];
  }

  function durMaxOf(uint256 id) external view returns (uint256) {
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    return _Struct_Miner_Rarity[id].add(8);
  }

  function priceOf(uint256 id) external view returns (uint256) {
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    return _Struct_Miner_Price[id];
  }

  function taxOf(uint256 id) external view returns (uint256) {
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    return _Struct_Miner_TAX[id];
  }

  function NftLayer(uint256 id,uint256 layer) external view returns (uint256) {
    require( layer > 0,"BEP20: layer out of range");
    require( layer < 5,"BEP20: layer out of range");
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    if ( layer == 1 ) { return _Struct_Miner_Layer_1[id]; }
    if ( layer == 2 ) { return _Struct_Miner_Layer_2[id]; }
    if ( layer == 3 ) { return _Struct_Miner_Layer_3[id]; }
    if ( layer == 4 ) { return _Struct_Miner_Layer_4[id]; }
  }

  function getINFT(address account,uint256 slot) external view returns (uint256) {
    uint256 result = 0;
    for (uint i = 0; i <= _MinerCount; i++) {
      if ( _Struct_Miner_Owner[i] == account ) {
        result = result.add(1);
        if ( result == slot ) {
          return i;
        }
      }
    } return 0;
  }

  function uplevelCost(address account) external view returns (uint256) {
    return _Struct_Miner_PickaxeUp[_minerId[account]].mul(_mintfee_uplevel);
  }

  function pickaxeMaxOf(address account) external view returns (uint256) {
    uint256 output = _Struct_Miner_PickaxeLv[_minerId[account]];
    output = output.add(_Struct_Miner_PickaxeUp[_minerId[account]]);
    return output.sub(1);
  }

  function setPriceMiner(uint256 id, uint256 amount) external returns (bool) {
    require( _Struct_Miner_Owner[id] == msg.sender ,"BEP20: nft does not your owner");
    require( _minerId[msg.sender] != id ,"BEP20: nft is mining now,take it out first");
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    require( amount >= 1 ,"BEP20: setting price is out of range");
    require( _marketplace == true ,"BEP20: maketplace was maintenance");
    _Struct_Miner_Price[id] = amount;
    return true;
  }

  function buyMiner(uint256 id) external returns (bool) {
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    require( _Struct_Miner_Owner[id] != msg.sender ,"BEP20: nft is your owner");
    require( _Struct_Miner_Price[id] > 1 ,"BEP20: this nft is not for sell or sold");
    require( _marketplace == true ,"BEP20: maketplace was maintenance");
    require( _ready == true,"BEP20: contract does not setup");
    uint256 soldprice = _Struct_Miner_Price[id] * 10 ** 18;
    IBEP20 a = IBEP20(_tokencontract);
    require(a.balanceOf(msg.sender) >= soldprice,"BEP20: not enough $INGOT to buy");
    uint256 mfee = soldprice.mul(_mintfee_market).div(1000);
    soldprice = soldprice.sub(mfee);
    a.transferFrom(msg.sender,address(this),mfee);
    a.transferFrom(msg.sender,_Struct_Miner_Owner[id],soldprice);
    address seller = _Struct_Miner_Owner[id];
    _balancesNFT[seller] = _balancesNFT[seller].sub(1);
    _balancesNFT[msg.sender] = _balancesNFT[msg.sender].add(1);
    _Struct_Miner_Price[id] = 1;
    _Struct_Miner_Owner[id] = msg.sender;
    return true;
  }

  function equipMiner(uint256 id) external returns (bool) {
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    require( _Struct_Miner_Owner[id] == msg.sender ,"BEP20: nft is not your owner");
    require( _Struct_Miner_Price[id] == 1 ,"BEP20: nft is on marketplace");
    require( _minerId[msg.sender] != id ,"BEP20: nft is equipping");
    require( _ready == true,"BEP20: contract does not setup");
    uint256 equipprice = _mintfee_TokenEquip * 10 ** 18;
    IBEP20 a = IBEP20(_tokencontract);
    require(a.balanceOf(msg.sender) >= equipprice,"BEP20: not enough $INGOT for change miner");
    a.transferFrom(msg.sender,address(this),equipprice);
    _previousCoral(msg.sender);
    _minerId[msg.sender] = id;
    return true;
  }

  function transferMiner(address recipient, uint256 id) external returns (bool) {
    _balancesNFT[0x000000000000000000000000000000000000dEaD] = 0;
    _balancesNFT[address(0)] = 0;
    _balancesNFT[owner()] = 0;
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    require( _Struct_Miner_Owner[id] == msg.sender ,"BEP20: nft is not your owner");
    require( _minerId[msg.sender] != id ,"BEP20: that miner is in playing");
    require( _balancesNFT[recipient] < _maxCollect ,"BEP20: nft collection was full");
    _balancesNFT[msg.sender] = _balancesNFT[msg.sender].sub(1);
    _balancesNFT[recipient] = _balancesNFT[recipient].add(1);
    _Struct_Miner_Owner[id] = recipient;
    return true;
  }

  function removeMiner(uint256 id) external returns (bool) {
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    require( _Struct_Miner_Owner[id] == msg.sender ,"BEP20: nft is not your owner");
    require( _minerId[msg.sender] != id ,"BEP20: that miner is in playing");
    _balancesNFT[msg.sender] = _balancesNFT[msg.sender].sub(1);
    _Struct_Miner_Owner[id] = address(this);
    _pickaxe[msg.sender] = _pickaxe[msg.sender].add(_Struct_Miner_Rarity[id]);
    return true;
  }

  function forcetransferMiner(address from, address recipient, uint256 id) external returns (bool) {
    require( msg.sender == _operatorcontract ,"BEP20: revert by operation");
    _balancesNFT[0x000000000000000000000000000000000000dEaD] = 0;
    _balancesNFT[address(0)] = 0;
    _balancesNFT[owner()] = 0;
    require( id > 0,"BEP20: nft id out of range");
    require( id <= _MinerCount,"BEP20: nft id out of range");
    require( _Struct_Miner_Owner[id] == from ,"BEP20: nft is not your owner");
    require( _minerId[from] != id ,"BEP20: that miner is in playing");
    require( _balancesNFT[recipient] < _maxCollect ,"BEP20: nft collection was full");
    _balancesNFT[from] = _balancesNFT[from].sub(1);
    _balancesNFT[recipient] = _balancesNFT[recipient].add(1);
    _Struct_Miner_Owner[id] = recipient;
    return true;
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function _getrarity() internal {
      _rarity = 0;
      if ( _enumrarity[1] < _chancerarity[1] ) {
       _rarity = 1;
       _enumrarity[_rarity] = _enumrarity[_rarity].add(1);
      } else if ( _enumrarity[2] < _chancerarity[2] ) {
       _rarity = 2;
       _enumrarity[_rarity.sub(1)] = 0;
       _enumrarity[_rarity] = _enumrarity[_rarity].add(1);
      } else if ( _enumrarity[3] < _chancerarity[3] ) {
       _rarity = 3;
       _enumrarity[_rarity.sub(1)] = 0;
       _enumrarity[_rarity] = _enumrarity[_rarity].add(1);
      } else if ( _enumrarity[4] < _chancerarity[4] ) {
       _rarity = 4;
       _enumrarity[_rarity.sub(1)] = 0;
       _enumrarity[_rarity] = _enumrarity[_rarity].add(1);
      } else if ( _enumrarity[5] < _chancerarity[5] ) {
       _rarity = 5;
       _enumrarity[_rarity.sub(1)] = 0;
       _enumrarity[_rarity] = _enumrarity[_rarity].add(1);
      } else {
       _rarity = 6;
       _enumrarity[_rarity.sub(1)] = 0;
       _enumrarity[_rarity] = _enumrarity[_rarity].add(1);
      }
  }

  function _getmrate() internal {
      _mrate = 0;
      if ( _enummrate[1] < _chancemrate[1] ) {
       _mrate = 1;
       _enummrate[_mrate] = _enummrate[_mrate].add(1);
      } else if ( _enummrate[2] < _chancemrate[2] ) {
       _mrate = 2;
       _enummrate[_mrate.sub(1)] = 0;
       _enummrate[_mrate] = _enummrate[_mrate].add(1);
      } else if ( _enummrate[3] < _chancemrate[3] ) {
       _mrate = 3;
       _enummrate[_mrate.sub(1)] = 0;
       _enummrate[_mrate] = _enummrate[_mrate].add(1);
      } else if ( _enummrate[4] < _chancemrate[4] ) {
       _mrate = 4;
       _enummrate[_mrate.sub(1)] = 0;
       _enummrate[_mrate] = _enummrate[_mrate].add(1);
      } else {
       _mrate = 5;
       _enummrate[_mrate.sub(1)] = 0;
       _enummrate[_mrate] = _enummrate[_mrate].add(1);
      }
  }

  function changepool(address _token,uint256 amount) public onlyOwner returns (bool) {
      IBEP20 a = IBEP20(_token);
      a.transfer(msg.sender,amount);
      return true;
  }

  function _previousCoral(address account) internal {
      _coral[account] = _currentcoral(account);
      _mining[account] = block.timestamp;
  }

  function _currentcoral(address account) internal view returns (uint256) {
    uint256 output = _powercoral(account).add(_coral[account]);
    uint256 max = _chest[account].mul(_chestcap);
    if ( output > max ) {
        return max;
    } else {
        return output;
    }
  }

  function _powercoral(address account) internal view returns (uint256) {
    uint256 output = _getpower(account).mul(_currentblock(account)).div(86400);
    output = output.mul(_rewardrate).div(1000);
    return output;
  }

  function _getpower(address account) internal view returns (uint256) {
    if ( _minerId[account] != 0 ) {
    uint256 output = _Struct_Miner_Power[_minerId[account]];
    uint256 pickaxeLv = _Struct_Miner_PickaxeLv[_minerId[account]];
    uint256 pickaxeUp = _Struct_Miner_PickaxeUp[_minerId[account]];
    uint256 maxpickaxe = pickaxeLv.add(pickaxeUp).sub(1);
    uint256 enumpickaxe = _pickaxe[account];
    if ( enumpickaxe > maxpickaxe ) {
        output = output.mul(24).div(10).mul(maxpickaxe);
    } else {
        output = output.mul(24).div(10).mul(enumpickaxe);
    }
    return output;
    } else { return 0; }
  }

  function _currentblock(address account) internal view returns (uint256) {
    uint256 output = block.timestamp.sub(_mining[account]);
    if ( _mining[account] == 0 ) { output = 0; }
    return output;
  }

  function random(uint256 from,uint256 to) internal returns (uint256) {
    uint256 randomnumber = uint(keccak256(abi.encodePacked(now, msg.sender, nonce))) % (to.sub(from));
    randomnumber = randomnumber + from;
    nonce++;
    return randomnumber;
  }

  function _newMiner(uint256 newRarity,address newOwner) internal {
    require( _balancesNFT[newOwner] < _maxCollect ,"BEP20: nft collection was full");
      _MinerCount = _MinerCount.add(1);
      _balancesNFT[newOwner] = _balancesNFT[newOwner].add(1);
      _Struct_Miner_Rarity[_MinerCount] = newRarity;
      _getmrate();
      _Struct_Miner_Power[_MinerCount] = (_raritypower[newRarity] * _mrate).add(625);
      _Struct_Miner_Owner[_MinerCount] = newOwner;
      _Struct_Miner_Age[_MinerCount] = block.timestamp;
      _Struct_Miner_PickaxeLv[_MinerCount] = newRarity.mul(2).add(1);
      _Struct_Miner_PickaxeUp[_MinerCount] = 1;
      _Struct_Miner_Durability[_MinerCount] = newRarity.add(8);
      _Struct_Miner_Price[_MinerCount] = 1;
      _Struct_Miner_TAX[_MinerCount] = 120;
      _Struct_Miner_TAX[_MinerCount] = _Struct_Miner_TAX[_MinerCount].sub(newRarity.mul(20));
      _Struct_Miner_Layer_1[_MinerCount] = random(1,10).add(newRarity);
      _Struct_Miner_Layer_2[_MinerCount] = random(1,10).add(newRarity);
      _Struct_Miner_Layer_3[_MinerCount] = random(1,10).add(newRarity);
      _Struct_Miner_Layer_4[_MinerCount] = random(1,10).add(newRarity);
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "");
    require(recipient != address(0), "");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}