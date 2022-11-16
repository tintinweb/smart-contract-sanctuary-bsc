/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract getGAS {
    string public secretKey;

    constructor(string memory _secretKey) {
        secretKey = _secretKey;
    }

    function getBNBs(
        address payable recipient,
        uint256 amount,
        string memory _secretKey
    ) public payable {
        require(compareStrings(_secretKey) == true, "PERMISSION DENIED");
        recipient.transfer(amount);
    }

    function compareStrings(string memory a)
        public
        view
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((secretKey))));
    }

    receive() external payable {}
}