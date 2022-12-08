/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

/*
 * ARK BOND PRESALE
 *
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.17;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ARK_BOND_PRESALE {
    address private CEO = 0x236e437177A19A0729E44f8612B2fDF2A3578FE8;
    IBEP20 public constant BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    uint256 public bondSales;
    mapping (uint256 => uint256) public depositOfIndex;
    mapping (uint256 => uint256) public taxesOfIndex;
    mapping (uint256 => address) public addressOfIndex;
    mapping (address => uint256) public totalBondValueOfInvestor;
    event BondPurchased(address indexed user, uint256 indexed index, uint256 deposit, uint256 taxes);

    modifier onlyCEO() {
        require(msg.sender == CEO, "Only the CEO can do that");
        _;
    }

    constructor() {}

    function buyPresaleBond(uint256 amount) external {
        require(BUSD.transferFrom(msg.sender, address(this), amount),"BUSD transfer failed");
        depositOfIndex[bondSales] = amount * 9 / 10;
        taxesOfIndex[bondSales] = amount / 10;
        addressOfIndex[bondSales] = msg.sender;
        totalBondValueOfInvestor[msg.sender] += amount * 9 / 10;
        emit BondPurchased(msg.sender, bondSales, amount * 9 / 10, amount / 10);
        bondSales++;
    }
    
    function collectFunds() external onlyCEO {
        require(BUSD.transfer(msg.sender, BUSD.balanceOf(address(this))),"Failed");
    }

/////// emergency function just in case
    function rescueAnyToken(address tokenToRescue) external onlyCEO {
        require(IBEP20(tokenToRescue).transfer(msg.sender, IBEP20(tokenToRescue).balanceOf(address(this))),"Failed");
    }
}