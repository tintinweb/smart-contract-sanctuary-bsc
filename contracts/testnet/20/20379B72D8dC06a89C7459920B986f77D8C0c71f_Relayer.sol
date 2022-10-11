//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./IVaultFactory.sol";
import "./IVault.sol";

/// @title  Asset Relayer
/// @author Christian B. Martinez
/// @notice This contract is to be used as a transaction relayer.
/// @notice Valid txns will be assessed a fee and relayed to account/smart contracts for processing.
/// @dev Roles based for admin methods; public contract interactions for txns relays.
/// @dev Three types of relayed txns: transfer bnb, transfer ERC token, swap

contract Relayer is AccessControl {
    bool internal locked;
    uint256 public immutable feeDenominator = 10000;

    /// @notice A fee of 25 basis points (0.25%) will be assessed for every valid txn.
    uint256 public fee = 25;

    /// @notice Factory contract that creates vaults per assets.
    IRewardVaultFactory public vaultFactory;

    /// @notice Wallet where fees will be collected.
    address public exchangeWallet;

    /// @notice Accounts /w this Role can add/remove/update approved recipients, assets and currencies.
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /// @notice Accounts /w this Role can update fee and exchange wallet.
    bytes32 public constant FINANCE_ROLE = keccak256("FINANCE_ROLE");

    /// @notice Event to be captured, including relayed transaction and referrer to be credited.
    event AssetRelayed(
        address indexed referrerAddress,
        address indexed recipientAddress,
        address fromAddress,
        address indexed assetAddress,
        uint256 amountInvested
    );

    modifier noReentrant() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    /// @notice Relayer only works on recipients or assets that have been approved.
    modifier onlyDeployedRewardVaults(address vaultAddress) {
        require(vaultAddress != address(this));
        require(vaultAddress != address(0));
        address assetAddress = vaultFactory.getVaultAsset(vaultAddress);
        require(assetAddress != address(this));
        require(assetAddress != address(0));
        _;
    }

    constructor(
        address newExchangeWallet,
        IRewardVaultFactory rewardFactoryAddress
    ) {
        exchangeWallet = newExchangeWallet;
        vaultFactory = rewardFactoryAddress;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function updateFeeBasisPoints(uint256 _newFee)
        external
        onlyRole(FINANCE_ROLE)
    {
        require(_newFee > 0);
        require(_newFee != fee);
        fee = _newFee;
    }

    function updateExchangeWallet(address _newExchangeWallet)
        external
        onlyRole(FINANCE_ROLE)
    {
        require(_newExchangeWallet != address(0));
        require(_newExchangeWallet != address(this));
        require(_newExchangeWallet != exchangeWallet);
        exchangeWallet = _newExchangeWallet;
    }

    /// @notice Used to invest Network Token in pre-deployed, approved recipients/projects.
    /// @param _referrerAddress - The address of the referrer. Needed to produce event and credited for successful referral.
    /// @param vaultAddress - The address where the recipient/project funds are being held.
    function investNetworkToken(address _referrerAddress, address vaultAddress)
        external
        payable
        onlyDeployedRewardVaults(vaultAddress)
        noReentrant
    {
        address assetAddress = vaultFactory.getVaultAsset(vaultAddress);
        (uint256 minAmount, uint256 maxAmount, bool canInvest, ) = IRewardVault(
            vaultAddress
        ).getVaultStatus(msg.sender);
        require(canInvest);
        /// @notice Calculate fees and amount to relay.
        (uint256 _feeToTake, uint256 _amountToSend) = takeFee(msg.value);
        require(_amountToSend >= minAmount, "Not enough to purchase");

        if (maxAmount > 0) {
            require(_amountToSend <= maxAmount, "Not enough to purchase");
        }

        //require(_feeToTake >= 1, "Not enough to cover fee");

        /// @notice Send fees to exchange wallet.
        bool feeSent = payable(exchangeWallet).send(_feeToTake);
        require(feeSent, "Failed to send Ether");

        /// @notice Relay investment amount excluding fees.
        (bool sent, ) = assetAddress.call{value: _amountToSend}("");
        require(sent, "Failed to send Network Token");

        if (_referrerAddress != address(0)) {
            IRewardVault(vaultAddress).creditReferrer(
                _referrerAddress,
                _amountToSend
            );
        }

        emit AssetRelayed(
            _referrerAddress,
            vaultAddress,
            msg.sender,
            address(0),
            msg.value
        );
    }

    /// @notice Used to invest ERC Token in pre-deployed, approved recipients/projects.
    /// @notice Can only invest with pre-approved ERC tokens.
    /// @param _referrerAddress - The address of the referrer. Needed to produce event and credit for successful referral.
    /// @param vaultAddress - The address of the ERC asset the recipient/project is accepting for investments.
    /// @param _fundingAmount - The amount (pre fees) the user is intending to invest.
    function investERCToken(
        address _referrerAddress,
        address vaultAddress,
        uint256 _fundingAmount
    ) external payable onlyDeployedRewardVaults(vaultAddress) noReentrant {
        address assetAddress = vaultFactory.getVaultAsset(vaultAddress);
        (
            uint256 minAmount,
            uint256 maxAmount,
            bool canInvest,
            address currencyToRelay
        ) = IRewardVault(vaultAddress).getVaultStatus(msg.sender);
        require(canInvest);

        require(
            _fundingAmount <=
                IERC20(currencyToRelay).allowance(msg.sender, address(this))
        );
        /// @notice Calculate fees and amount to relay.
        (uint256 _feeToTake, uint256 _amountToSend) = takeFee(_fundingAmount);

        require(_amountToSend >= minAmount, "Not enough to purchase");

        if (maxAmount > 0) {
            require(_amountToSend <= maxAmount, "Not enough to purchase");
        }

        /// @notice Send fees to exchange wallet.
        IERC20(currencyToRelay).transferFrom(
            msg.sender,
            exchangeWallet,
            _feeToTake
        );
        /// @notice Relay investment amount excluding fees.
        IERC20(currencyToRelay).transferFrom(
            msg.sender,
            assetAddress,
            _amountToSend
        );

        if (_referrerAddress != address(0)) {
            IRewardVault(vaultAddress).creditReferrer(
                _referrerAddress,
                _amountToSend
            );
        }

        emit AssetRelayed(
            _referrerAddress,
            vaultAddress,
            msg.sender,
            currencyToRelay,
            _amountToSend
        );
    }

    /// @notice Used to invest Network Token in post-deployed, approved assets/projects.
    /// @notice Txn will be relayed to DEX for swapping the network token for the approved asset.
    /// @dev DEX address as paramter for flexibility when deploying to other chains.
    /// @dev Only investing the network token; no multi hops.
    /// @param _dex - The address of the DEX where _assetAddress is trading.
    /// @param vaultAddress - The address of the ERC asset the user is wanting to purchase.
    /// @param _referrerAddress - The address of the referrer. Needed to produce event and credited for successful referral.
    /// @param _purchaseAmt - The amount (pre fees) the user is intending to purchase with.
    function purchaseFromDex(
        IUniswapV2Router02 _dex,
        address vaultAddress,
        address _referrerAddress,
        uint256 _purchaseAmt,
        address[] calldata pathToRoute,
        uint256 deadline,
        bool exactEth
    ) external payable onlyDeployedRewardVaults(vaultAddress) noReentrant {
        require(checkPurchasableDex(vaultAddress, pathToRoute[1]));
        (uint256 minAmount, uint256 maxAmount, bool canInvest, ) = IRewardVault(
            vaultAddress
        ).getVaultStatus(msg.sender);
        require(canInvest);

        /// @notice Calculate fees and amount to relay.
        (uint256 _feeToTake, uint256 _amountToSend) = takeFee(msg.value);

        require(_amountToSend >= minAmount, "Not enough to purchase");

        if (maxAmount > 0) {
            require(_amountToSend <= maxAmount, "Not enough to purchase");
        }

        /// @notice Send fees to exchange wallet
        require(
            payable(exchangeWallet).send(_feeToTake),
            "Failed to send Ether"
        );

        if (exactEth == true) {
            /// @notice Make the swap
            _dex.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: _amountToSend
            }(_purchaseAmt, pathToRoute, msg.sender, deadline);
        } else {
            /// @notice Make the swap
            _dex.swapETHForExactTokens{value: _amountToSend}(
                _purchaseAmt,
                pathToRoute,
                msg.sender,
                deadline
            );
        }

        if (_referrerAddress != address(0)) {
            IRewardVault(vaultAddress).creditReferrer(
                _referrerAddress,
                _amountToSend
            );
        }

        emit AssetRelayed(
            _referrerAddress,
            vaultAddress,
            msg.sender,
            address(0),
            _amountToSend
        );
    }

    /// @notice Helper method to calculate fees taken by asset relayer.
    /// @return feeToTake - The fee we will take.
    /// @return amountToRelay - The final amount that will be relayed excluding the fee we will take.
    function takeFee(uint256 amountIn)
        internal
        view
        returns (uint256, uint256)
    {
        require(amountIn >= 1e12, "Not enough funds sent");
        uint256 feeToTake = (amountIn * fee) / feeDenominator;
        return (feeToTake, amountIn - feeToTake);
    }

    /// @notice Helper method to check whether it points to correct address for dex.
    /// @dev the asset address saved in the vault array should equal the token address passed into Uniswap's swap function.
    function checkPurchasableDex(
        address vaultAddress,
        address assetAddressInPath
    ) internal view returns (bool) {
        address assetAddress = vaultFactory.getVaultAsset(vaultAddress);
        return assetAddressInPath == assetAddress;
    }

    fallback() external payable {}

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
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
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
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
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

/// @title  RewardVaultFactory Interface
/// @author Christian B. Martinez
/// @notice Interface with exposed methods that can be used by outside contracts.

interface IRewardVaultFactory {
    function getVaultAsset(address vaultAddress)
        external
        view
        returns (address);

    function updateVaultAsset(address newAssetAddress) external;
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

/// @title  RewardVault Interface
/// @author Christian B. Martinez
/// @notice Interface with exposed methods that can be used by outside contracts.

interface IRewardVault {
    struct VaultInfo {
        bool rewardsDistributor;
        bool whitelistOnly;
        address rewardFactory;
        address clientAddress;
        address assetAddress;
        address currencyToRecieve;
        uint256 minimumInvestmentAmount;
        uint256 maximumInvestmentAmount;
        mapping(address => bool) relayers;
        mapping(address => bool) whitelistedAddress;
    }

    struct RewardInfo {
        bool canClaimRewards;
        uint8 nextRoundToReward;
        uint8 finalRewardRound;
        mapping(uint8 => uint256) totalAmountReferredPerRound;
        mapping(uint8 => uint256) notionalAmountPerRound;
    }

    struct ReferrerInfo {
        bool isActive;
        bool isBlacklisted;
        uint8 currentRoundToClaim;
        mapping(uint8 => uint256) shareOfAmountReferredPerRound;
    }

    function getCurrencyToReceive() external view returns (address);

    function getCurrentRewardsFunds() external view returns (uint256);

    function getVaultStatus(address prospect)
        external
        view
        returns (
            uint256 minAmount,
            uint256 maxAmount,
            bool canInvest,
            address currencyToRecieve
        );

    function getClaimableRewards(address referrer)
        external
        view
        returns (uint256);

    function canAccountInvest(address prospect) external view returns (bool);

    function canAccountClaim(address prospect) external view returns (bool);

    function creditReferrer(address referrerAddress, uint256 referrerAmount)
        external
        returns (bool);

    function claimRewards() external;

    function updateRelayers(address newRelayer, bool update) external;

    function updateAssetAddress(address newAssetAddress) external;

    function updateClientAddress(address newClientAddress) external;

    function skipRoundtoReward(uint8 roundToReward) external;

    function incrementRoundToReward() external;

    function updateFinalRewardRound(uint8 newFinalRound) external;

    function pauseRewards() external;

    function startRewards() external;

    function setWhitelistedAccounts(address[] memory whitelistedAddresses)
        external;

    function removeWhitelistedAccounts(address[] memory whitelistedAddresses)
        external;

    function addRewardFunds(uint256 totalRewardsFunds) external;

    function withdrawRewardFunds(uint256 amountToWithdraw) external;
}

// SPDX-License-Identifier: MIT
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
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
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

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}