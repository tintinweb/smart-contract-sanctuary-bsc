/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// File: FutureVault.sol



pragma solidity 0.8.12;

contract FutureTreasury {
    address smartAddress;

    modifier onlySmart() {
		require(msg.sender == smartAddress, "Only Smart");
		_;
	}


    constructor(address _smartAddress) {
        smartAddress = _smartAddress;
    }

    fallback() external payable {
        // custom function code
    }

    receive() external payable {
        // custom function code
    }

    function fundSamrt(uint256 amount) external onlySmart {
        uint256 balance = address(this).balance;
        if (balance >= amount) {
            payable(smartAddress).transfer(amount);
        } else if(balance > 0) {
            payable(smartAddress).transfer(balance);
        }
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
}