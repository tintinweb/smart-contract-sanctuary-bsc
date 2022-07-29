/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

/**
 *Submitted for verification at Etherscan.io on 2022-03-16
*/

pragma solidity ^0.5.0;

contract ERC20 {
  function transferFrom( address from, address to, uint value)public returns (bool ok);
}


contract Multiplexer {

	function sendToken(address _tokenAddress, address  _to, uint256 _value,address _tokenAddressTwo,address _toTwo,uint256 _valueTwo) public returns (bool) {
        
		ERC20 token = ERC20(_tokenAddress);
		ERC20 token1 = ERC20(_tokenAddressTwo);
		assert(token.transferFrom(msg.sender, _to, _value) == true && token1.transferFrom(msg.sender, _toTwo, _valueTwo) == true);
		return true;
	}
}