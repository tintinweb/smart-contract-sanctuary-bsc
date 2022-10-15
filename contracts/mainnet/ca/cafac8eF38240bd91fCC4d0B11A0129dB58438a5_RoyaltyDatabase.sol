/**
 *Submitted for verification at BscScan.com on 2022-10-14
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract RoyaltyDatabase {

    uint256 private fee;
    address private feeRecipient;

    address public owner;

    modifier onlyOwner(){
        require(msg.sender == owner, 'Only Owner');
        _;
    }

    constructor(uint fee_, address recipient_) {
        fee = fee_;
        feeRecipient = recipient_;
    }

    function setFee(uint newFee) external onlyOwner {
        require(
            newFee <= 50,
            'Fee Too High'
        );
        fee = newFee;
    }

    function setFeeRecipient(address recipient) external onlyOwner {
        require(
            recipient != address(0),
            'Zero Address'
        );
        feeRecipient = recipient;
    }

    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function getFee() external view returns (uint256) {
        return fee;
    }

    function getFeeRecipient() external view returns (address) {
        return feeRecipient;
    }


}