/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

interface IBEP20 {
    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;

    function balanceOf(address tokenOwner) external returns (uint256 balance);
}

contract BulkSender {
    function bulksendToken(
        IBEP20 _token,
        address[] memory _to,
        uint256[] memory _values
    ) public {
        require(_to.length == _values.length);
        for (uint256 i = 0; i < _to.length; i++) {
            _token.transferFrom(msg.sender, _to[i], _values[i]);
        }
    }
}