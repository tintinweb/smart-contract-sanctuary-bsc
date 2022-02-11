/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.11;


interface IBEP20 {
	function totalSupply() external view returns(uint256);

	function decimals() external view returns(uint8);

	function symbol() external view returns(string memory);

	function name() external view returns(string memory);

	function getOwner() external view returns(address);

	function balanceOf(address account) external view returns(uint256);

	function transfer(address recipient, uint256 amount) external returns(bool);

	function allowance(address _owner, address spender) external view returns(uint256);

	function approve(address spender, uint256 amount) external returns(bool);

	function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeRouter01 {
	function factory() external pure returns(address);
	function WETH() external pure returns(address);

	function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns(uint amountA, uint amountB, uint liquidity);

	function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns(uint amountToken, uint amountETH, uint liquidity);

	function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns(uint amountA, uint amountB);

	function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns(uint amountToken, uint amountETH);

	function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns(uint amountA, uint amountB);

	function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns(uint amountToken, uint amountETH);

	function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns(uint[] memory amounts);

	function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns(uint[] memory amounts);

	function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns(uint[] memory amounts);

	function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns(uint[] memory amounts);

	function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns(uint[] memory amounts);

	function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns(uint[] memory amounts);


	function quote(uint amountA, uint reserveA, uint reserveB) external pure returns(uint amountB);

	function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns(uint amountOut);

	function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns(uint amountIn);

	function getAmountsOut(uint amountIn, address[] calldata path) external view returns(uint[] memory amounts);

	function getAmountsIn(uint amountOut, address[] calldata path) external view returns(uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
	function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns(uint amountETH);

	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns(uint amountETH);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;

	function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;

	function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

interface IPancakeFactory {
	event PairCreated(address indexed token0, address indexed token1, address pair, uint);

	function feeTo() external view returns(address);
	function feeToSetter() external view returns(address);

	function getPair(address tokenA, address tokenB) external view returns(address pair);
	function allPairs(uint) external view returns(address pair);
	function allPairsLength() external view returns(uint);

	function createPair(address tokenA, address tokenB) external returns(address pair);

	function setFeeTo(address) external;
	function setFeeToSetter(address) external;
}


abstract contract Context {
	function _msgSender() internal view virtual returns(address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns(bytes calldata) {
		return msg.data;
	}
}

abstract contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 
	constructor() {
		_transferOwnership(_msgSender());
	}


	function owner() public view virtual returns(address) {
		return _owner;
	}

	modifier onlyOwner() {
		require(owner() == _msgSender(), "Ownable: caller is not the owner");
		_;
	}


	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");

		_transferOwnership(newOwner);
	}

	function _transferOwnership(address newOwner) internal virtual {
		address oldOwner = _owner;

		_owner = newOwner;

		emit OwnershipTransferred(oldOwner, newOwner);
	}
}

abstract contract BEP20 is IBEP20, Ownable {
	mapping(address => uint256) private _balances;
	mapping(address => mapping (address => uint256)) private _allowances;

	uint256 private _totalSupply;

	string private _symbol;
	string private _name;


	constructor(string memory name_, string memory symbol_) {
		_name = name_;
		_symbol = symbol_;
	}


	function getOwner() public view virtual override returns(address) {
		return owner();
	}

	function name() public view virtual override returns(string memory) {
		return _name;
	}

	function symbol() public view virtual override returns(string memory) {
		return _symbol;
	}

	function decimals() public view virtual override returns(uint8) {
		return 18;
	}

	function totalSupply() public view virtual override returns(uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public view virtual override returns(uint256) {
		return _balances[account];
	}

	function transfer(address recipient, uint256 amount) public virtual override returns(bool) {
		_transfer(_msgSender(), recipient, amount);

		return true;
	}

	function allowance(address owner, address spender) public view virtual override returns(uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public virtual override returns(bool) {
		_approve(_msgSender(), spender, amount);

		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns(bool) {
		uint256 currentAllowance = _allowances[sender][_msgSender()];

		if (currentAllowance != type(uint256).max) {
			require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");

			unchecked {
				_approve(sender, _msgSender(), currentAllowance - amount);
			}
		}

		_transfer(sender, recipient, amount);

		return true;
	}

	function _transfer(address sender, address recipient, uint256 amount) internal virtual {
		require(sender != address(0), "BEP20: transfer from the zero address");
		require(recipient != address(0), "BEP20: transfer to the zero address");

		_beforeTokenTransfer(sender, recipient, amount);

		uint256 senderBalance = _balances[sender];
		require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");

		unchecked {
			_balances[sender] = senderBalance - amount;
		}

		_balances[recipient] += amount;

		emit Transfer(sender, recipient, amount);

		_afterTokenTransfer(sender, recipient, amount);
	}

	function _mint(address account, uint256 amount) internal virtual {
		require(account != address(0), "BEP20: mint to the zero address");

		_beforeTokenTransfer(address(0), account, amount);

		_totalSupply += amount;
		_balances[account] += amount;

		emit Transfer(address(0), account, amount);

		_afterTokenTransfer(address(0), account, amount);
	}

	function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");

        unchecked {
            _balances[account] = accountBalance - amount;
        }

        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
	}

	function _burnFrom(address account, uint256 amount) internal virtual {
		_burn(account, amount);

		uint256 currentAllowance = _allowances[account][_msgSender()];
		require(currentAllowance >= amount, "BEP20: burn amount exceeds allowance");

		unchecked {
			_approve(account, _msgSender(), currentAllowance - amount);
		}
	}

	function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
	}


	function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
	function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}


contract MetaDog is BEP20 {
	IPancakeRouter02 public pancakeRouter;

	bool private swapping;

	address public pancakePair;
	address public marketingWallet;

	uint256 public swapTokensAtAmount;
	uint256 public maxHoldingAmount;

	uint256 public marketingFee;
	uint256 public liquidityFee;
	uint256 public accMarketingFee;
	uint256 public accLiquidityFee;

	uint256 public BNB_liquidityFee;
	uint256 public MDOG_liquidityFee;

	mapping(address => bool) private _excludedFromFees;
	mapping(address => bool) private _excludedFromMaxHoldLimit;

	uint256 private constant PERCENTAGE_MULTIPLIER = 10000;


	event SetSwapTokensAtAmount(uint256 oldAmount, uint256 newAmount);
	event SetMaxHoldingAmount(uint256 oldPercent, uint256 newPercent);
	event SetFees(uint256 oldLiquidityFee, uint256 newLiquidityFee, uint256 oldMarketingFee, uint256 newMarketingFee);

	event StartSwapTokensForEth(uint256 tokensToBeSwapped);
	event FinishSwapTokensForEth(uint256 BNBswapped);

	event CalculatedBNBForEachRecipient(uint256 forLiquidity, uint256 forMarketing);
	event SwapAndSendTo(uint256 tokensSwapped, uint256 amount, string to);
	event ErrorInProcess(address msgSender);


	constructor(address _initMarketingWallet) BEP20("MetaDog", "MDOG") {
		marketingWallet = _initMarketingWallet;

		accLiquidityFee = 0;
		accMarketingFee = 0;

		swapTokensAtAmount = 150_000_000 * (10 ** decimals());

		BNB_liquidityFee = 0;
		MDOG_liquidityFee = 0;


		updatePancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

		excludeAddressFromAllLimits(owner(), true);
		excludeAddressFromAllLimits(address(this), true);
		excludeAddressFromAllLimits(marketingWallet, true);


		_mint(owner(), 100_000_000_000 * (10 ** decimals()));

		setMaxHoldingAmount( totalSupply() * 500 / PERCENTAGE_MULTIPLIER );
		setFees(500, 500);
	}


	function _transfer(address from, address to, uint256 amount) internal override {
		if (amount == 0) {
			super._transfer(from, to, 0);
			return;
		}

		require(from != address(0), "BEP20: transfer from the zero address");
		require(to != address(0), "BEP20: transfer to the zero address");


		bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;

		if (canSwap && !swapping && msg.sender != pancakePair) {
			swapping = true;

			swapAndAddLiquidity(accLiquidityFee + accMarketingFee);

			swapping = false;
		}


		bool takeFee = isExcludedFromFees(from) || isExcludedFromFees(to) ? false : !swapping;

		if (takeFee) {
			uint256 forLiquidity = amount * liquidityFee / PERCENTAGE_MULTIPLIER;
			uint256 forMarketing = amount * marketingFee / PERCENTAGE_MULTIPLIER;

			accLiquidityFee = accLiquidityFee + forLiquidity;
			accMarketingFee = accMarketingFee + forMarketing;

			uint256 fees = forLiquidity + forMarketing;

			amount -= fees;

			super._transfer(from, address(this), fees);
		}


		if (!_excludedFromMaxHoldLimit[to]) {
			require(balanceOf(to) + amount <= maxHoldingAmount, "MetaDog: surpassed holding limit");
		}


		super._transfer(from, to, amount);
	}

	function swapTokensForEth(uint256 amount) private {
		emit StartSwapTokensForEth(amount);


		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = pancakeRouter.WETH();

		_approve(address(this), address(pancakeRouter), amount);


		uint256 halfOfLiquidityFee = accLiquidityFee / 2;

		uint256[] memory amounts = pancakeRouter.getAmountsOut(halfOfLiquidityFee, path);

		MDOG_liquidityFee = amounts[0];
		BNB_liquidityFee = amounts[1];


		pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(amount - halfOfLiquidityFee, 0, path, address(this), block.timestamp);
		pancakeRouter.addLiquidityETH{ value: amounts[1] }(address(this), halfOfLiquidityFee, 0, 0, address(this), block.timestamp);


		emit FinishSwapTokensForEth(address(this).balance);
	}

	function swapAndAddLiquidity(uint256 tokens) private {
		swapTokensForEth(tokens);


		uint256 balance = address(this).balance;

		uint256 accTotal = accMarketingFee + accLiquidityFee;
		uint256 forMarketing = balance * accMarketingFee / accTotal;
		uint256 forLiquidity = balance * accLiquidityFee / accTotal;


		emit CalculatedBNBForEachRecipient(forLiquidity, forMarketing);


		(bool success, ) = payable(marketingWallet).call{ value: forMarketing }("");

		if (success) {
			emit SwapAndSendTo(accMarketingFee, forMarketing, "MARKETING");

			accMarketingFee = 0;
		}

		accLiquidityFee = 0;
	}


	function isExcludedFromFees(address _address) public view returns(bool) {
		return _excludedFromFees[_address];
	}

	function isExcludedFromMaxHoldLimit(address _address) public view returns(bool) {
		return _excludedFromMaxHoldLimit[_address];
	}


	function updatePancakeRouter(address newAddress) public onlyOwner {
		require(newAddress != address(0), "MetaDog: router cannot be the null address");
		require(newAddress != address(pancakeRouter), "MetaDog: cannot update to the same value");

		pancakeRouter = IPancakeRouter02(newAddress);
		pancakePair = IPancakeFactory(pancakeRouter.factory()).createPair(address(this), pancakeRouter.WETH());

		excludeAddressFromAllLimits(newAddress, true);
		_excludedFromMaxHoldLimit[pancakePair] = true;
	}

	function excludeAddressesFromAllLimits(address[] calldata addresses, bool[] calldata statuses) public onlyOwner {
		require(addresses.length == statuses.length, "MetaDog: invalid input parameters");

		for (uint256 i = 0; i < addresses.length; i++) {
			excludeAddressFromAllLimits(addresses[i], statuses[i]);
		}
	}

	function excludeAddressFromAllLimits(address _address, bool status) public onlyOwner {
		excludeFromFees(_address, status);
		excludeFromMaxHoldLimit(_address, status);
	}

	function excludeFromFees(address _address, bool status) public onlyOwner {
		_excludedFromFees[_address] = status;
	}

	function excludeFromMaxHoldLimit(address _address, bool status) public onlyOwner {
		_excludedFromMaxHoldLimit[_address] = status;
	}

	function setFees(uint256 newLiquidityFee, uint256 newMarketingFee) public onlyOwner {
		require(newLiquidityFee + newMarketingFee <= 10 * PERCENTAGE_MULTIPLIER / 100, "MetaDog: sum of fees must not exceed 10%");

		emit SetFees(liquidityFee, newLiquidityFee, marketingFee, newMarketingFee);

		liquidityFee = newLiquidityFee;
		marketingFee = newMarketingFee;
	}

	function setMaxHoldingAmount(uint256 amount) public onlyOwner {
		require(amount > 0, "MetaDog: value must be breater than 0");

		emit SetMaxHoldingAmount(maxHoldingAmount, amount);

		maxHoldingAmount = amount;
	}

	function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
		emit SetSwapTokensAtAmount(swapTokensAtAmount, amount);

		swapTokensAtAmount = amount;
	}

	function setMarketingAddress(address newAddress) external onlyOwner {
		require(newAddress != address(0), "MetaDog: marketing wallet cannot be the null address");

		marketingWallet = newAddress;
	}


	receive() external payable {}
}