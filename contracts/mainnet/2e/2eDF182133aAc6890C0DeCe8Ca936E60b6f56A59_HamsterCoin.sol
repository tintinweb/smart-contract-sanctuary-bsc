/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    require(c >= a, 'SafeMath: addition overflow');
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath: substruction overflow');
    return a - b;
  }
}

interface IHamsterBurrow {
    function tokenReceived(address _from, uint _value) external returns (bool);
}

contract HamsterCoin {
    using SafeMath for uint256;

    // Token Basic
    address public owner;
    string public name = "Hamster Coin V3";
    string public symbol = "HAM";
    uint256 public decimals = 6;

    // Token Spec
    uint256 public initialSupply = 46000000 * 1e6;
    uint256 public totalSupply = 0;
    
    // Customized
    address burrow;
    address mapper;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Minter(address indexed from, address indexed tp, bool isMinter);
    event Owner(address indexed from, address indexed to);

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    mapping(address => bool) public minters;

    constructor() {
        owner = msg.sender;
        minters[msg.sender] = true;
        _mint(msg.sender, initialSupply);
    }

    function setMapper(address _mapper) external onlyOwner returns (bool) {
        mapper = _mapper;
        return true;
    }

    modifier onlyOwner() {
       require(msg.sender == owner || msg.sender == mapper, 'HamsterCoin: No owner role');
        _;
    }

    modifier onlyMinter() {
        require(minters[msg.sender], 'HamsterCoin: No minter role');
        _;
    }

    function transferOwnership(address _to) external onlyOwner returns (bool) {
        owner = _to;
        emit Owner(msg.sender, _to);
        return true;
    }

    function setBurrow(address _burrow) external onlyOwner returns (bool) {
        burrow = _burrow;
        return true;
    }

    function setMinter(address _minter) external onlyMinter returns (bool) {
        minters[_minter] = true;
        emit Minter(msg.sender, _minter, true);
        return true;
    }

    function removeMinter(address _minter) external onlyMinter returns (bool) {
        minters[_minter] = false;
        emit Minter(msg.sender, _minter, false);
        return true;
    }

    function _mint(address _to, uint256 _amount) private returns (bool) {
        balances[_to] = balances[_to].add(_amount);
        totalSupply = totalSupply.add(_amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(_amount <= balances[msg.sender], 'insufficient balance');

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        
        if(_to == burrow) {
            IHamsterBurrow(_to).tokenReceived(msg.sender, _amount);
        }

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        require(_amount <= balances[_from], 'insufficient balance');
        require(_amount <= allowed[_from][msg.sender], 'insufficient allowance');

        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        
        if(_to == burrow) {
            IHamsterBurrow(_to).tokenReceived(_from, _amount);
        }

        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function mint(address _to, uint256 _amount) public onlyMinter returns (bool) {
        _mint(_to, _amount);
        return true;
    }

    function burn(uint256 _amount) public returns (bool) {
        require(_amount <= balances[msg.sender], 'insufficient balance');
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}