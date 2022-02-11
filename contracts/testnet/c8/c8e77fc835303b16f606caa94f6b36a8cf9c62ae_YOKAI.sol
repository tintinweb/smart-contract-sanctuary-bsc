/**
 *Submitted for verification at BscScan.com on 2022-02-10
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

contract YOKAI {
    
    address yurei = 0x9cf3b3cf6a8d995d148ace610a8495721fd14666; 
    uint256 public HUMAN_TO_HUNT_1=1440000;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    address public ceoAddress1;
    address public ceoAddress2;
    mapping (address => uint256) public huntHumans;
    mapping (address => uint256) public claimedMoneys;
    mapping (address => uint256) public lastClaim;
    mapping (address => address) public referrals;
    uint256 public marketHumans;
    constructor() public{
        ceoAddress=msg.sender;
        ceoAddress1=address(0xc55E00a32F4A0bbf587F625f5eeb933eEde40e41);
        ceoAddress2=address(0x5Ce568aB18d29de411D8D9fB19C8416ce38bBeF7);
    }
    function harvestHumans(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 printerUsed=getMyHuman();
        uint256 newPrinters=SafeMath.div(printerUsed,HUMAN_TO_HUNT_1);
        huntHumans[msg.sender]=SafeMath.add(huntHumans[msg.sender],newPrinters);
        claimedMoneys[msg.sender]=0;
        lastClaim[msg.sender]=now;
        
        claimedMoneys[referrals[msg.sender]]=SafeMath.add(claimedMoneys[referrals[msg.sender]],SafeMath.div(printerUsed,10));

        marketHumans=SafeMath.add(marketHumans,SafeMath.div(printerUsed,5));
    }
    function huntHumans() public {
        require(initialized);
        uint256 hasHuman=getMyHuman();
        uint256 HumanValue=calculateMoneyClaim(hasHuman);
        uint256 fee=devFee(HumanValue);
        uint256 fee2=fee/3;
        claimedMoneys[msg.sender]=0;
        lastClaim[msg.sender]=now;
        marketHumans=SafeMath.add(marketHumans,hasHuman);
        ERC20(yurei).transfer(ceoAddress, fee2);
        ERC20(yurei).transfer(ceoAddress1, fee2);
        ERC20(yurei).transfer(ceoAddress2, fee2);
        ERC20(yurei).transfer(address(msg.sender), SafeMath.sub(HumanValue,fee));
    }
    function buyYokai(address ref, uint256 amount) public {
        require(initialized);
    
        ERC20(yurei).transferFrom(address(msg.sender), address(this), amount);
        
        uint256 balance = ERC20(yurei).balanceOf(address(this));
        uint256 YokaiBought=calculatePrinterBuy(amount,SafeMath.sub(balance,amount));
        YokaiBought=SafeMath.sub(YokaiBought,devFee(YokaiBought));
        uint256 fee=devFee(amount);
        uint256 fee2=fee/5;
        ERC20(yurei).transfer(ceoAddress, fee2);
        ERC20(yurei).transfer(ceoAddress1, fee2);
        ERC20(yurei).transfer(ceoAddress2, fee2);
        claimedMoneys[msg.sender]=SafeMath.add(claimedMoneys[msg.sender],YokaiBought);
        harvestHumans(ref);
    }
    //magic happens here
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateMoneyClaim(uint256 printers) public view returns(uint256) {
        return calculateTrade(printers,marketHumans,ERC20(yurei).balanceOf(address(this)));
    }
    function calculatePrinterBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketHumans);
    }
    function calculatePrinterBuySimple(uint256 eth) public view returns(uint256){
        return calculatePrinterBuy(eth,ERC20(yurei).balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,5),100);
    }
    function seedMarket(uint256 amount) public {
        require(msg.sender == ceoAddress);
        ERC20(yurei).transferFrom(address(msg.sender), address(this), amount);
        require(marketHumans==0);
        initialized=true;
        marketHumans=144000000000;
    }
    function getBalance() public view returns(uint256) {
        return ERC20(yurei).balanceOf(address(this));
    }
    function getMyHumans() public view returns(uint256) {
        return huntHumans[msg.sender];
    }
    function getMyHuman() public view returns(uint256) {
        return SafeMath.add(claimedMoneys[msg.sender],getHumansSinceLastHunt(msg.sender));
    }
    function getHumansSinceLastHunt(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(HUMAN_TO_HUNT_1,SafeMath.sub(now,lastClaim[adr]));
        return SafeMath.mul(secondsPassed,huntHumans[adr]);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}