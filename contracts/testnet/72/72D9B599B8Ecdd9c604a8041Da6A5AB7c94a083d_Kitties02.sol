//SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import './kitties-V0.9imports.sol';

abstract contract Tokenomics {
  // --------------------- Token Settings ------------------- //

  string internal constant NAME = 'Kitties-v02';
  string internal constant SYMBOL = 'KTT-02';

  uint16 internal constant FEES_DIVISOR = 10**3;
  uint8 internal constant DECIMALS = 9;
  uint256 internal constant ZEROES = 10**DECIMALS;

  uint256 private constant MAX = ~uint256(0);
  uint256 internal constant TOTAL_SUPPLY = 1000000 * ZEROES; //1m for testnet which is 100m(mainnet)/100 so 0.2bnb for lp is equivalent for 20bnb on mainnet
  uint256 internal _reflectedSupply = (MAX - (MAX % TOTAL_SUPPLY));

  /**
   * @dev Set the maximum transaction amount allowed in a transfer.
   */
  uint256 internal constant maxTransactionAmount = TOTAL_SUPPLY / 200; // 0.5% of the total supply (150,000)

  /**
   * @dev Set the number of tokens to swap and add to liquidity.
   *
   * Whenever the contract's balance reaches 1000 Kitties the swap & liquify will be
   * executed in the very next transfer.
   *
   */
  uint256 internal constant numberOfTokensToSwapToLiquidity = TOTAL_SUPPLY / 1000; // 0.1% of the total supply

  // --------------------- Fees Settings ------------------- //

  address internal burnAddress = 0x000000000000000000000000000000000000dEaD;

  enum FeeType {
    Rfi,
    Burn,
    External
  }

  struct Fee {
    uint256 position;
    FeeType name;
    uint256 value;
    address recipient;
    uint256 total;
  }

  //Transfer fee
  Fee[] internal transferFees;
  uint256 public transferSumOfFees;
  //Buy fee
  Fee[] internal buyFees;
  uint256 public buySumOfFees;
  //Sell fee
  Fee[] internal sellFees;
  uint256 public sellSumOfFees;

  //indicates the type of the transfer
  enum TransferType {
    Transfer,
    Sell,
    Buy
  }
  TransferType internal _transferType;
  //used in _transferTokens()
  uint256 internal sumOfFees;

  constructor() {
    _addFees();
  }

  function _addTransferFee(
    uint256 position,
    FeeType name,
    uint256 value,
    address recipient
  ) private {
    transferFees.push(Fee(position, name, value, recipient, 0));
    transferSumOfFees += value;
  }

  function _addSellFee(
    uint256 position,
    FeeType name,
    uint256 value,
    address recipient
  ) private {
    sellFees.push(Fee(position, name, value, recipient, 0));
    sellSumOfFees += value;
  }

  function _addBuyFee(
    uint256 position,
    FeeType name,
    uint256 value,
    address recipient
  ) private {
    buyFees.push(Fee(position, name, value, recipient, 0));
    buySumOfFees += value;
  }

  function _addFees() private {
    /**
     * The value of fees is given in part per 1000 (based on the value of FEES_DIVISOR),
     * e.g. for 5% use 50, for 3.5% use 35, etc.
     */
    _addTransferFee(1, FeeType.External, 0, address(this));
    _addTransferFee(2, FeeType.Rfi, 0, address(this));
    _addTransferFee(3, FeeType.Burn, 0, burnAddress);

    _addSellFee(1, FeeType.External, 160, address(this));
    _addSellFee(2, FeeType.Rfi, 0, address(this));
    _addSellFee(3, FeeType.Burn, 0, burnAddress);

    _addBuyFee(1, FeeType.External, 100, address(this));
    _addBuyFee(2, FeeType.Rfi, 60, address(this));
    _addBuyFee(3, FeeType.Burn, 0, burnAddress);
  }

  /**
   *  Here "transferFees" length is same for all fee arrays so returning just one is sufficient enough
   */
  function _getFeesCount() internal view returns (uint256) {
    return transferFees.length;
  }

  function _getTransferFeeStruct(uint256 index) private view returns (Fee storage) {
    require(index >= 0 && index < transferFees.length, 'FeesSettings._getFeeStruct: Fee index out of bounds');
    return transferFees[index];
  }

  function _getBuyFeeStruct(uint256 index) private view returns (Fee storage) {
    require(index >= 0 && index < sellFees.length, 'FeesSettings._getFeeStruct: Fee index out of bounds');
    return buyFees[index];
  }

  function _getSellFeeStruct(uint256 index) private view returns (Fee storage) {
    require(index >= 0 && index < buyFees.length, 'FeesSettings._getFeeStruct: Fee index out of bounds');
    return sellFees[index];
  }

  function _getFee(uint256 index)
    internal
    view
    returns (
      uint256,
      FeeType,
      uint256,
      address,
      uint256
    )
  {
    if (_transferType == TransferType.Transfer) {
      Fee memory fee = _getTransferFeeStruct(index);

      return (fee.position, fee.name, fee.value, fee.recipient, fee.total);
    } else if (_transferType == TransferType.Sell) {
      Fee memory fee = _getSellFeeStruct(index);

      return (fee.position, fee.name, fee.value, fee.recipient, fee.total);
    } else {
      Fee memory fee = _getBuyFeeStruct(index);

      return (fee.position, fee.name, fee.value, fee.recipient, fee.total);
    }
  }

  function _addFeeCollectedAmount(uint256 index, uint256 amount) internal {
    if (_transferType == TransferType.Transfer) {
      Fee storage transferFee = _getTransferFeeStruct(index);

      transferFee.total = transferFee.total + amount;
    } else if (_transferType == TransferType.Sell) {
      Fee storage sellFee = _getSellFeeStruct(index);

      sellFee.total = sellFee.total = amount;
    } else {
      Fee storage buyFee = _getBuyFeeStruct(index);

      buyFee.total = buyFee.total = amount;
    }
  }

  // TODO us this implement this function. For now nobody calls this function
  function getCollectedFeeTotal(uint256 index)
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    Fee memory transferFee = _getTransferFeeStruct(index);
    Fee memory sellFee = _getSellFeeStruct(index);
    Fee memory buyFee = _getBuyFeeStruct(index);

    return (transferFee.total, sellFee.total, buyFee.total);
  }

  function displayTransferFees(uint256 index)
    external
    view
    returns (
      uint256,
      FeeType,
      uint256,
      address,
      uint256
    )
  {
    Fee memory transferFee = _getTransferFeeStruct(index);

    return (transferFee.position, transferFee.name, transferFee.value, transferFee.recipient, transferFee.total);
  }

  function displaySellFees(uint256 index)
    external
    view
    returns (
      uint256,
      FeeType,
      uint256,
      address,
      uint256
    )
  {
    Fee memory sellFee = _getSellFeeStruct(index);

    return (sellFee.position, sellFee.name, sellFee.value, sellFee.recipient, sellFee.total);
  }

  function displayBuyFees(uint256 index)
    external
    view
    returns (
      uint256,
      FeeType,
      uint256,
      address,
      uint256
    )
  {
    Fee memory buyFee = _getBuyFeeStruct(index);
    return (buyFee.position, buyFee.name, buyFee.value, buyFee.recipient, buyFee.total);
  }
}

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////BaseRfiToken START HERE////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

