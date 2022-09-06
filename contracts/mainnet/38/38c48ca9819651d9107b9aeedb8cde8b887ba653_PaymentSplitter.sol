/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

/**
 //SPDX-License-Identifier: UNLICENSED
*/
pragma solidity ^0.8.4;
contract PaymentSplitter {
    address payable private _address1;
    address payable private _address2;
    

    receive() external payable {}

    constructor() {
        _address1 = payable(0xb7fa02352f6cD77d809028DA6f382Ce962958151); // M
        _address2 = payable(0xaF47Ef773501b093146b92D7f77A5e493D688bC3); // D
 
    }

    function withdraw() external {
        require(
            msg.sender == _address1 ||
            msg.sender == _address2
        , "Invalid admin address");

        uint256 split =  address(this).balance / 100;
        _address1.transfer(split * 50);
        _address2.transfer(split * 50);
    }

    function sendbnb(address _address, uint256 _amount) external {
        require(
            msg.sender == _address1 ||
            msg.sender == _address2  
        , "Invalid admin address");
        address payable to = payable(_address);
        to.transfer(_amount);
    }
}