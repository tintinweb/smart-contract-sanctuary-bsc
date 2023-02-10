/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol


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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: contracts/BUSD-PrivateRound.sol


pragma solidity ^0.8.7;


contract BackBoneProPrivateRound {   
    using SafeMath for uint; // 

    address public  Owner;    
    uint256 public TokensSold;
    bool public SaleOpen = true;

    /* sale config */
    IERC20 public PayToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IERC20 public Token = IERC20(0x3f5D8371AddFA3703639dB0b3520b00fbc9FB095);
    uint256 public MinOrder = 1000000000000000000000; // Min token order 
    uint256 public MaxOrder = 30000000000000000000000000; // Max token order
    uint256 public TotalSupply = 300000000000000000000000000; // Total token supply
    uint256 public LockingTime = 15778476; // 6 Months Locking time in seconds
    uint256 public VestingTime = 63113904; // 24 Months Vesting time in seconds
    uint256 public ClaimPeriod = 86400; // Claim once per day 
    uint256 public TokenPrice = 5000000000000000; // Token price per BUSD
    /* end sale config */
    
    mapping(address => uint256) public UserBuy;
    mapping(address => uint256) public BuyDate;
    mapping(address => uint256) public LastClaim;
    mapping(address => uint256) public Claimed;

    event Buy(address indexed _buyer, uint256 _amount, uint256 date); // Save event to BlockChain
    event Claim(address indexed _buyer, uint256 _amount, uint256 date); // Save event to BlockChain
    event Transfer(address indexed _beneficiary, uint256 _destination, uint256 date); // Save event to BlockChain
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        Owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == Owner, "not authorized");
        _;
    }
    

    function TransferVesting(address _destination) public {
        require(UserBuy[msg.sender] > 0, "You dont have any vested amount");
        require(UserBuy[_destination] == 0, "Cannot transfer to available users");
        UserBuy[_destination] = UserBuy[msg.sender];
        BuyDate[_destination] = BuyDate[msg.sender];
        LastClaim[_destination] = LastClaim[msg.sender];
     
        UserBuy[msg.sender] = 0;
        BuyDate[msg.sender] = 0;
        LastClaim[msg.sender] = 0;
    }

    function BuyTokens(uint256 _numberOfTokens) public {
        require(UserBuy[msg.sender] == 0,"User has made a purchase");
        require(_numberOfTokens >= MinOrder,"Amount cannot lower than minimum");
        require(_numberOfTokens <= MaxOrder,"Amount cannot higher than maximum");
        require(_numberOfTokens <= TotalSupply,"Amount higher than available supply");
        require(SaleOpen == true,"Token sale is closed");

        uint256 TotalPayment = (_numberOfTokens/1e18).mul(TokenPrice);

        bool status = PayToken.transferFrom(
            msg.sender,
            address(this),
            TotalPayment
        );
        
        require(status==true);
        PayToken.transfer(Owner,TotalPayment); // move BUSD to Owner
        TokensSold += _numberOfTokens;
        LastClaim[msg.sender] = block.timestamp + LockingTime;
        BuyDate[msg.sender] = block.timestamp;
        UserBuy[msg.sender] = _numberOfTokens;
        TotalSupply -= _numberOfTokens;        
        emit Buy(msg.sender, _numberOfTokens, block.timestamp);
    }

    function claim() public {
        require(
            block.timestamp >= BuyDate[msg.sender] + LockingTime,
            "Claim available after 365 days cliff period"
        );
        require(
            (LastClaim[msg.sender] + ClaimPeriod) < block.timestamp,
            "Claim is available after 24H from last Claim"
        );
        uint256 reward = Earned(msg.sender);
        if (reward > 0) {
            Token.transfer(msg.sender, reward);
            Claimed[msg.sender] += reward;
            LastClaim[msg.sender] = block.timestamp;
            emit Claim(msg.sender, reward, block.timestamp);
        }        
    }

    function EndSale() public onlyOwner{
        Token.transfer(address(this),address(this).balance);
        SaleOpen = false;
    }

    function TransferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new Owner is the zero address");
        address oldOwner = Owner;
        Owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function Calculate(uint256 _numberOfTokens) public view returns (uint256) {
         return (_numberOfTokens/1e18).mul(TokenPrice);
    }

    // 63120000 24 month in seconds
    function Earned(address _account) public view returns (uint256) { 
        return ((block.timestamp - LastClaim[_account]) * UserBuy[_account].div(VestingTime));
    }

    function TotalBuy() public view returns (uint256) {
        return UserBuy[msg.sender];
    }
}

interface IERC20 {
    function TotalSupply() external view returns (uint256);
    function BalanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address Owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed Owner,
        address indexed spender,
        uint256 value
    );
}