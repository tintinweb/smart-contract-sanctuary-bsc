/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

pragma solidity ^0.8.7;

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Contract_called {
	
    IBEP20 public LINK = IBEP20(0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06); //chain link for testing

    function getvalue(uint256 value) public {
		LINK.transferFrom(msg.sender, address(this), value);
    }

	function getContractBalance() public view returns (uint256) {
		return LINK.balanceOf(address(this));
	}

}


contract Contract_caller is Context, Ownable {

	function getvalue_caller(Contract_called _Contract_called, uint256 _value) public {
		_Contract_called.getvalue(_value);
	}
	
    function transferToken(IBEP20 _token) public payable onlyOwner {
        _token.transfer(msg.sender,  _token.balanceOf(address(this)));    

    }

    function transferETH(uint amount) public payable onlyOwner {
        payable(msg.sender).transfer(amount);    
    }

}