/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ILufiToken {
    function pause() external;
    function unpause() external;
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function approve(address spender, uint256 amount) external;
    function transfer(address to, uint256 amount) external; 
    function decimals() external returns (uint8);
}

contract Bridge {

    ILufiToken tokenInstance;
    address admin;

    event Received(address, uint);
    event Burn(uint256);
    event Mint(address, uint256);

    constructor(address _admin) 
    {
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    function burnToken(address _tokenAddress, uint256 amount) public {
        tokenInstance = ILufiToken(_tokenAddress);
        tokenInstance.burn(amount);
        emit Burn(amount);
    }

    function mintToken(address _tokenAddress, address receiver, uint256 amount) public {
        tokenInstance = ILufiToken(_tokenAddress);
        tokenInstance.mint(receiver, amount);
        emit Mint(receiver, amount);
    }

    function withdraw(address _tokenAddress, uint256 _amount) public onlyAdmin {
        payable(admin).transfer(_amount);
        tokenInstance = ILufiToken(_tokenAddress);
        tokenInstance.transfer(admin, _amount);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}