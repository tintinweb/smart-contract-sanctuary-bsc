/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

// Sources flattened with hardhat v2.11.2 https://hardhat.org

// File contracts/interfaces/IEmergencyGuard.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IEmergencyGuard {
    /**
     * Emitted on BNB withdrawal
     *
     * @param receiver address - Receiver of BNB
     * @param amount uint256 - BNB amount
     */
    event EmergencyWithdraw(address receiver, uint256 amount);

    /**
     * Emitted on token withdrawal
     *
     * @param receiver address - Receiver of token
     * @param token address - Token address
     * @param amount uint256 - token amount
     */
    event EmergencyWithdrawToken(
        address receiver,
        address token,
        uint256 amount
    );

    /**
     * Withdraws BNB stores at the contract
     *
     * @param amount uint256 - Amount of BNB to withdraw
     */
    function emergencyWithdraw(uint256 amount) external;

    /**
     * Withdraws token stores at the contract
     *
     * @param token address - Token to withdraw
     * @param amount uint256 - Amount of token to withdraw
     */
    function emergencyWithdrawToken(address token, uint256 amount) external;
}

// File @openzeppelin/contracts/token/ERC20/[email protected]

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

// File contracts/EmergencyGuard.sol

pragma solidity 0.8.17;

abstract contract EmergencyGuard is IEmergencyGuard {
    function _emergencyWithdraw(uint256 amount) internal virtual {
        address payable sender = payable(msg.sender);
        (bool sent, ) = sender.call{value: amount}("");
        require(sent, "WeSendit: Failed to send BNB");

        emit EmergencyWithdraw(msg.sender, amount);
    }

    function _emergencyWithdrawToken(
        address token,
        uint256 amount
    ) internal virtual {
        IERC20(token).transfer(msg.sender, amount);
        emit EmergencyWithdrawToken(msg.sender, token, amount);
    }
}

// File contracts/interfaces/IPancakeRouter.sol

pragma solidity 0.8.17;

interface IPancakeRouter01 {
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
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

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

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

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

// File contracts/interfaces/IDynamicFeeManager.sol

pragma solidity 0.8.17;

/**
 * Fee entry structure
 */
struct FeeEntry {
    // Unique identifier for the fee entry
    // Generated out of (destination, doLiquify, doSwapForBusd, swapOrLiquifyAmount) to
    // always use the same feeEntryAmounts entry.
    bytes32 id;
    // Sender address OR wildcard address
    address from;
    // Receiver address OR wildcard address
    address to;
    // Fee percentage multiplied by 100000
    uint256 percentage;
    // Fee destination address
    address destination;
    // Indicator, if callback should be called on the destination address
    bool doCallback;
    // Indicator, if the fee amount should be used to add liquidation on DEX
    bool doLiquify;
    // Indicator, if the fee amount should be swapped to BUSD
    bool doSwapForBusd;
    // Amount used to add liquidation OR swap to BUSD
    uint256 swapOrLiquifyAmount;
    // Timestamp after which the fee won't be applied anymore
    uint256 expiresAt;
}

interface IDynamicFeeManager {
    /**
     * Emitted on fee addition
     *
     * @param id bytes32 - "Unique" identifier for fee entry
     * @param from address - Sender address OR address(0) for wildcard
     * @param to address - Receiver address OR address(0) for wildcard
     * @param percentage uint256 - Fee percentage to take multiplied by 100000
     * @param destination address - Destination address for the fee
     * @param doCallback bool - Indicates, if a callback should be called at the fee destination
     * @param doLiquify bool - Indicates, if the fee amount should be used to add liquidy on DEX
     * @param doSwapForBusd bool - Indicates, if the fee amount should be swapped to BUSD
     * @param swapOrLiquifyAmount uint256 - Amount for liquidify or swap
     * @param expiresAt uint256 - Timestamp after which the fee won't be applied anymore
     */
    event FeeAdded(
        bytes32 indexed id,
        address indexed from,
        address to,
        uint256 percentage,
        address indexed destination,
        bool doCallback,
        bool doLiquify,
        bool doSwapForBusd,
        uint256 swapOrLiquifyAmount,
        uint256 expiresAt
    );

    /**
     * Emitted on fee removal
     *
     * @param id bytes32 - "Unique" identifier for fee entry
     * @param index uint256 - Index of removed the fee
     */
    event FeeRemoved(bytes32 indexed id, uint256 index);

    /**
     * Emitted on fee reflection / distribution
     *
     * @param id bytes32 - "Unique" identifier for fee entry
     * @param token address - Token used for fee
     * @param from address - Sender address OR address(0) for wildcard
     * @param to address - Receiver address OR address(0) for wildcard
     * @param destination address - Destination address for the fee
     * @param doCallback bool - Indicates, if a callback should be called at the fee destination
     * @param doLiquify bool - Indicates, if the fee amount should be used to add liquidy on DEX
     * @param doSwapForBusd bool - Indicates, if the fee amount should be swapped to BUSD
     * @param swapOrLiquifyAmount uint256 - Amount for liquidify or swap
     * @param expiresAt uint256 - Timestamp after which the fee won't be applied anymore
     */
    event FeeReflected(
        bytes32 indexed id,
        address token,
        address indexed from,
        address to,
        uint256 tFee,
        address indexed destination,
        bool doCallback,
        bool doLiquify,
        bool doSwapForBusd,
        uint256 swapOrLiquifyAmount,
        uint256 expiresAt
    );

    /**
     * Emitted on fee state update
     *
     * @param enabled bool - Indicates if fees are enabled now
     */
    event FeeEnabledUpdated(bool enabled);

    /**
     * Emitted on pancake router address update
     *
     * @param newAddress address - New pancake router address
     */
    event PancakeRouterUpdated(address newAddress);

    /**
     * Emitted on BUSD address update
     *
     * @param newAddress address - New BUSD address
     */
    event BusdAddressUpdated(address newAddress);

    /**
     * Emitted on fee limits (fee percentage and transsaction limit) decrease
     */
    event FeeLimitsDecreased();

    /**
     * Emitted on volume percentage for swap events updated
     *
     * @param newPercentage uint256 - New volume percentage for swap events
     */
    event PercentageVolumeSwapUpdated(uint256 newPercentage);

    /**
     * Emitted on volume percentage for liquify events updated
     *
     * @param newPercentage uint256 - New volume percentage for liquify events
     */
    event PercentageVolumeLiquifyUpdated(uint256 newPercentage);

    /**
     * Emitted on Pancakeswap pair (WSI <-> BUSD) address updated
     *
     * @param newAddress address - New pair address
     */
    event PancakePairBusdUpdated(address newAddress);

    /**
     * Emitted on Pancakeswap pair (WSI <-> BNB) address updated
     *
     * @param newAddress address - New pair address
     */
    event PancakePairBnbUpdated(address newAddress);

    /**
     * Emitted on swap and liquify event
     *
     * @param firstHalf uint256 - Half of tokens
     * @param newBalance uint256 - Amount of BNB
     * @param secondHalf uint256 - Half of tokens for BNB swap
     */
    event SwapAndLiquify(
        uint256 firstHalf,
        uint256 newBalance,
        uint256 secondHalf
    );

    /**
     * Emitted on token swap to BUSD
     *
     * @param token address - Token used for swap
     * @param inputAmount uint256 - Amount used as input for swap
     * @param newBalance uint256 - Amount of received BUSD
     * @param destination address - Destination address for BUSD
     */
    event SwapTokenForBusd(
        address token,
        uint256 inputAmount,
        uint256 newBalance,
        address indexed destination
    );

    /**
     * Return the fee entry at the given index
     *
     * @param index uint256 - Index of the fee entry
     *
     * @return fee FeeEntry - Fee entry
     */
    function getFee(uint256 index) external view returns (FeeEntry memory fee);

    /**
     * Adds a fee entry to the list of fees
     *
     * @param from address - Sender address OR wildcard address
     * @param to address - Receiver address OR wildcard address
     * @param percentage uint256 - Fee percentage to take multiplied by 100000
     * @param destination address - Destination address for the fee
     * @param doCallback bool - Indicates, if a callback should be called at the fee destination
     * @param doLiquify bool - Indicates, if the fee amount should be used to add liquidy on DEX
     * @param doSwapForBusd bool - Indicates, if the fee amount should be swapped to BUSD
     * @param swapOrLiquifyAmount uint256 - Amount for liquidify or swap
     * @param expiresAt uint256 - Timestamp after which the fee won't be applied anymore
     *
     * @return index uint256 - Index of the newly added fee entry
     */
    function addFee(
        address from,
        address to,
        uint256 percentage,
        address destination,
        bool doCallback,
        bool doLiquify,
        bool doSwapForBusd,
        uint256 swapOrLiquifyAmount,
        uint256 expiresAt
    ) external returns (uint256 index);

