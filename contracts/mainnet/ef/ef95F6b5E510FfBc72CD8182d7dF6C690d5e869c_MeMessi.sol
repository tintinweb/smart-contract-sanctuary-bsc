// SPDX-License-Identifier: MIT

// MeMessi Token
// $MEMESSI = $BUSD dividends


pragma solidity ^0.6.2;

import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./DividendPayingToken.sol";

contract MeMessi is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    bool private swapping;
    MeMessiDividendTracker public dividendTracker;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public immutable BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // BUSD
    uint256 public swapTokensAtAmount = 50000000 * (10**18);
    bool private _lock;
    bool public swapEnabled = true;
    mapping(address => bool) public _isBlacklisted;


    uint256 public BUSDRewardsFee = 3;
    uint256 public liquidityFee = 1;
    uint256 public buyBackStableFee = 1;
    uint256 public BuyBackFee = 1;
    uint256 public totalFees = BUSDRewardsFee.add(liquidityFee).add(buyBackStableFee).add(BuyBackFee);
    uint256 public _buy_BUSDRewardsFee = 3;
    uint256 public _buy_liquidityFee = 1;
    uint256 public _buy_buyBackStableFee = 1;
    uint256 public _buy_BuyBackFee = 1;
    uint256 public _buy_totalFees = _buy_BUSDRewardsFee.add(_buy_liquidityFee).add(_buy_buyBackStableFee).add(_buy_BuyBackFee);
    uint256 public _sell_BUSDRewardsFee = 5;
    uint256 public _sell_liquidityFee = 1;
    uint256 public _sell_buyBackStableFee = 1;
    uint256 public _sell_BuyBackFee = 3;
    uint256 public _sell_totalFees = _sell_BUSDRewardsFee.add(_sell_liquidityFee).add(_sell_buyBackStableFee).add(_sell_BuyBackFee);
    uint256 public average_BUSDRewardsFee = BUSDRewardsFee.add(_buy_BUSDRewardsFee).add(_sell_BUSDRewardsFee);
    uint256 public average_liquidityFee = liquidityFee.add(_buy_liquidityFee).add(_sell_liquidityFee);
    uint256 public average_buyBackStableFee = buyBackStableFee.add(_buy_buyBackStableFee).add(_sell_buyBackStableFee);
    uint256 public average_BuyBackFee = BuyBackFee.add(_buy_BuyBackFee).add(_sell_BuyBackFee);
    uint256 public average_totalFees = average_BUSDRewardsFee.add(average_liquidityFee).add(average_buyBackStableFee).add(average_BuyBackFee);

    struct AddressFee {
        bool enable;

        uint256 totalFees;

        uint256 _buy_totalFees;

        uint256 _sell_totalFees;
    }
    mapping (address => AddressFee) public _addressFees;

    address public _buyBackStableWalletAddress = 0xEB58ce8B4BBd95530bfC6A8d20EDF52AE9F2BC97;
    address payable public _BuyBackWalletAddress = payable(0xEB58ce8B4BBd95530bfC6A8d20EDF52AE9F2BC97);

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    mapping (address => bool) private _isExcludedFromFees;

    mapping (address => bool) public automatedMarketMakerPairs;


    bool public autoDividend=true;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
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

    modifier ContractLock() {
        require(_lock == false, "Transaction Blocked");
        _;
    }

    constructor() public ERC20("MeMessi Token", "MEMESSI") {

    	dividendTracker = new MeMessiDividendTracker();

    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        //excludeFromFees(_buyBackStableWalletAddress, true);
        //excludeFromFees(_BuyBackWalletAddress, true);
        excludeFromFees(address(this), true);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 10000000000 * (10**18));
    }

    receive() external payable {

  	}

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "MeMessi: The dividend tracker already has that address");

        MeMessiDividendTracker newDividendTracker = MeMessiDividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "MeMessi: The new dividend tracker must be owned by the MeMessi token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(deadWallet);
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "MeMessi: The router already has that address.");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "MeMessi: Account is already the value of 'excluded'.");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setAutoDividend(bool _state) external onlyOwner{
        autoDividend = _state;
    }

    function setSwapTokensAtAmount(uint256 amount) external onlyOwner{
        swapTokensAtAmount = amount;
    }

    function setbuyBackStableWallet(address payable wallet) external onlyOwner{
        _buyBackStableWalletAddress = wallet;
    }

    function setBuyBackWallet(address wallet) external onlyOwner{
        _BuyBackWalletAddress = payable(wallet);
    }

    function updateAverageFee() internal{
        average_BUSDRewardsFee = BUSDRewardsFee.add(_buy_BUSDRewardsFee).add(_sell_BUSDRewardsFee);
        average_liquidityFee = liquidityFee.add(_buy_liquidityFee).add(_sell_liquidityFee);
        average_buyBackStableFee = buyBackStableFee.add(_buy_buyBackStableFee).add(_sell_buyBackStableFee);
        average_BuyBackFee = BuyBackFee.add(_buy_BuyBackFee).add(_sell_BuyBackFee);
        average_totalFees = average_BUSDRewardsFee.add(average_liquidityFee).add(average_buyBackStableFee).add(average_BuyBackFee);
    }

    function setBUSDRewardsFee(uint256 value) external onlyOwner{
        BUSDRewardsFee = value;
        totalFees = BUSDRewardsFee.add(liquidityFee).add(buyBackStableFee).add(BuyBackFee);
        updateAverageFee();
    }

    function setLiquiditFee(uint256 value) external onlyOwner{
        liquidityFee = value;
        totalFees = BUSDRewardsFee.add(liquidityFee).add(buyBackStableFee).add(BuyBackFee);
        updateAverageFee();
    }

    function setbuyBackStableFee(uint256 value) external onlyOwner{
        buyBackStableFee = value;
        totalFees = BUSDRewardsFee.add(liquidityFee).add(buyBackStableFee).add(BuyBackFee);
        updateAverageFee();
    }
    function setBuyBackFee(uint256 value) external onlyOwner{
        BuyBackFee = value;
        totalFees = BUSDRewardsFee.add(liquidityFee).add(buyBackStableFee).add(BuyBackFee);
        updateAverageFee();
    }

    function setBuyFee(uint256 buy_BUSDRewardsFee, uint256 buy_liquidityFee, uint256 buy_buyBackStableFee, uint256 buy_BuyBackFee) external onlyOwner {
        _buy_BUSDRewardsFee  = buy_BUSDRewardsFee ;
        _buy_liquidityFee = buy_liquidityFee;
        _buy_buyBackStableFee = buy_buyBackStableFee;
        _buy_BuyBackFee = buy_BuyBackFee;
        _buy_totalFees = _buy_BUSDRewardsFee.add(_buy_liquidityFee).add(_buy_buyBackStableFee).add(_buy_BuyBackFee);
        updateAverageFee();
    }

    function setSellFee(uint256 sell_BUSDRewardsFee, uint256 sell_liquidityFee, uint256 sell_buyBackStableFee, uint256 sell_BuyBackFee) external onlyOwner {
        _sell_BUSDRewardsFee  = sell_BUSDRewardsFee ;
        _sell_liquidityFee = sell_liquidityFee;
        _sell_buyBackStableFee = sell_buyBackStableFee;
        _sell_BuyBackFee = sell_BuyBackFee;
        _sell_totalFees = _sell_BUSDRewardsFee.add(_sell_liquidityFee).add(_sell_buyBackStableFee).add(_sell_BuyBackFee);
        updateAverageFee();
    }


    function setAddressFee(address _address, bool _enable, uint256 _BUSDRewardsFee, uint256 _liquidityFee, uint256 _buyBackStableFee, uint256 _BuyBackFee) external onlyOwner {
        _addressFees[_address].enable = _enable;

        _addressFees[_address].totalFees = _BUSDRewardsFee.add(_liquidityFee).add(_buyBackStableFee).add(_BuyBackFee);

    }

    function setBuyAddressFee(address _address, bool _enable, uint256 _BUSDRewardsFee, uint256 _liquidityFee, uint256 _buyBackStableFee, uint256 _BuyBackFee) external onlyOwner {
        _addressFees[_address].enable = _enable;

        _addressFees[_address]._buy_totalFees = _BUSDRewardsFee.add(_liquidityFee).add(_buyBackStableFee).add(_BuyBackFee);

    }

    function setSellAddressFee(address _address, bool _enable, uint256 _BUSDRewardsFee, uint256 _liquidityFee, uint256 _buyBackStableFee, uint256 _BuyBackFee) external onlyOwner {
        _addressFees[_address].enable = _enable;

        _addressFees[_address]._sell_totalFees = _BUSDRewardsFee.add(_liquidityFee).add(_buyBackStableFee).add(_BuyBackFee);

    }


    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "MeMessi: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function blacklistAddress(address account, bool value) external onlyOwner{
        _isBlacklisted[account] = value;
    }

    function lockContract() external onlyOwner {
        _lock = true;
    }

    function unlockContract() external onlyOwner {
        _lock = false;
    }

    function enableDisableSwap(bool value) external onlyOwner {
        swapEnabled = value;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "MeMessi: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "MeMessi: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "MeMessi: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function swapManual(bool sendToBuyBackStable, bool sendToBuyBack, bool liquify, bool sendDividends) external onlyOwner {
        swapping = true;

        uint256 contractTokenBalance = balanceOf(address(this));

        if (sendToBuyBackStable) {
            uint256 buyBackStableTokens = contractTokenBalance.mul(average_buyBackStableFee).div(average_totalFees);
            swapAndsendToBuyBackStable(buyBackStableTokens);
        }

        if (sendToBuyBack) {
            uint256 BuyBackTokens = contractTokenBalance.mul(average_BuyBackFee).div(average_totalFees);
            swapAndSendToBuyBack(BuyBackTokens);
        }

        if (liquify) {
            uint256 swapTokens = contractTokenBalance.mul(average_liquidityFee).div(average_totalFees);
            swapAndLiquify(swapTokens);
        }

        if (sendDividends) {
            uint256 sellTokens = balanceOf(address(this));
            swapAndSendDividends(sellTokens);
        }

        swapping = false;
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

    function claimAddress(address claimee) external onlyOwner {
		dividendTracker.processAccount(payable(claimee), false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
    	dividendTracker.setLastProcessedIndex(index);
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function Sweep() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function transferForeignToken(address _token, address _to) public onlyOwner returns(bool _sent){
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override ContractLock {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner() &&
            swapEnabled
        ) {
            swapping = true;

            uint256 buyBackStableTokens = contractTokenBalance.mul(average_buyBackStableFee).div(average_totalFees);
            swapAndsendToBuyBackStable(buyBackStableTokens);

            uint256 BuyBackTokens = contractTokenBalance.mul(average_BuyBackFee).div(average_totalFees);
            swapAndSendToBuyBack(BuyBackTokens);

            uint256 swapTokens = contractTokenBalance.mul(average_liquidityFee).div(average_totalFees);
            swapAndLiquify(swapTokens);

            uint256 sellTokens = balanceOf(address(this));
            swapAndSendDividends(sellTokens);

            swapping = false;
        }

        bool takeFee = !swapping;

        uint256 context_totalFees=totalFees;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        else{
            // Buy
            if(from == uniswapV2Pair){
                context_totalFees = _buy_totalFees;
            }
            // Sell
            if(to == uniswapV2Pair){
                context_totalFees = _sell_totalFees;
            }


            // If send account has a special fee
            if(_addressFees[from].enable){
                context_totalFees = _addressFees[from].totalFees;

                // Sell
                if(to == uniswapV2Pair){
                    context_totalFees = _addressFees[from]._sell_totalFees;
                }
            }
            else{
                // If buy account has a special fee
                if(_addressFees[to].enable){
                    //buy
                    if(from == uniswapV2Pair){
                        context_totalFees = _addressFees[to]._buy_totalFees;
                    }
                }
            }

        }

        if(takeFee) {
        	//uint256 fees = amount.mul(totalFees).div(100);
        	uint256 fees = amount.mul(context_totalFees).div(100);
        	if(automatedMarketMakerPairs[to]){
        	    fees += amount.mul(1).div(100);
        	}
        	amount = amount.sub(fees);

            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping && autoDividend) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {

	    	}
        }
    }

    function swapAndsendToBuyBackStable(uint256 tokens) private  {
        uint256 initialBUSDBalance = IERC20(BUSD).balanceOf(address(this));

        swapTokensForBUSD(tokens);
        uint256 newBalance = (IERC20(BUSD).balanceOf(address(this))).sub(initialBUSDBalance);
        IERC20(BUSD).transfer(_buyBackStableWalletAddress, newBalance);
    }

    function swapAndSendToBuyBack(uint256 tokens) private  {
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokens);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        transferToAddressETH(_BuyBackWalletAddress, newBalance);
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
        uint256 newBalance = address(this).balance.sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForBUSD(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = BUSD;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function swapAndSendDividends(uint256 tokens) private{
        swapTokensForBUSD(tokens);
        uint256 dividends = IERC20(BUSD).balanceOf(address(this));
        bool success = IERC20(BUSD).transfer(address(dividendTracker), dividends);
        if (success) {
            dividendTracker.distributeBUSDDividends(dividends);
            emit SendDividends(tokens, dividends);
        }
    }
}

contract MeMessiDividendTracker is Ownable, DividendPayingToken {
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

    constructor() public DividendPayingToken("MeMessi_Dividen_Tracker", "MeMessi_Dividend_Tracker") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 200000 * (10**18); //must hold 200000+ tokens
    }

    function _transfer(address, address, uint256) internal override {
        require(false, "MeMessi_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public override {
        require(false, "MeMessi_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main MeMessi contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 1 && newClaimWait <= 604800, "MeMessi_Dividend_Tracker: claimWait must be updated to between 1 second and 7 days");
        require(newClaimWait != claimWait, "MeMessi_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
    	lastProcessedIndex = index;
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
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
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;


                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }


        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
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