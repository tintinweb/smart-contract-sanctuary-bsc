// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Sta{
IERC20 public BSI;

uint _price;
struct depo{
    uint amt;
    uint timed;
}


mapping(address=>depo[]) public deposit;
// mapping(address=>uint) public timed;
// uint public times;


struct boost{
    uint boosterTime;
    uint boosterPct;
    uint boosterAmt;
}
// uint public Reward;
mapping(address=>boost[]) public booster;

// uint public ct;
// uint dt;
uint public _pct;
// uint public dailyearn;
mapping(address=>uint) public rewards;

 
 
constructor(uint pct,uint price){
        BSI=IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
        // ct=block.timestamp;
        // dt=block.timestamp;
        _pct=pct;
        _price=price;

}

function Deposit(uint _amountStacked) public{
    require(_amountStacked>=2000000000000000,"more amount needs to be deposited" );//min amt =0.002 busd
    BSI.transferFrom(msg.sender,address(this),_amountStacked);
    BSI.transfer(0xdD39931469Aa21E3C646ab2DF378407e6c56ebdc,(_amountStacked*5)/100);//MM token transfer
    BSI.transfer(0x5ae98e5F7FFC2cD9443cE30ef515cE3AA2d0A0ef,(_amountStacked*6)/100);//treasurer token transfer
    BSI.transfer(0x872fb27DEDfD2670c690740E999a48738f83C7c7,(_amountStacked*4)/100);//dev token transfer
    deposit[msg.sender].push(depo({amt:_amountStacked,timed:block.timestamp}));
}
function Booster(uint _amountBooster) public {
    
    

    require(_price>=300000000000000 && _price<=500000000000000);//price range .0005 to .0003
    require(deposit[msg.sender].length!=0);
    

    // booster[msg.sender][boosterTime].boosterAmt=_amountBooster;//can be commented out
    for(uint i=0;i<deposit[msg.sender].length;i++){
   
        if(deposit[msg.sender][i].amt>=2000000000000000 && deposit[msg.sender][i].amt<4000000000000000){
                booster[msg.sender].push(boost({boosterTime:block.timestamp,boosterPct:(_amountBooster*25)/100,boosterAmt:_amountBooster}));

            }
            else if (deposit[msg.sender][i].amt>=4000000000000000 && deposit[msg.sender][i].amt<8000000000000000){
                booster[msg.sender].push(boost({boosterTime:block.timestamp,boosterPct:(_amountBooster*25)/200,boosterAmt:_amountBooster}));

            }
            else if(deposit[msg.sender][i].amt>=8000000000000000 && deposit[msg.sender][i].amt<12000000000000000){
                booster[msg.sender].push(boost({boosterTime:block.timestamp,boosterPct:(_amountBooster*25)/300,boosterAmt:_amountBooster}));

            }
            else if(deposit[msg.sender][i].amt>=12000000000000000 && deposit[msg.sender][i].amt<16000000000000000){
                booster[msg.sender].push(boost({boosterTime:block.timestamp,boosterPct:(_amountBooster*25)/400,boosterAmt:_amountBooster}));

            }
            else if(deposit[msg.sender][i].amt>=1600000000000000) {
                booster[msg.sender].push(boost({boosterTime:block.timestamp,boosterPct:(_amountBooster*25)/500,boosterAmt:_amountBooster}));
            }

        BSI.transferFrom(msg.sender,address(this),_price*_amountBooster);
    }
}

function DailyEarning(address _address) public view returns(uint dailyearn){

   
    require(_pct>=5 && _pct<=10,"amount decided should be between .5 and 1");
    require(deposit[_address].length!=0,"deposit something please");

    for(uint i=0;i<deposit[_address].length;i++){
        if(booster[_address].length!=0){
            for(uint j;j<booster[_address].length;j++){
                dailyearn+=(deposit[_address][i].amt* _pct * (block.timestamp-deposit[_address][i].timed))/10000+(deposit[_address][i].amt* booster[_address][i].boosterPct * (block.timestamp-booster[_address][i].boosterTime))/10000;
            }
            
        }
         
        
        else{
            dailyearn+=(deposit[_address][i].amt* _pct * (block.timestamp-deposit[_address][i].timed))/10000;
            

        }
         


        }
        return dailyearn;
    }
    


   
    
    



function RewardWith() public{
    require(deposit[msg.sender].length!=0);
    for(uint i=0;i<deposit[msg.sender].length;i++){
        require(block.timestamp>=deposit[msg.sender][i].timed+70,"call function after 70 sec");
        rewards[msg.sender]= DailyEarning(msg.sender);
        BSI.transfer(msg.sender,rewards[msg.sender]);
        BSI.transfer(0x5ae98e5F7FFC2cD9443cE30ef515cE3AA2d0A0ef,(rewards[msg.sender]*15)/100);
        BSI.transfer(0x872fb27DEDfD2670c690740E999a48738f83C7c7,(rewards[msg.sender]*5)/100);
        rewards[msg.sender]=0;
        deposit[msg.sender][i].timed=block.timestamp;
    }
}




function compound() public {
    require(deposit[msg.sender].length!=0);
    for(uint i=0;i<deposit[msg.sender].length;i++){
    require(block.timestamp>=deposit[msg.sender][i].timed+70,"call function after 70 sec");
    rewards[msg.sender]=DailyEarning(msg.sender);
    deposit[msg.sender][i].amt+=rewards[msg.sender];
    BSI.transfer(0x5ae98e5F7FFC2cD9443cE30ef515cE3AA2d0A0ef,(rewards[msg.sender]*10)/100);//treasurer token transfer
    deposit[msg.sender][i].timed=block.timestamp;
}
    
}
function unstake() public {
    require(deposit[msg.sender].length!=0);
    for(uint i=0;i<deposit[msg.sender].length;i++){
    require(block.timestamp>=deposit[msg.sender][i].timed+70,"call function after 70 sec");
    deposit[msg.sender][i].timed=block.timestamp;
    BSI.transfer(msg.sender,(deposit[msg.sender][i].amt*20)/100);
    deposit[msg.sender][i].amt-=(deposit[msg.sender][i].amt*20)/100;
    rewards[msg.sender]=0;
    }
}



}
//0x70D5Cd168585041709d70715AdB2eDE7CA9b9EC1