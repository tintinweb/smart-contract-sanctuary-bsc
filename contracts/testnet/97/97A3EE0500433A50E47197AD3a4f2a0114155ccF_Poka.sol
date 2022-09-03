//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
contract  Poka {
   uint256 public id  =1000;
   uint16[15] public belv=[3,4,5,8,10,20,30,60,80,100,125,175,250,500,1000];
   uint16[15] public  gl =[300,220,190,100,80,40,25,13,10,7,6,3,3,2,1];
   mapping(address=>uint256[]) public userIds;
   mapping(uint256=>Game) public idGames;
   mapping(address=>uint16[15]) internal accBls;
   event logBl(uint16 key,uint8 findex,uint16[15] temp);
   event logSZ(uint8 len,uint16 yzs,uint16 yzbl);
    struct Game{
        uint256 id;
        uint16 key;
   //     uint16[][] bets;
        uint16 bl;
        uint16 findex;
        uint16 won;
    }
    /*
    function play(uint16[][] memory btms) external {  
        id ++;
        Game storage game  = idGames[id];
        (uint16 key,uint16 bl,uint16 won,uint8 findex) = runHorse(btms);
        game.id = id;
        game.key =key ;
    //    game.bets = btms;
        game.won = won;
        game.bl = bl;
        game.findex = findex;
        userIds[msg.sender].push(id);
        
    }*/
function newGame() public view returns(uint16[15] memory tmp) {
    uint16 bl ;
    tmp = belv;
    for(uint i;i < 30;i++)
    {
        uint8 key1 = uint8(uint256(keccak256(abi.encodePacked(block.timestamp,i))) % 15) ;
        uint8 key2 = uint8(uint256(keccak256(abi.encodePacked(block.timestamp,i+11))) % 15) ;
        if( key1 != key2 )
        {
            bl = tmp[key1];
            tmp[key1] = tmp[key2];
            tmp[key2] = bl;
        }    
    }
}
function runHorse(uint16[][] memory btms) external{
   uint16 po;
   uint16 yzbl;
   uint16 yzs;
   uint16 key;
   uint16 bl;
   uint16 won;
   uint8 findex;
   uint8 len = uint8(btms.length);
   uint8 index;
   uint16[15] memory temp;
   require(len == 15,"arrays length is wrong!");
   Game storage game  = idGames[id];        
   key = uint16(uint256(keccak256(abi.encodePacked(block.timestamp, btms[0].length *171 +3 ))) % 1000);
  for(uint8 i; i< 15;i++)
  {
    temp[i] = btms[i][0];
     po += gl[i];
    if(key <= po)
    {
        index = i ;
        break ;
    }
  }
   bl = belv[index];
    for(uint8 j;j< 15; j++)
    {
        yzbl = btms[j][0];
        yzs = btms[j][1];
        if(yzbl == bl){
            findex = j ;
            won = yzbl * yzs;
            break ;
        }
    } 
    game.id = id;
    game.key =key;
    game.won = won;
    game.bl = bl;
    game.findex = findex;
    userIds[msg.sender].push(id);
    id ++;
    emit logSZ(len,yzbl,yzs);
    emit logBl(key,findex,temp);
}
function getGl() public view returns(uint16[15] memory){
    return gl;
}
function getBelv() public view returns(uint16[15] memory){
    return belv;
}
function getAccBls(address addr) public view returns(uint16[15] memory){
    return accBls[addr];
}
function getUserIds(address addr) public view returns(uint256[] memory)
{
    return userIds[addr];
}
}