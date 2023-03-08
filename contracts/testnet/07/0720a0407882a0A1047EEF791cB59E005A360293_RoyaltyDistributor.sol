/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

contract RoyaltyDistributor {
    address public IncineratorRoyaltyWallet = 0x09687803876959a48132d875d5f7EC606a1f7746;
    address public ServerMaintenanceWallet = 0x991e5b29e76b709d2998E3cC4c17a4CE9dbe496f;
    address public ProjectRoyaltyWallet;

    IBEP20 public token;

    constructor(address _tokenAddress, address _projectRoyaltyWallet) {
        token = IBEP20(_tokenAddress);
        ProjectRoyaltyWallet = _projectRoyaltyWallet;
    }

    function rewardTimerAirdrop() public {
        uint256 totalBalance = token.balanceOf(address(this));
        uint256 royaltyAmount = totalBalance *  5 / 100;

        token.transfer(IncineratorRoyaltyWallet, royaltyAmount / 3);
        token.transfer(ServerMaintenanceWallet, royaltyAmount / 3);
        token.transfer(ProjectRoyaltyWallet, royaltyAmount / 3);
    }
}