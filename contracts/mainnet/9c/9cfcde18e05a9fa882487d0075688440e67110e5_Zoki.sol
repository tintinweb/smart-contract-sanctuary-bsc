/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT

pragma solidity = 0.8.17;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
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

interface IDexRouter {
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

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract Zoki is IBEP20, Auth {

	address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

	string constant _name = "Zombie Floki";
    string constant _symbol = "ZOKI";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100_000_000 ether;
    uint256 public _maxTxAmount = _totalSupply / 100;
	uint256 public _maxWalletAmount = _totalSupply / 100;

	mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => uint256) lastTx;

	// Fees. Some may be completely inactive at all times.
	uint256 liquidityFee = 0;
	uint256 ecosystemFee = 0;
	uint256 developerFee = 0;
    uint256 feeDenominator = 1000;
	uint256 liquidityFeeSell = 10;
	uint256 ecosystemFeeSell = 0;
	uint256 developerFeeSell = 20;
    uint256 feeDenominatorSell = 1000;
	bool public feeOnNonTrade = false;
    uint256 private launchBlock;

	address public autoLiquidityReceiver;
	address public ecosystemFeeReceiver;
	address public devFeeReceiver;

	IDexRouter public router;
    address public dexPair;
	mapping(address => bool) public pairs;

	bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 20000;
    bool inSwap;
    modifier swapping() {
		inSwap = true;
		_;
		inSwap = false;
	}

	event AutoLiquifyEnabled(bool enabledOrNot);
	event AutoLiquify(uint256 amountBNB, uint256 amountToken);

	constructor(address r) Auth(msg.sender) {
		router = IDexRouter(r);
        dexPair = IDexFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

		isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
		isTxLimitExempt[msg.sender] = true;
		isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;

		autoLiquidityReceiver = msg.sender;
		pairs[dexPair] = true;
		_balances[msg.sender] = _totalSupply;

		emit Transfer(address(0), msg.sender, _totalSupply);
	}

	receive() external payable {}
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

	function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
			require(_allowances[sender][msg.sender] >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

	function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
		require(amount > 0, "Transfer amount cannot be zero.");
        if (inSwap || sender == owner) {
            return _basicTransfer(sender, recipient, amount);
        }
        if(launchBlock == 0 && pairs[recipient]) return true;

        checkTxLimit(sender, recipient, amount);

        if (shouldSwapBack()) swapBack();

		require(amount <= _balances[sender], "Insufficient Balance");
        
        _balances[sender] -= amount;
        
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount, pairs[recipient]) : amount;
        _balances[recipient] += amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function dumpProtection(address sender, uint256 amount, bool isSale) internal {
        if(block.number < launchBlock + 100){
            require(amount <= 200 * (10 ** _decimals) * (block.number - launchBlock));
            if(isSale) require(lastTx[sender] + 5 minutes < block.timestamp,"delay against bots");
            lastTx[sender] = block.timestamp; 
        }
    }

	function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
		require(amount <= _balances[sender], "Insufficient Balance");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

