/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: proprietary

pragma solidity = 0.8.17;

// ███████╗███╗   ██╗██╗██████╗ ███████╗██████╗ 
// ██╔════╝████╗  ██║██║██╔══██╗██╔════╝██╔══██╗
// ███████╗██╔██╗ ██║██║██████╔╝█████╗  ██████╔╝
// ╚════██║██║╚██╗██║██║██╔═══╝ ██╔══╝  ██╔══██╗
// ███████║██║ ╚████║██║██║     ███████╗██║  ██║
// ╚══════╝╚═╝  ╚═══╝╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
//                                   by TsarBuig
// Contract V2

// This contract is designed to add/remove users for using SniperV2 bot from LimitSwap team
// If you want to use the bot, please join our Telegram channel : https://t.me/LimitSwap

contract SniperWhitelist {

    address owner;
    uint public whitelisted_amount = 0;
    uint public whitelisted_with_LIMIT_amount = 0;

    mapping(address => bool) whitelistedAddresses;
    mapping(address => bool) whitelistedAddresses_with_LIMIT;

    constructor() {
      owner = msg.sender;
    }

    modifier onlyOwner() {
      require(msg.sender == owner, "Nice try! Please contact @TsarBuig on TG if you want to use Sniper bot");
      _;
    }

    function addUser(address _addressToWhitelist) public onlyOwner {
      whitelistedAddresses[_addressToWhitelist] = true;
      whitelisted_amount = whitelisted_amount + 1;
    }

    function deleteUser(address _addressToDelete) public onlyOwner {
      whitelistedAddresses[_addressToDelete] = false;
      whitelisted_amount = whitelisted_amount - 1;
    }

    function verifyUser(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
      return userIsWhitelisted;
    }

    function addUser_withLIMIT(address _addressToWhitelist) public onlyOwner {
      whitelistedAddresses_with_LIMIT[_addressToWhitelist] = true;
      whitelisted_with_LIMIT_amount = whitelisted_with_LIMIT_amount + 1;
    }

    function deleteUser_withLIMIT(address _addressToDelete) public onlyOwner {
      whitelistedAddresses_with_LIMIT[_addressToDelete] = false;
      whitelisted_with_LIMIT_amount = whitelisted_with_LIMIT_amount - 1;
    }

    function verifyUser_withLIMIT(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = whitelistedAddresses_with_LIMIT[_whitelistedAddress];
      return userIsWhitelisted;
    }

    // Count how many people use it without LIMIT tokens
    function count_whitelisted() public view returns(uint) {
      return whitelisted_amount;
    }

    // Count how many people use it with LIMIT tokens
    function count_whitelisted_withLIMIT() public view returns(uint) {
      return whitelisted_with_LIMIT_amount;
    }


}