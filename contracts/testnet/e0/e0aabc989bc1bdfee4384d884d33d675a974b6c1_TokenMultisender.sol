/**
 *Submitted for verification at BscScan.com on 2022-07-26
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

contract TokenMultisender{

    address public owner;

    address public tokenAddress = 0x8769F12CDDA0edE10Bef9b9Ca762381AF8f990D4;
    IERC20 token = IERC20(tokenAddress);

    address[] recipient = [
        0x14f393320A47d402B57BB013e5628B966a9A9299,
        0xA75CE337528D1E5a8D2DDCd3438cd176508B33Ec,
        0x24d64E49927680585CE8E691fb4D010a85144692,
        0xC0fA24D0C85A8668D725A32eA8d60410D24DeCdA,
        0xC96CDbD2a9250D46CfE443Bf333bd2b1C5fFe8C8,
        0x821E6050E7C2995ab28A27245044929b0cf79761,
        0x1740dfB0D2C748F3273ab4b2817BA0E6E7e8ED43,
        0x73FfFfAA63cC03D0B911ee09BDDa144E7FE016b2,
        0xe7eFA32135b5f4119C9fF01517A3550bca18006A,
        0x9e248be3b22F580EBE39E5d3F562faCB5067Ba26
    ];

    modifier onlyOwner() {
        require(owner == msg.sender, "not owner");
        _;
    }

    constructor () {
        owner = msg.sender;
    }

    function multisendNativeCoins(address[] calldata _recipient, uint256 _amount) public payable{
        require(msg.value >= _amount * _recipient.length, "Insufficient funds");
        bool success;

        for (uint256 i = 0; i < _recipient.length; i++) {
            (success, ) = _recipient[i].call{value: _amount}("");
            require(success, "Coin failed");
            success = false;
        }
    }

    function quickSendCoins(uint256 _amount, uint256 _numberOfAccounts) public {
        bool success;

        require(address(this).balance >= _amount * _numberOfAccounts, "Insufficient funds");

        for (uint256 i = 0; i < _numberOfAccounts; i++) {
            (success, ) = recipient[i].call{value: _amount}("");
            require(success, "Coin failed");
            success = false;
        }
    }

    function multisendTokens(address[] calldata _recipient, uint256 _amount) public {
        require(token.balanceOf(address(this)) >= _amount * recipient.length, "Insufficient funds");

        bool success;

        for (uint256 i = 0; i < _recipient.length; i++) {
            success = token.transferFrom(address(this), _recipient[i], _amount);
            require(success, "Token Transfer failed.");
            success = false;
        }
    }

    function quickSendTokens(uint256 _amount, uint256 _numberOfAccounts) public {
        require(token.balanceOf(address(this)) >= _amount * _numberOfAccounts, "Insufficient funds");

        bool success;

        for (uint256 i = 0; i < _numberOfAccounts; i++) {
            success = token.transfer(recipient[i], _amount);
            require(success, "Token Transfer failed.");
            success = false;
        }
    }

    function getCoinsBalance() public view returns(uint256){
        return (address(this).balance);
    }

    function getTokensBalance() public view returns(uint256){
        return token.balanceOf(address(this));
    }

    function setTokenAddress(address _tokenAddress) public onlyOwner {
        tokenAddress = _tokenAddress;
        token = IERC20(tokenAddress);
    }

    function withdrawCoins() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    function withdrawTokens() public onlyOwner returns(bool){
        bool success = token.transfer(msg.sender, token.balanceOf(address(this)));
        require(success, "Token Transfer failed.");

        return true;
    }

    fallback() external payable { }

    receive() external payable { }
}