    /**
     * Removes the fee entry at the given index
     *
     * @param index uint256 - Index to remove
     */
    function removeFee(uint256 index) external;

    /**
     * Reflects the fee for a transaction
     *
     * @param from address - Sender address
     * @param to address - Receiver address
     * @param amount uint256 - Transaction amount
     *
     * @return tTotal uint256 - Total transaction amount after fees
     * @return tFees uint256 - Total fee amount
     */
    function reflectFees(
        address from,
        address to,
        uint256 amount
    ) external returns (uint256 tTotal, uint256 tFees);

    /**
     * Returns the collected amount for swap / liquify fees
     *
     * @param id bytes32 - Fee entry id
     *
     * @return amount uint256 - Collected amount
     */
    function getFeeAmount(bytes32 id) external view returns (uint256 amount);

    /**
     * Returns true if fees are enabled, false when disabled
     *
     * @param value bool - Indicates if fees are enabled
     */
    function feesEnabled() external view returns (bool value);

    /**
     * Sets the transaction fee state
     *
     * @param value bool - true to enable fees, false to disable
     */
    function setFeesEnabled(bool value) external;

    /**
     * Returns the pancake router
     *
     * @return value IPancakeRouter02 - Pancake router
     */
    function pancakeRouter() external view returns (IPancakeRouter02 value);

    /**
     * Sets the pancake router
     *
     * @param value address - New pancake router address
     */
    function setPancakeRouter(address value) external;

    /**
     * Returns the BUSD address
     *
     * @return value address - BUSD address
     */
    function busdAddress() external view returns (address value);

    /**
     * Sets the BUSD address
     *
     * @param value address - BUSD address
     */
    function setBusdAddress(address value) external;

    /**
     * Returns the fee decrease status
     *
     * @return value bool - True if fees are already decreased, false if not
     */
    function feeDecreased() external view returns (bool value);

    /**
     * Returns the fee entry percentage limit
     *
     * @return value uint256 - Fee entry percentage limit
     */
    function feePercentageLimit() external view returns (uint256 value);

    /**
     * Returns the overall transaction fee limit
     *
     * @return value uint256 - Transaction fee limit in percent
     */
    function transactionFeeLimit() external view returns (uint256 value);

    /**
     * Decreases the fee limits from initial values (used for bot protection), to normal values
     */
    function decreaseFeeLimits() external;

    /**
     * Returns the current volume percentage for swap events
     *
     * @return value uint256 - Volume percentage for swap events
     */
    function percentageVolumeSwap() external view returns (uint256 value);

    /**
     * Sets the volume percentage for swap events
     * If set to zero, swapping based on volume will be disabled and fee.swapOrLiquifyAmount is used.
     *
     * @param value uint256 - New volume percentage for swapping
     */
    function setPercentageVolumeSwap(uint256 value) external;

    /**
     * Returns the current volume percentage for liquify events
     *
     * @return value uint256 - Volume percentage for liquify events
     */
    function percentageVolumeLiquify() external view returns (uint256 value);

    /**
     * Sets the volume percentage for liquify events
     * If set to zero, adding liquidity based on volume will be disabled and fee.swapOrLiquifyAmount is used.
     *
     * @param value uint256 - New volume percentage for adding liquidity
     */
    function setPercentageVolumeLiquify(uint256 value) external;

    /**
     * Returns the Pancakeswap pair address (WSI <-> BUSD)
     *
     * @return value address - Pair address
     */
    function pancakePairBusdAddress() external view returns (address value);

    /**
     * Sets the Pancakeswap pair address (WSI <-> BUSD)
     *
     * @param value address - New pair address
     */
    function setPancakePairBusdAddress(address value) external;

    /**
     * Returns the Pancakeswap pair address (WSI <-> BNB)
     *
     * @return value address - Pair address
     */
    function pancakePairBnbAddress() external view returns (address value);

    /**
     * Sets the Pancakeswap pair address (WSI <-> BNB)
     *
     * @param value address - New pair address
     */
    function setPancakePairBnbAddress(address value) external;

