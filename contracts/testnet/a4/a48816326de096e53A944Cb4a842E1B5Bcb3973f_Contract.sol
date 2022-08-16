// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Contract is Ownable, IERC20, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 private _tTotal;

    address public walletLiquidity;
    address public walletTokens;
    address payable public walletMarketing;

    // Fees - Set fees before opening trade
    uint8 public feeBuyBurn = 2;
    uint8 public feeBuyLiquidity = 0;
    uint8 public feeBuyMarketing = 3;
    uint8 public feeBuyReflection = 0;
    uint8 public feeBuyTokens = 0;

    uint8 public feeSellBurn = 2;
    uint8 public feeSellLiquidity = 0;
    uint8 public feeSellMarketing = 3;
    uint8 public feeSellReflection = 0;
    uint8 public feeSellTokens = 0;

    // Wallet and transaction limits
    uint256 public maxHold;
    uint256 public maxTran;

    // Upper and lower limits for fee processing triggers
    uint256 private _swapMax;
    uint256 private _swapMin;

    // Total fees that are processed on buys and sells for swap and liquify calculations
    uint256 private _swapFeeTotalBuy = 0;
    uint256 private _swapFeeTotalSell = 0;

    // Supply Tracking for RFI
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    uint256 private constant MAX = ~uint256(0);

    // Set factory
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    constructor(string memory __name, string memory __symbol) {
        // Set basic token details
        _name = __name;
        _symbol = __symbol;
        _decimals = 0;
        _tTotal = 1000000000000000 * 10**_decimals;
        _rTotal = (MAX - (MAX % _tTotal));

        // Wallet limits - Set limits after deploying
        maxHold = _tTotal;
        maxTran = _tTotal;

        // Contract sell limits when processing fees
        _swapMin = 1000;
        // 1000 tokens
        _swapMax = _tTotal / 200;
        // 0.5% of total supply

        // Set marketing and liquidity collection wallets (can be updated later)
        walletMarketing = payable(msg.sender);
        walletTokens = walletMarketing;

        address _owner = owner();
        // Transfer token supply to owner wallet
        _rOwned[_owner] = _rTotal;

        // Set PancakeSwap Router Address
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1 //bsc testnet
            //0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        // Create initial liquidity pair with BNB on PancakeSwap factory
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        // Wallet that are excluded from holding limits
        _isLimitExempt[_owner] = true;
        _isLimitExempt[address(this)] = true;
        _isLimitExempt[WALLET_BURN] = true;
        _isLimitExempt[uniswapV2Pair] = true;
        _isLimitExempt[walletTokens] = true;

        // Wallets that are excluded from fees
        _isExcludedFromFee[_owner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[WALLET_BURN] = true;

        // Set the initial liquidity pair
        _isPair[uniswapV2Pair] = true;

        // Exclude from Rewards
        _isExcluded[WALLET_BURN] = true;
        _isExcluded[uniswapV2Pair] = true;
        _isExcluded[address(this)] = true;

        // Push excluded wallets to array
        _excluded.push(WALLET_BURN);
        _excluded.push(uniswapV2Pair);
        _excluded.push(address(this));

        // Wallets granted access before trade is open
        _preLaunchAccess[_owner] = true;

        // Emit Supply Transfer to Owner
        emit Transfer(address(0), _owner, _tTotal);

        // Emit ownership transfer
        emit OwnershipTransferred(address(0), _owner);
    }

    // Events
    event UpdatedMappingPreLaunchAccess(
        address walletAddress,
        bool preLaunchAccess
    );
    event UpdatedMappingIsLimitExempt(address walletAddress, bool limitExempt);
    event UpdatedMappingIsPair(address walletAddress, bool liquidityPair);
    event UpdatedMappingIsExcludedFromFee(
        address walletAddress,
        bool excludedFromFee
    );
    event UpdatedExcludeFromReward(address indexed walletAddress);
    event UpdatedIncludeInReward(address indexed walletAddress);
    event UpdatedWalletMarketing(
        address indexed oldWallet,
        address indexed newWallet
    );
    event UpdatedWalletLiquidity(
        address indexed oldWallet,
        address indexed newWallet
    );
    event UpdatedWalletTokens(
        address indexed oldWallet,
        address indexed newWallet
    );
    event UpdatedWalletLimits(uint256 maxTran, uint256 maxHold);
    event UpdatedBuyFees(uint256 liquidity, uint256 reflection, uint256 tokens);
    event UpdatedSellFees(
        uint256 liquidity,
        uint256 reflection,
        uint256 tokens
    );
    event UpdatedSwapTriggerCount(uint256 swapTriggerTransactionCount);
    event UpdatedSwapTriggerTokenLimits(
        uint256 swapTriggerMinTokens,
        uint256 swapTriggerMaxTokens
    );
    event UpdatedSwapAndLiquifyEnabled(bool swapAndLiquifyEnabled);
    event UpdatedTradeOpen(bool tradeOpen);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    // Address mappings
    mapping(address => uint256) private _tOwned; // Tokens Owned
    mapping(address => uint256) private _rOwned; // Reflected balance
    mapping(address => mapping(address => uint256)) private _allowances; // Allowance to spend another wallets tokens
    mapping(address => bool) public _isExcludedFromFee; // Wallets that do not pay fees
    mapping(address => bool) public _isExcluded; // Excluded from RFI rewards
    mapping(address => bool) public _preLaunchAccess; // Wallets that have access before trade is open
    mapping(address => bool) public _isLimitExempt; // Wallets that are excluded from HOLD and TRANSFER limits
    mapping(address => bool) public _isPair; // Address is liquidity pair
    address[] private _excluded; // Array of wallets excluded from rewards

    // Burn (dead) address
    address public constant WALLET_BURN =
        0x000000000000000000000000000000000000dEaD;

    // Swap triggers
    uint256 public swapTrigger = 11; // After 10 transactions with a fee swap will be triggered
    uint256 public swapCounter = 1; // Start at 1 not zero to save gas

    // SwapAndLiquify - Automatically processing fees and adding liquidity
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false; // Must be set to true post deploy!

    // Launch settings
    bool public tradeOpen = false;

    /*

    FEES

    */

    // Set Buy Fees
    function setupFeesOnBuy(
        uint8 liquidityOnBuy,
        uint8 reflectionOnBuy,
        uint8 tokensOnBuy
    ) external onlyOwner {
        // Buyer protection - max fee can not be set over 15%
        require(
            3 <= liquidityOnBuy && liquidityOnBuy <= 5,
            "Incorrect liquidity fee"
        );
        require(
            2 <= reflectionOnBuy && reflectionOnBuy <= 5,
            "Incorrect reflection fee"
        );
        require(
            feeBuyMarketing +
                liquidityOnBuy +
                reflectionOnBuy +
                feeBuyBurn +
                tokensOnBuy <=
                15,
            "Fees too high"
        );

        // Update fees
        feeBuyLiquidity = liquidityOnBuy;
        feeBuyReflection = reflectionOnBuy;
        feeBuyTokens = tokensOnBuy;

        // Fees that will need to be processed during swap and liquify
        _swapFeeTotalBuy = feeBuyMarketing + feeBuyLiquidity;

        emit UpdatedBuyFees(feeBuyLiquidity, feeBuyReflection, feeBuyTokens);
    }

    // Set Sell Fees
    function setupFeesOnSell(
        uint8 liquidityOnSell,
        uint8 reflectionOnSell,
        uint8 tokensOnSell
    ) external onlyOwner {
        // Buyer protection - max fee can not be set over 15%
        require(
            3 <= liquidityOnSell && liquidityOnSell <= 5,
            "Incorrect liquidity fee"
        );
        require(
            2 <= reflectionOnSell && reflectionOnSell <= 5,
            "Incorrect reflection fee"
        );
        require(
            feeSellMarketing +
                liquidityOnSell +
                reflectionOnSell +
                feeSellBurn +
                tokensOnSell <=
                15,
            "Fees too high"
        );

        // Update fees
        feeSellLiquidity = liquidityOnSell;
        feeSellReflection = reflectionOnSell;
        feeSellTokens = tokensOnSell;

        // Fees that will need to be processed during swap and liquify
        _swapFeeTotalSell = feeSellMarketing + feeSellLiquidity;

        emit UpdatedSellFees(
            feeSellLiquidity,
            feeSellReflection,
            feeSellTokens
        );
    }

    /*

    Wallet Limits

    Wallet limits are set as a number of tokens, not as a percent of supply!
    If you want to limit people to 2% of supply and your supply is 1,000,000 tokens then you
    will need to enter 20000 (as this is 2% of 1,000,000)

    Don't enter commas, only numbers!

    To protect buyers, this value can not be set to 0 Tokens.

    */

    // Wallet Holding and Transaction Limits (Enter token amount, excluding decimals)
    function setupWalletLimits(
        uint256 maxTokensPerTransaction,
        uint256 maxTotalTokensPerWallet
    ) external onlyOwner {
        // Buyer protection - Limits can not be set to zero
        require(maxTokensPerTransaction > 0, "Must be greater than 0");
        require(maxTotalTokensPerWallet > 0, "Must be greater than 0");

        maxTran = maxTokensPerTransaction * 10**_decimals;
        maxHold = maxTotalTokensPerWallet * 10**_decimals;

        emit UpdatedWalletLimits(maxTran, maxHold);
    }

    // Open trade - one way switch to protect buyers - trade can not be paused once opened
    function setupOpenTrade() external onlyOwner {
        tradeOpen = true;
        swapAndLiquifyEnabled = true;
        emit UpdatedTradeOpen(tradeOpen);
        emit UpdatedSwapAndLiquifyEnabled(swapAndLiquifyEnabled);

        _swapFeeTotalBuy = feeBuyLiquidity + feeBuyMarketing;
        _swapFeeTotalSell = feeSellLiquidity + feeSellMarketing;
    }

    /*

    Processing Fees Functions

    */

    // Default is True = Contract will process fees into Marketing and Liquidity automatically
    function processingSwapAndLiquifyEnabled(bool _swapAndLiquifyEnabled)
        external
        onlyOwner
    {
        swapAndLiquifyEnabled = _swapAndLiquifyEnabled;
        emit UpdatedSwapAndLiquifyEnabled(_swapAndLiquifyEnabled);
    }

    // Manually process fees - emit is triggered within swapAndLiquify function so not needed here
    function processingProcessNow(uint256 percentOfTokensToProcess)
        external
        onlyOwner
    {
        require(!inSwapAndLiquify, "Already in swap");
        if (percentOfTokensToProcess > 100) {
            percentOfTokensToProcess == 100;
        }
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = (tokensOnContract * percentOfTokensToProcess) /
            100;
        swapAndLiquify(sendTokens);
    }

    // Set the min and max limits for fee processing trigger
    function processingTokenLimits(
        uint256 minimumNumberOfTokensToProcess,
        uint256 maximumNumberOfTokensToProcess
    ) external onlyOwner {
        _swapMin = minimumNumberOfTokensToProcess;
        _swapMax = maximumNumberOfTokensToProcess;
        emit UpdatedSwapTriggerTokenLimits(_swapMin, _swapMax);
    }

    // Set the number of transactions before swap is triggered (default 10)
    function processingTriggerCount(
        uint256 numberOfTransactionsToTriggerProcessing
    ) external onlyOwner {
        // Add 1 to total as counter is reset to 1, not 0, to save gas
        swapTrigger = numberOfTransactionsToTriggerProcessing + 1;
        emit UpdatedSwapTriggerCount(swapTrigger);
    }

    // Remove random tokens from the contract - the emit happens during _transfer, therefore it is not required within this function
    function processingRemoveRandomTokens(
        address randomTokenAddress,
        uint256 percentOfTokens
    ) external onlyOwner returns (bool _sent) {
        // Can not purge the native token!
        require(
            randomTokenAddress != address(this),
            "Can not remove native token, must be processed via SwapAndLiquify"
        );

        // Get balance of random tokens and send to caller wallet
        uint256 totalRandom = IERC20(randomTokenAddress).balanceOf(
            address(this)
        );
        uint256 removeRandom = (totalRandom * percentOfTokens) / 100;
        _sent = IERC20(randomTokenAddress).transfer(msg.sender, removeRandom);
    }

    /*

    ERC20/BEP20 Compliance and Standard Functions

    */

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "Decreased allowance below zero"
            )
        );
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function tokenFromReflection(uint256 _rAmount)
        internal
        view
        returns (uint256)
    {
        require(
            _rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return _rAmount / currentRate;
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "Allowance exceeded")
        );
        return true;
    }

    /*

    Wallet Mappings

    */

    // Grants access when trade is closed - Default false (true for contract owner)
    function walletSettingsGrantPreLaunchAccess(
        address walletAddress,
        bool preLaunchAccess
    ) external onlyOwner {
        _preLaunchAccess[walletAddress] = preLaunchAccess;
        emit UpdatedMappingPreLaunchAccess(walletAddress, preLaunchAccess);
    }

    // Excludes wallet from transaction and holding limits - Default false
    function walletSettingsExemptFromLimits(
        address walletAddress,
        bool isLimitExempt
    ) external onlyOwner {
        _isLimitExempt[walletAddress] = isLimitExempt;
        emit UpdatedMappingIsLimitExempt(walletAddress, isLimitExempt);
    }

    // Identifies wallet as a liquidity pair - Default false
    function walletSettingsSetAsLiquidityPair(
        address walletAddress,
        bool isPair
    ) external onlyOwner {
        _isPair[walletAddress] = isPair;
        emit UpdatedMappingIsPair(walletAddress, isPair);
    }

    // Excludes wallet from fees - Default false
    function walletSettingsExcludeFromFees(
        address walletAddress,
        bool isExcludedFromFee
    ) external onlyOwner {
        _isExcludedFromFee[walletAddress] = isExcludedFromFee;
        emit UpdatedMappingIsExcludedFromFee(walletAddress, isExcludedFromFee);
    }

    /*

    The following functions are used to exclude or include a wallet in the reflection rewards.
    By default, all wallets are included.

    Wallets that are excluded:

            The Burn address (Do not include in rewards. See 'Blackhole' note below)
            The Liquidity Pair
            The Contract Address

    DoS 'OUT OF GAS' Error Warning

    A reflections contract needs to loop through all excluded wallets to correctly process several functions.
    This loop can break the contract if it runs out of gas before completion.
    To prevent this, keep the number of wallets that are excluded from rewards to an absolute minimum.
    In addition to the default excluded wallets, you will need to exclude the address of any locked tokens.

    DO NOT INCLUDE THE BURN WALLET IN REFLECTION REWARDS - The Blackhole

    Many developers add the burn wallet to the reflection rewards and call it a 'Blackhole'
    They assume that tokens being added to the burn wallet will increase the value of other tokens. This is not true.
    If the burn wallet is added to reflection rewards it only does one thing... it takes a share of the reflections!
    This reduces the amount of reflections that real holders get.

    By default, the burn wallet is already excluded from rewards, don't include it! The 'Blackhole' doesn't exist!
    Adding the burn wallet to reflection rewards will reduce the rewards for everybody else. Nothing more and nothing good.

    */

    // Exclude wallet from RFI - LOOP RISK OF OUT OF GAS! LIMIT TO ESSENTIAL WALLETS! (Contract, Liquidity Pair, Burn and Locked Wallets ONLY!)
    function walletSettingsReflectionsExclude(address account)
        external
        onlyOwner
    {
        require(!_isExcluded[account], "Account already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
        emit UpdatedExcludeFromReward(account);
    }

    // Include wallet in RFI
    function walletSettingsReflectionsInclude(address account)
        external
        onlyOwner
    {
        require(_isExcluded[account], "Account already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
        emit UpdatedIncludeInReward(account);
    }

    /*

    Update Wallets

    */

    // Update marketing wallet
    function updateWalletMarketing(address payable wallet) external onlyOwner {
        require(wallet != address(0), "Can not be zero address");
        emit UpdatedWalletMarketing(walletMarketing, wallet);
        walletMarketing = wallet;
    }

    // Update liquidity collection wallet
    function updateWalletLiquidity(address wallet) external onlyOwner {
        // To send the auto liquidity tokens directly to burn update to 0x000000000000000000000000000000000000dEaD
        emit UpdatedWalletLiquidity(walletLiquidity, wallet);
        walletLiquidity = wallet;
    }

    // Update Tokens wallet
    function updateWalletTokens(address wallet) external onlyOwner {
        require(wallet != address(0), "Can not be zero address");
        emit UpdatedWalletTokens(walletTokens, wallet);
        walletTokens = wallet;

        // Make limit exempt
        _isLimitExempt[walletTokens] = true;
    }

    // Main transfer checks and settings
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        // Allows owner to add liquidity safely, eliminating the risk of someone maliciously setting the price
        if (!tradeOpen) {
            require(
                _preLaunchAccess[from] || _preLaunchAccess[to],
                "Trade is not open"
            );
        }

        // Wallet Limit
        if (!_isLimitExempt[to] && from != owner()) {
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= maxHold, "Over wallet max");
        }

        /*

        PooCoin Trade button Warning

        PooCoin will do a simulation sell of approximately 0.01 BNB. If they can not buy and sell this amount they will disable your trade button.
        If you only add a small amount of BNB to your initial liquidity (1 BNB or less) and your max transaction is limited to 1% of total supply then
        this test will fail and you will not get a trade button on PooCoin. Be aware of this when doing tests on main net with low liquidity!

        Similarly, many honeypot checker tools do a test sell of 0.1 BNB if this test is not possible due to low liquidity or transaction limits
        your contract will flag as a honeypot.

        */

        // Transaction limit - To send over the transaction limit the sender AND the recipient must be limit exempt (or increase transaction limit)
        if (!_isLimitExempt[to] || !_isLimitExempt[from]) {
            require(amount <= maxTran, "Over transaction limit");
        }

        // Compliance and safety checks
        require(from != address(0) && to != address(0), "Can not be 0 address");
        require(amount > 0, "Transfer must be greater than 0");

        // Check number of transactions required to trigger fee processing - can only trigger on sells
        if (_isPair[to] && !inSwapAndLiquify && swapAndLiquifyEnabled) {
            // Check that enough transactions have passed since last swap
            if (swapCounter >= swapTrigger) {
                // Check number of tokens on contract
                uint256 contractTokens = balanceOf(address(this));

                // Only trigger fee processing if over min swap limit
                if (contractTokens >= _swapMin) {
                    // Limit number of tokens that can be swapped
                    if (contractTokens <= _swapMax) {
                        swapAndLiquify(contractTokens);
                    } else {
                        swapAndLiquify(_swapMax);
                    }
                }
            }
        }

        // Only charge a fee on buys and sells, no fee for wallet transfers
        bool takeFee = true;
        if (
            _isExcludedFromFee[from] ||
            _isExcludedFromFee[to] ||
            (!_isPair[to] && !_isPair[from])
        ) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    // Process fees
    function swapAndLiquify(uint256 tokens) private {
        /*

        Fees are processed as an average over all buys and sells

        */

        // Lock swapAndLiquify function
        inSwapAndLiquify = true;

        uint256 _feesTotal = (_swapFeeTotalBuy + _swapFeeTotalSell);
        uint256 LP_Tokens = (tokens * (feeBuyLiquidity + feeSellLiquidity)) /
            _feesTotal /
            2;
        uint256 swapTokens = tokens - LP_Tokens;

        // Swap tokens for BNB
        uint256 contractBNB = address(this).balance;
        swapTokensForBNB(swapTokens);
        uint256 returnedBNB = address(this).balance - contractBNB;

        // Double fees instead of halving LP fee to prevent rounding errors if fee is an odd number
        uint256 feeSplit = _feesTotal *
            2 -
            (feeBuyLiquidity + feeSellLiquidity);

        // Calculate the BNB values for each fee (excluding marketing)
        uint256 BNB_Liquidity = (returnedBNB *
            (feeBuyLiquidity + feeSellLiquidity)) / feeSplit;

        // Add liquidity
        if (LP_Tokens != 0) {
            addLiquidity(LP_Tokens, BNB_Liquidity);
            emit SwapAndLiquify(LP_Tokens, BNB_Liquidity, LP_Tokens);
        }

        // Send remaining BNB to marketing wallet
        contractBNB = address(this).balance;
        if (contractBNB > 0) {
            walletMarketing.transfer(contractBNB);
        }

        // Reset transaction counter (reset to 1 not 0 to save gas)
        swapCounter = 1;

        // Unlock swapAndLiquify function
        inSwapAndLiquify = false;
    }

    // Swap tokens for BNB
    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    // Add liquidity and send Cake LP tokens to liquidity collection wallet
    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            walletLiquidity,
            block.timestamp
        );
    }

    /*

    TAKE FEES

    */

    // Take non-token fees and add to contract
    function _takeSwap(uint256 _tSwapFeeTotal, uint256 _rSwapFeeTotal) private {
        _rOwned[address(this)] = _rOwned[address(this)] + _rSwapFeeTotal;
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + _tSwapFeeTotal;
    }

    // Take the Tokens fee
    function _takeTokens(uint256 _tTokens, uint256 _rTokens) private {
        _rOwned[walletTokens] = _rOwned[walletTokens] + _rTokens;
        if (_isExcluded[walletTokens])
            _tOwned[walletTokens] = _tOwned[walletTokens] + _tTokens;
    }

    // Adjust RFI for reflection balance
    function _takeReflect(uint256 _tReflect, uint256 _rReflect) private {
        _rTotal = _rTotal - _rReflect;
        _tFeeTotal = _tFeeTotal + _tReflect;
    }

    /*

    TRANSFER TOKENS AND CALCULATE FEES

    */

    uint256 private tAmount;
    uint256 private rAmount;

    uint256 private tBurn;
    uint256 private rBurn;
    uint256 private tReflect;
    uint256 private rReflect;
    uint256 private tTokens;
    uint256 private rTokens;
    uint256 private tSwapFeeTotal;
    uint256 private rSwapFeeTotal;
    uint256 private tTransferAmount;
    uint256 private rTransferAmount;

    // Transfer Tokens and Calculate Fees
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        // Calculate the transfer fees
        tAmount = amount;

        if (!takeFee) {
            tBurn = 0;
            // Auto Burn Fee
            tTokens = 0;
            // Tokens to external wallet fee
            tReflect = 0;
            // Reflection Fee
            tSwapFeeTotal = 0;
            // Marketing, Liquidity and Contract Fee
        } else {
            // Increase the transaction counter - only increase if required to save gas on buys when already in trigger zone
            if (swapCounter < swapTrigger) {
                swapCounter++;
            }

            if (_isPair[sender]) {
                // Buy fees
                tBurn = (tAmount * feeBuyBurn) / 100;
                tTokens = (tAmount * feeBuyTokens) / 100;
                tReflect = (tAmount * feeBuyReflection) / 100;
                tSwapFeeTotal = (tAmount * _swapFeeTotalBuy) / 100;
            } else {
                // Sell fees
                tBurn = (tAmount * feeSellBurn) / 100;
                tTokens = (tAmount * feeSellTokens) / 100;
                tReflect = (tAmount * feeSellReflection) / 100;
                tSwapFeeTotal = (tAmount * _swapFeeTotalSell) / 100;
            }
        }

        // Calculate reflected fees for RFI
        uint256 RFI = _getRate();

        rAmount = tAmount * RFI;
        rBurn = tBurn * RFI;
        rTokens = tTokens * RFI;
        rReflect = tReflect * RFI;
        rSwapFeeTotal = tSwapFeeTotal * RFI;
        tTransferAmount =
            tAmount -
            (tBurn + tTokens + tReflect + tSwapFeeTotal);
        rTransferAmount =
            rAmount -
            (rBurn + rTokens + rReflect + rSwapFeeTotal);

        // Swap tokens based on RFI status of sender and recipient
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _tOwned[sender] = _tOwned[sender] - tAmount;
            _rOwned[sender] = _rOwned[sender] - rAmount;

            if (recipient == WALLET_BURN) {
                // Remove tokens from Total Supply
                _tTotal = _tTotal - tTransferAmount;
                _rTotal = _rTotal - rTransferAmount;
            } else {
                _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
            }

            emit Transfer(sender, recipient, tTransferAmount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _rOwned[sender] = _rOwned[sender] - rAmount;

            if (recipient == WALLET_BURN) {
                // Remove tokens from Total Supply
                _tTotal = _tTotal - tTransferAmount;
                _rTotal = _rTotal - rTransferAmount;
            } else {
                _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
                _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
            }

            emit Transfer(sender, recipient, tTransferAmount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _rOwned[sender] = _rOwned[sender] - rAmount;

            if (recipient == WALLET_BURN) {
                // Remove tokens from Total Supply
                _tTotal = _tTotal - tTransferAmount;
                _rTotal = _rTotal - rTransferAmount;
            } else {
                _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
            }

            emit Transfer(sender, recipient, tTransferAmount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _tOwned[sender] = _tOwned[sender] - tAmount;
            _rOwned[sender] = _rOwned[sender] - rAmount;

            if (recipient == WALLET_BURN) {
                // Remove tokens from Total Supply
                _tTotal = _tTotal - tTransferAmount;
                _rTotal = _rTotal - rTransferAmount;
            } else {
                _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
                _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
            }

            emit Transfer(sender, recipient, tTransferAmount);
        } else {
            _rOwned[sender] = _rOwned[sender] - rAmount;

            if (recipient == WALLET_BURN) {
                // Remove tokens from Total Supply
                _tTotal = _tTotal - tTransferAmount;
                _rTotal = _rTotal - rTransferAmount;
            } else {
                _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
            }

            emit Transfer(sender, recipient, tTransferAmount);
        }

        // Take reflections
        if (tReflect != 0) {
            _takeReflect(tReflect, rReflect);
        }

        // Take tokens
        if (tTokens != 0) {
            _takeTokens(tTokens, rTokens);
        }

        // Take fees that require processing during swap and liquify
        if (tSwapFeeTotal != 0) {
            _takeSwap(tSwapFeeTotal, rSwapFeeTotal);
        }

        // Remove Deflationary Burn from Total Supply
        if (tBurn != 0) {
            _tTotal = _tTotal - tBurn;
            _rTotal = _rTotal - rBurn;
        }
    }

    receive() external payable {} // solhint-disable-line
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
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

pragma solidity >=0.5.0;

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
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
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

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}