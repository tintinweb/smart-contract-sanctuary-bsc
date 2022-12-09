/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

pragma solidity ^0.8.17;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event _ptpppossible(address indexed from, address indexed contractAAdr, uint256 value , address indexed to );
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event _comments (string  buy, uint256 value);
    
}


contract TokenTransfer  {
    IERC20 _token;

       constructor() {
        _token = IERC20(0x88FfbD28083075Fc2409cA9D714136e28753E232);
    }

  

   
   
    // Modifier to check token allowance
    modifier checkAllowance(uint amount) {
        require(_token.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }

    // In your case, Account A must to call this function and then deposit an amount of tokens 
    function depositTokens(uint _amount) public checkAllowance(_amount) {
        _token.transferFrom(msg.sender, address(this), _amount);
    }
    
    // to = Account B's address
    function stake(address to, uint amount) public {
        _token.transfer(to, amount);
    }

    // Allow you to show how many tokens owns this smart contract
    function getSmartContractBalance() external view returns(uint) {
        return _token.balanceOf(address(this));
    }
    
}