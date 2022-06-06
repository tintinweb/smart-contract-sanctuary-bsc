/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

pragma solidity ^0.8.0;

contract DropFunds {

    address ownerAddress = 0xB8A57e0Ed2138d450a08376C0518d6E38A44f8e9;

    modifier onlyOwner() {
        require(ownerAddress == msg.sender, "Caller is not the owner");
        _;
    }

    function dropBNB(address[] memory _recipients, uint256[] memory _amount) public payable returns (bool) {
        require(_recipients.length == _amount.length, "Receivers and funds length are different.");
        for (uint i = 0; i < _recipients.length; i++) {
            require(_recipients[i] != address(0), "Address not found.");
            payable(_recipients[i]).transfer(_amount[i]);
        }
        return true;
    }

    function sendRemainingFunds()public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}