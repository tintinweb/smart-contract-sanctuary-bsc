/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// File: contracts/stakingContract.sol



pragma solidity  >=0.7.0 <0.9.0;


contract newBnbMiner{
    //uint256 BNB_PER_STAKE_PER_SECOND=1;
    uint256 public BNB_TO_STAKE=1;//for final version should be seconds in a day.
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
        address ceoAddress;
        address ceoAddress2 = 0xd6f35b52F8678bA4cD45Cbb55353f0eF36d4Bf45;

    mapping (address => uint256) public stakedBNB;
    mapping (address => uint256) public claimedBNB;
    mapping (address => uint256) public lastPlay;
    mapping (address => address) public referrals;
    uint256 public marketBNB;
    
    constructor() {

        ceoAddress=msg.sender;

    }
    function playBNB(address ref) public{
        require(initialized);
        if(ref == msg.sender) {
            ref = address(0);
        }
        if(referrals[msg.sender]==address(0) && referrals[msg.sender]!=msg.sender){
            referrals[msg.sender]=ref;
        }
        uint256 BNBUsed=getMyBNB();
        uint256 newStake= BNBUsed/BNB_TO_STAKE;
        stakedBNB[msg.sender]=stakedBNB[msg.sender]+newStake;
        claimedBNB[msg.sender]=0;
        lastPlay[msg.sender]=block.timestamp;
        

        claimedBNB[referrals[msg.sender]]=(claimedBNB[referrals[msg.sender]]+(BNBUsed/10));
        

        marketBNB=marketBNB+(BNBUsed/5);
    }
    function sellBNB() public payable {
        require(initialized);
        uint256 hasBNB=getMyBNB();
        uint256 BNBValue=calculateBNBell(hasBNB);
        uint256 fee=devFee(BNBValue);
        uint256 fee2=fee/2;
        claimedBNB[msg.sender]=0;
        lastPlay[msg.sender]=block.timestamp;
        marketBNB=marketBNB+hasBNB;
        payable(ceoAddress).transfer(fee2);
        payable(ceoAddress2).transfer(fee2);
        payable(msg.sender).transfer(BNBValue-fee);
    }
    function buyBNB(address ref) public payable{
        require(initialized);
        uint256 BNBBought=calculateBNBBuy(msg.value,(address(this).balance-msg.value));
        BNBBought=BNBBought-devFee(BNBBought);
        uint256 fee=devFee(msg.value);
        uint256 fee2=fee/2;
        payable(ceoAddress).transfer(fee2);
        payable(ceoAddress2).transfer(fee2);
        claimedBNB[msg.sender]=claimedBNB[msg.sender]+BNBBought;
        playBNB(ref);
    }


    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){

        return (PSN*bs)/(PSNH+((PSN*rs)+(PSNH*rt))/rt);
    }
    function calculateBNBell(uint256 BNB) public view returns(uint256){
        return calculateTrade(BNB,marketBNB,address(this).balance);
    }
    function calculateBNBBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketBNB);
    }
    function calculateBNBBuySimple(uint256 eth) public view returns(uint256){
        return calculateBNBBuy(eth,address(this).balance);
    }
    function devFee(uint256 amount) public pure returns(uint256){
        uint256 tax = (5 * amount)/100;
        return tax;
    }
    function seedMarket() public payable{
        require(marketBNB==0);
        initialized=true;
        marketBNB=86400000000;
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyVHS() public view returns(uint256){
        return stakedBNB[msg.sender];
    }
    function getMyBNB() public view returns(uint256){
        return claimedBNB[msg.sender]+getBNBSinceLastPlay(msg.sender);
    }
    function getBNBSinceLastPlay(address adr) public view returns(uint256){
        uint256 secondsPassed=min(BNB_TO_STAKE,block.timestamp-lastPlay[adr]);
        return secondsPassed*stakedBNB[adr];
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}