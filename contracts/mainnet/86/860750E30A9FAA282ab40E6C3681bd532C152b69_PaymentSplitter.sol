/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

/**
 *Submitted for verification at Etherscan.io on 2022-03-23
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
        _address1 = payable(0x4CA8C93f9c099B6aFB7dfce061833840d6594370); // DS
        _address2 = payable(0xaF47Ef773501b093146b92D7f77A5e493D688bC3); // DP
        _address3 = payable(0x458eCC92a5986eaAB544Ef9ac66a1E46E0c69761); // DM
        _address4 = payable(0xe5E422014D4a535002d289A888a30AEc9276097B); // R
        _address5 = payable(0x5e5bdeECee8B59C5CD1a68444b420895530C01eA); // M
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