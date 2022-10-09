/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

    function getLastUserAndTime() external view returns(address customer,uint256 time);
    function getRecommendQuantity(address customer) external view returns(uint256);
    function getCurrentPrice() external view returns(uint256);
}


interface IFomo{
    function updateAmount(uint256 amount) external;
    function sendFomoRewardToWiner(address customer) external;
    function sendSurplusToMarketing() external;
}

contract Fomo{

    address tokenCsr;
    address surplus;
    address[] winers;
    mapping(address=>uint256) winerInfo;
    uint256 totalAmount;
    address manager;
    
    constructor(){
        manager = msg.sender;
        tokenCsr = 0xc76474E324F17Ea9891aD1C1Bf736F5Ccf0dceb3;
        surplus = 0x0173bb43C66069017222a12755D71945238867Aa;
    }

    modifier onlyTokenCsr(){
        require(tokenCsr == msg.sender || manager == msg.sender,"Fomo:No permit");
        _;
    }

    function updateAmount(uint256 amount) public onlyTokenCsr{
        totalAmount = totalAmount + amount;
    }

    function sendFomoRewardToWiner(address customer) public onlyTokenCsr{
        require(IERC20(tokenCsr).transfer(customer, totalAmount),"Fomo:Transfer failed");
        winers.push(customer);
        winerInfo[customer] = winerInfo[customer] + totalAmount;
        totalAmount = 0;
    }

    function sendSurplusToMarketing() public onlyTokenCsr{
        require(IERC20(tokenCsr).transfer(surplus, totalAmount),"Fomo:Transfer failed");
        totalAmount = 0;
    }   

    function getTotalFomo() public view returns(uint256){
        uint256 price = IERC20(tokenCsr).getCurrentPrice();
        return totalAmount * price / 1e9;
    }

    function getLastUserAndCounting() public view returns(address customer,uint256 time) {
        (address cueerntUser,uint256 currentTime) = IERC20(tokenCsr).getLastUserAndTime();
        customer = cueerntUser;
        if(block.timestamp - currentTime <= 86400){
            time = 86400 - (block.timestamp - currentTime);
        }   
    }

    function getAllWiners() public view returns(address[] memory wine,uint256 leng){
        wine = winers;
        leng = winers.length;
    }

    function getWinerAmount(address customer) public view returns(uint256){
        return winerInfo[customer];
    }

    function getRecommend(address customer) public view returns(uint256 amount){
        amount = IERC20(tokenCsr).getRecommendQuantity(customer);
    }

    function setAddresInfo(address token,address surp) public{
        require(manager == msg.sender,"Fomo:No permit");
        tokenCsr = token;
        surplus = surp;
    }
}