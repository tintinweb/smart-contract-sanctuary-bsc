/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
contract Baccarat {
    address private  DevAddress;
    baccarat public BaccaratRoom1;
    baccarat public BaccaratRoom2;
    baccarat public BaccaratRoom3;
    uint256 private constant TieOdds=12;
    uint256 private PublicPrizePool;
    mapping (address => ReferralInfo) private referrals;
    struct ReferralInfo{
       address referral;
       uint256 ReferralProfit;
    }
    struct baccarat{
        uint128 MinBankerAmount;
        uint128 MinBetAmount;
        uint128 MaxBetAmount;
        baccaratPub BacPublic;
        address[] GamblersAddress;
        mapping(address => Gambler) Gamblers;
    }
    struct baccaratPub{
        uint256 PrizePool;
        uint128 BetAmount; 
        uint128 TieBetAmount; 
        address Banker;
        uint32 StopBlockNumber; 
        uint32 BlockNumber; 
    }
    struct Gambler{
        BacBetInfo[] bacBetInfo;
        BacResult[] betResult;
        uint32 BankerBlock;
    }
    struct BacResult{
        uint48 BankerNum;
        uint48 PlayNum;
        uint48 BacNum;
        uint128 BetAmount;
    }
    struct BacBetInfo{
        address Banker;
        uint96 BetNum;
        uint128 betAmount;
        uint128 blockNumber;
    }
    constructor() {  
        DevAddress =msg.sender; 
        BaccaratRoom1.MinBankerAmount=1 ether;
        BaccaratRoom1.MinBetAmount=0.02 ether;
        BaccaratRoom1.MaxBetAmount=1 ether;

        BaccaratRoom2.MinBankerAmount=1 ether;
        BaccaratRoom2.MinBetAmount=0.02 ether;
        BaccaratRoom2.MaxBetAmount=1 ether;

        BaccaratRoom3.MinBankerAmount=1 ether;
        BaccaratRoom3.MinBetAmount=0.02 ether;
        BaccaratRoom3.MaxBetAmount=1 ether;
    }
    function GetBacSort(uint256 BacSort) private view returns(baccarat storage){
        require(BacSort<=2);
        if(BacSort==0){
           return BaccaratRoom1;
        }else if(BacSort==1){
           return BaccaratRoom2;      
        }else if(BacSort==2){
           return BaccaratRoom3;
        }else{
            return BaccaratRoom3;
        }
    }
    //be a Banker 
    function BacBeBanker(uint256 BacSort) external  payable {
        baccarat storage Bac=GetBacSort(BacSort);
        require(msg.value>=Bac.MinBankerAmount,"Below minimum");
        require(Bac.BacPublic.Banker==address(0),"Someone is already a Banker");
        Bac.BacPublic.Banker=msg.sender;
        Bac.BacPublic.StopBlockNumber=0;
        Bac.BacPublic.PrizePool=uint128(msg.value);
        Bac.BacPublic.BetAmount=0;
        Bac.BacPublic.BlockNumber=uint32(block.number);
        if(Bac.GamblersAddress.length>0) delete Bac.GamblersAddress;
    }
    function BatchSette(bool IsForce,baccarat storage Bac,uint256 BacSort) private {
        uint256 devfee;
        uint256 PrizePool=Bac.BacPublic.PrizePool;
        uint256 PubPrizePool=PublicPrizePool;
        Bac.BacPublic.PrizePool=0;
        for (uint256 i=0;i<Bac.GamblersAddress.length;i++){
            address gambler=Bac.GamblersAddress[i];
            if (Bac.Gamblers[gambler].bacBetInfo.length>0){
                delete Bac.Gamblers[gambler].betResult;
                uint256 WinAmount;
                uint256 referProfit;
                for(uint256 j=0;j<Bac.Gamblers[gambler].bacBetInfo.length;j++){
                    bytes32 RandomNum=keccak256(abi.encodePacked(BacSort,blockhash(Bac.Gamblers[gambler].bacBetInfo[j].blockNumber)));
                    uint128 thisBetAmount=Bac.Gamblers[gambler].bacBetInfo[j].betAmount;
                    BacResult memory betResult;
                    betResult.BankerNum=uint48(bytes6(RandomNum))%13+1;
                    betResult.PlayNum=uint48(uint256(RandomNum))%13+1;
                    if(uint256(blockhash(Bac.Gamblers[gambler].bacBetInfo[j].blockNumber))==0){
                        betResult.BacNum=100;//Timeout does not open judge you to lose
                    } 
                    else{
                        if(betResult.BankerNum>betResult.PlayNum){
                            betResult.BacNum=0;
                        }else if(betResult.BankerNum<betResult.PlayNum){
                            betResult.BacNum=1;
                        }else{
                            betResult.BacNum=2;
                        }
                    } 
                    betResult.BetAmount=thisBetAmount;                 
                    Bac.Gamblers[gambler].betResult.push(betResult);
                    uint256 ThisWinAmount;
                    if(Bac.Gamblers[gambler].bacBetInfo[j].BetNum==betResult.BacNum){                          
                        if(betResult.BacNum<=1){ 
                            ThisWinAmount= thisBetAmount*2;              
                        }else{
                            ThisWinAmount=thisBetAmount*TieOdds;
                        }
                    }
                    if(Bac.Gamblers[gambler].bacBetInfo[j].Banker==Bac.BacPublic.Banker){
                        PrizePool+=thisBetAmount;   
                        if(ThisWinAmount>0){  
                            PrizePool-=ThisWinAmount;
                            referProfit+=SafeMathmul(ThisWinAmount,2)/100;
                            devfee+=SafeMathmul(ThisWinAmount,3)/100;
                            WinAmount=SafeMathmul(ThisWinAmount,95)/100;
                        }
                    }else{
                        PubPrizePool+=thisBetAmount;
                        if(ThisWinAmount>0){
                            if(ThisWinAmount>PubPrizePool) {
                                ThisWinAmount=PubPrizePool;
                            }         
                            PubPrizePool-=ThisWinAmount;
                            referProfit+=SafeMathmul(ThisWinAmount,2)/100;
                            devfee+=SafeMathmul(ThisWinAmount,3)/100;
                            WinAmount=SafeMathmul(ThisWinAmount,95)/100;
                        }
                    }                  
                }
                delete Bac.Gamblers[gambler].bacBetInfo;
                if(WinAmount>0){
                    payable(gambler).transfer(WinAmount);
                }
                address referral=referrals[gambler].referral;
                if(referral==DevAddress){
                    devfee+=referProfit;
                }else{
                    referrals[referral].ReferralProfit+=referProfit;
                }
            }
        }
        delete Bac.GamblersAddress;
        if(devfee>0){
            payable(DevAddress).transfer(devfee);
        } 
        if(PubPrizePool!=PublicPrizePool){
            PublicPrizePool=PubPrizePool;
        }
        if(PrizePool>0){    
            if(IsForce)
            {
                payable(msg.sender).transfer(SafeMathmul(PrizePool,3)/100);
                payable(Bac.BacPublic.Banker).transfer(SafeMathmul(PrizePool,97)/100);
            }else{
                payable(Bac.BacPublic.Banker).transfer(PrizePool);
            }         

        }
        Bac.BacPublic.Banker=address(0);
    }
    function WithdrawReferralProfit() external {
        require(referrals[msg.sender].ReferralProfit>=0.01 ether,"At least 0.01BNB");
        uint256 profit=referrals[msg.sender].ReferralProfit;
        referrals[msg.sender].ReferralProfit=0;
        payable(msg.sender).transfer(profit);
    }
    //If the dealer stops betting and doesn't come down, anyone can kick it down,5% will be deducted if kicked down
    function ForcedDownBanker(uint256 BacSort) external{
        baccarat storage Bac=GetBacSort(BacSort);
        require(Bac.BacPublic.Banker!=address(0)&&Bac.BacPublic.StopBlockNumber>0,"There is no banker going down");
        require(block.number>Bac.BacPublic.StopBlockNumber+10,"Wait to stop betting");
        BatchSette(true,Bac,BacSort);
    }
    function  BacStopBeBanker(uint256 BacSort) external{
        baccarat storage Bac=GetBacSort(BacSort);
        require(Bac.BacPublic.Banker==msg.sender||msg.sender==DevAddress,"You are not a Banker");
        if(Bac.BacPublic.BetAmount==0 && Bac.BacPublic.TieBetAmount==0){
            uint256 Bacprizepool=Bac.BacPublic.PrizePool;
            Bac.BacPublic.PrizePool=0;
            if(Bacprizepool>0){
                payable(Bac.BacPublic.Banker).transfer(Bacprizepool);
            }
            Bac.BacPublic.Banker=address(0);
        }
        else if(Bac.BacPublic.StopBlockNumber==0){
            Bac.BacPublic.StopBlockNumber=uint32(block.number);
        }
        else{
            require(block.number>Bac.BacPublic.StopBlockNumber+1,"Wait to stop betting");
            BatchSette(false,Bac,BacSort);
        }
    }
    function BacBet(uint96 BetNum,uint256 BacSort,address ref) external payable{
        baccarat storage Bac=GetBacSort(BacSort);
        require(BetNum<=2,"Illegal bet");
        require(msg.value>= Bac.MinBetAmount &&msg.value<=Bac.MaxBetAmount,"Amount not in range");
        address Banker;
        uint128 BetAmount=uint128(msg.value);
        if(Bac.BacPublic.Banker!=address(0) && Bac.BacPublic.StopBlockNumber==0){
            Banker=Bac.BacPublic.Banker;
            uint256 RmBetAmount=Bac.BacPublic.BetAmount;
            uint256 TieBetAmt=Bac.BacPublic.TieBetAmount;
            if(BetNum<=1){
                RmBetAmount+=msg.value;
            }else{
                TieBetAmt+=msg.value;
            }
            uint256 MaximumLost=RmBetAmount+TieBetAmt*TieOdds;
            require(MaximumLost<=Bac.BacPublic.PrizePool,"Insufficient balance of the banker");
            if(Bac.Gamblers[msg.sender].BankerBlock!=Bac.BacPublic.BlockNumber){
                Bac.GamblersAddress.push(msg.sender);
                Bac.Gamblers[msg.sender].BankerBlock=Bac.BacPublic.BlockNumber;
            }
            if(BetNum<=1){
                Bac.BacPublic.BetAmount+=BetAmount;
            }else{
                Bac.BacPublic.TieBetAmount+=BetAmount;
            }
        }
        if(referrals[msg.sender].referral == address(0)) {
            if(ref == msg.sender || ref == address(0) ) {
                ref = DevAddress;
            }
            referrals[msg.sender].referral = ref;
        }
        BacBetInfo memory bacBetInfo = BacBetInfo(Banker,BetNum,BetAmount,uint128(block.number));
        Bac.Gamblers[msg.sender].bacBetInfo.push(bacBetInfo);
    }
    function BacSettleBet(uint256 BacSort) external{
        baccarat storage Bac=GetBacSort(BacSort);
        uint256 BetCount=Bac.Gamblers[msg.sender].bacBetInfo.length;
        require(BetCount>0,"You didn't bet");
        require(block.number>Bac.Gamblers[msg.sender].bacBetInfo[BetCount-1].blockNumber,"It's not time");
        uint256 devfee;
        uint256 referProfit;
        if (Bac.Gamblers[msg.sender].betResult.length>0) delete Bac.Gamblers[msg.sender].betResult;
        for(uint256 i=0;i<Bac.Gamblers[msg.sender].bacBetInfo.length;i++){
            uint256 BetNum=Bac.Gamblers[msg.sender].bacBetInfo[i].BetNum;
            bytes32 BetBlockHash=blockhash(Bac.Gamblers[msg.sender].bacBetInfo[i].blockNumber);
            bytes32 RandomNum=keccak256(abi.encodePacked(BacSort,BetBlockHash));
            uint128 thisBetAmount=Bac.Gamblers[msg.sender].bacBetInfo[i].betAmount;          
            BacResult memory betResult;
            betResult.BankerNum=uint48(bytes6(RandomNum))%13+1;
            betResult.PlayNum=uint48(uint256(RandomNum))%13+1;
            if(uint256(BetBlockHash)==0){
                betResult.BacNum=100;//Timeout does not open judge you to lose
            } 
            else{
                if(betResult.BankerNum>betResult.PlayNum){
                    betResult.BacNum=0;
                }else if(betResult.BankerNum<betResult.PlayNum){
                     betResult.BacNum=1;
                }else{
                    betResult.BacNum=2;
                }
            }
            betResult.BetAmount=thisBetAmount;
            Bac.Gamblers[msg.sender].betResult.push(betResult);
            bool HaveBanker=Bac.Gamblers[msg.sender].bacBetInfo[i].Banker==Bac.BacPublic.Banker;
            uint256 PrizePool;
            if(HaveBanker){
                PrizePool=Bac.BacPublic.PrizePool;
                if(BetNum<=1){
                    Bac.BacPublic.BetAmount-=thisBetAmount;
                }else{
                    Bac.BacPublic.TieBetAmount-=thisBetAmount;
                }
            }else{
                PrizePool=PublicPrizePool;
            }
            if(BetNum==betResult.BacNum){  
                PrizePool+=thisBetAmount;
                uint256 ThisWinAmount;
                if(BetNum<=1){ 
                    ThisWinAmount= thisBetAmount*2;              
                    if(ThisWinAmount>PrizePool) {
                        ThisWinAmount=PrizePool;
                    }
                    PrizePool-=ThisWinAmount;
                }else{
                    ThisWinAmount=thisBetAmount*TieOdds;
                    if(ThisWinAmount>PrizePool) {
                        ThisWinAmount=PrizePool;
                    }
                    PrizePool-=ThisWinAmount;
                }
                referProfit+=SafeMathmul(ThisWinAmount,2)/100;
                devfee+=SafeMathmul(ThisWinAmount,3)/100;
                uint256 WinAmount=SafeMathmul(ThisWinAmount,95)/100;
                payable(msg.sender).transfer(WinAmount);
            }
            else{
                PrizePool+=thisBetAmount;
            }
            if(HaveBanker){
                if(PrizePool<Bac.MinBetAmount){
                    Bac.BacPublic.PrizePool=0;
                    delete Bac.GamblersAddress;
                    if(PrizePool>0) {
                        payable(Bac.BacPublic.Banker).transfer(PrizePool);
                    }           
                    Bac.BacPublic.Banker=address(0);
                }else{
                    Bac.BacPublic.PrizePool=PrizePool;
                }
            }else{
                PublicPrizePool=PrizePool;
            }
        }
        delete Bac.Gamblers[msg.sender].bacBetInfo;
        address referral=referrals[msg.sender].referral;
        if(referProfit>0){
            if(referral==DevAddress){
                devfee+=referProfit;
            }else{
                referrals[referral].ReferralProfit+=referProfit;
            }
            payable(DevAddress).transfer(devfee);
        }
    }
    function GetBankerInfo(uint256 BacSort) public view returns (baccaratPub memory){
        baccarat storage Bac=GetBacSort(BacSort);
        return Bac.BacPublic;
    }
    //get public information
    function GetPublicInformation() public view returns(baccaratPub memory,baccaratPub memory,baccaratPub memory,uint256){
        return(BaccaratRoom1.BacPublic,BaccaratRoom2.BacPublic,BaccaratRoom3.BacPublic,block.number);
    }
    //get privite information
    function GetPrivateInformation() public view returns(BacBetInfo[] memory,BacBetInfo[] memory,BacBetInfo[] memory,ReferralInfo memory){
        return(BaccaratRoom1.Gamblers[msg.sender].bacBetInfo,BaccaratRoom2.Gamblers[msg.sender].bacBetInfo,BaccaratRoom3.Gamblers[msg.sender].bacBetInfo,referrals[msg.sender]);
    }
        //Get the latest lottery information
    function GetLatestBetResult(uint256 BacSort) public view returns(BacResult[]  memory){
        baccarat storage Bac=GetBacSort(BacSort);
        return Bac.Gamblers[msg.sender].betResult;
    }
    function StopBacGame()  external  {
        require(msg.sender==DevAddress);
        require(BaccaratRoom1.BacPublic.Banker==address(0)&& BaccaratRoom2.BacPublic.Banker==address(0)&& BaccaratRoom3.BacPublic.Banker==address(0));
        selfdestruct(payable(DevAddress));
    }
    function SafeMathmul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
}