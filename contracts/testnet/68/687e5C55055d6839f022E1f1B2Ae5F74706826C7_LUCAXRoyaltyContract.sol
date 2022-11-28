/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ILUCAX {
    function getOwner() external view returns (address);
}

contract LUCAXRoyaltyContract {

    address public LUCAX;
    address public owner;
    uint256 private fee;
    address private feeRecipient;

    modifier onlyOwner(){
        require(msg.sender == owner, 'Only Owner');
        _;
    }

    constructor(address LUCAXAddr,uint fee_, address recipient_) {
        fee = fee_;
        feeRecipient = recipient_;
        LUCAX = LUCAXAddr;
        owner = ILUCAX(LUCAX).getOwner();
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

    function getFee() external view returns (uint256) {
        return fee;
    }

    function getFeeRecipient() external view returns (address) {
        return feeRecipient;
    }


}