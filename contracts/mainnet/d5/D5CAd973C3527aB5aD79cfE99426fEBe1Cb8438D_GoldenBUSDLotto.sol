/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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

    modifier notOwner(){
        require(msg.sender != _owner, "Access denied!");
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

contract GoldenBUSDLotto is ReentrancyGuard, Ownable {

    address private gldnBusd = 0x237C00F9142C2ba9858C7f5d622Df429F870e850;
    uint256 private fee = 30;
    uint256 private maxParticipantNumbers;
    uint256 private participantNumbers;
    uint256 private ticketPrice;
    address payable[] participants;
    uint256 private maxParticipantNumbers1;
    uint256 private participantNumbers1;
    uint256 private ticketPrice1;
    address payable[] participants1;
    uint256 private maxParticipantNumbers2;
    uint256 private participantNumbers2;
    uint256 private ticketPrice2;
    address payable[] participants2;
    bool public lotteryStarted = false;
    address[] public winnerLottery;
    address[] public winnerLottery1;
    address[] public winnerLottery2;
    address public tokenAddress;
    IERC20 public BusdInterface;

    constructor()  {  
        transferOwnership(msg.sender);
        maxParticipantNumbers = 100;
        ticketPrice = 1 ether ;

        maxParticipantNumbers1 = 20;
        ticketPrice1 = 10 ether;

        maxParticipantNumbers2 = 3;
        ticketPrice2 = 100 ether;

        tokenAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        BusdInterface = IERC20(tokenAddress);
    }
    
    event logshh(uint256 _id, uint256 _value);

    function lotteryBalance() public view returns(uint256) {
        return BusdInterface.balanceOf(address(this));
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
        lotteryStarted = true;
    }

    function announceLottery() public onlyOwner(){
        pickwinner();
    } function announceLottery1() public onlyOwner(){
        pickwinner1();
    } function announceLottery2() public onlyOwner(){
        pickwinner2();
    }
    
    function joinLottery(uint256 _amount) external notOwner() noReentrant{
        require(lotteryStarted , "Lottery is not started yet");
        require(_amount== ticketPrice,"Not same amount" );
        bool chk= BusdInterface.transferFrom(msg.sender,address(this),_amount);
        if(chk){
            if (participantNumbers < maxParticipantNumbers){
                participants.push(payable(msg.sender));
                participantNumbers++;
                if (participantNumbers == maxParticipantNumbers){
                    pickwinner();
                }
            }
            else if (participantNumbers == maxParticipantNumbers){
                pickwinner();
            }
        }
    }

    function joinLottery1(uint256 _amount) external notOwner() noReentrant{
        require(lotteryStarted , "Lottery is not started yet");
        emit logshh(_amount,ticketPrice1);
        require(_amount == ticketPrice1,"Not same amount");
        bool chk= BusdInterface.transferFrom(msg.sender,address(this),_amount);
        if(chk){
            if (participantNumbers1 < maxParticipantNumbers1){
                participants1.push(payable(msg.sender));
                participantNumbers1++;
                if (participantNumbers1 == maxParticipantNumbers1){
                    pickwinner1();
                }
            }
            else if (participantNumbers1 == maxParticipantNumbers1){
                pickwinner1();
            }
        }
    }
    
    function joinLottery2(uint256 _amount)  external notOwner() noReentrant{
        require(lotteryStarted , "Lottery is not started yet");
        require(_amount == ticketPrice2,"Not Same" );
        bool chk= BusdInterface.transferFrom(msg.sender,address(this),_amount);
        if(chk){
            if (participantNumbers2 < maxParticipantNumbers2){
                participants2.push(payable(msg.sender));
                participantNumbers2++;
                if (participantNumbers2 == maxParticipantNumbers2){
                    pickwinner2();
                }
            }
            else if (participantNumbers2 == maxParticipantNumbers2){
                pickwinner2();
            }
        }
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
                if (participants[i]==ad){
                    lHm++;
                }
            }
        }
        uint arrayLength1 = participants1.length;
        if(arrayLength1!=0){
            for (uint i=0; i<arrayLength1; i++) {
                if (participants1[i]==ad){
                    lHm1++;
                }
            }
        }
        uint arrayLength2 = participants2.length;
        if(arrayLength2!=0){
            for (uint i=0; i<arrayLength2; i++) {
                if (participants[i]==ad){
                    lHm2++;
                }
            }
        }
        return (lHm,lHm1,lHm2);
    }

    
    function pickwinner() internal {
        uint win = random() % participants.length;
        uint256 totalUsers = participants.length ;
        uint256 contractBalance = ticketPrice * totalUsers;
        uint256 gldnBusdFee = SafeMath.div(SafeMath.mul(contractBalance,fee),100);
        BusdInterface.transfer(gldnBusd,gldnBusdFee);
        uint256 winnerAmount = SafeMath.sub(contractBalance,gldnBusdFee);
        BusdInterface.transfer(participants[win],winnerAmount);
        winnerLottery.push(participants[win]);
        delete participants;
        participantNumbers = 0;
    }

    function pickwinner1() internal {
        uint win = random() % participants1.length;
        uint256 contractBalance = ticketPrice1 * participants1.length;
        uint256 gldnBusdFee = SafeMath.div(SafeMath.mul(contractBalance,fee),100);
        BusdInterface.transfer(gldnBusd,gldnBusdFee);
        uint256 winnerAmount = SafeMath.sub(contractBalance,gldnBusdFee);
        BusdInterface.transfer(participants1[win],winnerAmount);
        winnerLottery1.push(participants1[win]);
        delete participants1;
        participantNumbers1 = 0;
    }

    function pickwinner2() internal {
        uint win = random() % participants2.length;
        uint256 contractBalance = ticketPrice2 * participants2.length;
        uint256 gldnBusdFee = SafeMath.div(SafeMath.mul(contractBalance,fee),100);
        BusdInterface.transfer(gldnBusd,gldnBusdFee);
        uint256 winnerAmount = SafeMath.sub(contractBalance,gldnBusdFee);
        BusdInterface.transfer(participants2[win],winnerAmount);
        winnerLottery2.push(participants2[win]);
        delete participants2;
        participantNumbers2 = 0;
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
        else {
            for (uint256 i=arrayLength; i>0; i--) {
                resultLength++;
                address payable _address = payable(winnerLottery[i-1]);
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
        else {
            for (uint256 i=arrayLength; i>0; i--) {
                resultLength++;
                address payable _address = payable(winnerLottery1[i-1]);
                result[index]=_address;
                index++;
            }
        }
        return result;
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
        else {
            for (uint256 i=arrayLength; i>0; i--) {
                resultLength++;
                address payable _address = payable(winnerLottery2[i-1]);
                result[index]=_address;
                index++;
            }
        }
        return result;
    }
}