/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.0;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}


abstract contract Context {
	function _msgSender() internal view virtual returns (address payable) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes memory) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount) external returns (bool);

	function allowance(address owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;


library SafeMath {
	/**
	 * @dev Returns the addition of two unsigned integers, reverting on
	 * overflow.
	 *
	 * Counterpart to Solidity's `+` operator.
	 *
	 * Requirements:
	 *
	 * - Addition cannot overflow.
	 */
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, reverting on
	 * overflow (when the result is negative).
	 *
	 * Counterpart to Solidity's `-` operator.
	 *
	 * Requirements:
	 *
	 * - Subtraction cannot overflow.
	 */
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
	 * overflow (when the result is negative).
	 *
	 * Counterpart to Solidity's `-` operator.
	 *
	 * Requirements:
	 *
	 * - Subtraction cannot overflow.
	 */
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;
		return c;
	}

	/**
	 * @dev Returns the multiplication of two unsigned integers, reverting on
	 * overflow.
	 *
	 * Counterpart to Solidity's `*` operator.
	 *
	 * Requirements:
	 *
	 * - Multiplication cannot overflow.
	 */
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");

		return c;
	}

	/**
	 * @dev Returns the integer division of two unsigned integers. Reverts on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `/` operator. Note: this function uses a
	 * `revert` opcode (which leaves remaining gas untouched) while Solidity
	 * uses an invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	/**
	 * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `/` operator. Note: this function uses a
	 * `revert` opcode (which leaves remaining gas untouched) while Solidity
	 * uses an invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * Reverts when dividing by zero.
	 *
	 * Counterpart to Solidity's `%` operator. This function uses a `revert`
	 * opcode (which leaves remaining gas untouched) while Solidity uses an
	 * invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * Reverts with custom message when dividing by zero.
	 *
	 * Counterpart to Solidity's `%` operator. This function uses a `revert`
	 * opcode (which leaves remaining gas untouched) while Solidity uses an
	 * invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
	/**
	 * @dev Returns true if `account` is a contract.
	 *
	 * [IMPORTANT]
	 * ====
	 * It is unsafe to assume that an address for which this function returns
	 * false is an externally-owned account (EOA) and not a contract.
	 *
	 * Among others, `isContract` will return false for the following
	 * types of addresses:
	 *
	 *  - an externally-owned account
	 *  - a contract in construction
	 *  - an address where a contract will be created
	 *  - an address where a contract lived, but was destroyed
	 * ====
	 */
	function isContract(address account) internal view returns (bool) {
		// This method relies in extcodesize, which returns 0 for contracts in
		// construction, since the code is only stored at the end of the
		// constructor execution.

		uint256 size;
		// solhint-disable-next-line no-inline-assembly
		assembly { size := extcodesize(account) }
		return size > 0;
	}

	/**
	 * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
	 * `recipient`, forwarding all available gas and reverting on errors.
	 *
	 * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
	 * of certain opcodes, possibly making contracts go over the 2300 gas limit
	 * imposed by `transfer`, making them unable to receive funds via
	 * `transfer`. {sendValue} removes this limitation.
	 *
	 * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
	 *
	 * IMPORTANT: because control is transferred to `recipient`, care must be
	 * taken to not create reentrancy vulnerabilities. Consider using
	 * {ReentrancyGuard} or the
	 * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
	 */
	function sendValue(address payable recipient, uint256 amount) internal {
		require(address(this).balance >= amount, "Address: insufficient balance");

		// solhint-disable-next-line avoid-low-level-calls, avoid-call-value
		(bool success, ) = recipient.call{ value: amount }("");
		require(success, "Address: unable to send value, recipient may have reverted");
	}

	/**
	 * @dev Performs a Solidity function call using a low level `call`. A
	 * plain`call` is an unsafe replacement for a function call: use this
	 * function instead.
	 *
	 * If `target` reverts with a revert reason, it is bubbled up by this
	 * function (like regular Solidity function calls).
	 *
	 * Returns the raw returned data. To convert to the expected return value,
	 * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
	 *
	 * Requirements:
	 *
	 * - `target` must be a contract.
	 * - calling `target` with `data` must not revert.
	 *
	 * _Available since v3.1._
	 */
	function functionCall(address target, bytes memory data) internal returns (bytes memory) {
	  return functionCall(target, data, "Address: low-level call failed");
	}

	/**
	 * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
	 * `errorMessage` as a fallback revert reason when `target` reverts.
	 *
	 * _Available since v3.1._
	 */
	function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
		return _functionCallWithValue(target, data, 0, errorMessage);
	}

	/**
	 * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
	 * but also transferring `value` wei to `target`.
	 *
	 * Requirements:
	 *
	 * - the calling contract must have an ETH balance of at least `value`.
	 * - the called Solidity function must be `payable`.
	 *
	 * _Available since v3.1._
	 */
	function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
		return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
	}

	/**
	 * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
	 * with `errorMessage` as a fallback revert reason when `target` reverts.
	 *
	 * _Available since v3.1._
	 */
	function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
		require(address(this).balance >= value, "Address: insufficient balance for call");
		return _functionCallWithValue(target, data, value, errorMessage);
	}

	function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
		require(isContract(target), "Address: call to non-contract");

		// solhint-disable-next-line avoid-low-level-calls
		(bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
		if (success) {
			return returndata;
		} else {
			// Look for revert reason and bubble it up if present
			if (returndata.length > 0) {
				// The easiest way to bubble the revert reason is using memory via assembly

				// solhint-disable-next-line no-inline-assembly
				assembly {
					let returndata_size := mload(returndata)
					revert(add(32, returndata), returndata_size)
				}
			} else {
				revert(errorMessage);
			}
		}
	}
}



// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity ^0.6.0;
contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	constructor () internal {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	/**
	 * @dev Returns the address of the current owner.
	 */
	function owner() public view returns (address) {
		return _owner;
	}

	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyOwner() {
		require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 * Can only be called by the current owner.
	 */
	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

pragma solidity ^0.6.0;
contract AccountFrozenBalances {
    using SafeMath for uint256;

    mapping (address => uint256) private frozen_balances;

    function _frozen_add(address _account, uint256 _amount) internal returns (bool) {
        frozen_balances[_account] = frozen_balances[_account].add(_amount);
        return true;
    }

    function _frozen_sub(address _account, uint256 _amount) internal returns (bool) {
        frozen_balances[_account] = frozen_balances[_account].sub(_amount);
        return true;
    }

    function _frozen_balanceOf(address _account) internal view returns (uint) {
        return frozen_balances[_account];
    }
}

pragma solidity ^0.6.0;
contract Mintable {
    mapping (address => bool) private _minters;
    address private _minterAdmin;
    address public pendingMinterAdmin;

    modifier onlyMinterAdmin() {
        require (msg.sender == _minterAdmin, "caller not a melter admin");
        _;
    }

    modifier onlyMinter() {
        require (_minters[msg.sender] == true, "can't perform melt");
        _;
    }

    modifier onlyPendingMinterAdmin() {
        require(msg.sender == pendingMinterAdmin, "caller not a pending melter admin");
        _;
    }

    event MinterTransferred(address indexed previousMinter, address indexed newMinter);

    constructor () internal {
        _minterAdmin = msg.sender;
        _minters[msg.sender] = true;
    }

    function minteradmin() public view returns (address) {
        return _minterAdmin;
    }

    function addToMinters(address account) public onlyMinterAdmin {
        _minters[account] = true;
    }

    function removeFromMinters(address account) public onlyMinterAdmin {
        _minters[account] = false;
    }

    function transferMinterAdmin(address newMinter) public onlyMinterAdmin {
        pendingMinterAdmin = newMinter;
    }

    function claimMinterAdmin() public onlyPendingMinterAdmin {
        emit MinterTransferred(_minterAdmin, pendingMinterAdmin);
        _minterAdmin = pendingMinterAdmin;
        pendingMinterAdmin = address(0);
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.6.0;
contract ERC20 is Context, IERC20, AccountFrozenBalances, Ownable, Mintable {
	using SafeMath for uint256;
	using Address for address;

	mapping (address => uint256) private _balances;

	mapping (address => mapping (address => uint256)) private _allowances;

	uint256 private _totalSupply;
	uint256 private _maxSupply;
	
	string private _name;
	string private _symbol;
	uint8 private _decimals;

	/**
	 * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
	 * a default value of 18.
	 *
	 * To select a different value for {decimals}, use {_setupDecimals}.
	 *
	 * All three of these values are immutable: they can only be set once during
	 * construction.
	 */

	constructor (string memory name, string memory symbol, uint256 max, uint total) public {
		_name = name;
		_symbol = symbol;
		_decimals = 9;
		_maxSupply = max;
		_totalSupply = total;
		_balances[address(msg.sender)] = total;
	}

	function name() public view returns (string memory) {
		return _name;
	}

	function symbol() public view returns (string memory) {
		return _symbol;
	}

	function decimals() public view returns (uint8) {
		return _decimals;
	}

	function totalSupply() public view override returns (uint256) {
		return _totalSupply;
	}
	
	function maxSupply() public view returns (uint256) {
		return _maxSupply;
	}

	function availableBalance(address account) public view returns (uint256) {
		return _balances[account];
	}

	function balanceOf(address account) public view override returns (uint256) {
		return _balances[account].add(_frozen_balanceOf(account));
	}

	function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) public view virtual override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public virtual override returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
		return true;
	}

	function _transfer(address sender, address recipient, uint256 amount) internal virtual {
		require(sender != address(0), "ERC20: transfer from the zero address");
		require(recipient != address(0), "ERC20: transfer to the zero address");
		_beforeTokenTransfer(sender, amount);
		_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
		_balances[recipient] = _balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
	}

	function _mint(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: mint to the zero address");

		// _beforeTokenTransfer(address(0), amount);

		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}

	function _burn(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: burn from the zero address");

		_beforeTokenTransfer(account,  amount);

		_balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
	}

	function _approve(address owner, address spender, uint256 amount) internal virtual {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _setupDecimals(uint8 decimals_) internal {
		_decimals = decimals_;
	}

	function _beforeTokenTransfer(address from, uint256 amount) internal virtual {
		require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");
	}
	
	
	function _mintfrozen(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint frozen to the zero address");
        require(account != address(this), "ERC20: mint frozen to the contract address");
        require(amount > 0, "ERC20: mint frozen amount should be > 0");
        require(_totalSupply.add(amount) <= _maxSupply, "ERC20Capped: max supply exceeded");

        _totalSupply = _totalSupply.add(amount);

        emit Transfer(address(this), account, amount);

        _frozen_add(account, amount);

        emit MintFrozen(account, amount);
    }
    
    function _melt(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: melt from the zero address");
        require(amount > 0, "ERC20: melt from the address: value should be > 0");
        require(_frozen_balanceOf(account) >= amount, "ERC20: melt from the address: balance < amount");

        _frozen_sub(account, amount);
        emit MeltFrozen(account, amount);
        
        _balances[account] = _balances[account].add(amount);
        // emit Transfer(address(this), account, amount);
    }
    
    function _burnFrozen(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: frozen burn from the zero address");

        _totalSupply = _totalSupply.sub(amount);
        _frozen_sub(account, amount);

        emit Transfer(account, address(this), amount);
    }
	
    
    event Freeze(address indexed from, uint256 amount);
    event MeltFrozen(address indexed from, uint256 amount);
    event MintFrozen(address indexed to, uint256 amount);
    event FrozenTransfer(address indexed from, address indexed to, uint256 value);
	
}

pragma solidity 0.6.12;

// Token with Governance.
contract World_Step is ERC20("World Step", "WSP", 10000*10**9*10**6, 1*10**9*10**6) {
	
    address payable private _developmentAddress = payable(address(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2));
    address payable private _marketingAddress = payable(address(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db));
    address payable private _rewardPool = payable(address(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB));
	address payable private _liquidityPool = payable(address(0x617F2E2fD72FD9D5503197092aC168c91465E7f2));

	uint256 public transferFeeRate;
	uint256 public transferFeeSellRWP;
	uint256 public transferFeeBuyLP;
	uint256 public transferFeeBuyMKT;
	uint256 public transferFeeBuyDEV;
	uint256 public transferFeeBuyRWP;

	
    mapping(address => bool) private _transactionFee;
    mapping (address => bool) private _isExcludedFromFee;


	/**
	 * @dev See {ERC20-_beforeTokenTransfer}.
	 */

	function _beforeTokenTransfer(address from,  uint256 amount) internal virtual override {
		super._beforeTokenTransfer(from,  amount);
		
	    if (from == address(0)) { // When minting tokens
			require(totalSupply().add(amount) <= maxSupply(), "ERC20Capped: max supply exceeded");
		}

	}

	function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
	    if (transferFeeRate > 0 && _transactionFee[recipient] == true && recipient != address(0) && _developmentAddress != address(0)) {
			uint256 _feeamount = amount.mul(transferFeeRate).div(100);
			super._transfer(sender, _developmentAddress, _feeamount); // TransferFee
			amount = amount.sub(_feeamount);
		}

		super._transfer(sender, recipient, amount);
	}

	function _transferSell(address sender, address recipient, uint256 amount) internal virtual{
	    if (transferFeeSellRWP > 0 && recipient != address(0) && _rewardPool != address(0)) {
			_beforeTokenTransfer(sender,amount);
			uint256 _feeamount = amount.mul(transferFeeSellRWP).div(100);
			super._transfer(sender, _rewardPool, _feeamount); // TransferFee
			amount = amount.sub(_feeamount);
		}
		super._transfer(sender, recipient, amount);
	}

	function _transferBuy(uint256 amount) internal virtual {
			uint256 taxAmount = 0;
	    if (transferFeeBuyLP > 0 && address(msg.sender) != address(0) && _liquidityPool != address(0)) {
			uint256 _feeamountLP = amount.mul(transferFeeBuyLP).div(100);
			// super._transfer(sender, _liquidityPool, _feeamountLP); // TransferFee
			_mint(_liquidityPool,_feeamountLP);
			taxAmount = taxAmount.add(_feeamountLP);
			emit Transfer(address(0), _liquidityPool, _feeamountLP);
		}
		 if (transferFeeBuyDEV > 0 && address(msg.sender) != address(0) && _developmentAddress != address(0)) {
			uint256 _feeamountDEV = amount.mul(transferFeeBuyDEV).div(100);
			// super._transfer(sender, _developmentAddress, _feeamountDEV); // TransferFee
			_mint(_developmentAddress,_feeamountDEV);
			taxAmount = taxAmount.add(_feeamountDEV);
			emit Transfer(address(0), _developmentAddress, _feeamountDEV);

		}
		 if (transferFeeBuyMKT > 0 && address(msg.sender) != address(0) && _marketingAddress != address(0)) {
			uint256 _feeamountMKT = amount.mul(transferFeeBuyMKT).div(100);
			// super._transfer(sender, _marketingAddress, _feeamountMKT); // TransferFee
			_mint(_marketingAddress,_feeamountMKT);
			taxAmount = taxAmount.add(_feeamountMKT);
			emit Transfer(address(0), _marketingAddress, _feeamountMKT);
		}
		 if (transferFeeBuyRWP > 0 && address(msg.sender) != address(0) && _rewardPool != address(0)) {
			uint256 _feeamountRWP = amount.mul(transferFeeBuyRWP).div(100);
			// super._transfer(sender, _rewardPool, _feeamountRWP); // TransferFee
			_mint(_rewardPool,_feeamountRWP);
			taxAmount = taxAmount.add(_feeamountRWP);
			emit Transfer(address(0), _rewardPool, _feeamountRWP);

		}
		amount = amount.sub(taxAmount);
		// super._transfer(sender, recipient, amount);
		_mint(msg.sender,amount);
	}
	function BuyTest(uint256 amount) public virtual { 
		_transferBuy(amount);
	}
	function SellTest(address recipient, uint256 amount) public virtual { 
		_approve(msg.sender,recipient,amount);
		_transferSell(msg.sender,recipient,amount);
	}
	/// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
	function mint(address _to, uint256 _amount) public onlyOwner {
		_mint(_to, _amount);
	}

	function burn(uint256 amount) public virtual returns (bool) {
		_burn(_msgSender(), amount);
		return true;
	}

	function burnFrom(address account, uint256 amount) public virtual returns (bool) {
		uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

		_approve(account, _msgSender(), decreasedAllowance);
		_burn(account, amount);
		return true;
	}
	
	function mintFrozenTokens(address account, uint256 amount) public onlyMinter returns (bool) {
        _mintfrozen(account, amount);
        return true;
    }
	
	function transferFrozenToken(address from, address to, uint256 amount) public onlyMinter returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _frozen_sub(from, amount);
        _frozen_add(to, amount);

        emit FrozenTransfer(from, to, amount);
        emit Transfer(from, to, amount);

        return true;
    }
    
    function meltTokens(address account, uint256 amount) public onlyMinter returns (bool) {
        _melt(account, amount);
        return true;
    }
    
    function destroyFrozen(address account, uint256 amount) public onlyMinter {
        _burnFrozen(account, amount);
    }
    
    function addTransferFeeAddress(address _transferFeeAddress) public onlyOwner {
		_transactionFee[_transferFeeAddress] = true;
	}

	function removeTransferBurnAddress(address _transferFeeAddress) public onlyOwner {
		delete _transactionFee[_transferFeeAddress];
	}

    // function setFeeAddr(address _feeaddr) public onlyOwner {
	// 	feeaddr = _feeaddr;
    // }
    
    // function setTransferFeeRateBuy(uint256 _rate) public onlyOwner {
	// 	transferFeeRateBuy = _rate;
    // }
	//   function setTransferFeeRateSeel(uint256 _rate) public onlyOwner {
	// 	transferFeeRateSell = _rate;
    // }

	// function swapTokensForEth(uint256 tokenAmount) private {
    //     address[] memory path = new address[](2);
    //     path[0] = address(this);
    //     path[1] = uniswapV2Router.WETH();
    //     _approve(address(this), address(uniswapV2Router), tokenAmount);
    //     uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    //         tokenAmount,
    //         0,
    //         path,
    //         address(this),
    //         block.timestamp
    //     );
    // }

	// function _actionBuy(address buyer, uint tokenAmount) private { 
	// 	uint256 feeToMkt = tokenAmount.div(100);
	// 	uint256 feeToDev = tokenAmount.div(100);
	// 	uint256 feeToLP = tokenAmount.div(100);
	// 	uint256 feeToPR = tokenAmount.div(100);
	// 	uint256 tokenToEth = feeToLP.div(2);
	// 	_mint(_marketingAddress,feeToMkt);
	// 	_mint(_developmentAddress, feeToDev);
	// 	_mint(_rewardPool, feeToPR);
	// 	swapTokensForEth(tokenToEth);
	// }

	constructor() public {
		transferFeeRate = 0;
		transferFeeBuyLP = 1;
		transferFeeBuyDEV = 1;
		transferFeeBuyMKT = 1;
		transferFeeBuyRWP = 1;
		transferFeeSellRWP =1;
		//  IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3));
        // uniswapV2Router = _uniswapV2Router;
        // uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        //     .createPair(address(this), _uniswapV2Router.WETH() );
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_developmentAddress] = true;
        _isExcludedFromFee[_marketingAddress] = true;
	}
}


