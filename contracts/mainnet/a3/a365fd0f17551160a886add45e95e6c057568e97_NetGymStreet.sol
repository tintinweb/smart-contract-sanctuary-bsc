// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./interfaces/IAmountsDistributor.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/INetGymStreet.sol";
import "./interfaces/INFTReflection.sol";
import "./interfaces/IBuyAndBurn.sol";

contract DistributeAmounts is OwnableUpgradeable, ReentrancyGuardUpgradeable, IAmountsDistributor {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /// @notice Operation type constants
    uint8 private constant OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS = 10;
    uint8 private constant OPERATION_TYPE_MINT_MINERS = 20;
    uint8 private constant OPERATION_TYPE_PURCHASE_ELECTRICITY = 30;
    uint8 private constant OPERATION_TYPE_PURCHASE_REPAIR = 40;

    // @notice Wallet addresses
    address public ambassadorWalletAddress;
    address public reserveWalletAddress;
    address public companyWalletAddress;

    // Addresses of Gymstreet smart contracts
    address public nftReflectionPoolAddress;
    address public netGymStreetAddress;
    address public nftRankRewardsAddress;

    // Addresses of GymNet smart contracts
    address public gymTurnoverPoolAddress;
    address public buyAndBurnAddress;

    // Token addresses for interacint with liquidity pools
    address public busdAddress;
    address public wbnbAddress;

    // PancakeSwap router address
    address public routerAddress;

    /// @notice Wallets to be replaced
    address public vBTCBuyAndBurnWallet;
    address public liquidityWallet;

    // @notice Amounts that we keep track of in the Municipality smart contract (in BUSD)
    uint256 public linearBuyAndBurnAmountVBTC;
    uint256 public vbtcLiquidityAmount;

    address public municipalityAddress;
    address public companyWalletMetablocks;

    // @notice Operation Type to percentages
    mapping(uint8 => uint256[10]) public operationTypeToPercentagesMapping;

    event NFTContractAddressesSet(address[3] indexed nftContractAddresses);
    event DistributionReceiverAddressesSet(address[12] indexed nftContractAddresses);

    modifier onlyMunicipality() {
        require(msg.sender == municipalityAddress, "MinerPublicBuilding: Only municipality is authorized to call this function");
        _;
    }

    // @notice Proxy SC support - initialize internal state
    function initialize(
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        // @notice Array index to distribution percentage
        // [0:companyWallet, 1:nftReflectionPool, 2:buyAndBurnVBTC, 3:addLiquidity, 4:buynAndBurnGym,
        // 5:gymTurnoverPool, 6:netGymStreet, 7:reserveWallet, 8:ambassador, 9:nftRankRewards]

        operationTypeToPercentagesMapping[OPERATION_TYPE_MINT_MINERS] = [
            20, // companyWallet
            5, // nftReflectionPool
            7, // buyAndBurnVBTC
            8, // addVBTCLiquidity
            10, // buynAndBurnGym
            3, // gymTurnoverPool
            39, // netGymStreet
            7, // reserveWallet
            5, // ambassador
            23 //nftRankRewards
        ];
        operationTypeToPercentagesMapping[OPERATION_TYPE_PURCHASE_REPAIR] = [
            20, // companyWallet
            5, // nftReflectionPool
            7, // buyAndBurnVBTC
            8, // addVBTCLiquidity
            10, // buynAndBurnGym
            3, // gymTurnoverPool
            39, // netGymStreet
            7, // reserveWallet
            5, // ambassador
            23 //nftRankRewards
        ];
        operationTypeToPercentagesMapping[OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS] = [
            20, // companyWallet
            5, // nftReflectionPool
            6, // buyAndBurnVBTC
            4, // addVBTCLiquidity
            15, // buynAndBurnGym
            3, // gymTurnoverPool
            39, // netGymStreet
            7, // reserveWallet
            5, // ambassador
            23 //nftRankRewards
        ];
        operationTypeToPercentagesMapping[OPERATION_TYPE_PURCHASE_ELECTRICITY] = [
            20, // companyWallet
            0, // nftReflectionPool
            40, // buyAndBurnVBTC
            0, // addVBTCLiquidity
            40, // buynAndBurnGym
            0, // gymTurnoverPool
            0, // netGymStreet
            0, // reserveWallet
            0, // ambassador
            0 //nftRankRewards
        ];
    }

    function distributeAmounts(uint256 _amount, uint8 _operationType, address _user) external onlyMunicipality {
        _distributeAmounts(_amount, _operationType, _user);
    }

    /// @notice Set contract addresses for all NFTs we currently have
    function setNFTContractAddresses(address[3] calldata _nftContractAddresses) external onlyOwner {
        routerAddress =  _nftContractAddresses[0];
        busdAddress = _nftContractAddresses[1];
        wbnbAddress = _nftContractAddresses[2];

        emit NFTContractAddressesSet( _nftContractAddresses);
    }

    /// @notice Set addresses to all smart contract and wallet addresses we currently distribute the amounts to
    function setDistributionReceiverAddresses(address[12] calldata _distributionReceiverAddresses) external onlyOwner {
        nftReflectionPoolAddress = _distributionReceiverAddresses[0];
        netGymStreetAddress = _distributionReceiverAddresses[1];
        ambassadorWalletAddress = _distributionReceiverAddresses[2];
        reserveWalletAddress = _distributionReceiverAddresses[3];
        companyWalletAddress = _distributionReceiverAddresses[4];
        gymTurnoverPoolAddress =_distributionReceiverAddresses[5];
        buyAndBurnAddress = _distributionReceiverAddresses[6];
        nftRankRewardsAddress = _distributionReceiverAddresses[7];
        vBTCBuyAndBurnWallet = _distributionReceiverAddresses[8];
        liquidityWallet = _distributionReceiverAddresses[9];
        municipalityAddress = _distributionReceiverAddresses[10];
        companyWalletMetablocks = _distributionReceiverAddresses[11];

        emit DistributionReceiverAddressesSet(_distributionReceiverAddresses);
    }

    // @notice Distribution of the received amount
    function _distributeAmounts(uint256 _amount, uint8 _operationType, address _user) private {
        address companyAddress = companyWalletAddress;
        if(
            _operationType == OPERATION_TYPE_MINT_MINERS || 
            _operationType == OPERATION_TYPE_PURCHASE_REPAIR || 
            _operationType == OPERATION_TYPE_PURCHASE_ELECTRICITY
        ){
            companyAddress = companyWalletMetablocks;
        }

        uint256[10] memory distributionPercentages = operationTypeToPercentagesMapping[_operationType];
        // transfer 20% to company Wallet
        _transferAmountTo((_amount * distributionPercentages[0]) / 100, companyAddress);
        // transfer 5% to NFT Reflection pool and distribute according to gGymnet shares
        _distributeNftReflectionPool((_amount * distributionPercentages[1]) / 100);
        // transfer 6% or 7% to managemnent wallet for further buyandburn / 40% for electricity
        linearBuyAndBurnAmountVBTC += ((_amount * distributionPercentages[2]) / 100);
        _transferAmountTo((_amount * distributionPercentages[2]) / 100, vBTCBuyAndBurnWallet);
        // transfer 8% or 4% to management wallet for vBTC liquidity
        vbtcLiquidityAmount += (distributionPercentages[3] * _amount) / 100;
        _transferAmountTo((_amount * distributionPercentages[3]) / 100, liquidityWallet);
        // transfer 10% or 15% to Gymnet buyAndBurn adrress / 40% for electricity
        _buyAndBurnGYMNET((distributionPercentages[4] * _amount) / 100);
        // transfer 3% to gym turnover pool address
        _transferAmountTo((_amount * distributionPercentages[5]) / 100, gymTurnoverPoolAddress);
        // transfer 39% to NFTMLM and distribute among referrers accordingly
        _distributeNetGymStreet((_amount * distributionPercentages[6]) / 100, _amount, _user);
        // transfer 0.7% to reserve Wallet
        _transferAmountTo((_amount * distributionPercentages[7]) / 1000, reserveWalletAddress);
        // transfer 5% to Ambassador Wallet
        _transferAmountTo((_amount * distributionPercentages[8]) / 100, ambassadorWalletAddress);
        // transfer 2.3% to NFT RankRewards wallet
        _transferAmountTo((distributionPercentages[9] * _amount) / 1000, nftRankRewardsAddress);
    }

    function _distributeNftReflectionPool(uint256 _amount) private {
        if (_amount > 0) {
            _transferAmountTo(_amount, nftReflectionPoolAddress);
            INftReflection(nftReflectionPoolAddress).updatePool(_amount);
        }
    }

    function _distributeNetGymStreet(
        uint256 _amount,
        uint256 _distributeAmount,
        address _user
    ) private {
        if (_amount > 0) {
            _transferAmountTo(_amount, netGymStreetAddress);
            INetGymStreet(netGymStreetAddress).distributeRewards(
                _distributeAmount,
                busdAddress,
                _user
            );
        }
    }

    /// @notice Transfer the given amount to a specified wallet
    function _transferAmountTo(uint256 _amount, address _walletAddress) private {
        if (_amount > 0) {
            IERC20Upgradeable(busdAddress).safeTransfer(_walletAddress, _amount);
        }
    }

    /// @notice Convert the amounts
    function _convertBUSDtoBNB(uint256 _amount) private returns (uint256) {
        IERC20Upgradeable(busdAddress).safeApprove(routerAddress, _amount);
        return _swapTokens(busdAddress, wbnbAddress, _amount, address(this), block.timestamp + 100);
    }

    /// @notice Swap the given tokens
    function _swapTokens(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        address receiver,
        uint256 deadline
    ) private returns (uint256) {
        require(inputToken != outputToken, "Municipality: Invalid swap path");

        address[] memory path = new address[](2);

        path[0] = inputToken;
        path[1] = outputToken;

        uint256[] memory swapResult = IPancakeRouter02(routerAddress).swapExactTokensForTokens(
            inputAmount,
            0,
            path,
            receiver,
            deadline
        );
        return swapResult[1];
    }

    /// @notice Buy and burn previously distributed amount
    function _buyAndBurnGYMNET(uint256 _buyAndBurnAmountGYM) private {
        IERC20Upgradeable(busdAddress).safeTransfer(buyAndBurnAddress, _buyAndBurnAmountGYM);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
pragma solidity ^0.8.15;

interface IAmountsDistributor {
    function distributeAmounts(uint256 _amount, uint8 _operationType, address _user) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface INetGymStreet {
    function addGymMlm(address _user, uint256 _referrerId) external;

    function distributeRewards(
        uint256 _wantAmt,
        address _wantAddr,
        address _user
    ) external;

    function getUserCurrentLevel(address _user) external view returns (uint256);

    function updateAdditionalLevel(address _user, uint256 _level) external;

    function getInfoForAdditionalLevel(address _user) external view returns (uint256 _termsTimestamp, uint256 _level);

    function lastPurchaseDateERC(address _user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface INftReflection {
    struct UserInfo {
        uint256 totalGgymnetAmt;
        uint256 rewardsClaimt;
        uint256 rewardDebt;
    }

    function pendingReward(address) external view returns (uint256);

    function updateUser(
        uint256,
        address
    ) external;
    function updatePool(
        uint256
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IBuyAndBurn {
    function buyAndBurnGymWithBNB(
        uint256,
        uint256,
        uint256
    ) external returns (uint256);

    function buyAndBurnGymWithBUSD(
        uint256,
        uint256,
        uint256
    ) external returns (uint256);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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

pragma solidity 0.8.15;

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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./interfaces/IMinerPublicBuildingInterface.sol";
import "./interfaces/ISignatureValidator.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IParcelInterface.sol";
import "./interfaces/INetGymStreet.sol";
import "./interfaces/IERC721Base.sol";
import "./interfaces/IBuyAndBurn.sol";
import "./interfaces/IMinerNFT.sol";
import "./interfaces/IMining.sol";
import "./interfaces/IAmountsDistributor.sol";

contract Municipality is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct AttachedMiner {
        uint256 parcelId;
        uint256 minerId;
    }

    struct Parcel {
        uint16 x;
        uint16 y;
        uint8 parcelType;
        uint8 parcelLandType;
    }

    // Used to keep Parcel information
    struct ParcelInfo {
        bool isUpgraded;
        uint8 parcelType;
        uint8 parcelLandType;
        bool isValid;
    }

    struct BundleInfo {
        uint256 parcelsAmount;
        uint256 minersAmount;
        uint256 bundlePrice;
        uint256 discountPct;
    }

    struct ParcelsMintSignature {
        Parcel[] parcels;
        bytes[] signatures;
    }

    struct MintedNFT {
        uint256 firstNFTId;
        uint256 count;
    }

    uint8 private constant OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS = 10;
    uint8 private constant OPERATION_TYPE_MINT_MINERS = 20;
    uint8 private constant OPERATION_TYPE_PURCHASE_ELECTRICITY = 30;
    uint8 private constant OPERATION_TYPE_PURCHASE_REPAIR = 40;

    uint8 private constant MINER_STATUS_DETACHED = 10;
    uint8 private constant MINER_STATUS_ATTACHED = 20;

    uint8 private constant PARCEL_TYPE_STANDARD = 10;
    uint8 private constant PARCEL_TYPE_BUSINESS = 20;

    uint8 private constant PARCEL_LAND_TYPE_NEXT_TO_OCEAN = 10;
    uint8 private constant PARCEL_LAND_TYPE_NEAR_OCEAN = 20;
    uint8 private constant PARCEL_LAND_TYPE_INLAND = 30;

    uint8 private constant BUNDLE_TYPE_PARCELS_MINERS_1 = 0;
    uint8 private constant BUNDLE_TYPE_PARCELS_1 = 1;
    uint8 private constant BUNDLE_TYPE_PARCELS_2 = 2;
    uint8 private constant BUNDLE_TYPE_PARCELS_3 = 3;
    uint8 private constant BUNDLE_TYPE_PARCELS_4 = 4;
    uint8 private constant BUNDLE_TYPE_PARCELS_5 = 5;
    uint8 private constant BUNDLE_TYPE_PARCELS_6 = 6;
    uint8 private constant BUNDLE_TYPE_MINERS_1 = 7;
    uint8 private constant BUNDLE_TYPE_MINERS_2 = 8;
    uint8 private constant BUNDLE_TYPE_MINERS_3 = 9;
    uint8 private constant BUNDLE_TYPE_MINERS_4 = 10;
    uint8 private constant BUNDLE_TYPE_MINERS_5 = 11;
    uint8 private constant BUNDLE_TYPE_MINERS_6 = 12;
    
    /// @notice Pricing information (in BUSD)
    uint256 public upgradePrice;
    uint256 public minerPrice;
    uint256 public minerRepairPrice;
    uint256 public electricityVoucherPrice;

    /// @notice Addresses of Gymstreet smart contracts
    address public standardParcelNFTAddress;
    address public businessParcelNFTAddress;
    address public minerV1NFTAddress;
    address public miningAddress;
    address public busdAddress;
    address public netGymStreetAddress;
    address public signatureValidatorAddress;

    mapping(address => uint256) public userToPurchasedAmountMapping;

    /// @notice Parcels pricing changes per percentage
    mapping(uint256 => uint256) public soldCountToStandardParcelPriceMapping;
    mapping(uint256 => uint256) public soldCountToBusinessParcelPriceMapping;
    uint256 public currentlySoldStandardParcelsCount;
    uint256 public currentlySoldBusinessParcelsCount;
    uint256 public currentStandardParcelPrice;
    uint256 public currentBusinessParcelPrice;

    /// @notice Parcel <=> Miner attachments and Parcel/Miner properties
    mapping(uint256 => uint256[]) public parcelMinersMapping;
    mapping(uint256 => uint256) public minerParcelMapping;
    uint8 public standardParcelSlotsCount;
    uint8 public upgradedParcelSlotsCount;

    /// @notice Electricity voucher mapping to user who owns them
    mapping(address => uint256) public userToElectricityVoucherAmountMapping;

    /// @notice Timestamps the user requested repair
    mapping(address => uint256[]) public userToRepairDatesMapping;

    /// @notice Signatures when minting a parcel
    mapping(bytes => bool) public mintParcelsUsedSignaturesMapping;

    /// @notice Array of all available bundles OLD VERSION DEPRICATED
    BundleInfo[6] public bundles;

    /// @notice Indicator if the sales can happen
    bool public isSaleActive;

    address public minerPublicBuildingAddress;
    address public amountsDistributorAddress;

    /// @notice Array of all available bundles
    BundleInfo[13] public newBundles;

    
    struct LastPurchaseData {
        uint256 lastPurchaseDate;
        uint256 expirationDate;
        uint256 dollarValue;
    }
    mapping(address => LastPurchaseData) public lastPurchaseData;

    // ------------------------------------ EVENTS ------------------------------------ //

    event ParcelsSoldCountPricingSet(
        uint256[] indexed standardParcelPrices, 
        uint256[] indexed businessParcelPrices
    );
    event BundlesSet(BundleInfo[13] indexed bundles);
    event ParcelsSlotsCountSet(
        uint8 indexed standardParcelSlotsCount,
        uint8 indexed upgradedParcelSlotsCount
    );
    event PurchasePricesSet(
        uint256 upgradePrice,
        uint256 minerPrice,
        uint256 minerRepairPrice,
        uint256 electricityVoucherPrice
    );
    event SaleActivationSet(bool indexed saleActivation);
    event BundlePurchased(address indexed user, uint256 indexed bundleType);
    event MinerAttached(address user, uint256 indexed parcelId, uint256 indexed minerId);
    event MinerDetached(address indexed user, uint256 indexed parcelId, uint256 indexed minerId);
    event VouchersPurchased(address indexed user, uint256 vouchersCount);
    event MinersRepaired(address indexed user, uint256 minersCount);
    event VouchersApplied(address indexed user, uint256[] minerIds);
    event StandardParcelUpgraded(address indexed user, uint256 indexed parcelId);
    event NFTContractAddressesSet(address[9] indexed _nftContractAddresses);

    /// @notice Modifier for 0 address check
    modifier notZeroAddress() {
        require(address(0) != msg.sender, "Municipality: Caller can not be address 0");
        _;
    }

    /// @notice Modifier not to allow sales when it is made inactive
    modifier onlySaleActive() {
        require(isSaleActive, "Municipality: Sale is deactivated now");
        _;
    }

    /// @notice Access to only the miner public building
    modifier onlyMinerPublicBuilding() {
        require(msg.sender == minerPublicBuildingAddress, "Municipality: This function is available only to a miner public building");
        _;
    }

    // @notice Proxy SC support - initialize internal state
    function initialize(
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    receive() external payable {}

    fallback() external payable {}

    /// @notice Public interface

    /// @notice Array of the prices is given in the following way [sold_count1, price1, sold_count2, price2, ...]
    function setParcelsSoldCountPricing(
        uint256[] calldata _standardParcelPrices,
        uint256[] calldata _businessParcelPrices
    ) external onlyOwner notZeroAddress {
        require(_standardParcelPrices[0] == 0, "Municipality: The given standard parcel array must start from 0");
        require(_businessParcelPrices[0] == 0, "Municipality: The given business parcel array must start from 0");
        for (uint8 i = 0; i < _standardParcelPrices.length; i += 2) {
            uint256 standardParcelSoldCount = _standardParcelPrices[i];
            uint256 standardParcelPrice = _standardParcelPrices[i + 1];
            soldCountToStandardParcelPriceMapping[standardParcelSoldCount] = standardParcelPrice;
        }
        for (uint8 i = 0; i < _businessParcelPrices.length; i += 2) {
            uint256 businessParcelSoldCount = _businessParcelPrices[i];
            uint256 businessParcelPrice = _businessParcelPrices[i + 1];
            soldCountToBusinessParcelPriceMapping[businessParcelSoldCount] = businessParcelPrice;
        }
        emit ParcelsSoldCountPricingSet(_standardParcelPrices, _businessParcelPrices);
    }

    /// @notice Update bundles
    function setBundles(BundleInfo[13] calldata _bundles) external onlyOwner notZeroAddress {
        newBundles = _bundles;
        emit BundlesSet(_bundles);
    }

    /// @notice Set contract addresses for all NFTs we currently have
    function setNFTContractAddresses(address[9] calldata _nftContractAddresses) external onlyOwner {
        standardParcelNFTAddress = _nftContractAddresses[0];
        businessParcelNFTAddress = _nftContractAddresses[1];
        minerV1NFTAddress = _nftContractAddresses[2];
        miningAddress = _nftContractAddresses[3];
        busdAddress = _nftContractAddresses[4];
        netGymStreetAddress = _nftContractAddresses[5];
        minerPublicBuildingAddress = _nftContractAddresses[6];
        signatureValidatorAddress = _nftContractAddresses[7];
        amountsDistributorAddress = _nftContractAddresses[8];
        emit NFTContractAddressesSet(_nftContractAddresses);
    }
    
    /// @notice Set the number of slots available for the miners for standard and upgraded parcels
    function setParcelsSlotsCount(uint8[2] calldata _parcelsSlotsCount) external onlyOwner {
        standardParcelSlotsCount = _parcelsSlotsCount[0];
        upgradedParcelSlotsCount = _parcelsSlotsCount[1];

        emit ParcelsSlotsCountSet(_parcelsSlotsCount[0], _parcelsSlotsCount[1]);
    }

    /// @notice Set the prices for all different entities we currently sell
    function setPurchasePrices(uint256[4] calldata _purchasePrices) external onlyOwner {
        upgradePrice = _purchasePrices[0];
        minerPrice = _purchasePrices[1];
        minerRepairPrice = _purchasePrices[2];
        electricityVoucherPrice = _purchasePrices[3];

        emit PurchasePricesSet(
            _purchasePrices[0],
            _purchasePrices[1],
            _purchasePrices[2],
            _purchasePrices[3]
        );
    }

    /// @notice Activate/Deactivate sales
    function setSaleActivation(bool _saleActivation) external onlyOwner {
        isSaleActive = _saleActivation;
        emit SaleActivationSet(_saleActivation);
    }

    // @notice (Purchase) Generic minting functionality for parcels, regardless the currency
    function mintParcels(ParcelsMintSignature calldata _mintingSignature, uint256 _referrerId)
        external
        onlySaleActive
        notZeroAddress
    {
        require(ISignatureValidator(signatureValidatorAddress).verifySigner(_mintingSignature), "Municipality: Not authorized signer");
        INetGymStreet(netGymStreetAddress).addGymMlm(msg.sender, _referrerId);
        (uint256 purchasePrice,) = _getPriceForParcels(_mintingSignature.parcels);
        uint256 percentage;
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        if(_mintingSignature.parcels.length >= 240) {
            percentage = 18;
        } else if(_mintingSignature.parcels.length >= 140) {
            percentage = 16;
        } else if(_mintingSignature.parcels.length >= 80) {
            percentage = 12;
        } else if(_mintingSignature.parcels.length >= 40) {
            percentage = 10;
        } else if(_mintingSignature.parcels.length >= 10) {
            percentage = 8;
        } else if(_mintingSignature.parcels.length >= 4) {
            percentage = 5;
        }
        uint256 discountedPrice = _discountPrice(purchasePrice, percentage);
        _transferToContract(discountedPrice);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(discountedPrice, OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS, msg.sender);
        userToPurchasedAmountMapping[msg.sender] += discountedPrice;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += discountedPrice;
        _lastPurchaseDateUpdate(msg.sender);
        IParcelInterface(standardParcelNFTAddress).mintParcels(msg.sender, _mintingSignature.parcels);
        currentlySoldStandardParcelsCount += _mintingSignature.parcels.length;
    }

    // @notice (Purchase) Mint the given amount of miners
    function mintMiners(uint256 _count, uint256 _referrerId) external onlySaleActive notZeroAddress returns(uint256, uint256)
    {
        INetGymStreet(netGymStreetAddress).addGymMlm(msg.sender, _referrerId);
        uint256 purchasePrice = _count * minerPrice;
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        uint256 percentage;
         if(_count >= 240) {
            percentage = 18;
        } else if(_count >= 140) {
            percentage = 16;
        } else if(_count >= 80) {
            percentage = 12;
        } else if(_count >= 40) {
            percentage = 10;
        } else if(_count >= 10) {
            percentage = 8;
        } else if(_count >= 4) {
            percentage = 5;
        }
        uint256 discountedPrice = _discountPrice(purchasePrice, percentage);
        _transferToContract(discountedPrice);
        userToPurchasedAmountMapping[msg.sender] += discountedPrice;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += discountedPrice;
        _lastPurchaseDateUpdate(msg.sender);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(discountedPrice, OPERATION_TYPE_MINT_MINERS, msg.sender);
        return IMinerNFT(minerV1NFTAddress).mintMiners(msg.sender, _count);
    }

    function purchaseBasicBundle(uint8 _bundleType, ParcelsMintSignature calldata _mintingSignature,
        uint256 _referrerId) external onlySaleActive notZeroAddress
    {
        _validateBasicBundleType(_bundleType);
        _requireOnlyStandardParcels(_mintingSignature.parcels);
        require(ISignatureValidator(signatureValidatorAddress).verifySigner(_mintingSignature), "Municipality: Not authorized signer");
        BundleInfo memory bundle = newBundles[_bundleType];
        require(_mintingSignature.parcels.length == bundle.parcelsAmount, "Municipality: Invalid parcels amount");
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        INetGymStreet(netGymStreetAddress).addGymMlm(msg.sender, _referrerId);
        uint256 bundlePurchasePrice = _discountPrice(bundle.bundlePrice, bundle.discountPct);
        _transferToContract(bundlePurchasePrice);
        userToPurchasedAmountMapping[msg.sender] += bundlePurchasePrice;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += bundlePurchasePrice;
        _lastPurchaseDateUpdate(msg.sender);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(
            bundlePurchasePrice,
            OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS,
            msg.sender
        );
        uint256[] memory parcelIds = IMinerPublicBuildingInterface(minerPublicBuildingAddress).mintParcelsBundle(msg.sender, _mintingSignature.parcels);
        (uint256 minerIdPair0, uint256 minerIdPair1) = IMinerPublicBuildingInterface(minerPublicBuildingAddress).mintMinersBundle(msg.sender, bundle.minersAmount);
        uint256[] memory minerIds = new uint256[](minerIdPair1);
        uint256 index = 0;
        for(uint256 minerId = minerIdPair0; minerId < minerIdPair0 + minerIdPair1; minerId++) {
            minerIds[index] = minerId;
            index++;
        }
        _automaticallyAttachMinersToParcels(parcelIds, minerIds, minerIds.length);
        currentlySoldStandardParcelsCount += bundle.parcelsAmount;
        emit BundlePurchased(msg.sender, _bundleType);
    }

    function purchaseParcelsBundle(uint8 _bundleType, ParcelsMintSignature calldata _mintingSignature,
        uint256 _referrerId) external onlySaleActive notZeroAddress
    {
        _validateParcelsBundleType(_bundleType);
        _requireOnlyStandardParcels(_mintingSignature.parcels);
        require(ISignatureValidator(signatureValidatorAddress).verifySigner(_mintingSignature), "Municipality: Not authorized signer");
        BundleInfo memory bundle = newBundles[_bundleType];
        require(_mintingSignature.parcels.length == bundle.parcelsAmount, "Municipality: Invalid parcels amount");
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        INetGymStreet(netGymStreetAddress).addGymMlm(msg.sender, _referrerId);
        uint256 bundlePurchasePrice = _discountPrice(bundle.bundlePrice, bundle.discountPct);
        _transferToContract(bundlePurchasePrice);
        userToPurchasedAmountMapping[msg.sender] += bundlePurchasePrice;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += bundlePurchasePrice;
        _lastPurchaseDateUpdate(msg.sender);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(
            bundlePurchasePrice,
            OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS,
            msg.sender
        );
        IMinerPublicBuildingInterface(minerPublicBuildingAddress).mintParcelsBundle(msg.sender, _mintingSignature.parcels);
        currentlySoldStandardParcelsCount += bundle.parcelsAmount;
        emit BundlePurchased(msg.sender, _bundleType);
    }

    function purchaseMinersBundle(uint8 _bundleType, uint256 _referrerId) external onlySaleActive notZeroAddress returns(uint256, uint256) {
        _validateMinersBundleType(_bundleType);
        INetGymStreet(netGymStreetAddress).addGymMlm(msg.sender, _referrerId);
        BundleInfo memory bundle = newBundles[_bundleType];
        uint256 bundlePurchasePrice = _discountPrice(bundle.bundlePrice, bundle.discountPct);
        _transferToContract(bundlePurchasePrice);
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        userToPurchasedAmountMapping[msg.sender] += bundlePurchasePrice;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += bundlePurchasePrice;
        _lastPurchaseDateUpdate(msg.sender);
        uint256 minersAmount = bundle.minersAmount;
        uint256 minersPurchasePrice = _discountPrice(minersAmount * minerPrice, bundle.discountPct);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(minersPurchasePrice, OPERATION_TYPE_MINT_MINERS, msg.sender);
        (uint256 firstMinerId, uint256 count) = IMinerPublicBuildingInterface(minerPublicBuildingAddress).mintMinersBundle(msg.sender, minersAmount);
        emit BundlePurchased(msg.sender, _bundleType);
        return (firstMinerId, count);
    }

    // granting free Parcels to selected user 
    function grantParcels(ParcelsMintSignature calldata _mintingSignature,
        uint256 _referrerId, address _user) external onlyOwner {
        require(_mintingSignature.parcels.length <= 240, "Municipality: The amount of miners should be less or equal to 240");
        _requireOnlyStandardParcels(_mintingSignature.parcels);
        require(ISignatureValidator(signatureValidatorAddress).verifySigner(_mintingSignature), "Municipality: Not authorized signer");
        INetGymStreet(netGymStreetAddress).addGymMlm(_user, _referrerId);
        IParcelInterface(standardParcelNFTAddress).mintParcels(_user, _mintingSignature.parcels);
        currentlySoldStandardParcelsCount += _mintingSignature.parcels.length;
    }

    // granting free Miners to selected user
    function grantMiners(uint8 _minersAmount, uint256 _referrerId, address _user) external onlyOwner returns(uint256, uint256) {
        require(_minersAmount <= 240, "Municipality: The amount of miners should be less than or equal to 240");
        INetGymStreet(netGymStreetAddress).addGymMlm(_user, _referrerId);
        (uint256 firstMinerId, uint256 count) = IMinerNFT(minerV1NFTAddress).mintMiners(_user, _minersAmount);
        return (firstMinerId, count);
    }

    // @notice (Purchase) Purchase a given amount of el. vouchers
    function purchaseVouchers(uint16 count) external onlySaleActive notZeroAddress {
        uint256 _amount = count * electricityVoucherPrice;
        _transferToContract(_amount);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(_amount, OPERATION_TYPE_PURCHASE_ELECTRICITY, msg.sender);
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        userToElectricityVoucherAmountMapping[msg.sender] += count;
        userToPurchasedAmountMapping[msg.sender] += _amount;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += _amount;
        _lastPurchaseDateUpdate(msg.sender);
        emit VouchersPurchased(msg.sender, count);
    }

    // @notice (Purchase) Repair ALL miners - reset the amortization points in the mining SC.
    function repairAllMiners() external onlySaleActive notZeroAddress {
        uint256 minersCount = IMining(miningAddress).getMinersCount(msg.sender);
        uint256 _amount = minersCount * minerRepairPrice;
        _transferToContract(_amount);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(_amount, OPERATION_TYPE_PURCHASE_REPAIR, msg.sender);
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        userToRepairDatesMapping[msg.sender].push(block.timestamp);
        userToPurchasedAmountMapping[msg.sender] += _amount;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += _amount;
        _lastPurchaseDateUpdate(msg.sender);
        IMining(miningAddress).repairMiners(msg.sender);
        emit MinersRepaired(msg.sender, minersCount);
    }

    // @notice Apply a voucher from the user's balance to a selected miner
    // We won't use the amount of vouchers to be used in this function.  
    // But just to keep things consistent with the Back/Front ends we will keep the arguments the same
    function applyVoucher(uint256, uint256[] memory minerIds) external notZeroAddress {
        uint256 numAvailableVouchers = userToElectricityVoucherAmountMapping[msg.sender];
        require(
            numAvailableVouchers >= minerIds.length,
            "Municipality: Not enough vouchers on balance"
        );
        userToElectricityVoucherAmountMapping[msg.sender] = numAvailableVouchers - minerIds.length;
        IMining(miningAddress).applyVouchers(msg.sender, minerIds);
        emit VouchersApplied(msg.sender, minerIds);
    }

    // @notice Attach/Detach the miners
    function attachDetachMinersToParcel(uint256[] calldata minersToAttach, uint256 parcelId) external notZeroAddress {
        require(IERC721Base(standardParcelNFTAddress).exists(parcelId), "Municipality: Parcel doesnt exist");
        _requireMinersCountMatchingWithParcelSlots(parcelId, minersToAttach.length);
        require(
            IERC721Base(standardParcelNFTAddress).ownerOf(parcelId) == msg.sender,
            "Municipality: Invalid parcel owner"
        );
        IMinerNFT(minerV1NFTAddress).requireNFTsBelongToUser(minersToAttach, msg.sender);
        _attachDetachMinersToParcel(minersToAttach, parcelId);
    }

    /// @notice Used by MinerPublicBuilding to attach miner to a parcel
    function attachMinerToParcel(address user, uint256 firstMinerId, uint256[] calldata parcelIds) external onlyMinerPublicBuilding {
        uint32 minerCounter = 0;
        for (uint16 i = 0; i < parcelIds.length; i++) {
            for (uint16 j = 0; j < 4; j++) {
                minerParcelMapping[firstMinerId + minerCounter] = parcelIds[i];
                parcelMinersMapping[parcelIds[i]].push(firstMinerId + minerCounter);
                minerCounter++;
                emit MinerAttached(user, parcelIds[i], firstMinerId + minerCounter);
            }
        }
    }

    /// @notice Upgrade the standard parcel
    function upgradeStandardParcel(uint256 _parcelId) external onlySaleActive {
        require(
            IERC721Base(standardParcelNFTAddress).ownerOf(_parcelId) == msg.sender,
            "Municipality: Invalid NFT owner"
        );
        bool isParcelUpgraded = IParcelInterface(standardParcelNFTAddress).isParcelUpgraded(_parcelId);
        require(!isParcelUpgraded, "Municipality: Parcel is already upgraded");
        _transferToContract(upgradePrice);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(upgradePrice, OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS, msg.sender);
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        userToPurchasedAmountMapping[msg.sender] += upgradePrice;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += upgradePrice;
        _lastPurchaseDateUpdate(msg.sender);
        IParcelInterface(standardParcelNFTAddress).upgradeParcel(_parcelId);
        emit StandardParcelUpgraded(msg.sender, _parcelId);
    }

    // @notice App will use this function to get the price for the selected parcels
    function getPriceForParcels(Parcel[] calldata parcels) external view returns (uint256, uint256) {
        (uint256 price, uint256 unitPrice) = _getPriceForParcels(parcels);
        return (price, unitPrice);
    }
    
    function getUserMiners(address _user) external view returns (AttachedMiner[] memory) {
        uint256[] memory userMiners = IERC721Base(minerV1NFTAddress).tokensOf(_user);
        AttachedMiner[] memory result = new AttachedMiner[](userMiners.length);
        for (uint256 i = 0; i < userMiners.length; ++i) {
            uint256 minerId = userMiners[i];
            uint256 parcelId = minerParcelMapping[minerId];
            result[i] = AttachedMiner(parcelId, minerId);
        }
        return result;
    }
    // TODO: This function should be removed after 30 days from upgrade as the expiration date is in mapping lastPurchaseData
    function getNFTPurchaseExpirationDate(address _user) external view returns(uint256) {
        if(lastPurchaseData[_user].expirationDate > (INetGymStreet(netGymStreetAddress).lastPurchaseDateERC(_user) + 30 days)) {
            return lastPurchaseData[_user].expirationDate;
        } else {
            return INetGymStreet(netGymStreetAddress).lastPurchaseDateERC(_user) + 30 days;
        } 
    }

    function isTokenLocked(address _tokenAddress, uint256 _tokenId) external view returns(bool) { 
        if(_tokenAddress == minerV1NFTAddress) {
            return minerParcelMapping[_tokenId] > 0;
        } else if(_tokenAddress == standardParcelNFTAddress) {
            return parcelMinersMapping[_tokenId].length > 0;
        } else {
            revert("Municipality: Unsupported NFT token address");
        }
    }

    /// @notice automatically attach free miners to parcels
    function automaticallyAttachMinersToParcels(uint256 numMiners) external {
        _automaticallyAttachMinersToParcels(
            IERC721Base(standardParcelNFTAddress).tokensOf(msg.sender),
            IERC721Base(minerV1NFTAddress).tokensOf(msg.sender),
            numMiners);
    }

    

    // @notice Private interface

    function _automaticallyAttachMinersToParcels(uint256[] memory parcelIds, uint256[] memory userMiners, uint256 numMiners) private {
        // uint256 minerHashrate = IMinerNFT(minerV1NFTAddress).hashrate();
        uint256 lastAvailableMinerIndex = 0;
        for(uint256 i = 0; i < parcelIds.length && lastAvailableMinerIndex < userMiners.length && numMiners > 0; ++i) {
            uint256 availableSize = standardParcelSlotsCount - parcelMinersMapping[parcelIds[i]].length;
            if(availableSize > 0) {
                for(uint256 j = 0; j < availableSize; ++j) {
                    if(numMiners != 0) {
                        for(uint256 k = lastAvailableMinerIndex; k < userMiners.length; ++k) {
                            lastAvailableMinerIndex = k + 1;
                            if(minerParcelMapping[userMiners[k]] == 0) {
                                parcelMinersMapping[parcelIds[i]].push(userMiners[k]);
                                minerParcelMapping[userMiners[k]] = parcelIds[i];
                                IMining(miningAddress).deposit(msg.sender, userMiners[k], 1000);
                                emit MinerAttached(msg.sender, parcelIds[i], userMiners[k]);
                                --numMiners;
                                break;
                            }
                        }

                    }
                }
            }
        }
    }

    /// @notice Transfers the given BUSD amount to distributor contract
    function _transferToContract(uint256 _amount) private {
        IERC20Upgradeable(busdAddress).safeTransferFrom(
            address(msg.sender),
            address(amountsDistributorAddress),
            _amount
        );
    }

    /// @notice Checks if the miner is in the given list
    function _isMinerInList(uint256 _tokenId, uint256[] memory _minersList) private pure returns (bool) {
        for (uint256 index; index < _minersList.length; index++) {
            if (_tokenId == _minersList[index]) {
                return true;
            }
        }
        return false;
    }

    /// @notice Validates if the bundle corresponds to a type from this smart contract
    function _validateBasicBundleType(uint8 _bundleType) private pure {
        require
        (
            _bundleType == BUNDLE_TYPE_PARCELS_MINERS_1,
            "Municipality: Invalid bundle type"
        );
    }

    function _validateParcelsBundleType(uint8 _bundleType) private pure {
        require
        (
            _bundleType == BUNDLE_TYPE_PARCELS_1 ||
            _bundleType == BUNDLE_TYPE_PARCELS_2 ||
            _bundleType == BUNDLE_TYPE_PARCELS_3 ||
            _bundleType == BUNDLE_TYPE_PARCELS_4 ||
            _bundleType == BUNDLE_TYPE_PARCELS_5 ||
            _bundleType == BUNDLE_TYPE_PARCELS_6,
            "Municipality: Invalid bundle type"
        );
    }

    /// @notice Validates if the bundle corresponds to a type from this smart contract
    function _validateMinersBundleType(uint8 _bundleType) private pure {
        require
        (
            _bundleType == BUNDLE_TYPE_MINERS_1 ||
            _bundleType == BUNDLE_TYPE_MINERS_2 ||
            _bundleType == BUNDLE_TYPE_MINERS_3 ||
            _bundleType == BUNDLE_TYPE_MINERS_4 ||
            _bundleType == BUNDLE_TYPE_MINERS_5 ||
            _bundleType == BUNDLE_TYPE_MINERS_6,
            "Municipality: Invalid bundle type"
        );
    }

    /// @notice Requires that only a standard parcel can perform the operation
    function _requireOnlyStandardParcels(Parcel[] memory parcels) private pure {
        for(uint256 index; index < parcels.length; index++) {
            require(
                parcels[index].parcelType == PARCEL_TYPE_STANDARD,
                "Municipality: Parcel does not have standard type"
            );
        }
    }

    /// @notice Requires the miner status to match with the given by a function argument status
    function _requireMinerStatus(uint256 miner, uint8 status, uint256 attachedParcelId) private view {
        if (status == MINER_STATUS_ATTACHED) {
            require(minerParcelMapping[miner] == attachedParcelId, "Municipality: Miner not attached to this parcel");
        } else if (status == MINER_STATUS_DETACHED) {
            uint256 attachedParcel = minerParcelMapping[miner];
            require(attachedParcel == 0, "Municipality: Miner is not detached");
        }
    }

    /// @notice Attach or detach the miners from/to parcel
    function _attachDetachMinersToParcel(uint256[] memory newMiners, uint256 parcelId) private {
        uint256[] memory oldMiners = parcelMinersMapping[parcelId];
        for (uint256 index; index < oldMiners.length; index++) {
            uint256 tokenId = oldMiners[index];
            if (!_isMinerInList(tokenId, newMiners)) {
                _requireMinerStatus(tokenId, MINER_STATUS_ATTACHED, parcelId);
                minerParcelMapping[tokenId] = 0;
                IMining(miningAddress).withdraw(msg.sender,tokenId);
                emit MinerDetached(msg.sender, parcelId, tokenId);
            }
        }
        uint256 minerHashrate = IMinerNFT(minerV1NFTAddress).hashrate();
        for (uint256 index; index < newMiners.length; index++) {
            uint256 tokenId = newMiners[index];
            if (!_isMinerInList(tokenId, oldMiners)) {
                _requireMinerStatus(tokenId, MINER_STATUS_DETACHED, parcelId);
                minerParcelMapping[tokenId] = parcelId;
                IMining(miningAddress).deposit(msg.sender, tokenId, minerHashrate);
                emit MinerAttached(msg.sender, parcelId, tokenId);
            }
        }
        parcelMinersMapping[parcelId] = newMiners;
    }

    /// @notice Require that the count of the miners match with the slots that are on a parcel (4 or 10)
    function _requireMinersCountMatchingWithParcelSlots(uint256 _parcelId, uint256 _count)
        private
        view
    {
        bool isParcelUpgraded = IParcelInterface(standardParcelNFTAddress).isParcelUpgraded(_parcelId);
        require(
            isParcelUpgraded
                ? _count <= upgradedParcelSlotsCount
                : _count <= standardParcelSlotsCount,
            "Municipality: Miners count exceeds parcel's slot count"
        );
    }

    /// @notice Returns the price of a given parcels
    function _getPriceForParcels(Parcel[] memory parcels) private view returns (uint256, uint256) {
        uint256 price = parcels.length * 100000000000000000000;
        uint256 unitPrice = 100000000000000000000;
        uint256 priceBefore = 0;
        uint256 totalParcelsToBuy = currentlySoldStandardParcelsCount + parcels.length;
        if(totalParcelsToBuy > 157500) {
            unitPrice = 301000000000000000000;
            if (currentlySoldStandardParcelsCount > 157500) {
                price = parcels.length * 301000000000000000000;
            } else {
                price = (parcels.length + currentlySoldStandardParcelsCount - 157500) * 301000000000000000000;
                priceBefore = (157500 - currentlySoldStandardParcelsCount) * 209000000000000000000;
            }
        } else if(totalParcelsToBuy > 105000) {
            unitPrice = 209000000000000000000;
             if (currentlySoldStandardParcelsCount > 105000) {
                price = parcels.length * 209000000000000000000;
            } else {
                price = (parcels.length + currentlySoldStandardParcelsCount - 105000) * 209000000000000000000;
                priceBefore = (105000 - currentlySoldStandardParcelsCount) * 144000000000000000000;
            }
        } else if(totalParcelsToBuy > 52500) {
            unitPrice = 144000000000000000000;
            if (currentlySoldStandardParcelsCount > 52500) {
                price = parcels.length * 144000000000000000000;
            } else {
                price = (parcels.length + currentlySoldStandardParcelsCount - 52500) * 144000000000000000000;
                priceBefore = (52500 - currentlySoldStandardParcelsCount) * 116000000000000000000;
            }
        } else if(totalParcelsToBuy > 21000) {
             unitPrice = 116000000000000000000;
            if (currentlySoldStandardParcelsCount > 21000) {
                price = parcels.length * 116000000000000000000; 
            } else {
                price = (parcels.length + currentlySoldStandardParcelsCount - 21000) * 116000000000000000000;
                priceBefore = (21000 - currentlySoldStandardParcelsCount) * 100000000000000000000;
            }
            
        }
        return (priceBefore + price, unitPrice);
    }

    /// @notice Returns the discounted price of the bundle
    function _discountPrice(uint256 _price, uint256 _percentage) private pure returns (uint256) {
        return _price - (_price * _percentage) / 100;
    }

     /**
     * @notice Private function to update additional level in GymStreet
     * @param _user: user address
     */
    function _updateAdditionLevel(address _user) private {
        uint256 _additionalLevel;
        (uint256 termTimestamp, uint256 _gymLevel) = INetGymStreet(netGymStreetAddress).getInfoForAdditionalLevel(_user);
        if (termTimestamp + 1209600 > block.timestamp){ // 14 days
            if (userToPurchasedAmountMapping[_user] >= 20000 * 1e18) {
                _additionalLevel = 14;
            } else if (userToPurchasedAmountMapping[_user] >= 5000 * 1e18) {
                _additionalLevel = 8;
            } else if (userToPurchasedAmountMapping[_user] >= 1000 * 1e18) {
                _additionalLevel = 5;
            }

            if (_additionalLevel > _gymLevel) {
            INetGymStreet(netGymStreetAddress).updateAdditionalLevel(_user, _additionalLevel);
            }
        }
    }

    /**
     * @notice Private function to update last purchase date
     * @param _user: user address
     */
    function _lastPurchaseDateUpdate(address _user) private {
        LastPurchaseData storage lastPurchase = lastPurchaseData[_user];
        uint256 _lastDate = INetGymStreet(netGymStreetAddress).lastPurchaseDateERC(_user);
        lastPurchase.lastPurchaseDate = block.timestamp;
        if (lastPurchase.expirationDate < _lastDate + 30 days) {
            lastPurchase.expirationDate = _lastDate + 30 days;
        }
        if(lastPurchase.expirationDate < block.timestamp) {
            lastPurchase.expirationDate = lastPurchase.lastPurchaseDate;
        }
        if (lastPurchase.dollarValue >= (100 * 1e18)) {
            lastPurchase.expirationDate = lastPurchase.lastPurchaseDate + 30 days;
            lastPurchase.dollarValue = 0;     
        }
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import '../Municipality.sol';

interface IMinerPublicBuildingInterface {
    function mintParcelsBundle(address user, Municipality.Parcel [] memory) external returns (uint256[] memory);
    function mintMinersBundle(address user, uint256 minersAmount) external returns (uint256, uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "../Municipality.sol";

interface ISignatureValidator {
    function verifySigner(Municipality.ParcelsMintSignature memory mintParcelSignature) external view returns(bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../Municipality.sol";

interface IParcelInterface {
    function mint(address user, uint256 x, uint256 y, uint256 landType) external returns (uint256);
    function parcelExists(uint256 x, uint256 y, uint256 landType) external view returns(bool);
    function getParcelId(uint256 x, uint256 y, uint256 landType) external pure returns (uint256);
    function isParcelUpgraded(uint256 tokenId) external view returns (bool);
    function upgradeParcel(uint256 tokenId) external;
    function mintParcels(address _user, Municipality.Parcel[] calldata parcels) external returns(uint256[] memory);
    function requireNFTsBelongToUser(uint256[] memory nftIds, address userWalletAddress) external;
}

// SPDX-License-Identifier: MIT

import "./IERC165.sol";
import "./IERC721Lockable.sol";
import "./IERC721Metadata.sol";

pragma solidity ^0.8.15;

interface IERC721Base is IERC165, IERC721Lockable, IERC721Metadata {
    /**
     * @dev This event is emitted when token is transfered
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /**
     * @dev This event is emitted when user is approved for token
     * @param _owner address of the owner of the token
     * @param _approval address of the user who gets approved
     * @param _tokenId id of the token that gets approved
     */
    event Approval(address indexed _owner, address indexed _approval, uint256 indexed _tokenId);

    /**
     * @dev This event is emitted when an address is approved/disapproved for another user's tokens
     * @param _owner address of the user whos tokens are being approved/disapproved to be used
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Total amount of nft tokens in circulation
    function totalSupply() external view returns (uint256);

    /**
     * @notice Gives the number of nft tokens that a given user owns
     * @param _owner address of the user who's token's count will be returned
     * @return amount of tokens given user owns
     */
    function balanceOf(address _owner) external view returns (uint256);

    /**
     * @notice Tells weather a token exists
     * @param _tokenId id of the token who's existence is returned
     * @return true - exists, false - does not exist
     */
    function exists(uint256 _tokenId) external view returns (bool);

    /**
     * @notice Gives owner address of a given token
     * @param _tokenId id of the token who's owner address is returned
     * @return address of the given token owner
     */
    function ownerOf(uint256 _tokenId) external view returns (address);

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes "_data" from this function arguments
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     * @param _data argument which will be passed to "onERC721Received" function
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external;

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes an empty string for "data" parameter
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /**
     * @notice Transfers token without checking weather it was recieved
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev Does not call "onERC721Received" function even if the reciver is ERC721TokenReceiver
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /**
     * @notice Approves an address to use given token
     *         Only authorized users can call this function
     * @dev Only one user can be approved at any given moment
     * @param _approved address of the user who gets approved
     * @param _tokenId id of the token the given user get aproval on
     */
    function approve(address _approved, uint256 _tokenId) external;

    /**
     * @notice Approves or disapproves an address to use all tokens of the caller
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    function setApprovalForAll(address _operator, bool _approved) external;

    /**
     * @notice Gives the approved address of the given token
     * @param _tokenId id of the token who's approved user is returned
     * @return address of the user who is approved for the given token
     */
    function getApproved(uint256 _tokenId) external view returns (address);

    /**
     * @notice Tells weather given user (_operator) is approved to use tokens of another given user (_owner)
     * @param _owner address of the user who's tokens are checked to be aproved to another user
     * @param _operator address of the user who's checked to be approved by owner of the tokens
     * @return true - approved, false - disapproved
     */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    /**
     * @notice Tells weather given user (_operator) is approved to use given token (_tokenId)
     * @param _operator address of the user who's checked to be approved for given token
     * @param _tokenId id of the token for which approval will be checked
     * @return true - approved, false - disapproved
     */
    function isAuthorized(address _operator, uint256 _tokenId) external view returns (bool);

    /// @notice Returns the purchase date for this NFT
    function getUserPurchaseTime(address _user) external view returns (uint256[2] memory);

    /// @notice Returns all the token IDs belonging to this user
    function tokensOf(address _owner) external view returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IMinerNFT {
    function mint(address) external returns (uint256);
    function hashrate() external pure returns (uint256);
    function lastMinerId() external returns(uint256);
    function mintMiners(address _user, uint256 _count) external returns(uint256, uint256);
    function requireNFTsBelongToUser(uint256[] memory nftIds, address userWalletAddress) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IMining {
    function deposit(address _user, uint256 _miner, uint256 _hashRate) external;
    function depositMiners(address _user, uint256 _firstMinerId, uint256 _minersCount, uint256 _hashRate) external;
    function withdraw(address _user,uint256 _miner) external;
    function applyVouchers(address _user, uint256[] calldata _minerIds) external;
    function getMinersCount(address _user) external view returns (uint256);
    function repairMiners(address _user) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC165 {
    /**
     * @notice Returns weather contract supports fiven interface
     * @dev This contract supports ERC165 and ERC721 interfaces
     * @param _interfaceId id of the interface which is checked to be supported
     * @return true - given interface is supported, false - given interface is not supported
     */
    function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC721Lockable {
    /**
     * @dev Event that is emitted when token lock status is set
     * @param _tokenId id of the token who's lock status is set
     * @param _lock true - is locked, false - is not locked
     */
    event LockStatusSet(uint256 _tokenId, bool _lock);

    /**
     * @notice Tells weather a token is locked
     * @param _tokenId id of the token who's lock status is returned
     * @return true - is locked, false - is not locked
     */
    function isLocked(uint256 _tokenId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IERC721Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function baseURI() external view returns (string memory);
}

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./Municipality.sol";

pragma solidity ^0.8.15;

contract SignatureValidator is OwnableUpgradeable, ReentrancyGuardUpgradeable, EIP712Upgradeable {

    string private constant SIGNING_DOMAIN = "SIGNATURE_VALIDATOR";
    string private constant SIGNATURE_VERSION = "1";

    address private ourSignerAddress;
    address public municipalityAddress;

    modifier onlyMunicipality() {
        require(msg.sender == municipalityAddress, "SignatureValidator: Only Municipality contract is authorized to call this function");
        _;
    }

    function initialize(
        address _ourSignerAddress
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __EIP712_init(SIGNING_DOMAIN, SIGNATURE_VERSION);
        ourSignerAddress = _ourSignerAddress;
    }

    function setMunicipalityAddress(address _municipalityAddress) external onlyOwner {
        municipalityAddress = _municipalityAddress;
    }

    function setSignerAddress(address  _ourSignerAddress) external onlyOwner {
        ourSignerAddress = _ourSignerAddress;
    }

    function verifySigner(Municipality.ParcelsMintSignature memory mintParcelSignature) external  view onlyMunicipality returns (bool){
        require(
            mintParcelSignature.parcels.length == mintParcelSignature.signatures.length,
            "SignatureValidator: Number of signuatures does not match number of parcels"
        );
        for (uint256 index; index < mintParcelSignature.parcels.length; index++) {
            bytes32 _digest = _hash(mintParcelSignature.parcels[index]);
            address signer = ECDSAUpgradeable.recover(
                _digest,
                mintParcelSignature.signatures[index]
            );
            if(signer != ourSignerAddress) {
                return false;
            }
        }
        return true;
    }

    function _hash(Municipality.Parcel memory parcel) private view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "Parcel(uint16 x,uint16 y,uint8 parcelType,uint8 parcelLandType)"
                        ),
                        parcel
                    )
                )
            );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSAUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 *
 * @custom:storage-size 52
 */
abstract contract EIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
interface ITaxCollector {
    function swapTaxTokens() external returns (bool);

    function updateTaxationAmount(bool, uint256) external;
    function updateManagementTaxationAmount(uint256) external;
}
contract VBTC is IERC20Upgradeable, OwnableUpgradeable {
    /* solhint-disable const-name-snakecase */

    string public constant name = "VBTC Token";
    string public constant symbol = "VBTC";

    uint8 public constant decimals = 18;

    /// @notice Percent amount of tax for the token trade on dex
    uint8 public constant devFundTax = 6;

    /// @notice Percent amount of tax for the token sell on dex
    uint8 public constant taxOnSell = 4;

    /// @notice Percent amount of tax for the token purchase on dex
    uint8 public constant taxOnPurchase = 1;

    /* solhint-disable const-name-snakecase */

    uint256 public constant MAX_SUPPLY = 250_000_000 ether;
    uint256 public totalSupply;
    uint256 public minted;

    address public managementAddress;
    address public taxCollector;

    mapping(address => mapping(address => uint256)) internal allowances;

    /// @dev Official record of token balances for each account
    mapping(address => uint256) internal balances;

    /// @notice A record of each DEX account
    mapping(address => bool) public isDex;

    /// @notice A record of addresses that are not taxed during trades
    mapping(address => bool) private _dexTaxExcempt;

    /// @notice A record of blacklisted addresses
    mapping(address => bool) private _isBlackListed;

    bool public isTradingPaused;

    bool public autoSwapTax;

    event DexAddressUpdated(address indexed dex, bool indexed isDex);
    event TaxExcemptAddressUpdated(address indexed addr, bool indexed isExcempt);
    event TaxCollectorUpdated(address indexed taxCollector);
    event BlacklistUpdated(address indexed user, bool indexed toBlcacklist);
    event MintFor(address indexed user, uint256 indexed amount);
    event TradingPaused(bool indexed paused);
    event ManagmentAddressUpdated(address indexed managmentAddress);
    event BNBWithdrawn(uint256 indexed amount);

    function initialize(
        address _managementAddress,
        address _taxCollectorAddress,
        address _preMintAddress,
        uint256 _preMintAmount
    ) external initializer {
        isTradingPaused = true;

        managementAddress = _managementAddress;
        taxCollector = _taxCollectorAddress;

        _dexTaxExcempt[address(this)] = true;
        _dexTaxExcempt[taxCollector] = true;

        _mint(_preMintAddress, _preMintAmount);

        __Ownable_init();
    }

    function updateDexAddress(address _dex, bool _isDex) external onlyOwner {
        isDex[_dex] = _isDex;
        emit DexAddressUpdated(_dex, _isDex);
    }

    function updateTaxExcemptAddress(address _addr, bool _isExcempt) external onlyOwner {
        _dexTaxExcempt[_addr] = _isExcempt;
        emit TaxExcemptAddressUpdated(_addr, _isExcempt);
    }

    function updateTaxCollector(address _taxCollector) external onlyOwner {
        taxCollector = _taxCollector;
        emit TaxCollectorUpdated(taxCollector);
    }

    function manageBlacklist(address[] calldata users, bool[] calldata _toBlackList)
        external
        onlyOwner
    {
        require(users.length == _toBlackList.length, "VBTC: Array mismatch");

        for (uint256 i; i < users.length; i++) {
            _isBlackListed[users[i]] = _toBlackList[i];
            emit BlacklistUpdated(users[i], _toBlackList[i]);
        }
    }

    function mintFor(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
        emit MintFor(account, amount);
    }

    function pauseTrading(bool _isPaused) external onlyOwner {
        isTradingPaused = _isPaused;
        emit TradingPaused(_isPaused);
    }

    function updateManagementAddress(address _address) external onlyOwner {
        managementAddress = _address;
        emit ManagmentAddressUpdated(_address);
    }

    function withdrawBnb() external onlyOwner {
        address payable to = payable(msg.sender);
        uint256 amount = address(this).balance;
        to.transfer(amount);
        emit BNBWithdrawn(amount);
    }

    /**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(address account, address spender) external view returns (uint256) {
        return allowances[account][spender];
    }
   function updateAutoSwapTax(bool _autoSwapTax) public onlyOwner {
        autoSwapTax = _autoSwapTax;
    }
    /**
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param _spender The address of the account which may transfer tokens
     * @param _value The number of tokens that are approved (2^256-1 means infinite)
     * @return Whether or not the approval succeeded
     */
    function approve(address _spender, uint256 _value) external override returns (bool) {
        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param _to The address of the destination account
     * @param _value The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transfer(address _to, uint256 _value) external override returns (bool) {
        _transferTokens(msg.sender, _to, _value);

        return true;
    }

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param _from The address of the source account
     * @param _to The address of the destination account
     * @param _value The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external override returns (bool) {
        address spender = msg.sender;
        uint256 currentAllowance = allowances[_from][spender];

        if (spender != _from && currentAllowance != type(uint256).max) {
            require(currentAllowance >= _value, "VBTC: insufficient allowance");

            uint256 newAllowance = currentAllowance - _value;
            allowances[_from][spender] = newAllowance;

            emit Approval(_from, spender, newAllowance);
        }

        _transferTokens(_from, _to, _value);

        return true;
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     */
    function burn(uint256 amount) external returns (bool) {
        _burn(msg.sender, amount);

        return true;
    }

    /**
     * @dev Destroys `_amount` tokens from `_from`, deducting from the caller's
     * allowance.
     */
    function burnFrom(address _from, uint256 _amount) external returns (bool) {
        require(_from != address(0), "VBTC: burn from the zero address");
        require(_amount <= allowances[_from][msg.sender], "VBTC: burn amount exceeds allowance");

        allowances[_from][msg.sender] = allowances[_from][msg.sender] - _amount;

        _burn(_from, _amount);

        return true;
    }

    function _burn(address account, uint256 amount) private {
        require(amount <= balances[account], "VBTC: burn amount exceeds balance");

        balances[account] -= amount;
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _transferTokens(
        address src,
        address dst,
        uint256 amount
    ) private {
        require(src != address(0), "VBTC: from address is not valid");
        require(dst != address(0), "VBTC: to address is not valid");

        require(
            !_isBlackListed[src] && !_isBlackListed[dst],
            "VBTC: cannot transfer to/from blacklisted account"
        );

        require(amount <= balances[src], "VBTC: insufficient balance");

        if (
            (!isDex[dst] && !isDex[src]) ||
            (_dexTaxExcempt[dst] || _dexTaxExcempt[src]) ||
            src == taxCollector ||
            dst == taxCollector
        ) {
            balances[src] -= amount;
            balances[dst] += amount;

            emit Transfer(src, dst, amount);
        } else {
            require(!isTradingPaused, "VBTC: only liq transfer allowed");

            uint8 taxValue = isDex[src] ? taxOnPurchase : taxOnSell;

            uint256 tax = (amount * taxValue) / 100;
            uint256 teamTax = (amount * devFundTax) / 100;
            bool isBuyAction = isDex[src] ? true : false;

            balances[src] -= amount;

            balances[taxCollector] += tax;

            balances[taxCollector] += teamTax;

            ITaxCollector(taxCollector).updateManagementTaxationAmount(teamTax);
            if (balances[taxCollector] > 0 && !isBuyAction) {
                ITaxCollector(taxCollector).updateTaxationAmount(false, tax);
                if (autoSwapTax) {
                    ITaxCollector(taxCollector).swapTaxTokens();
                }
            } else {
                ITaxCollector(taxCollector).updateTaxationAmount(true, tax);
            }
           

            balances[dst] += (amount - tax - teamTax);

            emit Transfer(src, taxCollector, tax);
            emit Transfer(src, managementAddress, teamTax);
            emit Transfer(src, dst, (amount - tax - teamTax));
        }
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "VBTC: mint to the zero address");
        require(minted + amount <= MAX_SUPPLY, "VBTC: mint amount exceeds max supply");

        totalSupply += amount;
        minted += amount;
        balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }
    
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20Upgradeable.sol";

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@quant-finance/solidity-datetime/contracts/DateTime.sol";

contract Mining is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    struct UserInfo {
        uint256 totalHashRate;
        uint256 minersCount;
        uint256 totalClaims;
    }


    struct MinerInfo {
        uint256 hashrate;
        uint256 rewardDebt;
        uint256 electricityLastDay;
        uint256 stakedTimestamp;
        uint256 unstakeTimestamp;
        uint256 lastAmortization;
        uint256 lastUpdated;
        uint256 totalClaims;
        uint256 minerId;
        uint256 accRewardUserShare;
        bool isStaked;
    }

    struct PoolInfo {
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }

    IERC20Upgradeable public rewardToken;
    uint256 public rewardPerBlock;
    uint256 public startBlock;
    uint256 public lastRewardDay;

    address public municipalityAddress;
    address public minerPublicBuilding;

    /// Info of pool.
    PoolInfo public poolInfo;
    uint256 private lastChangeBlock;
    uint256 public totalHashRate;
    uint256 public totalMintedTokens;
    bool public isPoolActive;


    /// Info of each user that staked tokens.
    mapping(address => UserInfo) public userInfo;

    /// @notice Info of each miner that assigned miner to parcel
    mapping(address => mapping(uint256 => MinerInfo)) public minersInfo;
    mapping(address => EnumerableSetUpgradeable.UintSet) private userToMiners;

    mapping(uint256 => uint256) public rewardSharesByDays;

    uint32 constant public SECONDS_PER_MONTH = 30 * 24 * 60 * 60;

    /// @notice Trigger event about assignment of miner to parcel
    event Deposit(uint256 indexed minerId);

    /// @notice Trigger event about claiming of miner rewards
    event Claim(address user, uint256 indexed minerId, uint256 amount);

    event ClaimAll(address userAddress);

    /// @notice Trigger event about unassignment of miner from the parcel
    event Withdraw(uint256 indexed minerId);

    event MunicipalitAddressSet(address indexed municipality);

    event RewardTokenAddressSet(address indexed rewardToken);

    event MinerPublicBuildingAddress(address indexed minerPublciBuilding);

    event StartRewardBlockSet(uint256 indexed startBlock);

    function initialize(
        IERC20Upgradeable _rewardToken, // VBTC address
        uint256 _rewardPerBlock, // 20,25462963
        uint256 _startBlock
    ) public initializer {
        require(address(_rewardToken) != address(0), "Mining: Reward TokenAddress can not be address 0");

        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;

        __Ownable_init();
        __ReentrancyGuard_init();
    }

    modifier onlyAuthorizedContracts() {
        require(minerPublicBuilding == msg.sender || msg.sender == municipalityAddress, "MinerNFT: Only authorized contracts can call this function");
        _;
    }

    modifier onlyDetachedMiner(address _user, uint256 _minerId) {
        require(!minersInfo[_user][_minerId].isStaked, "Mining: This miner is already Attached");
        _;
    }

    modifier onlyAttachedMiner(address _user, uint256 _minerId) {
        require(minersInfo[_user][_minerId].isStaked, "Mining: This miner is not attached");
        _;
    }

    receive() external payable {}

    fallback() external payable {}

    function setMunicipalityAddress(address _municipalityAddress) external onlyOwner {
        municipalityAddress = _municipalityAddress;
        emit MunicipalitAddressSet(municipalityAddress);
    }

    function setRewardTokenAddress(IERC20Upgradeable _rewardToken) external onlyOwner {
        rewardToken = _rewardToken;
        emit RewardTokenAddressSet(address(rewardToken));
    }

    function setPoolInfo(
        uint256 lastRewardBlock,
        uint256 accRewardPerShare
    ) external onlyOwner {
        updatePool();

        poolInfo = PoolInfo({
        lastRewardBlock : lastRewardBlock,
        accRewardPerShare : accRewardPerShare
        });

    }

    function updateStartBlock(uint256 _startBlock) external onlyOwner {
        startBlock = _startBlock;
    }

    function setIsPoolActive(bool _isPoolActive) external onlyOwner {
        isPoolActive = _isPoolActive;
    }

    function setMinerPublicBuildingAddress(address _minerPublicBuilding) external onlyOwner {
        minerPublicBuilding = _minerPublicBuilding;
        emit MinerPublicBuildingAddress(minerPublicBuilding);
    }

    function setRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        updatePool();
        rewardPerBlock = _rewardPerBlock;
    }

    function setStartBlock(uint256 _startBlock) external onlyOwner {
        startBlock = _startBlock;
        emit StartRewardBlockSet(startBlock);
    }


    function repairMiners(address _user) external onlyAuthorizedContracts nonReentrant {
        EnumerableSetUpgradeable.UintSet storage userMiners = userToMiners[_user];
        UserInfo storage user = userInfo[_user];
        require(user.minersCount > 0, "Mining: User does not have any Miners to repair");
        _claimAll(_user);
        for (uint256 index; index < userMiners.length(); ++index) {
            uint256 minerId = userMiners.at(index);
            MinerInfo storage miner = minersInfo[_user][minerId];
            miner.lastAmortization = 1000;
        }
    }

    function getUserMinersIdsByIndex(address _user) external view returns (uint256[] memory){
        EnumerableSetUpgradeable.UintSet storage userMiners = userToMiners[_user];
        uint256[] memory collectedArrays = new uint256[](userMiners.length());
        for (uint256 i = 0; i < userMiners.length(); i++) {
            collectedArrays[i] = userMiners.at(i);
        }
        return collectedArrays;
    }

    function getUserActiveMiners(address _user) external view returns (uint256){
        EnumerableSetUpgradeable.UintSet storage userMiners = userToMiners[_user];
        uint256 activeMiners;
        for (uint256 i = 0; i < userMiners.length(); i++) {
            uint256 minerId = userMiners.at(i);
            MinerInfo storage miner = minersInfo[_user][minerId];
            if(miner.electricityLastDay > block.timestamp) {
                activeMiners++;
            }
        }
        return activeMiners;
    }
    
    function applyVouchers(address _user, uint256[] calldata _minerIds)
    external
    onlyAuthorizedContracts
    {
        for (uint32 i = 0; i < _minerIds.length; i++) {
            _claim(_user, _minerIds[i]);
            MinerInfo storage miner = minersInfo[_user][_minerIds[i]];
            if (miner.electricityLastDay < block.timestamp)
                miner.electricityLastDay = block.timestamp + SECONDS_PER_MONTH;
            else
                miner.electricityLastDay += SECONDS_PER_MONTH;
        }
    }

    function deposit(address _user, uint256 _minerId, uint256 _hashrate)
    external
    onlyAuthorizedContracts
    nonReentrant
    onlyDetachedMiner(_user, _minerId)
    {
        updatePool();
        _deposit(_user, _minerId, _hashrate);
    }

    function depositMiners(address _user, uint256 _firstMinerId, uint256 _minersCount, uint256 _hashRate)
    external
    onlyAuthorizedContracts
    nonReentrant
    {
        updatePool();
        for (uint256 minerId = _firstMinerId; minerId < _firstMinerId + _minersCount; minerId++) {
            require(!minersInfo[_user][minerId].isStaked, "Mining: Miner is already Attached");
            _deposit(_user, minerId, _hashRate);
        }
    }

    function withdraw(address _user, uint256 _minerId)
    external
    onlyAuthorizedContracts
    nonReentrant
    onlyAttachedMiner(_user, _minerId)
    {
        updatePool();
        _withdraw(_user, _minerId);
    }

    function claim(uint256 _minerId) external nonReentrant {
        _claim(msg.sender, _minerId);
    }

    function claimAll() external nonReentrant {
        _claimAll(msg.sender);
    }


    function _withdraw(address _user, uint256 _minerId) private {
        MinerInfo storage miner = minersInfo[_user][_minerId];
        UserInfo storage userInfo = userInfo[_user];
        PoolInfo storage pool = poolInfo;
        EnumerableSetUpgradeable.UintSet storage userIndexToMinerId = userToMiners[_user];
        _claim(_user, _minerId);
        miner.rewardDebt = (miner.hashrate * (pool.accRewardPerShare)) / (1e18);

        userInfo.totalHashRate -= miner.hashrate;
        totalHashRate -= miner.hashrate;

        miner.isStaked = false;
        miner.hashrate = 0;
        miner.lastAmortization = ((block.timestamp - miner.unstakeTimestamp) / 86400) / 10;
        miner.unstakeTimestamp = block.timestamp;
        userIndexToMinerId.remove(_minerId);
        userInfo.minersCount = userIndexToMinerId.length();

        emit Withdraw(_minerId);
    }

    function _deposit(address _user, uint256 _minerId, uint256 _hashrate) private {
        MinerInfo storage miner = minersInfo[_user][_minerId];
        UserInfo storage userInfo = userInfo[_user];
        PoolInfo storage pool = poolInfo;
        EnumerableSetUpgradeable.UintSet storage userIndexToMinerId = userToMiners[_user];
        uint256 timestamp = block.timestamp + SECONDS_PER_MONTH;
        if (miner.electricityLastDay > 0) {
            timestamp = miner.electricityLastDay;
        }

        miner.hashrate = _hashrate;
        miner.rewardDebt = (miner.hashrate * (pool.accRewardPerShare)) / (1e18);
        miner.electricityLastDay = timestamp;
        miner.stakedTimestamp = block.timestamp;
        miner.unstakeTimestamp = block.timestamp;
        miner.lastAmortization = 1000;
        miner.lastUpdated = 0;
        miner.totalClaims = 0;
        miner.minerId = _minerId;
        miner.isStaked = true;

        userIndexToMinerId.add(_minerId);
        // miner = stakingDetails;
        userInfo.totalHashRate += _hashrate;
        userInfo.minersCount = userIndexToMinerId.length();
        totalHashRate += _hashrate;
        emit Deposit(_minerId);
    }

    function _claim(address _user, uint256 _minerId) private {
        MinerInfo storage miner = minersInfo[_user][_minerId];
        UserInfo storage userInfo = userInfo[_user];
        updatePool();
        PoolInfo storage pool = poolInfo;

        uint256 pending = pendingReward(_user, _minerId);

        if (pending > 0) {
            rewardToken.safeTransfer(_user, pending);

            userInfo.totalClaims += pending;
            totalMintedTokens += pending;
            miner.totalClaims += pending;
            emit Claim(_user, _minerId, pending);
        }
        miner.rewardDebt =
        (miner.hashrate * (pool.accRewardPerShare)) /
        (1e18);
    }

    function _claimAll(address _user) internal {
        UserInfo storage userInfo = userInfo[_user];
        EnumerableSetUpgradeable.UintSet storage userIndexToMinerId = userToMiners[_user];
        PoolInfo storage pool = poolInfo;
        updatePool();
        uint256 totalPending = 0;
        for (uint256 i = 0; i < userIndexToMinerId.length(); i++) {
            uint256 _minerId = userIndexToMinerId.at(i);
            MinerInfo storage miner = minersInfo[_user][_minerId];
            uint256 pending = pendingReward(_user, _minerId);

            if (pending > 0) {
                totalPending += pending;
                miner.totalClaims += pending;
               
            }
             miner.rewardDebt = (miner.hashrate * (pool.accRewardPerShare)) / (1e18);
        }
        require(totalPending > 0, "You dont have enought rewards to claim");

        userInfo.totalClaims += totalPending;
        totalMintedTokens += totalPending;

        rewardToken.safeTransfer(_user, totalPending);
        emit Claim(_user, 0, totalPending);
    }


    function getPendingRewardsFromAllMiners(address _user) external view returns (uint256)  {
        EnumerableSetUpgradeable.UintSet storage userIndexToMinerId = userToMiners[_user];

        uint256 totalRewards = 0;
        for (uint256 i = 0; i < userIndexToMinerId.length(); i++) {
            totalRewards += _getPendingRewards(_user, userIndexToMinerId.at(i));
        }

        return totalRewards;
    }

    function pendingReward(address _user, uint256 _minerId) public view returns (uint256) {
        return _getPendingRewards(_user, _minerId);
    }

    function getMinersCount(address _user) public view returns (uint256) {
        UserInfo memory userInfo = userInfo[_user];
        return userInfo.minersCount;
    }

    function _getPendingRewards(address _user, uint256 _minerId) private view returns (uint256) {
        MinerInfo storage miner = minersInfo[_user][_minerId];

        if (!miner.isStaked) {
            return 0;
        }

        PoolInfo storage pool = poolInfo;
        if (block.timestamp > miner.electricityLastDay) {
            uint256 userAccRewardPerShare = rewardSharesByDays[getDateTimeConcat(miner.electricityLastDay)];
            uint256 userAccReward = miner.hashrate * userAccRewardPerShare / 1e18;
            return userAccReward > miner.rewardDebt
                                 ? userAccReward - miner.rewardDebt
                                 : 0;
        }

        uint256 _accRewardPerShare = pool.accRewardPerShare;
        uint256 sharesTotal = totalHashRate;

        if (block.number > pool.lastRewardBlock && sharesTotal != 0) {
            uint256 _multiplier = block.number - pool.lastRewardBlock;
            uint256 _reward = (_multiplier * rewardPerBlock);
            _accRewardPerShare = _accRewardPerShare + ((_reward * 1e18) / sharesTotal);
        }

        return
        (miner.hashrate * _accRewardPerShare) / (1e18) - (miner.rewardDebt);
    }

    function updatePool() public {
        PoolInfo storage pool = poolInfo;
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 sharesTotal = totalHashRate;
        if (sharesTotal == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number - pool.lastRewardBlock;
        if (multiplier <= 0) {
            return;
        }
        uint256 _reward = (multiplier * rewardPerBlock);
        pool.accRewardPerShare = pool.accRewardPerShare + ((_reward * 1e18) / sharesTotal);
        rewardSharesByDays[getDateTimeConcat(block.timestamp)] = pool.accRewardPerShare;

        pool.lastRewardBlock = block.number;
    }

    function getDateTimeConcat(uint256 _timestamp) public pure returns (uint256) {
        (uint256 year,uint256 month,uint256 day) = DateTime.timestampToDate(_timestamp);
        uint256 date;
        if(year == 2022 && month <= 9) 
            date = (year * 1000) + (month * 100) + day;
        else 
            date = (year * 10000) + (month * 100) + day;
        return date;
    }
}

// SPDX-License-Identifier: MIT
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
library EnumerableSetUpgradeable {
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
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
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
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
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
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
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
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
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
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
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
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
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
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
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
    function values(AddressSet storage set) internal view returns (address[] memory) {
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
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
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
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
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
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ----------------------------------------------------------------------------
// DateTime Library v2.0
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------

library DateTime {
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_HOUR = 60 * 60;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256 constant DOW_MON = 1;
    uint256 constant DOW_TUE = 2;
    uint256 constant DOW_WED = 3;
    uint256 constant DOW_THU = 4;
    uint256 constant DOW_FRI = 5;
    uint256 constant DOW_SAT = 6;
    uint256 constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 _days) {
        require(year >= 1970);
        int256 _year = int256(year);
        int256 _month = int256(month);
        int256 _day = int256(day);

        int256 __days =
            _day -
                32075 +
                (1461 * (_year + 4800 + (_month - 14) / 12)) /
                4 +
                (367 * (_month - 2 - ((_month - 14) / 12) * 12)) /
                12 -
                (3 * ((_year + 4900 + (_month - 14) / 12) / 100)) /
                4 -
                OFFSET19700101;

        _days = uint256(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint256 _days)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        int256 __days = int256(_days);

        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        int256 _month = (80 * L) / 2447;
        int256 _day = L - (2447 * _month) / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }

    function timestampFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }

    function timestampFromDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (uint256 timestamp) {
        timestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            hour *
            SECONDS_PER_HOUR +
            minute *
            SECONDS_PER_MINUTE +
            second;
    }

    function timestampToDate(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function timestampToDateTime(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day,
            uint256 hour,
            uint256 minute,
            uint256 second
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint256 daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }

    function isValidDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }

    function isLeapYear(uint256 timestamp)
        internal
        pure
        returns (bool leapYear)
    {
        (uint256 year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }

    function _isLeapYear(uint256 year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }

    function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }

    function isWeekEnd(uint256 timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }

    function getDaysInMonth(uint256 timestamp)
        internal
        pure
        returns (uint256 daysInMonth)
    {
        (uint256 year, uint256 month, ) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }

    function _getDaysInMonth(uint256 year, uint256 month)
        internal
        pure
        returns (uint256 daysInMonth)
    {
        if (
            month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12
        ) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }

    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint256 timestamp)
        internal
        pure
        returns (uint256 dayOfWeek)
    {
        uint256 _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = ((_days + 3) % 7) + 1;
    }

    function getYear(uint256 timestamp) internal pure returns (uint256 year) {
        (year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getMonth(uint256 timestamp) internal pure returns (uint256 month) {
        (, month, ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getDay(uint256 timestamp) internal pure returns (uint256 day) {
        (, , day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getHour(uint256 timestamp) internal pure returns (uint256 hour) {
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }

    function getMinute(uint256 timestamp)
        internal
        pure
        returns (uint256 minute)
    {
        uint256 secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }

    function getSecond(uint256 timestamp)
        internal
        pure
        returns (uint256 second)
    {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = ((month - 1) % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }

    function addHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }

    function addMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }

    function addSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = (yearMonth % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }

    function subHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }

    function subMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }

    function subSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _years)
    {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, , ) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, , ) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }

    function diffMonths(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _months)
    {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, uint256 fromMonth, ) =
            _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, uint256 toMonth, ) =
            _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }

    function diffDays(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _days)
    {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }

    function diffHours(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _hours)
    {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }

    function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _minutes)
    {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }

    function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _seconds)
    {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract RewardRateConfigurable is Initializable {
    struct RewardsConfiguration {
        uint256 rewardPerBlock;
        uint256 lastUpdateBlockNum;
        uint256 updateBlocksInterval;
    }

    uint256 public constant REWARD_PER_BLOCK_MULTIPLIER = 967742;
    uint256 public constant DIVIDER = 1e6;

    RewardsConfiguration private rewardsConfiguration;

    event RewardPerBlockUpdated(uint256 oldValue, uint256 newValue);

    // solhint-disable-next-line func-name-mixedcase
    function __RewardRateConfigurable_init(
        uint256 _rewardPerBlock,
        uint256 _rewardUpdateBlocksInterval
    ) internal onlyInitializing {
        __RewardRateConfigurable_init_unchained(_rewardPerBlock, _rewardUpdateBlocksInterval);
    }

    // solhint-disable-next-line func-name-mixedcase
    function __RewardRateConfigurable_init_unchained(
        uint256 _rewardPerBlock,
        uint256 _rewardUpdateBlocksInterval
    ) internal onlyInitializing {
        rewardsConfiguration.rewardPerBlock = _rewardPerBlock;
        rewardsConfiguration.lastUpdateBlockNum = block.number;
        rewardsConfiguration.updateBlocksInterval = _rewardUpdateBlocksInterval;
    }

    function getRewardsConfiguration() public view returns (RewardsConfiguration memory) {
        return rewardsConfiguration;
    }

    function getRewardPerBlock() public view returns (uint256) {
        return rewardsConfiguration.rewardPerBlock;
    }

    function _setRewardConfiguration(uint256 rewardPerBlock, uint256 updateBlocksInterval)
        internal
    {
        uint256 oldRewardValue = rewardsConfiguration.rewardPerBlock;

        rewardsConfiguration.rewardPerBlock = rewardPerBlock;
        rewardsConfiguration.lastUpdateBlockNum = block.number;
        rewardsConfiguration.updateBlocksInterval = updateBlocksInterval;

        emit RewardPerBlockUpdated(oldRewardValue, rewardPerBlock);
    }

    function _updateRewardPerBlock() internal {
        if (
            (block.number - rewardsConfiguration.lastUpdateBlockNum) <
            rewardsConfiguration.updateBlocksInterval
        ) {
            return;
        }

        uint256 rewardPerBlockOldValue = rewardsConfiguration.rewardPerBlock;

       rewardsConfiguration.rewardPerBlock =
            (rewardPerBlockOldValue * REWARD_PER_BLOCK_MULTIPLIER) / DIVIDER;

        rewardsConfiguration.lastUpdateBlockNum = block.number;

        emit RewardPerBlockUpdated(rewardPerBlockOldValue, rewardsConfiguration.rewardPerBlock);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "./interfaces/INetGymStreet.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IPancakePair.sol";
import "./RewardRateConfigurable.sol";

/* solhint-disable max-states-count, not-rely-on-time */
contract GymStreetFarming is
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    RewardRateConfigurable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @notice Info of each user
     * @param totalDepositTokens total amount of deposits in tokens
     * @param totalDepositDollarValue total amount of tokens converted to USD
     * @param lpTokensAmount: How many LP tokens the user has provided
     * @param rewardDebt: Reward debt. See explanation below
     * @param totalClaims: total amount of claimed tokens
     */
    struct UserInfo {
        uint256 totalDepositTokens;
        uint256 totalDepositDollarValue;
        uint256 lpTokensAmount;
        uint256 rewardDebt;
        uint256 totalClaims;
    }

    /**
     * @notice Info of each pool
     * @param lpToken: Address of LP token contract
     * @param allocPoint: How many allocation points assigned to this pool. rewards to distribute per block
     * @param lastRewardBlock: Last block number that rewards distribution occurs
     * @param accRewardPerShare: Accumulated rewards per share, times 1e18. See below
     */
    struct PoolInfo {
        address lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }

    /**
     * @notice Internal struct to transfer data between function calls
     * @param baseTokensStaked amount of base tokens added to liquidity pool
     * @param vbtcTokensStaked amount of VBTC tokens added to liquidity pool
     * @param lpTokensReceived total LP tokens received after addLiquidity
     * @param baseTokensRemainder remaining amount of base tokens to be refunded
     * @param vbtcTokensRemainder remaining amount of VBTC tokens to be refunded
     */
    struct AddLiquidityResult {
        uint256 baseTokensStaked;
        uint256 vbtcTokensStaked;
        uint256 lpTokensReceived;
        uint256 baseTokensRemainder;
        uint256 vbtcTokensRemainder;
    }

    uint256 public constant MAX_COMMISSION_PERCENT = 80;

    /// The reward token
    address public rewardToken;
    /// Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    /// The block number when reward mining starts.
    uint256 public startBlock;
    address public routerAddress;
    address public wbnbAddress;
    address public busdAddress;

    uint256 public affilateCommission;
    uint256 public poolCommission;

    address public netGymStreetAddress;
    address public poolCommissionCollector;

    /// Info of each pool.
    PoolInfo[] public poolInfo;

    address[] public rewardTokenToWbnb;
    address[] public rewardTokenToBusd;
    address[] public wbnbToBusd;

    /// Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => bool) public isPoolExist;

    mapping(address => bool) private whitelist;

    bool public isTradingOn;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    event NewPoolAdded(uint256 indexed pid, address indexed lpToken, uint256 allocPoint);
    event PoolAllocPointUpdated(uint256 indexed pid, uint256 allocPoint);
    event StartBlockUpdated(uint256 newValue);
    event PoolCommissionUpdated(uint256 newValue);
    event AffilateCommissionUpdated(uint256 newValue);

    event WhitelistAddress(address indexed _wallet, bool whitelist);
    event SetRewardTokenAddress(address indexed _address);
    event SetNetGymStreetAddress(address indexed _address);
    event SetPoolCommissionCollectorAddress(address indexed _address);
    event SetWBNBAddress(address indexed _address);
    event SetBUSDAddress(address indexed _address);
    event SetPancakeRouterAddress(address indexed _address);
    event SetLastRewardPerBlock(
        uint256 indexed pid,
        uint256 indexed lastRewardPerBlock,
        uint256 indexed accRewardPerShare
    );
    event ToggleTrading(bool enabled);

    function initialize(
        address _rewardToken,
        address _netGymStreetAddress,
        address _poolCommissionCollector,
        address _wbnbAddress,
        address _busdAddress,
        address _routerAddress,
        uint256 _rewardPerBlock,
        uint256 _startBlock
    ) public initializer {
        rewardToken = _rewardToken;
        netGymStreetAddress = _netGymStreetAddress;
        poolCommissionCollector = _poolCommissionCollector;
        wbnbAddress = _wbnbAddress;
        busdAddress = _busdAddress;
        routerAddress = _routerAddress;
        startBlock = _startBlock;

        rewardTokenToWbnb = [_rewardToken, _wbnbAddress];
        rewardTokenToBusd = [_rewardToken, _busdAddress];
        wbnbToBusd = [_wbnbAddress, _busdAddress];

        poolCommission = 6;
        affilateCommission = 39;
        isTradingOn = false;

        __Ownable_init();
        __ReentrancyGuard_init();
        __RewardRateConfigurable_init(_rewardPerBlock, 864000);
    }

    modifier validAddress(address _address) {
        require(_address != address(0), "GymStreetFarming: Zero address");
        _;
    }

    modifier poolExists(uint256 _pid) {
        require(_pid < poolInfo.length, "GymStreetFarming: Unknown pool");
        _;
    }

    modifier validCommission(uint256 commission) {
        require(commission < MAX_COMMISSION_PERCENT, "GymStreetFarming: Max commission 80%");
        _;
    }

    modifier onlyWhitelisted() {
        require(
            whitelist[msg.sender] || msg.sender == owner(),
            "GymStreetFarming: not whitelisted or owner"
        );
        _;
    }

    modifier tradingEnabled() {
        require(isTradingOn, "GymStreetFarming: trading disabled");
        _;
    }

    receive() external payable {}

    fallback() external payable {}

    /**
     * @notice Function to set reward token
     * @param _address: address of reward token
     */
    function setRewardToken(address _address) external onlyOwner validAddress(_address) {
        rewardToken = _address;
        rewardTokenToWbnb = [_address, wbnbAddress];
        rewardTokenToBusd = [_address, busdAddress];
        emit SetRewardTokenAddress(_address);
    }

    function setNetGymStreetAddress(address _address) external onlyOwner validAddress(_address) {
        netGymStreetAddress = _address;

        emit SetNetGymStreetAddress(_address);
    }

    /**
     * @notice Function to set pool commission collector address
     * @param _address: new address
     */
    function setPoolCommissionCollectorAddress(address _address)
        external
        onlyOwner
        validAddress(_address)
    {
        poolCommissionCollector = _address;

        emit SetPoolCommissionCollectorAddress(_address);
    }

    function setBUSDAddress(address _address) external onlyOwner validAddress(_address) {
        busdAddress = _address;
        rewardTokenToBusd[1] = _address;
        emit SetBUSDAddress(_address);
    }

    function setWBNBAddress(address _address) external onlyOwner validAddress(_address) {
        wbnbAddress = _address;
        rewardTokenToWbnb[1] = _address;

        emit SetWBNBAddress(_address);
    }

    function setStartBlock(uint256 _startBlock) external onlyOwner {
        startBlock = _startBlock;

        emit StartBlockUpdated(_startBlock);
    }

    function setRouterAddress(address _address) external onlyOwner validAddress(_address) {
        routerAddress = _address;

        emit SetPancakeRouterAddress(_address);
    }

    function getVbtcPrice(uint256 amount) external view returns (uint256) {
        return _getVbtcPrice(amount);
    }

    /**
     * @notice Function to set commission on claim
     * @param _commission: value between 0 and 80
     */
    function setAffilateCommission(uint256 _commission)
        external
        onlyOwner
        validCommission(_commission)
    {
        affilateCommission = _commission;

        emit AffilateCommissionUpdated(_commission);
    }

    /**
     * @notice Function to set comission on claim
     * @param _commission: value between 0 and 80
     */
    function setPoolCommission(uint256 _commission)
        external
        onlyOwner
        validCommission(_commission)
    {
        poolCommission = _commission;

        emit PoolCommissionUpdated(_commission);
    }

    /**
     * @notice Function to set amount of reward per block
     */
    function setRewardConfiguration(uint256 _rewardPerBlock, uint256 _rewardUpdateBlocksInterval)
        external
        onlyOwner
    {
        massUpdatePools();

        _setRewardConfiguration(_rewardPerBlock, _rewardUpdateBlocksInterval);
    }

    /**
     * @notice Disable or enable deposit functions
     */
    function toggleIsTradingOn(bool enabled) external onlyOwner {
        isTradingOn = enabled;

        emit ToggleTrading(enabled);
    }

    /**
     * @notice Add or remove wallet to/from whitelist, callable only by contract owner
     *         whitelisted wallet will be able to call functions
     *         marked with onlyWhitelisted modifier
     * @param _wallet wallet to whitelist
     * @param _whitelist boolean flag, add or remove to/from whitelist
     */
    function whitelistAddress(address _wallet, bool _whitelist) external onlyOwner {
        whitelist[_wallet] = _whitelist;

        emit WhitelistAddress(_wallet, _whitelist);
    }

    function setlastRewardBlock(
        uint256 _pid,
        uint256 _lastRewardBlock,
        uint256 _accRewardPerShare
    ) external onlyOwner {
        poolInfo[_pid].lastRewardBlock = _lastRewardBlock;
        poolInfo[_pid].accRewardPerShare = _accRewardPerShare;
        emit SetLastRewardPerBlock(_pid, _lastRewardBlock, _accRewardPerShare);
    }

    function isWhitelisted(address wallet) external view returns (bool) {
        return whitelist[wallet];
    }

    /**
     * @notice Add a new lp to the pool. Can only be called by the owner
     * @param _allocPoint: allocPoint for new pool
     * @param _lpToken: address of lpToken for new pool
     */
    function add(uint256 _allocPoint, address _lpToken) external onlyOwner {
        require(!isPoolExist[address(_lpToken)], "GymStreetFarming: Duplicate pool");
        require(_isSupportedLP(_lpToken), "GymStreetFarming: Unsupported liquidity pool");

        massUpdatePools();

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint += _allocPoint;

        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accRewardPerShare: 0
            })
        );

        isPoolExist[address(_lpToken)] = true;

        uint256 pid = poolInfo.length - 1;

        emit NewPoolAdded(pid, _lpToken, _allocPoint);
    }

    /**
     * @notice Update the given pool's reward allocation point. Can only be called by the owner
     */
    function set(uint256 _pid, uint256 _allocPoint) external onlyOwner poolExists(_pid) {
        massUpdatePools();

        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;

        emit PoolAllocPointUpdated(_pid, _allocPoint);
    }

    /**
     * @notice Deposit LP tokens to GymStreetFarming for reward allocation
     * @param _pid: pool ID on which LP tokens should be deposited
     * @param _amount: the amount of LP tokens that should be deposited
     */
    function deposit(uint256 _pid, uint256 _amount)
        external
        nonReentrant
        tradingEnabled
        poolExists(_pid)
    {
        updatePool(_pid);

        require(
            IERC20Upgradeable(poolInfo[_pid].lpToken).balanceOf(msg.sender) >= _amount,
            "GymStreetFarming: Insufficient LP balance"
        );

        IERC20Upgradeable(poolInfo[_pid].lpToken).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        IPancakePair pair = IPancakePair(poolInfo[_pid].lpToken);

        uint256 totalSupply = pair.totalSupply();

        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        (uint256 reserveVbtc, uint256 reserveBaseToken) = pair.token0() == rewardToken
            ? (reserve0, reserve1)
            : (reserve1, reserve0);

        AddLiquidityResult memory liquidityData;

        liquidityData.lpTokensReceived = _amount;
        liquidityData.baseTokensStaked = (_amount * reserveBaseToken) / totalSupply;
        liquidityData.vbtcTokensStaked = (_amount * reserveVbtc) / totalSupply;

        _updateUserInfo(_pid, msg.sender, liquidityData);

        emit Deposit(msg.sender, _pid, liquidityData.lpTokensReceived);
    }

    /**
     * @notice Function which take ETH & tokens or tokens & tokens, add liquidity with provider and deposit given LP's
     * @param _pid: pool ID where we want deposit
     * @param _baseTokenAmount: amount of token pool base token for staking (used for BUSD, use 0 for BNB pool)
     * @param _vbtcTokenAmount: amount of VBTC for staking
     * @param _amountAMin: bounds the extent to which the B/A price can go up before the transaction reverts.
        Must be <= amountADesired.
     * @param _amountBMin: bounds the extent to which the A/B price can go up before the transaction reverts.
        Must be <= amountBDesired
     * @param _minAmountOutA: the minimum amount of output A tokens that must be received
        for the transaction not to revert
     * @param _deadline transaction deadline timestamp
     */
    function speedStake(
        uint256 _pid,
        uint256 _baseTokenAmount,
        uint256 _vbtcTokenAmount,
        uint256 _amountAMin,
        uint256 _amountBMin,
        uint256 _minAmountOutA,
        uint256 _deadline
    ) external payable nonReentrant tradingEnabled poolExists(_pid) {
        require(
            _baseTokenAmount == 0 || msg.value == 0,
            "GymStreetFarming: Cannot pass both BNB and BEP-20 assets"
        );

        require(
            _vbtcTokenAmount <= IERC20Upgradeable(rewardToken).balanceOf(msg.sender),
            "GymStreetFarming: Not enough vBTC tokens"
        );

        updatePool(_pid);

        if (_vbtcTokenAmount > 0) {
            IERC20Upgradeable(rewardToken).safeTransferFrom(
                msg.sender,
                address(this),
                _vbtcTokenAmount
            );
        }

        _deposit(
            _pid,
            _baseTokenAmount,
            _vbtcTokenAmount,
            _amountAMin,
            _amountBMin,
            _minAmountOutA,
            _deadline
        );
    }

    /**
     * @notice Deposit LP tokens to GymStreetFarming from GymVaultsBank
     * @param _pid: pool ID on which LP tokens should be deposited
     * @param _vbtcTokenAmount: the amount of reward tokens that should be converted to LP tokens
        and deposits to GymStreetFarming contract
     * @param _from: Address of user that called function from GymVaultsBank
     */
    function depositFromOtherContract(
        uint256 _pid,
        uint256 _vbtcTokenAmount,
        address _from
    ) external nonReentrant tradingEnabled poolExists(_pid) onlyWhitelisted {
        IPancakePair lpToken = IPancakePair(poolInfo[_pid].lpToken);
        bool isBnbPool = _isBnbPool(lpToken);
        address poolBaseToken = _getPoolBaseTokenFromPair(lpToken);
        uint256 poolBaseTokenAmount = 0;
        uint256 deadline = block.timestamp + 100;

        updatePool(_pid);

        if (_vbtcTokenAmount == 0) {
            return;
        }

        IERC20Upgradeable(rewardToken).safeTransferFrom(
            msg.sender,
            address(this),
            _vbtcTokenAmount
        );

        IERC20Upgradeable(rewardToken).safeApprove(routerAddress, 0);
        IERC20Upgradeable(rewardToken).safeApprove(routerAddress, _vbtcTokenAmount);

        if (isBnbPool) {
            uint256 contractBalance = address(this).balance;

            IPancakeRouter02(routerAddress).swapExactTokensForETHSupportingFeeOnTransferTokens(
                _vbtcTokenAmount,
                0,
                rewardTokenToWbnb,
                address(this),
                deadline
            );

            poolBaseTokenAmount = address(this).balance - contractBalance;
        } else {
            uint256 contractBalance = IERC20Upgradeable(poolBaseToken).balanceOf(address(this));

            address[] memory path = new address[](2);

            path[0] = rewardToken;
            path[1] = poolBaseToken;

            IPancakeRouter02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _vbtcTokenAmount,
                0,
                path,
                address(this),
                deadline
            );

            poolBaseTokenAmount =
                IERC20Upgradeable(poolBaseToken).balanceOf(address(this)) -
                contractBalance;
        }

        AddLiquidityResult memory result = _addLiquidity(
            poolBaseToken,
            poolBaseTokenAmount, // pool base token amount
            0, // VBTC token amount
            0, // amount A min
            0, // amount B min
            0,
            deadline,
            true // split poolBaseTokenAmount in half and swap one half for VBTC
        );

        _updateUserInfo(_pid, _from, result);
        _refundRemainderTokens(_from, poolBaseToken, result);

        emit Deposit(_from, _pid, result.lpTokensReceived);
    }

    /**
     * @notice Function which send accumulated reward tokens to messege sender
     * @param _pid: pool ID from which the accumulated reward tokens should be received
     */
    function harvest(uint256 _pid) external nonReentrant poolExists(_pid) {
        _harvest(_pid, msg.sender);
    }

    /**
     * @notice Function which send accumulated reward tokens to messege sender from all pools
     */
    function harvestAll() external nonReentrant {
        uint256 length = poolInfo.length;

        for (uint256 pid = 0; pid < length; ++pid) {
            if (poolInfo[pid].allocPoint > 0) {
                _harvest(pid, msg.sender);
            }
        }
    }

    /**
     * @notice Function which withdraw LP tokens to messege sender with the given amount
     * @param _pid: pool ID from which the LP tokens should be withdrawn
     */
    function withdraw(uint256 _pid) external nonReentrant poolExists(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 withdrawAmount = user.lpTokensAmount;

        updatePool(_pid);

        uint256 pending = (withdrawAmount * pool.accRewardPerShare) / 1e18 - user.rewardDebt;

        safeRewardTransfer(user, msg.sender, pending);

        emit Harvest(msg.sender, _pid, pending);

        user.lpTokensAmount = 0;
        user.rewardDebt = 0;
        user.totalDepositTokens = 0;
        user.totalDepositDollarValue = 0;

        IERC20Upgradeable(pool.lpToken).safeTransfer(msg.sender, withdrawAmount);

        emit Withdraw(msg.sender, _pid, withdrawAmount);
    }

    /// @return All pools amount
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    /**
     * @notice View function to see total pending rewards on frontend
     * @param _user: user address for which reward must be calculated
     * @return total Return reward for user
     */
    function pendingRewardTotal(address _user) external view returns (uint256 total) {
        for (uint256 pid = 0; pid < poolInfo.length; ++pid) {
            total += pendingReward(pid, _user);
        }
    }

    function getUserInfo(uint256 _pid, address _user)
        external
        view
        poolExists(_pid)
        returns (UserInfo memory)
    {
        return userInfo[_pid][_user];
    }

    /**
     * @notice Get USD amount of user deposits in all farming pools
     * @param _user user address
     * @return uint256 total amount in USD
     */
    function getUserUsdDepositAllPools(address _user) external view returns (uint256) {
        uint256 usdDepositAllPools = 0;

        for (uint256 pid = 0; pid < poolInfo.length; ++pid) {
            usdDepositAllPools += userInfo[pid][_user].totalDepositDollarValue;
        }

        return usdDepositAllPools;
    }

    /**
     * @notice Update reward vairables for all pools
     */
    function massUpdatePools() public {
        uint256 length = poolInfo.length;

        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    /**
     * @notice Update reward variables of the given pool to be up-to-date
     * @param _pid: pool ID for which the reward variables should be updated
     */
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];

        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        uint256 lpSupply = IERC20Upgradeable(pool.lpToken).balanceOf(address(this));

        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 reward = (multiplier * pool.allocPoint) / totalAllocPoint;

        pool.accRewardPerShare = pool.accRewardPerShare + ((reward * 1e18) / lpSupply);
        pool.lastRewardBlock = block.number;

        // Update rewardPerBlock AFTER pool was updated
        _updateRewardPerBlock();
    }

    /**
     * @param _from: block block from which the reward is calculated
     * @param _to: block block before which the reward is calculated
     * @return Return reward multiplier over the given _from to _to block
     */
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return (getRewardPerBlock() * (_to - _from));
    }

    /**
     * @notice View function to see pending rewards on frontend
     * @param _pid: pool ID for which reward must be calculated
     * @param _user: user address for which reward must be calculated
     * @return Return reward for user
     */
    function pendingReward(uint256 _pid, address _user)
        public
        view
        poolExists(_pid)
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = IERC20Upgradeable(pool.lpToken).balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 reward = (multiplier * pool.allocPoint) / totalAllocPoint;
            accRewardPerShare = accRewardPerShare + ((reward * 1e18) / lpSupply);
        }

        return (user.lpTokensAmount * accRewardPerShare) / 1e18 - user.rewardDebt;
    }

    /**
     * @notice Contract private function to process user deposit.
        1. Transfe pool base tokens to this contract if _baseTokenAmount > 0
        2. Swap VBTC tokens for pool base token
        3. Provide liquidity using 50/50 split of pool base tokens:
            a. 50% of pool base tokens used as is
            b. 50% used to buy VBTC tokens
            c. Add both amounts to liquidity pool
        4. Update user deposit information
     * @param _pid pool id
     * @param _baseTokenAmount amount of pool base tokens provided by user
     * @param _vbtcTokenAmount amount if VBTC tokens provided by user
     * @param _amountAMin: bounds the extent to which the B/A price can go up before the transaction reverts.
        Must be <= amountADesired.
     * @param _amountBMin: bounds the extent to which the A/B price can go up before the transaction reverts.
        Must be <= amountBDesired
     * @param _minAmountOutA: the minimum amount of output A tokens that must be received
        for the transaction not to revert
     * @param _deadline transaction deadline timestamp
     */
    function _deposit(
        uint256 _pid,
        uint256 _baseTokenAmount,
        uint256 _vbtcTokenAmount,
        uint256 _amountAMin,
        uint256 _amountBMin,
        uint256 _minAmountOutA,
        uint256 _deadline
    ) private {
        IPancakePair lpToken = IPancakePair(address(poolInfo[_pid].lpToken));
        address poolBaseToken = _getPoolBaseTokenFromPair(lpToken);
        uint256 poolBaseTokenAmount = _isBnbPool(lpToken) ? msg.value : _baseTokenAmount;
        uint256 vbtcTokenAmount = _vbtcTokenAmount;

        bool splitAndSwap = vbtcTokenAmount == 0 ? true : false;

        if (_isBnbPool(lpToken)) {
            require(_baseTokenAmount == 0, "GymStreetFarming: only BNB tokens expected");
        } else {
            require(msg.value == 0, "GymStreetFarming: only BEP-20 tokens expected");
        }

        if (_baseTokenAmount > 0) {
            IERC20Upgradeable(poolBaseToken).safeTransferFrom(
                msg.sender,
                address(this),
                _baseTokenAmount
            );
        }

        if (vbtcTokenAmount > 0 && poolBaseTokenAmount == 0) {
            IERC20Upgradeable(rewardToken).safeApprove(routerAddress, 0);
            IERC20Upgradeable(rewardToken).safeApprove(routerAddress, vbtcTokenAmount);

            poolBaseTokenAmount = _swapTokens(
                rewardToken,
                poolBaseToken,
                vbtcTokenAmount,
                0,
                address(this),
                _deadline
            );

            vbtcTokenAmount = 0;
            splitAndSwap = true;
        }

        AddLiquidityResult memory result = _addLiquidity(
            poolBaseToken,
            poolBaseTokenAmount,
            vbtcTokenAmount,
            _amountAMin,
            _amountBMin,
            _minAmountOutA,
            _deadline,
            splitAndSwap
        );

        _updateUserInfo(_pid, msg.sender, result);
        _refundRemainderTokens(msg.sender, poolBaseToken, result);

        emit Deposit(msg.sender, _pid, result.lpTokensReceived);
    }

    /**
     * @notice Function to swap exact amount of tokens A for tokens B
     * @param inputToken have token address
     * @param outputToken want token address
     * @param inputAmount have token amount
     * @param amountOutMin the minimum amount of output tokens that must be
        received for the transaction not to revert.
     * @param receiver want tokens receiver address
     * @param deadline swap transaction deadline
     * @return uint256 amount of want tokens received
     */
    function _swapTokens(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 amountOutMin,
        address receiver,
        uint256 deadline
    ) private returns (uint256) {
        require(inputToken != outputToken, "GymStreetFarming: Invalid swap path");

        address[] memory path = new address[](2);

        path[0] = inputToken;
        path[1] = outputToken;

        uint256[] memory swapResult;

        if (inputToken == wbnbAddress) {
            swapResult = IPancakeRouter02(routerAddress).swapExactETHForTokens{value: inputAmount}(
                amountOutMin,
                path,
                receiver,
                deadline
            );
        } else if (outputToken == wbnbAddress) {
            swapResult = IPancakeRouter02(routerAddress).swapExactTokensForETH(
                inputAmount,
                amountOutMin,
                path,
                receiver,
                deadline
            );
        } else {
            swapResult = IPancakeRouter02(routerAddress).swapExactTokensForTokens(
                inputAmount,
                amountOutMin,
                path,
                receiver,
                deadline
            );
        }

        return swapResult[1];
    }

    function _addLiquidity(
        address _basePoolToken,
        uint256 _baseTokenAmount,
        uint256 _rewardTokenAmount,
        uint256 _amountAMin,
        uint256 _amountBMin,
        uint256 _minAmountOut,
        uint256 _deadline,
        bool splitAndSwap
    ) private returns (AddLiquidityResult memory result) {
        uint256 baseTokensToLpAmount = _baseTokenAmount;
        uint256 rewardTokensToLpAmount = _rewardTokenAmount;

        if (_basePoolToken == wbnbAddress) {
            if (splitAndSwap) {
                uint256 swapAmount = baseTokensToLpAmount / 2;

                rewardTokensToLpAmount = _swapTokens(
                    _basePoolToken,
                    rewardToken,
                    swapAmount,
                    _minAmountOut,
                    address(this),
                    _deadline
                );

                baseTokensToLpAmount -= swapAmount;
            }

            IERC20Upgradeable(rewardToken).safeApprove(routerAddress, 0);
            IERC20Upgradeable(rewardToken).safeApprove(routerAddress, rewardTokensToLpAmount);

            (
                result.vbtcTokensStaked,
                result.baseTokensStaked,
                result.lpTokensReceived
            ) = IPancakeRouter02(routerAddress).addLiquidityETH{value: baseTokensToLpAmount}(
                rewardToken,
                rewardTokensToLpAmount,
                _amountBMin,
                _amountAMin,
                address(this),
                _deadline
            );
        } else {
            if (splitAndSwap) {
                uint256 swapAmount = baseTokensToLpAmount / 2;

                IERC20Upgradeable(_basePoolToken).safeApprove(routerAddress, 0);
                IERC20Upgradeable(_basePoolToken).safeApprove(routerAddress, swapAmount);

                rewardTokensToLpAmount = _swapTokens(
                    _basePoolToken,
                    rewardToken,
                    swapAmount,
                    _minAmountOut,
                    address(this),
                    _deadline
                );

                baseTokensToLpAmount -= swapAmount;
            }

            require(
                baseTokensToLpAmount >= _amountAMin,
                "GymStreetFarming: insufficient pool base tokens"
            );
            require(
                rewardTokensToLpAmount >= _amountBMin,
                "GymStreetFarming: insufficient VBTC tokens"
            );

            IERC20Upgradeable(_basePoolToken).safeApprove(routerAddress, 0);
            IERC20Upgradeable(rewardToken).safeApprove(routerAddress, 0);

            IERC20Upgradeable(_basePoolToken).safeApprove(routerAddress, baseTokensToLpAmount);
            IERC20Upgradeable(rewardToken).safeApprove(routerAddress, rewardTokensToLpAmount);

            (
                result.baseTokensStaked,
                result.vbtcTokensStaked,
                result.lpTokensReceived
            ) = IPancakeRouter02(routerAddress).addLiquidity(
                _basePoolToken,
                rewardToken,
                baseTokensToLpAmount,
                rewardTokensToLpAmount,
                _amountAMin,
                _amountBMin,
                address(this),
                _deadline
            );
        }

        if (baseTokensToLpAmount > result.baseTokensStaked) {
            result.baseTokensRemainder = baseTokensToLpAmount - result.baseTokensStaked;
        }

        if (rewardTokensToLpAmount > result.vbtcTokensStaked) {
            result.vbtcTokensRemainder = rewardTokensToLpAmount - result.vbtcTokensStaked;
        }
    }

    /**
     * @notice Function which transfer reward tokens to _to with the given amount
     * @param _to: transfer receiver address
     * @param _amount: amount of reward token which should be transfer
     */
    function safeRewardTransfer(
        UserInfo storage user,
        address _to,
        uint256 _amount
    ) private {
        if (_amount > 0) {
            uint256 rewardTokenBal = IERC20Upgradeable(rewardToken).balanceOf(address(this));

            require(_amount < rewardTokenBal, "GymStreetFarming: Insufficient rewards");

            IERC20Upgradeable(rewardToken).safeTransfer(_to, _amount);

            user.totalClaims += _amount;
        }
    }

    /**
     * @notice Function for updating user info
     */
    function _updateUserInfo(
        uint256 _pid,
        address _from,
        AddLiquidityResult memory liquidityData
    ) private {
        UserInfo storage user = userInfo[_pid][_from];
        address poolBaseToken = _getPoolBaseTokenFromPair(
            IPancakePair(address(poolInfo[_pid].lpToken))
        );

        uint256 dollarValue = 0;

        _harvest(_pid, _from);

        user.totalDepositTokens += liquidityData.baseTokensStaked;
        user.totalDepositTokens += _getVbtcInBaseTokensAmount(
            liquidityData.vbtcTokensStaked,
            poolBaseToken
        );

        user.lpTokensAmount += liquidityData.lpTokensReceived;
        user.rewardDebt = (user.lpTokensAmount * poolInfo[_pid].accRewardPerShare) / 1e18;

        if (poolBaseToken == wbnbAddress) {
            dollarValue += (_getBnbPrice(liquidityData.baseTokensStaked) / 1e18);
        } else {
            dollarValue += liquidityData.baseTokensStaked / 1e18;
        }

        if (liquidityData.vbtcTokensStaked > 0) {
            dollarValue += (_getVbtcPrice(liquidityData.vbtcTokensStaked) / 1e18);
        }

        user.totalDepositDollarValue += dollarValue;
    }

    /**
     * @notice Private function which send accumulated reward tokens to givn address
     * @param _pid: pool ID from which the accumulated reward tokens should be received
     * @param _from: Recievers address
     */
    function _harvest(uint256 _pid, address _from) private poolExists(_pid) {
        UserInfo storage user = userInfo[_pid][_from];

        if (user.lpTokensAmount > 0) {
            updatePool(_pid);

            uint256 accRewardPerShare = poolInfo[_pid].accRewardPerShare;
            uint256 pending = (user.lpTokensAmount * accRewardPerShare) / 1e18 - user.rewardDebt;

            safeRewardTransfer(user, _from, pending);
            user.rewardDebt = (user.lpTokensAmount * accRewardPerShare) / 1e18;

            emit Harvest(_from, _pid, pending);
        }
    }

    /**
     * @notice Check if provided Pancakeswap Pair contains WNBN token
     * @param pair Pancakeswap pair contract
     * @return bool true if provided pair is WBNB/<Token> or <Token>/WBNB pair
                    false otherwise
     */
    function _isBnbPool(IPancakePair pair) private view returns (bool) {
        IPancakeRouter02 router = IPancakeRouter02(routerAddress);

        return pair.token0() == router.WETH() || pair.token1() == router.WETH();
    }

    function _isSupportedLP(address pairAddress) private view returns (bool) {
        IPancakePair pair = IPancakePair(pairAddress);

        require(
            rewardToken == pair.token0() || rewardToken == pair.token1(),
            "GymStreetFarming: not a VBTC pair"
        );

        address baseToken = _getPoolBaseTokenFromPair(pair);

        return baseToken == wbnbAddress || baseToken == busdAddress || baseToken == rewardToken;
    }

    /**
     * @notice Get pool base token from Pancakeswap Pair. Base token - BUSD or WBNB
     * @param pair Pancakeswap pair contract
     * @return address pool base token address
     */
    function _getPoolBaseTokenFromPair(IPancakePair pair) private view returns (address) {
        return pair.token0() == rewardToken ? pair.token1() : pair.token0();
    }

    function _percentage(uint256 amount, uint256 percent) private pure returns (uint256) {
        return (amount * percent) / 100;
    }

    function _getBnbPrice(uint256 amount) private view returns (uint256) {
        uint256[] memory bnbPriceInUsd = IPancakeRouter02(routerAddress).getAmountsOut(
            amount,
            wbnbToBusd
        );

        return bnbPriceInUsd[1];
    }

    // function _getVbtcPrice(uint256 amount) private view returns (uint256) {
    //     uint256[] memory vbtcPriceInBnb = IPancakeRouter02(routerAddress).getAmountsOut(
    //         amount,
    //         rewardTokenToWbnb
    //     );

    //     return _getBnbPrice(vbtcPriceInBnb[1]);
    // }

    function _getVbtcPrice(uint256 amount) private view returns (uint256) {
        uint256[] memory vbtcPriceInBusd = IPancakeRouter02(routerAddress).getAmountsOut(
            amount,
            rewardTokenToBusd
        );

        return vbtcPriceInBusd[1];
    }

    function _getVbtcInBaseTokensAmount(uint256 vbtcAmount, address poolBaseToken)
        private
        view
        returns (uint256)
    {
        if (poolBaseToken == wbnbAddress) {
            return IPancakeRouter02(routerAddress).getAmountsOut(vbtcAmount, rewardTokenToWbnb)[1];
        } else {
            address[] memory path = new address[](2);

            path[0] = rewardToken;
            path[1] = poolBaseToken;

            return IPancakeRouter02(routerAddress).getAmountsOut(vbtcAmount, path)[1];
        }
    }

    function _refundRemainderTokens(
        address user,
        address poolBaseToken,
        AddLiquidityResult memory liquidityData
    ) private {
        if (liquidityData.baseTokensRemainder > 0) {
            if (poolBaseToken == wbnbAddress) {
                payable(user).transfer(liquidityData.baseTokensRemainder);
            } else {
                IERC20Upgradeable(poolBaseToken).safeTransfer(
                    user,
                    liquidityData.baseTokensRemainder
                );
            }
        }

        if (liquidityData.vbtcTokensRemainder > 0) {
            IERC20Upgradeable(rewardToken).safeTransfer(user, liquidityData.vbtcTokensRemainder);
        }
    }

    // function withdrawFromContract(address token) external onlyOwner {
    //     uint256 balance =  IERC20Upgradeable(token).balanceOf(address(this));
    //     require(balance > 0,"No tokens found");
    //     IERC20Upgradeable(token).safeTransfer(msg.sender,balance);
    // }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
pragma solidity 0.8.15;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IPancakeRouter02.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./interfaces/IPancakePair.sol";
import "./interfaces/IPancakeFactory.sol";

/* preserved Line */
/* preserved Line */
/* preserved Line */
/* preserved Line */
/* preserved Line */

/**
 * @notice GymSinglePool contract:
 * - Users can:
 *   # Deposit GYMNET
 *   # Withdraw assets
 */

contract TaxCollector is ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public tokenAddress;
    address public routerAddress;

    IERC20Upgradeable token;
    IPancakeRouter02 router;
    mapping(address => bool) private whitelist_contract;
    uint256 public collectedBuyTax;
    uint256 public collectedSellTax;
    uint256 public collectedManagementTax;
    address public managementAddress;
    address public busdAddress;
    /* ========== EVENTS ========== */

    event Initialized(address indexed executor, uint256 at);

    event SetTokenAddress(address indexed _address);
    event WhitelistWallet(address indexed _address, bool _whitelisted);
    event SetSellTaxAddress(address indexed _address);
    event SetBuyTaxAddress(address indexed _address);
    event SetWBNBAddress(address indexed _address);
    event SetPancakeRouterAddress(address indexed _address);

    receive() external payable {}

    fallback() external payable {}

    modifier onlyWhitelisted() {
        require(
            whitelist_contract[msg.sender] || msg.sender == owner(),
            "TaxCollector: not whitelisted or owner"
        );
        _;
    }

    // all initialize parameters are mandatory
    function initialize(
        address _tokenAddress,
        address _routerAddress,
        address _busdAddress,
        address _managementAddress
    ) external initializer {
        tokenAddress = _tokenAddress;
        routerAddress = _routerAddress;
        busdAddress = _busdAddress;
        managementAddress = _managementAddress;
        whitelist_contract[owner()] = true;
        whitelist_contract[_tokenAddress] = true;
        token = IERC20Upgradeable(tokenAddress);
        router = IPancakeRouter02(routerAddress);
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    
    function setTokenAddress(address _tokenAddress) external onlyOwner {
        tokenAddress = _tokenAddress;

        emit SetTokenAddress(_tokenAddress);
    }

    function whitelistContract(address _wallet, bool _whitelist) external onlyOwner {
        whitelist_contract[_wallet] = _whitelist;

        emit WhitelistWallet(_wallet, _whitelist);
    }

    function isWhitelistedContract(address wallet) external view returns (bool) {
        return whitelist_contract[wallet];
    }
    function setManagementAddress(address _address) external onlyOwner {
         managementAddress = _address;
    }
    function setBusdAddress(address _address) external onlyOwner {
         busdAddress = _address;
    }


    function updateRouterAddress(address _router) external onlyOwner {
        routerAddress = _router;

        emit SetPancakeRouterAddress(_router);
    }

    function updateInteractions() external onlyOwner {
        token = IERC20Upgradeable(tokenAddress);
        router = IPancakeRouter02(routerAddress);
    }

    function swapTaxTokens() external onlyWhitelisted returns (bool) {
        uint256 totalBalance = token.balanceOf(address(this));
        if (totalBalance > 0) {
            _swapWholeBalanace(collectedManagementTax+collectedBuyTax+collectedSellTax);
            collectedManagementTax =0;
            collectedBuyTax = 0;
            collectedSellTax = 0;
            _sendToManagement();
        }
        return true;
    }

    function updateTaxationAmount(bool isBuy, uint256 amount) external onlyWhitelisted {
        if (isBuy) {
            collectedBuyTax += amount;
        } else {
            collectedSellTax += amount;
        }
    }

    function updateManagementTaxationAmount(uint256 amount) external onlyWhitelisted {
        collectedManagementTax += amount;
    }

    function _swapWholeBalanace(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(tokenAddress);
        path[1] = address(busdAddress);
        token.safeApprove(routerAddress, 0);
        token.safeApprove(routerAddress, amount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, address(this), block.timestamp);
    }

    function _sendToManagement() private  {
        require(managementAddress != address(0), "Management Address is Zero");
        IERC20Upgradeable token = IERC20Upgradeable(busdAddress);
        uint256 balance = token.balanceOf(address(this));
        token.safeTransfer(managementAddress,balance);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function transfer(address dst, uint256 wad) external;

    function balanceOf(address dst) external view returns (uint256);

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/IParcelInterface.sol";
import "./ERC721Base.sol";
import "../Municipality.sol";

contract StandardParcelNFT is
    ERC721Base,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 constant PARCEL_TYPE = 10;

    address public municipalityAddress;
    address public minerPublicBuilding;
    mapping(uint256 => bool) private upgradedParcelsMapping;

    uint8 private constant PARCEL_LAND_TYPE_NEXT_TO_OCEAN = 10;
    uint8 private constant PARCEL_LAND_TYPE_NEAR_OCEAN = 20;
    uint8 private constant PARCEL_LAND_TYPE_INLAND = 30;

    event TransferActivationSet(bool indexed transferActivation);
    event ParcelMinted(address indexed user, uint256[] indexed parcelIds);
    event MaxSupplySet(uint256 indexed amount);
    event MunicipalityAddressSet(address indexed municipalityAddress);
    event MinerPublicBuildingSet(address indexed minerPublicBuildingAddress);

    modifier onlyAuthorizedContracts() {
        require(minerPublicBuilding == msg.sender || msg.sender == municipalityAddress, "MinerNFT: Only authorized contracts can call this function");
        _;
    }

    modifier onlyUnlockedToken(uint256 _tokenId) override {
        require(Municipality(payable(municipalityAddress)).isTokenLocked(address(this), _tokenId) == false, "StandardParcel: This parcel is locked and can not be transfered");
        _;
    }

    // @notice Proxy SC support - initialize internal state
    function initialize(string memory _tokenBaseURI, address _municipalityAddress, uint256 _maxSupply)
        external
        initializer
    {
        __Ownable_init();
        __ReentrancyGuard_init();
        municipalityAddress = _municipalityAddress;
        _name = "StandardParcel";
        _symbol = "SP";
        _baseURI = _tokenBaseURI;
        _setMaxSupply(_maxSupply);
    }

    function setTransferActivation(bool _transferActivation) public onlyOwner {
        _setTransferActivation(_transferActivation);
        emit TransferActivationSet(_transferActivation);
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        _setMaxSupply(_maxSupply);
        emit MaxSupplySet(_maxSupply);
    }

    function setMunicipalityAddress(address _municipalityAddress) external onlyOwner {
        municipalityAddress = _municipalityAddress;
        emit MunicipalityAddressSet(municipalityAddress);
    }

    function setMinerPublicBuildingAddress(address _minerPublicBuilding) external onlyOwner {
        minerPublicBuilding = _minerPublicBuilding;
        emit MinerPublicBuildingSet(minerPublicBuilding);
    }

    /// @notice IParcelInterface functions
    function mint(address _user, uint256 _x, uint256 _y, uint256 _lt) public onlyAuthorizedContracts returns (uint256) {
        uint256 parcelId = _getParcelId(_x, _y, _lt);
        require(!_exists(parcelId), "StandardParcelNFT: Parcel already exists as a standard parcel");
        _mintFor(parcelId, _user);
        return parcelId;
    }

    function upgradeParcel(uint256 tokenId) external onlyAuthorizedContracts  {
        upgradedParcelsMapping[tokenId] = true;
    }

    function parcelExists(uint256 _x, uint256 _y, uint256 _lt) external view returns(bool) {
        return _parcelExists(_x, _y, _lt);
    }

    function getParcelId(uint256 _x, uint256 _y, uint256 _lt) external pure returns (uint256) {
        return _getParcelId(_x, _y, _lt);
    }

    function isParcelUpgraded(uint256 tokenId) external view returns (bool) {
        return upgradedParcelsMapping[tokenId];
    }

    function getParcelInfo(uint256 token)  public pure returns (uint256, uint256, uint256, uint256) { //private pure
        uint256 x = token & 65535;
        uint256 y = (token >> 16) & 65535;
        uint256 pt = (token >> 32) & 255;
        uint256 lt = token >> 40;
        return (x, y, pt, lt);
    }

    // Private interface
    function _getParcelId(uint256 _x, uint256 _y, uint256 _lt) private pure returns (uint256) {
        uint256 token = _lt;
        token = (token << 8) | PARCEL_TYPE;
        token = (token << 16) | _y;
        token = (token << 16) | _x;
        return token;
    }

    function _parcelExists(uint256 _x, uint256 _y, uint256 _lt) private view returns(bool) {
        uint256 parcelId = _getParcelId(_x, _y, _lt);
        return _exists(parcelId);
    }

    function mintParcels(address _user, Municipality.Parcel[] calldata parcels) external onlyAuthorizedContracts returns(uint256[] memory) {
        uint256[] memory parcelIds = new uint256[](parcels.length);
        for (uint256 i = 0; i < parcels.length; ++i) {
            Municipality.Parcel memory parcel = parcels[i];
            require(
                parcel.parcelLandType == PARCEL_LAND_TYPE_NEXT_TO_OCEAN ||
                    parcel.parcelLandType == PARCEL_LAND_TYPE_NEAR_OCEAN ||
                    parcel.parcelLandType == PARCEL_LAND_TYPE_INLAND,
                "Municipality: Invalid parcel land type"
            );
            uint256 parcelId = mint(
                _user,
                parcel.x,
                parcel.y,
                parcel.parcelLandType
            );
            parcelIds[i] = parcelId;
        }
        emit ParcelMinted(_user, parcelIds);
        return parcelIds;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../interfaces/IERC721Base.sol";
import "../interfaces/IERC721TokenReceiver.sol";

contract ERC721Base is IERC721Base {
    /// @dev This contract uses SafeMath library functionality with type
    using SafeMath for uint256;

    /// @dev Calculated by "bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))"
    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

    /// @dev Id of the ERC165 interface
    bytes4 private constant InterfaceId_ERC165 = 0x01ffc9a7;

    /// @dev Id of the ERC721 interface
    bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;

    string internal _name;

    string internal _symbol;

    string internal _baseURI;

    /// @dev Amount of nft tokens in circulation
    uint256 internal _tokensCount;

    uint256 internal _maxSupply;

    bool internal _isTransferActive;

    /// @dev Index of the token inside owner's tokens array
    mapping(uint256 => uint256) internal _indexOfToken;

    /// @dev Reflets weather token is locked
    // This mapping will not be used in the future, It is kept not to create a storage clash, in future it will be removed
    mapping(uint256 => bool) internal _isLocked;

    /// @dev Reflects owner of a token
    mapping(uint256 => address) internal _tokenOwner;

    /// @dev Reflects operator of a token
    mapping(uint256 => address) internal _tokenOperator;

    /// @dev Array of the user's tokens in holding
    mapping(address => uint256[]) internal _userTokens;

    /// @dev Reflects weather an address can operate all of the user's tokens
    mapping(address => mapping(address => bool)) internal _operatorForAll;

    mapping(address => uint256) public _userPurchaseDate;

    /// @dev Modifier that reverts if caller is not authorized for given token
    modifier onlyAuthorized(uint256 _tokenId) {
        require(
            _isAuthorized(msg.sender, _tokenId),
            "ERC721Base: You are not authorized to call this function"
        );
        _;
    }

    /// @dev Modifier that reverts if token is locked
    modifier onlyUnlockedToken(uint256 _tokenId) virtual {
        _;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function baseURI() external view returns (string memory) {
        return _baseURI;
    }

    /**
     * @notice Returns weather contract supports fiven interface
     * @dev This contract supports ERC165 and ERC721 interfaces
     * @param _interfaceId id of the interface which is checked to be supported
     * @return true - given interface is supported, false - given interface is not supported
     */
    function supportsInterface(bytes4 _interfaceId) external pure returns (bool) {
        return _interfaceId == InterfaceId_ERC165 || _interfaceId == InterfaceId_ERC721;
    }

    /// @notice Total amount of nft tokens in circulation
    function totalSupply() external view returns (uint256) {
        return _tokensCount;
    }

    function maxSupply() external view returns (uint256) {
        return _maxSupply;
    }

    /**
     * @notice Gives the number of nft tokens that a given user owns
     * @param _owner address of the user who's token's count will be returned
     * @return amount of tokens given user owns
     */
    function balanceOf(address _owner) external view returns (uint256) {
        return _userTokens[_owner].length;
    }

    function tokensOf(address _owner) external view returns (uint256[] memory) {
        return _userTokens[_owner];
    }

    /**
     * @notice Tells weather a token exists
     * @param _tokenId id of the token who's existence is returned
     * @return true - exists, false - does not exist
     */
    function exists(uint256 _tokenId) external view returns (bool) {
        return _exists(_tokenId);
    }

    /**
     * @notice Tells weather a token is locked
     * @param _tokenId id of the token who's lock status is returned
     * @return true - is locked, false - is not locked
     */
    function isLocked(uint256 _tokenId) external view returns (bool) {
        return _isLocked[_tokenId];
    }

    /**
     * @notice Gives owner address of a given token
     * @param _tokenId id of the token who's owner address is returned
     * @return address of the given token owner
     */
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return _ownerOf(_tokenId);
    }

    function requireNFTsBelongToUser(uint256[] memory nftIds, address userWalletAddress) external view {
        for (uint32 i = 0; i < nftIds.length; i++) {
            require(_ownerOf(nftIds[i]) == userWalletAddress, "ERC721Base: Invalid NFT owner");
        }
    }

    /**
     * @notice Gives the approved address of the given token
     * @param _tokenId id of the token who's approved user is returned
     * @return address of the user who is approved for the given token
     */
    function getApproved(uint256 _tokenId) external view returns (address) {
        return _getApproved(_tokenId);
    }

    /**
     * @notice Tells weather given user (_operator) is approved to use given token (_tokenId)
     * @param _operator address of the user who's checked to be approved for given token
     * @param _tokenId id of the token for which approval will be checked
     * @return true - approved, false - disapproved
     */
    function isAuthorized(address _operator, uint256 _tokenId) external view returns (bool) {
        return _isAuthorized(_operator, _tokenId);
    }

    /**
     * @notice Tells weather given user (_operator) is approved to use tokens of another given user (_owner)
     * @param _owner address of the user who's tokens are checked to be aproved to another user
     * @param _operator address of the user who's checked to be approved by owner of the tokens
     * @return true - approved, false - disapproved
     */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return _isApprovedForAll(_owner, _operator);
    }

    function getUserPurchaseTime(address _user) external view returns (uint256[2] memory) {
        uint256 _time = uint256(_userPurchaseDate[_user]);
        return [_time, _time + 30 days];
    }

    /**
     * @notice Approves an address to use given token
     *         Only authorized users can call this function
     * @dev Only one user can be approved at any given moment
     * @param _approved address of the user who gets approved
     * @param _tokenId id of the token the given user get aproval on
     */
    function approve(address _approved, uint256 _tokenId) external onlyAuthorized(_tokenId) {
        require(
            _approved != _tokenOperator[_tokenId],
            "ERC721Base: Address is already an operator"
        );
        _tokenOperator[_tokenId] = _approved;
        emit Approval(_tokenOwner[_tokenId], _approved, _tokenId);
    }

    /**
     * @notice Approves or disapproves an address to use all tokens of the caller
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    function setApprovalForAll(address _operator, bool _approved) external {
        require(
            _operatorForAll[msg.sender][_operator] != _approved,
            "ERC721Base: Address already has this approval status"
        );
        _operatorForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes "_data" from this function arguments
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     * @param _data argument which will be passed to "onERC721Received" function
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external {
        _transferToken(_from, _to, _tokenId, _data, true);
    }

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes an empty string for "data" parameter
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        _transferToken(_from, _to, _tokenId, "", true);
    }

    /**
     * @notice Transfers token without checking weather it was recieved
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev Does not call "onERC721Received" function even if the reciver is ERC721TokenReceiver
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        _transferToken(_from, _to, _tokenId, "", false);
    }

    function _setName(string memory _newName) internal {
        _name = _newName;
    }

    function _setSymbol(string memory _newSymbol) internal {
        _symbol = _newSymbol;
    }

    function _setBaseURI(string memory _newBaseURI) internal {
        _baseURI = _newBaseURI;
    }

    /**
     * @dev Tells weather given user (_operator) is approved to use given token (_tokenId)
     * @param _operator address of the user who's checked to be approved for given token
     * @param _tokenId id of the token for which approval will be checked
     * @return true - approved, false - disapproved
     */
    function _isAuthorized(address _operator, uint256 _tokenId) internal view returns (bool) {
        require(_operator != address(0), "ERC721Base: Operator address can not be address 0");
        address tokenOwner = _tokenOwner[_tokenId];
        return
            _operator == tokenOwner ||
            _isApprovedForAll(tokenOwner, _operator) ||
            _getApproved(_tokenId) == _operator;
    }

    function _mintFor(uint256 _tokenId, address _owner) internal {
        require(_tokensCount + 1 <= _maxSupply, "ERC721Base: Max supply reached");
        require(_tokenOwner[_tokenId] == address(0), "ERC721Base: Token has already been minted");
        _addTokenTo(_owner, _tokenId);
        emit Transfer(address(0), _owner, _tokenId);
    }

    function _setTransferActivation(bool _transferActivation) internal {
        _isTransferActive = _transferActivation;
    }

    function _setMaxSupply(uint256 _supply) internal {
        _maxSupply = _supply;
    }

    /**
     * @dev Tells weather given user (_operator) is approved to use tokens of another given user (_owner)
     * @param _owner address of the user who's tokens are checked to be aproved to another user
     * @param _operator address of the user who's checked to be approved by owner of the tokens
     * @return true - approved, false - disapproved
     */
    function _isApprovedForAll(address _owner, address _operator) internal view returns (bool) {
        return _operatorForAll[_owner][_operator];
    }

    /**
     * @dev Gives the approved address of the given token
     * @param _tokenId id of the token who's approved user is returned
     * @return address of the user who is approved for the given token
     */
    function _getApproved(uint256 _tokenId) internal view returns (address) {
        return _tokenOperator[_tokenId];
    }

    /**
     * @dev This function is called from all the different transfer functions
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     * @param _data argument which will be passed to "onERC721Received" function
     */
    function _transferToken(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data,
        bool _check
    ) internal onlyAuthorized(_tokenId) onlyUnlockedToken(_tokenId) {
        require(_isTransferActive, "ERC721Base: Transfers are deactivated now");
        require(_to != address(0), "ERC721Base: Can not transfer to address 0");
        address tokenOwner = _tokenOwner[_tokenId];
        require(_to != tokenOwner, "ERC721Base: Can not transfer token to its owner");
        require(_from == tokenOwner, "ERC721Base: Address from does not match token owner");

        _resetApproval(_tokenId);
        _removeTokenFrom(_from, _tokenId);
        _addTokenTo(_to, _tokenId);
        emit Transfer(tokenOwner, _to, _tokenId);

        if (_check && _isContract(_to)) {
            require(
                IERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) ==
                    ERC721_RECEIVED,
                "ERC721Base: Token was not received"
            );
        }
    }

    /**
     * @dev Resets approval of the given token
     * @param _tokenId id of the tokens who's approval will be resetn
     */
    function _resetApproval(uint256 _tokenId) private {
        _tokenOperator[_tokenId] = address(0);
        emit Approval(_tokenOwner[_tokenId], address(0), _tokenId);
    }

    /**
     * @dev Removes given token from the given addrese's ownership
     * @param _from address of the user from whom the token will be removed
     * @param _tokenId id of the tokens that will be removed
     */
    function _removeTokenFrom(address _from, uint256 _tokenId) internal {
        uint256 tokenIndex = _indexOfToken[_tokenId];
        uint256 lastTokenId = _userTokens[_from][_userTokens[_from].length - 1];

        _userTokens[_from][tokenIndex] = lastTokenId;
        delete _indexOfToken[_tokenId];
        _userTokens[_from].pop();

        _tokenOwner[_tokenId] = address(0);
        _tokensCount = _tokensCount.sub(1);

        if (_userTokens[_from].length == 0) {
            delete _userTokens[_from];
        }
    }

    /**
     * @dev Sets given address as owner for the given token
     * @param _to address to which token will be tranfered
     * @param _tokenId id of the tokens that will be transfered
     */
    function _addTokenTo(address _to, uint256 _tokenId) internal {
        _tokenOwner[_tokenId] = _to;
        _userTokens[_to].push(_tokenId);
        _indexOfToken[_tokenId] = _userTokens[_to].length - 1;
        _tokensCount = _tokensCount.add(1);
        // _userPurchaseDate[_to] = block.timestamp;
    }

    function _ownerOf(uint256 _tokenId) internal view returns (address) {
        return _tokenOwner[_tokenId];
    }

    function _exists(uint256 _tokenId) internal view returns (bool) {
        return _tokenOwner[_tokenId] != address(0);
    }

    /**
     * @dev Tells weather given address is contract or not
     * @param _to address which will be checked to be contract address
     * @return true - is a contract address, false - is not a contract address
     */
    function _isContract(address _to) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_to)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

pragma solidity ^0.8.15;

interface IERC721TokenReceiver {
    /**
     * @notice Returns data which is used to understand weather contract has recived given token
     * @param _operator address of the operator
     * @param _from address of the token owner
     * @param _tokenId id of the token for which was transfered
     * @param _data additional data with no specific format
     * @return Returns `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
     */
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/IMunicipality.sol";
import "../interfaces/IMinerNFT.sol";
import "./ERC721Base.sol";

contract MinerNFT is ERC721Base, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 lastMinerId;
    address public municipalityAddress;
    address public minerPublicBuilding;

    event TransferActivationSet(bool indexed transferActivation);
    event MaxSupplySet(uint256 indexed amount);
    event MunicipalityAddressSet(address indexed municipalityAddress);
    event MinerPublicBuildingSet(address indexed minerPublicBuildingAddress);
    event MinerMinted(address indexed user, uint256 firstMinerId, uint256 count);

    modifier onlyAuthorizedContracts() {
        require(minerPublicBuilding == msg.sender || msg.sender == municipalityAddress, "MinerNFT: Only authorized contracts can call this function");
        _;
    }

    modifier onlyUnlockedToken(uint256 _tokenId) override {
        require(IMunicipality(municipalityAddress).isTokenLocked(address(this), _tokenId) == false, "MinerNFT: This miner is locked and can not be transfered");
        _;
    }

    // @notice Proxy SC support - initialize internal state
    function initialize(string memory _tokenBaseURI, address _municipalityAddress, uint256 _maxSupply)
        external
        initializer
    {
        __Ownable_init();
        __ReentrancyGuard_init();
        municipalityAddress = _municipalityAddress;
        _name = "MinerV1";
        _symbol = "MV1";
        _baseURI = _tokenBaseURI;
        _setMaxSupply(_maxSupply);
    }

    function setTransferActivation(bool _transferActivation) external onlyOwner {
        _setTransferActivation(_transferActivation);
        emit TransferActivationSet(_transferActivation);
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        _setMaxSupply(_maxSupply);
        emit MaxSupplySet(_maxSupply);
    }

    function setMunicipalityAddress(address _municipalityAddress) external onlyOwner {
        municipalityAddress = _municipalityAddress;
        emit MunicipalityAddressSet(municipalityAddress);
    }

    function setMinerPublicBuilding(address _minerPublicBuilding) external onlyOwner {
        minerPublicBuilding = _minerPublicBuilding;
        emit MinerPublicBuildingSet(minerPublicBuilding);
    }

    /// @notice Mint a given amount of miners
    function mintMiners(address _user, uint256 _count) external onlyAuthorizedContracts returns(uint256, uint256) {
        uint256 firstMinerId;
        for (uint256 i = 0; i < _count; ++i) {
            uint256 minerId = mint(_user);
            if(i == 0) {
                firstMinerId = minerId;
            }
        }
        emit MinerMinted(_user, firstMinerId, _count);
        return (firstMinerId, _count);
    }

    /// @notice IMinerNFT interface methods
    function mint(address user) public onlyAuthorizedContracts returns (uint256) {
        _mintFor(++lastMinerId, user);
        return lastMinerId;
    }

    function hashrate() external pure returns (uint256) {
        return 1000;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IMunicipality {
    struct LastPurchaseData {
        uint256 lastPurchaseDate;
        uint256 expirationDate;
        uint256 dollarValue;
    }
    function lastPurchaseData(address) external view returns (LastPurchaseData memory);
    function attachMinerToParcel(address user, uint256 firstMinerId, uint256[] memory parcelIds) external;
    function isTokenLocked(address _tokenAddress, uint256 _tokenId) external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./interfaces/IParcelInterface.sol";
import "./interfaces/IMinerPublicBuildingInterface.sol";
import "./interfaces/IMinerNFT.sol";
import "./interfaces/IMining.sol";
import "./interfaces/IMunicipality.sol";

contract MinerPublicBuilding is OwnableUpgradeable, ReentrancyGuardUpgradeable, IMinerPublicBuildingInterface {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public standardParcelNFTAddress;
    address public minerV1NFTAddress;
    address public miningAddress;
    address public municipalityAddress;

    event NFTContractAddressesSet(address[4] indexed nftContractAddresses);

    modifier onlyMunicipality() {
        require(msg.sender == municipalityAddress, "MinerPublicBuilding: Only municipality is authorized to call this function");
        _;
    }

    function initialize() external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    /// @notice Set contract addresses for all NFTs we currently have
    function setNFTContractAddresses(address[4] calldata _nftContractAddresses) external onlyOwner {
        standardParcelNFTAddress = _nftContractAddresses[0];
        minerV1NFTAddress = _nftContractAddresses[1];
        miningAddress = _nftContractAddresses[2];
        municipalityAddress = _nftContractAddresses[3];
        emit NFTContractAddressesSet(_nftContractAddresses);
    }

    function mintParcelsBundle(address _user, Municipality.Parcel[] memory parcels) external onlyMunicipality
        returns (uint256[] memory)
    {
        uint256[] memory parcelIds = IParcelInterface(standardParcelNFTAddress).mintParcels(_user, parcels);
        return parcelIds;
    }

    function mintMinersBundle(address _user, uint256 minerAmount) external onlyMunicipality returns (uint256, uint256) {
        (uint256 firstMinerId, uint256 count) = IMinerNFT(minerV1NFTAddress).mintMiners(_user, minerAmount);
        return (firstMinerId, count);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IGymMLMQualifications.sol";
import "./interfaces/IERC721Base.sol";
import "./interfaces/IGymMLM.sol";
import "./interfaces/IGymFarming.sol";
import "./interfaces/IMunicipality.sol";

contract NetGymStreet is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    uint256 public currentId;
    uint256[25] public directReferralBonuses;

    mapping(address => bool) public termsAndConditions;
    mapping(address => bool) private whitelist;

    address public mlmQualificationsAddress;
    address public mlmAddress;
    address public standardParcelAddress;
    address public businessParcelAddress;
    address public minerNFTAddress;
    address public managementAddress;

    mapping(address => bool) public whiteListedContracts;
   

    mapping(address => uint256) public termsAndConditionsTimestamp;
    mapping(address => uint256) public additionalLevel;
    address municipalityAddress;

    /* ========== EVENTS ========== */
    event ReferralRewardReceived(
        address indexed referrer,
        address indexed _user,
        uint256 index,
        uint256 rewardToTransfer,
        address _wantAddr
    );
    event Whitelisted(address indexed wallet, bool whitelist);
    event SetStandardParcelAddress(address indexed _address);
    event SetBusinessParcelAddress(address indexed _address);
    event SetMinerAddress(address indexed _address);
    event SetMLMQualificationsAddress(address indexed _address);
    event SetManagementAddress(address indexed _address);
    event SetMLMAddress(address indexed _address);
    event WhitelistedContract(address indexed _contract, bool whitelisted);
    event MLMCommissionUpdated(uint256 indexed _level, uint256 indexed _commission);

    function initialize() external initializer {
        directReferralBonuses = [
            1000,
            500,
            500,
            300,
            300,
            200,
            200,
            100,
            100,
            100,
            50,
            50,
            50,
            50,
            50,
            50,
            50,
            50,
            50,
            25,
            25,
            25,
            25,
            25,
            25
        ];
        termsAndConditions[0x49A6DaD36768c23eeb75BD253aBBf26AB38BE4EB] = true;
        currentId = 2;

        __Ownable_init();
    }

    modifier onlyWhiteListedContracts() {
        require(whiteListedContracts[msg.sender], "NetGymStreet: not whitelisted contract");
        _;
    }

    modifier onlyWhitelisted() {
        require(
            whitelist[msg.sender] || msg.sender == owner(),
            "NetGymStreet: not whitelisted or owner"
        );
        _;
    }

    receive() external payable {}

    fallback() external payable {}

    function setStandardParcelAddress(address _contract) external onlyOwner {
        standardParcelAddress = _contract;

        emit SetStandardParcelAddress(_contract);
    }

    function setBusinessParcelAddress(address _contract) external onlyOwner {
        businessParcelAddress = _contract;

        emit SetBusinessParcelAddress(_contract);
    }

    function setMinerAddress(address _contract) external onlyOwner {
        minerNFTAddress = _contract;

        emit SetMinerAddress(_contract);
    }

    function setMLMQualificationsAddress(address _address) external onlyOwner {
        mlmQualificationsAddress = _address;

        emit SetMLMQualificationsAddress(_address);
    }

    function setManagementAddress(address _address) external onlyOwner {
        managementAddress = _address;

        emit SetManagementAddress(_address);
    }

    function setMLMAddress(address _address) external onlyOwner {
        mlmAddress = _address;

        emit SetMLMAddress(_address);
    }

    function setMunicipalityAddress(address _address) external onlyOwner {
        municipalityAddress = _address;

        emit SetMLMAddress(_address);
    }
    /**
     * @notice Add or remove wallet to/from whitelist, callable only by contract owner
     *         whitelisted wallet will be able to call functions
     *         marked with onlyWhitelisted modifier
     * @param _wallet wallet to whitelist
     * @param _whitelist boolean flag, add or remove to/from whitelist
     */
    function whitelistWallet(address _wallet, bool _whitelist) external onlyOwner {
        whitelist[_wallet] = _whitelist;

        emit Whitelisted(_wallet, _whitelist);
    }

    /**
     * @notice Add or remove contract to/from whitelist, callable only by contract owner
     *         whitelisted contract will be able to call functions
     *         marked with onlyWhitelisted modifier
     * @param _contract contract to whitelist
     * @param _whitelist boolean flag, add or remove to/from whitelist
     */
    function whitelistContract(address _contract, bool _whitelist) external onlyOwner {
        whiteListedContracts[_contract] = _whitelist;

        emit WhitelistedContract(_contract, _whitelist);
    }

    /**
     * @notice  Function to update MLM commission
     * @param _level commission level for change
     * @param _commission new commission
     */
    function updateMLMCommission(uint256 _level, uint256 _commission) external onlyOwner {
        directReferralBonuses[_level] = _commission;

        emit MLMCommissionUpdated(_level, _commission);
    }

    function agreeTermsAndConditions() external {
        termsAndConditions[msg.sender] = true;
        if(termsAndConditionsTimestamp[msg.sender] == 0) {
            termsAndConditionsTimestamp[msg.sender] = block.timestamp;
        }
    }


    function hasNFT(address _user) external view returns(bool) {
        return _hasNFT(_user);
    }

    function lastPurchaseDateERC(address _user) external view returns (uint256)  {
        return _checkPurchaseDate(_user);
    }
    /**
     * @notice  Function to add GymMLM
     * @param _user Address of user
     * @param _referrerId id of referrer
     */
    function addGymMlm(address _user, uint256 _referrerId) external onlyWhiteListedContracts {
        // address _referrer = IGymMLM(mlmAddress).idToAddress(_referrerId);
        // require(
        //     termsAndConditions[_referrer],
        //     "NetGymStreet: your sponsor not activate Affiliate program"
        // );
        uint256 userId = IGymMLM(mlmAddress).addressToId(_user);
        if(termsAndConditionsTimestamp[_user] == 0 || (termsAndConditionsTimestamp[_user] < 1664788248 && userId < 25500)) {
            termsAndConditionsTimestamp[_user] = block.timestamp;
        }
        IGymMLM(mlmAddress).addGymMLMNFT(_user, _referrerId);
    }

    /**
     * @notice Function to distribute rewards to referrers
     * @param _wantAmt Amount of assets that will be distributed
     * @param _wantAddr Address of want token contract
     * @param _user Address of user
     */
    function distributeRewards(
        uint256 _wantAmt,
        address _wantAddr,
        address _user
    ) external onlyWhiteListedContracts {
        uint256 index;
        uint256 rewardToTransfer;
        IERC20Upgradeable token = IERC20Upgradeable(_wantAddr);
        uint256 _level = _getUserLevel(_user);
        address[] memory _referrers = IGymMLM(mlmAddress).getReferrals(_user, 25);
        uint256 referrerId = IGymMLM(mlmAddress).addressToId(
            IGymMLM(mlmAddress).userToReferrer(_user)
        );

        while (
            index < directReferralBonuses.length && index < _referrers.length && referrerId != 1
        ) {
            _level = _getUserLevel(_referrers[index]);
            rewardToTransfer += (_wantAmt * directReferralBonuses[index]) / 10000;

            if (index <= _level && _hasNFT(_referrers[index])) {
                token.safeTransfer(_referrers[index], rewardToTransfer);

                emit ReferralRewardReceived(
                    _referrers[index],
                    _user,
                    index,
                    rewardToTransfer,
                    _wantAddr
                );
                rewardToTransfer = 0;
            }

            index++;
            if(index < 25) {
                referrerId = IGymMLM(mlmAddress).addressToId(_referrers[index]);
            }
        }

        if (token.balanceOf(address(this)) > 0) {
            token.safeTransfer(managementAddress, token.balanceOf(address(this)));
        }

        return;
    }

    /**
     * @notice External function to update additional level
     * @param _user: user address to get the level
     * @param _level: level for update
     */
    function updateAdditionalLevel(address _user, uint256 _level)
        external
        onlyWhiteListedContracts
    {
        additionalLevel[_user] = _level;
    }

    /**
     * @notice External view function to get info for update additional level
     * @param _user: user address to get the level
     */
    function getInfoForAdditionalLevel(address _user)
        external
        view
        returns (uint256 _termsTimestamp, uint256 _level)
    {
        _level = additionalLevel[_user];
        if (termsAndConditions[_user] && termsAndConditionsTimestamp[_user] == 0) {
            _termsTimestamp = block.timestamp;
        } else {
            _termsTimestamp = termsAndConditionsTimestamp[_user];
        }
    }

    /**
     * @notice External view function to get user GymStreet level
     * @param _user: user address to get the level
     * @return userLevel user GymStreet level
     */
    function getUserCurrentLevel(address _user) external view returns (uint256) {
        return _getUserLevel(_user);
    }

    /**
     * @notice Private view function to get user GymStreet level
     * @param _user: user address to get the level
     * @return _levelNFT user GymStreet level
     */
    function _getUserLevel(address _user) private view returns (uint256 _levelNFT) {

        uint256 _level = IGymMLMQualifications(mlmQualificationsAddress).getUserCurrentLevel(_user);
        if (_level >= 8 && block.timestamp < 1668058613) {
            return 24;
        }

        if (_hasNFT(_user)) {
            _levelNFT = 2;

            if (_level > _levelNFT && _level <= 9) {
                _levelNFT = _level;
            }
            if (_level > 9) {
                if (IMunicipality(municipalityAddress).lastPurchaseData(_user).expirationDate > block.timestamp || (_checkPurchaseDate(_user) + 30 days) > block.timestamp) {
                    _levelNFT = _level;
                } else {
                    _levelNFT = 0;
                }
            }

            if (additionalLevel[_user] > _levelNFT) {
                _levelNFT = additionalLevel[_user];
            }
        }
    }

    /**
     * @notice Private view function to check nft
     * @param _user: user address
     * @return bool
     */
    function _hasNFT(address _user) private view returns (bool) {
        return (IERC721Base(standardParcelAddress).balanceOf(_user) != 0 ||
            IERC721Base(businessParcelAddress).balanceOf(_user) != 0 ||
            IERC721Base(minerNFTAddress).balanceOf(_user) != 0);
    }

    function _checkPurchaseDate(address _user) private view returns (uint256) {
        uint256 _lastDate = IERC721Base(standardParcelAddress).getUserPurchaseTime(_user)[0];
        if (IERC721Base(businessParcelAddress).getUserPurchaseTime(_user)[0] > _lastDate) {
            _lastDate = IERC721Base(businessParcelAddress).getUserPurchaseTime(_user)[0];
        }
        if (IERC721Base(minerNFTAddress).getUserPurchaseTime(_user)[0] >  _lastDate) {
            _lastDate = IERC721Base(minerNFTAddress).getUserPurchaseTime(_user)[0];
        }
        return _lastDate;

    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IGymMLMQualifications {
    function getUserCurrentLevel(address) external view returns (uint32);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IGymMLM {
    function idToAddress(uint256) external view returns (address);

    function addressToId(address) external view returns (uint256);

    function userToReferrer(address) external view returns (address);

    function addGymMLMNFT(address, uint256) external;

    function getReferrals(address, uint256) external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IGymFarming {
    struct UserInfo {
        uint256 totalDepositTokens;
        uint256 totalDepositDollarValue;
        uint256 lpTokensAmount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        address lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }

    function getUserInfo(uint256, address) external view returns (UserInfo memory);

    function getUserUsdDepositAllPools(address) external view returns (uint256);

    function depositFromOtherContract(
        uint256,
        uint256,
        address
    ) external;

    function pendingRewardTotal(address) external view returns (uint256 total);

    function isSpecialOfferParticipant(address _user) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/IParcelInterface.sol";
import "./ERC721Base.sol";
import "../Municipality.sol";

contract BusinessParcelNFT is
    ERC721Base,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 constant PARCEL_TYPE = 20;

    address public municipalityAddress;

    event TransferActivationSet(bool indexed transferActivation);
    event MunicipalityAddressSet(address indexed municipalityAddress);
    event MaxSupplySet(uint256 indexed amount);
    event ParcelMinted(address indexed user, uint256[] indexed parcelIds);

    modifier onlyMunicipality() {
        require(msg.sender == municipalityAddress, "BusinessParcel: Only municipality is allowed to call this function");
        _;
    }

    modifier onlyUnlockedToken(uint256 _tokenId) override {
        require(true, "BusinessParcel: This parcel is locked and can not be transfered");
        _;
    }

    // @notice Proxy SC support - initialize internal state
    function initialize(string memory _tokenBaseURI, address _municipalityAddress,
        uint256 _maxSupply) external initializer
    {
        __Ownable_init();
        __ReentrancyGuard_init();
        municipalityAddress = _municipalityAddress;
        _name = "BusinessParcel";
        _symbol = "BP";
        _baseURI = _tokenBaseURI;
        _setMaxSupply(_maxSupply);
    }


    function setTransferActivation(bool _transferActivation) public onlyOwner {
        _setTransferActivation(_transferActivation);
        emit TransferActivationSet(_transferActivation);
    }

    function setMunicipalityAddress(address _municipalityAddress) external onlyOwner {
        municipalityAddress = _municipalityAddress;
        emit MunicipalityAddressSet(municipalityAddress);
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        _setMaxSupply(_maxSupply);
        emit MaxSupplySet(_maxSupply);
    }

    /// @notice IParcelInterface functions
    function mint(address _user, uint256 _x, uint256 _y, uint256 _lt) public onlyMunicipality returns (uint256) {
        uint256 parcelId = _getParcelId(_x, _y, _lt);
        _mintFor(parcelId, _user);
        return parcelId;
    }

    function parcelExists(uint256 _x, uint256 _y, uint256 _lt) external view returns(bool) {
        return _parcelExists(_x, _y, _lt);
    }

    function getParcelId(uint256 _x, uint256 _y, uint256 _lt) external pure returns (uint256) {
        return _getParcelId(_x, _y, _lt);
    }

    function isParcelUpgraded(uint256) external pure returns (bool) {
        require(1 == 0, "BusinessParcel: Not implemented");
        return false;
    }

    function upgradeParcel(uint256) external view onlyMunicipality  {
        require(1 == 0, "BusinessParcel: Not implemented");
    }

    function mintParcels(address _user, Municipality.Parcel[] calldata parcels) external onlyMunicipality returns(uint256[] memory){
        uint256[] memory parcelIds = new uint256[](parcels.length);
        for (uint256 i = 0; i < parcels.length; ++i) {
            Municipality.Parcel memory parcel = parcels[i];
            require(
                !_parcelExists(
                    parcel.x,
                    parcel.y,
                    parcel.parcelLandType
                ),
                "Municipality: Parcel already exists as a standard parcel"
            );
            
            uint256 parcelId = mint(
                _user,
                parcel.x,
                parcel.y,
                parcel.parcelLandType
            );
            parcelIds[i] = parcelId;
        }
        emit ParcelMinted(_user, parcelIds);
        return parcelIds;
    }

    // Private interface
    function _getParcelId(uint256 _x, uint256 _y, uint256 _lt) private pure returns (uint256) {
        uint256 token = _lt;
        token = (token << 8) | PARCEL_TYPE;
        token = (token << 16) | _y;
        token = (token << 16) | _x;
        return token;
    }

    function _getParcelInfo(uint256 token) external pure returns (uint256, uint256, uint256, uint256) {
        uint256 x = token & 65535;
        uint256 y = (token >> 16) & 65535;
        uint256 pt = (token >> 32) & 255;
        uint256 lt = token >> 40;
        return (x, y, pt, lt);
    }

    function _parcelExists(uint256 _x, uint256 _y, uint256 _lt) internal view returns(bool) {
        uint256 parcelId = _getParcelId(_x, _y, _lt);
        return _exists(parcelId);
    }
}