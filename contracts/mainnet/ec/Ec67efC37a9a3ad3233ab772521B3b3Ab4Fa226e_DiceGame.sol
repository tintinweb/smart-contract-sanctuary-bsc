/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
contract DiceGame {
    address private  DevAddress;
    Dice public PrimaryDice;
    Dice public JuniorDice;
    Dice public IntermediateDice;
    Dice public SeniorDice;
    Dice public SupremeDice;
    uint256 private   PublicPrizePool;
    mapping (address => ReferralInfo) private referrals;
    struct ReferralInfo{
       address referral;
       uint256 ReferralProfit;
    }
    struct Dice{
        uint128 MinBankerAmount;
        uint128 MinBetAmount;
        uint128 MaxBetAmount;
        DicePublic dicePublic;
        address[] GamblersAddress;
        mapping(address => Gambler) Gamblers;
    }
    struct DicePublic{
        uint128 PrizePool;
        uint128 BetAmount; 
        address Banker;
        uint32 StopBlockNumber; 
        uint32 BlockNumber; 
    }
    struct Gambler{
        DiceBetInfo[] diceBetInfo;
        BetResult[] betResult;
        uint32 BankerBlock;
    }
    struct BetResult{
        uint128 diceNum;
        uint128 BetAmount;
        uint256 WinAmount;
    }
    struct DiceBetInfo{
        address Banker;
        uint128 betAmount;
        uint128 blockNumber;
        bytes32 diceID;
    }
    constructor() {  
        DevAddress =msg.sender; 
        PrimaryDice.MinBankerAmount=1 ether;
        PrimaryDice.MinBetAmount=0.02 ether;
        PrimaryDice.MaxBetAmount=0.5 ether;
        JuniorDice.MinBankerAmount=5 ether;
        JuniorDice.MinBetAmount=0.02 ether;
        JuniorDice.MaxBetAmount=2.5 ether;
        IntermediateDice.MinBankerAmount=10 ether;
        IntermediateDice.MinBetAmount=0.1 ether;
        IntermediateDice.MaxBetAmount=5 ether;
        SeniorDice.MinBankerAmount=50 ether;
        SeniorDice.MinBetAmount=0.1 ether;
        SeniorDice.MaxBetAmount=25 ether;
        SupremeDice.MinBankerAmount=100 ether;
        SupremeDice.MinBetAmount=0.1 ether;
        SupremeDice.MaxBetAmount=50 ether;   
    }
    function GetDiceSort(uint256 DiceSort) private view returns(Dice storage){
        require(DiceSort<=4);
        if(DiceSort==0){
           return PrimaryDice;    
        }else if(DiceSort==1){
           return JuniorDice;
        }
        else if (DiceSort==2){
          return IntermediateDice;
        }
        else if (DiceSort==3){
           return SeniorDice;
        }else{
            return SupremeDice;
        }
    }
    //be a Banker 
    function DiceBeBanker(uint256 DiceSort) external  payable {
        Dice storage dice=GetDiceSort(DiceSort);
        require(msg.value>=dice.MinBankerAmount,"Below minimum");
        require(dice.dicePublic.Banker==address(0),"Someone is already a Banker");
        dice.dicePublic.Banker=msg.sender;
        dice.dicePublic.StopBlockNumber=0;
        dice.dicePublic.PrizePool=uint128(msg.value);
        dice.dicePublic.BetAmount=0;
        dice.dicePublic.BlockNumber=uint32(block.number);
        if(dice.GamblersAddress.length>0) delete dice.GamblersAddress;
    }
    function BatchSette(bool IsForce,Dice storage dice) private {
        uint256 devfee;
        uint256 PubPrizePool=PublicPrizePool;
        uint256 PrizePool=dice.dicePublic.PrizePool;
        dice.dicePublic.PrizePool=0;
        for (uint256 i=0;i<dice.GamblersAddress.length;i++){
            address gambler=dice.GamblersAddress[i];
            if (dice.Gamblers[gambler].diceBetInfo.length>0){
                delete dice.Gamblers[gambler].betResult;
                uint256 WinAmount;
                uint256 referProfit;
                for (uint256 j=0;j<dice.Gamblers[gambler].diceBetInfo.length;j++){
                    uint128 diceNum;
                    uint256 BetblockNumber=dice.Gamblers[gambler].diceBetInfo[j].blockNumber;
                    if(uint256(blockhash(BetblockNumber))==0){
                        diceNum=100;//Timeout does not open judge you to lose
                    } 
                    else{
                        diceNum=uint128(uint256(keccak256(abi.encodePacked(dice.Gamblers[gambler].diceBetInfo[j].diceID,blockhash(BetblockNumber))))%100+1);
                    }   
                    uint128 thisBetAmount=dice.Gamblers[gambler].diceBetInfo[j].betAmount;
                    uint256 thisWinAmount;
                    devfee+=SafeMathmul(thisBetAmount,2)/100;
                    referProfit += SafeMathmul(thisBetAmount,2)/100;
                    if(dice.Gamblers[gambler].diceBetInfo[j].Banker!=address(0)){
                        if(diceNum<=48){
                            thisWinAmount=thisBetAmount;
                            PrizePool-=thisWinAmount;    
                            WinAmount+=thisWinAmount+SafeMathmul(thisBetAmount,96)/100;
                        }
                        else{
                            PrizePool+=SafeMathmul(thisBetAmount,96)/100;
                        } 
                    }else{
                        if(diceNum<=48){
                            thisWinAmount=thisBetAmount;
                            if(thisWinAmount>PubPrizePool){
                                thisWinAmount=PubPrizePool;
                            }
                            PubPrizePool-=thisWinAmount;    
                            WinAmount+=thisWinAmount+SafeMathmul(thisBetAmount,96)/100;
                        }
                        else{
                            PubPrizePool+=SafeMathmul(thisBetAmount,96)/100;
                        }                     
                    }
                    BetResult memory betResult=BetResult(diceNum,thisBetAmount,thisWinAmount);
                    dice.Gamblers[gambler].betResult.push(betResult);                       
                }
                delete dice.Gamblers[gambler].diceBetInfo;
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
        delete dice.GamblersAddress;
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
                payable(dice.dicePublic.Banker).transfer(SafeMathmul(PrizePool,97)/100);
            }else{
                payable(dice.dicePublic.Banker).transfer(PrizePool);
            }         
        }
        dice.dicePublic.Banker=address(0);
    }
    function WithdrawReferralProfit() external {
        require(referrals[msg.sender].ReferralProfit>=0.01 ether,"At least 0.01BNB");
        uint256 profit=referrals[msg.sender].ReferralProfit;
        referrals[msg.sender].ReferralProfit=0;
        payable(msg.sender).transfer(profit);
    }
    //If the dealer stops betting and doesn't come down, anyone can kick it down,5% will be deducted if kicked down
    function ForcedDownBanker(uint256 DiceSort) external{
        Dice storage dice=GetDiceSort(DiceSort);
        require(dice.dicePublic.Banker!=address(0)&&dice.dicePublic.StopBlockNumber>0,"There is no banker going down");
        require(block.number>dice.dicePublic.StopBlockNumber+10,"Wait to stop betting");
        BatchSette(true,dice);
    }
    function  DiceStopBeBanker(uint256 DiceSort) external{
        Dice storage dice=GetDiceSort(DiceSort);
        require(dice.dicePublic.Banker==msg.sender||msg.sender==DevAddress,"You are not a Banker");
        if(dice.dicePublic.BetAmount==0){
            uint256 diceprizepool=dice.dicePublic.PrizePool;
            dice.dicePublic.PrizePool=0;
            if(diceprizepool>0){
                payable(dice.dicePublic.Banker).transfer(diceprizepool);
            }
            dice.dicePublic.Banker=address(0);
        }
        else if(dice.dicePublic.StopBlockNumber==0){
            dice.dicePublic.StopBlockNumber=uint32(block.number);
        }
        else{
            require(block.number>dice.dicePublic.StopBlockNumber+1,"Wait to stop betting");
            BatchSette(false,dice);
        }
    }
    function DiceBet(uint256 Lucknum,uint256 DiceSort,address ref) external payable{
        Dice storage dice=GetDiceSort(DiceSort);
        require(msg.value>= dice.MinBetAmount &&msg.value<=dice.MaxBetAmount,"Amount not in range");
        require(dice.dicePublic.StopBlockNumber==0,"The banker is going down");
        address Banker;
        if(dice.dicePublic.Banker!=address(0) && dice.dicePublic.StopBlockNumber==0){
            require(dice.dicePublic.BetAmount +msg.value<=dice.dicePublic.PrizePool,"Insufficient balance of the banker");
            Banker=dice.dicePublic.Banker;
            if(dice.Gamblers[msg.sender].BankerBlock!=dice.dicePublic.BlockNumber){
                dice.GamblersAddress.push(msg.sender);
                dice.Gamblers[msg.sender].BankerBlock=dice.dicePublic.BlockNumber;
            }
            dice.dicePublic.BetAmount+=uint128(msg.value);
        } 
        if(referrals[msg.sender].referral == address(0)) {
            if(ref == msg.sender || ref == address(0) ) {
                ref = DevAddress;
            }
            referrals[msg.sender].referral = ref;
        }
        DiceBetInfo memory diceBetInfo = DiceBetInfo(Banker,uint128(msg.value),uint128(block.number),keccak256(abi.encodePacked(block.coinbase,msg.sender,Lucknum)));
        dice.Gamblers[msg.sender].diceBetInfo.push(diceBetInfo);
    }
    function DiceSettleBet(uint256 DiceSort) external{
        Dice storage dice=GetDiceSort(DiceSort);
        require(dice.Gamblers[msg.sender].diceBetInfo.length>0,"You didn't bet");
        require(block.number>dice.Gamblers[msg.sender].diceBetInfo[dice.Gamblers[msg.sender].diceBetInfo.length-1].blockNumber,"It's not time");
        uint256 WinAmount;
        uint256 devfee;
        uint256 referProfit;
        uint128 BetAmount=dice.dicePublic.BetAmount;
        uint128 PrizePool=dice.dicePublic.PrizePool;
        uint256 PubPrizePool=PublicPrizePool; 
        if (dice.Gamblers[msg.sender].betResult.length>0) delete dice.Gamblers[msg.sender].betResult;
        for(uint256 i=0;i<dice.Gamblers[msg.sender].diceBetInfo.length;i++){
            uint128 diceNum;
            if(uint256(blockhash(dice.Gamblers[msg.sender].diceBetInfo[i].blockNumber))==0){
                diceNum=100;//Timeout does not open judge you to lose
            } 
            else{
                diceNum=uint128(uint256(keccak256(abi.encodePacked(dice.Gamblers[msg.sender].diceBetInfo[i].diceID,blockhash(dice.Gamblers[msg.sender].diceBetInfo[i].blockNumber))))%100+1);
            }
            uint128 thisBetAmount=dice.Gamblers[msg.sender].diceBetInfo[i].betAmount;  
            devfee+=SafeMathmul(thisBetAmount,2)/100;
            referProfit+=SafeMathmul(thisBetAmount,2)/100;
            uint256 thisWinAmount;
            if(dice.Gamblers[msg.sender].diceBetInfo[i].Banker!=address(0)){
                BetAmount-=thisBetAmount;
                if(diceNum<=48){          
                    thisWinAmount=thisBetAmount;    
                    PrizePool-=thisBetAmount;
                    WinAmount+=thisWinAmount+SafeMathmul(thisBetAmount,96)/100;
                }
                else{
                    PrizePool+=uint128(SafeMathmul(thisBetAmount,96)/100);
                }
            }else{
                if(diceNum<=48){
                    thisWinAmount= thisBetAmount;    
                    if(thisWinAmount>PubPrizePool){
                        thisWinAmount=PubPrizePool;
                    }    
                    PubPrizePool-=thisWinAmount;
                    WinAmount+=thisWinAmount+SafeMathmul(thisBetAmount,96)/100;
                }
                else{ 
                    PubPrizePool+=SafeMathmul(thisBetAmount,96)/100;
                }              
            }       
            BetResult memory betResult=BetResult(diceNum,thisBetAmount,thisWinAmount);
            dice.Gamblers[msg.sender].betResult.push(betResult);         
        }
        delete dice.Gamblers[msg.sender].diceBetInfo;
        address referral=referrals[msg.sender].referral;
        if(referral==DevAddress){
            devfee+=referProfit;
        }else{
            referrals[referral].ReferralProfit+=referProfit;
        }
        payable(DevAddress).transfer(devfee);
        if(WinAmount>0){
            payable(msg.sender).transfer(WinAmount);
        }
        if(PublicPrizePool!=PubPrizePool){
            PublicPrizePool=PubPrizePool;
        }
        if(dice.dicePublic.Banker!=address(0)){
            if(PrizePool<dice.MinBetAmount){
                dice.dicePublic.PrizePool=0;
                delete dice.GamblersAddress;
                if(PrizePool>0) {
                    payable(dice.dicePublic.Banker).transfer(PrizePool);
                }           
                dice.dicePublic.Banker=address(0);
            }else{
                dice.dicePublic.PrizePool=PrizePool;
                dice.dicePublic.BetAmount=BetAmount;
            }
        }
    }
    function GetBankerInfo(uint256 DiceSort) public view returns (DicePublic memory){
        Dice storage dice=GetDiceSort(DiceSort);
        return dice.dicePublic;
    }
    //get public information
    function GetPublicInformation() public view returns(DicePublic memory,DicePublic memory,DicePublic memory,DicePublic memory,DicePublic memory,uint256,uint256){
        return(PrimaryDice.dicePublic,JuniorDice.dicePublic,IntermediateDice.dicePublic,SeniorDice.dicePublic,SupremeDice.dicePublic,block.number,PublicPrizePool);
    }
    //get privite information
    function GetPrivateInformation() public view returns(DiceBetInfo[] memory,DiceBetInfo[] memory,DiceBetInfo[] memory,DiceBetInfo[] memory,DiceBetInfo[] memory,ReferralInfo memory){
        return(PrimaryDice.Gamblers[msg.sender].diceBetInfo,JuniorDice.Gamblers[msg.sender].diceBetInfo,IntermediateDice.Gamblers[msg.sender].diceBetInfo,SeniorDice.Gamblers[msg.sender].diceBetInfo,SupremeDice.Gamblers[msg.sender].diceBetInfo,referrals[msg.sender]);
    }
        //Get the latest lottery information
    function GetLatestBetResult(uint256 DiceSort) public view returns(BetResult[]  memory){
        Dice storage dice=GetDiceSort(DiceSort);
        return dice.Gamblers[msg.sender].betResult;
    }
    function StopDiceGame()  external  {
        require(msg.sender==DevAddress);
        require(PrimaryDice.dicePublic.Banker==address(0)&& JuniorDice.dicePublic.Banker==address(0));
        require(IntermediateDice.dicePublic.Banker==address(0)&&SeniorDice.dicePublic.Banker==address(0)&&SupremeDice.dicePublic.Banker==address(0));
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