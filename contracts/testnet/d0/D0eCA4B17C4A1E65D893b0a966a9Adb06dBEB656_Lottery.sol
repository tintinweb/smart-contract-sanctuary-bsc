/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: MIT
pragma solidity   0.8.16;
contract Lottery{
      address public owner;
    uint256 totalAmount1 = 0;
    uint256 totalAmount2 = 0;
    uint256 totalAmount3 = 0;
     mapping (address=>bool)  user1;
     mapping (address=>bool) user2;
     mapping (address=>bool) user3;
     address[] _user1;
     address[] _user2;
     address[] _user3;
          constructor(){
       owner = msg.sender;
    }
     function joinLottery() public payable{
         require(msg.value == 0.1 ether,"value should be 0.1 bnb");
         require(msg.value == 0.5 ether,"value should be 0.5 bnb");
         require(msg.value == 1 ether ,  "value should be 1 bnb");
         if (msg.value == 0.1 ether){
         require (user1[msg.sender] == false,"user already participiant");
        _user1.push(msg.sender);
        user1[msg.sender] = true;
        payable(address(this)).transfer(msg.value);
        totalAmount1 = totalAmount1 + msg.value;
         }
         else if (msg.value == 0.5 ether)
         {
        require (user2[msg.sender] == false,"user already participiant");
        _user2.push(msg.sender);
        user2[msg.sender] = true;
        payable(address(this)).transfer(msg.value);
        totalAmount2 = totalAmount2 + msg.value;
         }
    
      else if   (msg.value == 1 ether)
         {
        require (user3[msg.sender] == false,"user already participiant");
        _user3.push(msg.sender);
        user3[msg.sender] = true;
        payable(address(this)).transfer(msg.value);
        totalAmount3 = totalAmount3 + msg.value;
         }
     }
    function random1() private view returns(uint){
        return  uint (keccak256(abi.encode(block.timestamp,  _user1)));
    }
    function random2() private view returns(uint){
        return  uint (keccak256(abi.encode(block.timestamp,  _user2)));
    }
        function random3() private view returns(uint){
        return  uint (keccak256(abi.encode(block.timestamp,  _user3)));
    }
    function pickWinner1() internal {
        require (_user1.length != 0 ,"No participient");
       uint index1 = random1() % _user1.length;
       uint256 winnerPrize = 85;
       winnerPrize = winnerPrize / 100;
       winnerPrize = winnerPrize * totalAmount1;
       totalAmount1 = totalAmount1 - winnerPrize;
        payable (_user1[index1]).transfer(winnerPrize);
        payable (owner).transfer(winnerPrize);
        _user1 = new address[](0);
    }
    function pickWinner2() internal {
        require (_user2.length != 0 ,"No participient");
       uint index2 = random1() % _user1.length;
       uint256 winnerPrize = 85;
       winnerPrize = winnerPrize / 100;
       winnerPrize = winnerPrize * totalAmount1;
       totalAmount1 = totalAmount1 - winnerPrize;
        payable (_user1[index2]).transfer(winnerPrize);
        payable (owner).transfer(winnerPrize);
        _user2 = new address[](0);
    }
        function pickWinner3() internal {
        require (_user1.length != 0 ,"No participient");
       uint index3 = random1() % _user3.length;
       uint256 winnerPrize = 85;
       winnerPrize = winnerPrize / 100;
       winnerPrize = winnerPrize * totalAmount1;
       totalAmount1 = totalAmount1 - winnerPrize;
        payable (_user1[index3]).transfer(winnerPrize);
        payable (owner).transfer(winnerPrize);
        _user3 = new address[](0);
    }
    function pickwinner(uint256 slot) public{
        require(slot <= 3 || slot != 0," slot 1,2,3");
        if (slot == 1){
            pickWinner1();
        }else if(slot == 2){
            pickWinner2();
        }else if(slot == 3){
            pickWinner3();
        }
    }
 }