/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
}

contract RoyaltyDistributor {
    address public IncineratorRoyaltyWallet;
    address public ServerMaintenanceWallet;
    address public ProjectRoyaltyWallet;
    address public tokenAddress;
    uint256 public royaltyAmount = 5;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function.");
        _;
    }

    function setWalletAddresses(
        address _incineratorWallet, 
        address _maintenanceWallet, 
        address _projectWallet
    ) external onlyOwner {
        IncineratorRoyaltyWallet = _incineratorWallet;
        ServerMaintenanceWallet = _maintenanceWallet;
        ProjectRoyaltyWallet = _projectWallet;
    }

    function rewardTimerAirdrop() public payable {
        require(
            IncineratorRoyaltyWallet != address(0) &&
            ServerMaintenanceWallet != address(0) &&
            ProjectRoyaltyWallet != address(0),
            "Wallet addresses not set"
        );

        uint256 totalBalance = address(this).balance;
        uint256 royaltyAmountInWei = (totalBalance * royaltyAmount) / 100;

        payable(IncineratorRoyaltyWallet).transfer(royaltyAmountInWei / 3);
        payable(ServerMaintenanceWallet).transfer(royaltyAmountInWei / 3);
        payable(ProjectRoyaltyWallet).transfer(royaltyAmountInWei / 3);
    }

    function withdrawFunds(address payable _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "Invalid recipient address");
        require(_amount <= address(this).balance, "Insufficient funds in the contract");

        _to.transfer(_amount);
    }

    function setRoyaltyAmount(uint256 _newRoyaltyAmount) external onlyOwner {
        royaltyAmount = _newRoyaltyAmount;
    }

    function buyTokens(uint256 _tokenAmount) external payable {
        require(tokenAddress != address(0), "Token address not set");
        require(_tokenAmount > 0, "Token amount must be greater than zero");

        IBEP20 token = IBEP20(tokenAddress);

        uint256 totalCost = _tokenAmount * 1 ether;
        require(msg.value >= totalCost, "Insufficient funds");

        require(token.transfer(msg.sender, _tokenAmount), "Token transfer failed");

        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
    }

    function airdropTokens(address[] calldata _recipients, uint256[] calldata _tokenAmounts) external onlyOwner {
        require(tokenAddress != address(0), "Token address not set");
        require(_recipients.length == _tokenAmounts.length, "Arrays length mismatch");

        IBEP20 token = IBEP20(tokenAddress);

        for (uint i = 0; i < _recipients.length; i++) {
            require(token.transfer(_recipients[i], _tokenAmounts[i]), "Token transfer failed");
        }
    }
function receive() external payable {
    }
}