abstract contract BaseRfiToken is IERC20, IERC20Metadata, Ownable, Pausable, Tokenomics {
  using Address for address;

  mapping(address => uint256) internal _reflectedBalances;
  mapping(address => uint256) internal _balances;
  mapping(address => mapping(address => uint256)) internal _allowances;

  mapping(address => bool) internal _isExcludedFromFee;
  mapping(address => bool) internal _isExcludedFromRewards;
  address[] private _excluded;
  bool private _paused;

  constructor() {
    _reflectedBalances[owner()] = _reflectedSupply;

    // exclude owner and this contract from fee
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;

    // exclude the owner and this contract from rewards
    _exclude(owner());
    _exclude(address(this));

    emit Transfer(address(0), owner(), TOTAL_SUPPLY);
  }

  /** Functions required by IERC20Metadat **/
  function name() external pure override returns (string memory) {
    return NAME;
  }

  function symbol() external pure override returns (string memory) {
    return SYMBOL;
  }

  function decimals() external pure override returns (uint8) {
    return DECIMALS;
  }

  /** Functions required by IERC20Metadat - END **/
  /** Functions required by IERC20 **/
  function totalSupply() external pure override returns (uint256) {
    return TOTAL_SUPPLY;
  }

  function balanceOf(address account) public view override returns (uint256) {
    if (_isExcludedFromRewards[account]) return _balances[account];
    return tokenFromReflection(_reflectedBalances[account]);
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
    return true;
  }

  /** Functions required by IERC20 - END **/

  /**
   * @dev this is really a "soft" burn (total supply is not reduced). RFI holders
   * get two benefits from burning tokens:
   *
   * 1) Tokens in the burn address increase the % of tokens held by holders not
   *    excluded from rewards (assuming the burn address is excluded)
   * 2) Tokens in the burn address cannot be sold (which in turn draing the
   *    liquidity pool)
   *
   *
   * In RFI holders already get % of each transaction so the value of their tokens
   * increases (in a way). Therefore there is really no need to do a "hard" burn
   * (reduce the total supply). What matters (in RFI) is to make sure that a large
   * amount of tokens cannot be sold = draining the liquidity pool = lowering the
   * value of tokens holders own. For this purpose, transfering tokens to a (vanity)
   * burn address is the most appropriate way to "burn".
   *
   * There is an extra check placed into the `transfer` function to make sure the
   * burn address cannot withdraw the tokens is has (although the chance of someone
   * having/finding the private key is virtually zero).
   */
  function burn(uint256 amount) external {
    address sender = _msgSender();
    require(sender != address(0), 'BaseRfiToken: burn from the zero address');
    require(sender != address(burnAddress), 'BaseRfiToken: burn from the burn address');

    uint256 balance = balanceOf(sender);
    require(balance >= amount, 'BaseRfiToken: burn amount exceeds balance');

    uint256 reflectedAmount = amount * _getCurrentRate();

    // remove the amount from the sender's balance first
    _reflectedBalances[sender] = _reflectedBalances[sender] - reflectedAmount;
    if (_isExcludedFromRewards[sender]) _balances[sender] = _balances[sender] - amount;

    _burnTokens(sender, amount, reflectedAmount);
  }

  /**
   * @dev "Soft" burns the specified amount of tokens by sending them
   * to the burn address
   */
  function _burnTokens(
    address sender,
    uint256 tBurn,
    uint256 rBurn
  ) internal {
    /**
     * @dev Do not reduce _totalSupply and/or _reflectedSupply. (soft) burning by sending
     * tokens to the burn address (which should be excluded from rewards) is sufficient
     * in RFI
     */
    _reflectedBalances[burnAddress] = _reflectedBalances[burnAddress] + rBurn;
    if (_isExcludedFromRewards[burnAddress]) _balances[burnAddress] = _balances[burnAddress] + tBurn;

    /**
     * @dev Emit the event so that the burn address balance is updated (on bscscan)
     */
    emit Transfer(sender, burnAddress, tBurn);
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
    return true;
  }

  function isExcludedFromReward(address account) external view returns (bool) {
    return _isExcludedFromRewards[account];
  }

  /**
   * @dev Calculates and returns the reflected amount for the given amount with or without
   * the transfer fees (deductTransferFee true/false)
   */
  function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    require(tAmount <= TOTAL_SUPPLY, 'Amount must be less than supply');
    if (!deductTransferFee) {
      (uint256 rAmountTransfer, , , , ) = _getValues(tAmount, 0);
      (uint256 rAmountSell, , , , ) = _getValues(tAmount, 0);
      (uint256 rAmountBuy, , , , ) = _getValues(tAmount, 0);

      return (rAmountTransfer, rAmountSell, rAmountBuy);
    } else {
      (, uint256 rTransferAmountTransfer, , , ) = _getValues(tAmount, _getTransferSumOfFees());
      (, uint256 rTransferAmountSell, , , ) = _getValues(tAmount, _getSellSumOfFees());
      (, uint256 rTransferAmountBuy, , , ) = _getValues(tAmount, _getBuySumOfFees());

      return (rTransferAmountTransfer, rTransferAmountSell, rTransferAmountBuy);
    }
  }

  /**
   * @dev Calculates and returns the amount of tokens corresponding to the given reflected amount.
   */
  function tokenFromReflection(uint256 rAmount) internal view returns (uint256) {
    require(rAmount <= _reflectedSupply, 'Amount must be less than total reflections');
    uint256 currentRate = _getCurrentRate();
    return rAmount / currentRate;
  }

  function excludeFromReward(address account) external onlyOwner {
    require(!_isExcludedFromRewards[account], 'Account is not included');
    _exclude(account);
  }

  function _exclude(address account) internal {
    if (_reflectedBalances[account] > 0) {
      _balances[account] = tokenFromReflection(_reflectedBalances[account]);
    }
    _isExcludedFromRewards[account] = true;
    _excluded.push(account);
  }

  function includeInReward(address account) external onlyOwner {
    require(_isExcludedFromRewards[account], 'Account is not excluded');
    for (uint256 i = 0; i < _excluded.length; i++) {
      if (_excluded[i] == account) {
        _excluded[i] = _excluded[_excluded.length - 1];
        _balances[account] = 0;
        _isExcludedFromRewards[account] = false;
        _excluded.pop();
        break;
      }
    }
  }

  function setExcludedFromFee(address account, bool value) external onlyOwner {
    _isExcludedFromFee[account] = value;
  }

  function isExcludedFromFee(address account) public view returns (bool) {
    return _isExcludedFromFee[account];
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal {
    require(owner != address(0), 'BaseRfiToken: approve from the zero address');
    require(spender != address(0), 'BaseRfiToken: approve to the zero address');

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   */
  function _isUnlimitedSender(address account) internal view returns (bool) {
    // the owner should be the only whitelisted sender
    return (account == owner());
  }

  /**
   */
  function _isUnlimitedRecipient(address account) internal view returns (bool) {
    // the owner should be a white-listed recipient
    // and anyone should be able to burn as many tokens as
    // he/she wants
    return (account == owner() || account == burnAddress);
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) private {
    require(sender != address(0), 'BaseRfiToken: transfer from the zero address');
    require(recipient != address(0), 'BaseRfiToken: transfer to the zero address');
    require(sender != address(burnAddress), 'BaseRfiToken: transfer from the burn address');
    require(amount > 0, 'Transfer amount must be greater than zero');

    // indicates whether or not fee should be deducted from the transfer
    bool takeFee = true;

    if (paused()) {
      takeFee = false;
    } else {
      /**
       * Check the amount is within the max allowed limit as long as a
       * unlimited sender/recepient is not involved in the transaction
       */
      if (amount > maxTransactionAmount && !_isUnlimitedSender(sender) && !_isUnlimitedRecipient(recipient)) {
        revert('Transfer amount exceeds the maxTxAmount.');
      }
    }
    // else {
    //   /**
    //    * Check the amount is within the max allowed limit as long as a
    //    * unlimited sender/recepient is not involved in the transaction
    //    */
    //   if (amount > maxTransactionAmount && !_isUnlimitedSender(sender) && !_isUnlimitedRecipient(recipient)) {
    //     revert("Transfer amount exceeds the maxTxAmount.");
    //   }
    // }
    //TODO implement this check with delegate isV2par() !inSwapAndLiquify &&
    //Transfer
    if (sender != _v2Pair() && recipient != _v2Pair() && !paused()) {
      _transferType = TransferType.Transfer;
    }
    //TODO implement this check with delegate isV2par() !inSwapAndLiquify &&
    //Sell
    if (recipient == _v2Pair() && !paused()) {
      _transferType = TransferType.Sell;
    }
    //TODO implement this check with delegate isV2par() !inSwapAndLiquify &&
    //Buy
    if (sender == _v2Pair() && !paused()) {
      _transferType = TransferType.Buy;
    }

    // if any account belongs to _isExcludedFromFee account then remove the fee
    if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
      takeFee = false;
    }

    _beforeTokenTransfer(sender, recipient, amount, takeFee);
    _transferTokens(sender, recipient, amount, takeFee);
  }

  function _transferTokens(
    address sender,
    address recipient,
    uint256 amount,
    bool takeFee
  ) private {
    /**
     * We don't need to know anything about the individual fees here
     * (like Safemoon does with `_getValues`). All that is required
     * for the transfer is the sum of all fees to calculate the % of the total
     * transaction amount which should be transferred to the recipient.
     *
     * The `_takeFees` call will/should take care of the individual fees
     */

    if (_transferType == TransferType.Transfer) {
      sumOfFees = _getTransferSumOfFees();
    } else if (_transferType == TransferType.Sell) {
      sumOfFees = _getSellSumOfFees();
    } else {
      sumOfFees = _getBuySumOfFees();
    }

    if (!takeFee) {
      sumOfFees = 0;
    }

    (
      uint256 rAmount,
      uint256 rTransferAmount,
      uint256 tAmount,
      uint256 tTransferAmount,
      uint256 currentRate
    ) = _getValues(amount, sumOfFees);

    /**
     * Sender's and Recipient's reflected balances must be always updated regardless of
     * whether they are excluded from rewards or not.
     */
    _reflectedBalances[sender] = _reflectedBalances[sender] - rAmount;
    _reflectedBalances[recipient] = _reflectedBalances[recipient] + rTransferAmount;

    /**
     * Update the true/nominal balances for excluded accounts
     */
    if (_isExcludedFromRewards[sender]) {
      _balances[sender] = _balances[sender] - tAmount;
    }
    if (_isExcludedFromRewards[recipient]) {
      _balances[recipient] = _balances[recipient] + tTransferAmount;
    }

    _takeFees(amount, currentRate, sumOfFees);
    emit Transfer(sender, recipient, tTransferAmount);
  }

  function _takeFees(
    uint256 amount,
    uint256 currentRate,
    uint256 sumOfFees
  ) private {
    if (sumOfFees > 0 && !paused()) {
      _takeTransactionFees(amount, currentRate);
    }
  }

  function _getValues(uint256 tAmount, uint256 feesSum)
    internal
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    uint256 tTotalFees = (tAmount * feesSum) / FEES_DIVISOR;
    uint256 tTransferAmount = tAmount - tTotalFees;
    uint256 currentRate = _getCurrentRate();
    uint256 rAmount = tAmount * currentRate;
    uint256 rTotalFees = tTotalFees * currentRate;
    uint256 rTransferAmount = rAmount - rTotalFees;

    return (rAmount, rTransferAmount, tAmount, tTransferAmount, currentRate);
  }

  function _getCurrentRate() internal view returns (uint256) {
    (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
    return rSupply / tSupply;
  }

  function _getCurrentSupply() internal view returns (uint256, uint256) {
    uint256 rSupply = _reflectedSupply;
    uint256 tSupply = TOTAL_SUPPLY;

    /**
     * The code below removes balances of addresses excluded from rewards from
     * rSupply and tSupply, which effectively increases the % of transaction fees
     * delivered to non-excluded holders
     */
    for (uint256 i = 0; i < _excluded.length; i++) {
      if (_reflectedBalances[_excluded[i]] > rSupply || _balances[_excluded[i]] > tSupply)
        return (_reflectedSupply, TOTAL_SUPPLY);
      rSupply = rSupply - _reflectedBalances[_excluded[i]];
      tSupply = tSupply - _balances[_excluded[i]];
    }
    if (tSupply == 0 || rSupply < _reflectedSupply / TOTAL_SUPPLY) return (_reflectedSupply, TOTAL_SUPPLY);
    return (rSupply, tSupply);
  }

  /**
   * @dev Hook that is called before any transfer of tokens.
   */
  function _beforeTokenTransfer(
    address sender,
    address recipient,
    uint256 amount,
    bool takeFee
  ) internal virtual;

  /**
   * @dev Returns the total sum of fees to be processed in each transaction.
   *
   * To separate concerns this contract (class) will take care of ONLY handling RFI, i.e.
   * changing the rates and updating the holder's balance (via `_redistribute`).
   * It is the responsibility of the dev/user to handle all other fees and taxes
   * in the appropriate contracts (classes).
   */
  // function _getSumOfFees() internal view virtual returns (uint256);
  function _getTransferSumOfFees() internal view virtual returns (uint256);

  function _getSellSumOfFees() internal view virtual returns (uint256);

  function _getBuySumOfFees() internal view virtual returns (uint256);

  /**
   * @dev A delegate which should return true if the given address is the V2 Pair and false otherwise
   */
  function _isV2Pair(address account) internal view virtual returns (bool);

  /**
   * @dev A delegate which should return v2 pair address
   */

  function _v2Pair() internal view virtual returns (address);

  /**
   * @dev Redistributes the specified amount among the current holders via the reflect.finance
   * algorithm, i.e. by updating the _reflectedSupply (_rSupply) which ultimately adjusts the
   * current rate used by `tokenFromReflection` and, in turn, the value returns from `balanceOf`.
   * This is the bit of clever math which allows rfi to redistribute the fee without
   * having to iterate through all holders.
   *
   * Visit our discord at https://discord.gg/dAmr6eUTpM
   */
  function _redistribute(
    uint256 amount,
    uint256 currentRate,
    uint256 fee,
    uint256 index
  ) internal {
    uint256 tFee = (amount * fee) / FEES_DIVISOR;
    uint256 rFee = tFee * currentRate;

    _reflectedSupply = _reflectedSupply - rFee;
    _addFeeCollectedAmount(index, tFee);
  }

  /**
   * @dev Hook that is called before the `Transfer` event is emitted if fees are enabled for the transfer
   */
  function _takeTransactionFees(uint256 amount, uint256 currentRate) internal virtual;

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }
}

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////Liquifier START HERE////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

