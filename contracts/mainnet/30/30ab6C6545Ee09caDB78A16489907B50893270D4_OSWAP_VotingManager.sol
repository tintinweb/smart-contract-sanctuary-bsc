/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: GPL-3.0-only

// Sources flattened with hardhat v2.9.9 https://hardhat.org

// File @openzeppelin/contracts/utils/introspection/[email protected]



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


// File @openzeppelin/contracts/token/ERC721/[email protected]



pragma solidity ^0.8.0;

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


// File contracts/contracts/interfaces/I_TrollNFT.sol


pragma solidity 0.8.6;
interface I_TrollNFT is IERC721 {
    function stakingBalance(uint256 tokenId) external view returns (uint256 stakes);
    function lastStakeDate(uint256 tokenId) external view returns (uint256 timestamp);
    function addStakes(uint256 tokenId, uint256 amount) external;
}


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


// File contracts/contracts/OSWAP_ChainRegistry.sol


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


// File @openzeppelin/contracts/security/[email protected]



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
     * by making the `nonReentrant` function external, and make it call a
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


// File @openzeppelin/contracts/utils/[email protected]



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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]



pragma solidity ^0.8.0;


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
            "SafeERC20: approve from non-zero to non-zero allowance"
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
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File @openzeppelin/contracts/token/ERC721/[email protected]



pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


// File @openzeppelin/contracts/token/ERC721/utils/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}


// File @openzeppelin/contracts/utils/cryptography/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
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
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
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


// File contracts/contracts/OSWAP_MainChainTrollRegistry.sol


