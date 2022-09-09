/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

//SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

interface IERC20 
{

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}


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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}


contract mr is Context, Ownable , ReentrancyGuard {

    uint256 public constant min = 49.99 ether; //min deposit 50 busd
    uint256 public constant max = 9999.99 ether; //min deposit 10000 busd
    address public dev = 0xb82C7938766A6e25F694FCc953691B335a0E5bfd;
    IERC20 private BusdInterface;
    address public tokenAddress;
    bool public init = false;
    constructor() {
    tokenAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; 
    BusdInterface = IERC20(tokenAddress);
                 }

    struct user_investment_details {
        address user_address;
        uint256 invested;
    }

    struct userBalance {
        address user_address;
        uint256 invested;
        uint256 claimed;
        uint256 withdrawn;
        uint256 withdraw;
        uint256 start_claim;
        uint256 start_withdraw;
        uint256 ref_balance;
        uint256 ref_withdrawn;
    }

    mapping(address => user_investment_details) public investments;
    mapping(address => userBalance) public balance;


    function checkAlready() public view returns(bool) {
        address _address= msg.sender;
        if(investments[_address].user_address==_address){
            return true;
        }
        else{
            return false;
        }
    }

    function deposit(address ref, uint256 amount) public noReentrant {
        require(init, "Not Started Yet");
        require(amount>=min && amount<=max, "Cannot Deposit");
        uint256 addref = SafeMath.add(balance[msg.sender].ref_balance,SafeMath.div(amount,10));
        uint256 fee = SafeMath.div(amount,20);
        
        if(!checkAlready()){
            balance[msg.sender] = userBalance(msg.sender,amount,0,0,0,block.timestamp,block.timestamp,balance[msg.sender].ref_balance,balance[msg.sender].ref_withdrawn);
        } else {
            uint256 newInv = SafeMath.add(amount,balance[msg.sender].invested);
            balance[msg.sender] = userBalance(msg.sender,newInv,balance[msg.sender].claimed,balance[msg.sender].withdrawn,balance[msg.sender].withdraw,block.timestamp,balance[msg.sender].start_withdraw,balance[msg.sender].ref_balance,balance[msg.sender].ref_withdrawn);
        }
        
        if(ref != address(0) && ref != msg.sender) {
        balance[ref] = userBalance(ref,balance[ref].invested,balance[ref].claimed,balance[ref].withdrawn,balance[ref].withdraw,balance[ref].start_claim,balance[ref].start_withdraw,addref,balance[ref].ref_withdrawn);
        }
        else {
        balance[dev] = userBalance(dev,balance[dev].invested,balance[dev].claimed,balance[dev].withdrawn,balance[dev].withdraw,balance[dev].start_claim,balance[dev].start_withdraw,addref,balance[dev].ref_withdrawn);
        }

        // fees 
        uint256 total_contract = SafeMath.sub(amount,fee);
        BusdInterface.transferFrom(msg.sender,dev,fee);
        BusdInterface.transferFrom(msg.sender,address(this),total_contract);

    }

    function claim() public {
        uint256 end = balance[msg.sender].start_claim + 1 days;
        if (block.timestamp>=end) {
            uint256 claimAmount = SafeMath.mul(SafeMath.div(balance[msg.sender].invested,625),100);
            uint256 addClaim = SafeMath.add(claimAmount,balance[msg.sender].claimed);
            uint256 addWithdraw = SafeMath.add(claimAmount,balance[msg.sender].withdraw);
            balance[msg.sender] = userBalance(msg.sender,balance[msg.sender].invested,addClaim,balance[msg.sender].withdrawn,addWithdraw,block.timestamp,balance[msg.sender].start_withdraw,balance[msg.sender].ref_balance,balance[msg.sender].ref_withdrawn);
        }
    }

    function withdraw() public {
        uint256 end = balance[msg.sender].start_withdraw + 7 days;
        if (block.timestamp>=end) {
            uint256 newWithdraw = SafeMath.div(balance[msg.sender].withdraw,2);
            uint256 addWithdrawn = SafeMath.add(balance[msg.sender].withdrawn,newWithdraw);
            uint256 fee = SafeMath.div(balance[msg.sender].withdraw,20);
            balance[msg.sender] = userBalance(msg.sender,balance[msg.sender].invested,balance[msg.sender].claimed,addWithdrawn,newWithdraw,balance[msg.sender].start_claim,block.timestamp,balance[msg.sender].ref_balance,balance[msg.sender].ref_withdrawn);
            BusdInterface.transfer(msg.sender,newWithdraw);
            BusdInterface.transfer(dev,fee);
        }
    }

    function reinvest() public {
        uint256 newInvest = SafeMath.add(balance[msg.sender].invested,balance[msg.sender].withdraw);
        balance[msg.sender] = userBalance(msg.sender,newInvest,balance[msg.sender].claimed,balance[msg.sender].withdrawn,0,balance[msg.sender].start_claim,balance[msg.sender].start_withdraw,balance[msg.sender].ref_balance,balance[msg.sender].ref_withdrawn);
    }

    function ref_withdraw() public {
        uint256 newWithdraw = SafeMath.add(balance[msg.sender].ref_withdrawn,balance[msg.sender].ref_balance);
        BusdInterface.transfer(msg.sender,balance[msg.sender].ref_balance);
        balance[msg.sender] = userBalance(msg.sender,balance[msg.sender].invested,balance[msg.sender].claimed,balance[msg.sender].withdrawn,balance[msg.sender].withdraw,balance[msg.sender].start_claim,balance[msg.sender].start_withdraw,0,newWithdraw);
    }

    function getInvested() public view returns(uint256) {
        return balance[msg.sender].invested;
    }

    function getClaimed() public view returns(uint256) {
        return balance[msg.sender].claimed;
    }

    function getWithdrawn() public view returns(uint256) {
        return balance[msg.sender].withdrawn;
    }

    function getClaimTime() public view returns(uint256) {
        return balance[msg.sender].start_claim;
    }

    function getWithdraw() public view returns(uint256) {
        return balance[msg.sender].withdraw;
    }

    function getWithdrawTime() public view returns(uint256) {
        return balance[msg.sender].start_withdraw;
    }

    function getRefBalance() public view returns(uint256) {
        return balance[msg.sender].ref_balance;
    }

    function getrefWithdrawn() public view returns(uint256) {
        return balance[msg.sender].ref_withdrawn;
    }

    function signal_market() public onlyOwner {
        init = true;
    }
}