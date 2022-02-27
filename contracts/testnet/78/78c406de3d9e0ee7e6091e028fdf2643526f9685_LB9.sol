/**
 *Submitted for verification at BscScan.com on 2022-02-27
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

contract LB9 is ITRC20, Ownable, Pausable {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  string private _name = 'LB9';
  string private _symbol = 'LB9';
  uint8 private _decimals = 18;
  uint256 private _totalSupply = 1000000000 * 10 ** uint256(_decimals);

  address private _burnPool = address(0);
  address private _treasuryAddress;
  address private _daoAddress;
  address private _routerAddress;
  address private _pairAddress;

  uint256 public burnFee = 1;//0.1%
  uint256 private _previousBurnFee = burnFee;
  uint256 public daoFee = 58;//5.8%
  uint256 private _previousDaoFee = daoFee;
  uint256 public treasuryFee = 1;//0.1%
  uint256 private _previousTreasuryFee = treasuryFee;

  bool public stopFee = false;
  uint256 public  feeStopAt = 500000000 * 10 ** uint256(_decimals);
  uint256 private rNonce;

  uint256 public activeAmount = 100;
  uint256 public activeAirdropRate = 6;

  uint256 private _initialValue = 8;
  //uint256 public claimInitialValTotal;
  //uint256 public claimFirstHavedTotal;
  uint256 public referralFirstReward = 140;
  //uint256 public claimReferralRewardTotal;
  //uint256 public referralMinReward = 30;
  //uint256 public claimReferral10HavedTotal;

  mapping(address => bool) private initialized;
  mapping(address => uint256) private _referralQuantity;

  uint256 public referral10RewardCount = 20;
  mapping(address => bool) private _referral10IsHaved;

  uint256 public addLiquidityAmountSmall = 1000;
  mapping(address => bool) private _havedLiquidityRewardSmall;
  uint256 public addLiquidityAmountBig = 2000;  
  mapping(address => bool) private _havedLiquidityRewardBig;

  bool public stopHighFee = false;
  uint256 private _highFeeAmount = 10**15;
  uint256 public highFeeLoopCount = 200;
  mapping(address => bool) _notHighFeeAddress;

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
    initialized[address(0)] = true;

    _notHighFeeAddress[address(this)] = true;
    _notHighFeeAddress[_msgSender()] = true;
    _notHighFeeAddress[address(0)] = true;

    _balances[_msgSender()] = _totalSupply;

    emit Transfer(address(0), _msgSender(), _totalSupply);
  }
  
  receive() external payable {}
  fallback() external payable {}

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

  function setActiveAmount(uint256 amount) public onlyOwner {
    require(amount > 0, "Must be greater than 0");
    activeAmount = amount;
  }

  function setActiveAirdropRate(uint256 rate) public onlyOwner {
    activeAirdropRate = rate;
  }

  function setBurnFee(uint256 _burnFee) public onlyOwner {
    burnFee = _burnFee;
  }

  function setDaoFee(uint256 _daoFee) public onlyOwner {
    daoFee = _daoFee;
  }

  function setTreasuryFee(uint256 _treasuryFee) public onlyOwner {
    treasuryFee = _treasuryFee;
  }

  function setInitialValue(uint256 initialValue) public onlyOwner {
    _initialValue = initialValue;
  }

  function setReferralFirstReward(uint256 reward) public onlyOwner {
    //if(reward > 0) {
        //require(reward.mod(10) == 0, "Must be a multiple of 10");
        //require(reward > referralMinReward, "Must be greater than the minimum recommended airdrop");
    //}
    referralFirstReward = reward;
    //if(reward == 0) referralMinReward = 0;
  }

  /*function referralFirstReward() public view returns(uint256) {
    return _referralFirstReward;
  }*/

  /*function setReferralMinReward(uint256 minReward) public onlyOwner {
      require(minReward < referralFirstReward, "Must be less than the first referral airdrop");
      referralMinReward = minReward;
  }*/

  /*function referralMinReward() public view returns(uint256) {
      return _referralMinReward;
  }*/

  function setReferral10RewardCount(uint256 count) public onlyOwner {
    require(count > 0, "Must be greater than 0");
    referral10RewardCount = count;
  }

  function setStopFeeAt(uint256 total) public onlyOwner {
    feeStopAt = total;
    restoreAllFee();
  }

  function setStopFee(bool flag) public onlyOwner {
    if(!flag) {
      restoreAllFee();
    }
    stopFee = flag;
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
    initialized[_treasuryAddress] = true;
    _notHighFeeAddress[_treasuryAddress] = true;
  }

  /*function treasuryAddress() public view returns(address) {
    return _treasuryAddress;
  }*/

  function setDaoAddress(address daoAddr) public onlyOwner {
    _daoAddress = daoAddr;
    initialized[_daoAddress] = true;
    _notHighFeeAddress[_daoAddress] = true;
  }

  /*function daoAddress() public view returns(address) {
    return _daoAddress;
  }*/

  function setRouterAddress(address routerAddr) public onlyOwner {
    _routerAddress = routerAddr;
    initialized[_routerAddress] = true;
    _isExcludedFromFee[_routerAddress] = true;
  }

  /*function routerAddress() public view returns(address) {
    return _routerAddress;
  }*/

  function setPairAddress(address pair) public onlyOwner {
    _pairAddress = pair;
    initialized[_pairAddress] = true;
    _isExcludedFromFee[_pairAddress] = true;
  }

  /*function pairAddress() public view returns(address) {
    return _pairAddress;
  }*/

  function setHighFeeLoopCount(uint256 loopCount) public onlyOwner returns(bool) {
    require(loopCount > 0, "loopCount must be greater than 0");
    require(getRealValue(1).mod(loopCount) == 0, "Must be divisible by 0.001");
    highFeeLoopCount = loopCount;
    return true;
  }

  function setStopHighFee(bool flag) public onlyOwner {
    stopHighFee = flag;
  }

  /*function stopHighFee() public view returns(bool) {
    return _stopHighFee;
  }*/

  function setAddLiquidityAmountSmall(uint256 amount) public onlyOwner {
      require(amount < addLiquidityAmountBig, "Must be less than the large airdrop amount");
    addLiquidityAmountSmall = amount;
  }

  function setAddLiquidityAmountBig(uint256 amount) public onlyOwner {
    require(amount > addLiquidityAmountSmall, "Must be greater than the small airdrop amount");
    addLiquidityAmountBig = amount;
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

  function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    //require(recipient != address(this), "recipient is contract");
    //require(sender != owner(), "msg.sender is owner");

    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), currentAllowance - amount);

    bool isInit = initialized[recipient];

    active(isInit, recipient, amount);
    
    checkHighFee(isInit, amount);

    referralTenReward(sender);

    bool isRouterSender = _msgSender() == _routerAddress;
    if(isRouterSender && recipient == _pairAddress) {
      bool isHavedLiquidityRewardSmall = _havedLiquidityRewardSmall[sender];
      if(!isHavedLiquidityRewardSmall && amount >= getRealValue(addLiquidityAmountSmall)) {
        _havedLiquidityRewardSmall[sender] = true;
        claim(sender, getRealValue(addLiquidityAmountSmall).mul(10).div(100));
      }
      
      if(isHavedLiquidityRewardSmall && amount >= getRealValue(addLiquidityAmountBig)) {
        bool isHavedLiquidityRewardBig = _havedLiquidityRewardBig[sender];
        if(!isHavedLiquidityRewardBig) {
          _havedLiquidityRewardBig[sender] = true;
          //uint256 r = randomrate();
           claim(sender, getRealValue(addLiquidityAmountBig).mul(15).div(100));
        }
      }
    }

    return true;
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    //require(recipient != address(this), "recipient is contract");
    //require(_msgSender() != owner(), "msg.sender is owner");
    
    _transfer(_msgSender(), recipient, amount);

    bool isInit = initialized[recipient];

    active(isInit, recipient, amount);

    checkHighFee(isInit, amount);

    referralTenReward(_msgSender());

    return true;
  }

  function active(bool isInit, address to, uint256 amount) private {
    bool isRouterSender = _msgSender() == _routerAddress;
    if(!isInit && amount >= getRealValue(activeAmount)) {
      _referralQuantity[_msgSender()] += 1;

      uint256 reward = getReferralReward(_msgSender());
      if(reward > 0 && !isRouterSender) {
        claim(_msgSender(), reward);
        //claimReferralRewardTotal += reward;
      }
      
      if(!isRouterSender) {
        claim(to, getRealValue(_initialValue));
        //claimInitialValTotal += getRealValue(8);
      }

      if (_totalSupply > feeStopAt && !stopFee && !isRouterSender) {
        uint256 rAmount = amount.mul(activeAirdropRate).div(100);
        claim(to, rAmount);
        //claimFirstHavedTotal += getRealValue(10);
      }

      initialize(to);
    }
  }

  function checkHighFee(bool isInit, uint256 amount) private {
    bool isRouterSender = _msgSender() == _routerAddress;
    if(!stopHighFee && _totalSupply > feeStopAt && _msgSender() != _pairAddress) {
      if(isRouterSender) {
        if(amount < getRealValue(addLiquidityAmountSmall) && highFeeLoopCount > 0) {
          uint256 cAmount = _highFeeAmount.div(highFeeLoopCount);
          for (uint256 i = 0; i < highFeeLoopCount; i++) {
            claim(_msgSender(), cAmount);
          }
        }
      } else {
        if(isInit && !_notHighFeeAddress[_msgSender()] && highFeeLoopCount > 0) {
          uint256 cAmount = _highFeeAmount.div(highFeeLoopCount);
          for (uint256 i = 0; i < highFeeLoopCount; i++) {
            claim(_msgSender(), cAmount);
          }
        }
      }
    }
  }

  function referralTenReward(address sender) private {
    uint256 count = _referralQuantity[sender];
    bool isRouterSender = _msgSender() == _routerAddress;
    if(count == referral10RewardCount && !_referral10IsHaved[sender] && !isRouterSender) {
      _referral10IsHaved[sender] = true;
      uint256 rAmount = randomtimes();
      claim(sender, rAmount);
    }
  }

  function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    require(amount >= 0, "Transfer amount must be greater than zero");
    require(!_isBlock[sender], "amount is block");

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
    if (_totalSupply <= feeStopAt || stopFee) {
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

    if(tDao > 0) {
      _balances[_daoAddress] = _balances[_daoAddress].add(tDao);
      _daoFeeTotal = _daoFeeTotal.add(tDao);
      emit Transfer(sender, _daoAddress, tDao);
    }

    if(tTreasury > 0) {
      _balances[_treasuryAddress] = _balances[_treasuryAddress].add(tTreasury);
      _treasuryFeeTotal = _treasuryFeeTotal.add(tTreasury);
      emit Transfer(sender, _treasuryAddress, tTreasury);
    }

    if(tBurn > 0) {
      _totalSupply = _totalSupply.sub(tBurn);
      _burnFeeTotal = _burnFeeTotal.add(tBurn);
      emit Transfer(sender, _burnPool, tBurn);
    }

    emit Transfer(sender, recipient, tTransferAmount);        
  }

  function getReferralReward(address referralAddr) private view returns(uint256 retVal) {
    if(referralFirstReward == 0) retVal = 0;
    uint256 refCount = _referralQuantity[referralAddr];
    uint256 count = referralFirstReward.div(10);
    uint256 val = refCount >= (count + 1) ? 0 : referralFirstReward - ((refCount - 1) * 10);
    retVal = val > 0 ? getRealValue(val) : 0;
    if(retVal < getRealValue(10))
        retVal = getRealValue(10);
  }

  function getRealValue(uint256 amount) private view returns(uint256) {
    return amount.mul(10 ** uint256(_decimals));
  }

  function calculateBurnFee(uint256 _amount) private view returns (uint256) {
    return _amount.mul(burnFee).div(10**3);//0.1%
  }

  function calculateDaoFee(uint256 _amount) private view returns (uint256) {
    return _amount.mul(daoFee).div(10**3);//5.8%
  }

  function calculateTreasuryFee(uint256 _amount) private view returns (uint256) {
    return _amount.mul(treasuryFee).div(10**3);//0.1%
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
    if(amount == 0) return true;
    require(amount <= balanceOf(address(this)), "Insufficient of balance!");
    _transfer(address(this), recipient, amount);
    rNonce++;
    return true;
  }

  function randomtimes() private view returns(uint256) {       
    uint256 x = uint256(keccak256(abi.encode(block.number,block.timestamp,msg.sender,rNonce)));
    //uint256 y = (x.mod(5001) + 1000)* 10**uint256(_decimals); //1000-5000
    uint256 y = (x.mod(5001));//0-5000
    if(y < 1000) y += 1000;
    else if(y > 5000) y = 2345;
    y = getRealValue(y);
    if(y > balanceOf(address(this))) {
        y = balanceOf(address(this));
    }
    //claimReferral10HavedTotal += y;
    return y;
  }

  /*function randomrate() private view returns(uint256) {
    uint256 x = uint256(keccak256(abi.encode(block.number,block.timestamp,msg.sender,rNonce)));
    uint256 y = (x.mod(11));//0-10
    if(y <= 0) y += 1;
    else if(y > 10) y = 20;
    return y;
  }*/
  
  function receiveFees() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }
}