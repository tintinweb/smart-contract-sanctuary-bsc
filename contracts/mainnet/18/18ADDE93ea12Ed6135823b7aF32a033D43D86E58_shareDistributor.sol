/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract shareDistributor {

    address[] private holders;
    uint[] private shares;
    mapping(address => bool) public admins;

    modifier onlyOwner() {
        require(admins[msg.sender] == true, "Not allowed");
        _;
    }

    constructor() {
        admins[msg.sender] = true;
    }
    
    receive() external payable {}

    event NewDistribution(uint amount);
    event NewHolderAdded(address holder, uint share);
    event NewHolderRemoved(address holder);

    function distributeFunds() external onlyOwner {
        uint256 contractBal = contractBalance();
        require(contractBal > 0, "No funds in contract");
        
        //Check if total share is 100% before proceeding
        uint totalSharePercent = 0;
        for(uint8 i=0; i < shares.length; i++) {
            totalSharePercent += shares[i];
        }
        require(totalSharePercent == 10000, "All shares do not add up to 100%");

        //Distribute
        for(uint8 i=0; i < holders.length; i++) {
            payable(holders[i]).transfer(contractBal*shares[i]/10000);
        }

        emit NewDistribution(contractBal);
    }

    //Add holders
    function addHolders(address[] calldata _holders, uint[] calldata _shares) public onlyOwner {
        require(_holders.length == _shares.length, "Mismatch arrays");
        
        for(uint8 i=0; i < _holders.length; i++) {
            holders.push(_holders[i]);
            shares.push(_shares[i]);
            emit NewHolderAdded(holders[i], _shares[i]);
        }

    }
    
    //remove holder
    function removeHolders(uint[] calldata _holderIndex) external onlyOwner {
        for(uint8 i=0; i < _holderIndex.length; i++) {
            require(_holderIndex[i] < holders.length, "Invalid holder index");
            emit NewHolderRemoved(holders[_holderIndex[i]]);
            holders[_holderIndex[i]] = holders[holders.length-1];
            holders.pop();
            shares[_holderIndex[i]] = shares[shares.length-1];
            shares.pop();
        }
    }

    function deleteAllHolders() public onlyOwner {
        holders = new address[](0);
        shares = new uint[](0);
    }

    function updateAdmin(address _admin, bool _status) external onlyOwner {
        admins[_admin] = _status;
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function showHolders() public view returns (address[] memory) {
        return holders;
    }

    function showShares() public view returns (uint[] memory) {
        return shares;
    }

}