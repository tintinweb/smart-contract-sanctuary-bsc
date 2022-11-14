/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: GPL-3.0-only

// Sources flattened with hardhat v2.10.0 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]



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


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]



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


// File contracts/contracts/interfaces/IAuthorization.sol


pragma solidity 0.8.6;

interface IAuthorization {
    function owner() external view returns (address owner);
    function newOwner() external view returns (address newOwner);

    function isPermitted(address) external view returns (bool isPermitted);

    event Authorize(address user);
    event Deauthorize(address user);
    event StartOwnershipTransfer(address user);
    event TransferOwnership(address user);

    function transferOwnership(address newOwner_) external;
    function takeOwnership() external;
    function permit(address user) external;
    function deny(address user) external;
}


// File contracts/contracts/interfaces/IOSWAP_VotingExecutorManager.sol


pragma solidity 0.8.6;
interface IOSWAP_VotingExecutorManager {
    function govToken() external view returns (IERC20 govToken);
    function votingExecutor(uint256 index) external view returns (address);
    function votingExecutorInv(address) external view returns (uint256 votingExecutorInv);
    function isVotingExecutor(address) external view returns (bool isVotingExecutor);
    function trollRegistry() external view returns (address trollRegistry);
    function newVotingExecutorManager() external view returns (IOSWAP_VotingExecutorManager newVotingExecutorManager);

    function votingExecutorLength() external view returns (uint256);
    function setVotingExecutor(address _votingExecutor, bool _bool) external;
}


// File contracts/contracts/interfaces/IOSWAP_ConfigStore.sol


pragma solidity 0.8.6;
interface IOSWAP_ConfigStore is IAuthorization {

    event ParamSet1(bytes32 indexed name, bytes32 value1);
    event ParamSet2(bytes32 indexed name, bytes32 value1, bytes32 value2);
    event UpdateVotingExecutorManager(IOSWAP_VotingExecutorManager newVotingExecutorManager);
    event Upgrade(IOSWAP_ConfigStore newConfigStore);

    function govToken() external view returns (IERC20 govToken);
    function votingExecutorManager() external view returns (IOSWAP_VotingExecutorManager votingExecutorManager);
    function swapPolicy() external view returns (IOSWAP_SwapPolicy swapPolicy);

    function priceOracle(IERC20 token) external view returns (address priceOracle); // priceOracle[token] = oracle
    function baseFee(IERC20 asset) external view returns (uint256 baseFee);
    function isApprovedProxy(address proxy) external view returns (bool isApprovedProxy);
    function lpWithdrawlDelay() external view returns (uint256 lpWithdrawlDelay);
    function transactionsGap() external view returns (uint256 transactionsGap); // side chain
    function superTrollMinCount() external view returns (uint256 superTrollMinCount); // side chain
    function generalTrollMinCount() external view returns (uint256 generalTrollMinCount); // side chain
    function transactionFee() external view returns (uint256 transactionFee);
    function router() external view returns (address router);
    function rebalancer() external view returns (address rebalancer);
    function newConfigStore() external view returns (IOSWAP_ConfigStore newConfigStore);
    function feeTo() external view returns (address feeTo);
    struct Params {
        IOSWAP_VotingExecutorManager votingExecutorManager;
        IOSWAP_SwapPolicy swapPolicy;
        uint256 lpWithdrawlDelay;
        uint256 transactionsGap;
        uint256 superTrollMinCount;
        uint256 generalTrollMinCount;
        uint256 minStakePeriod;
        uint256 transactionFee;
        address router;
        address rebalancer;
        address wrapper;
        IERC20[] asset;
        uint256[] baseFee;
    }

    function initAddress(IOSWAP_VotingExecutorManager _votingExecutorManager) external;
    function upgrade(IOSWAP_ConfigStore _configStore) external;
    function updateVotingExecutorManager() external;
    function setMinStakePeriod(uint256 _minStakePeriod) external;
    function setConfigAddress(bytes32 name, bytes32 _value) external;
    function setConfig(bytes32 name, bytes32 _value) external;
    function setConfig2(bytes32 name, bytes32 value1, bytes32 value2) external;
    function setOracle(IERC20 asset, address oracle) external;
    function setSwapPolicy(IOSWAP_SwapPolicy _swapPolicy) external;
    function getSignatureVerificationParams() external view returns (uint256,uint256,uint256);
    function getBridgeParams(IERC20 asset) external view returns (IOSWAP_SwapPolicy,address,address,address,uint256,uint256);
    function getRebalanceParams(IERC20 asset) external view returns (address rebalancer, address govTokenOracle, address assetTokenOracle);
}


