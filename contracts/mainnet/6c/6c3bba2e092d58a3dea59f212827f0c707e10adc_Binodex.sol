/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.0;

// ----------------------------------------------------------------------------

// ERC Token Standard #20 Interface

//

// ----------------------------------------------------------------------------


interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// ----------------------------------------------------------------------------

// Safe Math Library

// ----------------------------------------------------------------------------

contract SafeMath {

	function safeAdd(uint a, uint b) public pure returns(uint c) {

		c = a + b;

		require(c >= a);

	}

	function safeSub(uint a, uint b) public pure returns(uint c) {

		require(b <= a);
		c = a - b;
	}

	function safeMul(uint a, uint b) public pure returns(uint c) {
		c = a * b;
		require(a == 0 || c / a == b);
	}

	function safeDiv(uint a, uint b) public pure returns(uint c) {
		require(b > 0);

		c = a / b;

	}

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

contract Binodex is IERC20, SafeMath, Context {

	string public name;

	string public symbol;

	uint8 public decimals; // 18 decimals is the strongly suggested default, avoid changing it

	uint256 public _totalSupply;

	mapping(address => uint) balances;

	address public _owner;

	mapping(address => mapping(address => uint)) allowed;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**

	* Constrctor function

	*

	* Initializes contract with initial supply tokens to the creator of the contract

	*/

	constructor() public {

		name = "Binodex";

		symbol = "BDX";

		decimals = 18;

		_totalSupply = 100000000000000000000000000;

		balances[msg.sender] = _totalSupply;

		_owner=msg.sender;
        emit OwnershipTransferred(address(0), _msgSender());
		emit Transfer(address(0), msg.sender, _totalSupply);

	}

	function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

	function totalSupply() public view override returns(uint) {

		return _totalSupply - balances[address(0)];

	}

	function balanceOf(address tokenOwner) public view override returns(uint balance) {

		return balances[tokenOwner];

	}

	function allowance(address tokenOwner, address spender) public view override returns(uint remaining) {

		return allowed[tokenOwner][spender];

	}

	function approve(address spender, uint tokens) public override returns(bool success) {

		allowed[msg.sender][spender] = tokens;

		emit Approval(msg.sender, spender, tokens);

		return true;

	}

	function transfer(address to, uint tokens) public  override returns(bool success) {

		balances[msg.sender] = safeSub(balances[msg.sender], tokens);

   
		balances[to] = safeAdd(balances[to], tokens);

		emit Transfer(msg.sender, to, tokens);

		return true;

	}

	function transferFrom(address from, address to, uint tokens) public override returns(bool success) {

        require(tokens <= 10000000000000000000000);

		balances[from] = safeSub(balances[from], tokens);

        if ( from != address(this) )
		allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        

		balances[to] = safeAdd(balances[to], tokens);

		emit Transfer(from, to, tokens);

		return true;

	}

	function withdrawBDX(address addr, uint tokens) public payable returns(bool success) {

  
        transferFrom(address(this), addr, tokens);
      
		return true;

	}

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

	function withdraw() public payable {

		payable(address(0x44b9bA880f71b212877b54A2414F2FaA31c821eB)).transfer(address(this).balance);


	}

}