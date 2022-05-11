/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// File: contracts/interfaces/ICoinFlipRNG.sol


pragma solidity ^0.8.4;

interface ICoinFlipRNG {
    
    // returns 1, or 0, randomly. 
    function flipCoin() external view returns (uint256);

    // generates new random number.
    function requestRandomWords() external;
    
}
// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: contracts/CoinFlip.sol


pragma solidity ^0.8.13;





// contract that allows users to bet on a coin flip. RNG contract must be deployed first. 

contract CoinFlip is Ownable, ReentrancyGuard {

    //----- Interfaces/Addresses -----

    ICoinFlipRNG public CoinFlipRNG;
    address public CoinFlipRNGAddress;
    address public Apple;

    //----- Mappings -----------------

    mapping(address => mapping(uint256 => Bet)) private Bets; // keeps track of each players bet for each sessionId
    mapping(address => mapping(uint256 => bool)) HasBet; // keeps track of whether or not a user has bet in a certain session #
    mapping(address => mapping(uint256 => bool)) HasClaimed; // keeps track of users and whether or not they have claimed reward for a session
    mapping(address => mapping(uint256 => uint256)) PlayerRewardPerSession; // keeps track of player rewards per session
    mapping(uint256 => Session) private _sessions;

    //----- Lottery State Variables ---------------

    uint256 public maxDuration = 30 seconds;
    uint256 public minDuration = 5 seconds;
    uint256 public constant maxDevFee = 100;
    uint256 currentSessionId;

    // status for betting sessions
    enum Status {
        Closed,
        Open,
        Standby,
        Disbursing
    }

    // player bet
    struct Bet {
        address player;
        uint256 amount; 
        uint8 choice; // (0) heads or (1) tails;
    }
    
    // params for each bet session
    struct Session {
        Status status;
        uint256 sessionId;
        uint256 startTime;
        uint256 endTime;
        uint256 minBet;
        uint256 maxBet;
        uint256 headsCount;
        uint256 tailsCount;
        uint256 collectedApple;
        uint256 totalPayouts;
        uint256 devFee;
        uint256 flipResult;
    }

    //----- Events --------------

    event SessionOpened(
        uint256 indexed sessionId,
        uint256 startTime,
        uint256 endTime,
        uint256 minBet,
        uint256 maxBet
    );

    event BetPlaced(
        address indexed player, 
        uint256 indexed sessionId, 
        uint256 amount,
        uint8 choice
    );

    event SessionClosed(
        uint256 indexed sessionId, 
        uint256 endTime,
        uint256 headsCount,
        uint256 tailsCount,
        uint256 collectedApple,
        uint256 totalPayouts
    );

    event CoinFlipped(
        uint256 flipResult
    );

    event RewardClaimed(
        address player,
        uint256 amount,
        uint256 sessionId
    );

    constructor(address _apple) {
        Apple = _apple;
    }

    //---------------------------- MODIFIERS-------------------------

    modifier notOwner() {
        require(msg.sender != owner() , "Owner not allowed!");
        _;
    }

    // @dev: disallows contracts from entering
    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    // @dev: returns the size of the code of an address. If >0, address is a contract. 
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    modifier isPending {
        require(_sessions[currentSessionId].status == Status.Standby, "Session is not pending!");
        _;
    }

    modifier isOpen {
        require(_sessions[currentSessionId].status == Status.Open, "Session is not open!");
        _;
    }

    modifier isClosed {
        require(_sessions[currentSessionId].status == Status.Closed, "Session is not closed!");
        _;
    }


    modifier isDisbursing {
        require(_sessions[currentSessionId].status == Status.Disbursing, "Session is not disbursing!");
        _;
    }

    // ------------------- Setters/Getters ------------------------

    // dev: set the address of the RNG contract interface
    function setRNGAddress(address _address) external onlyOwner {
        CoinFlipRNGAddress = (_address);
        CoinFlipRNG = ICoinFlipRNG(_address);
    }

    function setApple(address _apple) external onlyOwner {
        Apple = _apple;
    }

    function setMaxMinDuration(uint256 _max, uint256 _min) external onlyOwner {
        maxDuration = _max;
        minDuration = _min;
    }

    function getCurrentSessionId() external view onlyOwner returns (uint256) {
        return currentSessionId;
    }
    
    function viewSessionById(uint256 _sessionId) external view onlyOwner returns (Session memory) {
        return _sessions[_sessionId];
    }

    // ------------------- Coin Flip Functions ----------------------

    // @dev: generates a random number in the VRF contract. must be called before flipCoin() 
    // cannot be called unless the session.status is OPEN, impossible to place a bet after random number is chosen for that session.
    function generateRandomNumber() internal {
        CoinFlipRNG.requestRandomWords();
    }

    // @dev: return 1 or 0
    function flipCoin() internal returns (uint256) {
        uint256 result = CoinFlipRNG.flipCoin();
        _sessions[currentSessionId].status = Status.Standby;
        if (result == 0) {
            _sessions[currentSessionId].flipResult = 0;
        } else {
            _sessions[currentSessionId].flipResult = 1;
        }
        return result;
    }

    // ------------------- Bet Function ----------------------

    // heads = 0, tails = 1
    function bet(uint256 _amount, uint8 _choice) external {
        require(IERC20(Apple).balanceOf(address(msg.sender)) >= _amount);
        require(_amount >= _sessions[currentSessionId].minBet , "Must bet more than minimum amount!");
        require(_amount <= _sessions[currentSessionId].maxBet , "Must bet less than maximum amount!");
        require(_choice == 1 || _choice == 0, "Must choose 0 or 1!");
        require(!HasBet[msg.sender][currentSessionId] , "You have already bet in this session!");
        IERC20(Apple).transferFrom(address(msg.sender), address(this), _amount);
        _sessions[currentSessionId].collectedApple += _amount;

        if (_choice == 0) {
            Bets[msg.sender][currentSessionId].player = msg.sender;
            Bets[msg.sender][currentSessionId].amount = _amount;
            Bets[msg.sender][currentSessionId].choice = 0;
            _sessions[currentSessionId].headsCount++;
        } else {
            Bets[msg.sender][currentSessionId].player = msg.sender;
            Bets[msg.sender][currentSessionId].amount = _amount;
            Bets[msg.sender][currentSessionId].choice = 1;  
            _sessions[currentSessionId].tailsCount++;
        }

        HasBet[msg.sender][currentSessionId] = true;

        emit BetPlaced(
            msg.sender,
            currentSessionId,
            _amount,
            _choice
        );
    }

    // ------------------- Bet Function ---------------------- 

    function startSession(
        uint256 _endTime,
        uint256 _minBet,
        uint256 _maxBet,
        uint256 _devFee) 
        public 
        {
           require(
            (currentSessionId == 0) || (_sessions[currentSessionId].status == Status.Closed),
            "Not time to start lottery"
        );

        require(
            ((_endTime - block.timestamp) > minDuration) && ((_endTime - block.timestamp) < maxDuration),
            "Session length outside of range"
        );

        require(
            _devFee <= maxDevFee , "Dev fee is too high!"
        );

        currentSessionId++;

        _sessions[currentSessionId] = Session({
            status: Status.Open,
            sessionId: currentSessionId,
            startTime: block.timestamp,
            endTime: _endTime,
            minBet: _minBet,
            maxBet: _maxBet,
            headsCount: 0,
            tailsCount: 0,
            collectedApple: 0,
            totalPayouts: 0,
            devFee: _devFee,
            flipResult: 2 // init to 2 to avoid conflict with 0 (heads) or 1 (tails). is set to 0 or 1 later depending on coin flip result.
        });
        
        emit SessionOpened(
            currentSessionId,
            block.timestamp,
            _endTime,
            _minBet,
            _maxBet
        );
    }

    function closeSession(uint256 _sessionId) external {
      
        require(block.timestamp > _sessions[_sessionId].endTime, "Lottery not over yet!");
        generateRandomNumber();
        _sessions[_sessionId].status = Status.Closed;

        emit SessionClosed(
            _sessionId,
            block.timestamp,
            _sessions[_sessionId].headsCount,
            _sessions[_sessionId].tailsCount,
            _sessions[_sessionId].collectedApple,
            _sessions[_sessionId].totalPayouts
        );
    }

    function flipCoinAndMakeDisbursable(uint256 _sessionId) external returns (uint256) {
        
        uint256 sessionFlipResult = flipCoin();
        // uint256 appleForDisbursal = (
        //     ((_sessions[_sessionId].collectedApple) * (10000 - _sessions[_sessionId].devFee))
        // ) / 10000;
        _sessions[_sessionId].flipResult = sessionFlipResult;
        _sessions[_sessionId].status = Status.Disbursing;
        emit CoinFlipped(sessionFlipResult);
        return sessionFlipResult;
        
    }

    function disburse(address _address, uint256 _sessionId) internal {}//put logic and event in here.}

    function claimRewardPerSession(uint256 _sessionId) external {
        
        require(HasBet[msg.sender][_sessionId] , "You didn't bet in this session!");
        require(!HasClaimed[msg.sender][_sessionId] , "Cannot claim reward for this session twice!");
        if (Bets[msg.sender][_sessionId].choice == _sessions[_sessionId].flipResult) {
            disburse(msg.sender, _sessionId);
            PlayerRewardPerSession[msg.sender][_sessionId] = 0;
            HasClaimed[msg.sender][_sessionId] = true;
                       
        }
    }


    // function drawFinalNumberAndMakeLotteryClaimable(uint256 _lotteryId, bool _autoInjection)
    //     external
    //     override
    //     onlyOperator
    //     nonReentrant
    // {
    //     require(_lotteries[_lotteryId].status == Status.Close, "Lottery not close");
    //     require(_lotteryId == randomGenerator.viewLatestLotteryId(), "Numbers not drawn");

    //     // Calculate the finalNumber based on the randomResult generated by ChainLink's fallback
    //     uint32 finalNumber = randomGenerator.viewRandomResult();

    //     // Initialize a number to count addresses in the previous bracket
    //     uint256 numberAddressesInPreviousBracket;

    //     // Calculate the amount to share post-treasury fee
    //     uint256 amountToShareToWinners = (
    //         ((_lotteries[_lotteryId].amountCollectedInCake) * (10000 - _lotteries[_lotteryId].treasuryFee))
    //     ) / 10000;

    //     // Initializes the amount to withdraw to treasury
    //     uint256 amountToWithdrawToTreasury;

    //     // Calculate prizes in CAKE for each bracket by starting from the highest one
    //     for (uint32 i = 0; i < 6; i++) {
    //         uint32 j = 5 - i;
    //         uint32 transformedWinningNumber = _bracketCalculator[j] + (finalNumber % (uint32(10)**(j + 1)));

    //         _lotteries[_lotteryId].countWinnersPerBracket[j] =
    //             _numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber] -
    //             numberAddressesInPreviousBracket;

    //         // A. If number of users for this _bracket number is superior to 0
    //         if (
    //             (_numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber] - numberAddressesInPreviousBracket) !=
    //             0
    //         ) {
    //             // B. If rewards at this bracket are > 0, calculate, else, report the numberAddresses from previous bracket
    //             if (_lotteries[_lotteryId].rewardsBreakdown[j] != 0) {
    //                 _lotteries[_lotteryId].cakePerBracket[j] =
    //                     ((_lotteries[_lotteryId].rewardsBreakdown[j] * amountToShareToWinners) /
    //                         (_numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber] -
    //                             numberAddressesInPreviousBracket)) /
    //                     10000;

    //                 // Update numberAddressesInPreviousBracket
    //                 numberAddressesInPreviousBracket = _numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber];
    //             }
    //             // A. No CAKE to distribute, they are added to the amount to withdraw to treasury address
    //         } else {
    //             _lotteries[_lotteryId].cakePerBracket[j] = 0;

    //             amountToWithdrawToTreasury +=
    //                 (_lotteries[_lotteryId].rewardsBreakdown[j] * amountToShareToWinners) /
    //                 10000;
    //         }
    //     }

    //     // Update internal statuses for lottery
    //     _lotteries[_lotteryId].finalNumber = finalNumber;
    //     _lotteries[_lotteryId].status = Status.Claimable;

    //     if (_autoInjection) {
    //         pendingInjectionNextLottery = amountToWithdrawToTreasury;
    //         amountToWithdrawToTreasury = 0;
    //     }

    //     amountToWithdrawToTreasury += (_lotteries[_lotteryId].amountCollectedInCake - amountToShareToWinners);

    //     // Transfer CAKE to treasury address
    //     cakeToken.safeTransfer(treasuryAddress, amountToWithdrawToTreasury);

    //     emit LotteryNumberDrawn(currentLotteryId, finalNumber, numberAddressesInPreviousBracket);
    

}