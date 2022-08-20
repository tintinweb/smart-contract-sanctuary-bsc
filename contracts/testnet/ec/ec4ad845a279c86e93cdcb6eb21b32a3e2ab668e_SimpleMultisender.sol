/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract SimpleMultisender{

    address public owner;

    modifier onlyOwner() {
        require(owner == msg.sender, "not owner");
        _;
    }

    constructor () {
        owner = msg.sender;
    }

    function multisendBNBs(address[] calldata _recipient, uint256 _amount) public payable{
        require(msg.value >= _amount * _recipient.length, "Insufficient funds");
        bool success;

        for (uint256 i = 0; i < _recipient.length; i++) {
            (success, ) = _recipient[i].call{value: _amount}("");
            require(success, "Coin failed");
            success = false;
        }
    }

    function multisendTokens(address _tokenAddress, address[] calldata _recipient, uint256 _amount) public {
        IERC20 token = IERC20(_tokenAddress);
        require(token.balanceOf(msg.sender) >= _amount * _recipient.length, "Insufficient funds");
        require(token.allowance(msg.sender,address(this)) >= _amount * _recipient.length, "Insufficient allowance");

        bool success;

        for (uint256 i = 0; i < _recipient.length; i++) {
            success = token.transferFrom(msg.sender, _recipient[i], _amount);
            require(success, "Token Transfer failed.");
            success = false;
        }
    }

    function withdrawCoins() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    function withdrawTokens(address _tokenAddress) public onlyOwner returns(bool){
        IERC20 token = IERC20(_tokenAddress);

        bool success = token.transfer(msg.sender, token.balanceOf(address(this)));
        require(success, "Token Transfer failed.");

        return true;
    }

    fallback() external payable { }

    receive() external payable { }
}