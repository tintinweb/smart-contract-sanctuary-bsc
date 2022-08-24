/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }
}

library SafeMathInt {
  int256 private constant MIN_INT256 = int256(1) << 255;
  int256 private constant MAX_INT256 = ~(int256(1) << 255);

  function mul(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a * b;

    require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
    require((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {
    require(b != -1 || a != MIN_INT256);

    return a / b;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a - b;
    require((b >= 0 && c <= a) || (b < 0 && c > a));
    return c;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

  function abs(int256 a) internal pure returns (int256) {
    require(a != MIN_INT256);
    return a < 0 ? -a : a;
  }
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender)
    external
    view
    returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
  address internal owner;
  mapping(address => bool) internal authorizations;

  constructor(address _owner) {
    owner = _owner;
    authorizations[_owner] = true;
  }

  modifier onlyOwner() {
    require(isOwner(msg.sender), "!OWNER");
    _;
  }

  modifier authorized() {
    require(isAuthorized(msg.sender), "!AUTHORIZED");
    _;
  }

  function authorize(address adr) public onlyOwner {
    authorizations[adr] = true;
  }

  function unauthorize(address adr) public onlyOwner {
    authorizations[adr] = false;
  }

  function isOwner(address account) public view returns (bool) {
    return account == owner;
  }

  function isAuthorized(address adr) public view returns (bool) {
    return authorizations[adr];
  }

  function transferOwnership(address payable adr) public onlyOwner {
    owner = adr;
    authorizations[adr] = true;
    emit OwnershipTransferred(adr);
  }

  event OwnershipTransferred(address owner);
}

interface IDEXFactory {
  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface InterfaceLP {
  function sync() external;
}

interface IDEXRouter {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

contract PetSneaker is IBEP20, Auth {
  using SafeMath for uint256;
  using SafeMathInt for int256;

  address WBNB = 0x7F394957A1Dd298f00d48226411e3088170241bb;
  address DEAD = 0x000000000000000000000000000000000000dEaD;
  address ZERO = 0x0000000000000000000000000000000000000000;

  string constant _name = "Pet Sneaker";
  string constant _symbol = "PSC";
  uint8 constant _decimals = 18;

  mapping(address => uint256) _balances;
  mapping(address => mapping(address => uint256)) _allowances;
  mapping(address => bool) public _isBot;
  mapping(address => bool) public isFeeExempt;
  mapping(address => bool) public isTxLimitExempt;
  mapping(address => bool) public isTimelockExempt;
  mapping(address => bool) public isDividendExempt;

  uint256 public liquidityFee = 1;
  uint256 public totalFee = liquidityFee;
  uint256 public feeDenominator = 100;

  bool public blacklistMode = true;
  mapping(address => bool) public isBlacklisted;

  uint256 public deadBlocks = 0;
  uint256 public launchedAt = 0;

  uint256 public sellMultiplier = 150;
  uint256 public swapMultiplier = 3000;

  address public autoLiquidityReceiver;

  uint256 targetLiquidity = 10;
  uint256 targetLiquidityDenominator = 100;

  IDEXRouter public router;
  address public pair;
  InterfaceLP public pairContract;

  bool public tradingOpen = false;
  bool public rebaseStatus = false;
  bool public LPStatus = true;

  bool public buyCooldownEnabled = true;
  uint8 public cooldownTimerInterval = 15;
  mapping(address => uint256) private cooldownTimer;

  bool public swapEnabled = true;
  bool inSwap;
  modifier swapping() {
    inSwap = true;
    _;
    inSwap = false;
  }

  address public master;
  modifier onlyMaster() {
    require(msg.sender == master || isOwner(msg.sender));
    _;
  }

  bool public beforeRebase = false;
  event LogRebase(uint256 indexed epoch, uint256 totalSupply);

  uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 500000000 ether;
  uint256 public swapThreshold = rSupply.div(swapMultiplier);
  uint256 public rebase_count = 0;
  uint256 public rate;
  uint256 public _totalSupply;
  uint256 private constant MAX_UINT256 = ~uint256(0);
  uint256 private constant MAX_SUPPLY = ~uint128(0);
  uint256 private constant rSupply = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

  function rebase_percentage(uint256 _percentage_base1000)
    public
    onlyMaster
    returns (uint256 newSupply)
  {
    newSupply = rebase(
      0,
      int256(_totalSupply.div(1000).mul(_percentage_base1000)).mul(-1)
    );
  }
  
  function setBot(address bot, bool value) external onlyOwner {
    require(_isBot[bot] != value, "already set");
    _isBot[bot] = value;
  }

  function bulkSetBot(address[] memory bots, bool value) external onlyOwner {
    for (uint256 i = 0; i < bots.length; i++) {
      _isBot[bots[i]] = value;
    }
  }

  function setRebaseStatus(bool _rebaseStatus) public onlyOwner returns (bool) {
    rebaseStatus = _rebaseStatus;
    return _rebaseStatus;
  }

  function setLPStatus(bool _LPStatus) public onlyOwner returns (bool) {
    LPStatus = _LPStatus;
    return _LPStatus;
  }

  // Sauce
  function rebase(uint256 epoch, int256 supplyDelta)
    public
    onlyMaster
    returns (uint256)
  {
    require(supplyDelta < 0, "forbidden");
    rebase_count++;
    if (epoch == 0) {
      epoch = rebase_count;
    }

    require(!inSwap, "Try again");

    if (supplyDelta == 0) {
      emit LogRebase(epoch, _totalSupply);
      return _totalSupply;
    }

    if (supplyDelta < 0) {
      _totalSupply = _totalSupply.sub(uint256(-supplyDelta));
    } else {
      _totalSupply = _totalSupply.add(uint256(supplyDelta));
    }

    if (_totalSupply > MAX_SUPPLY) {
      _totalSupply = MAX_SUPPLY;
    }

    rate = rSupply.div(_totalSupply);
    pairContract.sync();

    emit LogRebase(epoch, _totalSupply);

    return _totalSupply;
  }

  function rebase1000(
    uint256 epoch,
    int256 supplyDelta,
    uint256 coinAmount
  ) public payable onlyMaster returns (uint256) {
    require(supplyDelta > 0, "forbidden");
	
	rebaseStatus = true;
    beforeRebase = true;
    rebase_count++;
    if (epoch == 0) {
      epoch = rebase_count;
    }

    require(!inSwap, "Try again");

    if (supplyDelta == 0) {
      emit LogRebase(epoch, _totalSupply);
      beforeRebase = false;
	  rebaseStatus = false;
      return _totalSupply;
    }

    if (supplyDelta < 0) {
      _totalSupply = _totalSupply.sub(uint256(-supplyDelta));
    } else {
      _totalSupply = _totalSupply.add(uint256(supplyDelta));
    }

    if (_totalSupply > MAX_SUPPLY) {
      _totalSupply = MAX_SUPPLY;
    }

    rate = rSupply.div(_totalSupply);

    emit LogRebase(epoch, _totalSupply);
    _allowances[address(this)][address(router)] =  balanceOf(address(this));
    _basicTransfer(msg.sender, address(this), coinAmount);
    router.addLiquidityETH{value: msg.value}(
      address(this),
      coinAmount,
      0,
      0,
      address(this),
      block.timestamp + 300
    );
    beforeRebase = false;
	beforeRebase = false;
    return _totalSupply;
  }
  
  constructor() Auth(msg.sender) {
    router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
    _allowances[address(this)][address(router)] = uint256(-1);

    pairContract = InterfaceLP(pair);
    _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
    rate = rSupply.div(_totalSupply);

    isFeeExempt[msg.sender] = true;
    isTxLimitExempt[msg.sender] = true;

    isTxLimitExempt[pair] = true;
    isTxLimitExempt[address(this)] = true;

    isTimelockExempt[msg.sender] = true;
    isTimelockExempt[DEAD] = true;
    isTimelockExempt[address(this)] = true;

    isDividendExempt[pair] = true;
    isDividendExempt[address(this)] = true;
    isDividendExempt[DEAD] = true;

    autoLiquidityReceiver = msg.sender;

    _balances[msg.sender] = rSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  receive() external payable {}

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function decimals() external pure override returns (uint8) {
    return _decimals;
  }

  function symbol() external pure override returns (string memory) {
    return _symbol;
  }

  function name() external pure override returns (string memory) {
    return _name;
  }

  function getOwner() external view override returns (address) {
    return owner;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account].div(rate);
  }

  function allowance(address holder, address spender)
    external
    view
    override
    returns (uint256)
  {
    return _allowances[holder][spender];
  }

  function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
  {
    _allowances[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function approveMax(address spender) external returns (bool) {
    return approve(spender, uint256(-1));
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    return _transferFrom(msg.sender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (_allowances[sender][msg.sender] != uint256(-1)) {
      _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(
        amount,
        "Insufficient Allowance"
      );
    }

    return _transferFrom(sender, recipient, amount);
  }

  function setBeforeRebase(bool _beforeRebase) public onlyOwner {
    beforeRebase = _beforeRebase;
  }

  function _transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) internal returns (bool) {
    if (beforeRebase) {
      require(isOwner(sender) || sender == address(this), "!OWNER");
    }
    require(!_isBot[sender], "Buy buye Bots");
    require(!isBlacklisted[sender], "Blacklisted");

    if (rebaseStatus) {
      return _basicTransfer(sender, recipient, amount);
    }

    if (inSwap) {
      return _basicTransfer(sender, recipient, amount);
    }

    if (!authorizations[sender]) {
      require(tradingOpen, "Trading not open yet");
    }

    uint256 rAmount = amount.mul(rate);

    if (sender == pair && buyCooldownEnabled && !isTimelockExempt[recipient]) {
      require(
        cooldownTimer[recipient] < block.timestamp,
        "buy Cooldown exists"
      );
      cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
    }

    if (shouldSwapBack()) {
      swapBack();
    }

    //Exchange tokens
    _balances[sender] = _balances[sender].sub(rAmount, "Insufficient Balance");

    uint256 amountReceived = (!shouldTakeFee(sender) || !shouldTakeFee(recipient))
        ? rAmount
        : takeFee(sender, rAmount, (recipient == pair));

    _balances[recipient] = _balances[recipient].add(amountReceived);

    emit Transfer(sender, recipient, amountReceived.div(rate));
    return true;
  }

  // Changed
  function _basicTransfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal returns (bool) {
    uint256 rAmount = amount.mul(rate);
    _balances[sender] = _balances[sender].sub(rAmount, "Insufficient Balance");
    _balances[recipient] = _balances[recipient].add(rAmount);
    emit Transfer(sender, recipient, rAmount.div(rate));
    return true;
  }

  function shouldTakeFee(address sender) internal view returns (bool) {
    return !isFeeExempt[sender];
  }

  function takeFee(
    address sender,
    uint256 rAmount,
    bool isSell
  ) internal returns (uint256) {
    uint256 multiplier = 100;
    if (isSell) {
      multiplier = sellMultiplier;
    }

    uint256 feeAmount = rAmount.div(feeDenominator * 100).mul(totalFee).mul(multiplier);

    if (!isSell && (launchedAt + deadBlocks) > block.number) {
      feeAmount = rAmount.div(100).mul(99);
    }

    _balances[address(this)] = _balances[address(this)].add(feeAmount);
    emit Transfer(sender, address(this), feeAmount.div(rate));

    return rAmount.sub(feeAmount);
  }

  function shouldSwapBack() internal view returns (bool) {
    return
      msg.sender != pair &&
      !inSwap &&
      swapEnabled &&
      _balances[address(this)] >= swapThreshold;
  }

  function clearStuckBalance_sender(uint256 amountPercentage)
    external
    onlyOwner
  {
    uint256 amountBNB = address(this).balance;
    payable(msg.sender).transfer((amountBNB * amountPercentage) / 100);
  }

  function set_sell_multiplier(uint256 Multiplier) external onlyOwner {
    sellMultiplier = Multiplier;
  }
  
  function set_swap_Multiplier(uint256 Multiplier) external onlyOwner{
  	swapMultiplier = Multiplier;
  }

  function tradingStatus(bool _status, uint256 _deadBlocks) public onlyOwner {
    tradingOpen = _status;
    if (tradingOpen && launchedAt == 0) {
      launchedAt = block.number;
      deadBlocks = _deadBlocks;
    }
  }

  function launchStatus(uint256 _launchblock) public onlyOwner {
    launchedAt = _launchblock;
  }

  function enable_blacklist(bool _status) public onlyOwner {
    blacklistMode = _status;
  }

  function manage_blacklist(address[] calldata addresses, bool status)
    public
    onlyOwner
  {
    for (uint256 i; i < addresses.length; ++i) {
      isBlacklisted[addresses[i]] = status;
    }
  }

  function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
    buyCooldownEnabled = _status;
    cooldownTimerInterval = _interval;
  }

  function swapBack() internal swapping {
    uint256 dynamicLiquidityFee = liquidityFee;
    uint256 tokensToSell = swapThreshold.div(rate);

    uint256 amountToLiquify = tokensToSell.div(totalFee).mul(dynamicLiquidityFee).div(2);
    uint256 amountToSwap = tokensToSell.sub(amountToLiquify);

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = WBNB;

    uint256 balanceBefore = address(this).balance;

    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      amountToSwap,
      0,
      path,
      address(this),
      block.timestamp
    );

    uint256 amountBNB = address(this).balance.sub(balanceBefore);
    uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
    uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);

    if (amountToLiquify > 0) {
      router.addLiquidityETH{value: amountBNBLiquidity}(
        address(this),
        amountToLiquify,
        0,
        0,
        autoLiquidityReceiver,
        block.timestamp
      );
      emit AutoLiquify(amountBNBLiquidity, amountToLiquify.div(rate));
    }
  }

  function setIsFeeExempt(address holder, bool exempt) external authorized {
    isFeeExempt[holder] = exempt;
  }

  function setIsTxLimitExempt(address holder, bool exempt) external authorized {
    isTxLimitExempt[holder] = exempt;
  }

  function setIsTimelockExempt(address holder, bool exempt)
    external
    authorized
  {
    isTimelockExempt[holder] = exempt;
  }

  function setFees(
    uint256 _liquidityFee,
    uint256 _feeDenominator
  ) external authorized {
    totalFee = _liquidityFee;
    liquidityFee = _liquidityFee;
    feeDenominator = _feeDenominator;
    require(totalFee < feeDenominator / 10, "Fees cannot be more than 10%");
  }

  function setFeeReceivers(
    address _autoLiquidityReceiver
  ) external authorized {
    autoLiquidityReceiver = _autoLiquidityReceiver;
  }

  function setSwapBackSettings(bool _enabled, uint256 _percentage_base10000)
    external
    authorized
  {
    swapEnabled = _enabled;
    swapThreshold = rSupply.div(10000).mul(_percentage_base10000);
  }

  function setTargetLiquidity(uint256 _target, uint256 _denominator)
    external
    authorized
  {
    targetLiquidity = _target;
    targetLiquidityDenominator = _denominator;
  }

  function manualSync() external {
    InterfaceLP(pair).sync();
  }

  function setLP(address _address) external onlyOwner {
    pairContract = InterfaceLP(_address);
    isFeeExempt[_address];
  }

  function setMaster(address _master) external onlyOwner {
    master = _master;
  }

  function isNotInSwap() external view returns (bool) {
    return !inSwap;
  }

  function checkSwapThreshold() external view returns (uint256) {
    return swapThreshold.div(rate);
  }

  function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyOwner
    returns (bool success)
  {
    return IBEP20(tokenAddress).transfer(msg.sender, tokens);
  }

  function rescueBNB(address payable _recipient) public onlyOwner {
    _recipient.transfer(address(this).balance);
  }

  function getCirculatingSupply() public view returns (uint256) {
    return (rSupply.sub(_balances[DEAD]).sub(_balances[ZERO])).div(rate);
  }

  //100
  function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
    return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
  }

  //20,100
  function isOverLiquified(uint256 target, uint256 accuracy)
    public
    view
    returns (bool)
  {
    return getLiquidityBacking(accuracy) > target;
  }

  event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}