abstract contract Liquifier is Ownable {
  uint256 private withdrawableBalance;

  address private _routerAddress;

  IPancakeV2Router internal _router;
  address internal _pair;

  bool private inSwapAndLiquify;
  bool private swapAndLiquifyEnabled = true;

  uint256 private maxTransactionAmount;
  uint256 private numberOfTokensToSwapToLiquidity;

  address private LPReceiver;

  modifier lockTheSwap() {
    inSwapAndLiquify = true;
    _;
    inSwapAndLiquify = false;
  }

  event RouterSet(address indexed router);
  event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
  event SwapAndLiquifyEnabledUpdated(bool enabled);
  event LiquidityAdded(uint256 tokenAmountSent, uint256 ethAmountSent, uint256 liquidity);
  event LPReceiverChanged(address LPReceiver);
  event NumberOfTokensToSwapToLiquidityChanged(uint256 tokenAmount);

  receive() external payable {}

  function _setNumberOfTokensToSwapToLiquidity(uint256 tokenAmount) external onlyOwner {
    numberOfTokensToSwapToLiquidity = tokenAmount;
    emit NumberOfTokensToSwapToLiquidityChanged(tokenAmount);
  }

  function showNumberOfTokensToSwapToLiquidity() external view returns (uint256) {
    return numberOfTokensToSwapToLiquidity;
  }

  function initializeLiquiditySwapper(
    address env,
    uint256 maxTx,
    uint256 liquifyAmount
  ) internal {
    _setRouterAddress(env);

    maxTransactionAmount = maxTx;
    numberOfTokensToSwapToLiquidity = liquifyAmount;
  }

  /**
   * NOTE: passing the `contractTokenBalance` here is preferred to creating `balanceOfDelegate`
   */
  function liquify(uint256 contractTokenBalance, address sender) internal {
    if (contractTokenBalance >= maxTransactionAmount) contractTokenBalance = maxTransactionAmount;

    bool isOverRequiredTokenBalance = (contractTokenBalance >= numberOfTokensToSwapToLiquidity);

    /**
     * - first check if the contract has collected enough tokens to swap and liquify
     * - then check swap and liquify is enabled
     * - then make sure not to get caught in a circular liquidity event
     * - finally, don't swap & liquify if the sender is the uniswap pair
     */
    if (isOverRequiredTokenBalance && swapAndLiquifyEnabled && !inSwapAndLiquify && (sender != _pair)) {
      // TODO check if the `(sender != _pair)` is necessary because that basically
      // stops swap and liquify for all "buy" transactions
      //...MOST LIKELY NOT WILL TEST LATER?
      _swapAndLiquify(contractTokenBalance);
    }
  }

  /**
   * @dev sets the router address and created the router, factory pair to enable
   * swapping and liquifying (contract) tokens
   */
  function _setRouterAddress(address router) private {
    IPancakeV2Router _newPancakeRouter = IPancakeV2Router(router);
    _pair = IPancakeV2Factory(_newPancakeRouter.factory()).createPair(address(this), _newPancakeRouter.WETH());
    _router = _newPancakeRouter;
    emit RouterSet(router);
  }

  //TODO Check edge cases for setPortionFees()
  function setPortionFees(
    uint16 _treasuryPortionFee,
    uint16 _marketingPortionFee,
    uint16 _liquidityPortionFee
  ) external onlyOwner {
    treasuryPortionFee = _treasuryPortionFee;
    marketingPortionFee = _marketingPortionFee;
    liquidityPortionFee = _liquidityPortionFee;
  }

  //TODO move state vars up when done
  uint16 public treasuryPortionFee = 610;
  uint16 public marketingPortionFee = 230;
  uint16 public liquidityPortionFee = 160;
  uint256 public feeDivisor = 10**3;

  function _swapAndLiquify(uint256 amount) private lockTheSwap {
    // split the contract balance into halves
    uint256 _treasuryPortionFee = (amount * treasuryPortionFee) / feeDivisor;
    uint256 _marketingPortionFee = (amount * marketingPortionFee) / feeDivisor;
    uint256 _halfOfLiquidityPortionFee = (amount * (liquidityPortionFee / 2)) / feeDivisor;

    //calculates how many tokens should be swap to BNB
    uint256 swapToBnb = _treasuryPortionFee + _marketingPortionFee + _halfOfLiquidityPortionFee;

    // capture the contract's current BNB balance.
    // this is so that we can capture exactly the amount of BNB that the
    // swap creates, and not make the liquidity event include any BNB that
    // has been manually sent to the contract
    uint256 initialBalance = address(this).balance;

    // swap tokens for BNB
    _swapTokensForBNB(swapToBnb); // <- this breaks the BNB

    // how much BNB did we just swap into?
    uint256 newBalance = address(this).balance - initialBalance;
    //calculates the percentage of BNB left for _addLiquidity()
    uint256 percentBnbLeftForAddLP = 100 / (swapToBnb / _halfOfLiquidityPortionFee);
    uint256 bnbForLp = (newBalance / 100) * percentBnbLeftForAddLP;

    // add liquidity to uniswap-like amm
    _addLiquidity(_halfOfLiquidityPortionFee, bnbForLp);

    sendBnbToFund();

    emit SwapAndLiquify(_halfOfLiquidityPortionFee, newBalance, bnbForLp);
  }

  function _swapTokensForBNB(uint256 tokenAmount) private {
    // generate the uniswap pair path of token -> weth
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = _router.WETH();

    _approveDelegate(address(this), address(_router), tokenAmount);

    // make the swap
    _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      tokenAmount,
      // The minimum amount of output tokens that must be received for the transaction not to revert.
      // 0 = accept any amount (slippage is inevitable)
      0,
      path,
      address(this),
      block.timestamp
    );
  }

  // TODO move the addresses up and create function to change them
  address payable public treasuryAddress = payable(0x826AAc8AA549bE0a3A60423ab20e1f88Fcd6C6a3);
  address payable public marketingAddress = payable(0xcBaA5457E8E01790a2ce0a6aD2986e263a866969);

  function setFundWallets(address payable _treasuryAddress, address payable _marketingAddress) external onlyOwner {
    treasuryAddress = _treasuryAddress;
    marketingAddress = _marketingAddress;
  }

  function sendBnbToFund() private {
    uint256 bnbRaised = address(this).balance;

    if (treasuryPortionFee >= marketingPortionFee) {
      uint256 marketingPortion = ((bnbRaised / 100) * (100 / (treasuryPortionFee / marketingPortionFee)));
      uint256 treasuryPortion = bnbRaised - marketingPortion;

      marketingAddress.transfer(marketingPortion);
      treasuryAddress.transfer(treasuryPortion);
    } else {
      uint256 treasuryPortion = ((bnbRaised / 100) * (100 / (marketingPortionFee / treasuryPortionFee)));
      uint256 marketingPortion = bnbRaised - treasuryPortion;

      marketingAddress.transfer(marketingPortion);
      treasuryAddress.transfer(treasuryPortion);
    }
  }

  function setLPReceiver(address receiver) external onlyOwner {
    LPReceiver = receiver;
    emit LPReceiverChanged(LPReceiver);
  }

  function showLPReceiver() external view returns (address) {
    return LPReceiver;
  }

  function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
    // approve token transfer to cover all possible scenarios
    _approveDelegate(address(this), address(_router), tokenAmount);

    // add the liquidity
    (uint256 tokenAmountSent, uint256 ethAmountSent, uint256 liquidity) = _router.addLiquidityETH{ value: ethAmount }(
      address(this),
      tokenAmount,
      // Bounds the extent to which the WETH/token price can go up before the transaction reverts.
      // Must be <= amountTokenDesired; 0 = accept any amount (slippage is inevitable)
      0,
      // Bounds the extent to which the token/WETH price can go up before the transaction reverts.
      // 0 = accept any amount (slippage is inevitable)
      0,
      // this is a centralized risk if the owner's account is ever compromised (see Certik SSL-04)
      // owner(),
      LPReceiver,
      block.timestamp
    );

    // fix the forever locked BNBs as per the certik's audit
    /**
     * The swapAndLiquify function converts half of the contractTokenBalance SafeMoon tokens to BNB.
     * For every swapAndLiquify function call, a small amount of BNB remains in the contract.
     * This amount grows over time with the swapAndLiquify function being called throughout the life
     * of the contract. The Safemoon contract does not contain a method to withdraw these funds,
     * and the BNB will be locked in the Safemoon contract forever.
     */
    withdrawableBalance = address(this).balance;
    emit LiquidityAdded(tokenAmountSent, ethAmountSent, liquidity);
  }

  /**
   * @dev Sets the uniswapV2 pair (router & factory) for swapping and liquifying tokens
   */
  function setRouterAddress(address router) external onlyOwner {
    _setRouterAddress(router);
  }

  /**
   * @dev Sends the swap and liquify flag to the provided value. If set to `false` tokens collected in the contract will
   * NOT be converted into liquidity.
   */
  function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner {
    swapAndLiquifyEnabled = enabled;
    emit SwapAndLiquifyEnabledUpdated(swapAndLiquifyEnabled);
  }

  /**
   * @dev The owner can withdraw ETH(BNB) collected in the contract from `swapAndLiquify`
   * or if someone (accidentally) sends ETH/BNB directly to the contract.
   *
   * Note: This addresses the contract flaw pointed out in the Certik Audit of Safemoon (SSL-03):
   *
   * The swapAndLiquify function converts half of the contractTokenBalance SafeMoon tokens to BNB.
   * For every swapAndLiquify function call, a small amount of BNB remains in the contract.
   * This amount grows over time with the swapAndLiquify function being called
   * throughout the life of the contract. The Safemoon contract does not contain a method
   * to withdraw these funds, and the BNB will be locked in the Safemoon contract forever.
   * https://www.certik.org/projects/safemoon
   */
  function withdrawLockedBNB(address payable recipient) external onlyOwner {
    require(recipient != address(0), 'Cannot withdraw the BNB balance to the zero address');
    require(withdrawableBalance > 0, 'The BNB balance must be greater than 0');

    // prevent re-entrancy attacks
    uint256 amount = withdrawableBalance;
    withdrawableBalance = 0;
    recipient.transfer(amount);
  }

  /**
   * @dev Use this delegate instead of having (unnecessarily) extend `BaseRfiToken` to gained access
   * to the `_approve` function.
   */
  function _approveDelegate(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual;
}

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////Kitties START HERE////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

