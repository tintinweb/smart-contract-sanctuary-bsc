/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
contract DiceGame {
    address private  DevAddress;
    Dice public PrimaryDice1;
    Dice public PrimaryDice2;
    Dice public JuniorDice;
    Dice public IntermediateDice;
    Dice public SeniorDice;
    Dice public SupremeDice;
    struct Dice{
        DicePublic dicePublic;
        uint128 MinBankerAmount;
        uint128 MinBetAmount;
        uint128 MaxBetAmount;
        address[] GamblersAddress;
        mapping(address => Gambler) Gamblers;
    }
    struct DicePublic{
        address Banker;
        uint128 PrizePool;
        uint128 BetAmount; 
        uint128 StopBlockNumber; 
    }
    struct Gambler{
        DiceBetInfo[] diceBetInfo;
        BetResult[] betResult;
        address Banker;
    }
    struct BetResult{
        uint128 diceNum;
        uint128 BetAmount;
    }
    struct DiceBetInfo{
        uint128 betAmount;
        uint128 blockNumber;
        bytes32 diceID;
    }
    constructor() {  
        DevAddress =msg.sender; 
        PrimaryDice1.MinBankerAmount=1 ether;
        PrimaryDice1.MinBetAmount=0.02 ether;
        PrimaryDice1.MaxBetAmount=1 ether;
        PrimaryDice2.MinBankerAmount=1 ether;
        PrimaryDice2.MinBetAmount=0.02 ether;
        PrimaryDice2.MaxBetAmount=1 ether;
        JuniorDice.MinBankerAmount=5 ether;
        JuniorDice.MinBetAmount=0.02 ether;
        JuniorDice.MaxBetAmount=5 ether;
        IntermediateDice.MinBankerAmount=10 ether;
        IntermediateDice.MinBetAmount=0.1 ether;
        IntermediateDice.MaxBetAmount=10 ether;
        SeniorDice.MinBankerAmount=50 ether;
        SeniorDice.MinBetAmount=0.1 ether;
        SeniorDice.MaxBetAmount=50 ether;
        SupremeDice.MinBankerAmount=100 ether;
        SupremeDice.MinBetAmount=0.1 ether;
        SupremeDice.MaxBetAmount=100 ether;   
    }
    function GetDiceSort(uint256 DiceSort) private view returns(Dice storage){
        require(DiceSort<=5);
        if(DiceSort==0){
           return PrimaryDice1;
        }else if(DiceSort==1){
           return PrimaryDice2;      
        }else if(DiceSort==2){
           return JuniorDice;
        }
        else if (DiceSort==3){
          return IntermediateDice;
        }
        else if (DiceSort==4){
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
        if(dice.GamblersAddress.length>0) delete dice.GamblersAddress;
    }
    function BatchSette(bool IsForce,Dice storage dice) private {
        uint256 devfee;
        uint256 prizepool=dice.dicePublic.PrizePool;
        dice.dicePublic.PrizePool=0;
        for (uint256 i=0;i<dice.GamblersAddress.length;i++){
            if (dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo.length>0){
                delete dice.Gamblers[dice.GamblersAddress[i]].betResult;
                uint256 WinAmount;
                for (uint256 j=0;j<dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo.length;j++){
                    uint128 diceNum;
                    if(uint256(blockhash(dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo[j].blockNumber))==0){
                        diceNum=100;//Timeout does not open judge you to lose
                    } 
                    else{
                        diceNum=uint128(uint256(keccak256(abi.encodePacked(dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo[j].diceID,blockhash(dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo[j].blockNumber))))%100+1);
                    }   
                    uint256 thisBetAmount=dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo[j].betAmount;
                    BetResult memory betResult=BetResult(diceNum,uint128(thisBetAmount));
                    dice.Gamblers[dice.GamblersAddress[i]].betResult.push(betResult);
                    devfee+=SafeMathmul(thisBetAmount,2)/100;
                    if(diceNum<=48){
                        prizepool-=thisBetAmount;
                        WinAmount+=thisBetAmount+SafeMathmul(thisBetAmount,98)/100;
                    }
                    else{
                        prizepool+=SafeMathmul(thisBetAmount,98)/100;
                    }     
                }
                delete dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo;
                if(WinAmount>0){
                    payable(dice.GamblersAddress[i]).transfer(WinAmount);
                }
            }
        }
        delete dice.GamblersAddress;
        if(devfee>0){
            payable(DevAddress).transfer(devfee);
        } 
        if(prizepool>0){    
            if(IsForce)
            {
                payable(msg.sender).transfer(SafeMathmul(prizepool,3)/100);
                payable(dice.dicePublic.Banker).transfer(SafeMathmul(prizepool,97)/100);
            }else{
                payable(dice.dicePublic.Banker).transfer(prizepool);
            }         

        }
        dice.dicePublic.Banker=address(0);
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
            dice.dicePublic.StopBlockNumber=uint128(block.number);
        }
        else{
            require(block.number>dice.dicePublic.StopBlockNumber+1,"Wait to stop betting");
            BatchSette(false,dice);
        }
    }
    function DiceBet(uint256 Lucknum,uint256 DiceSort) external payable{
        Dice storage dice=GetDiceSort(DiceSort);
        require(msg.value>= dice.MinBetAmount &&msg.value<=dice.MaxBetAmount,"Amount not in range");
        require(dice.dicePublic.BetAmount +msg.value<=dice.dicePublic.PrizePool,"Insufficient balance of the banker");
        require(dice.dicePublic.StopBlockNumber==0,"The banker is going down");
        if(dice.Gamblers[msg.sender].Banker!=dice.dicePublic.Banker){
            dice.GamblersAddress.push(msg.sender);
            dice.Gamblers[msg.sender].Banker=dice.dicePublic.Banker;
        }
        uint128 BetAmount=uint128(msg.value);
        dice.dicePublic.BetAmount+=BetAmount;
        DiceBetInfo memory diceBetInfo = DiceBetInfo(BetAmount,uint128(block.number),keccak256(abi.encodePacked(block.coinbase,msg.sender,Lucknum)));
        dice.Gamblers[msg.sender].diceBetInfo.push(diceBetInfo);
    }
    function DiceSettleBet(uint256 DiceSort) external{
        Dice storage dice=GetDiceSort(DiceSort);
        require(dice.Gamblers[msg.sender].diceBetInfo.length>0,"You didn't bet");
        require(block.number>dice.Gamblers[msg.sender].diceBetInfo[dice.Gamblers[msg.sender].diceBetInfo.length-1].blockNumber,"It's not time");
        uint256 WinAmount;
        uint256 devfee;
        uint128 BetAmount=dice.dicePublic.BetAmount;
        uint128 PrizePool=dice.dicePublic.PrizePool;
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
            BetResult memory betResult=BetResult(diceNum,thisBetAmount);
            dice.Gamblers[msg.sender].betResult.push(betResult);
            devfee+=SafeMathmul(thisBetAmount,2)/100;
            if(diceNum<=48){
                BetAmount-=thisBetAmount;
                PrizePool-=thisBetAmount;
                WinAmount+=thisBetAmount+SafeMathmul(thisBetAmount,98)/100;
            }
            else{
                BetAmount-=thisBetAmount;
                PrizePool+=uint128(SafeMathmul(thisBetAmount,98)/100);
            }
        }
        dice.dicePublic.BetAmount=BetAmount;
        delete dice.Gamblers[msg.sender].diceBetInfo;
        payable(DevAddress).transfer(devfee);
        if(WinAmount>0){
            payable(msg.sender).transfer(WinAmount);
        }
        if(PrizePool<dice.MinBetAmount){
            dice.dicePublic.PrizePool=0;
            delete dice.GamblersAddress;
            if(PrizePool>0) {
                payable(dice.dicePublic.Banker).transfer(PrizePool);
            }           
            dice.dicePublic.Banker=address(0);
        }else{
            dice.dicePublic.PrizePool=PrizePool;
        }
    }
    function GetBankerInfo(uint256 DiceSort) public view returns (DicePublic memory){
        Dice storage dice=GetDiceSort(DiceSort);
        return dice.dicePublic;
    }
    //get public information
    function GetPublicInformation() public view returns(DicePublic memory,DicePublic memory,DicePublic memory,DicePublic memory,DicePublic memory,DicePublic memory,uint256){
        return(PrimaryDice1.dicePublic,PrimaryDice2.dicePublic,JuniorDice.dicePublic,IntermediateDice.dicePublic,SeniorDice.dicePublic,SupremeDice.dicePublic,block.number);
    }
    //get privite information
    function GetPrivateInformation() public view returns(DiceBetInfo[] memory,DiceBetInfo[] memory,DiceBetInfo[] memory,DiceBetInfo[] memory,DiceBetInfo[] memory,DiceBetInfo[] memory){
        return(PrimaryDice1.Gamblers[msg.sender].diceBetInfo,PrimaryDice2.Gamblers[msg.sender].diceBetInfo,JuniorDice.Gamblers[msg.sender].diceBetInfo,IntermediateDice.Gamblers[msg.sender].diceBetInfo,SeniorDice.Gamblers[msg.sender].diceBetInfo,SupremeDice.Gamblers[msg.sender].diceBetInfo);
    }
        //Get the latest lottery information
    function GetLatestBetResult(uint256 DiceSort) public view returns(BetResult[]  memory){
        Dice storage dice=GetDiceSort(DiceSort);
        return dice.Gamblers[msg.sender].betResult;
    }
    function Returntoinvestor()  external  {
        require(msg.sender==DevAddress);
        require(PrimaryDice1.dicePublic.Banker==address(0)&& PrimaryDice2.dicePublic.Banker==address(0)&& JuniorDice.dicePublic.Banker==address(0));
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