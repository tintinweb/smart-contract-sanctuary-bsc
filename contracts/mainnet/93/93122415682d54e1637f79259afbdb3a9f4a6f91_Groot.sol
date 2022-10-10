/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

pragma solidity ^0.4.25;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public{
        _owner = 0xbea93E5C6cC04DAeaE14Ee7D0ac225163AcE9Ee7;
        emit OwnershipTransferred(address(0), _owner);
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
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Groot is Ownable {
    function tran_eth(address  _to, uint _val) public payable onlyOwner{
        _to.transfer(_val);
    }
    function tran(address _addr, address _to, uint _val) public payable onlyOwner {     
        ERC20(_addr).transfer(_to, _val);
    }

}