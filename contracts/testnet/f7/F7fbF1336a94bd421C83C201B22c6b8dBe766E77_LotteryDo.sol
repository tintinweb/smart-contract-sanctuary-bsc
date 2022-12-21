// SPDX-License-Identifier: MIT

//     www.cryptodo.app

pragma solidity 0.8.16;

contract LotteryDo  {

    address immutable devAddress;
    uint8   immutable ownerFee;
    uint8   immutable devFee;
    address public    owner; 

    constructor 
    (address devAddress_, uint8 devFee_, uint8 ownerFee_,
     uint ticketsPrice_, uint32 ticketsAmount_, uint startTime_,
     uint endTime_, uint8[] memory winnersPercentage_, uint8[] memory valuePercantage_)
    {
        devAddress=devAddress_;
        owner = msg.sender;
        ownerFee=ownerFee_;
        devFee=devFee_;
        createBlock(ticketsPrice_,ticketsAmount_,startTime_,endTime_,winnersPercentage_,valuePercantage_);
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
      

        uint32   ticketsWonAmount;
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
 
        mapping (uint32=>uint32)  ticketsAmount;
        mapping (uint32=>uint32)  wonticketsAmont;

        uint balance;
    }

    mapping (uint32=>LotteryBlock) public BlockID;
    mapping (address=>userBlock)   private UserID;
    
    
    uint32 private  ID;
    uint   private counter; 

    event CreateLottery (uint32 ID, uint StartTime, uint EndTime);
    event Winner        (uint32 ID,uint Ticket,uint PrizeValue);
    event RefundSurplus (uint32 ID,uint Tickets, uint Amount);
    event TicketsBought (address User,uint32 Amount);
    event Withdraw      (address User, uint Amount);
    event EndLottery    (uint32 ID,uint EndTime);
    
//_____________________________________________________________________________________________________________________________________________________________________________________________
    
    
    function createBlock
    (uint ticketsPrice_, uint32 ticketsAmount_, uint startTime_, uint endTime_, uint8[] memory winnersPercentage_, uint8[] memory valuePercantage_) 
    public onlyOwner {
        
        require(winnersPercentage_.length==valuePercantage_.length,"array's length must be equal to");
        require(startTime_<endTime_,"start time must be more than end time");
        require(ticketsAmount_>9,"tickets amount must be >= than ten");
        require(ticketsPrice_>999,"ticket price must be >= than thousand");
        require(winnersPercentage_.length<101,"Enter fewer winners");
        
        uint16  winnerPercentage;
        uint16   totalPercentage;
        
        for(uint i=0;i<valuePercantage_.length;i++){
            totalPercentage+=valuePercantage_[i];
            winnerPercentage+=winnersPercentage_[i];
            require(valuePercantage_[i]>0 && winnersPercentage_[i]>0,"need to set percentage above zero");
            if (ticketsAmount_<100)
            require(valuePercantage_[i]>9,"set percentage above 9");
        }
        require(totalPercentage==100 && winnerPercentage<101,"requires the correct ratio of percentages");
        
        BlockID[ID].startTime=startTime_+block.timestamp;
        BlockID[ID].winnersPercentage=winnersPercentage_;
        BlockID[ID].valuePercantage=valuePercantage_;
        BlockID[ID].endTime=endTime_+block.timestamp;
        BlockID[ID].ticketsPrice=ticketsPrice_;
        BlockID[ID].ticketsAmount=ticketsAmount_;
       
        emit CreateLottery(ID,startTime_+block.timestamp,endTime_+block.timestamp);

        ID++;
    }

    function addValue(uint32 ID_) external payable onlyOwner {
        require(BlockID[ID_].startTime<block.timestamp && !BlockID[ID_].ended,"Lottery didn't started or already ended");
        require(msg.value>0,"0 value");
        
        bool sent=payable(devAddress).send(msg.value*devFee/100);
        require(sent,"Send is failed");

        BlockID[ID_].pot+=msg.value-(msg.value*devFee/100);
    }

    function endBlock(uint32 ID_) external onlyOwner {
        require(BlockID[ID_].endTime<block.timestamp,"Lottery are still running");
        require(!BlockID[ID_].ended,"Lottery is over,gg");
        setWinners(ID_);
    }


//_____________________________________________________________________________________________________________________________________________________________________________________________

    function setWinners(uint32 ID_) private {
        uint32 winnersAmount;
        uint8[] memory valuePercantage_=BlockID[ID_].valuePercantage;
        BlockID[ID_].surplus=BlockID[ID_].pot;
        uint32 ticketsBought=BlockID[ID_].ticketsBought;
        unchecked{
            for (uint i=0;i<valuePercantage_.length;i++){
                winnersAmount=ticketsBought*BlockID[ID_].winnersPercentage[i]/100;     
                uint prizeValue=(BlockID[ID_].pot*valuePercantage_[i]/100)/winnersAmount;  
                setTickets(winnersAmount,prizeValue,ID_);
            }
        }
        if(BlockID[ID_].surplus/ticketsBought>0)
        refundSurplus(ID_);
        BlockID[ID_].ended=true;
        emit EndLottery(ID_,block.timestamp);
    }

        function refundSurplus(uint32 ID_) private {
            if(BlockID[ID_].surplus>0){
                UserID[owner].balance+=BlockID[ID_].surplus;
                BlockID[ID_].surplus=0;
            }
    }

    function setTickets (uint winnersAmount_, uint prizeValue_,uint32 ID_) private {
        uint prize;
        bool newTicket;
        unchecked{
        for (uint a=0;a<winnersAmount_;a++){
                uint wonTicket;
                newTicket=false;
                while (!newTicket){
                        wonTicket = random(BlockID[ID_].ticketsBought)+1;
                        if (BlockID[ID_].ticketWon[wonTicket]!=1)
                            newTicket=true;
                }
                
                UserID[BlockID[ID_].ticketsOwner[wonTicket]].balance+=prizeValue_;
                UserID[BlockID[ID_].ticketsOwner[wonTicket]].wonticketsAmont[ID_]++;
                BlockID[ID_].ticketWon[wonTicket]=1;
                prize+=prizeValue_;
                BlockID[ID_].ticketsWonAmount++;

                emit Winner(ID_,wonTicket,prizeValue_);
            }
        }
        BlockID[ID_].surplus-=prize;
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
        }
        UserID[msg.sender].ticketsAmount[ID_]+=amount;
        BlockID[ID_].ticketsBought+=amount;

        BlockID[ID_].pot+=msg.value-(msg.value/100*devFee)-(msg.value*ownerFee/100);
        
        bool sent = payable(devAddress).send(msg.value*devFee/100);
        require(sent,"Send is failed");

        UserID[owner].balance+=msg.value/100*ownerFee;

        emit TicketsBought(msg.sender,amount);

        if (BlockID[ID_].ticketsBought==BlockID[ID_].ticketsAmount)
            setWinners(ID_);
    }


    function withdraw() external {
        require(msg.sender!=address(0),"Zero address");
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
   
    function checkTickets(address user,uint32 ID_) external view returns (uint32[] memory tickets){
        uint32[] memory tickets_ = new uint32[] (UserID[msg.sender].ticketsAmount[ID_]);
        uint32 a;
        uint32 amount=BlockID[ID_].ticketsBought;
        for (uint32 i=1;i<amount+1;i++){
            if(BlockID[ID_].ticketsOwner[i]==user){
                tickets_[a]=i;
                a++;
            }
        }
        return(tickets_);
    }

    function checkWonTickets(address user,uint32 ID_) external view returns (uint[] memory tickets){
        uint[] memory wonTickets_ = new uint[] (UserID[user].wonticketsAmont[ID_]);
        uint32 allTickets = BlockID[ID_].ticketsBought;
        uint32 a;
        for (uint32 i=1;i<allTickets+1;i++){
            if(BlockID[ID_].ticketWon[i]>0 && BlockID[ID_].ticketsOwner[i]==user){
                wonTickets_[a]=i;
                a++;
            }
        }
   
        return(wonTickets_);
    }

    function checkBalance(address user) external view returns (uint balance){
        return(UserID[user].balance);
    }

    function checkTicketOwner(uint32 ID_,uint32 ticket) external view returns(address user){
        return(BlockID[ID_].ticketsOwner[ticket]);
    }

    function checkLotterysWinners(uint32 ID_) external view returns (uint[] memory winners){
        uint[] memory wonTickets=new uint[](BlockID[ID_].ticketsWonAmount);
        uint32 a;
        for (uint32 i=1;i<BlockID[ID_].ticketsBought+1;i++){
            if(BlockID[ID_].ticketWon[i]>0){
                wonTickets[a]=i;
                a++;
            }
        }
        return(wonTickets);
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