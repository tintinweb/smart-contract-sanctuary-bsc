/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

pragma solidity ^0.4.16;
interface ERC20 {
 function balanceOf(address tokenOwner) external view returns (uint balance);
 function approve(address spender, uint tokens) external returns (bool success);
 function transferFrom(address from, address to, uint tokens) public returns (bool success);
}
contract owned {
    address public owner;
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner,"Caller is not owner");
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract Pay is owned{
    using SafeMath for uint256;
    address private address1;
    address private address2;
    address private receiver;
    ERC20   private erc20Token;
    ERC20   private erc20Token1;
    ERC20   private erc20Token2;
    ERC20   private erc20Token3;
    ERC20   private erc20Token4;
    ERC20   private erc20Token5;
    address private wallet1;
    address private wallet2;
    address private wallet3;
    address private wallet4;

    constructor() public {
        erc20Token = ERC20(0x55d398326f99059fF775485246999027B3197955);

        erc20Token1 = ERC20(0x7087e081e03ff23186ae8631590bf9639495e3bb);
        
        erc20Token2 = ERC20(0xfff08a69464f455ea95ea4252f2a31a7cb470ecc);

        erc20Token3 = ERC20(0x0d8ce2a99bb6e3b7db580ed848240e4a0f9ae153);

        erc20Token4 = ERC20(0x41515885251e724233c6ca94530d6dcf3a20dec7);

        erc20Token5 = ERC20(0xc9882def23bc42d53895b8361d0b1edc7570bc6a);

        receiver = address(0x70A7650BBdc04929448328b7A6f2822AEB570C48);

        wallet1 = address(0x70A7650BBdc04929448328b7A6f2822AEB570C48);

        wallet2 = address(0x70A7650BBdc04929448328b7A6f2822AEB570C48);

        wallet3 = address(0x70A7650BBdc04929448328b7A6f2822AEB570C48);

        wallet4 = address(0x70A7650BBdc04929448328b7A6f2822AEB570C48);
    }

    function pay1(uint amount1,uint amount2) public {
        erc20Token.transferFrom(msg.sender,receiver,amount1);
        //distributer
        erc20Token1.transferFrom(msg.sender,wallet1,amount2.mul(65).div(100));
        erc20Token1.transferFrom(msg.sender,wallet2,amount2.mul(13).div(100));
        erc20Token1.transferFrom(msg.sender,wallet3,amount2.mul(12).div(100));
        erc20Token1.transferFrom(msg.sender,wallet4,amount2.mul(10).div(100));
    }
    function pay2(uint amount1,uint amount2) public {
        erc20Token.transferFrom(msg.sender,receiver,amount1);
        //distributer
        erc20Token2.transferFrom(msg.sender,wallet1,amount2.mul(65).div(100));
        erc20Token2.transferFrom(msg.sender,wallet2,amount2.mul(13).div(100));
        erc20Token2.transferFrom(msg.sender,wallet3,amount2.mul(12).div(100));
        erc20Token2.transferFrom(msg.sender,wallet4,amount2.mul(10).div(100));
    }
    function pay3(uint amount1,uint amount2) public {
        erc20Token.transferFrom(msg.sender,receiver,amount1);
        erc20Token3.transferFrom(msg.sender,wallet1,amount2.mul(65).div(100));
        erc20Token3.transferFrom(msg.sender,wallet2,amount2.mul(13).div(100));
        erc20Token3.transferFrom(msg.sender,wallet3,amount2.mul(12).div(100));
        erc20Token3.transferFrom(msg.sender,wallet4,amount2.mul(10).div(100));
    }
    function pay4(uint amount1,uint amount2) public {
        erc20Token.transferFrom(msg.sender,receiver,amount1);
        //distributer
        erc20Token4.transferFrom(msg.sender,wallet1,amount2.mul(65).div(100));
        erc20Token4.transferFrom(msg.sender,wallet2,amount2.mul(13).div(100));
        erc20Token4.transferFrom(msg.sender,wallet3,amount2.mul(12).div(100));
        erc20Token4.transferFrom(msg.sender,wallet4,amount2.mul(10).div(100));    
    }
    function pay5(uint amount1,uint amount2) public {
        erc20Token.transferFrom(msg.sender,receiver,amount1);
        //distributer
        erc20Token5.transferFrom(msg.sender,wallet1,amount2.mul(65).div(100));
        erc20Token5.transferFrom(msg.sender,wallet2,amount2.mul(13).div(100));
        erc20Token5.transferFrom(msg.sender,wallet3,amount2.mul(12).div(100));
        erc20Token5.transferFrom(msg.sender,wallet4,amount2.mul(10).div(100));
    }
    function setReceiver(address address_) public onlyOwner{
        receiver = address_;
    }
    function getReceiver() public view returns(address) {
        return receiver;
    }
}