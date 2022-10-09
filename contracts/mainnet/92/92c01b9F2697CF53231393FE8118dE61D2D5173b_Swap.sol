/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

contract Swap{
    //0xc76474E324F17Ea9891aD1C1Bf736F5Ccf0dceb3
    address previous;
    address current;
    address manager;

    constructor(){
        manager = msg.sender;
    }

    function getUserInfo(address account) external view returns(uint previousAmount,bool isApprove){
        uint approveAmount = IERC20(previous).allowance(account, address(this));
        if(approveAmount >= 100000e18) isApprove = true;
        previousAmount = IERC20(previous).balanceOf(account);
    }

    function swap(address account,uint amount) external {
        require(account == msg.sender);
        require(IERC20(previous).transferFrom(account, address(this), amount),"TransferFrom failed");
        require(IERC20(current).transfer(account, amount),"Transfer failed");
        
    }

    function updateAddress(address _previous,address _current) external {
        require(manager == msg.sender);
        previous = _previous;
        current = _current;
    }

    function managerWithdraw(address to,uint amount) external {
        require(manager == msg.sender);
        require(IERC20(current).transfer(to, amount),"Transfer failed");
    }
}