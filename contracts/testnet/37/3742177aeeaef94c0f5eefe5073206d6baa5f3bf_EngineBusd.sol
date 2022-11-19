/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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

contract EngineBusd {
    
    uint256 public total_supply = 0;
    uint256 public decimals = 10**18;
    uint256 public price = 0.1 ether;
    uint256 public last_price = 0 ether;
    uint256 I_P = 0.00025 ether;
    uint256 D_P = 0.0004 ether;
    uint256 min_invest = 10 ether;
    uint256 max_invest = 15000 ether;
    uint256 public OverAllTvl = 0 ether;
    uint256 public Trading_Fee = 6; // all these fees will be trade on centralized exchanges and deposit to the project to increase the price
    uint256 public Other_Fee = 4; // marketing 3% and dev 1%
    uint256 public Ref_Fee = 3;
    uint256 public Compound = 1; 
    uint256 public Per_Day = 86400;
    uint256 public timeUnit = 0;
    uint256 public Transaction = 0;
    bool public launch = false;
    address public owner;
    address public wallet1 = 0xD44F8199b0eA2cFEe1ee8d58171581229DfBb597; // tradingWallet
    address public wallet2 = 0xD44F8199b0eA2cFEe1ee8d58171581229DfBb597; // OtherFees wallet
    address public TokenAddress;
    IERC20 public BUSD;

    constructor() {
        TokenAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // BUSD-MainNet
        BUSD = IERC20(TokenAddress);
        owner = msg.sender;
    }

    struct UserInvestment {
        address user_addr;
        uint256 amount;
        uint256 key;
    }

    struct UserDepoMap {
        address user_addr;
        uint256 key;
        uint256 amount;
        uint256 reward;
        uint256 startTime;
        uint256 deadline;
        bool init;
    }

    struct stakeId {
        address user_addr;
        uint256 stakeId;
    }

    struct UserCollected {
        address user_addr;
        uint256 amount;
    }

    struct UserRef {
        address user_addr;
        address ref_addr;
    }

    struct UserWithdrawTime {
        address user_addr;
        uint256 start_time;
        uint256 deadline;
    }

    struct PriceHistory {
        uint256 id;
        uint256 price;
        uint256 uTime;
    }

    struct UserOpenStakes {
        address user_addr;
        uint256 stakeslength;
    }



    mapping(address => UserInvestment) public UserQuery;
    mapping(address => mapping(uint256 => UserDepoMap)) public DepoQuery;
    mapping(address => UserCollected) public claimQuery;
    mapping(address => stakeId) public stakeQuery;
    mapping(address => UserRef) public refQuery;
    mapping(address => UserWithdrawTime) public withdrawTime;
    mapping(uint256 => PriceHistory) public priceQuery;
    mapping(address => UserOpenStakes) public userStakesQuery;


    

    function DEPO(address _ref, uint256 _amount) public {
        require(_ref!=msg.sender && _ref != address(0), "Ref error");
        require(launch,"Project is not yet live");
        require(_amount>=min_invest && _amount<=max_invest, "Kindly Min Investment is 50 BUSD and Max per deposit investment is 15000 BUSD");
       uint256 totalFee = SafeMath.add(feeViewer(_amount),OtherFee(_amount)); 
       uint256 _amtx = SafeMath.sub(_amount,totalFee);
       uint256 _price = price;
       uint256 getCoins = SafeMath.div(SafeMath.mul(_amtx,decimals),_price);
       

       
     
      // Add value to over TVL
       OverAllTvl = SafeMath.add(OverAllTvl,_amtx);

       // get previous data of user
       uint256 previousAmount = UserQuery[msg.sender].amount;
       uint256 totalCoins = SafeMath.add(getCoins,previousAmount);

       uint256 _point = UserQuery[msg.sender].key;


       UserQuery[msg.sender] = UserInvestment(
           msg.sender,
           totalCoins,
           _point + 1);
       
       BUSD.transferFrom(msg.sender,address(this),_amtx);
       BUSD.transferFrom(msg.sender,wallet1,feeViewer(_amount));
       BUSD.transferFrom(msg.sender,wallet2,OtherFee(_amount));

       // last Price 

       last_price = price;

       // price Calculation and setup the new price
       uint256 _power = BuyPower(_amtx);
       price = SafeMath.add(price,_power);

     
       
   
    
        timeUnit = timeUnit + 1;

        priceQuery[timeUnit] = PriceHistory(
            timeUnit,
            price,
            block.timestamp);
       

       // total Supply adding
       total_supply = SafeMath.add(total_supply,getCoins);

       refQuery[msg.sender] = UserRef(
           msg.sender,
           _ref);

       Transaction = Transaction + 1;
    }



   function Stake(uint256 _amount, uint256 noOfDays) public {
       uint256 _deadline = noOfDays * Per_Day;
       require(UserQuery[msg.sender].amount>=_amount);
       require(_deadline>=259200,"You cant stake less than 3 days");

       uint256 estimatedTarget = SafeMath.div(SafeMath.mul(_amount,Compound),100);
       uint256 toGetCoins = SafeMath.mul(noOfDays,estimatedTarget);
       uint256 totalReward = SafeMath.add(_amount,toGetCoins);
       total_supply = SafeMath.add(total_supply,toGetCoins); 
       uint256 _time = block.timestamp + _deadline; 
       uint256 _stakeId = stakeQuery[msg.sender].stakeId;
       if(stakeQuery[msg.sender].user_addr == address(0)) {
        
        uint256 userEngineBalance = UserQuery[msg.sender].amount;
        uint256 userKeyPad = UserQuery[msg.sender].key;
        uint256 nowEngineBalance = userEngineBalance - _amount;

        UserQuery[msg.sender] = UserInvestment(
            msg.sender,
            nowEngineBalance,
            userKeyPad); 

       DepoQuery[msg.sender][_stakeId] = UserDepoMap(
           msg.sender,
           0,
           _amount,
           totalReward,
           block.timestamp,
           _time, 
           false);

       stakeQuery[msg.sender] = stakeId(
           msg.sender,
           0);

       uint256 currentStakes = userStakesQuery[msg.sender].stakeslength;
       userStakesQuery[msg.sender] = UserOpenStakes(
           msg.sender,
           currentStakes);
          
       }
        else {
        uint256 _stakeIdIncrease = _stakeId + 1;   
        uint256 userEngineBalance = UserQuery[msg.sender].amount;
        uint256 userKeyPad = UserQuery[msg.sender].key;
        uint256 nowEngineBalance = SafeMath.sub(userEngineBalance,_amount);
        
        UserQuery[msg.sender] = UserInvestment(
            msg.sender,
            nowEngineBalance,
            userKeyPad); 

       DepoQuery[msg.sender][_stakeIdIncrease] = UserDepoMap(
           msg.sender,
           _stakeId + 1,
           _amount,totalReward,
           block.timestamp,
           _time,
            false);

       stakeQuery[msg.sender] = stakeId(msg.sender,_stakeId + 1);

       uint256 currentStakes = userStakesQuery[msg.sender].stakeslength;
       userStakesQuery[msg.sender] = UserOpenStakes(
           msg.sender,
           currentStakes + 1);
           }

    
    if(withdrawTime[msg.sender].user_addr == address(0)) {
        uint256 WDdeadline = block.timestamp + 3 days;

        withdrawTime[msg.sender] = UserWithdrawTime(
            msg.sender,
            block.timestamp,
            WDdeadline);
    }
     
    
   }


   function Collect(uint256 _StakeId) public {
       require(block.timestamp>=DepoQuery[msg.sender][_StakeId].deadline, "Please Wait Till your Time comes for Collection"); // TestNet Function Off
       require(!DepoQuery[msg.sender][_StakeId].init,"You have already Collected The Stake");
       uint256 _previous = claimQuery[msg.sender].amount;
       uint256 _earned = DepoQuery[msg.sender][_StakeId].reward;
       uint256 _value = SafeMath.add(_previous,_earned);
       claimQuery[msg.sender] = UserCollected(
        msg.sender,
        _value);
       DepoQuery[msg.sender][_StakeId].init = true;
    }


    function Swap(uint256 _amount) public {
        require(claimQuery[msg.sender].amount>=_amount); 
        require(AntiWhale(msg.sender)>=_amount);
        require(block.timestamp>=withdrawTime[msg.sender].deadline,"Your next withdraw time is still left"); // TestNet Function Off
        
        
        uint256 total = SafeMath.mul(_amount,price);
        uint256 _total = SafeMath.div(total,decimals);
      
       // last price 
        last_price = price;
       // sell formula
       uint256 _power = SellPower(_total);
       price = SafeMath.sub(price,_power);

        uint256 addPrice = priceQuery[0].price;
       
       if(addPrice == 0) {
         priceQuery[timeUnit] = PriceHistory(
             timeUnit,
             price,
             block.timestamp);
       }
       else {
        timeUnit = timeUnit + 1;
        priceQuery[timeUnit] = PriceHistory(
            timeUnit,
            price,
            block.timestamp);
       }

       uint256 refFee = ReffeeViewer(_total);
       uint256 userValue = SafeMath.sub(_total,refFee);
       // total Supply Subtracting
       total_supply = SafeMath.sub(total_supply,_amount);
       BUSD.transfer(msg.sender,userValue);
       BUSD.transfer(refQuery[msg.sender].ref_addr,refFee);

        uint256 _val = SafeMath.sub(claimQuery[msg.sender].amount,_amount);
        claimQuery[msg.sender].amount = _val;

        uint256 deadline = block.timestamp + 1 days;

        withdrawTime[msg.sender] = UserWithdrawTime(
            msg.sender,
            block.timestamp,
            deadline);
  
        Transaction = Transaction + 1;


    }


     function AntiWhale(address _userAddr) public view returns(uint256) {
        uint256 _amount = claimQuery[_userAddr].amount;
         uint256 output = SafeMath.mul(_amount,price);
        uint256 _output = SafeMath.div(output,decimals);
        _output = SafeMath.mul(_output,10);
        uint256 TVL = TVL_NOW();
        

        uint256 total = SafeMath.div(SafeMath.mul(TVL,50),100);

        if(total>=_output) {
            return _amount;
        }
        else {
           
            return SafeMath.div(SafeMath.mul(total,10**18),price);
        }
     }

     function Launch() public {
         require(msg.sender == owner && !launch,"This Function is only for admin");
         launch = true;

         priceQuery[0] = PriceHistory(
             0,
             price,
             block.timestamp);
        }

   

 

     // Supportive functions
     
     function feeViewer(uint256 _amount) public view returns(uint256) {
         uint256 _value =  SafeMath.div(_amount,100);
         return SafeMath.mul(_value,Trading_Fee);
     }

        function OtherFee(uint256 _amount) public view returns(uint256) {
         uint256 _value =  SafeMath.div(_amount,100);
         return SafeMath.mul(_value,Other_Fee);
     }

     function ReffeeViewer(uint256 _amount) public view returns(uint256) {
         uint256 _value =  SafeMath.div(_amount,100);
         return SafeMath.mul(_value,Ref_Fee);
     }

     function BuyPower(uint256 _amount) public view returns(uint256) {
        uint256 _value =  SafeMath.mul(_amount,I_P);
         uint256 _output = SafeMath.div(_value,decimals);
        return SafeMath.div(_output,100);
     }

     function SellPower(uint256 _amount) public view returns(uint256) {
         uint256 _value =  SafeMath.mul(_amount,D_P);
         uint256 _output = SafeMath.div(_value,decimals);
         return SafeMath.div(_output,100);
     }


     function TVL_NOW() public view returns(uint256) {
         return BUSD.balanceOf(address(this));
     }

    

}