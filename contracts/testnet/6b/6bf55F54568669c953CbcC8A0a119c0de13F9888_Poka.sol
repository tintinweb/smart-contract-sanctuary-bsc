//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
contract  Poka {
   uint256 public id  =1000;
   uint16[15] public belv=[3,4,5,8,10,20,30,60,80,100,125,175,250,500,1000];
   uint16[15] public  gl =[300,220,190,100,80,40,25,13,10,7,6,3,3,2,1];
  // mapping(address=>Game[]) internal accGames; 
   mapping(address=>uint256) public userIds;
   mapping(uint256=>Game) public idGames;
   mapping(address=>uint16[15]) internal accBls;
   mapping(address=>bool) internal isFirst;
   uint8[15] public gen_keys;
    struct Game{
        uint256 id;
        uint16 key;
        uint16 cost;
        uint8 findex;
        uint8 ma;
        uint16 bl;
  //      uint16[15] temp;
        uint16 won;
        uint32 gtime;
    }
    function playGame(uint16 yzs, uint8 yzma) external {  
        id ++;
        Game storage game  = idGames[id];
        uint16[15] memory temp =  getrandom();
        (uint16 key,uint16 bl,uint16 won,uint8 findex) = betm(yzs,yzma,temp);
        game.id = id;
        game.key = key  ;
        game.cost = yzs ;
        game.won = won;
        game.findex = findex;
        game.ma = yzma;
        game.bl = bl;
  //      game.temp = temp ;
        game.gtime =uint32(block.timestamp);
        isFirst[msg.sender] = true;
        idGames[id] = game;
  //      userIds[msg.sender] = id;
    //    pushIn(accGames[msg.sender],game);
    }
    function pushIn(Game[] storage games,Game memory gm) private  {
        if(games.length == 3){
            for(uint8 i;i< games.length -1 ;i ++)
                games[i] = games [i+1];
            games.pop();
        }
        games.push(gm);
    }
function getrandom() public returns(uint16[15] memory tmp)  {
    uint16 bl ;
    if(!isFirst[msg.sender])
        tmp = belv;
    else 
        tmp = accBls[msg.sender];
    for(uint i;i < 15;i++)
    {
        uint8 key1 = uint8(uint256(keccak256(abi.encodePacked(block.timestamp,i))) % 15) ;
        uint8 key2 = uint8(uint256(keccak256(abi.encodePacked(block.timestamp,i+11))) % 15) ;
        if( key1 != key2 )
        {
            bl = tmp[key1];
            tmp[key1] = tmp[key2];
            tmp[key2] = bl;
        }    
        gen_keys[i] = key1;
    }
    accBls[msg.sender] = tmp ;
}
function betm(uint16 yz,uint8 ma,uint16[15] memory temp) public view returns(uint16 key,uint16 bl,uint16 won,uint8 findex){
  uint16 po;
  uint8 index;
  key = uint16(uint256(keccak256(abi.encodePacked(block.timestamp,yz+5))) % 1000);
  for(uint8 i; i< 15;i++)
  {
     po += gl[i];
    if(key <= po)
    {
        index = i ;
        break ;
    }
  }
  for(uint8 i;i < 15 ;i++)
  {
    if(temp[i] == belv[index])
    {
        findex = i;
        bl = temp[i] ;
        if( ma == bl)
            won = yz* ma ;
        break ;
    } 
  }
  return(key,bl,won,findex);
}

function getGl() public view returns(uint16[15] memory){
    return gl;
}
function getBelv() public view returns(uint16[15] memory){
    return belv;
}
/*
function getUserGame(address addr) public view returns(Game[] memory ){
    return accGames[addr];
}*/

function getAccBls(address addr) public view returns(uint16[15] memory){
    return accBls[addr];
}

function getGen_keys() public view returns(uint8[15] memory )
{
    return gen_keys;
}
}