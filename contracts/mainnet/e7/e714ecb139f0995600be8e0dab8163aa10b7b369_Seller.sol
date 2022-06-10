/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: Unlicensed

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}

interface IRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract Seller {
    mapping (address => bool) private _auth;
    uint256 depositId;
    modifier onlyAuth() {
        require(_auth[msg.sender], "Access Forbidden");
        _;
    }
    
    constructor() {
        _auth[msg.sender] = true;
    }
    
    function Allow(address a) public onlyAuth() {
        _auth[a] = true;
    }
    
    function Deny(address a) public onlyAuth() {
        _auth[a] = false;
    }
    function isAllowed(address a) public view returns (bool) {
        return _auth[a];
    }
    
    
    receive() external payable { }
       
    function ApprovePCS(address c) public onlyAuth() returns (bool) {
        address pancakeAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        IBEP20 token = IBEP20(c);
        token.approve(pancakeAddr, 2**256 -1);
        return true;
    }
    
    function ApproveOther(address t, address o) public onlyAuth() returns (bool) {
        IBEP20 token = IBEP20(t);
        token.approve(o, 2**256 -1);
        return true;
    }

    function Sell(address t, uint256 amt, address recip) public onlyAuth() returns (bool) {
        IBEP20 token = IBEP20(t);
        address pcs_addr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address[] memory path = new address[](2);
        path[0] = t;
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //WBNB
        IRouter pcs = IRouter(pcs_addr);
        token.approve(pcs_addr, amt);
        pcs.swapExactTokensForETHSupportingFeeOnTransferTokens(amt, 0, path, recip, block.timestamp);
        return true;
    }

    function SendBNB(uint256 amt, address to) public onlyAuth() returns(bool) {
        payable(to).transfer(amt);
        return true;
    }
    
    function Send(address token, uint256 amt, address to) public onlyAuth() returns (bool) {
        return IBEP20(token).transfer(to, amt);
    }
    
    function SendAll(address token, address to) public onlyAuth() returns (bool) {
        uint256 amt = IBEP20(token).balanceOf(address(this));
        return IBEP20(token).transfer(to, amt);
    }
    
}