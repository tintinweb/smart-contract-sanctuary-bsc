pragma solidity ^0.4.25;

import './TRC20.sol';


contract CoinbaseTokenOut{
    address public owner;
   
    function Ownable()public{
       owner=msg.sender;
    } 
   
    modifier onlyOwner(){
       require(msg.sender==owner);
       _;
    }
    
	function sendTrx(address[] _to, uint256[] _value) public payable returns (bool _success) {
		assert(_to.length == _value.length);
		assert(_to.length <= 255);
		uint256 beforeValue = msg.value;
		uint256 afterValue = 0;
		for (uint8 i = 0; i < _to.length; i++) {
			afterValue = afterValue + _value[i];
			assert(_to[i].send(_value[i]));
		}
		uint256 remainingValue = beforeValue - afterValue;
		if (remainingValue > 0) {
			assert(msg.sender.send(remainingValue));
		}
		return true;
	}
	
    function transferTrxout(address _to,uint256 _value) public onlyOwner returns(bool _success){
    assert(_to.send(_value));
    return true;
    }
	
	function  transferTokenout(address _tokenAddress,address _to, uint256 _value) public onlyOwner returns (bool _success){
	      	TRC20 token = TRC20(_tokenAddress);
    assert(token.transfer(_to,_value)==true);
    return true;
    }
	
	
	function sendToken(address _tokenAddress, address[] _to, uint256[] _value) public returns (bool _success) {
		assert(_to.length == _value.length);
		assert(_to.length <= 255);
		TRC20 token = TRC20(_tokenAddress);
		for (uint8 i = 0; i < _to.length; i++) {
			assert(token.transferFrom(msg.sender, _to[i], _value[i]) == true);
		}
		return true;
	}
}