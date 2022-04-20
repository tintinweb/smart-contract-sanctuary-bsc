// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import '../interfaces/IERC20.sol';
import '../libraries/SafeERC20.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

/*
 * Allow whitelisted users to purchase outputToken using inputToken via the medium of tickets
 * Purchasing tickets with the inputToken is mediated by the INPUT_RATE and
 * withdrawing tickets for the outputToken is mediated by the OUTPUT_RATE
 * 
 * Purchasing occurs over 2 purchase phases:
 *  1: purchases are limited by a maxTicket account attribute
 *  2: purchases are unlimited
 * 
 * Further purchases are prohibited after purchase phase 2 ends
 * The withdraw phase begins after the purchase phase ends
 * 
 * Withdrawing occurs over 4 withdraw phases:
 *  1: withrawals are limited to 25% of tickets purchased
 *  2: withrawals are limited to 50% of tickets purchased
 *  3: withrawals are limited to 75% of tickets purchased
 *  4: withrawals are unlimited
 */
contract VipPresale is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Information about whitelisted users tickets
    struct User {
        uint maxTicket;         // sets purchase phase 1 upper limit on ticket purchases
        uint purchased;         // tickets purchased, invariant: purchased <= maxTicket
        uint balance;           // tickets purchased but not withdrawn
    }

    // Maximum number of tickets available for purchase at the start of the sale
    uint public TICKET_MAX;

    // Minimum number of tickets that can be purchased at a time
    uint public MINIMUM_TICKET_PURCHASE;

    // Unsold tickets available for purchase
    // ticketsAvailable = TICKET_MAX - (sum(user.purchased) for user in whitelist)
    // where user.purchased is in range [0, user.maxTicket] for user in whitelist
    uint public ticketsAvailable;

    // Unsold tickets out of the maximum that have been reserved to users
    // Used to prevent promising more tickets to users than are available
    // ticketsReserved = (sum(user.maxTicket) for user in whitelist)
    // and ticketsReserved <= ticketsAvailable <= TICKET_MAX
    uint public ticketsReserved;

    // Token exchanged to purchase tickets, i.e. BUSD
    IERC20 public inputToken;

    // Number of tickets a user gets per `inputToken`
    uint public INPUT_RATE;

    // Token being sold in presale and redeemable by exchanging tickets, i.e. HELIX
    IERC20 public outputToken;

    // Number of `outputTokens` a user gets per ticket
    uint public OUTPUT_RATE;
    
    // Number of decimals on the `inputToken` used for calculating ticket exchange rates
    uint public INPUT_TOKEN_DECIMALS;

    // Number of decimals on the `outputToken` used for calculating ticket exchange rates
    uint public OUTPUT_TOKEN_DECIMALS;

    // Address that receives `inputToken`s sold in exchange for tickets
    address public treasury;

    /*
     * Purchase phase determines ticket purchases using `inputToken` by whitelisted users 
     *  0: is the default on contract creation
     *     purchases are prohibited
     *  1: manually set by the owner
     *     purchases are limited by a user's `maxTicket` 
     *  2: begins automatically PURCHASE_PHASE_DURATION after the start of purchase phase 1
     *     purchases are unlimited
     */
    uint public PURCHASE_PHASE_START;           // Phase when purchasing starts
    uint public PURCHASE_PHASE_END;             // Last phase before purchasing ends
    uint public PURCHASE_PHASE_DURATION;        // Length of time for a purchasePhase, 86400 == 1 day
    uint public purchasePhase;                  // Current purchasePhase
    uint public purchasePhaseEndTimestamp;      // Timestamp after which the current purchasePhase has ended
    
    /* 
     * Withdraw phase determines ticket withdrawals for `outputToken` by whitelisted users
     *  0: default on contract creation
     *     sales are prohibited
     *  1: started manually by the owner 
     *     sales are prohibited
     *  2: withdraw up to 25% of purchased tickets
     *  3: withdraw up to 50% of purchased tickets
     *  4: withdraw up to 75% of purchased tickets
     *  5: withdraw up to 100% of purchased tickets
     * 
     * After withdraw phase 1 is started, subsequent withdraw phases automatically 
     * begin `WITHDRAW_PHASE_DURATION` after the start of the previous withdraw phase
     */
    uint public WITHDRAW_PHASE_START;           // Phase when withdrawing starts 
    uint public WITHDRAW_PHASE_END;             // Last withdraw phase, does not end withdrawing
    uint public WITHDRAW_PHASE_DURATION;        // Length of time for a withdrawPhase, 86400 == 1 day
    uint public withdrawPhase;                  // Current withdrawPhase
    uint public withdrawPhaseEndTimestamp;      // Timestamp after which the current withdrawPhase has ended

    uint public WITHDRAW_PERCENT;               // Used as the denominator when calculating withdraw percent

    // if true, users cannot purchase or withdraw but owner can remove
    // else if false, users can purchase or withdraw depending on phase
    // but owner cannot withdraw
    bool public isPaused;

    // Owners who can whitelist users
    address[] public owners;

    // true if address is an owner and false otherwise
    mapping(address => bool) public isOwner;

    // true if user can purchase tickets and false otherwise
    mapping(address => bool) public whitelist;

    // relates user addresses to their struct
    mapping(address => User) public users;
    
    // relates a withdrawPhase to the percent of purchased tickets a user may withdraw during that withdrawPhase
    mapping (uint => uint) public withdrawPhasePercent;
    
    event SetPurchasePhase(uint purchasePhase, uint startTimestamp, uint endTimestamp);
    event SetWithdrawPhase(uint withdrawPhase, uint startTimestamp, uint endTimestamp);

    modifier isValidPurchasePhase(uint phase) {
        require(phase <= PURCHASE_PHASE_END, "VipPresale: PHASE EXCEEDS PURCHASE PHASE END");
        _;
    }

    modifier isValidWithdrawPhase(uint phase) {
        require(phase <= WITHDRAW_PHASE_END, "VipPresale: PHASE EXCEEDS WITHDRAW PHASE END");
        _;
    }

    modifier isValidAddress(address _address) {
        require(_address != address(0), "VipPresale: INVALID ADDRESS");
        _;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "VipPresale: CALLER IS NOT OWNER");
        _;
    }

    constructor(
        address _inputToken,
        address _outputToken, 
        address _treasury,
        uint _INPUT_RATE, 
        uint _OUTPUT_RATE,
        uint _PURCHASE_PHASE_DURATION,
        uint _WITHDRAW_PHASE_DURATION
    ) 
        isValidAddress(_inputToken)
        isValidAddress(_outputToken)
        isValidAddress(_treasury)
    {
        inputToken = IERC20(_inputToken);
        outputToken = IERC20(_outputToken);

        INPUT_RATE = _INPUT_RATE;
        OUTPUT_RATE = _OUTPUT_RATE;

        treasury = _treasury;

        isOwner[msg.sender] = true;
        owners.push(msg.sender);

        INPUT_TOKEN_DECIMALS = 1e18;
        OUTPUT_TOKEN_DECIMALS = 1e18;

        TICKET_MAX = 50000;
        ticketsAvailable = TICKET_MAX;
        MINIMUM_TICKET_PURCHASE = 1;

        PURCHASE_PHASE_START = 1;
        PURCHASE_PHASE_END = 2;
        PURCHASE_PHASE_DURATION = _PURCHASE_PHASE_DURATION;

        WITHDRAW_PHASE_START = 1;
        WITHDRAW_PHASE_END = 5;
        WITHDRAW_PHASE_DURATION = _WITHDRAW_PHASE_DURATION;

        withdrawPhasePercent[2] = 25;       // 25%
        withdrawPhasePercent[3] = 50;       // 50%
        withdrawPhasePercent[4] = 75;       // 75%
        withdrawPhasePercent[5] = 100;      // 100%
        WITHDRAW_PERCENT = 100;             // the denominator, withdrawPhasePercent[x]/WITHDRAW_PERCENT
    }

    // purchase `amount` of tickets
    function purchase(uint amount) external nonReentrant {
        // want to be in the latest phase
        _updatePurchasePhase();
   
        // proceed only if the purchase is valid
        _validatePurchase(msg.sender, amount);

        // get the `inputTokenAmount` in `inputToken` to purchase `amount` of tickets
        uint tokenAmount = getAmountOut(amount, inputToken); 

        require(
            tokenAmount <= inputToken.balanceOf(msg.sender), 
            "VipPresale: INSUFFICIENT TOKEN BALANCE"
        );
        require(
            tokenAmount <= inputToken.allowance(msg.sender, address(this)),
            "VipPresale: INSUFFICIENT ALLOWANCE"
        );
        inputToken.safeTransferFrom(msg.sender, treasury, tokenAmount);

        users[msg.sender].purchased += amount;
        users[msg.sender].balance += amount;

        ticketsAvailable -= amount;
    }

    // validate that `user` is eligible to purchase `amount` of tickets
    function _validatePurchase(address user, uint amount) private view isValidAddress(user) {
        require(!isPaused, "VipPresale: SALE IS PAUSED");
        require(purchasePhase >= PURCHASE_PHASE_START, "VipPresale: SALE HAS NOT STARTED");
        require(whitelist[user], "VipPresale: USER IS NOT WHITELISTED");
        require(amount >= MINIMUM_TICKET_PURCHASE, "VipPresale: AMOUNT IS LESS THAN MINIMUM TICKET PURCHASE");
        require(amount <= ticketsAvailable, "VipPresale: TICKETS ARE SOLD OUT");
        if (purchasePhase == PURCHASE_PHASE_START) { 
            require(
                users[user].purchased + amount <= users[user].maxTicket, 
                "VipPresale: AMOUNT EXCEEDS MAX TICKET LIMIT"
            );
        } else {
            require(block.timestamp < purchasePhaseEndTimestamp, "VipPresale: SALE HAS ENDED");
        }
    }

    // get `amountOut` of `tokenOut` for `amountIn` of tickets
    function getAmountOut(uint amountIn, IERC20 tokenOut) public view returns(uint amountOut) {
        if (address(tokenOut) == address(inputToken)) {
            amountOut = amountIn * INPUT_RATE * INPUT_TOKEN_DECIMALS;
        } else if (address(tokenOut) == address(outputToken)) {
            amountOut = amountIn * OUTPUT_RATE * OUTPUT_TOKEN_DECIMALS;
        } else {
            amountOut = 0;
        }
    }

    // used to destroy `outputToken` equivalant in value to `amount` of tickets
    // should only be used after purchasePhase 2 ends
    function burn(uint amount) external onlyOwner { 
        // remove `amount` of tickets
        _remove(amount);

        // get the `tokenAmount` equivalent in value to `amount` of tickets
        uint tokenAmount = getAmountOut(amount, outputToken);
        outputToken.burn(address(this), tokenAmount);
    }

    // used to withdraw `outputToken` equivalent in value to `amount` of tickets to `to`
    function withdraw(uint amount) external {
        // want to be in the latest phase
        _updateWithdrawPhase();

        // remove `amount` of tickets
        _remove(amount);

        // get the `tokenAmount` equivalent in value to `amount` of tickets
        uint tokenAmount = getAmountOut(amount, outputToken);
        outputToken.safeTransfer(msg.sender, tokenAmount);
    }

    // used internally to remove `amount` of tickets from circulation
    function _remove(uint amount) private {
        // proceed only if the removal is valid
        _validateRemoval(msg.sender, amount);

        if (isOwner[msg.sender]) {
            // if the caller is an owner, they won't have purchased tickets
            // so we need to decrease the tickets available by the amount being removed
            ticketsAvailable -= amount;
        } else {
            // otherwise, the user will have purchased tickets and the tickets available
            // will already have been updated so we only need to decrease their balance
            users[msg.sender].balance -= amount;
        }
    }

    // validate whether `amount` of tickets are removable by address `by`
    function _validateRemoval(address by, uint amount) private view {
        require(amount <= ticketsAvailable, "VipPresale: INSUFFICIENT CONTRACT BALANCE TO REMOVE");
        require(amount <= maxRemovable(by), "VipPresale: INSUFFICIENT ACCOUNT BALACE TO REMOVE");
    }

    // returns `maxAmount` removable by address `by`
    function maxRemovable(address by) public view returns(uint maxAmount) {
        if (isOwner[by]) {
            // owner can remove all of the tokens available
            maxAmount = isPaused ? ticketsAvailable : 0;
        } else {
            if (isPaused) {
                maxAmount = 0;
            } else {
                // Max number of tickets user can withdraw as a function of withdrawPhase and 
                // number of tickets purchased
                uint allowed = users[by].purchased * withdrawPhasePercent[withdrawPhase] / WITHDRAW_PERCENT;

                // Number of tickets remaining in their balance
                uint balance = users[by].balance;
        
                // Can only only withdraw the max allowed if they have a large enough balance
                maxAmount = balance < allowed ? balance : allowed;
            }
        }
    }

    // returns true if `amount` is removable by address `by`
    function isRemovable(address by, uint amount) external view returns(bool) {
        _validateRemoval(by, amount);
        return true;
    }
 
    // add a new owner to the contract, only callable by an existing owner
    function addOwner(address owner) external isValidAddress(owner) onlyOwner {
        require(!isOwner[owner], "VipPresale: ALREADY AN OWNER");
        isOwner[owner] = true;
        owners.push(owner);
    }

    // return the address array of registered owners
    function getOwners() external view returns(address[] memory) {
        return owners;
    }

    // Stop user purchases and withdrawals, enable owner withdrawals
    function pause() external onlyOwner {
        isPaused = true;
    }

    function unpause() external onlyOwner {
        isPaused = false;
    }

    // called periodically and, if sufficient time has elapsed, update the purchasePhase
    function updatePurchasePhase() external {
        _updatePurchasePhase();
    }

    function _updatePurchasePhase() private {
        if (block.timestamp >= purchasePhaseEndTimestamp) {
            if (purchasePhase >= PURCHASE_PHASE_START && purchasePhase < PURCHASE_PHASE_END) {
                _setPurchasePhase(purchasePhase + 1);
            }
        }
    }

    // used externally to update from purchasePhase 0 to purchasePhase 1
    // should only ever be called to set purchasePhase == 1
    function setPurchasePhase(uint phase) external onlyOwner isValidPurchasePhase(phase) {
        _setPurchasePhase(phase);
    }

    // used internally to update purchasePhases
    function _setPurchasePhase(uint phase) private {
        purchasePhase = phase;
        purchasePhaseEndTimestamp = block.timestamp + PURCHASE_PHASE_DURATION;
        emit SetPurchasePhase(phase, block.timestamp, purchasePhaseEndTimestamp);
    }

    // called periodically and, if sufficient time has elapsed, update the withdrawPhase
    function updateWithdrawPhase() external {
        _updateWithdrawPhase();
    }

    function _updateWithdrawPhase() private {
        if (block.timestamp >= withdrawPhaseEndTimestamp) {
            if (withdrawPhase >= WITHDRAW_PHASE_START && withdrawPhase < WITHDRAW_PHASE_END) {
                _setWithdrawPhase(withdrawPhase + 1);
            }
        }
    }

    // used externally to update from withdrawPhase 0 to withdrawPhase 1
    // should only ever be called to set withdrawPhase == 1
    function setWithdrawPhase(uint phase) external onlyOwner isValidWithdrawPhase(phase) {
        _setWithdrawPhase(phase);
    }

    // used internally to update withdrawPhases
    function _setWithdrawPhase(uint phase) private {
        withdrawPhase = phase;
        withdrawPhaseEndTimestamp = block.timestamp + WITHDRAW_PHASE_DURATION;
        emit SetWithdrawPhase(phase, block.timestamp, withdrawPhaseEndTimestamp);
    }
   
    // used externally to grant multiple `_users` permission to purchase `maxTickets`
    // such that _users[i] can purchase maxTickets[i] many tickets for i in range _users.length
    function whitelistAdd(address[] calldata _users, uint[] calldata maxTickets) external onlyOwner {
        require(_users.length == maxTickets.length, "VipPresale: USERS AND MAX TICKETS MUST HAVE SAME LENGTH");
        for (uint i = 0; i < _users.length; i++) {
            address user = _users[i];
            uint maxTicket = maxTickets[i];
            _whitelistAdd(user, maxTicket);
        }
    }

    // used internally to grant `user` permission to purchase up to `maxTicket`, purchasePhase dependent
    function _whitelistAdd(address user, uint maxTicket) private isValidAddress(user) {
        require(maxTicket <= ticketsAvailable, "VipPresale: MAX TICKET CAN'T BE GREATER THAN TICKETS AVAILABLE");
        require(!whitelist[user], "VipPresale: USER IS ALREADY WHITELISTED");
        whitelist[user] = true;
        users[user].maxTicket = maxTicket;

        require(ticketsReserved + maxTicket <= ticketsAvailable, "VipPresale: INADEQUATE TICKETS FOR ALL USERS");
        ticketsReserved += maxTicket;
    }

    // revoke permission for `user` to purchase tickets
    function whitelistRemove(address user) external onlyOwner {
        // prohibit a whitelisted user from purchasing tickets
        // but not from withdrawing those they've already purchased
        whitelist[user] = false;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.8.0;

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
    function burn(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity >=0.8.0;

import "../interfaces/IERC20.sol";
import '@openzeppelin/contracts/utils/Address.sol';

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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