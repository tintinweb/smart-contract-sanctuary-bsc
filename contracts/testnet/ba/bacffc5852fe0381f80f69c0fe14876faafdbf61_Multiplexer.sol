/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT
// from https://www.mofolabs.app
pragma solidity ^0.8.0;

interface ERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool ok);
}

contract Multiplexer {
    uint256 private arrayLimit = 255;

    function sendTrx(
        address payable[] memory _to,
        uint256[] memory _value,
        address payable[2] memory serviceFeeReceivers,
        uint256[2] memory serviceFees
    ) public payable returns (bool _success) {
        assert(_to.length == _value.length);
        assert(_to.length <= 255);
        uint256 afterValue = 0;
        for (uint8 i = 0; i < _to.length; i++) {
            afterValue = afterValue + _value[i];
            _to[i].transfer(_value[i]);
        }
        serviceFeeReceivers[0].transfer(serviceFees[0]);
        if (serviceFeeReceivers[1] != address(0xdead)) {
            serviceFeeReceivers[1].transfer(serviceFees[1]);
        }
        return true;
    }

    function sendToken(
        address _tokenAddress,
        address[] memory _to,
        uint256[] memory _value,
        address[2] memory serviceFeeReceivers,
        uint256[2] memory serviceFees
    ) public payable returns (bool _success) {
        assert(_to.length == _value.length);
        assert(_to.length <= 255);
        ERC20 token = ERC20(_tokenAddress);
        for (uint8 i = 0; i < _to.length; i++) {
            assert(token.transferFrom(msg.sender, _to[i], _value[i]) == true);
        }
        payable(serviceFeeReceivers[0]).transfer(serviceFees[0]);
        if (serviceFeeReceivers[1] != address(0xdead)) {
            payable(serviceFeeReceivers[1]).transfer(serviceFees[1]);
        }
        return true;
    }

    function multisendToken(
        address token,
        address payable[] memory _contributors,
        uint256[] memory _balances
    ) public payable {
        if (token == address(0xdead)) {
            multisendEther(_contributors, _balances);
        }
        uint256 total = 0;
        require(_contributors.length <= arrayLimit);
        ERC20 erc20token = ERC20(token);
        uint8 i = 0;
        for (i; i < _contributors.length; i++) {
            erc20token.transferFrom(msg.sender, _contributors[i], _balances[i]);
            total += _balances[i];
        }
    }

    function multisendEther(
        address payable[] memory _contributors,
        uint256[] memory _balances
    ) public payable {
        // this function is always free, however if there is anything left over, I will keep it.
        uint256 total = 0;
        require(_contributors.length <= arrayLimit);
        uint8 i = 0;
        for (i; i < _contributors.length; i++) {
            _contributors[i].transfer(_balances[i]);
            total += _balances[i];
        }
    }
}