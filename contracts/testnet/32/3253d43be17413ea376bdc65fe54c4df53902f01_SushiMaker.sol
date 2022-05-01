/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

/*
███████╗██╗   ██╗███████╗██╗  ██╗██╗    ███╗   ███╗ █████╗ ██╗  ██╗███████╗██████╗ 
██╔════╝██║   ██║██╔════╝██║  ██║██║    ████╗ ████║██╔══██╗██║ ██╔╝██╔════╝██╔══██╗
███████╗██║   ██║███████╗███████║██║    ██╔████╔██║███████║█████╔╝ █████╗  ██████╔╝
╚════██║██║   ██║╚════██║██╔══██║██║    ██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗
███████║╚██████╔╝███████║██║  ██║██║    ██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██║  ██║
╚══════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                                                                                   
*/
pragma solidity ^0.4.26; 

contract SushiMaker{
    uint256 public SUSHIS_TO_COOK=864000;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public itamaeAddress;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedSushis;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    uint256 public marketSushis;
    constructor() public{
        itamaeAddress=msg.sender;
    }
    function hatchSushis(address ref) public{
        require(initialized);
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = itamaeAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        uint256 sushisUsed=getMySushis();
        uint256 newMiners=SafeMath.div(sushisUsed,SUSHIS_TO_COOK);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedSushis[msg.sender]=0;
        lastHatch[msg.sender]=now;
        claimedSushis[referrals[msg.sender]]=SafeMath.add(claimedSushis[referrals[msg.sender]],SafeMath.div(SafeMath.mul(sushisUsed,13),100));
        marketSushis=SafeMath.add(marketSushis,SafeMath.div(sushisUsed,5));
    }
    function sellSushis() public{
        require(initialized);
        uint256 hasSushis=getMySushis();
        uint256 eggValue=calculateSushiSell(hasSushis);
        uint256 fee=devFee(eggValue);
        claimedSushis[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketSushis=SafeMath.add(marketSushis,hasSushis);
        itamaeAddress.transfer(fee);
        msg.sender.transfer(SafeMath.sub(eggValue,fee));
    }
    function buySushis(address ref) public payable{
        require(initialized);
        uint256 sushisBought=calculateSushiBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        sushisBought=SafeMath.sub(sushisBought,devFee(sushisBought));
        uint256 fee=devFee(msg.value);
        itamaeAddress.transfer(fee);
        claimedSushis[msg.sender]=SafeMath.add(claimedSushis[msg.sender],sushisBought);
        hatchSushis(ref);
    }
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateSushiSell(uint256 sushis) public view returns(uint256){
        return calculateTrade(sushis,marketSushis,address(this).balance);
    }
    function calculateSushiBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketSushis);
    }
    function calculateSushiBuySimple(uint256 eth) public view returns(uint256){
        return calculateSushiBuy(eth,address(this).balance);
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,4),100);
    }
    function openKitchen() public payable{
        require(msg.sender == itamaeAddress, 'invalid call');
        require(marketSushis==0);
        initialized=true;
        marketSushis=86400000000;
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyMiners() public view returns(uint256){
        return hatcheryMiners[msg.sender];
    }
    function getMySushis() public view returns(uint256){
        return SafeMath.add(claimedSushis[msg.sender],getSushisSinceLastHatch(msg.sender));
    }
    function getSushisSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsPassed=min(SUSHIS_TO_COOK,SafeMath.sub(now,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
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