// File contracts/contracts/interfaces/IOSWAP_SideChainTrollRegistry.sol


pragma solidity 0.8.6;
interface IOSWAP_SideChainTrollRegistry is IAuthorization, IOSWAP_VotingExecutorManager {

    event Shutdown(address indexed account);
    event Resume();

    event AddTroll(address indexed troll, uint256 indexed trollProfileIndex, bool isSuperTroll);
    event UpdateTroll(uint256 indexed trollProfileIndex, address indexed troll);
    event RemoveTroll(uint256 indexed trollProfileIndex);
    event DelistTroll(uint256 indexed trollProfileIndex);
    event LockSuperTroll(uint256 indexed trollProfileIndex, address lockedBy);
    event LockGeneralTroll(uint256 indexed trollProfileIndex, address lockedBy);
    event UnlockSuperTroll(uint256 indexed trollProfileIndex, bool unlock, address bridgeVault, uint256 penalty);
    event UnlockGeneralTroll(uint256 indexed trollProfileIndex);
    event UpdateConfigStore(IOSWAP_ConfigStore newConfigStore);
    event NewVault(IERC20 indexed token, IOSWAP_BridgeVault indexed vault);
    event SetVotingExecutor(address newVotingExecutor, bool isActive);
    event Upgrade(address newTrollRegistry);

    enum TrollType {NotSpecified, SuperTroll, GeneralTroll, BlockedSuperTroll, BlockedGeneralTroll}

    struct TrollProfile {
        address troll;
        TrollType trollType;
    }
    // function govToken() external view returns (IERC20 govToken);
    function configStore() external view returns (IOSWAP_ConfigStore configStore);
    // function votingExecutor(uint256 index) external view returns (address);
    // function votingExecutorInv(address) external view returns (uint256 votingExecutorInv);
    // function isVotingExecutor(address) external view returns (bool isVotingExecutor);
    function trollProfiles(uint256 trollProfileIndex) external view returns (TrollProfile memory trollProfiles); // trollProfiles[trollProfileIndex] = {troll, trollType}
    function trollProfileInv(address troll) external view returns (uint256 trollProfileInv); // trollProfileInv[troll] = trollProfileIndex
    function superTrollCount() external view returns (uint256 superTrollCount);
    function generalTrollCount() external view returns (uint256 generalTrollCount);
    function transactionsCount() external view returns (uint256 transactionsCount);
    function lastTrollTxCount(address troll) external view returns (uint256 lastTrollTxCount); // lastTrollTxCount[troll]
    function usedNonce(uint256) external view returns (bool usedNonce);

    function vaultToken(uint256 index) external view returns (IERC20);
    function vaults(IERC20) external view returns (IOSWAP_BridgeVault vaults); // vaultRegistries[token] = vault

    function newTrollRegistry() external view returns (address newTrollRegistry);

    function initAddress(address _votingExecutor, IERC20[] calldata tokens, IOSWAP_BridgeVault[] calldata _vaults) external;

    /*
     * upgrade
     */
    function updateConfigStore() external;
    function upgrade(address _trollRegistry) external;
    function upgradeByAdmin(address _trollRegistry) external;

    /*
     * pause / resume
     */
    function paused() external view returns (bool);
    function shutdownByAdmin() external;
    function shutdownByVoting() external;
    function resume() external;

    // function votingExecutorLength() external view returns (uint256);
    // function setVotingExecutor(address _votingExecutor, bool _bool) external;

    function vaultTokenLength() external view returns (uint256);
    function allVaultToken() external view returns (IERC20[] memory);

    function isSuperTroll(address troll, bool returnFalseIfBlocked) external view returns (bool);
    function isSuperTrollByIndex(uint256 trollProfileIndex, bool returnFalseIfBlocked) external view returns (bool);
    function isGeneralTroll(address troll, bool returnFalseIfBlocked) external view returns (bool);
    function isGeneralTrollByIndex(uint256 trollProfileIndex, bool returnFalseIfBlocked) external view returns (bool);

    function verifySignatures(address msgSender, bytes[] calldata signatures, bytes32 paramsHash, uint256 _nonce) external;
    function hashAddTroll(uint256 trollProfileIndex, address troll, bool _isSuperTroll, uint256 _nonce) external view returns (bytes32);
    function hashUpdateTroll(uint256 trollProfileIndex, address newTroll, uint256 _nonce) external view returns (bytes32);
    function hashRemoveTroll(uint256 trollProfileIndex, uint256 _nonce) external view returns (bytes32);
    function hashUnlockTroll(uint256 trollProfileIndex, bool unlock, address[] memory vaultRegistry, uint256[] memory penalty, uint256 _nonce) external view returns (bytes32);
    function hashRegisterVault(IERC20 token, IOSWAP_BridgeVault vaultRegistry, uint256 _nonce) external view returns (bytes32);