pragma solidity 0.8.6;
contract OSWAP_MainChainTrollRegistry is Authorization, ERC721Holder, ReentrancyGuard {
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    modifier onlyVoting() {
        require(votingManager.isVotingExecutor(msg.sender), "OSWAP: Not from voting");
        _;
    }
    modifier whenPaused() {
        require(paused(), "NOT PAUSED!");
        _;
    }
    modifier whenNotPaused() {
        require(!paused(), "PAUSED!");
        _;
    }

    event Shutdown(address indexed account);
    event Resume();
    event AddTroll(address indexed owner, address indexed troll, uint256 indexed trollProfileIndex, bool isSuperTroll);
    event UpdateTroll(uint256 indexed trollProfileIndex, address indexed oldTroll, address indexed newTroll);

    event UpdateNFT(I_TrollNFT indexed nft, TrollType trollType);
    event BlockNftTokenId(I_TrollNFT indexed nft, uint256 indexed tokenId, bool blocked);
    event UpdateVotingManager(OSWAP_VotingManager newVotingManager);
    event Upgrade(address newTrollRegistry);

    event StakeSuperToll(address indexed backer, uint256 indexed trollProfileIndex, I_TrollNFT nft, uint256 tokenId, uint256 stakesChange, uint256 stakesBalance);
    event StakeGeneralToll(address indexed backer, uint256 indexed trollProfileIndex, I_TrollNFT nft, uint256 tokenId, uint256 stakesChange, uint256 stakesBalance);
    event UnstakeSuperToll(address indexed backer, uint256 indexed trollProfileIndex, I_TrollNFT nft, uint256 tokenId, uint256 stakesChange, uint256 stakesBalance);
    event UnstakeGeneralToll(address indexed backer, uint256 indexed trollProfileIndex, I_TrollNFT nft, uint256 tokenId, uint256 stakesChange, uint256 stakesBalance);

    enum TrollType {NotSpecified, SuperTroll, GeneralTroll, BlockedSuperTroll, BlockedGeneralTroll}
    // trolls in Locked state can still participate in voting (to replicate events in main chain) in side chain, but cannot do cross chain transactions

    struct TrollProfile {
        address owner;
        address troll;
        TrollType trollType;
        uint256 nftCount;
    }
    struct StakeTo {
        I_TrollNFT nft;
        uint256 tokenId;
        uint256 trollProfileIndex;
        uint256 timestamp;
    }
    struct Staked {
        address backer;
        uint256 index;
    }
    struct StakedInv {
        uint256 trollProfileIndex;
        uint256 index;
    }
    struct Nft {
        I_TrollNFT nft;
        uint256 tokenId;
    }

    bool private _paused;
    IERC20 public immutable govToken;
    OSWAP_VotingManager public votingManager;

    TrollProfile[] public trollProfiles; // trollProfiles[trollProfileIndex] = {owner, troll, trollType, nftCount}
    mapping(address => uint256) public trollProfileInv; // trollProfileInv[troll] = trollProfileIndex
    mapping(address => uint256[]) public ownerTrolls; // ownerTrolls[owner][idx] = trollProfileIndex
    mapping(address => StakeTo[]) public stakeTo;  // stakeTo[backer][idx] = {nft, tokenId, trollProfileIndex}
    mapping(I_TrollNFT => mapping(uint256 => Staked)) public stakeToInv;   // stakeToInv[nft][tokenId] = {backer, idx}
    mapping(uint256 => Nft[]) public stakedBy;  // stakedBy[trollProfileIndex][idx2] = {nft, tokenId}
    mapping(I_TrollNFT => mapping(uint256 => StakedInv)) public stakedByInv;   // stakedByInv[nft][tokenId] = {trollProfileIndex, idx2}

    I_TrollNFT[] public trollNft;
    mapping(I_TrollNFT => uint256) public trollNftInv;
    mapping(I_TrollNFT => TrollType) public nftType;

    uint256 public totalStake;
    mapping(address => uint256) public stakeOf; // stakeOf[owner]

    address public newTrollRegistry;

    constructor(IERC20 _govToken, I_TrollNFT[] memory _superTrollNft, I_TrollNFT[] memory _generalTrollNft) {
        govToken = _govToken;

        uint256 length = _superTrollNft.length;
        for (uint256 i = 0 ; i < length ; i++) {
            I_TrollNFT nft = _superTrollNft[i];
            trollNftInv[nft] = i;
            trollNft.push(nft);
            nftType[nft] = TrollType.SuperTroll;
            emit UpdateNFT(nft, TrollType.SuperTroll);
        }

        uint256 length2 = _generalTrollNft.length;
        for (uint256 i = 0 ; i < length2 ; i++) {
            I_TrollNFT nft = _generalTrollNft[i];
            trollNftInv[nft] = i + length;
            trollNft.push(nft);
            nftType[nft] = TrollType.GeneralTroll;
            emit UpdateNFT(nft, TrollType.GeneralTroll);
        }

        // make trollProfiles[0] invalid and trollProfiles.length > 0
        trollProfiles.push(TrollProfile({owner:address(0), troll:address(0), trollType:TrollType.NotSpecified, nftCount:0}));
        isPermitted[msg.sender] = true;
    }
    function initAddress(OSWAP_VotingManager _votingManager) external onlyOwner {
        require(address(_votingManager) != address(0), "null address");
        require(address(votingManager) == address(0), "already set");
        votingManager = _votingManager;
        // renounceOwnership();
    }

    /*
     * upgrade
     */
    function updateVotingManager() external {
        OSWAP_VotingManager _votingManager = votingManager.newVotingManager();
        require(address(_votingManager) != address(0), "Invalid config store");
        votingManager = _votingManager;
        emit UpdateVotingManager(votingManager);
    }

    function upgrade(address _trollRegistry) external onlyVoting {
        _upgrade(_trollRegistry);
    }
    function upgradeByAdmin(address _trollRegistry) external onlyOwner {
        _upgrade(_trollRegistry);
    }
    function _upgrade(address _trollRegistry) internal {
        // require(address(newTrollRegistry) == address(0), "already set");
        newTrollRegistry = _trollRegistry;
        emit Upgrade(_trollRegistry);
    }

    /*
     * pause / resume
     */
    function paused() public view returns (bool) {
        return _paused;
    }
    function shutdownByAdmin() external auth whenNotPaused {
        _paused = true;
        emit Shutdown(msg.sender);
    }
    function shutdownByVoting() external onlyVoting whenNotPaused {
        _paused = true;
        emit Shutdown(msg.sender);
    }
    function resume() external onlyVoting whenPaused {
        _paused = false;
        emit Resume();
    }

    /*
     * states variables getter
     */
    function ownerTrollsLength(address owner) external view returns (uint256 length) {
        length = ownerTrolls[owner].length;
    }
    function trollProfilesLength() external view returns (uint256 length) {
        length = trollProfiles.length;
    }
    function getTrolls(uint256 start, uint256 length) external view returns (TrollProfile[] memory trolls) {
        if (start < trollProfiles.length) {
            if (start + length > trollProfiles.length) {
                length = trollProfiles.length - start;
            }
            trolls = new TrollProfile[](length);
            for (uint256 i ; i < length ; i++) {
                trolls[i] = trollProfiles[i + start];
            }
        }
    }
    function stakeToLength(address backer) external view returns (uint256 length) {
        length = stakeTo[backer].length;
    }
    function getStakeTo(address backer) external view returns (StakeTo[] memory) {
        return stakeTo[backer];
    }
    function stakedByLength(uint256 trollProfileIndex) external view returns (uint256 length) {
        length = stakedBy[trollProfileIndex].length;
    }
    function getStakedBy(uint256 trollProfileIndex) external view returns (Nft[] memory) {
        return stakedBy[trollProfileIndex];
    }
    function trollNftLength() external view returns (uint256 length) {
        length = trollNft.length;
    }
    function getTrollProperties(uint256 trollProfileIndex) public view returns (
        TrollProfile memory troll,
        Nft[] memory nfts,
        address[] memory backers
    ){
        troll = trollProfiles[trollProfileIndex];
        nfts = stakedBy[trollProfileIndex];
        uint256 length = nfts.length;
        backers = new address[](length);
        for (uint256 i ; i < length ; i++) {
            backers[i] = stakeToInv[nfts[i].nft][nfts[i].tokenId].backer;
        }
    }
    function getTrollPropertiesByAddress(address trollAddress) external view returns (
        TrollProfile memory troll,
        Nft[] memory nfts,
        address[] memory backers
    ) {
        return getTrollProperties(trollProfileInv[trollAddress]);
    }
    function getTrollByNft(I_TrollNFT nft, uint256 tokenId) external view returns (address troll) {
        uint256 trollProfileIndex = stakedByInv[nft][tokenId].trollProfileIndex;
        require(trollProfileIndex != 0, "not exists");
        troll = trollProfiles[trollProfileIndex].troll;
    }

    function updateNft(I_TrollNFT nft, TrollType trolltype) external onlyOwner {
        // new nft or block the nft if exists
        TrollType oldType = nftType[nft];
        bool isNew = trollNft.length == 0 || trollNft[trollNftInv[nft]] != nft;
        if (isNew) {
            trollNftInv[nft] = trollNft.length;
            trollNft.push(nft);
        } else {
            require(oldType == TrollType.SuperTroll ? trolltype==TrollType.BlockedSuperTroll : trolltype==TrollType.BlockedGeneralTroll);
        }
        nftType[nft] = trolltype;
        emit UpdateNFT(nft, trolltype);
    }

    /*
     * helper functions
     */
    function getStakes(address troll) public view returns (uint256 totalStakes) {
        uint256 trollProfileIndex = trollProfileInv[troll];
        return getStakesByTrollProfile(trollProfileIndex);
    }
    function getStakesByTrollProfile(uint256 trollProfileIndex) public view returns (uint256 totalStakes) {
        Nft[] storage stakes = stakedBy[trollProfileIndex];
        uint256 length = stakes.length;
        for (uint256 i = 0 ; i < length ; i++) {
            Nft storage staking = stakes[i];
            if (nftType[staking.nft] == TrollType.SuperTroll) {
                totalStakes += staking.nft.stakingBalance(staking.tokenId);
            }
        }
    }

    /*
     * functions called by owner
     */
    function addTroll(address troll, bool _isSuperTroll, bytes calldata signature) external whenNotPaused {
        // check if owner has the troll's private key to sign message
        address trollOwner = msg.sender;

        require(troll != address(0), "Invalid troll");
        require(trollProfileInv[troll] == 0, "troll already exists");
        require(trollOwner != troll && trollProfileInv[trollOwner] == 0, "owner cannot be a troll");
        require(!isPermitted[troll], "permitted address cannot be a troll");
        require(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msg.sender)))).recover(signature) == troll, "invalid troll signature");

        uint256 trollProfileIndex = trollProfiles.length;
        trollProfileInv[troll] = trollProfileIndex;
        ownerTrolls[trollOwner].push(trollProfileIndex);
        trollProfiles.push(TrollProfile({owner:trollOwner, troll:troll, trollType:_isSuperTroll ? TrollType.SuperTroll : TrollType.GeneralTroll, nftCount:0}));
        emit AddTroll(trollOwner, troll, trollProfileIndex, _isSuperTroll);
    }
    function updateTroll(uint256 trollProfileIndex, address newTroll, bytes calldata signature) external {
        // check if owner has the troll's private key to sign message
        require(newTroll != address(0), "Invalid troll");
        require(trollProfileInv[newTroll] == 0, "newTroll already exists");
        require(!isPermitted[newTroll], "permitted address cannot be a troll");
        require(trollProfiles[trollProfileIndex].owner == msg.sender, "not from owner");
        require(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msg.sender)))).recover(signature) == newTroll, "invalid troll signature");

        TrollProfile storage troll = trollProfiles[trollProfileIndex];
        address oldTroll = troll.troll;
        troll.troll = newTroll;
        trollProfileInv[newTroll] = trollProfileIndex;
        delete trollProfileInv[oldTroll];
        emit UpdateTroll(trollProfileIndex, oldTroll, newTroll);
    }

    /*
     * functions called by backer
     */
    function _stakeMainChain(uint256 trollProfileIndex, I_TrollNFT nft, uint256 tokenId) internal returns (uint256 stakes) {
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        stakes = nft.stakingBalance(tokenId);
        stakeOf[msg.sender] += stakes;
        totalStake += stakes;

        address backer = msg.sender;
        TrollProfile storage troll = trollProfiles[trollProfileIndex];
        require(troll.trollType == nftType[nft], "Invalid nft type");
        uint256 index = stakeTo[backer].length;
        Staked memory staked = Staked({backer: backer, index: index});
        stakeToInv[nft][tokenId] = staked;
        stakeTo[backer].push(StakeTo({nft:nft, tokenId: tokenId, trollProfileIndex: trollProfileIndex, timestamp: block.timestamp}));
        uint256 index2 = stakedBy[trollProfileIndex].length;
        stakedByInv[nft][tokenId] = StakedInv({trollProfileIndex: trollProfileIndex, index: index2});
        stakedBy[trollProfileIndex].push(Nft({nft:nft, tokenId:tokenId}));
        troll.nftCount++;

        votingManager.updateWeight(msg.sender); 
    }
    function stakeSuperTroll(uint256 trollProfileIndex, I_TrollNFT nft, uint256 tokenId) external nonReentrant whenNotPaused {
        require(trollProfiles[trollProfileIndex].trollType == TrollType.SuperTroll, "Invalid type");
        (uint256 stakes) = _stakeMainChain(trollProfileIndex, nft, tokenId);
        emit StakeSuperToll(msg.sender, trollProfileIndex, nft, tokenId, stakes, stakeOf[msg.sender]);
    }
    function stakeGeneralTroll(uint256 trollProfileIndex, I_TrollNFT nft, uint256 tokenId) external nonReentrant whenNotPaused {
        require(trollProfiles[trollProfileIndex].trollType == TrollType.GeneralTroll, "Invalid type");
        (uint256 stakes) = _stakeMainChain(trollProfileIndex, nft, tokenId);
        emit StakeGeneralToll(msg.sender, trollProfileIndex, nft, tokenId, stakes, stakeOf[msg.sender]);
    }

    // add more stakes to the specified nft/tokenId
    function _addStakesSuperTroll(I_TrollNFT nft, uint256 tokenId, uint256 amount) internal returns (uint256 trollProfileIndex){
        trollProfileIndex = stakedByInv[nft][tokenId].trollProfileIndex;
        Staked storage staked = stakeToInv[nft][tokenId];
        require(staked.backer == msg.sender, "not from backer");
        govToken.safeTransferFrom(msg.sender, address(this), amount);
        govToken.approve(address(nft), amount);
        nft.addStakes(tokenId, amount);
        stakeOf[msg.sender] += amount;
        totalStake += amount;

        votingManager.updateWeight(msg.sender); 
    }
    function addStakesSuperTroll(I_TrollNFT nft, uint256 tokenId, uint256 amount) external nonReentrant whenNotPaused {
        uint256 trollProfileIndex = _addStakesSuperTroll(nft, tokenId, amount);
        require(trollProfiles[trollProfileIndex].trollType == TrollType.SuperTroll, "Invalid type");
        emit StakeSuperToll(msg.sender, trollProfileIndex, nft, tokenId, amount, stakeOf[msg.sender]);
    }
    function addStakesGeneralTroll(I_TrollNFT nft, uint256 tokenId, uint256 amount) external nonReentrant whenNotPaused {
        uint256 trollProfileIndex = _addStakesSuperTroll(nft, tokenId, amount);
        require(trollProfiles[trollProfileIndex].trollType == TrollType.GeneralTroll, "Invalid type");
        emit StakeGeneralToll(msg.sender, trollProfileIndex, nft, tokenId, amount, stakeOf[msg.sender]);
    }

    function _unstakeMainChain(I_TrollNFT nft, uint256 tokenId) internal returns (uint256 trollProfileIndex, uint256 stakes) {
        address backer = msg.sender;
        StakedInv storage _stakedByInv = stakedByInv[nft][tokenId];
        // require(staked.backer != address(0));
        trollProfileIndex = _stakedByInv.trollProfileIndex;
        require(trollProfileIndex != 0);

        uint256 indexToBeReplaced;
        uint256 lastIndex;
        // update stakeTo / stakeToInv
        {
        StakeTo[] storage _staking = stakeTo[backer];
        lastIndex = _staking.length - 1;
        Staked storage _staked = stakeToInv[nft][tokenId];
        require(_staked.backer == backer, "not a backer");
        indexToBeReplaced = _staked.index;
        if (indexToBeReplaced != lastIndex) {
            StakeTo storage last = _staking[lastIndex];
            _staking[indexToBeReplaced] = last;
            stakeToInv[last.nft][last.tokenId].index = indexToBeReplaced;
        }
        _staking.pop();
        delete stakeToInv[nft][tokenId];
        }
        // update stakedBy / stakedByInv
        {
        indexToBeReplaced = stakedByInv[nft][tokenId].index;
        Nft[] storage _staked = stakedBy[trollProfileIndex];
        lastIndex = _staked.length - 1;
        if (indexToBeReplaced != lastIndex) {
            Nft storage last = _staked[lastIndex];
            _staked[indexToBeReplaced] = last;
            stakedByInv[last.nft][last.tokenId].index = indexToBeReplaced;
        }
        _staked.pop();
        delete stakedByInv[nft][tokenId];
        }
        trollProfiles[trollProfileIndex].nftCount--;

        stakes = nft.stakingBalance(tokenId);
        stakeOf[msg.sender] -= stakes;
        totalStake -= stakes;
        nft.safeTransferFrom(address(this), msg.sender, tokenId);

        votingManager.updateWeight(msg.sender); 
    }
    function unstakeSuperTroll(I_TrollNFT nft, uint256 tokenId) external nonReentrant whenNotPaused returns (uint256 trollProfileIndex) {
        uint256 stakes;
        (trollProfileIndex, stakes) = _unstakeMainChain(nft, tokenId);
        require(trollProfiles[trollProfileIndex].trollType == TrollType.SuperTroll, "Invalid type");
        emit UnstakeSuperToll(msg.sender, trollProfileIndex, nft, tokenId, stakes, stakeOf[msg.sender]);
    }
    function unstakeGeneralTroll(I_TrollNFT nft, uint256 tokenId) external nonReentrant whenNotPaused returns (uint256 trollProfileIndex) {
        uint256 stakes;
        (trollProfileIndex, stakes) = _unstakeMainChain(nft, tokenId);
        require(trollProfiles[trollProfileIndex].trollType == TrollType.GeneralTroll, "Invalid type");
        emit UnstakeGeneralToll(msg.sender, trollProfileIndex, nft, tokenId, stakes, stakeOf[msg.sender]);
    }


    function backerStaking(address backer, uint256 start, uint256 length) external view returns (StakeTo[] memory stakings) {
        StakeTo[] storage _backerStakings = stakeTo[backer];

        if (start + length > _backerStakings.length) {
            length = _backerStakings.length - start;
        }
        stakings = new StakeTo[](length);

        uint256 j = start;
        for (uint256 i = 0 ; i < length ; i++) {
            stakings[i] = _backerStakings[j + start];
            j++;
        }
    }
}


