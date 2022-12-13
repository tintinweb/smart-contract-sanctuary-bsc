import "@openzeppelin/contracts/access/Ownable.sol";
// SPDX-License-Identifier: MIT

//    www.cryptodo.app

pragma solidity 0.8.16;

contract LotteryDo is Ownable {

    address immutable devAddress;
    uint8   immutable ownerFee;
    uint8   immutable devFee;

    constructor (address devAddress_, uint8 devFee_, uint8 ownerFee_){
        devAddress=devAddress_;
        ownerFee=ownerFee_;
        devFee=devFee_;
    }

    struct LotteryBlock {
        mapping (uint=>address) ticketsOwner;
        mapping (uint=>uint8) ticketWon;

        uint8 [] winnersPercentage;      
        uint8 [] valuePercantage; 
        uint  [] wonTickets;

     
        uint32   ticketsAmount;
        uint32   ticketsBought; 
        uint     ticketsPrice;

        uint     startTime;
        uint     surplus;
        uint     endTime;
        
        
        bool     ended;
        uint     pot;
        
    }

    struct userBlock{
 
        mapping (uint32=>uint[])  Tickets;
        mapping (uint32=>uint[])  WonTickets;

        uint balance;
    }

    mapping (uint32=>LotteryBlock) public BlockID;
    mapping (address=>userBlock)   private UserID;
    
    uint8  usersRefund;
    uint32 private  ID;
    uint   private counter; 

    event CreateLottery (uint32 ID, uint StartTime, uint EndTime);
    event Winner        (uint32 ID,uint Ticket,uint PrizeValue);
    event TicketsBought (address User,uint32 Amount);
    event Withdraw      (address User, uint Amount);
    event EndLottery    (uint32 ID,uint EndTime);
    
//_____________________________________________________________________________________________________________________________________________________________________________________________
    
    
    function createBlock
    (uint ticketsPrice_, uint32 ticketsAmount_, uint startTime_, uint endTime_, uint8[] memory winnersPercentage_, uint8[] memory valuePercantage_) 
    external onlyOwner {
        
        require(winnersPercentage_.length==valuePercantage_.length,"array's length must be equal to");
        require(startTime_<endTime_,"start time must be more than end time");
        require(ticketsAmount_>0,"tickets amount must be more than zero");
        require(ticketsPrice_>0,"ticket price must be more than zero");
        require(winnersPercentage_.length<=100,"Enter fewer winners");
        
        uint16  winnerPercentage;
        uint16   totalPercentage;
        
        for(uint i=0;i<valuePercantage_.length;i++){
            totalPercentage+=valuePercantage_[i];
            winnerPercentage+=winnersPercentage_[i];
            require(valuePercantage_[i]>0 && winnersPercentage_[i]>0,"need to set percentage above zero");
        }
        require(totalPercentage<=100 && winnerPercentage<=100,"requires the correct ratio of percentages");
        
        BlockID[ID].startTime=startTime_+block.timestamp;
        BlockID[ID].winnersPercentage=winnersPercentage_;
        BlockID[ID].valuePercantage=valuePercantage_;
        BlockID[ID].endTime=endTime_+block.timestamp;
        BlockID[ID].ticketsPrice=ticketsPrice_;
        BlockID[ID].ticketsAmount=ticketsAmount_;
       
        emit CreateLottery(ID,startTime_+block.timestamp,endTime_+block.timestamp);

        ID++;
    }

    function endBlock(uint32 ID_) external onlyOwner {
        require(BlockID[ID_].endTime<block.timestamp,"Lottery are still running");
        require(!BlockID[ID_].ended,"Lottery is over,gg");
        setWinners(ID_);
    }

    function changeQuantityForRefund (uint8 usersRefund_) external onlyOwner {
        usersRefund=usersRefund_;
    }

//_____________________________________________________________________________________________________________________________________________________________________________________________

    function setWinners(uint32 ID_) private {
        uint32 winnersAmount;
        BlockID[ID_].surplus=BlockID[ID_].pot;
        for (uint i=0;i<BlockID[ID_].valuePercantage.length;i++){
            if (BlockID[ID_].ticketsBought>=100)
                winnersAmount=BlockID[ID_].ticketsBought/100*BlockID[ID_].winnersPercentage[i];
            else                   
                winnersAmount=(BlockID[ID_].ticketsBought*100*BlockID[ID_].winnersPercentage[i])/10000;    
            uint   prizeValue=(BlockID[ID_].pot/100*BlockID[ID_].valuePercantage[i])/winnersAmount;  
                setTickets(winnersAmount,prizeValue,ID_);
               
        }
        if(BlockID[ID_].surplus/BlockID[ID_].ticketsBought>0)
        refundSurplus(ID_);
        BlockID[ID_].ended=true;
        emit EndLottery(ID_,block.timestamp);
    }

        function refundSurplus(uint32 ID_) private {
            uint surplusPerTicket = BlockID[ID_].surplus/usersRefund;
            setTickets(usersRefund,surplusPerTicket,ID_);

            if(BlockID[ID_].surplus>0){
                UserID[owner()].balance+=BlockID[ID_].surplus;
                BlockID[ID_].surplus=0;
            }
    }

    function setTickets (uint32 winnersAmount_, uint prizeValue_,uint32 ID_) private {
        for (uint a=0;a<winnersAmount_;a++){
                uint wonTicket;
                bool newTicket;
                while (!newTicket){
                    wonTicket = random(BlockID[ID_].ticketsBought)+1;
                    if (BlockID[ID_].ticketWon[wonTicket]!=1)
                        newTicket=!newTicket;
                }
                BlockID[ID_].wonTickets.push(wonTicket);
                BlockID[ID_].ticketWon[wonTicket]=1;
                UserID[BlockID[ID_].ticketsOwner[wonTicket]].WonTickets[ID_].push(wonTicket);
                UserID[BlockID[ID_].ticketsOwner[wonTicket]].balance+=prizeValue_;
                BlockID[ID_].surplus-=prizeValue_;
                
                emit Winner(ID_,wonTicket,prizeValue_);
        }
    }
    

     function random(uint num) private returns(uint){
        counter++;
        return uint(keccak256(abi.encodePacked(block.number,counter, msg.sender))) % num;
    }

//_____________________________________________________________________________________________________________________________________________________________________________________________  
    

    function buyTickets(uint32 amount,uint32 ID_) external payable {
        require(BlockID[ID_].startTime<block.timestamp && BlockID[ID_].endTime>block.timestamp,"Lottery didn't started or already ended");
        require(amount>0,"You need to buy at least 1 ticket");
        require(msg.value==amount*BlockID[ID_].ticketsPrice,"Inncorect value");
        require(amount+BlockID[ID_].ticketsBought<=BlockID[ID_].ticketsAmount,"Buy fewer tickets");
  
        for (uint32 i=BlockID[ID_].ticketsBought+1;i<BlockID[ID_].ticketsBought+1+amount;i++){
            BlockID[ID_].ticketsOwner[i]=msg.sender;
            UserID[msg.sender].Tickets[ID_].push(i);
        }
        BlockID[ID_].ticketsBought+=amount;

        BlockID[ID_].pot+=msg.value-(msg.value/100*devFee)-(msg.value/100*ownerFee);
        
        bool sent = payable(devAddress).send(msg.value/100*devFee);
        require(sent,"Send is failed");

        UserID[owner()].balance+=msg.value/100*ownerFee;

        emit TicketsBought(msg.sender,amount);

        if (BlockID[ID_].ticketsBought==BlockID[ID_].ticketsAmount)
            setWinners(ID_);
    }


    function withdraw() external {
        require(UserID[msg.sender].balance>0,"Nothing to withdraw");
        bool sent = payable(msg.sender).send(UserID[msg.sender].balance);
        require(sent,"Send is failed");
        
        emit Withdraw(msg.sender,UserID[msg.sender].balance);

        UserID[msg.sender].balance=0;
    }

//_____________________________________________________________________________________________________________________________________________________________________________________________

   function checkLotteryPercentage(uint32 ID_) external view returns(uint8[] memory winnersPercentage,uint8[] memory valuePercantage){
        return(BlockID[ID_].winnersPercentage,BlockID[ID_].valuePercantage);
    }
   
    function checkTickets(address user,uint32 ID_) external view returns (uint[] memory tickets){
        return(UserID[user].Tickets[ID_]);
    }

    function checkWonTickets(address user,uint32 ID_) external view returns (uint[] memory tickets){
        return(UserID[user].WonTickets[ID_]);
    }

    function checkBalance(address user) external view returns (uint balance){
        return(UserID[user].balance);
    }

    function checkTicketOwner(uint32 ID_,uint32 ticket) external view returns(address owner){
        return(BlockID[ID_].ticketsOwner[ticket]);
    }

    function checkLotterysWinners(uint32 ID_) external view returns (uint[] memory winners){
        return(BlockID[ID_].wonTickets);
    } 

    function checkTicketPrice(uint32 ID_) external view returns (uint ticketsPrice){
        return(BlockID[ID_].ticketsPrice);
    }

    function checkLotterysEnd(uint32 ID_) external view returns (uint endTime) {
        return(BlockID[ID_].endTime);
    }

    function checkLotterysPot(uint32 ID_) external view returns (uint pot) {
        return(BlockID[ID_].pot);
    }  

    function checkID () external view returns (uint32 Id) {
        if (ID==0)
        return ( ID );
        return (ID-1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}