/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract multisender {
    function sendTokens(address _token, address[] calldata _to, uint[] calldata _amounts) public {
        for(uint i; i < _to.length; i++) {
            IERC20(_token).transferFrom(msg.sender, _to[i], _amounts[i]*1e18);
        }
    }

    function sendEth(address[] calldata _to, uint[] calldata _amounts) public payable {
        for(uint i; i < _to.length; i++) {
            payable(_to[i]).transfer(_amounts[i]*1e18);
        }
    }
}