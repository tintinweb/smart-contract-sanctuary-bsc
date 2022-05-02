/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/
/* 

░██╗░░░░░░░██╗███████╗░█████╗░██╗░░░░░████████╗██╗░░██╗  ███╗░░░███╗██╗███╗░░██╗███████╗██████╗░
░██║░░██╗░░██║██╔════╝██╔══██╗██║░░░░░╚══██╔══╝██║░░██║  ████╗░████║██║████╗░██║██╔════╝██╔══██╗
░╚██╗████╗██╔╝█████╗░░███████║██║░░░░░░░░██║░░░███████║  ██╔████╔██║██║██╔██╗██║█████╗░░██████╔╝
░░████╔═████║░██╔══╝░░██╔══██║██║░░░░░░░░██║░░░██╔══██║  ██║╚██╔╝██║██║██║╚████║██╔══╝░░██╔══██╗
░░╚██╔╝░╚██╔╝░███████╗██║░░██║███████╗░░░██║░░░██║░░██║  ██║░╚═╝░██║██║██║░╚███║███████╗██║░░██║
░░░╚═╝░░░╚═╝░░╚══════╝╚═╝░░╚═╝╚══════╝░░░╚═╝░░░╚═╝░░╚═╝  ╚═╝░░░░░╚═╝╚═╝╚═╝░░╚══╝╚══════╝╚═╝░░╚═╝
 */

pragma solidity ^0.4.26; // solhint-disable-line

contract WealthMiner{
    //uint256 REWARDS_PER_MINERS_PER_SECOND=1;
    uint256 public REWARDS_TO_HATCH_1MINERS=864000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public marketMaker;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedRewards;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    uint256 public marketRewards;
    constructor() public{
        marketMaker=msg.sender;
    }
    function compound(address ref) public{
        require(initialized);
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = marketMaker;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        uint256 rewardsUsed=getMyRewards();
        uint256 newMiners=SafeMath.div(rewardsUsed,REWARDS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedRewards[msg.sender]=0;
        lastHatch[msg.sender]=now;

        //send referral rewards
        claimedRewards[referrals[msg.sender]]=SafeMath.add(claimedRewards[referrals[msg.sender]],SafeMath.div(SafeMath.mul(rewardsUsed,8),100));

        //boost market to nerf miners hoarding
        marketRewards=SafeMath.add(marketRewards,SafeMath.div(rewardsUsed,5));
    }
    function withdraw() public{
        require(initialized);
        uint256 hasRewards=getMyRewards();
        uint256 rewardValue=calculateWithdraw(hasRewards);
        uint256 fee=devFee(rewardValue);
        claimedRewards[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketRewards=SafeMath.add(marketRewards,hasRewards);
        marketMaker.transfer(fee);
        msg.sender.transfer(SafeMath.sub(rewardValue,fee));
    }
    function invest(address ref) public payable{
        require(initialized);
        uint256 investAmount=calculateDeposit(msg.value,SafeMath.sub(address(this).balance,msg.value));
        investAmount=SafeMath.sub(investAmount,devFee(investAmount));
        uint256 fee=devFee(msg.value);
        marketMaker.transfer(fee);
        claimedRewards[msg.sender]=SafeMath.add(claimedRewards[msg.sender],investAmount);
        compound(ref);
    }

    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateWithdraw(uint256 rewards) public view returns(uint256){
        return calculateTrade(rewards,marketRewards,address(this).balance);
    }
    function calculateDeposit(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketRewards);
    }
    function calculateDepositSimple(uint256 eth) public view returns(uint256){
        return calculateDeposit(eth,address(this).balance);
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,2),100);
    }
    function seedMarket() public payable{
        require(msg.sender == marketMaker, 'invalid call');
        require(marketRewards==0);
        initialized=true;
        marketRewards=86400000000;
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyMiners() public view returns(uint256){
        return hatcheryMiners[msg.sender];
    }
    function getMyRewards() public view returns(uint256){
        return SafeMath.add(claimedRewards[msg.sender],getRewardsSinceLastHatch(msg.sender));
    }
    function getRewardsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsPassed=min(REWARDS_TO_HATCH_1MINERS,SafeMath.sub(now,lastHatch[adr]));
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