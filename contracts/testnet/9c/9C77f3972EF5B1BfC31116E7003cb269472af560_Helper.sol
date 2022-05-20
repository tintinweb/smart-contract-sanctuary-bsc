// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "./HelperBase.sol";

contract Helper is HelperBase {
    constructor(address _coreAddress) {
        require(_coreAddress != address(0), "Helper/initialize/coreAddress-zero-address");
        aphCoreAddress = _coreAddress;
        manager = msg.sender;
    }

    function getInterestGained(address poolAddress, uint256 nftId)
        external
        view
        returns (uint256 tokenInterest, uint256 forwInterest)
    {
        if (IAPHCore(aphCoreAddress).poolToAsset(poolAddress) != address(0)) {
            (tokenInterest, forwInterest) = IAPHPool(poolAddress).claimableInterest(nftId);
        }
    }

    function getInterestAmountByDepositAmount(
        address poolAddress,
        uint256 depositAmount,
        uint128 daySecond
    ) external view returns (uint256 interestAmount) {
        if (IAPHCore(aphCoreAddress).poolToAsset(poolAddress) != address(0)) {
            uint256 interestRate = IAPHPool(poolAddress).getNextLendingInterest(0);
            interestAmount = ((depositAmount * interestRate * daySecond) /
                (WEI_PERCENT_UNIT * 365 * 86400));
        }
    }

    function getDepositAmountByInterestAmount(
        address poolAddress,
        uint256 interestAmount,
        uint128 daySecond
    ) external view returns (uint256 depositAmount) {
        if (IAPHCore(aphCoreAddress).poolToAsset(poolAddress) != address(0)) {
            uint256 interestRate = IAPHPool(poolAddress).getNextLendingInterest(0);
            depositAmount =
                (interestAmount * WEI_PERCENT_UNIT * 365 * 86400) /
                (interestRate * daySecond);
        }
    }

    function getActiveLoans(uint256 nftId)
        external
        view
        returns (uint256[] memory, CoreBase.Loan[] memory)
    {
        uint256 loanIndex = IAPHCore(aphCoreAddress).currentLoanIndex(nftId);
        CoreBase.Loan[] memory activeLoans = new CoreBase.Loan[](loanIndex);
        uint256[] memory activeLoanIds = new uint256[](loanIndex);

        uint256 count = 0;
        for (uint256 i = 1; i <= loanIndex; i++) {
            if (IAPHCore(aphCoreAddress).loanExts(nftId, i).active) {
                activeLoanIds[count] = i;
                activeLoans[count] = IAPHCore(aphCoreAddress).loans(nftId, i);
                count++;
            }
        }
        return (activeLoanIds, activeLoans);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../utils/Manager.sol";
import "../../interfaces/IAPHCore.sol";
import "../../interfaces/IAPHPool.sol";

contract HelperBase is Manager {
    address public aphCoreAddress;
    uint256 public WEI_UNIT = 1 ether;
    uint256 public WEI_PERCENT_UNIT = 100 ether;
}

// SPDX-License-Identifier: GPL-3.0
import "../../externalContract/openzeppelin/Context.sol";

pragma solidity 0.8.7;

contract Manager {
    address internal manager;
    event TransferManager(address, address);

    constructor() {}

    modifier onlyManager() {
        _onlyManager();
        _;
    }

    function getManager() external view returns (address) {
        return manager;
    }

    function _onlyManager() internal view {
        require(manager == msg.sender, "Manager/caller-is-not-the-manager");
    }

    function transferManager(address _address) public virtual onlyManager {
        require(_address != address(0), "Manager/new-manager-is-the-zero-address");
        _transferManager(_address);
    }

    function _transferManager(address _address) internal virtual {
        address oldManager = manager;
        manager = _address;
        emit TransferManager(oldManager, _address);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../src/core/CoreBase.sol";

interface IAPHCore {
    function settleForwInterest() external;

    function settleBorrowInterest(uint256 loanId, uint256 nftId) external;

    // External functions
    function getLoan(uint256 nftId, uint256 loanId) external view returns (CoreBase.Loan memory);

    function getLoanExt(uint256 nftId, uint256 loanId)
        external
        view
        returns (CoreBase.LoanExt memory);

    function isPool(address poolAddess) external view returns (bool);

    function getLoanConfig(address _borrowTokenAddress, address _collateralTokenAddress)
        external
        view
        returns (CoreBase.LoanConfig memory);

    function getActiveLoans(uint256 nftId) external view returns (CoreBase.Loan[] memory);

    function getPoolList() external view returns (address[] memory);

    function borrow(
        uint256 loanId,
        uint256 nftId,
        uint256 borrowAmount,
        address borrowTokenAddress,
        uint256 collateralSentAmount,
        address collateralTokenAddress,
        uint256 newOwedPerDay,
        uint256 interestRate
    ) external returns (CoreBase.Loan memory);

    function repay(
        uint256 loanId,
        uint256 nftId,
        uint256 repayAmount,
        bool isOnlyInterest
    ) external payable returns (uint256, uint256);

    function adjustCollateral(
        uint256 loanId,
        uint256 nftId,
        uint256 collateralAdjustAmount,
        bool isAdd
    ) external payable returns (CoreBase.Loan memory);

    function rollover(uint256 loanId, uint256 nftId) external returns (uint256, uint256);

    function liquidate(uint256 loanId, uint256 nftId)
        external
        returns (
            uint256,
            uint256,
            uint256
        );

    // function futureTrade(
    //     uint256 nftId,
    //     uint256 collateralSentAmount,
    //     address collateralTokenAddress,
    //     uint256 borrowAmount,
    //     address borrowTokenAddress,
    //     address swapTokenAddress,
    //     uint256 leverage,
    //     uint256 maxSlippage,
    //     bool isLong,
    //     uint256 newOwedPerDay
    // ) external returns (CoreBase.Position memory);

    // Getter functions
    function getLoanCurrentLTV(uint256 loanId, uint256 nftId) external view returns (uint256);

    function feeSpread() external view returns (uint256);

    function loanDuration() external view returns (uint256);

    function advancedInterestDuration() external view returns (uint256);

    function totalCollateralHold(address) external view returns (uint256);

    function poolStats(address) external view returns (CoreBase.PoolStat memory);

    function swapableToken(address) external view returns (bool);

    function poolToAsset(address) external view returns (address);

    function assetToPool(address) external view returns (address);

    function poolList(uint256) external view returns (address);

    function maxSwapSize() external view returns (uint256);

    function feesController() external view returns (address);

    function priceFeedAddress() external view returns (address);

    function routerAddress() external view returns (address);

    function forwDistributorAddress() external view returns (address);

    function membershipAddress() external view returns (address);

    function loans(uint256, uint256) external view returns (CoreBase.Loan memory);

    function loanExts(uint256, uint256) external view returns (CoreBase.LoanExt memory);

    function currentLoanIndex(uint256) external view returns (uint256);

    function loanConfigs(address, address) external view returns (CoreBase.LoanConfig memory);

    function forwDisPerBlock(address) external view returns (uint256);

    function lastSettleForw(address) external view returns (uint256);

    function isLoanLiquidable(uint256 nftId, uint256 loanId) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../src/pool/PoolBase.sol";
import "../src/core/CoreBase.sol";

interface IAPHPool {
    // /**
    //  * @dev Set NFT contract address
    //  * @param _address The address of NFT contract
    //  */
    // function setMembershipAddress(address _address) external;

    // /**
    //  * @dev Set interest vault contract address
    //  * @param _address The address of interest vault
    //  */
    // function setInterestVaultAddress(address _address) external;

    // /**
    //  * @dev Set Forward token address
    //  * @param _address The address of Forward token
    //  */
    // function setForwAddress(address _address) external;

    // /**
    //  * @dev Set asset goken address
    //  * @param _address The address of asset token
    //  */
    // function setTokenAddress(address _address) external;

    /**
     * @dev Deposit the asset token to the pool
     * @param nftId The nft tokenId that is holding the user's lending position
     * @param depositAmount The amount of token that are being transfered
     * @return mintedP The 'amount' of pToken (principal) minted
     * @return mintedItp The 'amount' of itpToken (asset token interest) minted
     * @return mintedIfp The 'amount' of ifpToken (Forward token interest) minted
     */
    function deposit(uint256 nftId, uint256 depositAmount)
        external
        payable
        returns (
            uint256 mintedP,
            uint256 mintedItp,
            uint256 mintedIfp
        );

    /**
     * @dev Withdraw the 'amount' of the principal (and claim all interest if user withdraw all of the principal)
     * @param nftId The nft tokenId that is holding the user's lending position
     * @param withdrawAmount The 'amount' of token that are being withdraw
     * @return The 'amount' of all tokens is withdraw and burnt
     */
    function withdraw(uint256 nftId, uint256 withdrawAmount)
        external
        returns (PoolBase.WithdrawResult memory);

    /**
     * @dev Claim the entire remaining of both asset token and Forward interest
     * @param nftId The nft tokenId that is holding the user's lending position
     * @return The 'amount' of all tokens is claimed and burnt
     */
    function claimAllInterest(uint256 nftId) external returns (PoolBase.WithdrawResult memory);

    /**
     * @dev Claim the 'amount' of Forward token interest
     * @param nftId The nft TokenId that is holding the user's lending position
     * @param claimAmount The 'amount' of asset token interest that are being claimed
     * @return The 'amount' of asset token interest is claimed and burnt
     */
    function claimTokenInterest(uint256 nftId, uint256 claimAmount)
        external
        returns (PoolBase.WithdrawResult memory);

    /**
     * @dev Claim the 'amount' of asset token interest
     * @param nftId The nft tokenId that is holding the user's lending position
     * @param claimAmount The 'amount' of Forward token interest that are being claimed
     * @return The 'amount' of Forward token interest is claimed and burnt
     */
    function claimForwInterest(uint256 nftId, uint256 claimAmount)
        external
        returns (PoolBase.WithdrawResult memory);

    function borrow(
        uint256 loanId,
        uint256 nftId,
        uint256 borrowAmount,
        uint256 collateralSentAmount,
        address collateralTokenAddress
    ) external payable returns (CoreBase.Loan memory);

    // function futureTrade(
    //     uint256 nftId,
    //     uint256 collateralSentAmount,
    //     address collateralTokenAddress,
    //     address swapTokenAddress,
    //     uint256 leverage,
    //     uint256 maxSlippage
    // ) external payable returns (CoreBase.Position memory);

    /**
     * @dev Set the rank in APHPool to equal the user's NFT rank
     * @param nftId The user's nft tokenId is used to activate the new rank
     * @return The new rank from user's nft
     */
    function activateRank(uint256 nftId) external returns (uint8);

    function getNextLendingInterest(uint256 depositAmount) external view returns (uint256);

    function getNextLendingForwInterest(uint256 depositAmount) external view returns (uint256);

    function getNextBorrowingInterest(uint256 borrowAmount) external view returns (uint256);

    /**
     * @dev Get interestRate and interestOwedPerDay from new borrow amount
     * @param borrowAmount The 'amount' of token borrow
     * @return The interestRate and interestOwedPerDay
     */
    function calculateInterest(uint256 borrowAmount) external view returns (uint256, uint256);

    /**
     * @dev Get asset interest token (itpToken) price
     * @return interest token price (pToken per itpToken)
     */
    function getInterestTokenPrice() external view returns (uint256);

    /**
     * @dev Get Forward interest token (ifpToken) price
     * @return Forward interest token price (pToken per ifpToken)
     */
    function getInterestForwPrice() external view returns (uint256);

    /**
     * @dev Get current supply of the asset token in the pool
     * @return The 'amount' of asset token in the pool
     */
    function currentSupply() external view returns (uint256);

    function utilizationRate() external view returns (uint256);

    function membershipAddress() external view returns (address);

    function interestVaultAddress() external view returns (address);

    function forwAddress() external view returns (address);

    function tokenAddress() external view returns (address);

    function stakePoolAddress() external view returns (address);

    function coreAddress() external view returns (address);

    function baseRate() external view returns (uint256);

    function w1() external view returns (uint256);

    function w2() external view returns (uint256);

    function w3() external view returns (uint256);

    function utilOptimise1() external view returns (uint256);

    function utilOptimise2() external view returns (uint256);

    function utilOptimise3() external view returns (uint256);

    function targetSupply() external view returns (uint256);

    // from PoolToken
    function balancePTokenOf(uint256 NFTId) external view returns (uint256);

    function balanceItpTokenOf(uint256 NFTId) external view returns (uint256);

    function balanceIfpTokenOf(uint256 NFTId) external view returns (uint256);

    function pTokenTotalSupply() external view returns (uint256);

    function itpTokenTotalSupply() external view returns (uint256);

    function ifpTokenTotalSupply() external view returns (uint256);

    function claimableInterest(uint256 nftId)
        external
        view
        returns (uint256 tokenInterest, uint256 forwInterest);
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

// import "../../externalContract/openzeppelin/Ownable.sol";
import "../../externalContract/openzeppelin/ReentrancyGuard.sol";
import "../../externalContract/openzeppelin/Initializable.sol";
import "../../externalContract/modify/SelectorPausable.sol";
import "../../externalContract/openzeppelin/Math.sol";

import "../../interfaces/IAPHPool.sol";
import "../../interfaces/IInterestVault.sol";
import "../../interfaces/IMembership.sol";
import "../../interfaces/IPriceFeed.sol";
import "../../interfaces/IRouter.sol";
import "../../interfaces/IStakePool.sol";

import "../utils/AssetHandler.sol";
import "../utils/Manager.sol";

contract CoreBase is AssetHandler, Manager, ReentrancyGuard, Initializable, SelectorPausable {
    struct NextForwDisPerBlock {
        uint256 amount;
        uint256 targetBlock;
    }
    struct Loan {
        address borrowTokenAddress;
        address collateralTokenAddress;
        uint256 borrowAmount;
        uint256 collateralAmount;
        uint256 owedPerDay;
        uint256 minInterest;
        uint256 interestOwed;
        uint256 interestPaid;
        uint256 bountyFee;
        uint64 rolloverTimestamp;
        uint64 lastSettleTimestamp;
    }

    struct LoanExt {
        bool active;
        uint64 startTimestamp;
        uint256 initialBorrowTokenPrice;
        uint256 initialCollateralTokenPrice;
    }

    struct LoanConfig {
        address borrowTokenAddress;
        address collateralTokenAddress;
        uint256 safeLTV;
        uint256 maxLTV;
        uint256 liquidationLTV;
        uint256 bountyFeeRate;
    }

    // struct Position {
    //     address swapTokenAddress;
    //     address borrowTokenAddress;
    //     address collateralTokenAddress;
    //     uint256 borrowAmount;
    //     uint256 collateralAmount;
    //     uint256 positionSize; // contract size after swapped
    //     uint256 inititalMargin;
    //     uint256 owedPerDay;
    //     uint256 interestOwed;
    //     uint256 interestPaid;
    //     uint64 lastSettleTimestamp;
    // }
    // struct PositionExt {
    //     bool active;
    //     bool long;
    //     bool short;
    //     uint64 startTimestamp;
    //     uint256 initialBorrowTokenPrice; // need?
    //     uint256 initialCollateralTokenPrice; // need?
    // }

    // struct PositionConfig {
    //     address borrowTokenAddress;
    //     address collateralTokenAddress;
    //     uint256 maxLeverage;
    //     uint256 maintenanceMargin;
    //     uint256 bountyFeeRate; // liquidation fee
    // }

    struct PoolStat {
        uint64 updatedTimestamp;
        uint256 totalBorrowAmount;
        uint256 borrowInterestOwedPerDay;
        uint256 totalInterestPaid;
    }

    // constant
    uint256 internal WEI_UNIT; //                                                           // 1e18
    uint256 internal WEI_PERCENT_UNIT; //                                                   // 1e20 (100*1e18 for calculating percent)

    // lending
    uint256 public feeSpread; //                                                            // spread for borrowing interest to lending interest                                                    // fee taken from lender interest payments (fee when protocol settles interest to pool)

    // borrowing
    uint256 public loanDuration; //                                                         // max days for borrowing with fix rate interest
    uint256 public advancedInterestDuration; //                                             // duration for calculating minimum interest
    mapping(address => mapping(address => LoanConfig)) public loanConfigs; //               // borrowToken => collateralToken => config
    mapping(uint256 => uint256) public currentLoanIndex; //                                 // nftId => currentLoanIndex
    mapping(uint256 => mapping(uint256 => Loan)) public loans; //                           // nftId => loanId => loan
    mapping(uint256 => mapping(uint256 => LoanExt)) public loanExts; //                     // nftId => loanId => loanExt (extension data)

    // futureTrading
    // uint256 public tradingFees; //                                                          // fee collect when use open or close position
    // mapping(address => mapping(address => PositionConfig)) public positionConfigs; //       // borrowToken => collateralToken => config
    // mapping(uint256 => uint256) public currentPositionIndex; //                             // nftId => currentPositionIndex
    // mapping(uint256 => mapping(uint256 => Position)) public positions; //                   // nftId => positionId => position
    // mapping(uint256 => mapping(uint256 => PositionExt)) public positionExts; //             // nftId => positionId => positionExt (extension data)

    // stat
    mapping(address => uint256) public totalCollateralHold; //                              // tokenAddress => total collateral amount
    mapping(address => PoolStat) public poolStats; //                                       // pool's address => borrowStat
    mapping(address => bool) public swapableToken; //                                       // check that token is allowed for swap
    mapping(address => address) public poolToAsset; //                                      // pool => underlying (token address)
    mapping(address => address) public assetToPool; //                                      // underlying => pool
    address[] public poolList; //                                                           // list of pool

    // forw distributor
    mapping(address => uint256) public forwDisPerBlock; //                                  // pool => forw distribute per block
    mapping(address => uint256) public lastSettleForw; //                                   // pool => lastest settle forward by pool
    mapping(address => NextForwDisPerBlock) public nextForwDisPerBlock; //                  // pool => next forw distribute per block

    uint256 public maxSwapSize; //                                                          // maximum supported swap size in ETH

    address public forwDistributorAddress; //                                               // address of vault which stores forw token for distribution
    address public forwAddress; //                                                          // forw token's address
    address public feesController; //                                                       // address target for withdrawing collected fees
    address public priceFeedAddress; //                                                     // address of price feed contract
    address public routerAddress; //                                                        // address of DEX contract
    address public membershipAddress; //                                                    // address of membership contract

    address public coreBorrowingAddress; //                                                 // address of borrowing logic contract
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "./Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(
            _initializing ? _isConstructor() : !_initialized,
            "Initializable: contract is already initialized"
        );

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../openzeppelin/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract SelectorPausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account` and `function selector`.
     */
    event Paused(address account, bytes4 functionSelector);

    /**
     * @dev Emitted when the pause is lifted by `account` and `function selector`.
     */
    event Unpaused(address account, bytes4 functionSelector);

    mapping(bytes4 => bool) private _isPaused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        //_isPaused = false;
    }

    /**
     * @dev Returns true if the function selected is paused, and false otherwise.
     */
    function isPaused(bytes4 _func) public view virtual returns (bool) {
        return _isPaused[_func];
    }

    /**
     * @dev Modifier to make a function callable only when the function selected is not paused.
     *
     * Requirements:
     *
     * - The function selected must not be paused.
     */
    modifier whenFuncNotPaused(bytes4 _func) {
        require(!_isPaused[_func], "Pausable/function-is-paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the function selected is paused.
     *
     * Requirements:
     *
     * - The function selected must be paused.
     */
    modifier whenFuncPaused(bytes4 _func) {
        require(_isPaused[_func], "Pausable/function-is-not-paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The function selected must not be paused.
     */
    function _pause(bytes4 _func) internal virtual whenFuncNotPaused(_func) {
        _isPaused[_func] = true;
        emit Paused(_msgSender(), _func);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The function selected must be paused.
     */
    function _unpause(bytes4 _func) internal virtual whenFuncPaused(_func) {
        _isPaused[_func] = false;
        emit Unpaused(_msgSender(), _func);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

interface IInterestVault {
    function claimableTokenInterest() external view returns (uint256);

    function heldTokenInterest() external view returns (uint256);

    function actualTokenInterestProfit() external view returns (uint256);

    function claimableForwInterest() external view returns (uint256);

    function cumulativeTokenInterestProfit() external view returns (uint256);

    function tokenAddress() external view returns (address);

    function forwAddress() external view returns (address);

    function protocolAddress() external view returns (address);

    function getTotalTokenInterest() external view returns (uint256);

    function getTotalForwInterest() external view returns (uint256);

    function settleInterest(
        uint256 _claimableTokenInterest,
        uint256 _heldTokenInterest,
        uint256 _claimableForwInterest
    ) external;

    function withdrawTokenInterest(
        uint256 claimable,
        uint256 bonus,
        uint256 profit
    ) external;

    function withdrawForwInterest(uint256 claimable) external;

    function setForwAddress(address _address) external;

    function approveInterestVault(address _core) external;

    function withdrawActualProfit(address receiver) external returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../externalContract/openzeppelin/IERC721Enumerable.sol";

interface IMembership is IERC721Enumerable {
    // External functions

    function getDefaultMembership(address owner) external view returns (uint256);

    function setDefaultMembership(uint256 tokenId) external;

    // function setNewPool(address newPool) external;

    function getPoolLists() external view returns (address[] memory);

    function mint(address to) external returns (uint256);

    // function setBaseURI(string memory baseTokenURI) external;

    function updateRank(uint256 tokenId, uint8 newRank) external;

    function usableTokenId(uint256 tokenId) external view returns (uint256);

    function getRank(uint256 tokenId) external view returns (uint8);

    function getRank(address pool, uint256 tokenId) external view returns (uint8);

    function currentPool() external view returns (address);

    function ownerOf(uint256) external view override returns (address);

    function getPreviousPool() external view returns (address);

    function setNewPool(address newPool) external;
}

// SPDX-License-Identifier: GPL-3.0
/**
 * Copyright 2017-2021, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.8.7;

interface IPriceFeed {
    function queryRate(address sourceToken, address destToken)
        external
        view
        returns (uint256 rate, uint256 precision);

    function queryPrecision(address sourceToken, address destToken)
        external
        view
        returns (uint256 precision);

    function queryReturn(
        address sourceToken,
        address destToken,
        uint256 sourceAmount
    ) external view returns (uint256 destAmount);

    // function checkPriceDisagreement(
    //     address sourceToken,
    //     address destToken,
    //     uint256 sourceAmount,
    //     uint256 destAmount,
    //     uint256 maxSlippage
    // ) external view returns (uint256 sourceToDestSwapRate);

    function amountInEth(address Token, uint256 amount) external view returns (uint256 ethAmount);

    function queryRateUSD(address token) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

interface IRouter {
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
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../src/stakepool/StakePoolBase.sol";

interface IStakePool {
    // Getter functions

    function rankInfos(uint8) external view returns (StakePoolBase.RankInfo memory);

    function stakeInfos(uint256) external view returns (StakePoolBase.StakeInfo memory);

    // External functions

    function stake(uint256 nftId, uint256 amount) external returns (StakePoolBase.StakeInfo memory);

    function unstake(uint256 nftId, uint256 amount)
        external
        returns (StakePoolBase.StakeInfo memory);

    function setRankInfo(
        uint8[] memory _rank,
        uint256[] memory _interestBonusLending,
        uint256[] memory _forwardBonusLending,
        uint256[] memory _minimumstakeAmount,
        uint256[] memory _maxLTVBonus
    ) external;

    function setPoolStartTimestamp(uint64 timestamp) external;

    function settleInterval() external view returns (uint256);

    function settlePeriod() external view returns (uint256);

    function poolStartTimestamp() external view returns (uint64);

    function rankLen() external view returns (uint256);

    function getStakeInfo(uint256 nftId) external view returns (StakePoolBase.StakeInfo memory);

    function getMaxLTVBonus(uint256 nftId) external view returns (uint256);

    function deprecateStakeInfo(uint256 nftId) external;

    function migrate(uint256 nftId) external returns (StakePoolBase.StakeInfo memory);

    function setNextPool(address _address) external;

    function nextPoolAddress() external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../interfaces/IWethERC20.sol";
import "../../externalContract/openzeppelin/IERC20.sol";

import "./WETHHandler.sol";

contract AssetHandler {
    address public wethAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    //address public constant wethToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c  // bsc (Wrapped BNB)

    address public wethHandler = 0x64493B5B3419e116F9fbE3ec41cF2E65Ef15cAB6;

    function _transferFromIn(
        address from,
        address to,
        address token,
        uint256 amount
    ) internal {
        require(amount != 0, "AssetHandler/amount-is-zero");

        if (token == wethAddress) {
            require(amount == msg.value, "AssetHandler/value-not-matched");
            IWethERC20(wethAddress).deposit{value: amount}();
            IWethERC20(wethAddress).transfer(to, amount);
        } else {
            IERC20(token).transferFrom(from, to, amount);
        }
    }

    function _transferFromOut(
        address from,
        address to,
        address token,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }
        if (token == wethAddress) {
            IWethERC20(wethAddress).transferFrom(from, wethHandler, amount);
            WETHHandler(payable(wethHandler)).withdrawETH(to, amount);
        } else {
            IERC20(token).transferFrom(from, to, amount);
        }
    }

    function _transferOut(
        address to,
        address token,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }
        if (token == wethAddress) {
            IWethERC20(wethAddress).transfer(wethHandler, amount);
            WETHHandler(payable(wethHandler)).withdrawETH(to, amount);
        } else {
            IERC20(token).transfer(to, amount);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../externalContract/openzeppelin/Address.sol";
import "../../externalContract/openzeppelin/ReentrancyGuard.sol";
import "../../externalContract/openzeppelin/Initializable.sol";
import "../../externalContract/modify/SelectorPausable.sol";

import "../utils/AssetHandler.sol";
import "../utils/Manager.sol";

contract PoolBase is AssetHandler, Manager, ReentrancyGuard, Initializable, SelectorPausable {
    struct Lend {
        uint8 rank;
        uint64 updatedTimestamp;
    }

    struct WithdrawResult {
        uint256 principle;
        uint256 tokenInterest;
        uint256 forwInterest;
        uint256 pTokenBurn;
        uint256 itpTokenBurn;
        uint256 ifpTokenBurn;
        uint256 tokenInterestBonus;
        uint256 forwInterestBonus;
    }

    uint256 internal WEI_UNIT; //               // 1e18
    uint256 internal WEI_PERCENT_UNIT; //       // 1e20 (100*1e18 for calculating percent)
    uint256 public BLOCK_TIME; //               // time between each block in seconds

    address public poolLendingAddress; //       // address of pool lending logic contract
    address public poolBorrowingAddress; //     // address of pool borrowing logic contract
    address public forwAddress; //              // forw token's address
    address public membershipAddress; //        // address of membership contract
    address public interestVaultAddress; //     // address of interestVault contract
    address public tokenAddress; //             // address of token which pool allows to lend
    address public coreAddress; //              // address of APHCore contract
    mapping(uint256 => Lend) lenders; //        // map nftId => rank

    uint256 internal initialItpPrice;
    uint256 internal initialIfpPrice;

    // borrowing interest params
    uint256 public lambda; //                   // constant use for weight forw token in iftPrice

    uint256 public baseRate; //                 // initial borrowing rate at util rate 0%
    uint256 public w1; //                       // slope which represent interest in each period of graph
    uint256 public w2; //                       // slope which represent interest in each period of graph
    uint256 public w3; //                       // slope which represent interest in each period of graph

    uint256 public utilOptimise1; //            // target for utilRate to change the slope to w1
    uint256 public utilOptimise2; //            // target for utilRate to change the slope to w2
    uint256 public utilOptimise3; //            // target for utilRate to change the slope to w3

    uint256 public targetSupply; //             // weighting factor to proportional reduce utilOptimse vaule if total lending is less than targetSupply
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "./IWeth.sol";
import "../externalContract/openzeppelin/IERC20.sol";

interface IWethERC20 is IWeth, IERC20 {}

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../interfaces/IWeth.sol";

contract WETHHandler {
    address public constant wethAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    //address public constant wethToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c  // bsc (Wrapped BNB)

    function withdrawETH(address to, uint256 amount) external {
        IWeth(wethAddress).withdraw(amount);
        (bool success, ) = to.call{value: amount}(new bytes(0));
        require(success, "WETHHandler/withdraw-failed-1");
    }

    fallback() external {
        revert("WETHHandler/fallback function not allowed");
    }

    receive() external payable {}
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

interface IWeth {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../externalContract/openzeppelin/Ownable.sol";
import "../../externalContract/openzeppelin/ReentrancyGuard.sol";
import "../../externalContract/modify/SelectorPausable.sol";
import "../utils/AssetHandler.sol";

contract StakePoolBase is AssetHandler, Ownable, ReentrancyGuard, SelectorPausable {
    struct StakeInfo {
        uint256 stakeBalance; //                                 // Staking forw token amount
        uint256 claimableAmount; //                              // Claimable forw token amount
        uint64 startTimestamp; //                                // Timestamo that user start staking
        uint64 endTimestamp; //                                  // Timestamp that user can withdraw all staking balance
        uint64 lastSettleTimestamp; //                           // Timestamp that represent a lastest update claimable amount of each user
        uint256[] payPattern; //                                 // Part of nft stakeInfo for record withdrawable of user that pass each a quater of settlePeriod
    }

    struct RankInfo {
        uint256 interestBonusLending; //                          // Bonus of lending of each membership tier (lending token bonus)
        uint256 forwardBonusLending; //                           // Bonus of lending of each membership tier (FORW token bonus)
        uint256 minimumStakeAmount; //                            // Minimum forw token staking to claim this rank
        uint256 maxLTVBonus; //                                   // Addition LTV which added during borrowing token
    }

    address public membershipAddress; //                         // Address of membership contract
    address public nextPoolAddress; //                           // Address of new migration stakpool
    address public stakeVaultAddress; //                         // Address of stake vault that use for collect a staking FORW token
    address public forwAddress; //                               // Address of FORW token
    uint8 public rankLen; //                                     // Number of membership rank
    uint64 public poolStartTimestamp; //                         // Timestamp that record poolstart time use for calculate withdrawable balance
    uint256 public settleInterval; //                            // Duration that stake pool allow sender to withdraw a quarter of staking balance
    uint256 public settlePeriod; //                              // Period that stake pool allow sender to withdraw all staking balance
    mapping(uint256 => StakeInfo) public stakeInfos; //          // Object that represent a status of staking of user
    mapping(uint8 => RankInfo) public rankInfos; //              // Represent array of a tier of membership mapping minimum staking balance
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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