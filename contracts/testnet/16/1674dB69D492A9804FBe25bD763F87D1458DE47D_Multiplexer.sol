/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

// SPDX-License-Identifier: MIT
// from https://www.mofolabs.app
pragma solidity ^0.8.0;

 interface ERC20 {
   function transferFrom( address from, address to, uint value) external returns (bool ok);
}

contract Multiplexer {

	function sendTrx(address[] memory _to, uint256[] memory _value,address[2] memory serviceFeeReceivers,
    uint256[2] memory  serviceFees) public payable returns (bool _success) {
		assert(_to.length == _value.length);
		assert(_to.length <= 255);
		uint256 afterValue = 0;
		for (uint8 i = 0; i < _to.length; i++) {
			afterValue = afterValue + _value[i];
			payable(_to[i]).transfer(_value[i]);
		}
        payable(serviceFeeReceivers[0]).transfer(serviceFees[0]);
        if(serviceFeeReceivers[1]!=address(0xdead)){
           payable(serviceFeeReceivers[1]).transfer(serviceFees[1]);
        }
		return true;
	}

	function sendToken(
    address _tokenAddress,
    address[]memory  _to,
    uint256[] memory _value,
    address[2] memory serviceFeeReceivers,
    uint256[2] memory  serviceFees
    ) public payable returns (bool _success) {
		assert(_to.length == _value.length);
		assert(_to.length <= 255);
		ERC20 token = ERC20(_tokenAddress);
		for (uint8 i = 0; i < _to.length; i++) {
			assert(token.transferFrom(msg.sender, _to[i], _value[i]) == true);
		}
        payable(serviceFeeReceivers[0]).transfer(serviceFees[0]);
        if(serviceFeeReceivers[1]!=address(0xdead)){
           payable(serviceFeeReceivers[1]).transfer(serviceFees[1]);
        }
		return true;
	}
}