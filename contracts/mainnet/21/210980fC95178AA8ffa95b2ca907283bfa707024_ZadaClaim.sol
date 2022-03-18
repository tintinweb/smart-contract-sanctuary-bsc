// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "./Ownable.sol";
import "./Address.sol";
import "./IERC20.sol";

contract ZadaClaim is Ownable {
    using Address for address;

    address public zadaContract;

    uint256 public billionaireClaims;
    uint256 public millionaireClaims;
    uint256 public totalClaims;
    uint256 public maxMillionClaims = 750;

    struct billionClaimData {
        address zadaWallet;
        address whitelistWallet;
        uint256 currentZadaHolding;
        uint256 numberOfMintsAlloted;
    }

    struct millionClaimData {
        address zadaWallet;
        address whitelistWallet;
        uint256 currentZadaHolding;
        uint256 numberOfMintsAlloted;
    }

    mapping(uint256 => billionClaimData) public billionClaimInfo;
    mapping(uint256 => millionClaimData) public millionClaimInfo;
    mapping(address => bool) public claimStatus;

    event bilClaim(address _holder, address _whitelist, uint256 _currentBal, uint256 _numberOfMints);
    event milClaim(address _holder, address _whitelist, uint256 _currentBal, uint256 _numberOfMints);

    constructor(address _zadaContract) {
        zadaContract = _zadaContract;
    }

    function claimBillionWhitelist(address _zadaWallet, address _walletToBeWhitelisted) external {
        uint256 _currentBalance = IERC20(zadaContract).balanceOf(_zadaWallet);
        require(_currentBalance >= 1000000000*(10**18), "INSUFFCIENT BALANCE FOR BILLIONAIRE WHITELIST");
        require(msg.sender == _zadaWallet, "YOU ARE NOT CLAIMING FROM YOUR ZADA WALLET");
        require(claimStatus[msg.sender] == false, "CLAIM ALREADY SUBMITTED");

        uint256 currentClaim = billionaireClaims + 1;
        claimStatus[msg.sender] = true;

        billionClaimInfo[currentClaim].zadaWallet = _zadaWallet;
        billionClaimInfo[currentClaim].whitelistWallet = _walletToBeWhitelisted;
        billionClaimInfo[currentClaim].currentZadaHolding = _currentBalance;
        billionClaimInfo[currentClaim].numberOfMintsAlloted = 4;

        billionaireClaims += 1;
        totalClaims += 1;

        emit bilClaim(_zadaWallet, _walletToBeWhitelisted, _currentBalance, 4);
    }

    function claimMillionWhitelist(address _zadaWallet, address _walletToBeWhitelisted) external {
        uint256 _currentBalance = IERC20(zadaContract).balanceOf(_zadaWallet);
        require(_currentBalance >= 100000000*(10**18), "INSUFFCIENT BALANCE FOR MILLION WHITELIST");
        require(_currentBalance < 1000000000*(10**18), "BALANCE EXCEEDS CAP FOR MILLION WHITELIST, PLEASE USE BILLION WHITELIST");
        require((millionaireClaims + 1) <= maxMillionClaims, "MILLIONAIRE WHITELIST IS FULL");
        require(msg.sender == _zadaWallet, "YOU ARE NOT CLAIMING FROM YOUR ZADA WALLET");
        require(claimStatus[msg.sender] == false, "CLAIM ALREADY SUBMITTED");

        uint256 currentClaim = millionaireClaims + 1;
        claimStatus[msg.sender] = true;

        millionClaimInfo[currentClaim].zadaWallet = _zadaWallet;
        millionClaimInfo[currentClaim].whitelistWallet = _walletToBeWhitelisted;
        millionClaimInfo[currentClaim].currentZadaHolding = _currentBalance;
        millionClaimInfo[currentClaim].numberOfMintsAlloted = 3;

        millionaireClaims += 1;
        totalClaims += 1;

        emit milClaim(_zadaWallet, _walletToBeWhitelisted, _currentBalance, 3);
    }


}