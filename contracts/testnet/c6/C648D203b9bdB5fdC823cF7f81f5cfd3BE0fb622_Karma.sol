// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./DividendPayingToken.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./IERC20.sol";

contract Karma is ERC20, Ownable {
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedFromMaxSellTxLimit;

    address constant private  DEAD = 0x000000000000000000000000000000000000dEaD;

    // Selling fee
    uint8 public sellBurnFee = 10;
    uint256 public totalSellFees;

    // Dates
    uint256 public sellStartDate;
    uint256 public sellEndDate;

    // Limits
    uint256 public maxSellLimit =  50_000_000 * 10**18; // 0.5%

    // Reward system
    address public rewardTokenAddress;
    KarmaDividendTracker public dividendTracker;

    // Any transfer to these addresses could be subject to some sell/buy taxes
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event ProcessedDividendTracker(uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool indexed automatic, uint256 gas, address indexed processor);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromMaxSellTxLimit(address indexed account, bool isExcluded);

    event AddAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event Burn(uint256 amount);

    event BurnFeeUpdated(uint8 fee);

    event MaxSellLimitUpdated(uint256 amount);

    event SellDatesUpdated(uint256 newStartDate, uint256 newEndDate);


    constructor() ERC20("Karma", "KARMA") {
        // Create supply
        _mint(msg.sender, 10_000_000_000 * 10**18);

        totalSellFees = sellBurnFee;
    	dividendTracker = new KarmaDividendTracker();

        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // 0x10ED43C718714eb63d5aA57B78B54704E256024E
         // Create a uniswap pair for this new token
        IUniswapV2Pair uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH()));
        setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        rewardTokenAddress = address(0x6E2bA8115392fA84A80daEDa8bcB8a6172beb009); // SGC2

        // Exclude the project addresses of the different limits
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(address(uniswapV2Router));
        dividendTracker.excludeFromDividends(address(DEAD));

        excludeFromFees(owner(),true);
        excludeFromFees(address(this),true);

        excludeFromMaxSellLimit(owner(),true);

    }

    receive() external payable {
  	}
    

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "KARMA: Account has already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeFromMaxSellLimit(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromMaxSellTxLimit[account] != excluded, "KARMA: Account has already the value of 'excluded'");
        _isExcludedFromMaxSellTxLimit[account] = excluded;

        emit ExcludeFromMaxSellTxLimit(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public {
        require(automatedMarketMakerPairs[pair] != value, "KARMA: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit AddAutomatedMarketMakerPair(pair, value);
    }

    function setBurnFee(uint8 newBurnFee) external onlyOwner {
        require(newBurnFee <= 10 && newBurnFee >=0,"KARMA: Burn fee must be between 10 and 0");
        sellBurnFee = newBurnFee;
        totalSellFees = newBurnFee;
        emit BurnFeeUpdated(newBurnFee);
    }

    function setMaxSellLimit(uint256 amount) external onlyOwner {
        require(amount >= 1000 && amount <= 100_000_000, "KARMA: Amount must be bewteen 1000 and 100 000 000");
        maxSellLimit = amount *10**18;
        emit MaxSellLimitUpdated(amount);
    }

     function updateSellDates(uint256 newStartDate, uint256 newEndDate) external onlyOwner {
        require(newEndDate > newStartDate, "KARMA: endDate must be greater than startDate");
        sellStartDate = newStartDate;
        sellEndDate = newEndDate;
        emit SellDatesUpdated(newStartDate,newEndDate);
    }

    function burn(uint256 amount) external returns (bool) {
        super._transfer(_msgSender(), DEAD, amount);
        emit Burn(amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "KARMA: Transfer from the zero address");
        require(to != address(0), "KARMA: Transfer to the zero address");
        require(amount >= 0, "KARMA: Transfer amount must be greater or equals to zero");

        bool isSellTransfer = automatedMarketMakerPairs[to];
        if(isSellTransfer) {
            require(block.timestamp <= sellEndDate && block.timestamp >= sellStartDate, "KARMA: You can sell tokens only during the selling period");
            if (!_isExcludedFromMaxSellTxLimit[from]) require(amount <= maxSellLimit, "KARMA: Amount exceeds the maxSellTxLimit.");
        }

        bool takeFee = isSellTransfer;
        // Remove fees if one of the address is excluded from fees
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) takeFee = false;


        uint256 feeAmount = 0;
        if(takeFee) {
            feeAmount = amount * totalSellFees / 100;
            if(feeAmount != 0) {super._transfer(from, DEAD, feeAmount);}
        }
        super._transfer(from, to, amount - feeAmount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {require(false, "Something went wrong");}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {require(false, "Something went wrong");}

    }


    // To distribute airdrops easily
    function batchTokensTransfer(address[] calldata _holders, uint256[] calldata _amounts) external onlyOwner {
        require(_holders.length <= 200);
        require(_holders.length == _amounts.length);
            for (uint i = 0; i < _holders.length; i++) {
              if (_holders[i] != address(0)) {
                super._transfer(_msgSender(), _holders[i], _amounts[i]);
            }
        }
    }

    function getStuckBNBs(address payable to) external onlyOwner {
        require(address(this).balance > 0, "KARMA: There are no BNBs in the contract");
        to.transfer(address(this).balance);
    } 

    function getStuckTokens(address payable to, address tokenAddress) external onlyOwner {
        require(IERC20(tokenAddress).balanceOf(address(this)) > 0, "KARMA: There are tokens in the contract");
        IERC20(tokenAddress).transfer(to,IERC20(tokenAddress).balanceOf(address(this)));
    }

    // Reward system

    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    function includeInDividends(address account) external onlyOwner {
        dividendTracker.includeInDividends(account,balanceOf(account));
    }


    function claim() external {
		dividendTracker.processAccount(payable(msg.sender), false);
    }

    function updateRewardTokenAddress(address newTokenAddress) external onlyOwner {
        require(rewardTokenAddress != newTokenAddress, "The new token address is the same as the old one");
        rewardTokenAddress = newTokenAddress;
        dividendTracker.updateRewardTokenAddress(newTokenAddress);
    }

    function shareDividends(uint256 tokenAmount) external onlyOwner {
        dividendTracker.shareDividends(tokenAmount);
    }

    function getCirculatingSupply() external view returns (uint256) {
        return totalSupply() - balanceOf(DEAD) - balanceOf(address(0));
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function isExcludedFromMaxSellLimit(address account) public view returns(bool) {
        return _isExcludedFromMaxSellTxLimit[account];
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromDividends(address account) public view returns(bool) {
        return dividendTracker.isExcludedFromDividends(account);
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
    	return dividendTracker.withdrawableDividendOf(account);
  	}

	function dividendTokenBalanceOf(address account) public view returns (uint256) {
		return dividendTracker.balanceOf(account);
	}

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }
}

contract KarmaDividendTracker is DividendPayingToken {
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;

    mapping (address => bool) private _excludedFromDividends;

    uint256 public immutable MINIMUM_TOKEN_BALANCE_FOR_DIVIDENDS; 

    event ExcludeFromDividends(address indexed account);
    event IncludeInDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SetBalance(address payable account, uint256 newBalance);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() DividendPayingToken("KARMA_Dividend_Tracker", "KARMA_Dividend_Tracker") {
        MINIMUM_TOKEN_BALANCE_FOR_DIVIDENDS = 1* (10**18); //must hold 1 token
    }

    function _transfer(address, address, uint256) pure internal override {
        require(false, "KARMA_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() pure public override {
        require(false, "KARMA_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main KARMA contract.");
    }
    function isExcludedFromDividends(address account) external view returns(bool) {
        return _excludedFromDividends[account];
    }
    function excludeFromDividends(address account) external onlyOwner {
    	require(!_excludedFromDividends[account]);
    	_excludedFromDividends[account] = true;
    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function includeInDividends(address account, uint256 balance) external onlyOwner {
    	require(_excludedFromDividends[account]);
    	_excludedFromDividends[account] = false;
        if(balance >= MINIMUM_TOKEN_BALANCE_FOR_DIVIDENDS) {
            _setBalance(account, balance);
    		tokenHoldersMap.set(account, balance);
    	}
    	emit IncludeInDividends(account);
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(_excludedFromDividends[account]) {
    		return;
    	}

    	if(newBalance >= MINIMUM_TOKEN_BALANCE_FOR_DIVIDENDS) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
            emit SetBalance(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
            emit SetBalance(account, 0);
    	}
    }


    function processAccount(address account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

    	if(amount > 0) {
            emit Claim(account, amount, automatic);
    		return true;
    	}

    	return false;
    }
}