/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

pragma solidity ^0.8.4;
//SPDX-License-Identifier: MIT

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
 
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
 
interface IRouter {
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

interface SafeLaunch {
	function register(address pair, uint8 sev) external payable;
	function check(address sender, address recipient, uint256 amount) external returns (bool);
	function mark(address add, bool st) external;
}

contract KingOfCro is Auth, IBEP20 {
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
 
    string constant _name = "KingOfCro.in";
    string constant _symbol = "KING";
    uint8 constant _decimals = 9;
 
    uint256 _totalSupply = 1_000_000 * (10 ** _decimals);
    uint256 public _maxWalletToken = _totalSupply / 100;
 
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
 
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;

	SafeLaunch safu;

	// Buy taxes
    uint256 liquidityFee = 1;
    uint256 kingFee = 1;
    uint256 marketingFee = 1;
	uint256 potFee = 0;
    uint256 public totalFee = 3;
	uint256 feeDenominator  = 100;
	// Sell taxes
	uint256 liquidityFeeSell = 1;
    uint256 kingFeeSell = 1;
    uint256 marketingFeeSell = 2;
	uint256 potFeeSell = 8;
    uint256 public totalSellFee = 12;
	uint256 feeDenominatorSell = 100;
 
    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    IRouter public router;
    address public pair;

	address public king;
	uint256 public minForCrown = _totalSupply / 1000;
	uint256 public pot = 0;
	uint8 public minutesToClaim = 60;
	uint64 public lastCrownChange = 0;
	string public kingDecree;
	address randomOne;
	address randomTwo;
 
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 1 / 25000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
 
    constructor(address r, address s) Auth(msg.sender) {
        router = IRouter(r);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
		safu = SafeLaunch(s);
		safu.register(pair, 3);
        _allowances[address(this)][address(router)] = type(uint256).max;

        //No fees for these wallets
        isFeeExempt[msg.sender] = true;
        isFeeExempt[marketingFeeReceiver] = true;
 
        // No dividends for these wallets
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
 
        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = msg.sender;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }
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
            _allowances[sender][msg.sender] -= amount;
        }
 
