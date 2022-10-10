/**
 *Submitted for verification at BscScan.com on 2022-10-09
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

// DO NOT SHARE this contract with anyone

// version 1.0

contract SniperWhitelist {

    address owner;

    mapping(address => bool) whitelistedAddresses;

    constructor() {
      owner = msg.sender;
    }

    modifier onlyOwner() {
      require(msg.sender == owner, "Nice try! Please contact @TsarBuig on TG if you want to use Sniper bot");
      _;
    }

    function addUser(address _addressToWhitelist) public onlyOwner {
      whitelistedAddresses[_addressToWhitelist] = true;
    }

    function deleteUser(address _addressToDelete) public onlyOwner {
      whitelistedAddresses[_addressToDelete] = false;
    }

    function verifyUser(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
      return userIsWhitelisted;
    }

}