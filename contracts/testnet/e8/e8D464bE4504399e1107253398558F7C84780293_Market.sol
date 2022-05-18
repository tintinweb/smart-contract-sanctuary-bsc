// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "./OwnableUpgradeable.sol";
import "./ReentrancyGuardUpgradeable.sol";
import "./SafeERC20Upgradeable.sol";
import "./IERC20Upgradeable.sol";
import "./MathUpgradeable.sol";
import "./CommonConversion.sol";

import "./IOracle.sol";
import "./ICashier.sol";
import "./IMarketConfig.sol";
import "./ITreasuryHolder.sol";
import "./NonblockingLzApp.sol";

/// @title Market - A place where fellow baristas come and get their debt.
// solhint-disable not-rely-on-time
contract Market is LzApp {
  using CommonConversion for Conversion;
  using SafeERC20Upgradeable for IERC20Upgradeable;

  /// @dev Events
  event LogUpdateCollateralPrice(uint256 newPrice);
  event LogUpdateDebtPrice(uint256 newPrice);
  event LogAccrue(uint256 amount);
  event LogAddCollateral(address indexed from, address indexed to, uint256 share);
  event LogRemoveCollateral(address indexed from, address indexed to, uint256 share);
  event LogBorrow(address indexed from, address indexed to, uint256 amount, uint256 part);
  event LogIsBorrowed(address indexed from, address indexed to, uint256 amount, uint256 part);
  event LogRepay(address indexed from, address indexed to, uint256 amount, uint256 part);
  event LogIsRepaid(address indexed from, address indexed to, uint256 amount, uint256 part);
  event LogFeeTo(address indexed newFeeTo);
  event LogSetInterestPerSec(uint256 oldInterestPerSec, uint256 newInterestPerSec);
  event LogWithdrawSurplus(address indexed feeTo, uint256 surplus);
  event LogWithdrawLiquidationFee(address indexed feeTo, uint256 liquidationFee);
  event LogSetDebtMarket(address indexed debt);
  event LogSetDebt(address indexed debt);
  event LogSetOracle(IOracle indexed oracle);
  event LogSetCollateralOracleData(bytes data);
  event LogSetDebtOracleData(bytes data);

  /// @dev Constants
  uint256 private constant BPS_PRECISION = 1e4;
  uint256 private constant COLLATERAL_PRICE_PRECISION = 1e18;

  /// @dev Default configuration states.
  /// These configurations are expected to be the same amongs markets.
  ICashier public cashier;

  /// @dev Market configuration states.
  address public debtMarket;
  IERC20Upgradeable public collateral;
  IERC20Upgradeable public debt;
  IOracle public oracle;
  bytes public collateralOracleData;
  bytes public debtOracleData;

  /// @dev Global states of the market
  uint256 public totalCollateralShare;
  uint256 public totalDebtShareLocal; // used in collateral chain
  uint256 public totalDebtValueLocal; // used in collateral chain
  uint256 public totalDebtShare; // used in debt chain
  uint256 public totalDebtValue; // used in debt chain

  /// @dev User's states
  mapping(address => uint256) public userCollateralShare;
  mapping(address => uint256) public userDebtShareLocal; // used in collateral chain
  mapping(address => uint256) public userDebtShare; // used in debt chain

  /// @dev Price of collateral
  uint256 public collateralPrice;
  uint256 public debtPrice;

  /// @dev Interest-related states
  uint256 public lastAccrueTime;

  /// @dev Protocol revenue
  uint256 public surplus;
  uint256 public liquidationFee;

  /// @dev Fee & Risk parameters
  IMarketConfig public marketConfig;

  // layerzero variable
  uint16 private constant LZ_VERSION = 1;
  uint256 private constant LZ_DESTINATION_GAS_RECEIVE = 10000000;
  uint16 public lzDebtChainId;

  /// @notice The constructor is only used for the initial master contract.
  /// Subsequent clones are initialised via `init`.
  function initialize(
    ICashier _cashier,
    IERC20Upgradeable _collateral,
    IMarketConfig _marketConfig,
    IOracle _oracle,
    bytes calldata _collateralOracleData,
    address _lzEndpoint,
    uint16 _lzDebtChainId
  ) external initializer {
    require(address(_cashier) != address(0), "cashier cannot be address(0)");
    require(address(_collateral) != address(0), "collateral cannot be address(0)");
    require(address(_marketConfig) != address(0), "marketConfig cannot be address(0)");
    require(address(_oracle) != address(0), "oracle cannot be address(0)");

    cashier = _cashier;
    oracle = _oracle;
    marketConfig = _marketConfig;

    // collateral market
    collateral = _collateral;
    collateralOracleData = _collateralOracleData;

    // debt market
    // `debt` must be set separately by owner
    // `debtMarket` must be set separately by owner
    // `debtOracleData` must be set separately by owner

    // lz
    LzApp.__LzApp_init(_lzEndpoint);
    lzDebtChainId = _lzDebtChainId;
  }

  /// @notice Accrue interest and realized surplus.
  /// CHAIN: collateral (TODO: confirm)
  modifier accrue() {
    // Only accrue interest if there is time diff and there is a debt
    if (block.timestamp > lastAccrueTime) {
      // 1. Findout time diff between this block and update lastAccruedTime
      uint256 _timePast = block.timestamp - lastAccrueTime;
      lastAccrueTime = block.timestamp;

      // 2. If totalDebtValue > 0 then calculate interest
      if (totalDebtValue > 0) {
        // 3. Calculate interest
        uint256 _pendingInterest = (marketConfig.interestPerSecond(address(this)) * totalDebtValue * _timePast) / 1e18;
        totalDebtValue = totalDebtValue + _pendingInterest;

        // 4. Realized surplus
        surplus = surplus + _pendingInterest;

        emit LogAccrue(_pendingInterest);
      }
    }
    _;
  }

  /// @notice Modifier to check if the user is safe from liquidation at the end of function.
  /// CHAIN: ? (TODO: confirm)
  modifier checkSafe() {
    _;
    require(_checkSafe(msg.sender, collateralPrice, debtPrice), "!safe");
  }

  /// [OK]
  /// @notice Update collateral price and check slippage
  /// CHAIN: collateral
  modifier simpleUpdateCollateralPrice() {
    (bool _update, uint256 _price) = updateCollateralPrice();
    require(_update, "bad price");
    _;
  }

  /// [OK]
  /// @notice Update debt price and check slippage
  /// CHAIN: collateral
  modifier simpleUpdateDebtPrice() {
    (bool _update, uint256 _price) = updateDebtPrice();
    require(_update, "bad price");
    _;
  }

  /// @notice check debt size after an execution
  /// CHAIN: ? (TODO: confirm)
  modifier checkDebtSize() {
    _;
  }

  /// [OK]
  /// @notice Update debt market
  /// CHAIN: collateral
  function setDebt(IERC20Upgradeable _debt) external onlyOwner {
    require(address(_debt) != address(0), "debt cannot be address(0)"); // debtMarket is in another chain
    debt = _debt;
    emit LogSetDebt(address(debt));
  }

  /// [OK]
  /// @notice Update debt market
  /// CHAIN: collateral
  function setDebtMarket(address _debtMarket) external onlyOwner {
    require(address(_debtMarket) != address(0), "debtMarket cannot be address(0)"); // debtMarket is in another chain
    debtMarket = _debtMarket;
    emit LogSetDebtMarket(address(_debtMarket));
  }

  /// [OK]
  /// @notice Update oracle
  /// CHAIN: collateral
  function setOracle(IOracle _oracle) external onlyOwner {
    require(address(oracle) != address(0), "oracle cannot be address 0");
    oracle = _oracle;
    emit LogSetOracle(oracle);
  }

  /// [OK]
  /// @notice Update collateralOracleData
  /// CHAIN: collateral
  function setCollateralOracleData(bytes calldata _collateralOracleData) external onlyOwner {
    require(address(oracle) != address(0), "oracle cannot be address 0");
    collateralOracleData = _collateralOracleData;
    emit LogSetCollateralOracleData(collateralOracleData);
  }

  /// [OK]
  /// @notice Update debtOracleData
  /// CHAIN: collateral
  function setDebtOracleData(bytes calldata _debtOracleData) public onlyOwner {
    require(address(oracle) != address(0), "oracle cannot be address 0");
    debtOracleData = _debtOracleData;
    emit LogSetDebtOracleData(debtOracleData);
  }

  /// [OK]
  /// @notice Perform actual add collateral, move shares from user's to market's
  /// CHAIN: collateral
  /// @param _to The address of the user to get the collateral added
  /// @param _share The share of the collateral to be added
  function _addCollateral(address _to, uint256 _share) internal {
    require(
      cashier.balanceOf(collateral, msg.sender) - userCollateralShare[msg.sender] >= _share,
      "not enough balance to add collateral"
    );

    userCollateralShare[_to] = userCollateralShare[_to] + _share;
    uint256 _oldTotalCollateralShare = totalCollateralShare;
    totalCollateralShare = _oldTotalCollateralShare + _share;

    // to save gas, because cashier.transfer() to self does not change anything at cashier
    if (_to != msg.sender) {
      cashier.transfer(collateral, msg.sender, _to, _share);
    }

    emit LogAddCollateral(msg.sender, _to, _share);
  }

  /// [OK]
  /// @notice Adds `collateral` from msg.sender to the account `to`
  /// (require to have some shares deposited at cashier first)
  /// CHAIN: collateral
  /// @param _to The receiver of the tokens.
  /// @param _amount The amount of collateral to be added to "_to".
  function addCollateral(address _to, uint256 _amount) external nonReentrant accrue {
    uint256 _share = cashier.toShare(collateral, _amount, false);
    _addCollateral(_to, _share);
  }

  /// @notice Return if true "_user" is safe from liquidation.
  /// CHAIN: collateral
  /// @dev Beware of unaccrue interest. accrue is expected to be executed before _isSafe.
  /// @param _user The address to check if it is safe from liquidation.
  /// @param _collateralPrice Collateral price in USD
  /// @param _debtPrice Debt price in USD
  function _checkSafe(
    address _user,
    uint256 _collateralPrice,
    uint256 _debtPrice
  ) internal view returns (bool) {
    uint256 _collateralFactor = marketConfig.collateralFactor(address(this), _user);

    require(_collateralFactor <= 9500 && _collateralFactor >= 5000, "bad collateralFactor");

    uint256 _userDebtShare = userDebtShareLocal[_user];
    if (_userDebtShare == 0) return true;
    uint256 _userCollateralShare = userCollateralShare[_user];
    if (_userCollateralShare == 0) return false;

    return
      (cashier.toAmount(collateral, _userCollateralShare, false) * _collateralPrice * _collateralFactor) /
        (BPS_PRECISION * COLLATERAL_PRICE_PRECISION) >=
      (_userDebtShare * totalDebtValueLocal * _debtPrice) / totalDebtShareLocal;
  }

  /// [OK]
  /// @notice Perform the actual borrow request to paird market on another chain
  /// CHAIN: collateral
  /// @dev msg.sender borrow "_amount" of debt and transfer to "_to"
  /// @param _to The address to received borrowed debt
  /// @param _amount The amount of debt to be borrowed
  function _borrow(address _to, uint256 _amount) internal checkDebtSize returns (uint256 _debtShare, uint256 _share) {
    // 1. Find out debtShare from the give "_value" that msg.sender wish to borrow
    _debtShare = debtValueToShareLocal(_amount);

    // 2. Update user's debtShare
    userDebtShareLocal[msg.sender] = userDebtShareLocal[msg.sender] + _debtShare;

    // 3. Book totalDebtShare and totalDebtValue
    totalDebtShareLocal = totalDebtShareLocal + _debtShare;
    totalDebtValueLocal = totalDebtValueLocal + _amount;

    // LZ: prepare payload to transfer borrowing debt to "_to" in another chain
    bytes memory payload = abi.encode(
      "borrow",
      _to,
      _amount,
      userDebtShareLocal[msg.sender],
      totalDebtShareLocal,
      totalDebtValueLocal
    );
    // LZ: use adapterParams v1 to specify more gas for the destination
    bytes memory adapterParams = abi.encodePacked(LZ_VERSION, LZ_DESTINATION_GAS_RECEIVE);
    // LZ: estimate LZ fees for message delivery
    (uint256 messageFee, ) = lzEndpoint.estimateFees(lzDebtChainId, address(this), payload, false, adapterParams);
    require(msg.value >= messageFee, "msg.value < messageFee, not enough gas for lzEndpoint.send()");

    // send LayerZero message
    lzEndpoint.send{ value: messageFee }( // {value: messageFee} will be paid out of this contract!
      lzDebtChainId, // destination chainId
      abi.encodePacked(debtMarket), // destination address of market B contract
      payload, // abi.encode()'ed bytes
      payable(msg.sender), // (msg.sender will be this contract) refund address (LayerZero will refund any extra gas back to caller of send()
      address(0x0), // the address of the ZRO token holder who would pay for the transaction
      adapterParams // v1 adapterParams, specify custom destination gas qty
    );

    emit LogBorrow(msg.sender, _to, _amount, _debtShare);
  }

  /// [OK]
  /// @notice Sender borrows `_amount` of debt on the paired market (another chain) and transfers it to `to`.
  /// CHAIN: collateral
  /// @dev "checkSafe" modifier prevents msg.sender from borrow > collateralFactor
  /// @param _to The address to received borrowed debt
  /// @param _borrowAmount The amount of debt to be borrowed
  function borrow(address _to, uint256 _borrowAmount)
    external
    payable
    nonReentrant
    accrue
    simpleUpdateCollateralPrice
    simpleUpdateDebtPrice
    checkSafe
    returns (uint256 _debtShare, uint256 _share)
  {
    // Perform borrow request
    (_debtShare, _share) = _borrow(_to, _borrowAmount);
  }

  /// @notice Return the debt value of the given debt share.
  /// CHAIN: collateral (TODO: confirm)
  /// @param _debtShare The debt share to be convered.
  function debtShareToValue(uint256 _debtShare) public view returns (uint256) {
    if (totalDebtShare == 0) return _debtShare;
    uint256 _debtValue = (_debtShare * totalDebtValue) / totalDebtShare;
    return _debtValue;
  }

  /// @notice Return the debt share for the given debt value.
  /// CHAIN: collateral (TODO: confirm)
  /// @dev debt share will always be rounded up to prevent tiny share.
  /// @param _debtValue The debt value to be converted.
  function debtValueToShare(uint256 _debtValue) public view returns (uint256) {
    if (totalDebtShare == 0) return _debtValue;
    uint256 _debtShare = (_debtValue * totalDebtShare) / totalDebtValue;
    if ((_debtShare * totalDebtValue) / totalDebtShare < _debtValue) {
      return _debtShare + 1;
    }
    return _debtShare;
  }

  /// @notice Return the debt share for the given debt value.
  /// CHAIN: collateral (TODO: confirm)
  /// @dev debt share will always be rounded up to prevent tiny share.
  /// @param _debtValue The debt value to be converted.
  function debtValueToShareLocal(uint256 _debtValue) public view returns (uint256) {
    if (totalDebtShareLocal == 0) return _debtValue;
    uint256 _debtShare = (_debtValue * totalDebtShareLocal) / totalDebtValueLocal;
    if ((_debtShare * totalDebtValueLocal) / totalDebtShareLocal < _debtValue) {
      return _debtShare + 1;
    }
    return _debtShare;
  }

  /// [OK]
  /// @notice Deposit collateral to Cashier.
  /// CHAIN: collateral
  /// @dev msg.sender deposits `_amount` of `_token` to Cashier. "_to" will be credited with `_amount` of `_token`.
  /// @param _token The address of the token to be deposited.
  /// @param _to The address to be credited with `_amount` of `_token`.
  /// @param _collateralAmount The amount of `_token` to be deposited.
  function deposit(
    IERC20Upgradeable _token,
    address _to,
    uint256 _collateralAmount
  ) external nonReentrant accrue {
    _cashierDeposit(_token, _to, _collateralAmount, 0);
  }

  /// [OK]
  /// @notice Deposit and add collateral from msg.sender to the account `to`.
  /// CHAIN: collateral
  /// @param _to The beneficial to received collateral in Cashier.
  /// @param _collateralAmount The amount of collateral to be added to "_to".
  function depositAndAddCollateral(address _to, uint256 _collateralAmount) public nonReentrant accrue {
    // 1. Deposit collateral in Cashier from msg.sender
    _cashierDeposit(collateral, msg.sender, _collateralAmount, 0);

    // 2. Add collateral from msg.sender to _to in Cashier
    uint256 _share = cashier.toShare(collateral, _collateralAmount, false);
    _addCollateral(_to, _share);
  }

  /// @notice Deposit collateral to Cashier and borrow debt
  /// CHAIN: collateral
  /// @param _to The address to received borrowed debt
  /// @param _collateralAmount The amount of collateral to be deposited
  /// @param _borrowAmount The amount of debt to be borrowed
  function depositAndBorrow(
    address _to,
    uint256 _collateralAmount,
    uint256 _borrowAmount
  ) external nonReentrant accrue simpleUpdateCollateralPrice simpleUpdateDebtPrice checkSafe {
    // 1. Deposit collateral to the Vault
    (, uint256 _shareOut) = _cashierDeposit(collateral, _to, _collateralAmount, 0);

    // 2. Add all as collateral
    _addCollateral(_to, _shareOut);

    // 3. Borrow debt
    _borrow(_to, _borrowAmount);
  }

  /// @notice Repays a loan.
  /// @param _for Address of the user this payment should go.
  /// @param _maxDebtReturn The maxium amount of debt to be return.
  function depositAndRepay(address _for, uint256 _maxDebtReturn) external nonReentrant accrue returns (uint256) {
    updateCollateralPrice();
    // 1. Find out how much debt to repaid
    uint256 _debtValue = MathUpgradeable.min(_maxDebtReturn, debtShareToValue(userDebtShare[_for]));

    // 2. Deposit debt to Cashier
    _cashierDeposit(debt, msg.sender, _debtValue, 0);

    // 3. Repay debt
    _repay(_for, _debtValue);

    return _debtValue;
  }

  /// @notice Deposit "_debtValue" debt to the vault, repay the debt, and withdraw "_collateralAmount" of collateral.
  /// @dev source of funds to repay debt will come from msg.sender, "_to" is beneficiary
  /// @param _to The address to received collateral token.
  /// @param _maxDebtReturn The maxium amount of debt to be return.
  /// @param _collateralAmount The amount of collateral to be withdrawn.
  function depositRepayAndWithdraw(
    address _to,
    uint256 _maxDebtReturn,
    uint256 _collateralAmount
  ) external nonReentrant accrue simpleUpdateCollateralPrice checkSafe {
    // 1. Find out how much debt to repaid
    uint256 _debtValue = MathUpgradeable.min(_maxDebtReturn, debtShareToValue(userDebtShare[msg.sender]));

    // 2. Deposit debt to Vault for preparing to settle the debt
    _cashierDeposit(debt, msg.sender, _debtValue, 0);

    // 3. Repay the debt
    _repay(msg.sender, _debtValue);

    // 4. Remove collateral from Market to "_to"
    uint256 _collateralShare = cashier.toShare(collateral, _collateralAmount, false);
    _removeCollateral(msg.sender, _collateralShare);

    // 5. Withdraw collateral to "_to"
    _vaultWithdraw(collateral, _to, _collateralAmount, 0);
  }

  /// @dev during a bad debt, need to notify a treasudy holder `onBadDebt` function to update the bad debt
  /// @dev separate to prevent stack-too-deep error
  function _treasuryCallback(address _user) internal {
    if (userCollateralShare[_user] == 0 && userDebtShare[_user] != 0) {
      uint256 _badDebtValue = debtShareToValue(userDebtShare[_user]);
      totalDebtShare = totalDebtShare - userDebtShare[_user];
      totalDebtValue = totalDebtValue - _badDebtValue;
      userDebtShare[_user] = 0;
      // call an `onBadDebt` call back so that the treasury would know if this market has a bad debt
      ITreasuryHolderCallback(marketConfig.treasury()).onBadDebt(_badDebtValue);
    }
  }

  /// @notice transfer collateral share to _to
  /// CHAIN: collateral
  /// @dev separate to prevent stack-too-deep error
  function _transferCollateralShare(
    address _from,
    address _to,
    uint256 _collateralShare
  ) internal {
    cashier.transfer(collateral, _from, _to, _collateralShare);
    emit LogRemoveCollateral(_from, _to, _collateralShare);
  }

  /// @notice Perform the actual removeCollateral.
  /// CHAIN: collateral
  /// @dev msg.sender will be the source of funds to remove collateral from and then
  /// the funds will be credited to "_to".
  /// @param _to The beneficary of the removed collateral.
  /// @param _share The amount of collateral to remove in share units.
  function _removeCollateral(address _to, uint256 _share) internal {
    userCollateralShare[msg.sender] = userCollateralShare[msg.sender] - _share;
    totalCollateralShare = totalCollateralShare - _share;

    if (msg.sender != _to) {
      cashier.transfer(collateral, msg.sender, _to, _share);
    }

    emit LogRemoveCollateral(msg.sender, _to, _share);
  }

  /// @notice Remove `share` amount of collateral and transfer it to `to`.
  /// CHAIN: collateral
  /// @param _to The receiver of the shares.
  /// @param _amount Amount of collaterals to be removed
  function removeCollateral(address _to, uint256 _amount)
    public
    nonReentrant
    accrue
    simpleUpdateCollateralPrice
    checkSafe
  {
    uint256 _share = cashier.toShare(collateral, _amount, false);
    _removeCollateral(_to, _share);
  }

  /// @notice Remove and withdraw collateral from Cashier.
  /// @param _to The address to receive token.
  /// @param _collateralAmount The amount of collateral to be withdrawn.
  function removeCollateralAndWithdraw(address _to, uint256 _collateralAmount)
    external
    nonReentrant
    accrue
    simpleUpdateCollateralPrice
    checkSafe
  {
    // 1. Remove collateral from Market to "_to"
    uint256 _collateralShare = cashier.toShare(collateral, _collateralAmount, false);
    _removeCollateral(msg.sender, _collateralShare);

    // 2. Withdraw collateral to "_to"
    _vaultWithdraw(collateral, _to, _collateralAmount, 0);
  }

  /// @param _for The address to repay debt.
  /// @param _debtValue The debt value to be repaid.
  function _isRepaid(address _for, uint256 _debtValue) internal checkDebtSize returns (uint256 _debtShare) {
    // 1. Findout "_debtShare" from the given "_debtValue"
    _debtShare = debtValueToShareLocal(_debtValue);

    // 2. Update user's debtShare
    userDebtShareLocal[_for] = userDebtShareLocal[_for] - _debtShare;

    // 3. Update total debtShare and debtValue
    totalDebtShareLocal = totalDebtShareLocal - _debtShare;
    totalDebtValueLocal = totalDebtValueLocal - _debtValue;

    emit LogIsRepaid(msg.sender, _for, _debtValue, _debtShare);
  }

  /// @notice Perform the actual repay.
  /// @param _for The address to repay debt.
  /// @param _debtValue The debt value to be repaid.
  function _repay(address _for, uint256 _debtValue) internal checkDebtSize returns (uint256 _debtShare) {
    // 1. Findout "_debtShare" from the given "_debtValue"
    _debtShare = debtValueToShare(_debtValue);

    // 2. Update user's debtShare
    userDebtShare[_for] = userDebtShare[_for] - _debtShare;

    // 3. Update total debtShare and debtValue
    totalDebtShare = totalDebtShare - _debtShare;
    totalDebtValue = totalDebtValue - _debtValue;

    // 4. Transfer debt from msg.sender to this market, actually transfer ERC20 token from user
    cashier.transferERC20From(collateral, msg.sender, address(cashier), _debtValue);

    bytes memory payload = abi.encode("repay", _for, _debtValue);

    // use adapterParams v1 to specify more gas for the destination
    bytes memory adapterParams = abi.encodePacked(LZ_VERSION, LZ_DESTINATION_GAS_RECEIVE);

    // get the fees we need to pay to LayerZero for message delivery
    (uint256 messageFee, ) = lzEndpoint.estimateFees(lzDebtChainId, address(this), payload, false, adapterParams);
    require(
      address(this).balance >= messageFee,
      "address(this).balance < messageFee. fund this contract with more ether"
    );

    // send LayerZero message
    lzEndpoint.send{ value: messageFee }( // {value: messageFee} will be paid out of this contract!
      lzDebtChainId, // destination chainId
      abi.encodePacked(debtMarket), // destination address of market A contract
      payload, // abi.encode()'ed bytes
      payable(msg.sender), // (msg.sender will be this contract) refund address (LayerZero will refund any extra gas back to caller of send()
      address(0x0), // the address of the ZRO token holder who would pay for the transaction
      adapterParams // v1 adapterParams, specify custom destination gas qty
    );

    emit LogRepay(msg.sender, _for, _debtValue, _debtShare);
  }

  /// @notice Repays a loan.
  /// CHAIN: debt
  /// @param _for Address of the user this payment should go.
  /// @param _maxDebtValue The maximum amount of debt to be repaid.
  function repay(address _for, uint256 _maxDebtValue) external payable nonReentrant accrue returns (uint256) {
    updateCollateralPrice();
    uint256 _debtValue = MathUpgradeable.min(_maxDebtValue, debtShareToValue(userDebtShare[_for]));
    _repay(_for, _debtValue);
    return _debtValue;
  }

  /// [OK]
  /// @notice Update collateral price from Oracle.
  function updateCollateralPrice() public returns (bool _updated, uint256 _price) {
    (_updated, _price) = oracle.get(collateralOracleData);

    if (_updated) {
      collateralPrice = _price;
      emit LogUpdateCollateralPrice(_price);
    } else {
      // Return the old rate if fetching wasn't successful
      _price = collateralPrice;
    }
  }

  /// [OK]
  /// @notice Update debt price from Oracle.
  function updateDebtPrice() public returns (bool _updated, uint256 _price) {
    (_updated, _price) = oracle.get(debtOracleData);

    if (_updated) {
      debtPrice = _price;
      emit LogUpdateDebtPrice(_price);
    } else {
      // Return the old rate if fetching wasn't successful
      _price = debtPrice;
    }
  }

  /// [OK]
  /// @notice Perform deposit token from msg.sender and credit token's balance to "_to"
  /// @param _token The token to deposit.
  /// @param _to The address to credit the deposited token's balance to.
  /// @param _amount The amount of tokens to deposit.
  /// @param _share The amount to deposit in share units.
  function _cashierDeposit(
    IERC20Upgradeable _token,
    address _to,
    uint256 _amount,
    uint256 _share
  ) internal returns (uint256 amount, uint256 shareOut) {
    return cashier.deposit(_token, msg.sender, _to, uint256(_amount), uint256(_share));
  }

  /// @notice Perform debit token's balance from msg.sender and transfer token to "_to"
  /// @param _token The token to withdraw.
  /// @param _to The address of the receiver.
  /// @param _amount The amount to withdraw.
  /// @param _share The amount to withdraw in share.
  function _vaultWithdraw(
    IERC20Upgradeable _token,
    address _to,
    uint256 _amount,
    uint256 _share
  ) internal returns (uint256, uint256) {
    uint256 share_ = _amount > 0 ? cashier.toShare(_token, _amount, true) : _share;
    require(_token == collateral || _token == debt, "invalid token to be withdrawn");
    if (_token == collateral) {
      require(
        cashier.balanceOf(_token, msg.sender) - share_ >= userCollateralShare[msg.sender],
        "please exclude the collateral"
      );
    }

    return cashier.withdraw(_token, msg.sender, _to, _amount, _share);
  }

  /// @notice Withdraw collateral from the Cashier.
  /// @param _token The token to be withdrawn.
  /// @param _to The address of the receiver.
  /// @param _collateralAmount The amount to be withdrawn.
  function withdraw(
    IERC20Upgradeable _token,
    address _to,
    uint256 _collateralAmount
  ) external accrue {
    _vaultWithdraw(_token, _to, _collateralAmount, 0);
  }

  /// @notice Withdraws accumulated surplus + liquidation fee.
  function withdrawSurplus() external accrue returns (uint256, uint256) {
    require(marketConfig.treasury() != address(0), "bad treasury");
    require(marketConfig.treasury() == msg.sender, "not treasury");

    // 1. Cached old data
    uint256 _surplus = surplus;
    uint256 _liquidationFee = liquidationFee;

    // 2. Update calculate _share to be transferred
    uint256 _surplusShare = cashier.toShare(debt, surplus, false);
    uint256 _liquidationFeeShare = cashier.toShare(debt, liquidationFee, false);
    surplus = 0;
    liquidationFee = 0;

    // 3. Perform the actual transfer
    cashier.transfer(debt, address(this), marketConfig.treasury(), _surplusShare + _liquidationFeeShare);

    emit LogWithdrawSurplus(marketConfig.treasury(), _surplus);
    emit LogWithdrawLiquidationFee(marketConfig.treasury(), _liquidationFee);

    return (_surplus, _liquidationFee);
  }

  function fakeLzReceive(
    uint16 _srcChainId,
    bytes memory _srcAddress,
    uint64 _nonce,
    bytes memory _payload
  ) external {
    _blockingLzReceive(_srcChainId, _srcAddress, _nonce, _payload);
  }

  function _blockingLzReceive(
    uint16 _srcChainId,
    bytes memory _srcAddress,
    uint64 _nonce,
    bytes memory _payload
  ) internal override {
    // decode the number of pings sent thus far
    (
      string memory action,
      address to,
      uint256 _debtValue,
      uint256 _share,
      uint256 _totalShare,
      uint256 _totalValue
    ) = abi.decode(_payload, (string, address, uint256, uint256, uint256, uint256));
    require(_srcChainId == lzDebtChainId, "invalid pair sourceChainId");
    require(address(uint160(bytes20(_srcAddress))) == address(debtMarket), "invalid pair sourceMarket");

    if (_compareStrings("repay", action)) {
      _isRepaid(to, _debtValue);
    }
    if (_compareStrings("borrow", action)) {
      _isBorrowed(to, _debtValue, _share, _totalShare, _totalValue);
    }
  }

  function _addressMatches() internal {}

  function _addressMatches256() internal {}

  /// @notice called after receiving borrow request from the paired market of collateral chain
  /// CHAIN: debt
  /// @param _to The receiver of the tokens.
  /// @param _borrowAmount The borrowed amount of debt to be transferred out from cashier on debt side
  function _isBorrowed(
    address _to,
    uint256 _borrowAmount,
    uint256 _userDebtShareForValidate,
    uint256 _totalDebtShareForValidate,
    uint256 _totalDebtValueForValidate
  ) internal {
    // parallel track debtShare, totalDebtShare,
    // 1. Find out debtShare from the give "_value" that msg.sender wish to borrow
    uint256 _debtShare = debtValueToShare(_borrowAmount);

    // 2. Update user's debtShare
    userDebtShare[msg.sender] = userDebtShare[msg.sender] + _debtShare;
    require(userDebtShare[msg.sender] == _userDebtShareForValidate, "userDebtShare on two chains are off-synced!");

    // 3. Book totalDebtShare and totalDebtValue
    totalDebtShare = totalDebtShare + _debtShare;
    require(totalDebtShare == _totalDebtShareForValidate, "totalDebtShare on two chains are off-synced!");
    totalDebtValue = totalDebtValue + _borrowAmount;
    require(totalDebtValue == _totalDebtValueForValidate, "totalDebtValue on two chains are off-synced!");

    // 4. actually transfer ERC20 token out
    cashier.transferERC20(collateral, address(this), _to, _borrowAmount);

    emit LogIsBorrowed(msg.sender, _to, _borrowAmount, _debtShare);
  }

  function _compareStrings(string memory a, string memory b) internal pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
  }
}