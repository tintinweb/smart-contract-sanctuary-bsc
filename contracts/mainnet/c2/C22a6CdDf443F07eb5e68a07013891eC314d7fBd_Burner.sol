/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


interface BEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Burner {
    address public owner;
    address public burnAddress;
    address[] public supportedTokens;
    address public tokenHolding;

    constructor()  {
        owner = msg.sender;
    }

    function setBurnAddress(address _burnAddress) public {
        require(msg.sender == owner, "Only owner can set the burn address");
        burnAddress = _burnAddress;
    }

    function setTokenHolding(address _tokenHolding) public {
        require(msg.sender == owner, "Only owner can set the token holding address");
        tokenHolding = _tokenHolding;
    }

    function addSupportedToken(address _token) public {
        require(msg.sender == owner, "Only owner can add supported tokens");
        supportedTokens.push(_token);
    }
    function transfer(address _to, uint256 _value,address _token) public {
        require(_to == address(this), "Transfer must be to the contract address");
        require(_value > 0, "Must transfer a positive amount");
        require(BEP20(_token).transferFrom(msg.sender, _to, _value), "Transfer failed");
        require(BEP20(tokenHolding).transfer(_token,_value), "Transfer to tokenHolding failed");
    }

    function burn(uint256 _value,address _token) public {
        require(burnAddress != address(0), "Burn address not set");
        require(tokenHolding != address(0), "Token holding address not set");
        require(_value > 0, "Must burn a positive amount");
        require(BEP20(_token).transferFrom(tokenHolding, burnAddress, _value), "Burn failed");
    }
}