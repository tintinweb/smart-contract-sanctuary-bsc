// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/ILockerFactory.sol";

/**
 * @notice
 */
contract Locker is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 claimedAmount;
    }

    struct VoteInfo {
        uint256 amount;
    }

    struct ProposalInfo {
        uint256 id;
        uint256 unlockPercent;
        uint256 startTime;
        uint256 endTime;
        uint256 agree; // total agreed power
        uint256 disagree; // total disagreed power
        uint256 totalPower; // possible total power
        bool passed; // if passed or not
    }

    uint256 private constant MULTIPLIER = 1e4;
    uint256 private constant MIN_PROPOSAL_DURATION = 1 days;
    bool private initialized;
    uint256 private constant PROPOSAL_PASS_PERCENT = 5100; // 51%

    // The factory contract address
    ILockerFactory public factory;

    // uri of metadata
    string public uri;
    bool public isLP;

    // token address
    IERC20 public token;

    mapping(address => UserInfo) public userInfo;

    // proposalId => address => votedPower
    mapping(uint256 => mapping(address => uint256)) public userVote;

    // past proposals
    ProposalInfo[] public proposals;
    // current proposal
    ProposalInfo public proposal;

    // unlock by admin and project owner
    uint256 public suggestedUnlockPercent;

    // set by proposal, or factory and owner
    uint256 public unlockedPercent;

    // 0: simple lock, 1: vesting
    uint256 public lockType;

    // users can deposit funds before cliffTime or startTime
    // for vesting
    uint256 public cliffTime;
    uint256 public duration;
    uint256 public periodicity;
    // for linear lock
    uint256 public startTime;
    uint256 public endTime;

    uint256 public totalDeposited;
    uint256 public totalClaimed;

    event LockerInitialized(
        uint256 lockType,
        uint256 param1,
        uint256 param2,
        uint256 param3,
        address token,
        bool isLP,
        string uri
    );
    event UriChanged(string uri);

    event Deposit(address user, uint256 amount, address beneficiary);
    event Claim(address user, uint256 amount);

    event ProposalCreated(uint256 proposalId, uint256 percent, uint256 endTime);
    event UserVoted(address user, uint256 proposalId, uint256 power, bool agree);
    event ProposalFinalized(uint256 proposalId, uint256 status); // 0: failed, 1: passed
    event EmergencyUnlock(uint256 status, uint256 percent); // 0: by admin and factory, >0: proposalId
    event EmergencyUnlockSuggested(uint256 percent); //

    constructor() {
        factory = ILockerFactory(msg.sender);
    }

    modifier onlyFactory() {
        require(address(factory) == msg.sender, "Not factory");
        _;
    }

    /* external functions */

    /**
     * @notice initialize Locker
     *
     * @param _lockType: 0 => simple lock, 1 => vesting
     * @param _param1: cliffTime or startTime
     * @param _param2: duration or endTime
     * @param _param3: periodicity or 0
     * @param _token: token address
     * @param _isLP: true if it's lp token
     * @param _uri: meta data uri
     */
    function initialize(
        uint256 _lockType,
        uint256 _param1,
        uint256 _param2,
        uint256 _param3,
        address _token,
        bool _isLP,
        string memory _uri
    ) external onlyFactory {
        require(!initialized, "Already initialized");

        initialized = true;

        lockType = _lockType;
        token = IERC20(_token);
        uri = _uri;
        isLP = _isLP;

        if (lockType == 0) {
            startTime = _param1;
            endTime = _param2;
        } else {
            cliffTime = _param1;
            duration = _param2;
            periodicity = _param3;
        }

        emit LockerInitialized(lockType, _param1, _param2, _param3, address(token), isLP, uri);
    }

    /**
     * @notice update metadata uri
     *
     * @param _uri: metadata uri
     */
    function setUri(string memory _uri) external onlyOwner {
        uri = _uri;

        emit UriChanged(uri);
    }

    /**
     * @notice deposit amount of token
     *
     * @param amount: token amount
     */
    function deposit(uint256 amount) external {
        _deposit(msg.sender, amount, msg.sender);
    }

    /**
     * @notice deposit amount of token for beneficiary
     *
     * @param amount: token amount
     * @param beneficiary: beneficiary user
     */
    function depositFor(uint256 amount, address beneficiary) external {
        require(beneficiary != address(0), "Invalid beneficiary");

        _deposit(msg.sender, amount, beneficiary);
    }

    /**
     * @notice claim available tokens
     */
    function claim() external nonReentrant {
        uint256 claimableAmount = getClaimableAmount(msg.sender);

        token.safeTransfer(msg.sender, claimableAmount);

        totalClaimed += claimableAmount;
        userInfo[msg.sender].claimedAmount += claimableAmount;

        emit Claim(msg.sender, claimableAmount);
    }

    /**
     * @notice project owner suggested unlock percent
     */
    function suggestUnlock(uint256 _suggestedUnlockPercent) external payable onlyOwner nonReentrant {
        require(_suggestedUnlockPercent > unlockedPercent, "Invalid _suggestedUnlockPercent");
        suggestedUnlockPercent = _suggestedUnlockPercent;

        (address feeRecipient, , uint256 emergencyUnlockFee) = factory.getFeeInfo();
        require(msg.value == emergencyUnlockFee, "Insufficient fee");
        feeRecipient.call{ value: emergencyUnlockFee }("");

        emit EmergencyUnlockSuggested(suggestedUnlockPercent);
    }

    /**
     * @notice Factory approve suggest unlock percent by project owner
     */
    function approveSuggestedUnlock() external onlyFactory {
        require(suggestedUnlockPercent > unlockedPercent, "Invalid");
        unlockedPercent = suggestedUnlockPercent;
        suggestedUnlockPercent = 0;

        emit EmergencyUnlock(0, unlockedPercent);
    }

    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }

    function getProposals() external view returns (ProposalInfo[] memory) {
        return proposals;
    }

    /**
     * @notice start a proposal to unlock certain percent
     */
    function startProposal(uint256 _unlockPercent, uint256 _endTime) external onlyOwner {
        require(proposal.id == 0, "Can't init a proposal");
        require(_unlockPercent > unlockedPercent, "Invalid _unlockPercent");
        require(_endTime >= block.timestamp + MIN_PROPOSAL_DURATION, "Invalid _endTime");

        proposal.id = proposals.length + 1;
        proposal.unlockPercent = _unlockPercent;
        proposal.startTime = block.timestamp;
        proposal.endTime = _endTime;
        proposal.totalPower = totalDeposited - getUnlockedAmount(totalDeposited);
        proposal.passed = false;

        emit ProposalCreated(proposal.id, proposal.unlockPercent, proposal.endTime);
    }

    /**
     * @notice user votes to a proposal with power
     *
     * @param agree: true/false
     */
    function vote(uint256 power, bool agree) external nonReentrant {
        require(proposal.endTime >= block.timestamp, "Not active");
        uint256 userVoted = userVote[proposal.id][msg.sender];
        require(userVoted + power <= getVotingPower(msg.sender), "Invalid power");

        userVote[proposal.id][msg.sender] += power;

        if (agree) {
            proposal.agree += power;
        } else {
            proposal.disagree += power;
        }

        emit UserVoted(msg.sender, proposal.id, power, agree);
    }

    /**
     * @notice end a proposal
     */
    function endProposal() external onlyOwner {
        require(proposal.id > 0, "No active proposal");
        uint256 passPower = (proposal.totalPower * PROPOSAL_PASS_PERCENT) / MULTIPLIER;

        if (proposal.agree >= passPower) {
            unlockedPercent = proposal.unlockPercent;
            proposal.passed = true;

            emit ProposalFinalized(proposal.id, 1);
            emit EmergencyUnlock(1, unlockedPercent);
        } else {
            require(proposal.disagree >= passPower || proposal.endTime <= block.timestamp, "Can't end yet");
            proposal.passed = false;

            emit ProposalFinalized(proposal.id, 0);
        }

        proposal.endTime = block.timestamp;

        proposals.push(proposal);

        delete proposal;
    }

    /**
     * @notice recover any token on this contract
     * @dev
     *
     * @param _token: address of token to recover
     */
    function recoverToken(IERC20 _token) external onlyFactory {
        require(token != _token, "Not wrong token");
        uint256 bal = _token.balanceOf(address(this));
        _token.transfer(msg.sender, bal);
    }

    /**
     * @notice recover any bnb on this contract
     * @dev
     */
    function recoverBNB() external onlyFactory {
        uint256 bal = address(this).balance;
        msg.sender.call{ value: bal }("");
    }

    /* public functions */

    function getClaimableAmount(address user) public view returns (uint256) {
        return getUnlockedAmount(userInfo[user].amount) - userInfo[user].claimedAmount;
    }

    function getVotingPower(address user) public view returns (uint256) {
        return userInfo[user].amount - getUnlockedAmount(userInfo[user].amount);
    }

    /* internal functions */

    function getUnlockedAmount(uint256 amount) public view returns (uint256) {
        uint256 unlockedAmount;

        if (lockType == 0) {
            // linear lock
            if (block.timestamp >= endTime) {
                unlockedAmount = amount;
            } else if (block.timestamp >= startTime) {
                unlockedAmount = (amount * (block.timestamp - startTime)) / (endTime - startTime);
            }
        } else {
            // vesting
            if (block.timestamp >= cliffTime + duration) {
                unlockedAmount = amount;
            } else if (block.timestamp >= cliffTime) {
                uint256 periodicityCount = duration / periodicity;
                uint256 periodicityAmount = amount / periodicityCount;
                unlockedAmount = ((block.timestamp - cliffTime) / periodicity) * periodicityAmount;
            }
        }

        uint256 emergencyUnlockedAmount = (amount * unlockedPercent) / MULTIPLIER;

        return (unlockedAmount > emergencyUnlockedAmount ? unlockedAmount : emergencyUnlockedAmount);
    }

    function _deposit(
        address funder,
        uint256 amount,
        address beneficiary
    ) internal nonReentrant {
        // for fee token
        uint256 bal = token.balanceOf(address(this));
        token.safeTransferFrom(funder, address(this), amount);
        uint256 realAmount = token.balanceOf(address(this)) - bal;

        userInfo[beneficiary].amount += realAmount;

        totalDeposited += realAmount;

        emit Deposit(funder, realAmount, beneficiary);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

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

    constructor () {
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

// SPDX-License-Identifier: MIT

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILockerFactory {
    function getFeeInfo()
        external
        view
        returns (
            address,
            uint256,
            uint256
        );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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