pragma solidity ^0.6.12;

contract Token_PreSale is Ownable {
    using SafeMath for uint256;
	using Address for address;

	IERC20 public _BUSD;
    World_Step public _tokenPresale;
	uint256 public _maxTokenSale;
	uint256 public _saledToken;
	bool public _saleStatus;
	uint256 public _tokenPrice;  // token pre-sale price in BNB
	uint256 public _endSaleBlock ;
	uint[10] public _openBlockArr;
    mapping(address => uint256) public buyedToken;
	mapping(address => uint256) public buyedBNB;
	mapping(address => uint256) public claimedPercent;
    
    constructor(address _token) public {
		_BUSD = IERC20(address(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee));
		_tokenPresale = World_Step(_token) ;
		_maxTokenSale = 2*10**4*10**18;
		_saledToken = 0;
		_saleStatus = true;
		_tokenPrice = 38 * 10 ** 12;
		_endSaleBlock = block.timestamp.add(2*60*60);
		_openBlockArr[0] = _endSaleBlock.add(15*60);
		_openBlockArr[1] = _endSaleBlock.add(30*60);
		_openBlockArr[2] = _endSaleBlock.add(45*60);
		_openBlockArr[3] = _endSaleBlock.add(60*60);
		_openBlockArr[4] = _endSaleBlock.add(75*60);
		_openBlockArr[5] = _endSaleBlock.add(90*60);
		_openBlockArr[6] = _endSaleBlock.add(105*60);
		_openBlockArr[7] = _endSaleBlock.add(120*60);
		_openBlockArr[8] = _endSaleBlock.add(135*60);
	}
	
	function viewAllow() public view returns(uint256) { 
		return _BUSD.allowance(msg.sender,address(this));
	}

	function viewBalance() public view returns(uint256) { 
		return _BUSD.balanceOf(msg.sender);
	}

	function buyByBUSD(address payable ref_Address,uint256 _amount) public payable { 
		uint256 totalToken = _amount.div(_tokenPrice);
		require(_endSaleBlock > block.timestamp , "Pre-sale ended .");
		require( _saledToken.add(totalToken * 10 ** 18) < _maxTokenSale , "Token soled out .");
		require(buyedBNB[msg.sender] < 20000 * 10 ** 18 , "Limit BUSD buyed .");

		address payable owner = payable(this.owner());
		_BUSD.transferFrom(msg.sender, owner, _amount);
		_tokenPresale.mintFrozenTokens(address(msg.sender), totalToken * 10 ** 18); 
		_tokenPresale.meltTokens(address(msg.sender), (totalToken * 10 ** 18).mul(3).div(100));

		if(ref_Address != address(0) && buyedToken[ref_Address] > 0){
			_tokenPresale.mintFrozenTokens(address(ref_Address), (totalToken * 10 ** 18).mul(5).div(100) );
			_tokenPresale.meltTokens(address(ref_Address), ((totalToken * 10 ** 18).mul(5).div(100)).mul(3).div(100));
		}
		_saledToken = _saledToken.add(totalToken * 10 ** 18);
		buyedToken[msg.sender] = buyedToken[msg.sender].add(totalToken * 10 ** 18);
		buyedBNB[msg.sender] = buyedBNB[msg.sender].add(_amount);
		buyedToken[ref_Address] = buyedToken[ref_Address].add((totalToken * 10 ** 18).mul(5).div(100));
		claimedPercent[msg.sender] = 3;
		emit Buy_PreSale(ref_Address, totalToken);
	}

	// function buy_PreSale(address payable ref_Address) public payable {
	// 	require(_endSaleBlock > block.timestamp , "Pre-sale ended .");
	// 	require(_saledToken < _maxTokenSale , "Token soled out .");
	// 	require(buyedBNB[msg.sender] < 20 * 10 ** 18 , "Limit BNB buyed .");
		
		
	// 	uint256 totalToken = msg.value.div(_tokenPrice);
	// 	_tokenPresale.mintFrozenTokens(address(msg.sender), totalToken * 10 ** 18 );
	// 	_tokenPresale.meltTokens(address(msg.sender), (totalToken * 10 ** 18).mul(10).div(100) );

	// 	address payable owner = payable(this.owner());
	// 	if(ref_Address != address(0)){
	// 		_tokenPresale.mintFrozenTokens(address(ref_Address), (totalToken * 10 ** 18).mul(5).div(100) );
	// 		_tokenPresale.meltTokens(address(ref_Address), (totalToken * 10 ** 18).mul(5).mul(10).div(100) );
	// 		ref_Address.transfer(msg.value.mul(5).div(100));
	// 		owner.transfer(msg.value.mul(95).div(100));
	// 	}else{
	// 		owner.transfer(msg.value);
	// 	}
	// 	_saledToken = _saledToken.add(totalToken * 10 ** 18);
	// 	buyedToken[msg.sender] = buyedToken[msg.sender].add(totalToken * 10 ** 18);
	// 	buyedBNB[msg.sender] = buyedBNB[msg.sender].add(msg.value);
	// 	claimedPercent[msg.sender] = 10;
	// 	emit Buy_PreSale(ref_Address, totalToken);
	// }    

	function checkTimeUnlockPercent () public view returns (uint256){
		uint256 checkNumber = block.timestamp;
		if(checkNumber < _openBlockArr[0]){
			return 3;
		}else if (_openBlockArr[0] <= checkNumber && checkNumber < _openBlockArr[1]){
			return 10;
		}else if (_openBlockArr[1] <= checkNumber && checkNumber < _openBlockArr[2]){
			return 25;
		}else if (_openBlockArr[2] <= checkNumber && checkNumber < _openBlockArr[3]){
			return 40;
		}else if (_openBlockArr[3] <= checkNumber && checkNumber < _openBlockArr[4]){
			return 55;
		}else if (_openBlockArr[4] <= checkNumber && checkNumber < _openBlockArr[5]){
			return 70;
		}else if (_openBlockArr[5] <= checkNumber && checkNumber < _openBlockArr[6]){
			return 85;
		}else if (_openBlockArr[6] <= checkNumber ){
			return 100;
		}
		
	}

	function unlockToken() public returns (bool) {
		uint256 checkPercent = checkTimeUnlockPercent() ;
		require(claimedPercent[msg.sender] < 100, "No locked token");
		require(checkPercent > claimedPercent[msg.sender], "unlock maximum this time");

		uint256 tokenUnlock = buyedToken[msg.sender] * (checkPercent - claimedPercent[msg.sender]) / 100;
		_tokenPresale.meltTokens(address(msg.sender), tokenUnlock );
		claimedPercent[msg.sender] = claimedPercent[msg.sender].add( (checkPercent - claimedPercent[msg.sender]) );

		emit Unlock_Token(msg.sender, tokenUnlock);
		return true;
	}

	function set_Price(uint256 tokenPrice) public onlyOwner {
		_tokenPrice = tokenPrice;
	}

	function set_SaleStatus(bool saleStatus) public onlyOwner {
		_saleStatus = saleStatus;
	}
 
    
    event Buy_PreSale(address indexed user, uint256 amount);
	event Unlock_Token(address indexed user, uint256 amount);

}