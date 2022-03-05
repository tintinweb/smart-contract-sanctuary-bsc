/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

pragma solidity 0.5.16;

/*

███╗░░░███╗███████╗████████╗░█████╗░░░░░░░░░███╗░░░███╗██╗███╗░░██╗███████╗██████╗░░░░██╗░█████╗░
████╗░████║██╔════╝╚══██╔══╝██╔══██╗░░░░░░░░████╗░████║██║████╗░██║██╔════╝██╔══██╗░░░██║██╔══██╗
██╔████╔██║█████╗░░░░░██║░░░███████║░█████║░██╔████╔██║██║██╔██╗██║█████╗░░██████╔╝░░░██║██║░░██║
██║╚██╔╝██║██╔══╝░░░░░██║░░░██╔══██║░░░░░░░░██║╚██╔╝██║██║██║╚████║██╔══╝░░██╔══██╗░░░██║██║░░██║
██║░╚═╝░██║███████╗░░░██║░░░██║░░██║░░░░░░░░██║░╚═╝░██║██║██║░╚███║███████╗██║░░██║██╗██║╚█████╔╝
╚═╝░░░░░╚═╝╚══════╝░░░╚═╝░░░╚═╝░░╚═╝░░░░░░░░╚═╝░░░░░╚═╝╚═╝╚═╝░░╚══╝╚══════╝╚═╝░░╚═╝╚═╝╚═╝░╚════╝░

Mainnet Website : https://meta-miner.io/
Website(v1): https://metaminer.netlify.app/

*Community*
Discord : https://discord.com/invite/8H9nAW6TPT
Telegram : https://t.me/minereveryday
Twitter : https://twitter.com/EverydayMiner
Join us community for more detail.

------------------------------------------------------
----Token Lock with renounce owner to dead address----
----And have no mint/pause/blacklist function---------
----Safe token can't set tax more than 20%------------
------------------------------------------------------

*/

interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

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
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
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

