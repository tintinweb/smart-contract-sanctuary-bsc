//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.4;
pragma abicoder v2;

import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./ERC20PresetFixedSupplyUpgradeable.sol";
import "./OwnableUpgradeable.sol";
import "./Strings.sol";
import "./ReentrancyGuard.sol";

// Base class that implements: ERC20 interface, fees & swaps
abstract contract AMTBase is ERC20PresetFixedSupplyUpgradeable, OwnableUpgradeable, ReentrancyGuard {
    // REWARD WALLETS
    address public _rusticityWallet = 0xAec3F27c1612dF71075417007341040b2c6Dd561;
    address public _marketingWallet = 0x79910e35c0d0D4758840F7Dbb4487C58506F5767;
    address public _devWallet = 0x36615cBaB9Def10fEe9a992a45595517ee33243B;
    address public _charityWallet = 0xe2b9Fe279E07316dC235e64Eb4D255e710D5375a;
    // BASE TAXES
    uint8 public _marketingFee; //% of each transaction that will be used for marketing
    uint8 public _devFee; //% of each transaction that will be used for development
    uint8 public _charityFee; //% of each transaction that will be used for charity
    uint8 private _poolFee; //The total fee to be taken and added to the pool, this includes all fees
	uint8 private _highBuyFee;

	mapping (address => uint256) private _balances; //The balance of each address.  This is before applying distribution rate.  To get the actual balance, see balanceOf() method
	mapping (address => mapping (address => uint256)) private _allowances;

	// FEES & REWARDS
	bool private _isSwapEnabled; // True if the contract should swap for liquidity & reward pool, false otherwise
	bool private _isFeeEnabled; // True if fees should be applied on transactions, false otherwise
	bool private _isTokenHoldEnabled;
	uint256 private _tokenSwapThreshold; //There should be at least 0.0001% of the total supply in the contract before triggering a swap
	uint256 private _totalFeesPooled; // The total fees pooled (in number of tokens)
	uint256 private _totalBNBLiquidityAddedFromFees; // The total number of BNB added to the pool through fees
	mapping (address => bool) private _addressesExcludedFromFees; // The list of addresses that do not pay a fee for transactions
	mapping (address => bool) private _addressesExcludedFromHold; // The list of addresses that hold token amount

	// TRANSACTION LIMIT
	uint256 private _transactionSellLimit; // = _totalTokens; // The amount of tokens that can be sold at once
	uint256 private _transactionBuyLimit; // = _totalTokens; // The amount of tokens that can be bought at once
	bool private _isBuyingAllowed; // This is used to make sure that the contract is activated before anyone makes a purchase on PCS.  The contract will be activated once liquidity is added.

	// HOLD LIMIT
	uint256 private _maxHoldAmount;
    
	// QUICKSWAP INTERFACES (For swaps)
	address private _quickSwapRouterAddress;
	IUniswapV2Router02 private _quickSwapV2Router;
	address private _quickSwapV2Pair;

	// EVENTS
	event Swapped(uint256 tokensSwapped, uint256 bnbReceived, uint256 bnbIntoMarketing, uint256 bnbIntoDev, uint256 bnbIntoCharity);

	//QuickSwap Router address will be: 0xa5e0829caced8ffdd4de3c43696c57f7d7a678ff or for testnet: 0x8954afa98594b838bda56fe4c12a09d7739d179b
	constructor (address routerAddress) {
        initializeAskjaCoin("AGRO-MATIC", "AMT", 100000000 * 10**decimals(), _msgSender());
            
        // Exclude contract from fees & hold limitation
        _addressesExcludedFromFees[address(this)] = true;
        _addressesExcludedFromFees[_marketingWallet] = true;
        _addressesExcludedFromFees[_devWallet] = true;
        _addressesExcludedFromFees[_msgSender()] = true;

        _addressesExcludedFromHold[address(this)] = true;
        _addressesExcludedFromHold[_marketingWallet] = true;
        _addressesExcludedFromHold[_devWallet] = true;
        _addressesExcludedFromHold[_msgSender()] = true;

        // Initialize QuickSwap V2 router and AMT <-> MATIC pair.
        require(routerAddress != address(0), "Cannot use the zero address as router address");
		_quickSwapRouterAddress = routerAddress; 
		_quickSwapV2Router = IUniswapV2Router02(_quickSwapRouterAddress);
		_quickSwapV2Pair = IUniswapV2Factory(_quickSwapV2Router.factory()).createPair(address(this), _quickSwapV2Router.WETH());
		onQuickSwapRouterUpdated();

        _tokenSwapThreshold = totalSupply() / 10000; //There should be at least 0.0001% of the total supply in the contract before triggering a swap
        _transactionSellLimit = totalSupply(); // The amount of tokens that can be sold at once
        _transactionBuyLimit = totalSupply(); // The amount of tokens that can be bought at once
        _maxHoldAmount = 1200000 * 10**decimals();

		// 3% marketing fee, 2% dev fee, 1% charity fee
	    _marketingFee = 3;
		_devFee = 2;
        _charityFee = 1;
		
		// Enforce invariant
		_poolFee = _marketingFee + _devFee + _charityFee;
		_highBuyFee = 99;

		emit Transfer(address(0), _msgSender(), totalSupply());
	}

    function initializeAskjaCoin(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _owner
    ) public initializer {
        ERC20PresetFixedSupplyUpgradeable.initialize(
            _name,
            _symbol,
            _initialSupply,
            _owner
        );
    }

	// This function is used to enable all functions of the contract, after the setup of the token sale (e.g. Liquidity) is completed
	function activate() public onlyOwner {
		setSwapEnabled(true);
		setFeeEnabled(true);
		setTokenHoldEnabled(true);
		setTransactionSellLimit(400000 * 10**decimals());
		setTransactionBuyLimit(600000 * 10**decimals());
		activateBuying(true);
		onActivated();
	}

	function onActivated() internal virtual { }

	function balanceOf(address account) public view override returns (uint256) {
		return _balances[account];
	}
	
	function transfer(address recipient, uint256 amount) public override returns (bool) {
		doTransfer(_msgSender(), recipient, amount);
		return true;
	}
	
	function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
		doTransfer(sender, recipient, amount);
		doApprove(sender, _msgSender(), _allowances[sender][_msgSender()] - amount); // Will fail when there is not enough allowance
		return true;
	}
	
	function approve(address spender, uint256 amount) public override returns (bool) {
		doApprove(_msgSender(), spender, amount);
		return true;
	}
	
	function doTransfer(address sender, address recipient, uint256 amount) internal virtual {
		require(sender != address(0), "Transfer from the zero address is not allowed");
		require(recipient != address(0), "Transfer to the zero address is not allowed");
		require(amount > 0, "Transfer amount must be greater than zero");
		require(!isQuickSwapPair(sender) || _isBuyingAllowed, "Buying is not allowed before contract activation");

		if (_isSwapEnabled) {
			// Ensure that amount is within the limit in case we are selling
			if (isSellTransferLimited(sender, recipient)) {
				require(amount <= _transactionSellLimit, "Sell amount exceeds the maximum allowed");
			}

			// Ensure that amount is within the limit in case we are buying
			if (isQuickSwapPair(sender)) {
				require(amount <= _transactionBuyLimit, "Buy amount exceeds the maximum allowed");
			}
		}

		// Perform a swap if needed.  A swap in the context of this contract is the process of swapping the contract's token balance with BNBs in order to provide liquidity and increase the reward pool
		executeSwapIfNeeded(sender, recipient);

		onBeforeTransfer(sender, recipient, amount);

		// Calculate fee rate
		uint256 feeRate = calculateFeeRate(sender, recipient);
		
		uint256 feeAmount = amount * feeRate / 100;
		uint256 transferAmount = amount - feeAmount;

		bool applyTokenHold = _isTokenHoldEnabled && !isQuickSwapPair(recipient) && !_addressesExcludedFromHold[recipient];

		if (applyTokenHold) {
			require(_balances[recipient] + transferAmount < _maxHoldAmount, "Cannot hold more than Maximum hold amount");
		}

		// Update balances
		updateBalances(sender, recipient, amount, feeAmount);

		// Update total fees, this is just a counter provided for visibility
		_totalFeesPooled += feeAmount;

		emit Transfer(sender, recipient, transferAmount); 

		onTransfer(sender, recipient, amount);
	}

	function onBeforeTransfer(address sender, address recipient, uint256 amount) internal virtual { }

	function onTransfer(address sender, address recipient, uint256 amount) internal virtual { }


	function updateBalances(address sender, address recipient, uint256 sentAmount, uint256 feeAmount) private {
		// Calculate amount to be received by recipient
		uint256 receivedAmount = sentAmount - feeAmount;

		// Update balances
		_balances[sender] -= sentAmount;
		_balances[recipient] += receivedAmount;
		
		// Add fees to contract
		_balances[address(this)] += feeAmount;
	}


	function doApprove(address owner, address spender, uint256 amount) private {
		require(owner != address(0), "Cannot approve from the zero address");
		require(spender != address(0), "Cannot approve to the zero address");

		_allowances[owner][spender] = amount;
		
		emit Approval(owner, spender, amount);
	}


	function calculateFeeRate(address sender, address recipient) private view returns(uint256) {
		bool applyFees = _isFeeEnabled && !_addressesExcludedFromFees[sender] && !_addressesExcludedFromFees[recipient];
		if (applyFees) {
		    bool antiBotFalg = onBeforeCalculateFeeRate();
		    if (isQuickSwapPair(sender) && antiBotFalg) {
		        return _highBuyFee;
		    }
		    
			if (isQuickSwapPair(recipient) || isQuickSwapPair(sender)) {
				return _poolFee;
			}
		}

		return 0;
	}
	
	
	function onBeforeCalculateFeeRate() internal virtual view returns(bool) {
	    return false;
	}

	
	function executeSwapIfNeeded(address sender, address recipient) private {
		if (!isMarketTransfer(sender, recipient)) {
			return;
		}

		// Check if it's time to swap for liquidity & reward pool
		uint256 tokensAvailableForSwap = balanceOf(address(this));
		if (tokensAvailableForSwap >= _tokenSwapThreshold) {

			// Limit to threshold
			tokensAvailableForSwap = _tokenSwapThreshold;

			// Make sure that we are not stuck in a loop (Swap only once)
			bool isSelling = isQuickSwapPair(recipient);
			if (isSelling) {
				executeSwap(tokensAvailableForSwap);
			}
		}
	}


	function executeSwap(uint256 amount) private {
		// Allow QuickSwap to spend the tokens of the address
		doApprove(address(this), _quickSwapRouterAddress, amount);
		uint256 bnbSwapped = swapTokensForBNB(amount);
		
		//send bnb to marketing wallet
		uint256 bnbToBeSendToMarketing = bnbSwapped * _marketingFee / _poolFee;
		(bool sent, ) = _marketingWallet.call{value: bnbToBeSendToMarketing}("");
		require(sent, "Failed to send BNB to marketing wallet");
		
		//send bnb to dev wallet
		uint256 bnbToBeSendToDev = bnbSwapped * _devFee / _poolFee;
		(sent, ) = _devWallet.call{value: bnbToBeSendToDev}("");
		require(sent, "Failed to send BNB to dev wallet");

    //send bnb to charity wallet
		uint256 bnbToBeSendToCharity = bnbSwapped * _charityFee / _poolFee;
		(sent, ) = _devWallet.call{value: bnbToBeSendToCharity}("");
		require(sent, "Failed to send BNB to dev wallet");
		
		emit Swapped(amount, bnbSwapped, bnbToBeSendToMarketing, bnbToBeSendToDev, bnbToBeSendToCharity);
	}

	// This function swaps a {tokenAmount} of AMT tokens for BNB and returns the total amount of BNB received
	function swapTokensForBNB(uint256 tokenAmount) internal returns(uint256) {
		uint256 initialBalance = address(this).balance;
		
		// Generate pair for AMT -> WBNB
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = _quickSwapV2Router.WETH();

		// Swap
		_quickSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp + 360);
		
		// Return the amount received
		return address(this).balance - initialBalance;
	}


	function swapBNBForTokens(uint256 bnbAmount, address to) internal returns(bool) { 
		// Generate pair for WBNB -> AMT
		address[] memory path = new address[](2);
		path[0] = _quickSwapV2Router.WETH();
		path[1] = address(this);


		// Swap and send the tokens to the 'to' address
		try _quickSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: bnbAmount }(0, path, to, block.timestamp + 360) { 
			return true;
		} 
		catch { 
			return false;
		}
	}

	// Returns true if the transfer between the two given addresses should be limited by the transaction limit and false otherwise
	function isSellTransferLimited(address sender, address recipient) private view returns(bool) {
		bool isSelling = isQuickSwapPair(recipient);
		return isSelling && isMarketTransfer(sender, recipient);
	}


	function isSwapTransfer(address sender, address recipient) private view returns(bool) {
		bool isContractSelling = sender == address(this) && isQuickSwapPair(recipient);
		return isContractSelling;
	}


	// Function that is used to determine whether a transfer occurred due to a user buying/selling/transfering and not due to the contract swapping tokens
	function isMarketTransfer(address sender, address recipient) internal virtual view returns(bool) {
		return !isSwapTransfer(sender, recipient);
	}


	// Returns how many more $AMT tokens are needed in the contract before triggering a swap
	function amountUntilSwap() public view returns (uint256) {
		uint256 balance = balanceOf(address(this));
		if (balance > _tokenSwapThreshold) {
			// Swap on next relevant transaction
			return 0;
		}

		return _tokenSwapThreshold - balance;
	}


	function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool) {
		doApprove(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
		return true;
	}


	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual override returns (bool) {
		doApprove(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
		return true;
	}


	function setQuickSwapRouter(address routerAddress) public onlyOwner {
		require(routerAddress != address(0), "Cannot use the zero address as router address");

		_quickSwapRouterAddress = routerAddress; 
		_quickSwapV2Router = IUniswapV2Router02(_quickSwapRouterAddress);
		_quickSwapV2Pair = IUniswapV2Factory(_quickSwapV2Router.factory()).createPair(address(this), _quickSwapV2Router.WETH());

		onQuickSwapRouterUpdated();
	}


	function onQuickSwapRouterUpdated() internal virtual { }


	function isQuickSwapPair(address addr) internal view returns(bool) {
		return _quickSwapV2Pair == addr;
	}


	// This function can also be used in case the fees of the contract need to be adjusted later on as the volume grows
	function setFees(uint8 marketingFee, uint8 devFee, uint8 charityFee) public onlyOwner {
		_marketingFee = marketingFee;
		_devFee = devFee;
        _charityFee = charityFee;
		
		// Enforce invariant
		_poolFee = _marketingFee + _devFee + _charityFee;
	}

	function setTransactionSellLimit(uint256 limit) public onlyOwner {
		_transactionSellLimit = limit;
	}

		
	function transactionSellLimit() public view returns (uint256) {
		return _transactionSellLimit;
	}


	function setTransactionBuyLimit(uint256 limit) public onlyOwner {
		_transactionBuyLimit = limit;
	}

		
	function transactionBuyLimit() public view returns (uint256) {
		return _transactionBuyLimit;
	}

	
	function setHoldLimit(uint256 limit) public onlyOwner {
		_maxHoldAmount = limit;
	}

		
	function holdLimit() public view returns (uint256) {
		return _maxHoldAmount;
	}

	function setTokenSwapThreshold(uint256 threshold) public onlyOwner {
		require(threshold > 0, "Threshold must be greater than 0");
		_tokenSwapThreshold = threshold;
	}


	function tokenSwapThreshold() public view returns (uint256) {
		return _tokenSwapThreshold;
	}

	function allowance(address user, address spender) public view override returns (uint256) {
		return _allowances[user][spender];
	}


	function quickSwapRouterAddress() public view returns (address) {
		return _quickSwapRouterAddress;
	}


	function quickSwapPairAddress() public view returns (address) {
		return _quickSwapV2Pair;
	}

	function marketingWallet() public view returns (address) {
		return _marketingWallet;
	}


	function setMarketingWallet(address marketingWalletAddress) public onlyOwner {
		_marketingWallet = marketingWalletAddress;
	}


	function devWallet() public view returns (address) {
		return _devWallet;
	}


	function setDevWallet(address devWalletAddress) public onlyOwner {
		_devWallet = devWalletAddress;
	}

  function charityWallet() public view returns (address) {
		return _charityWallet;
	}


	function setCharityWallet(address charityWalletAddress) public onlyOwner {
		_charityWallet = charityWalletAddress;
	}


	function totalFeesPooled() public view returns (uint256) {
		return _totalFeesPooled;
	}


	function isSwapEnabled() public view returns (bool) {
		return _isSwapEnabled;
	}


	function setSwapEnabled(bool isEnabled) public onlyOwner {
		_isSwapEnabled = isEnabled;
	}


	function isFeeEnabled() public view returns (bool) {
		return _isFeeEnabled;
	}


	function setFeeEnabled(bool isEnabled) public onlyOwner {
		_isFeeEnabled = isEnabled;
	}

	function isTokenHoldEnabled() public view returns (bool) {
		return _isTokenHoldEnabled;
	}


	function setTokenHoldEnabled(bool isEnabled) public onlyOwner {
		_isTokenHoldEnabled = isEnabled;
	}


	function isExcludedFromFees(address addr) public view returns(bool) {
		return _addressesExcludedFromFees[addr];
	}


	function setExcludedFromFees(address addr, bool value) public onlyOwner {
		_addressesExcludedFromFees[addr] = value;
	}

	function isExcludedFromHold(address addr) public view returns(bool) {
		return _addressesExcludedFromHold[addr];
	}


	function setExcludedFromHold(address addr, bool value) public onlyOwner {
		_addressesExcludedFromHold[addr] = value;
	}


	function activateBuying(bool isEnabled) public onlyOwner {
		_isBuyingAllowed = isEnabled;
	}

	// Ensures that the contract is able to receive BNB
	receive() external payable {}
}

// Implements rewards & burns
contract AMT is AMTBase {

	//anti-bot
	uint256 public antiBlockNum = 3;
	bool public antiEnabled;
	uint256 private antiBotTimestamp;

	constructor (address routerAddress) AMTBase(routerAddress) {
	}


	// This function is used to enable all functions of the contract, after the setup of the token sale (e.g. Liquidity) is completed
	function onActivated() internal override {
		super.onActivated();
		updateAntiBotStatus(true);
	}

	function onBeforeTransfer(address sender, address recipient, uint256 amount) internal override {
        super.onBeforeTransfer(sender, recipient, amount);

		if (!isMarketTransfer(sender, recipient)) {
			return;
		}

		bool isSelling = isQuickSwapPair(recipient);
		if (!isSelling) {
			// Wait for a dip, stellar diamond hands
			return;
		}
    }


	function onTransfer(address sender, address recipient, uint256 amount) internal override {
        super.onTransfer(sender, recipient, amount);

		if (!isMarketTransfer(sender, recipient)) {
			return;
		}
    }

	function isMarketTransfer(address sender, address recipient) internal override view returns(bool) {
		// Not a market transfer when we are burning or sending out rewards
		return super.isMarketTransfer(sender, recipient);
	}

	function isContract(address account) public view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
	}

	function setAntiBotEnabled(bool _isEnabled) public onlyOwner {
		updateAntiBotStatus(_isEnabled);
	}


	function updateAntiBotStatus(bool _flag) private {
		antiEnabled = _flag;
		antiBotTimestamp = block.timestamp + antiBlockNum;
	}


	function updateBlockNum(uint256 _blockNum) public onlyOwner {
		antiBlockNum = _blockNum;
	}

	
	function onBeforeCalculateFeeRate() internal override view returns (bool) {
		if (antiEnabled && block.timestamp < antiBotTimestamp) {
			return true;
		}
	    return super.onBeforeCalculateFeeRate();
	}
}