    /**
     * Returns the WeSendit token instance
     *
     * @return value IERC20 - WeSendit Token instance
     */
    function token() external view returns (IERC20 value);
}

// File @openzeppelin/contracts/utils/[email protected]

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

// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(
        bytes32 role,
        uint256 index
    ) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// File @openzeppelin/contracts/utils/introspection/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File @openzeppelin/contracts/utils/introspection/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IAccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(
        bytes32 role
    ) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(
        bytes32 role,
        address account
    ) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(
        bytes32 role,
        address account
    ) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(
        bytes32 role,
        address account
    ) public virtual override {
        require(
            account == _msgSender(),
            "AccessControl: can only renounce roles for self"
        );

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File @openzeppelin/contracts/utils/structs/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(
        Set storage set,
        bytes32 value
    ) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(
        Set storage set,
        uint256 index
    ) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(
        Bytes32Set storage set,
        bytes32 value
    ) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(
        Bytes32Set storage set,
        bytes32 value
    ) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(
        Bytes32Set storage set,
        bytes32 value
    ) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(
        Bytes32Set storage set,
        uint256 index
    ) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(
        Bytes32Set storage set
    ) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(
        AddressSet storage set,
        address value
    ) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(
        AddressSet storage set,
        address value
    ) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(
        AddressSet storage set,
        address value
    ) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(
        AddressSet storage set,
        uint256 index
    ) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(
        AddressSet storage set
    ) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(
        UintSet storage set,
        uint256 value
    ) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(
        UintSet storage set,
        uint256 value
    ) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(
        UintSet storage set,
        uint256 index
    ) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(
        UintSet storage set
    ) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is
    IAccessControlEnumerable,
    AccessControl
{
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IAccessControlEnumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(
        bytes32 role,
        uint256 index
    ) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(
        bytes32 role
    ) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(
        bytes32 role,
        address account
    ) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(
        bytes32 role,
        address account
    ) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}

// File @openzeppelin/contracts/security/[email protected]

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File contracts/BaseDynamicFeeManager.sol

pragma solidity 0.8.17;

/**
 * @title Base Dynamic Fee Manager
 */
abstract contract BaseDynamicFeeManager is
    IDynamicFeeManager,
    EmergencyGuard,
    AccessControlEnumerable,
    Ownable,
    ReentrancyGuard
{
    // Role allowed to do admin operations like adding to fee whitelist, withdraw, etc.
    bytes32 public constant ADMIN = keccak256("ADMIN");

    // Role allowed to bypass fees
    bytes32 public constant FEE_WHITELIST = keccak256("FEE_WHITELIST");

    // Role allowed to token be sent to without fee
    bytes32 public constant RECEIVER_FEE_WHITELIST =
        keccak256("RECEIVER_FEE_WHITELIST");

    // Role allowed to bypass swap and liquify
    bytes32 public constant BYPASS_SWAP_AND_LIQUIFY =
        keccak256("BYPASS_SWAP_AND_LIQUIFY");

    // Role allowed to bypass wildcard fees
    bytes32 public constant EXCLUDE_WILDCARD_FEE =
        keccak256("EXCLUDE_WILDCARD_FEE");

    // Role allowed to call reflectFees
    bytes32 public constant CALL_REFLECT_FEES = keccak256("CALL_REFLECT_FEES");

    // Fee percentage limit
    uint256 public constant FEE_PERCENTAGE_LIMIT = 10_000; // 10%

    // Fee percentage limit on creation
    uint256 public constant INITIAL_FEE_PERCENTAGE_LIMIT = 25_000; // 25%

    // Transaction fee limit
    uint256 public constant TRANSACTION_FEE_LIMIT = 10_000; // 10%

    // Transaction fee limit on creation
    uint256 public constant INITIAL_TRANSACTION_FEE_LIMIT = 25_000; // 25%

    // Max. amount for fee entries
    uint256 public constant MAX_FEE_AMOUNT = 30;

    // Min. amount for swap / liquify
    uint256 public constant MIN_SWAP_OR_LIQUIFY_AMOUNT = 1 ether;

    // Fee divider
    uint256 internal constant FEE_DIVIDER = 100_000;

    // Wildcard address for fees
    address internal constant WHITELIST_ADDRESS =
        0x000000000000000000000000000000000000dEaD;

    // List of all currently added fees
    FeeEntry[] internal feeEntries;

    // Mapping id to current swap or liquify amounts
    mapping(bytes32 => uint256) internal feeEntryAmounts;

    // Fees enabled state
    bool internal feesEnabled_ = false;

    // Pancake Router address
    IPancakeRouter02 private _pancakeRouter =
        IPancakeRouter02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));

    // BUSD address
    address private _busdAddress;

    // Fee Decrease status
    bool private _feeDecreased = false;

    // Volume percentage for swap events
    uint256 private _percentageVolumeSwap = 0;

    // Volume percentage for liquify events
    uint256 private _percentageVolumeLiquify = 0;

    // Pancakeswap Pair (WSI <-> BUSD) address
    address private _pancakePairBusdAddress;

    // Pancakeswap Pair (WSI <-> BNB) address
    address private _pancakePairBnbAddress;

    // WeSendit token
    IERC20 private _token;

    constructor(address wesenditToken) {
        // Add creator to admin role
        _setupRole(ADMIN, _msgSender());

        // Set role admin for roles
        _setRoleAdmin(ADMIN, ADMIN);
        _setRoleAdmin(FEE_WHITELIST, ADMIN);
        _setRoleAdmin(RECEIVER_FEE_WHITELIST, ADMIN);
        _setRoleAdmin(BYPASS_SWAP_AND_LIQUIFY, ADMIN);
        _setRoleAdmin(EXCLUDE_WILDCARD_FEE, ADMIN);
        _setRoleAdmin(CALL_REFLECT_FEES, ADMIN);

        // Create WeSendit token instance
        _token = IERC20(wesenditToken);
    }

    /**
     * Getter & Setter
     */
    function getFee(
        uint256 index
    ) external view override returns (FeeEntry memory fee) {
        return feeEntries[index];
    }

    function getFeeAmount(
        bytes32 id
    ) external view override returns (uint256 amount) {
        return feeEntryAmounts[id];
    }

    function setFeesEnabled(bool value) external override onlyRole(ADMIN) {
        feesEnabled_ = value;

        emit FeeEnabledUpdated(value);
    }

    function setPancakeRouter(address value) external override onlyRole(ADMIN) {
        require(
            value != address(0),
            "DynamicFeeManager: Cannot set Pancake Router to zero address"
        );

        _pancakeRouter = IPancakeRouter02(value);
        emit PancakeRouterUpdated(value);
    }

    function setBusdAddress(address value) external override onlyRole(ADMIN) {
        require(
            value != address(0),
            "DynamicFeeManager: Cannot set BUSD to zero address"
        );

        _busdAddress = value;
        emit BusdAddressUpdated(value);
    }

    function feeDecreased() external view override returns (bool value) {
        return _feeDecreased;
    }

    function decreaseFeeLimits() external override onlyRole(ADMIN) {
        require(
            !_feeDecreased,
            "DynamicFeeManager: Fee limits are already decreased"
        );

        _feeDecreased = true;

        emit FeeLimitsDecreased();
    }

    function emergencyWithdraw(
        uint256 amount
    ) external override onlyRole(ADMIN) {
        super._emergencyWithdraw(amount);
    }

    function emergencyWithdrawToken(
        address tokenToWithdraw,
        uint256 amount
    ) external override onlyRole(ADMIN) {
        super._emergencyWithdrawToken(tokenToWithdraw, amount);
    }

    function setPercentageVolumeSwap(
        uint256 value
    ) external override onlyRole(ADMIN) {
        require(
            value <= 100,
            "DynamicFeeManager: Invalid percentage volume swap value"
        );

        _percentageVolumeSwap = value;

        emit PercentageVolumeSwapUpdated(value);
    }

    function setPercentageVolumeLiquify(
        uint256 value
    ) external override onlyRole(ADMIN) {
        require(
            value <= 100,
            "DynamicFeeManager: Invalid percentage volume liquify value"
        );

        _percentageVolumeLiquify = value;

        emit PercentageVolumeLiquifyUpdated(value);
    }

    function setPancakePairBusdAddress(
        address value
    ) external override onlyRole(ADMIN) {
        require(
            value != address(0),
            "DynamicFeeManager: Cannot set BUSD pair to zero address"
        );

        _pancakePairBusdAddress = value;

        emit PancakePairBusdUpdated(value);
    }

    function setPancakePairBnbAddress(
        address value
    ) external override onlyRole(ADMIN) {
        require(
            value != address(0),
            "DynamicFeeManager: Cannot set BNB pair to zero address"
        );

        _pancakePairBnbAddress = value;

        emit PancakePairBnbUpdated(value);
    }

    function feesEnabled() public view override returns (bool) {
        return feesEnabled_;
    }

    function pancakeRouter()
        public
        view
        override
        returns (IPancakeRouter02 value)
    {
        return _pancakeRouter;
    }

    function busdAddress() public view override returns (address value) {
        return _busdAddress;
    }

    function feePercentageLimit() public view override returns (uint256 value) {
        return
            _feeDecreased ? FEE_PERCENTAGE_LIMIT : INITIAL_FEE_PERCENTAGE_LIMIT;
    }

    function transactionFeeLimit()
        public
        view
        override
        returns (uint256 value)
    {
        return
            _feeDecreased
                ? TRANSACTION_FEE_LIMIT
                : INITIAL_TRANSACTION_FEE_LIMIT;
    }

    function percentageVolumeSwap()
        public
        view
        override
        returns (uint256 value)
    {
        return _percentageVolumeSwap;
    }

    function percentageVolumeLiquify()
        public
        view
        override
        returns (uint256 value)
    {
        return _percentageVolumeLiquify;
    }

    function pancakePairBusdAddress()
        public
        view
        override
        returns (address value)
    {
        return _pancakePairBusdAddress;
    }

    function pancakePairBnbAddress()
        public
        view
        override
        returns (address value)
    {
        return _pancakePairBnbAddress;
    }

    function token() public view override returns (IERC20 value) {
        return _token;
    }

    /**
     * Swaps half of the token amount and add liquidity on Pancakeswap
     *
     * @param amount uint256 - Amount to use
     * @param destination address - Destination address for the LP tokens
     *
     * @return tokenSwapped uint256 - Amount of token which have been swapped
     */
    function _swapAndLiquify(
        uint256 amount,
        address destination
    ) internal nonReentrant returns (uint256 tokenSwapped) {
        // split the contract balance into halves
        uint256 half = amount / 2;
        uint256 otherHalf = amount - half;

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        _swapTokensForBnb(half, address(this));

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to uniswap
        uint256 tokenLiquified = _addLiquidity(
            otherHalf,
            newBalance,
            destination
        );

        emit SwapAndLiquify(half, newBalance, otherHalf);

        return half + tokenLiquified;
    }

    /**
     * Swaps tokens against BNB on Pancakeswap
     *
     * @param amount uint256 - Amount to use
     * @param destination address - Destination address for BNB
     */
    function _swapTokensForBnb(uint256 amount, address destination) internal {
        // generate the uniswap pair path of token -> wbnb
        address[] memory path = new address[](2);
        path[0] = address(token());
        path[1] = pancakeRouter().WETH();

        require(
            token().approve(address(pancakeRouter()), amount),
            "DynamicFeeManager: Failed to approve token for swap to BNB"
        );

        // make the swap
        pancakeRouter().swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of BNB
            path,
            destination,
            block.timestamp
        );
    }

    /**
     * Swaps tokens against BUSD on Pancakeswap
     *
     * @param amount uint256 - Amount to use
     * @param destination address - Destination address for BUSD
     */
    function _swapTokensForBusd(
        uint256 amount,
        address destination
    ) internal nonReentrant {
        // generate the uniswap pair path of token -> wbnb
        address[] memory path = new address[](2);
        path[0] = address(token());
        path[1] = busdAddress();

        require(
            token().approve(address(pancakeRouter()), amount),
            "DynamicFeeManager: Failed to approve token for swap to BUSD"
        );

        // capture the contract's current balances
        uint256 initialBalance = IERC20(busdAddress()).balanceOf(destination);

        // make the swap
        pancakeRouter().swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of BUSD
            path,
            destination,
            block.timestamp
        );

        // how much BUSD did we just swap into?
        uint256 newBalance = IERC20(busdAddress()).balanceOf(destination) -
            initialBalance;

        emit SwapTokenForBusd(
            address(token()),
            amount,
            newBalance,
            destination
        );
    }

    /**
     * Creates liquidity on Pancakeswap
     *
     * @param tokenAmount uint256 - Amount of token to use
     * @param bnbAmount uint256 - Amount of BNB to use
     * @param destination address - Destination address for the LP tokens
     *
     * @return tokenSwapped uint256 - Amount of token which have been swapped
     */
    function _addLiquidity(
        uint256 tokenAmount,
        uint256 bnbAmount,
        address destination
    ) internal returns (uint256 tokenSwapped) {
        // approve token transfer to cover all possible scenarios
        require(
            token().approve(address(pancakeRouter()), tokenAmount),
            "DynamicFeeManager: Failed to approve token for adding liquidity"
        );

        // add the liquidity
        (tokenSwapped, , ) = pancakeRouter().addLiquidityETH{value: bnbAmount}(
            address(token()),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            destination,
            block.timestamp
        );

        return tokenSwapped;
    }

    /**
     * Returns the amount used for swap / liquify based on volume percentage for swap / liquify
     *
     * @param feeId bytes32 - Fee entry id
     * @param swapOrLiquifyAmount uint256 - Fee entry swap or liquify amount
     * @param percentageVolume uint256 - Volume percentage for swap / liquify
     * @param pancakePairAddress address - Pancakeswap pair address to use for volume
     *
     * @return amount uint256 - Amount used for swap / liquify
     */
    function _getSwapOrLiquifyAmount(
        bytes32 feeId,
        uint256 swapOrLiquifyAmount,
        uint256 percentageVolume,
        address pancakePairAddress
    ) internal view returns (uint256 amount) {
        // If no percentage and fixed amount is set, use balance
        if (percentageVolume == 0 && swapOrLiquifyAmount == 0) {
            return feeEntryAmounts[feeId];
        }

        if (pancakePairAddress == address(0) || percentageVolume == 0) {
            return swapOrLiquifyAmount;
        }

        // Get pancakeswap pair token balance to identify, how many
        // token are currently on the market
        uint256 pancakePairTokenBalance = token().balanceOf(pancakePairAddress);

        // Calculate percentual amount of volume
        uint256 percentualAmount = (pancakePairTokenBalance *
            percentageVolume) / 100;

        // If swap or liquify amount is zero, and percentual amount is
        // higher than collected amount, return collected amount, otherwise
        // return percentual amount
        if (swapOrLiquifyAmount == 0) {
            return
                percentualAmount > feeEntryAmounts[feeId]
                    ? feeEntryAmounts[feeId]
                    : percentualAmount;
        }

        // Do not exceed swap or liquify amount from fee entry
        if (percentualAmount >= swapOrLiquifyAmount) {
            return swapOrLiquifyAmount;
        }

        return percentualAmount;
    }
}

