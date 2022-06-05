// BNB Hive - 3% daily in BNB
// 🌎 Website: https://bnb-hive.net/
// 📱 Telegram: https://t.me/Bnb_hive_official
// 🌐 Twitter: https://twitter.com/bnb_hive

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