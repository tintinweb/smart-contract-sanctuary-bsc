// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./interfaces/IDEXRouter.sol";
import "./interfaces/IDEXFactory.sol";
import "./interfaces/IDEXPair.sol";

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
contract TokenV2 is IERC20, Initializable, OwnableUpgradeable, PausableUpgradeable, UUPSUpgradeable {
  using SafeMath for uint256;

  string private constant _name = "EQUO";
  string private constant _symbol = "EQUO";
  uint8 private constant _decimals = 18;

  uint256 private constant ONE_UNIT = 10**_decimals;
  uint256 private constant INITIAL_FRAGMENTS_SUPPLY = (10**9 + 5 * 10**8) * ONE_UNIT; // 1.5 billion
  uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
  uint256 private constant DEFAULT_GONSWAP_THRESHOLD = TOTAL_GONS / 1000;

  uint256 public constant MAX_UINT256 = ~uint256(0);
  address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
  address public constant ZERO = 0x0000000000000000000000000000000000000000;

  uint256 public constant MAX_DAILY_SELL_LIMIT_FACTOR = 100;
  uint256 public constant MIN_DAILY_SELL_LIMIT_FACTOR = 10;

  uint256 private _totalSupply;
  uint256 private _gonsPerFragment;
  bool private _inSwap;
  uint256 private _gonsCollectedFeeThreshold;

  mapping(address => bool) public automatedMarketMakerPairs;
  mapping(address => uint256) private _gonBalances;
  mapping(address => mapping(address => uint256)) private _allowedFragments;
  mapping(address => bool) private _noCheckDailySellLimit;
  mapping(address => SaleHistory) internal _saleHistories;

  uint256 public positiveRebaseRate;
  uint256 public positiveRebaseRateDenominator;

  uint256 public negativeFromAthPercent;
  uint256 public negativeFromAthPercentDenominator;

  uint256 public lastRebasedTime;

  // Transaction fees
  uint256 public buyFee;
  uint256 public sellFee;
  uint256 public transferFee;
  uint256 public feeDenominator;

  // Coefficients for the daily sell limit liner equation
  uint256 public coefficientA;
  uint256 public coefficientB;
  uint256 public maxHoldingPercentSellLimitApplied;

  // Fee split
  uint256 public autoLiquidityFeePercent;
  uint256 public treasuryFeePercent;
  uint256 public burnFeePercent;

  // Sell limit
  uint256 public sellLimitDenominator;

  // 3rd party contracts
  address public BUSD;
  IDEXRouter public router;

  address public pair;
  // all time high price
  uint256 public athPrice;
  uint256 public athPriceDeltaPermille;

  uint256 public lastNegativeRebaseTriggerAthPrice;
  uint256 public rebaseFrequency;

  address public autoLiquidityReceiver;
  address public treasury;
  address public deployer;

  bool public launched;
  bool public autoRebase;
  bool public swapBackEnabled;
  bool public dailySellLimitEnabled;
  bool public priceEnabled;
  bool public transferFeeEnabled;
  mapping(address => bool) public blocklist;
  mapping(address => bool) public isFeeExempt;
  address[] public _makerPairs;
  // INFO: add new state variables here. Don't modify orders of old variables to avoid storage collision.

  enum RebaseType {
    POSITIVE,
    NEGATIVE
  }

  enum TransactionType {
    BUY,
    SELL,
    TRANSFER
  }

  // SaleHistory tracking how many tokens that a user has sold within a span of 24hs
  struct SaleHistory {
    uint256 lastDailySellLimitAmount;
    uint256 lastSoldTimestamp;
    uint256 totalSoldAmountLast24h;
  }

  event LogRebase(uint256 indexed epoch, RebaseType rebaseType, uint256 lastTotalSupply, uint256 currentTotalSupply);
  event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
  event Launched(uint256 launchedAt);
  event WithdrawFeesToTreasury(uint256 amount);
  event SetPriceEnabled(bool value);
  event SetRebaseFrequency(uint256 valueInSeconds);
  event SetAutoRebase(bool flag);
  event SetDailySellLimitEnabled(bool flag);
  event SetNoCheckDailySellLimit(address indexed address_, bool flag);
  event SetTransferFeeEnabled(bool flag);
  event SetSwapBackEnabled(bool flag);
  event SetCollectedFeeThreshold(uint256 amount);
  event SetDailySellLimitCoefficients(uint256 a, uint256 b, uint256 denominator);
  event SetNegativeRebaseFromAth(uint256 percent, uint256 denominator);
  event SetPositiveRebaseRate(uint256 rate, uint256 denominator);
  event SetMaxHoldingPercentSellLimitApplied(uint256 percent);
  event SetTreasuryWallet(address wallet);
  event SetAutoLiquidityReceiver(address wallet);
  event SetBlocklistAddress(address address_, bool flag);
  event SetFeeExemptAddress(address address_, bool flag);
  event SetBackingLPToken(address lpAddress);
  event Pause();
  event Unpause();
  event SetFeeSplit(uint256 autoLiquidityPercent, uint256 treasuryPercent, uint256 burnPercent);
  event NewAllTimeHigh(uint256 lastAthPrice, uint256 newAthPrice);
  event SetFees(uint256 buyFee, uint256 sellFee, uint256 transferFee, uint256 feeDenominator);

  modifier swapping() {
    _inSwap = true;
    _;
    _inSwap = false;
  }

  modifier validRecipient(address to) {
    require(to != address(0x0));
    _;
  }

  function initialize(
    address _dexRouter,
    address _busd,
    address _autoLiquidityReceiver,
    address _treasury
  ) public initializer {
    __Ownable_init();
    __Pausable_init();
    __UUPSUpgradeable_init();

    router = IDEXRouter(_dexRouter);
    BUSD = _busd;
    pair = IDEXFactory(router.factory()).createPair(_busd, address(this));

    autoLiquidityReceiver = _autoLiquidityReceiver;
    treasury = _treasury;

    setAutomatedMarketMakerPair(pair, true);

    _allowedFragments[address(this)][address(router)] = MAX_UINT256;

    _totalSupply = INITIAL_FRAGMENTS_SUPPLY;

    address _deployer = msg.sender;
    deployer = _deployer;
    _gonBalances[_deployer] = TOTAL_GONS;
    _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

    isFeeExempt[deployer] = true;

    _inSwap = false;
    _gonsCollectedFeeThreshold = DEFAULT_GONSWAP_THRESHOLD;
    positiveRebaseRate = 2073;
    positiveRebaseRateDenominator = 10**7;

    negativeFromAthPercent = 5;
    negativeFromAthPercentDenominator = 100;

    // Transaction fees
    buyFee = 13;
    sellFee = 17;
    transferFee = 35;
    feeDenominator = 100;

    coefficientA = 10;
    coefficientB = 110;
    maxHoldingPercentSellLimitApplied = 9;

    // Fee split
    autoLiquidityFeePercent = 50;
    treasuryFeePercent = 30;
    burnFeePercent = 20;

    // Sell limit
    sellLimitDenominator = 10000;
    athPriceDeltaPermille = 10;
    rebaseFrequency = 30 minutes;

    emit Transfer(address(0x0), deployer, _totalSupply);
  }

  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  receive() external payable {}

  function getVersion() external pure returns (string memory) {
    return "2.0";
  }

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
   * @dev Execute launch after adding liquidity
   */
  function launch() external onlyOwner {
    require(IERC20(address(this)).balanceOf(pair) > 0, "LIQUIDITY_NOT_ADDED");
    require(IERC20(BUSD).allowance(autoLiquidityReceiver, address(this)) > 0, "INSUFFICIENT_BUSD_ALLOWANCE_FROM_LIQUIDITY_RECEIVER");

    autoRebase = true;
    swapBackEnabled = true;

    dailySellLimitEnabled = true;
    transferFeeEnabled = true;
    priceEnabled = true;

    uint256 currentTime = block.timestamp;
    lastRebasedTime = currentTime;
    launched = true;
    emit Launched(currentTime);
  }

  function setAthDeltaPermille(uint256 permille) external onlyOwner {
    require(permille > 0 && permille < 1000, "INVALID_PERMILLE");
    athPriceDeltaPermille = permille;
  }

  /**
   * @dev Manual trigger rebase to increase or reduce the total supply of the token
   */
  function rebase() external {
    require(_shouldRebase(), "SHOULD_NOT_REBASE");
    // calculate time weighted price for 1 EQUO token
    uint256 price = priceEnabled ? _getTokenPriceInBUSD() : 0;
    _rebase(price);
  }

  /**
   * @dev Collect all fees, remaining BUSD of the contract and send to treasury
   */
  function withdrawFeesToTreasury() external swapping onlyOwner {
    uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);
    if (amountToSwap > 0) {
      address[] memory path = new address[](2);
      path[0] = address(this);
      path[1] = BUSD;

      if (IERC20(address(this)).allowance(address(this), address(router)) < amountToSwap) {
        IERC20(address(this)).approve(address(router), type(uint256).max);
      }

      router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountToSwap, 0, path, treasury, block.timestamp);
    }

    uint256 balanceBUSD = IERC20(BUSD).balanceOf(address(this));
    if (balanceBUSD > 0) {
      IERC20(BUSD).transfer(treasury, balanceBUSD);
      emit WithdrawFeesToTreasury(balanceBUSD);
    }
  }

  /* ========== FUNCTIONS FOR OWNER ========== */

  /**
   * @dev enable calculating current price for each transaction
   */
  function setPriceEnabled(bool flag) external onlyOwner {
    priceEnabled = flag;
    emit SetPriceEnabled(flag);
  }

  /**
   * @dev Set rebase frequency in seconds
   * @param valueInSeconds Provide duration in seconds
   */
  function setRebaseFrequency(uint256 valueInSeconds) external onlyOwner {
    rebaseFrequency = valueInSeconds;
    emit SetRebaseFrequency(valueInSeconds);
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
    emit SetAutoRebase(flag);
  }

  /**
   * @dev Switch on/off checking daily sell limit feature
   * @param flag provide the boolean value
   */
  function setDailySellLimitEnabled(bool flag) external onlyOwner {
    dailySellLimitEnabled = flag;
    emit SetDailySellLimitEnabled(flag);
  }

  /**
   * @dev Exclude an address from daily sell limit restriction
   * @param _address Provide the address to be excluded
   * @param flag provide the boolean value
   */
  function setNoCheckDailySellLimit(address _address, bool flag) external onlyOwner {
    _noCheckDailySellLimit[_address] = flag;
    emit SetNoCheckDailySellLimit(_address, flag);
  }

  /**
   * @dev Switch on/off taking transfer fee feature
   * @param flag provide the boolean value
   */
  function setTransferFeeEnabled(bool flag) external onlyOwner {
    transferFeeEnabled = flag;
    emit SetTransferFeeEnabled(flag);
  }

  /**
   * @dev Toggle swapback
   * @param flag provide the boolean value
   */
  function setSwapBackEnabled(bool flag) external onlyOwner {
    swapBackEnabled = flag;
    emit SetSwapBackEnabled(flag);
  }

  /**
   * @dev Set threshold amount to trigger collecting fees when balance of the contract goes above this threshold
   * @param amount provide the threshold amount
   */
  function setCollectedFeeThreshold(uint256 amount) external onlyOwner {
    _gonsCollectedFeeThreshold = amount.mul(_gonsPerFragment);
    emit SetCollectedFeeThreshold(amount);
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

    emit SetDailySellLimitCoefficients(_coefficientA, _coefficientB, denominator);
  }

  /**
   * @dev set the max percentage that could be applied when calculating the daily sell limit factor to avoid math overflow
   * the percentage is the percent of a holder's balance comparing to the balance of liquidity pool
   * @param percent provide the max percentage
   */
  function setMaxHoldingPercentSellLimitApplied(uint256 percent) external onlyOwner {
    maxHoldingPercentSellLimitApplied = percent;
    emit SetMaxHoldingPercentSellLimitApplied(percent);
  }

  /**
   * @dev how much should the price drop before triggering negative rebase
   * This is a percentage (base value: 5%)
   * @param percent provide the percent
   */
  function setNegativeRebaseFromAth(uint256 percent, uint256 denominator) external onlyOwner {
    negativeFromAthPercent = percent;
    negativeFromAthPercentDenominator = denominator;
    emit SetNegativeRebaseFromAth(percent, denominator);
  }

  /**
   * @dev set rebase rate and denominator for the positive rabase mechanism
   */
  function setPositiveRebaseRate(uint256 rate, uint256 denominator) external onlyOwner {
    positiveRebaseRate = rate;
    positiveRebaseRateDenominator = denominator;
    emit SetPositiveRebaseRate(rate, denominator);
  }

  /**
   * @dev Function allows admin to set the address of the treasury
   */
  function setTreasuryWallet(address wallet) external onlyOwner {
    treasury = wallet;
    emit SetTreasuryWallet(wallet);
  }

  /**
   * @dev Function allows admin to set the address of liquidity receiver
   */
  function setAutoLiquidityReceiver(address wallet) external onlyOwner {
    autoLiquidityReceiver = wallet;
    emit SetAutoLiquidityReceiver(wallet);
  }

  /**
   * @dev Function allows admin to block list an address
   */
  function setBlocklistAddress(address address_, bool flag) external onlyOwner {
    blocklist[address_] = flag;
    emit SetBlocklistAddress(address_, flag);
  }

  /**
   * @dev Function allows admin to exclude an address from transaction fees
   */
  function setFeeExemptAddress(address address_, bool flag) external onlyOwner {
    isFeeExempt[address_] = flag;
    emit SetFeeExemptAddress(address_, flag);
  }

  /**
   * @dev Set LP address of EQUO/BUSD pair
   */
  function setBackingLPToken(address lpAddress) external onlyOwner {
    pair = lpAddress;
    emit SetBackingLPToken(lpAddress);
  }

  function pause() external onlyOwner {
    _pause();
    emit Pause();
  }

  function unpause() external onlyOwner {
    _unpause();
    emit Unpause();
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

    emit SetFeeSplit(autoLiquidityPercent, treasuryPercent, burnPercent);
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
    emit SetFees(buyFee, sellFee, transferFee, feeDenominator);
  }

  function balanceOf(address who) external view override returns (uint256) {
    return _gonBalances[who].div(_gonsPerFragment);
  }

  /**
   * @dev Check collected fee threshold amount
   * If balance of the contract surpasses the threshold, a swapback will be triggered
   */
  function checkCollectedFeeThreshold() external view returns (uint256) {
    return _gonsCollectedFeeThreshold.div(_gonsPerFragment);
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

  /**
   * @dev internal method to get the daily sell limit amount in gons
   */
  function _getDailySellLimitAmountInternalInGons(address _address) internal view returns (uint256) {
    uint256 factor = _getDailySellLimitFactor(_address);
    uint256 bal = _gonBalances[_address];
    return bal.div(sellLimitDenominator).mul(factor);
  }

  /**
   * @dev external method to get the daily sell limit amount
   */
  function getDailySellLimitAmount(address _address) public view returns (uint256) {
    return _getDailySellLimitAmountInternalInGons(_address).div(_gonsPerFragment);
  }

  function allowance(address owner_, address spender) public view override returns (uint256) {
    return _allowedFragments[owner_][spender];
  }

  /**
   * @dev Manual update AMM pair reserve's balance
   */
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
    require(launched || sender == deployer, "TOKEN_NOT_LAUNCHED_YET");

    if (_inSwap) {
      return _basicTransfer(sender, recipient, amount);
    }

    uint256 price;
    if (priceEnabled) {
      price = _getTokenPriceInBUSD();
    }

    uint256 gonAmount = amount.mul(_gonsPerFragment);

    if (dailySellLimitEnabled && _isSellTx(recipient) && !_noCheckDailySellLimit[sender]) {
      _checkDailySellLimitAndUpdateSaleHistory(sender, gonAmount);
    }

    if (_shouldRebase()) {
      _rebase(price);
    }

    if (_shouldSwapBack()) {
      _swapBack();
    }

    uint256 gonAmountToRecipient = _shouldTakeFee(sender, recipient) ? _takeFee(sender, recipient, gonAmount) : gonAmount;
    _gonBalances[sender] = _gonBalances[sender].sub(gonAmount, "ERC20: transfer amount exceeds balance");
    _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountToRecipient);

    if (price > athPrice) {
      uint256 lastAthPrice = athPrice;
      athPrice = price;
      emit NewAllTimeHigh(lastAthPrice, price);
    }

    emit Transfer(sender, recipient, gonAmountToRecipient.div(_gonsPerFragment));

    return true;
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
   * @param gonAmount transfer amount
   */
  function _checkDailySellLimitAndUpdateSaleHistory(address sender, uint256 gonAmount) private {
    SaleHistory storage history = _saleHistories[sender];
    uint256 timeElapsed = block.timestamp.sub(history.lastSoldTimestamp);
    if (timeElapsed < 1 days) {
      require(history.totalSoldAmountLast24h.add(gonAmount) <= history.lastDailySellLimitAmount, "EXCEEDS_DAILY_SELL_LIMIT");
      history.totalSoldAmountLast24h += gonAmount;
    } else {
      uint256 limitAmount = _getDailySellLimitAmountInternalInGons(sender);
      require(gonAmount <= limitAmount, "EXCEEDS_DAILY_SELL_LIMIT");
      history.lastSoldTimestamp = block.timestamp;
      history.lastDailySellLimitAmount = limitAmount;
      history.totalSoldAmountLast24h = gonAmount;
    }
  }

  /**
   * @dev _swapBack collect fees and swap fees into BUSD
   * A portion of BUSD amount will be added to liquidity, the rest will be transferred to the treasury
   */
  function _swapBack() internal swapping {
    uint256 totalFee = autoLiquidityFeePercent.add(treasuryFeePercent);
    uint256 balance = _gonBalances[address(this)].div(_gonsPerFragment);
    uint256 balanceBUSDBefore = IERC20(BUSD).balanceOf(autoLiquidityReceiver);

    uint256 amountForAutoLiquidity = balance.mul(autoLiquidityFeePercent).div(totalFee);
    uint256 amountToLiquify = amountForAutoLiquidity.div(2);
    uint256 amountToSwap = balance.sub(amountToLiquify);

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = BUSD;
    // this contract can't receive BUSD so it delegates received BUSD to autoLiquidityReceiver
    router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountToSwap, 0, path, autoLiquidityReceiver, block.timestamp);

    uint256 balanceBUSDAfter = IERC20(BUSD).balanceOf(autoLiquidityReceiver);
    uint256 amountBUSD = balanceBUSDAfter.sub(balanceBUSDBefore);
    IERC20(BUSD).transferFrom(autoLiquidityReceiver, address(this), amountBUSD);

    uint256 totalBUSDFee = totalFee.sub(autoLiquidityFeePercent.div(2));
    uint256 amountBUSDLiquidity = amountBUSD.mul(autoLiquidityFeePercent).div(totalBUSDFee).div(2);

    if (IERC20(BUSD).allowance(address(this), address(router)) < amountBUSDLiquidity) {
      IERC20(BUSD).approve(address(router), type(uint256).max);
    }

    if (IERC20(address(this)).allowance(address(this), address(router)) < amountToLiquify) {
      IERC20(address(this)).approve(address(router), type(uint256).max);
    }

    if (amountToLiquify > 0) {
      router.addLiquidity(BUSD, address(this), amountBUSDLiquidity, amountToLiquify, 0, 0, autoLiquidityReceiver, block.timestamp);
    }

    uint256 amountBUSDTreasury = IERC20(BUSD).balanceOf(address(this));
    IERC20(BUSD).transfer(treasury, amountBUSDTreasury);
  }

  /**
   * @dev _takeFee take fees of a transaction
   *
   */
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
    uint256 liquidityAndTreasuryAmount = feeAmount.sub(burnAmount);

    _gonBalances[DEAD] = _gonBalances[DEAD].add(burnAmount);
    _gonBalances[address(this)] = _gonBalances[address(this)].add(liquidityAndTreasuryAmount);

    emit Transfer(sender, DEAD, burnAmount.div(_gonsPerFragment));
    emit Transfer(sender, address(this), liquidityAndTreasuryAmount.div(_gonsPerFragment));

    return gonAmount.sub(feeAmount);
  }

  function _getTokenPriceInBUSD() private view returns (uint256) {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = BUSD;
    uint256[] memory amounts = router.getAmountsOut(ONE_UNIT, path);
    return amounts[1];
  }

  /**
   * @dev _isSellTx check if a transaction is a sell transaction by comparing the recipient to the pair address
   */
  function _isSellTx(address recipient) private view returns (bool) {
    return recipient == pair;
  }

  /**
   * @dev _shouldRebase check if the contract should do a rebase after a rebase frequency period has passed
   */
  function _shouldRebase() private view returns (bool) {
    return autoRebase && !_inSwap && msg.sender != pair && block.timestamp >= (lastRebasedTime + rebaseFrequency);
  }

  /**
   * @dev _shouldTakeFee check if a transaction should be applied fee or not
   * an address that exists in the fee exempt mapping will be excluded from fee
   */
  function _shouldSwapBack() private view returns (bool) {
    return swapBackEnabled && !_inSwap && msg.sender != pair && _gonBalances[address(this)] >= _gonsCollectedFeeThreshold;
  }

  /**
   * @dev _shouldTakeFee check if a transaction should be applied fee or not
   * an address that exists in the fee exempt mapping will be excluded from fee
   */
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
   * this will trigger either a positive or negative rebase depending on the current price
   * If it detects a significant price drop, it will trigger a negative rebase to reduce the totalSupply
   * otherwise it would increase the totalSupply
   * Ater increase/reduce the totalSupply, it executes syncing to update values of the pair's reserve
   */
  function _rebase(uint256 currentPrice) private {
    RebaseType rebaseType = RebaseType.POSITIVE;
    uint256 triggerNegativeRebasePrice = athPrice.sub(athPrice.mul(negativeFromAthPercent).div(negativeFromAthPercentDenominator));

    if (currentPrice != 0 && currentPrice < triggerNegativeRebasePrice && lastNegativeRebaseTriggerAthPrice < athPrice) {
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
      _totalSupply = _estimateNegativeRebaseSupply();
    }

    _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
    lastRebasedTime = lastRebasedTime.add(times.mul(rebaseFrequency));

    manualSync();

    uint256 epoch = block.timestamp;
    emit LogRebase(epoch, rebaseType, lastTotalSupply, _totalSupply);
  }

  /**
   * @dev _getTransactionType detects if a transaction is a buy or sell/ transfer transaction buy checking if the sender/recipient matches the pair address
   */
  function _getTransactionType(address sender, address recipient) private view returns (TransactionType) {
    if (pair == sender) {
      return TransactionType.BUY;
    } else if (pair == recipient) {
      return TransactionType.SELL;
    }

    return TransactionType.TRANSFER;
  }

  /**
   * @dev Estimate the new supply for a negative rebase
   */
  function _estimateNegativeRebaseSupply() private view returns (uint256) {
    if (athPrice == 0) {
      return _totalSupply;
    }

    address token0 = IDEXPair(pair).token0();
    (uint256 reserve0, uint256 reserve1, ) = IDEXPair(pair).getReserves();
    uint256 reserveIn = token0 == address(this) ? reserve0 : reserve1;
    uint256 reserveOut = token0 == BUSD ? reserve0 : reserve1;

    // this is a reverse computation of getAmountOut to find reserveIn
    // https://github.com/pancakeswap/pancake-smart-contracts/blob/d8f55093a43a7e8913f7730cfff3589a46f5c014/projects/exchange-protocol/contracts/libraries/PancakeLibrary.sol#L63
    uint256 expectedAmountOut = athPrice.add(athPrice.mul(athPriceDeltaPermille).div(1000));
    uint256 amountIn = ONE_UNIT;
    uint256 amountInWithFee = amountIn.mul(9975);
    uint256 numerator = amountInWithFee.mul(reserveOut);
    uint256 expectedDenominator = numerator.div(expectedAmountOut);
    // calculate expectedReserveIn to achieve expectedAmountOut
    uint256 expectedReserveIn = expectedDenominator.sub(amountInWithFee).div(10000);
    // reserveIn / _totalSupply  = expectedReserveIn / new totalSupply
    uint256 newTotalSupply = expectedReserveIn.mul(_totalSupply).div(reserveIn);
    return newTotalSupply;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
pragma solidity ^0.8.13;

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

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IDEXFactory {
  function createPair(address tokenA, address tokenB) external returns (address pair);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IDEXPair {
  function token0() external view returns (address);

  function token1() external view returns (address);

  function sync() external;

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}