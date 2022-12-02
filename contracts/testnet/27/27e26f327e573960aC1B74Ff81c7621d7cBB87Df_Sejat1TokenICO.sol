/**
 *Submitted for verification at BscScan.com on 2021-12-22
*/

// SPDX-License-Identifier: MIT
// Sources flattened with hardhat v2.7.0 https://hardhat.org
// @dev TG: defi_guru
// File @openzeppelin/contracts/token/ERC20/[email protected]
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.4;

import "./Sejat1Token.sol";
// sell closed = 35_000_000e18
// sell opened 65_000_000e18

contract Sejat1TokenICO {
    address admin;

    Sejat1Token internal tokenContract;

    uint256 public total = 500_000_000e18; // There will be total 100 Hashnode Tokens
    uint256 public countTeam = 50_000_000e18;
    uint256 public countMarketing = 75_000_000e18;
    uint256 public countP2E = 75_000_000e18;

    uint256 public tokenForSell = 100_000_000e18; // 60 HTs will be sold in Crowdsale

    address internal addrTest = 0xcE6526985b69DEc97311092A2492ADc2Aa669Db6;

 /*  /// кошел 1 под stacking 17 % / 100 млн
    address internal stackingAddress;
    /// кошел 2 под плэй ту ерн 17 % / 100 млн
    address internal p2eAddress;
    /// кошел 4 маркетинг 13% / 75 млн
    address internal marketingAddress;
    /// кошел 5 пресел 11 % / 65 млн (в контракте ИКО)
    /// address presaleAddress;
    /// кошел 6 команда 8%  / 50 млн
    address internal teamAddress;
    /// кошел 7 резерв 8%  / 50 млн
    address internal reserveAddress;
    /// кошел 8 резерв 6%  / 35 млн
    address internal sponsorAddress;
    /// кошел 9 под сжигание 4% / 25 млн
    address internal burnAddress;*/

    uint256 public tokenSold;

    event Sell(address _buyer, uint256 _amount);

    constructor(address _tokenContract)
    {

        admin = msg.sender;

        tokenContract = Sejat1Token(_tokenContract);

    }

    function multiply(uint256 x, uint256 y) internal pure returns(uint256 z)
    {
        require( y == 0 || (z = x * y) / y == x);
    }

    function buyTokens(uint256 _countTokens) public payable 
    {
        require(msg.value == multiply(_countTokens, tokenForSell));

        require(tokenContract.balanceOf(address(this)) >= _countTokens);

        require(tokenContract.transfer(msg.sender, _countTokens));

        tokenSold += _countTokens;

        emit Sell(msg.sender, _countTokens);

    }

    function endSale() public {

        require(msg.sender == admin);

        require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))));

        payable(admin).transfer(address(this).balance);

        tokenContract.mint(addrTest, countTeam);

        /// кошел 3 под плэй ту ерн 17 % / 100 млн (ликвид)
        tokenContract.mint(admin, 100_000_000e18);

        /// кошел 4 маркетинг 13% / 75 млн
        tokenContract.mint(addrTest, countMarketing);

        /// кошел 6 команда 11%  / 50 млн
        //_mint(teamAddress, 50_000_000e18);
        
        /// кошел 6 команда 8%  / 50 млн
        tokenContract.mint(addrTest, countP2E);

    }

}