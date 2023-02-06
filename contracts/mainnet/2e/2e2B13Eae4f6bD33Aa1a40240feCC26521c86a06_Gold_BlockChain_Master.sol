// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./SafeMath.sol";

interface Gold_BlockChain
{
    function balanceOf(address user) external view returns(uint);
    function transferFrom(address _from, address _to, uint _value) external returns(bool);
}

contract Gold_BlockChain_Master{
    using SafeMath for uint;
    Gold_BlockChain public GBCtoken;

    struct Deposit {
        uint amount ;
        uint timestamp;
    }

    struct  User {
        uint tolalAmount;
        uint withdrawan;
        Deposit [] deposit;
    }

     modifier onlyAdmin() {
        require(msg.sender == admin,"no acess");
        _;
    }


    bool public started;
    bool private IsInitinalized;
    address payable public admin;
    uint public tokenPrice;
    mapping (address => User)  public userdata;

    function initialize(address payable _admin, Gold_BlockChain _tokenAddress) external{
        require(IsInitinalized ==false);
        admin = _admin;
        GBCtoken = _tokenAddress;
        tokenPrice = 1e8;
        IsInitinalized = true ;
    }


   

    function deposit (uint _amount) public {
        User storage user = userdata[msg.sender];
       uint balance = GBCtoken.balanceOf(msg.sender);
       require(balance>=_amount,"Insufficant funds");
       user.tolalAmount = user.tolalAmount.add(_amount);
       user.deposit.push(Deposit(_amount,block.timestamp));
       GBCtoken.transferFrom(msg.sender, address(this), _amount);
        
    }

    function withdraw(address _user,uint _tokenAmount) public onlyAdmin{
        uint balance = GBCtoken.balanceOf(msg.sender);
       require(balance>=_tokenAmount,"Insufficant funds");
      userdata[_user].withdrawan += _tokenAmount;
      GBCtoken.transferFrom(address(this),_user ,_tokenAmount);   
    }

    function adminTransfer(address _admin,uint _amount) public onlyAdmin{
        uint balance = GBCtoken.balanceOf(msg.sender);
       require(balance>=_amount,"Insufficant funds");
       GBCtoken.transferFrom(address(this),_admin ,_amount);

    } 

    function checkBalance(address _user) public view returns(uint){
        uint balance = GBCtoken.balanceOf(_user);
        return balance;
    }




    function getDepositLength(address _useraddress) public view returns(uint){
        User storage u = userdata[_useraddress] ;
        return u.deposit.length;
    }


    function getDeposit(uint _index ,address _useraddress) public view returns(uint,uint){
        User storage u = userdata[_useraddress] ;
        return (u.deposit[_index].amount,u.deposit[_index].timestamp);
    } 
       
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

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