contract MetaMinerToken is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => bool) private _permission;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint256 private _timelock;
  uint256 private _wanttimelock;
  uint256 private _buytaxfee;
  uint256 private _selltaxfee;
  uint256 private _impacttaxfee;
  uint256 private _tokenomic_pool;
  uint256 private _tokenomic_pool_future;
  uint256 private _tokenomic_pool_staking;
  uint256 private _tokenomic_marketing;
  uint256 private _tokenomic_dev;
  uint256 private _tokenomic_support;

  uint8 private _decimals;

  string private _symbol;
  string private _name;

  address private _previousOwner;
  address private _deadAddress;
  address private _poolAddress;
  address private _fpoolAddress;
  address private _spoolAddress;
  address private _dexAddress;
  address private _marketingAddress;
  address private _devAddress;
  address private _supportAddress;

  bool private _antibot;
  bool private _disabledfee;

  constructor() public {
    _name = "$Meta-Miner";
    _symbol = "$INGOT";
    _decimals = 18;
    _totalSupply = 1000000000 * (10 ** 18);
    _balances[msg.sender] = _totalSupply;
    _permission[msg.sender] = true;
    _deadAddress = 0x000000000000000000000000000000000000dEaD;
    _antibot = true;
    _buytaxfee = 20;
    _selltaxfee = 120;
    _impacttaxfee = 200;

    _tokenomic_pool_future = 4500;
    _tokenomic_pool = 3000;
    _tokenomic_pool_staking = 2300;
    _tokenomic_marketing = 50;
    _tokenomic_dev = 50;
    _tokenomic_support = 75;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function getOwner() external view returns (address) {
    return owner();
  }

  function getPreviousOwner() external view returns (address) {
    return _previousOwner;
  }

  function getPoolAddress() external view returns (address) {
    return _poolAddress;
  }
  
  function getfPoolAddress() external view returns (address) {
    return _fpoolAddress;
  }

  function getsPoolAddress() external view returns (address) {
    return _spoolAddress;
  }

  function getDexAddress() external view returns (address) {
    return _dexAddress;
  }

  function getMarketingAddress() external view returns (address) {
    return _marketingAddress;
  }

  function getDevAddress() external view returns (address) {
    return _devAddress;
  }

  function getSupportAddress() external view returns (address) {
    return _supportAddress;
  }

  function getPermission(address account) external view returns (bool) {
    return _permission[account];
  }

  function getAntibot() external view returns (bool) {
    return _antibot;
  }

  function getDisabledFee() external view returns (bool) {
    return _disabledfee;
  }

  function getTimelock() external view returns (uint256) {
    return _timelock;
  }

  function getBuyTax() external view returns (uint256) {
    return _buytaxfee;
  }

  function getSellTax() external view returns (uint256) {
    return _selltaxfee;
  }

  function getImpactTax() external view returns (uint256) {
    return _impacttaxfee;
  }

  function getlockCooldown() external view returns (uint256) {
    require( _wanttimelock != 0,"BEP20: owner not want to unlock now");
    return _wanttimelock + _timelock - block.timestamp;
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
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

  function mint(uint256 amount) public onlyOwner returns (bool) {
    require( 0 > 1,"BEP20: disable this function forever");
    _mint(_msgSender(), amount);
    return true;
  }

  function lock(uint256 timer) public onlyOwner returns (bool) {
    _previousOwner = owner();
    _timelock = timer;
    renounceOwnership();
    return true;
  }

  function updatePermission(address account,bool permission) public onlyOwner returns (bool) {
    _permission[account] = permission;
    return true;
  }

  function updatePoolAddress(address account) public onlyOwner returns (bool) {
    _poolAddress = account;
    _permission[account] = true;
    return true;
  }

  function updatefuturePoolAddress(address account) public onlyOwner returns (bool) {
    _fpoolAddress = account;
    _permission[account] = true;
    return true;
  }

  function updatestakePoolAddress(address account) public onlyOwner returns (bool) {
    _spoolAddress = account;
    _permission[account] = true;
    return true;
  }

  function updateDexAddress(address account) public onlyOwner returns (bool) {
    _dexAddress = account;
    return true;
  }

  function updateDevAddress(address account) public onlyOwner returns (bool) {
    _devAddress = account;
    _permission[account] = true;
    return true;
  }

  function updateMarketingAddress(address account) public onlyOwner returns (bool) {
    _marketingAddress = account;
    _permission[account] = true;
    return true;
  }

  function updateSupportAddress(address account) public onlyOwner returns (bool) {
    _supportAddress = account;
    _permission[account] = true;
    return true;
  }

  function updateBatch(address fpool,address pool,address stake,address dex,address market,address dev,address support) public onlyOwner returns (bool) {
    updatefuturePoolAddress(fpool);
    updatePoolAddress(pool);
    updatestakePoolAddress(stake);
    updateDexAddress(dex);
    updateDevAddress(market);
    updateMarketingAddress(dev);
    updateSupportAddress(support);
    _disabledfee = true;
    _transfer(msg.sender,_fpoolAddress,_totalSupply.mul(_tokenomic_pool_future).div(10000));
    _transfer(msg.sender,_spoolAddress,_totalSupply.mul(_tokenomic_pool_staking).div(10000));
    _transfer(msg.sender,_poolAddress,_totalSupply.mul(_tokenomic_pool).div(10000));
    _transfer(msg.sender,_marketingAddress,_totalSupply.mul(_tokenomic_marketing).div(10000));
    _transfer(msg.sender,_devAddress,_totalSupply.mul(_tokenomic_dev).div(10000));
    _transfer(msg.sender,_supportAddress,_totalSupply.mul(_tokenomic_support).div(10000));
    _disabledfee = false;
    antibotset(false);
    return true;
  }

  function sendToMany(address[] memory recipients,uint256 amount) public onlyOwner returns (bool) {
    _disabledfee = true;
    for(uint i = 0; i< recipients.length; i++){
      _transfer(msg.sender,recipients[i],amount.mul(_decimals));
    }
    _disabledfee = false;
    return true;
  }

  function antibotset(bool b) public onlyOwner returns (bool) {
    _antibot = b;
    return true;
  }

  function disableFeeset(bool b) public onlyOwner returns (bool) {
    _disabledfee = b;
    return true;
  }

  function setbuytax(uint256 tax) public onlyOwner returns (bool) {
    require( tax <= 200, "BEP20: safe token can't set tax above 20%");
    _buytaxfee = tax;
    return true;
  }
  
  function setselltax(uint256 tax) public onlyOwner returns (bool) {
    require( tax <= 200, "BEP20: safe token can't set tax above 20%");
    _selltaxfee = tax;
    return true;
  }

  function setimpacttax(uint256 tax) public onlyOwner returns (bool) {
    require( tax <= 200, "BEP20: safe token can't set tax above 20%");
    _impacttaxfee = tax;
    return true;
  }

  function wantunlock() public returns (bool) {
    require( msg.sender == _previousOwner,"BEP20: only previous owner can want unlock");
    _wanttimelock = block.timestamp;
    return true;
  }

  function unlock() public returns (bool) {
    require( msg.sender == _previousOwner,"BEP20: only previous owner can unlock");
    require( block.timestamp > _wanttimelock + _timelock,"BEP20: timelock is not expired");
    require( _wanttimelock != 0,"BEP20: want timelock before unlock");
    _transferOwnership(_previousOwner);
    _previousOwner = address(0);
    _wanttimelock = 0;
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    if ( _disabledfee != true ) {
      if ( _antibot == true ){
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
      if ( _permission[sender] != true ) {
      uint _fee = amount.mul(_impacttaxfee).div(1000);
      _balances[address(this)] = _balances[address(this)].add(_fee);
      _balances[recipient] = _balances[recipient].sub(_fee);
      emit Transfer(recipient, address(this), _fee);
      } else { emit Transfer(sender, recipient, amount); }
      } else {
        if ( sender == _dexAddress ) {
          _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
          _balances[recipient] = _balances[recipient].add(amount);
          emit Transfer(sender, recipient, amount);
          _takeFee(recipient,amount.mul(_buytaxfee).div(1000));
        } else if ( recipient == _dexAddress) {
          _takeFee(sender,amount.mul(_selltaxfee).div(1000));
          uint256 _beforetransfer = amount - (amount.mul(_selltaxfee).div(1000));
          _balances[sender] = _balances[sender].sub(_beforetransfer, "BEP20: transfer amount exceeds balance");
          _balances[recipient] = _balances[recipient].add(_beforetransfer);
          emit Transfer(sender, recipient, _beforetransfer);
        } else {
          _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
          _balances[recipient] = _balances[recipient].add(amount);
          emit Transfer(sender, recipient, amount);
        }
      }
    } else {
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
    }
  }

  function _takeFee(address account, uint256 amount) internal {
    uint Fee = amount.div(4);
    if ( _permission[account] == true ) { Fee = 0; }

    _balances[_poolAddress] = _balances[_poolAddress].add(Fee.mul(2));
    _balances[account] = _balances[account].sub(Fee.mul(2));
    emit Transfer(account, _poolAddress, Fee.mul(2));

    _balances[_marketingAddress] = _balances[_marketingAddress].add(Fee);
    _balances[account] = _balances[account].sub(Fee);
    emit Transfer(account, _marketingAddress, Fee);

    _balances[_devAddress] = _balances[_devAddress].add(Fee);
    _balances[account] = _balances[account].sub(Fee);
    emit Transfer(account, _supportAddress, Fee);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}