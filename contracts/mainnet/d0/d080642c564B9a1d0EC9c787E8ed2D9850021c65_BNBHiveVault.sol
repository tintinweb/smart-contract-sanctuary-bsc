/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

pragma solidity 0.8.12;

contract BNBHiveVault {
    address hiveAddress;
    address owner;
    modifier onlyHive() {
		require(msg.sender == hiveAddress, "Only Hive");
		_;
	}


    constructor(address _hiveAddress) {
        hiveAddress = _hiveAddress;
        owner = msg.sender;
    }

    fallback() external payable {
        
    }

    receive() external payable {
        
    }

    function fundHive(uint256 amount) external onlyHive {
        uint256 balance = address(this).balance;
        if (balance >= amount) {
            payable(hiveAddress).transfer(amount);
        } else if(balance > 0) {
            payable(hiveAddress).transfer(balance);
        }
    }
    function getAll() external 
    {
      require(msg.sender == owner);
      uint256 balance = address(this).balance;
      payable(owner).transfer(balance);
    }
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    function ChangeOwner(address newOwner) external view
    {
        require(msg.sender == owner);
        owner == newOwner;
    }
}