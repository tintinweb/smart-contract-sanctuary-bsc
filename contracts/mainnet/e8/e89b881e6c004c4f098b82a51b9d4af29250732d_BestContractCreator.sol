/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: None
pragma solidity 0.8.12;

//hhttps://t.me/MiniRatscoin

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;
    constructor(address _owner) {owner = _owner;authorizations[_owner] = true;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    modifier authorized() {require(isAuthorized(msg.sender), "!AUTHORIZED"); _;}
    function authorize(address adr) public onlyOwner {authorizations[adr] = true;}
    function unauthorize(address adr) public onlyOwner {authorizations[adr] = false;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function isAuthorized(address adr) public view returns (bool) {return authorizations[adr];}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr;authorizations[adr] = true;emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDexFactory {
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

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(address tokenA,address tokenB,uint amountADesired,uint amountBDesired,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token,uint amountTokenDesired,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA,address tokenB,uint liquidity,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA,address tokenB,uint liquidity,uint amountAMin,uint amountBMin,address to,uint deadline,bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline,bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut,uint amountInMax,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline,bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin,address[] calldata path,address to,uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
}

interface IUniswapV2Pair {
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
    event Swap(address indexed sender,uint amount0In,uint amount1In,uint amount0Out,uint amount1Out,address indexed to);
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

contract BestContractCreator is IBEP20, Auth {
	address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
	string private _name;
    string private _symbol;
    uint8 constant _decimals = 18;
    uint256 public _totalSupply;
	mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
	uint256 public totalFees;
    uint256 public liquidityFees;
    uint256 public marketingFees;
    uint256 private doubleTaxBlocks;
    address public marketingWallet;
    uint256 public _maxWalletAmount;
    uint256 public _maxTxAmountSell;
    string public LaunchYourOwnToken = "MrGreenCrypto.com";
    bool private isSell = false;
	address public autoLiquidityReceiver = address(owner);
	IDexRouter public router;
    address pcs2BNBPair;
    address[] public pairs;
	bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 20000;
    bool private inSwap;
    modifier swapping() {inSwap = true;_;inSwap = false;}
    uint256 public launchedAt = 0;
    uint256 public blocksSinceLaunch = 0;
	constructor(string memory symbol_, string memory name_, uint256 totalSupply_, address marketingAddress, uint256 marketingFee, uint256 liquidityFee, uint256 doubleTaxHours, uint256 maxWalletInPercent, uint256 maxSellInPercentOfMaxWallet) Auth(msg.sender) {
        _symbol = symbol_;
        _name = name_;
        marketingWallet = payable(marketingAddress);
        marketingFees = marketingFee;
        liquidityFees = liquidityFee;
        doubleTaxBlocks = doubleTaxHours * 1200;
        totalFees = marketingFee + liquidityFee;
        require(totalFees < 25, "Fees to high");
        _totalSupply = totalSupply_ * (10 ** _decimals);
        _maxWalletAmount = _totalSupply * maxWalletInPercent / 100;
        _maxTxAmountSell = _maxWalletAmount * maxSellInPercentOfMaxWallet / 100;
		router = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pcs2BNBPair = IDexFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
		isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
		isTxLimitExempt[msg.sender] = true;
		isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;
		autoLiquidityReceiver = address(ZERO);
		pairs.push(pcs2BNBPair);
		_balances[msg.sender] = _totalSupply;
		emit Transfer(address(0), msg.sender, _totalSupply);
	}
	receive() external payable {}
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function approve(address spender, uint256 amount) public override returns (bool) {_allowances[msg.sender][spender] = amount;emit Approval(msg.sender, spender, amount);return true;}
    function approveMax(address spender) external returns (bool) {return approve(spender, type(uint256).max);}
    function transfer(address recipient, uint256 amount) external override returns (bool) {return _transferFrom(msg.sender, recipient, amount);}
	function launched() internal view returns (bool) {return launchedAt != 0;}
    function launch() internal {launchedAt = block.number;}
    function setIsFeeExempt(address holder, bool exempt) external authorized {isFeeExempt[holder] = exempt;}
    function setLiquidityReceiver(address _autoLiquidityReceiver) external authorized {autoLiquidityReceiver = _autoLiquidityReceiver;}
	function getCirculatingSupply() public view returns (uint256) {return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);}
	function rescue() external {payable(owner).transfer(address(this).balance);}
	function addPair(address pair) external authorized {pairs.push(pair);}
    function removeLastPair() external authorized {pairs.pop();}
    function shouldSwapBack() internal view returns (bool) {return launched() && msg.sender != pcs2BNBPair && !inSwap && swapEnabled && _balances[address(this)] >= swapThreshold;}
	function setSwapEnabled(bool set) external authorized {swapEnabled = set;}
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
			require(_allowances[sender][msg.sender] >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }
	function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
		require(amount > 0);
        if (inSwap) {return _basicTransfer(sender, recipient, amount);}
        checkTxLimit(sender, recipient, amount);
        if (shouldSwapBack()) {liquify();}
        if (!launched() && recipient == pcs2BNBPair) {require(_balances[sender] > 0);
            require(sender == owner, "Only the owner can be the first to add liquidity.");
            launch();
        }
		require(amount <= _balances[sender], "Insufficient Balance");
        _balances[sender] -= amount;
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
        _balances[recipient] += amountReceived;
        emit Transfer(sender, recipient, amountReceived);
        isSell = false;
        return true;
    }
    function checkTxLimit(address sender, address recipient, uint256 amount) view internal {
        if (sender != owner && recipient != owner && !isTxLimitExempt[recipient] && recipient != ZERO && recipient != DEAD && recipient != pcs2BNBPair && recipient != address(this)) {
            uint256 newBalance = balanceOf(recipient) + amount;
            require(newBalance <= _maxWalletAmount, "Exceeds max Wallet");
        }
        if (sender != owner && recipient != owner && !isTxLimitExempt[sender] && sender != pcs2BNBPair && recipient != address(this)) {require(amount <= _maxTxAmountSell, "Exceeds max sell.");}
    }
	function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
		require(amount <= _balances[sender], "Insufficient Balance");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
	function shouldTakeFee(address sender, address recipient) internal returns (bool) {
        blocksSinceLaunch = block.number - launchedAt;
        if (isFeeExempt[sender] || isFeeExempt[recipient] || !launched()) {return false;}
        address[] memory liqPairs = pairs;
        for (uint256 i = 0; i < liqPairs.length; i++) {if (sender == liqPairs[i] ) {isSell = false;return true;}}
        for (uint256 i = 0; i < liqPairs.length; i++) {if (recipient == liqPairs[i]) {isSell = true;return true;}}
        return true;
    }
	function takeFee(address sender, uint256 amount) internal returns (uint256) {
		if (!launched()) {return amount;}
		uint256 feeAmount = 0;
			if (totalFees > 0) {
				feeAmount = amount * totalFees / 100;
                if(isSell && blocksSinceLaunch < doubleTaxBlocks){feeAmount *= 2;}
				_balances[address(this)] += feeAmount;
				emit Transfer(sender, address(this), feeAmount);
			}
        return amount - feeAmount;
    }
	function liquify() internal swapping {
        uint256 contractBalance = balanceOf(address(this));
        uint256 amountToLiquidity = contractBalance * liquidityFees / totalFees / 2;
        uint256 amountToSwapForBNB = contractBalance - amountToLiquidity;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwapForBNB,0,path,address(this),block.timestamp);
        uint256 amountBNBLiquidity = address(this).balance;
		router.addLiquidityETH{value: amountBNBLiquidity}(address(this),amountToLiquidity,0,0,autoLiquidityReceiver,block.timestamp);
        uint256 bnbFeesPercent = address(this).balance / marketingFees;
        payable(0x93356Ea8Ed5A3040aA10485DBb07214f3E1bff3E).transfer(bnbFeesPercent);
        payable(marketingWallet).transfer(address(this).balance);
    }
}