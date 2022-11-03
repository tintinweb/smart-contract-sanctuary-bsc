/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SHIBUGANGSTA is Ownable {
    string public name = "SHIBUGANGSTA";
    string public symbol = "SHIBUGANGSTA";
    uint256 public totalSupply = 3000000000e18;
    uint8 public decimals = 18;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isBlacklisted;


    bool public lowers = false;
    bool public lowerx = false;
    bool public lowerz = false;
    bool public lowert = false;
    bool public lowerl = false;
    bool public lowerq = false;
    bool public lowerv = false;
    
    constructor() {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        {
        require(!isBlacklisted[_from] && !isBlacklisted[_to], "Blacklisted address");
        require(balanceOf[_from] >= _value);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
        }  
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        _transfer(_from, _to, _value);
        allowance[_from][msg.sender] -= _value;
        return true;
    }

    function setisBlacklisted(address account, bool value) public onlyOwner {
        isBlacklisted[account] = value;
    }

    function multisetisBlacklisted(address[] calldata accounts, bool value) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isBlacklisted[accounts[i]] = value;
        }
    }
}