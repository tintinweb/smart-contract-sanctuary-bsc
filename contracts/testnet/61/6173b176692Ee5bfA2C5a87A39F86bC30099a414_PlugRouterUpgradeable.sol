// SPDX-License-Identifier: MIT

pragma solidity =0.8.9;

/// interfaces
import {IERC20} from './interfaces/IERC20.sol';
import {IPlugRouterUpgradeable} from './interfaces/IPlugRouterUpgradeable.sol';
import {IBridgeAdapter} from './interfaces/IBridgeAdapter.sol';

// libraries
import {TransferHelpers} from './libraries/TransferHelpers.sol';

// contracts
import {Initializable} from './proxy/Initializable.sol';
import {OwnableUpgradeable} from './access/OwnableUpgradeable.sol';
import {ReentrancyGuardUpgradeable} from './security/ReentrancyGuardUpgradeable.sol';
import {PausableUpgradeable} from './security/PausableUpgradeable.sol';

/**
 * @title The PlugRouter Upgradeable Contract
 * @author Plug Exchange
 * @notice Performing swap,bridge deposit and crosschain Swap
 */
contract PlugRouterUpgradeable is
  IPlugRouterUpgradeable,
  Initializable,
  OwnableUpgradeable,
  ReentrancyGuardUpgradeable,
  PausableUpgradeable
{
  /// @notice Receive ETH
  receive() external payable {}

  /// @dev The swap fee configuration
  struct SwapFeeConfig {
    // swap fee percentage
    uint256 swapFeePercentage;
    // swap fee collector
    address swapFeeCollector;
  }

  /// @notice The swap fee config
  SwapFeeConfig public swapFeeConfig;

  /// @notice The fee denominator
  uint256 public constant FEE_DENOMINATER = 100000000;

  /// @notice The native token address
  address public constant NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  /// @notice The crosschain swap magic value
  bytes4 public constant CROSS_CHAIN_SWAP_MV = bytes4(keccak256(('crossChainSwap')));

  /// @notice The swap magic value
  bytes4 public constant SWAP_MV = bytes4(keccak256(('swap')));

  /// @notice The deposit magic value
  bytes4 public constant DEPOSIT_MV = bytes4(keccak256(('deposit')));

  /// @notice The map to lock specific user action
  mapping(bytes4 => bool) public lock;

  /// @notice The fee tokens config
  mapping(address => bool) public feeTokens;

  /// @notice The exchanges and bridges map
  mapping(bytes4 => address) public aggregatorsAndBridgesMap;

  /**
   * @notice Initialization of plug router
   * @param _swapFeePercentage The swap fee percentage
   * @param _swapFeeCollector The swap fee collector address
   * @param _trustedForwarder The trusted forwarder address
   */
  function __PlugRouterUpgradeable_init(
    uint256 _swapFeePercentage,
    address _swapFeeCollector,
    address _trustedForwarder
  ) external initializer {
    __Ownable_init(_trustedForwarder);
    __PlugRouterUpgradeable_init_unchained(_swapFeePercentage, _swapFeeCollector);
  }

  /**
   * @notice Sets fee config of plug router
   * @param _swapFeePercentage The swap fee percentage
   * @param _swapFeeCollector The swap fee collector address
   */
  function __PlugRouterUpgradeable_init_unchained(uint256 _swapFeePercentage, address _swapFeeCollector) internal {
    _setSwapFeeConfig(_swapFeePercentage, _swapFeeCollector);
  }

  /**
   * @inheritdoc IPlugRouterUpgradeable
   */
  function swap(
    address affiliateAddr,
    address fromToken,
    uint256 amount,
    bytes4 exchangeId,
    bytes calldata swapCallData
  ) external payable nonReentrant {
    require(!lock[SWAP_MV], 'SWAP_PAUSED');
    // swap
    (address outToken, uint256 swapedAmount) = _swap(fromToken, amount, exchangeId, swapCallData, true);
    // send tokens to user
    _transfers(outToken, _msgSender(), swapedAmount);

    emit SwapPerformed(affiliateAddr, _msgSender(), fromToken, outToken, amount, swapedAmount, exchangeId);
  }

  /**
   * @inheritdoc IPlugRouterUpgradeable
   */
  function crossChainSwap(
    address affiliateAddr,
    address fromToken,
    uint256 amount,
    bytes4 exchangeId,
    bytes4 bridgeId,
    bytes calldata swapCallData,
    bytes calldata bridgeCallData
  ) external payable nonReentrant {
    require(!lock[CROSS_CHAIN_SWAP_MV], 'CROSS_CHAIN_SWAP_PAUSED');
    // swap
    (address toToken, uint256 swapedAmount) = _swap(fromToken, amount, exchangeId, swapCallData, false);
    // deposit
    {
      if (toToken != NATIVE_TOKEN_ADDRESS) {
        TransferHelpers.safeTransfer(toToken, aggregatorsAndBridgesMap[bridgeId], swapedAmount);
      }

      uint256 toChainId = _deposit(
        _msgSender(),
        toToken,
        aggregatorsAndBridgesMap[bridgeId],
        swapedAmount,
        bridgeCallData
      );
      _logCrossChainSwap(affiliateAddr, fromToken, toToken, amount, swapedAmount, toChainId, exchangeId, bridgeId);
    }
  }

  /**
   * @inheritdoc IPlugRouterUpgradeable
   */
  function deposit(
    address affiliateAddr,
    address token,
    uint256 amount,
    bytes4 bridgeId,
    bytes calldata bridgeCallData
  ) external payable nonReentrant {
    require(!lock[DEPOSIT_MV], 'DEPOSIT_PAUSED');

    address bridgeAdapter = aggregatorsAndBridgesMap[bridgeId];
    require(bridgeAdapter != address(0), 'BRIDGE_ADAPTER_NOT_EXIST');

    pullTokens(token, bridgeAdapter, amount);
    // deposit
    uint256 toChainId = _deposit(_msgSender(), token, bridgeAdapter, amount, bridgeCallData);

    emit Deposit(affiliateAddr, _msgSender(), token, amount, toChainId, bridgeId);
  }

  /**
   * @inheritdoc IPlugRouterUpgradeable
   */
  function updateSwapFeeConfig(uint256 _swapFeePercentage, address _swapFeeCollector) external onlyOwner {
    _setSwapFeeConfig(_swapFeePercentage, _swapFeeCollector);
  }

  /**
   * @inheritdoc IPlugRouterUpgradeable
   */
  function addFeeTokens(address[] memory tokens, bool[] memory flags) external onlyOwner {
    uint256 len = tokens.length;
    require(len == flags.length, 'INVALID_ARRAY_LENGTH');

    for (uint256 k = 0; k < len; k++) {
      require(tokens[k] != address(0), 'INVALID_FEE_TOKEN');
      feeTokens[tokens[k]] = flags[k];
    }

    emit FeeTokens(tokens, flags);
  }

  /**
   * @inheritdoc IPlugRouterUpgradeable
   */
  function rescueTokens(
    address withdrawableAddress,
    address[] memory tokens,
    uint256[] memory amounts
  ) external onlyOwner {
    require(withdrawableAddress != address(0), 'ZERO_ADDRESS_NOT_ALLOWED');
    require(tokens.length == amounts.length, 'RESCUE_TOKEN_FAILED');

    uint8 len = uint8(tokens.length);
    uint8 i = 0;
    while (i < len) {
      TransferHelpers.safeTransfer(tokens[i], withdrawableAddress, amounts[i]);
      i++;
    }
  }

  /**
   * @inheritdoc IPlugRouterUpgradeable
   */
  function resuceEth(address withdrawableAddress, uint256 amount) external onlyOwner {
    require(withdrawableAddress != address(0), 'ZERO_ADDRESS_NOT_ALLOWED');
    TransferHelpers.safeTransferETH(withdrawableAddress, amount);
  }

  /**
   * @inheritdoc IPlugRouterUpgradeable
   */
  function setAggregatorsAndBridgeMap(bytes4[] memory ids, address[] memory routers) external onlyOwner {
    require(ids.length == routers.length, 'INVALID_LENGTH');
    uint8 len = uint8(ids.length);
    // iterate loop
    for (uint8 k = 0; k < len; k++) {
      require(ids[k] != bytes8(0), 'INVALID_ID');
      require(routers[k] != address(0), 'INVALID_ROUTER');
      aggregatorsAndBridgesMap[ids[k]] = routers[k];
    }

    emit SupportedAggregatorsAndBridges(ids, routers);
  }

  /**
   * @inheritdoc IPlugRouterUpgradeable
   */
  function pause() external onlyOwner {
    _pause();
  }

  /**
   * @inheritdoc IPlugRouterUpgradeable
   */
  function unpause() external onlyOwner {
    _unpause();
  }

  /**
   * @inheritdoc IPlugRouterUpgradeable
   */
  function startOrStopParticularUserAction(bytes4 action, bool lockStatus) external onlyOwner {
    lock[action] = lockStatus;
    emit LockedAction(action, lockStatus);
  }

  /**
   * @notice Set swap fee configuration
   * @param _swapFeePercentage The swap fee percentage
   * @param _swapFeeCollector The swap fee collector address
   */
  function _setSwapFeeConfig(uint256 _swapFeePercentage, address _swapFeeCollector) internal {
    require(_swapFeePercentage > 0, 'INVALID_SWAP_FEE_PERCENTAGE');
    require(_swapFeeCollector != address(0), 'INVALID_SWAP_FEE_COLLECTOR');
    swapFeeConfig = SwapFeeConfig({swapFeePercentage: _swapFeePercentage, swapFeeCollector: _swapFeeCollector});
    emit SwapFeeConfigAdded(_swapFeePercentage);
  }

  /**
   * @notice Approve spender to spend tokens for specific user action
   * @param token The token address to spend
   */
  function _approve(address spender, address token) internal {
    if (token != NATIVE_TOKEN_ADDRESS) {
      uint256 allowance = IERC20(token).allowance(address(this), spender);
      if (allowance == 0) {
        TransferHelpers.safeApprove(token, spender, type(uint256).max);
      }
    }
  }

  /**
   * @notice Derive the swap fee token
   * @param _fromToken The from token contract address
   * @param _toToken The to token contract address
   * @return feeToken The fee token address
   */
  function _getSwapFeeToken(address _fromToken, address _toToken) internal view returns (address feeToken) {
    bool hasFromToken = feeTokens[_fromToken];
    bool hasToToken = feeTokens[_toToken];

    if (hasFromToken && !hasToToken) {
      feeToken = _fromToken;
    } else if (hasToToken && !hasFromToken) {
      feeToken = _toToken;
    } else if (hasFromToken && hasToToken) {
      feeToken = _fromToken;
    } else {
      feeToken = _fromToken;
    }
  }

  /**
   * @notice Transfers tokens from plug router to recipient
   * @param token The token address which needs to transfer
   * @param recipient The receiver Wallet address
   * @param amount The amount to transfer
   */
  function _transfers(
    address token,
    address recipient,
    uint256 amount
  ) internal {
    if (token == NATIVE_TOKEN_ADDRESS) {
      TransferHelpers.safeTransferETH(recipient, amount);
    } else {
      TransferHelpers.safeTransfer(token, recipient, amount);
    }
  }

  /**
   * @notice Take fee function transfers fee tokens to swap fee collector
   * @param _swapFeeCollector The swap fee collector
   * @param _feeToken The fee token address
   * @param _amount The amount
   * @param _swapFeePercentage The swap fee percentage
   */
  function _takeFee(
    address _swapFeeCollector,
    address _feeToken,
    uint256 _amount,
    uint256 _swapFeePercentage
  ) internal returns (uint256 amount) {
    uint256 feeAmount = (_amount * _swapFeePercentage) / FEE_DENOMINATER;
    amount = _amount - feeAmount;
    _transfers(_feeToken, _swapFeeCollector, feeAmount);
  }

  /**
   * @notice Performing swap
   * @param _fromToken The from token contract address
   * @param _amount The amount to swap
   * @param _exchangeId The exchange Id
   * @param _swapCallData The call data for swap
   * @param _feeFlag The indicator for swap fee
   */
  function _swap(
    address _fromToken,
    uint256 _amount,
    bytes4 _exchangeId,
    bytes calldata _swapCallData,
    bool _feeFlag
  ) internal whenNotPaused returns (address outToken, uint256 swapedAmount) {
    require(_amount > 0, 'INSUFFICIENT_INPUT_AMOUNT');

    pullTokens(_fromToken, address(this), _amount);

    address exchangeRouter = aggregatorsAndBridgesMap[_exchangeId];
    require(exchangeRouter != address(0), 'EXCHANGE_NOT_SUPPORTED');

    // approve
    _approve(exchangeRouter, _fromToken);

    uint256 sClen = _swapCallData.length;
    bytes memory byteAddress = _swapCallData[(sClen - 20):sClen];

    // solhint-disable-next-line
    assembly {
      outToken := mload(add(byteAddress, 20))
    }
    // slice swap call data
    _swapCallData = _swapCallData[:sClen - 20];

    address feeToken = _getSwapFeeToken(_fromToken, outToken);
    address swapFeeCollector = swapFeeConfig.swapFeeCollector;
    // fee calculation
    uint256 swapFeePercentage = swapFeeConfig.swapFeePercentage;

    // check if some one send extra eth
    if (_fromToken == NATIVE_TOKEN_ADDRESS) {
      require(_amount == msg.value, 'INVALID_VALUE');
    }

    if (_feeFlag) {
      if (_fromToken == feeToken) {
        _amount = _takeFee(swapFeeCollector, feeToken, _amount, swapFeePercentage);
      }
    }

    // init swap
    uint256 value = _fromToken == NATIVE_TOKEN_ADDRESS ? _amount : msg.value;
    (bool success, ) = exchangeRouter.call{value: value}(_swapCallData);
    require(success, 'SWAP_FAILED');

    swapedAmount = outToken == NATIVE_TOKEN_ADDRESS ? address(this).balance : IERC20(outToken).balanceOf(address(this));
    require(swapedAmount > 0, 'INSUFFICIENT_OUPUT_AMOUNT');
    // after swap fee calculation
    if (_feeFlag) {
      if (outToken == feeToken) {
        swapedAmount = _takeFee(swapFeeCollector, feeToken, swapedAmount, swapFeePercentage);
      }
    }
  }

  /**
   * @notice Deposit tokens to bridge contract
   * @param recipient The receiver wallet address
   * @param token The token contract address
   * @param bridgeAdapter The bridge Adapter
   * @param amount The amount to bridge
   * @param bridgeCallData The bridge calldata
   */
  function _deposit(
    address recipient,
    address token,
    address bridgeAdapter,
    uint256 amount,
    bytes calldata bridgeCallData
  ) internal whenNotPaused returns (uint256 toChainId) {
    // bridge deposit call
    uint256 value = token == NATIVE_TOKEN_ADDRESS ? msg.value : 0;

    (toChainId) = IBridgeAdapter(bridgeAdapter).deposit{value: value}(amount, recipient, token, bridgeCallData);
  }

  /**
   * @notice Pull ERC20 tokens from user wallet address
   * @dev Also make sure you have provided proper token apporval to plug router
   * @param token The token contract address
   * @param amount The transferable amount
   */
  function pullTokens(
    address token,
    address receiver,
    uint256 amount
  ) internal {
    if (token != NATIVE_TOKEN_ADDRESS) {
      TransferHelpers.safeTransferFrom(token, _msgSender(), receiver, amount);
    }
  }

  /**
   * @notice Log on cross chain swap
   * @param affiliateAddr The affliate wallet address
   * @param fromToken The from token contract address
   * @param toToken The toToken token contract address
   * @param amount The swap input amount
   * @param swapedAmount The swap output amount
   * @param toChainId The destination ChainId
   * @param exchangeId The exchange Id
   * @param bridgeId The bridge Id
   */
  function _logCrossChainSwap(
    address affiliateAddr,
    address fromToken,
    address toToken,
    uint256 amount,
    uint256 swapedAmount,
    uint256 toChainId,
    bytes4 exchangeId,
    bytes4 bridgeId
  ) internal {
    emit CrossChainSwapPerformed(
      affiliateAddr,
      _msgSender(),
      fromToken,
      toToken,
      amount,
      swapedAmount,
      toChainId,
      exchangeId,
      bridgeId
    );
  }

  /** @dev This empty reserved space is put in place to allow future versions to add new
   variables without shifting down storage in the inheritance chain.
   See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
  */
  uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity =0.8.9;

import {ERC2771ContextUpgradeable} from '../metatx/ERC2771ContextUpgradeable.sol';
import {Initializable} from '../proxy/Initializable.sol';

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
// solhint-disable
abstract contract OwnableUpgradeable is Initializable, ERC2771ContextUpgradeable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  function __Ownable_init(address trustedForwarder) internal onlyInitializing {
    __Ownable_init_unchained();
    __ERC2771ContextUpgradeable_init(trustedForwarder);
  }

  function __Ownable_init_unchained() internal onlyInitializing {
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
    require(owner() == _msgSender(), 'Ownable: caller is not the owner');
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
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
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

pragma solidity =0.8.9;

/**
 * @title The Interface of Bridge Adapter
 * @author Plug Exchange
 * @notice Deposit the bridge token through specific bridge adapter contract
 */
interface IBridgeAdapter {
  /**
   * @notice Transfer The token from one chain to another chain
   * @param amount The amount to transfer
   * @param recipient The Recipient wallet address
   * @param token The token which needs to bridge
   * @param data The bridge call data
   */
  function deposit(
    uint256 amount,
    address recipient,
    address token,
    bytes calldata data
  ) external payable returns (uint256 toChainId);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity =0.8.9;

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

pragma solidity =0.8.9;

/**
 * @title IPlugRouterUpgradeable Interface
 * @author Plug
 * @notice performing swap,bridge deposit and crosschain Swap
 */
interface IPlugRouterUpgradeable {
  /**
   * @notice Perform swaps
   * @param affiliateAddr The affliate wallet address
   * @param fromToken The from token contract address
   * @param amount The amount to swap
   * @param exchangeId The exchange Id
   * @param swapCallData The call data for swap
   */
  function swap(
    address affiliateAddr,
    address fromToken,
    uint256 amount,
    bytes4 exchangeId,
    bytes memory swapCallData
  ) external payable;

  /**
   * @notice Perform cross chain swaps
   * @param affiliateAddr The affliate wallet address
   * @param fromToken The From token contract address
   * @param amount The amount to swap
   * @param exchangeId The Whitelisted exchange Id
   * @param bridgeId The Registered bridge Id
   * @param swapCallData The call data for swap action
   * @param bridgeCallData The call data for bridge action
   */
  function crossChainSwap(
    address affiliateAddr,
    address fromToken,
    uint256 amount,
    bytes4 exchangeId,
    bytes4 bridgeId,
    bytes calldata swapCallData,
    bytes calldata bridgeCallData
  ) external payable;

  /**
   * @notice Deposit tokens to bridge contract thorugh bridgeApdater
   * @param affiliateAddr The Affliate wallet address
   * @param token The Token contract address
   * @param amount The amount to bridge
   * @param bridgeId The bridge Id
   * @param bridgeCallData The call data for bridge action
   */
  function deposit(
    address affiliateAddr,
    address token,
    uint256 amount,
    bytes4 bridgeId,
    bytes calldata bridgeCallData
  ) external payable;

  /**
   * @notice Update swap fee config
   * @dev Call by current owner
   * @param _swapFeePercentage The swap fee percentage
   * @param _swapFeeCollector The swap fee collector address
   */
  function updateSwapFeeConfig(uint256 _swapFeePercentage, address _swapFeeCollector) external;

  /**
   * @notice Add specfic fee tokens
   * @dev Call by current owner
   * @param tokens The list of Fee tokens
   * @param flags The list of fee tokens status
   */
  function addFeeTokens(address[] memory tokens, bool[] memory flags) external;

  /**
   * @notice Rescue stuck tokens of plug router
   * @dev Call by current owner
   * @param withdrawableAddress The Address to withdraw this tokens
   * @param tokens The list of tokens
   * @param amounts The list of amounts
   */
  function rescueTokens(
    address withdrawableAddress,
    address[] memory tokens,
    uint256[] memory amounts
  ) external;

  /**
   * @notice Rescue stuck ETH of plug router
   * @dev Call by current owner
   * @param withdrawableAddress The Withdrawable Address
   * @param amount The value to withdraw
   */
  function resuceEth(address withdrawableAddress, uint256 amount) external;

  /**
   * @notice Whitelist aggregators and bridges
   * @dev Call by current owner
   * @param ids The bridges or aggregators ids
   * @param routers Their routers respectively
   */
  function setAggregatorsAndBridgeMap(bytes4[] memory ids, address[] memory routers) external;

  /**
   * @notice Pause Whole contract
   * @dev Call by current owner
   */
  function pause() external;

  /**
   * @notice Unpause Whole contract
   * @dev Call by current owner
   */
  function unpause() external;

  /**
   * @notice Start and Stop Particular User Action
   * @dev call by current owner
   * @param action The action magic value
   * @param lockStatus The lock status
   */
  function startOrStopParticularUserAction(bytes4 action, bool lockStatus) external;

  /**
   * @notice Emits when plug exchange owner sets the fee config
   * @param swapFeePercentage The swap fee percentage
   */
  event SwapFeeConfigAdded(uint256 swapFeePercentage);

  /**
   * @notice Emits when plug exchange owner add the fee tokens
   * @param feeTokens The list of Fee tokens
   * @param flags The list of fee tokens status
   */
  event FeeTokens(address[] feeTokens, bool[] flags);

  /**
   * @notice Emits when plug exchange owner whitelist the supported aggregators &
   * bridges
   * @param ids The bridges or aggregators ids
   * @param routers Their routers respectively
   */
  event SupportedAggregatorsAndBridges(bytes4[] ids, address[] routers);

  /**
   * @notice Emits when plug owner sets the locked for particular plug
   * exchange action
   * @param action The action magic value
   * @param lockStatus The lock status
   */
  event LockedAction(bytes4 action, bool lockStatus);

  /**
   * @notice Emits when plug users do swap with the plug router
   * @param affiliateAddr The affliate wallet address
   * @param user The recipient wallet address
   * @param fromToken The From token contract address
   * @param toToken The toToken token contract address
   * @param amount The Swap Input Amount
   * @param swapedAmount The Swap Output Amount
   * @param exchangeId The Exchange Id
   */
  event SwapPerformed(
    address affiliateAddr,
    address user,
    address fromToken,
    address toToken,
    uint256 amount,
    uint256 swapedAmount,
    bytes4 exchangeId
  );

  /**
   * @notice Emits when plug users do crosschain swap with the plug router
   * @param affiliateAddr The affliate wallet address
   * @param user The recipient wallet address
   * @param fromToken The From token contract address
   * @param toToken The toToken token contract address
   * @param amount The Swap Input Amount
   * @param swapedAmount The Swap Output Amount
   * @param toChainId The Destination ChainId
   * @param exchangeId The Exchange Id
   * @param bridgeId The Bridge Id
   */
  event CrossChainSwapPerformed(
    address affiliateAddr,
    address user,
    address fromToken,
    address toToken,
    uint256 amount,
    uint256 swapedAmount,
    uint256 toChainId,
    bytes4 exchangeId,
    bytes4 bridgeId
  );

  /**
   * @notice Emits when plug users deposit the token with the plug router
   * @param affiliateAddr The affliate wallet address
   * @param recipient The recipient wallet address
   * @param token The Token to bridge
   * @param amount The Swap Input Amount
   * @param toChainId The Destination ChainId
   * @param bridgeId The Bridge Id
   */
  event Deposit(
    address affiliateAddr,
    address recipient,
    address token,
    uint256 amount,
    uint256 toChainId,
    bytes4 bridgeId
  );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity =0.8.9;

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
    require(address(this).balance >= amount, 'Address: insufficient balance');

    (bool success, ) = recipient.call{value: amount}('');
    require(success, 'Address: unable to send value, recipient may have reverted');
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
    return functionCall(target, data, 'Address: low-level call failed');
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
    return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
    require(address(this).balance >= value, 'Address: insufficient balance for call');
    require(isContract(target), 'Address: call to non-contract');

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
    return functionStaticCall(target, data, 'Address: low-level static call failed');
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
    require(isContract(target), 'Address: static call to non-contract');

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

// SPDX-License-Identifier: GNU GPLv3

pragma solidity =0.8.9;

// solhint-disable avoid-low-level-calls

/**
 * @title The transfer helpers library
 * @author Plug Exchange
 * @notice Handles token transfers, approvals and ethereum transfers for protocol
 */
library TransferHelpers {
  /**
   * @dev Safe approve an ERC20 token
   * @param token an ERC20 token
   * @param to The spender address
   * @param value The value that will be approve
   */
  function safeApprove(
    address token,
    address to,
    uint256 value
  ) internal {
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
    require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: approval failed');
  }

  /**
   * @dev Token approvals must required
   * @param target The ERC20 token address
   * @param sender The sender wallet address
   * @param recipient The receiver wallet Address
   * @param amount The number of tokens to transfer
   */
  function safeTransferFrom(
    address target,
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    (bool success, ) = target.call(abi.encodeWithSelector(0x23b872dd, sender, recipient, amount));
    require(success, 'TransferHelper: transfer failed');
  }

  /**
   * @notice Transfer any ERC20 token
   * @param target The target contract address
   * @param to The receiver wallet address
   * @param amount The number of tokens to transfer
   */
  function safeTransfer(
    address target,
    address to,
    uint256 amount
  ) internal {
    (bool success, ) = target.call(abi.encodeWithSelector(0xa9059cbb, to, amount));
    require(success, 'TransferHelper: transfer failed');
  }

  /**
   * @notice Transfer ETH
   * @param to The receiver wallet address
   * @param value The ETH to transfer
   */
  function safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{value: uint128(value)}(new bytes(0));
    require(success, 'TransferHelper: transfer failed');
  }
}

// SPDX-License-Identifier: GNU GPLv3

pragma solidity =0.8.9;

import {Initializable} from '../proxy/Initializable.sol';

/**
 * @dev Context variant with ERC2771 support
 */

// solhint-disable
abstract contract ERC2771ContextUpgradeable is Initializable {
  /**
   * @dev holds the trust forwarder
   */

  address public trustedForwarder;

  /**
   * @dev context upgradeable initializer
   * @param _trustedForwarder trust forwarder
   */

  function __ERC2771ContextUpgradeable_init(address _trustedForwarder) internal onlyInitializing {
    __ERC2771ContextUpgradeable_init_unchained(_trustedForwarder);
  }

  /**
   * @dev called by initializer to set trust forwarder
   * @param _trustedForwarder trust forwarder
   */

  function __ERC2771ContextUpgradeable_init_unchained(address _trustedForwarder) internal {
    trustedForwarder = _trustedForwarder;
  }

  /**
   * @dev check if the given address is trust forwarder
   * @param forwarder forwarder address
   * @return isForwarder true/false
   */

  function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
    return forwarder == trustedForwarder;
  }

  /**
   * @dev if caller is trusted forwarder will return exact sender.
   * @return sender wallet address
   */

  function _msgSender() internal view virtual returns (address sender) {
    if (isTrustedForwarder(msg.sender)) {
      // The assembly code is more direct than the Solidity version using `abi.decode`.
      assembly {
        sender := shr(96, calldataload(sub(calldatasize(), 20)))
      }
    } else {
      return msg.sender;
    }
  }

  /**
   * @dev returns msg data for called function
   * @return function call data
   */

  function _msgData() internal view virtual returns (bytes calldata) {
    if (isTrustedForwarder(msg.sender)) {
      return msg.data[:msg.data.length - 20];
    } else {
      return msg.data;
    }
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity =0.8.9;

import '../libraries/AddressUpgradeable.sol';

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
    bool isTopLevelCall = _setInitializedVersion(1);
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
    bool isTopLevelCall = _setInitializedVersion(version);
    if (isTopLevelCall) {
      _initializing = true;
    }
    _;
    if (isTopLevelCall) {
      _initializing = false;
      emit Initialized(version);
    }
  }

  /**
   * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
   * {initializer} and {reinitializer} modifiers, directly or indirectly.
   */
  modifier onlyInitializing() {
    require(_initializing, 'Initializable: contract is not initializing');
    _;
  }

  /**
   * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
   * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
   * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
   * through proxies.
   */
  function _disableInitializers() internal virtual {
    _setInitializedVersion(type(uint8).max);
  }

  function _setInitializedVersion(uint8 version) private returns (bool) {
    // If the contract is initializing we ignore whether _initialized is set in order to support multiple
    // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
    // of initializers, because in other contexts the contract may have been reentered.
    if (_initializing) {
      require(
        version == 1 && !AddressUpgradeable.isContract(address(this)),
        'Initializable: contract is already initialized'
      );
      return false;
    } else {
      require(_initialized < version, 'Initializable: contract is already initialized');
      _initialized = version;
      return true;
    }
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity =0.8.9;

import {Initializable} from '../proxy/Initializable.sol';

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable {
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
    require(!paused(), 'Pausable: paused');
  }

  /**
   * @dev Throws if the contract is not paused.
   */
  function _requirePaused() internal view virtual {
    require(paused(), 'Pausable: not paused');
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
    emit Paused(msg.sender);
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
    emit Unpaused(msg.sender);
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity =0.8.9;

import {Initializable} from '../proxy/Initializable.sol';

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
  // Booleans are more expensive than uint256 or any type that takes up a full
  // word because each write operation emits an extra SLOAD to first read the
  // slot's contents, replace the bits taken up by the boolean, and then write
  // back. This is the compiler's defense against contract upgrades and
  // pointer aliasing, and it cannot be disabled.

  // The values being non-zero value makes deployment a bit more expensive,
  // but in exchange the refund on every call to nonReentrant will be lower in
  // amount. Since refunds are capped to a percentage of the total
  // transaction's gas, it is best to keep them low in cases like this one, to
  // increase the likelihood of the full refund coming into effect.
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  function __ReentrancyGuard_init() internal onlyInitializing {
    __ReentrancyGuard_init_unchained();
  }

  function __ReentrancyGuard_init_unchained() internal onlyInitializing {
    _status = _NOT_ENTERED;
  }

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * Calling a `nonReentrant` function from another `nonReentrant`
   * function is not supported. It is possible to prevent this from happening
   * by making the `nonReentrant` function external, and making it call a
   * `private` function that does the actual work.
   */
  modifier nonReentrant() {
    // On the first call to nonReentrant, _notEntered will be true
    require(_status != _ENTERED, 'ReentrancyGuard: reentrant call');

    // Any calls to nonReentrant after this point will fail
    _status = _ENTERED;

    _;

    // By storing the original value once again, a refund is triggered (see
    // https://eips.ethereum.org/EIPS/eip-2200)
    _status = _NOT_ENTERED;
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[49] private __gap;
}