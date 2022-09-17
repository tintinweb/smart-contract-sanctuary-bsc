/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

pragma solidity =0.6.12;
// SPDX-License-Identifier: MIT

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract transferHelper {
    function transfer(IERC20 _token, address[] memory _addressList, uint256 _amount) external {
        for (uint256 i = 0; i < _addressList.length; i++) {
            _token.transferFrom(msg.sender, _addressList[i], _amount);
        }
    }
}