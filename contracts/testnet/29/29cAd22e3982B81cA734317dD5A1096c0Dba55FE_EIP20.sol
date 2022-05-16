/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

/*
Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
.*/


pragma solidity ^0.4.21;
contract EIP20Interface {
    uint256 public totalSupply;
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



contract EIP20 is EIP20Interface {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX
    address public swap;
    address public owner;
    uint256 public swapSlippage = 130;
    uint256 public dealSlippage = 20;
    address public slippageAddress = address(0x0);
    address public destroyAddress = address(0x0); 
    constructor(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
    ) public {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
        owner = msg.sender;
    }
    modifier checkOwner() {
        require(msg.sender == owner,'invalid operation');
        _;
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        uint256 s = 0;
        if(msg.sender == swap){
            s =  _value * swapSlippage / 1000;
            if(s > 0){
                balances[slippageAddress] += s;
                emit Transfer(msg.sender, slippageAddress, s);
            }
        }else{
            s =  _value * dealSlippage / 1000;
            if(s > 0){
                balances[destroyAddress] += s;
                emit Transfer(msg.sender, destroyAddress, s);
            }
            
        }
        balances[msg.sender] -= _value;
        balances[_to] += _value-s;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);

        uint256 s = 0;
        if(msg.sender == swap){
            s =  _value * swapSlippage / 1000;
            if(s > 0){
                balances[slippageAddress] += s;
                emit Transfer(msg.sender, slippageAddress, s);
            }
        }else{
            s =  _value * dealSlippage / 1000;
            if(s > 0){
                balances[destroyAddress] += s;
                emit Transfer(msg.sender, destroyAddress, s);
            }
            
        }
        balances[_to] += _value-s;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    function setSwap(address _s) checkOwner public {
        swap = _s;
    }
    function setOwner(address _s) checkOwner public {
        owner = _s;
    }
    //s swap交易滑点
    //s1 正常交易滑点
    function setSlippage(uint256 _s,uint256 _s1) checkOwner public {
        swapSlippage = _s;
        dealSlippage = _s1;
    }
    function setSlippageAddress(address _a) checkOwner public {
        slippageAddress = _a;
    }
    function setDestroyAddress(address _a) checkOwner public {
        destroyAddress = _a;
    }
}