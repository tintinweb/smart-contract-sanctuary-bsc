/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-02
 */

// File: walletGen/safeMath.sol

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.19;

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
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            if (b > a) return (0);
            return (a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.19;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.19;

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

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.19;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File: walletGen/walletGen.sol

pragma solidity ^0.8.19;

contract walletGenerator is Ownable {
    using SafeMath for uint256;

    struct plan {
        uint256 price;
        uint256 timePeriod;
        IERC20 feeToken;
        bool nativeFee;
        uint256 feeInBNB;
    }

    struct variableFeeRecord {
        uint256 paidTime;
        uint256 noOfWallets;
        uint256 amountPaid;
    }

    IERC20 public token; // user holding token
    IERC20 public variableFeeToken; // fee token (for pay-per-use plan)
    uint256 public variableFee; // fee amount in tokens (for pay-per-use plan)
    
    bool private nativeFee; // to check whether fee is in bnb or not (for pay-per-use plan)
    uint256 public feeInBNB; // fee amount in bnb (for pay-per-use plan)

    mapping(string => plan) public planDetails;
    mapping(address => uint256) public userPlan;
    mapping(address => variableFeeRecord[]) public paidFeeRecords;
    mapping(address => bool) private authorizedusers;
    mapping(address => bool) private restrictedUser;

    // modifier for restrication check
    modifier restrictionCheck(address addr) {
        require(isRestrictedUser(addr) == false, "restricted user detected");
        _;
    }

    // token quantity for free access
    uint public tokenQtyForFreeAccess;

    constructor(address tokenAddr) {
        variableFee = 10**16;
        tokenQtyForFreeAccess = 10000 * (10**18);

        planDetails["1month"] = plan(10 * 10**18,300,IERC20(tokenAddr),false,0);
        planDetails["year"] = plan(100 * 10**18,600,IERC20(tokenAddr),false,0);
        // authorizedusers[msg.sender] = true;
        nativeFee = false;

        token = IERC20(tokenAddr);
        variableFeeToken = IERC20(tokenAddr);
        
    }

    function payFee(uint256 amountWallets) public payable restrictionCheck(msg.sender) {
        if (readAuthorizedUsers(msg.sender) == false || qualifyForFreeAccess(msg.sender) == false) {
            if (nativeFee) {
                require(msg.value >= feeInBNB, "Insufficient BNB fee");
            } else {
                variableFeeToken.transferFrom(msg.sender,address(this),amountWallets * variableFee);
            }
        }
        paidFeeRecords[msg.sender].push(variableFeeRecord(block.timestamp,amountWallets,amountWallets * variableFee));
    }

    function buyPlan(string memory _plan) public payable restrictionCheck(msg.sender) {
        if (readAuthorizedUsers(msg.sender) == false || qualifyForFreeAccess(msg.sender) == false) {
            if (planDetails[_plan].nativeFee) {
                require(msg.value >= planDetails[_plan].feeInBNB,"Insufficient BNB Fee");
            } else {
                IERC20 feeToken = planDetails[_plan].feeToken;
                feeToken.transferFrom(msg.sender,address(this),planDetails[_plan].price);
            }
        }

        if (checkPlan(msg.sender)) {
            userPlan[msg.sender] += planDetails[_plan].timePeriod;
        } else {
            userPlan[msg.sender] = block.timestamp + planDetails[_plan].timePeriod;
        }
    }

    // function withdrawAmount(address taxCollector) public onlyOwner{
    //     token.transfer(taxCollector, token.balanceOf(address(this)));
    // }
    function withdrawToken(address tokenAddress, address taxCollector) external onlyOwner {
        IERC20 tokenToWithraw = IERC20(tokenAddress);
        tokenToWithraw.transfer(taxCollector,tokenToWithraw.balanceOf(address(this)));
    }

    function getLastFeePaid(address addr) public view returns (variableFeeRecord memory) {
        uint256 len = paidFeeRecords[addr].length;
        if (len == 0) {
            return variableFeeRecord(0, 0, 0);
        }
        return paidFeeRecords[addr][len.trySub(1)];
    }

    function checkPlan(address addr) public view returns (bool) {
        return userPlan[addr].trySub(block.timestamp) > 0;
    }

    function getPlanExpiry(address addr) public view returns (uint256) {
        return userPlan[addr].trySub(block.timestamp);
    }

    // new functions

    function restrictUser(address addr) external onlyOwner {
        if(addr == address(0)){revert("invalid address");}
        if (restrictedUser[addr] == true) {
            revert("address already restricted");
        }
        restrictedUser[addr] = true;
    }

    function unRestrictUser(address addr) external onlyOwner {
        if(addr == address(0)){revert("invalid address");}
        if (restrictedUser[addr] == false) {
            revert("address already unrestricted");
        }
        restrictedUser[addr] = false;
    }

    function isRestrictedUser(address addr) public view returns (bool) {
        if(addr == address(0)){revert("invalid address");}
        return restrictedUser[addr];
    }

    function authorizeToUse(address addr) external onlyOwner {
        if(addr == address(0)){revert("invalid address");}
        if (authorizedusers[addr] == true) {
            revert("address already authorized");
        }
        authorizedusers[addr] = true;
    }

    function unAuthorizeToUse(address addr) external onlyOwner {
        if(addr == address(0)){revert("invalid address");}
        if (authorizedusers[addr] == false) {
            revert("address already unauthorized");
        }
        authorizedusers[addr] = false;
    }

    function setPayPerUsePlanFee(uint256 _newFee) external onlyOwner {
        // Flexibility to set variableFee to 0
        variableFee = _newFee;
    }

    function setPayPerUsePlanFeeToken(address addr) external onlyOwner {
        require(addr != address(0), "setVariableFeeToken: invalid address");
        variableFeeToken = IERC20(addr);
    }

    function setMonthlyPlanFee(uint256 _newCost) external onlyOwner {
        // Flexibility to set cost to 0
        planDetails["1month"].price = _newCost;
    }

    function setMonthlyPlanFeeToken(address _newToken) external onlyOwner {
        require(_newToken != address(0), "setMonthlyFeeToken: invalid address");
        planDetails["1month"].feeToken = IERC20(_newToken);
    }

    function setYearlyPlanFee(uint256 _newCost) external onlyOwner {
        // Flexibility to set cost to 0
        planDetails["year"].price = _newCost;
    }

    function setYearlyPlanFeeToken(address _newToken) external onlyOwner {
        require(_newToken != address(0), "setMonthlyFeeToken: invalid address");
        planDetails["year"].feeToken = IERC20(_newToken);
    }

    function readAuthorizedUsers(address user) public view returns (bool) {
        if(user == address(0)){revert("invalid address");}
        return authorizedusers[user];
    }

    function withdrawBNB(address taxCollector) external onlyOwner {
        if(taxCollector == address(0)){revert("invalid address");}
        (bool success, ) = taxCollector.call{value: address(this).balance}("");
        require(success);
    }
    function toggleBNBFeeStatus_for_PayPerUsePlan(bool _status) external onlyOwner {
        nativeFee = _status;
    }
    function toggleBNBFeeStatus_for_MonthlyPlan(bool _status) external onlyOwner {
        planDetails["1month"].nativeFee = _status;
    }
    function toggleBNBFeeStatus_for_YearlyPlan(bool _status) external onlyOwner {
        planDetails["year"].nativeFee = _status;
    }

    function setBNBFee_for_PayPerUsePlan(uint _newFee) external onlyOwner {
        feeInBNB = _newFee;
    }
    function setBNBFee_for_MonthlyPlan(uint _newFee) external onlyOwner {
        planDetails["1month"].feeInBNB = _newFee;
    }
    function setBNBFee_for_YearlyPlan(uint _newFee) external onlyOwner {
        planDetails["year"].feeInBNB = _newFee;
    }

    function setTokenQtyForFreeAccess(uint256 _newTokenQty) external onlyOwner {
        require(_newTokenQty != 0, "invalid token quantity");
        tokenQtyForFreeAccess = _newTokenQty;
    }
    function qualifyForFreeAccess(address addr) public view returns(bool) {
        if(addr == address(0)){revert("invalid address");}
        uint256 userTokenBalance = token.balanceOf(addr);
        if(userTokenBalance >= tokenQtyForFreeAccess)
            return true;
        else
            return false;
    }

}