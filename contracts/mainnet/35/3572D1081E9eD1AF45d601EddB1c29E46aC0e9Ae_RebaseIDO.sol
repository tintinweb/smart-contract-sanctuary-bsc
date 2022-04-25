// SPDX-License-Identifier: Unlicensed

pragma solidity 0.7.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RebaseIDO is Ownable {
  
    using SafeMath for uint256;

    IERC20 public rebaseToken;
    address payable public recipientAddress;
    uint256 public minContribution = 0.5 * 10**18;
    uint256 public initialMaxContribution = 1 * 10**18;
    uint256 public bracketInterval = 900;       // 15 minutes
    uint256 public hardCap = 2000 * 10**18;
    uint256 public rate = 50000 * 10**18;

    // Time settings
    uint256 public startTime;
    uint256 public endTime;
    uint256 public claimTime;

    // For tracking purposes
    uint256 public totalBnbRaised;
    uint256 public totalParticipants;
    uint256 public totalClaimedParticipants;
    uint256 public totalPendingClaimToken;
    uint256 public totalWhitelist;
    
    bool public whitelistEnabled = false;

    //Store the information of all users
    struct Account {
        uint256 contribution;           // user's contributed BNB amount
        uint256 tokenAllocation;        // user's token allocation 
        uint256 claimedTimestamp;       // user's last claimed timestamp. 0 means never claim
    }

    mapping(address => Account) public accounts;
    mapping(address => bool) public whiteLists;
    uint256[] private maxContributionBracket;

    constructor(address _token) {
        rebaseToken = IERC20(_token);
        recipientAddress = payable(msg.sender);
    }

    function contribute() public payable {
        require(block.timestamp >= startTime, "IDO not started yet");
        require(block.timestamp <= endTime, "IDO ended");
        if(whitelistEnabled)
            require(whiteLists[_msgSender()], "You are not in whitelist");

        Account storage userAccount = accounts[_msgSender()];
        uint256 _contribution = msg.value;
        uint256 _totalContribution = userAccount.contribution.add(_contribution);

        require(_totalContribution >= minContribution, "Contribution is lower than minimum contribution threshold");
        require(_totalContribution <= getCurrentMaxContribution(), "Contribution exceeded current maximum contribution threshold");
        require(totalBnbRaised.add(_contribution) <= hardCap, "Exceeded hardcap");
        
        // Forward funds
        forwardFunds(_contribution);

        // Calculate entitled token amount
        uint256 _tokenAllocation = calculateTokenAllocation(_contribution);

        // Set tracking variables
        if (userAccount.contribution == 0) 
            totalParticipants = totalParticipants.add(1);

        totalBnbRaised = totalBnbRaised.add(_contribution);
        totalPendingClaimToken = totalPendingClaimToken.add(_tokenAllocation);

        // Set user contribution details
        userAccount.contribution = userAccount.contribution.add(_contribution);
        userAccount.tokenAllocation = userAccount.tokenAllocation.add(_tokenAllocation);

        emit Contributed(_msgSender(), _contribution);
    }

    function claim() external {
        Account storage userAccount = accounts[_msgSender()];
        uint256 _tokenAllocation = userAccount.tokenAllocation;

        require(block.timestamp >= claimTime, "Can not claim at this time");
        require(_tokenAllocation > 0, "Nothing to claim");
        
        //Validate whether contract token balance is sufficient
        uint256 contractTokenBalance = rebaseToken.balanceOf(address(this));
        require(contractTokenBalance >= _tokenAllocation, "Insufficient token in contract");

        //Update user details
        userAccount.claimedTimestamp = block.timestamp;
        userAccount.tokenAllocation = 0;

        //For tracking
        totalPendingClaimToken = totalPendingClaimToken.sub(_tokenAllocation);
        totalClaimedParticipants = totalClaimedParticipants.add(1);

        //Release token
        rebaseToken.transfer(_msgSender(), _tokenAllocation);

        emit Claimed(_msgSender(), _tokenAllocation);
    }

    function setMaxContributionBracket(uint256[] memory _maxContributionBracket) external onlyOwner {
        maxContributionBracket = _maxContributionBracket;
    }

    function getCurrentMaxContribution() public view returns (uint256){
        uint256 _maxContribution = initialMaxContribution;
        uint256 _time = startTime;

        for(uint256 index=0; index < maxContributionBracket.length; index++) {
            
            if(block.timestamp >= _time) {
                _maxContribution = maxContributionBracket[index];
                _time = _time.add(bracketInterval);
            } else {
                break;
            }
        }

        return _maxContribution;
    }

    function getMaxContributionBracket() external view returns (uint256[] memory) {
        return maxContributionBracket;
    }

    function calculateTokenAllocation(uint256 _amount) internal view returns (uint256){
        return _amount.mul(rate).div(1 *10**18);
    }

    function setRecipientAddress(address _recipientAddress) external onlyOwner {
        require(_recipientAddress != address(0), "Zero address");
        recipientAddress = payable(_recipientAddress);
    }

    function setTime(uint256 _startTime, uint256 _endTime) external onlyOwner {
        require(_startTime < _endTime, "Start time should be less than end time");
        startTime = _startTime;
        endTime = _endTime;
    }

    function setClaimTime(uint256 _claimTime) external onlyOwner {
        claimTime = _claimTime;
    }

    function setRebaseToken(address _token) external onlyOwner {
        require(_token != address(0), "Zero address");
        rebaseToken = IERC20(_token);
    }

    function setContribution(uint256 _minContribution, uint256 _initialMaxContribution) external onlyOwner {
        minContribution = _minContribution;
        initialMaxContribution = _initialMaxContribution;
    }

    function setRate(uint256 _rate) external onlyOwner {
        rate = _rate;
    }

    function setHardCap(uint256 _hardCap) external onlyOwner {
        hardCap = _hardCap;
    }

    function setWhitelistEnabled(bool _bool) external onlyOwner {
        whitelistEnabled = _bool;
    }

    function setBracketInterval(uint256 _interval) external onlyOwner {
        bracketInterval = _interval;
    }

    function addToWhiteList(address[] memory _accounts) external onlyOwner {
        require(_accounts.length > 0, "Invalid input");
        for (uint256 index = 0; index < _accounts.length; index++) {
            whiteLists[_accounts[index]] = true;
            totalWhitelist = totalWhitelist.add(1);
        }
    }

    function removeFromWhiteList(address[] memory _accounts) external onlyOwner {
        require(_accounts.length > 0, "Invalid input");
        for (uint256 index = 0; index < _accounts.length; index++) {
            whiteLists[_accounts[index]] = false;
            totalWhitelist = totalWhitelist.sub(1);
        }
    }

    function forwardFunds(uint256 _contribution) internal {
        recipientAddress.transfer(_contribution);
    }

    function rescueToken(address _token, address _to) public onlyOwner returns (bool _sent) {
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    function clearStuckBalance() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    receive() external payable {}

    event Contributed(address account, uint256 contribution);
    event Claimed(address account, uint256 tokenQuantity);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
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