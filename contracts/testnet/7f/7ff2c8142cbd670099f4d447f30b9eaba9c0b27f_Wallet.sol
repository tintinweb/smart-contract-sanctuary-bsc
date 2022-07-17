/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

interface iToken
{
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Wallet
{
    event TokenExtracted(address indexed contractAddress, address indexed from, address indexed to, uint256 amount, uint256 timestamp);
    event EtherExtracted(address indexed from, address indexed to, uint256 amount, uint256 timestamp);

    address private _owner;

    constructor()
    {
        _owner = msg.sender;
    }

    modifier onlyOwner
    {
        require(msg.sender == _owner, "Permission Denied, You're not the Owner!");
        _;
    }

    function extractToken(address contractAddress, address account, uint256 amount) onlyOwner external returns (bool)
    {
        require(iToken(contractAddress).balanceOf(address(this)) > 0, "Zero Balance!");
        require(iToken(contractAddress).balanceOf(address(this)) >= amount, "Low Balance!");
        iToken(contractAddress).transfer(account, amount);
        emit TokenExtracted(contractAddress, address(this), account, amount, block.timestamp);
        return true;
    }

    function extractAllToken(address contractAddress, address account) onlyOwner external returns (bool)
    {
        require(iToken(contractAddress).balanceOf(address(this)) > 0, "Zero Balance!");
        iToken(contractAddress).transfer(account, iToken(contractAddress).balanceOf(address(this)));
        emit TokenExtracted(contractAddress, address(this), account, iToken(contractAddress).balanceOf(address(this)), block.timestamp);
        return true;
    }

    function extractEther(address payable account, uint256 amount) onlyOwner external returns (bool)
    {
        require(address(this).balance > 0, "Zero Balance!");
        require(address(this).balance >= amount, "Low Balance!");
        account.transfer(amount);
        emit EtherExtracted(address(this), account, amount, block.timestamp);
        return true;
    }

    function extractAllEther(address payable account) onlyOwner external returns (bool)
    {
        require(address(this).balance > 0, "Zero Balance!");
        account.transfer(address(this).balance);
        emit EtherExtracted(address(this), account, address(this).balance, block.timestamp);
        return true;
    }

    receive() external payable {}
}