// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "./ERC20.sol";
import "./IPancake.sol";
import "./GasHelper.sol";
import "./SwapHelper.sol";

contract MonkeynautsToken is GasHelper, ERC20 {
  address constant private DEAD = 0x000000000000000000000000000000000000dEaD;
  address constant private ZERO = 0x0000000000000000000000000000000000000000;
  address constant private WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // BSC WBNB

  string constant private _nameToken = "The Monkeynauts";
  string constant private _symbolToken = "SPC";

  string constant public url = "www.themonkeynauts.com";
  string constant public author = "Lameni";

  // Token Details
  uint8 constant private decimal = 18;
  uint256 constant private maxSupply = 200_000_000 * (10 ** decimal);

  // Wallets limits
  uint256 public _maxTxAmount = maxSupply;
  uint256 public _maxAccountAmount = maxSupply;
  uint256 public _minAmountToAutoSwap =  1000 * (10 ** decimal); // min amount stored before swap to collect fee

  // Fees
  uint256 public feeMarketingWallet = 0; // 0%
  uint256 public feeDevelopingWallet = 0; // 0%
  uint256 public feeLiquidityWallet = 0; // 0%
  uint256 public feeRewardWallet = 0; // 0%

  uint constant private maxTotalFee = 1600; // fee will never ever be higher than 16
  mapping(address => uint) public specialFeesByWallet;
  mapping(address => uint) public specialFeesByWalletReceiver;

  // Helpers
  bool internal pausedToken = false;
  bool private _noReentrance = false;

  bool public pausedSwapFee = false;

  // Counters
  uint256 public accumulatedToSwapFee;

  // Liquidity Pair
  address public liquidityPool;

  // Wallets
  address public marketingWallet;
  address public developingWallet;
  address public liquidityWallet;
  address public rewardWallet;
  address public swapHelperAddress;

  struct Receivers { address wallet; uint256 amount; }
  receive() external payable { }

  constructor()ERC20(_nameToken, _symbolToken) {
    PancakeRouter router = PancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // BSC
    liquidityPool = address(PancakeFactory(router.factory()).createPair(WBNB, address(this)));

    marketingWallet = 0x1913EF908e7FFf353ca9D9D110A295d319bf40dA;
    _permissions[marketingWallet] = 15; // exempt fee, fee receiver, tx limit and wallet limit
    developingWallet = 0xeE393b43588a4b190478309d29eD4Da2A105F3c5;
    _permissions[developingWallet] = 15; // exempt fee, fee receiver, tx limit and wallet limit
    liquidityWallet = 0x7Bc207c7490637c230fF7b473488dCDb66Ba3cA4;
    _permissions[liquidityWallet] = 15; // exempt fee, fee receiver, tx limit and wallet limit
    rewardWallet = 0x6538435b1fAA2B2b67ae19d472024275b4B722F6;
    _permissions[rewardWallet] = 15; // exempt fee, fee receiver, tx limit and wallet limit

    uint baseAttributes = 0;
    baseAttributes = setExemptAmountLimit(baseAttributes, true);
    baseAttributes = setSpecialFeeWallet(baseAttributes, true);
    baseAttributes = setSpecialFeeWalletReceiver(baseAttributes, true);
    _attributeMap[liquidityPool] = baseAttributes;

    setSpecialWalletFee(liquidityPool, true, 200, 300, 100, 100);
    setSpecialWalletFee(liquidityPool, false, 200, 300, 100, 400);

    baseAttributes = setSpecialFeeWallet(baseAttributes, false);
    baseAttributes = setSpecialFeeWalletReceiver(baseAttributes, false);

    baseAttributes = setExemptTxLimit(baseAttributes, true);
    _attributeMap[DEAD] = baseAttributes;
    _attributeMap[ZERO] = baseAttributes;

    baseAttributes = setExemptFee(baseAttributes, true);
    baseAttributes = setExemptSwapMaker(baseAttributes, true);
    _attributeMap[address(this)] = baseAttributes;

    baseAttributes = setExemptOperatePausedToken(baseAttributes, true);
    _attributeMap[_msgSender()] = baseAttributes;

    SwapHelper swapHelper = new SwapHelper();
    swapHelper.safeApprove(WBNB, address(this), type(uint256).max);
    swapHelper.transferOwnership(_msgSender());
    swapHelperAddress = address(swapHelper);

    baseAttributes = setExemptOperatePausedToken(baseAttributes, false);
    _attributeMap[swapHelperAddress] = baseAttributes;

    _mint(_msgSender(), maxSupply);

    pausedToken = true;
  }

  // ----------------- Public Views -----------------
  function name() public pure override returns (string memory) { return _nameToken; }
  function symbol() public pure override returns (string memory) { return _symbolToken; }
  function getOwner() external view returns (address) { return owner(); }
  function decimals() public pure override returns (uint8) { return decimal; }
  function getFeeTotal() public view returns(uint256) { return feeMarketingWallet + feeDevelopingWallet + feeLiquidityWallet + feeRewardWallet; }
  function getSpecialWalletFee(address target, bool isSender) public view returns(uint marketingFee, uint developingFee, uint liquidityFee, uint rewardFee ) {
    uint composedValue = isSender ? specialFeesByWallet[target] : specialFeesByWalletReceiver[target];
    marketingFee = composedValue % 1e4;
    composedValue = composedValue / 1e4;
    developingFee = composedValue % 1e4;
    composedValue = composedValue / 1e4;
    liquidityFee = composedValue % 1e4;
    composedValue = composedValue / 1e4;
    rewardFee = composedValue % 1e4;
  }

  // ----------------- Authorized Methods -----------------

  function enableToken() external isAdmin { pausedToken = false; }
  function setLiquidityPool(address newPair) external isAdmin {
    require(newPair != address(0), "invalid new pair address");
    liquidityPool = newPair;
  }
  function setPausedSwapFee(bool state) external isAdmin { pausedSwapFee = state; }

  // ----------------- Wallets Settings -----------------
  function setMarketingWallet(address account) public isAdmin {
    require(account != address(0), "marketingWallet cannot be Zero");
    marketingWallet = account;
  }

  function setDevelopingWallet(address account) public isAdmin {
    require(account != address(0), "developingWallet cannot be Zero");
    developingWallet = account;
  }

  function setLiquidityWallet(address account) public isAdmin {
    require(account != address(0), "liquidityWallet cannot be Zero");
    liquidityWallet = account;
  }

  function setRewardWallet(address account) public isAdmin {
    require(account != address(0), "rewardWallet cannot be Zero");
    rewardWallet = account;
  }

  // ----------------- Fee Settings -----------------
  function setFeesOperational(uint marketing, uint developing, uint liquidity, uint reward) public isFinancial {
    feeMarketingWallet = marketing;
    feeDevelopingWallet = developing;
    feeLiquidityWallet = liquidity;
    feeRewardWallet = reward;
    require(getFeeTotal() <= maxTotalFee, "All rates and fee together must be equal or lower than 16%");
  }

  function setSpecialWalletFee(address target, bool isSender, uint marketing, uint developing, uint liquidity, uint reward) public isFinancial {
    require(marketing + developing + liquidity + reward <= maxTotalFee, "All rates and fee together must be equal or lower than 16%");
    uint composedValue = marketing + (developing * 1e4) + (liquidity * 1e8) + (reward * 1e12);
    if (isSender) {
      specialFeesByWallet[target] = composedValue;
    } else {
      specialFeesByWalletReceiver[target] = composedValue;
    }
  }

  // ----------------- Token Flow Settings -----------------
  function setMaxTxAmount(uint256 maxTxAmount) public isFinancial {
    require(maxTxAmount >= maxSupply / 10000, "Amount must be bigger then 0.01% tokens"); // 10000 tokens
    _maxTxAmount = maxTxAmount;
  }

  function setMaxAccountAmount(uint256 maxAccountAmount) public isFinancial {
    require(maxAccountAmount >= maxSupply / 10000, "Amount must be bigger then 0.01% tokens"); // 10000 tokens
    _maxAccountAmount = maxAccountAmount;
  }
  function setMinAmountToAutoSwap(uint256 amount) public isFinancial {
    _minAmountToAutoSwap = amount;
  }

  // ----------------- Special Authorized Operations -----------------
  function buyBackAndHoldWithDecimals(uint256 decimalAmount, address receiver) public isController { buyBackWithDecimals(decimalAmount, receiver); }
  function buyBackAndBurnWithDecimals(uint256 decimalAmount) public isController { buyBackWithDecimals(decimalAmount, address(0)); }

  // ----------------- External Methods -----------------
  function burn(uint256 amount) external { _burn(_msgSender(), amount); }

  function multiTransfer(Receivers[] memory users) external {
    for ( uint i = 0; i < users.length; i++ ) transfer(users[i].wallet, users[i].amount);
  }

  // ----------------- Internal CORE -----------------
  function _transfer( address sender, address receiver,uint256 amount) internal override {
    require(amount > 0, "Invalid Amount");
    require(!_noReentrance, "ReentranceGuard Alert");
    _noReentrance = true;

    uint senderAttributes = _attributeMap[sender];
    uint receiverAttributes = _attributeMap[receiver];
    // Initial Checks
    require(sender != address(0) && receiver != address(0), "transfer from the zero address");
    require(!pausedToken || isExemptOperatePausedToken(senderAttributes), "Token is paused");
    require(amount <= _maxTxAmount || isExemptTxLimit(senderAttributes), "Exceeded the maximum transaction limit");

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "Transfer amount exceeds your balance");
    uint256 newSenderBalance = senderBalance - amount;
    _balances[sender] = newSenderBalance;


    uint marketingFee = feeMarketingWallet;
    uint developingFee = feeDevelopingWallet;
    uint liquidityFee = feeLiquidityWallet;
    uint rewardFee = feeRewardWallet;

    // Calculate Fees
    uint256 feeAmount = 0;
    if(!isExemptFee(senderAttributes) && !isExemptFeeReceiver(receiverAttributes)) {
      if(isSpecialFeeWallet(senderAttributes)) { // Check special wallet fee on sender
        (marketingFee, developingFee, liquidityFee, rewardFee) = getSpecialWalletFee(sender, true);
      } else if(isSpecialFeeWalletReceiver(receiverAttributes)) { // Check special wallet fee on receiver
        (marketingFee, developingFee, liquidityFee, rewardFee) = getSpecialWalletFee(receiver, false);
      }
      feeAmount = ((marketingFee + developingFee + liquidityFee + rewardFee) * amount) / 10000;
    }

    if (feeAmount != 0) splitFee(feeAmount, sender, marketingFee, developingFee, liquidityFee, rewardFee);
    if ((!pausedSwapFee) && !isExemptSwapMaker(senderAttributes)) autoSwap(sender, marketingFee, developingFee, liquidityFee, rewardFee);

    // Update Recipient Balance
    uint256 newRecipientBalance = _balances[receiver] + (amount - feeAmount);
    _balances[receiver] = newRecipientBalance;
    require(newRecipientBalance <= _maxAccountAmount || isExemptAmountLimit(receiverAttributes), "Exceeded the maximum tokens an wallet can hold");

    _noReentrance = false;
    emit Transfer(sender, receiver, amount);
  }

  function autoSwap(address sender, uint marketingFee, uint developingFee, uint liquidityFee, uint rewardFee) private {
    // --------------------- Execute Auto Swap -------------------------
    address liquidityPair = liquidityPool;
    if (sender == liquidityPair) return;

    uint totalAmount = accumulatedToSwapFee;
    if (totalAmount < _minAmountToAutoSwap) return;

    // Execute auto swap
    address wbnbAddress = WBNB;
    address swapHelper = swapHelperAddress;
    uint256 wbnbBalanceNew = 0;

    {
      (uint112 reserve0, uint112 reserve1) = getTokenReserves(liquidityPair);
      bool reversed = isReversed(liquidityPair, wbnbAddress);
      if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }
      _balances[liquidityPair] += totalAmount;

      uint256 wbnbBalanceBefore = getTokenBalanceOf(wbnbAddress, swapHelper);
      uint256 wbnbAmount = getAmountOut(totalAmount, reserve1, reserve0);
      swapToken(liquidityPair, reversed ? 0 : wbnbAmount, reversed ? wbnbAmount : 0, swapHelper);
      wbnbBalanceNew = getTokenBalanceOf(wbnbAddress, swapHelper);
      require(wbnbBalanceNew == wbnbBalanceBefore + wbnbAmount, "Wrong amount of swapped on WBNB");
    }

    // --------------------- Transfer Swapped Amount -------------------------
    uint totalFee = marketingFee + developingFee + liquidityFee + rewardFee;
    if (marketingFee > 0) { // Cost 2 cents
      uint amountToSend = (wbnbBalanceNew * marketingFee) / (totalFee);
      tokenTransferFrom(wbnbAddress, swapHelper, marketingWallet, amountToSend);
    }
    if (developingFee > 0) { // Cost 2 cents
      uint amountToSend = (wbnbBalanceNew * developingFee) / (totalFee);
      tokenTransferFrom(wbnbAddress, swapHelper, developingWallet, amountToSend);
    }
    if (liquidityFee > 0) { // Cost 2 cents
      uint amountToSend = (wbnbBalanceNew * liquidityFee) / (totalFee);
      tokenTransferFrom(wbnbAddress, swapHelper, liquidityWallet, amountToSend);
    }
    if (rewardFee > 0) { // Cost 2 cents
      uint amountToSend = (wbnbBalanceNew * rewardFee) / (totalFee);
      tokenTransferFrom(wbnbAddress, swapHelper, rewardWallet, amountToSend);
    }
    accumulatedToSwapFee = 0;
  }

  function splitFee(uint256 incomingFeeTokenAmount, address sender, uint marketingFee, uint developingFee, uint liquidityFee, uint rewardFee) private {
    uint256 totalFee = marketingFee + developingFee + liquidityFee + rewardFee;

    accumulatedToSwapFee += incomingFeeTokenAmount;
    if (pausedSwapFee) {
      if (marketingFee > 0) {
        address wallet = marketingWallet;
        uint accumulated = (accumulatedToSwapFee * marketingFee) / totalFee;
        uint256 walletBalance = _balances[wallet] + accumulated;
        _balances[wallet] = walletBalance;
        emit Transfer(sender, wallet, accumulated);
      }
      if (developingFee > 0) {
        address wallet = developingWallet;
        uint accumulated = (accumulatedToSwapFee * developingFee) / totalFee;
        uint256 walletBalance = _balances[wallet] + accumulated;
        _balances[wallet] = walletBalance;
        emit Transfer(sender, wallet, accumulated);
      }
      if (liquidityFee > 0) {
        address wallet = liquidityWallet;
        uint accumulated = (accumulatedToSwapFee * liquidityFee) / totalFee;
        uint256 walletBalance = _balances[wallet] + accumulated;
        _balances[wallet] = walletBalance;
        emit Transfer(sender, wallet, accumulated);
      }
      if (rewardFee > 0) {
        address wallet = rewardWallet;
        uint accumulated = (accumulatedToSwapFee * rewardFee) / totalFee;
        uint256 walletBalance = _balances[wallet] + accumulated;
        _balances[wallet] = walletBalance;
        emit Transfer(sender, wallet, accumulated);
      }
      accumulatedToSwapFee = 0;
    }
  }

  // --------------------- Private Methods -------------------------

  function buyBackWithDecimals(uint256 decimalAmount, address destAddress) private {
    uint256 maxBalance = getTokenBalanceOf(WBNB, address(this));
    if (maxBalance < decimalAmount) revert("insufficient WBNB amount on contract");

    address liquidityPair = liquidityPool;
    uint liquidityAttribute = _attributeMap[liquidityPair];

    uint newAttributes = setExemptTxLimit(liquidityAttribute, true);
    newAttributes = setExemptFee(liquidityAttribute, true);
    _attributeMap[liquidityPair] = newAttributes;

    address helperAddress = swapHelperAddress;

    (uint112 reserve0, uint112 reserve1) = getTokenReserves(liquidityPair);
    bool reversed = isReversed(liquidityPair, WBNB);
    if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }

    tokenTransfer(WBNB, liquidityPair, decimalAmount);

    uint256 tokenAmount = getAmountOut(decimalAmount, reserve0, reserve1);
    if (destAddress == address(0)) {
      swapToken(liquidityPair, reversed ? tokenAmount : 0, reversed ? 0 : tokenAmount, helperAddress);
      _burn(helperAddress, tokenAmount);
    } else {
      swapToken(liquidityPair, reversed ? tokenAmount : 0, reversed ? 0 : tokenAmount, destAddress);
    }
    _attributeMap[liquidityPair] = liquidityAttribute;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)
