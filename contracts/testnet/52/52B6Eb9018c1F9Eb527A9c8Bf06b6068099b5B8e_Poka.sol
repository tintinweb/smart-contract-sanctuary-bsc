//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract  Poka {
    address  token = 0x2A1e9A4dc7918444568E325293846D234bD84f60;
    uint256 token_coins;
    function transTo(address to,uint256 amount) external {
        IERC20(token).transferFrom(msg.sender,to,amount);
    }
    struct Broker{
        address parent;
        uint8 level;
        address[] follows;
        uint256 counts;
    }
   uint32[15] public belv=[3,4,5,8,10,20,30,60,80,100,125,175,250,500,1000];
   string[15] public flag =["1-6","1-5","1-4","1-3","1-2","2-6","2-5","2-4","2-3","3-6","3-5","3-4","4-6","4-5","5-6"];
   mapping(address=>Broker) public  brokers;
   mapping(address=>bool) actives;
   mapping(address=>uint256) public userAmount;
function invite(address node) external {
       address account = msg.sender;
       Broker storage  b = brokers[account] ;
       require(!actives[node]," address has been active!");
       b.level = 0;
       b.follows.push(); 
       b.follows[b.counts] = node;
       b.counts ++ ;
       b.parent = account;
       actives[node] =true;
    }
function inviteList(address input) public view returns(address[] memory){
    return brokers[input].follows;
}
function activeAcc() external{
    require(!actives[msg.sender],"acc is aready acitved!");
    actives[msg.sender] = true ;
}
function totalCoins() public view returns(uint256){
    return IERC20(token).balanceOf(address(this));
}
 function transToken(uint256 amount) external {
        userAmount[msg.sender] = amount;
        IERC20(token).transferFrom(msg.sender,address(this),amount);
    }
function getrandom(uint256 k) internal view returns(uint32[15] memory){
    uint32[15] memory temp_bl;
    uint8 len = 0;
    uint256 seed = 188 ;
    while(len < 15) 
    {
        uint8 key = uint8(uint256(keccak256(abi.encodePacked(block.timestamp,seed ))) % 15);
        bool exists = false;
        uint32 value = belv[key];
        for(uint256 j =0 ;j<15 ;j++)
        {
            if (value == temp_bl[j])
            {
                exists =true;
                break ;
            }
        }
        if(!exists){ 
            temp_bl[len] = value;   
            len ++;
        }   
        seed ++ ;        
    }
    return temp_bl;
}

function betm(uint8 yz,uint8 ma) public view returns(uint16 key,uint32 won,string memory ff){
  uint256 k = 344;
  uint32[15] memory temp = getrandom(k);
  uint16 key = uint16(uint256(keccak256(abi.encodePacked(block.timestamp,k ))) % 1000);
  uint16[15] memory gl =[300,220,190,100,80,40,25,13,10,7,6,3,3,2,1];
  uint16 po ;
  uint16 total;
  uint8 index;
  uint32 won;
  string memory ff;
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
  uint8 index2;
  for(uint8 i =0 ;i < 15 ;i++)
  {
    if(temp[i] == belv[index])
    {
        ff = flag[i];
        index2 = i;
    }
        
  }
  if (ma == temp[index2])
    won = yz* ma ;
  return(key,won,ff);
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