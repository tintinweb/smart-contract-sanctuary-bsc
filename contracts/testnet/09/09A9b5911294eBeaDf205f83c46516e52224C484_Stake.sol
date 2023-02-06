/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: 释放(1).sol


pragma solidity ^0.8;




contract Stake {
    //mu
    IERC20 public immutable muToken =  IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); 
  
    //可领取时间 必须从小到大
    uint256[] public  times;
    //对应times奖励
    uint256[]  public nums;
    //可提现用户
    mapping(address => bool) public whiteList;

    //[1678066499,1678066599,1678066699,1678066799,1678066899,1678066999,1678067199,1678067299,1678067399,1678067499,1678067599,1678067699]
    //[1000000000000000000,1000000000000000000,1000000000000000000,1000000000000000000,1000000000000000000,1000000000000000000,1000000000000000000,1000000000000000000,1000000000000000000,1000000000000000000,1000000000000000000,1000000000000000000]
    constructor(uint256[] memory _times,uint256[] memory _nums,address[] memory _white) {
        require(_times.length == _nums.length,"length error");
        require(_white.length == 2,"_white length error");
        times = _times;
        nums = _nums;
        whiteList[_white[0]] = true;
        whiteList[_white[1]] = true;
    }
    function  getReward() external 
     {
        require(whiteList[msg.sender],"You don't have permission");
        uint num = 0;
        for(uint256 i=0;i<times.length;i++){
           if(block.timestamp > times[i]){
                if( nums[i] > 0){
                    num += nums[i];
                    nums[i] = 0;      
                }              
            }else{
                break;
            }
        }
        
        require(num > 0, "There is no reward to claim");
        muToken.transfer(msg.sender, num);
        
    }
   

}