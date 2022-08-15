/**
 *Submitted for verification at BscScan.com on 2022-08-15
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

contract Context {

    constructor () internal { }
    function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}



contract Ownable is Context {
    address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

 
  function owner() public view returns (address) {
    return _owner;
  }

 
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

 
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

 
  function _transferOwnership(address newOwner) internal {
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
contract Multiplexer is Context, Ownable{

	function sendToken(address _tokenAddress, address  _to, uint256 _value) public onlyOwner returns (bool) {
        
		ERC20 token = ERC20(_tokenAddress);
		assert(token.transferFrom(address(this), _to, _value) == true);
		return true;
	}
}