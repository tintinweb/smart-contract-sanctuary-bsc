// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./Strings.sol";

interface IBUSD {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Presale is Ownable {
    using SafeMath for uint256;
    using Strings for uint256;
    
    IBUSD public BUSD;

    //Addresses for devs, to be paid out
    address public constant dev1Address = 0xF6eb68D6A857EdbdaF05DAB7Dec05ab258Ad7223;
    address public constant dev2Address = 0xF6eb68D6A857EdbdaF05DAB7Dec05ab258Ad7223;
    address public constant dev3Address = 0x58ceea88B5476455b3683C2F7920989b2BDF6718;
    address public constant dev4Address = 0x56bE52b71eF76A4659b94d0B2b8859f3dD7C758c;
    address public constant dev5Address = 0xCF3D6E2a56b6C9764Eed7BFA519c413f819d1830;
    address public constant projectExpensesAddress = 0x0a0EE0AA5a2F5b596EfA7d0f5cc4fea318B30fDe;

    uint256 public maxPerWallet = 500000 * 1e18;

    uint256 public amountRaisedInPrivate = 0 * 1e18;

    uint256 public projectExpensesWithdrawn = 0;
    
    bool public preSaleActive = false;

    mapping(address => uint256) public amountPurchased;
    
    /*/////////////////////////////////////////////////////////////////////////////
                            Sale Logic
    /////////////////////////////////////////////////////////////////////////////*/

    function deposit(uint256 amount) public {
        require(preSaleActive, "Sale has not begun");
        require(amount + amountPurchased[msg.sender] <= maxPerWallet, "You cannot purchase this much $CBOW");
        BUSD.transferFrom(msg.sender, address(this), amount);
        amountPurchased[msg.sender] += amount;
        amountRaisedInPrivate += amount;
    }

    /*/////////////////////////////////////////////////////////////////////////////
                            Internal Logic
    /////////////////////////////////////////////////////////////////////////////*/

    function togglePreSale() external onlyOwner{
        preSaleActive = !preSaleActive;
    }

    function setMaxPerWallet(uint256 amount) external onlyOwner{
        maxPerWallet = amount;
    }

    function setBUSDAddress(address busdAddr) external onlyOwner {
        BUSD = IBUSD(busdAddr);
    }

    //withdraw project expenses
    function withdrawProjectExpenses() public onlyOwner {
        require(projectExpensesWithdrawn < 100000 * 1e18, "Project Expenses have been withdrawn");
        uint256 balance = BUSD.balanceOf((address(this)));

        if(projectExpensesWithdrawn + balance < 100000 * 1e18){
            BUSD.transfer(projectExpensesAddress, balance);
            projectExpensesWithdrawn += balance;
        } else {
            BUSD.transfer(projectExpensesAddress, 100000 * 1e18 - projectExpensesWithdrawn);
            projectExpensesWithdrawn = 100000 * 1e18;
        }
    }

    //Withdraw 
    function withdrawAll() public onlyOwner {
        require(projectExpensesWithdrawn >= 100000 * 1e18);
        uint256 balance = BUSD.balanceOf((address(this)));

        uint256 dev1Share = balance.mul(166).div(1000);
        uint256 dev2Share = balance.mul(167).div(1000);
        uint256 dev3Share = balance.mul(167).div(1000);
        uint256 dev4Share = balance.mul(350).div(1000);
        uint256 dev5Share = balance.mul(150).div(1000);

        require(balance > 0);
        BUSD.transfer(dev1Address, dev1Share);
        BUSD.transfer(dev2Address, dev2Share);
        BUSD.transfer(dev3Address, dev3Share);
        BUSD.transfer(dev4Address, dev4Share);
        BUSD.transfer(dev5Address, dev5Share);
    }
    
}