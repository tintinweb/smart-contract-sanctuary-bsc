/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.4.16;


contract Ownable {
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}



contract ERC20 {
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom( address from, address to, uint value) returns (bool ok);
}


contract Multiplexer is Ownable {


	function sendErc20(address _tokenAddress, address[] _to, uint256[] _value) payable returns (bool _success) {
		// input validation
		assert(_to.length == _value.length);
		assert(_to.length <= 255);

		// use the erc20 abi
		ERC20 token = ERC20(_tokenAddress);
		// loop through to addresses and send value
		for (uint8 i = 0; i < _to.length; i++) {
			assert(token.transferFrom(msg.sender, _to[i], _value[i]) == true);
		}
		return true;
	}

}