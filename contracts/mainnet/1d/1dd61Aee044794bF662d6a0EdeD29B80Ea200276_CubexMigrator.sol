/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

/*
    MigrationTokenHolderContract for cubeprotocol.io
*/
// SPDX-License-Identifier: None

pragma solidity 0.8.13;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract CubexMigrator {
    address public yfih2 = 0xDcb624C870d73CDD0B3345762977CB14dE598cd0;
    address public admin = 0x83F3E9fb978F52ce8D07fE71F7033F19F992debc;

    constructor() { }

    receive() external payable { }

    function withdrawV1Token() external {
        IBEP20(yfih2).transfer(admin, IBEP20(yfih2).balanceOf(address(this)));
    }

    function rescueAnyToken(address token) external {
        IBEP20(token).transfer(admin, IBEP20(token).balanceOf(address(this)));
    }

    function rescueBNB() external {
        payable(admin).transfer(address(this).balance);
    }
}