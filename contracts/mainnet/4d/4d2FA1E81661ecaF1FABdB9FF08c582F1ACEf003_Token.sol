// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./Pausable.sol";

import "./IDEXRouter.sol";
import "./IDEXFactory.sol";
import "./IDEXPair.sol";
import "./IPriceOracle.sol";

/**
 * @title EQUO ERC20 token
 * @dev This is part of an implementation of the EQUO token.
 *      EQUO is a normal ERC20 token, but its supply can be adjusted by splitting and
 *      combining tokens proportionally across all wallets.
 *
 *      Stash balances are privately represented with a hidden denomination, 'gons'.
 *      We support splitting the currency in expansion and combining the currency on contraction by
 *      changing the exchange rate between the hidden 'gons' and the public 'fragments'.
 */
contract Token is IERC20, Ownable, Pausable {
  using SafeMath for uint256;

  string private constant _name = "EQUO";
  string private constant _symbol = "EQUO";
  uint8 private constant _decimals = 18;

  enum RebaseType {
    POSITIVE,
    NEGATIVE
  }

  enum TransactionType {
    BUY,
    SELL,
    TRANSFER
  }

  uint256 private constant ONE_UNIT = 10**_decimals;
  uint256 private constant INITIAL_FRAGMENTS_SUPPLY = (10**9 + 5 * 10**8) * ONE_UNIT; // 1.5 billion
  uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

  uint256 public constant MAX_UINT256 = ~uint256(0);
  address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
  address public constant ZERO = 0x0000000000000000000000000000000000000000;

  uint256 public constant MAX_DAILY_SELL_LIMIT_FACTOR = 100;
  uint256 public constant MIN_DAILY_SELL_LIMIT_FACTOR = 10;

  uint256 private _totalSupply;
  uint256 private _gonsPerFragment;
  bool private _inSwap = false;
  uint256 private DEFAULT_GONSWAP_THRESHOLD = TOTAL_GONS / 1000;
  uint256 private _minFeeAmountToCollect = DEFAULT_GONSWAP_THRESHOLD;
  uint256 private _minAmountToAddLiquidity = DEFAULT_GONSWAP_THRESHOLD;

  mapping(address => bool) public automatedMarketMakerPairs;
  mapping(address => uint256) private _gonBalances;
  mapping(address => mapping(address => uint256)) private _allowedFragments;
  mapping(address => bool) private _noCheckDailySellLimit;
  address[] public _makerPairs;

  uint256 public positiveRebaseRate = 2073;
  uint256 public positiveRebaseRateDenominator = 10**7;
  uint256 public negativeRebaseRate = 51;
  uint256 public negativeRebaseRateDenominator = 10**3;

  uint256 public negativeFromAthPercent = 5;
  uint256 public negativeFromAthPercentDenominator = 100;

  uint256 public lastRebasedTime;

  // Transaction fees
  uint256 public buyFee = 13;
  uint256 public sellFee = 17;
  uint256 public transferFee = 35;
  uint256 public feeDenominator = 100;

  // Coefficients for the daily sell limit liner equation
  uint256 public coefficientA = 10;
  uint256 public coefficientB = 110;
  uint256 public maxHoldingPercentSellLimitApplied = 9;

  // Fee split
  uint256 public autoLiquidityFeePercent = 50;
  uint256 public treasuryFeePercent = 30;
  uint256 public burnFeePercent = 20;

  // Sell limit
  uint256 public sellLimitDenominator = 10000;

  // 3rd party contracts
  address public BUSD;
  IDEXRouter public router;
  IPriceOracle public priceOracle;

  address public pair;
  // all time high price
  uint256 public athPrice;
  uint256 public lastNegativeRebaseTriggerAthPrice;
  uint256 public rebaseFrequency = 30 minutes;

  address public autoLiquidityReceiver;
  address public treasury;

  bool public autoRebase;
  bool public autoCollectFees;
  bool public autoAddLiquidity;
  bool public dailySellLimitEnabled;
  bool public priceOracleEnabled;
  bool public transferFeeEnabled;
  mapping(address => bool) public blocklist;
  mapping(address => bool) public isFeeExempt;
  mapping(address => SaleHistory) public saleHistories;

  // SaleHistory tracking how many tokens that a user has sold within a span of 24hs
  struct SaleHistory {
    uint256 lastDailySellLimitAmount;
    uint256 lastSoldTimestamp;
    uint256 totalSoldAmountLast24h;
  }

  event LogRebase(uint256 indexed epoch, RebaseType rebaseType, uint256 lastTotalSupply, uint256 currentTotalSupply);
  event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

  modifier swapping() {
    _inSwap = true;
    _;
    _inSwap = false;
  }

  modifier validRecipient(address to) {
    require(to != address(0x0));
    _;
  }

  constructor(
    address _dexRouter,
    address _busd,
    address _autoLiquidityReceiver,
    address _treasury,
    address _priceOracle
  ) {
    router = IDEXRouter(_dexRouter);
    BUSD = _busd;
    pair = IDEXFactory(router.factory()).createPair(_busd, address(this));
    priceOracle = IPriceOracle(_priceOracle);

    autoLiquidityReceiver = _autoLiquidityReceiver;
    treasury = _treasury;

    setAutomatedMarketMakerPair(pair, true);

    _allowedFragments[address(this)][address(router)] = MAX_UINT256;

    _totalSupply = INITIAL_FRAGMENTS_SUPPLY;

    address deployer = msg.sender;
    _gonBalances[deployer] = TOTAL_GONS;
    _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

    isFeeExempt[deployer] = true;

    lastRebasedTime = block.timestamp;

    autoRebase = true;
    autoCollectFees = true;
    autoAddLiquidity = true;

    emit Transfer(address(0x0), deployer, _totalSupply);
  }

  receive() external payable {}

  function transfer(address to, uint256 value) external override validRecipient(to) whenNotPaused returns (bool) {
    _transferFrom(msg.sender, to, value);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external override validRecipient(to) whenNotPaused returns (bool) {
    uint256 currentAllowance = allowance(from, msg.sender);
    if (currentAllowance != MAX_UINT256) {
      _allowedFragments[from][msg.sender] = currentAllowance.sub(value, "ERC20: insufficient allowance");
    }
    _transferFrom(from, to, value);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
    uint256 oldValue = _allowedFragments[msg.sender][spender];
    if (subtractedValue >= oldValue) {
      _allowedFragments[msg.sender][spender] = 0;
    } else {
      _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
    }
    emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
    _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender].add(addedValue);
    emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
    return true;
  }

  function approve(address spender, uint256 value) external override whenNotPaused returns (bool) {
    _allowedFragments[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Manual trigger rebase to increase or reduce the total supply of the token
   */
  function rebase() external {
    require(_shouldRebase(), "SHOULD_NOT_REBASE");
    // calculate time weighted price for 1 EQUO token
    uint256 twap = priceOracle.consult(address(this), ONE_UNIT, BUSD);
    _rebase(twap);
  }

  /* ========== FUNCTIONS FOR OWNER ========== */

  /**
   * @dev Set the address for the price Oracle
   * @param _priceOracle Provide the priceOracle address
   */
  function setPriceOracle(IPriceOracle _priceOracle) external onlyOwner {
    priceOracle = _priceOracle;
  }

  /**
   * @dev Toggle price oracle
   * @param flag provide the boolean value
   */
  function setPriceOracleEnabled(bool flag) external onlyOwner {
    priceOracleEnabled = flag;

    if (flag) {
      priceOracle.update(address(this), BUSD);
    }
  }

  /**
   * @dev Set rebase frequency in seconds
   * @param valueInSeconds Provide duration in seconds
   */
  function setRebaseFrequency(uint256 valueInSeconds) external onlyOwner {
    rebaseFrequency = valueInSeconds;
  }

  /**
   * @dev Set auto rebase to trigger automatic rebasing on a transfer when rebase frequency duration has passed
   * @param flag provide the boolean value
   */
  function setAutoRebase(bool flag) external onlyOwner {
    if (flag) {
      lastRebasedTime = block.timestamp;
    }

    autoRebase = flag;
  }

  /**
   * @dev Switch on/off checking daily sell limit feature
   * @param flag provide the boolean value
   */
  function setDailySellLimitEnabled(bool flag) external onlyOwner {
    dailySellLimitEnabled = flag;
  }

  /**
   * @dev Exclude an address from daily sell limit restriction
   * @param _address Provide the address to be excluded
   * @param flag provide the boolean value
   */
  function setNoCheckDailySellLimit(address _address, bool flag) external onlyOwner {
    _noCheckDailySellLimit[_address] = flag;
  }

  /**
   * @dev Switch on/off taking transfer fee feature
   * @param flag provide the boolean value
   */
  function setTransferFeeEnabled(bool flag) external onlyOwner {
    transferFeeEnabled = flag;
  }

  /**
   * @dev Set auto liquidity to trigger automatic liquidity on a transfer when balance of liquidityReceiver has gone above threshold
   * @param flag provide the boolean value
   */
  function setAutoAddLiquidity(bool flag) external onlyOwner {
    autoAddLiquidity = flag;
  }

  /**
   * @dev Set auto liquidity to trigger collecting available fees and send to the treasury
   * @param flag provide the boolean value
   */
  function setAutoCollectFees(bool flag) external onlyOwner {
    autoCollectFees = flag;
  }

  /**
   * @dev Set threshold amount to trigger adding liquidity when balance of liquidityReceiver goes above this threshold
   * @param amount provide the threshold amount
   */
  function setMinAmountToAddLiquidity(uint256 amount) external onlyOwner {
    _minAmountToAddLiquidity = amount.mul(_gonsPerFragment);
  }

  /**
   * @dev Set threshold amount to trigger collecting fees when balance of the contract goes above this threshold
   * @param amount provide the threshold amount
   */
  function setMinFeeAmountToCollect(uint256 amount) external onlyOwner {
    _minFeeAmountToCollect = amount.mul(_gonsPerFragment);
  }

  /**
   * @dev daily sell limit amount follow a linear equation y = ax + b
   * Set the coefficients for the linear equation
   *
   * @param _coefficientA `a` value of the equation
   * @param _coefficientB `b` value of the equation
   * @param denominator the denominator of the dailySellLimitFactor
   */
  function setDailySellLimitCoefficients(
    uint256 _coefficientA,
    uint256 _coefficientB,
    uint256 denominator
  ) external onlyOwner {
    require(_coefficientB > _coefficientA * maxHoldingPercentSellLimitApplied, "INVALID_COEFFICIENTS");
    coefficientA = _coefficientA;
    coefficientB = _coefficientB;
    sellLimitDenominator = denominator;
  }

  /**
   * @dev set the max percentage that could be applied when calculating the daily sell limit factor to avoid math overflow
   * the percentage is the percent of a holder's balance comparing to the balance of liquidity pool
   * @param percent provide the max percentage
   */
  function setMaxHoldingPercentSellLimitApplied(uint256 percent) external onlyOwner {
    maxHoldingPercentSellLimitApplied = percent;
  }

  /**
   * @dev how much should the price drop before triggering negative rebase
   * This is a percentage (base value: 5%)
   * @param percent provide the percent
   */
  function setNegativeRebaseFromAth(uint256 percent, uint256 denominator) external onlyOwner {
    negativeFromAthPercent = percent;
    negativeFromAthPercentDenominator = denominator;
  }

  /**
   * @dev set rebase rate and denominator for the positive rabase mechanism
   */
  function setPositiveRebaseRate(uint256 rate, uint256 denominator) external onlyOwner {
    positiveRebaseRate = rate;
    positiveRebaseRateDenominator = denominator;
  }

  /**
   * @dev set rebase rate and denominator for the negative rabase mechanism
   */
  function setNegativeRebaseRate(uint256 rate, uint256 denominator) external onlyOwner {
    negativeRebaseRate = rate;
    negativeRebaseRateDenominator = denominator;
  }

  /**
   * @dev Function allows admin to set the address of the treasury
   */
  function setTreasuryWallet(address wallet) external onlyOwner {
    treasury = wallet;
  }

  /**
   * @dev Function allows admin to set the address of the treasury
   */
  function setAutoLiquidityReceiver(address wallet) external onlyOwner {
    autoLiquidityReceiver = wallet;
  }

  /**
   * @dev Function allows admin to block list an address
   */
  function setBlocklistAddress(address address_, bool flag) external onlyOwner {
    blocklist[address_] = flag;
  }

  /**
   * @dev Function allows admin to exclude an address from transaction fees
   */
  function setFeeExemptAddress(address address_, bool flag) external onlyOwner {
    isFeeExempt[address_] = flag;
  }

  /**
   * @dev Set LP address of EQUO/BUSD pair
   */
  function setBackingLPToken(address lpAddress) external onlyOwner {
    pair = lpAddress;
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }

  /**
   * @dev Function allows admin to withdraw ETH accidentally dropped to the contract.
   */
  function clearStuckBalance(address _receiver) external onlyOwner {
    uint256 balance = address(this).balance;
    payable(_receiver).transfer(balance);
  }

  /**
   * @dev Function allows admin to withdraw tokens accidentally dropped to the contract.
   */
  function rescueToken(address tokenAddress, uint256 amount) external onlyOwner {
    require(IERC20(tokenAddress).transfer(msg.sender, amount), "RESCUE_TOKENS_FAILED");
  }

  /**
   * @dev Set fee split for transaction fee
   * 3 values that modify the percentage of how fees are divided and
   * distributed (Auto-Liquidity, Treasury and Burn Address)
   */
  function setFeeSplit(
    uint256 autoLiquidityPercent,
    uint256 treasuryPercent,
    uint256 burnPercent
  ) external onlyOwner {
    require(autoLiquidityPercent + treasuryPercent + burnPercent == 100, "INVALID_FEE_SPLIT");
    autoLiquidityFeePercent = autoLiquidityPercent;
    treasuryFeePercent = treasuryPercent;
    burnFeePercent = burnPercent;
  }

  /**
   * @dev Set transaction fee rate
   */
  function setFees(
    uint256 _buyFee,
    uint256 _sellFee,
    uint256 _transferFee,
    uint256 _feeDenominator
  ) external onlyOwner {
    buyFee = _buyFee;
    sellFee = _sellFee;
    transferFee = _transferFee;
    feeDenominator = _feeDenominator;
  }

  function balanceOf(address who) external view override returns (uint256) {
    return _gonBalances[who].div(_gonsPerFragment);
  }

  function checkMinAmountToAddLiquidity() external view returns (uint256) {
    return _minAmountToAddLiquidity.div(_gonsPerFragment);
  }

  function checkMinFeeAmountToCollect() external view returns (uint256) {
    return _minFeeAmountToCollect.div(_gonsPerFragment);
  }

  function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
    require(automatedMarketMakerPairs[_pair] != _value, "Value already set");

    automatedMarketMakerPairs[_pair] = _value;

    if (_value) {
      _makerPairs.push(_pair);
    } else {
      require(_makerPairs.length > 1, "Required 1 pair");
      for (uint256 i = 0; i < _makerPairs.length; i++) {
        if (_makerPairs[i] == _pair) {
          _makerPairs[i] = _makerPairs[_makerPairs.length - 1];
          _makerPairs.pop();
          break;
        }
      }
    }

    emit SetAutomatedMarketMakerPair(_pair, _value);
  }

  /**
   * @dev Calculate the sell limit factor
   * A user can only sell a portion of his total balance within a span of 24h
   * This factor is used to calculate the max token amount that a holder could sell in 24h
   * The factor is the result of a linear equation: y = -ax + b
   * @param holdingPercent the percentage of a wallet balance over the liquidity pool balance
   */
  function calculateSellLimitFactor(uint256 holdingPercent) public view returns (uint256) {
    // the sell limit factor follow a linear equation
    uint256 percentApplied = holdingPercent > maxHoldingPercentSellLimitApplied ? maxHoldingPercentSellLimitApplied : holdingPercent;
    uint256 sellLimitFactor = (coefficientB - coefficientA * percentApplied);

    if (sellLimitFactor > MAX_DAILY_SELL_LIMIT_FACTOR) {
      return MAX_DAILY_SELL_LIMIT_FACTOR;
    } else if (sellLimitFactor < MIN_DAILY_SELL_LIMIT_FACTOR) {
      return MIN_DAILY_SELL_LIMIT_FACTOR;
    }

    return sellLimitFactor;
  }

  function getDailySellLimitAmount(address _address) public view returns (uint256) {
    uint256 factor = _getDailySellLimitFactor(_address);
    uint256 bal = IERC20(address(this)).balanceOf(_address);
    return bal.mul(factor).div(sellLimitDenominator);
  }

  function allowance(address owner_, address spender) public view override returns (uint256) {
    return _allowedFragments[owner_][spender];
  }

  function manualSync() public {
    for (uint256 i = 0; i < _makerPairs.length; i++) {
      IDEXPair(_makerPairs[i]).sync();
    }
  }

  /* ========== PUBLIC AND EXTERNAL VIEW FUNCTIONS ========== */

  /**
   * @dev Get total supply excluding burned amount
   */
  function totalSupplyIncludingBurnAmount() public view returns (uint256) {
    return _totalSupply;
  }

  function totalSupply() public view override returns (uint256) {
    return (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(_gonsPerFragment);
  }

  function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
    uint256 liquidityBalance = 0;
    for (uint256 i = 0; i < _makerPairs.length; i++) {
      liquidityBalance = liquidityBalance.add(_gonBalances[_makerPairs[i]].div(_gonsPerFragment));
    }

    return accuracy.mul(liquidityBalance.mul(2)).div(totalSupply());
  }

  /**
   * @dev Returns the name of the token.
   */
  function name() public pure returns (string memory) {
    return _name;
  }

  /**
   * @dev Returns the symbol of the token, usually a shorter version of the
   * name.
   */
  function symbol() public pure returns (string memory) {
    return _symbol;
  }

  /**
   * @dev Returns the number of decimals used to get its user representation.
   * For example, if `decimals` equals `2`, a balance of `505` tokens should
   * be displayed to a user as `5.05` (`505 / 10 ** 2`).
   *
   * Tokens usually opt for a value of 18, imitating the relationship between
   * Ether and Wei. This is the value {ERC20} uses, unless this function is
   * overridden;
   *
   * NOTE: This information is only used for _display_ purposes: it in
   * no way affects any of the arithmetic of the contract, including
   * {IERC20-balanceOf} and {IERC20-transfer}.
   */
  function decimals() public pure returns (uint8) {
    return _decimals;
  }

  /* ========== PRIVATE FUNCTIONS ========== */
  function _transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(!blocklist[sender] && !blocklist[recipient], "ADDRESS_IN_BLOCKLIST");
    if (_inSwap) {
      return _basicTransfer(sender, recipient, amount);
    }

    uint256 twap;
    if (priceOracleEnabled) {
      uint256 amountIn = ONE_UNIT; // 1 token
      // calculate time weighted price for 1 token
      twap = priceOracle.consult(address(this), amountIn, BUSD);
    }

    if (_shouldRebase()) {
      _rebase(twap);
    }

    if (dailySellLimitEnabled && _isSellTx(recipient) && !_noCheckDailySellLimit[sender]) {
      _checkDailySellLimitAndUpdateSaleHistory(sender, amount);
    }

    bool shouldUpdateOracle = true;
    // make sure this transaction either execute auto collect fees or auto add liquidity
    if (_shouldCollectFees()) {
      _collectFeesAndSendToTreasury();
      // avoid trigger updating oracle if this transaction already trigger auto collect fees to save gas
      shouldUpdateOracle = false;
    } else if (_shouldAddLiquidity()) {
      // avoid trigger updating oracle if this transaction already trigger auto adding liquidity to save gas
      _addLiquidity();
      shouldUpdateOracle = false;
    }

    uint256 gonAmount = amount.mul(_gonsPerFragment);
    uint256 gonAmountToRecipient = _shouldTakeFee(sender, recipient) ? _takeFee(sender, recipient, gonAmount) : gonAmount;
    _gonBalances[sender] = _gonBalances[sender].sub(gonAmount, "ERC20: transfer amount exceeds balance");
    _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountToRecipient);

    if (priceOracleEnabled && shouldUpdateOracle) {
      priceOracle.update(address(this), BUSD);
    }

    if (twap > athPrice) {
      athPrice = twap;
    }

    emit Transfer(sender, recipient, gonAmountToRecipient.div(_gonsPerFragment));
    return true;
  }

  /**
   * @dev Collects tax fees, swap into BUSD and send to the treasury
   */
  function _collectFeesAndSendToTreasury() private swapping {
    uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = BUSD;

    if (IERC20(address(this)).allowance(address(this), address(router)) < amountToSwap) {
      IERC20(address(this)).approve(address(router), type(uint256).max);
    }

    router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountToSwap, 0, path, treasury, block.timestamp);
  }

  function _basicTransfer(
    address from,
    address to,
    uint256 amount
  ) private returns (bool) {
    uint256 gonAmount = amount.mul(_gonsPerFragment);
    _gonBalances[from] = _gonBalances[from].sub(gonAmount, "ERC20: transfer amount exceeds balance");
    _gonBalances[to] = _gonBalances[to].add(gonAmount);
    return true;
  }

  /**
   * @dev Internal function to check if transfer amount surpasses the daily sell limit amount
   * @param sender address of the sender that execute the transaction
   * @param amount transfer amount
   */
  function _checkDailySellLimitAndUpdateSaleHistory(address sender, uint256 amount) private {
    SaleHistory storage history = saleHistories[sender];
    uint256 timeElapsed = block.timestamp.sub(history.lastSoldTimestamp);
    if (timeElapsed < 1 days) {
      require(history.totalSoldAmountLast24h.add(amount) <= history.lastDailySellLimitAmount, "EXCEEDS_DAILY_SELL_LIMIT");
      history.totalSoldAmountLast24h += amount;
    } else {
      uint256 limitAmount = getDailySellLimitAmount(sender);
      require(amount <= limitAmount, "EXCEEDS_DAILY_SELL_LIMIT");
      history.lastSoldTimestamp = block.timestamp;
      history.lastDailySellLimitAmount = limitAmount;
      history.totalSoldAmountLast24h = amount;
    }
  }

  function _addLiquidity() private swapping {
    uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(_gonsPerFragment);
    _gonBalances[address(this)] = _gonBalances[address(this)].add(_gonBalances[autoLiquidityReceiver]);
    _gonBalances[autoLiquidityReceiver] = 0;
    uint256 amountToLiquify = autoLiquidityAmount.div(2);
    uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

    if (amountToSwap == 0) {
      return;
    }
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = BUSD;

    uint256 balanceBUSDBefore = IERC20(BUSD).balanceOf(autoLiquidityReceiver);
    router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountToSwap, 0, path, autoLiquidityReceiver, block.timestamp);

    uint256 amountBUSDLiquidity = IERC20(BUSD).balanceOf(autoLiquidityReceiver) - balanceBUSDBefore;
    // make sure autoLiquidityReceiver must approve spending for the token contract first
    IERC20(BUSD).transferFrom(autoLiquidityReceiver, address(this), amountBUSDLiquidity);

    if (IERC20(BUSD).allowance(address(this), address(router)) < amountBUSDLiquidity) {
      IERC20(BUSD).approve(address(router), type(uint256).max);
    }

    if (IERC20(address(this)).allowance(address(this), address(router)) < amountToLiquify) {
      IERC20(address(this)).approve(address(router), type(uint256).max);
    }

    if (amountToLiquify > 0 && amountBUSDLiquidity > 0) {
      router.addLiquidity(address(this), BUSD, amountToLiquify, amountBUSDLiquidity, 0, 0, autoLiquidityReceiver, block.timestamp);
    }
  }

  function _takeFee(
    address sender,
    address recipient,
    uint256 gonAmount
  ) private returns (uint256) {
    uint256 fee;

    TransactionType txType = _getTransactionType(sender, recipient);
    if (txType == TransactionType.BUY) {
      fee = buyFee;
    } else if (txType == TransactionType.SELL) {
      fee = sellFee;
    } else if (txType == TransactionType.TRANSFER) {
      fee = _shouldApplyTransferFee(sender, gonAmount) ? transferFee : 0;
    }

    if (fee == 0) {
      return gonAmount;
    }

    uint256 feeAmount = gonAmount.div(feeDenominator).mul(fee);
    // burn tokens
    uint256 burnAmount = feeAmount.div(feeDenominator).mul(burnFeePercent);
    uint256 treasuryAmount = feeAmount.div(feeDenominator).mul(treasuryFeePercent);
    uint256 liquidityAmount = feeAmount.sub(burnAmount.add(treasuryAmount));

    _gonBalances[DEAD] = _gonBalances[DEAD].add(burnAmount);
    _gonBalances[address(this)] = _gonBalances[address(this)].add(treasuryAmount);
    _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(liquidityAmount);

    emit Transfer(sender, DEAD, burnAmount.div(_gonsPerFragment));
    emit Transfer(sender, autoLiquidityReceiver, liquidityAmount.div(_gonsPerFragment));
    emit Transfer(sender, address(this), treasuryAmount.div(_gonsPerFragment));

    return gonAmount.sub(feeAmount);
  }

  function _isSellTx(address recipient) private view returns (bool) {
    return recipient == pair;
  }

  function _shouldRebase() private view returns (bool) {
    return autoRebase && !_inSwap && msg.sender != pair && block.timestamp >= (lastRebasedTime + rebaseFrequency);
  }

  function _shouldAddLiquidity() private view returns (bool) {
    return autoAddLiquidity && !_inSwap && msg.sender != pair && _gonBalances[autoLiquidityReceiver] >= _minAmountToAddLiquidity;
  }

  function _shouldCollectFees() private view returns (bool) {
    return autoCollectFees && !_inSwap && msg.sender != pair && _gonBalances[address(this)] >= _minFeeAmountToCollect;
  }

  function _shouldTakeFee(address from, address to) private view returns (bool) {
    if (isFeeExempt[from] || isFeeExempt[to]) {
      return false;
    }

    return true;
  }

  /**

   * @dev Check if the transfer fee will be applied on a transfer
   * Transfer fee is only applied to users that transfer less than 100% of their holdings
   * from their wallet to another wallet
   *
   * @param sender the sender of transfer
   * @param gonAmount transfer amount in `gonAmount` unit
   */
  function _shouldApplyTransferFee(address sender, uint256 gonAmount) private view returns (bool) {
    if (!transferFeeEnabled) {
      return false;
    }

    uint256 balance = _gonBalances[sender].div(_gonsPerFragment);
    uint256 transferAmount = gonAmount.div(_gonsPerFragment);
    if (balance == transferAmount) {
      return false;
    }

    return true;
  }

  /**
   * @dev Get daily sell limit factor for a wallet address
   */
  function _getDailySellLimitFactor(address _address) private view returns (uint256) {
    uint256 balance = IERC20(address(this)).balanceOf(_address);
    uint256 balanceOfPair = IERC20(address(this)).balanceOf(pair);
    if (balanceOfPair == 0) {
      return 0;
    }

    uint256 holdingPercent = balance.mul(100).div(balanceOfPair);
    return calculateSellLimitFactor(holdingPercent);
  }

  /**
   * @dev Internal rebase method that notifies token contract about a new rebase cycle
   * this will trigger either a positive or negative rebase depending on the current TWAP
   * If it detects a significant price drop, it will trigger a negative rebase to reduce the totalSupply
   * otherwise it would increase the totalSupply
   * Ater increase/reduce the totalSupply, it executes syncing to update values of the pair's reserve
   */
  function _rebase(uint256 twap) private {
    RebaseType rebaseType = RebaseType.POSITIVE;
    uint256 triggerNegativeRebasePrice = athPrice.sub(athPrice.mul(negativeFromAthPercent).div(negativeFromAthPercentDenominator));

    if (twap != 0 && twap < triggerNegativeRebasePrice && lastNegativeRebaseTriggerAthPrice < athPrice) {
      rebaseType = RebaseType.NEGATIVE;
      // make sure only one negative rebase is trigger when the price drop 5% below the current ATH
      lastNegativeRebaseTriggerAthPrice = athPrice;
    }

    uint256 lastTotalSupply = _totalSupply;
    uint256 deltaTime = block.timestamp - lastRebasedTime;
    uint256 times = deltaTime.div(rebaseFrequency);

    if (rebaseType == RebaseType.POSITIVE) {
      for (uint256 i = 0; i < times; i++) {
        _totalSupply = _totalSupply.mul(positiveRebaseRateDenominator.add(positiveRebaseRate)).div(positiveRebaseRateDenominator);
      }
    } else {
      // if negative rebase, trigger rebase once
      _totalSupply = _totalSupply.mul(negativeRebaseRateDenominator.sub(negativeRebaseRate)).div(negativeRebaseRateDenominator);
    }

    _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
    lastRebasedTime = lastRebasedTime.add(times.mul(rebaseFrequency));

    manualSync();

    uint256 epoch = block.timestamp;
    emit LogRebase(epoch, rebaseType, lastTotalSupply, _totalSupply);
  }

  function _getTransactionType(address sender, address recipient) private view returns (TransactionType) {
    if (pair == sender) {
      return TransactionType.BUY;
    } else if (pair == recipient) {
      return TransactionType.SELL;
    }

    return TransactionType.TRANSFER;
  }
}