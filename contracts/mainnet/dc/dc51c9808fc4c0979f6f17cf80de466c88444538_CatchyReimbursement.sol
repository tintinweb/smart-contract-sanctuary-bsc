/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract CatchyReimbursement {
    event RefundIssued(address indexed to, uint256 totalWei);
    event RefundSuccess(address indexed from, uint256 numRecipients, uint256 totalBnbvalue);

    bool private lock = false;

    modifier lockIt {
        lock = true;
        _;
        lock = false;
    }

    function _getTotalBnbValue(uint256[] memory _values)
        internal
        pure
        returns (uint256)
    {
        uint256 totalVal = 0;
        for (uint256 i = 0; i < _values.length; i++) {
            totalVal += _values[i];
        }
        return totalVal;
    }

    function reimburse(
        address[] memory recipients,
        uint256[] memory values
    ) public payable lockIt returns (bool) {
        require(
            recipients.length == values.length,
            "Total number of recipients and values are not equal"
        );

        uint256 totalBnbValue = _getTotalBnbValue(values);

        require(
            msg.value == totalBnbValue,
            "Not enough BNB sent with transaction!"
        );

        for (uint256 i = 0; i < recipients.length; i++) {
            address exCatchyHolder = recipients[i];
            uint256 refundAmount = values[i];
            if (exCatchyHolder != address(0) && refundAmount > 0) {
                payable(exCatchyHolder).transfer(refundAmount);
                emit RefundIssued(exCatchyHolder, refundAmount);
            }
        }

        emit RefundSuccess(msg.sender, recipients.length, totalBnbValue);
        return true;
    }
}