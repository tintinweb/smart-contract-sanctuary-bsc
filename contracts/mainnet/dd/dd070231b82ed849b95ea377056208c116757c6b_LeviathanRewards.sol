/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract LeviathanRewards {

    address owner;

    address [] addressList;

    mapping(address => bool) hasClaimed;
    mapping(address => uint256) claimAmount;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function addDiamondHand(address[] memory addAddressList, uint256[] memory addClaimAmount) external onlyOwner{
        for (uint i=0; i < addAddressList.length; i++) {
            claimAmount[addAddressList[i]] = addClaimAmount[i];
            hasClaimed[addAddressList[i]] = false;
        }
    }

    function claim() public {
        require(hasClaimed[msg.sender] == false, "You already claimed your rewards");
        require(claimAmount[msg.sender] > 0, "You have 0 BNB to claim");
        uint256 amountToClaim = claimAmount[msg.sender];
        claimAmount[msg.sender] = 0;
        hasClaimed[msg.sender] = true;
        payable(msg.sender).transfer(amountToClaim);
    }


    function addressHasClaimed() public view returns(bool) {
        return hasClaimed[msg.sender];
    }

    function claimableAmount() public view returns(uint256) {
        return claimAmount[msg.sender];
    }

    function getOwner() view public returns(address) {
        return owner;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() public onlyOwner{
        payable(owner).transfer(address(this).balance);
    }

    function deposit() public payable {  
        require(msg.value > 0 );
    }

    receive() external payable {}
}