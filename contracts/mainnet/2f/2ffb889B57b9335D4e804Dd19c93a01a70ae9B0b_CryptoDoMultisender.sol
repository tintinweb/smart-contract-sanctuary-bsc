/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract CryptoDoMultisender{
    address owner;
    constructor () {
        owner = msg.sender;
    }
    receive() external payable {

    }
    function MultisendBNB( address[]  memory  recipients , uint256[] memory values) external payable {
        uint256 sumValue;
        uint256 amount = msg.value;
        for (uint256 i = 0; i < recipients.length; i++) {
           payable(recipients[i]).transfer(values[i]);
           sumValue+=values[i]; 
        }
        uint256 valueBalance = amount-sumValue;
        if (address(this).balance > 0)
            payable(msg.sender).transfer(valueBalance);
    }

    function MultisendToken(IERC20 token, address[] memory recipients, uint256[] memory values) external payable {
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        require(token.transferFrom(msg.sender, address(this), total));
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));
    }

    function MultisendTokenSimple(IERC20 token, address[] memory recipients, uint256[] memory values) external payable {
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transferFrom(msg.sender, recipients[i], values[i]));
    }
    function withdraw () external {
        require (msg.sender == owner,'not an owner');
        (bool success, ) = owner.call{value: address(this).balance}('');
        require (success,'withdraw failed');
    }
}