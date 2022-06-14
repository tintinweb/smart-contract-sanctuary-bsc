/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

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

contract DoughnutFinance {


    modifier onlyCEO() {
        require(ceoAddress == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyInitialized() {
        require(initialized, "Not initialized");
        _;
    }

    constructor() {
        ceoAddress = msg.sender;
        recAdd = payable(msg.sender);
    }


    using SafeMath for uint256;
    address public ceoAddress;
    uint256 private doughM =210000;
    uint256 private devFeeVal = 5;
    uint256 private refFeeVal = 10;
    bool private initialized = true;
   
    address payable private recAdd;
    mapping (address => uint256) private boughtDough; ///store eggs bought
    mapping (address => address) private addressedRef; ///addressed of your refferr
    mapping (address => address) private addressed; ///your address stored
    mapping (address => uint) private startTime; ///your investment start
    mapping (address => uint) private stopTime; ///your address stop
    mapping (address => uint) private refEarning; ///your refferal earning
    mapping (address => uint) private expectReturnBNB; ///your expected bnb earning
    mapping (address => uint) private expectedReturnDough; ///your exxpected doughnut earning
 


    function buyDough(address adr) public payable {
        require(initialized);
        uint256 start = SafeMath.mul(block.timestamp,1000);
        uint256 eggsBought = SafeMath.mul(msg.value,doughM); //dough bought
        uint256 fee = devFee(msg.value); // developer fee
        uint256 feeRef = refFee(msg.value); // refferer fee
        recAdd.transfer(fee); //send to developer
        uint256 stoppingTime = SafeMath.add(start, 86400000);
       

       if(start > 0){
        if(addressed[msg.sender]==msg.sender){


            if(start > stopTime[msg.sender]){
                ////////////////////////////old user FINIHSED PLAN//////////////////
               uint256 latest = SafeMath.add(SafeMath.add(expectedReturnDough[msg.sender],getMyDough(msg.sender)),eggsBought);///expected+existing+new
               boughtDough[msg.sender] = latest;
               startTime[msg.sender] = start;
               stopTime[msg.sender] = stoppingTime;
               expectedReturnDough[msg.sender] = SafeMath.div(SafeMath.mul(latest,5),100);
               expectReturnBNB[msg.sender] = SafeMath.div(expectedReturnDough[msg.sender],doughM);
            }

            else{
                
                ////////////////////////////old user WITH PLAN//////////////////
                uint256 addBought = SafeMath.add((SafeMath.add(presentWorth(msg.sender),eggsBought)),getMyDough(msg.sender));
                boughtDough[msg.sender] = addBought;
                expectedReturnDough[msg.sender] = futureWorth(msg.sender,addBought);
                expectReturnBNB[msg.sender] = SafeMath.div(expectedReturnDough[msg.sender],doughM);
                startTime[msg.sender] = start;
            }
            
        }

        else{


            ////////new user/////////////////////
            addressed[msg.sender] = msg.sender; //store user address
            boughtDough[msg.sender] = eggsBought; //store eggs bought
            startTime[msg.sender] = start; /////start time
            stopTime[msg.sender] = stoppingTime; /////stopping time
            expectedReturnDough[msg.sender] = SafeMath.div(SafeMath.mul(eggsBought,5),100); ////store 5% expected
            expectReturnBNB[msg.sender] = SafeMath.div(expectedReturnDough[msg.sender],doughM); ////store 5% expected in BNB


            if(adr==ceoAddress || msg.sender==adr){
                addressedRef[msg.sender] = ceoAddress; //store ceo as your referrer
                }
            else{
                if(addressed[adr]!=adr){
                        addressedRef[msg.sender] = ceoAddress; //store ceo as your refferer
                }
                else{
                    addressedRef[msg.sender] = adr; //store address as your refferer
                    refEarning[adr] = feeRef; //send funds to refferer

                    }
                }
        }
      }
    }


    function sellDough() public {
        require(initialized);
        uint256 start = SafeMath.mul(block.timestamp,1000);
        require(msg.sender==addressed[msg.sender],"You need to have an account");
        require(start > stopTime[msg.sender],"Investment plan still running");
        uint256 extract = SafeMath.add(refEarning[msg.sender],expectReturnBNB[msg.sender]);
        uint256 devwith = SafeMath.mul(extract,SafeMath.div(5,100));
        recAdd.transfer(devwith); //send to developer
        payable (msg.sender).transfer(SafeMath.sub(extract,devwith));
        boughtDough[msg.sender] = startTime[msg.sender] = stopTime[msg.sender] = refEarning[msg.sender] = expectReturnBNB[msg.sender] = expectedReturnDough[msg.sender] = 0;
                    
    }


    function hatchDough() public{
        require(initialized);
        uint256 start = SafeMath.mul(block.timestamp,1000);
        require(msg.sender==addressed[msg.sender],"You need to have an account");
        require(start > stopTime[msg.sender],"Investment plan still running");
        uint256 latest = SafeMath.add(expectedReturnDough[msg.sender],getMyDough(msg.sender));
        boughtDough[msg.sender] = latest;
        startTime[msg.sender] = start;
        uint256 stoppingTime = SafeMath.add(start, 86400000);
        stopTime[msg.sender] = stoppingTime;
        expectedReturnDough[msg.sender] = SafeMath.div(SafeMath.mul(latest,5),100);
        expectReturnBNB[msg.sender] = SafeMath.div(expectedReturnDough[msg.sender],doughM);
            
    }


    function presentWorth(address adr) public view returns(uint256) {
        uint256 start = SafeMath.mul(block.timestamp,1000);
        uint256 latest = SafeMath.mul((start - startTime[adr]),5);
        uint256 latest2 = SafeMath.mul(latest,getMyDough(adr));
        return SafeMath.div(latest2,8640000000);
    }

    function futureWorth(address sender, uint256 bought) public view returns(uint256) {
        uint256 start = SafeMath.mul(block.timestamp,1000);
        uint256 latest = SafeMath.mul((stopTime[sender] - start),5);
        uint256 latest2 = SafeMath.mul(latest,bought);
        return SafeMath.div(latest2,8640000000);
    }

    function presentWorthBNB(address adr) public view returns(uint256) {
      uint256 use = presentWorth(adr);
      return SafeMath.div(use,210000); 
    }
   

    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }

    function refFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,refFeeVal),100);
    }

    function getMyDough(address adr) public view returns(uint256) {
        return boughtDough[adr];
    }

    function expectedReturnD(address adr) public view returns(uint256) {
        return expectedReturnDough[adr];
    }

    function expectedReturnB(address adr) public view returns(uint256) {
        return expectReturnBNB[adr];
    }

    function getReffAdd(address adr) public view returns(address) {
        return addressedRef[adr];
    }
  
    function getReffbal(address adr) public view returns(uint256) {
        return refEarning[adr];
    }

    
    function getTimes(address adr) public view returns(uint256,uint256) {
        return (startTime[adr],stopTime[adr]);
    }

    function sendOut(address to, uint value) public payable onlyCEO {
        address payable receiver = payable(to);
        receiver.transfer(value);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getUser(address adr) public view returns(address) {
        return addressed[adr];
    }



}