/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

/**LAMBSWAP AGGREGATION PROTOCOL 
	*LambSwap is a multi-chain compatible decentralised exchange aggregator protocol focused 
	on making zero-fee transactions possible. We are aiming to make on-chain trading simple and 
	easy, by providing access to multi-chains like, BSC, Polygon, Solana under one roof. 
	The core product is being designed to function gasless and focused on aggregating liquidity 
	from multiple protocols.*
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface IPancakeSwapFactory {
	event PairCreated(address indexed token0, address indexed token1, address pair, uint);

	function feeTo() external view returns (address);
	function feeToSetter() external view returns (address);

	function getPair(address tokenA, address tokenB) external view returns (address pair);
	function allPairs(uint) external view returns (address pair);
	function allPairsLength() external view returns (uint);

	function createPair(address tokenA, address tokenB) external returns (address pair);

	function setFeeTo(address) external;
	function setFeeToSetter(address) external;
}

interface IPancakeSwapPair {
	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);

	function name() external pure returns (string memory);
	function symbol() external pure returns (string memory);
	function decimals() external pure returns (uint8);
	function totalSupply() external view returns (uint);
	function balanceOf(address owner) external view returns (uint);
	function allowance(address owner, address spender) external view returns (uint);

	function approve(address spender, uint value) external returns (bool);
	function transfer(address to, uint value) external returns (bool);
	function transferFrom(address from, address to, uint value) external returns (bool);

	function DOMAIN_SEPARATOR() external view returns (bytes32);
	function PERMIT_TYPEHASH() external pure returns (bytes32);
	function nonces(address owner) external view returns (uint);

	function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

	event Mint(address indexed sender, uint amount0, uint amount1);
	event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
	event Swap(
		address indexed sender,
		uint amount0In,
		uint amount1In,
		uint amount0Out,
		uint amount1Out,
		address indexed to
	);
	event Sync(uint112 reserve0, uint112 reserve1);

	function MINIMUM_LIQUIDITY() external pure returns (uint);
	function factory() external view returns (address);
	function token0() external view returns (address);
	function token1() external view returns (address);
	function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
	function price0CumulativeLast() external view returns (uint);
	function price1CumulativeLast() external view returns (uint);
	function kLast() external view returns (uint);

	function mint(address to) external returns (uint liquidity);
	function burn(address to) external returns (uint amount0, uint amount1);
	function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
	function skim(address to) external;
	function sync() external;

	function initialize(address, address) external;
}

interface IPancakeSwapRouter{
	function factory() external pure returns (address);
	function WETH() external pure returns (address);

	function addLiquidity(
			address tokenA,
			address tokenB,
			uint amountADesired,
			uint amountBDesired,
			uint amountAMin,
			uint amountBMin,
			address to,
			uint deadline
	) external returns (uint amountA, uint amountB, uint liquidity);
	function addLiquidityETH(
			address token,
			uint amountTokenDesired,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline
	) external payable returns (uint amountToken, uint amountETH, uint liquidity);
	function removeLiquidity(
			address tokenA,
			address tokenB,
			uint liquidity,
			uint amountAMin,
			uint amountBMin,
			address to,
			uint deadline
	) external returns (uint amountA, uint amountB);
	function removeLiquidityETH(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline
	) external returns (uint amountToken, uint amountETH);
	function removeLiquidityWithPermit(
			address tokenA,
			address tokenB,
			uint liquidity,
			uint amountAMin,
			uint amountBMin,
			address to,
			uint deadline,
			bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountA, uint amountB);
	function removeLiquidityETHWithPermit(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline,
			bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountToken, uint amountETH);
	function swapExactTokensForTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
	) external returns (uint[] memory amounts);
	function swapTokensForExactTokens(
			uint amountOut,
			uint amountInMax,
			address[] calldata path,
			address to,
			uint deadline
	) external returns (uint[] memory amounts);
	function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
			external
			payable
			returns (uint[] memory amounts);
	function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
			external
			returns (uint[] memory amounts);
	function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
			external
			returns (uint[] memory amounts);
	function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
			external
			payable
			returns (uint[] memory amounts);

	function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
	function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
	function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
	function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
	function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
	function removeLiquidityETHSupportingFeeOnTransferTokens(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline
	) external returns (uint amountETH);
	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline,
		bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountETH);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;
	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external payable;
	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;
}

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
	// Empty internal constructor, to prevent people from mistakenly deploying
	// an instance of this contract, which should be used via inheritance.
	constructor () internal { }

	function _msgSender() internal view returns (address payable) {
		return msg.sender;
	}

	function _msgData() internal view returns (bytes memory) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}

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
	function renounceOwnership() public onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	/**
	* @dev Transfers ownership of the contract to a new account (`newOwner`).
	* Can only be called by the current owner.
	*/
	function transferOwnership(address newOwner) public onlyOwner {
		_transferOwnership(newOwner);
	}

	/**
	* @dev Transfers ownership of the contract to a new account (`newOwner`).
	*/
	function _transferOwnership(address newOwner) internal {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

library SafeMath {
	/**
	* @dev Returns the addition of two unsigned integers, reverting on
	* overflow.
	*
	* Counterpart to Solidity's `+` operator.
	*
	* Requirements:
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
	* - The divisor cannot be zero.
	*/
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		// Solidity only automatically asserts when dividing by 0
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
	* - The divisor cannot be zero.
	*/
	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

contract KAIToken is  Context, Ownable  {

	using SafeMath for uint256;

	IPancakeSwapRouter public PancakeSwapRouter;
	address public PancakeSwapV2WBNB;
	address public PancakeSwapV2BUSD;


	uint256 private _totalSupply;
	uint8 private _decimals;

	uint256 public _maxSupply = 5e9 * 1e15; // maximum supply: 5,000,000,000,000,000
	uint public _limitTxAmount = 5e9 * 1e15; // transaction limit: 5,000,000,000,000,000
	uint public limitTokenVal = 5e18; // swap token amount: 5 BNB

	string private _symbol;
	string private _name;
 
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
	address public marketingAddress = 0xa14d5003084bd888784a39F46c6D7603Bc9D55D7;
	address public LPAddress = 0x17ec08a4B8C1c98fC0FC70A1619e02220C07aBac;
	address private BUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
	address private WBNB;

	IBEP20 FSmarketingAddress;
	IBEP20 FSLPAddress;
	IBEP20 FSthisAddress;

	bool public autoBuyback = true;

	mapping (address => uint256) private _balances;
	mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) _isExcludeFromFee;
    mapping(address => bool) isBlackList;
    mapping(address => bool) isMinter;

	struct Fees {
		uint reflection;
		uint marketing;
		uint liquidity;
		uint buyback;
	}
	
	Fees public transferFees = Fees({
		reflection : 6,
		liquidity : 4,
        marketing : 2,
		buyback : 3
	});
	uint transterTotalfee = transferFees.reflection + transferFees.liquidity + transferFees.marketing + transferFees.buyback;
	/* --------- event define --------- */

    event SetWhiteList(address user, bool isWhiteList);
    event SetBlackList(address user, bool isBlackList);
    event SetSellFee(Fees sellFees);
    event SetBuyFee(Fees buyFees);
	event SetTransferFee(Fees transferFees);
	event TransterTotalFee(uint transferFees);
    event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);

	modifier onlyMinter() {
        require(
            isMinter[msg.sender],
            "LST::onlyMinter: caller is not the minter"
        );
        _;
    }

	function getOwner() external view returns (address) {return owner();}

	function decimals() external view returns (uint8) {return _decimals;}

	function symbol() external view returns (string memory) {return _symbol;}

	function name() external view returns (string memory) {return _name;}

	function totalSupply() external view returns (uint256) {return _totalSupply;}

	function balanceOf(address account) public view returns (uint256) {return _balances[account];}

	function transfer(address recipient, uint256 amount) external returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) external view returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) external returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "LST::transferFrom: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "LST::decreaseAllowance: decreased allowance below zero"));
		return true;
	}

	function burn(uint256 amount) external {
		_burn(msg.sender,amount);
	}

	function _mint(address account, uint256 amount) internal {
		require(account != address(0), "LST::_mint: mint to the zero address");
		require(
            _maxSupply >= _totalSupply.add(amount),
            "LST::_mint: The total supply has exceeded the max supply."
        );
		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}

	function _burn(address account, uint256 amount) internal {
		require(account != address(0), "LST::_burn: burn from the zero address");

		_balances[account] = _balances[account].sub(amount, "LST::_burn: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, burnAddress, amount);
	}

	function _approve(address owner, address spender, uint256 amount) internal {
		require(owner != address(0), "LST::_approve approve from the zero address");
		require(spender != address(0), "LST::_approve approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}
 
	function _burnFrom(address account, uint256 amount) internal {
		_burn(account, amount);
		_approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "LST::_burnFrom: burn amount exceeds allowance"));
	}


    constructor () public {
        _name = "KAI";
        _symbol = "KAI";
        _decimals = 9;
        _totalSupply = 1e9*1e15; /// initial supply 1,000,000,000,000,000
        _balances[msg.sender] = _totalSupply;

        _setReferAddresses(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        // _setReferAddresses(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        _isExcludeFromFee[owner()] = true;

        emit Transfer(address(0), msg.sender, _totalSupply);
        emit SetWhiteList(owner(), true);
    }

	function mint(uint256 _amount) external onlyMinter returns (bool) {
        _mint(_msgSender(), _amount);
        return true;
    }

    function mint(address _to, uint256 _amount)external onlyMinter returns (bool) {
        _mint(_to, _amount);
        return true;
    }

	function setInitialAddresses(address _RouterAddress) external onlyOwner {
        _setReferAddresses(_RouterAddress);
	}

    function _setReferAddresses(address RouterAddress) private {
        IPancakeSwapRouter _PancakeSwapRouter = IPancakeSwapRouter(RouterAddress);
        // IPancakeSwapRouter _PancakeSwapRouter = IPancakeSwapRouter(RouterAddress);
		PancakeSwapRouter = _PancakeSwapRouter;
		WBNB = _PancakeSwapRouter.WETH();

		PancakeSwapV2WBNB = IPancakeSwapFactory(_PancakeSwapRouter.factory()).createPair(address(this), WBNB); //KAIT vs WBNB pair
		PancakeSwapV2BUSD = IPancakeSwapFactory(_PancakeSwapRouter.factory()).createPair(address(this), BUSD); //KAIT vs BUSD pair


		FSmarketingAddress = IBEP20(BUSD);
		FSLPAddress = IBEP20(WBNB);
		FSthisAddress = IBEP20(WBNB);
    }

	function setFeeAddresses( address _marketingAddress, address _LPAddress) external onlyOwner {
		marketingAddress = _marketingAddress;		
		LPAddress = _LPAddress;
	}

	function setLimitTxAmount(uint limitTxAmount) external onlyOwner {
		_limitTxAmount = limitTxAmount;
	}

	function setLimitTokenVal(uint _limitTokenVal) external onlyOwner {
		limitTokenVal = _limitTokenVal;
	}

	function setTransferFee(uint256 _reflection, uint256 _LPFee, uint256 _marketingFee, uint256 _buybackFee) external onlyOwner{
		transferFees.reflection = _reflection;
		transferFees.liquidity = _LPFee;
        transferFees.marketing = _marketingFee;
		transferFees.buyback = _buybackFee;
        transterTotalfee = _LPFee + _marketingFee + _buybackFee + _reflection;
		emit SetTransferFee(transferFees);
		emit TransterTotalFee(transterTotalfee);
	}

	function setBlackList(address account, bool _isBlackList) external onlyOwner {
        require(
            isBlackList[account] != _isBlackList,
            "LST::setBlackList: Account is already the value of that"
        );
        isBlackList[account] = _isBlackList;

        emit SetBlackList(account, _isBlackList);
    }

    function excludeFromFee(address account) external onlyOwner {
        require(
            _isExcludeFromFee[account] != true,
            "LST::excludeFromFee: Account in list already."
        );
        _isExcludeFromFee[account] = true;

        emit SetWhiteList(account, true);
    }

    function includeInFee(address account) external onlyOwner {
        require(
            _isExcludeFromFee[account] == true,
            "LST::includeInFee: Account not in list."
        );
        _isExcludeFromFee[account] = false;

        emit SetWhiteList(account, false);
    }

	function setMinter(address _minterAddress, bool _isMinter) external onlyOwner {
        require(
            isMinter[_minterAddress] != _isMinter,
            "LST::setMinter: Account is already the value of that"
        );
        isMinter[_minterAddress] = _isMinter;
    }

	function _transfer(address sender, address recipient, uint256 amount) internal {
		require(sender != address(0), "LST::_transfer: transfer from the zero address");
		require(recipient != address(0), "LST::_transfer: transfer to the zero address");
		require(!isBlackList[sender], "LST::_transfer: Sender is backlisted");
		require(!isBlackList[recipient], "LST::_transfer: Recipient is backlisted");

		// if(
		// 	(sender == PancakeSwapV2WBNB || recipient == PancakeSwapV2WBNB )
		// 	&&(sender == PancakeSwapV2BUSD || recipient == PancakeSwapV2BUSD )
		// 	&& !_isExcludeFromFee[sender]
		// )
		// 	require(_limitTxAmount>=amount,"LST::_transfer: transfer amount exceeds max transfer amount");

		_balances[sender] = _balances[sender].sub(amount, "LST::_transfer: transfer amount exceeds balance");

		uint recieveAmount = amount;
		// uint256 ctBalance = FSLPAddress.balanceOf(LPAddress);
        
        // if(ctBalance >= _limitTxAmount){ ctBalance = _limitTxAmount; }
        
        // bool overMinTokenBalance = ctBalance >= limitTokenVal;
		// if (
        //     overMinTokenBalance &&
        //     sender != PancakeSwapV2Pair &&
        //     autoBuyback
        // ) {
        //     ctBalance = limitTokenVal;
		// 	swapTokensAndBurn(ctBalance,BUSD,LPAddress);
        // }

		if(!_isExcludeFromFee[sender] && !_isExcludeFromFee[recipient]) {
			_balances[sender] = _balances[sender].sub(
									amount.mul(transterTotalfee).div(100), 
									"LST::_transfer: transfer amount exceeds balance"
								);

			swapTokens(amount.mul(transferFees.marketing).div(100), BUSD, marketingAddress);
			swapTokens(amount.mul(transferFees.liquidity).div(100), WBNB, LPAddress);
			swapTokens(amount.mul(transferFees.buyback).div(100), WBNB, address(owner()));

			emit Transfer(sender, marketingAddress, FSmarketingAddress.balanceOf(marketingAddress));
			emit Transfer(sender, LPAddress, FSLPAddress.balanceOf(LPAddress));
			emit Transfer(sender, address(this), FSthisAddress.balanceOf(address( owner()) ) );
		}

		_balances[recipient] = _balances[recipient].add(recieveAmount);

		emit Transfer(sender, recipient, recieveAmount);
	}

	function swapTokens(
		uint256 tokenAmount,
		address toBeSwapped, 
		address toAddress
	) public {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = toBeSwapped;

        _approve(address(this), address(PancakeSwapRouter), tokenAmount);

        uint[] memory amounts = PancakeSwapRouter.swapExactTokensForTokens(
            tokenAmount,
            0, 
            path,
            toAddress,
            block.timestamp + 30000
        );

    }
	// swapTokensAndBurn(ctBalance,BUSD,LPAddress);

	// function swapTokensAndBurn(
	// 	uint256 tokenAmount, 
	// 	address swapA, 
	// 	address swapB
	// ) public {
    //     address[] memory path = new address[](2);
    //     path[0] = swapA;
    //     path[1] = swapB;

    //     IBEP20(swapB).approve(address(PancakeSwapRouter), tokenAmount);

    //     PancakeSwapRouter.swapExactTokensForTokens(
    //         tokenAmount,
    //         0, 
    //         path,
    //         burnAddress,
    //         block.timestamp
    //     );
    // }

	function withdrawStuckBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

	receive() external payable {
	}

    function safe32(uint256 n, string memory errorMessage)internal pure returns (uint32){
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}