// File contracts/contracts/OSWAP_MainChainVotingExecutor.sol


pragma solidity 0.8.6;
contract OSWAP_MainChainVotingExecutor {

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    event Execute(bytes32[] params);

    address owner;

    OSWAP_MainChainTrollRegistry public immutable trollRegistry;
    OSWAP_VotingManager public immutable votingManager;
    OSWAP_ChainRegistry public chainRegistry;

    constructor(OSWAP_VotingManager _votingManager) {
        OSWAP_MainChainTrollRegistry _trollRegistry = _votingManager.trollRegistry();
        trollRegistry = _trollRegistry;
        votingManager = _votingManager;
        owner = msg.sender;
    }

    function initAddress(OSWAP_ChainRegistry _chainRegistry) external onlyOwner {
        chainRegistry = _chainRegistry;
        owner = address(0);
    }

    function getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function execute(bytes32[] calldata params) external {
        require(votingManager.isVotingContract(msg.sender), "OSWAP_VotingExecutor: Not from voting");
        require(params.length > 0, "Invalid params length");

        emit Execute(params);

        bytes32 name = params[0];
        if (params.length == 1) {
            if (name == "shutdown") {
                trollRegistry.shutdownByVoting();
                return;
            } else if (name == "resume") {
                trollRegistry.resume();
                return;
            }
        } else {
            bytes32 param1 = params[1];
            if (name == "sideChainConfig") {
                sideChainConfig(params[1:]);
                return;
            } else {
                if (params.length == 2) {
                    if (name == "setAdmin") {
                        votingManager.setAdmin(address(bytes20(param1)));
                        return;
                    } else if (name == "upgradeVotingManager") {
                        votingManager.upgrade(OSWAP_VotingManager(address(bytes20(param1))));
                    }
                } else {
                    bytes32 param2 = params[2];
                    if (params.length == 3) {
                        if (name == "setVotingExecutor") {
                            votingManager.setVotingExecutor(address(bytes20(param1)), uint256(param2)!=0);
                            return;
                        } else if (name == "upgradeTrollRegistry") {
                            // only update if chain id match main chain
                            if (uint256(param1) == getChainId())
                                trollRegistry.upgrade(address(bytes20(param2)));
                            return;
                        }
                    } else {
                        bytes32 param3 = params[3];
                        if (params.length == 4) {
                            if (name == "setVotingConfig") {
                                votingManager.setVotingConfig(param1, param2, uint256(param3));
                                return;
                            }
                        } else {
                            if (params.length == 7) {
                                if (name == "addVotingConfig") {
                                    votingManager.addVotingConfig(param1, uint256(param2), uint256(param3), uint256(params[4]), uint256(params[5]), uint256(params[6]));
                                    return;
                                }
                            }
                        }
                    }
                }
            }
        }
        revert("Invalid parameters");
    }

    // ["sideChainConfig", {"setConfig","setConfigAddress","setConfig2"}, (num_chain), [chainId...], [params...]];
    function sideChainConfig(bytes32[] calldata params) internal {

        require(params.length > 2, "Invalid parameters");
        bytes32 name =  params[0];
        uint256 length = uint256(params[1]) + 2;
        if (params.length > length + 1) {
            bytes32 param1 = params[length];
            bytes32 param2 = params[length+1];

            if (params.length == length + 2) {
                if (name == "setConfig") {
                    for (uint256 i = 2 ; i < length ; i++)
                        chainRegistry.configStore(uint256(params[i])).setConfig(param1, param2);
                    return;
                } else if (name == "setConfigAddress") {
                    for (uint256 i = 2 ; i < length ; i++)
                        chainRegistry.configStore(uint256(params[i])).setConfigAddress(param1, param2);
                    return;
                }
            } else {
                bytes32 param3 = params[length + 2];
                if (params.length == length + 3) {
                    if (name == "setConfig2") { 
                        for (uint256 i = 2 ; i < length ; i++)
                            chainRegistry.configStore(uint256(params[i])).setConfig2(param1, param2, param3);
                        return;
                    }
                }
            }
        }
        revert("Invalid parameters");
    }
}


