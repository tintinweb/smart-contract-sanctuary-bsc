// SPDX-License-Identifier: MIT



pragma solidity ^0.6.2;

import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./DividendPayingToken.sol";

contract BABYWOOLF is ERC20, Ownable {
    using SafeMath for uint;

    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool private swapping;

    BABYWOOLFDividendTracker public dividendTracker;

    address public liquidityWallet;
    address public marketingWallet;
    address public appWallet;
    address public metaverseWallet;

    uint public maxSellTransactionAmount = 10; // 10% of total supply
    uint public swapTokensAtAmount = 200000 * (10**18);

    uint public immutable BNBRewardsFee;
    uint public immutable liquidityFee;
    uint public immutable totalFees;

    uint public vaultBalance;

    // use by default 300,000 gas to process auto-claiming dividends
    uint public gasForProcessing = 300000;

    mapping (address => uint) public nextAvailableClaimDate;
    uint public rewardCycleBlock = 30 days;


    // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;

    mapping (address => bool) public bot;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint indexed newValue, uint indexed oldValue);

    event ClaimBNBSuccessfully(address user, uint reward, uint nextClaimTime);

    event SwapAndLiquify(
        uint tokensSwapped,
        uint ethReceived,
        uint tokensIntoLiqudity
    );

    event SendDividends(
        uint tokensSwapped,
        uint amount
    );

    event ProcessedDividendTracker(
        uint iterations,
        uint claims,
        uint lastProcessedIndex,
        bool indexed automatic,
        uint gas,
        address indexed processor
    );

    uint8 _status = 1;

    modifier nonReentrant() {
        require(_status != 2, "ReentrancyGuard: reentrant call");

        _status = 2;
        _;
        _status = 1;
    }

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }

    constructor() public ERC20("BABYWOOLF", "BABYWOOLF") {
        uint _BNBRewardsFee = 7;
        uint _liquidityFee = 3;

        BNBRewardsFee = _BNBRewardsFee;
        liquidityFee = _liquidityFee;
        totalFees = _BNBRewardsFee.add(_liquidityFee);


        dividendTracker = new BABYWOOLFDividendTracker();

        liquidityWallet = owner();

        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
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
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));

        // exclude from paying fees or having max transaction amount
        excludeFromFees(liquidityWallet, true);
        excludeFromFees(address(this), true);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 420 * (10**15) * (10**18));
    }

    receive() external payable {

    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "BABYWOOLF: The dividend tracker already has that address");

        BABYWOOLFDividendTracker newDividendTracker = BABYWOOLFDividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "BABYWOOLF: The new dividend tracker must be owned by the BABYWOOLF token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "BABYWOOLF: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "BABYWOOLF: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "BABYWOOLF: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "BABYWOOLF: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateRewardWallets(address _marketingWallet, address _metaverseWallet, address _appWallet) external onlyOwner {
        marketingWallet = _marketingWallet;
        metaverseWallet = _metaverseWallet;
        appWallet = _appWallet;
    }

    function setBot(address _bot, bool _isbot) external onlyOwner {
        require (bot[_bot] != _isbot, "BABYWOOLF: This will change nothing.");

        bot[_bot] = _isbot;
    }

    function updateLiquidityWallet(address newLiquidityWallet) public onlyOwner {
        require(newLiquidityWallet != liquidityWallet, "BABYWOOLF: The liquidity wallet is already this address");
        excludeFromFees(newLiquidityWallet, true);
        emit LiquidityWalletUpdated(newLiquidityWallet, liquidityWallet);
        liquidityWallet = newLiquidityWallet;
    }

    function updateGasForProcessing(uint newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "BABYWOOLF: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "BABYWOOLF: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account) public view returns(uint) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account) public view returns (uint) {
        return dividendTracker.balanceOf(account);
    }

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint,
            uint,
            uint,
            uint,
            uint) {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint index)
        external view returns (
            address,
            int256,
            int256,
            uint,
            uint,
            uint,
            uint,
            uint) {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint gas) external {
        (uint iterations, uint claims, uint lastProcessedIndex) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
        dividendTracker.processAccount(msg.sender, false);
    }

    function getLastProcessedIndex() external view returns(uint) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function _transfer(
        address from,
        address to,
        uint amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!bot[from] && !bot[to], "Bot address detected!");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if( 
            !swapping &&
            automatedMarketMakerPairs[to] && // sells only by detecting transfer to automated market maker pair
            from != address(uniswapV2Router) && //router -> pair is removing liquidity which shouldn't have max
            !_isExcludedFromFees[to] //no max for those excluded from fees
        ) {
            require(amount <= totalSupply().mul(maxSellTransactionAmount).div(100), "Sell transfer amount exceeds the maxSellTransactionAmount.");
        }

        uint contractTokenBalance = balanceOf(address(this));
        
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        // selling: token-->pair-->eth
        if(
            canSwap &&
            !swapping &&
            automatedMarketMakerPairs[to] &&
            from != liquidityWallet &&
            to != liquidityWallet
        ) {
            swapping = true;

            uint swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
            swapAndLiquify(swapTokens);

            uint sellTokens = balanceOf(address(this));
            swapAndSendDividends(sellTokens, true);

            swapping = false;
        }

        // buying: eth-->pair-->token
        if(
            canSwap &&
            !swapping &&
            automatedMarketMakerPairs[from] &&
            from != liquidityWallet &&
            to != liquidityWallet
        ) {
            swapping = true;

            uint swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
            swapAndLiquify(swapTokens);

            uint sellTokens = balanceOf(address(this));
            swapAndSendDividends(sellTokens, false);

            swapping = false;
        }


        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            uint fees = amount.mul(totalFees).div(100);

            amount = amount.sub(fees);

            super._transfer(from, address(this), fees);

            nextAvailableClaimDate[from] = block.timestamp + rewardCycleBlock;
            nextAvailableClaimDate[to] = block.timestamp + rewardCycleBlock;
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
            uint gas = gasForProcessing;

            try dividendTracker.process(gas) returns (uint iterations, uint claims, uint lastProcessedIndex) {
                emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
            } 
            catch {

            }
        }
    }

    function swapAndLiquify(uint tokens) private {
        // split the contract balance into halves
        uint half = tokens.div(2);
        uint otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint tokenAmount) private {

        
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

    function addLiquidity(uint tokenAmount, uint ethAmount) private {
        
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityWallet,
            block.timestamp
        );
        
    }

    function swapAndSendDividends(uint tokens, bool isSelling) private {
        uint initialEth = address(this).balance;
        swapTokensForEth(tokens);
        uint newEth = address(this).balance.sub(initialEth);

        uint portion2_7 = newEth.mul(2).div(7);

        if (newEth > 0) {
            if (isSelling) {
                payable(metaverseWallet).transfer(portion2_7);
            } else {
                payable(marketingWallet).transfer(portion2_7);
            }
            vaultBalance.add(portion2_7);
            payable(appWallet).transfer(newEth.sub(portion2_7 * 3));
        }

        (bool success,) = address(dividendTracker).call{value: portion2_7}("");

        if(success) {
            emit SendDividends(tokens, portion2_7);
        }
    }

    function calculateBNBReward(address ofAddress)
        public
        view
        returns (uint)
    {
        uint tSupply = totalSupply()
        .sub(balanceOf(address(0)))
        .sub(balanceOf(0x000000000000000000000000000000000000dEaD)) // exclude burned wallet
        .sub(balanceOf(uniswapV2Pair));
        // exclude liquidity wallet

        return
            getBNBReward(
                balanceOf(address(ofAddress)),
                vaultBalance,
                tSupply
            );
    }

    function getBNBReward(
        uint currentBalance,
        uint currentBNBPool,
        uint tSupply
    ) private pure returns (uint) {
        uint bnbPool = currentBNBPool;

        // calculate reward to send

        uint multiplier = 100;

        // now calculate reward
        uint reward = bnbPool
        .mul(multiplier)
        .mul(currentBalance)
        .div(100)
        .div(tSupply);

        return reward;
    }

    function claimBNBReward() public isHuman nonReentrant {
        require(
            nextAvailableClaimDate[msg.sender] <= block.timestamp,
            "Error: next available not reached"
        );
        require(
            balanceOf(msg.sender) >= 0,
            "Error: must own BABYWOOLF to claim reward"
        );

        uint reward = calculateBNBReward(msg.sender);

        // update rewardCycleBlock
        nextAvailableClaimDate[msg.sender] =
            block.timestamp +
            rewardCycleBlock;

        emit ClaimBNBSuccessfully(
            msg.sender,
            reward,
            nextAvailableClaimDate[msg.sender]
        );

        (bool sent, ) = address(msg.sender).call{value: reward}("");
        require(sent, "Error: Cannot withdraw reward");
    }
}

