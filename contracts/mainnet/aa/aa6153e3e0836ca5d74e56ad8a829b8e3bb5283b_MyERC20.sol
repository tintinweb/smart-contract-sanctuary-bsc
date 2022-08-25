/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: GPL-3.0

//examplee sdasdasdsdadsadsadasdasdsad


pragma solidity >= 0.5.0 < 0.9.0;

abstract contract ERC20_STD
{

    function name() public view virtual returns (string memory);
    function symbol() public view virtual returns (string memory);
    function decimals() public view virtual returns (uint8);


    function totalSupply() public view virtual returns (uint256);
    function balanceOf(address _owner) public view virtual returns (uint256 balance);
    function transfer(address _to, uint256 _value) public virtual returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool success);
    function approve(address _spender, uint256 _value) public virtual returns (bool success);
    function allowance(address _owner, address _spender) public virtual view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract OwnerShip
{

    address public contractOnwer;
    address public newOwner;

    event TransferOwnership(address indexed _from, address indexed _to);

    constructor(){
        contractOnwer = msg.sender;
    }

    function changeOwner(address _to) public{
        require(msg.sender == contractOnwer, "Only owner can call it");
        newOwner = _to;
    }

    function acceptOwner() public{
        require(msg.sender==newOwner, "Only new owner can call it");
        contractOnwer = newOwner;
        newOwner =  address(0);
        emit TransferOwnership(contractOnwer, newOwner);

    }

}

contract MyERC20 is ERC20_STD,OwnerShip
{
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint256 public _totalSupply;

    address public _minter;

    mapping(address => uint256) tokenBalances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor (address minter_) {
        _name ="Silly Coin";
        _symbol="SC";
       // _decimals=""
        _totalSupply= 1000;
        _minter = minter_;
        tokenBalances[_minter]= _totalSupply;



    }
    
    function name() public view override returns (string memory){
        return _name;
    }

    function symbol() public view override returns (string memory){
        return _symbol;
    }


    function decimals() public view override returns (uint8){
        return _decimals;
    }

    function totalSupply() public view override returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) public view override returns (uint256 balance){
        return tokenBalances[_owner];
    }

    function transfer(address _to, uint256 _value) public override returns (bool success){
        require(tokenBalances[msg.sender] >= _value,"Insucifient balance");
        tokenBalances[msg.sender] -= _value;
        tokenBalances[_to] += _value;
        emit Transfer(msg.sender,_to, _value);
        return true;

    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success){
        uint  allowedBal = allowed[_from][msg.sender];
        require(allowedBal >= _value, "Insucifient balance ");
        tokenBalances[_from] -= _value;
        tokenBalances[_to] += _value;
        emit Transfer(_from,_to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool success){
        require(tokenBalances[msg.sender] >= _value,"Insucifient balance");
        allowed[msg.sender][_spender]= _value;
        emit Approval(msg.sender, _spender, _value);
        return true;

    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining){
        return allowed[_owner][_spender];
    }














}