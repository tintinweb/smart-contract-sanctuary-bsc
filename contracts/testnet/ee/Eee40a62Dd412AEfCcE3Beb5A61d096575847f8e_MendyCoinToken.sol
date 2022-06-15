/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.2;

//@title SafeMath -> for Safe Mathematical operatios
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

contract MendyCoinToken {
    
    using SafeMath for uint;
    //Array List of Balances of the Address
    mapping(address => uint) public balances;

    //Array list, Child Addresses.
    //@dev It means, you can send a token without using directly your owned Address, instead you can use Child
    mapping(address => mapping(address => uint)) public allowances;

    //Array list, Exempted from fees
    //@dev NOTE: Admins are automatically exempted from fees, not need to be listed here
    mapping(address => bool) public excemptToFee;

    //@dev initial total Supply of token
    uint public totalSupply = 10000 * 10 ** 18;

    //@dev initial fee, for every transfer transaction. zerp means no fee.
    uint public fee = 0;

    //@dev holds the address of the creator of this token
    address public master_admin;

    //@dev holds the list of admins, admins with special access of some restricted functions but not master`s functions
    mapping(address => bool) public admins;

    //@dev Name and Symbol of the Crypto Token
    string public name = "Mendy Coin Token";
    string public symbol = "MCT";

    //@dev Max Decimal of Token Value if 4 means 0.0004
    uint public decimals = 18;

    //@dev Used for keep track every action, thats affect the supply or balances of this tokens
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed sender, uint value);
    event Mint(address indexed sender, uint value);
    event TransferMaster(address indexed master, address indexed newMaster);

    //This will called once after deployment.
    constructor() {
        //@dev Let the supply to be insterted to the Owner
        balances[msg.sender] = totalSupply;
    }

    /**************************************************************
    *This Section is for Functions, that can be used Internal Only*
    **************************************************************/

    //@dev calculateFee -> use to calculate fee from the specified amount
    //Formula: amount x fee/100
    function calculateFee(uint amount) private view returns (uint) {
        return amount.mul(fee).div(10**2);
    }

    //@dev calculateAmount -> use to calculate the amount - fee, and returns final amount and fee.
    function calculateAmount(uint amount) private view returns (uint, uint) {
        uint _fee    =   calculateFee(amount);
        uint _amount =   amount.sub(_fee);
        return (_amount, _fee); 
    }


    /********************************************************
    *This Section is for Functions, that can be used outside*
    *********************************************************/

    //@dev balanceOf -> reads the balance of the specified address
    function balanceOf(address owner) public view returns (uint) {
        return balances[owner];
    }

    //@dev totalSupplyToken -> reads the current total supply of the Token
    function totalSupplyToken() public view returns (uint) {
        return totalSupply;
    }

    //@dev whoisMaster -> use to know who hold the ownership
    function whoisMaster() public view returns (address) {
        return master_admin;
    }

    //@dev transfer -> sends token to a specified address
    //the function name "transfer" is required by the binance smart chain
    //NOTE: if fees is not zero, fees will automatically applied 
    function transfer(address to, uint value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "Insufficient Balance");
        
        //Check First if the Sender is Exempted from the Fee, or Fee is set to zero
        if(excemptToFee[msg.sender]==true || admins[msg.sender]==true || fee == 0) {
            balances[to] += value;
            balances[msg.sender] -= value;
        } else {
            (uint _value, uint _fee) = calculateAmount(value);
            balances[to] += _value;
            balances[msg.sender] -= value; //Deduct the Original Amount
            balances[master_admin] += _fee; //Fees will goto Master
        }
        
        emit Transfer(msg.sender, to, value);
        return true;
    }

    //@dev transferFrom -> use child address to send token from parent to other address
    //NOTE: if fees is not zero, fees will automatically applied 
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, "Insufficient Balance");
        require(allowances[from][msg.sender] >= value, "Insufficient Child Balance");

        //Check First if the Sender is Exempted from the Fee, or Fee is set to zero
        if(excemptToFee[from]==true || admins[from]==true || fee == 0) {
            balances[to] += value;
            balances[from] -= value;
        } else {
            (uint _value, uint _fee) = calculateAmount(value);
            balances[to] += _value;
            balances[from] -= value; //Deduct the Original Amount
            balances[master_admin] += _fee; //Fees will goto Master
        }

        emit Transfer(from, to, value);
        return true;
    }

    //@dev approve -> use to assign 'max allowed amount' to spend, by the child (spender)
    function approve(address spender, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, "Insufficient Balance");
        //Register Child and specified which amount is allowed to spent of the child from the Parent Address;
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    //@dev mint -> use to add a supply to token
    //NOTE: added token will be automatically added to owner balances.
    function mint(uint value) public returns(bool) {
        require(admins[msg.sender] == true || msg.sender == master_admin, "Not Authorized");
        totalSupply += value;
        balances[msg.sender] += value;
        emit Mint(msg.sender, value);
        return true;
    }

    //@dev burn -> use to burn the supply to token
    //NOTE: Only the token of the sender will be burned, and does not affect other addresses
    function burn(uint value) public returns(bool) {
        require(admins[msg.sender] == true || msg.sender == master_admin, "Not Authorized");
        require(balanceOf(msg.sender) >= value,"The amount of token must equal or below to your balances.");
        totalSupply -= value;
        balances[msg.sender] -= value;
        emit Burn(msg.sender, value);
        return true;
    }

    //@dev setFee -> use to set the fee of every Transfer transaction
    //NOTE: Set it to zero, do disable fee
    function setFee(uint fee_percent) public returns(bool) {
        require(msg.sender == master_admin, "Only the Master has the right to do this");    
        require(fee_percent < 20, "More than 20% fee is huge, please make it lower");
        
        if(fee_percent < 0) {
            fee_percent = 0;
        }
        fee = fee_percent;
        return true;
    }

    //@dev setAdmin -> use to give access to administrative functions.
    //NOTE: Only the master has the right to assign admins.
    function setAdmin(address admin_address) public returns(bool) {
        require(master_admin != admin_address, "This is the master, not needed to register");
        require(msg.sender == master_admin, "Only the Master has the right to do this");
        require(admins[admin_address] == false, "Already in Admin list");
        admins[admin_address] = true;
        return true;
    }

    //@dev demoteAdmin -> use to remove from admins list and restrict its access to administrative functions.
    //NOTE: Only the master has the right to assign admins.
    function demoteAdmin(address admin_address) public returns(bool) {
        require(master_admin != admin_address, "This is the master, not needed to register");
        require(msg.sender == master_admin, "Only the Master has the right to do this");
        require(admins[admin_address] == true, "Already not Admin");
        admins[admin_address] = true;
        return true;
    }

    //@dev transferMaster -> use to transfer or assign new master/owner of this token.
    //NOTE: Only the current Master / Owner can perform this action.
    function transferMaster(address master) public returns(bool) {
        require(master_admin != master, "Already a Master");
        require(msg.sender == master_admin, "Only the Master has the right to do this");
        emit TransferMaster(master_admin, master);
        master_admin = master;
        return true;
    }

    //@dev renounceMaster -> use to leave being a master/ownership of this token, without assigning a new, which means it will assign to the orignal master (address(0))
    //NOTE: Only the current Master / Owner can perform this action.
    function renounceMaster() public returns(bool){
        require(msg.sender == master_admin, "Only the Master has the right to do this");
        master_admin = address(0);
        return true;
    }

}