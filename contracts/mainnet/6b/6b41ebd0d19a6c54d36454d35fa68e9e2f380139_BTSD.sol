/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

pragma solidity 0.5.16;
/*
* used 0.5.16 compailer due to lower gas charges
* SPDX-License-Identifier: MIT
* created by i70i7
*/

interface IBEP20{
	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
	function totalSupply() external view returns (uint256);
	function balanceOf(address _owner) external view returns (uint256 balance);
	function getOwner() external view returns (address);
	function transfer(address _to, uint256 _value) external returns (bool success);
	function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
	function approve(address _spender, uint256 _value) external returns (bool success);
	function allowance(address _owner, address _spender) external view returns (uint256 remaining);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	
}
// BEP20 token contract
contract BTSD is IBEP20{
    
    using SafeMath for uint256;

    mapping (address => uint256) private balances;

    mapping (address => mapping (address => uint256)) private allowed;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;
    address private _owner;
    IBEP20 private quoteToken;


   constructor() public {
    _name = "BSC Teather Stabile Deflation";
    _symbol = "BTSD";
    _decimals = 18;
    _totalSupply = 0;
    _owner = msg.sender;
    // Create USDT as quote token: contract address 0x55d398326f99059fF775485246999027B3197955
    quoteToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    }
    // Returns the token owner address.
    function getOwner() external view returns (address) {
    return _owner;
    }
    //Returns the token decimals
    function decimals() external view returns (uint8) {
    return _decimals;
    }
    // Returns the token symbol
    function symbol() external view returns (string memory) {
    return _symbol;
    }
    // Returns the token name
    function name() external view returns (string memory) {
    return _name;
    }
    // Returns total supply
    function totalSupply() external view returns (uint256) {
    return _totalSupply;
    }
    // Returns balance of specified address
    function balanceOf(address tokenOwner) external view returns (uint256) {
        return balances[tokenOwner];
    }
    // transfer amount to specified address
    function transfer(address receiver, uint256 amount) external returns (bool) {
        
        _transfer(msg.sender, receiver, amount);
        return true;
    }
    
    /* 
    * Approve other account to use your token
    * Requires:
    *    - sender cant be zero address
    *    - delegate can't be zero address
    */
    function approve(address delegate, uint256 amount) external returns (bool) {
        require(delegate != address(0));
        require(msg.sender != address(0));
        allowed[msg.sender][delegate] = amount;
        emit Approval(msg.sender, delegate, amount);
        return true;
    }
    // Returns how much owners tokens can be used by delegate
    function allowance(address owner, address delegate) external view returns (uint) {
        return allowed[owner][delegate];
    }
    /* Transfer amount as delegate
    * Sub amount from allowed map
    * Requires:
    *    -the caller must have allowance for `owner`'s tokens of at least
    *     amount -> checked by SafeMach library in sub method
    *    - other see in _transfer method
    */
    function transferFrom(address owner, address buyer, uint256 amount) external returns (bool) {
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(amount);
        _transfer(owner, buyer, amount);
        return true;
    }
    /* Transfer amount
    * Requires:
    *     -the caller must have a balance greater than the required amount -> 
            checked in the SafeMath library in the sub method
    *    - sender can't be zero address
    *    - receiver can't be zero address
    */
    function _transfer(address sender, address receiver, uint256 amount) internal {
        require(sender != address(0));
        require(receiver != address(0));
        balances[sender] = balances[sender].sub(amount);
        balances[receiver] = balances[receiver].add(amount);
        emit Transfer(sender, receiver, amount);
    }
    function buy(uint256 quoteAmount) external returns(bool){
        require(msg.sender != address(0));
        require(quoteAmount <= quoteToken.allowance(msg.sender,address(this)));
        // get baseAmount including trading fee 0.3% 
        uint256 baseAmount = quoteAmount.mul(_totalSupply).div(quoteToken.balanceOf(address(this))).mul(997).div(1000);
        quoteToken.transferFrom(msg.sender, address(this), quoteAmount);
         // mint new tokens -> baseAmount + development fee 0.01%
        _totalSupply = _totalSupply.add(baseAmount.add(baseAmount.div(10000)));
        // send baseAmount to buyer
        balances[msg.sender] = balances[msg.sender].add(baseAmount);
        // pay development fee  0.01% baseAmount/10000
        balances[_owner] = balances[_owner].add(baseAmount.div(10000));
        emit Transfer(address(0), msg.sender, baseAmount);
        return true;
    }
    function sell(uint256 baseAmount) external returns(bool){
        //the seller must have sufficient funds
        require(baseAmount <= balances[msg.sender]);
        // get quoteAmount including trading fee 0.3%
        uint256 quoteAmount = baseAmount.mul(quoteToken.balanceOf(address(this))).div(_totalSupply).mul(997).div(1000);
        balances[msg.sender] = balances[msg.sender].sub(baseAmount);
        // burn tokens baseAmount with deducted development fee
        _totalSupply = _totalSupply.sub(baseAmount.sub(baseAmount.div(10000)));
        // send amount to seller
        quoteToken.transfer(msg.sender, quoteAmount);
        // pay development fee  0.01% baseAmount/10000
        balances[_owner] = balances[_owner].add(baseAmount.div(10000));
        emit Transfer(msg.sender, address(0), baseAmount);
        return true;
    }
    
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      require(c >= a);
      return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        /*
        * none of the entries can't be 0 to avoid error
        * at the beginning _totalSupply and quoteToken.balanceOf(address(this)) 
        * have a value of 0, that would cause an error in calculating the price
        */
        if (a == 0) {
           a = 1;
        }
        if (b == 0) {
           b = 1;
        }
        

        uint256 c = a * b;
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        /*
        * none of the entries can't be 0 to avoid error
        * at the beginning _totalSupply and quoteToken.balanceOf(address(this)) 
        * have a value of 0, that would cause an error in calculating the price
        */
        if (a == 0) {
           a = 1;
        }
        if (b == 0) {
           b = 1;
        }
        uint256 c = a / b; 
        return c;
    }
}