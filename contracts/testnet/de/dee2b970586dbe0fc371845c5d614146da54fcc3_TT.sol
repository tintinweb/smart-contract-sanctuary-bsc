/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

pragma solidity 0.5.16;
// used 0.5.16 compailer due to lower gas charges
// SPDX-License-Identifier: MIT
// created by i70i7

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
contract TT is IBEP20{
    
    using SafeMath for uint256;

    mapping (address => uint256) private balances;

    mapping (address => mapping (address => uint256)) private allowed;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;
    address private _owner;


   constructor(uint256 total) public {
    _name = "Test token";
    _symbol = "TT";
    _decimals = 18;
    _totalSupply = total;
    _owner = msg.sender;
    balances[msg.sender] = _totalSupply;
    }
    // Returns the bep token owner.
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
    
    /* Approve other account to use your token
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
    *    - sender cant be zero address
    *    - receiver can't be zero address
    */
    function _transfer(address sender, address receiver, uint256 amount) internal {
        require(sender != address(0));
        require(receiver != address(0));
        balances[sender] = balances[sender].sub(amount);
        balances[receiver] = balances[receiver].add(amount);
        emit Transfer(sender, receiver, amount);
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
}