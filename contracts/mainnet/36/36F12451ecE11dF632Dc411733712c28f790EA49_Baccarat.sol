/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
contract Baccarat {
    address private  DevAddress;
    baccarat public BaccaratRoom1;
    baccarat public BaccaratRoom2;
    baccarat public BaccaratRoom3;
    uint256 private   PublicPrizePool;
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
        uint48 StopBlockNumber; 
        uint48 BlockNumber; 
    }
    struct Gambler{
        BacBetInfo[] bacBetInfo;
        BacResult[] betResult;
        uint48 BankerBlock;
    }
    struct BacResult{
        uint48 BetNum;
        uint48 BankerNum;
        uint48 PlayerNum;
        uint48 BacNum;
        uint48 blockNumber;
        uint128 WinAmount;
        uint128 BetAmount;
    }
    struct BacBetInfo{
        address Banker;
        uint48 BetNum;
        uint48 blockNumber;
        uint128 betAmount;
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
                    betResult.BetNum=Bac.Gamblers[gambler].bacBetInfo[j].BetNum;
                    betResult.BankerNum=uint48(bytes6(RandomNum))%13+2;
                    betResult.PlayerNum=uint48(uint256(RandomNum))%13+2;
                    if(uint256(blockhash(Bac.Gamblers[gambler].bacBetInfo[j].blockNumber))==0){
                        betResult.BacNum=100;//Timeout does not open judge you to lose
                    } 
                    else{
                        if(betResult.BankerNum>betResult.PlayerNum){
                            betResult.BacNum=0;
                        }else if(betResult.BankerNum<betResult.PlayerNum){
                            betResult.BacNum=1;
                        }else{
                            betResult.BacNum=2;
                        }
                    } 
                    betResult.BetAmount=thisBetAmount;    
                    betResult.blockNumber=Bac.Gamblers[gambler].bacBetInfo[j].blockNumber;    
                    uint256 ThisWinAmount;
                    if(Bac.Gamblers[gambler].bacBetInfo[j].BetNum==betResult.BacNum){        
                        if(betResult.BacNum==0){
                            ThisWinAmount=thisBetAmount+SafeMathmul(thisBetAmount,95)/100; 
                        }                  
                        else if(betResult.BacNum==1){ 
                            ThisWinAmount= thisBetAmount*2;              
                        }else{
                            ThisWinAmount=thisBetAmount*12;
                        }
                    }else if(betResult.BacNum==2){
                        ThisWinAmount=thisBetAmount;
                        WinAmount+=ThisWinAmount;
                    }
                    if(ThisWinAmount!=thisBetAmount){
                        if(Bac.Gamblers[gambler].bacBetInfo[j].Banker!=address(0)){
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
                    betResult.WinAmount=uint128(ThisWinAmount);    
                    Bac.Gamblers[gambler].betResult.push(betResult);              
                }
                delete Bac.Gamblers[gambler].bacBetInfo;
                if(WinAmount>0){
                    payable(gambler).transfer(WinAmount);
                }
                if(referProfit>0){
                    address referral=referrals[gambler].referral;
                    if(referral==DevAddress){
                        devfee+=referProfit;
                    }else{
                        referrals[referral].ReferralProfit+=referProfit;
                    }
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
    function BacBet(uint48 BetNum,uint256 BacSort,address ref) external payable{
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
            uint256 MaximumLost=RmBetAmount+TieBetAmt*12;
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
        BacBetInfo memory bacBetInfo = BacBetInfo(Banker,BetNum,uint48(block.number),BetAmount);
        Bac.Gamblers[msg.sender].bacBetInfo.push(bacBetInfo);
    }
    function BacSettleBet(uint256 BacSort) external{
        baccarat storage Bac=GetBacSort(BacSort);
        uint256 BetCount=Bac.Gamblers[msg.sender].bacBetInfo.length;
        require(BetCount>0,"You didn't bet");
        require(block.number>Bac.Gamblers[msg.sender].bacBetInfo[BetCount-1].blockNumber,"It's not time");
        uint256 devfee;
        uint256 referProfit;
        uint256 WinAmount;
        if (Bac.Gamblers[msg.sender].betResult.length>0) delete Bac.Gamblers[msg.sender].betResult;
        for(uint256 i=0;i<Bac.Gamblers[msg.sender].bacBetInfo.length;i++){
            uint48 BetNum=Bac.Gamblers[msg.sender].bacBetInfo[i].BetNum;
            bytes32 BetBlockHash=blockhash(Bac.Gamblers[msg.sender].bacBetInfo[i].blockNumber);
            bytes32 RandomNum=keccak256(abi.encodePacked(BacSort,BetBlockHash));
            uint128 thisBetAmount=Bac.Gamblers[msg.sender].bacBetInfo[i].betAmount;          
            BacResult memory betResult;
            betResult.BetNum=BetNum;
            betResult.BankerNum=uint48(bytes6(RandomNum))%13+2;
            betResult.PlayerNum=uint48(uint256(RandomNum))%13+2;
            if(uint256(BetBlockHash)==0){
                betResult.BacNum=100;//Timeout does not open judge you to lose
            } 
            else{
                if(betResult.BankerNum>betResult.PlayerNum){
                    betResult.BacNum=0;
                }else if(betResult.BankerNum<betResult.PlayerNum){
                     betResult.BacNum=1;
                }
                else{
                    betResult.BacNum=2;
                }
            }
            betResult.BetAmount=thisBetAmount;
            betResult.blockNumber=Bac.Gamblers[msg.sender].bacBetInfo[i].blockNumber;
            uint256 ThisWinAmount;
            if(BetNum==betResult.BacNum){  
                if(BetNum==0){ 
                    ThisWinAmount=thisBetAmount+SafeMathmul(thisBetAmount,95)/100; 
                }    
                else if(BetNum==1){ 
                    ThisWinAmount= thisBetAmount*2;           
                }else{
                    ThisWinAmount=thisBetAmount*12;
                }
            }else if(betResult.BacNum==2){
                ThisWinAmount= thisBetAmount;
                WinAmount+=ThisWinAmount;
            }
            if(Bac.Gamblers[msg.sender].bacBetInfo[i].Banker!=address(0)){
                if(BetNum<=1){
                    Bac.BacPublic.BetAmount-=thisBetAmount;
                }else{
                    Bac.BacPublic.TieBetAmount-=thisBetAmount;
                }
                if(ThisWinAmount!=thisBetAmount){
                    uint256 PrizePool=Bac.BacPublic.PrizePool+thisBetAmount;
                    if(ThisWinAmount>0){
                        referProfit+=SafeMathmul(ThisWinAmount,2)/100;
                        devfee+=SafeMathmul(ThisWinAmount,3)/100;
                        WinAmount+=SafeMathmul(ThisWinAmount,95)/100;
                        PrizePool-=ThisWinAmount;
                    }
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
                }
            }else if(ThisWinAmount!=thisBetAmount){
                uint256 PrizePool=PublicPrizePool+thisBetAmount;
                if(ThisWinAmount>0){
                    if(ThisWinAmount>PrizePool){
                        ThisWinAmount=PrizePool;
                    }
                    referProfit+=SafeMathmul(ThisWinAmount,2)/100;
                    devfee+=SafeMathmul(ThisWinAmount,3)/100;
                    WinAmount+=SafeMathmul(ThisWinAmount,95)/100;  
                    PrizePool-=ThisWinAmount;             
                }
                PublicPrizePool=PrizePool;
            }
            betResult.WinAmount=uint128(ThisWinAmount);
            Bac.Gamblers[msg.sender].betResult.push(betResult);
        }
        delete Bac.Gamblers[msg.sender].bacBetInfo;
        if(WinAmount>0){
            payable(msg.sender).transfer(WinAmount);
        }
        if(devfee>0){
            address referral=referrals[msg.sender].referral;
            if(referral==DevAddress){
                devfee+=referProfit;
            }else{
                referrals[referral].ReferralProfit+=referProfit;
            }
            payable(DevAddress).transfer(devfee);
        }
    }
    function DepositPubPrizePool() external  payable{
        require(msg.value>=0.01 ether);
        PublicPrizePool+=msg.value;
    } 
    function WithdrawPubPrizePool(uint256 WithdrawAmount) external {
        require(msg.sender==DevAddress);
        require(WithdrawAmount<=PublicPrizePool);
        PublicPrizePool-=WithdrawAmount;
        payable(DevAddress).transfer(WithdrawAmount);
    }
    function GetBankerInfo(uint256 BacSort) public view returns (baccaratPub memory){
        baccarat storage Bac=GetBacSort(BacSort);
        return Bac.BacPublic;
    }
    //get public information
    function GetPublicInformation() public view returns(baccaratPub memory,baccaratPub memory,baccaratPub memory,uint256,bytes32,uint256){
        return(BaccaratRoom1.BacPublic,BaccaratRoom2.BacPublic,BaccaratRoom3.BacPublic,block.number,blockhash(block.number-1),PublicPrizePool);
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