contract Kitties02 is BaseRfiToken, Liquifier {
  using SafeERC20 for IERC20;

  event FeeIncreased(uint256 FeePosition, uint256 AddedValue, uint256 FeeTotal);
  event FeeDecreased(uint256 FeePosition, uint256 AddedValue, uint256 FeeTotal);

  constructor(address _env) {
    initializeLiquiditySwapper(_env, maxTransactionAmount, numberOfTokensToSwapToLiquidity);

    // exclude the pair address from rewards - we don't want to redistribute
    // tx fees to these two; redistribution is only for holders, dah!
    _exclude(_pair);
    _exclude(burnAddress);
    _exclude(treasuryAddress);
    _exclude(marketingAddress);
    _approve(owner(), address(_router), ~uint256(0));
  }

  function _isV2Pair(address account) internal view override returns (bool) {
    return (account == _pair);
  }

  function _v2Pair() internal view override returns (address) {
    return _pair;
  }

  function _getTransferSumOfFees() internal view override returns (uint256) {
    return transferSumOfFees;
  }

  function _getSellSumOfFees() internal view override returns (uint256) {
    return sellSumOfFees;
  }

  function _getBuySumOfFees() internal view override returns (uint256) {
    return buySumOfFees;
  }

  function _beforeTokenTransfer(
    address sender,
    address,
    uint256,
    bool
  ) internal override {
    if (!paused()) {
      uint256 contractTokenBalance = balanceOf(address(this));
      liquify(contractTokenBalance, sender);
    }
  }

  function _takeTransactionFees(uint256 amount, uint256 currentRate) internal override {
    if (paused()) {
      return;
    }

    uint256 feesCount = _getFeesCount();
    for (uint256 index = 0; index < feesCount; index++) {
      (, FeeType name, uint256 value, address recipient, ) = _getFee(index);
      // no need to check value < 0 as the value is uint (i.e. from 0 to 2^256-1)
      if (value == 0) continue;

      if (name == FeeType.Rfi) {
        _redistribute(amount, currentRate, value, index);
      } else if (name == FeeType.Burn) {
        _burn(amount, currentRate, value, index);
      } else {
        _takeFee(amount, currentRate, value, recipient, index);
      }
    }
  }

  function _burn(
    uint256 amount,
    uint256 currentRate,
    uint256 fee,
    uint256 index
  ) private {
    uint256 tBurn = (amount * fee) / FEES_DIVISOR;
    uint256 rBurn = tBurn * currentRate;

    _burnTokens(address(this), tBurn, rBurn);
    _addFeeCollectedAmount(index, tBurn);
  }

  function _takeFee(
    uint256 amount,
    uint256 currentRate,
    uint256 fee,
    address recipient,
    uint256 index
  ) private {
    uint256 tAmount = (amount * fee) / FEES_DIVISOR;
    uint256 rAmount = tAmount * currentRate;

    _reflectedBalances[recipient] = _reflectedBalances[recipient] + rAmount;
    if (_isExcludedFromRewards[recipient]) _balances[recipient] = _balances[recipient] + tAmount;

    _addFeeCollectedAmount(index, tAmount);
  }

  function _approveDelegate(
    address owner,
    address spender,
    uint256 amount
  ) internal override {
    _approve(owner, spender, amount);
  }

  function increaseTransferFee(uint256 index, uint256 addedValue) external onlyOwner {
    require((_getTransferSumOfFees() + addedValue) <= 200, 'Maximum 20% fee is allowed!');

    uint256 prevTSumOfFees = transferSumOfFees;
    uint256 updatedTSumOfFees = prevTSumOfFees + addedValue;

    transferSumOfFees = updatedTSumOfFees;
    transferFees[index].value += addedValue;

    emit FeeIncreased(index, addedValue, transferSumOfFees);
  }

  function increaseSellFee(uint256 index, uint256 addedValue) external onlyOwner {
    require((_getSellSumOfFees() + addedValue) <= 200, 'Maximum 20% fee is allowed!');

    uint256 prevSSumOfFees = sellSumOfFees;
    uint256 updatedSSumOfFees = prevSSumOfFees + addedValue;

    sellSumOfFees = updatedSSumOfFees;
    sellFees[index].value += addedValue;

    emit FeeIncreased(index, addedValue, sellSumOfFees);
  }

  function increaseBuyFee(uint256 index, uint256 addedValue) external onlyOwner {
    require((_getTransferSumOfFees() + addedValue) <= 200, 'Maximum 20% fee is allowed!');

    uint256 prevBSumOfFees = buySumOfFees;
    uint256 updatedBSumOfFees = prevBSumOfFees + addedValue;

    buySumOfFees = updatedBSumOfFees;
    buyFees[index].value += addedValue;

    emit FeeIncreased(index, addedValue, buySumOfFees);
  }

  function decreaseTransferFee(uint256 index, uint256 subtractedValue) external onlyOwner {
    require((_getTransferSumOfFees() - subtractedValue) >= 0, "Can't go below 0");

    uint256 prevTSumOfFees = transferSumOfFees;
    uint256 updatedTSumOfFees = prevTSumOfFees - subtractedValue;

    transferSumOfFees = updatedTSumOfFees;
    transferFees[index].value -= subtractedValue;

    emit FeeDecreased(index, subtractedValue, transferSumOfFees);
  }

  function decreaseSellFee(uint256 index, uint256 subtractedValue) external onlyOwner {
    require((_getSellSumOfFees() - subtractedValue) >= 0, "Can't go below 0");

    uint256 prevSSumOfFees = sellSumOfFees;
    uint256 updatedSSumOfFees = prevSSumOfFees - subtractedValue;

    sellSumOfFees = updatedSSumOfFees;
    sellFees[index].value -= subtractedValue;

    emit FeeDecreased(index, subtractedValue, sellSumOfFees);
  }

  function decreaseBuyFee(uint256 index, uint256 subtractedValue) external onlyOwner {
    require((_getBuySumOfFees() - subtractedValue) >= 0, "Can't go below 0");

    uint256 prevBSumOfFees = buySumOfFees;
    uint256 updatedBSumOfFees = prevBSumOfFees - subtractedValue;

    buySumOfFees = updatedBSumOfFees;
    buyFees[index].value -= subtractedValue;

    emit FeeDecreased(index, subtractedValue, buySumOfFees);
  }

  //Finally Function to rescue tokens mistakenly sent to contract which is happening all fucking the time...
  function sendAnyIERC20token(
    IERC20 tokenAddress,
    address recipient,
    uint256 amount
  ) external onlyOwner {
    tokenAddress.safeTransferFrom(owner(), recipient, amount);
  }
}

