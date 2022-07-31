/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
contract ChineseZodiac {
    address private  DevAddress;
    Zodiac public PrimaryZo1;
    Zodiac public PrimaryZo2;
    Zodiac public JuniorZo;
    Zodiac public InterZo;
    Zodiac public SeniorZo;
    Zodiac public SupremeZo;
    //The actual calculation of the odds is 11.5,It should be divided by 10
    uint128 private constant Odds=115;
    struct Zodiac{
        ZodiacPublic zodPublic;
        uint128 MinBankerAmount;
        uint128 MinBetAmount;
        uint128 MaxBetAmount;
        address[] GamblersAddress;
        mapping(address => Gambler) Gamblers;
    }
    struct ZodiacPublic{
        address Banker;
        uint128 PrizePool;
        uint128 BetAmount; 
        uint48 StopBlockNumber; 
    }
    struct Gambler{
        ZoBetInfo[] BetInfo;
        BetResult[] betResult;
        address Banker;
    }
    struct BetResult{
        uint32 BetZodiac;
        uint32 OpenZodiac;
        uint128 BetAmount;
        uint48 blockNumber;
    }
    struct ZoBetInfo{
        uint128 betAmount;
        uint32 zodiacNumber;
        uint48 blockNumber;
    }
    constructor() {  
        DevAddress =msg.sender; 
        PrimaryZo1.MinBankerAmount=1 ether;
        PrimaryZo1.MinBetAmount=0.02 ether;
        PrimaryZo1.MaxBetAmount=1 ether;
        PrimaryZo2.MinBankerAmount=1 ether;
        PrimaryZo2.MinBetAmount=0.02 ether;
        PrimaryZo2.MaxBetAmount=1 ether;
        JuniorZo.MinBankerAmount=5 ether;
        JuniorZo.MinBetAmount=0.02 ether;
        JuniorZo.MaxBetAmount=2 ether;
        InterZo.MinBankerAmount=10 ether;
        InterZo.MinBetAmount=0.1 ether;
        InterZo.MaxBetAmount=5 ether;
        SeniorZo.MinBankerAmount=50 ether;
        SeniorZo.MinBetAmount=0.1 ether;
        SeniorZo.MaxBetAmount=20 ether;
        SupremeZo.MinBankerAmount=100 ether;
        SupremeZo.MinBetAmount=0.1 ether;
        SupremeZo.MaxBetAmount=50 ether;
    }
    function GetZodiacSort(uint256 ZodiacSort) private view returns(Zodiac storage){
        require(ZodiacSort<=5);
        if(ZodiacSort==0){
           return PrimaryZo1;
        }else if(ZodiacSort==1){
           return PrimaryZo2;
        }
        else if(ZodiacSort==2){
           return JuniorZo;
        }
        else if (ZodiacSort==3){
          return InterZo;
        }else if (ZodiacSort==4){
           return SeniorZo;
        }else{
            return SupremeZo;
        }
    }
    //be a Banker 
    function ZodiacBeBanker(uint256 ZodiacSort) external  payable {
        Zodiac storage zodiac=GetZodiacSort(ZodiacSort);
        require(msg.value>=zodiac.MinBankerAmount,"Below minimum");
        require(zodiac.zodPublic.Banker==address(0),"Someone is already a Banker");
        zodiac.zodPublic.Banker=msg.sender;
        zodiac.zodPublic.StopBlockNumber=0;
        zodiac.zodPublic.PrizePool=uint128(msg.value);
        zodiac.zodPublic.BetAmount=0;
        if(zodiac.GamblersAddress.length>0) delete zodiac.GamblersAddress;
    }
    function BatchSette(bool IsForce,Zodiac storage zodiac,uint256 ZodiacSort) private {
        uint256 devfee;
        uint256 prizepool=zodiac.zodPublic.PrizePool;
        zodiac.zodPublic.PrizePool=0;
        for (uint256 i=0;i<zodiac.GamblersAddress.length;i++){
            if (zodiac.Gamblers[zodiac.GamblersAddress[i]].BetInfo.length>0){
                delete zodiac.Gamblers[zodiac.GamblersAddress[i]].betResult;
                uint256 WinAmount;
                for (uint256 j=0;j<zodiac.Gamblers[zodiac.GamblersAddress[i]].BetInfo.length;j++){
                    uint32 zodiacNum;
                    uint32 BetzodiacNum=zodiac.Gamblers[zodiac.GamblersAddress[i]].BetInfo[j].zodiacNumber;
                    uint48 BetblockNumber=zodiac.Gamblers[zodiac.GamblersAddress[i]].BetInfo[j].blockNumber;
                    if(uint256(blockhash(zodiac.Gamblers[zodiac.GamblersAddress[i]].BetInfo[j].blockNumber))==0){
                        zodiacNum=BetzodiacNum%12+1;//Timeout does not open judge you to lose
                    } 
                    else{
                        zodiacNum=uint32(bytes4(keccak256(abi.encodePacked(ZodiacSort,blockhash(zodiac.Gamblers[zodiac.GamblersAddress[i]].BetInfo[j].blockNumber)))))%12+1;
                    }   
                    uint128 thisBetAmount=zodiac.Gamblers[zodiac.GamblersAddress[i]].BetInfo[j].betAmount;
                    BetResult memory betResult=BetResult(BetzodiacNum,zodiacNum,thisBetAmount,BetblockNumber);
                    zodiac.Gamblers[zodiac.GamblersAddress[i]].betResult.push(betResult); 
                    if(BetzodiacNum==zodiacNum){
                        uint256 ThisWinAmount=thisBetAmount*Odds/10;
                        prizepool=prizepool+thisBetAmount-ThisWinAmount;
                        devfee+=SafeMathmul(ThisWinAmount,3)/100;
                        WinAmount+=SafeMathmul(ThisWinAmount,97)/100;
                    }
                    else{
                        devfee+=SafeMathmul(thisBetAmount,3)/100;
                        prizepool+=SafeMathmul(thisBetAmount,97)/100;
                    }      
                }
                delete zodiac.Gamblers[zodiac.GamblersAddress[i]].BetInfo;
                if(WinAmount>0){
                    payable(zodiac.GamblersAddress[i]).transfer(WinAmount);
                }
            }
        }
        delete zodiac.GamblersAddress;
        if(devfee>0){
            payable(DevAddress).transfer(devfee);
        } 
        if(prizepool>0){     
            if(IsForce){
                payable(msg.sender).transfer(SafeMathmul(prizepool,3)/100);
                payable(zodiac.zodPublic.Banker).transfer(SafeMathmul(prizepool,97)/100);
            }
            else{
                payable(zodiac.zodPublic.Banker).transfer(prizepool);
            }         
        }
        zodiac.zodPublic.Banker=address(0);
    }
    //If the dealer stops betting and doesn't come down, anyone can kick it down,5% will be deducted if kicked down
    function ForcedDownBanker(uint256 ZodiacSort) external{
        Zodiac storage zodiac=GetZodiacSort(ZodiacSort);
        require(zodiac.zodPublic.Banker!=address(0)&&zodiac.zodPublic.StopBlockNumber>0,"There is no banker going down");
        require(block.number>zodiac.zodPublic.StopBlockNumber+10,"Wait to stop betting");
        BatchSette(true,zodiac,ZodiacSort);
    }
    function  ZodiacStopBeBanker(uint256 ZodiacSort) external{
        Zodiac storage zodiac=GetZodiacSort(ZodiacSort);
        require(zodiac.zodPublic.Banker==msg.sender||msg.sender==DevAddress,"You are not a Banker");
        if(zodiac.zodPublic.BetAmount==0){
            uint256 zodiacprizepool=zodiac.zodPublic.PrizePool;
            zodiac.zodPublic.PrizePool=0;
            if(zodiacprizepool>0){
                payable(zodiac.zodPublic.Banker).transfer(zodiacprizepool);
            }
            zodiac.zodPublic.Banker=address(0);
        }
        else if(zodiac.zodPublic.StopBlockNumber==0){
            zodiac.zodPublic.StopBlockNumber=uint48(block.number);
        }
        else{
            require(block.number>zodiac.zodPublic.StopBlockNumber+1,"Wait to stop betting");
            BatchSette(false,zodiac,ZodiacSort);
        }
    }
    function ZodiacBet(uint8 ZodiacNumber,uint256 ZodiacSort) external payable{
        Zodiac storage zodiac=GetZodiacSort(ZodiacSort);
        require(msg.value>= zodiac.MinBetAmount &&msg.value<=zodiac.MaxBetAmount,"Amount not in range");
        require((zodiac.zodPublic.BetAmount +msg.value)*Odds/10<=zodiac.zodPublic.PrizePool,"Insufficient balance of the banker");
        require(zodiac.zodPublic.StopBlockNumber==0,"The banker is going down");
        if(zodiac.Gamblers[msg.sender].Banker!=zodiac.zodPublic.Banker){
            zodiac.GamblersAddress.push(msg.sender);
            zodiac.Gamblers[msg.sender].Banker=zodiac.zodPublic.Banker;
        }
        uint128 BetAmount=uint128(msg.value);
        zodiac.zodPublic.BetAmount+=BetAmount;
        ZoBetInfo memory BetInfo = ZoBetInfo(BetAmount,ZodiacNumber,uint48(block.number));
        zodiac.Gamblers[msg.sender].BetInfo.push(BetInfo);
    }
    function ZodiacSettleBet(uint256 ZodiacSort) external{
        Zodiac storage zodiac=GetZodiacSort(ZodiacSort);
        require(zodiac.Gamblers[msg.sender].BetInfo.length>0,"You didn't bet");
        require(block.number>zodiac.Gamblers[msg.sender].BetInfo[zodiac.Gamblers[msg.sender].BetInfo.length-1].blockNumber,"It's not time");
        uint256 WinAmount;
        uint256 devfee;
        uint128 BetAmount=zodiac.zodPublic.BetAmount;
        uint128 PrizePool=zodiac.zodPublic.PrizePool;
        if (zodiac.Gamblers[msg.sender].betResult.length>0) delete zodiac.Gamblers[msg.sender].betResult;
        for(uint256 i=0;i<zodiac.Gamblers[msg.sender].BetInfo.length;i++){
            uint32 BetzodiacNum=zodiac.Gamblers[msg.sender].BetInfo[i].zodiacNumber;
            uint32 zodiacNum;
            uint48 BetblockNumber=zodiac.Gamblers[msg.sender].BetInfo[i].blockNumber;
            if(uint256(blockhash(zodiac.Gamblers[msg.sender].BetInfo[i].blockNumber))==0){
                zodiacNum=BetzodiacNum%12+1;//Timeout does not open judge you to lose
            } 
            else{
                zodiacNum=uint32(bytes4(keccak256(abi.encodePacked(ZodiacSort,blockhash(zodiac.Gamblers[msg.sender].BetInfo[i].blockNumber)))))%12+1;
            }
            uint128 thisBetAmount=zodiac.Gamblers[msg.sender].BetInfo[i].betAmount;          
            BetResult memory betResult=BetResult(BetzodiacNum,zodiacNum,thisBetAmount,BetblockNumber);
            zodiac.Gamblers[msg.sender].betResult.push(betResult);
            BetAmount-=thisBetAmount;           
            if(BetzodiacNum==zodiacNum){
                uint128 ThisWinAmount=thisBetAmount*Odds/10;
                PrizePool=PrizePool+thisBetAmount-ThisWinAmount;
                devfee+=SafeMathmul(ThisWinAmount,3)/100;
                WinAmount+=SafeMathmul(ThisWinAmount,97)/100;
            }
            else{
                devfee+=SafeMathmul(thisBetAmount,3)/100;
                PrizePool+=uint128(SafeMathmul(thisBetAmount,97)/100);
            }
        }
        zodiac.zodPublic.BetAmount=BetAmount;
        delete zodiac.Gamblers[msg.sender].BetInfo;
        payable(DevAddress).transfer(devfee);
        if(WinAmount>0){
            payable(msg.sender).transfer(WinAmount);
        }
        if(PrizePool<zodiac.MinBetAmount*Odds/10){
            zodiac.zodPublic.PrizePool=0;
            delete zodiac.GamblersAddress;
            if(PrizePool>0) {
                payable(zodiac.zodPublic.Banker).transfer(PrizePool);
            }           
            zodiac.zodPublic.Banker=address(0);
        }else{
            zodiac.zodPublic.PrizePool=PrizePool;
        }
    }
    function GetBankerInfo(uint256 ZodiacSort) public view returns (ZodiacPublic memory){
        Zodiac storage zodiac=GetZodiacSort(ZodiacSort);
        return zodiac.zodPublic;
    }
    //get public information
    function GetPublicInformation() public view returns(ZodiacPublic memory,ZodiacPublic memory,ZodiacPublic memory,ZodiacPublic memory,ZodiacPublic memory,ZodiacPublic memory,uint256,bytes32){
        return(PrimaryZo1.zodPublic,PrimaryZo2.zodPublic,JuniorZo.zodPublic,InterZo.zodPublic,SeniorZo.zodPublic,SupremeZo.zodPublic,block.number,blockhash(block.number-1));
    }
    //get privite information
    function GetPrivateInformation() public view returns(ZoBetInfo[] memory,ZoBetInfo[] memory,ZoBetInfo[] memory,ZoBetInfo[] memory,ZoBetInfo[] memory,ZoBetInfo[] memory){
        return(PrimaryZo1.Gamblers[msg.sender].BetInfo,PrimaryZo2.Gamblers[msg.sender].BetInfo,JuniorZo.Gamblers[msg.sender].BetInfo,InterZo.Gamblers[msg.sender].BetInfo,SeniorZo.Gamblers[msg.sender].BetInfo,SupremeZo.Gamblers[msg.sender].BetInfo);
    }
        //Get the latest lottery information
    function GetLatestBetResult(uint256 ZodiacSort) public view returns(BetResult[]  memory){
        Zodiac storage zodiac=GetZodiacSort(ZodiacSort);
        return zodiac.Gamblers[msg.sender].betResult;
    }
    function Returntoinvestor()  external  {
        require(msg.sender==DevAddress);
        require(PrimaryZo1.zodPublic.Banker==address(0)&&PrimaryZo2.zodPublic.Banker==address(0)&&  JuniorZo.zodPublic.Banker==address(0));
        require(InterZo.zodPublic.Banker==address(0)&&SeniorZo.zodPublic.Banker==address(0)&&SupremeZo.zodPublic.Banker==address(0));
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