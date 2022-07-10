/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

contract ShopXU{

    address public owner;
    IERC20 public tokenXu;
    uint public buyRatio = 10000000;   // 1 BNB = 10000000 XU                                           
    uint public sellRatio = 9990000;   // 1 BNB = 9990000 XU
    uint public min_BNB = 10**14;       // 0.0001 BNB
    uint public min_XU = 100;

    constructor(address _xu){
        owner = msg.sender;
        tokenXu = IERC20(_xu);
    }

    modifier checkOwner(){
        require(msg.sender==owner, "Sorry, you are not allowed");
        _;
    }

    function buyXU() public payable{
        require(msg.value>=min_BNB, "Sorry, minimum BNB is 0.0001 BNB");
        uint amountToken = msg.value*buyRatio;
        require(tokenXu.balanceOf(address(this))>=amountToken, "Sorry we dont have XU enought to sell");
        tokenXu.transfer(msg.sender, msg.value*buyRatio);
    }

    function sellXU(uint amountXU) public{
        require(tokenXu.balanceOf(msg.sender)>=amountXU*10**18, "Sorry, you dont have XU enought to sell");
        require(amountXU>=min_XU, "Sorry, minimum XU is 100");
        require(tokenXu.allowance(msg.sender, address(this))>=amountXU*10**18, "Please approve XU before sell");
        tokenXu.transferFrom(msg.sender, address(this), amountXU*10**18);
        uint amountBNB = amountXU*10**18 / sellRatio;
        require(address(this).balance>=amountBNB, "Sorry, we dont have BNB enought");
        payable(msg.sender).transfer(amountBNB);
    }

    function withdraw() public checkOwner{
        if(address(this).balance>0){
            payable(owner).transfer(address(this).balance);
        }
        if(tokenXu.balanceOf(address(this))>0){
            tokenXu.transfer(owner, tokenXu.balanceOf(address(this)));
        }
    }

}