    function addTroll(bytes[] calldata signatures, uint256 trollProfileIndex, address troll, bool _isSuperTroll, uint256 _nonce) external;
    function updateTroll(bytes[] calldata signatures, uint256 trollProfileIndex, address newTroll, uint256 _nonce) external;
    function removeTroll(bytes[] calldata signatures, uint256 trollProfileIndex, uint256 _nonce) external;

    function lockSuperTroll(uint256 trollProfileIndex) external;
    function unlockSuperTroll(bytes[] calldata signatures, uint256 trollProfileIndex, bool unlock, address[] calldata vaultRegistry, uint256[] calldata penalty, uint256 _nonce) external;
    function lockGeneralTroll(uint256 trollProfileIndex) external;
    function unlockGeneralTroll(bytes[] calldata signatures, uint256 trollProfileIndex, uint256 _nonce) external;

    function registerVault(bytes[] calldata signatures, IERC20 token, IOSWAP_BridgeVault vault, uint256 _nonce) external;
}


// File contracts/contracts/interfaces/IOSWAP_BridgeVaultTrollRegistry.sol


pragma solidity 0.8.6;
interface IOSWAP_BridgeVaultTrollRegistry {

    event Stake(address indexed backer, uint256 indexed trollProfileIndex, uint256 amount, uint256 shares, uint256 backerBalance, uint256 trollBalance, uint256 totalShares);
    event UnstakeRequest(address indexed backer, uint256 indexed trollProfileIndex, uint256 shares, uint256 backerBalance);
    event Unstake(address indexed backer, uint256 indexed trollProfileIndex, uint256 amount, uint256 shares, uint256 approvalDecrement, uint256 trollBalance, uint256 totalShares);
    event UnstakeApproval(address indexed backer, address indexed msgSender, uint256[] signers, uint256 shares);
    event UpdateConfigStore(IOSWAP_ConfigStore newConfigStore);
    event UpdateTrollRegistry(IOSWAP_SideChainTrollRegistry newTrollRegistry);
    event Penalty(uint256 indexed trollProfileIndex, uint256 amount);

    struct Stakes{
        uint256 trollProfileIndex;
        uint256 shares;
        uint256 pendingWithdrawal;
        uint256 approvedWithdrawal;
    }
    // struct StakedBy{
    //     address backer;
    //     uint256 index;
    // }
    function govToken() external view returns (IERC20 govToken);
    function configStore() external view returns (IOSWAP_ConfigStore configStore);
    function trollRegistry() external view returns (IOSWAP_SideChainTrollRegistry trollRegistry);
    function backerStakes(address backer) external view returns (Stakes memory backerStakes); // backerStakes[bakcer] = Stakes;
    function stakedBy(uint256 trollProfileIndex, uint256 index) external view returns (address stakedBy); // stakedBy[trollProfileIndex][idx] = backer;
    function stakedByInv(uint256 trollProfileIndex, address backer) external view returns (uint256 stakedByInv); // stakedByInv[trollProfileIndex][backer] = stakedBy_idx;
    function trollStakesBalances(uint256 trollProfileIndex) external view returns (uint256 trollStakesBalances); // trollStakesBalances[trollProfileIndex] = balance
    function trollStakesTotalShares(uint256 trollProfileIndex) external view returns (uint256 trollStakesTotalShares); // trollStakesTotalShares[trollProfileIndex] = shares
    function transactionsCount() external view returns (uint256 transactionsCount);
    function lastTrollTxCount(address troll) external view returns (uint256 lastTrollTxCount); // lastTrollTxCount[troll]
    function usedNonce(bytes32 nonce) external view returns (bool used);

    function updateConfigStore() external;
    function updateTrollRegistry() external;

    function getBackers(uint256 trollProfileIndex) external view returns (address[] memory backers);
    function stakedByLength(uint256 trollProfileIndex) external view returns (uint256 length);

    function stake(uint256 trollProfileIndex, uint256 amount) external returns (uint256 shares);

    function maxWithdrawal(address backer) external view returns (uint256 amount);
    function hashUnstakeRequest(address backer, uint256 trollProfileIndex, uint256 shares, uint256 _nonce) external view returns (bytes32 hash);
    function unstakeRequest(uint256 shares) external;
    function unstakeApprove(bytes[] calldata signatures, address backer, uint256 trollProfileIndex, uint256 shares, uint256 _nonce) external;
    function unstake(address backer, uint256 shares) external;