// File contracts/interfaces/IStakingPool.sol

pragma solidity 0.8.17;

/**
 * Pool object structure
 */
struct Pool {
    // Unique identifier for the pool
    // Generated out of (destination, doLiquify, doSwapForBusd, swapOrLiquifyAmount) to
    // always use the same feeEntryAmounts entry.
    bytes32 id;
    // Last block rewards were paid
    uint256 lastRewardBlock;
}

/**
 * Pool staking entry object structure
 */
struct PoolEntry {
    address account;
    uint256 locked;
    uint256 pendingRewards;
}

interface IStakingPool {
    /**
     * Returns the total amount of token locked inside the pool
     *
     * @return value uint256 - Total amount of token locked
     */
    function totalValueLocked() external pure returns (uint256 value);

    function maxDuration() external pure returns (uint256 duration);

    function minDuration() external pure returns (uint256 duration);

    function maxAmount() external pure returns (uint256 amount);

    function compoundInterval() external pure returns (uint256 interval);

    function poolBalance() external view returns (uint256 balance);

    function poolAllocation() external pure returns (uint256 allocation);

    function pendingRewards() external pure returns (uint256 pendingRewards);

    function lastRewardsBlock() external pure returns (uint256 block);

    function token() external view returns (IERC20 token);

    function apy(
        uint256 amount,
        uint256 duration
    ) external pure returns (uint256 apy);

    function poolFactor(
        uint256 balance
    ) external view returns (uint256 poolFactor);

    function getEntries(
        address account
    ) external view returns (PoolEntry[] memory entries);

    function stake(
        uint256 amount,
        uint256 duration
    ) external returns (bytes32 entryId);

    function unstake(bytes32 entryId) external;

    function compound(bytes32 entryId) external;

    function updatePool() external;
}

// File contracts/utils/Trigonometry.sol

pragma solidity ^0.8.0;

/**
 * @notice Solidity library offering basic trigonometry functions where inputs and outputs are
 * integers. Inputs are specified in radians scaled by 1e18, and similarly outputs are scaled by 1e18.
 *
 * This implementation is based off the Solidity trigonometry library written by Lefteris Karapetsas
 * which can be found here: https://github.com/Sikorkaio/sikorka/blob/e75c91925c914beaedf4841c0336a806f2b5f66d/contracts/trigonometry.sol
 *
 * Compared to Lefteris' implementation, this version makes the following changes:
 *   - Uses a 32 bits instead of 16 bits for improved accuracy
 *   - Updated for Solidity 0.8.x
 *   - Various gas optimizations
 *   - Change inputs/outputs to standard trig format (scaled by 1e18) instead of requiring the
 *     integer format used by the algorithm
 *
 * Lefertis' implementation is based off Dave Dribin's trigint C library
 *     http://www.dribin.org/dave/trigint/
 *
 * Which in turn is based from a now deleted article which can be found in the Wayback Machine:
 *     http://web.archive.org/web/20120301144605/http://www.dattalo.com/technical/software/pic/picsine.html
 */
