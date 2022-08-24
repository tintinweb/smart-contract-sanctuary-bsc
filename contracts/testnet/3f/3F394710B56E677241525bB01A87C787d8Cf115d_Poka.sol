//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract  Poka {
   uint256 public id  =1000;
   uint16[15] public belv=[3,4,5,8,10,20,30,60,80,100,125,175,250,500,1000];
   uint16[15] public  gl =[300,220,190,100,80,40,25,13,10,7,6,3,3,2,1];
    mapping(address=>Game[]) public accGames;  
    struct Game{
        uint256 id;
        uint16 key;
        uint16 cost;
        uint8 findex;
        uint8 ma;
        uint16 bl;
        uint16[15] temp;
        uint16 won;
        uint32 gtime;
    }
    function playGame(uint16 yzs, uint8 yzma) external {
      
       id ++;
        Game memory game ;
        uint16[15] memory temp =getrandom();
        (uint16 key,uint16 bl,uint16 won,uint8 findex) = betm(yzs,yzma,temp);
        game.id = id;
        game.key = key  ;
        game.cost = yzs ;
        game.won = won;
        game.findex = findex;
        game.ma = yzma;
        game.bl = bl;
        game.temp =temp ;
        game.gtime =uint32(block.timestamp);
        pushIn(accGames[msg.sender],game);
    }
    function pushIn(Game[] storage games,Game memory gm) private  {
        if(games.length == 5){
            for(uint8 i;i< games.length -1 ;i++)
            {
                games[i] =games [i+1];
            }
            games.pop();
        }
        games.push(gm);
    }
function getrandom() public view returns(uint16[15] memory temp_bl){
    uint8 len;
    uint8[15] memory indexs;
    uint8 key;
    uint256 seed = 188;
    while(len < 15) 
    {
        key = uint8(uint256(keccak256(abi.encodePacked(block.timestamp,seed))) % 15);
        if(!findKey(indexs,key))
        {
            indexs[len] = key;
            temp_bl[len] = belv[key];
            len ++ ;
        }
        seed ++;
    }
}
 function findKey(uint8[15] memory arrs,uint8 key) internal pure  returns(bool isfind){
    for(uint8 i;i<arrs.length;i++){
        if( arrs[i] == key){
            isfind =true;
            break;
        }
    }
 }
function betm(uint16 yz,uint8 ma,uint16[15] memory temp) public view returns(uint16 key,uint16 bl,uint16 won,uint8 findex){
  uint16 po;
  uint16 total;
  uint8 index;
 
  key = uint16(uint256(keccak256(abi.encodePacked(block.timestamp,uint8(102)))) % 1000);
  for(uint8 i= 0;i< 15;i++)
     total += gl[i];
  for(uint8 i=0; i< 15;i++)
  {
     po += gl[i];
    if(key <= po)
    {
        index = i ;
        break ;
    }
  }
  for(uint8 i =0 ;i < 15 ;i++)
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

function getUserGame(address addr) public view returns(Game[] memory ){
    return accGames[addr];
}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}