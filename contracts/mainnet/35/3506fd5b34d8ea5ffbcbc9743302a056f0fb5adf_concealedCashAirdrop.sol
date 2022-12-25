/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

pragma solidity >= 0.4.24;

interface token {
    function transfer(address receiver, uint amount) external;
    function balanceOf(address tokenOwner) constant external returns (uint balance);
}

contract concealedCashAirdrop {
    mapping(address => uint) public lastdate;
	
    string public  name = "Concealed Cash Airdrop";
    string public symbol = "CCFFAIR";
    string public comment = "Concealed Cash BSC Airdrop for Early Holders and Testers";
    string public note1 = "Do not send amounts for this contract";
    string public note2 = "It only requires the miner transaction fee to send the airdrop"; 
    token public tokenReward = token(0x069eA0A7C247f127007f30e7A2b56F3099822777);
    address releaseWallet = address(0x3C863847F4255C5C6d64518b780c254711E78103);
	
    function () payable external {        
        uint stockSupply = tokenReward.balanceOf(address(this));
        require(stockSupply >= 10000*(10**9),"Airdrop Ended");
	    require(now-lastdate[address(msg.sender)] >= 1 days,"Airdrop enable once a day");
	    lastdate[address(msg.sender)] = now;		
        tokenReward.transfer(msg.sender, 10000*(10**9));
        if (address(this).balance > 3*(10**15)) {
          if (releaseWallet.send(address(this).balance)) {
          }   
        }     			
    }
}