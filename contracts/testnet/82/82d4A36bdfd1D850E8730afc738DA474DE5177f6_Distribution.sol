//SPDX-License-Identifier: unlicensed

pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Distribution is Ownable {
    using SafeMath for uint256;

    IERC20 public decaToken;
    uint256 public constant DENOM = 100000;         // For percentage precision upto 0.01%

    // Token vesting 
    uint256[] public claimableTimestamp;
    mapping(uint256 => uint256) public claimablePercent;

    // Store the information of all users
    mapping(address => Account) public accounts;

    // For tracking
    uint256 public totalPendingVestingToken;    // Counter to track total required tokens
    uint256 public totalParticipants;           // Total presales participants

    struct Account {
        uint256 tokenAllocation;            // user's total token allocation 
        uint256 pendingTokenAllocation;     // user's pending token allocation
        uint256 claimIndex;                 // user's claimed at which index. 0 means never claim
        uint256 claimedTimestamp;           // user's last claimed timestamp. 0 means never claim
    }

    // constructor(address _decaToken) {
    //     decaToken = IERC20(_decaToken);

    //     uint256 timeA = block.timestamp + 5 minutes;
    //     uint256 timeB = timeA + 2 minutes;
    //     uint256 timeC = timeB + 2 minutes;
    //     uint256 timeD = timeC + 2 minutes;

    //     // THIS PROPERTIES WILL BE SET WHEN DEPLOYING CONTRACT
    //     claimableTimestamp = [
    //         timeA,     // Thursday, 31 March 2022 00:00:00 UTC
    //         timeB,     // Thursday, 30 June 2022 00:00:00 UTC       
    //         timeC,     // Friday, 30 September 2022 00:00:00 UTC
    //         timeD];    // Saturday, 31 December 2022 00:00:00 UTC

    //     claimablePercent[timeA] = 10000;
    //     claimablePercent[timeB] = 30000;
    //     claimablePercent[timeC] = 30000;
    //     claimablePercent[timeD] = 30000;
    // }

    constructor(address _decaToken, uint256[] memory _claimableTimestamp, uint256[] memory _claimablePercent) {
        decaToken = IERC20(_decaToken);
        setClaimable(_claimableTimestamp, _claimablePercent);
    }

    // Register token allocation info 
    // account : IDO address
    // tokenAllocation : IDO contribution amount in wei 
    function register(address[] memory account, uint256[] memory tokenAllocation) external onlyOwner {
        require(account.length > 0, "Account array input is empty");
        require(tokenAllocation.length > 0, "tokenAllocation array input is empty");
        require(tokenAllocation.length == account.length, "tokenAllocation length does not matched with account length");
        
        // Iterate through the inputs
        for(uint256 index = 0; index < account.length; index++) {
            // Save into account info
            Account storage userAccount = accounts[account[index]];

            // For tracking
            // Only add to the var if is a new entry
            // To update, deregister and re-register
            if(userAccount.tokenAllocation == 0) {
                totalParticipants++;

                userAccount.tokenAllocation = tokenAllocation[index];
                userAccount.pendingTokenAllocation = tokenAllocation[index];

                // For tracking purposes
                totalPendingVestingToken = totalPendingVestingToken.add(tokenAllocation[index]);
            }
        }
    }

    function deRegister(address[] memory account) external onlyOwner {
        require(account.length > 0, "Account array input is empty");
        
        // Iterate through the inputs
        for(uint256 index = 0; index < account.length; index++) {
            // Save into account info
            Account storage userAccount = accounts[account[index]];

            // For tracking
            // Only add to the var if is a new entry
            if(userAccount.tokenAllocation == 0) {
                totalParticipants--;

                // For tracking purposes
                totalPendingVestingToken = totalPendingVestingToken.add(userAccount.tokenAllocation);

                userAccount.tokenAllocation = 0;
                userAccount.pendingTokenAllocation = 0;
            }
        }
    }

    function claim() external {
        Account storage userAccount = accounts[_msgSender()];
        uint256 tokenAllocation = userAccount.tokenAllocation;
        require(tokenAllocation > 0, "Nothing to claim");

        uint256 claimIndex = userAccount.claimIndex;
        require(claimIndex < claimableTimestamp.length, "All tokens claimed");

        //Calculate user vesting distribution amount
        uint256 tokenQuantity = 0;
        for(uint256 index = claimIndex; index < claimableTimestamp.length; index++) {

            uint256 _claimTimestamp = claimableTimestamp[index];   
            if(block.timestamp >= _claimTimestamp) {
                claimIndex++;
                tokenQuantity = tokenQuantity.add(tokenAllocation.mul(claimablePercent[_claimTimestamp]).div(DENOM));
            } else {
                break;
            }
        }
        require(tokenQuantity > 0, "Nothing to claim now, please wait for next vesting");

        //Validate whether contract token balance is sufficient
        uint256 contractTokenBalance = decaToken.balanceOf(address(this));
        require(contractTokenBalance >= tokenQuantity, "Contract token quantity is not sufficient");

        //Update user details
        userAccount.claimedTimestamp = block.timestamp;
        userAccount.claimIndex = claimIndex;
        userAccount.pendingTokenAllocation = userAccount.pendingTokenAllocation.sub(tokenQuantity);

        //For tracking
        totalPendingVestingToken = totalPendingVestingToken.sub(tokenQuantity);

        //Release token
        decaToken.transfer(_msgSender(), tokenQuantity);

        emit Claimed(_msgSender(), tokenQuantity);
    }

    // Calculate claimable tokens at current timestamp
    function getClaimableAmount(address account) public view returns(uint256) {
        Account storage userAccount = accounts[account];
        uint256 tokenAllocation = userAccount.tokenAllocation;
        uint256 claimIndex = userAccount.claimIndex;

        if(tokenAllocation == 0) return 0;
        if(claimableTimestamp.length == 0) return 0;
        if(block.timestamp < claimableTimestamp[0]) return 0;
        if(claimIndex >= claimableTimestamp.length) return 0;

        uint256 tokenQuantity = 0;
        for(uint256 index = claimIndex; index < claimableTimestamp.length; index++){

            uint256 _claimTimestamp = claimableTimestamp[index];
            if(block.timestamp >= _claimTimestamp){
                tokenQuantity = tokenQuantity.add(tokenAllocation.mul(claimablePercent[_claimTimestamp]).div(DENOM));
            } else {
                break;
            }
        }

        return tokenQuantity;
    }

    function setDecaToken(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Zero address");
        decaToken = IERC20(newAddress);
    }

    // Update claim percentage. Timestamp must match with _claimableTime
    function setClaimable(uint256[] memory timestamp, uint256[] memory percent) public onlyOwner {
        require(timestamp.length > 0, "Empty timestamp input");
        require(timestamp.length == percent.length, "Array size not matched");

        // set claim percentage
        for(uint256 index = 0; index < timestamp.length; index++){
            claimablePercent[timestamp[index]] = percent[index];
        }

        // set claim timestamp
        claimableTimestamp = timestamp;
    }

    function getClaimableTimestamp() external view returns (uint256[] memory){
        return claimableTimestamp;
    }

    function getClaimablePercent() external view returns (uint256[] memory){
        uint256[] memory _claimablePercent = new uint256[](claimableTimestamp.length);

        for(uint256 index = 0; index < claimableTimestamp.length; index++) {

            uint256 _claimTimestamp = claimableTimestamp[index];   
            _claimablePercent[index] = claimablePercent[_claimTimestamp];
        }

        return _claimablePercent;
    }

    function rescueToken(address _token, address _to, uint256 _amount) external onlyOwner {
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        require(_contractBalance >= _amount, "Insufficient tokens");
        IERC20(_token).transfer(_to, _amount);
    }

	function clearStuckBalance() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
    
	receive() external payable {}

    event Claimed(address account, uint256 tokenQuantity);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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