/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract ca{
    mapping (address => bool) public _authorized;
    modifier Authorized() {
        require(_authorized[msg.sender]==true);
        _;
    }
    function swapExactETHForTokensSupportingFeeOnTransferTokens(address Token,address[] memory Path,uint256[] memory Amounts ,uint Deadline) external payable Authorized(){
      
    }
    function swapETHForExactTokens(address Token,address[] memory Path,uint256[] memory Amounts,uint256[] memory AmountsOfTokens,uint deadline) external payable Authorized(){

    }
}