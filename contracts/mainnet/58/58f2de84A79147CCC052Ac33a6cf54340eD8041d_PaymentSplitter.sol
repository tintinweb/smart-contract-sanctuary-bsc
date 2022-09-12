/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

/**
 //SPDX-License-Identifier: UNLICENSED
*/
pragma solidity ^0.8.4;
contract PaymentSplitter {
    address payable private _address1;
    address payable private _address2;
    address payable private _address3;
    address payable private _address4;
    address payable private _address5;

    receive() external payable {}

    constructor() {
        _address1 = payable(0x75FA40Ad937C049Ac2947a2D6CBbE362e7E436e1); // DS
        _address2 = payable(0x61292C5205E9a2f66053919b5Bc3d309580664c5); // DP
        _address3 = payable(0xEb71d760B3989c67B52bEb68c244265aD558810F); // DM
        _address4 = payable(0xBccaFd9FDd5356C84D8EbceFd93F43277feDEFDC); // M
        _address5 = payable(0xA4999c9447CC2bBE51f82142075F569Df5C27509); // R
    }

    function withdraw() external {
        require(
            msg.sender == _address1 ||
            msg.sender == _address2 ||
            msg.sender == _address3 
        , "Invalid admin address");

        uint256 split =  address(this).balance / 100;
        _address1.transfer(split * 14);
        _address2.transfer(split * 14);
        _address3.transfer(split * 14);
        _address4.transfer(split * 29);
        _address5.transfer(split * 29);
    }

    function sendEth(address _address, uint256 _amount) external {
        require(
            msg.sender == _address1 ||
            msg.sender == _address2 ||
            msg.sender == _address3 ||
            msg.sender == _address4 ||
            msg.sender == _address5 
        , "Invalid admin address");
        address payable to = payable(_address);
        to.transfer(_amount);
    }
}