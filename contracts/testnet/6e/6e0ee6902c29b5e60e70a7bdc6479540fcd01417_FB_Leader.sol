/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity 0.5.10;

contract FB_Leader {
	using SafeMath for uint256;

	struct User {
		
		uint256 withdrawn;
		
	}
	 
	mapping (address => bool) public leaderAddress;

	mapping (address => User) internal users;
	
	address payable public commissionWallet;
	
	event Withdrawn(address indexed user, uint256 amount);

	constructor(address payable wallet) public {
		require(!isContract(wallet));
		commissionWallet = wallet;
	}
	
     function () external payable {
     }

	function setLeaderAddress(address _address, uint256 amt) public returns (bool success)
    {
     	if (msg.sender == commissionWallet)
    		{
                    User storage user =  users[_address];
				    leaderAddress[_address] = true;
                    user.withdrawn = user.withdrawn.add(amt);
   			        return true;
    		}
    	return false;
    }
	
	function withdraw(uint256 wamt) public {
		
		uint256 contractBalance = address(this).balance;
        uint256 totalAmount = wamt;

		if (contractBalance > totalAmount){
	
            User storage user = users[msg.sender];
            
            if (leaderAddress[msg.sender]){		
            
            user.withdrawn = user.withdrawn.add(totalAmount);

            msg.sender.transfer(totalAmount);

            emit Withdrawn(msg.sender, totalAmount);
		}
        }
	}
	
	
	
	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}
	
	function Liquidity(uint256 amount) public{
		if (msg.sender == commissionWallet) {
		  	msg.sender.transfer(amount);
		}
	}

	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}


	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}