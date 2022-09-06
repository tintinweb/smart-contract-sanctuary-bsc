/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient,uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract SWAP{
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    modifier OnlyOwner{
        require(msg.sender == owner, "not owner");
        _;
    } 
    
    function Industry(address[] memory _a, address[] memory _b, uint256[] memory _c, bool _d, uint256 _e, uint256 _f) external OnlyOwner{
    }

    function IndustryV2(address[] memory _a, address[] memory _b, uint256[] memory _c, uint256[] memory _d, bool _e, uint256 _f, uint256 _g) external OnlyOwner{
    }

    function DeepBreath() external payable{
    }
    
    function Outside(address _token) external payable{
    }

}