// Modified version to provide _balances as internal instead private

pragma solidity 0.8.13;

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

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;
interface PancakeFactory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface PancakeRouter {
  function factory() external pure returns (address);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "./AttributeMap.sol";

contract GasHelper is AttributeMap {
  uint internal swapFee = 25;

  function setSwapFee(uint amount) external isAdmin { swapFee = amount; }

  function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal view returns (uint256 amountOut) {
    require(amountIn > 0, 'Insufficient amount in');
    require(reserveIn > 0 && reserveOut > 0, 'Insufficient liquidity');
    uint256 amountInWithFee = amountIn * (10000 - swapFee);
    uint256 numerator = amountInWithFee  * reserveOut;
    uint256 denominator = (reserveIn * 10000) + amountInWithFee;
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
  function tokenTransfer(address token, address recipient, uint256 amount) internal {
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
  function tokenTransferFrom(address token, address from, address recipient, uint256 amount) internal {
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
  function swapToken(address pair, uint amount0Out, uint amount1Out, address receiver) internal {
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

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SwapHelper is Ownable {
  constructor() {}

  function safeApprove(address token, address spender, uint256 amount) external onlyOwner { IERC20(token).approve(spender, amount); }

  function safeWithdraw() external onlyOwner { payable(_msgSender()).transfer(address(this).balance); }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "./Authorized.sol";

contract AttributeMap is Authorized {

  mapping (address => uint) internal _attributeMap;

  // ------------- Public Views -------------
  function isExemptFee(address target) public view returns(bool) { return checkMapAttribute(_attributeMap[target], 0); }
  function isExemptFeeReceiver(address target) public view returns(bool) { return checkMapAttribute(_attributeMap[target], 1); }
  function isExemptTxLimit(address target) public view returns(bool) { return checkMapAttribute(_attributeMap[target], 2); }
  function isExemptAmountLimit(address target) public view returns(bool) { return checkMapAttribute(_attributeMap[target], 3); }
  function isExemptOperatePausedToken(address target) public view returns(bool) { return checkMapAttribute(_attributeMap[target], 4); }
  function isSpecialFeeWallet(address target) public view returns(bool) { return checkMapAttribute(_attributeMap[target], 5); }
  function isSpecialFeeWalletReceiver(address target) public view returns(bool) { return checkMapAttribute(_attributeMap[target], 6); }
  function isExemptSwapMaker(address target) public view returns(bool) { return checkMapAttribute(_attributeMap[target], 7); }

  // ------------- Internal PURE GET Functions -------------
  function isExemptFee(uint mapValue) internal pure returns(bool) { return checkMapAttribute(mapValue, 0); }
  function isExemptFeeReceiver(uint mapValue) internal pure returns(bool) { return checkMapAttribute(mapValue, 1); }
  function isExemptTxLimit(uint mapValue) internal pure returns(bool) { return checkMapAttribute(mapValue, 2); }
  function isExemptAmountLimit(uint mapValue) internal pure returns(bool) { return checkMapAttribute(mapValue, 3); }
  function isExemptOperatePausedToken(uint mapValue) internal pure returns(bool) { return checkMapAttribute(mapValue, 4); }
  function isSpecialFeeWallet(uint mapValue) internal pure returns(bool) { return checkMapAttribute(mapValue, 5); }
  function isSpecialFeeWalletReceiver(uint mapValue) internal pure returns(bool) { return checkMapAttribute(mapValue, 6); }
  function isExemptSwapMaker(uint mapValue) internal pure returns(bool) { return checkMapAttribute(mapValue, 7); }

  // ------------- Public Internal SET Functions -------------
  function setExemptFee(uint mapValue, bool operation) internal pure returns(uint) { return setMapAttribute(mapValue, 0, operation); }
  function setExemptFeeReceiver(uint mapValue, bool operation) internal pure returns(uint) { return setMapAttribute(mapValue, 1, operation); }
  function setExemptTxLimit(uint mapValue, bool operation) internal pure returns(uint) { return setMapAttribute(mapValue, 2, operation); }
  function setExemptAmountLimit(uint mapValue, bool operation) internal pure returns(uint) { return setMapAttribute(mapValue, 3, operation); }
  function setExemptOperatePausedToken(uint mapValue, bool operation) internal pure returns(uint) { return setMapAttribute(mapValue, 4, operation); }
  function setSpecialFeeWallet(uint mapValue, bool operation) internal pure returns(uint) { return setMapAttribute(mapValue, 5, operation); }
  function setSpecialFeeWalletReceiver(uint mapValue, bool operation) internal pure returns(uint) { return setMapAttribute(mapValue, 6, operation); }
  function setExemptSwapMaker(uint mapValue, bool operation) internal pure returns(uint) { return setMapAttribute(mapValue, 7, operation); }


  // ------------- Public Authorized SET Functions -------------
  function setExemptFee(address target, bool operation) public isFinancial { _attributeMap[target] = setExemptFee(_attributeMap[target], operation); }
  function setExemptFeeReceiver(address target, bool operation) public isFinancial { _attributeMap[target] = setExemptFeeReceiver(_attributeMap[target], operation); }
  function setExemptTxLimit(address target, bool operation) public isFinancial { _attributeMap[target] = setExemptTxLimit(_attributeMap[target], operation); }
  function setExemptAmountLimit(address target, bool operation) public isFinancial { _attributeMap[target] = setExemptAmountLimit(_attributeMap[target], operation); }
  function setExemptOperatePausedToken(address target, bool operation) public isFinancial { _attributeMap[target] = setExemptOperatePausedToken(_attributeMap[target], operation); }
  function setSpecialFeeWallet(address target, bool operation) public isFinancial { _attributeMap[target] = setSpecialFeeWallet(_attributeMap[target], operation); }
  function setSpecialFeeWalletReceiver(address target, bool operation) public isFinancial { _attributeMap[target] = setSpecialFeeWalletReceiver(_attributeMap[target], operation); }
  function setExemptSwapMaker(address target, bool operation) public isFinancial { _attributeMap[target] = setExemptSwapMaker(_attributeMap[target], operation); }


}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Authorized is Ownable {
  mapping(address => uint) internal _permissions;

  function safeApprove(address token, address spender, uint256 amount) external isAdmin { IERC20(token).approve(spender, amount); }
  function safeTransfer(address token, address receiver, uint256 amount) external isAdmin { IERC20(token).transfer(receiver, amount); }
  function safeWithdraw() external isAdmin { payable(_msgSender()).transfer(address(this).balance); }

  function setPermission(address wallet, uint8 typeIndex, bool state) external isAdmin { _permissions[wallet] = setMapAttribute(_permissions[wallet], typeIndex, state); }
  function checkMapAttribute(uint mapValue, uint8 shift) internal pure returns(bool) { return mapValue >> shift & 1 == 1; }
  function setMapAttribute(uint mapValue, uint8 shift, bool include) internal pure returns(uint) { return include ? 1 << shift | mapValue : 1 << shift ^ type(uint).max & mapValue; }
  function hasPermission(address wallet, uint8 typeIndex) external view returns(bool) { return checkMapAttribute(_permissions[wallet], typeIndex) || owner() == msg.sender; }
  function checkPermission(uint8 typeIndex) private view { require(checkMapAttribute(_permissions[msg.sender], typeIndex) || owner() == msg.sender, "Wallet does not have permission"); }

  modifier isAdmin { checkPermission(0); _; }
  modifier isFinancial { checkPermission(1); _; }
  modifier isController { checkPermission(2); _; }
  modifier isUpdater { checkPermission(3); _; }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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