library Trigonometry {
    // Table index into the trigonometric table
    uint256 constant INDEX_WIDTH = 8;
    // Interpolation between successive entries in the table
    uint256 constant INTERP_WIDTH = 16;
    uint256 constant INDEX_OFFSET = 28 - INDEX_WIDTH;
    uint256 constant INTERP_OFFSET = INDEX_OFFSET - INTERP_WIDTH;
    uint32 constant ANGLES_IN_CYCLE = 1073741824;
    uint32 constant QUADRANT_HIGH_MASK = 536870912;
    uint32 constant QUADRANT_LOW_MASK = 268435456;
    uint256 constant SINE_TABLE_SIZE = 256;

    // Pi as an 18 decimal value, which is plenty of accuracy: "For JPL's highest accuracy calculations, which are for
    // interplanetary navigation, we use 3.141592653589793: https://www.jpl.nasa.gov/edu/news/2016/3/16/how-many-decimals-of-pi-do-we-really-need/
    uint256 constant PI = 3141592653589793238;
    uint256 constant TWO_PI = 2 * PI;
    uint256 constant PI_OVER_TWO = PI / 2;

    // The constant sine lookup table was generated by generate_trigonometry.py. We must use a constant
    // bytes array because constant arrays are not supported in Solidity. Each entry in the lookup
    // table is 4 bytes. Since we're using 32-bit parameters for the lookup table, we get a table size
    // of 2^(32/4) + 1 = 257, where the first and last entries are equivalent (hence the table size of
    // 256 defined above)
    uint8 constant entry_bytes = 4; // each entry in the lookup table is 4 bytes
    uint256 constant entry_mask = ((1 << (8 * entry_bytes)) - 1); // mask used to cast bytes32 -> lookup table entry
    bytes constant sin_table =
        hex"00_00_00_00_00_c9_0f_88_01_92_1d_20_02_5b_26_d7_03_24_2a_bf_03_ed_26_e6_04_b6_19_5d_05_7f_00_35_06_47_d9_7c_07_10_a3_45_07_d9_5b_9e_08_a2_00_9a_09_6a_90_49_0a_33_08_bc_0a_fb_68_05_0b_c3_ac_35_0c_8b_d3_5e_0d_53_db_92_0e_1b_c2_e4_0e_e3_87_66_0f_ab_27_2b_10_72_a0_48_11_39_f0_cf_12_01_16_d5_12_c8_10_6e_13_8e_db_b1_14_55_76_b1_15_1b_df_85_15_e2_14_44_16_a8_13_05_17_6d_d9_de_18_33_66_e8_18_f8_b8_3c_19_bd_cb_f3_1a_82_a0_25_1b_47_32_ef_1c_0b_82_6a_1c_cf_8c_b3_1d_93_4f_e5_1e_56_ca_1e_1f_19_f9_7b_1f_dc_dc_1b_20_9f_70_1c_21_61_b3_9f_22_23_a4_c5_22_e5_41_af_23_a6_88_7e_24_67_77_57_25_28_0c_5d_25_e8_45_b6_26_a8_21_85_27_67_9d_f4_28_26_b9_28_28_e5_71_4a_29_a3_c4_85_2a_61_b1_01_2b_1f_34_eb_2b_dc_4e_6f_2c_98_fb_ba_2d_55_3a_fb_2e_11_0a_62_2e_cc_68_1e_2f_87_52_62_30_41_c7_60_30_fb_c5_4d_31_b5_4a_5d_32_6e_54_c7_33_26_e2_c2_33_de_f2_87_34_96_82_4f_35_4d_90_56_36_04_1a_d9_36_ba_20_13_37_6f_9e_46_38_24_93_b0_38_d8_fe_93_39_8c_dd_32_3a_40_2d_d1_3a_f2_ee_b7_3b_a5_1e_29_3c_56_ba_70_3d_07_c1_d5_3d_b8_32_a5_3e_68_0b_2c_3f_17_49_b7_3f_c5_ec_97_40_73_f2_1d_41_21_58_9a_41_ce_1e_64_42_7a_41_d0_43_25_c1_35_43_d0_9a_ec_44_7a_cd_50_45_24_56_bc_45_cd_35_8f_46_75_68_27_47_1c_ec_e6_47_c3_c2_2e_48_69_e6_64_49_0f_57_ee_49_b4_15_33_4a_58_1c_9d_4a_fb_6c_97_4b_9e_03_8f_4c_3f_df_f3_4c_e1_00_34_4d_81_62_c3_4e_21_06_17_4e_bf_e8_a4_4f_5e_08_e2_4f_fb_65_4c_50_97_fc_5e_51_33_cc_94_51_ce_d4_6e_52_69_12_6e_53_02_85_17_53_9b_2a_ef_54_33_02_7d_54_ca_0a_4a_55_60_40_e2_55_f5_a4_d2_56_8a_34_a9_57_1d_ee_f9_57_b0_d2_55_58_42_dd_54_58_d4_0e_8c_59_64_64_97_59_f3_de_12_5a_82_79_99_5b_10_35_ce_5b_9d_11_53_5c_29_0a_cc_5c_b4_20_df_5d_3e_52_36_5d_c7_9d_7b_5e_50_01_5d_5e_d7_7c_89_5f_5e_0d_b2_5f_e3_b3_8d_60_68_6c_ce_60_ec_38_2f_61_6f_14_6b_61_f1_00_3e_62_71_fa_68_62_f2_01_ac_63_71_14_cc_63_ef_32_8f_64_6c_59_bf_64_e8_89_25_65_63_bf_91_65_dd_fb_d2_66_57_3c_bb_66_cf_81_1f_67_46_c7_d7_67_bd_0f_bc_68_32_57_aa_68_a6_9e_80_69_19_e3_1f_69_8c_24_6b_69_fd_61_4a_6a_6d_98_a3_6a_dc_c9_64_6b_4a_f2_78_6b_b8_12_d0_6c_24_29_5f_6c_8f_35_1b_6c_f9_34_fb_6d_62_27_f9_6d_ca_0d_14_6e_30_e3_49_6e_96_a9_9c_6e_fb_5f_11_6f_5f_02_b1_6f_c1_93_84_70_23_10_99_70_83_78_fe_70_e2_cb_c5_71_41_08_04_71_9e_2c_d1_71_fa_39_48_72_55_2c_84_72_af_05_a6_73_07_c3_cf_73_5f_66_25_73_b5_eb_d0_74_0b_53_fa_74_5f_9d_d0_74_b2_c8_83_75_04_d3_44_75_55_bd_4b_75_a5_85_ce_75_f4_2c_0a_76_41_af_3c_76_8e_0e_a5_76_d9_49_88_77_23_5f_2c_77_6c_4e_da_77_b4_17_df_77_fa_b9_88_78_40_33_28_78_84_84_13_78_c7_ab_a1_79_09_a9_2c_79_4a_7c_11_79_8a_23_b0_79_c8_9f_6d_7a_05_ee_ac_7a_42_10_d8_7a_7d_05_5a_7a_b6_cb_a3_7a_ef_63_23_7b_26_cb_4e_7b_5d_03_9d_7b_92_0b_88_7b_c5_e2_8f_7b_f8_88_2f_7c_29_fb_ed_7c_5a_3d_4f_7c_89_4b_dd_7c_b7_27_23_7c_e3_ce_b1_7d_0f_42_17_7d_39_80_eb_7d_62_8a_c5_7d_8a_5f_3f_7d_b0_fd_f7_7d_d6_66_8e_7d_fa_98_a7_7e_1d_93_e9_7e_3f_57_fe_7e_5f_e4_92_7e_7f_39_56_7e_9d_55_fb_7e_ba_3a_38_7e_d5_e5_c5_7e_f0_58_5f_7f_09_91_c3_7f_21_91_b3_7f_38_57_f5_7f_4d_e4_50_7f_62_36_8e_7f_75_4e_7f_7f_87_2b_f2_7f_97_ce_bc_7f_a7_36_b3_7f_b5_63_b2_7f_c2_55_95_7f_ce_0c_3d_7f_d8_87_8d_7f_e1_c7_6a_7f_e9_cb_bf_7f_f0_94_77_7f_f6_21_81_7f_fa_72_d0_7f_fd_88_59_7f_ff_62_15_7f_ff_ff_ff";

    /**
     * @notice Return the sine of a value, specified in radians scaled by 1e18
     * @dev This algorithm for converting sine only uses integer values, and it works by dividing the
     * circle into 30 bit angles, i.e. there are 1,073,741,824 (2^30) angle units, instead of the
     * standard 360 degrees (2pi radians). From there, we get an output in range -2,147,483,647 to
     * 2,147,483,647, (which is the max value of an int32) which is then converted back to the standard
     * range of -1 to 1, again scaled by 1e18
     * @param _angle Angle to convert
     * @return Result scaled by 1e18
     */
    function sin(uint256 _angle) internal pure returns (int256) {
        unchecked {
            // Convert angle from from arbitrary radian value (range of 0 to 2pi) to the algorithm's range
            // of 0 to 1,073,741,824
            _angle = (ANGLES_IN_CYCLE * (_angle % TWO_PI)) / TWO_PI;

            // Apply a mask on an integer to extract a certain number of bits, where angle is the integer
            // whose bits we want to get, the width is the width of the bits (in bits) we want to extract,
            // and the offset is the offset of the bits (in bits) we want to extract. The result is an
            // integer containing _width bits of _value starting at the offset bit
            uint256 interp = (_angle >> INTERP_OFFSET) &
                ((1 << INTERP_WIDTH) - 1);
            uint256 index = (_angle >> INDEX_OFFSET) & ((1 << INDEX_WIDTH) - 1);

            // The lookup table only contains data for one quadrant (since sin is symmetric around both
            // axes), so here we figure out which quadrant we're in, then we lookup the values in the
            // table then modify values accordingly
            bool is_odd_quadrant = (_angle & QUADRANT_LOW_MASK) == 0;
            bool is_negative_quadrant = (_angle & QUADRANT_HIGH_MASK) != 0;

            if (!is_odd_quadrant) {
                index = SINE_TABLE_SIZE - 1 - index;
            }

            bytes memory table = sin_table;
            // We are looking for two consecutive indices in our lookup table
            // Since EVM is left aligned, to read n bytes of data from idx i, we must read from `i * data_len` + `n`
            // therefore, to read two entries of size entry_bytes `index * entry_bytes` + `entry_bytes * 2`
            uint256 offset1_2 = (index + 2) * entry_bytes;

            // This following snippet will function for any entry_bytes <= 15
            uint256 x1_2;
            assembly {
                // mload will grab one word worth of bytes (32), as that is the minimum size in EVM
                x1_2 := mload(add(table, offset1_2))
            }

            // We now read the last two numbers of size entry_bytes from x1_2
            // in example: entry_bytes = 4; x1_2 = 0x00...12345678abcdefgh
            // therefore: entry_mask = 0xFFFFFFFF

            // 0x00...12345678abcdefgh >> 8*4 = 0x00...12345678
            // 0x00...12345678 & 0xFFFFFFFF = 0x12345678
            uint256 x1 = (x1_2 >> (8 * entry_bytes)) & entry_mask;
            // 0x00...12345678abcdefgh & 0xFFFFFFFF = 0xabcdefgh
            uint256 x2 = x1_2 & entry_mask;

            // Approximate angle by interpolating in the table, accounting for the quadrant
            uint256 approximation = ((x2 - x1) * interp) >> INTERP_WIDTH;
            int256 sine = is_odd_quadrant
                ? int256(x1) + int256(approximation)
                : int256(x2) - int256(approximation);
            if (is_negative_quadrant) {
                sine *= -1;
            }

            // Bring result from the range of -2,147,483,647 through 2,147,483,647 to -1e18 through 1e18.
            // This can never overflow because sine is bounded by the above values
            return (sine * 1e18) / 2_147_483_647;
        }
    }

    /**
     * @notice Return the cosine of a value, specified in radians scaled by 1e18
     * @dev This is identical to the sin() method, and just computes the value by delegating to the
     * sin() method using the identity cos(x) = sin(x + pi/2)
     * @dev Overflow when `angle + PI_OVER_TWO > type(uint256).max` is ok, results are still accurate
     * @param _angle Angle to convert
     * @return Result scaled by 1e18
     */
    function cos(uint256 _angle) internal pure returns (int256) {
        unchecked {
            return sin(_angle + PI_OVER_TWO);
        }
    }
}

