/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



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


interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

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





contract Alexa_StakingDAPP  {

    using SafeMath for uint256;
   string public name = "Alexa STAKING DAPP";
   address public owner ;
   address public  lPAdress ;
    IERC20  public Alexa ;
  mapping(address => bool) public hasStaked;
    uint256 public totalStakers;

      struct Deposit {
        uint64 amount;
        uint64 withdrawn;
        uint32 start;
    }


    Deposit[] empty;


 struct User {
        Deposit[] deposits;
        uint32 checkpoint;
        address referrer;
        uint64 bonus;
        uint24[3] refs;
        // uint16 rbackPercent;
    }
mapping (address  => mapping(uint256  => User)) internal users;

 event Newbie(address user);
    event NewDeposit(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    event RefBonus(address indexed referrer, address indexed referral, uint indexed level, uint amount);
    event RefBack(address indexed referrer, address indexed referral, uint amount);
    event FeePayed(address indexed user, uint totalAmount);


  uint256 public Plan1 = 45 days;  
  uint256 public Plan2 =  90 days;  
  uint256 public Plan3 = 180 days;  
uint256 public Plan4 =  365 days;  
uint256 public Plan5 = 500 days;  
uint256 public Plan6 = 730 days;  

uint256 public totalStakedOfPlan1;
uint256 public totalStakedOfPlan2;
uint256 public totalStakedOfPlan3;
uint256 public totalStakedOfPlan4;
uint256 public totalStakedOfPlan5;
uint256 public totalStakedOfPlan6;
  
  
  
uint[] public REFERRAL_PERCENTS = [500 , 300 , 100];   //5% , 3% , 1%
 uint256 public Plan1APY = 2400; // 24%;
 uint256 public Plan2APY = 4800; // 48%;
 uint256 public Plan3APY = 2400; // 24%;
 uint256 public Plan4APY = 12000; // 120%;
 uint256 public Plan5APY = 14400; // 144%;
uint256 public Plan6APY = 15000; // 150%;
uint256 public taxUnstake = 2500; // 25% 
uint256 public depositFee = 1000; // 10% 
uint256 public lPFee = 1000; // 10% 
uint constant public PERCENTS_DIVIDER = 10000;
 uint public totalRefBonus;
 uint public totalInvested;
 uint public totalDeposits;
 uint256 public INVEST_MIN_AMOUNT = 100000000000; // 85000000000
uint256 public INVEST_MAX_AMOUNT = 1000000000000;
uint constant public TIME_STEP = 1 days;
uint public totalWithdrawn;

mapping(address => uint256) public stakingBalancePlan1;
mapping(address => uint256) public stakingBalancePlan2;
mapping(address => uint256) public stakingBalancePlan3;
mapping(address => uint256) public stakingBalancePlan4;
mapping(address => uint256) public stakingBalancePlan5;
mapping(address => uint256) public stakingBalancePlan6;

mapping(address => uint256) public stakingStartTime1;
mapping(address => uint256) public stakingStartTime2;
mapping(address => uint256) public stakingStartTime3;
mapping(address => uint256) public stakingStartTime4;
mapping(address => uint256) public stakingStartTime5;
mapping(address => uint256) public stakingStartTime6;



 constructor(IERC20 _TokenAdress  , address _lPAdress ) public  {
        Alexa  = _TokenAdress;
        owner = msg.sender;
        lPAdress = _lPAdress;
    
    }




function stakeTokens(uint256 _amount , uint256 _plan, address referrer) public {
     require( _amount>= INVEST_MIN_AMOUNT && _amount <= INVEST_MAX_AMOUNT, "Bad Deposit");
      uint DepositFee = _amount.mul(depositFee).div(PERCENTS_DIVIDER);
    uint LpFee = _amount.mul(lPFee).div(PERCENTS_DIVIDER);
     Alexa.transferFrom(msg.sender, address(this), _amount);

        if(_plan == Plan1  ){

            totalStakedOfPlan1 = totalStakedOfPlan1 + _amount;
            stakingBalancePlan1[msg.sender] = stakingBalancePlan1[msg.sender] + _amount;
            stakingStartTime1[msg.sender]= block.timestamp;

        }
        if(_plan == Plan2  ){

            totalStakedOfPlan2 = totalStakedOfPlan2 + _amount;
            stakingBalancePlan2[msg.sender] = stakingBalancePlan2[msg.sender] + _amount;
             stakingStartTime2[msg.sender]= block.timestamp;

        }
        if(_plan == Plan3  ){

            totalStakedOfPlan3 = totalStakedOfPlan3 + _amount;
             stakingBalancePlan3[msg.sender] = stakingBalancePlan3[msg.sender] + _amount;
              stakingStartTime3[msg.sender]= block.timestamp;

        }

         if(_plan == Plan4  ){

            totalStakedOfPlan4 = totalStakedOfPlan4 + _amount;
             stakingBalancePlan4[msg.sender] = stakingBalancePlan4[msg.sender] + _amount;
              stakingStartTime4[msg.sender]= block.timestamp;

        }

         if(_plan == Plan5  ){

            totalStakedOfPlan5 = totalStakedOfPlan5 + _amount;
             stakingBalancePlan5[msg.sender] = stakingBalancePlan5[msg.sender] + _amount;
              stakingStartTime5[msg.sender]= block.timestamp;

        }

          if(_plan == Plan6  ){

            totalStakedOfPlan6 = totalStakedOfPlan6 + _amount;
             stakingBalancePlan6[msg.sender] = stakingBalancePlan6[msg.sender] + _amount;
              stakingStartTime6[msg.sender]= block.timestamp;

        }

        //checking if user staked before or not, if NOT staked adding to array of stakers
        if (!hasStaked[msg.sender]) {
        totalStakers++ ;
        }

        


         Alexa.transfer(owner,DepositFee );
        Alexa.transfer(lPAdress, LpFee );

         User storage user = users[msg.sender][_plan];


           if (user.referrer == address(0) && referrer != msg.sender) {
            user.referrer = referrer;
        }
        
        if (user.referrer != address(0)) {

            address upline = user.referrer;
            for (uint i = 0; i < 3; i++) {
                if (upline != address(0)) {
                    uint amount = _amount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);

                   

                    if (amount > 0) {
                        Alexa.transfer(upline,amount );
                        users[upline][_plan].bonus = uint64(uint(users[upline][_plan].bonus).add(amount));
                        
                        totalRefBonus = totalRefBonus.add(amount);
                        emit RefBonus(upline, msg.sender, i, amount);
                    }

                    users[upline][_plan].refs[i]++;
                    upline = users[upline][_plan].referrer;
                } else break;
            }

        }

        if (user.deposits.length == 0) {
            user.checkpoint = uint32(block.timestamp);
            emit Newbie(msg.sender);
        }

        user.deposits.push(Deposit(uint64(_amount), 0, uint32(block.timestamp)));

        totalInvested = totalInvested.add(_amount);
        totalDeposits =  totalDeposits + _amount ;
        hasStaked[msg.sender] = true;
        emit NewDeposit(msg.sender, _amount);
 }






  function unstakeTokens(uint256 _plan) public {
       User storage user = users[msg.sender][_plan];

        if(_plan == Plan1  ){

    require(stakingStartTime1[msg.sender] + 45 days < block.timestamp , "plase try after staking  Time period hours");
    uint256 _amount = stakingBalancePlan1[msg.sender];
        Alexa.transfer(msg.sender, _amount);

        totalStakedOfPlan1 = totalStakedOfPlan1 - _amount;
        stakingBalancePlan1[msg.sender] = stakingBalancePlan1[msg.sender] - _amount;
        stakingStartTime1[msg.sender]= 0;
        user.deposits =  empty ;

        }
        if(_plan == Plan2  ){

            require(stakingStartTime2[msg.sender] + 90 days < block.timestamp , "plase try after staking  Time period hours");
            uint256 _amount = stakingBalancePlan2[msg.sender];
            Alexa.transfer(msg.sender, _amount);
             totalStakedOfPlan2 = totalStakedOfPlan2 - _amount;
            stakingBalancePlan2[msg.sender] =  stakingBalancePlan2[msg.sender] - _amount;
            stakingStartTime2[msg.sender]= 0;
            user.deposits =  empty ;
        }
        if(_plan == Plan3  ){

            require(stakingStartTime3[msg.sender] + 180 days < block.timestamp , "plase try after staking  Time period hours");
            uint256 _amount = stakingBalancePlan3[msg.sender];
            Alexa.transfer(msg.sender, _amount);
             totalStakedOfPlan3 = totalStakedOfPlan3 - _amount;
            stakingBalancePlan3[msg.sender] =  stakingBalancePlan3[msg.sender] - _amount;
            stakingStartTime3[msg.sender]= 0;
            user.deposits =  empty ;

        }

          if(_plan == Plan4  ){

            require(stakingStartTime4[msg.sender] + 365 days < block.timestamp , "plase try after staking  Time period hours");
            uint256 _amount = stakingBalancePlan4[msg.sender];
            Alexa.transfer(msg.sender, _amount);
             totalStakedOfPlan4 = totalStakedOfPlan4 - _amount;
            stakingBalancePlan4[msg.sender] =  stakingBalancePlan4[msg.sender] - _amount;
            stakingStartTime4[msg.sender]= 0;
            user.deposits =  empty ;

        }

          if(_plan == Plan5 ){

            require(stakingStartTime5[msg.sender] + 500 days < block.timestamp , "plase try after staking  Time period hours");
            uint256 _amount = stakingBalancePlan5[msg.sender];
            Alexa.transfer(msg.sender, _amount);
             totalStakedOfPlan5 = totalStakedOfPlan5 - _amount;
            stakingBalancePlan5[msg.sender] =  stakingBalancePlan5[msg.sender] - _amount;
            stakingStartTime5[msg.sender]= 0;
            user.deposits =  empty ;

        }

          if(_plan == Plan6 ){

            require(stakingStartTime6[msg.sender] + 730 days < block.timestamp , "plase try after staking  Time period hours");
            uint256 _amount = stakingBalancePlan6[msg.sender];
            Alexa.transfer(msg.sender, _amount);
             totalStakedOfPlan6 = totalStakedOfPlan6 - _amount;
            stakingBalancePlan6[msg.sender] =  stakingBalancePlan6[msg.sender] - _amount;
            stakingStartTime6[msg.sender]= 0;
            user.deposits =  empty ;

        }

    }




function unstakeTokensbeforetime(uint256 _plan) public {
    User storage user = users[msg.sender][_plan];
      
      
        if(_plan == Plan2  ){

             
            uint256 _amount = stakingBalancePlan2[msg.sender];
            uint256 taxonunstake = _amount.mul(taxUnstake).div(PERCENTS_DIVIDER);
            uint256 sendtouser = _amount.sub(taxonunstake);

           Alexa.transfer(owner, taxonunstake );
          Alexa.transfer(msg.sender, sendtouser);
             totalStakedOfPlan2 = totalStakedOfPlan2 - _amount;
            stakingBalancePlan2[msg.sender] =  stakingBalancePlan2[msg.sender] - _amount;
            stakingStartTime2[msg.sender]= 0;
            user.deposits =  empty ;
        }
        if(_plan == Plan3  ){
             
            
            uint256 _amount = stakingBalancePlan3[msg.sender];
              uint256 taxonunstake = _amount.mul(taxUnstake).div(PERCENTS_DIVIDER);
              uint256 sendtouser = _amount.sub(taxonunstake);
  
             Alexa.transfer(owner, taxonunstake );
            Alexa.transfer(msg.sender, sendtouser);
             totalStakedOfPlan3 = totalStakedOfPlan3 - _amount;
            stakingBalancePlan3[msg.sender] =  stakingBalancePlan3[msg.sender] - _amount;
            stakingStartTime3[msg.sender]= 0;
            user.deposits =  empty ;

        }

        if(_plan == Plan1){
          

          uint256 _amount = stakingBalancePlan1[msg.sender];
          uint256 taxonunstake = _amount.mul(taxUnstake).div(PERCENTS_DIVIDER);
           uint256 sendtouser = _amount.sub(taxonunstake);

           Alexa.transfer(owner, taxonunstake );
           Alexa.transfer(msg.sender, sendtouser);
             totalStakedOfPlan1 = totalStakedOfPlan1 - _amount;
            stakingBalancePlan1[msg.sender] =  stakingBalancePlan1[msg.sender] - _amount;
            stakingStartTime1[msg.sender]= 0;
         
        user.deposits =  empty ;
          

        }

          if(_plan == Plan4  ){

               
            uint256 _amount = stakingBalancePlan4[msg.sender];
               uint256 taxonunstake = _amount.mul(taxUnstake).div(PERCENTS_DIVIDER);
             uint256 sendtouser = _amount.sub(taxonunstake);

             Alexa.transfer(owner, taxonunstake );
             Alexa.transfer(msg.sender, sendtouser);
             totalStakedOfPlan4 = totalStakedOfPlan4 - _amount;
            stakingBalancePlan4[msg.sender] =  stakingBalancePlan4[msg.sender] - _amount;
            stakingStartTime4[msg.sender]= 0;
            user.deposits =  empty ;

        }

          if(_plan == Plan5 ){

            
            uint256 _amount = stakingBalancePlan5[msg.sender];
         uint256 taxonunstake = _amount.mul(taxUnstake).div(PERCENTS_DIVIDER);
          uint256 sendtouser = _amount.sub(taxonunstake);

            Alexa.transfer(owner, taxonunstake );
           Alexa.transfer(msg.sender, sendtouser);
             totalStakedOfPlan5 = totalStakedOfPlan5 - _amount;
            stakingBalancePlan5[msg.sender] =  stakingBalancePlan5[msg.sender] - _amount;
            stakingStartTime5[msg.sender]= 0;
            user.deposits =  empty ;

        }

          if(_plan == Plan6 ){

            
            uint256 _amount = stakingBalancePlan6[msg.sender];
            uint256 taxonunstake = _amount.mul(taxUnstake).div(PERCENTS_DIVIDER);
           uint256 sendtouser = _amount.sub(taxonunstake);

           Alexa.transfer(owner, taxonunstake );
           Alexa.transfer(msg.sender, sendtouser);
             totalStakedOfPlan6 = totalStakedOfPlan6 - _amount;
            stakingBalancePlan6[msg.sender] =  stakingBalancePlan6[msg.sender] - _amount;
            stakingStartTime6[msg.sender]= 0;
            user.deposits =  empty ;

        }

    }





 function withdraw(uint256 _plan) public {
        User storage user = users[msg.sender][_plan];

     
        uint dividends;
          uint totalDividends;
        uint256 calApy;
        uint256 consec = 365 ;
      if(_plan == Plan1 ){
       calApy = Plan1APY / consec;
      }
       if(_plan == Plan2 ){
         calApy = Plan2APY / consec;
      }
       if(_plan == Plan3 ){
         calApy = Plan3APY / consec;
      }
       if(_plan == Plan4 ){
         calApy = Plan4APY / consec;
      }
       if(_plan == Plan5 ){
        calApy = Plan5APY / consec;
      }
       if(_plan == Plan6 ){
        calApy = Plan6APY / consec;
      }

    


    for (uint i = 0; i <  user.deposits.length; i++) {
           

            if (uint(user.deposits[i].withdrawn) < uint(user.deposits[i].amount).mul(2)) {
                

                if (user.deposits[i].start > user.checkpoint) {
                    

                    dividends = (uint(user.deposits[i].amount).mul(calApy).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint(user.deposits[i].start)))
                        .div(TIME_STEP);

                } else {
                            
                    dividends = (uint(user.deposits[i].amount).mul(calApy).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint(user.checkpoint)))
                        .div(TIME_STEP);

                }

                if (uint(user.deposits[i].withdrawn).add(dividends) > uint(user.deposits[i].amount).mul(2)) {
                    
                    dividends = (uint(user.deposits[i].amount).mul(2)).sub(uint(user.deposits[i].withdrawn));
                }

                totalDividends = totalDividends.add(dividends);
                user.deposits[i].withdrawn = uint64(uint(user.deposits[i].withdrawn).add(dividends)); /// changing of storage data

                

            }

        }

       

        user.checkpoint = uint32(block.timestamp);

         Alexa.transfer(msg.sender, totalDividends);

        totalWithdrawn = totalWithdrawn.add(totalDividends);


        emit Withdrawn(msg.sender, totalDividends);
    }





 function getUserAvailable( uint256 _plan , address sender) public view returns (uint) {
    
     User storage user = users[sender][_plan];
        uint dividends;
        uint totalDividends;
        uint calApy;
        uint256 consec = 365 ;
      if(_plan == Plan1 ){
       calApy = Plan1APY / consec;
      
      }
       if(_plan == Plan2 ){
         calApy = Plan2APY / consec;
        
      }
       if(_plan == Plan3 ){
         calApy = Plan3APY / consec;
      }
       if(_plan == Plan4 ){
         calApy = Plan4APY / consec;
      }
       if(_plan == Plan5 ){
        calApy = Plan5APY / consec;
      }
       if(_plan == Plan6 ){
        calApy = Plan6APY / consec;
      }

      

        for (uint i = 0; i <  user.deposits.length; i++) {
           

            if (uint(user.deposits[i].withdrawn) < uint(user.deposits[i].amount).mul(2)) {
                

                if (user.deposits[i].start > user.checkpoint) {
                    

                    dividends = (uint(user.deposits[i].amount).mul(calApy).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint(user.deposits[i].start)))
                        .div(TIME_STEP);

                } else {
                            
                    dividends = (uint(user.deposits[i].amount).mul(calApy).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint(user.checkpoint)))
                        .div(TIME_STEP);

                }

                if (uint(user.deposits[i].withdrawn).add(dividends) > uint(user.deposits[i].amount).mul(2)) {
                    
                    dividends = (uint(user.deposits[i].amount).mul(2)).sub(uint(user.deposits[i].withdrawn));
                }

                totalDividends = totalDividends.add(dividends);

                

            }

        }
         
        return totalDividends;
    }



    function setPlans( uint256 _plan1 , uint256 _plan2 , uint256 _plan3 , uint256 _plan4 , uint256 _plan5  , uint256 _plan6) public {
         require(msg.sender == owner , "only Owner can run this function");
        Plan1 = _plan1;
        Plan2 = _plan2 ;
        Plan3 =  _plan3;
        Plan4 =  _plan4;
        Plan5 =  _plan5;
        Plan6 =  _plan6;

 
    }

      function setPlansApy( uint256 _APY1 , uint256 _APY2 , uint256 _APY3 ,  uint256 _APY4 ,  uint256 _APY5 , uint256 _APY6) public {
           require(msg.sender == owner , "only Owner can run this function");
        Plan1APY = _APY1;
        Plan2APY = _APY2;
        Plan3APY =  _APY3;
         Plan4APY =  _APY4;
          Plan5APY =  _APY5;
           Plan5APY =  _APY6;

 
    }

    function transferOwnership(address newOwner) public   {
        require(msg.sender == owner , "only Owner can run this function");
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
    
    

     

    }