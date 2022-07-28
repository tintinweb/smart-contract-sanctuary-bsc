// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./SafeMathUint.sol";
import "./SafeMathInt.sol";
import "./DividendPayingTokenInterface.sol";
import "./DividendPayingTokenOptionalInterface.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./DividendPayingToken.sol";
import "./IterableMapping.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";

interface csaInviter {
    function inviter(address) external view returns (address);
    function setLevel(address,address) external;
}
interface exchequerLike {
    function dividendsPool(address) external returns (uint256);
}
interface TokenLike {
    function mint(address,uint256) external;
}
contract CSAToken is ERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "CSAToken/not-authorized");
        _;
    }

    csaDividendTracker public dividendTracker;
    IUniswapV2Router public uniswapV2Router;
    csaInviter public Inviter = csaInviter(0xC6107Bf3a0d7645B5c1ed4f04Feb7b1B1A898058);
    exchequerLike public vault = exchequerLike(0x6211F387Da41e0290327AfdeFC80A86BE7193742);

    address public  uniswapV2Pair;
    bool private swapping;
    bool public tier = true;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public operationAddress = 0x28A47379F29267Fbc2Bbd853FD59152dB9c6EFaA;
    address public doante = 0xD6a26CE9244455aEF59a800bDb0F5AF5f8bEE4Be;
    address public goldKey = 0xd4ee1e59Af6CA30f578aB05d371db290696aaAE4;

    uint256 public swapTokensAtAmount = 10000 * 1E18;
    uint256 public startTime;
    uint256 public minUsdtBuy = 100 * 1E18;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;
    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => uint256) public CSAReferrer;
    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SendDividends(
        address indexed ust,
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

    constructor() public ERC20("Consensus Ark", "CSA") {

        wards[msg.sender] = 1;
    	dividendTracker = new csaDividendTracker();
    	IUniswapV2Router _uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), usdt);
        uniswapV2Pair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(doante);
        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(doante, true);
        _mint(owner(), 40000000 * 1e18);
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "csa: The dividend tracker already has that address");
        csaDividendTracker newDividendTracker = csaDividendTracker(payable(newAddress));
        require(newDividendTracker.owner() == address(this), "csa: The new dividend tracker must be owned by the csa token contract");
        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));
        dividendTracker = newDividendTracker;
    }

    function excludeFromFees(address account, bool excluded) public auth {
        require(_isExcludedFromFees[account] != excluded, "csa: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) public auth {
        require(automatedMarketMakerPairs[pair] != value, "csa: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }
        emit SetAutomatedMarketMakerPair(pair, value);
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

	function excludeFromDividends(address account) external auth{
	    dividendTracker.excludeFromDividends(account);
	}
    function setTier() external auth{
	    tier = !tier;
	}

	function setTime(uint256 what,uint256 data, address ust) external onlyOwner{
        if (what == 1) Inviter = csaInviter(ust);
        if (what == 2) vault = exchequerLike(ust);
        if (what == 3) goldKey = ust;
        if (what == 4) startTime = data;
	}

	function setVariable(uint256 what, address ust, uint256 data) external auth{
        if (what == 1) operationAddress = ust;
        if (what == 2) doante = ust;
        if (what == 3) swapTokensAtAmount = data;
        if (what == 4) dividendTracker.setMinimumTokenBalanceForDividends(data);
        if (what == 5) minUsdtBuy = data;
	}

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

	function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	return dividendTracker.getAccountAtIndex(index);
    }

	function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
		dividendTracker.processAccount(msg.sender, false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function _transfer(address from,address to,uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        if (automatedMarketMakerPairs[to] && balanceOf(to) == 0) require(from == doante,"csa/001");
        if (automatedMarketMakerPairs[from] && isBuy(from,amount) || automatedMarketMakerPairs[to] && !isAddLiquidity(to,amount)) require(block.timestamp > startTime,"csa/001");
        if (Inviter.inviter(to) == address(0) && balanceOf(to) == 0) Inviter.setLevel(to,from);
        
        if(amount <= 1E18) {
            super._transfer(from, to, amount);
            return;
        }
 
		uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap && !swapping && !automatedMarketMakerPairs[from] && from != owner() && to != owner()) {
            swapping = true;
            uint256 burnTokens = contractTokenBalance.mul(1).div(10);
            super._transfer(address(this),deadWallet,burnTokens);

            uint256 sellTokens = balanceOf(address(this));
            swapAndSendDividends(sellTokens);
            swapping = false;
        }
        if (automatedMarketMakerPairs[from] && isBuy(from,amount)) {
            address[] memory path = new address[](2);
            path[0] = usdt;
            path[1] = address(this);
            uint[] memory amounts = uniswapV2Router.getAmountsIn(amount,path);
            uint256 goldKeyAmount = amounts[0]/minUsdtBuy;
            if (goldKeyAmount > 0) TokenLike(goldKey).mint(to,goldKeyAmount);
        }
        
        bool takeFee = !swapping;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        if(totalSupply().sub(balanceOf(deadWallet)) <= 1000*1E22) {
            takeFee = false;
        }

        if(takeFee) {
        	uint256 fees = amount.mul(10).div(100);
            super._transfer(from, address(this), fees);
            if (tier) {
                uint256 referralBonuses = amount.mul(1).div(100);
                address dst;
                if(automatedMarketMakerPairs[from]) dst = to;
                else dst = from;
                address _referrer = Inviter.inviter(dst);
                if(_referrer == address(0) || automatedMarketMakerPairs[_referrer]) _referrer = operationAddress;
                super._transfer(address(this), _referrer, referralBonuses);
            }
            amount = amount.sub(fees);
        }

        super._transfer(from, to, amount);
        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
            } catch {}
        }
        
    }

    function initApprove() public {
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
    }

    function swapTokensForUsdt(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        uniswapV2Router.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(vault),
            block.timestamp
        );
    }

    function swapAndSendDividends(uint256 tokens) private{
        swapTokensForUsdt(tokens);
        uint256 dividends = vault.dividendsPool(address(dividendTracker));
        if (dividends > 0) {
            dividendTracker.distributeDOGEDividends(dividends);
            emit SendDividends(address(dividendTracker),tokens, dividends);
        }
    }
    

    function getAsset(address _pair) public view returns (address){
        address _token0 = IUniswapV2Pair(_pair).token0();
        address _token1 = IUniswapV2Pair(_pair).token1();
        address asset = _token0 == address(this) ? _token1 : _token0;
        return asset;
    }
    //Decide whether to add liquidity or sell,
    function isAddLiquidity(address _pair,uint256 wad) internal view returns (bool) {
        address _asset = getAsset(_pair);
        uint256 balance1 = IERC20(_asset).balanceOf(_pair);
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(_pair).getReserves();
        if (reserve0 ==0 || reserve1 ==0 ) return true;
        address _token0 = IUniswapV2Pair(_pair).token0();
        (uint256 spdreserve, uint256 assetreserve)= _token0 == address(this) ? (reserve0,reserve1) : (reserve1,reserve0);
        uint256 assetamount = uniswapV2Router.quote(wad, spdreserve, assetreserve);
        return (balance1 > assetreserve + assetamount/2 );
    }
    function isBuy(address _pair,uint256 wad) internal view returns (bool) {
        if (!automatedMarketMakerPairs[_pair]) return false;
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(_pair).getReserves();
        address _token0 = IUniswapV2Pair(_pair).token0();
        (,uint assetreserve)= _token0 == address(this) ? (reserve0,reserve1) : (reserve1,reserve0);
        address _asset = getAsset(_pair);
        address[] memory path = new address[](2);
        path[0] = _asset;
        path[1] = address(this);
        uint[] memory amounts = uniswapV2Router.getAmountsIn(wad,path);
        uint balance1 = IERC20(_asset).balanceOf(_pair);
        return (balance1 > assetreserve + amounts[0]/2);
    }
}

contract csaDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;
    mapping (address => bool) public excludedFromDividends;
    mapping (address => uint256) public lastClaimTimes;
    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() public DividendPayingToken("CSA_Dividen_Tracker", "CSA_Dividend_Tracker") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 1000 * (10**18); //must hold 1000+ tokens
    }

    function _transfer(address, address, uint256) internal override {
        require(false, "CSA_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public override {
        require(false, "CSA_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main csa contract.");
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }
    function setMinimumTokenBalanceForDividends(uint256 _min) external onlyOwner {
    	minimumTokenBalanceForDividends = _min;
    }

    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;
        index = tokenHoldersMap.getIndexOfKey(account);
        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ? tokenHoldersMap.keys.length.sub(lastProcessedIndex) : 0;
                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);
        lastClaimTime = lastClaimTimes[account];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
    }

    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);
        return getAccount(account);
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