// File contracts/BaseStakingPool.sol

pragma solidity 0.8.17;

abstract contract BaseStakingPool is
    IStakingPool,
    EmergencyGuard,
    Ownable,
    AccessControlEnumerable,
    ReentrancyGuard
{
    IERC20 private _token = IERC20(address(0));

    function token() public view returns (IERC20 value) {
        return _token;
    }

    function poolBalance() public view returns (uint256 value) {
        return token().balanceOf(address(this));
    }

    function poolFactor(uint256 balance) external view returns (uint256 value) {
        uint256 pMax = 120_000_000;
        uint256 pBalance = 100_000_000;
        uint256 pMin = 0;
        uint256 low = 15 * 1e4;

        // ((cos(pi*((120_000_000 - 120000000)/(120000000-0)))+1)/2)*(1-0.15)+0.15 = 1
        // ((cos(pi*((120000000 - 120000000)/(120000000-0)))+1)/2)*(100-15)+15 = 100
        // ((cos(pi*((120000000 - 120000000)/(120000000-0)))+1)/2)*(10000-1500)+1500 = 10000

        /**
         * (
         *      (cos(
         *          pi*(
         *               (120000000 - 120000000) / (120000000 - 0)
         *          )
         *      ) + 1) / 2
         * ) * (10000-1500) + 1500 = 10000
         */

        // min. 10 cec. for pmax, pmin and x
        // min. 2 dec. for low
        // min. 4 dec. for PI

        // 999999999752169356

        // 99.9982253697025
        // 99.9991968259112

        return
            (((uint256(
                Trigonometry.cos(
                    (Trigonometry.PI / 1e10) *
                        (((pMax * 1e18) - (pBalance * 1e18)) /
                            ((pMax * 1e10) - pMin))
                )
            ) + (1 * 1e18)) / 2) *
                ((100 * 1e14) - low) +
                low) / 1e16;
    }
}

// File contracts/interfaces/IWeSenditToken.sol

pragma solidity 0.8.17;

interface IWeSenditToken {
    /**
     * Emitted on transaction unpause
     */
    event Unpaused();

    /**
     * Emitted on dynamic fee manager update
     *
     * @param newAddress address - New dynamic fee manager address
     */
    event DynamicFeeManagerUpdated(address newAddress);

    /**
     * Returns the initial supply
     *
     * @return value uint256 - Initial supply
     */
    function initialSupply() external pure returns (uint256 value);

    /**
     * Returns true if transactions are pause, false if unpaused
     *
     * @param value bool - Indicates if transactions are paused
     */
    function paused() external view returns (bool value);

    /**
     * Sets the transaction pause state to false and therefor, allowing any transactions
     */
    function unpause() external;

    /**
     * Returns the dynamic fee manager
     *
     * @return value IDynamicFeeManager - Dynamic Fee Manager
     */
    function dynamicFeeManager()
        external
        view
        returns (IDynamicFeeManager value);

    /**
     * Sets the dynamic fee manager
     * Can be set to zero address to disable fee reflection.
     *
     * @param value address - New dynamic fee manager address
     */
    function setDynamicFeeManager(address value) external;

