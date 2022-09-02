//SPDX-License-Identifier: KAISHANGUAI
pragma solidity ^0.8.0;
contract Goldgun{
   mapping(uint256=>Guncircle) public IdGunCirs;
   mapping(address=>uint256) public userAmount;
   mapping(address=>bool) private isInPlay;
   uint8 public allowMax;
   uint256 id;
    struct Guncircle{
        uint256 id;
        bool isFinished;
        uint8 aliveTotal;
        uint8 deadTotal;
        uint256 everyPer;
        uint256 depositTotal;
        uint8 playerid;
        mapping(uint8=>address) depostAddr;
    }
    constructor(){
        allowMax = 6;
        id = 10000 ;
    }
    function joinGuanCircle(uint256 deposit,address player) external{
        require(userAmount[player] >= deposit,"deposite amount greater than address balance.");
        require(!isInPlay[player],"addr has in the game!");
        Guncircle storage gc = IdGunCirs[id];
        gc.id = id ;
        gc.everyPer =deposit;
        gc.depositTotal +=deposit;
        gc.aliveTotal +=1;
        gc.playerid +=1;
        gc.depostAddr[gc.playerid] = player;
        userAmount[player] -= deposit;
        isInPlay[player] = true;
        if(gc.playerid == allowMax)
         fireGun(id);

    }
    function fireGun(uint256 gid) internal {
       Guncircle storage gc = IdGunCirs[gid]; 
      uint8 key;
      uint8[3] memory deadKeys;
      for(uint8 i; i< 3;++i)
      {
        key =uint8(uint256(keccak256(abi.encodePacked(block.timestamp, id * 137 +i))) % 6) ;
        deadKeys[i] =key;
        gc.deadTotal += 1;
      }
       for(uint8 i;i< 6;++i)
       {
        address addr = gc.depostAddr[i];
        uint8 dkey = deadKeys[i];
        if( i == dkey)
            continue;    
        userAmount[addr] += gc.depositTotal / 3 ;
      //  isInPlay[addr] = false ;
       }
       gc.isFinished = true;
       id ++;
       
    }
}