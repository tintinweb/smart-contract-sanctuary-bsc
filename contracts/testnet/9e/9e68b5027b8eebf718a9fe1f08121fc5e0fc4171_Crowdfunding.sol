/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

pragma solidity 0.8.13;
// SPDX-License-Identifier: UNLICENSED

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

contract Crowdfunding is Ownable {
    using SafeMath for uint256;
    bool started;   
    uint256 public endDate;
    uint256 public hardCap;
    uint256 public totalInvestments;

    uint256 public status = 0; // not started, 1 = started, 2 = successful, 3= failed
    address payable ownerWallet;
    event CrowdfundingStarted();
    
    mapping (address => uint256) public investors;

    constructor() {
        ownerWallet = payable(msg.sender);
    }

    // owner can start the crowdfunding by using this function
    // end date of crowdfunding and hard cap value needs to be provided
    function Start(uint256 endDate_, uint256 hardCap_) external onlyOwner{
        endDate = endDate_;
        hardCap = hardCap_;
        emit CrowdfundingStarted();
        status = 1;
    }

    modifier hardCapLimit{
        if(status != 0)
            require(totalInvestments < hardCap, "Hard cap reached");
            _;
    }

    modifier open {
        require(block.timestamp < endDate, "closed");
        require(status == 1, "closed");
        _;
    }

    // users send ethers to participate in crowdfunding
    receive() external payable {
        if(_msgSender() != owner())
            processInvestment(msg.value);
        else 
            _allocateDividends();
    }

    function processInvestment(uint256 amt) private hardCapLimit open{
        updateAcc(_msgSender(), amt, round);
        if(totalInvestments >= hardCap){
            status = 2; // successful
        }
    }

    function collectInvestments() external onlyOwner {
        if(status == 1)
            require(totalInvestments >= hardCap, "hard cap not reached");
        else 
            require(status == 2, "already collected");
        status = 2;
        address payable receiver = payable(_msgSender());
        receiver.transfer(totalInvestments);
    }

    function refund() external {
        require(totalInvestments < hardCap, "hard cap has reached");
        uint256 amt = investors[_msgSender()];
        require(amt > 0, "No funds");
        require(block.timestamp > endDate, "crowdfunding has not closed");
        
        address payable receiver = payable(_msgSender());
        investors[_msgSender()] = 0;
        status = 3;
        receiver.transfer(amt);
    }

    function checkStatus() external view returns(uint256 status_) {
        uint256 _status = 0;
        if(block.timestamp < endDate && totalInvestments >= hardCap) {
            // end date has not reached but investments reached hardcap
            _status = 2; // successful
        } else if(block.timestamp < endDate && totalInvestments < hardCap){
            // end date has not reached and investments also not reached hardcap
            _status = 1; // running
        } else if(block.timestamp > endDate && totalInvestments < hardCap) {
            // end date reached but investments didnt reached
            _status = 3; // failed
        } else if(block.timestamp > endDate && totalInvestments >= hardCap) {
            // end date has  reached and investments also reached hardcap
            _status = 2; // successful
        } else 
            _status = 0;

        return _status; 
    }

    //// DIVIDEND FUNCTIONS

    uint256 private scaling = uint256(10) ** 12;
    uint256 public scaledRemainder = 0;
    uint256 public totalDividends = 0;
    mapping (uint => uint256) public payouts; // keeps record of each payout
    uint public round = 1;

    mapping (address => Account) public accounts;  // keeps record of each token holder

    event Payout(uint, uint256);                   // Logged when payout is paid
    event claimed(address, uint256);              // Logged when payout is claimed
    
    // ------------------------------------------------------------------------
    // Each user related information is maintained using `Account` struct
    // ------------------------------------------------------------------------ 
    struct Account {
        uint256 lastDividends;
        uint256 fromTotalDividend;
        uint round;
        uint256 remainder;
    }

    function updateAcc(address _wallet, uint256 _amount, uint256 _r) public {
        Account memory a;
        a.round = _r;
        totalInvestments = totalInvestments.add(_amount);
        investors[_msgSender()] = investors[_msgSender()].add(_amount);
        accounts[_wallet] = a;
    }

    // ------------------------------------------------------------------------
    // Private function to allocate dividends to all holders
    // ------------------------------------------------------------------------ 
    function _allocateDividends() private{
        
        if(address(this).balance >= msg.value && totalInvestments > hardCap){
            
            // scale the deposit and add the previous remainder
            uint256 available = (msg.value * scaling)+ scaledRemainder; 
            uint256 dividendPerToken = available / totalInvestments;
            
            scaledRemainder = available % totalInvestments;
        
            totalDividends += dividendPerToken; 
            payouts[round] = payouts[round-1].add(dividendPerToken);
            emit Payout(round, msg.value);
            round++;
        }
    }
    
    // ------------------------------------------------------------------------
    // Token holders can claim their pending dividends using this function
    // - the sender address must not be excluded by owner
    // ------------------------------------------------------------------------
    function claimDividend() public  {
        require(totalDividends > accounts[msg.sender].fromTotalDividend, "no pending claim");
        require(investors[_msgSender()] > 0, "you have not invested");
        _redeem();
    }
    
    function _redeem() private {
        uint256 owing = _accountDividend(_msgSender());
        
        require(owing > 0, "nothing pending");
        owing = owing + accounts[_msgSender()].remainder;
        accounts[msg.sender].remainder = 0;
        address payable receiver = payable(_msgSender());
        receiver.transfer(owing);
        emit claimed(msg.sender, owing);
        accounts[msg.sender].lastDividends = owing; // unscaled
        accounts[msg.sender].round = round;
        accounts[msg.sender].fromTotalDividend = totalDividends; // scaled
    }
    
    // ------------------------------------------------------------------------
    // Calculates the pending dividends of the holders
    // ------------------------------------------------------------------------    
    function _accountDividend(address account) public returns (uint256) {
        uint256 amount =  (((totalDividends.sub(payouts[accounts[account].round - 1])).mul(investors[account])) / scaling );
        accounts[account].remainder += (((totalDividends.sub(payouts[accounts[account].round - 1])).mul(investors[account])) % scaling );
        return amount;
    }


}