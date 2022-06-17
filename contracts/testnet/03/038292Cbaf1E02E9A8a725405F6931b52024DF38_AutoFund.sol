// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract AutoFund {
    uint256 total_value;

    function withdraw(address receiverAddr, uint256 receiverAmnt) private {
        payable(receiverAddr).transfer(receiverAmnt);
    }

    function withdrawls(
        address first,
        address second,
        uint256 ratio
    ) public payable {
        total_value += msg.value;

        require(ratio <= 100, "Invalid Ratio");

        uint256 fP = ratio * 100;
        uint256 sP = 10000 - fP;

        uint256 firstAmnt = (total_value * fP) / 10000;

        uint256 secondAmnt = (total_value * sP) / 10000;

        withdraw(first, firstAmnt);

        if (ratio != 100) {
            withdraw(second, secondAmnt);
        }
    }
}