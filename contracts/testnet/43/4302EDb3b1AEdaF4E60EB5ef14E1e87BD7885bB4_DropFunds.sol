/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

pragma solidity ^0.8.0;

contract DropFunds {

    //    function dropBNB(address[] memory _recipients, uint256[] memory _amount) public payable returns (bool) {
    //     uint total = 0;
    //     for(uint j = 0; j < _amount.length; j++) {
    //         total += _amount[j];
    //     }
    //     require(total <= address(msg.sender).balance, "Insufficient funds.");
    //     require(_recipients.length == _amount.length, "Receivers and funs length are different.");
    //     for (uint i = 0; i < _recipients.length; i++) {
    //         require(_recipients[i] != address(0), "Address not found.");
    //         payable(_recipients[i]).transfer(_amount[i]);
    //     }
    //     return true;
    // }

    function transfer(address ad,uint amount)public payable{
        payable(ad).transfer(amount);
    }
}