	function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender] || isTxLimitExempt[recipient] && pairs[sender], "TX Limit Exceeded");
		// Max wallet check.
		if (sender != owner
            && recipient != owner
            && !isTxLimitExempt[recipient]
            && recipient != ZERO 
            && recipient != DEAD 
            && !pairs[recipient]
            && recipient != address(this)
        ) {
            uint256 newBalance = balanceOf(recipient) + amount;
            require(newBalance <= _maxWalletAmount, "Exceeds max wallet.");
        }
    }

	// Decides whether this trade should take a fee.
	// Trades with pairs are taxed by default, unless sender or receiver is exempt.
	// Non trades, like wallet to wallet, are configured, untaxed by default.
	function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient]) return false;
		if (pairs[sender] || pairs[recipient]) return true;
        return feeOnNonTrade;
    }

	function takeFee(address sender, uint256 amount, bool isSale) internal returns (uint256) {
        dumpProtection(sender, amount, isSale);
		uint256 liqFee = 0;
        uint256 devFee = 0;
		uint256 eco = 0;
		uint256 den = isSale ? feeDenominatorSell : feeDenominator;

		// If there is a liquidity tax active for autoliq, the contract keeps it.
		if (liquidityFee > 0 || devFee > 0) {
			uint256 lFee = isSale ? liquidityFeeSell : liquidityFee;
			uint256 dFee = isSale ? developerFeeSell : developerFee;
			liqFee = amount * lFee / den;
			devFee = amount * dFee / den;
			_balances[address(this)] += liqFee + devFee;
			emit Transfer(sender, address(this), liqFee + devFee);
		}

		// If ecosystem tax is active, it is sent to receiver. Ignored if receiver not set.
		if (ecosystemFee > 0 && ecosystemFeeReceiver != address(0)) {
			uint256 eFee = isSale ? ecosystemFeeSell : ecosystemFee;
			eco = amount * eFee / den;
			_balances[ecosystemFeeReceiver] += eco;
			emit Transfer(sender, ecosystemFeeReceiver, eco);
		}

        return amount - liqFee - eco - devFee;
    }

    function shouldSwapBack() internal view returns (bool) {
        return !pairs[msg.sender]
            && !inSwap
            && swapEnabled
            && _balances[address(this)] >= swapThreshold;
    }

	function setSwapEnabled(bool set) external authorized {
		swapEnabled = set;
		emit AutoLiquifyEnabled(set);
	}

	function swapBack() internal swapping {
		uint256 tokensToSwap = balanceOf(address(this));
		if (tokensToSwap > swapThreshold) {
			tokensToSwap = swapThreshold;
		}

		uint256 totalSellFee = liquidityFeeSell + developerFeeSell + ecosystemFeeSell;
        uint256 amountToLiquify = tokensToSwap * liquidityFeeSell / totalSellFee / 2;
        uint256 amountToSwap = tokensToSwap - amountToLiquify;
 
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
 
        uint256 balanceBefore = address(this).balance;
 
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
 
        uint256 amount = address(this).balance - balanceBefore;
        uint256 tFee = totalSellFee - liquidityFeeSell / 2;
        uint256 amountLiquidity = amount * liquidityFeeSell / tFee / 2;
        uint256 amountMarketing = amount * developerFeeSell / tFee;

		router.addLiquidityETH{value: amountLiquidity}(
			address(this),
			amountToLiquify,
			0,
			0,
			autoLiquidityReceiver,
			block.timestamp
		);
		emit AutoLiquify(amountLiquidity, amountToLiquify);

		if (devFeeReceiver != address(0)) {
			payable(devFeeReceiver).transfer(amountMarketing + balanceBefore);
		}
    }

	function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000);
        _maxTxAmount = amount;
    }

	function setMaxWallet(uint256 amount) external authorized {
		require(amount >= _totalSupply / 1000);
		_maxWalletAmount = amount;
	}

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _burnFee, uint256 _ecosystemFee, uint256 _devFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
		ecosystemFee = _ecosystemFee;
		developerFee = _devFee;
        feeDenominator = _feeDenominator;
		uint256 totalFee = _liquidityFee + _burnFee + _ecosystemFee + _devFee;
        require(totalFee <= feeDenominator / 5, "Maximum fees allowed in this contract is 20%.");
    }

	function setSellFees(uint256 _liquidityFee, uint256 _burnFee, uint256 _ecosystemFee, uint256 _devFee, uint256 _feeDenominator) external authorized {
        liquidityFeeSell = _liquidityFee;
		ecosystemFeeSell = _ecosystemFee;
		developerFeeSell = _devFee;
        feeDenominatorSell = _feeDenominator;
		uint256 totalFee = _liquidityFee + _burnFee + _ecosystemFee + _devFee;
        require(totalFee <= feeDenominatorSell / 5, "Maximum sale fees allowed in this contract is 20%.");
    }

    function setLiquidityReceiver(address _autoLiquidityReceiver) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
    }

	function setEcoReceiver(address eco) external authorized {
        ecosystemFeeReceiver = eco;
    }

	function setDevFeeReceiver(address dev) external authorized {
        devFeeReceiver = dev;
    }

	function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

	// Recover tokens sent to the contract by mistake.
	function rescueToken(address token) external {
		IBEP20 t = IBEP20(token);
		t.transfer(owner, t.balanceOf(address(this)));
    }

	function setPair(address pair, bool isPair) external authorized {
       pairs[pair] = isPair;
    }

	function changeRouter(address r) external authorized {
		router = IDexRouter(r);
        _allowances[address(this)][r] = type(uint256).max;
	}

	function updateMainPair() external authorized {
		dexPair = IDexFactory(router.factory()).createPair(router.WETH(), address(this));
	}

	function updateMainPairNotWeth(address notWeth) external authorized {
		dexPair = IDexFactory(router.factory()).createPair(notWeth, address(this));
	}

    function launch() external authorized {
        require(launchBlock == 0, "can only be done once");
        launchBlock = block.number;
    }
}