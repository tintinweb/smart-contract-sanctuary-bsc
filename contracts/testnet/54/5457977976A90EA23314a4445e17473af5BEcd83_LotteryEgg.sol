/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

contract LotteryEgg {
    address private  DevAddress;
    //Maximum investment pool
    uint256 private Maximum_Investment_pool=3000*10**18;
    //Minimum investment amount
    uint256 private Minimum_investment_amount=0.1*10**18;
    //Investor profit balance,These balances can be distributed to investors in proportion
    uint256 public InvestorsProfit;
    //The dividend time of investors in the recent bonus pool shall be at least one week apart
    uint256 public RecentDividendTime;
    //deposit balance
    mapping(address=>Egginfo[]) public EggsBalance;
    //referrals
    mapping (address => address) private referrals;
    //Total investment amount
    uint256 public TotalInvestmentAmount;
    //investor balance struct
    struct investorbalance{
        uint256 balance;
        bool HasInvested;
    }
    //investor balance
    mapping (address => investorbalance) public InvestorsBalance;
    address[] public investors;
    uint256 private PerEggPrice= 0.0001*10**18;//0.0001BNB
    //最近开奖
    uint256[] public LatelyLotteryNum;
    uint32[] public LatelyLotteryNum32;
    struct Egginfo
    {
        bytes32 uid;
        uint256 mul;
        uint256 blocknumber;
    }
    struct LotteryResult
    {
        uint32 LotteryNum;
        uint256 WiningGrade;//0 to 20,0 means no winning
        uint256 WinningAmount;
    }
    constructor() {  
        DevAddress =msg.sender; 
        RecentDividendTime=block.timestamp;
    }
    //buy eggs
    function BuyEggs(uint256 LotCount, uint256 mul,uint256 Lucknum,address ref) external payable{
       require(msg.value>=PerEggPrice);
       require(mul>=1 && mul<=10);
       require(LotCount>=1);
       uint256 AllLotteryCount=SafeMathdiv(msg.value,PerEggPrice);
       assert(AllLotteryCount==LotCount*mul);
       for(uint256 i=0;i<LotCount;i++){
            Egginfo memory egginfo=Egginfo(keccak256(abi.encodePacked(block.timestamp, block.coinbase,address(this).balance,Lucknum++)),mul,block.number);
            EggsBalance[msg.sender].push(egginfo);
       }
       //Developer part
       payable(DevAddress).transfer(SafeMathdiv(SafeMathmul(msg.value,3),100));
       //Investor part
       InvestorsProfit+=SafeMathdiv(SafeMathmul(msg.value,2),100);
        //referral part
        if(ref == msg.sender || ref == address(0)) {
            ref = DevAddress;
        }
        if(referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
        }      
       payable(referrals[msg.sender]).transfer(SafeMathdiv(SafeMathmul(msg.value,5),100));
    }
    //draw the winning numbers of a lottery
    function OpenEggs() external  returns(LotteryResult[] memory){
        require(EggsBalance[msg.sender].length>0);
        LotteryResult[] memory  AllLotteryResult=new LotteryResult[](EggsBalance[msg.sender].length);
        uint256   WinningAmont=0;
        for(uint256 i=0 ;i<EggsBalance[msg.sender].length;i++){
            if(block.number>EggsBalance[msg.sender][i].blocknumber){
                uint256 LotteryNum=bytesToUint(keccak256(abi.encodePacked(EggsBalance[msg.sender][i].uid,blockhash(EggsBalance[msg.sender][i].blocknumber))));
                //test
                LatelyLotteryNum.push(LotteryNum);
                LatelyLotteryNum32.push(uint32(LotteryNum));
                 uint32  LotteryNum32=uint32(LotteryNum);
                 uint256  Winninggrade=GetWinninggrade(LotteryNum32);
                 uint256 WinningMoney=GetWinningmultiple(Winninggrade)*EggsBalance[msg.sender][i].mul*PerEggPrice;
                 WinningAmont+=WinningMoney;
                LotteryResult memory  ThisLotterResult=LotteryResult(LotteryNum32,Winninggrade,WinningMoney);
                AllLotteryResult[i]=ThisLotterResult;
            }
            else{
                revert();
            }
        }
        delete  EggsBalance[msg.sender];
        if(WinningAmont>0){
            //You can only get 75% of the prize pool at most each time
            uint256 MaxWinningAmount=SafeMathdiv(SafeMathmul(SafeMathsub(address(this).balance,InvestorsProfit),75),100);
            if(WinningAmont>MaxWinningAmount) WinningAmont=MaxWinningAmount;
            if(WinningAmont>=50*10**18) {
                InvestorsProfit+=SafeMathdiv(SafeMathmul(WinningAmont,5),100);
                payable(DevAddress).transfer(SafeMathdiv(SafeMathmul(WinningAmont,5),100));
                payable(msg.sender).transfer(SafeMathdiv(SafeMathmul(WinningAmont,90),100));
            }
            else{
                InvestorsProfit+=SafeMathdiv(SafeMathmul(WinningAmont,3),100);
                payable(DevAddress).transfer(SafeMathdiv(SafeMathmul(WinningAmont,3),100));
                payable(msg.sender).transfer(SafeMathdiv(SafeMathmul(WinningAmont,94),100));
            }
        }
        return AllLotteryResult;
    }
    //Bonus pool balance
    function GetBonuspollbalance() public view returns(uint256){
        return SafeMathsub(address(this).balance,InvestorsProfit);
    }
    //get my investment balance
    function Getinvestmentbalance() public view returns(uint256){
        return InvestorsBalance[msg.sender].balance;
    }
    //Investment deposit
    function Investmentdeposit() public payable returns(uint256){
        //Minimum investment is 1 BNB,Maxnum investment is 1000 BNB
        require(msg.value>=Minimum_investment_amount && msg.value<=1000*10**18);
        //The balance of the prize pool is required to be less than Maximum_Investment_pool
        require(SafeMathadd(SafeMathsub(address(this).balance,InvestorsProfit),msg.value)<=Maximum_Investment_pool);

        TotalInvestmentAmount+=msg.value;
        payable(DevAddress).transfer(SafeMathdiv(SafeMathmul(msg.value,3),100));
        InvestorsBalance[msg.sender].balance+=msg.value;
        if(!InvestorsBalance[msg.sender].HasInvested){
            InvestorsBalance[msg.sender].HasInvested=true;
            investors.push(msg.sender);
        }
        return InvestorsBalance[msg.sender].balance;
    }
    //Withdrawal of investment funds
    function InvestmentWithdrawal(uint256 WithdrawalAmount) public {
        //The investment balance must be greater than 1BNB, and the withdrawal amount must be greater than 1 BNB
        require(InvestorsBalance[msg.sender].balance>=Minimum_investment_amount && WithdrawalAmount>=Minimum_investment_amount);
        assert(WithdrawalAmount<=InvestorsBalance[msg.sender].balance);
        require(SafeMathsub(SafeMathsub(address(this).balance,InvestorsProfit),WithdrawalAmount)>=Maximum_Investment_pool);
        InvestorsBalance[msg.sender].balance-=WithdrawalAmount;
        TotalInvestmentAmount-=WithdrawalAmount;
        payable(msg.sender).transfer(WithdrawalAmount);
    }
    //Investment dividend,Distribute investment income according to the proportion of investors
    function DistributeInvestmentIncome() public  returns(uint256){
        //Only investors and developer have the right to initiate
        require(InvestorsBalance[msg.sender].balance>=Minimum_investment_amount||msg.sender==DevAddress);
        //The total dividend income to be distributed must be greater than Minimum_investment_amount
        // And total investment amount must be greater than Minimum_investment_amount
        require(InvestorsProfit>=0.001*10**18 && TotalInvestmentAmount>=Minimum_investment_amount);
        //The interval between dividends shall be at least one week
        require(block.timestamp>= RecentDividendTime+1 weeks);
        //dividends amount
        uint256  Tmpinvestorsprofit;
        //When the prize pool exceeds 10000, 1% will be used as a dividend for investors
        if(SafeMathsub(address(this).balance,InvestorsProfit)>=10000*10**18)
            Tmpinvestorsprofit=SafeMathadd(InvestorsProfit, SafeMathdiv(SafeMathsub(address(this).balance,InvestorsProfit),100));
        else
            Tmpinvestorsprofit=InvestorsProfit;
        InvestorsProfit=0;
        //Amount of profit distributed
        uint256  distributedprofit=0;
        //Dividend base
        uint256  Dividendbase;
        if(TotalInvestmentAmount>Maximum_Investment_pool)
            Dividendbase=TotalInvestmentAmount;
        else
            Dividendbase=Maximum_Investment_pool;
        for(uint256 i=0;i<investors.length;i++){
            if(InvestorsBalance[investors[i]].balance>=10**18){
                uint256 thisinvestorprofit=SafeMathdiv(SafeMathmul(InvestorsBalance[investors[i]].balance,Tmpinvestorsprofit),Dividendbase);
                distributedprofit+=thisinvestorprofit;
                payable(investors[i]).transfer(thisinvestorprofit);
            }
        }
        //If there is a balance after profit distribution, it will be distributed to developers
        if(SafeMathsub(Tmpinvestorsprofit,distributedprofit)>=0.01*10**18)
        {
            payable(DevAddress).transfer(SafeMathsub(Tmpinvestorsprofit,distributedprofit));
        }
        return SafeMathdiv(SafeMathmul(InvestorsBalance[msg.sender].balance,Tmpinvestorsprofit),Dividendbase);
    }
    //Winning grade
    function GetWinninggrade(uint32 LotteryNum) private pure  returns(uint256){
      if(LotteryNum<=64)  return 1;
      if(LotteryNum<=128)  return 2;
      if(LotteryNum<=256)  return 3;
      if(LotteryNum<=512)  return 4;
      if(LotteryNum<=1024)  return 5;
      if(LotteryNum<=2048)  return 6;
      if(LotteryNum<=4096)  return 7;
      if(LotteryNum<=8192)  return 8;
      if(LotteryNum<=16384)  return 9;
      if(LotteryNum<=32768)  return 10;
      if(LotteryNum<=65536)  return 11;
      if(LotteryNum<=131072)  return 12;
      if(LotteryNum<=262144)  return 13;
      if(LotteryNum<=524288)  return 14;
      if(LotteryNum<=1048576)  return 15;
      if(LotteryNum<=2097152)  return 16;
      if(LotteryNum<=4194304)  return 17;
      if(LotteryNum<=8388608)  return 18;
      if(LotteryNum<=16777216)  return 19;
      return 0;
    }
    //Winning multiple
    function GetWinningmultiple(uint256 winninggrade) private pure  returns(uint256){
      if(winninggrade==0)  return 0;
      if(winninggrade==19)  return 5;
      if(winninggrade==18)  return 11;
      if(winninggrade==17)  return 22;
      if(winninggrade==16)  return 43;
      if(winninggrade==15)  return 86;
      if(winninggrade==14)  return 172;
      if(winninggrade==13)  return 344;
      if(winninggrade==12)  return 688;
      if(winninggrade==11)  return 1376;
      if(winninggrade==10)  return 2753;
      if(winninggrade==9)  return 5505;
      if(winninggrade==8)  return 11010;
      if(winninggrade==7)  return 22020;
      if(winninggrade==6)  return 50332;
      if(winninggrade==5)  return 100663;
      if(winninggrade==4)  return 201327;
      if(winninggrade==3)  return 419430;
      if(winninggrade==2)  return 1006633;
      if(winninggrade==1)  return 2013266;
      return 0;
    }
    //bytes To Uint
    function bytesToUint(bytes32 b) private pure returns(uint256){
        uint256  number;
        for(uint256 i = 0;i<b.length;i++){
            number = number + uint8(b[i])*(2 **(8 *(b.length-(i + 1))));
        }
        return number;
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