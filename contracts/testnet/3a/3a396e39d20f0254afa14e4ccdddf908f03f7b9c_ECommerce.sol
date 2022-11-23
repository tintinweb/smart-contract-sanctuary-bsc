/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ECommerce {
    IERC20 token;
    address private owner;

    constructor() {
        token = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
        // this token address is BUSD deployed on Binance testnet
       // You can use any other ERC20 token smart contarct address here
        owner = msg.sender;
    }
    
    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

   function GetUserTokenBalance() public view returns(uint256){ 
       return token.balanceOf(msg.sender);// balanceOf function is already declared in ERC20 token function
   }
   
   function GetAllowance() public view returns(uint256){
       return token.allowance(msg.sender, address(this));
   }
   
   function AcceptPayment(uint256 _tokenamount) public returns(bool) {
       // _tokenAmount cannot exceed allowance. In this case I put equals symbol to prevent require error
       require(_tokenamount >= GetAllowance(), "Please approve tokens before transferring");
       // Use transferFrom() function if you want to transfer from user to smart contract a specific amount of tokens.
       token.transferFrom(msg.sender, address(this), _tokenamount);
       return true;
   }
   
   function GetContractTokenBalance() public OnlyOwner view returns(uint256){
       return token.balanceOf(address(this));
   }
   
}