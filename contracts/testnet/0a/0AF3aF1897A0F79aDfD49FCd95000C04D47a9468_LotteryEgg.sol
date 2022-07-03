/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
contract LotteryEgg {
    address private  DevAddress;
    address[] private investors;
    //Maximum investment pool
    uint256 private constant  Maximum_Investment_pool=5000*10**18;
    //Minimum investment amount
    uint256 private constant  Minimum_investment_amount=10**18;
    //Investor profit balance,These balances can be distributed to investors in proportion
    uint256 private InvestorsProfit;
    //The dividend time of investors in the recent bonus pool shall be at least one week apart
    uint256 public RecentDividendTime;
    //Last buy eggs time
    uint256 public LastBuyEggTime;
    //Total investment amount
    uint256 public TotalInvestmentAmount;
    //all referral profit
    uint256 private TotalReferralProfit;
    uint256 public DevProfit;
    uint256 private constant  PerEggPrice= 0.02*10**18;//0.02BNB per egg
    //users infomation,Including the information of purchased eggs and activated infomation 
    mapping(address=>userinfo) private Usersinfo;
    //referrals
    mapping (address => address) private referrals;
    //investor balance
    mapping (address => investorbalance) private InvestorsBalance;
    WinningInfo[] private WinningRecord;
    struct WinningInfo{
        uint32 LotteryNum;
        uint8 mul;
        uint56 timestamp;
        address winner;
    }
    //investor balance struct
    struct investorbalance{
        uint256 balance;
        bool HasInvested;
    }
    struct Egginfo
    {
        bytes32 uid;
        uint8 mul;
        uint248 blocknumber;
    }
    struct OpenedLotInfo{
        uint32 LotteryNum;
        uint8 mul; 
    }
    struct userinfo
    {
        Egginfo[] eggsinfo;
        OpenedLotInfo[] openedeggs;
        uint256 ReferralProfit;
        bool actived;
    }
    constructor() {  
        DevAddress =msg.sender; 
        RecentDividendTime=block.timestamp;
        LastBuyEggTime=block.timestamp;
    }
    //buy eggs
    function BuyEggs(uint16 LotCount, uint8 mul,uint232 Lucknum,address ref) external payable {
        require(msg.value>=PerEggPrice,"Buy at least one egg");
        require(mul>=1 && mul<=10,"Multiples between 1 and 10");
        require(LotCount>=1 && LotCount<=10000,"Number of eggs between 1 and 10000");
        uint256 AllLotteryCount=SafeMathdiv(msg.value,PerEggPrice);
        require(AllLotteryCount==LotCount*mul);
        for(uint256 i=0;i<LotCount;i++){
            Egginfo memory  egginfo=Egginfo(keccak256(abi.encodePacked(block.timestamp, block.coinbase,msg.sender,Lucknum++)),mul,uint248(block.number));
            Usersinfo[msg.sender].eggsinfo.push(egginfo);
        }
        if(!Usersinfo[msg.sender].actived) Usersinfo[msg.sender].actived=true;
        //Developer part
        DevProfit+=SafeMathdiv(SafeMathmul(msg.value,3),100);
        //Investor part
        InvestorsProfit+=SafeMathdiv(SafeMathmul(msg.value,3),100);
        if(referrals[msg.sender] == address(0)) {
            //referral part,only actived account can get referral reward
            if(ref == msg.sender || ref == address(0)||!Usersinfo[ref].actived) {
                ref = DevAddress;
            }
            referrals[msg.sender] = ref;
        }
        uint256 referralprofit=SafeMathdiv(SafeMathmul(msg.value,4),100);
        if(referrals[msg.sender]==DevAddress){
            DevProfit +=referralprofit;
        }
        else{
            Usersinfo[msg.sender].ReferralProfit +=referralprofit;
            TotalReferralProfit +=referralprofit;
        }
        LastBuyEggTime=block.timestamp;
    }
    //withdraw referral profit
    function WithdrawReferralProfit() external {
        require(Usersinfo[msg.sender].ReferralProfit>=0.01*10**18,"Your referral profit is at least 0.01BNB");
        uint256 profit=Usersinfo[msg.sender].ReferralProfit;
        Usersinfo[msg.sender].ReferralProfit=0;
        TotalReferralProfit -= profit;
        payable(msg.sender).transfer(profit);
    }
    //get public information
    function GetPublicInformation() public view returns(uint256 ,uint256 ,uint256 ,uint256 ){
        return(address(this).balance-InvestorsProfit-TotalReferralProfit-DevProfit,TotalInvestmentAmount,InvestorsProfit,RecentDividendTime);
    }
    //get privite information
    function GetPrivateInformation() public view returns(uint256,uint256,uint256){
        return(Usersinfo[msg.sender].eggsinfo.length,InvestorsBalance[msg.sender].balance,Usersinfo[msg.sender].ReferralProfit);
    }
    //draw the winning numbers of a lottery
    function OpenEggs() external  {
        require(Usersinfo[msg.sender].eggsinfo.length>0,"You don't have undraw lottery tickets");
        require(block.number>Usersinfo[msg.sender].eggsinfo[Usersinfo[msg.sender].eggsinfo.length-1].blocknumber,"It's not time");
        if(Usersinfo[msg.sender].openedeggs.length>0) delete Usersinfo[msg.sender].openedeggs;
        uint256   WinningAmont=0;
        for(uint256 i=0 ;i<Usersinfo[msg.sender].eggsinfo.length;i++){
            //If the lottery time exceeds 256 blocks, it will be automatically voided
            if(uint256(blockhash(Usersinfo[msg.sender].eggsinfo[i].blocknumber))==0) continue;
            uint32 LotteryNum=uint32(bytes4(keccak256(abi.encodePacked(Usersinfo[msg.sender].eggsinfo[i].uid,blockhash(Usersinfo[msg.sender].eggsinfo[i].blocknumber)))));
            uint256  Winninggrade=GetWinninggrade(LotteryNum);
            uint256 WinningMoney=0;
            if(Winninggrade>0){
                WinningMoney=GetWinningmultiple(Winninggrade)*Usersinfo[msg.sender].eggsinfo[i].mul*PerEggPrice;
                WinningAmont+=WinningMoney;     
                //winning record
                WinningInfo memory winning= WinningInfo(LotteryNum,Usersinfo[msg.sender].eggsinfo[i].mul,uint40(block.timestamp),msg.sender); 
                WinningRecord.push(winning);       
            }
            OpenedLotInfo memory OpenedLotterys=OpenedLotInfo(LotteryNum,Usersinfo[msg.sender].eggsinfo[i].mul);
            Usersinfo[msg.sender].openedeggs.push(OpenedLotterys);
        }
        delete  Usersinfo[msg.sender].eggsinfo;
        if(WinningAmont>0){
            //You can only get 70% of the prize pool at most each time
            uint256 MaxWinningAmount=SafeMathdiv(SafeMathmul(SafeMathsub(address(this).balance,InvestorsProfit+TotalReferralProfit+DevProfit),70),100);
            if(WinningAmont>MaxWinningAmount) WinningAmont=MaxWinningAmount;
            InvestorsProfit+=SafeMathdiv(SafeMathmul(WinningAmont,5),100);
            DevProfit +=SafeMathdiv(SafeMathmul(WinningAmont,5),100);
            payable(msg.sender).transfer(SafeMathdiv(SafeMathmul(WinningAmont,90),100));
        }
    }
    //Get winning record
    function GetWinnersRecord(uint256 RecordCount) public view returns(WinningInfo[] memory){
        uint256 RecordCt=RecordCount;
        uint256 WinningRecordLen=WinningRecord.length;
        if(RecordCt>WinningRecordLen)RecordCt=WinningRecordLen;
        WinningInfo[] memory LatelyWinnersRecord=new WinningInfo[](RecordCt);
        for(uint256 i=0;i<RecordCt;i++){
            LatelyWinnersRecord[i]=WinningRecord[WinningRecordLen-1-i];
        }
        return LatelyWinnersRecord;
    }
    //Get the latest lottery information
    function GetLatestLottery() public view returns(OpenedLotInfo[] memory){
        return Usersinfo[msg.sender].openedeggs;
    }
    //get my investment balance
    function GetInvestmentBalance(address addr) public view returns(uint256){
        return InvestorsBalance[addr].balance;
    }
    //Investment deposit
    function InvestmentDeposit() external payable {
        //Minimum investment is 1 BNB,Maxnum investment is 1000 BNB
        require(msg.value>=Minimum_investment_amount && msg.value<=1000*10**18,"Investment amount between 1 and 1000 BNB");
        //The balance of the prize pool is required to be less than Maximum_Investment_pool
        require(SafeMathsub(address(this).balance,InvestorsProfit)<Maximum_Investment_pool,"Prize pool must less than 5000 BNB");
        TotalInvestmentAmount+=msg.value;
        DevProfit +=SafeMathdiv(SafeMathmul(msg.value,3),100);
        InvestorsBalance[msg.sender].balance+=msg.value;
        if(!InvestorsBalance[msg.sender].HasInvested){
            InvestorsBalance[msg.sender].HasInvested=true;
            investors.push(msg.sender);
        }
    }
    //Withdrawal of investment funds
    function InvestmentWithdrawal(uint256 WithdrawalAmount) external {
        //The investment balance must be greater than 1BNB, and the withdrawal amount must be greater than 1 BNB
        require(InvestorsBalance[msg.sender].balance>=Minimum_investment_amount && WithdrawalAmount>=Minimum_investment_amount,"you must withdraw more than 1BNB");
        require(WithdrawalAmount<=InvestorsBalance[msg.sender].balance,"Exceed you investment balance");
        require(SafeMathsub(address(this).balance,(InvestorsProfit+DevProfit+TotalReferralProfit+WithdrawalAmount))>=Maximum_Investment_pool+1000*10**18,"Prize pool must keep more than 6000BNB");
        InvestorsBalance[msg.sender].balance-=WithdrawalAmount;
        TotalInvestmentAmount-=WithdrawalAmount;
        payable(msg.sender).transfer(WithdrawalAmount);
    }
    //Developer withdrawal
    function DeveloperWithdrawal() external{
        require(msg.sender==DevAddress,"You are not Developer");
        uint256 devprofit= DevProfit;
        DevProfit=0;
        payable(DevAddress).transfer(devprofit);
    }
    //Investment dividend,Distribute investment income according to the proportion of investors
    function DistributeInvestmentIncome() external{
        //Only investors and developer have the right to initiate
        require(InvestorsBalance[msg.sender].balance>=Minimum_investment_amount||msg.sender==DevAddress,"You must be a investor");
        //The total dividend income to be distributed must be greater than Minimum_investment_amount
        // And total investment amount must be greater than Minimum_investment_amount
        require(InvestorsProfit>=10**18 && TotalInvestmentAmount>=Minimum_investment_amount,"Investment profit must more than 1 BNB");
        //The interval between dividends shall be at least one week
        require(block.timestamp>= RecentDividendTime+1 weeks,"One week can only distribute once,maybe someone else have distrited it");
        //dividends amount
        uint256  Tmpinvestorsprofit=InvestorsProfit;
        //developer award
        uint256 devloperaward=0;
        //When the prize pool exceeds twice Maximum_Investment_pool, 0.5% will be used as a dividend for investors,0.5% will be awarded to developer
        if(SafeMathsub(address(this).balance,InvestorsProfit)>=Maximum_Investment_pool*2){
            Tmpinvestorsprofit+= SafeMathsub(address(this).balance,InvestorsProfit)/200;
            devloperaward=SafeMathsub(address(this).balance,InvestorsProfit)/200;
        }       
        //reset InvestorsProfit
        InvestorsProfit=0;
        for(uint256 i=0;i<investors.length;i++){
            if(InvestorsBalance[investors[i]].balance>=10**18){
                uint256 thisinvestorprofit=SafeMathdiv(SafeMathmul(InvestorsBalance[investors[i]].balance,Tmpinvestorsprofit),TotalInvestmentAmount);
                payable(investors[i]).transfer(thisinvestorprofit);
            }
        }
        if(devloperaward>=0.01*10**18)
        {
            payable(DevAddress).transfer(devloperaward);
        }
    }
    //If no one buys for more than 15 days, the developer can consume the contract and return it to the investors
    function Returntoinvestor()  external  {
        require(msg.sender==DevAddress);
        require(block.timestamp>LastBuyEggTime+15 days);
        if(address(this).balance>=TotalInvestmentAmount){
            for(uint256 i=0;i<investors.length;i++){
                if(InvestorsBalance[investors[i]].balance>=10**18){
                    payable(investors[i]).transfer(InvestorsBalance[investors[i]].balance);
                }
            }
        }
        else
        {
            uint256 contractBalance=address(this).balance;
            if(contractBalance>=10**18){
                for(uint256 i=0;i<investors.length;i++){
                    if(InvestorsBalance[investors[i]].balance>=10**18){
                        payable(investors[i]).transfer(InvestorsBalance[investors[i]].balance*contractBalance/TotalInvestmentAmount);
                    }
                }
            }
        }
        selfdestruct(payable(DevAddress));
    }
    //Winning grade
    function GetWinninggrade(uint32 LotteryNum) private pure  returns(uint256){ 
        if(LotteryNum>=67108864)  return 0;
        if(LotteryNum>=33554432)  return 20;
        if(LotteryNum>=16777216)  return 19;
        if(LotteryNum>=8388608)  return 18;
        if(LotteryNum>=4194304)  return 17;
        if(LotteryNum>=2097152)  return 16;
        if(LotteryNum>=1048576)  return 15;
        if(LotteryNum>=524288)  return 14;
        if(LotteryNum>=262144)  return 13;
        if(LotteryNum>=131072)  return 12;
        if(LotteryNum>=65536)  return 11;
        if(LotteryNum>=32768)  return 10;
        if(LotteryNum>=16384)  return 9;
        if(LotteryNum>=8192)  return 8;
        if(LotteryNum>=4096)  return 7;
        if(LotteryNum>=2048)  return 6;
        if(LotteryNum>=1024)  return 5;
        if(LotteryNum>=512)  return 4;
        if(LotteryNum>=256)  return 3;
        if(LotteryNum>=128){
            return 2;
        }
        else {
            return 1;
        }
    }
    //Winning multiple
    function GetWinningmultiple(uint256 winninggrade) private pure  returns(uint256){
      if(winninggrade==0)  return 0;
      if(winninggrade==20)  return 2;
      if(winninggrade==19)  return 5;
      if(winninggrade==18)  return 10;
      if(winninggrade==17)  return 20;
      if(winninggrade==16)  return 40;
      if(winninggrade==15)  return 80;
      if(winninggrade==14)  return 160;
      if(winninggrade==13)  return 320;
      if(winninggrade==12)  return 640;
      if(winninggrade==11)  return 1280;
      if(winninggrade==10)  return 2560;
      if(winninggrade==9)  return 5120;
      if(winninggrade==8)  return 10240;
      if(winninggrade==7)  return 20480;
      if(winninggrade==6)  return 50000;
      if(winninggrade==5)  return 100000;
      if(winninggrade==4)  return 200000;
      if(winninggrade==3)  return 500000;
      if(winninggrade==2)  return 1000000;
      if(winninggrade==1)  return 2000000;
      return 0;
    }
    function SafeMathmul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function SafeMathdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        //assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        //assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function SafeMathsub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function SafeMathadd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}