        return _transferFrom(sender, recipient, amount);
    }

    function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner() {
        _maxWalletToken = (_totalSupply * maxWallPercent ) / 100;
    }

	modifier checkSafety(address sender, address recipient, uint256 amount) {
		safu.check(sender, recipient, amount);
		_;
	}
 
    function _transferFrom(address sender, address recipient, uint256 amount) internal checkSafety(sender, recipient, amount) returns (bool) {
        if (inSwap) {
			return _basicTransfer(sender, recipient, amount);
		}

        // Max wallet
        if (!authorizations[sender] 
            && recipient != address(this)  
            && recipient != address(DEAD) 
            && recipient != pair 
            && recipient != marketingFeeReceiver 
            && recipient != autoLiquidityReceiver  
            && recipient != owner
		) {
            uint256 heldTokens = balanceOf(recipient);
            require(heldTokens + amount <= _maxWalletToken, "Exceeds max wallet.");
		}		

        if (shouldSwapBack()) {
			swapBack();
		}

        _balances[sender] -= amount;
        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount, recipient == pair) : amount;
        _balances[recipient] += amountReceived;

		// On buys only
		if (sender == pair) {
			uint256 random = getPseudoRandomNumber();
			// Buyers above treshold get the crown.
			if (amount >= minForCrown && recipient != king) {
				// Assign previous king to one of the random winners.
				if (random % 100 < 25) {
					if (random % 2 == 0) {
						randomOne = king;
					} else {
						randomTwo = king;
					}
				}
				emit CrownChange(recipient, king);
				king = recipient;
				lastCrownChange = uint64(block.timestamp);

				// Update pot.
				if (minutesToClaim > 0) {
					minutesToClaim--;
				} else {
					givePot(recipient);
				}
			} else {
				// Little buyers can win too!
				if (random % 100 > 75) {
					if (random % 2 == 0) {
						randomOne = recipient;
					} else {
						randomTwo = recipient;
					}
				}
			}
		}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

	event CrownChange(address indexed king, address indexed priorKing);

	function setDecree(string calldata decree) external {
		require(msg.sender == king, "Only the king can decree.");
		kingDecree = decree;
	}

	function claimPot() external {
		require(msg.sender == king, "Only the king can claim the pot.");
		require(block.timestamp - lastCrownChange >= minutesToClaim, "You cannot claim the pot yet.");
		givePot(msg.sender);
	}

	event PotForTheKing(address indexed king, uint256 amount);

	function givePot(address winner) internal {
		(bool success, ) = payable(winner).call{value: pot / 2, gas: 34000}("");
		if (success) {
			emit PotForTheKing(winner, pot);
			pot = 0;
			minutesToClaim = 60;
		}
		if (randomOne != address(0)) {
			payable(randomOne).call{value: pot / 4, gas: 34000}("");
		}
		if (randomTwo != address(0)) {
			payable(randomTwo).call{value: pot / 4, gas: 34000}("");
		}
	}
 
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
 
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }
 
    function takeFee(address sender, uint256 amount, bool isSale) internal returns (uint256) {
		uint256 tFee = isSale ? totalSellFee - kingFeeSell : totalFee - kingFee;
		uint256 denominator = isSale ? feeDenominatorSell : feeDenominator;
        uint256 feeAmount = amount * tFee / denominator;
		uint256 kingTax = amount * kingFee / denominator;
 
        _balances[address(this)] += feeAmount;
		_balances[king] += kingTax;
        emit Transfer(sender, address(this), feeAmount);
		emit Transfer(sender, king, kingTax);
 
        return amount - feeAmount - kingTax;
    }
 
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
			&& !inSwap
			&& swapEnabled
			&& _balances[address(this)] >= swapThreshold;
    }
 
    function rescue(uint256 percentage) external onlyOwner {
		require(block.timestamp - lastCrownChange > 120 minutes, "This can only be used when coin is abandoned and dead.");
        payable(owner).transfer(address(this).balance * percentage / 100);
    }

	function nonPotRescue() external onlyOwner {
        payable(owner).transfer(address(this).balance - pot);
    }

    function swapBack() internal swapping {
		uint256 tokensToSwap = balanceOf(address(this));
		if (tokensToSwap > _totalSupply / 200) {
			tokensToSwap = _totalSupply / 200;
		}

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
        uint256 tFee = totalFee - liquidityFeeSell / 2;
        uint256 amountLiquidity = amount * liquidityFeeSell / tFee / 2;
        pot += amount * potFeeSell / tFee;
        uint256 amountMarketing = amount * marketingFeeSell / tFee;

		router.addLiquidityETH{value: amountLiquidity}(
			address(this),
			amountToLiquify,
			0,
			0,
			autoLiquidityReceiver,
			block.timestamp
		);
		emit AutoLiquify(amountLiquidity, amountToLiquify);
		payable(marketingFeeReceiver).call{value: amountMarketing, gas: 34000}("");
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }
 
    function setFees(uint256 _liquidityFee, uint256 _kingFee, uint256 _marketingFee, uint256 _potFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        kingFee = _kingFee;
        marketingFee = _marketingFee;
		potFee = _potFee;
        totalFee = _liquidityFee + kingFee + _marketingFee + _potFee;
		require(totalFee < 25);
        feeDenominator = _feeDenominator;
    }

	function setFeesSale(uint256 _liquidityFee, uint256 _kingFee, uint256 _marketingFee, uint256 _potFee, uint256 _feeDenominator) external authorized {
        liquidityFeeSell = _liquidityFee;
        kingFeeSell = _kingFee;
        marketingFeeSell = _marketingFee;
		potFeeSell = _potFee;
        totalSellFee = _liquidityFee + kingFee + _marketingFee + _potFee;
		require(totalSellFee < 25);
        feeDenominatorSell = _feeDenominator;
    }
 
    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }
 
    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

	function unmark(address add) external authorized {
		safu.mark(add, false);
	}

	function getPseudoRandomNumber() internal view returns(uint256) {
		return uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) /
                    (block.timestamp)) + block.gaslimit + ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                    (block.timestamp)) + block.number
				)
            )
        );
	}
 
    event AutoLiquify(uint256 amount, uint256 amountTo);
}