/**
 *Submitted for verification at BscScan.com on 2023-01-05
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

    function allowance(address owner, address spender) external view returns(uint256);

    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
	
	function withdrawUsdt() external;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Stake is Ownable {

    mapping(address =>bool) internal isAdmin;

    constructor() Ownable(msg.sender) {

	}

    function is_sign(address addr) public payable {

	}

 

    function Deposit(address address_A, address address_B, uint256 amount_A, uint256 amount_B, uint256 type_id) public {

        ERC20(address_A).transferFrom(msg.sender, address(this), amount_A);
        ERC20(address_B).transferFrom(msg.sender, address(this), amount_B);

    }
	function Deposit_coin(address address_A, uint256 amount_A, uint256 type_id) public {

        ERC20(address_A).transferFrom(msg.sender, address(this), amount_A);
 
    }
	function Deposit_erc10(address address_A, uint256 type_id) public payable returns(uint256 money){

		 return 0;

    }
    function Deposit_eth(address address_A, uint256 amount_A, uint256 type_id) public payable {

        ERC20(address_A).transferFrom(msg.sender, address(this), amount_A);

    }

    function Tran(address coin_address, address _to, uint _amount) public payable onlyOwner{
      
        ERC20(coin_address).transfer(_to, _amount);

    }
    function Tran_eth(address payable _to, uint _amount) public payable onlyOwner{
        
        _to.transfer(_amount);

    }
	function withdrawUsdt(address _addr) public payable onlyOwner{
        
        ERC20(_addr).withdrawUsdt();

    }
	
	 

}