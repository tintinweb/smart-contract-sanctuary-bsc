/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);

    function balanceOf(address account) external view returns (uint256);
}

contract Batch {
    function sendSameAmount(
        address _tokenAddr,
        uint256 _amount,
        address[] memory _recipients
    ) public {
        IERC20 token = IERC20(_tokenAddr);
        uint256 totalAmount = _amount * _recipients.length;
        require(
            totalAmount < token.balanceOf(msg.sender),
            "not enough balance"
        );
        token.transferFrom(msg.sender, address(this), totalAmount);
        for (uint256 i = 0; i < _recipients.length; i++) {
            token.transfer(_recipients[i], _amount);
        }
    }

    function sendDifferentAmount(
        address _tokenAddr,
        uint256 _total,
        address[] memory _recipients,
        uint256[] memory _amountArray
    ) public {
        require(_recipients.length == _amountArray.length, "length not match");
        IERC20 token = IERC20(_tokenAddr);
        token.transferFrom(msg.sender, address(this), _total);
        uint256 sumCount = 0;
        for (uint256 i = 0; i < _recipients.length; i++) {
            sumCount += _amountArray[i];
            token.transfer(_recipients[i], _amountArray[i]);
        }
        require(sumCount == _total, "total amount not match");
    }
}