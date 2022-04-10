/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

/**
$$$$$$$\   $$$$$$\   $$$$$$\        $$$$$$$$\ $$\       $$$$$$\ $$$$$$$\        
$$  __$$\ $$  __$$\ $$  __$$\       $$  _____|$$ |      \_$$  _|$$  __$$\       
$$ |  $$ |$$ /  \__|$$ /  \__|      $$ |      $$ |        $$ |  $$ |  $$ |      
$$$$$$$\ |\$$$$$$\  $$ |            $$$$$\    $$ |        $$ |  $$$$$$$  |      
$$  __$$\  \____$$\ $$ |            $$  __|   $$ |        $$ |  $$  ____/       
$$ |  $$ |$$\   $$ |$$ |  $$\       $$ |      $$ |        $$ |  $$ |            
$$$$$$$  |\$$$$$$  |\$$$$$$  |      $$ |      $$$$$$$$\ $$$$$$\ $$ |            
\_______/  \______/  \______/       \__|      \________|\______|\__|            
                                                                                
This contract provides the root functionality for coin flips to take place,
and allows the owner to use different tokens and wager sizes by sending those
tokens to the contract.
 */
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

contract BSCCoinFlip is Ownable {
    using Address for address;
    using SafeMath for uint256;

    event GameStarted(
        address indexed better,
        address token,
        uint256 wager,
        uint8 predictedOutcome,
        uint32 id
    );

    event GameFinished(
        address indexed better,
        address token,
        bool winner,
        uint256 wager,
        uint32 id
    );

    event PayoutComplete(
        address indexed winner,
        address token,
        uint256 winnings
    );

    struct Game {
        address better;
        address token;
        uint32 id;
        uint8 predictedOutcome;
        bool finished;
        bool winner;
        uint256 wager;
        uint256 startBlock;
    }

    struct Queue {
        uint32 start;
        uint32 end;
    }

    address public _houseFeeReceiver = address(0x2c3DE508c770a44F2902259f1800aA798f25ee06);
    uint8 public _houseFeePercentage = 30; // In 0.1% increments

    address public _devFeeReceiver = address(0x9AF4295d939482Cb293D5A4Fa395bAbC39C5E839);
    uint8 public _devFeePercentage = 5; // In 0.1% increments

    mapping (address => bool) public _team;
    mapping (address => bool) public _isBlacklisted;

    // Game Details
    mapping (uint256 => Game) public _games; // Game ID -> Game
    Queue public _queuedGames;
    bool _gameEnabled = true; // If we want to pause the flip game
    uint32 public _queueResetSize = 1; // How many games we want to queue before finalizing a game
    uint256 public _blockWaitTime = 2; // How many blocks we want to wait before finalizing a game
    uint256 public _globalQueueSize;
    mapping (address => mapping (address => uint256)) public _winnings;
    mapping (address => uint256) _minBetForToken;
    mapping (address => uint256) _maxBetForToken;

    modifier onlyTeam {
        _onlyTeam();
        _;
    }

    function _onlyTeam() private view {
        require(_team[_msgSender()], "Only a team member may perform this action");
    }

    constructor() 
    {
        _team[owner()] = true;
    }

    // To recieve BNB from anyone, including the router when swapping
    receive() external payable {}

    function withdrawBNB(uint256 amount) external onlyOwner {
        (bool sent, bytes memory data) = _msgSender().call{value: amount}("");
        require(sent, "Failed to send BNB");
    }

    function enterGame(uint256 wager, uint8 outcome, address token) external payable {
        require(_gameEnabled, "Game is currently paused");
        require(!_isBlacklisted[_msgSender()], "This user is blacklisted");

        IERC20 gameToken = IERC20(token);
        if (_minBetForToken[token] != 0) {
            require(wager >= _minBetForToken[token], "This wager is lower than the minimum bet for this token");
        }
        if (_maxBetForToken[token] != 0) {
            require(wager <= _maxBetForToken[token], "This wager is larger than the maximum bet for this token");
        }
        require(outcome < 2, "Must choose heads or tails (0 or 1)");

        if (token != address(0x0)) {
            require(wager <= gameToken.balanceOf(address(this)).div(2), "Can't bet more than the amount available in the contract to pay you");
            gameToken.transferFrom(_msgSender(), address(this), wager);
        } else {
            require(wager <= address(this).balance.div(2), "Can't bet more than the amount available in the contract to pay you");
            require(msg.value == wager, "Must send same amount as specified in wager");
        }

        emit GameStarted(_msgSender(), token, wager, outcome, _queuedGames.end);
        _games[_queuedGames.end++] = Game({better: _msgSender(), token: token, id: _queuedGames.end, predictedOutcome: outcome, finished: false, winner: false, wager: wager, startBlock: block.number});
        _globalQueueSize++;

        completeQueuedGames();
    }

    function completeQueuedGames() internal {
        while (_globalQueueSize > _queueResetSize) {
            Game storage game = _games[_queuedGames.start];
            if (block.number < game.startBlock.add(_blockWaitTime)) {
                break;  // Wait _blockWaitTime before completing this game, to avoid exploits.
            }
            _queuedGames.start++;
            _globalQueueSize--;

            game.winner = (rand() % 2) == game.predictedOutcome;

            if (game.winner) {
                _winnings[game.better][game.token] += (game.wager * 2);
            }

            game.finished = true;

            emit GameFinished(game.better, game.token, game.winner, game.wager, game.id);
        }
    }

    function rand() public view returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(_msgSender())))) / (block.timestamp)) +
            block.number + _globalQueueSize
        )));

        return seed;
    }

    // If you need to withdraw BNB, tokens, or anything else that's been sent to the contract
    function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        
        // transfer the token from address of this contract
        // to address of the user (executing the withdrawToken() function)
        tokenContract.transfer(msg.sender, _amount);
    }

    function setTeamMember(address member, bool isTeamMember) external onlyOwner {
        _team[member] = isTeamMember;
    }

    function setHouseFeeReceiver(address newReceiver) external onlyOwner {
        require(newReceiver != _houseFeeReceiver, "This is already the house fee receiver");

        _houseFeeReceiver = newReceiver;
    }

    function setHouseFeePercentage(uint8 newPercentage) external onlyOwner {
        require(newPercentage != _houseFeePercentage, "This is already the house fee percentage");
        require(newPercentage <= 30, "Cannot set house fee percentage higher than 3 percent");

        _houseFeePercentage = newPercentage;
    }

    function setDevFeeReceiver(address newReceiver) external onlyOwner {
        require(newReceiver != _devFeeReceiver, "This is already the dev fee receiver");

        _devFeeReceiver = newReceiver;
    }

    function setDevFeePercentage(uint8 newPercentage) external onlyOwner {
        require(newPercentage != _devFeePercentage, "This is already the dev fee percentage");
        require(newPercentage <= 5, "Cannot set dev fee percentage higher than 0.5 percent");

        _devFeePercentage = newPercentage;
    }

    function setQueueSize(uint32 newSize) external onlyTeam {
        require(newSize != _queueResetSize, "This is already the queue size");

        _queueResetSize = newSize;
    }

    function setGameEnabled(bool enabled) external onlyTeam {
        require(enabled != _gameEnabled, "Must set a new value for gameEnabled");

        _gameEnabled = enabled;
    }

    function setMinBetForToken(address token, uint256 minBet) external onlyTeam {
        _minBetForToken[token] = minBet;
    }

    function setMaxBetForToken(address token, uint256 maxBet) external onlyTeam {
        _maxBetForToken[token] = maxBet;
    }

    function setBlacklist(address wallet, bool isBlacklisted) external onlyTeam {
        _isBlacklisted[wallet] = isBlacklisted;
    }

    function forceCompleteQueuedGames() external onlyTeam {
        completeQueuedGames();
    }

    function claimWinnings(address token) external {
        require(!_isBlacklisted[_msgSender()], "This user is blacklisted");
        uint256 winnings = _winnings[_msgSender()][token];
        require(winnings > 0, "This user has no winnings to claim");
        IERC20 gameToken = IERC20(token);

        if (token != address(0x0)) {
            require(winnings <= gameToken.balanceOf(address(this)), "Not enough tokens in the contract to distribute winnings");
        } else {
            require(winnings <= address(this).balance, "Not enough BNB in the contract to distribute winnings");
        }

        delete _winnings[_msgSender()][token];
        
        uint256 feeToHouse = winnings.mul(_houseFeePercentage).div(1000);
        uint256 feeToDev = winnings.mul(_devFeePercentage).div(1000);
        uint256 winningsToUser = winnings.sub(feeToHouse).sub(feeToDev);

        if (token != address(0x0)) {
            gameToken.transfer(_houseFeeReceiver, feeToHouse);
            gameToken.transfer(_devFeeReceiver, feeToDev);
            gameToken.transfer(_msgSender(), winningsToUser);
        } else {
            (bool sent, bytes memory data) = _devFeeReceiver.call{value: feeToDev}("");
            (bool sent1, bytes memory data1) = _houseFeeReceiver.call{value: feeToHouse}("");
            (bool sent2, bytes memory data2) = _msgSender().call{value: winningsToUser}("");
        }

        completeQueuedGames();

        emit PayoutComplete(_msgSender(), token, winningsToUser);
    }
}