/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// File: contracts/ITransferListener.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface ITransferListener {
    function onTransfer(address msgSender, address sender, address recipient, uint amount) external;
}

// File: contracts/IReferBook.sol


pragma solidity >=0.4.22 <0.9.0;

interface IReferBook {
    function addReferForNoExist(address referral, address referrer) external;

    function getRefer(address referee) external view returns (address);
}

// File: contracts/ReferTransferListener.sol


pragma solidity >=0.4.22 <0.9.0;


contract ReferTransferListener is ITransferListener {
    IReferBook public referBook;

    constructor(IReferBook value) {
        referBook = value;
    }

    function onTransfer(address, address sender, address recipient, uint) public override {
        referBook.addReferForNoExist(recipient, sender);
    }
}