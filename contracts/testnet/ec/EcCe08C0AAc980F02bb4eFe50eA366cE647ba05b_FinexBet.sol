// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/Ownable.sol";
import "./libraries/SafeERC20.sol";
import "./interfaces/IERC20.sol";

/**
 * @title FinexBet - Betting Contract
 * @notice Crypto Betting platform where punters can enter and predict the closing price for a betting event.
 * @author [email protected]
 */
contract FinexBet is Ownable {
    using SafeERC20 for IERC20;

    /////////////////////////
    ////// Events
    /////////////////////////

    event EventCreated(uint256 _eventId);
    event EventEnded(uint256 _eventId, uint256 _closingValue, uint256 _participantCount);
    event EventCancelled(uint256 _eventId);

    event Prediction(uint256 _eventId, address indexed _punter, uint256 _amount);

    event TokenContractUpdated(address _newTokenContract, address _oldTokenContract);
    event DelegateUpdated(address _newDelegate);

    /////////////////////////
    ////// Storage
    /////////////////////////

    string public constant NAME = "Finex Ultra Bets";
    /** Delegate of admin to perform some transactions on the platform on behalf of the admin */
    address public delegate;

    /**
     * @notice States for the smart contract.
     */
    enum State {
        NA,
        Running,
        /* BetClosed, */
        Ended,
        Cancelled
    }

    /**
     * @notice Type of pool the event can belong to.
     * Public is open for all. Private to only invited only. P2P is self-explained and public.
     * @dev These are just for on-chain representation and as such poses no use.
     * But the signatures are used for the betters to participate in them and differentiate between them.
     */
    enum Pool {
        Pulbic,
        Private,
        P2P
    }

    /**
     * @notice The different category of events that can be created.
     * They are only for representation but can be used to understand the nature of the prediction.
     * @dev Only SingleValueEntry makes use of the `stopValue` field.
     */
    enum Category {
        SingleValueEntry,
        UpOrDown,
        YesNo,
        Polling,
        MCQ
    }

    /**
     * @notice Meta data and some basic data for an event.
     */
    struct EventMeta {
        string domainCounter; // domain + counter (ex.- crp-eth / frx-usd / shr-amz)
        Category category; // category of event
        Pool pool; // type of the pool
        uint256 ticketCost; // cost of event participation in tokens
        uint256 poolAmount; // total pool amount added to an event
        address creator;
    }

    struct Predict {
        /*
         * This is the prediction made by the betters for an event.
         * For SingleValueEntry, the prediciton will be the future value of the counter.
         * For UpOrDown, YesNo and Polling, the prediction is the option number - 0,1,2,3,...
         * For MCQ, the prediction will be & (AND) of the selected options.
         *  Ex. - selecting 2 & 4 means 2^1 + 2^2 = 2 + 4 = 6
         */
        uint256 prediction;
        /*
         * Amount of tokens placed for bet on the prediction.
         */
        uint256 betAmount;
    }

    /**
     * Structure for Events.
     * Only meta data is stored on-chain.
     * Prize distribution is done off-chain and can be confirmed with on-chain data.
     */
    struct Event {
        EventMeta meta;
        /* By default its value is NA */
        State status;
        /* Time till better can place bets */
        uint64 betDuration;
        /* Time till event will run and it cannot be ended before this time */
        uint64 totalDuration;
        /* % age of winners - ex. 30% of the closest bets will be winner */
        uint8 winnerPercent;
        /* %age of amount in pool given to winners - ex. 50% of pool will be distributed to winners */
        uint8 prizePercent;
        /* %age amount of pool to be paid to platform as fees */
        uint8 platformFeePercent;
        /*
         * Denotes the decimals to use for percent and values.
         * ex. prizePercent=365 and valDecimals=2 means prizePercent is actually 3.65
         */
        uint8 valDecimals;
        /*
         * This value is of the time when the betting period ends.
         * But it is stored only when the event ends as it's not used
         * for anything other than saving data.
         * Its value will always be zero except for SingleValueEntry event.
         */
        uint16 stopValue;
        /*
         * This value is of the time when the event ends.
         * For MCQ, the limit is 16 options - 0 to 15 and are represented as powers of 2.
         * Ex. - Say there are 5 options (1,2,4,8,16) for MCQ and correct options are (2nd, 4th and 5th)
         * then closing value will be -> 26 (= 2+8+16)
         */
        uint16 closingValue;
        /*
         * Using mapping instead of array like `address[] participants` to
         * decrease gas cost on checking when only single participation is allowed.
         * Should only be used when the participation pool can be large (> 50).
         * Ref. - https://ethereum.stackexchange.com/questions/2592/store-data-in-mapping-vs-array
         */
        address[] participants;
        // eventHash => bidderAddress => Predict - prediction placed by punter
        mapping(address => Predict) prediction;
    }

    /** Number of successfully completed events. */
    uint256 public completedEvents;
    /** Incremental counter for the event. */
    uint256 public eventCounter;

    /**
     * The mapping of all the events.
     * The key is an incremental value - eventCounter.
     */
    mapping(uint256 => Event) public events;

    /** Address of the token contract address to be used for payments. */
    address public tokenContract;

    constructor(address _delegate) {
        delegate = _delegate;
    }

    modifier onlyOwnerOrDelegate() {
        require(_onlyOwnerOrDelegate(), "Caller is unauthorized");
        _;
    }

    function _onlyOwnerOrDelegate() private view returns (bool) {
        return msg.sender == owner() || msg.sender == delegate;
    }

    /////////////////////////
    ////// Getter functions
    /////////////////////////

    /**
     * @notice Get total number of participations of an event
     */
    function getParticipantsCount(uint256 _eventId) external view returns (uint256) {
        return events[_eventId].participants.length;
    }

    /**
     * @notice Get prediction of a user for an event
     */
    function getPrediction(uint256 _eventId, address _user) external view returns (uint256) {
        return events[_eventId].prediction[_user].prediction;
    }

    /**
     * @notice Get actual pool amount for an event that will get distributed.
     */
    function getPoolAmount(uint256 _eventId) external view returns (uint256) {
        return (((100 - events[_eventId].platformFeePercent) * events[_eventId].meta.poolAmount) /
            100);
    }

    /////////////////////////
    ////// Events
    /////////////////////////

    /**
     * @notice Creates and start an event.
     * Only owner or delegate can create an event.
     */
    function createEvent(
        string memory _domainCounter,
        Category _category,
        Pool _pool,
        uint256 _ticketCost,
        uint64 _betDuration,
        uint64 _totalDuration,
        uint8 _winnerPercent,
        uint8 _prizePercent,
        uint8 _platformFeePercent,
        uint8 _valDecimals
    ) public onlyOwnerOrDelegate {
        require(_winnerPercent < 100, "Incorrect winner percent");
        require(_prizePercent < 100, "Incorrect prize percent");
        require(events[eventCounter].status == State.NA, "Event not exist");

        Event storage eventDetails = events[eventCounter];
        eventDetails.meta.domainCounter = _domainCounter;
        eventDetails.meta.category = _category;
        eventDetails.meta.pool = _pool;
        eventDetails.status = State.Running;
        eventDetails.meta.ticketCost = _ticketCost;
        // solhint-disable-next-line not-rely-on-time
        eventDetails.betDuration = uint64(block.timestamp) + _betDuration;
        // solhint-disable-next-line not-rely-on-time
        eventDetails.totalDuration = uint64(block.timestamp) + _totalDuration;
        eventDetails.winnerPercent = _winnerPercent;
        eventDetails.prizePercent = _prizePercent;
        eventDetails.platformFeePercent = _platformFeePercent;
        eventDetails.valDecimals = _valDecimals;
        eventDetails.meta.creator = msg.sender;

        emit EventCreated(eventCounter);
        
        eventCounter++; // increase the counter for the next event
    }

    function createEventsBatch(
        string[] memory _domainCounter,
        Category[] memory _category,
        Pool[] memory _pool,
        uint256[] memory _ticketCost,
        uint64[] memory _betDuration,
        uint64[] memory _totalDuration,
        uint8[] memory _winnerPercent,
        uint8[] memory _prizePercent,
        uint8[] memory _platformFeePercent,
        uint8[] memory _valDecimals
    ) external onlyOwnerOrDelegate {
        for (uint256 i = 0; i < _domainCounter.length; i++) {
            createEvent(
                _domainCounter[i],
                _category[i],
                _pool[i],
                _ticketCost[i],
                _betDuration[i],
                _totalDuration[i],
                _winnerPercent[i],
                _prizePercent[i],
                _platformFeePercent[i],
                _valDecimals[i]
            );
        }
    }

    /**
     * @notice Place bet in an event.
     * Owner or delegate cannot place bet in an event.
     */
    function placeBet(uint256 _eventId, uint256 _prediction) external payable {
        Event storage currEvent = events[_eventId];
        require(currEvent.status == State.Running, "Event not running");
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp < currEvent.betDuration, "Bet period expired");
        require(currEvent.prediction[msg.sender].betAmount == 0, "Already predicted");
        require(currEvent.meta.ticketCost >= msg.value, "Not received ticket cost");
        require(!_onlyOwnerOrDelegate(), "Authority cannot predict");

        currEvent.participants.push(msg.sender);
        currEvent.prediction[msg.sender].prediction = _prediction;
        currEvent.prediction[msg.sender].betAmount = msg.value;
        emit Prediction(_eventId, msg.sender, _prediction);

        currEvent.meta.poolAmount += msg.value;
    }

    /**
     * @notice Ends an event and distribute the pool amount among bidders.
     * Only owner or delegate can end an event.
     */
    function endEvent(
        uint256 _eventId,
        uint16 _stopValue,
        uint16 _closingValue,
        address[] memory _bidders,
        uint256[] memory _tokenAmounts
    ) external onlyOwnerOrDelegate {
        Event storage currEvent = events[_eventId];
        require(currEvent.status == State.Running, "Event not running");
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= currEvent.totalDuration, "Event period not expired");

        currEvent.status = State.Ended;
        currEvent.stopValue = _stopValue;
        currEvent.closingValue = _closingValue;

        emit EventEnded(_eventId, _closingValue, currEvent.participants.length);

        uint256 platformFeeTokens = ((currEvent.platformFeePercent * currEvent.meta.poolAmount) /
            100);
        // tranfer platform fees to owner's account
        IERC20(tokenContract).safeTransfer(owner(), platformFeeTokens);
        // transfer remaining pool amount to bidders
        _distributeTokens(_bidders, _tokenAmounts, currEvent.meta.poolAmount - platformFeeTokens);
    }

    function _distributeTokens(
        address[] memory _bidders,
        uint256[] memory _tokenAmounts,
        uint256 _poolAmount
    ) internal {
        require(_bidders.length == _tokenAmounts.length, "Array length mismatch");
        IERC20 tokenContractAddress = IERC20(tokenContract);
        uint256 totalPoolAmount;
        for (uint256 i = 0; i < _bidders.length; i++) {
            // transfer amount to bidders
            tokenContractAddress.safeTransfer(_bidders[i], _tokenAmounts[i]);
            totalPoolAmount += _tokenAmounts[i];
        }
        require(totalPoolAmount == _poolAmount, "Incorrect distribution");
    }

    /**
     * @notice Cancels an event.
     * The full amount of bets placed are refunded to the participants.
     * Only owner or delegate can cancel an event.
     */
    function cancelEvent(uint256 _eventId) external onlyOwnerOrDelegate {
        Event storage currEvent = events[_eventId];
        require(currEvent.status == State.Running, "Event not running");
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp > currEvent.betDuration, "Bet period expired");

        currEvent.status = State.Cancelled;
        emit EventCancelled(_eventId);

        _refundTokens(_eventId);
    }

    function _refundTokens(uint256 _eventId) internal {
        Event storage currEvent = events[_eventId];
        address[] memory participants = currEvent.participants;

        for (uint256 i = 0; i < participants.length; i++) {
            IERC20(tokenContract).safeTransfer(
                participants[i],
                currEvent.prediction[participants[i]].betAmount
            );
        }
    }

    /////////////////////////
    ////// Platform
    /////////////////////////

    /**
     * @notice Updates the delegate address.
     * Only owner can update the delegate.
     */
    function updateDelegate(address _newDelegate) external onlyOwner {
        delegate = _newDelegate;
        emit DelegateUpdated(_newDelegate);
    }

    /**
     * @notice Updates the token contract address.
     * Only owner can update the contract address.
     */
    function updateTokenContract(address _newTokenContract) external onlyOwner {
        emit TokenContractUpdated(_newTokenContract, tokenContract);
        tokenContract = _newTokenContract;
    }

    /**
     * @notice Owner can transfer out any accidentally sent ERC20 tokens.
     * @param _tokenContract The contract address of ERC-20 compitable token.
     * @param _to The wallet/contract address to transfer tokens to.
     * @param _value The number of tokens to be transferred.
     */
    function transferERC20Token(
        address _tokenContract,
        address _to,
        uint256 _value
    ) external onlyOwner {
        require(_tokenContract != address(this), "Cannot withdraw to this address");
        IERC20(_tokenContract).safeTransfer(_to, _value);
    }

    /**
     * @notice Prevents contract from accepting ETHs.
     * @dev Contracts can still be sent ETH with self destruct.
     * If anyone deliberately does that, the ETHs will be lost.
     */
    receive() external payable {
        revert("Contract does not accept ethers");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IOwnable.sol";

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
contract Ownable is IOwnable {
    address private owner_;

    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Caller not owner");
        _;
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view override returns (address) {
        return owner_;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external override onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address _newOwner) public override onlyOwner {
        require(_newOwner != address(0), "New owner is zero address");
        _setOwner(_newOwner);
    }

    function _setOwner(address _newOwner) private {
        emit OwnershipTransferred(owner_, _newOwner);
        owner_ = _newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "./Address.sol";

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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        // functionCall(target, data, "Address: low-level call failed")
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * Utility library of inline functions on addresses
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
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

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
        return
            functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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
pragma solidity ^0.8.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
interface IOwnable {
    function owner() external view returns (address ownerAddress);

    function renounceOwnership() external;

    function transferOwnership(address _newOwner) external;
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