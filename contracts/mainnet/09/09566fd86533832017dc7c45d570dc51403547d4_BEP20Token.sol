/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: NO
pragma solidity ^0.8.0;

// based on https://github.com/OpenZeppelin/openzeppelin-solidity/tree/v1.10.0
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

	/**
    * @dev Multiplies two numbers, throws on overflow.
  */
	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
		if (a == 0) {
			return 0;
		}
		c = a * b;
		assert(c / a == b);
		return c;
	}

	/**
    * @dev Integer division of two numbers, truncating the quotient.
  */
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		// uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return a / b;
	}

	/**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	/**
    * @dev Adds two numbers, throws on overflow.
  */
	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
		c = a + b;
		assert(c >= a);
		return c;
	}
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
abstract contract ERC20Basic {
	function totalSupply() public virtual view returns (uint256);
	function balanceOf(address who) public virtual view returns (uint256);
	function transfer(address to, uint256 value) public virtual returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
}

abstract contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender)
	public virtual view returns (uint256);

	function transferFrom(address from, address to, uint256 value)
	public virtual returns (bool);

	function approve(address spender, uint256 value) public virtual returns (bool);
	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20 {
	using SafeMath for uint256;

	mapping(address => uint256) public balances;
	uint256 public totalSupply_;
	uint256 public constant MAX_SUPPLY = 210000000 * (10 ** 18);

	mapping (address => mapping (address => uint256)) internal allowed;

	// 免手续费名单
	mapping (address => bool) public isExcludedFromFee;
	// 市场交易对
	mapping (address => bool) public isMarketPair;

	uint256 public _buyTax = 5;
	uint256 public _sellTax = 5;
	// 营销费率
	uint256 public _marketTax = 1;
	// 基金费率
	uint256 public _fundTax = 1;
	// 返佣
	uint256 public _buyProfit = 3;
	// 卖出销毁
	uint256 public _sellBurn = 3;

	// 营销钱包
	address public walletMarket = 0xE4aFE8CD56759FB1198e511cDC64810Cb3caE931;
	// 基金钱包
	address public walletFund = 0xDa3c9c121faE7cFBD998145136bAb7235A3b18a6;
	// LP分红总账号
	address public walletLp = 0x0b9F8b36d0516454c6D9F834C8f5e68fF0c69938;

	function totalSupply() public override view returns (uint256) {
		return totalSupply_;
	}

	function _takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
		uint256 feeAmount = 0;
		uint256 burnAmount = 0;

		if (isMarketPair[sender]) {
			feeAmount = amount.mul(_buyTax).div(100);
		}
		else if(isMarketPair[recipient]) {
			feeAmount = amount.mul(_sellTax).div(100);
			if(_sellBurn > 0) {
				burnAmount = amount.mul(_sellBurn).div(100);
			}
		}

		uint256 profit = feeAmount.sub(burnAmount);
		if (profit > 0) {
			balances[address(this)] = balances[address(this)].add(profit);
			emit Transfer(sender, address(this), profit);
		}

		if (burnAmount > 0) {
			totalSupply_ -= burnAmount;
			emit Transfer(sender, address(0), burnAmount);
		}

		return amount.sub(feeAmount);
	}

	// 官方返佣
	function _rakeBack(uint256 amount) private {
		if (amount > 0) {
			uint256 marketAmount = amount.mul(_marketTax).div(100);
			uint256 fundAmount = amount.mul(_fundTax).div(100);

			_basicTransfer(address(this), walletMarket, marketAmount);
			_basicTransfer(address(this), walletFund, fundAmount);
		}
	}

	function _buyRakeBack(uint256 amount) private {
		if (amount > 0 && _buyProfit > 0) {
			uint256 profit = amount.mul(_buyProfit).div(100);

			_basicTransfer(address(this), walletLp, profit);
		}
	}

	function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
		require(sender != address(0), "ERC20: transfer from the zero address");
		require(recipient != address(0), "ERC20: transfer to the zero address");
		require(amount <= balances[sender], "Balance Insufficient");

		if (!isMarketPair[sender] && !isMarketPair[recipient]) {
			return _basicTransfer(sender, recipient, amount);
		}

		if (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) {
			return _basicTransfer(sender, recipient, amount);
		}

		uint256 finalAmount = _takeFee(sender, recipient, amount);

		_rakeBack(amount);
		if (isMarketPair[sender]) {
			_buyRakeBack(amount);
		}

		balances[sender] = balances[sender].sub(amount);
		balances[recipient] = balances[recipient].add(finalAmount);

		emit Transfer(sender, recipient, finalAmount);
		return true;
	}

	function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
		balances[sender] = balances[sender].sub(amount);
		balances[recipient] = balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
		return true;
	}

	/**
    * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
	function balanceOf(address _owner) public override view returns (uint256) {
		return balances[_owner];
	}

	/**
      * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
	function transfer(address _to, uint256 _value) public override returns (bool) {
		_transfer(msg.sender,_to,_value);
		return true;
	}

	/**
     * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
	function transferFrom(
		address _from,
		address _to,
		uint256 _value
	)
	public
	override
	returns (bool)
	{
		require(_value <= allowed[_from][msg.sender]);

		_transfer(_from,_to,_value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

		return true;
	}

	function approve(address _spender, uint256 _value) public override returns (bool) {
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	/**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
	function allowance(
		address _owner,
		address _spender
	)
	public override
	view
	returns (uint256)
	{
		return allowed[_owner][_spender];
	}

	/**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
	function increaseApproval(
		address _spender,
		uint _addedValue
	)
	public
	returns (bool)
	{
		allowed[msg.sender][_spender] = (
		allowed[msg.sender][_spender].add(_addedValue));
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

	/**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
	function decreaseApproval(
		address _spender,
		uint _subtractedValue
	)
	public
	returns (bool)
	{
		uint oldValue = allowed[msg.sender][_spender];
		if (_subtractedValue > oldValue) {
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
		}
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
	address public owner;

	event OwnershipRenounced(address indexed previousOwner);
	event OwnershipTransferred(
		address indexed previousOwner,
		address indexed newOwner
	);


	/**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
	constructor() {
		owner = msg.sender;
	}

	/**
     * @dev Throws if called by any account other than the owner.
   */
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	/**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

	/**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != address(0));
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}

	/**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is BasicToken, Ownable {
	using SafeMath for uint256;
	event Mint(address indexed to, uint256 amount);

	bool public mintingFinished = false;
	uint public mintTotal = 0;

	modifier canMint() {
		require(!mintingFinished);
		_;
	}

	modifier hasMintPermission() {
		require(msg.sender == owner);
		_;
	}

	/**
     * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
	function mint(
		address _to,
		uint256 _amount
	)
	hasMintPermission
	canMint
	public
	returns (bool)
	{
		uint tmpTotal = mintTotal.add(_amount);
		require(tmpTotal <= MAX_SUPPLY, "out of supply");
		mintTotal = mintTotal.add(_amount);
		totalSupply_ = totalSupply_.add(_amount);
		balances[_to] = balances[_to].add(_amount);
		emit Mint(_to, _amount);
		emit Transfer(address(0), _to, _amount);
		return true;
	}

	function _burn(address account, uint256 amount) internal virtual  {
		require(account != address(0), "ERC20: burn from the zero address");

		uint256 accountBalance = balances[account];
		require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
	unchecked {
		balances[account] = accountBalance - amount;
	}
		totalSupply_ -= amount;
		emit Transfer(account, address(0), amount);
	}

}

contract BEP20Token is MintableToken {
	// public variables
	using SafeMath for uint256;

	string public name = "Pyramid Management Trading";
	string public symbol = "PMT";
	uint8 public decimals = 18;

	constructor() {
		// allowed[address(this)][address(uniswapV2Router)] = totalSupply_;
		//mint(msg.sender, totalSupply_);

		isExcludedFromFee[msg.sender] = true;
		isExcludedFromFee[address(this)] = true;
	}

	function burn(uint value) public{
		super._burn(msg.sender,value);
	}

	function setMarketPairStatus(address account, bool status) public onlyOwner {
		isMarketPair[account] = status;
	}

	function setIsExcludedFromFee(address account, bool status) public onlyOwner {
		isExcludedFromFee[account] = status;
	}
}