/**
 *Submitted for verification at BscScan.com on 2022-09-06
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


contract hd is Context, Ownable , ReentrancyGuard {
    using SafeMath for uint256;
    uint256 public constant min = 9.99 ether; //min deposite 10 busd
    uint256 public constant fee = 5; //5% dev fee
    uint256 public constant withdraw_fee = 5; //5% dev fee
    uint256 public constant ref_fee = 10; //referral reward 10%
    uint256 public minerId = 0;
    uint256 public chestId = 0;
    address public dev = 0xb82C7938766A6e25F694FCc953691B335a0E5bfd;
    IERC20 private BusdInterface;
    address public tokenAddress;
    bool public init = false;
    bool public alreadyInvested = false;
    constructor() {
    tokenAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; 
    BusdInterface = IERC20(tokenAddress);
                 }

    struct refferal_system {
        address ref_address;
        uint256 reward;
    }

    struct refferal_withdraw {
        address ref_address;
        uint256 totalWithdraw;
    }

    struct user_investment_details {
        address user_address;
        uint256 invested;
    }

    struct userBalance {
        address user_address;
        uint256 buybalance;
        uint256 withdrawbalance;
    }

    struct miners {
        uint256 id;
        address owner;
        uint256 lvl;
        uint256 date;
    }

    struct chests {
        uint256 id;
        uint256 persId;
        address owner;
        uint256 lvl;
    }

    struct claims {
        address owner;
        uint256 amount;
    }


    mapping(address => refferal_system) public refferal;
    mapping(address => user_investment_details) public investments;
    mapping(address => refferal_withdraw) public refTotalWithdraw;
    mapping(address => userBalance) public balance;
    mapping(uint256 => miners) public miner;
    mapping(uint256 => chests) public chest;
    mapping(address => claims) public claim;

    function checkAlready() public view returns(bool) {
        address _address= msg.sender;
        if(investments[_address].user_address==_address){
            return true;
        }
        else{
            return false;
        }
    }

        function refFee(uint256 _amount) public pure returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,ref_fee),100);
    }

        function depositFee(uint256 _amount) public pure returns(uint256) {
     return SafeMath.div(SafeMath.mul(_amount,fee),100);
    }



    function hire(uint256 lvl) public {
        uint256 price = 1000*(2**(lvl-1));
        if (lvl<1 || lvl>8 || balance[msg.sender].buybalance<price) {
           
        } else {
            uint256 id = minerId+1;
            miner[id] = miners(id,msg.sender,lvl,block.timestamp);
            uint256 newBalance = SafeMath.sub(balance[msg.sender].buybalance,price);
            balance[msg.sender] = userBalance(msg.sender,newBalance,balance[msg.sender].withdrawbalance);
            minerId=id;
        }
    }

    function upgradeMiner(uint256 id) public {
        uint price = 0;
        for (uint i=1; i<=minerId; i++) {
            if (miner[i].owner == msg.sender && miner[i].id == id) {
                price = (2**miner[i].lvl)*250;
                if (balance[msg.sender].withdrawbalance>=price) {
                    uint lvl=SafeMath.add(miner[i].lvl,1);
                    uint neww = SafeMath.sub(balance[msg.sender].withdrawbalance,price);
                    balance[msg.sender] = userBalance(msg.sender,balance[msg.sender].buybalance,neww);
                    claimReward();
                    miner[i] = miners(i,msg.sender,lvl, miner[i].date);
                }
            }
        }
    }

    function buychest() public {
        uint c = 0;
        for (uint i = 1; i <= chestId; i++) {
            if (chest[i].owner == msg.sender) {
                c++;
            }
        }
        if (c<4 && balance[msg.sender].buybalance>=100) {
            uint id = SafeMath.add(chestId,1);
            c++;
            uint newBalance = SafeMath.sub(balance[msg.sender].buybalance,100);
            chest[id] = chests(id,c,msg.sender,1);
            balance[msg.sender] = userBalance(msg.sender,newBalance,balance[msg.sender].withdrawbalance);
            chestId++;
        }
    }

    function getReward() public view returns(uint256) {
        uint reward = 0;
        for (uint i=1;i<=minerId;i++) {
            if (miner[i].owner == msg.sender) {
                reward += (block.timestamp-miner[i].date)*(2**(miner[i].lvl-1)*(4+miner[i].lvl)*10)/86400;
            }
        }
        reward = SafeMath.sub(reward,claim[msg.sender].amount);
        return reward;
    }

    function claimReward() public {
        uint reward = 0;
        uint cap = 0;
        for (uint i=1;i<=minerId;i++) {
            if (miner[i].owner == msg.sender) {
                reward += (block.timestamp-miner[i].date)*(2**(miner[i].lvl-1)*(4+miner[i].lvl)*10)/86400;
                miner[i] = miners(i,msg.sender,miner[i].lvl,block.timestamp);
            }
        }
        for (uint i=1;i<=chestId;i++) {
            if (chest[i].owner == msg.sender) {
                cap+=200*(5**(chest[i].lvl-1));
            }
        }
        if (reward>cap) {
            reward=cap;
        }

        reward = SafeMath.add(reward,balance[msg.sender].withdrawbalance);
        balance[msg.sender] = userBalance(msg.sender,balance[msg.sender].buybalance,reward);
    }

    function upgradechest(uint256 id) public {
        for (uint i = 1; i <= chestId; i++) {
            uint price = 500*(5**(chest[i].lvl-1));
            if (chest[i].owner == msg.sender && chest[i].persId == id && balance[msg.sender].buybalance>=price && chest[i].lvl<7) {
                uint newlvl = SafeMath.add(chest[i].lvl,1);
                chest[i]=chests(i,id,msg.sender,newlvl);
                uint newBalance = SafeMath.sub(balance[msg.sender].buybalance,price);
                balance[msg.sender] = userBalance(msg.sender,newBalance,balance[msg.sender].withdrawbalance);
            }
        }
    }

    function getMiners() public view returns(uint256) {
        if (minerId == 0) {
            return 0;
        } else {
            uint256 m = 0;
            for (uint i = 1; i <= minerId; i++) {
                if (miner[i].owner == msg.sender) {
                    m = m*10+miner[i].lvl;
                }
            }
            return m;
        }
    }

    function getChests() public view returns(uint256) {
        if (chestId == 0) {
            return 0;
        } else {
            uint256 ch = 0;
            for (uint i = 1; i <= chestId; i++) {
                if (chest[i].owner == msg.sender) {
                    ch = ch*10+chest[i].lvl;
                }
            }
            return ch;
        }
    }


    // invest function 
    function deposit(address _ref, uint256 _amount) public noReentrant  {
        require(init, "Not Started Yet");
        require(_amount>=min, "Cannot Deposit");
        uint256 userCurrentInvestment = SafeMath.div(_amount,10000000000000000);
        if(!checkAlready()){
            // chest
            uint256 id = chestId+1;
            chest[id] = chests(id,1,msg.sender,1);
            chestId = id;
            userCurrentInvestment = SafeMath.add(userCurrentInvestment,SafeMath.div(userCurrentInvestment,10));
        }

        uint256 ref_fee_add = refFee(userCurrentInvestment);
        if(_ref != address(0) && _ref != msg.sender) {
        uint256 ref_last_balance = refferal[_ref].reward;
        uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);   
        refferal[_ref] = refferal_system(_ref,totalRefFee);
        uint256 addref = SafeMath.add(ref_fee_add,balance[_ref].withdrawbalance);   
        balance[_ref] = userBalance(_ref,balance[_ref].buybalance,addref);

        }
        else {
            uint256 ref_last_balance = refferal[dev].reward;
            uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);  
            refferal[dev] = refferal_system(dev,totalRefFee);
        }



        // investment details
        uint256 userLastInvestment = investments[msg.sender].invested;
        uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
        investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);
        uint256 oldBalance = balance[msg.sender].buybalance;
        uint256 newBalance = SafeMath.add(oldBalance,userCurrentInvestment);
        balance[msg.sender] = userBalance(msg.sender,newBalance,balance[msg.sender].withdrawbalance);


        // fees 
        uint256 total_fee = depositFee(_amount);
        uint256 total_contract = SafeMath.sub(_amount,total_fee);
        BusdInterface.transferFrom(msg.sender,dev,total_fee);
        BusdInterface.transferFrom(msg.sender,address(this),total_contract);
    }

    function withdraw(uint256 amount) public noReentrant {
        uint256 check = SafeMath.div(amount,10000000000000000);
        if (check<=balance[msg.sender].withdrawbalance) {
            uint256 wamount = SafeMath.sub(amount,SafeMath.div(amount,20));
            uint256 wfee = SafeMath.div(amount,20);
            BusdInterface.transfer(msg.sender,wamount);
            BusdInterface.transfer(dev,wfee);

            wamount = SafeMath.sub(balance[msg.sender].withdrawbalance,check);
            balance[msg.sender] = userBalance(msg.sender,balance[msg.sender].buybalance,wamount);
        } 
    }

    function exchange(uint256 amount) public {
        if (amount<=balance[msg.sender].withdrawbalance) {
            uint neww = SafeMath.sub(balance[msg.sender].withdrawbalance,amount);
            amount = SafeMath.add(amount,SafeMath.div(amount,10));
            uint newb = SafeMath.add(balance[msg.sender].buybalance,amount);
            balance[msg.sender] = userBalance(msg.sender,newb,neww);
        }
    }



     function getBuyBalance() public view returns(uint256){
         return balance[msg.sender].buybalance;
    }    

     function getWithdrawBalance() public view returns(uint256){
         return balance[msg.sender].withdrawbalance;
    }    

    // initialize the game

    function signal_market() public onlyOwner {
        init = true;
    }


}