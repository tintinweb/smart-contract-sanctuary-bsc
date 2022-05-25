/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

/**
* MIT License
* 
* Copyright (c) 2022 Giant Shiba Inu
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
* 
* █████▀██████████████████████████████████████████████████████████████████████████
* █─▄▄▄▄█▄─▄██▀▄─██▄─▀█▄─▄█─▄─▄─███─▄▄▄▄█─█─█▄─▄█▄─▄─▀██▀▄─████▄─▄█▄─▀█▄─▄█▄─██─▄█
* █─██▄─██─███─▀─███─█▄▀─████─█████▄▄▄▄─█─▄─██─███─▄─▀██─▀─█████─███─█▄▀─███─██─██
* █▄▄▄▄▄█▄▄▄█▄▄█▄▄█▄▄▄██▄▄██▄▄▄████▄▄▄▄▄█▄█▄█▄▄▄█▄▄▄▄██▄▄█▄▄███▄▄▄█▄▄▄██▄▄██▄▄▄▄██
* ████████████████████████████████████████████████████████████████████████████████
* 
* @title GSI Market Wallet Contract | Fantom Chain [Mainnet]
* @author Rajesh Kumar Roy <[email protected]> India
* @notice
* @dev
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IGSI
{
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract GSI_Marketing_Wallet
{
    address private _owner;

    constructor()
    {
        _owner = msg.sender;
    }

    modifier onlyOwner
    {
        require(msg.sender == _owner, "Permission Denied!");
        _;
    }

    function etherBal() public view returns (uint256)
    {
        return address(this).balance;
    }

    function ERC20Bal(address token) public view returns (uint256)
    {
        return IGSI(token).balanceOf(address(this));
    }

    function extractERC20(address token, address account, uint256 amount) onlyOwner external
    {
        require(ERC20Bal(token) > 0, "Zero Balance!");
        require(ERC20Bal(token) >= amount * (10 ** IGSI(token).decimals()), "Low Balance!");
        IGSI(token).transfer(account, amount * (10 ** IGSI(token).decimals()));
    }

    function extractAllERC20(address token, address account) onlyOwner external
    {
        require(ERC20Bal(token) > 0, "Zero Balance!");
        IGSI(token).transfer(account, ERC20Bal(token));
    }

    function extractEther(address account, uint256 amount) onlyOwner external
    {
        require(etherBal() > 0, "Zero Balance!");
        require(etherBal() >= amount, "Low Balance!");
        payable(account).transfer(amount * 1 ether);
    }

    function extractAllEther(address account) onlyOwner external
    {
        require(etherBal() > 0, "Zero Balance!");
        payable(account).transfer(etherBal());
    }

    receive() external payable {}
}