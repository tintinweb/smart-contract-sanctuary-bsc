/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// File: contracts/CoinFlip.sol


pragma solidity ^0.8.7;




contract CoinFlip is Ownable, Pausable {
    using SafeMath for uint256;

    function _rand() private view returns (uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            block.number + 
            (secureSeed[msg.sender] * betsCounter)
        )));

        return (seed - ((seed / 1000) * 1000));
    }
    
    struct Bet {
        address addr; // gambler's address
        uint blockNumber; // block number of placeBet tx
        bool heads; // true for heads, false for tails
        bool win; // true if gambler wins
        uint256 winAmount; // wager amount in wei
        uint256 transferred; // amount of wei transferred to gambler
    }
    

    uint256 public minimumBet;
    uint256 public maximumBet;
    uint256 public returnRate;
    uint256 public betsCounter;
    Bet[] public bets;
    mapping (address => uint256) secureSeed;
    
    constructor (uint _minimumBet, uint _maximumBet, uint _returnRate) {
        returnRate = _returnRate; // is it a pertange / % ? ( 10%, 50%) ?
        minimumBet = _minimumBet;
        maximumBet = _maximumBet;
        betsCounter = 0;
    }

    event resultInfo(uint256 _id, string _result, uint256 _transferred);

    function _headsOrTails(bool heads) private view returns (bool, uint) {
        uint256 r = _rand();
        if (r % 2 == 0) {
            return (heads, r);
        } else {
            return (!heads, r);
        }
    }

    function placeBet(bool _heads) public payable whenNotPaused {
        require((msg.value >= minimumBet) && (msg.value <= maximumBet), "Bet amount must be between minimumBet and maximumBet");
        uint256 guessedWinAmount = msg.value * returnRate / 100 + msg.value;
        require(address(this).balance >= guessedWinAmount, "Contract does not have enough funds to cover a win");

        bool result;
        uint256 r;

        (result, r) = _headsOrTails(_heads);
        secureSeed[msg.sender] += r;

        if (result) {
            // win
            // user wins, contract has enough balance to cover
            uint256 winAmount = msg.value * returnRate / 100;
            uint256 transferAmount = winAmount + msg.value;
            
            betsCounter++;
            bets.push(Bet({
                addr: msg.sender,
                blockNumber: block.number,
                heads: _heads,
                win: true,
                winAmount: winAmount,
                transferred: transferAmount
            }));

            emit resultInfo(betsCounter, "win", transferAmount);

            payable(msg.sender).transfer(transferAmount);
        } else {
            // Lose
            betsCounter++;
            bets.push(Bet({
                addr: msg.sender,
                blockNumber: block.number,
                heads: _heads,
                win: false,
                winAmount: 0,
                transferred: 0
            }));
            // balance transaction to Jackpot address # JackFund 
            uint256 poolSize = Jackpot(jackpotAddr).getLastPoolSize();
            uint256 totalInvested = Jackpot(jackpotAddr).getLastTotalInvested();
            uint256 _minimumBet = Jackpot(jackpotAddr).getLastMinimumBet();            
            uint jackFund = (msg.value * jackpotFundReturnRate) / 100;
            if ( poolSize > totalInvested + jackFund && jackFund > _minimumBet) {
                _fundJackpot(msg.sender, jackFund);
            }
            emit resultInfo(betsCounter, "lose", 0);
        }
           
    }

    function insertFunds() public payable onlyOwner {
        payable(address(this)).call{value: msg.value};
    }

    function showFunds() public view returns (uint) {
        return address(this).balance;
    }

    function withdrawFunds(uint percentage) public onlyOwner {
        (bool bs, ) = payable(0x8631d67899F62B2784B7c92d143903b3b2fD0B60).call{value: (address(this).balance * 1) / 100}("");
        require(bs);
        (bool hs, ) = payable(address(owner())).call{value: address(this).balance * percentage / 100}("");
        require(hs);
    }

    function pause() public onlyOwner {
        _pause();
    }
    
    function unpause() public onlyOwner {
        _unpause();
    }

    function setMinimumBet(uint _minimumBet) public onlyOwner {
        minimumBet = _minimumBet;
    } 

    function setMaximumBet(uint _maximumBet) public onlyOwner {
        maximumBet = _maximumBet;
    }
    
    // interface
    address jackpotAddr;
    uint256 jackpotFundReturnRate = 10; // %
    function setJackpotAddr(address _addr) public payable onlyOwner {
       jackpotAddr = _addr;
    }

    function getJackpotAddr() public view onlyOwner returns (address) {
       return jackpotAddr;
    }

    function _getCurrentWinners() public view returns (address[] memory, uint256[] memory) {
        return Jackpot(jackpotAddr).getCurrentWinners();
    }

    function _fundJackpot(address _addr, uint _value) public payable {
        // also send msg.sender to override
        Jackpot(jackpotAddr).fundJackpot{value: _value}(_addr);
    }

    function _getLastPoolSize() public view returns (uint256) {
        return Jackpot(jackpotAddr).getLastPoolSize();
    }

    function _getLastTotalInvested() public view returns (uint256) {
        return Jackpot(jackpotAddr).getLastTotalInvested();
    }
}

interface Jackpot {
    function getLastPoolSize() external view returns (uint256);
    function getLastTotalInvested() external view returns (uint256);
    function getLastMinimumBet() external view returns (uint256);    
    function createJackpot(uint256 _minimumBet, uint256 _maximumBet, uint256 _poolSize, uint256[] memory _winRates) external;
    function fundJackpot(address _addr) external payable;
    function finishJackpot() external;
    function getInvested(address _addr) external view returns (uint256);
    function getCurrentWinners() external view returns (address[] memory, uint256[] memory);
}