// File contracts/contracts/OSWAP_VotingRegistry.sol


pragma solidity 0.8.6;

contract OSWAP_VotingRegistry {

    OSWAP_MainChainTrollRegistry public immutable trollRegistry;
    OSWAP_VotingManager public immutable votingManager;

    constructor(OSWAP_VotingManager _votingManager) {
        trollRegistry = _votingManager.trollRegistry();
        votingManager = _votingManager;
    }

    function newVote(
        OSWAP_MainChainVotingExecutor executor,
        bytes32 name, 
        bytes32[] calldata options, 
        uint256 quorum, 
        uint256 threshold, 
        uint256 voteEndTime,
        uint256 executeDelay, 
        bytes32[] calldata executeParam
    ) external {
        bool isExecutiveVote = executeParam.length != 0;
        {
        require(votingManager.isVotingExecutor(address(executor)), "OSWAP_VotingRegistry: Invalid executor");
        bytes32 configName = isExecutiveVote ? executeParam[0] : bytes32("poll");
        (uint256 minExeDelay, uint256 minVoteDuration, uint256 maxVoteDuration, uint256 minGovTokenToCreateVote, uint256 minQuorum) = votingManager.getVotingParams(configName);
        uint256 staked = trollRegistry.stakeOf(msg.sender);
        require(staked >= minGovTokenToCreateVote, "OSWAP_VotingRegistry: minGovTokenToCreateVote not met");
        require(voteEndTime >= minVoteDuration + block.timestamp, "OSWAP_VotingRegistry: minVoteDuration not met");
        require(voteEndTime <= maxVoteDuration + block.timestamp, "OSWAP_VotingRegistry: exceeded maxVoteDuration");
        if (isExecutiveVote) {
            require(quorum >= minQuorum, "OSWAP_VotingRegistry: minQuorum not met");
            require(executeDelay >= minExeDelay, "OSWAP_VotingRegistry: minExeDelay not met");
        }
        }

        uint256 id = votingManager.getNewVoteId();
        OSWAP_VotingContract voting = new OSWAP_VotingContract(
        OSWAP_VotingContract.Params({
            executor:executor, 
            id:id, 
            name:name, 
            options:options, 
            quorum:quorum, 
            threshold:threshold, 
            voteEndTime:voteEndTime, 
            executeDelay:executeDelay, 
            executeParam:executeParam
        }));
        votingManager.newVote(address(voting), isExecutiveVote);
    }
}


