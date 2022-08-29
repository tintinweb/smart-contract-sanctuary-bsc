pragma solidity ^0.8.0;
pragma abicoder v2;
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract RandomNumberGen is VRFConsumerBase, Ownable {
    using SafeMath for uint256;

    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomNumber;
    uint256 public numberOfTimesCalled;
    
    constructor(
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        uint256 _fee
    ) VRFConsumerBase(_vrfCoordinator, _link) {
        keyHash = _keyHash;
        fee = _fee;
    }

    function getRandomness() external onlyOwner returns (bytes32) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Inadequate Link to fund this transaction"
        );
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        randomNumber = randomness;
    }

    function retrieveRandomNumber() external onlyOwner view returns (uint256) {
        return randomNumber;
    }

    function increaseNumberOfTimesCalled() public onlyOwner {
        numberOfTimesCalled++;
    }
    
    //function retrieveNumberOfTimesCalled() external onlyOwner view returns (uint256) {
    function retrieveNumberOfTimesCalled() public view returns (uint256) {
        return numberOfTimesCalled;
    }

}


contract Lootbox is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    struct BetInfo {
        address player;
        uint256 betAmount;
        uint256 action;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    mapping(uint256 => BetInfo[]) private bets;
    mapping(uint256 => uint256[]) public roundAmounts;
    mapping(address => uint256) public claimable;
    uint256[] private actions;
    uint256[] public probabilities;
    uint256[] private cumulativeProbabilities;
    uint256 public roundId;
    mapping(uint256 => RandomNumberGen) public roundResults;
    uint256 public minAmountToBet;

    address private vrfCoordinator;
    address private link;
    bytes32 private keyHash;
    uint256 private linkFee;
    RandomNumberGen private rng;
    mapping(uint256 => uint256) private treasuryAmountRound;
    uint256 private treasuryAmount;
    LinkTokenInterface LINK;

    bool private _paused;
    bool private _stopped;
    uint128 private treasuryFee;

    event Bet(address indexed sender, uint256 amount, uint256 action, uint256 roundId);
    event RoundStarted(uint256 roundId);
    event RoundFinished(uint256 roundId);
    event Claim(address indexed sender, uint256 amount);
    event TreasuryClaim(uint256 amount);
    event GeneratingWinningBox();
    event StopContract();
    event UnstopContract();
    event ProbabilityGenerated(uint256 probability);


    //constructor(address _vrfCoordinator, address _link, bytes32 _keyHash, uint256 _linkFee, uint _minNumPlayersToStartGame, uint256 _treasuryFee) {
    constructor(){
        _paused = false;
        _stopped = true;
        LINK = LinkTokenInterface(0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06);
        vrfCoordinator = 0xa555fC018435bef5A13C6c6870a9d4C11DEC329C;
        link = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;
        keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
        linkFee = 0.1*(10**18);
        treasuryFee = 10;
        rng = new RandomNumberGen(vrfCoordinator, link, keyHash, linkFee);
        //probabilities = [50, 35, 15];
        cumulativeProbabilities = [1, 50, 85, 100];
        //actions = [0, 1, 2];
        minAmountToBet = 0.001*(10**18);    // TODO: change this in prod
    }

    function setMinAmountTobet(uint256 _newMinAmountToBet) external onlyOwner whenPaused {
        require(_newMinAmountToBet <= 0.1*(10**18), "Trying to set too high value for the minimum amount to bet");
        minAmountToBet = _newMinAmountToBet;
    }

    function setActions(uint256[] memory _actions, uint256[] memory _probabilities) external onlyOwner whenStopped {
        require(checkProbabilities(_probabilities), "Probabilities do not sum up to 1");
        require(_actions.length == _probabilities.length, "Mismatch in dimensions between actions and probabilities");

        actions = _actions;
        probabilities = _probabilities;
        cumulativeProbabilities = computeCumulativeProb(_probabilities);
    }

    function getPlayersBetInRound(address _player, uint256 _roundId) private view returns (uint256) {
        for (uint i=0; i<bets[_roundId].length; i=unsafe_inc(i)) {
            if (address(bets[_roundId][i].player) == _player) {
                return bets[roundId][i].action;
            }
        }
        return actions.length;
    }

    function getCurrentRound() public view returns (uint256) {
        return roundId;
    }

    function checkPlayerHasCurrentBet(address _player) private view returns(bool) {
        if (getPlayersBetInRound(_player, getCurrentRound()) != actions.length) {
            return true;
        } else {
            return false;
        }
    }

    function viewRoundAmounts(uint256 _roundId) external view onlyOwner returns (uint256[] memory) {
        return roundAmounts[_roundId];
    }

    function viewTreasury() external view onlyOwner returns (uint256) {
        return treasuryAmount;
    }

    function viewRandomNumber() external view onlyOwner returns (uint256) {
        return rng.retrieveRandomNumber();
    }

    function startRound() private {
        roundId++;
        roundAmounts[roundId] = new uint256[](actions.length);
        unpause();
        emit RoundStarted(roundId);
    }

    function bet(uint256 box) external payable whenNotPaused notContract whenNotStopped {
        require(!checkPlayerHasCurrentBet(msg.sender), "Player has already placed a bet in this round");
        require(box < actions.length, "Incorrect action");
        require(msg.value >= minAmountToBet, "Too low amount to bet");

        uint256 _currentRound = getCurrentRound();
        uint256 _tmpTreasuryAmount = (msg.value).mul(treasuryFee).div(1000);
        uint256 _betAmount = (msg.value).sub(_tmpTreasuryAmount);
        roundAmounts[_currentRound][box] = (roundAmounts[_currentRound][box]).add(_betAmount);

        treasuryAmountRound[_currentRound] = treasuryAmountRound[_currentRound].add(_tmpTreasuryAmount);

        BetInfo memory newBet;
        newBet.player = msg.sender;
        newBet.betAmount = _betAmount;
        newBet.action = box;

        bets[_currentRound].push(newBet);

        emit Bet(address(msg.sender), msg.value, box, getCurrentRound());
    }

    function generateWinningBox() external onlyOwner nonReentrant returns(uint256) {
        require(address(rng) != address(0), "Rng address is zero address");
        uint256 _currentRoundNumberBetBox = getCurrentRoundNumberBetBox();

        if (_currentRoundNumberBetBox == 1) {
            
            uint256 _currentRound = getCurrentRound();
            uint256 _boxSelected = getBetBoxWhenOnlyOneIsSelected();
            uint256 amountToBeSplit = roundAmounts[_currentRound][_boxSelected];

            for (uint i=0; i<bets[_currentRound].length; i++) {
                claimable[address(bets[_currentRound][i].player)] = claimable[address(bets[_currentRound][i].player)].add(amountToBeSplit).mul(bets[_currentRound][i].betAmount).div(roundAmounts[_currentRound][_boxSelected]);
            }

            treasuryAmount = treasuryAmount.add(treasuryAmountRound[_currentRound]);

            roundId++;
            roundAmounts[roundId] = new uint256[](actions.length);

        } else if (_currentRoundNumberBetBox > 1) {
            pause();

            if (getRngLinkBalance() < linkFee) {
                require(getContractLinkBalance() >= linkFee, "Contract has not enough LINK to generate random number");
                IERC20(link).transfer(address(rng), getContractLinkBalance());
            }
            
            rng.getRandomness();

            emit GeneratingWinningBox();
        } else {

            roundId++;
            roundAmounts[roundId] = new uint256[](actions.length);
        }

        rng.increaseNumberOfTimesCalled();

        return _currentRoundNumberBetBox;
    }

    function getCurrentRoundNumberBetBox() private view returns(uint256) {
        uint256 _currentRound = getCurrentRound();
        uint256 numDifferentBoxesBets;
        
        for (uint i=0; i<roundAmounts[_currentRound].length; i=unsafe_inc(i)) {
            if (roundAmounts[_currentRound][i] > 0) {
                numDifferentBoxesBets++;
            }
        }
        return numDifferentBoxesBets;
    }

    function getBetBoxWhenOnlyOneIsSelected() private view returns(uint256) {
        require(getCurrentRoundNumberBetBox() == 1, "Boxes selected are either 0 or more than 1");
        uint256 _currentRound = getCurrentRound();
        uint256 boxSelected;

        for (uint i=0; i<roundAmounts[_currentRound].length; i=unsafe_inc(i)) {
            if (roundAmounts[_currentRound][i] > 0) {
                boxSelected = i;
            }
        }

        return boxSelected;
    }

    function determineWinners() external onlyOwner {
        uint256 _currentRound = getCurrentRound();
        uint256 winningBox = getWinningBox();

        if (getCurrentRoundNumberBetBox() > 0) {
            uint256 amountToBeSplit;
            for (uint i=0; i<roundAmounts[_currentRound].length; i=unsafe_inc(i)) {
                amountToBeSplit = amountToBeSplit.add(roundAmounts[_currentRound][i]);
            }

            for (uint i=0; i<bets[_currentRound].length; i++) {
                 if(bets[_currentRound][i].action == winningBox){
                    claimable[address(bets[_currentRound][i].player)] = claimable[address(bets[_currentRound][i].player)].add(amountToBeSplit).mul(bets[_currentRound][i].betAmount).div(roundAmounts[_currentRound][winningBox]);
                }
            }

            treasuryAmount = treasuryAmount.add(treasuryAmountRound[_currentRound]);
        }
        emit RoundFinished(roundId);

        startRound();
    }

    function getWinningBox() private view returns(uint256) {  // can declare as "view" if you remove the emit
        require(roundId == rng.retrieveNumberOfTimesCalled(), "Random number not updated");
        uint256 prob = rng.retrieveRandomNumber().mod(100) + 1;

        // emit ProbabilityGenerated(prob);

        uint256 winningBox;

        for (uint i=1; i<probabilities.length; i=unsafe_inc(i)) {
            if ((prob <= cumulativeProbabilities[i]) && (prob >= cumulativeProbabilities[i-1])) {
                winningBox = uint256(i-1);
            }
        }

        return winningBox;
    }
       
    function claim() external payable nonReentrant notContract {
        uint256 amountToBeClaimed = claimable[msg.sender];

        require(amountToBeClaimed > 0, "Nothing to claim");

        claimable[msg.sender] = 0;
        Address.sendValue(payable(msg.sender), amountToBeClaimed);

        emit Claim(msg.sender, amountToBeClaimed);
    }

    function removeBet() external whenNotStopped whenNotPaused {
        require(checkPlayerHasCurrentBet(address(msg.sender)), "Player has not placed the bet requested to remove");
        uint256 _currentRound = getCurrentRound();
        for (uint i=0; i<bets[_currentRound].length; i=unsafe_inc(i)) {
            if (bets[_currentRound][i].player == address(msg.sender)) {
                uint256 amountToRemove = bets[_currentRound][i].betAmount;
                uint256 actionToRemove = bets[_currentRound][i].action;
                bets[_currentRound][i] = bets[_currentRound][bets[_currentRound].length-1];
                bets[_currentRound].pop();
                claimable[address(msg.sender)] = claimable[address(msg.sender)].add(amountToRemove);
                
                roundAmounts[_currentRound][actionToRemove] = (roundAmounts[_currentRound][actionToRemove]).sub(amountToRemove);
                // TODO: check... può andare storto qualcosa? mmh...
            }
        }
    }

    function getContractLinkBalance() private view returns (uint256) {
        return LINK.balanceOf(address(this));
    }
    
    function getRngLinkBalance() private view returns (uint256) {
        return LINK.balanceOf(address(rng));
    }
    
    function getContractBNBBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }
    
    function pause() private whenNotPaused {
        _paused = true;
    }

    function unpause() private whenPaused {
        _paused = false;
    }

    function stopContract() external onlyOwner whenNotStopped {
        _stopped = true;

        uint256 _currentRound = getCurrentRound();
        for (uint i=0; i<bets[_currentRound].length; i = unsafe_inc(i)) {
            claimable[address(bets[_currentRound][i].player)] = claimable[address(bets[_currentRound][i].player)].add(bets[_currentRound][i].betAmount);
            delete bets[_currentRound][i];
        }
        
        emit StopContract();
    }

    function unstopContract() external onlyOwner whenStopped {
        _stopped = false;
        roundId++;
        roundAmounts[roundId] = new uint256[](actions.length);
        emit UnstopContract();
    }

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}("");
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

    function claimTreasury() external nonReentrant onlyOwner {
        require(treasuryAmount != 0, "No treasury to claim");
        uint256 tmpTreasury = treasuryAmount;
        treasuryAmount = 0;
        _safeTransferBNB(owner(), tmpTreasury);
        emit TreasuryClaim(tmpTreasury);
    }

    function updateTreasuryFee(uint128 _newTreasuryFee) external onlyOwner {
        require(paused() || stopped(), "Not paused and not stopped");
        require((_newTreasuryFee >= 0) && (_newTreasuryFee <= 50), "Too high treasury fee");
        treasuryFee = _newTreasuryFee;
    }

    function viewTreasuryFee() public view returns(uint256) {
        return treasuryFee;
    } 

    function computeCumulativeProb(uint256[] memory _newProbabilities) private pure returns (uint256[] memory) {
        uint256[] memory newCumulativeProb = new uint256[](_newProbabilities.length+1);
        newCumulativeProb[0] = 1;
        newCumulativeProb[1] = _newProbabilities[0];
        for (uint i=1; i<_newProbabilities.length; i=unsafe_inc(i)) {
            newCumulativeProb[i+1] = _newProbabilities[i].add(newCumulativeProb[i]);
        }

        return newCumulativeProb;
    }

    function checkProbabilities(uint256[] memory _probs) private pure returns (bool) {
        uint256 probSum;
        for (uint i=0; i<_probs.length; i=unsafe_inc(i)) {
            probSum += _probs[i];
        }
        return probSum == 100;
    }

    function updateProbabilitiesBox(uint256[] memory _newProbabilities) external onlyOwner{
        require(!paused() || stopped(), "Need to have contract stopped or not paused");
        require(_newProbabilities.length == actions.length, "Length of probabilities inserted does not match the number of actions available");
        require(checkProbabilities(_newProbabilities), "Probabilities do not sum up to 1");

        probabilities = _newProbabilities;
        cumulativeProbabilities = computeCumulativeProb(_newProbabilities);
    }

    function viewBoxesProbabilities() external view returns (uint256[] memory) {
        return probabilities;
    }

    modifier whenNotPaused() {
        require(!paused(), "Paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), " Not paused");
        _;
    }

    modifier whenStopped() {
        require(stopped(), "Not stopped");
        _;
    }

    modifier whenNotStopped() {
        require(!stopped(), "stopped");
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function stopped() public view virtual returns (bool) {
        return _stopped;
    }

    receive () external payable {}

    function unsafe_inc(uint x) private pure returns (uint) {
        unchecked { return x + 1; }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/LinkTokenInterface.sol";

import "./VRFRequestIDBase.sol";

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBase is VRFRequestIDBase {
  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 private constant USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 => uint256) /* keyHash */ /* nonce */
    private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(address _vrfCoordinator, address _link) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VRFRequestIDBase {
  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}