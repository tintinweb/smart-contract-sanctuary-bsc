/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {

  /**
   * @dev Multiplies two unsigned integers, reverts on overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath#mul: OVERFLOW");

    return c;
  }

  /**
   * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
}

  /**
   * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath#sub: UNDERFLOW");
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Adds two unsigned integers, reverts on overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath#add: OVERFLOW");

    return c;
  }

  /**
   * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
   * reverts when dividing by zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
    return a % b;
  }

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @title TRC20 interface
 */
interface ITRC20 {
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}



contract LobangDaoTestV1 is ITRC20, Ownable, Pausable {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  string private _name = 'LobangDaoTestV1';
  string private _symbol = 'LDAOT';
  uint8 private _decimals = 18;
  uint256 private _totalSupply = 1000000000 * 10 ** uint256(_decimals);

  address private _burnPool = address(0);
  address private _treasuryAddress;
  address private _daoAddress;
  address private _routerAddress;

  mapping(address => uint256) private _routerRecord;
  mapping(address => bool) private _routerRecordExist;
  address[] private _routerRecordAddress;

  uint256 public burnFee = 1;
  uint256 private _previousBurnFee = burnFee;
  uint256 public daoFee = 6;
  uint256 private _previousDaoFee = daoFee;
  uint256 public treasuryFee = 3;
  uint256 private _previousTreasuryFee = treasuryFee;

  uint256 public  feeStopAt = 500000000 * 10 ** uint256(_decimals);
  uint256 public rNonce;

  //uint256 private _referralRewardStopAt = 10000000 * 10 ** uint256(_decimals);

  uint256 private _initialValue = 8;
  uint256 private _initialValTotal;
  uint256 private _firstHavedTotal;
  uint256 private _referralReward = 300;
  uint256 private _referralRewardTotal;
  uint256 private _decreaseRate = 7;//0.7
  uint256 private _referral10HavedTotal;

  mapping(address => bool) private initialized;
  mapping(address => uint256) private _referralQuantity;

  /*function setReferralQuantity(address addr, uint256 quantity) public returns(bool) {
    _referralQuantity[addr] = quantity;
    return true;
  }*/

  mapping(address => bool) private _isExcludedFromFee;
  mapping(address => bool) private _isBlock;

  uint256 private _burnFeeTotal;
  uint256 private _daoFeeTotal;
  uint256 private _treasuryFeeTotal;

  constructor() Ownable() {
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;

    initialized[address(this)] = true;
    initialized[_msgSender()] = true;

    _balances[_msgSender()] = _totalSupply;

    emit Transfer(address(0), _msgSender(), _totalSupply);
  }
  
  receive () external payable {
    //claim(msg.sender);
  }
  fallback() external payable{
    //claim(msg.sender);
  }

  function name() public view virtual returns (string memory) {
    return _name;
  }

  function symbol() public view virtual returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual returns (uint8) {
    return _decimals;
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view virtual override returns (uint256) {
    return getBalance(account);
  }

  function getBalance(address _account) internal view returns (uint256) {
    if (!initialized[_account]) {
      return _balances[_account] + _initialValue * 10 ** uint256(_decimals);
    }
    else {
      return _balances[_account];
    }
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function _approve(address owner, address spender, uint256 amount) internal virtual {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function setInitialValue(uint256 initialValue) public onlyOwner {
    _initialValue = initialValue;
  }

  function setReferralReward(uint256 referralReward) public onlyOwner {
    _referralReward = referralReward;
  }

  function getReferralReward() public view returns(uint256) {
    return _referralReward;
  }

  function getReferralRewardTotal() public view returns(uint256) {
    return _referralRewardTotal;
  }

  function getInitialValTotal() public view returns(uint256) {
    return _initialValTotal;
  }

  function getFirstHavedTotal() public view returns(uint256) {
    return _firstHavedTotal;
  }

  /*function setReferralRewardStopAt(uint256 referralRewardStopAt) public onlyOwner {
    _referralRewardStopAt = referralRewardStopAt;
  }

  function getReferralRewardStopAt() public view returns(uint256) {
    return _referralRewardStopAt;
  }*/

  function getReferral10HavedTotal() public view returns(uint256) {
    return _referral10HavedTotal;
  }

  function setMaxStopFeeTotal(uint256 total) public onlyOwner {
    feeStopAt = total;
    restoreAllFee();
  }

  function excludeFromFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = true;
  }

  function includeInFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = false;
  }

  function setBlock(address account, bool key) public onlyOwner {
    _isBlock[account] = key;
  }

  function setTreasuryAddress(address treasuryAddr) public onlyOwner {
    _treasuryAddress = treasuryAddr;
  }

  function setDaoAddress(address daoAddr) public onlyOwner {
    _daoAddress = daoAddr;
  }

  function daoAddress() public view returns(address) {
    return _daoAddress;
  }

  function setRouterAddress(address routerAddr) public onlyOwner {
    _routerAddress = routerAddr;
  }

  function routerAddress() public view returns(address) {
    return _routerAddress;
  }

  function getRouterRecordCount() public view returns(uint256) {
    return _routerRecordAddress.length;
  }

  function getRouterRecord(uint256 index) public view returns(address _address, uint256 _amount) {
    _address = _routerRecordAddress[index];
    _amount = _routerRecord[_address];
  }

  function treasuryAddress() public view returns(address) {
    return _treasuryAddress;
  }

  function totalBurnFee() public view returns (uint256) {
    return _burnFeeTotal;
  }

  function totalTreasuryFee() public view returns (uint256) {
    return _treasuryFeeTotal;
  }

  function totalDaoFee() public view returns (uint256) {
    return _daoFeeTotal;
  }

  function removeAllFee() private {
    if(daoFee == 0 && burnFee == 0 && treasuryFee == 0) return;
    _previousDaoFee = daoFee;
    _previousBurnFee = burnFee;
    _previousTreasuryFee = treasuryFee;
    daoFee = 0;
    burnFee = 0;
    treasuryFee = 0;
  }

  function restoreAllFee() private {
    daoFee = _previousDaoFee;
    burnFee = _previousBurnFee;
    treasuryFee = _previousTreasuryFee;
  }

  function initialize(address _account) internal returns (bool success) {
    if (!initialized[_account]) {
      initialized[_account] = true;
    }
    return true;
  }

  function pushRouterAddress(address sender, uint256 amount) internal returns(bool) {
    if(_msgSender() == _routerAddress) {      
      _routerRecord[sender] += amount;
      if(!_routerRecordExist[sender]) {
        _routerRecordAddress.push(sender);
        _routerRecordExist[sender] = true;
      }      
    }
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    //require(recipient != address(this), "recipient is contract");
    //require(sender != owner(), "msg.sender is owner");

    pushRouterAddress(sender, amount);

    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), currentAllowance - amount);

    if (!initialized[recipient] && amount >= getRealValue(200)) {
      _referralQuantity[_msgSender()] += 1;

      //if(_referralRewardTotal < _referralRewardStopAt) {
        uint256 reward = getReferralReward(_msgSender());
        claim(_msgSender(), reward);
        _referralRewardTotal += reward;
      //}
      claim(recipient, getRealValue(8));
      _initialValTotal += getRealValue(8);
      claim(recipient, getRealValue(20));
      _firstHavedTotal += getRealValue(20);

      initialize(recipient);
    }

    uint256 count = _referralQuantity[_msgSender()];
    if(count == 10) {
      uint256 rAmount = randomtimes();
      claim(_msgSender(), rAmount);
    }

    return true;
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    //require(recipient != address(this), "recipient is contract");
    //require(_msgSender() != owner(), "msg.sender is owner");

    if (!initialized[recipient] && amount >= getRealValue(200)) {
      _referralQuantity[_msgSender()] += 1;

      //if(_referralRewardTotal < _referralRewardStopAt) {
        uint256 reward = getReferralReward(_msgSender());
        claim(_msgSender(), reward);
        _referralRewardTotal += reward;
      //}
      claim(recipient, getRealValue(8));
      _initialValTotal += getRealValue(8);
      claim(recipient, getRealValue(20));
      _firstHavedTotal += getRealValue(20);

      initialize(recipient);
    }

    uint256 count = _referralQuantity[_msgSender()];
    if(count == 10) {
      uint256 rAmount = randomtimes();
      claim(_msgSender(), rAmount);
    }

    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    require(amount >= 0, "Transfer amount must be greater than zero");
    require(!_isBlock[sender], "amount is block");

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
    if (_totalSupply <= feeStopAt) {
      removeAllFee();
      _transferStandard(sender, recipient, amount);
    } else {
        if(
            _isExcludedFromFee[sender] || 
            _isExcludedFromFee[recipient] || 
            sender == _daoAddress
        ) {
            removeAllFee();
        }
        _transferStandard(sender, recipient, amount);
        if(
            _isExcludedFromFee[sender] || 
            _isExcludedFromFee[recipient] || 
            sender == _daoAddress
        ) {
            restoreAllFee();
        }
    }
  }

  function _transferStandard(address sender, address recipient, uint256 tAmount) private {
    (uint256 tTransferAmount, uint256 tBurn, uint256 tDao, uint256 tTreasury) = _getValues(tAmount);

    _balances[sender] = _balances[sender].sub(tAmount);
    _balances[recipient] = _balances[recipient].add(tTransferAmount);

    if(
        !_isExcludedFromFee[sender] && 
        !_isExcludedFromFee[recipient] &&
        sender != _daoAddress
    ) {
        _balances[_daoAddress] = _balances[_daoAddress].add(tDao);
        _daoFeeTotal = _daoFeeTotal.add(tDao);

        _balances[_treasuryAddress] = _balances[_treasuryAddress].add(tTreasury);
        _treasuryFeeTotal = _treasuryFeeTotal.add(tTreasury);

        _totalSupply = _totalSupply.sub(tBurn);
        _burnFeeTotal = _burnFeeTotal.add(tBurn);

        emit Transfer(sender, _daoAddress, tDao);
        emit Transfer(sender, _treasuryAddress, tTreasury);
        emit Transfer(sender, _burnPool, tBurn);
    }

    emit Transfer(sender, recipient, tTransferAmount);
        
  }

  //function getBurnFee() private returns(uint256) {
    //return burnFee;
  //}

  function getReferralReward(address referralAddr) private view returns(uint256) {
    uint256 count = _referralQuantity[referralAddr];
    if(count == 1) {
      return getRealValue(_referralReward);
    } else if(count > 1 && count <= 7) {
      uint256 val = _referralReward.mul(_decreaseRate**(count - 1)).div(10**(count - 1));
      return getRealValue(val);
    } else {
      return getRealValue(30);
    }
  }

  function getRealValue(uint256 amount) private view returns(uint256) {
    return amount * 10 ** uint256(_decimals);
  }

  function calculateBurnFee(uint256 _amount) private view returns (uint256) {
    return _amount.mul(burnFee).div(10**2);
  }

  function calculateDaoFee(uint256 _amount) private view returns (uint256) {
    return _amount.mul(daoFee).div(10**2);
  }

  function calculateTreasuryFee(uint256 _amount) private view returns (uint256) {
    return _amount.mul(treasuryFee).div(10**2);
  }

  function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
    (uint256 tTransferAmount, uint256 tBurn, uint256 tDao, uint256 tTreasury) = _getTValues(tAmount);

    return (tTransferAmount, tBurn, tDao, tTreasury);
  }

  function _getTValues(uint256 tAmount) private view returns (uint256, uint256,uint256, uint256) {
    uint256 tBurn = calculateBurnFee(tAmount);
    uint256 tDao = calculateDaoFee(tAmount);
    uint256 tTreasury = calculateTreasuryFee(tAmount);
    uint256 tTransferAmount = tAmount.sub(tBurn).sub(tDao).sub(tTreasury);

    return (tTransferAmount, tBurn, tDao, tTreasury);
  }

  function claim(address recipient, uint256 amount) private returns(bool) {
    require(amount <= balanceOf(address(this)), "Insufficient of balance!");
    _transfer(address(this), recipient, amount);
    rNonce++;
    return true;
  }

  /*function claim(address recipient) public returns(bool){
    uint256 rAmount = randomtimes(rNonce);
    require(rAmount <= balanceOf(address(this)), "Insufficient of balance!");
    require(rAmount <= 2000000* 10**uint256(_decimals), "rAmount wrong: try again!");
    _transfer(address(this), recipient, rAmount);
    rNonce++;
    return true;
  }*/

  function randomtimes() private returns(uint256) {       
    uint256 x = uint256(keccak256(abi.encode(block.number,block.timestamp,msg.sender,rNonce)));
    //uint256 y = (x.mod(5001) + 1000)* 10**uint256(_decimals); //1000-5000
    uint256 y = (x.mod(5001));
    if(y < 1000) y += 1000;
    if(y > 5000) y = 2345;
    y = getRealValue(y);
    if(y > balanceOf(address(this))) {
        y = balanceOf(address(this));
    }
    _referral10HavedTotal += y;
    return y;
  }

  /*function randomTest() public returns(uint256) {
    return randomtimes();
  }*/
  
  function receiveFees() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }
}