/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

pragma solidity ^0.4.26; // solhint-disable-line

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract HORUS_GAME_TEST01 {
    //uint256 WorkerS_PER_MINERS_PER_SECOND=1;
    address busd = 0x235D44f7e023C5Ad0E9e0ca95Bb1FbD359dfEEE7; 
    uint256 public WorkerS_TO_HATCH_1MINERS=540000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    address public ceoAddress2;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedWorkers;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    uint256 public marketWorkers;
    constructor() public{
        ceoAddress=msg.sender;
        ceoAddress2=address(0xf618b62BcD502a66F5d2E9c74Dd1641090F2Fe01);
    }
    function hatchWorkers(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 WorkersUsed=getMyWorkers();
        uint256 newMiners=SafeMath.div(WorkersUsed,WorkerS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedWorkers[msg.sender]=0;
        lastHatch[msg.sender]=now;
        
        //send referral Workers
        claimedWorkers[referrals[msg.sender]]=SafeMath.add(claimedWorkers[referrals[msg.sender]],SafeMath.div(WorkersUsed,8));
        
        //boost market to nerf miners hoarding
        marketWorkers=SafeMath.add(marketWorkers,SafeMath.div(WorkersUsed,5));
    }
    function sellWorkers() public {
        require(initialized);
        uint256 hasWorkers=getMyWorkers();
        uint256 WorkerValue=calculateWorkerSell(hasWorkers);
        uint256 fee=devFee(WorkerValue);
        uint256 fee2=fee/2;
        claimedWorkers[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketWorkers=SafeMath.add(marketWorkers,hasWorkers);
        ERC20(busd).transfer(ceoAddress, fee2);
        ERC20(busd).transfer(ceoAddress2, fee-fee2);
        ERC20(busd).transfer(address(msg.sender), SafeMath.sub(WorkerValue,fee));
    }
    function buyWorkers(address ref, uint256 amount) public {
        require(initialized);
    
        ERC20(busd).transferFrom(address(msg.sender), address(this), amount);
        
        uint256 balance = ERC20(busd).balanceOf(address(this));
        uint256 WorkersBought=calculateWorkerBuy(amount,SafeMath.sub(balance,amount));
        WorkersBought=SafeMath.sub(WorkersBought,devFee(WorkersBought));
        uint256 fee=devFee(amount);
        uint256 fee2=fee/2;
        ERC20(busd).transfer(ceoAddress, fee2);
        ERC20(busd).transfer(ceoAddress2, fee-fee2);
        claimedWorkers[msg.sender]=SafeMath.add(claimedWorkers[msg.sender],WorkersBought);
        hatchWorkers(ref);
    }
    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateWorkerSell(uint256 Workers) public view returns(uint256) {
        return calculateTrade(Workers,marketWorkers,ERC20(busd).balanceOf(address(this)));
    }
    function calculateWorkerBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketWorkers);
    }
    function calculateWorkerBuySimple(uint256 eth) public view returns(uint256){
        return calculateWorkerBuy(eth,ERC20(busd).balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,10),100);
    }
    function seedMarket(uint256 amount) public {
        ERC20(busd).transferFrom(address(msg.sender), address(this), amount);
        require(marketWorkers==0);
        initialized=true;
        marketWorkers=54000000000;
    }
    function getBalance() public view returns(uint256) {
        return ERC20(busd).balanceOf(address(this));
    }
    function getMyMiners() public view returns(uint256) {
        return hatcheryMiners[msg.sender];
    }
    function getMyWorkers() public view returns(uint256) {
        return SafeMath.add(claimedWorkers[msg.sender],getWorkersSinceLastHatch(msg.sender));
    }
    function getWorkersSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(WorkerS_TO_HATCH_1MINERS,SafeMath.sub(now,lastHatch[adr]));
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