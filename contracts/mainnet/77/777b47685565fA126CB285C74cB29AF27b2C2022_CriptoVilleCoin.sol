// SPDX-License-Identifier: PROPRIETARY

pragma solidity 0.8.17;

import "./ERC20.sol";
import "./IPancake.sol";
import "./GasHelper.sol";
import "./SwapHelper.sol";

contract CriptoVilleCoin is GasHelper, ERC20 {
  address constant DEAD = 0x000000000000000000000000000000000000dEaD;
  address constant ZERO = 0x0000000000000000000000000000000000000000;
  address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
  address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 

  string constant _name = "CRIPTOVILLE COINS";
  string constant _symbol = "CVLC";

  string public constant url = "www.criptoville.com";

  uint constant maxSupply = 100_000_000e18;

  // Wallets limits
  uint public _maxTxAmount = maxSupply;
  uint public _maxAccountAmount = maxSupply;
  uint public _minAmountToAutoSwap = 1000 * (10**decimals()); // 100

  // Fees
  uint private _feePool = 0;
  uint private _feeBurnRate = 0;
  uint private _feeAdministrationWallet = 350;
  uint private _feeMarketingWallet = 350;

  uint constant maxTotalFee = 1600;

  mapping(address => uint) public specialFeesByWallet;
  mapping(address => uint) public specialFeesByWalletReceiver;

  // Helpers
  bool internal pausedToken;
  bool private _noReentrance;

  bool public pausedSwapPool;
  bool public pausedSwapAdmin;
  bool public pausedSwapMarketing;
  bool public disabledAutoLiquidity;

  // Counters
  uint public accumulatedToAdmin;
  uint public accumulatedToMarketing;
  uint public accumulatedToPool;

  // Liquidity Pair
  address public liquidityPool;

  // Wallets
  address public administrationWallet;
  address public marketingWallet;

  address public swapHelperAddress;

  receive() external payable {}

  constructor() ERC20(_name, _symbol) {
    permissions[0][_msgSender()] = true;
    permissions[1][_msgSender()] = true;
    permissions[2][_msgSender()] = true;
    permissions[3][_msgSender()] = true;

    PancakeRouter router = PancakeRouter(PANCAKE_ROUTER);
    liquidityPool = address(PancakeFactory(router.factory()).createPair(WBNB, address(this)));

    uint baseAttributes = 0;
    baseAttributes = setExemptAmountLimit(baseAttributes, true);
    _attributeMap[liquidityPool] = baseAttributes;

    baseAttributes = setExemptTxLimit(baseAttributes, true);
    _attributeMap[DEAD] = baseAttributes;
    _attributeMap[ZERO] = baseAttributes;

    baseAttributes = setExemptFee(baseAttributes, true);
    _attributeMap[address(this)] = baseAttributes;

    baseAttributes = setExemptOperatePausedToken(baseAttributes, true);
    baseAttributes = setExemptSwapperMaker(baseAttributes, true);
    baseAttributes = setExemptFeeReceiver(baseAttributes, true);

    _attributeMap[_msgSender()] = baseAttributes;

    SwapHelper swapHelper = new SwapHelper();
    swapHelper.safeApprove(WBNB, address(this), type(uint).max);
    swapHelper.transferOwnership(_msgSender());
    swapHelperAddress = address(swapHelper);

    baseAttributes = setExemptOperatePausedToken(baseAttributes, false);
    _attributeMap[swapHelperAddress] = baseAttributes;

    _mint(_msgSender(), maxSupply);

    pausedToken = true;
    disabledAutoLiquidity = true;
  }

  // ----------------- Public Views -----------------
  function getOwner() external view returns (address) {
    return owner();
  }

  function getFeeTotal() public view returns (uint) {
    return _feePool + _feeBurnRate + _feeAdministrationWallet + _feeMarketingWallet;
  }

  function getSpecialWalletFee(address target, bool isSender)
    public
    view
    returns (
      uint pool,
      uint burnRate,
      uint adminFee,
      uint marketingFee
    )
  {
    uint composedValue = isSender ? specialFeesByWallet[target] : specialFeesByWalletReceiver[target];
    pool = composedValue % 1e4;
    composedValue = composedValue / 1e4;
    burnRate = composedValue % 1e4;
    composedValue = composedValue / 1e4;
    adminFee = composedValue % 1e4;
    composedValue = composedValue / 1e4;
    marketingFee = composedValue % 1e4;
  }

  // ----------------- Authorized Methods -----------------

  function enableToken() external isAuthorized(0) {
    pausedToken = false;
  }

  function setLiquidityPool(address newPair) external isAuthorized(0) {
    require(newPair != ZERO, "Invalid address");
    liquidityPool = newPair;
  }

  function setPausedSwapPool(bool state) external isAuthorized(0) {
    pausedSwapPool = state;
  }

  function setPausedSwapAdmin(bool state) external isAuthorized(0) {
    pausedSwapAdmin = state;
  }

  function setPausedSwapMarketing(bool state) external isAuthorized(0) {
    pausedSwapMarketing = state;
  }

  function setDisabledAutoLiquidity(bool state) external isAuthorized(0) {
    disabledAutoLiquidity = state;
  }

  // ----------------- Wallets Settings -----------------
  function setAdministrationWallet(address account) public isAuthorized(0) {
    administrationWallet = account;
  }

  function setMarketingWallet(address account) public isAuthorized(0) {
    marketingWallet = account;
  }

  // ----------------- Fee Settings -----------------
  function setFees(
    uint pool,
    uint burnRate,
    uint administration,
    uint feeMarketing
  ) external isAuthorized(1) {
    _feePool = pool;
    _feeBurnRate = burnRate;
    _feeAdministrationWallet = administration;
    _feeMarketingWallet = feeMarketing;
    require(getFeeTotal() <= maxTotalFee, "All fee together must be lower than 16%");
  }

  function setSpecialWalletFeeOnSend(
    address target,
    uint pool,
    uint burnRate,
    uint adminFee,
    uint marketingFee
  ) public isAuthorized(1) {
    setSpecialWalletFee(target, true, pool, burnRate, adminFee, marketingFee);
  }

  function setSpecialWalletFeeOnReceive(
    address target,
    uint pool,
    uint burnRate,
    uint adminFee,
    uint marketingFee
  ) public isAuthorized(1) {
    setSpecialWalletFee(target, false, pool, burnRate, adminFee, marketingFee);
  }

  function setSpecialWalletFee(
    address target,
    bool isSender,
    uint pool,
    uint burnRate,
    uint adminFee,
    uint marketingFee
  ) private {
    uint total = pool + burnRate + adminFee + marketingFee;
    require(total <= maxTotalFee, "All rates and fee together must be lower than 16%");
    uint composedValue = pool + (burnRate * 1e4) + (adminFee * 1e8) + (marketingFee * 1e12);
    if (isSender) {
      specialFeesByWallet[target] = composedValue;
    } else {
      specialFeesByWalletReceiver[target] = composedValue;
    }
  }

  function increment(uint amount) external isAuthorized(0) {
    _mint(_msgSender(), amount);
  }

  // ----------------- Token Flow Settings -----------------
  function setMaxTxAmount(uint maxTxAmount) public isAuthorized(1) {
    require(maxTxAmount >= totalSupply() / 100_000, "Amount must be bigger then 0.001% tokens");
    _maxTxAmount = maxTxAmount;
  }

  function setMaxAccountAmount(uint maxAccountAmount) public isAuthorized(1) {
    require(maxAccountAmount >= totalSupply() / 100_000, "Amount must be bigger then 0.001% tokens");
    _maxAccountAmount = maxAccountAmount;
  }

  function setMinAmountToAutoSwap(uint amount) public isAuthorized(1) {
    _minAmountToAutoSwap = amount;
  }

  // ----------------- External Methods -----------------
  function burn(uint amount) external {
    _burn(_msgSender(), amount);
  }

  function multiTransfer(address[] calldata wallets, uint112[] calldata amounts) external {
    require(wallets.length == amounts.length, "Invalid list sizes");
    require(!_noReentrance, "ReentranceGuard Alert");
    _noReentrance = true;

    address sender = msg.sender;
    uint senderAttributes = _attributeMap[sender];
    uint totalAmount;

    for (uint i = 0; i < amounts.length; i++) totalAmount += amounts[i];
    require(!pausedToken || isExemptOperatePausedToken(senderAttributes), "Token is paused");

    uint senderBalance = _balances[sender];
    require(senderBalance >= totalAmount, "Transfer amount exceeds your balance");
    senderBalance -= totalAmount;
    _balances[sender] = senderBalance;

    for (uint i = 0; i < wallets.length; i++) {
      address receiver = wallets[i];
      uint amount = amounts[i];

      require(amount > 0, "Invalid Amount");
      require(amount <= _maxTxAmount || isExemptTxLimit(senderAttributes), "Exceeded the maximum transaction limit");

      uint receiverAttributes = _attributeMap[receiver];

      uint adminFee;
      uint poolFee;
      uint burnFee;
      uint marketingFee;
      uint feeAmount;

      if (!isExemptFee(senderAttributes) && !isExemptFeeReceiver(receiverAttributes)) {
        if (isSpecialFeeWallet(senderAttributes)) {
          (poolFee, burnFee, adminFee, marketingFee) = getSpecialWalletFee(sender, true); // Check special wallet fee on sender
        } else if (isSpecialFeeWalletReceiver(receiverAttributes)) {
          (poolFee, burnFee, adminFee, marketingFee) = getSpecialWalletFee(receiver, true); // Check special wallet fee on receiver
        } else {
          adminFee = _feeAdministrationWallet;
          poolFee = _feePool;
          burnFee = _feeBurnRate;
          marketingFee = _feeMarketingWallet;
        }
        feeAmount = ((poolFee + burnFee + adminFee + marketingFee) * amount) / 10_000;
      }
      if (feeAmount != 0) splitFee(feeAmount, sender, adminFee, poolFee, burnFee, marketingFee);
      uint discountedAmount = amount - feeAmount;
      uint newRecipientBalance = _balances[receiver] + discountedAmount;
      _balances[receiver] = newRecipientBalance;
      require(newRecipientBalance <= _maxAccountAmount || isExemptAmountLimit(receiverAttributes), "Exceeded the maximum tokens an wallet can hold");

      emit Transfer(sender, receiver, discountedAmount);
    }
    if ((!pausedSwapPool || !pausedSwapAdmin || !pausedSwapMarketing) && !isExemptSwapperMaker(senderAttributes)) autoSwap(sender);
    _noReentrance = false;
  }

  // ----------------- Internal CORE -----------------
  function _transfer(
    address sender,
    address receiver,
    uint amount
  ) internal override {
    require(amount > 0, "Invalid Amount");
    require(!_noReentrance, "ReentranceGuard Alert");
    _noReentrance = true;

    uint senderAttributes = _attributeMap[sender];
    uint receiverAttributes = _attributeMap[receiver];

    // Initial Checks
    require(sender != ZERO && receiver != ZERO, "transfer from / to the zero address");
    require(!pausedToken || isExemptOperatePausedToken(senderAttributes), "Token is paused");
    require(amount <= _maxTxAmount || isExemptTxLimit(senderAttributes), "Exceeded the maximum transaction limit");

    uint senderBalance = _balances[sender];
    require(senderBalance >= amount, "Transfer amount exceeds your balance");
    senderBalance -= amount;
    _balances[sender] = senderBalance;

    uint adminFee;
    uint poolFee;
    uint burnFee;
    uint marketingFee;

    // Calculate Fees
    uint feeAmount = 0;
    if (!isExemptFee(senderAttributes) && !isExemptFeeReceiver(receiverAttributes)) {
      if (isSpecialFeeWallet(senderAttributes)) {
        (poolFee, burnFee, adminFee, marketingFee) = getSpecialWalletFee(sender, true); // Check special wallet fee on sender
      } else if (isSpecialFeeWalletReceiver(receiverAttributes)) {
        (poolFee, burnFee, adminFee, marketingFee) = getSpecialWalletFee(receiver, true); // Check special wallet fee on receiver
      } else {
        adminFee = _feeAdministrationWallet;
        poolFee = _feePool;
        burnFee = _feeBurnRate;
        marketingFee = _feeMarketingWallet;
      }
      feeAmount = ((poolFee + burnFee + adminFee + marketingFee) * amount) / 10_000;
    }

    if (feeAmount != 0) splitFee(feeAmount, sender, adminFee, poolFee, burnFee, marketingFee);
    if ((!pausedSwapPool || !pausedSwapAdmin || !pausedSwapMarketing) && !isExemptSwapperMaker(senderAttributes)) autoSwap(sender);

    // Update Recipient Balance
    uint newRecipientBalance = _balances[receiver] + (amount - feeAmount);
    _balances[receiver] = newRecipientBalance;
    require(newRecipientBalance <= _maxAccountAmount || isExemptAmountLimit(receiverAttributes), "Exceeded the maximum tokens an wallet can hold");

    _noReentrance = false;
    emit Transfer(sender, receiver, amount - feeAmount);
  }

  function operateSwap(
    address liquidityPair,
    address swapHelper,
    uint amountIn
  ) private returns (uint) {
    (uint112 reserve0, uint112 reserve1) = getTokenReserves(liquidityPair);
    bool reversed = isReversed(liquidityPair, WBNB);

    if (reversed) {
      uint112 temp = reserve0;
      reserve0 = reserve1;
      reserve1 = temp;
    }

    _balances[liquidityPair] += amountIn;
    uint wbnbAmount = getAmountOut(amountIn, reserve1, reserve0);
    if (!reversed) {
      swapToken(liquidityPair, wbnbAmount, 0, swapHelper);
    } else {
      swapToken(liquidityPair, 0, wbnbAmount, swapHelper);
    }
    return wbnbAmount;
  }

  function autoSwap(address sender) private {
    // --------------------- Execute Auto Swap -------------------------
    address liquidityPair = liquidityPool;
    address swapHelper = swapHelperAddress;

    if (sender == liquidityPair) return;

    uint poolAmount = disabledAutoLiquidity ? accumulatedToPool : accumulatedToPool / 2;
    uint adminAmount = accumulatedToAdmin;
    uint marketingAmount = accumulatedToMarketing;
    uint totalAmount = poolAmount + adminAmount + marketingAmount;

    if (totalAmount < _minAmountToAutoSwap) return;

    // Execute auto swap
    uint amountOut = operateSwap(liquidityPair, swapHelper, totalAmount);

    // --------------------- Add Liquidity -------------------------
    if (poolAmount > 0) {
      if (!disabledAutoLiquidity) {
        uint amountToSend = (amountOut * poolAmount) / (totalAmount);
        (uint112 reserve0, uint112 reserve1) = getTokenReserves(liquidityPair);
        bool reversed = isReversed(liquidityPair, WBNB);
        if (reversed) {
          uint112 temp = reserve0;
          reserve0 = reserve1;
          reserve1 = temp;
        }

        uint amountA;
        uint amountB;
        {
          uint amountBOptimal = (amountToSend * reserve1) / reserve0;
          if (amountBOptimal <= poolAmount) {
            (amountA, amountB) = (amountToSend, amountBOptimal);
          } else {
            uint amountAOptimal = (poolAmount * reserve0) / reserve1;
            assert(amountAOptimal <= amountToSend);
            (amountA, amountB) = (amountAOptimal, poolAmount);
          }
        }
        tokenTransferFrom(WBNB, swapHelper, liquidityPair, amountA);
        _balances[liquidityPair] += amountB;
        IPancakePair(liquidityPair).mint(address(this));
      } else {
        uint amountToSend = (amountOut * poolAmount) / (totalAmount);
        tokenTransferFrom(WBNB, swapHelper, address(this), amountToSend);
      }
    }

    // --------------------- Transfer Swapped Amount -------------------------
    if (adminAmount > 0) {
      uint amountToSend = (amountOut * adminAmount) / (totalAmount);
      tokenTransferFrom(WBNB, swapHelper, administrationWallet, amountToSend);
    }
    if (marketingAmount > 0) {
      uint amountToSend = (amountOut * marketingAmount) / (totalAmount);
      tokenTransferFrom(WBNB, swapHelper, marketingWallet, amountToSend);
    }

    accumulatedToPool = 0;
    accumulatedToAdmin = 0;
    accumulatedToMarketing = 0;
  }

  function splitFee(
    uint incomingFeeAmount,
    address sender,
    uint adminFee,
    uint poolFee,
    uint burnFee,
    uint marketingFee
  ) private {
    uint totalFee = adminFee + poolFee + burnFee + marketingFee;

    //Burn
    if (burnFee > 0) {
      uint burnAmount = (incomingFeeAmount * burnFee) / totalFee;
      _balances[address(this)] += burnAmount;
      _burn(address(this), burnAmount);
    }

    // Administrative distribution
    if (adminFee > 0) {
      accumulatedToAdmin += (incomingFeeAmount * adminFee) / totalFee;
      if (pausedSwapAdmin) {
        address wallet = administrationWallet;
        uint walletBalance = _balances[wallet] + accumulatedToAdmin;
        _balances[wallet] = walletBalance;
        emit Transfer(sender, wallet, accumulatedToAdmin);
        accumulatedToAdmin = 0;
      }
    }

    // Marketing distribution
    if (marketingFee > 0) {
      accumulatedToMarketing += (incomingFeeAmount * marketingFee) / totalFee;
      if (pausedSwapMarketing) {
        address wallet = marketingWallet;
        uint walletBalance = _balances[wallet] + accumulatedToMarketing;
        _balances[wallet] = walletBalance;
        emit Transfer(sender, wallet, accumulatedToMarketing);
        accumulatedToMarketing = 0;
      }
    }

    // Pool Distribution
    if (poolFee > 0) {
      accumulatedToPool += (incomingFeeAmount * poolFee) / totalFee;
      if (pausedSwapPool) {
        _balances[address(this)] += accumulatedToPool;
        emit Transfer(sender, address(this), accumulatedToPool);
        accumulatedToPool = 0;
      }
    }
  }

  function buyBackAndBurn(uint amount) external isAuthorized(3) {
    buyBack(amount, swapHelperAddress, liquidityPool, true);
  }

  function buyBackAndHold(uint amount, address receiver) external isAuthorized(3) {
    buyBack(amount, receiver, liquidityPool, false);
  }

  function buyBackAndLiquidity(uint amount, address receiver) external isAuthorized(3) {
    uint maxBalance = getTokenBalanceOf(WBNB, address(this));
    require(maxBalance >= amount, "Insufficient balance on contract");

    if (receiver == address(0)) receiver = address(this);

    address liquidityPair = liquidityPool;
    uint amountToSend = amount / 2;
    uint poolAmount = buyBack(amountToSend, swapHelperAddress, liquidityPool, false);

    (uint112 reserve0, uint112 reserve1) = getTokenReserves(liquidityPair);
    bool reversed = isReversed(liquidityPair, WBNB);
    if (reversed) {
      uint112 temp = reserve0;
      reserve0 = reserve1;
      reserve1 = temp;
    }
    uint amountA;
    uint amountB;
    {
      uint amountBOptimal = (amountToSend * reserve1) / reserve0;
      if (amountBOptimal <= poolAmount) {
        (amountA, amountB) = (amountToSend, amountBOptimal);
      } else {
        uint amountAOptimal = (poolAmount * reserve0) / reserve1;
        assert(amountAOptimal <= amountToSend);
        (amountA, amountB) = (amountAOptimal, poolAmount);
      }
    }
    tokenTransfer(WBNB, liquidityPair, amountA);

    require(_balances[swapHelperAddress] >= amountB, "Invalid SwapHelper Token Balance");
    _balances[liquidityPair] += amountB;
    _balances[swapHelperAddress] -= amountB;

    emit Transfer(swapHelperAddress, liquidityPair, amountB);
    IPancakePair(liquidityPair).mint(receiver);
  }

  function buyBack(
    uint amount,
    address wallet,
    address liquidityPair,
    bool burnTokens
  ) private returns (uint) {
    uint maxBalance = getTokenBalanceOf(WBNB, address(this));
    require(maxBalance >= amount, "Insufficient balance on contract");

    (uint112 reserve0, uint112 reserve1) = getTokenReserves(liquidityPair);
    bool reversed = isReversed(liquidityPair, address(this));

    if (reversed) {
      uint112 temp = reserve0;
      reserve0 = reserve1;
      reserve1 = temp;
    }
    tokenTransfer(WBNB, liquidityPair, amount);
    uint tokenAmount = getAmountOut(amount, reserve1, reserve0);
    if (!reversed) {
      swapToken(liquidityPair, tokenAmount, 0, wallet);
    } else {
      swapToken(liquidityPair, 0, tokenAmount, wallet);
    }
    if (wallet == swapHelperAddress && burnTokens) _burn(swapHelperAddress, tokenAmount);
    return tokenAmount;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)
// Modified version to provide _balances as internal instead private

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
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
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface PancakeFactory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface PancakeRouter {
  function factory() external pure returns (address);
}

interface IPancakePair {
  function mint(address to) external returns (uint liquidity);
}

// SPDX-License-Identifier: PROPRIETARY

pragma solidity 0.8.17;

import "./AttributeMap.sol";

contract GasHelper is AttributeMap {
  uint internal swapFee = 25;

  function setSwapFee(uint amount) external isAuthorized(1) {
    swapFee = amount;
  }

  function getAmountOut(
    uint amountIn,
    uint reserveIn,
    uint reserveOut
  ) internal view returns (uint amountOut) {
    require(amountIn > 0, "Insufficient amount in");
    require(reserveIn > 0 && reserveOut > 0, "Insufficient liquidity");
    uint amountInWithFee = amountIn * (10000 - swapFee);
    uint numerator = amountInWithFee * reserveOut;
    uint denominator = (reserveIn * 10000) + amountInWithFee;
    amountOut = numerator / denominator;
  }

  function isReversed(address pair, address tokenA) internal view returns (bool) {
    address token0;
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x0dfe168100000000000000000000000000000000000000000000000000000000)
      failed := iszero(staticcall(gas(), pair, emptyPointer, 0x04, emptyPointer, 0x20))
      token0 := mload(emptyPointer)
    }
    if (failed) revert("Unable to check tokens direction");
    return token0 != tokenA;
  }

  // gas optimization on transfer token
  function tokenTransfer(
    address token,
    address recipient,
    uint amount
  ) internal {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
      mstore(add(emptyPointer, 0x04), recipient)
      mstore(add(emptyPointer, 0x24), amount)
      failed := iszero(call(gas(), token, 0, emptyPointer, 0x44, 0, 0))
    }
    if (failed) revert("Unable to transfer token");
  }

  // gas optimization on transfer from token method
  function tokenTransferFrom(
    address token,
    address from,
    address recipient,
    uint amount
  ) internal {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
      mstore(add(emptyPointer, 0x04), from)
      mstore(add(emptyPointer, 0x24), recipient)
      mstore(add(emptyPointer, 0x44), amount)
      failed := iszero(call(gas(), token, 0, emptyPointer, 0x64, 0, 0))
    }
    if (failed) revert("Unable to transferFrom token");
  }

  // gas optimization on swap operation using a liquidity pool
  function swapToken(
    address pair,
    uint amount0Out,
    uint amount1Out,
    address receiver
  ) internal {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x022c0d9f00000000000000000000000000000000000000000000000000000000)
      mstore(add(emptyPointer, 0x04), amount0Out)
      mstore(add(emptyPointer, 0x24), amount1Out)
      mstore(add(emptyPointer, 0x44), receiver)
      mstore(add(emptyPointer, 0x64), 0x80)
      mstore(add(emptyPointer, 0x84), 0)
      failed := iszero(call(gas(), pair, 0, emptyPointer, 0xa4, 0, 0))
    }
    if (failed) revert("Unable to swap Pair");
  }

  // gas optimization on get balanceOf from BEP20 or ERC20 token
  function getTokenBalanceOf(address token, address holder) internal view returns (uint112 tokenBalance) {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x70a0823100000000000000000000000000000000000000000000000000000000)
      mstore(add(emptyPointer, 0x04), holder)
      failed := iszero(staticcall(gas(), token, emptyPointer, 0x24, emptyPointer, 0x40))
      tokenBalance := mload(emptyPointer)
    }
    if (failed) revert("Unable to get balance");
  }

  // gas optimization on get reserves from liquidity pool
  function getTokenReserves(address pairAddress) internal view returns (uint112 reserve0, uint112 reserve1) {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x0902f1ac00000000000000000000000000000000000000000000000000000000)
      failed := iszero(staticcall(gas(), pairAddress, emptyPointer, 0x4, emptyPointer, 0x40))
      reserve0 := mload(emptyPointer)
      reserve1 := mload(add(emptyPointer, 0x20))
    }
    if (failed) revert("Unable to get reserves from pair");
  }
}

