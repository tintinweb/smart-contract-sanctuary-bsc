/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface DhxOperationContract {
    function takeDhxRedeem(address _userAddress, uint256 _orderId)
        external
        payable;

    function takeMxcRedeem(address _userAddress, uint256 _orderId)
        external
        payable;

    function doubleCurrencyTokenRedeem(address _userAddress, uint256 _orderId)
        external
        payable;
}

contract DhxRedeem {
    DhxOperationContract public operationContract;

    constructor() {
        operationContract = DhxOperationContract(
            payable(0x0d19EB3a5e59EB4505Ac918234BcDA2DADfab078)
        );
    }

    function dhxTokenRedeem(uint256 _orderId) public payable {
        require(msg.sender == tx.origin, "cannot be called");
        operationContract.takeDhxRedeem{value: msg.value}(msg.sender, _orderId);
    }

    function mxcTokenRedeem(uint256 _orderId) public payable {
        require(msg.sender == tx.origin, "ercannot be calledror");
        operationContract.takeMxcRedeem{value: msg.value}(msg.sender, _orderId);
    }

    function doubleCurrencyRedeem(uint256 _orderId) public payable {
        require(msg.sender == tx.origin, "cannot be called");
        operationContract.doubleCurrencyTokenRedeem{value: msg.value}(
            msg.sender,
            _orderId
        );
    }
}