contract BABYWOOLFDividendTracker is DividendPayingToken, Ownable {
    using SafeMath for uint;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint) public lastClaimTimes;

    uint public claimWait;
    uint public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint indexed newValue, uint indexed oldValue);

    event Claim(address indexed account, uint amount, bool indexed automatic);

    constructor() public DividendPayingToken("BABYWOOLF_Dividend_Tracker", "BABYWOOLF_Dividend_Tracker") {
        claimWait = 3600;
        // minimumTokenBalanceForDividends = 10000 * (10**18); //must hold 10000+ tokens
        minimumTokenBalanceForDividends = 0;
    }

    function _transfer(address, address, uint) internal override {
        require(false, "BABYWOOLF_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public override {
        require(false, "BABYWOOLF_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main BABYWOOLF contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "BABYWOOLF_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "BABYWOOLF_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns(uint) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint) {
        return tokenHoldersMap.keys.length;
    }



    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint withdrawableDividends,
            uint totalDividends,
            uint lastClaimTime,
            uint nextClaimTime,
            uint secondsUntilAutoClaimAvailable) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
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

    function getAccountAtIndex(uint index)
        public view returns (
            address,
            int256,
            int256,
            uint,
            uint,
            uint,
            uint,
            uint) {
        if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint lastClaimTime) private view returns (bool) {
        if(lastClaimTime > block.timestamp)  {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint newBalance) external onlyOwner {
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

    function process(uint gas) public returns (uint, uint, uint) {
        uint numberOfTokenHolders = tokenHoldersMap.keys.length;

        if(numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint _lastProcessedIndex = lastProcessedIndex;

        uint gasUsed = 0;

        uint gasLeft = gasleft();

        uint iterations = 0;
        uint claims = 0;

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

            uint newGasLeft = gasleft();

            if(gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint amount = _withdrawDividendOfUser(account);

        if(amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }

        return false;
    }
}