/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;
pragma abicoder v2;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract transferToContract {
    address public _WETH = 0xdF71EBeBBcB195B882be02fC161b21324e73664D;
    IERC20 public WETH = IERC20(_WETH);

    function transferTo (uint amount) public
    {
        WETH.approve(msg.sender,amount);
        WETH.transfer(address(this),amount);
    }
    function transferToC (uint amount) public
    {
        WETH.approve(msg.sender,amount);
        WETH.transferFrom(msg.sender,address(this),amount);
    }
    
    function transferFromC(uint amount) public{
        WETH.approve(address(this),amount);
        WETH.transferFrom(address(this),msg.sender,amount);
    }
    
    function getbal() public view returns(uint){
        return WETH.balanceOf(msg.sender);
    }
    
    
}