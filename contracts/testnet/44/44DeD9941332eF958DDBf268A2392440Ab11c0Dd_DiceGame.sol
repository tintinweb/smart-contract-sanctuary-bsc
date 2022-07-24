/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
contract DiceGame {
    address private  DevAddress;
    Dice public PrimaryDice;
    Dice public JuniorDice;
    Dice public IntermediateDice;
    Dice public SeniorDice;
    struct Dice{
        DicePublic dicePublic;
        uint256 MinBankerAmount;
        uint256 MinBetAmount;
        uint256 MaxBetAmount;
        uint256 StopBlockNumber;
        address[] GamblersAddress;
        mapping(address => Gambler) Gamblers;
    }
    struct DicePublic{
        address Banker;
        uint256 PrizePool;
        uint256 BetAmount;  
    }
    struct Gambler{
        DiceBetInfo[] diceBetInfo;
        BetResult[] betResult;
        address Banker;
    }
    struct BetResult{
        uint8 diceNum;
        uint248 BetAmount;
    }
    struct DiceBetInfo{
        uint256 betAmount;
        bytes32 diceID;
        uint256 blockNumber;
    }
    constructor() {  
        DevAddress =msg.sender; 
        PrimaryDice.MinBankerAmount=1 ether;
        PrimaryDice.MinBetAmount=0.02 ether;
        PrimaryDice.MaxBetAmount=1 ether;
        JuniorDice.MinBankerAmount=5 ether;
        JuniorDice.MinBetAmount=0.1 ether;
        JuniorDice.MaxBetAmount=5 ether;
        IntermediateDice.MinBankerAmount=10 ether;
        IntermediateDice.MinBetAmount=0.1 ether;
        IntermediateDice.MaxBetAmount=10 ether;
        SeniorDice.MinBankerAmount=100 ether;
        SeniorDice.MinBetAmount=0.1 ether;
        SeniorDice.MaxBetAmount=100 ether;
    }
    function GetDiceSort(uint256 DiceSort) private view returns(Dice storage){
        if(DiceSort==0){
           return PrimaryDice;
        }else if(DiceSort==1){
           return JuniorDice;
        }
        else if (DiceSort==2){
          return IntermediateDice;
        }else{
           return SeniorDice;
        }
    }
    //be a Banker 
    function DiceBeBanker(uint256 DiceSort) external  payable {
        Dice storage dice=GetDiceSort(DiceSort);
        require(msg.value>=dice.MinBankerAmount,"Below minimum");
        require(dice.dicePublic.Banker==address(0),"Someone is already a Banker");
        dice.dicePublic.Banker=msg.sender;
        dice.StopBlockNumber=0;
        dice.dicePublic.PrizePool=msg.value;
        dice.dicePublic.BetAmount=0;
        if(dice.GamblersAddress.length>0) delete dice.GamblersAddress;
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
        else if(dice.StopBlockNumber==0){
            dice.StopBlockNumber=block.number;
        }
        else{
            require(block.number>dice.StopBlockNumber+1,"Wait to stop betting");
            uint256 devfee;
            uint256 prizepool=dice.dicePublic.PrizePool;
            dice.dicePublic.PrizePool=0;
            for (uint256 i=0;i<dice.GamblersAddress.length;i++){
                if (dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo.length>0){
                    delete dice.Gamblers[dice.GamblersAddress[i]].betResult;
                    uint256 WinAmount;
                    for (uint256 j=0;j<dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo.length;j++){
                        uint256 diceNum;
                        if(uint256(blockhash(dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo[j].blockNumber))==0){
                            diceNum=100;//Timeout does not open judge you to lose
                        } 
                        else{
                            diceNum=uint256(keccak256(abi.encodePacked(dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo[j].diceID,blockhash(dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo[j].blockNumber))))%100+1;
                        }   
                        BetResult memory betResult=BetResult(uint8(diceNum),uint248(dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo[j].betAmount));
                        dice.Gamblers[dice.GamblersAddress[i]].betResult.push(betResult);
                        devfee+=SafeMathmul(dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo[j].betAmount,3)/100;
                        if(diceNum<=49){
                            prizepool-=dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo[j].betAmount;
                            WinAmount+=dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo[j].betAmount+SafeMathmul(dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo[j].betAmount,97)/100;
                        }
                        else{
                            prizepool+=SafeMathmul(dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo[j].betAmount,97)/100;
                        }     
                    }
                    delete dice.Gamblers[dice.GamblersAddress[i]].diceBetInfo;
                    if(WinAmount>0){
                        payable(dice.GamblersAddress[i]).transfer(WinAmount);
                    }
                }
            }
            if(devfee>0){
                payable(DevAddress).transfer(devfee);
            } 
            delete dice.GamblersAddress;
            if(prizepool>0){              
                payable(dice.dicePublic.Banker).transfer(prizepool);
            }
            dice.dicePublic.Banker=address(0);
        }
    }
    function DiceBet(uint256 Lucknum,uint256 DiceSort) external payable{
        Dice storage dice=GetDiceSort(DiceSort);
        require(msg.value>= dice.MinBetAmount &&msg.value<=dice.MaxBetAmount,"Amount not in range");
        require(dice.dicePublic.BetAmount +msg.value>dice.dicePublic.PrizePool,"Insufficient balance of the banker");
        require(dice.StopBlockNumber==0,"The banker is going down");
        if(dice.Gamblers[msg.sender].Banker!=dice.dicePublic.Banker){
            dice.GamblersAddress.push(msg.sender);
            dice.Gamblers[msg.sender].Banker=dice.dicePublic.Banker;
        }
        dice.dicePublic.BetAmount+=msg.value;
        DiceBetInfo memory diceBetInfo = DiceBetInfo(msg.value,keccak256(abi.encodePacked(block.coinbase,msg.sender,Lucknum)),block.number);
        dice.Gamblers[msg.sender].diceBetInfo.push(diceBetInfo);
    }
    function DiceSettleBet(uint256 DiceSort) external{
        Dice storage dice=GetDiceSort(DiceSort);
        require(dice.Gamblers[msg.sender].diceBetInfo.length>0,"You didn't bet");
        require(block.number>dice.Gamblers[msg.sender].diceBetInfo[dice.Gamblers[msg.sender].diceBetInfo.length-1].blockNumber,"It's not time");
        uint256 WinAmount;
        uint256 devfee;
        delete dice.Gamblers[msg.sender].betResult;
        for(uint256 i=0;i<dice.Gamblers[msg.sender].diceBetInfo.length;i++){
            uint256 diceNum;
            if(uint256(blockhash(dice.Gamblers[msg.sender].diceBetInfo[i].blockNumber))==0){
                diceNum=100;//Timeout does not open judge you to lose
            } 
            else{
                diceNum=uint256(keccak256(abi.encodePacked(dice.Gamblers[msg.sender].diceBetInfo[i].diceID,blockhash(dice.Gamblers[msg.sender].diceBetInfo[i].blockNumber))))%100+1;
            }          
            BetResult memory betResult=BetResult(uint8(diceNum),uint248(dice.Gamblers[msg.sender].diceBetInfo[i].betAmount));
            dice.Gamblers[msg.sender].betResult.push(betResult);
            if(diceNum<=49){
                dice.dicePublic.BetAmount-=dice.Gamblers[msg.sender].diceBetInfo[i].betAmount;
                dice.dicePublic.PrizePool-=dice.Gamblers[msg.sender].diceBetInfo[i].betAmount;
                WinAmount+=dice.Gamblers[msg.sender].diceBetInfo[i].betAmount+SafeMathmul(dice.Gamblers[msg.sender].diceBetInfo[i].betAmount,97)/100;
                devfee+=SafeMathmul(dice.Gamblers[msg.sender].diceBetInfo[i].betAmount,3)/100;
            }
            else{
                dice.dicePublic.BetAmount-=dice.Gamblers[msg.sender].diceBetInfo[i].betAmount;
                devfee+=SafeMathmul(dice.Gamblers[msg.sender].diceBetInfo[i].betAmount,3)/100;
                dice.dicePublic.PrizePool+=SafeMathmul(dice.Gamblers[msg.sender].diceBetInfo[i].betAmount,97)/100;
            }
        }
        delete dice.Gamblers[msg.sender].diceBetInfo;
        payable(DevAddress).transfer(devfee);
        if(WinAmount>0){
            payable(msg.sender).transfer(WinAmount);
        }
        if(dice.dicePublic.PrizePool<=0){
            dice.dicePublic.Banker=address(0);
            delete dice.GamblersAddress;
        }
    }
    //get public information
    function GetPublicInformation() public view returns(DicePublic memory,DicePublic memory,DicePublic memory,DicePublic memory){
        return(PrimaryDice.dicePublic,JuniorDice.dicePublic,IntermediateDice.dicePublic,SeniorDice.dicePublic);
    }
    //get privite information
    function GetPrivateInformation() public view returns(DiceBetInfo[] memory,DiceBetInfo[] memory,DiceBetInfo[] memory,DiceBetInfo[] memory){
        return(PrimaryDice.Gamblers[msg.sender].diceBetInfo,JuniorDice.Gamblers[msg.sender].diceBetInfo,IntermediateDice.Gamblers[msg.sender].diceBetInfo,SeniorDice.Gamblers[msg.sender].diceBetInfo);
    }
        //Get the latest lottery information
    function GetLatestBetResult(uint256 DiceSort) public view returns(BetResult[]  memory){
        Dice storage dice=GetDiceSort(DiceSort);
        return dice.Gamblers[msg.sender].betResult;
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