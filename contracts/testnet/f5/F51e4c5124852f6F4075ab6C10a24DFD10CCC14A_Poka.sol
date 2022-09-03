//SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
pragma solidity ^0.8.0;
contract  Poka {
   address token = 0xE97F46C26ef27eeDCfB9bf705f33436A30A68346;
   uint128 public id  = 1000;
   uint16[15] public belv = [3,4,5,8,10,20,30,60,80,100,125,175,250,500,1000];
   uint16[15] public gl = [300,220,190,100,80,40,25,13,10,7,6,3,3,2,1];
   mapping(address=>uint256[]) public userIds;
   mapping(uint256=>Game) public idGames;
   mapping(address=>uint256) public userAmount;
   event logBl(uint16 key,uint8 findex,uint16[15] temp);
   event logSZ(uint16 won,uint16 yzs,uint16 yzbl);
   struct Game{
        uint128 id;
        uint16 key;
        uint16 bl;
        uint16 btem;
        uint16 findex;
        uint16 won;
    }
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
   uint16 amount;
   uint16 yzs;
   uint16 key;
   uint16 bl;
   uint16 won;
   uint8 findex;
   uint8 index;
   uint16[15] memory temp;
   address addr = msg.sender ;
   require(btms.length == 15,"arrays length is wrong!");      
   key = uint16(uint256(keccak256(abi.encodePacked(block.timestamp, btms[0].length *171 +3 ))) % 1000);
  for(uint8 i; i< 15;i++)
  {
     temp[i] = btms[i][0];
     amount += btms[i][1];
     po += gl[i];
    if(index == 0 )
      if(key <= po)
        index = i ;
  }
  require(userAmount[addr] >= amount ,"betm amount cannot greater than balance");
  userAmount[addr] -= amount ;
   Game storage game  = idGames[id]; 
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
    game.btem = amount;
    game.bl = bl;
    game.findex = findex;
    userIds[addr].push(id);
    userAmount[addr] += won;
    id ++;
    emit logSZ(won,yzbl,amount);
    emit logBl(key,findex,temp);
}
function recharge(uint256 amount) external {
    userAmount[msg.sender] += amount ;
    IERC20(token).transferFrom(msg.sender,address(this),amount);
}
function withdraw(uint256 amount) external{
    require(amount <= userAmount[msg.sender],"withdrawl amount cannot greater than balance!");
    userAmount[msg.sender] -= amount;
    IERC20(token).transferFrom(address(this),msg.sender,amount);
}
function getGl() public view returns(uint16[15] memory){
    return gl;
}
function getBelv() public view returns(uint16[15] memory){
    return belv;
}
function getUserIds(address addr) public view returns(uint256[] memory)
{
    return userIds[addr];
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