/**
 * SPDX-License-Identifier: MIT
 */

pragma solidity 0.8.12;

//////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////Necessary imports////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    this;
    return msg.data;
  }
}

library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, 'Address: insufficient balance');
    (bool success, ) = recipient.call{ value: amount }('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }

  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, 'Address: low-level call failed');
  }

  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, errorMessage);
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(address(this).balance >= value, 'Address: insufficient balance for call');
    require(isContract(target), 'Address: call to non-contract');
    (bool success, bytes memory returndata) = target.call{ value: value }(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
    return functionStaticCall(target, data, 'Address: low-level static call failed');
  }

  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    require(isContract(target), 'Address: static call to non-contract');
    (bool success, bytes memory returndata) = target.staticcall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionDelegateCall(target, data, 'Address: low-level delegate call failed');
  }

  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(isContract(target), 'Address: delegate call to non-contract');
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function _verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) private pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      if (returndata.length > 0) {
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

abstract contract Ownable is Context {
  address private _owner;
  address private _previousOwner;
  uint256 private _lockTime;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), 'Ownable: caller is not the owner');
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  function getUnlockTime() public view returns (uint256) {
    return _lockTime;
  }

  function lock(uint256 time) public virtual onlyOwner {
    _previousOwner = _owner;
    _owner = address(0);
    _lockTime = block.timestamp + time;
    emit OwnershipTransferred(_owner, address(0));
  }

  function unlock() public virtual {
    require(_previousOwner == msg.sender, 'Only the previous owner can unlock onwership');
    require(block.timestamp > _lockTime, 'The contract is still locked');
    emit OwnershipTransferred(_owner, _previousOwner);
    _owner = _previousOwner;
  }
}

