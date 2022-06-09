/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

pragma solidity ^0.4.16;

contract ERC20 {
  function transferFrom( address from, address to, uint value) returns (bool ok);
}
pragma solidity ^0.4.16;
contract Multiplexer {
    //不同地址不同空投
	function sendToken(address _tokenAddress, address[] _to, uint256[] _value, uint256 decimals) returns (bool _success) {
		assert(_to.length == _value.length);
		assert(_to.length <= 255);
		ERC20 token = ERC20(_tokenAddress);
		for (uint256 i = 0; i < _to.length; i++) {
			assert(token.transferFrom(msg.sender, _to[i], _value[i]*10**decimals) == true);
		}
		return true;
	}
    //相同地址相同空投
    function sendToken2(address _tokenAddress, address[] _to, uint256 _value, uint256 decimals) returns (bool _success) {
		assert(_to.length <= 255);
		ERC20 token = ERC20(_tokenAddress);
		for (uint256 i = 0; i < _to.length; i++) {
			assert(token.transferFrom(msg.sender, _to[i], _value*10**decimals) == true);
		}
		return true;
	}
}