// File contracts/contracts/OSWAP_VotingContract.sol


pragma solidity 0.8.6;
contract OSWAP_VotingContract {

    uint256 constant WEI = 10 ** 18;

    OSWAP_MainChainTrollRegistry public immutable trollRegistry;
    OSWAP_VotingManager public immutable votingManager;
    OSWAP_MainChainVotingExecutor public immutable executor;

    uint256 public immutable id;
    bytes32 public immutable name;
    bytes32[] public options;
    uint256 public immutable quorum;
    uint256 public immutable threshold;

    uint256 public immutable voteStartTime;
    uint256 public immutable voteEndTime;
    uint256 public immutable executeDelay;
    bool public executed;
    bool public vetoed;


    mapping (address => uint256) public accountVoteOption;
    mapping (address => uint256) public accountVoteWeight;
    uint256[] public  optionsWeight;
    uint256 public totalVoteWeight;
    uint256 public totalWeight;
    bytes32[] public executeParam;


    struct Params {
        OSWAP_MainChainVotingExecutor executor; 
        uint256 id; 
        bytes32 name; 
        bytes32[] options; 
        uint256 quorum; 
        uint256 threshold; 
        uint256 voteEndTime;
        uint256 executeDelay; 
        bytes32[] executeParam;
    }
    constructor(
        Params memory params
    ) {
        OSWAP_MainChainTrollRegistry _trollRegistry = OSWAP_VotingRegistry(msg.sender).trollRegistry();
        OSWAP_VotingManager _votingManager = OSWAP_VotingRegistry(msg.sender).votingManager();
        votingManager = _votingManager;
        trollRegistry = _trollRegistry;
        require(block.timestamp <= params.voteEndTime, 'VotingContract: Voting already ended');
        if (params.executeParam.length != 0) {
            require(_votingManager.isVotingExecutor(address(params.executor)), "VotingContract: Invalid executor");
            require(params.options.length == 2 && params.options[0] == 'Y' && params.options[1] == 'N', "VotingContract: Invalid options");
            require(params.threshold <= WEI, "VotingContract: Invalid threshold");
            require(params.executeDelay > 0, "VotingContract: Invalid execute delay");
        }

        executor = params.executor;
        totalWeight = _trollRegistry.totalStake();
        id = params.id;
        name = params.name;
        options = params.options;
        quorum = params.quorum;
        threshold = params.threshold;
        optionsWeight = new uint256[](params.options.length);

        voteStartTime = block.timestamp;
        voteEndTime = params.voteEndTime;
        executeDelay = params.executeDelay;
        executeParam = params.executeParam;
    }
    function getParams() external view returns (
        address executor_,
        uint256 id_,
        bytes32 name_,
        bytes32[] memory options_,
        uint256 voteStartTime_,
        uint256 voteEndTime_,
        uint256 executeDelay_,
        bool[2] memory status_, // [executed, vetoed]
        uint256[] memory optionsWeight_,
        uint256[3] memory quorum_, // [quorum, threshold, totalWeight]
        bytes32[] memory executeParam_
    ) {
        return (address(executor), id, name, options, voteStartTime, voteEndTime, executeDelay, [executed, vetoed], optionsWeight, [quorum, threshold, totalWeight], executeParam);
    }
    function veto() external {
        require(msg.sender == address(votingManager), 'OSWAP_VotingContract: Not from Governance');
        require(!executed, 'OSWAP_VotingContract: Already executed');
        vetoed = true;
    }
    function optionsLength() external view returns(uint256){
        return options.length;
    }
    function allOptions() external view returns (bytes32[] memory){
        return options;
    }
    function allOptionsWeight() external view returns (uint256[] memory){
        return optionsWeight;
    }
    function execute() external {
        require(block.timestamp > voteEndTime + executeDelay, "VotingContract: Execute delay not past yet");
        require(!vetoed, 'VotingContract: Vote already vetoed');
        require(!executed, 'VotingContract: Vote already executed');
        require(executeParam.length != 0, 'VotingContract: Execute param not defined');

        require(totalVoteWeight >= quorum, 'VotingContract: Quorum not met');
        require(optionsWeight[0] > optionsWeight[1], "VotingContract: Majority not met"); // 0: Y, 1:N
        require(optionsWeight[0] * WEI > totalVoteWeight * threshold, "VotingContract: Threshold not met");
        executed = true;
        executor.execute(executeParam);
        votingManager.executed();
    }
    function vote(uint256 option) external {
        require(block.timestamp <= voteEndTime, 'VotingContract: Vote already ended');
        require(!vetoed, 'VotingContract: Vote already vetoed');
        require(!executed, 'VotingContract: Vote already executed');
        require(option < options.length, 'VotingContract: Invalid option');

        votingManager.voted(executeParam.length == 0, msg.sender, option);

        uint256 currVoteWeight = accountVoteWeight[msg.sender];
        if (currVoteWeight > 0){
            uint256 currVoteIdx = accountVoteOption[msg.sender];
            optionsWeight[currVoteIdx] = optionsWeight[currVoteIdx] - currVoteWeight;
            totalVoteWeight = totalVoteWeight - currVoteWeight;
        }

        uint256 weight = trollRegistry.stakeOf(msg.sender);
        require(weight > 0, "VotingContract: Not staked to vote");
        accountVoteOption[msg.sender] = option;
        accountVoteWeight[msg.sender] = weight;
        optionsWeight[option] = optionsWeight[option] + weight;
        totalVoteWeight = totalVoteWeight + weight;

        totalWeight = trollRegistry.totalStake();
    }
    function updateWeight(address account) external {
        // use if-cause and don't use requrie() here to avoid revert as Governance is looping through all votings
        if (block.timestamp <= voteEndTime && !vetoed && !executed){
            uint256 weight = trollRegistry.stakeOf(account);
            uint256 currVoteWeight = accountVoteWeight[account];
            if (currVoteWeight > 0 && currVoteWeight != weight){
                uint256 currVoteIdx = accountVoteOption[account];
                accountVoteWeight[account] = weight;
                optionsWeight[currVoteIdx] = optionsWeight[currVoteIdx] - currVoteWeight + weight;
                totalVoteWeight = totalVoteWeight - currVoteWeight + weight;
            }
            totalWeight = trollRegistry.totalStake();
        }
    }
    function executeParamLength() external view returns (uint256){
        return executeParam.length;
    }
    function allExecuteParam() external view returns (bytes32[] memory){
        return executeParam;
    }
}


