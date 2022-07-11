/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;



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

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract Popcorn_Lottery_V1 is ReentrancyGuard{
    
    uint256 private maxParticipantNumbers;
    uint256 private participantNumbers;
    uint256 private ticketPrice;
    address payable[] participants;
    address private owner;
    
    address private popcornBusd = 0x2946d0DBC8D7eD53938706549F003Df243235BeA;
    address private dev = 0x668c0ee84E8CC6d512c04C112b0D74c0a284f8Df;
    
uint256 private maxParticipantNumbers1;
    uint256 private participantNumbers1;
    uint256 private ticketPrice1;
    address payable[] participants1;

    uint256 private maxParticipantNumbers2;
    uint256 private participantNumbers2;
    uint256 private ticketPrice2;
    address payable[] participants2;
    bool public initization = false;
    address[] public winnerLottery;
    address[] public winnerLottery1;
    address[] public winnerLottery2;
    address public tokenAdress;
    IERC20 public BusdInterface;



    constructor()  {  
        owner =  msg.sender;
        maxParticipantNumbers = 5;
        ticketPrice = 10 ether ;

         maxParticipantNumbers1 = 5;
        ticketPrice1 = 50 ether;

         maxParticipantNumbers2 = 5;
        ticketPrice2 = 100 ether;

        tokenAdress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; 
        BusdInterface = IERC20(tokenAdress);
    }


event logshh(uint256 _id, uint256 _value);



    function lotteryBalance() public view returns(uint256) {
        return BusdInterface.balanceOf(address(this));
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Access denied!");
        _;
    }
    
    modifier notOwner(){
        require(msg.sender != owner, "Access denied");
        _;
    }
    
    function setTicketPrice(uint256 _valueInEther) public onlyOwner{
        ticketPrice = _valueInEther;
    }

    function setTicketPrice1(uint256 _valueInEther) public onlyOwner{
        ticketPrice1 = _valueInEther;
    }

    function setTicketPrice2(uint256 _valueInEther) public onlyOwner{
        ticketPrice2 = _valueInEther;
    }
    
    function setMaximmNumbers(uint256 _maxNumbers) public onlyOwner{
        maxParticipantNumbers = _maxNumbers;
    }
function setMaximmNumbers1(uint256 _maxNumbers) public onlyOwner{
        maxParticipantNumbers1 = _maxNumbers;
    }
    function setMaximmNumbers2(uint256 _maxNumbers) public onlyOwner{
        maxParticipantNumbers2 = _maxNumbers;
    }

    function viewTicketPrice() external view returns(uint256){
        return ticketPrice;
    }
    function viewTicketPrice1() external view returns(uint256){
        return ticketPrice1;
    }
    function viewTicketPrice2() external view returns(uint256){
        return ticketPrice2;
    }
    function viewTicket() external view returns(uint256){
        return maxParticipantNumbers;
    }
    function viewTicket1() external view returns(uint256){
        return maxParticipantNumbers1;
    }
    function viewTicket2() external view returns(uint256){
        return maxParticipantNumbers2;
    }

    function startLottery() public onlyOwner(){
        initization = true;
    }
   function announceLottery() public onlyOwner(){
       pickwinner();
    } function announceLottery1() public onlyOwner(){
        pickwinner1();
    } function announceLottery2() public onlyOwner(){
       pickwinner2();
    }
    
    function joinLottery(uint256 _amount) external notOwner() noReentrant{
       
        require(initization , "Lottery is not started yet");


        require(_amount== ticketPrice,"Not Same" );
        //BusdInterface.transferFrom(msg.sender,address(this),_amount);
          bool chk= BusdInterface.transferFrom(msg.sender,address(this),_amount);
       if(chk){
        if (participantNumbers < maxParticipantNumbers){
           
            participants.push(payable(msg.sender));
            participantNumbers++;
            if (participantNumbers == maxParticipantNumbers){
           //payable( msg.sender).transfer(msg.value);
            pickwinner();
       }

        }
        else if (participantNumbers == maxParticipantNumbers){
          // payable( msg.sender).transfer(_amount);
            pickwinner();
        }}
    }
     function joinLottery1(uint256 _amount) external notOwner() noReentrant{
       
        require(initization , "Lottery is not started yet");
        
        emit logshh(_amount,ticketPrice1);
        require(_amount == ticketPrice1,"Not Same" );

       bool chk= BusdInterface.transferFrom(msg.sender,address(this),_amount);
       if(chk){
        if (participantNumbers1 < maxParticipantNumbers1){
           
            participants1.push(payable(msg.sender));
            participantNumbers1++;
            if (participantNumbers1 == maxParticipantNumbers1){
         //  payable( msg.sender).transfer(_amount);
            pickwinner1();
        }

        }
        else if (participantNumbers1 == maxParticipantNumbers1){
          // payable( msg.sender).transfer(_amount);
            pickwinner1();
        }}
    }
    
    function joinLottery2(uint256 _amount)  external notOwner() noReentrant{
        
        require(initization , "Lottery is not started yet");


        require(_amount == ticketPrice2,"Not Same" );
       //  BusdInterface.transferFrom(msg.sender,address(this),_amount);
         bool chk= BusdInterface.transferFrom(msg.sender,address(this),_amount);
       if(chk){
        if (participantNumbers2 < maxParticipantNumbers2){
           
            participants2.push(payable(msg.sender));
            participantNumbers2++;
            if (participantNumbers2 == maxParticipantNumbers2){
          // payable( msg.sender).transfer(msg.value);
            pickwinner2();
        }

        }
        else if (participantNumbers2 == maxParticipantNumbers2){
           //payable( msg.sender).transfer(_amount);
            pickwinner2();
        }}
    }
    
    function random() private view returns(uint256){
        return uint256(keccak256(abi.encode(block.difficulty, block.timestamp, participants, block.number)));
    }
    function getLotteryLength() public view returns(uint256){
        return participants.length;
    }
     function getLottery1Length() public view returns(uint256){
        return participants1.length;
    }
     function getLottery2Length() public view returns(uint256){
        return participants2.length;
    }
    function howMany(address ad) public view returns(uint256,uint256,uint256){
        uint256 lHm=0;
        uint256 lHm1=0;
        uint256 lHm2=0;
uint arrayLength = participants.length;
if(arrayLength!=0){
for (uint i=0; i<arrayLength; i++) {
  // do something
  if (participants[i]==ad){
      lHm++;
  }
}}
uint arrayLength1 = participants1.length;
if(arrayLength1!=0){
for (uint i=0; i<arrayLength1; i++) {
  // do something
  if (participants1[i]==ad){
      lHm1++;
  }}
}uint arrayLength2 = participants2.length;
if(arrayLength2!=0){
for (uint i=0; i<arrayLength2; i++) {
  // do something
  if (participants[i]==ad){
      lHm2++;
  }}
}
        
        
        return (lHm,lHm1,lHm2);
    }

    
    function pickwinner() internal {
        uint win = random() % participants.length;
        uint256 totalUsers = participants.length ;
        uint256 contractBalance = ticketPrice * totalUsers;
       
        uint256 popcornBusdFee = SafeMath.div(SafeMath.mul(contractBalance,25),100);
        uint256 devFee = SafeMath.div(SafeMath.mul(contractBalance,5),100);
      
        BusdInterface.transfer(popcornBusd,popcornBusdFee);
        uint256 winnerAmount = SafeMath.sub(contractBalance,popcornBusdFee);
        winnerAmount -= devFee;
  
       BusdInterface.transfer(dev,devFee);
        BusdInterface.transfer(participants[win],winnerAmount);
        winnerLottery.push(participants[win]);
        delete participants;
        participantNumbers = 0;
    }

    function pickwinner1() internal {
        uint win = random() % participants1.length;
        uint256 contractBalance = ticketPrice1 * participants1.length;
       
        uint256 popcornBusdFee = SafeMath.div(SafeMath.mul(contractBalance,25),100);
         uint256 devFee = SafeMath.div(SafeMath.mul(contractBalance,5),100);
      
       BusdInterface.transfer(popcornBusd,popcornBusdFee);
        uint256 winnerAmount = SafeMath.sub(contractBalance,popcornBusdFee);
       
         winnerAmount -= devFee;
          BusdInterface.transfer(dev,devFee);
     
     BusdInterface.transfer(participants1[win],winnerAmount);
       winnerLottery1.push(participants1[win]);
        delete participants1;
        participantNumbers1 = 0;
    }
    function pickwinner2() internal {
        uint win = random() % participants2.length;
        uint256 contractBalance = ticketPrice2 * participants2.length;
       
        uint256 popcornBusdFee = SafeMath.div(SafeMath.mul(contractBalance,25),100);
     
         uint256 devFee = SafeMath.div(SafeMath.mul(contractBalance,5),100);
     
      BusdInterface.transfer(popcornBusd,popcornBusdFee);
        uint256 winnerAmount = SafeMath.sub(contractBalance,popcornBusdFee);
       
         winnerAmount -= devFee;
          BusdInterface.transfer(dev,devFee);
    
      BusdInterface.transfer(participants2[win],winnerAmount);
       winnerLottery2.push(participants2[win]);
        delete participants2;
        participantNumbers2 = 0;
    }
     function allWinner2() public view returns(address[] memory){
        address[] memory result= new address[](17);
uint256 arrayLength = winnerLottery2.length;
uint256 resultLength = result.length;
uint256 index =0;

if(arrayLength>10){
        for (uint256 i=arrayLength; i>(arrayLength-10); i--) {
            resultLength++;
  result[resultLength]=winnerLottery2[i];
}
        
  }
  else{
       for (uint256 i=arrayLength; i>0; i--) {
  resultLength++;
  
  address payable _address = payable(winnerLottery2[i-1]);
  
  result[index]=_address;
  index++;
  
}
  }
  return result;
}
   function allWinner1() public view returns(address[] memory){
        address[] memory result= new address[](17);
uint256 arrayLength = winnerLottery1.length;
uint256 resultLength = result.length;
uint256 index =0;

if(arrayLength>10){
        for (uint256 i=arrayLength; i>(arrayLength-10); i--) {
            resultLength++;
  result[resultLength]=winnerLottery1[i];
}
        
  }
  else{
       for (uint256 i=arrayLength; i>0; i--) {
  resultLength++;
  
  address payable _address = payable(winnerLottery1[i-1]);
  
  result[index]=_address;
  index++;
}
  }
  return result;
}
    function allWinner() public view returns(address[] memory){
        address[] memory result= new address[](17);
uint256 arrayLength = winnerLottery.length;
uint256 resultLength = result.length;
uint256 index =0;
if(arrayLength>10){
        for (uint256 i=arrayLength; i>(arrayLength-10); i--) {
            resultLength++;
  result[resultLength]=winnerLottery[i];
}
        
  }
  else{
       for (uint256 i=arrayLength; i>0; i--) {
  resultLength++;
  address payable _address = payable(winnerLottery[i-1]);
 
  result[index]=_address;
  index++;
  
}
  }
  return result;
}
}