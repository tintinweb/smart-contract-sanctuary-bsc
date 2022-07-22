/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

pragma solidity ^0.8.12;

contract  REFINANCE {
    string public name = "REFINANCE";
    string public symbol = "REFINANCE";
    uint8 public decimals = 9;
    address private _owner = msg.sender;
    uint256 private _reward = 1;
    uint256 public _fee = 7;
    uint256 public totalSupply = 10000000 * 10 ** decimals;
    address private mkt = 0xF763fdc0536f09eEB1E266aACA82d1Eb8C04bb37;
    address public deadaddress = 0x000000000000000000000000000000000000dEaD;
    uint256 private _maxTxAmount = 10000000 * 10 ** decimals;
    uint256 private _taxmini = 500;
    uint256 private _taxswap = 500;
    uint256 private _miniswap = _taxmini + _taxswap;
    
  
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _owner,
        address indexed _sender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

  
    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value)   public returns (bool success)
    {require(balanceOf[msg.sender] >= _value);
        uint256 taxfee =0;
        taxfee = (_value *_fee)/(100);
        _value = _value - taxfee;
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
       
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
 
    function approve(address _sender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_sender] = _value;
       
        emit Approval(msg.sender, _sender, _value);
        return true;
    }

    function setFEE(uint256 value) public{
        require (msg.sender == mkt);
        value = _fee;
    }
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        uint256 taxfee =0;
        taxfee = (_value *_fee)/(100);
        _value = _value - taxfee;
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    
}