interface IPancakeV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeV2Router {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

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

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

abstract contract Pausable is Context {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() {
    _paused = false;
  }

  function paused() public view virtual returns (bool) {
    return _paused;
  }

  modifier whenNotPaused() {
    require(!paused(), 'Pausable: paused');
    _;
  }

  modifier whenPaused() {
    require(paused(), 'Pausable: not paused');
    _;
  }

  function _pause() internal virtual whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

  function _unpause() internal virtual whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  /**
   * @dev Deprecated. This function has issues similar to the ones found in
   * {IERC20-approve}, and its usage is discouraged.
   *
   * Whenever possible, use {safeIncreaseAllowance} and
   * {safeDecreaseAllowance} instead.
   */
  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    // safeApprove should only be called when setting an initial allowance,
    // or when resetting it to zero. To increase and decrease it, use
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      'SafeERC20: approve from non-zero to non-zero allowance'
    );
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    unchecked {
      uint256 oldAllowance = token.allowance(address(this), spender);
      require(oldAllowance >= value, 'SafeERC20: decreased allowance below zero');
      uint256 newAllowance = oldAllowance - value;
      _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
  }

  /**
   * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
   * on the return value: the return value is optional (but if data is returned, it must not be false).
   * @param token The token targeted by the call.
   * @param data The call data (encoded using abi.encode or one of its variants).
   */
  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
    // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
    // the target address contains contract code and also asserts for success in the low-level call.

    bytes memory returndata = address(token).functionCall(data, 'SafeERC20: low-level call failed');
    if (returndata.length > 0) {
      // Return data is optional
      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
    }
  }
}