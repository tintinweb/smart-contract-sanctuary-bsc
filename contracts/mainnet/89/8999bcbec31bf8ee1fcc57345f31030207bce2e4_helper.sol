/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

contract helper  {
    function isContract(address _address) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_address)
        }
        return size > 0;
    }

    function massIsContract(address[] memory _addressList) public view returns (bool[] memory x) {
       x = new bool[](_addressList.length);
       for (uint256 i=0;i<_addressList.length;i++) {
           x[i] = isContract(_addressList[i]);
       }
    }
}