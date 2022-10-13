/**
 *Submitted for verification at BscScan.com on 2022-10-13
*/

// SPDX-License-Identifier: proprietary

pragma solidity = 0.8.17;

// ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗████████╗
// ██║    ██║██╔══██╗██║     ██║     ██╔═══╝╚══██╔══╝
// ██║ █╗ ██║███████║██║     ██║     ████╗     ██║ ██║   ██║██╗   ██╗███╗  ██╗████████╗██████╗██████╗
// ██║███╗██║██╔══██║██║     ██║     ██╔═╝     ██║ ██║   ██║██║   ██║████╗ ██║╚══██╔══╝██╔═══╝██╔══██╗
// ╚███╔███╔╝██║  ██║███████╗███████╗██████╗   ██║ ████████║██║   ██║██╔██╗██║   ██║   ████╗  ██████╔╝
//  ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═════╝   ╚═╝ ██║   ██║██║   ██║██║╚████║   ██║   ██╔═╝  ██╔══██╗
//                                                 ██║   ██║╚██████╔╝██║ ╚███║   ██║   ██████╗██║  ██║
//                                                 ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚══╝   ╚═╝   ╚═════╝╚═╝  ╚═╝
//                                                                                         by TsarBuig

// Contract V1

// This contract is designed to add/remove users for using WalletHunter bot from TsarBuig, LimitSwap team
// If you want to use the bot, please join our Telegram channel : https://t.me/LimitSwap

contract SniperWhitelist {

    address owner;
    uint public whitelisted_amount_of_users = 0;
    uint public whitelisted_with_LIMIT_amount_of_users = 0;

    mapping(address => bool) whitelistedAddresses;
    mapping(address => bool) whitelistedAddresses_with_LIMIT;

    constructor() {
      owner = msg.sender;
    }

    modifier onlyOwner() {
      require(msg.sender == owner, "Nice try! Please contact @TsarBuig on TG if you want to use WalletHunter bot");
      _;
    }

    function addUser(address _addressToWhitelist) public onlyOwner {
      whitelistedAddresses[_addressToWhitelist] = true;
      whitelisted_amount_of_users = whitelisted_amount_of_users + 1;
    }

    function deleteUser(address _addressToDelete) public onlyOwner {
      whitelistedAddresses[_addressToDelete] = false;
      whitelisted_amount_of_users = whitelisted_amount_of_users - 1;
    }

    function checkIfUserIsWhitelisted(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
      return userIsWhitelisted;
    }

    function addUser_withLIMIT(address _addressToWhitelist) public onlyOwner {
      whitelistedAddresses_with_LIMIT[_addressToWhitelist] = true;
      whitelisted_with_LIMIT_amount_of_users = whitelisted_with_LIMIT_amount_of_users + 1;
    }

    function deleteUser_withLIMIT(address _addressToDelete) public onlyOwner {
      whitelistedAddresses_with_LIMIT[_addressToDelete] = false;
      whitelisted_with_LIMIT_amount_of_users = whitelisted_with_LIMIT_amount_of_users - 1;
    }

    function checkIfUserIsWhitelisted_withLIMIT(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = whitelistedAddresses_with_LIMIT[_whitelistedAddress];
      return userIsWhitelisted;
    }

}