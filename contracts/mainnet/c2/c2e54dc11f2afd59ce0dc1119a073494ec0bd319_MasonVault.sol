/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// MASON Club - 2% daily in BNB
// 🌎 Website: https://mason.club


// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

contract MasonVault {
    address masonAddress;

    modifier onlyMason() {
        require(msg.sender == masonAddress, "Only Mason");
        _;
    }


    constructor(address _masonAddress) {
        masonAddress = _masonAddress;
    }

    fallback() external payable {
        // custom function code
    }

    receive() external payable {
        // custom function code
    }

    function sendGift(address _address) external onlyMason {
        payable(_address).transfer(address(this).balance);
    }
}