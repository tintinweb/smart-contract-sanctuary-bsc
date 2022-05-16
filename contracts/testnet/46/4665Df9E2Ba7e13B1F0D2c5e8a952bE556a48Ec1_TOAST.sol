// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; // solhint-disable-line

contract TOAST{
    //uint256 EGGS_PER_MINERS_PER_SECOND=1;
    uint256 public EGGS_TO_HATCH_1MINERS=864000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    uint256 public minBuyValue=50000000000000000;
    address public marketingAddress;

    bool public initialized=false;
    address public ceoAddress;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    mapping (address => uint256) public numRealRef;
    uint256 public marketEggs;

    uint256 public fomoTime;
    address public fomoAddress;
    uint256 public fomoNeededTime = 28800;
    uint256 public fomoRewards;
    uint256 public timeLock = 1750866480;
    mapping(address => bool) public isWhiteList;
    bool whiteListNeeded = true;
    bool public isFomoFinished = false;
    constructor() public{
        ceoAddress=msg.sender;
        marketingAddress = 0x1fF2528171F10f17D0Bf4BeBD350980ae99C090b;
        isWhiteList[ceoAddress] = true;
    }
    function hatchEggs(address ref) public{
        require(initialized);
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        uint256 eggsUsed=getMyEggs();
        uint256 newMiners=SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=block.timestamp;

        // uplingAddress
        address upline1reward = referrals[msg.sender];
        address upline2reward = referrals[upline1reward];
        address upline3reward = referrals[upline2reward];
        address upline4reward = referrals[upline3reward];
        address upline5reward = referrals[upline4reward];

        //send referral eggs
        // claimedEggs[upline1reward]=SafeMath.add(claimedEggs[upline1reward],SafeMath.div(SafeMath.mul(eggsUsed,13),100));


        //send referral eggs
        if (upline1reward != address(0)) {
            claimedEggs[upline1reward] = SafeMath.add(
                claimedEggs[upline1reward],
                SafeMath.div((eggsUsed * 10), 100)
            );
        }

        if (upline2reward != address(0)) {
            claimedEggs[upline2reward] = SafeMath.add(
                claimedEggs[upline2reward],
                SafeMath.div((eggsUsed * 4), 100)
            );
        }
        if (upline3reward != address(0)) {
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







        //boost market to nerf miners hoarding
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
    }
    function sellEggs() public{
        require(initialized);
        uint256 hasEggs=getMyEggs();
        uint256 eggValue=calculateEggSell(hasEggs);
        uint256 fee=devFee(eggValue);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=block.timestamp;
        marketEggs=SafeMath.add(marketEggs,hasEggs);
        payable(marketingAddress).transfer(fee);
        payable(msg.sender).transfer(SafeMath.sub(eggValue,fee));

    }

    function updateFomoFinished() private returns(bool){
        uint256 realTime = SafeMath.add(fomoNeededTime, fomoTime);
        if(!isFomoFinished){
            if(block.timestamp > realTime){
                isFomoFinished=true;
            }
        }
    }



    function buyEggs(address ref) public payable{
        require(initialized);
        require(msg.value >= minBuyValue, "Not Enough BNB");
        updateFomoFinished();


        if(!isFomoFinished){
            fomoAddress = msg.sender;
            fomoTime = block.timestamp;
            uint256 fomoPlusRewards = SafeMath.div(msg.value, 20);
            fomoRewards = SafeMath.add(fomoRewards,fomoPlusRewards);
        }

        if(whiteListNeeded){
            require(isWhiteList[msg.sender] == true, "You are not on the whitelist");
        }

        uint256 eggsBought=calculateEggBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought));
        uint256 fee=devFee(msg.value);
        payable(marketingAddress).transfer(fee);
        claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);

        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        if (msg.value>=100000000000000000){
            numRealRef[referrals[msg.sender]] +=1;

        }

        hatchEggs(ref);
    }

    function getFomoRewards() public  {
        require(msg.sender == fomoAddress);
        require(isFomoFinished);

        // (bool success, ) = payable(msg.sender).call{value: fomoRewards}("");
        payable(msg.sender).transfer(fomoRewards);
        // require(success == true, "Transfer failed.");

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

    function setFomoNeededTime(uint256 time) public{
        require(msg.sender == ceoAddress);
        fomoNeededTime = time;
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

    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateEggSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs,marketEggs,address(this).balance);
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
    function getMyMiners() public view returns(uint256){
        return hatcheryMiners[msg.sender];
    }
    function getMyEggs() public view returns(uint256){
        return SafeMath.add(claimedEggs[msg.sender],getEggsSinceLastHatch(msg.sender));
    }
    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
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