    /**
     * Transfers token from <from> to <to> without applying fees
     *
     * @param from address - Sender address
     * @param to address - Receiver address
     * @param amount uin256 - Transaction amount
     */
    function transferFromNoFees(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File contracts/BaseWeSenditToken.sol

pragma solidity 0.8.17;

abstract contract BaseWeSenditToken is
    IWeSenditToken,
    EmergencyGuard,
    AccessControlEnumerable,
    Ownable
{
    // Initial token supply
    uint256 public constant INITIAL_SUPPLY = 37_500_000 ether;

    // Total token supply
    uint256 public constant TOTAL_SUPPLY = 1_500_000_000 ether;

    // Role allowed to do admin operations like adding to fee whitelist, withdraw, etc.
    bytes32 public constant ADMIN = keccak256("ADMIN");

    // Role allowed to bypass pause
    bytes32 public constant BYPASS_PAUSE = keccak256("BYPASS_PAUSE");

    // Indicator, if transactions are paused
    bool private _paused = true;

    // Dynamic Fee Manager instance
    IDynamicFeeManager private _dynamicFeeManager;

    constructor() {
        _setupRole(ADMIN, _msgSender());
        _setRoleAdmin(ADMIN, ADMIN);
        _setRoleAdmin(BYPASS_PAUSE, ADMIN);
    }

    /**
     * Getter & Setter
     */
    function initialSupply() external pure override returns (uint256) {
        return INITIAL_SUPPLY;
    }

    function unpause() external override onlyRole(ADMIN) {
        _paused = false;
        emit Unpaused();
    }

    function setDynamicFeeManager(
        address value
    ) external override onlyRole(ADMIN) {
        _dynamicFeeManager = IDynamicFeeManager(value);
        emit DynamicFeeManagerUpdated(value);
    }

    function emergencyWithdraw(
        uint256 amount
    ) external override onlyRole(ADMIN) {
        super._emergencyWithdraw(amount);
    }

    function emergencyWithdrawToken(
        address token,
        uint256 amount
    ) external override onlyRole(ADMIN) {
        super._emergencyWithdrawToken(token, amount);
    }

    function paused() public view override returns (bool) {
        return _paused;
    }

    function dynamicFeeManager()
        public
        view
        override
        returns (IDynamicFeeManager manager)
    {
        return _dynamicFeeManager;
    }
}

// File contracts/interfaces/IFeeReceiver.sol

pragma solidity 0.8.17;

interface IFeeReceiver {
    /**
     * Callback function on ERC20 receive
     *
     * @param caller address - Calling contract
     * @param token address - Received ERC20 token address
     * @param from address - Sender address
     * @param to address - Receiver address
     * @param amount uint256 - Transaction amount
     */
    function onERC20Received(
        address caller,
        address token,
        address from,
        address to,
        uint256 amount
    ) external;
}

// File contracts/DynamicFeeManager.sol

pragma solidity 0.8.17;

/**
 * @title Dynamic Fee Manager for ERC20 token
 *
 * The dynamic fee manager allows to dynamically add fee rules to ERC20 token transactions.
 * Fees will be applied if the given conditions are met.
 * Additonally, fees can be used to create liquidity on DEX or can be swapped to BUSD.
 */
contract DynamicFeeManager is BaseDynamicFeeManager {
    constructor(address wesenditToken) BaseDynamicFeeManager(wesenditToken) {}

    receive() external payable {}

    function addFee(
        address from,
        address to,
        uint256 percentage,
        address destination,
        bool doCallback,
        bool doLiquify,
        bool doSwapForBusd,
        uint256 swapOrLiquifyAmount,
        uint256 expiresAt
    ) external override onlyRole(ADMIN) returns (uint256 index) {
        require(
            feeEntries.length < MAX_FEE_AMOUNT,
            "DynamicFeeManager: Amount of max. fees reached"
        );
        require(
            percentage <= feePercentageLimit(),
            "DynamicFeeManager: Fee percentage exceeds limit"
        );
        require(
            !(doLiquify && doSwapForBusd),
            "DynamicFeeManager: Cannot enable liquify and swap at the same time"
        );

        bytes32 id = _generateIdentifier(
            destination,
            doLiquify,
            doSwapForBusd,
            swapOrLiquifyAmount
        );

        FeeEntry memory feeEntry = FeeEntry(
            id,
            from,
            to,
            percentage,
            destination,
            doCallback,
            doLiquify,
            doSwapForBusd,
            swapOrLiquifyAmount,
            expiresAt
        );

        feeEntries.push(feeEntry);

        emit FeeAdded(
            id,
            from,
            to,
            percentage,
            destination,
            doCallback,
            doLiquify,
            doSwapForBusd,
            swapOrLiquifyAmount,
            expiresAt
        );

        // Return entry index
        return feeEntries.length - 1;
    }

    function removeFee(uint256 index) external override onlyRole(ADMIN) {
        require(
            index < feeEntries.length,
            "DynamicFeeManager: array out of bounds"
        );

        // Reset current amount for liquify or swap
        bytes32 id = feeEntries[index].id;
        feeEntryAmounts[id] = 0;

        // Remove fee entry from array
        feeEntries[index] = feeEntries[feeEntries.length - 1];
        feeEntries.pop();

        emit FeeRemoved(id, index);
    }

    function reflectFees(
        address from,
        address to,
        uint256 amount
    ) external override returns (uint256 tTotal, uint256 tFees) {
        require(
            hasRole(CALL_REFLECT_FEES, _msgSender()),
            "DynamicFeeManager: Caller is missing required role"
        );

        bool bypassFees = !feesEnabled() ||
            from == owner() ||
            hasRole(ADMIN, from) ||
            hasRole(FEE_WHITELIST, from) ||
            hasRole(RECEIVER_FEE_WHITELIST, to);

        if (bypassFees) {
            return (amount, 0);
        }

        bool bypassSwapAndLiquify = hasRole(ADMIN, to) ||
            hasRole(ADMIN, from) ||
            hasRole(BYPASS_SWAP_AND_LIQUIFY, to) ||
            hasRole(BYPASS_SWAP_AND_LIQUIFY, from);

        // Loop over all fee entries and calculate plus reflect fee
        uint256 feeAmount = feeEntries.length;

        // Keep track of fees applied, to prevent applying more fees than transaction limit
        uint256 totalFeePercentage = 0;
        uint256 txFeeLimit = transactionFeeLimit();

        for (uint256 i = 0; i < feeAmount; i++) {
            FeeEntry memory fee = feeEntries[i];

            if (_isFeeEntryValid(fee) && _isFeeEntryMatching(fee, from, to)) {
                uint256 tFee = _calculateFee(amount, fee.percentage);
                uint256 tempPercentage = totalFeePercentage + fee.percentage;

                if (tFee > 0 && tempPercentage <= txFeeLimit) {
                    tFees = tFees + tFee;
                    totalFeePercentage = tempPercentage;
                    _reflectFee(from, to, tFee, fee, bypassSwapAndLiquify);
                }
            }
        }

        tTotal = amount - tFees;
        require(tTotal > 0, "DynamicFeeManager: invalid total amount");

        return (tTotal, tFees);
    }

    /**
     * Reflects a single fee
     *
     * @param from address - Sender address
     * @param to address - Receiver address
     * @param tFee uint256 - Fee amount
     * @param fee FeeEntry - Fee Entry
     * @param bypassSwapAndLiquify bool - Indicator, if swap and liquify should be bypassed
     */
    function _reflectFee(
        address from,
        address to,
        uint256 tFee,
        FeeEntry memory fee,
        bool bypassSwapAndLiquify
    ) private {
        // add to liquify / swap amount or transfer to fee destination
        if (fee.doLiquify || fee.doSwapForBusd) {
            require(
                IWeSenditToken(address(token())).transferFromNoFees(
                    from,
                    address(this),
                    tFee
                ),
                "DynamicFeeManager: Fee transfer to manager failed"
            );
            feeEntryAmounts[fee.id] = feeEntryAmounts[fee.id] + tFee;
        } else {
            require(
                IWeSenditToken(address(token())).transferFromNoFees(
                    from,
                    fee.destination,
                    tFee
                ),
                "DynamicFeeManager: Fee transfer to destination failed"
            );
        }

        // Check if swap / liquify amount was reached
        if (
            !bypassSwapAndLiquify &&
            feeEntryAmounts[fee.id] >= MIN_SWAP_OR_LIQUIFY_AMOUNT &&
            feeEntryAmounts[fee.id] >= fee.swapOrLiquifyAmount
        ) {
            // Disable fees, to prevent PancakeSwap pair recursive calls
            feesEnabled_ = false;

            // Check if swap / liquify amount was reached
            uint256 tokenSwapped = 0;

            if (fee.doSwapForBusd && from != pancakePairBusdAddress()) {
                // Calculate amount of token we're going to swap
                tokenSwapped = _getSwapOrLiquifyAmount(
                    fee.id,
                    fee.swapOrLiquifyAmount,
                    percentageVolumeSwap(),
                    pancakePairBusdAddress()
                );

                // Swap token for BUSD
                _swapTokensForBusd(tokenSwapped, fee.destination);
            }

            if (fee.doLiquify) {
                // Swap (BNB) and liquify token
                tokenSwapped = _swapAndLiquify(
                    _getSwapOrLiquifyAmount(
                        fee.id,
                        fee.swapOrLiquifyAmount,
                        percentageVolumeLiquify(),
                        pancakePairBnbAddress()
                    ),
                    fee.destination
                );
            }

            // Subtract amount of swapped token from fee entry amount
            feeEntryAmounts[fee.id] = feeEntryAmounts[fee.id] - tokenSwapped;

            // Enable fees again
            feesEnabled_ = true;
        }

        // Check if callback should be called on destination
        if (fee.doCallback && !fee.doSwapForBusd && !fee.doLiquify) {
            // Try to call onERC20Received on destination and ignore reverts here
            try
                IFeeReceiver(fee.destination).onERC20Received(
                    address(this),
                    address(token()),
                    from,
                    to,
                    tFee
                )
            {} catch (bytes memory) {}
        }

        emit FeeReflected(
            fee.id,
            address(token()),
            from,
            to,
            tFee,
            fee.destination,
            fee.doCallback,
            fee.doLiquify,
            fee.doSwapForBusd,
            fee.swapOrLiquifyAmount,
            fee.expiresAt
        );
    }

    /**
     * Checks if the fee entry is still valid
     *
     * @param fee FeeEntry - Fee Entry
     *
     * @return isValid bool - Indicates, if the fee entry is still valid
     */
    function _isFeeEntryValid(
        FeeEntry memory fee
    ) private view returns (bool isValid) {
        return fee.expiresAt == 0 || block.timestamp <= fee.expiresAt;
    }

    /**
     * Checks if the fee entry matches
     *
     * @param fee FeeEntry - Fee Entry
     * @param from address - Sender address
     * @param to address - Receiver address
     *
     * @return matching bool - Indicates, if the fee entry and from / to are matching
     */
    function _isFeeEntryMatching(
        FeeEntry memory fee,
        address from,
        address to
    ) private view returns (bool matching) {
        return
            (fee.from == WHITELIST_ADDRESS &&
                fee.to == WHITELIST_ADDRESS &&
                !hasRole(EXCLUDE_WILDCARD_FEE, from) &&
                !hasRole(EXCLUDE_WILDCARD_FEE, to)) ||
            (fee.from == from &&
                fee.to == WHITELIST_ADDRESS &&
                !hasRole(EXCLUDE_WILDCARD_FEE, to)) ||
            (fee.to == to &&
                fee.from == WHITELIST_ADDRESS &&
                !hasRole(EXCLUDE_WILDCARD_FEE, from)) ||
            (fee.to == to && fee.from == from);
    }

    /**
     * Calculates a single fee
     *
     * @param amount uint256 - Transaction amount
     * @param percentage uint256 - Fee percentage
     *
     * @return tFee - Total Fee Amount
     */
    function _calculateFee(
        uint256 amount,
        uint256 percentage
    ) private pure returns (uint256 tFee) {
        return (amount * percentage) / FEE_DIVIDER;
    }

    /**
     * Generates an unique identifier for a fee entry
     *
     * @param destination address - Destination address for the fee
     * @param doLiquify bool - Indicates, if the fee amount should be used to add liquidy on DEX
     * @param doSwapForBusd bool - Indicates, if the fee amount should be swapped to BUSD
     * @param swapOrLiquifyAmount uint256 - Amount for liquidify or swap
     *
     * @return id bytes32 - Unique id
     */
    function _generateIdentifier(
        address destination,
        bool doLiquify,
        bool doSwapForBusd,
        uint256 swapOrLiquifyAmount
    ) private pure returns (bytes32 id) {
        return
            keccak256(
                abi.encodePacked(
                    destination,
                    doLiquify,
                    doSwapForBusd,
                    swapOrLiquifyAmount
                )
            );
    }
}

// File contracts/StakingPool.sol

pragma solidity 0.8.17;

/**
 * @title WeSendit Staking Pool
 */
contract StakingPool is BaseStakingPool {
    constructor() {}

    function totalValueLocked()
        external
        pure
        override
        returns (uint256 value)
    {}

    function maxDuration() external pure override returns (uint256 duration) {}

    function minDuration() external pure override returns (uint256 duration) {}

    function maxAmount() external pure override returns (uint256 amount) {}

    function compoundInterval()
        external
        pure
        override
        returns (uint256 interval)
    {}

    function poolAllocation()
        external
        pure
        override
        returns (uint256 allocation)
    {}

    function pendingRewards()
        external
        pure
        override
        returns (uint256 pendingRewards)
    {}

    function lastRewardsBlock()
        external
        pure
        override
        returns (uint256 block)
    {}

    function apy(
        uint256 amount,
        uint256 duration
    ) external pure override returns (uint256 apy) {}

    function getEntries(
        address account
    ) external view override returns (PoolEntry[] memory entries) {}

    function stake(
        uint256 amount,
        uint256 duration
    ) external override returns (bytes32 entryId) {}

    function unstake(bytes32 entryId) external override {}

    function compound(bytes32 entryId) external override {}

    function updatePool() external override {}

    function emergencyWithdraw(uint256 amount) external override {}

    function emergencyWithdrawToken(
        address token,
        uint256 amount
    ) external override {}
}

// File contracts/interfaces/ITokenVault.sol

pragma solidity 0.8.17;

interface ITokenVault {
    /**
     * Emitted on vault lock
     */
    event Locked();

    /**
     * Emitted on vault unlock
     */
    event Unlocked();

    /**
     * Emitted on token withdrawal
     *
     * @param receiver address - Receiver of token
     * @param token address - Token address
     * @param amount uint256 - token amount
     */
    event WithdrawToken(address receiver, address token, uint256 amount);

    /**
     * Locks the vault
     */
    function lock() external;

    /**
     * Unlocks the vault
     */
    function unlock() external;

    /**
     * Withdraws token stores at the contract
     *
     * @param token address - Token to withdraw
     * @param amount uint256 - Amount of token to withdraw
     */
    function withdrawToken(address token, uint256 amount) external;
}

// File contracts/TokenVault.sol

pragma solidity 0.8.17;

contract TokenVault is ITokenVault, Ownable {
    bool public locked = true;

    function lock() external onlyOwner {
        locked = true;
        emit Locked();
    }

    function unlock() external onlyOwner {
        locked = false;
        emit Unlocked();
    }

    function withdrawToken(
        address token,
        uint256 amount
    ) external override onlyOwner {
        require(!locked, "TokenVault: Token vault is locked");

        IERC20(token).transfer(msg.sender, amount);
        emit WithdrawToken(msg.sender, token, amount);
    }
}

// File contracts/WeSenditSender.sol

pragma solidity 0.8.17;

/**
 * @title WeSendit token sender
 */
contract WeSenditSender is Ownable {
    IERC20 private _token;

    constructor(address token) {
        _token = IERC20(token);
    }

    function transferBulk(
        address[] calldata addresses,
        uint256[] calldata amounts
    ) external onlyOwner returns (bool) {
        require(
            addresses.length == amounts.length,
            "WeSenditSender: mismatching addresses / amounts pair"
        );

        for (uint256 i = 0; i < addresses.length; i++) {
            require(
                _token.transferFrom(_msgSender(), addresses[i], amounts[i])
            );
        }

        return true;
    }
}

// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

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

// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

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
    mapping(address => uint256) private _balances;

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
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Capped.sol)

pragma solidity ^0.8.0;

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
abstract contract ERC20Capped is ERC20 {
    uint256 private immutable _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor(uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        require(
            ERC20.totalSupply() + amount <= cap(),
            "ERC20Capped: cap exceeded"
        );
        super._mint(account, amount);
    }
}

// File contracts/WeSenditToken.sol

pragma solidity 0.8.17;

/**
 * @title WeSendit ERC20 token
 */
contract WeSenditToken is BaseWeSenditToken, ERC20Capped, ERC20Burnable {
    constructor(
        address addressTotalSupply
    ) ERC20("WeSendit", "WSI") ERC20Capped(TOTAL_SUPPLY) BaseWeSenditToken() {
        _mint(addressTotalSupply, TOTAL_SUPPLY);
    }

    /**
     * Transfer token from without fee reflection
     *
     * @param from address - Address to transfer token from
     * @param to address - Address to transfer token to
     * @param amount uint256 - Amount of token to transfer
     *
     * @return bool - Indicator if transfer was successful
     */
    function transferFromNoFees(
        address from,
        address to,
        uint256 amount
    ) external virtual override returns (bool) {
        require(
            _msgSender() == address(dynamicFeeManager()),
            "WeSendit: Can only be called by Dynamic Fee Manager"
        );

        return super.transferFrom(from, to, amount);
    }

    /**
     * Transfer token with fee reflection
     *
     * @inheritdoc ERC20
     */
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        // Reflect fees
        (uint256 tTotal, ) = _reflectFees(_msgSender(), to, amount);

        // Execute normal transfer
        return super.transfer(to, tTotal);
    }

