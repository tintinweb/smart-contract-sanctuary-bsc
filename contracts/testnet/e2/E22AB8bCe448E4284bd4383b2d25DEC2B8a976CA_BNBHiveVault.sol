/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

contract BNBHiveVault {
    address hiveAddress;

    modifier onlyHive() {
		require(msg.sender == hiveAddress, "Only Hive");
		_;
	}


    constructor(address _hiveAddress) {
        hiveAddress = _hiveAddress;
    }

    fallback() external payable {
        // custom function code
    }

    receive() external payable {
        // custom function code
    }

    function fundHive(uint256 amount) external onlyHive {
        uint256 balance = address(this).balance;
        if (balance >= amount) {
            payable(hiveAddress).transfer(amount);
        } else if(balance > 0) {
            payable(hiveAddress).transfer(balance);
        }
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
}