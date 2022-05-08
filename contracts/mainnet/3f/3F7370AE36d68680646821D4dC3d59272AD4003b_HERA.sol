// SPDX-License-Identifier: MIT

//

pragma solidity ^0.6.2;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./IRewardPool.sol";

contract HERA {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    uint8 private _decimals;

    string private _name;
    string private _symbol;

    address private _owner;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    bool private swapping;

    HERADividendTracker public dividendTracker;

    address public deadWallet;

    address public BUSD; //BUSD

    uint256 public swapTokensAtAmount;
    
    mapping(address => bool) public _isBlacklisted;

    struct FeeInfo {
    // sell, transfer
        uint256 BUSDRewardsFee;
        uint256 liquidityFee;
        uint256 treasuryFee;
        uint256 buyBackFee;

        // buy
        uint256 BUSDRewardsFee_buy;
        uint256 liquidityFee_buy;
        uint256 treasuryFee_buy;
        uint256 buyBackFee_buy;
    }

    FeeInfo public feeInfo;
    
    address public treasuryWallet;
    address public buybackWallet;

    address public rewardPool;
    address public operator;

    uint256 private liquidityAmount;
    uint256 private buybackAmount;
    uint256 private treasuryAmount;
    uint256 private rewardAmount;
    
    uint256 public startTime;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing;
    uint256 public TIME_STEP;

    bool public adjustmentEnabled;

     // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;


    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    // mapping (address => bool) public automatedMarketMakerPairs;

    mapping(address => mapping(uint256 => uint256)) public sold;

    mapping(address => bool) public _excludeFromLimit;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 busdReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends(
    	uint256 tokensSwapped,
    	uint256 amount
    );

    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

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
    
    modifier onlyOperator() {
        require(operator == msg.sender, "Operator: caller is not the operator");
        _;
    }

    modifier checkLimit(address from, address to, uint256 value) {
        if(!_excludeFromLimit[from]) {
            uint256 pairBalance = balanceOf(uniswapV2Pair);
            require(sold[from][getCurrentDay()] + value <= pairBalance.div(100), "Cannot sell or transfer more than limit.");
        }
        _;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function run(address owner) public {
        _owner = owner;
        _name = "HERA";
        _symbol = "HERA";
        _decimals = 18;
    }

    function runInit() public onlyOwner{
        deadWallet = 0x000000000000000000000000000000000000dEaD;
        BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        swapTokensAtAmount = 1000000 * (10**18);
        treasuryWallet = 0x24e21EF2C3C9C93B5791d77cF934bF92a91276ba;
        buybackWallet = 0x24e21EF2C3C9C93B5791d77cF934bF92a91276ba;
        gasForProcessing = 3000000;
        TIME_STEP = 1 days;

        dividendTracker = new HERADividendTracker();


    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);

        _excludeFromLimit[deadWallet] = true;
        _excludeFromLimit[address(0)] = true;
        _excludeFromLimit[address(this)] = true;
        _excludeFromLimit[uniswapV2Pair] = true;

        startTime = block.timestamp;

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 100000000000 * (10**18));

    // sell, transfer
        feeInfo.BUSDRewardsFee = 2;
        feeInfo.liquidityFee = 5;
        feeInfo.treasuryFee = 5;
        feeInfo.buyBackFee = 7;

    // buy
        feeInfo.BUSDRewardsFee_buy = 2;
        feeInfo.liquidityFee_buy = 4;
        feeInfo.treasuryFee_buy = 3;
        feeInfo.buyBackFee_buy = 6;
    }

    receive() external payable {

  	}

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function mint(address account, uint256 amount) public onlyOperator {
        _mint(account, amount);
    }

    function setOperator(address _operator) public onlyOwner {
        require(operator == address(0), "Already existed!");
        operator = _operator;
    }

    function toggleAdjustment() public onlyOwner {
        bool val = adjustmentEnabled;
        adjustmentEnabled = !val;
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "HERA: The dividend tracker already has that address");

        HERADividendTracker newDividendTracker = HERADividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "HERA: The new dividend tracker must be owned by the HERA token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "HERA: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function setExcludeFromLimit(address _address, bool _bool) public onlyOwner {
        _excludeFromLimit[_address] = _bool;
    }

    function getCurrentDay() public view returns (uint256) {
        return minZero(block.timestamp, startTime).div(TIME_STEP);
    }

    function minZero(uint a, uint b) private pure returns(uint) {
        if (a > b) {
           return a - b; 
        } else {
           return 0;    
        }    
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 5000000, "HERA: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "HERA: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
    	return dividendTracker.withdrawableDividendOf(account);
  	}

	function dividendTokenBalanceOf(address account) public view returns (uint256) {
		return dividendTracker.balanceOf(account);
	}

	function excludeFromDividends(address account) external onlyOwner{
	    dividendTracker.excludeFromDividends(account);
	}

	function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
		dividendTracker.processAccount(msg.sender, false);
    }

    uint256 public lastAdjustTime;

    function adjustment() private {
        if (block.timestamp < lastAdjustTime.add(60 * 60))
            return;
        
        lastAdjustTime = lastAdjustTime.add(60 * 60);
        uint256 pairBalance = balanceOf(uniswapV2Pair);
        if (pairBalance > 0) {
            // 1.00062055  every hour, 1.015 every day
            uint256 adjAmount = pairBalance.mul(62055).div(10**8);
            _burn(deadWallet, adjAmount);

            IUniswapV2Pair(uniswapV2Pair).sync();
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal checkLimit(from, to, amount) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');

        if(amount == 0) {
            tokenTransfer(from, to, 0);
            return;
        }

        bool canSwap = liquidityAmount.add(buybackAmount).add(treasuryAmount).add(rewardAmount) >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            !(from == uniswapV2Pair) &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;

            swapAndSendToFee(treasuryAmount, treasuryWallet);
            swapAndSendToFee(buybackAmount, buybackWallet);
            swapAndLiquify(liquidityAmount);
            swapAndSendDividends(rewardAmount);

            treasuryAmount = 0;
            buybackAmount = 0;
            liquidityAmount = 0;
            rewardAmount = 0;

            swapping = false;
        }


        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {

            uint256 fee_;
            uint256 fees = 0;
            // buying
            if (from == uniswapV2Pair) {
                fee_ = amount.mul(feeInfo.liquidityFee_buy).div(100);
                liquidityAmount += fee_;
                fees += fee_;
                fee_ = amount.mul(feeInfo.buyBackFee_buy).div(100);
                buybackAmount += fee_;
                fees += fee_;
                fee_ = amount.mul(feeInfo.BUSDRewardsFee_buy).div(100);
                rewardAmount += fee_;
                fees += fee_;
                fee_ = amount.mul(feeInfo.treasuryFee_buy).div(100);
                treasuryAmount += fee_;
                fees += fee_;
                amount = amount.sub(fees);
                tokenTransfer(from, address(this), fees);
            }
            // selling, transfer
        	else {         
                if (adjustmentEnabled)     
                    adjustment();
                // anti-whale
                uint256 moreFee = 0;
                {
                    uint256 userBalance = IRewardPool(rewardPool).pendingHera(from);
                    userBalance = userBalance.add(balanceOf(from));
                    if ( userBalance >= balanceOf(uniswapV2Pair).mul(3).div(100) )
                        moreFee = amount.mul(15).div(100);
                    else if ( userBalance >= balanceOf(uniswapV2Pair).div(50) )
                        moreFee = amount.div(10);
                    else if ( userBalance >= balanceOf(uniswapV2Pair).div(100) )
                        moreFee = amount.div(20);
                }

                moreFee = moreFee.div(2);
                fee_ = amount.mul(feeInfo.liquidityFee).div(100);
                liquidityAmount += fee_;
                fees += fee_;
                fee_ = amount.mul(feeInfo.buyBackFee).div(100).add(moreFee);
                buybackAmount += fee_;
                fees += fee_;
                fee_ = amount.mul(feeInfo.BUSDRewardsFee).div(100);
                rewardAmount += fee_;
                fees += fee_;
                fee_ = amount.mul(feeInfo.treasuryFee).div(100);
                treasuryAmount += fee_;
                fees += fee_;

                amount = amount.sub(fees).sub(moreFee);
                tokenTransfer(from, address(this), fees);
                _burn(from, moreFee);
            }

        }
        tokenTransfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {

	    	}
        }
    }

    function swapAndSendToFee(uint256 tokens, address wallet) private  {
        swapTokensForBusd(tokens);
        uint256 newBalance = (IERC20(BUSD).balanceOf(address(this)));
        IERC20(BUSD).transfer(wallet, newBalance);
    }

    function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current BUSD balance.
        // this is so that we can capture exactly the amount of BUSD that the
        // swap creates, and not make the liquidity event include any BUSD that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        if (initialBalance > 3 * 10**18) {
            payable(buybackWallet).transfer(initialBalance);
            initialBalance = 0;
        }

        // swap tokens for BUSD
        swapTokensForEth(half); // <- this breaks the BUSD -> HATE swap when swap+liquify is triggered

        // how much BUSD did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }


    function swapTokensForEth(uint256 tokenAmount) private {


        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }


    function swapTokensForBusd(uint256 tokenAmount) private {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = BUSD;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );

    }

    function swapAndSendDividends(uint256 tokens) private{
        swapTokensForBusd(tokens);
        uint256 dividends = IERC20(BUSD).balanceOf(address(this));
        bool success = IERC20(BUSD).transfer(address(dividendTracker), dividends);

        if (success) {
            dividendTracker.distributeBUSDDividends(dividends);
            emit SendDividends(tokens, dividends);
        }
    }

    function setRewardPool(address _rewardPool) external onlyOwner {
        rewardPool = _rewardPool;
    }

    function tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}

contract HERADividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() public DividendPayingToken("HERA_Dividen_Tracker", "HERA_Dividend_Tracker") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 2000000 * (10**18); //must hold 2000000+ tokens
    }

    function _transfer(address, address, uint256) internal override {
        require(false, "HERA_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public override {
        require(false, "HERA_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main HERA contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "HERA_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "HERA_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }
  
    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}

    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}

    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
    	}

    	processAccount(account, true);
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}

    	uint256 _lastProcessedIndex = lastProcessedIndex;

    	uint256 gasUsed = 0;

    	uint256 gasLeft = gasleft();

    	uint256 iterations = 0;
    	uint256 claims = 0;

    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;

    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}

    		address account = tokenHoldersMap.keys[_lastProcessedIndex];

    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(processAccount(payable(account), true)) {
    				claims++;
    			}
    		}

    		iterations++;

    		uint256 newGasLeft = gasleft();

    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}

    		gasLeft = newGasLeft;
    	}

    	lastProcessedIndex = _lastProcessedIndex;

    	return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}

    	return false;
    }
}