    function verifyStakedValue(address msgSender, bytes[] calldata signatures, bytes32 paramsHash) external returns (uint256 superTrollCount, uint totalStake, uint256[] memory signers);

    function penalizeSuperTroll(uint256 trollProfileIndex, uint256 amount) external;
}


// File contracts/contracts/interfaces/IOSWAP_BridgeVault.sol


pragma solidity 0.8.6;
interface IOSWAP_BridgeVault is IERC20, IERC20Metadata {

    event AddLiquidity(address indexed provider, uint256 amount, uint256 mintAmount, uint256 newBalance, uint256 newLpAssetBalance);
    event RemoveLiquidityRequest(address indexed provider, uint256 amount, uint256 burnAmount, uint256 newBalance, uint256 newLpAssetBalance, uint256 newPendingWithdrawal);
    event RemoveLiquidity(address indexed provider, uint256 amount, uint256 newPendingWithdrawal);
    event NewOrder(uint256 indexed orderId, address indexed owner, Order order, int256 newImbalance);
    event WithdrawUnexecutedOrder(address indexed owner, uint256 orderId, int256 newImbalance);
    event AmendOrderRequest(uint256 indexed orderId, uint256 indexed amendment, Order order);
    event RequestCancelOrder(address indexed owner, uint256 indexed sourceChainId, uint256 indexed orderId, bytes32 hashedOrderId);
    event OrderCanceled(uint256 indexed orderId, address indexed sender, uint256[] signers, bool canceledByOrderOwner, int256 newImbalance, uint256 newProtocolFeeBalance);
    event Swap(uint256 indexed orderId, address indexed sender, uint256[] signers, address owner, uint256 amendment, Order order, uint256 outAmount, int256 newImbalance, uint256 newLpAssetBalance, uint256 newProtocolFeeBalance);
    event VoidOrder(bytes32 indexed orderId, address indexed sender, uint256[] signers);
    event UpdateConfigStore(IOSWAP_ConfigStore newConfigStore);
    event UpdateTrollRegistry(IOSWAP_SideChainTrollRegistry newTrollRegistry);
    event Rebalance(address rebalancer, int256 amount, int256 newImbalance);
    event WithdrawlTrollFee(address feeTo, uint256 amount, uint256 newProtocolFeeBalance);
    event Sync(uint256 excess, uint256 newProtocolFeeBalance);

    // pending must be the init status which have value of 0
    enum OrderStatus{NotSpecified, Pending, Executed, RequestCancel, RefundApproved, Cancelled, RequestAmend}

    function trollRegistry() external view returns (IOSWAP_SideChainTrollRegistry trollRegistry);
    function govToken() external view returns (IERC20 govToken);
    function asset() external view returns (IERC20 asset);
    function assetDecimalsScale() external view returns (int8 assetDecimalsScale);
    function configStore() external view returns (IOSWAP_ConfigStore configStore);
    function vaultRegistry() external view returns (IOSWAP_BridgeVaultTrollRegistry vaultRegistry);
    function imbalance() external view returns (int256 imbalance);
    function lpAssetBalance() external view returns (uint256 lpAssetBalance);
    function totalPendingWithdrawal() external view returns (uint256 totalPendingWithdrawal);
    function protocolFeeBalance() external view returns (uint256 protocolFeeBalance);
    function pendingWithdrawalAmount(address liquidityProvider) external view returns (uint256 pendingWithdrawalAmount);
    function pendingWithdrawalTimeout(address liquidityProvider) external view returns (uint256 pendingWithdrawalTimeout);

    // source chain
    struct Order {
        uint256 peerChain;
        uint256 inAmount;
        address outToken;
        uint256 minOutAmount;
        address to;
        uint256 expire;
    }
    // source chain
    function orders(uint256 orderId) external view returns (uint256 peerChain, uint256 inAmount, address outToken, uint256 minOutAmount, address to, uint256 expire);
    function orderAmendments(uint256 orderId, uint256 amendment) external view returns (uint256 peerChain, uint256 inAmount, address outToken, uint256 minOutAmount, address to, uint256 expire);
    function orderOwner(uint256 orderId) external view returns (address orderOwner);
    function orderStatus(uint256 orderId) external view returns (OrderStatus orderStatus);
    function orderRefunds(uint256 orderId) external view returns (uint256 orderRefunds);
    // target chain
    function swapOrderStatus(bytes32 orderHash) external view returns (OrderStatus swapOrderStatus);

    function initAddress(IOSWAP_BridgeVaultTrollRegistry _vaultRegistry) external;
    function updateConfigStore() external;
    function updateTrollRegistry() external;
    function ordersLength() external view returns (uint256 length);
    function orderAmendmentsLength(uint256 orderId) external view returns (uint256 length);