    /**
     * Transfer token from with fee reflection
     *
     * @inheritdoc ERC20
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        // Reflect fees
        (uint256 tTotal, ) = _reflectFees(from, to, amount);

        // Execute normal transfer
        return super.transferFrom(from, to, tTotal);
    }

    /**
     * @inheritdoc ERC20
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        _preValidateTransfer(from);
    }

    // Needed since we inherit from ERC20 and ERC20Capped
    function _mint(
        address account,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Capped) {
        super._mint(account, amount);
    }

    /**
     * Reflects fees using the dynamic fee manager
     *
     * @param from address - Sender address
     * @param to address - Receiver address
     * @param amount uint256 - Transaction amount
     */
    function _reflectFees(
        address from,
        address to,
        uint256 amount
    ) private returns (uint256 tTotal, uint256 tFees) {
        if (address(dynamicFeeManager()) == address(0)) {
            return (amount, 0);
        } else {
            // Allow dynamic fee manager to spent amount for fees if needed
            _approve(from, address(dynamicFeeManager()), amount);

            // Reflect fees
            (tTotal, tFees) = dynamicFeeManager().reflectFees(from, to, amount);

            // Reset fee manager approval to zero for security reason
            _approve(from, address(dynamicFeeManager()), 0);

            return (tTotal, tFees);
        }
    }

    /**
     * Checks if the minimum transaction amount is exceeded and if pause is enabled
     *
     * @param from address - Sender address
     */
    function _preValidateTransfer(address from) private view {
        /**
         * Only allow transfers if:
         * - token is not paused
         * - sender is owner
         * - sender is admin
         * - sender has bypass role
         */
        require(
            !paused() ||
                from == address(0) ||
                from == owner() ||
                hasRole(ADMIN, from) ||
                hasRole(BYPASS_PAUSE, from),
            "WeSendit: transactions are paused"
        );
    }
}

// File contracts/mocks/MockERC20.sol

pragma solidity 0.8.17;

contract MockERC20 is ERC20, Ownable {
    constructor() ERC20("MockERC20", "MERC20") {
        _mint(_msgSender(), 100_000_000 ether);
    }
}

// File contracts/mocks/MockFeeReceiver.sol

pragma solidity 0.8.17;

contract MockFeeReceiver is IFeeReceiver {
    function onERC20Received(
        address caller,
        address token,
        address from,
        address to,
        uint256 amount
    ) external override {}
}

// File contracts/mocks/MockPancakePair.sol

pragma solidity 0.8.17;

contract MockPancakePair {
    constructor() {}

    function swap(address token, address to, uint256 amountOutMin) public {
        IERC20(token).transfer(to, amountOutMin);
    }
}

// File contracts/mocks/MockPancakeRouter.sol

pragma solidity 0.8.17;

contract MockPancakeRouter {
    event MockEvent(uint256 value);

    address private immutable _weth;

    // See https://github.com/pancakeswap/pancake-smart-contracts/blob/master/projects/exchange-protocol/contracts/PancakeFactory.sol#L13
    mapping(address => mapping(address => address)) public getPair;

    constructor(
        address weth,
        address busd,
        address wsi,
        address wethPair,
        address busdPair
    ) {
        // BNB
        _weth = weth;

        // BNB <-> WSI
        getPair[weth][wsi] = wethPair;
        getPair[wsi][weth] = wethPair;

        // BUSD <-> WSI
        getPair[busd][wsi] = busdPair;
        getPair[wsi][busd] = busdPair;
    }

    function WETH() public view returns (address) {
        return _weth;
    }

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        public
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity)
    {
        address pair = getPair[_weth][token];

        IERC20(token).transferFrom(msg.sender, pair, amountTokenDesired);

        return (amountTokenDesired, msg.value, 0);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) public {
        require(amountIn > 0, "MockPancakeRouter: Invalid input amount");

        address pair = getPair[path[0]][path[1]];

        IERC20(path[0]).transferFrom(msg.sender, pair, amountIn);
        // MockPancakePair(_pair).swap(path[1], address(0), amountIn);
        payable(to).transfer(amountIn);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) public payable {
        address pair = getPair[path[0]][path[1]];

        IERC20(path[0]).transfer(pair, msg.value);
        MockPancakePair(pair).swap(path[1], to, amountOutMin);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) public {
        address pair = getPair[path[0]][path[1]];

        IERC20(path[0]).transferFrom(msg.sender, pair, amountIn);
        MockPancakePair(pair).swap(
            path[1],
            to,
            amountOutMin > 0 ? amountOutMin : amountIn
        );
    }
}