// SPDX-License-Identifier: PROPRIETARY

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SwapHelper is Ownable {
  constructor() {}

  function safeApprove(
    address token,
    address spender,
    uint amount
  ) external onlyOwner {
    IERC20(token).approve(spender, amount);
  }

  function safeWithdraw() external onlyOwner {
    payable(_msgSender()).transfer(address(this).balance);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// SPDX-License-Identifier: PROPRIETARY

pragma solidity 0.8.17;

import "./Authorized.sol";

contract AttributeMap is Authorized {
  mapping(address => uint) internal _attributeMap;

  // ------------- Public Views -------------
  function isExemptFee(address target) public view returns (bool) {
    return checkMapAttribute(_attributeMap[target], 0);
  }

  function isExemptFeeReceiver(address target) public view returns (bool) {
    return checkMapAttribute(_attributeMap[target], 1);
  }

  function isExemptTxLimit(address target) public view returns (bool) {
    return checkMapAttribute(_attributeMap[target], 2);
  }

  function isExemptAmountLimit(address target) public view returns (bool) {
    return checkMapAttribute(_attributeMap[target], 3);
  }

  function isExemptSwapperMaker(address target) public view returns (bool) {
    return checkMapAttribute(_attributeMap[target], 4);
  }

  function isExemptOperatePausedToken(address target) public view returns (bool) {
    return checkMapAttribute(_attributeMap[target], 5);
  }

  function isSpecialFeeWallet(address target) public view returns (bool) {
    return checkMapAttribute(_attributeMap[target], 6);
  }

  function isSpecialFeeWalletReceiver(address target) public view returns (bool) {
    return checkMapAttribute(_attributeMap[target], 7);
  }

  // ------------- Internal PURE GET Functions -------------
  function checkMapAttribute(uint mapValue, uint8 shift) internal pure returns (bool) {
    return (mapValue >> shift) & 1 == 1;
  }

  function isExemptFee(uint mapValue) internal pure returns (bool) {
    return checkMapAttribute(mapValue, 0);
  }

  function isExemptFeeReceiver(uint mapValue) internal pure returns (bool) {
    return checkMapAttribute(mapValue, 1);
  }

  function isExemptTxLimit(uint mapValue) internal pure returns (bool) {
    return checkMapAttribute(mapValue, 2);
  }

  function isExemptAmountLimit(uint mapValue) internal pure returns (bool) {
    return checkMapAttribute(mapValue, 3);
  }

  function isExemptSwapperMaker(uint mapValue) internal pure returns (bool) {
    return checkMapAttribute(mapValue, 4);
  }

  function isExemptOperatePausedToken(uint mapValue) internal pure returns (bool) {
    return checkMapAttribute(mapValue, 5);
  }

  function isSpecialFeeWallet(uint mapValue) internal pure returns (bool) {
    return checkMapAttribute(mapValue, 6);
  }

  function isSpecialFeeWalletReceiver(uint mapValue) internal pure returns (bool) {
    return checkMapAttribute(mapValue, 7);
  }

  // ------------- Internal PURE SET Functions -------------
  function setMapAttribute(
    uint mapValue,
    uint8 shift,
    bool include
  ) internal pure returns (uint) {
    return include ? applyMapAttribute(mapValue, shift) : removeMapAttribute(mapValue, shift);
  }

  function applyMapAttribute(uint mapValue, uint8 shift) internal pure returns (uint) {
    return (1 << shift) | mapValue;
  }

  function removeMapAttribute(uint mapValue, uint8 shift) internal pure returns (uint) {
    return (1 << shift) ^ (type(uint).max & mapValue);
  }

  // ------------- Public Internal SET Functions -------------
  function setExemptFee(uint mapValue, bool operation) internal pure returns (uint) {
    return setMapAttribute(mapValue, 0, operation);
  }

  function setExemptFeeReceiver(uint mapValue, bool operation) internal pure returns (uint) {
    return setMapAttribute(mapValue, 1, operation);
  }

  function setExemptTxLimit(uint mapValue, bool operation) internal pure returns (uint) {
    return setMapAttribute(mapValue, 2, operation);
  }

  function setExemptAmountLimit(uint mapValue, bool operation) internal pure returns (uint) {
    return setMapAttribute(mapValue, 3, operation);
  }

  function setExemptSwapperMaker(uint mapValue, bool operation) internal pure returns (uint) {
    return setMapAttribute(mapValue, 4, operation);
  }

  function setExemptOperatePausedToken(uint mapValue, bool operation) internal pure returns (uint) {
    return setMapAttribute(mapValue, 5, operation);
  }

  function setSpecialFeeWallet(uint mapValue, bool operation) internal pure returns (uint) {
    return setMapAttribute(mapValue, 6, operation);
  }

  function setSpecialFeeWalletReceiver(uint mapValue, bool operation) internal pure returns (uint) {
    return setMapAttribute(mapValue, 7, operation);
  }

  // ------------- Public Authorized SET Functions -------------
  function setExemptFee(address target, bool operation) public isAuthorized(2) {
    _attributeMap[target] = setExemptFee(_attributeMap[target], operation);
  }

  function setExemptFeeReceiver(address target, bool operation) public isAuthorized(2) {
    _attributeMap[target] = setExemptFeeReceiver(_attributeMap[target], operation);
  }

  function setExemptTxLimit(address target, bool operation) public isAuthorized(2) {
    _attributeMap[target] = setExemptTxLimit(_attributeMap[target], operation);
  }

  function setExemptAmountLimit(address target, bool operation) public isAuthorized(2) {
    _attributeMap[target] = setExemptAmountLimit(_attributeMap[target], operation);
  }

  function setExemptSwapperMaker(address target, bool operation) public isAuthorized(2) {
    _attributeMap[target] = setExemptSwapperMaker(_attributeMap[target], operation);
  }

  function setExemptOperatePausedToken(address target, bool operation) public isAuthorized(2) {
    _attributeMap[target] = setExemptOperatePausedToken(_attributeMap[target], operation);
  }

  function setSpecialFeeWallet(address target, bool operation) public isAuthorized(2) {
    _attributeMap[target] = setSpecialFeeWallet(_attributeMap[target], operation);
  }

  function setSpecialFeeWalletReceiver(address target, bool operation) public isAuthorized(2) {
    _attributeMap[target] = setSpecialFeeWalletReceiver(_attributeMap[target], operation);
  }
}

// SPDX-License-Identifier: PROPRIETARY

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Authorized is Ownable {
  mapping(uint8 => mapping(address => bool)) public permissions;

  constructor() {}

  // 0 - Admin
  // 1 - Controller
  // 2 - Operator
  // 3 - Executer
  modifier isAuthorized(uint8 index) {
    if (!permissions[index][_msgSender()]) {
      revert("Account does not have permission");
    }
    _;
  }

  function getAllPermissions(address wallet) external view returns (bool[] memory results) {
    results = new bool[](4);
    for (uint8 i = 0; i < 4; i++) results[i] = permissions[i][wallet];
  }

  function safeApprove(
    address token,
    address spender,
    uint amount
  ) external isAuthorized(0) {
    IERC20(token).approve(spender, amount);
  }

  function safeTransfer(
    address token,
    address receiver,
    uint amount
  ) external isAuthorized(0) {
    IERC20(token).transfer(receiver, amount);
  }

  function safeWithdraw() external isAuthorized(0) {
    payable(_msgSender()).transfer(address(this).balance);
  }

  function grantPermission(address operator, uint8[] memory grantedPermissions) external isAuthorized(0) {
    for (uint8 i = 0; i < grantedPermissions.length; i++) permissions[grantedPermissions[i]][operator] = true;
  }

  function revokePermission(address operator, uint8[] memory revokedPermissions) external isAuthorized(0) {
    for (uint8 i = 0; i < revokedPermissions.length; i++) permissions[revokedPermissions[i]][operator] = false;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
}