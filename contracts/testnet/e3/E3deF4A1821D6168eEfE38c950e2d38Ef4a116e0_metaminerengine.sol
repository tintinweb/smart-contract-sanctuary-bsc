/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

pragma solidity 0.5.16;

interface IBEP20 {

  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
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
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

contract metaminerengine is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => uint256) private _chest;
  mapping (address => uint256) private _pickaxe;
  mapping (address => uint256) private _miner;
  mapping (address => uint256) private _power;
  mapping (address => uint256) private _uplevel;

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
  uint256 public _maxlevel;
  uint256 public _rewardrate;
  uint256 private _rarity;
  uint256 private _mrate;
  uint256 private _count;

  string private _symbol;
  string private _name;

  address public _tokencontract;

  bool private _ready;

  constructor() public {
    _name = "Meta-Miner Gold TestNet";
    _symbol = "$Gold TestNet";
    //setup mint fee//
    _mintfee_chest = 200;
    _mintfee_pickaxe = 25;
    _mintfee_miner = 100;
    _mintfee_uplevel = 30;
    _maxlevel = 5;
    _rewardrate = 1000;
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
    require( _ready == true,"BEP20: contract does not setup");
    uint256 mintcost0 = _mintfee_chest * 10 ** 18;
    uint256 mintcost1 = _mintfee_chest.mul(90).div(100);
    mintcost0 = mintcost0.mul(num);
    mintcost1 = mintcost1.mul(num);
    IBEP20 a = IBEP20(_tokencontract);
    if ( ingot == true ) {
        require(a.balanceOf(msg.sender) >= mintcost0,"BEP20: not enough $INGOT");
        a.transferFrom(msg.sender,address(this),mintcost0);
    } else {
        require(_balances[msg.sender] >= mintcost1,"BEP20: not enough $GOLD");
        _balances[msg.sender] = _balances[msg.sender].sub(mintcost1);
    }
        _chest[msg.sender] = _chest[msg.sender].add(num);
    return true;
  }

  function mintPickaxe(bool ingot,uint256 num) public returns (bool) {
    require( _ready == true,"BEP20: contract does not setup");
    uint256 mintcost0 = _mintfee_pickaxe * 10 ** 18;
    uint256 mintcost1 = _mintfee_pickaxe.mul(90).div(100);
    mintcost0 = mintcost0.mul(num);
    mintcost1 = mintcost1.mul(num);
    IBEP20 a = IBEP20(_tokencontract);
    if ( ingot == true ) {
        require(a.balanceOf(msg.sender) >= mintcost0,"BEP20: not enough $INGOT");
        a.transferFrom(msg.sender,address(this),mintcost0);
    } else {
        require(_balances[msg.sender] >= mintcost1,"BEP20: not enough $GOLD");
        _balances[msg.sender] = _balances[msg.sender].sub(mintcost1);
    }
        _pickaxe[msg.sender] = _pickaxe[msg.sender].add(num);
    return true;
  }

  function uplevel() public returns (bool) {
    require( _ready == true,"BEP20: contract does not setup");
    require( _uplevel[msg.sender] < _maxlevel,"BEP20 : pickaxe level was max");
    uint256 mintcost = _mintfee_uplevel * _uplevel[msg.sender].add(1);
    require(_balances[msg.sender] >= mintcost,"BEP20: not enough $GOLD");
    _balances[msg.sender] = _balances[msg.sender].sub(mintcost);
    _uplevel[msg.sender] = _uplevel[msg.sender].add(1);
    return true;
  }

  function mintMiner(bool ingot) public returns (uint256) {
    require( _ready == true,"BEP20: contract does not setup");
    uint256 mintcost0 = _mintfee_miner * 10 ** 18;
    uint256 mintcost1 = _mintfee_miner.mul(90).div(100);
    IBEP20 a = IBEP20(_tokencontract);
    if ( ingot == true ) {
        require(a.balanceOf(msg.sender) >= mintcost0,"BEP20: not enough $INGOT");
        a.transferFrom(msg.sender,address(this),mintcost0);
    } else {
        require(_balances[msg.sender] >= mintcost1,"BEP20: not enough $GOLD");
        _balances[msg.sender] = _balances[msg.sender].sub(mintcost1);
    }   
        _getrarity();
        _getmrate();
        if ( _rarity >= _miner[msg.sender] ) { 
            _miner[msg.sender] = _rarity;
            _power[msg.sender] = _raritypower[_rarity] * _mrate;
            return _rarity;
        } else { 
            _pickaxe[msg.sender] = _pickaxe[msg.sender].add(1);
            return 0;
        }
  }

  function updateTokenContract(address input) public onlyOwner returns (bool) {
    _tokencontract = input;
    _ready = true;
    return true;
  }

  function updateMintingFee(uint256 chest,uint256 pickaxe,uint256 miner,uint256 uplv,uint256 lv,uint256 rw) public onlyOwner returns (bool) {
    _mintfee_chest = chest;
    _mintfee_pickaxe = pickaxe;
    _mintfee_miner = miner;
    _mintfee_uplevel = uplv;
    _maxlevel = lv;
    _rewardrate = rw;
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

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  function chestOf(address account) external view returns (uint256) {
    return _chest[account];
  }

  function pickaxeOf(address account) external view returns (uint256) {
    return _pickaxe[account];
  }

  function minerOf(address account) external view returns (uint256) {
    return _miner[account];
  }

  function powerOf(address account) external view returns (uint256) {
    return _power[account];
  }

  function levelOf(address account) external view returns (uint256) {
    return _uplevel[account];
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

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

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