    function getOrders(uint256 start, uint256 length) external view returns (Order[] memory list);

    function lastKnownBalance() external view returns (uint256 balance);

    /*
     * signatures related functions
     */
    function getChainId() external view returns (uint256 chainId);
    function hashCancelOrderParams(uint256 orderId, bool canceledByOrderOwner, uint256 protocolFee) external view returns (bytes32);
    function hashVoidOrderParams(bytes32 orderId) external view returns (bytes32);
    function hashSwapParams(
        bytes32 orderId,
        uint256 amendment,
        Order calldata order,
        uint256 protocolFee,
        address[] calldata pair
    ) external view returns (bytes32);
    function hashWithdrawParams(address _owner, uint256 amount, uint256 _nonce) external view returns (bytes32);
    function hashOrder(address _owner, uint256 sourceChainId, uint256 orderId) external view returns (bytes32);

    /*
     * functions called by LP
     */
    function addLiquidity(uint256 amount) external;
    function removeLiquidityRequest(uint256 lpTokenAmount) external;
    function removeLiquidity(address provider, uint256 assetAmount) external;

    /*
     *  functions called by traders on source chain
     */
    function newOrder(Order memory order) external returns (uint256 orderId);
    function withdrawUnexecutedOrder(uint256 orderId) external;
    function requestAmendOrder(uint256 orderId, Order calldata order) external;

    /*
     *  functions called by traders on target chain
     */
    function requestCancelOrder(uint256 sourceChainId, uint256 orderId) external;

    /*
     * troll helper functions
     */
    function assetPriceAgainstGovToken(address govTokenOracle, address assetTokenOracle) external view returns (uint256 price);

    /*
     *  functions called by trolls on source chain
     */
    function cancelOrder(bytes[] calldata signatures, uint256 orderId, bool canceledByOrderOwner, uint256 protocolFee) external;

    /*
     *  functions called by trolls on target chain
     */
    function swap(
        bytes[] calldata signatures,
        address _owner,
        uint256 _orderId,
        uint256 amendment,
        uint256 protocolFee,
        address[] calldata pair,
        Order calldata order
    ) external returns (uint256 amount);
    function voidOrder(bytes[] calldata signatures, bytes32 orderId) external;

    function newOrderFromRouter(Order calldata order, address trader) external returns (uint256 orderId);

    /*
     * rebalancing
     */
    function rebalancerDeposit(uint256 assetAmount) external;
    function rebalancerWithdraw(bytes[] calldata signatures, uint256 assetAmount, uint256 _nonce) external;

    /*
     * anyone can call
     */
    function withdrawlTrollFee(uint256 amount) external;
    function sync() external;
}


// File contracts/contracts/interfaces/IOSWAP_SwapPolicy.sol


pragma solidity >= 0.8.6;
interface IOSWAP_SwapPolicy {

    function allowToSwap(IOSWAP_BridgeVault.Order calldata order) external view returns (bool isAllow);
}


// File contracts/contracts/Authorization.sol


pragma solidity 0.8.6;

contract Authorization {
    address public owner;
    address public newOwner;
    mapping(address => bool) public isPermitted;
    event Authorize(address user);
    event Deauthorize(address user);
    event StartOwnershipTransfer(address user);
    event TransferOwnership(address user);
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier auth {
        require(isPermitted[msg.sender], "Action performed by unauthorized address.");
        _;
    }
    function transferOwnership(address newOwner_) external onlyOwner {
        newOwner = newOwner_;
        emit StartOwnershipTransfer(newOwner_);
    }
    function takeOwnership() external {
        require(msg.sender == newOwner, "Action performed by unauthorized address.");
        owner = newOwner;
        newOwner = address(0x0000000000000000000000000000000000000000);
        emit TransferOwnership(owner);
    }
    function permit(address user) external onlyOwner {
        isPermitted[user] = true;
        emit Authorize(user);
    }
    function deny(address user) external onlyOwner {
        isPermitted[user] = false;
        emit Deauthorize(user);
    }
}


// File contracts/contracts/OSWAP_ConfigStore.sol