// File contracts/OSWAP_VotingManager.sol


pragma solidity 0.8.6;
contract OSWAP_VotingManager is Authorization {

    uint256 constant WEI = 10 ** 18;

    modifier onlyVoting() {
        require(isVotingExecutor[msg.sender], "OSWAP: Not from voting");
        _;
    }
    modifier onlyVotingRegistry() {
        require(msg.sender == votingRegister, "Governance: Not from votingRegistry");
        _;
    }

    struct VotingConfig {
        uint256 minExeDelay;
        uint256 minVoteDuration;
        uint256 maxVoteDuration;
        uint256 minGovTokenToCreateVote;
        uint256 minQuorum;
    }

    event ParamSet(bytes32 indexed name, bytes32 value);
    event ParamSet2(bytes32 name, bytes32 value1, bytes32 value2);
    event AddVotingConfig(
        bytes32 name, 
        uint256 minExeDelay, 
        uint256 minVoteDuration, 
        uint256 maxVoteDuration, 
        uint256 minGovTokenToCreateVote, 
        uint256 minQuorum);
    event SetVotingConfig(bytes32 indexed configName, bytes32 indexed paramName, uint256 minExeDelay);

    event NewVote(address indexed vote);
    event NewPoll(address indexed poll);
    event Vote(address indexed account, address indexed vote, uint256 option);
    event Poll(address indexed account, address indexed poll, uint256 option);
    event Executed(address indexed vote);
    event Veto(address indexed vote);
    event Upgrade(OSWAP_VotingManager newVotingManager);

    IERC20 public immutable govToken;
    OSWAP_MainChainTrollRegistry public trollRegistry;
    address public votingRegister;

    mapping (bytes32 => VotingConfig) public votingConfigs;
	bytes32[] public votingConfigProfiles;

    address[] public votingExecutor;
    mapping (address => uint256) public votingExecutorInv;
    mapping (address => bool) public isVotingExecutor;
    address public admin;

    uint256 public voteCount;
    mapping (address => uint256) public votingIdx;
    address[] public votings;

    OSWAP_VotingManager public newVotingManager;
    function newVotingExecutorManager() external view returns (address) { return address(newVotingManager); }

    constructor(
        OSWAP_MainChainTrollRegistry _trollRegistry,
        bytes32[] memory _names, 
        uint256[] memory _minExeDelay, 
        uint256[] memory _minVoteDuration, 
        uint256[] memory _maxVoteDuration, 
        uint256[] memory _minGovTokenToCreateVote, 
        uint256[] memory _minQuorum
    ) {
        trollRegistry = _trollRegistry;
        govToken = _trollRegistry.govToken();

        require(_names.length == _minExeDelay.length && 
                _minExeDelay.length == _minVoteDuration.length && 
                _minVoteDuration.length == _maxVoteDuration.length && 
                _maxVoteDuration.length == _minGovTokenToCreateVote.length && 
                _minGovTokenToCreateVote.length == _minQuorum.length, "OSWAP: Argument lengths not matched");
        for (uint256 i = 0 ; i < _names.length ; i++) {
            require(_minExeDelay[i] > 0 && _minExeDelay[i] <= 604800, "OSWAP: Invalid minExeDelay");
            require(_minVoteDuration[i] < _maxVoteDuration[i] && _minVoteDuration[i] <= 604800, "OSWAP: Invalid minVoteDuration");

            VotingConfig storage config = votingConfigs[_names[i]];
            config.minExeDelay = _minExeDelay[i];
            config.minVoteDuration = _minVoteDuration[i];
            config.maxVoteDuration = _maxVoteDuration[i];
            config.minGovTokenToCreateVote = _minGovTokenToCreateVote[i];
            config.minQuorum = _minQuorum[i];
			votingConfigProfiles.push(_names[i]);
            emit AddVotingConfig(_names[i], config.minExeDelay, config.minVoteDuration, config.maxVoteDuration, config.minGovTokenToCreateVote, config.minQuorum);
        }
    }
    function setVotingRegister(address _votingRegister) external onlyOwner {
        require(votingRegister == address(0), "OSWAP: Already set");
        votingRegister = _votingRegister;
        emit ParamSet("votingRegister", bytes32(bytes20(votingRegister)));
    }
    function initVotingExecutor(address[] calldata  _votingExecutor) external onlyOwner {
        require(votingExecutor.length == 0, "OSWAP: executor already set");
        uint256 length = _votingExecutor.length;
        for (uint256 i = 0 ; i < length ; i++) {
            _setVotingExecutor(_votingExecutor[i], true);
        }
    }

    function upgrade(OSWAP_VotingManager _votingManager) external onlyVoting {
        _upgrade(_votingManager);
    }
    function upgradeByAdmin(OSWAP_VotingManager _votingManager) external onlyOwner {
        _upgrade(_votingManager);
    }
    function _upgrade(OSWAP_VotingManager _votingManager) internal {
        // require(address(newVotingManager) == address(0), "already set");
        newVotingManager = _votingManager;
        emit Upgrade(_votingManager);
    }


	function votingConfigProfilesLength() external view returns(uint256) {
		return votingConfigProfiles.length;
	}
	function getVotingConfigProfiles(uint256 start, uint256 length) external view returns(bytes32[] memory profiles) {
		if (start < votingConfigProfiles.length) {
            if (start + length > votingConfigProfiles.length)
                length = votingConfigProfiles.length - start;
            profiles = new bytes32[](length);
            for (uint256 i = 0 ; i < length ; i++) {
                profiles[i] = votingConfigProfiles[i + start];
            }
        }
	}
    function getVotingParams(bytes32 name) external view returns (uint256 _minExeDelay, uint256 _minVoteDuration, uint256 _maxVoteDuration, uint256 _minGovTokenToCreateVote, uint256 _minQuorum) {
        VotingConfig storage config = votingConfigs[name];
        if (config.minGovTokenToCreateVote == 0){
            config = votingConfigs["vote"];
        }
        return (config.minExeDelay, config.minVoteDuration, config.maxVoteDuration, config.minGovTokenToCreateVote, config.minQuorum);
    }

    function votingExecutorLength() external view returns (uint256) {
        return votingExecutor.length;
    }
    function setVotingExecutor(address _votingExecutor, bool _bool) external onlyVoting {
        _setVotingExecutor(_votingExecutor, _bool);
    }
    function _setVotingExecutor(address _votingExecutor, bool _bool) internal {
        require(_votingExecutor != address(0), "OSWAP: Invalid executor");

        if (votingExecutor.length==0 || votingExecutor[votingExecutorInv[_votingExecutor]] != _votingExecutor) {
            votingExecutorInv[_votingExecutor] = votingExecutor.length;
            votingExecutor.push(_votingExecutor);
        } else {
            require(votingExecutorInv[_votingExecutor] != 0, "OSWAP: cannot reset main executor");
        }
        isVotingExecutor[_votingExecutor] = _bool;
        emit ParamSet2("votingExecutor", bytes32(bytes20(_votingExecutor)), bytes32(uint256(_bool ? 1 : 0)));
    }
    function initAdmin(address _admin) external onlyOwner {
        require(admin == address(0), "OSWAP: Already set");
        _setAdmin(_admin);
    }
    function setAdmin(address _admin) external onlyVoting {
        _setAdmin(_admin);
    }
    function _setAdmin(address _admin) internal {
        require(_admin != address(0), "OSWAP: Invalid admin");
        admin = _admin;
        emit ParamSet("admin", bytes32(bytes20(admin)));
    }
    function addVotingConfig(bytes32 name, uint256 minExeDelay, uint256 minVoteDuration, uint256 maxVoteDuration, uint256 minGovTokenToCreateVote, uint256 minQuorum) external onlyVoting {
        uint256 totalStake = trollRegistry.totalStake();
        require(minExeDelay > 0 && minExeDelay <= 604800, "OSWAP: Invalid minExeDelay");
        require(minVoteDuration < maxVoteDuration && minVoteDuration <= 604800, "OSWAP: Invalid voteDuration");
        require(minGovTokenToCreateVote <= totalStake, "OSWAP: Invalid minGovTokenToCreateVote");
        require(minQuorum <= totalStake, "OSWAP: Invalid minQuorum");

        VotingConfig storage config = votingConfigs[name];
        require(config.minExeDelay == 0, "OSWAP: Config already exists");

        config.minExeDelay = minExeDelay;
        config.minVoteDuration = minVoteDuration;
        config.maxVoteDuration = maxVoteDuration;
        config.minGovTokenToCreateVote = minGovTokenToCreateVote;
        config.minQuorum = minQuorum;
		votingConfigProfiles.push(name);
        emit AddVotingConfig(name, minExeDelay, minVoteDuration, maxVoteDuration, minGovTokenToCreateVote, minQuorum);
    }
    function setVotingConfig(bytes32 configName, bytes32 paramName, uint256 paramValue) external onlyVoting {
        uint256 totalStake = trollRegistry.totalStake();

        require(votingConfigs[configName].minExeDelay > 0, "OSWAP: Config not exists");
        if (paramName == "minExeDelay") {
            require(paramValue > 0 && paramValue <= 604800, "OSWAP: Invalid minExeDelay");
            votingConfigs[configName].minExeDelay = paramValue;
        } else if (paramName == "minVoteDuration") {
            require(paramValue < votingConfigs[configName].maxVoteDuration && paramValue <= 604800, "OSWAP: Invalid voteDuration");
            votingConfigs[configName].minVoteDuration = paramValue;
        } else if (paramName == "maxVoteDuration") {
            require(votingConfigs[configName].minVoteDuration < paramValue, "OSWAP: Invalid voteDuration");
            votingConfigs[configName].maxVoteDuration = paramValue;
        } else if (paramName == "minGovTokenToCreateVote") {
            require(paramValue <= totalStake, "OSWAP: Invalid minGovTokenToCreateVote");
            votingConfigs[configName].minGovTokenToCreateVote = paramValue;
        } else if (paramName == "minQuorum") {
            require(paramValue <= totalStake, "OSWAP: Invalid minQuorum");
            votingConfigs[configName].minQuorum = paramValue;
        }
        emit SetVotingConfig(configName, paramName, paramValue);
    }

    function allVotings() external view returns (address[] memory) {
        return votings;
    }
    function getVotingCount() external view returns (uint256) {
        return votings.length;
    }
    function getVotings(uint256 start, uint256 count) external view returns (address[] memory _votings) {
        if (start + count > votings.length) {
            count = votings.length - start;
        }
        _votings = new address[](count);
        for (uint256 i = 0; i < count ; i++) {
            _votings[i] = votings[start + i];
        }
    }

    function isVotingContract(address votingContract) external view returns (bool) {
        return votings[votingIdx[votingContract]] == votingContract;
    }

    function getNewVoteId() external onlyVotingRegistry returns (uint256) {
        voteCount++;
        return voteCount;
    }

    function newVote(address vote, bool isExecutiveVote) external onlyVotingRegistry {
        require(vote != address(0), "Governance: Invalid voting address");
        require(votings.length == 0 || votings[votingIdx[vote]] != vote, "Governance: Voting contract already exists");

        // close expired poll
        uint256 i = 0;
        while (i < votings.length) {
            OSWAP_VotingContract voting = OSWAP_VotingContract(votings[i]);
            if (voting.executeParamLength() == 0 && voting.voteEndTime() < block.timestamp) {
                _closeVote(votings[i]);
            } else {
                i++;
            }
        }

        votingIdx[vote] = votings.length;
        votings.push(vote);
        if (isExecutiveVote){
            emit NewVote(vote);
        } else {
            emit NewPoll(vote);
        }
    }

    function voted(bool poll, address account, uint256 option) external {
        require(votings[votingIdx[msg.sender]] == msg.sender, "Governance: Voting contract not exists");
        if (poll)
            emit Poll(account, msg.sender, option);
        else
            emit Vote(account, msg.sender, option);
    }

    function updateWeight(address account) external {
        for (uint256 i = 0; i < votings.length; i ++){
            OSWAP_VotingContract(votings[i]).updateWeight(account);
        }
    }

    function executed() external {
        require(votings[votingIdx[msg.sender]] == msg.sender, "Governance: Voting contract not exists");
        _closeVote(msg.sender);
        emit Executed(msg.sender);
    }

    function veto(address voting) external {
        require(msg.sender == admin, "OSWAP: Not from shutdown admin");
        OSWAP_VotingContract(voting).veto();
        _closeVote(voting);
        emit Veto(voting);
    }

    function closeVote(address vote) external {
        require(OSWAP_VotingContract(vote).executeParamLength() == 0, "Governance: Not a Poll");
        require(block.timestamp > OSWAP_VotingContract(vote).voteEndTime(), "Governance: Voting not ended");
        _closeVote(vote);
    }
    function _closeVote(address vote) internal {
        uint256 idx = votingIdx[vote];
        require(idx > 0 || votings[0] == vote, "Governance: Voting contract not exists");
        if (idx < votings.length - 1) {
            votings[idx] = votings[votings.length - 1];
            votingIdx[votings[idx]] = idx;
        }
        votingIdx[vote] = 0;
        votings.pop();
    }
}