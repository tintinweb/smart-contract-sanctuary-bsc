// SPDX-License-Identifier: MIT

//    www.cryptodo.app

pragma solidity 0.8.16;

contract LotteryDo {

    address immutable devAddress;
    uint8   immutable ownerFee;
    uint8   immutable devFee;
    address public    owner;  

    constructor (address devAddress_, uint8 devFee_, uint8 ownerFee_){
        devAddress=devAddress_;
        owner = msg.sender;
        ownerFee=ownerFee_;
        devFee=devFee_;
       
    }

    modifier onlyOwner() {
       require(msg.sender == owner, "Not owner");
       _;
    }

    struct LotteryBlock {
        mapping (uint=>address) ticketsOwner;
        mapping (uint=>uint8)   ticketWon;

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
    
    uint   usersRefund;
    uint32 private  ID;
    uint   private counter; 

    event CreateLottery (uint32 ID, uint StartTime, uint EndTime);
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
        uint8[] memory winnerPercentage_ = BlockID[ID_].winnersPercentage ;
        uint8[] memory valuePercantage_  = BlockID[ID_].valuePercantage;
        uint32  ticketsBought=BlockID[ID_].ticketsBought;
        BlockID[ID_].surplus=BlockID[ID_].pot;
        for (uint i=0;i<BlockID[ID_].valuePercantage.length;inc(i)){
            if (ticketsBought>=100)
                winnersAmount=ticketsBought/100*winnerPercentage_[i];
            else                   
                winnersAmount=(ticketsBought*100*winnerPercentage_[i])/10000;    
            
            uint prizeValue=(BlockID[ID_].pot/100*valuePercantage_[i])/winnersAmount;  
            setTickets(winnersAmount,prizeValue,ID_);   
        }
        if(BlockID[ID_].surplus/ticketsBought>0)
        refundSurplus(ID_);
        BlockID[ID_].ended=true;
        emit EndLottery(ID_,block.timestamp);
    }

        function refundSurplus(uint32 ID_) private {
            uint surplusPerTicket;
            uint usersRefund1=BlockID[ID_].ticketsBought-BlockID[ID_].wonTickets.length;
            if(usersRefund1>usersRefund){
                surplusPerTicket = BlockID[ID_].surplus/usersRefund1;
                setTickets(usersRefund1,surplusPerTicket,ID_);
            }
            else{
                surplusPerTicket = BlockID[ID_].surplus/usersRefund;
                setTickets(usersRefund,surplusPerTicket,ID_);
            }
                
            if(BlockID[ID_].surplus>0){
                UserID[owner].balance+=BlockID[ID_].surplus;
                BlockID[ID_].surplus=0;
            }
    }

    function setTickets (uint winnersAmount_, uint prizeValue_,uint32 ID_) private {
        uint surSub;
        for (uint32 a=0;a<winnersAmount_;inc(a)){
                uint wonTicket;
                bool newTicket;
                while (!newTicket){
                    wonTicket = random(BlockID[ID_].ticketsBought)+1;
                    if (BlockID[ID_].ticketWon[wonTicket]!=1)
                        newTicket=true;
                }
                BlockID[ID_].wonTickets.push(wonTicket);
                BlockID[ID_].ticketWon[wonTicket]=1;
                UserID[BlockID[ID_].ticketsOwner[wonTicket]].WonTickets[ID_].push(wonTicket);
                UserID[BlockID[ID_].ticketsOwner[wonTicket]].balance+=prizeValue_;
                surSub+=prizeValue_;
        }
        BlockID[ID_].surplus-=surSub;
    }
    

    function random(uint num) private returns(uint){
        counter++;
        return uint(keccak256(abi.encodePacked(block.number,counter, msg.sender))) % num;
    }

    function inc(uint x) private pure returns (uint) {
        unchecked { return x + 1; }
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

        UserID[owner].balance+=msg.value/100*ownerFee;

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

    function checkTicketOwner(uint32 ID_,uint32 ticket) external view returns(address user){
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