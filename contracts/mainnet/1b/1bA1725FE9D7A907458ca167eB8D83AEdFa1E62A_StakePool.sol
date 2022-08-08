// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC777/IERC777RecipientUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC1820RegistryUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import "./embedded-libs/BasisFee.sol";
import "./embedded-libs/Config.sol";
import "./embedded-libs/ExchangeRate.sol";
import "./interfaces/IAddressStore.sol";
import "./interfaces/IStakedBNBToken.sol";
import "./interfaces/IStakePoolBot.sol";
import "./interfaces/ITokenHub.sol";
import "./interfaces/IUndelegationHolder.sol";

// TODO:
// * Tests
contract StakePool is
    IStakePoolBot,
    IERC777RecipientUpgradeable,
    Initializable,
    AccessControlEnumerableUpgradeable
{
    /*********************
     * LIB USAGES
     ********************/

    using Config for Config.Data;
    using ExchangeRate for ExchangeRate.Data;
    using BasisFee for uint256;
    using SafeCastUpgradeable for uint256;

    /*********************
     * STRUCTS
     ********************/

    struct ClaimRequest {
        uint256 weiToReturn; // amount of wei that should be returned to user on claim
        uint256 createdAt; // block timestamp when this request was created
    }

    /*********************
     * RBAC ROLES
     ********************/

    bytes32 public constant BOT_ROLE = keccak256("BOT_ROLE"); // Bots can be added/removed through AccessControl

    /*********************
     * CONSTANTS
     ********************/

    IERC1820RegistryUpgradeable private constant _ERC1820_REGISTRY =
        IERC1820RegistryUpgradeable(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    address private constant _ZERO_ADDR = 0x0000000000000000000000000000000000000000;
    ITokenHub private constant _TOKEN_HUB = ITokenHub(0x0000000000000000000000000000000000001004);

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

    /*********************
     * STATE VARIABLES
     ********************/

    IAddressStore private _addressStore; // Used to fetch addresses of the other contracts in the system.
    Config.Data public config; // the contract configuration

    bool private _paused; // indicates whether this contract is paused or not
    uint256 private _status; // used for reentrancy protection

    /**
     * @dev The amount that needs to be unbonded in the next unstaking epoch.
     * It increases on every user unstake operation, and decreases when the bot initiates unbonding.
     * This is queried by the bot in order to initiate unbonding.
     * It is int256, not uint256 because bnbUnbonding can be more than it and is subtracted from it.
     * So, if it is < 0, means we have already initiated unbonding for that much amount and eventually
     * that amount would be part of claimReserve. So, we don't need to unbond anything new on the BBC
     * side as long as this value is negative.
     *
     * Increase frequency: anytime
     * Decrease frequency & Bot query frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     */
    int256 private _bnbToUnbond;

    /**
     * @dev The amount of BNB that is unbonding in the current unstaking epoch.
     * It increases when the bot initiates unbonding, and decreases when the unbonding is finished.
     * It is queried by the bot before calling unbondingFinished(), to figure out the amount that
     * needs to be moved from BBC to BSC.
     *
     * Increase, Decrease & Bot query frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     */
    uint256 private _bnbUnbonding;

    /**
     * @dev A portion of the contract balance that is reserved in order to satisfy the claims
     * for which the cooldown period has finished. This will never be sent to BBC for staking.
     * It increases when the unbonding is finished, and decreases when any user actually claims
     * their BNB.
     *
     * Increase frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     * Decrease frequency: anytime
     */
    uint256 private _claimReserve;

    /**
     * @dev The current exchange rate for converting BNB to stkBNB and vice-versa.
     */
    ExchangeRate.Data public exchangeRate;

    /**
     * @dev maps userAddress -> a list of claim requests for that user
     */
    mapping(address => ClaimRequest[]) public claimReqs;

    /*********************
     * EVENTS
     ********************/
    event ConfigUpdated(); // emitted when config is updated
    event Deposit(
        address indexed user,
        uint256 bnbAmount,
        uint256 poolTokenAmount,
        uint256 timestamp
    );
    event Withdraw(
        address indexed user,
        uint256 poolTokenAmount,
        uint256 bnbAmount,
        uint256 timestamp
    );
    event Claim(address indexed user, ClaimRequest req, uint256 timestamp);
    event InitiateDelegation_TransferOut(uint256 transferOutAmount); // emitted during initiateDelegation
    event InitiateDelegation_ShortCircuit(uint256 shortCircuitAmount); // emitted during initiateDelegation
    event InitiateDelegation_Success(); // emitted during initiateDelegation
    event EpochUpdate(uint256 bnbRewards, uint256 feeTokens); // emitted on epochUpdate
    event UnbondingInitiated(uint256 bnbUnbonding); // emitted on unbondingInitiated
    event UnbondingFinished(uint256 unbondedAmount); // emitted on unbondingFinished
    event Paused(address account); // emitted when the pause is triggered by `account`.
    event Unpaused(address account); // emitted when the pause is lifted by `account`.

    /*********************
     * ERRORS
     ********************/

    error UnknownSender();
    error LessThanMinimum(string tag, uint256 expected, uint256 got);
    error DustNotAllowed(uint256 dust);
    error TokenMintingToSelfNotAllowed();
    error TokenTransferToSelfNotAllowed();
    error UnexpectedlyReceivedTokensForSomeoneElse(address to);
    error CantClaimBeforeDeadline();
    error InsufficientFundsToSatisfyClaim();
    error InsufficientClaimReserve();
    error BNBTransferToUserFailed();
    error IndexOutOfBounds(uint256 index);
    error ToIndexMustBeGreaterThanFromIndex(uint256 from, uint256 to);
    error PausablePaused();
    error PausableNotPaused();
    error ReentrancyGuardReentrantCall();
    error TransferOutFailed();

    /*********************
     * MODIFIERS
     ********************/

    /**
     * @dev Checks that gotVal is at least minVal. Otherwise, reverts with the given tag.
     * Also ensures that the gotVal doesn't have token dust based on minVal.
     */
    modifier checkMinAndDust(
        string memory tag,
        uint256 minVal,
        uint256 gotVal
    ) {
        _checkMinAndDust(tag, minVal, gotVal);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _whenNotPaused();
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
        _whenPaused();
        _;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantPre();
        _;
        _nonReentrantPost();
    }

    /*********************
     * MODIFIERS FUNCTIONS
     ********************/

    /**
     * @dev A modifier is replaced by all the code in its definition. This leads to increase in compiled contract size.
     * Creating functions for the code inside a modifier, helps reduce the contract size as now the modifier will be
     * replaced by just the function call, instead of all the lines in these functions.
     */

    function _checkMinAndDust(
        string memory tag,
        uint256 minVal,
        uint256 gotVal
    ) private pure {
        if (gotVal < minVal) {
            revert LessThanMinimum(tag, minVal, gotVal);
        }
        uint256 dust = gotVal % minVal;
        if (dust != 0) {
            revert DustNotAllowed(dust);
        }
    }

    function _whenNotPaused() private view {
        if (_paused) {
            revert PausablePaused();
        }
    }

    function _whenPaused() private view {
        if (!_paused) {
            revert PausableNotPaused();
        }
    }

    function _nonReentrantPre() private {
        // On the first call to nonReentrant, _notEntered will be true
        if (_status == _ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantPost() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /*********************
     * INIT FUNCTIONS
     ********************/

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(IAddressStore addressStore_, Config.Data calldata config_)
        public
        initializer
    {
        __StakePool_init(addressStore_, config_);
    }

    function __StakePool_init(IAddressStore addressStore_, Config.Data calldata config_)
        internal
        onlyInitializing
    {
        // Need to call initializers for each parent without calling anything twice.
        // So, we need to individually see each parent's initializer and not call the initializer's that have already been called.
        //      1. __AccessControlEnumerable_init => This is empty in the current openzeppelin v0.4.6

        // Finally, initialize this contract.
        __StakePool_init_unchained(addressStore_, config_);
    }

    function __StakePool_init_unchained(IAddressStore addressStore_, Config.Data calldata config_)
        internal
        onlyInitializing
    {
        // set contract state variables
        _addressStore = addressStore_;
        config._init(config_);
        _paused = true; // to ensure that nothing happens until the whole system is setup
        _status = _NOT_ENTERED;
        _bnbToUnbond = 0;
        _bnbUnbonding = 0;
        _claimReserve = 0;
        exchangeRate._init();

        // register interfaces
        _ERC1820_REGISTRY.setInterfaceImplementer(
            address(this),
            keccak256("ERC777TokensRecipient"),
            address(this)
        );

        // Make the deployer the default admin, deployer will later transfer this role to a multi-sig.
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /*********************
     * ADMIN FUNCTIONS
     ********************/

    /**
     * @dev pause: Used by admin to pause the contract.
     *             Supposed to be used in case of a prod disaster.
     *
     * Requirements:
     *
     * - The caller must have the DEFAULT_ADMIN_ROLE.
     */
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev unpause: Used by admin to resume the contract.
     *               Supposed to be used after the prod disaster has been mitigated successfully.
     *
     * Requirements:
     *
     * - The caller must have the DEFAULT_ADMIN_ROLE.
     */
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    /**
     * @dev updateConfig: Used by admin to set/update the contract configuration.
     *                    It is allowed to update config even when the contract is paused.
     *
     * Requirements:
     *
     * - The caller must have the DEFAULT_ADMIN_ROLE.
     */
    function updateConfig(Config.Data calldata config_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        config._init(config_);
        emit ConfigUpdated();
    }

    /*********************
     * USER FUNCTIONS
     ********************/

    /**
     * @dev deposit: Called by a user to deposit BNB to the contract in exchange for stkBNB.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function deposit()
        external
        payable
        whenNotPaused
        nonReentrant
        checkMinAndDust("Deposit", config.minBNBDeposit, msg.value)
    {
        uint256 userWei = msg.value;
        uint256 poolTokensToReturn = exchangeRate._calcPoolTokensForDeposit(userWei);
        uint256 poolTokensDepositFee = config.fee.deposit._apply(poolTokensToReturn);
        uint256 poolTokensUser = poolTokensToReturn - poolTokensDepositFee;

        // update the exchange rate using the wei amount for which tokens will be minted
        exchangeRate._update(
            ExchangeRate.Data(userWei, poolTokensToReturn),
            ExchangeRate.UpdateOp.Add
        );

        // mint the tokens for appropriate accounts
        IStakedBNBToken stkBNB = IStakedBNBToken(_addressStore.getStkBNB());
        stkBNB.mint(msg.sender, poolTokensUser, "", "");
        if (poolTokensDepositFee > 0) {
            stkBNB.mint(_addressStore.getFeeVault(), poolTokensDepositFee, "", "");
        }

        emit Deposit(msg.sender, msg.value, poolTokensUser, block.timestamp);
    }

    /**
     * @dev Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account (`to`). The type of operation
     * is conveyed by `from` being the zero address or not.
     *
     * This call occurs _after_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the post-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     *
     * We use this to receive stkBNB tokens from users for the purpose of withdrawal.
     * So:
     * 1. `msg.sender` must be the address of pool token. Only the token contract should be the caller for this.
     * 2. `from` should be the address of some user. It should never be the zero address or the address of this contract.
     * 3. `to` should always be the address of this contract.
     * 4. `amount` should always be at least config.minTokenWithdrawal.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function tokensReceived(
        address, /*operator*/
        address from,
        address to,
        uint256 amount,
        bytes calldata, /*userData*/
        bytes calldata /*operatorData*/
    )
        external
        override
        whenNotPaused
        nonReentrant
        checkMinAndDust("Withdrawal", config.minTokenWithdrawal, amount)
    {
        // checks
        if (msg.sender != _addressStore.getStkBNB()) {
            revert UnknownSender();
        }
        if (from == address(0)) {
            revert TokenMintingToSelfNotAllowed();
        }
        if (from == address(this)) {
            revert TokenTransferToSelfNotAllowed();
        }
        if (to != address(this)) {
            revert UnexpectedlyReceivedTokensForSomeoneElse(to);
        }

        _withdraw(from, amount);
    }

    /**
     * @dev claimAll: Called by a user to claim all the BNB they had previously unstaked.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function claimAll() external whenNotPaused nonReentrant {
        uint256 claimRequestCount = claimReqs[msg.sender].length;
        uint256 i = 0;

        while (i < claimRequestCount) {
            if (_claim(i)) {
                --claimRequestCount;
                continue;
            }
            ++i;
        }
    }

    /**
     * @dev claim: Called by a user to claim the BNB they had previously unstaked.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     *
     * @param index: The index of the ClaimRequest which is to be claimed.
     */
    function claim(uint256 index) external whenNotPaused nonReentrant {
        if (!_claim(index)) {
            revert CantClaimBeforeDeadline();
        }
    }

    /*********************
     * BOT FUNCTIONS
     ********************/

    /**
     * @dev This is called by the bot in order to transfer the stakable BNB from contract to the
     * staking address on BBC.
     * Call frequency:
     *      Mainnet: Daily
     *      Testnet: Daily
     */
    function initiateDelegation() external override whenNotPaused onlyRole(BOT_ROLE) {
        // contract will always have at least the _claimReserve, so this should never overflow.
        uint256 excessBNB = address(this).balance - _claimReserve;
        // token hub expects only 8 decimals in the cross-chain transfer value to avoid any precision loss
        // so, remove the insignificant 10 decimals
        uint256 transferOutValue = excessBNB - (excessBNB % 1e10);
        uint256 miniRelayFee = _TOKEN_HUB.getMiniRelayFee(); // usually 0.01 BNB

        // Initiate a cross-chain transfer only if we have enough amount.
        if (transferOutValue >= miniRelayFee + config.minCrossChainTransfer) {
            // this would always be at least config.minCrossChainTransfer
            uint256 transferOutAmount = transferOutValue - miniRelayFee;
            // We are charging the relay fee from the user funds. Similarly, any other fees on the BBC would be
            // paid from user funds. This will eventually lead to the total BNB with the protocol to be less than what
            // is accounted in the exchangeRate. This might lead to claims not working in case of a black swan event.
            // So, we must pay back the fee losses to the protocol to ensure the protocol correctness.
            // For this, we will monitor the fee losses, and pay them back to the protocol periodically.
            // Note that the probability of a black swan event is very low. On top of that, as time passes, we will be
            // accumulating some stkBNB as rewards in FeeVault. This implies that our share of BNB in the pool will
            // keep increasing over time. As long as this share is more than the total fee spent till that time, we need
            // not worry about paying back the fee losses. Also, for us to be economically successful, we must set
            // protocol fee rates in a way so that the rewards we earn via FeeVault are significantly more than the fee
            // we are paying for the protocol operations.
            bool success = _TOKEN_HUB.transferOut{ value: transferOutValue }(
                _ZERO_ADDR,
                config.bcStakingWallet,
                transferOutAmount,
                uint64(block.timestamp + config.transferOutTimeout)
            );
            if (!success) {
                revert TransferOutFailed();
            }

            emit InitiateDelegation_TransferOut(transferOutAmount);
        } else if (excessBNB > 0 && _bnbToUnbond > 0) {
            // if the excess amount is so small that it can't be moved to BBC and there is _bnbToUnbond, short-circuit
            // the bot process and directly update the _claimReserve. This way, we will still be able to satisfy claims
            // even if the total deposit throughout the unstaking epoch is less than the minimum cross-chain transfer.

            // The reason we don't do this short-circuit process more generally is because the short-circuited amount
            // doesn't earn any rewards. While, if it would have gone through the normal transferOut process, it would
            // have earned significant staking rewards because we undelegate only once in 7 days on mainnet. So, we do
            // this short-circuit process only to handle the edge case when the deposits throughout the unstaking epoch
            // are less than the minimum cross-chain transfer and users initiated withdrawals, so that we are
            // successfully able to satisfy the claim requests.

            uint256 shortCircuitAmount;
            if (_bnbToUnbond > excessBNB.toInt256()) {
                // all the excessBNB we have in the contract will be used up to satisfy claims. The remaining
                // _bnbToUnbond will be made available to the contract by the bot via the unstaking operations.
                shortCircuitAmount = excessBNB;
            } else {
                // the amount we need to unbond to satisfy claims is already present in the contract. So, only that much
                // needs to be moved to _claimReserve.
                shortCircuitAmount = uint256(_bnbToUnbond);
            }
            _bnbToUnbond -= shortCircuitAmount.toInt256();
            _claimReserve += shortCircuitAmount;

            emit InitiateDelegation_ShortCircuit(shortCircuitAmount);
        }
        // else there is no excess amount or very small excess amount and no _bnbToUnbond. In these cases, the excess
        // amount will remain in the contract, and will be delegated the next day.

        // emitted to make the life of off-chain dependencies easy
        emit InitiateDelegation_Success();
    }

    /**
     * @dev Called by the bot to update the exchange rate in contract based on the rewards
     * obtained in the BBC staking address and accordingly mint fee tokens.
     * Call frequency:
     *      Mainnet: Daily
     *      Testnet: Daily
     *
     * @param bnbRewards: The amount of BNB which were received as staking rewards.
     */
    function epochUpdate(uint256 bnbRewards) external override whenNotPaused onlyRole(BOT_ROLE) {
        // calculate fee
        uint256 feeWei = config.fee.reward._apply(bnbRewards);
        uint256 feeTokens = (feeWei * exchangeRate.poolTokenSupply) /
            (exchangeRate.totalWei + bnbRewards - feeWei);

        // update exchange rate
        exchangeRate._update(ExchangeRate.Data(bnbRewards, feeTokens), ExchangeRate.UpdateOp.Add);

        // mint the fee tokens to FeeVault
        IStakedBNBToken(_addressStore.getStkBNB()).mint(
            _addressStore.getFeeVault(),
            feeTokens,
            "",
            ""
        );

        // emit the ack event
        emit EpochUpdate(bnbRewards, feeTokens);
    }

    /**
     * @dev This is called by the bot after it has executed the unbond transaction on BBC.
     * Call frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     *
     * @param bnbUnbonding_: The amount of BNB for which unbonding was initiated on BBC.
     *                       It can be more than bnbToUnbond, but within a factor of min undelegation amount.
     */
    function unbondingInitiated(uint256 bnbUnbonding_)
        external
        override
        whenNotPaused
        onlyRole(BOT_ROLE)
    {
        _bnbToUnbond -= bnbUnbonding_.toInt256();
        _bnbUnbonding += bnbUnbonding_;

        emit UnbondingInitiated(bnbUnbonding_);
    }

    /**
     * @dev Called by the bot after the unbonded amount for claim fulfilment is received in BBC
     * and has been transferred to the UndelegationHolder contract on BSC.
     * It calls UndelegationHolder.withdrawUnbondedBNB() to fetch the unbonded BNB to itself and
     * update `bnbUnbonding` and `claimReserve`.
     * Call frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     */
    function unbondingFinished() external override whenNotPaused onlyRole(BOT_ROLE) {
        // the unbondedAmount can never be more than _bnbUnbonding. UndelegationHolder takes care of that.
        // So, no need to worry about arithmetic overflows.
        uint256 unbondedAmount = IUndelegationHolder(payable(_addressStore.getUndelegationHolder()))
            .withdrawUnbondedBNB();
        _bnbUnbonding -= unbondedAmount;
        _claimReserve += unbondedAmount;

        emit UnbondingFinished(unbondedAmount);
    }

    /**
     * @dev It is called by the UndelegationHolder as part of withdrawUnbondedBNB() during the unbondingFinished() call.
     */
    receive() external payable whenNotPaused {
        if (msg.sender != _addressStore.getUndelegationHolder()) {
            revert UnknownSender();
        }
        // do nothing
        // Any necessary events for recording the balance change are emitted in unbondingFinished().
    }

    /*********************
     * VIEWS
     ********************/

    /**
     * @return the address store
     */
    function addressStore() external view returns (IAddressStore) {
        return _addressStore;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() external view returns (bool) {
        return _paused;
    }

    /**
     * @return _bnbToUnbond
     */
    function bnbToUnbond() external view override returns (int256) {
        return _bnbToUnbond;
    }

    /**
     * @return _bnbUnbonding
     */
    function bnbUnbonding() external view override returns (uint256) {
        return _bnbUnbonding;
    }

    /**
     * @return _claimReserve
     */
    function claimReserve() external view override returns (uint256) {
        return _claimReserve;
    }

    /**
     * @dev getClaimRequestCount: Get the number of active claim requests by user
     * @param user: Address of the user for which to query.
     */
    function getClaimRequestCount(address user) external view returns (uint256) {
        return claimReqs[user].length;
    }

    /**
     * @dev getPaginatedClaimRequests: Get a paginated view of a user's claim requests in the range [from, to).
     *                                 The returned claims are not sorted in any order.
     * @param user: Address of the user whose claims need to be queried.
     * @param from: List start index (inclusive).
     * @param to: List end index (exclusive).
     */
    function getPaginatedClaimRequests(
        address user,
        uint256 from,
        uint256 to
    ) external view returns (ClaimRequest[] memory) {
        if (from >= claimReqs[user].length) {
            revert IndexOutOfBounds(from);
        }
        if (from >= to) {
            revert ToIndexMustBeGreaterThanFromIndex(from, to);
        }

        if (to > claimReqs[user].length) {
            to = claimReqs[user].length;
        }

        ClaimRequest[] memory paginatedClaimRequests = new ClaimRequest[](to - from);
        for (uint256 i = 0; i < to - from; ++i) {
            paginatedClaimRequests[i] = claimReqs[user][from + i];
        }

        return paginatedClaimRequests;
    }

    /*********************
     * INTERNAL FUNCTIONS
     ********************/

    function _withdraw(address from, uint256 amount) internal {
        uint256 poolTokensFee = config.fee.withdraw._apply(amount);
        uint256 poolTokensToBurn = amount - poolTokensFee;

        // calculate the BNB needed to be sent to the user
        uint256 weiToReturn = exchangeRate._calcWeiWithdrawAmount(poolTokensToBurn);

        // create a claim request for this withdrawal
        claimReqs[from].push(ClaimRequest(weiToReturn, block.timestamp));

        // update the _bnbToUnbond
        _bnbToUnbond += weiToReturn.toInt256();

        // update the exchange rate to reflect the balance changes
        exchangeRate._update(
            ExchangeRate.Data(weiToReturn, poolTokensToBurn),
            ExchangeRate.UpdateOp.Subtract
        );

        IStakedBNBToken stkBNB = IStakedBNBToken(_addressStore.getStkBNB());
        // burn the non-fee tokens
        stkBNB.burn(poolTokensToBurn, "");
        if (poolTokensFee > 0) {
            // transfer the fee to FeeVault, if any
            stkBNB.send(_addressStore.getFeeVault(), poolTokensFee, "");
        }

        emit Withdraw(from, amount, weiToReturn, block.timestamp);
    }

    /**
     * @dev _claim: Claim BNB after cooldown has finished.
     *
     * @param index: The index of the ClaimRequest which is to be claimed.
     *
     * @return true if the request can be claimed, false otherwise.
     */
    function _claim(uint256 index) internal returns (bool) {
        if (index >= claimReqs[msg.sender].length) {
            revert IndexOutOfBounds(index);
        }

        // find the requested claim
        ClaimRequest memory req = claimReqs[msg.sender][index];

        if (!_canBeClaimed(req)) {
            return false;
        }
        // the contract should have at least as much balance as needed to fulfil the request
        if (address(this).balance < req.weiToReturn) {
            revert InsufficientFundsToSatisfyClaim();
        }
        // the _claimReserve should also be at least as much as needed to fulfil the request
        if (_claimReserve < req.weiToReturn) {
            revert InsufficientClaimReserve();
        }

        // update _claimReserve
        _claimReserve -= req.weiToReturn;

        // delete the req, as it has been fulfilled (swap deletion for O(1) compute)
        claimReqs[msg.sender][index] = claimReqs[msg.sender][claimReqs[msg.sender].length - 1];
        claimReqs[msg.sender].pop();

        // return BNB back to user (which can be anyone: EOA or a contract)
        (
            bool sent, /*memory data*/

        ) = msg.sender.call{ value: req.weiToReturn }("");
        if (!sent) {
            revert BNBTransferToUserFailed();
        }
        emit Claim(msg.sender, req, block.timestamp);
        return true;
    }

    /**
     * @dev _canBeClaimed: Helper function to check whether a ClaimRequest can be claimed or not.
     *                      It is allowed to claim only after the cooldown period has finished.
     *
     * @param req: The request which needs to be checked.
     * @return true if the request can be claimed.
     */
    function _canBeClaimed(ClaimRequest memory req) internal view returns (bool) {
        return block.timestamp > (req.createdAt + config.cooldownPeriod);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerableUpgradeable.sol";
import "./AccessControlUpgradeable.sol";
import "../utils/structs/EnumerableSetUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal onlyInitializing {
    }

    function __AccessControlEnumerable_init_unchained() internal onlyInitializing {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC777/IERC777Recipient.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC777TokensRecipient standard as defined in the EIP.
 *
 * Accounts can be notified of {IERC777} tokens being sent to them by having a
 * contract implement this interface (contract holders can be their own
 * implementer) and registering it on the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 global registry].
 *
 * See {IERC1820Registry} and {ERC1820Implementer}.
 */
interface IERC777RecipientUpgradeable {
    /**
     * @dev Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account (`to`). The type of operation
     * is conveyed by `from` being the zero address or not.
     *
     * This call occurs _after_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the post-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/introspection/IERC1820Registry.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the global ERC1820 Registry, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1820[EIP]. Accounts may register
 * implementers for interfaces in this registry, as well as query support.
 *
 * Implementers may be shared by multiple accounts, and can also implement more
 * than a single interface for each account. Contracts can implement interfaces
 * for themselves, but externally-owned accounts (EOA) must delegate this to a
 * contract.
 *
 * {IERC165} interfaces can also be queried via the registry.
 *
 * For an in-depth explanation and source code analysis, see the EIP text.
 */
interface IERC1820RegistryUpgradeable {
    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);

    /**
     * @dev Sets `newManager` as the manager for `account`. A manager of an
     * account is able to set interface implementers for it.
     *
     * By default, each account is its own manager. Passing a value of `0x0` in
     * `newManager` will reset the manager to this initial state.
     *
     * Emits a {ManagerChanged} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     */
    function setManager(address account, address newManager) external;

    /**
     * @dev Returns the manager for `account`.
     *
     * See {setManager}.
     */
    function getManager(address account) external view returns (address);

    /**
     * @dev Sets the `implementer` contract as ``account``'s implementer for
     * `interfaceHash`.
     *
     * `account` being the zero address is an alias for the caller's address.
     * The zero address can also be used in `implementer` to remove an old one.
     *
     * See {interfaceHash} to learn how these are created.
     *
     * Emits an {InterfaceImplementerSet} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     * - `interfaceHash` must not be an {IERC165} interface id (i.e. it must not
     * end in 28 zeroes).
     * - `implementer` must implement {IERC1820Implementer} and return true when
     * queried for support, unless `implementer` is the caller. See
     * {IERC1820Implementer-canImplementInterfaceForAddress}.
     */
    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external;

    /**
     * @dev Returns the implementer of `interfaceHash` for `account`. If no such
     * implementer is registered, returns the zero address.
     *
     * If `interfaceHash` is an {IERC165} interface id (i.e. it ends with 28
     * zeroes), `account` will be queried for support of it.
     *
     * `account` being the zero address is an alias for the caller's address.
     */
    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);

    /**
     * @dev Returns the interface hash for an `interfaceName`, as defined in the
     * corresponding
     * https://eips.ethereum.org/EIPS/eip-1820#interface-name[section of the EIP].
     */
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    /**
     * @notice Updates the cache with whether the contract implements an ERC165 interface or not.
     * @param account Address of the contract for which to update the cache.
     * @param interfaceId ERC165 interface for which to update the cache.
     */
    function updateERC165Cache(address account, bytes4 interfaceId) external;

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not.
     * If the result is not cached a direct lookup on the contract address is performed.
     * If the result is not cached or the cached value is out-of-date, the cache MUST be updated manually by calling
     * {updateERC165Cache} with the contract address.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not without using nor updating the cache.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCastUpgradeable {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 * BasisFee uses a constant denominator of 1e11, in the fee percentage formula:
 * fee % = numerator / denominator * 100
 * So, if you want to set 2% fee, you should be supplying (2/100)*1e11 = 2*1e9 as the numerator.
 * BasisFee allows you to have a precision of 9 digits while setting the fee %,
 * i.e., you can set 0.123456789% as a fee rate and be sure that the fee calculations will work.
 * This should suffice for most of the use-cases.
 */
library BasisFee {
    error NumeratorMoreThanBasis();
    error CantSetMoreThan30PercentFee();

    uint256 internal constant _BASIS = 1e11;

    function _checkValid(uint256 self) internal pure {
        if (self > _BASIS) {
            revert NumeratorMoreThanBasis();
        }
        if (self > (_BASIS / 100) * 30) {
            revert CantSetMoreThan30PercentFee();
        }
    }

    function _apply(uint256 self, uint256 amount) internal pure returns (uint256) {
        return (amount * self) / _BASIS;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./FeeDistribution.sol";

library Config {
    using Config for Data;
    using FeeDistribution for FeeDistribution.Data;

    error MustBeGreaterThanZero();
    error CantBeMoreThan1e18();
    error CooldownPeriodCantBeMoreThan30Days();

    struct Data {
        // @dev The address of the staking wallet on the BBC chain. It will be used for transferOut transactions.
        // It needs to be correctly converted from a bech32 BBC address to a solidity address.
        address bcStakingWallet;
        // @dev The minimum amount of BNB required to initiate a cross-chain transfer from BSC to BC.
        // This should be at least minStakingAddrBalance + minDelegationAmount.
        // Ideally, this should be set to a value such that the protocol revenue from this value is more than the fee
        // lost on this value for cross-chain transfer/delegation/undelegation/etc.
        // But, finding the ideal value is non-deterministic.
        uint256 minCrossChainTransfer;
        // The timeout for the cross-chain transfer out operation in seconds.
        uint256 transferOutTimeout;
        // @dev The minimum amount of BNB required to make a deposit to the contract.
        uint256 minBNBDeposit;
        // @dev The minimum amount of tokens required to make a withdrawal from the contract.
        uint256 minTokenWithdrawal;
        // @dev The minimum amount of time (in seconds) a user has to wait after unstake to claim their BNB.
        // It would be 15 days on mainnet. 3 days on testnet.
        uint256 cooldownPeriod;
        // @dev The fee distribution to represent different kinds of fee.
        FeeDistribution.Data fee;
    }

    function _init(Data storage self, Data calldata obj) internal {
        obj._checkValid();
        self._set(obj);
    }

    function _checkValid(Data calldata self) internal pure {
        self.fee._checkValid();
        if (self.minCrossChainTransfer == 0) {
            revert MustBeGreaterThanZero();
        }
        if (self.transferOutTimeout == 0) {
            revert MustBeGreaterThanZero();
        }
        if (self.minBNBDeposit > 1e18) {
            revert CantBeMoreThan1e18();
        }
        if (self.minTokenWithdrawal > 1e18) {
            revert CantBeMoreThan1e18();
        }
        if (self.cooldownPeriod > 2592000) {
            revert CooldownPeriodCantBeMoreThan30Days();
        }
    }

    function _set(Data storage self, Data calldata obj) internal {
        self.bcStakingWallet = obj.bcStakingWallet;
        self.minCrossChainTransfer = obj.minCrossChainTransfer;
        self.transferOutTimeout = obj.transferOutTimeout;
        self.minBNBDeposit = obj.minBNBDeposit;
        self.minTokenWithdrawal = obj.minTokenWithdrawal;
        self.cooldownPeriod = obj.cooldownPeriod;
        self.fee._set(obj.fee);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

library ExchangeRate {
    struct Data {
        uint256 totalWei;
        uint256 poolTokenSupply;
    }
    enum UpdateOp {
        Add,
        Subtract
    }

    function _init(Data storage self) internal {
        self.totalWei = 0;
        self.poolTokenSupply = 0;
    }

    function _update(
        Data storage self,
        Data memory change,
        UpdateOp op
    ) internal {
        if (op == UpdateOp.Add) {
            self.totalWei += change.totalWei;
            self.poolTokenSupply += change.poolTokenSupply;
        } else {
            self.totalWei -= change.totalWei;
            self.poolTokenSupply -= change.poolTokenSupply;
        }
    }

    function _calcPoolTokensForDeposit(Data storage self, uint256 weiAmount)
        internal
        view
        returns (uint256)
    {
        if (self.totalWei == 0 || self.poolTokenSupply == 0) {
            return weiAmount;
        }
        return (weiAmount * self.poolTokenSupply) / self.totalWei;
    }

    function _calcWeiWithdrawAmount(Data storage self, uint256 poolTokens)
        internal
        view
        returns (uint256)
    {
        uint256 numerator = poolTokens * self.totalWei;
        uint256 denominator = self.poolTokenSupply;

        if (numerator < denominator || denominator == 0) {
            return 0;
        }
        // TODO: later also take remainder into consideration
        return numerator / denominator;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IAddressStore {
    function setAddr(string memory key, address value) external;

    function setTimelockedAdmin(address addr) external;

    function setStkBNB(address addr) external;

    function setFeeVault(address addr) external;

    function setStakePool(address addr) external;

    function setUndelegationHolder(address addr) external;

    function getAddr(string calldata key) external view returns (address);

    function getTimelockedAdmin() external view returns (address);

    function getStkBNB() external view returns (address);

    function getFeeVault() external view returns (address);

    function getStakePool() external view returns (address);

    function getUndelegationHolder() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "./IBEP20.sol";

interface IStakedBNBToken is IERC777, IBEP20 {
    function mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) external;

    function pause() external;

    function unpause() external;

    function selfDestruct() external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

/**
 * @title StakePool Bot
 * @dev The functionalities required from the StakePool contract by the bot. This contract should
 * be implemented by the StakePool contract.
 */
interface IStakePoolBot {
    /**
     * @dev The amount that needs to be unbonded in the next unstaking epoch.
     * It increases on every user unstake operation, and decreases when the bot initiates unbonding.
     * This is queried by the bot in order to initiate unbonding.
     * It is int256, not uint256 because bnbUnbonding can be more than it and is subtracted from it.
     * So, if it is < 0, means we have already initiated unbonding for that much amount and eventually
     * that amount would be part of claimReserve. So, we don't need to unbond anything new on the BBC
     * side as long as this value is negative.
     *
     * Increase frequency: anytime
     * Decrease frequency & Bot query frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     */
    function bnbToUnbond() external view returns (int256);

    /**
     * @dev The amount of BNB that is unbonding in the current unstaking epoch.
     * It increases when the bot initiates unbonding, and decreases when the unbonding is finished.
     * It is queried by the bot before calling unbondingFinished(), to figure out the amount that
     * needs to be moved from BBC to BSC.
     *
     * Increase, Decrease & Bot query frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     */
    function bnbUnbonding() external view returns (uint256);

    /**
     * @dev A portion of the contract balance that is reserved in order to satisfy the claims
     * for which the cooldown period has finished. This will never be sent to BBC for staking.
     * It increases when the unbonding is finished, and decreases when any user actually claims
     * their BNB.
     *
     * Increase frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     * Decrease frequency: anytime
     */
    function claimReserve() external view returns (uint256);

    /**
     * @dev This is called by the bot in order to transfer the stakable BNB from contract to the
     * staking address on BC.
     * Call frequency:
     *      Mainnet: Daily
     *      Testnet: Daily
     */
    function initiateDelegation() external;

    /**
     * @dev Called by the bot to update the exchange rate in contract based on the rewards
     * obtained in the BC staking address and accordingly mint fee tokens.
     * Call frequency:
     *      Mainnet: Daily
     *      Testnet: Daily
     *
     * @param bnbRewards: The amount of BNB which were received as staking rewards.
     */
    function epochUpdate(uint256 bnbRewards) external;

    /**
     * @dev This is called by the bot after it has executed the unbond transaction on BBC.
     * Call frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     *
     * @param bnbUnbonding: The amount of BNB for which unbonding was initiated on BC.
     *                      It can be more than bnbToUnbond, but within a factor of min undelegation amount.
     */
    function unbondingInitiated(uint256 bnbUnbonding) external;

    /**
     * @dev Called by the bot after the unbonded amount for claim fulfilment is received in BBC
     * and has been transferred to the UndelegationHolder contract on BSC.
     * It calls UndelegationHolder.withdrawUnbondedBNB() to fetch the unbonded BNB to itself and
     * update `bnbUnbonding` and `claimReserve`.
     * Call frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     */
    function unbondingFinished() external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface ITokenHub {
    function getMiniRelayFee() external view returns (uint256);

    function getBoundContract(string memory bep2Symbol) external view returns (address);

    function getBoundBep2Symbol(address contractAddr) external view returns (string memory);

    function transferOut(
        address contractAddr,
        address recipient,
        uint256 amount,
        uint64 expireTime
    ) external payable returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 * @title Undelegation Holder interface
 *
 * @dev This contract temporarily holds the undelegated amount transferred from the BC staking
 * address before it is transferred to the StakePool contract to fulfil claimReserve. This is
 * needed to ensure that all the amount transferred from the BC staking address to BSC gets
 * correctly reflected in the StakePool claimReserve without any loss of funds in-between.
 * This has following benefits:
 * - Less dependence on bot. Lesser the amount of time funds remain with a custodial address managed
 *   by the bot, greater the security.
 * - In case of an emergency situation like bot failing to undelegate timely, or some security
 *   mishap with the staking address on BC, funds can be added directly to this contract to
 *   satisfy user claims.
 * - Possibility to replace this contract with a TSS managed address in future, if needed.
 */
interface IUndelegationHolder {
    // @dev Emitted when receive function is called.
    event Received(address sender, uint256 amount);

    /**
     * @dev Called by the TokenHub contract when undelegated funds are transferred cross-chain by
     * bot from BC staking address to this contract on BSC.
     */
    receive() external payable;

    /**
     * @dev Called by the StakePool contract to withdraw the undelegated funds. It sends all its
     * funds to StakePool.
     *
     * Requirements:
     * - The caller must be the StakePool contract.
     *
     * @return The current balance, all of which it will be sending to the StakePool.
     */
    function withdrawUnbondedBNB() external returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {
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
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
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
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
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
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

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

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
interface IERC165Upgradeable {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./BasisFee.sol";

library FeeDistribution {
    using BasisFee for uint256;

    struct Data {
        uint256 reward;
        uint256 deposit;
        uint256 withdraw;
    }

    function _checkValid(Data calldata self) internal pure {
        self.reward._checkValid();
        self.deposit._checkValid();
        self.withdraw._checkValid();
    }

    function _set(Data storage self, Data calldata obj) internal {
        self.reward = obj.reward;
        self.deposit = obj.deposit;
        self.withdraw = obj.withdraw;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC777/IERC777.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC777Token standard as defined in the EIP.
 *
 * This contract uses the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 registry standard] to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See {IERC1820Registry} and
 * {ERC1820Implementer}.
 */
interface IERC777 {
    /**
     * @dev Emitted when `amount` tokens are created by `operator` and assigned to `to`.
     *
     * Note that some additional user `data` and `operatorData` can be logged in the event.
     */
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    /**
     * @dev Emitted when `operator` destroys `amount` tokens from `account`.
     *
     * Note that some additional user `data` and `operatorData` can be logged in the event.
     */
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    /**
     * @dev Emitted when `operator` is made operator for `tokenHolder`
     */
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    /**
     * @dev Emitted when `operator` is revoked its operator status for `tokenHolder`
     */
    event RevokedOperator(address indexed operator, address indexed tokenHolder);

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the smallest part of the token that is not divisible. This
     * means all token operations (creation, movement and destruction) must have
     * amounts that are a multiple of this number.
     *
     * For most token contracts, this value will equal 1.
     */
    function granularity() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by an account (`owner`).
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * If send or receive hooks are registered for the caller and `recipient`,
     * the corresponding functions will be called with `data` and empty
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev Destroys `amount` tokens from the caller's account, reducing the
     * total supply.
     *
     * If a send hook is registered for the caller, the corresponding function
     * will be called with `data` and empty `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     */
    function burn(uint256 amount, bytes calldata data) external;

    /**
     * @dev Returns true if an account is an operator of `tokenHolder`.
     * Operators can send and burn tokens on behalf of their owners. All
     * accounts are their own operator.
     *
     * See {operatorSend} and {operatorBurn}.
     */
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    /**
     * @dev Make an account an operator of the caller.
     *
     * See {isOperatorFor}.
     *
     * Emits an {AuthorizedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function authorizeOperator(address operator) external;

    /**
     * @dev Revoke an account's operator status for the caller.
     *
     * See {isOperatorFor} and {defaultOperators}.
     *
     * Emits a {RevokedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function revokeOperator(address operator) external;

    /**
     * @dev Returns the list of default operators. These accounts are operators
     * for all token holders, even if {authorizeOperator} was never called on
     * them.
     *
     * This list is immutable, but individual holders may revoke these via
     * {revokeOperator}, in which case {isOperatorFor} will return false.
     */
    function defaultOperators() external view returns (address[] memory);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient`. The caller must
     * be an operator of `sender`.
     *
     * If send or receive hooks are registered for `sender` and `recipient`,
     * the corresponding functions will be called with `data` and
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - `sender` cannot be the zero address.
     * - `sender` must have at least `amount` tokens.
     * - the caller must be an operator for `sender`.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     * The caller must be an operator of `account`.
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `data` and `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     * - the caller must be an operator for `account`.
     */
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 * @title Interface representing the additional functionalities in a BEP20 token as compared to ERC777.
 * @dev See: https://github.com/bnb-chain/BEPs/blob/master/BEP20.md
 * Only the `getOwner()` function is an additional thing needed in the stkBNB implementation.
 * Rest of the BEP20 interface is already part of ERC777.
 */
interface IBEP20 {
    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     * Emits the `OwnershipTransferred` event.
     *
     * Note that this is copied form the Ownable contract in Openzeppelin contracts.
     * We don't need rest of the functionalities from Ownable, including `renounceOwnership`
     * as we always want to have an owner for this contract.
     */
    function transferOwnership(address newOwner) external;

    /**
     * Emitted on `transferOwnership`.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}