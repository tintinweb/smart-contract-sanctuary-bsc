/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
contract ChineseZodiac {
    address private  DevAddress;
    Zodiac public LowerPrimaryZo;
    Zodiac public UpperPrimaryZo;
    Zodiac public JuniorZo;
    Zodiac public InterZo;
    Zodiac public SeniorZo;
    Zodiac public SupremeZo;
    mapping (address => ReferralInfo) private referrals;
    struct ReferralInfo{
       address referral;
       uint256 ReferralProfit;
    }
    //The actual calculation of the odds is 11.5,It should be divided by 10
    uint128 private constant Odds=112;
    struct Zodiac{
        uint128 MinBankerAmount;
        uint128 MinBetAmount;
        uint128 MaxBetAmount;
        ZodiacPublic zodPublic;
        address[] GamblersAddress;
        mapping(address => Gambler) Gamblers;
    }
    struct ZodiacPublic{
        uint128 PrizePool;
        uint128 BetAmount; 
        address Banker;
        uint32 StopBlockNumber; 
        uint32 BlockNumber; 
    }
    struct Gambler{
        ZoBetInfo[] BetInfo;
        BetResult[] betResult;
        uint32 BankerBlock;
    }
    struct BetResult{
        uint32 BetZodiac;
        uint32 OpenZodiac;
        uint128 BetAmount;
        uint64 blockNumber;
    }
    struct ZoBetInfo{
        uint128 betAmount;
        uint32 zodiacNumber;
        uint64 blockNumber;
    }
    constructor() {  
        DevAddress =msg.sender; 
        LowerPrimaryZo.MinBankerAmount=1 ether;
        LowerPrimaryZo.MinBetAmount=0.02 ether;
        LowerPrimaryZo.MaxBetAmount=0.1 ether;
        UpperPrimaryZo.MinBankerAmount=2 ether;
        UpperPrimaryZo.MinBetAmount=0.02 ether;
        UpperPrimaryZo.MaxBetAmount=0.5 ether;
        JuniorZo.MinBankerAmount=5 ether;
        JuniorZo.MinBetAmount=0.02 ether;
        JuniorZo.MaxBetAmount=1 ether;
        InterZo.MinBankerAmount=10 ether;
        InterZo.MinBetAmount=0.1 ether;
        InterZo.MaxBetAmount=2 ether;
        SeniorZo.MinBankerAmount=50 ether;
        SeniorZo.MinBetAmount=0.1 ether;
        SeniorZo.MaxBetAmount=10 ether;
        SupremeZo.MinBankerAmount=100 ether;
        SupremeZo.MinBetAmount=0.1 ether;
        SupremeZo.MaxBetAmount=20 ether;
    }
    function GetZodiacSort(uint256 ZodiacSort) private view returns(Zodiac storage){
        require(ZodiacSort<=5);
        if(ZodiacSort==0){
           return LowerPrimaryZo;
        }else if(ZodiacSort==1){
           return UpperPrimaryZo;
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
        zodiac.zodPublic.BlockNumber=uint32(block.number);
        if(zodiac.GamblersAddress.length>0) delete zodiac.GamblersAddress;
    }
    function BatchSette(bool IsForce,Zodiac storage zodiac,uint256 ZodiacSort) private {
        uint256 devfee;
        uint256 prizepool=zodiac.zodPublic.PrizePool;
        zodiac.zodPublic.PrizePool=0;
        for (uint256 i=0;i<zodiac.GamblersAddress.length;i++){
            address gambler=zodiac.GamblersAddress[i];
            if (zodiac.Gamblers[gambler].BetInfo.length>0){
                delete zodiac.Gamblers[gambler].betResult;
                uint256 WinAmount;
                uint256 referProfit;
                for (uint256 j=0;j<zodiac.Gamblers[gambler].BetInfo.length;j++){
                    uint32 zodiacNum;
                    uint32 BetzodiacNum=zodiac.Gamblers[gambler].BetInfo[j].zodiacNumber;
                    uint64 BetblockNumber=zodiac.Gamblers[gambler].BetInfo[j].blockNumber;
                    if(uint256(blockhash(BetblockNumber))==0){
                        zodiacNum=BetzodiacNum%12+1;//Timeout does not open judge you to lose
                    } 
                    else{
                        zodiacNum=uint32(bytes4(keccak256(abi.encodePacked(ZodiacSort,blockhash(BetblockNumber)))))%12+1;
                    }   
                    uint128 thisBetAmount=zodiac.Gamblers[gambler].BetInfo[j].betAmount;
                    BetResult memory betResult=BetResult(BetzodiacNum,zodiacNum,thisBetAmount,BetblockNumber);
                    zodiac.Gamblers[gambler].betResult.push(betResult); 
                    devfee+=SafeMathmul(thisBetAmount,2)/100;
                    referProfit+=SafeMathmul(thisBetAmount,2)/100; 
                    prizepool+=SafeMathmul(thisBetAmount,96)/100;
                    if(BetzodiacNum==zodiacNum){
                        uint256 ThisWinAmount=thisBetAmount*Odds/10;
                        prizepool-=ThisWinAmount;
                        devfee+=SafeMathmul(ThisWinAmount,3)/100;     
                        WinAmount+=SafeMathmul(ThisWinAmount,97)/100;
                    }    
                }
                delete zodiac.Gamblers[gambler].BetInfo;
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
    function WithdrawReferralProfit() external {
        require(referrals[msg.sender].ReferralProfit>=0.01 ether,"At least 0.01BNB");
        uint256 profit=referrals[msg.sender].ReferralProfit;
        referrals[msg.sender].ReferralProfit=0;
        payable(msg.sender).transfer(profit);
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
            zodiac.zodPublic.StopBlockNumber=uint32(block.number);
        }
        else{
            require(block.number>zodiac.zodPublic.StopBlockNumber+1,"Wait to stop betting");
            BatchSette(false,zodiac,ZodiacSort);
        }
    }
    function ZodiacBet(uint32[] calldata ZodiacNumber,uint256 ZodiacSort,address ref) external payable{
        Zodiac storage zodiac=GetZodiacSort(ZodiacSort);
        require(ZodiacNumber.length>=1);
        uint256 PeiZodiacBet=msg.value/ZodiacNumber.length;
        require(PeiZodiacBet>= zodiac.MinBetAmount &&PeiZodiacBet<=zodiac.MaxBetAmount,"Amount not in range");
        require((zodiac.zodPublic.BetAmount +msg.value)*Odds/10<=zodiac.zodPublic.PrizePool,"Insufficient balance of the banker");
        require(zodiac.zodPublic.StopBlockNumber==0,"The banker is going down");
        if(referrals[msg.sender].referral == address(0)) {
            if(ref == msg.sender || ref == address(0) ) {
                ref = DevAddress;
            }
            referrals[msg.sender].referral = ref;
        }
        if(zodiac.Gamblers[msg.sender].BankerBlock!=zodiac.zodPublic.BlockNumber){
            zodiac.GamblersAddress.push(msg.sender);
            zodiac.Gamblers[msg.sender].BankerBlock=zodiac.zodPublic.BlockNumber;
        }
        uint128 BetAmount=uint128(msg.value);
        zodiac.zodPublic.BetAmount+=BetAmount;
        for(uint256 i=0;i<ZodiacNumber.length;i++){
            ZoBetInfo memory BetInfo = ZoBetInfo(uint128(PeiZodiacBet),ZodiacNumber[i],uint64(block.number));
            zodiac.Gamblers[msg.sender].BetInfo.push(BetInfo);
        }
    }
    function ZodiacSettleBet(uint256 ZodiacSort) external{
        Zodiac storage zodiac=GetZodiacSort(ZodiacSort);
        require(zodiac.Gamblers[msg.sender].BetInfo.length>0,"You didn't bet");
        require(block.number>zodiac.Gamblers[msg.sender].BetInfo[zodiac.Gamblers[msg.sender].BetInfo.length-1].blockNumber,"It's not time");
        uint256 WinAmount;
        uint256 devfee;
        uint256 referProfit;
        uint128 BetAmount=zodiac.zodPublic.BetAmount;
        uint128 PrizePool=zodiac.zodPublic.PrizePool;
        if (zodiac.Gamblers[msg.sender].betResult.length>0) delete zodiac.Gamblers[msg.sender].betResult;
        for(uint256 i=0;i<zodiac.Gamblers[msg.sender].BetInfo.length;i++){
            uint32 BetzodiacNum=zodiac.Gamblers[msg.sender].BetInfo[i].zodiacNumber;
            uint32 zodiacNum;
            uint64 BetblockNumber=zodiac.Gamblers[msg.sender].BetInfo[i].blockNumber;
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
            devfee+=SafeMathmul(thisBetAmount,2)/100;
            referProfit+=SafeMathmul(thisBetAmount,2)/100;   
            PrizePool+=uint128(SafeMathmul(thisBetAmount,96)/100);        
            if(BetzodiacNum==zodiacNum){
                uint128 ThisWinAmount=thisBetAmount*Odds/10;
                PrizePool-=ThisWinAmount;
                devfee+=SafeMathmul(ThisWinAmount,3)/100;
                WinAmount+=SafeMathmul(ThisWinAmount,97)/100;
            }
        }
        zodiac.zodPublic.BetAmount=BetAmount;
        delete zodiac.Gamblers[msg.sender].BetInfo;       
        if(WinAmount>0){
            payable(msg.sender).transfer(WinAmount);
        }
        address referral=referrals[msg.sender].referral;
        if(referral==DevAddress){
            devfee +=referProfit;
        }
        else{
            referrals[referral].ReferralProfit+=referProfit;     
        }        
        payable(DevAddress).transfer(devfee);
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
        return(LowerPrimaryZo.zodPublic,UpperPrimaryZo.zodPublic,JuniorZo.zodPublic,InterZo.zodPublic,SeniorZo.zodPublic,SupremeZo.zodPublic,block.number,blockhash(block.number-1));
    }
    //get privite information
    function GetPrivateInformation() public view returns(ZoBetInfo[] memory,ZoBetInfo[] memory,ZoBetInfo[] memory,ZoBetInfo[] memory,ZoBetInfo[] memory,ZoBetInfo[] memory, ReferralInfo memory){
        return(LowerPrimaryZo.Gamblers[msg.sender].BetInfo,UpperPrimaryZo.Gamblers[msg.sender].BetInfo,JuniorZo.Gamblers[msg.sender].BetInfo,InterZo.Gamblers[msg.sender].BetInfo,SeniorZo.Gamblers[msg.sender].BetInfo,SupremeZo.Gamblers[msg.sender].BetInfo,referrals[msg.sender]);
    }
        //Get the latest lottery information
    function GetLatestBetResult(uint256 ZodiacSort) public view returns(BetResult[]  memory){
        Zodiac storage zodiac=GetZodiacSort(ZodiacSort);
        return zodiac.Gamblers[msg.sender].betResult;
    }
    function StopZodiacGame()  external  {
        require(msg.sender==DevAddress);
        require(LowerPrimaryZo.zodPublic.Banker==address(0)&&UpperPrimaryZo.zodPublic.Banker==address(0)&&  JuniorZo.zodPublic.Banker==address(0));
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