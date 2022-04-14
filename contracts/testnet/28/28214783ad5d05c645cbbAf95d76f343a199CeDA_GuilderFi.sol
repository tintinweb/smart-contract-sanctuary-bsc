// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./IDexPair.sol";
import "./IDexRouter.sol";
import "./IDexFactory.sol";
import "./IGuilderFi.sol";

contract GuilderFi is IGuilderFi, IERC20, Ownable {

  using SafeMath for uint256;

  // TOKEN SETTINGS
  string private _name = "GuilderFi";
  string private _symbol = "NPLUS1";
  uint8 private constant DECIMALS = 18;

  // CONSTANTS
  uint256 private constant MAX_UINT256 = ~uint256(0);
  address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
  address private constant ZERO = 0x0000000000000000000000000000000000000000;

  // SUPPLY CONSTANTS
  uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 100 * 10**6 * 10**DECIMALS; // 100 million
  uint256 private constant MAX_SUPPLY = 82 * 10**21 * 10**DECIMALS;
  uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

  // REBASE SETTINGS
  uint256 private constant YEAR1_REBASE_RATE = 1600; // 0.01600 %
  uint256 private constant YEAR2_REBASE_RATE = 1440; // 0.01440 %
  uint256 private constant YEAR3_REBASE_RATE = 1280; // 0.01280 %
  uint256 private constant YEAR4_REBASE_RATE = 1130; // 0.01130 %
  uint256 private constant YEAR5_REBASE_RATE = 970; // 0.00970 %
  uint256 private constant YEAR6_REBASE_RATE = 286; // 0.00286 %
  uint8   private constant REBASE_RATE_DECIMALS = 7;
  uint256 private constant REBASE_FREQUENCY = 12 minutes;
  
  // REBASE VARIABLES
  uint256 public override maxRebaseBatchSize = 40; // 8 hours
  uint256 public override pendingRebases = 0;
  
  // ADDRESSES
  address public _treasuryAddress = 0x46Af38553B5250f2560c3fc650bbAD0950c011c0; 
  address public _lrfAddress = 0xea7231dC1ed7778D5601B1F4dDe1120E8eE38F66;
  address public _autoLiquidityAddress = 0x0874813dEF7e61A003A6d3b114c4474001eD6F0A;
  address public _safeExitFundAddress = 0x67Efb7f2Dd5F6dD55c38C55de898d9f7EE111880;
  address public _burnAddress = DEAD;
  
  // DEX ADDRESSES
  // address private constant DEX_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PancakeSwap BSC Mainnet
  address private constant DEX_ROUTER_ADDRESS = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // PancakeSwap BSC Testnet

  // FEES
  uint256 private constant MAX_BUY_FEES = 200; // 20%
  uint256 private constant MAX_SELL_FEES = 240; // 24%
  uint256 private constant FEE_DENOMINATOR = 1000;
  
  // Buy fees = 3% treasury, 5% LRF, 5% auto liquidity, 0% burn
  Fee private _buyFees = Fee(30, 50, 50, 0, 130);
  
  // Sell fees = 7% treasury, 5% LRF, 5% auto liquidity, 0% burn
  Fee private _sellFees = Fee(70, 50, 50, 0, 170);

  // FEES COLLECTED
  uint256 private _treasuryFeesCollected;
  uint256 private _lrfFeesCollected;

  // SETTING FLAGS
  bool public override swapEnabled = true;
  bool public override autoRebaseEnabled = true;
  bool public override autoAddLiquidityEnabled = true;

  // PRIVATE FLAGS
  bool private _inSwap = false;

  // EXCHANGE VARIABLES
  IDexRouter private _router;
  IDexPair private _pair;
  
  // DATE/TIME STAMPS
  uint256 public override initRebaseStartTime;
  uint256 public override lastRebaseTime;
  uint256 public override lastAddLiquidityTime;
  uint256 public override lastEpoch;

  // TOKEN SUPPLY VARIABLES
  uint256 private _totalSupply;
  uint256 private _gonsPerFragment;

  // DATA
  mapping(address => bool) private _isFeeExempt;
  mapping(address => uint256) private _gonBalances;
  mapping(address => mapping(address => uint256)) private _allowedFragments;
  mapping(address => bool) public blacklist;

  // PRE-SALE FLAG
  bool public isOpen = false;
  mapping(address => bool) private _allowPreSaleTransfer;

  // MODIFIERS
  modifier isOpenForTrade() {
    require(isOpen || msg.sender == owner() || _allowPreSaleTransfer[msg.sender], "Trading not open yet");
    _;
  }  

  modifier swapping() {
    _inSwap = true;
    _;
    _inSwap = false;
  }

  modifier validRecipient(address to) {
    require(to != address(0x0), "Cannot send to zero address");
    _;
  }

  constructor() Ownable() {

    // set up DEX _router/_pair
    _router = IDexRouter(DEX_ROUTER_ADDRESS); 
    address pairAddress = IDexFactory(_router.factory()).createPair(_router.WETH(), address(this));
    _pair = IDexPair(address(pairAddress));

    // set exchange _router allowance
    _allowedFragments[address(this)][address(_router)] = type(uint256).max;
  
    // initialise total supply
    _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
    _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
    
    // exempt fees from contract + treasury
    _isFeeExempt[_treasuryAddress] = true;
    _isFeeExempt[address(this)] = true;

    // transfer ownership + total supply to treasury
    _gonBalances[_treasuryAddress] = TOTAL_GONS;
    _transferOwnership(_treasuryAddress);

    emit Transfer(address(0x0), _treasuryAddress, _totalSupply);
  }

  /*
   * REBASE FUNCTIONS
   */ 
  function rebase() public override {
    
    if (_inSwap || !isOpen) {
      return;
    }

    uint256 rebaseRate = getRebaseRate();
    
    // work out how many rebases to perform
    uint256 deltaTime = block.timestamp - lastRebaseTime;
    uint256 times = deltaTime.div(REBASE_FREQUENCY);

    if (times == 0) {
      return;
    } 
    
    // TODO: CHECK PENDING REBASES
    // if there are too many rebases, execute a maximum batch size
    if (times > maxRebaseBatchSize) {
      pendingRebases = pendingRebases.add(times).sub(maxRebaseBatchSize);
      times = maxRebaseBatchSize;
    } else {
      pendingRebases = 0;
    }

    lastEpoch = lastEpoch.add(times);

    // increase total supply by rebase rate
    for (uint256 i = 0; i < times; i++) {
      _totalSupply = _totalSupply
        .mul((10**REBASE_RATE_DECIMALS).add(rebaseRate))
        .div(10**REBASE_RATE_DECIMALS);
    }

    _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
    lastRebaseTime = lastRebaseTime.add(times.mul(REBASE_FREQUENCY));

    _pair.sync();

    emit LogRebase(lastEpoch, _totalSupply);
  }

  function getRebaseRate() public view override returns (uint256) {

    // calculate rebase rate depending on time passed since token launch
    uint256 deltaTimeFromInit = block.timestamp - initRebaseStartTime;

    if (deltaTimeFromInit < (365 days)) {
      return YEAR1_REBASE_RATE;
    } else if (deltaTimeFromInit >= (365 days) && deltaTimeFromInit < (2 * 365 days)) {
      return YEAR2_REBASE_RATE;
    } else if (deltaTimeFromInit >= (2 * 365 days) && deltaTimeFromInit < (3 * 365 days)) {
      return YEAR3_REBASE_RATE;
    } else if (deltaTimeFromInit >= (3 * 365 days) && deltaTimeFromInit < (4 * 365 days)) {
      return YEAR4_REBASE_RATE;
    } else if (deltaTimeFromInit >= (4 * 365 days) && deltaTimeFromInit < (5 * 365 days)) {
      return YEAR5_REBASE_RATE;
    } else {
      return YEAR6_REBASE_RATE;
    }
  }

  function transfer(address to, uint256 value) external
    override(IGuilderFi, IERC20)
    validRecipient(to)
    returns (bool) {
    
    _transferFrom(msg.sender, to, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) external
    override(IGuilderFi, IERC20)
    validRecipient(to)
    returns (bool) {

    if (_allowedFragments[from][msg.sender] != type(uint256).max) {
      _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value, "Insufficient allowance");
    }

    _transferFrom(from, to, value);
    return true;
  }

  function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
    uint256 gonAmount = amount.mul(_gonsPerFragment);
    _gonBalances[from] = _gonBalances[from].sub(gonAmount);
    _gonBalances[to] = _gonBalances[to].add(gonAmount);
    return true;
  }

  function _transferFrom(address sender, address recipient, uint256 amount) internal isOpenForTrade returns (bool) {

    require(!blacklist[sender] && !blacklist[recipient], "Address blacklisted");

    if (_inSwap) {
      return _basicTransfer(sender, recipient, amount);
    }

    if (shouldRebase()) {
       rebase();
    }

    if (shouldAddLiquidity()) {
      addLiquidity();
    }

    if (shouldSwapBack()) {
      swapBack();
    }

    uint256 gonAmount = amount.mul(_gonsPerFragment);
    uint256 gonAmountReceived = gonAmount;
    
    if (shouldTakeFee(sender, recipient)) {
      gonAmountReceived = takeFee(sender, recipient, gonAmount);
    }

    _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
    _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);

    emit Transfer(
      sender,
      recipient,
      gonAmountReceived.div(_gonsPerFragment)
    );
    return true;
  }

  function takeFee(address sender, address recipient, uint256 gonAmount) internal returns (uint256) {

    Fee storage fees = (recipient == address(_pair)) ? _sellFees : _buyFees;

    uint256 burnAmount = gonAmount.div(FEE_DENOMINATOR).mul(fees.burnFee);
    uint256 treasuryAmount = gonAmount.div(FEE_DENOMINATOR).mul(fees.treasuryFee);
    uint256 lrfAmount = gonAmount.div(FEE_DENOMINATOR).mul(fees.lrfFee);
    uint256 liquidityAmount = gonAmount.div(FEE_DENOMINATOR).mul(fees.liquidityFee);
    uint256 totalFeeAmount = burnAmount + treasuryAmount + lrfAmount + liquidityAmount;
     
    // burn 
    _gonBalances[_burnAddress] = _gonBalances[_burnAddress].add(burnAmount);

    // add treasury fees to smart contract
    _gonBalances[address(this)] = _gonBalances[address(this)].add(treasuryAmount);
    _treasuryFeesCollected = _treasuryFeesCollected.add(treasuryAmount);
    
    // add lrf fees to smart contract
    _gonBalances[address(this)] = _gonBalances[address(this)].add(lrfAmount);
    _lrfFeesCollected = _lrfFeesCollected.add(lrfAmount);

    // add liquidity fees to liquidity address
    _gonBalances[_autoLiquidityAddress] = _gonBalances[_autoLiquidityAddress].add(liquidityAmount);
    
    emit Transfer(sender, address(this), totalFeeAmount.div(_gonsPerFragment));
    return gonAmount.sub(totalFeeAmount);
  }

  function addLiquidity() internal swapping {
    // transfer all tokens from liquidity account to contract
    uint256 autoLiquidityAmount = _gonBalances[_autoLiquidityAddress].div(_gonsPerFragment);
    _gonBalances[address(this)] = _gonBalances[address(this)].add(_gonBalances[_autoLiquidityAddress]);
    _gonBalances[_autoLiquidityAddress] = 0;

    // calculate 50/50 split
    uint256 amountToLiquify = autoLiquidityAmount.div(2);
    uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

    if( amountToSwap == 0 ) {
      return;
    }

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = _router.WETH();

    uint256 balanceBefore = address(this).balance;

    // swap tokens for ETH
    _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      amountToSwap,
      0,
      path,
      address(this),
      block.timestamp
    );

    uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

    // add tokens + ETH to liquidity pool
    if (amountToLiquify > 0&&amountETHLiquidity > 0) {
      _router.addLiquidityETH{value: amountETHLiquidity}(
        address(this),
        amountToLiquify,
        0,
        0,
        _autoLiquidityAddress,
        block.timestamp
      );
    }

    lastAddLiquidityTime = block.timestamp;
  }

  function swapBack() internal swapping {

    uint256 totalGonFeesCollected = _treasuryFeesCollected.add(_lrfFeesCollected);
    uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);

    _gonBalances[address(this)] = 0;

    if (amountToSwap == 0) {
      return;
    }

    uint256 balanceBefore = address(this).balance;

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = _router.WETH();

    // swap all tokens in contract for ETH
    _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      amountToSwap,
      0,
      path,
      address(this),
      block.timestamp
    );

    uint256 amountETH = address(this).balance.sub(balanceBefore);
    uint256 treasuryETH = amountETH.mul(_treasuryFeesCollected).div(totalGonFeesCollected);
    uint256 lrfETH = amountETH.sub(treasuryETH);

    _treasuryFeesCollected = 0;
    _lrfFeesCollected = 0;
    
    // send eth to treasury
    (bool success, ) = payable(_treasuryAddress).call{ value: treasuryETH }("");

    // send eth to lrf
    (success, ) = payable(_lrfAddress).call{ value: lrfETH }("");
  }

  /*
   * INTERNAL CHECKER FUNCTIONS
   */ 
  function shouldTakeFee(address from, address to) internal view returns (bool) {
    return 
      (address(_pair) == from || address(_pair) == to) &&
      !_isFeeExempt[from];
  }

  function shouldRebase() internal view returns (bool) {
    return
      autoRebaseEnabled &&
      isOpen &&
      (_totalSupply < MAX_SUPPLY) &&
      msg.sender != address(_pair)  &&
      !_inSwap &&
      block.timestamp >= (lastRebaseTime + REBASE_FREQUENCY);
  }

  function shouldAddLiquidity() internal view returns (bool) {
    return
      autoAddLiquidityEnabled && 
      !_inSwap && 
      msg.sender != address(_pair) &&
      block.timestamp >= (lastAddLiquidityTime + 2 days);
  }

  function shouldSwapBack() internal view returns (bool) {
    return 
      !_inSwap &&
      swapEnabled &&
      msg.sender != address(_pair); 
  }

  /*
   * TOKEN ALLOWANCE/APPROVALS
   */ 
  function allowance(address owner_, address spender) public view override(IGuilderFi, IERC20) returns (uint256) {
    return _allowedFragments[owner_][spender];
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) external override returns (bool) {
    uint256 oldValue = _allowedFragments[msg.sender][spender];
    
    if (subtractedValue >= oldValue) {
      _allowedFragments[msg.sender][spender] = 0;
    } else {
      _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
    }

    emit Approval(
      msg.sender,
      spender,
      _allowedFragments[msg.sender][spender]
    );

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) external override returns (bool) {
    _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender].add(addedValue);
    
    emit Approval(
      msg.sender,
      spender,
      _allowedFragments[msg.sender][spender]
    );

    return true;
  }

  function approve(address spender, uint256 value) external override(IGuilderFi, IERC20) returns (bool) {
    _allowedFragments[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function manualSync() override external {
    IDexPair(address(_pair)).sync();
  }

  /*
   * PUBLIC SETTER FUNCTIONS
   */ 
  function setAutoSwap(bool _flag) external override onlyOwner {
    swapEnabled = _flag;
  }

  function setAutoAddLiquidity(bool _flag) external override onlyOwner {
    autoAddLiquidityEnabled = _flag;
    if(_flag) {
      lastAddLiquidityTime = block.timestamp;
    }
  }

  function setAutoRebase(bool _flag) override external onlyOwner {
    autoRebaseEnabled = _flag;
    if (_flag) {
      lastRebaseTime = block.timestamp;
    }
  }

  function setFeeExempt(address _address, bool _flag) external override onlyOwner {
    _isFeeExempt[_address] = _flag;
  }

  function setBlacklist(address _address, bool _flag) external override onlyOwner {
    blacklist[_address] = _flag;  
  }

  function allowPreSaleTransfer(address _addr, bool _flag) external override onlyOwner {
    _allowPreSaleTransfer[_addr] = _flag;
  }

  function setMaxRebaseBatchSize(uint256 _maxRebaseBatchSize) external override onlyOwner {
    maxRebaseBatchSize = _maxRebaseBatchSize;
  }

  function setDex(address routerAddress) external override onlyOwner {
    _router = IDexRouter(routerAddress); 
    address pairAddress = IDexFactory(_router.factory()).createPair(_router.WETH(), address(this));
    _pair = IDexPair(address(pairAddress));
  }

  function setAddresses(
    address treasuryAddress,
    address lrfAddress,
    address autoLiquidityAddress,
    address burnAddress
  ) external override onlyOwner {
    _treasuryAddress = treasuryAddress;
    _lrfAddress = lrfAddress;
    _autoLiquidityAddress = autoLiquidityAddress;
    _burnAddress = burnAddress;
  }

  function setFees(
    bool _isSellFee,
    uint256 _treasuryFee,
    uint256 _lrfFee,
    uint256 _liquidityFee,
    uint256 _burnFee
  ) external override onlyOwner {

    uint256 feeTotal = _treasuryFee
      .add(_lrfFee)
      .add(_liquidityFee)
      .add(_burnFee);

    Fee memory fee = Fee(_treasuryFee, _lrfFee, _liquidityFee, _burnFee, feeTotal);
    
    if (_isSellFee) {
      require(feeTotal <= MAX_SELL_FEES, "Sell fees are too high");
      _sellFees = fee;
    }
    
    if (!_isSellFee) {
      require(feeTotal <= MAX_BUY_FEES, "Buy fees are too high");
      _buyFees = fee;
    }
  }  

  function openTrade() external override onlyOwner {
    isOpen = true;
    
    // record rebase timestamps
    lastAddLiquidityTime = block.timestamp;
    initRebaseStartTime = block.timestamp;
    lastRebaseTime = block.timestamp;
    lastEpoch = 0;
  }
  
  /*
   * EXTERNAL GETTER FUNCTIONS
   */ 
  function getCirculatingSupply() public view override returns (uint256) {
    return (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(_gonsPerFragment);
  }
  function checkFeeExempt(address _addr) public view override returns (bool) {
    return _isFeeExempt[_addr];
  }
  function isNotInSwap() public view override returns (bool) {
    return !_inSwap;
  }
  function getTreasuryAddress() public view override returns (address) {
    return _treasuryAddress;
  }
  function getLrfAddress() public view override returns (address) {
    return _lrfAddress;
  }
  function getAutoLiquidityAddress() public view override returns (address) {
    return _autoLiquidityAddress;
  }
  function getBurnAddress() public view override returns (address) {
    return _burnAddress;
  }
  function getRouter() public view override returns (address) {
    return address(_router);
  }
  function getPair() public view override returns (address) {
    return address(_pair);
  }
  
  /*
   * STANDARD ERC20 FUNCTIONS
   */ 
  function totalSupply() external view override(IGuilderFi, IERC20) returns (uint256) {
    return _totalSupply;
  }
   
  function balanceOf(address who) external view override(IGuilderFi, IERC20) returns (uint256) {
    return _gonBalances[who].div(_gonsPerFragment);
  }

  function name() public view override returns (string memory) {
    return _name;
  }

  function symbol() public view override returns (string memory) {
    return _symbol;
  }

  function decimals() public pure override returns (uint8) {
    return DECIMALS;
  }

  receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IDexPair {
  event Approval(address indexed owner, address indexed spender, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
  
  function name() external pure returns (string memory);
  
  function symbol() external pure returns (string memory);
  function decimals() external pure returns (uint8);
  function totalSupply() external view returns (uint);
  function balanceOf(address owner) external view returns (uint);
  function allowance(address owner, address spender) external view returns (uint);

  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);
  function PERMIT_TYPEHASH() external pure returns (bytes32);
  function nonces(address owner) external view returns (uint);

  function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

  event Mint(address indexed sender, uint amount0, uint amount1);
  event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
  
  event Swap(
    address indexed sender,
    uint amount0In,
    uint amount1In,
    uint amount0Out,
    uint amount1Out,
    address indexed to
  );

  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint);
  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function price0CumulativeLast() external view returns (uint);
  function price1CumulativeLast() external view returns (uint);
  function kLast() external view returns (uint);

  function mint(address to) external returns (uint liquidity);
  function burn(address to) external returns (uint amount0, uint amount1);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
  function skim(address to) external;
  function sync() external;

  function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IDexRouter {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB, uint liquidity);

  function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB);

  function removeLiquidityETH(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external returns (uint amountToken, uint amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountA, uint amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountToken, uint amountETH);

  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapTokensForExactTokens(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

  function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

  function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

  function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

  function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
  function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
  function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
  function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external returns (uint amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IDexFactory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;
  function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IGuilderFi {
  
  // Events
  event LogRebase(uint256 indexed epoch, uint256 totalSupply);

  // Fee struct
  struct Fee {
    uint256 treasuryFee;
    uint256 lrfFee;
    uint256 liquidityFee;
    uint256 burnFee;
    uint256 totalFee;
  }

  // Rebase functions
  function rebase() external;
  function getRebaseRate() external view returns (uint256);

  // Transfer
  function transfer(address to, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  // Allowance
  function allowance(address owner_, address spender) external view returns (uint256);
  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
  function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);

  // Smart Contract Settings
  function openTrade() external;
  function setAutoSwap(bool _flag) external;
  function setAutoAddLiquidity(bool _flag) external;
  function setAutoRebase(bool _flag) external;
  function setMaxRebaseBatchSize(uint256 _maxRebaseBatchSize) external;
  function setDex(address routerAddress) external;
  function setAddresses(
    address _autoLiquidityAddress,
    address _treasuryAddress,
    address _lrfAddress,
    address _burnAddress
  ) external;
  function setFees(
    bool _isSellFee,
    uint256 _treasuryFee,
    uint256 _lrfFee,
    uint256 _liquidityFee,
    uint256 _burnFee
  ) external;

  // Address settings
  function setFeeExempt(address _address, bool _flag) external;
  function setBlacklist(address _address, bool _flag) external;
  function allowPreSaleTransfer(address _addr, bool _flag) external;

  // Read only functions
  function getCirculatingSupply() external view returns (uint256);
  function checkFeeExempt(address _addr) external view returns (bool);
  function isNotInSwap() external view returns (bool);

  // Rebase variables
  function maxRebaseBatchSize() external view returns (uint256);
  function pendingRebases() external view returns (uint256);
  
  // Addresses
  function getTreasuryAddress() external view returns (address);
  function getLrfAddress() external view returns (address);
  function getAutoLiquidityAddress() external view returns (address);
  function getBurnAddress() external view returns (address);

  // Setting flags
  function swapEnabled() external view returns (bool);
  function autoRebaseEnabled() external view returns (bool);
  function autoAddLiquidityEnabled() external view returns (bool);

  // Date/time stamps
  function initRebaseStartTime() external view returns (uint256);
  function lastRebaseTime() external view returns (uint256);
  function lastAddLiquidityTime() external view returns (uint256);
  function lastEpoch() external view returns (uint256);

  // Dex addresses
  function getRouter() external view returns (address);
  function getPair() external view returns (address);

  // Standard ERC20 functions
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external pure returns (uint8);
  
  function manualSync() external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}