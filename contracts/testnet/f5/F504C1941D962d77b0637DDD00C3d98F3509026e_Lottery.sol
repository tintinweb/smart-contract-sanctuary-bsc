/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

pragma solidity ^0.4.21;

contract Lottery {
    struct Player {
      address reffer;
      uint weight;
    }
  address public manager;
  address[] public players;//in this lottery
  address[] public enteredPlayers;//in this contract
  mapping(address => Player) public playerInfo;//all players info
  mapping(address => uint ) public playerChance;//players chance  
  uint totalChance;




  constructor() public {
    manager = msg.sender;
  }

  function _enter() public payable {
    require(msg.value > .01 ether );
    require(msg.value < 1 ether );
    
    if (checkPlayerExists(msg.sender)){
        uint chance = (msg.value / 10**16) * (1+playerInfo[msg.sender].weight)/10;//- کارمزد
        playerChance[msg.sender] += chance;
        totalChance += chance;
    }else{
        players.push(msg.sender);
        enteredPlayers.push(msg.sender);
        playerInfo[msg.sender].weight=0;       
        playerChance[msg.sender] = (msg.value / 10**16);//- کارمزد
        totalChance += chance;
    }
    
  }


  function random() private view returns (uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, now, players)));
  }

  function pickWinner() public restricted {
      require(msg.sender == manager);
    uint index = random() % totalChance;
    uint sumChance =0;
    for(uint256 i = 0; i < players.length; i++ )
    {
        sumChance +=playerChance[players[i]];
        if (index <= sumChance)
        {
            index = i;
            break;
        }
    }
    uint gift = (address(this).balance/100)*95;    
    manager.transfer((address(this).balance/100)*5);

    if(players[index] != address(0))
        players[index].transfer(gift);
    
    for(uint j=0;i<players.length;i++)
        delete playerChance[players[j]];
    players = new address[](0);
  }

  function getPlayers() public view returns (address[]) {
    return players;
  }

  function checkPlayerExists(address player) public constant returns(bool){
      for(uint256 i = 0; i < players.length; i++){
         if(players[i] == player) return true;
      }
      return false;
   }

    function checkPlayerEnterd(address player) public constant returns(bool){
        for(uint256 i = 0; i < enteredPlayers.length; i++){
            if(enteredPlayers[i] == player) return true;
        }
        return false;
    }

   function addReffer(address refferalCode) public {
       require(checkPlayerEnterd(msg.sender));       
       require(playerInfo[msg.sender].reffer == address(0));
       require(checkPlayerEnterd(refferalCode));
       playerInfo[refferalCode].weight +=1;
       playerInfo[msg.sender].reffer=refferalCode;
       if (checkPlayerExists(refferalCode)){
           totalChance -=playerChance[msg.sender];
           uint newChance = ((playerChance[msg.sender] /(1+(playerInfo[msg.sender].weight-1)/10))* (1+(playerInfo[msg.sender].weight/10)));
           playerChance[msg.sender] = newChance;
           totalChance +=newChance;
       }
   }

  modifier restricted() {
    require(msg.sender == manager);
    _;
  }

  function stop() public {
      if(msg.sender == manager) selfdestruct(manager);
   }
}