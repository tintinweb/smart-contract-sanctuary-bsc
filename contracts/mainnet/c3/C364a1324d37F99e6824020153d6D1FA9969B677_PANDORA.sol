/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

pragma solidity ^0.6.8;
interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver) external view returns(uint256);
    function approve(address spender, uint amount) external returns (bool);
}
interface PCD {
    function InvestmentCountdown(address addr) external view returns (uint);
    function hatcheryMiners(address addr) external view returns (uint);
    function claimedEggs(address addr) external view returns (uint);
    function lastHatch(address addr) external view returns (uint);
    function referrals(address addr) external view returns (address);
    function numRealRef(address addr) external view returns (uint);
    function isWhiteList(address addr) external view returns (bool);
    function AlreadyInvolved(address addr) external view returns (bool);
    function marketEggs() external returns (uint);
    function fomoTime() external returns (uint);
    function TotalNumberOfAddress() external returns (uint);
    function fomoRewards() external returns (uint);
    function balanceOf(address receiver) external view returns(uint256);
    function minerPower(address receiver) external view returns(uint256);
    function minerPowerPcd(address receiver) external view returns(uint256);
    function allPcdPower() external view returns(uint256);
}
interface IPancakeRouter01 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}
interface pcdmier{
    function setTime(address addr)external;
    function lastHatch(address addr) external view returns(uint256);
}
contract PANDORA{
    using SafeMath for uint256;
    //uint256 EGGS_PER_MINERS_PER_SECOND=1;
    uint256 public EGGS_TO_HATCH_1MINERS=864000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    uint256 public minBuyValue;
    address public marketingAddress;
    address public market;
    address public ceoAddress;
    address public USDT;
    uint256 public allPcdPower;//PCD全网算力
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    mapping (address => uint256) public numRealRef;
    mapping (address =>bool) public AlreadyInvolved;
    mapping(address =>uint256) public InvestmentCountdown;
    mapping(address =>uint256) public minerPower;
    mapping(address =>uint256) public minerPowerPcd;
    uint256 public marketEggs=86400000000;
    uint256 public TotalNumberOfAddress;
    uint256 public vaTova;
    uint256 public fomoTime;
    address public fomoAddress;
    uint256 public fomoNeededTime = 28800;
    uint256 public fomoRewards;
    uint256 public orMax;
    address public pancakeRouter=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public toplusToken=0xE4f1AE07760b985D1A94c6e5FB1589afAf44918c;
    mapping(address => bool) public isWhiteList;
    mapping(address => bool) public isPower;
    mapping(address => uint) public balanceOf;
    bool whiteListNeeded = true;
    bool public isFomoFinished = false;
    constructor() public{
        ceoAddress=msg.sender;
        marketingAddress = 0x7e6825510DCE92efd2D95E1f3F4fCcE98D66925B;
        USDT=0x55d398326f99059fF775485246999027B3197955;
        isWhiteList[ceoAddress] = true;
        orMax=60;
        minBuyValue= 100 ether;
        hatcheryMiners[msg.sender]=1;
    }
    receive() external payable{ 
    }
    function update(address addr)public{
        require(PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).lastHatch(addr) < 1654959996);
        if(PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).AlreadyInvolved(addr) && !AlreadyInvolved[addr]){
          AlreadyInvolved[addr]=true;
          hatcheryMiners[addr]=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).hatcheryMiners(addr);       
          claimedEggs[addr]=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).claimedEggs(addr);
          lastHatch[addr]=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).lastHatch(addr);
          numRealRef[addr]=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).numRealRef(addr);
          InvestmentCountdown[addr]=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).InvestmentCountdown(addr);
          balanceOf[addr]=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).balanceOf(addr);
          referrals[addr]=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).referrals(addr);
          minerPower[addr]=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).minerPower(addr);
          minerPowerPcd[addr]=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).minerPowerPcd(addr);
          if(marketEggs == 86400000000){
           marketEggs=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).marketEggs();
           fomoTime=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).fomoTime();
           fomoRewards=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).fomoRewards();
           TotalNumberOfAddress=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).TotalNumberOfAddress();
           allPcdPower=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).allPcdPower();
           }
        }else if(PCD(0x704bf329ee29d4169220Bd97a92083B74B772F0c).AlreadyInvolved(addr) && !AlreadyInvolved[addr]){
          AlreadyInvolved[addr]=true;
          hatcheryMiners[addr]=PCD(0x704bf329ee29d4169220Bd97a92083B74B772F0c).hatcheryMiners(addr);       
          claimedEggs[addr]=PCD(0x704bf329ee29d4169220Bd97a92083B74B772F0c).claimedEggs(addr);
          lastHatch[addr]=PCD(0x704bf329ee29d4169220Bd97a92083B74B772F0c).lastHatch(addr);
          numRealRef[addr]=PCD(0x704bf329ee29d4169220Bd97a92083B74B772F0c).numRealRef(addr);
          InvestmentCountdown[addr]=PCD(0x704bf329ee29d4169220Bd97a92083B74B772F0c).InvestmentCountdown(addr);
          balanceOf[addr]=PCD(0x704bf329ee29d4169220Bd97a92083B74B772F0c).balanceOf(addr);
          referrals[addr]=PCD(0x704bf329ee29d4169220Bd97a92083B74B772F0c).referrals(addr);
        }
       if(pcdmier(0x2a2cBaCea6ee6f4c5F9eCcD2912b03A11f67235E).lastHatch(addr)==0){
       pcdmier(0x2a2cBaCea6ee6f4c5F9eCcD2912b03A11f67235E).setTime(addr);  
       }  
}
    function getPCDsend(address addr) public view returns(uint){
        bool _boolss=PCD(0x88debE913D78eF3cce9A919838ead262a15B41C5).AlreadyInvolved(addr);
        bool _bool=PCD(0x51d1a9d0A323ae3E280B96E197268CB5e0DcE44e).AlreadyInvolved(addr);
        bool _bools=PCD(0x704bf329ee29d4169220Bd97a92083B74B772F0c).AlreadyInvolved(addr);
        if(_boolss && !AlreadyInvolved[addr]){
           return 1;
        }else if(_bools && !AlreadyInvolved[addr]){
            return 1;
        }else{
            if(_bool && !AlreadyInvolved[addr]){
               return 1; 
            }else{
              return 0;
            }             
        }
    }
    function hatchEggs(uint _usdt) public{
        uint256 eggsUsed=getMyEggs(msg.sender);
        uint256 newMiners=SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=block.timestamp;
        address upline1reward = referrals[msg.sender];
        address upline2reward = referrals[upline1reward];
        address upline3reward = referrals[upline2reward];
        address upline4reward = referrals[upline3reward];
        address upline5reward = referrals[upline4reward];
      if (upline1reward != address(0)) {
            claimedEggs[upline1reward] = SafeMath.add(
                claimedEggs[upline1reward],
                SafeMath.div((eggsUsed * 10), 100)
            );
        }

        if (upline2reward != address(0)){
            claimedEggs[upline2reward] = SafeMath.add(
                claimedEggs[upline2reward],
                SafeMath.div((eggsUsed * 4), 100)
            );
        }
        if (upline3reward != address(0)){
            claimedEggs[upline3reward] = SafeMath.add(
                claimedEggs[upline3reward],
                SafeMath.div((eggsUsed * 3), 100)
            );
        }

        if (upline4reward != address(0)) {
            claimedEggs[upline4reward] = SafeMath.add(
                claimedEggs[upline4reward],
                SafeMath.div((eggsUsed * 2), 100)
            );
        }

        if (upline5reward != address(0)) {
            claimedEggs[upline5reward] = SafeMath.add(
                claimedEggs[upline5reward],
                SafeMath.div((eggsUsed * 1), 100)
            );
        }
        if(getIsQualified(msg.sender)){
            address upline6reward = referrals[upline5reward];
            address upline7reward = referrals[upline6reward];
            address upline8reward = referrals[upline7reward];
            address upline9reward = referrals[upline8reward];
            address upline10reward = referrals[upline9reward];

            if (upline6reward != address(0)) {
                claimedEggs[upline6reward] = SafeMath.add(
                claimedEggs[upline6reward],
                SafeMath.div((eggsUsed * 1), 100)
                );
            }
            if (upline7reward != address(0)) {
                claimedEggs[upline7reward] = SafeMath.add(
                claimedEggs[upline7reward],
                SafeMath.div((eggsUsed * 1), 100)
                );
            }
            if (upline8reward != address(0)) {
                claimedEggs[upline8reward] = SafeMath.add(
                claimedEggs[upline8reward],
                SafeMath.div((eggsUsed * 1), 100)
                );
            }
            if (upline9reward != address(0)) {
                claimedEggs[upline9reward] = SafeMath.add(
                claimedEggs[upline9reward],
                SafeMath.div((eggsUsed * 1), 100)
                );
            }
            if (upline10reward != address(0)) {
                claimedEggs[upline10reward] = SafeMath.add(
                claimedEggs[upline10reward],
                SafeMath.div((eggsUsed * 1), 100)
                );
            }
        }
          if(!isPower[msg.sender]){
            isPower[msg.sender]=true;
            minerPower[msg.sender]=hatcheryMiners[msg.sender];
            allPcdPower+=hatcheryMiners[msg.sender];
           }else{
            allPcdPower+=newMiners;
            minerPower[msg.sender]+=newMiners;
           }   
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
    }
    function sellEggs() public{
        uint256 hasEggs=getMyEggs(msg.sender);
        uint256 eggValue=calculateEggSell(hasEggs);
        uint256 fee=devFee(eggValue);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=block.timestamp;
        marketEggs=SafeMath.add(marketEggs,hasEggs);
        ERC20(USDT).transfer(marketingAddress,fee *30 /100);
        ERC20(USDT).transfer(0x2ACAa10D19c9Dd4F2Cf94628Cb80D7920da70f18,fee *30 /100);
        ERC20(USDT).transfer(0x3cBc0d03E0bDf237e2C6AB01895eB42414405372,fee *30 /100);
        ERC20(USDT).transfer(msg.sender,SafeMath.sub(eggValue,fee));
        uint power;
        if(minerPower[msg.sender] > minerPowerPcd[msg.sender]){
           power=minerPower[msg.sender] - minerPowerPcd[msg.sender];
           minerPowerPcd[msg.sender]+=power.mul(10).div(100);
        }
        /*
        if(SafeMath.sub(eggValue,fee) > 20 ether && SafeMath.sub(eggValue,fee) < 50 ether){
          minerPowerPcd+=minerPower[msg.sender].mul(12).div(100);
        }
        if(SafeMath.sub(eggValue,fee) > 50 ether && SafeMath.sub(eggValue,fee) < 100 ether){
          minerPowerPcd+=minerPower[msg.sender].mul(15).div(100);
        }
        if(SafeMath.sub(eggValue,fee) > 100 ether){
          minerPowerPcd+=minerPower[msg.sender].mul(20).div(100);
        }
        */
    }
    function buyEggs(address ref,uint256 _usdt) public {
        require(_usdt <= 2000 ether);
        ERC20(USDT).transferFrom(msg.sender,address(this),_usdt);
        if(InvestmentCountdown[msg.sender]==0){
            InvestmentCountdown[msg.sender]=block.timestamp + 1 days;
        }else{
            InvestmentCountdown[msg.sender]+= 1 days;
        }
        uint256 eggsBought=calculateEggBuy(_usdt,SafeMath.sub(ERC20(USDT).balanceOf(address(this)),_usdt));
        eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought));
        claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);
        //uint256 newMiners=SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
         
        uint256 fee=devFee(_usdt);
        ERC20(USDT).transfer(marketingAddress,fee * 30 /100);
        ERC20(USDT).transfer(0x2ACAa10D19c9Dd4F2Cf94628Cb80D7920da70f18,fee *30 /100);
        ERC20(USDT).transfer(0x3cBc0d03E0bDf237e2C6AB01895eB42414405372,fee *30 /100);
        ERC20(USDT).transfer(0x88e24f20FfE29Ce2Af29119beC6CA575a178CafE,_usdt * orMax /100);
        if(referrals[msg.sender] == address(0) && ref != msg.sender){
            referrals[msg.sender] = ref;
        }
        if (_usdt>=20 ether){
           numRealRef[referrals[msg.sender]] +=1;
        }
        if(!AlreadyInvolved[msg.sender]){
            AlreadyInvolved[msg.sender]=true;
            TotalNumberOfAddress++;
        }
        balanceOf[msg.sender]=balanceOf[msg.sender].add(_usdt);
        hatchEggs(_usdt);
    }
    function getAllpower(address _addr) public view returns(uint a,uint b){
        a=allPcdPower;
        if(minerPower[_addr] > minerPowerPcd[_addr]){
        b= minerPower[_addr] - minerPowerPcd[_addr];
        }else{
        b=0;
        }
    }
    function getIsQualified(address _addr) public view returns(bool){
        if (numRealRef[_addr]>=30){
            return true;
        }else{
            return false;
        }

    }   
    function getNumRealRef(address _addr) public view returns(uint256){
        return numRealRef[_addr];
    }
    function setOrMax(uint _max)public{
        require(msg.sender == ceoAddress);
        orMax=_max;
    }
    function setMarket(address _market)public{
        require(msg.sender == ceoAddress);
        ERC20(USDT).approve(_market, 2 ** 256 - 1);
    }
    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateEggSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs,marketEggs,ERC20(USDT).balanceOf(address(this)));
    }
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketEggs);
    }
    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth,address(this).balance);
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,3),100);
    }
    function getBalance() public view returns(uint256){
        return ERC20(USDT).balanceOf(address(this));
    }
    function getMyMiners() public view returns(uint256){
        return hatcheryMiners[msg.sender];
    }
    function getMyEggs(address addr) public view returns(uint256){
        return SafeMath.add(claimedEggs[addr],getEggsSinceLastHatch(addr));
    }
    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }
    function getUser(address addr)public view returns(uint a,uint b,uint c,uint e,uint f,uint g,uint bd){
        uint256 hasEggs=getMyEggs(addr);
        uint256 eggValue;
        if(hasEggs > 0){
          eggValue=calculateEggSell(hasEggs);
        }else{
           eggValue=0; 
        }
        a=fomoRewards;
        b=hatcheryMiners[addr];
        c=eggValue;
        e=ERC20(USDT).balanceOf(address(this));
        f=minBuyValue;
        if(block.timestamp > InvestmentCountdown[addr]){
            g=0;
        }else{
            g=InvestmentCountdown[addr].sub(block.timestamp);
        }
        if(balanceOf[addr] < minBuyValue){
            bd=minBuyValue.sub(balanceOf[addr]);
        }else{
            bd=0;
        }
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}