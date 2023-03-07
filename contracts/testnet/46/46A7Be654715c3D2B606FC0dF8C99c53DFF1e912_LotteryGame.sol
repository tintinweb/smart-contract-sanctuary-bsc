/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
contract LotteryGame{
    //购买彩票数据结构
    struct Egginfo{
        bytes32 uid;
        uint8 mul;
        uint248 blocknumber;
    }
    //开奖号码数据结构
    struct OpenedLotInfo{
        uint32 Lotterynum;
        uint8 mul;
    }
    //用户信息数据结构
    struct userinfo{
        Egginfo[] eggsinfo;
        OpenedLotInfo[] openedeggs;
        uint256 ReferralProfit;
        bool actived;
    }
    //中奖记录数据结构
    struct Winninginfo{
        uint32 LotteryNum;
        uint8 mul;
        uint256 timestamp;
        address winner;
    }
    //投资者数据结构
    struct investorbalance{
        uint256 balance;
        uint256 LastInvestTime;  
        bool HasInvested;
    }
    //每注彩票金额
    uint256 private constant PerEggPrice=0.02 ether;
    //接受投资的奖池最大值
    uint256 private constant Maxinum_Investment_pool=10000 ether;
    //最小投资金额
    uint256 private constant Mininum_investment_amount=1 ether;
    //最大投资金额
    uint256 private constant Maxinum_investment_amount=1000 ether;
    //开发者地址
    address public DevAddress;
    //开发者收益
    uint256 private DevProfit;
    //所有投资者地址
    address[] private investors;
    //投资者信息
    mapping(address=>investorbalance) private InvestorsBalance;
    //所有投资者总投资金额
    uint256 public TotalInvestmentAmount;
    //投资者收益
    uint256 public InvestorsProfit;
    //最近投资分红时间
    uint256 public RecentDividendTime;
    //所有推荐者奖励
    uint256 private TotalReferralProfit;
    //最近一次购买彩票时间
    uint256 private LastBuyEggTime;
    //所有用户信息
    mapping(address=>userinfo) private Usersinfo;
    // 所有推荐者信息
    mapping(address=>address) private referrals;
    //所有中奖记录
    Winninginfo[] private WinningRecord;
    constructor(){
        DevAddress=msg.sender;
        RecentDividendTime=block.timestamp;
        LastBuyEggTime=block.timestamp;
    }
    function SafeMathadd(uint256 a,uint256 b) internal pure returns(uint256){
        uint256 c=a+b;
        assert(c>=a);
        return c;
    }
    function SafeMathsub(uint256 a,uint256 b) internal pure returns(uint256){
        assert (b<=a);
        return a-b;
    }
    function SafeMathmul(uint256 a,uint256 b) internal pure returns(uint256){
        if(a==0){
            return 0;
        }
        uint256 c=a*b;
        assert(c/a==b);
        return c;
    }
    function SafeMathdiv(uint256 a,uint256 b) internal pure returns(uint256){
        assert(b>0);
        uint256 c=a/b;
        return c;
    }
    //购买彩票
    function BuyEggs(uint16 LotCount,uint8 mul,uint232 Lucknum,address ref) external payable{
        require(msg.value>=PerEggPrice,"Buy at least one egg");
        require(mul>=1 && mul<=100,"Multiples between 1 and 100");
        require(LotCount>=1 && LotCount<=1000,"Number of eggs between 1 and 1000");
        uint256 AllLotteryCount=SafeMathdiv(msg.value,PerEggPrice);
        require(AllLotteryCount==LotCount*mul,"invalid data");
        for(uint256 i=0;i<LotCount;i++){
            Egginfo memory egginfo=Egginfo(keccak256(abi.encodePacked(block.timestamp,block.coinbase,msg.sender,Lucknum++)),mul,uint248(block.number));
            Usersinfo[msg.sender].eggsinfo.push(egginfo);
        }
        if(!Usersinfo[msg.sender].actived) Usersinfo[msg.sender].actived=true;
        uint256 profit=SafeMathdiv(SafeMathmul(msg.value,3),100);
        uint256 Refprofit=SafeMathdiv(SafeMathmul(msg.value,4),100);
        //给开发者加上百分3
        DevProfit+=profit;
        //给投资者加上百分3
        InvestorsProfit+=profit;
        if(referrals[msg.sender]==address(0)){
            //判断传过来的地址是不是有效的
            if(ref==msg.sender||ref==address(0)||!Usersinfo[msg.sender].actived){
                ref=DevAddress;
            }
            referrals[msg.sender]=ref;
        }
        if(referrals[msg.sender]==DevAddress){
            DevProfit+=Refprofit;
        }else{
            Usersinfo[referrals[msg.sender]].ReferralProfit+=Refprofit;
            TotalReferralProfit+=Refprofit;
        }
        LastBuyEggTime=block.timestamp;
    }
    //根据开奖号码计算中奖等级
    function GetWinninggrade(uint32 LotteryNum) private pure returns(uint256){
        if(LotteryNum>=67108864) return 0;
        if(LotteryNum>=16777216) return 10;
        if(LotteryNum>=4194304) return 9;
        if(LotteryNum>=1048576) return 8;
        if(LotteryNum>=262144) return 7;
        if(LotteryNum>=65536) return 6;
        if(LotteryNum>=16384) return 5;
        if(LotteryNum>=4096) return 4;
        if(LotteryNum>=1024) return 3;
        if(LotteryNum>=256) {
            return 2;}
        else{
            return 1;
        }
    }
    //根据中奖等级计算获奖倍数
    function GetWinningmultiple(uint256 winninggrade) private pure returns(uint256){
        if(winninggrade==0) return 0;
        if(winninggrade==10) return 5;
        if(winninggrade==9) return 20;
        if(winninggrade==8) return 80;
        if(winninggrade==7) return 320;
        if(winninggrade==6) return 1200;
        if(winninggrade==5) return 4800;
        if(winninggrade==4) return 20000;
        if(winninggrade==3) return 100000;
        if(winninggrade==2) return 500000;
        if(winninggrade==1) return 2000000;
        return 0;
    }
    //彩票开奖
    function OpenEggs() external{
        //判断有没有未开奖彩票
        require(Usersinfo[msg.sender].eggsinfo.length>0,"You don't have undraw lottery tickets");
        //判断区块号
        require(block.number>Usersinfo[msg.sender].eggsinfo[Usersinfo[msg.sender].eggsinfo.length-1].blocknumber,"It's not time");
        //判断是否有历史开奖号码
        if(Usersinfo[msg.sender].openedeggs.length>0) delete Usersinfo[msg.sender].openedeggs;
        uint256 WinningAmount;
        for(uint256 i=0;i<Usersinfo[msg.sender].eggsinfo.length;i++){
            //判断是否失效
            if(uint256(blockhash(Usersinfo[msg.sender].eggsinfo[i].blocknumber))==0) continue;
            uint32 LotteryNum=uint32(bytes4(keccak256(abi.encodePacked(Usersinfo[msg.sender].eggsinfo[i].uid,blockhash(Usersinfo[msg.sender].eggsinfo[i].blocknumber)))));
            uint256 Winninggrade=GetWinninggrade(LotteryNum);
            if(Winninggrade>0){
                uint256 WinningMoney=GetWinningmultiple(Winninggrade)*Usersinfo[msg.sender].eggsinfo[i].mul*PerEggPrice;
                WinningAmount+=WinningMoney;
                Winninginfo memory winning=Winninginfo(LotteryNum,Usersinfo[msg.sender].eggsinfo[i].mul,uint40(block.timestamp),msg.sender);
                WinningRecord.push(winning);
            }
            OpenedLotInfo memory OpenedLotterys=OpenedLotInfo(LotteryNum,Usersinfo[msg.sender].eggsinfo[i].mul);
            Usersinfo[msg.sender].openedeggs.push(OpenedLotterys);
        }
        delete Usersinfo[msg.sender].eggsinfo;
        //每次中奖金额不能超过总奖池的百分70
        if(WinningAmount>0){
            uint256 MaxWinningAmount=SafeMathdiv(SafeMathmul(SafeMathsub(address(this).balance,InvestorsProfit+TotalReferralProfit+DevProfit),70),100);
            if(WinningAmount>MaxWinningAmount) WinningAmount=MaxWinningAmount;
            uint256 profit=SafeMathdiv(SafeMathmul(WinningAmount,5),100);
            InvestorsProfit+=profit;
            DevProfit+=profit;
            payable(msg.sender).transfer(WinningAmount-profit*2);
        }
    }
    //投资者投资
    function InvestmentDeposit() external payable{
        //判断投资金额是否符合要求
        require(msg.value>=Mininum_investment_amount && msg.value<=Maxinum_investment_amount," Investment amount between 1 and 1000");
        //判断奖池的金额
        require(SafeMathsub(address(this).balance,InvestorsProfit+TotalReferralProfit+DevProfit)<=Maxinum_Investment_pool);
        //累加总投资金额
        TotalInvestmentAmount+=msg.value;
        //累加该投资者投资金额
        InvestorsBalance[msg.sender].balance+=msg.value;
        InvestorsBalance[msg.sender].LastInvestTime=block.timestamp;
        //判断投资者是否第一次投资
        if(!InvestorsBalance[msg.sender].HasInvested){
            InvestorsBalance[msg.sender].HasInvested=true;
            investors.push(msg.sender);
        }
    }
    //投资者退出投资
    function InvestmentWithdrawal(uint256 WithdrawalAmount) external{
        //判断取款金额是否大于最小投资金额
        require(WithdrawalAmount>=Mininum_investment_amount,"you must withdraw more than 1 bnb");
        //判断余额是否足够
        require(WithdrawalAmount<=InvestorsBalance[msg.sender].balance,"Exceed you investment balance");
        //判断投资时间是否足够了
        require(block.timestamp>=InvestorsBalance[msg.sender].LastInvestTime+1 weeks,"At least one week from the lasted investment");
        //判断奖池金额是否足够
        require(SafeMathsub(address(this).balance,InvestorsProfit+TotalReferralProfit+DevProfit)>=WithdrawalAmount,"Insufficient balance of prize pool");
        InvestorsBalance[msg.sender].balance-=WithdrawalAmount;
        TotalInvestmentAmount-=WithdrawalAmount;
        payable(msg.sender).transfer(WithdrawalAmount);
    }
    //投资者分红函数
    function DistributeInvestementIncome() external{
        //判断分红者有没有资格发起
        require(InvestorsBalance[msg.sender].balance>=Mininum_investment_amount|| msg.sender==DevAddress,"you must be a investor");
        uint256 Tmpinvestorsprofit=InvestorsProfit;
        uint256 developeraward=0;
        uint256 prizepool= SafeMathsub(address(this).balance,InvestorsProfit+TotalReferralProfit+DevProfit);
        if(prizepool>=Maxinum_Investment_pool){
            Tmpinvestorsprofit+=prizepool/200;
            developeraward+=prizepool/200;
        }
        InvestorsProfit=0;
        for(uint256 i=0;i<investors.length;i++){
            if(InvestorsBalance[investors[i]].balance>=Mininum_investment_amount){
                uint256 thisinvestorprofit=SafeMathdiv(SafeMathmul(InvestorsBalance[investors[i]].balance,Tmpinvestorsprofit),TotalInvestmentAmount);
                payable(investors[i]).transfer(thisinvestorprofit);
            }
        }
        if(developeraward>0){
            payable(DevAddress).transfer(developeraward);
        }
    }
    //提取推荐奖励
    function WithdrawReferralProfit() external{
        //判断推荐奖励是否足够
        require(Usersinfo[msg.sender].ReferralProfit>=0.01 ether,"Your referral profit is at least 0.01BNB");
        uint256 profit=Usersinfo[msg.sender].ReferralProfit;
        Usersinfo[msg.sender].ReferralProfit=0;
        TotalReferralProfit-=profit;
        payable(msg.sender).transfer(profit);
    }
    //提取开发者奖励
    function DeveloperWithdrawal() external{
        require(msg.sender==DevAddress,"You are not developer");
        uint256 devprofit=DevProfit;
        DevProfit=0;
        payable(DevAddress).transfer(devprofit);
    }
    //查询中奖记录
    function GetWinningRecord(uint256 RecordCount) public view returns(Winninginfo[] memory){
        uint256 RecordCt=RecordCount;
        uint256 WinningRecordLen=WinningRecord.length;
        if(RecordCt>WinningRecordLen) RecordCt=WinningRecordLen;
        Winninginfo[] memory LatelyWinnersRecord=new Winninginfo[](RecordCt);
        for(uint256 i=0;i<RecordCt;i++){
            LatelyWinnersRecord[i]=WinningRecord[WinningRecordLen-1-i];
        }
        return LatelyWinnersRecord;
    }
    //查询自己最近开奖记录
    function GetLatestLottery() public view returns(OpenedLotInfo[] memory){
        return Usersinfo[msg.sender].openedeggs;
    }
    //查询投资余额
    function GetInvestmentBalance(address addr) public view returns(uint256){
        return InvestorsBalance[addr].balance;
    }
    //合约销毁
    function DestructContract() external{
        require(msg.sender==DevAddress);
        require(block.timestamp>=LastBuyEggTime+15 days);
        if(address(this).balance>=TotalInvestmentAmount){
            for(uint256 i=0;i<investors.length;i++){
                if(InvestorsBalance[investors[i]].balance>=Mininum_investment_amount){
                    payable(investors[i]).transfer(InvestorsBalance[investors[i]].balance);
                }
            }
        }else{
            uint256 contractBalance=address(this).balance;
            if(contractBalance>=Mininum_investment_amount){
                for(uint256 i=0;i<investors.length;i++){
                    if(InvestorsBalance[investors[i]].balance>=Mininum_investment_amount){
                        payable(investors[i]).transfer(InvestorsBalance[investors[i]].balance*contractBalance/TotalInvestmentAmount);
                    }
                }
            }
        }
        payable(DevAddress).transfer(address(this).balance);
    }
}