pragma solidity 0.8.6;
contract OSWAP_ConfigStore is Authorization {

    modifier onlyVoting() {
        require(votingExecutorManager.isVotingExecutor(msg.sender), "OSWAP: Not from voting");
        _;
    }

    event ParamSet1(bytes32 indexed name, bytes32 value1);
    event ParamSet2(bytes32 indexed name, bytes32 value1, bytes32 value2);
    event UpdateVotingExecutorManager(IOSWAP_VotingExecutorManager newVotingExecutorManager);
    event Upgrade(OSWAP_ConfigStore newConfigStore);

    IERC20 public immutable govToken;
    IOSWAP_VotingExecutorManager public votingExecutorManager;
    IOSWAP_SwapPolicy public swapPolicy;

    // side chain
    mapping(IERC20 => address) public priceOracle; // priceOracle[token] = oracle
    mapping(IERC20 => uint256) public baseFee;
    mapping(address => bool) public isApprovedProxy;
    uint256 public lpWithdrawlDelay;
    uint256 public transactionsGap;
    uint256 public superTrollMinCount;
    uint256 public generalTrollMinCount;
    uint256 public transactionFee;
    address public router;
    address public rebalancer;
    address public feeTo;

    OSWAP_ConfigStore public newConfigStore;

    struct Params {
        IERC20 govToken;
        IOSWAP_SwapPolicy swapPolicy;
        uint256 lpWithdrawlDelay;
        uint256 transactionsGap;
        uint256 superTrollMinCount;
        uint256 generalTrollMinCount;
        uint256 transactionFee;
        address router;
        address rebalancer;
        address feeTo;
        address wrapper;
        IERC20[] asset;
        uint256[] baseFee;
    }
    constructor(
        Params memory params
    ) {
        govToken = params.govToken;
        swapPolicy = params.swapPolicy;
        lpWithdrawlDelay = params.lpWithdrawlDelay;
        transactionsGap = params.transactionsGap;
        superTrollMinCount = params.superTrollMinCount;
        generalTrollMinCount = params.generalTrollMinCount;
        transactionFee = params.transactionFee;
        router = params.router;
        rebalancer = params.rebalancer;
        feeTo = params.feeTo;
        require(params.asset.length == params.baseFee.length);
        for (uint256 i ; i < params.asset.length ; i++){
            baseFee[params.asset[i]] = params.baseFee[i];
        }
        if (params.wrapper != address(0))
            isApprovedProxy[params.wrapper] = true;
        isPermitted[msg.sender] = true;
    }
    function initAddress(IOSWAP_VotingExecutorManager _votingExecutorManager) external onlyOwner {
        require(address(_votingExecutorManager) != address(0), "null address");
        require(address(votingExecutorManager) == address(0), "already init");
        votingExecutorManager = _votingExecutorManager;
    }

    function upgrade(OSWAP_ConfigStore _configStore) external onlyVoting {
        // require(address(_configStore) != address(0), "already set");
        newConfigStore = _configStore;
        emit Upgrade(newConfigStore);
    }
    function updateVotingExecutorManager() external {
        IOSWAP_VotingExecutorManager _votingExecutorManager = votingExecutorManager.newVotingExecutorManager();
        require(address(_votingExecutorManager) != address(0), "Invalid config store");
        votingExecutorManager = _votingExecutorManager;
        emit UpdateVotingExecutorManager(votingExecutorManager);
    }

    // side chain
    function setConfigAddress(bytes32 name, bytes32 _value) external onlyVoting {
        address value = address(bytes20(_value));

        if (name == "router") {
            router = value;
        } else if (name == "rebalancer") {
            rebalancer = value;
        } else if (name == "feeTo") {
            feeTo = value;
        } else {
            revert("Invalid config");
        }
        emit ParamSet1(name, _value);
    }
    function setConfig(bytes32 name, bytes32 _value) external onlyVoting {
        uint256 value = uint256(_value);
        if (name == "transactionsGap") {
            transactionsGap = value;
        } else if (name == "transactionFee") {
            transactionFee = value;
        } else if (name == "superTrollMinCount") {
            superTrollMinCount = value;
        } else if (name == "generalTrollMinCount") {
            generalTrollMinCount = value;
        } else if (name == "lpWithdrawlDelay") {
            lpWithdrawlDelay = value;
        } else {
            revert("Invalid config");
        }
        emit ParamSet1(name, _value);
    }
    function setConfig2(bytes32 name, bytes32 value1, bytes32 value2) external onlyVoting {
        if (name == "baseFee") {
            baseFee[IERC20(address(bytes20(value1)))] = uint256(value2);
        } else if (name == "isApprovedProxy") {
            isApprovedProxy[address(bytes20(value1))] = uint256(value2)==1;
        } else {
            revert("Invalid config");
        }
        emit ParamSet2(name, value1, value2);
    }
    function setOracle(IERC20 asset, address oracle) external auth {
        priceOracle[asset] = oracle;
        emit ParamSet2("oracle", bytes20(address(asset)), bytes20(oracle));
    }
    function setSwapPolicy(IOSWAP_SwapPolicy _swapPolicy) external auth {
        swapPolicy = _swapPolicy;
        emit ParamSet1("swapPolicy", bytes32(bytes20(address(_swapPolicy))));
    }
    function getSignatureVerificationParams() external view returns (uint256,uint256,uint256) {
        return (generalTrollMinCount, superTrollMinCount, transactionsGap);
    }
    function getBridgeParams(IERC20 asset) external view returns (IOSWAP_SwapPolicy,address,address,address,uint256,uint256) {
        return (swapPolicy, router, priceOracle[govToken], priceOracle[asset], baseFee[asset], transactionFee);
    }
    function getRebalanceParams(IERC20 asset) external view returns (address,address,address) {
        return (rebalancer, priceOracle[govToken], priceOracle[asset]);
    }
}


