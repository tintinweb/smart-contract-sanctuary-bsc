// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity =0.8.9;

import '../utils/Context.sol';

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
    require(owner() == _msgSender(), 'Ownable: caller is not the owner');
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
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.9;

// interface
import {IERC20} from '../interfaces/IERC20.sol';

// libs
import {TransferHelpers} from '../libraries/TransferHelpers.sol';

// contracts
import {Ownable} from '../access/Ownable.sol';

/**
 * @title AdapterBase Contract
 * @author Plug Exchange
 * @notice Implemented on each bridge apdater contracts
 */
abstract contract AdapterBase is Ownable {
  /**
   @notice Receive ethereum
   */
  receive() external payable {}

  /// @notice The plug router contract address
  address public immutable plugRouter;

  /// @notice The native token address
  address public constant NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  /**
   * @notice Initlization of base contract
   * @param _plugRouter The plug router contract address
   */
  constructor(address _plugRouter) {
    require(_plugRouter != address(0), 'INVALID_PLUG_ROUTER');
    plugRouter = _plugRouter;
  }

  /**
   * @notice Validate msg sender
   * @dev Throws error if sender is not plugRouter
   */
  modifier onlyPlugRouter() {
    _onlyPlugRouter();
    _;
  }

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
   * @notice Rescue stuck ETH of plug router
   * @dev Call by current owner
   * @param withdrawableAddress The withdrawable address
   * @param amount The value to withdraw
   */
  function resuceEth(address withdrawableAddress, uint256 amount) external onlyOwner {
    require(withdrawableAddress != address(0), 'ZERO_ADDRESS_NOT_ALLOWED');
    TransferHelpers.safeTransferETH(withdrawableAddress, amount);
  }

  /**
   * @notice Validate msg sender
   */
  function _onlyPlugRouter() internal view {
    require(msg.sender == plugRouter, 'ONLY_PLUG_ROUTER');
  }

  /**
   * @notice ERC20 Token approvals
   * @param token The token address to spend
   */
  function _approve(address spender, address token) internal {
    uint256 allowance = IERC20(token).allowance(address(this), spender);
    if (allowance == 0) {
      TransferHelpers.safeApprove(token, spender, type(uint256).max);
    }
  }

  /**
   * @notice Returns revert message thorough return data of a call
   * @dev Throws Error if there is no reason
   * @param _returnData The return data of delegate call
   * @return revertMessage The revert reason
   */
  function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
    // If the _res length is less than 68, then the transaction failed silently (without a revert message)
    if (_returnData.length < 68) return 'Unknown Error';

    // solhint-disable-next-line
    assembly {
      // Slice the sighash.
      _returnData := add(_returnData, 0x04)
    }
    return abi.decode(_returnData, (string)); // All that remains is the revert string
  }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.9;

// interfaces
import {IBridgeAdapter} from '../interfaces/IBridgeAdapter.sol';
// contracts
import {AdapterBase} from './AdapterBase.sol';

/**
 * @title The Multichain Adapter Contract
 * @author Plug Exchange
 * @notice Implemented multichain (previously anySwap) bridge contract
 * @dev Plug users can deposit the bridge token into the multichain bridge directly
 */
contract MultichainAdapter is IBridgeAdapter, AdapterBase {
  /// @dev The multi chain V4 router
  address private _multiChainV4Router;

  /**
   * @notice Initialization of multichain adapter contract
   * @param _plugRouter The plug router contract address
   */
  constructor(address _plugRouter, address multiChainV4Router_) AdapterBase(_plugRouter) {
    _multiChainV4Router = multiChainV4Router_;
  }

  /**
   * @notice Sets multichain v4 router contract address
   * @dev Called by only owner
   * @param multiChainV4Router_ The multi chain V4 router
   */
  function setMultichainV4Router(address multiChainV4Router_) external onlyOwner {
    _multiChainV4Router = multiChainV4Router_;
  }

  /**
   * @inheritdoc IBridgeAdapter
   */
  function deposit(
    uint256 amount,
    address recipient,
    address token,
    bytes calldata data
  ) external payable onlyPlugRouter returns (uint256 toChainId) {
    (address router, address anyToken, uint256 chainId) = abi.decode(data, (address, address, uint256));

    toChainId = chainId;
    bool success;
    bytes memory result;
    if (token == NATIVE_TOKEN_ADDRESS) {
      require(router != address(0), 'INVALID_MULTICHAIN_ROUTER');
      (success, result) = router.call{value: msg.value}(
        abi.encodeWithSignature('anySwapOutNative(address,address,uint256)', anyToken, recipient, chainId)
      );
    } else {
      _approve(_multiChainV4Router, token);
      (success, result) = _multiChainV4Router.call(
        abi.encodeWithSignature(
          'anySwapOutUnderlying(address,address,uint256,uint256)',
          anyToken,
          recipient,
          amount,
          chainId
        )
      );
    }

    require(success, _getRevertMsg(result));
  }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity =0.8.9;

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