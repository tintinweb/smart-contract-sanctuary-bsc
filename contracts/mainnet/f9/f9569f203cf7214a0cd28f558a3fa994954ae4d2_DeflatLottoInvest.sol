/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

pragma solidity ^0.4.24;

interface token {
    function transfer(address receiver, uint amount) external;
    function balanceOf(address tokenOwner) constant external returns (uint balance);
}

contract DeflatLottoInvest {

  string public name = "Concealed Cash Lotto Pool";
  string public symbol = "CCFFLotto";
  string public prob = "Probability 1 of 10";
  string public comment = "Send 0.01 BNB to captalize CCFF and try to win 0.06 BNB";
  
  // Send only 0.01 BNB, other value will be rejected and not refundable;
  // The prize is drawn when the accumulated balance reaches 0.1 BNB
  // More 1/10000 of CCFF Lotto Pool balance is transfer to all quota sender 

  address[] internal playerPool;
  address public deployer = address(0x3C863847F4255C5C6d64518b780c254711E78103); //Deployer Address;
  token public tokenReward = token(0x069eA0A7C247f127007f30e7A2b56F3099822777);// CCFF Token contract;
  uint rounds = 10;
  uint quota = 0.01 * (10**18);
  uint reward;
  uint divUnits = 10000;
  event payout(address from, address to, uint quantity);
  event detailInfo(string detail);
  function () public payable {
   if (msg.value == quota) {
    playerPool.push(msg.sender);
    if (playerPool.length >= rounds) {
      uint baserand = (block.number-1)+now+block.difficulty;
      uint winidx = uint(baserand)/10;
      winidx = baserand - (winidx*10);   
      address winner = playerPool[winidx];
      uint amount = address(this).balance;
      if (winner.send(amount)) { emit payout(this, winner, amount);}
      reward = tokenReward.balanceOf(address(this))/divUnits;    
      if (reward > 0) { tokenReward.transfer(msg.sender, reward);} else {emit detailInfo('Lotto Pool is Empty');}  
      playerPool.length = 0;                
    } 
    else {
       if (playerPool.length < 5) {
           if (deployer.send(address(this).balance)) { emit payout(this, deployer, quota);}
       }
       reward = tokenReward.balanceOf(address(this))/divUnits;    
       if (reward > 0) { tokenReward.transfer(msg.sender, reward); } else {emit detailInfo('Lotto Pool is Empty');}
    }
   } else {
       emit detailInfo("Invalid Quota Value");
   }
  }
}