// File contracts/OSWAP_ChainRegistry.sol


pragma solidity 0.8.6;
contract OSWAP_ChainRegistry {

    modifier onlyVoting() {
        require(votingExecutorManager.isVotingExecutor(msg.sender), "OSWAP: Not from voting");
        _;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    enum Status {NotExists, Active, Inactive}

    struct Vault {
        address token;
        address vaultRegistry; // OSWAP_BridgeVaultTrollRegistry
        address bridgeVault; // OSWAP_BridgeVault
    }

    event NewChain(uint256 indexed chainId, Status status, IERC20 govToken);
    event UpdateStatus(uint256 indexed chainId, Status status);
    event UpdateMainChainAddress(bytes32 indexed contractName, address _address);
    event UpdateAddress(uint256 indexed chainId, bytes32 indexed contractName, address _address);
    event UpdateConfigStore(uint256 indexed chainId, OSWAP_ConfigStore _address);
    event UpdateVault(uint256 indexed index, uint256 indexed chainId, Vault vault);

    address owner;

    IOSWAP_VotingExecutorManager public votingExecutorManager;

    uint256[] public chains; // chains[idx] = chainId
    mapping(uint256 => Status) public status; // status[chainId] = {NotExists, Active, Inactive}
    mapping(bytes32 => address) public mainChainContractAddress; // mainChainContractAddress[contractName] = contractAddress
    mapping(uint256 => mapping(bytes32 => address)) public sideChainContractAddress; //sideChainContractAddress[chainId][contractName] = contractAddress
    mapping(uint256 => IERC20) public govToken; // govToken[chainId] = govToken
    // the source-of-truth configStore of a sidechain on mainchain
    // the configStore on a sidechain should be a replica of this
    mapping(uint256 => OSWAP_ConfigStore) public configStore; // configStore[chainId]

    bytes32[] public tokenNames;
    mapping(uint256 => Vault)[] public vaults; // vaults[tokensIdx][chainId] = {token, vaultRegistry, bridgeVault}

    constructor(IOSWAP_VotingExecutorManager _votingExecutorManager) {
        votingExecutorManager = _votingExecutorManager;
        owner = msg.sender;
    }

    function init(
        uint256[] memory chainId, 
        Status[] memory _status, 
        IERC20[] memory _govToken, 
        OSWAP_ConfigStore[] memory _configStore,  
        bytes32[] memory mainChainContractNames, 
        address[] memory _mainChainContractAddress, 
        bytes32[] memory contractNames, 
        address[][] memory _address,
        bytes32[] memory _tokenNames,
        Vault[][] memory vault
    ) external onlyOwner {
        require(chains.length == 0, "already init");
        require(chainId.length != 0, "invalid length");
        // uint256 length = chainId.length;
        require(chainId.length==_status.length && chainId.length==_govToken.length && chainId.length==_configStore.length && chainId.length==_address.length, "array length not matched");
        require(mainChainContractNames.length == _mainChainContractAddress.length, "array length not matched");

        for (uint256 i ; i < mainChainContractNames.length ; i++) {
            _updateMainChainAddress(mainChainContractNames[i], _mainChainContractAddress[i]);
        }

        for (uint256 i ; i < chainId.length ; i++) {
            _addChain(chainId[i], _status[i], _govToken[i], _configStore[i], contractNames, _address[i]);
        }
        
        // length = _tokenNames.length;
        require(_tokenNames.length == vault.length, "array length not matched");
        for (uint256 i ; i < _tokenNames.length ; i++) {
            _newVault(_tokenNames[i], chainId, vault[i]);
        }
        owner = address(0);
    }
    function chainsLength() external view returns (uint256) {
        return chains.length;
    }
    function allChains() external view returns (uint256[] memory) {
        return chains;
    }
    function tokenNamesLength() external view returns (uint256) {
        return tokenNames.length;
    }
    function vaultsLength() external view returns (uint256) {
        return vaults.length;
    }

    function getChain(uint256 chainId, bytes32[] calldata contractnames) external view returns (Status _status, IERC20 _govToken, OSWAP_ConfigStore _configStore, address[] memory _contracts, Vault[] memory _vaults) {
        _status = status[chainId];
        _govToken = govToken[chainId];
        _configStore = configStore[chainId];
        uint256 length = contractnames.length;
        _contracts = new address[](length);
        for (uint256 i ; i < length ; i++) {
            _contracts[i] = sideChainContractAddress[chainId][contractnames[i]];
        }
        length = vaults.length;
        _vaults = new Vault[](length);
        for (uint256 i ; i < length ; i++) {
            _vaults[i] = vaults[i][chainId];
        }
    }
    function addChain(uint256 chainId, Status _status, IERC20 _govToken, OSWAP_ConfigStore _configStore,  bytes32[] memory contractNames, address[] memory _address) external onlyVoting {
        _addChain(chainId, _status, _govToken, _configStore, contractNames, _address);
    }
    function _addChain(uint256 chainId, Status _status, IERC20 _govToken, OSWAP_ConfigStore _configStore,  bytes32[] memory contractNames, address[] memory _address) internal {
        require(status[chainId] == Status.NotExists, "chain already exists");
        require(_status > Status.NotExists, "invalid status");
        require(contractNames.length == _address.length, "array length not matched");
        
        chains.push(chainId);
        status[chainId] = _status;
        govToken[chainId] = _govToken;
        emit NewChain(chainId, _status, _govToken);

        configStore[chainId] = _configStore;
        emit UpdateConfigStore(chainId, _configStore);

        uint256 length = contractNames.length;
        for (uint256 i ; i < length ; i++) {
            sideChainContractAddress[chainId][contractNames[i]] = _address[i];
            emit UpdateAddress(chainId, contractNames[i], _address[i]);
        }
    }
    function updateStatus(uint256 chainId, Status _status) external onlyVoting {
        require(status[chainId] != Status.NotExists, "chain not exists");
        require(_status == Status.Active || _status == Status.Inactive, "invalid status");
        status[chainId] = _status;
        emit UpdateStatus(chainId, _status);
    }
    function _updateMainChainAddress(bytes32 contractName, address _address) internal {
        mainChainContractAddress[contractName] = _address;
        emit UpdateMainChainAddress(contractName, _address);
    }
    function updateMainChainAddress(bytes32 contractName, address _address) external onlyVoting {
        _updateMainChainAddress(contractName, _address);
    }
    function updateAddress(uint256 chainId, bytes32 contractName, address _address) external onlyVoting {
        require(status[chainId] != Status.NotExists, "chain not exists");
        sideChainContractAddress[chainId][contractName] = _address;
        emit UpdateAddress(chainId, contractName, _address);
    }
    function updateAddresses(uint256 chainId, bytes32[] memory contractNames, address[] memory _addresses) external onlyVoting {
        require(status[chainId] != Status.NotExists, "chain not exists");
        uint256 length = contractNames.length;
        require(length == _addresses.length, "array length not matched");
        for (uint256 i ; i < length ; i++) {
            sideChainContractAddress[chainId][contractNames[i]] = _addresses[i];
            emit UpdateAddress(chainId, contractNames[i], _addresses[i]);
        }
    }
    function updateConfigStore(uint256 chainId, OSWAP_ConfigStore _address) external onlyVoting {
        require(status[chainId] != Status.NotExists, "chain not exists");
        configStore[chainId] = _address;
        emit UpdateConfigStore(chainId,  _address);
    }
    function newVault(bytes32 name, uint256[] memory chainId, Vault[] memory vault) external onlyVoting returns (uint256 index) {
        return _newVault(name, chainId, vault);
    }
    function _newVault(bytes32 name, uint256[] memory chainId, Vault[] memory vault) internal returns (uint256 index) {
        uint256 length = chainId.length;
        require(length == vault.length, "array length not matched");
        index = vaults.length;
        tokenNames.push(name);
        vaults.push();
        for (uint256 i ; i < length ; i++) {
            require(status[chainId[i]] != Status.NotExists, "chain not exists");
            vaults[index][chainId[i]] = vault[i];
            emit UpdateVault(index, chainId[i], vault[i]);
        }
    }
    function updateVault(uint256 index, uint256 chainId, Vault memory vault) external onlyVoting {
        require(index < vaults.length, "invalid index");
        require(status[chainId] != Status.NotExists, "chain not exists");
        vaults[index][chainId] = vault;
        emit UpdateVault(index, chainId, vault);
    }
}