/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.17;


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


contract FeeCollector {

    address payable private Wallet_DEV = payable(0x38CbCeF520B609b7183880e46045EDC0e419c6F6);
    
    receive() external payable {}

    function Process_BNB() external {
        uint256 contractBNB = address(this).balance;
        if (contractBNB > 0) {

        Send_BNB(contractBNB, Wallet_DEV);
        
        }
    }

    function Process_Tokens(address Token_Address, uint256 Percent_of_Tokens) public returns(bool _sent){
        uint256 totalRandom = IERC20(Token_Address).balanceOf(address(this));
        uint256 removeRandom = totalRandom * Percent_of_Tokens / 100;
        _sent = IERC20(Token_Address).transfer(Wallet_DEV, removeRandom);
    }      


    function Send_BNB(uint256 amount, address payable sendTo) private {
        sendTo.transfer(amount);
    }  
}