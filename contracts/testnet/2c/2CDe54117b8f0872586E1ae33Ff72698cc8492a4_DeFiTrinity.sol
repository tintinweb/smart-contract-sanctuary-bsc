//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../IUniswapV2Router02.sol";
import "../IUniswapV2Factory.sol";

contract DeFiTrinity is IERC20, Context, Ownable {
    using SafeMath for uint256;
    using SafeMath for uint8;
    using Address for address;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event DevFeeSent(address payable indexed recepient, uint256 amount);

    // Address for BUSD
    // Mainnet
    // address public _busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    // Testnet
    address public _busd = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    // Address for Pancakeswap Router V2
    IUniswapV2Router02 public router;
    address public uniswapV2Pair;
    // token data
    string constant _name = "DeFiTrinity";
    string constant _symbol = "DFT";
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 1_000 * 10**_decimals;
    // balances
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) public isWhitelisted;

    uint256 public swapTokensAtAmount = 50 * 10**_decimals;

    bool public inSwap;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 public spreadDivisor = 9400;

    uint256 public lpFee = 700;
    uint256 public jackpotFee = 300;
    uint256 public totalFees = 1000;
    uint256 constant FEE_DENOMINATOR = 10000;

    uint256 private constant BNB_DECIMALS = 18;
    uint256 private constant BUSD_DECIMALS = 18;

    uint256 private constant MAX_PCT = 10000;
    // PCS takes 0.25% fee on all txs
    uint256 private constant ROUTER_FEE = 25;

    // 55.55% jackpot cashout to last buyer
    uint256 public jackpotCashout = 10000;
    // 90% of jackpot cashout to last buyer
    uint256 public jackpotBuyerShare = 9000;
    // Buys > 10 BUSD will be eligible for the jackpot
    uint256 public jackpotMinBuy = 0 * 10**(BUSD_DECIMALS);
    // Jackpot time span is initially set to 5 mins
    uint256 public jackpotTimespan = 15 * 60;
    // Jackpot hard limit, BUSD value
    uint256 public jackpotHardLimit = 50000 * 10**(BUSD_DECIMALS);
    // Jackpot hard limit buyback share
    uint256 public jackpotHardBuyback = 5000;

    uint256 public _jackpotTokens = 0;
    uint256 public _pendingJackpotBalance = 0;

    address private _lastSeller = address(this);
    uint256 private _lastSellTimestamp = 0;
    uint256 private _lastSellBUSDValue = 0;

    address private _lastAwarded = address(0);
    uint256 private _lastAwardedCash = 0;
    uint256 private _lastAwardedTokens = 0;
    uint256 private _lastAwardedTimestamp = 0;

    uint256 private _lastBigBangCash = 0;
    uint256 private _lastBigBangTokens = 0;
    uint256 private _lastBigBangTimestamp = 0;

    uint256 private _totalJackpotCashedOut = 0;
    uint256 private _totalJackpotTokensOut = 0;
    uint256 private _totalJackpotBuyer = 0;
    uint256 private _totalJackpotBuyback = 0;
    uint256 private _totalJackpotBuyerTokens = 0;
    uint256 private _totalJackpotBuybackTokens = 0;

    event JackpotAwarded(address indexed receiver, uint256 amount);
    event BigBang(uint256 cashedOut, uint256 tokensOut);
    event JackpotFund(uint256 busdSent, uint256 tokenAmount);

    address payable public devAddress =
        payable(0x27DF7e6A705270e088447eb09A273cdC81cB39b6);

    bool public internalTradingEnabled;

    // initialize
    constructor() {
        /// Router
        /// Mainnet
        // router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        /// Testnet
        router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        address _uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        _balances[msg.sender] = _totalSupply;
        uniswapV2Pair = _uniswapV2Pair;
        isWhitelisted[msg.sender] = true;
        isWhitelisted[devAddress] = true;
        isWhitelisted[address(this)] = true;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function getLastSell()
        external
        view
        returns (
            address lastSeller,
            uint256 lastSellBUSDValue,
            uint256 lastSellTimestamp
        )
    {
        return (_lastSeller, _lastSellBUSDValue, _lastSellTimestamp);
    }

    function getLastAwardedJackpot()
        external
        view
        returns (
            address lastAwarded,
            uint256 lastAwardedCash,
            uint256 lastAwardedTokens,
            uint256 lastAwardedTimestamp
        )
    {
        return (
            _lastAwarded,
            _lastAwardedCash,
            _lastAwardedTokens,
            _lastAwardedTimestamp
        );
    }

    function getPendingJackpotBalance()
        external
        view
        returns (uint256 pendingJackpotBalance)
    {
        return (_pendingJackpotBalance);
    }

    function getPendingJackpotTokens()
        external
        view
        returns (uint256 pendingJackpotTokens)
    {
        return _jackpotTokens;
    }

    function getLastBigBang()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (_lastBigBangCash, _lastBigBangTokens, _lastBigBangTimestamp);
    }

    function getJackpot()
        public
        view
        returns (uint256 jackpotTokens, uint256 pendingJackpotAmount)
    {
        return (_jackpotTokens, _pendingJackpotBalance);
    }

    function totalJackpotOut() external view returns (uint256, uint256) {
        return (_totalJackpotCashedOut, _totalJackpotTokensOut);
    }

    function totalJackpotBuyer() external view returns (uint256, uint256) {
        return (_totalJackpotBuyer, _totalJackpotBuyerTokens);
    }

    function totalJackpotBuyback() external view returns (uint256, uint256) {
        return (_totalJackpotBuyback, _totalJackpotBuybackTokens);
    }

    function getBUSDValue(uint256 amount) public view returns (uint256) {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = _busd;
        uint256 value = router.getAmountsOut(amount, path)[2];
        return value;
    }

    function shouldAwardJackpot() public view returns (bool) {
        return
            _lastSeller != address(0) &&
            _lastSeller != address(this) &&
            block.timestamp.sub(_lastSellTimestamp) >= jackpotTimespan;
    }

    function isJackpotEligible(uint256 tokenAmount) public view returns (bool) {
        if (jackpotMinBuy == 0) {
            return true;
        }
        address[] memory path = new address[](3);
        path[0] = _busd;
        path[1] = router.WETH();
        path[2] = address(this);

        uint256 tokensOut = router
        .getAmountsOut(jackpotMinBuy, path)[1].mul(MAX_PCT.sub(ROUTER_FEE)).div(
                // We don't subtract the buy fee since the tokenAmount is pre-tax
                MAX_PCT
            );
        return tokenAmount >= tokensOut;
    }

    function processBigBang() internal lockTheSwap {
        uint256 cashedOut = _pendingJackpotBalance.mul(jackpotHardBuyback).div(
            MAX_PCT
        );
        uint256 tokensOut = _jackpotTokens.mul(jackpotHardBuyback).div(MAX_PCT);
        _lastBigBangTokens = tokensOut;

        IERC20(_busd).transfer(devAddress, cashedOut);
        _transfer(address(this), devAddress, tokensOut);

        emit BigBang(cashedOut, tokensOut);

        _lastBigBangCash = cashedOut;
        _lastBigBangTimestamp = block.timestamp;

        _pendingJackpotBalance = _pendingJackpotBalance.sub(cashedOut);
        _jackpotTokens = _jackpotTokens.sub(tokensOut);

        _totalJackpotCashedOut = _totalJackpotCashedOut.add(cashedOut);
        _totalJackpotBuyback = _totalJackpotBuyback.add(cashedOut);
        _totalJackpotTokensOut = _totalJackpotTokensOut.add(tokensOut);
        _totalJackpotBuybackTokens = _totalJackpotBuybackTokens.add(tokensOut);
    }

    function fundJackpot(uint256 tokenAmount, uint256 busdAmount)
        external
        onlyOwner
    {
        require(
            balanceOf(msg.sender) >= tokenAmount,
            "You don't have enough tokens to fund the jackpot"
        );
        bool isTransferBUSDSuccess = IERC20(_busd).transferFrom(
            msg.sender,
            address(this),
            busdAmount
        );
        if (isTransferBUSDSuccess) {
            _pendingJackpotBalance = _pendingJackpotBalance.add(busdAmount);
        }
        if (tokenAmount > 0) {
            _transfer(msg.sender, address(this), tokenAmount);
            _jackpotTokens = _jackpotTokens.add(tokenAmount);
        }

        emit JackpotFund(busdAmount, tokenAmount);
    }

    function awardJackpot() internal lockTheSwap {
        require(
            _lastSeller != address(0) && _lastSeller != address(this),
            "No last buyer detected"
        );
        uint256 cashedOut = _pendingJackpotBalance.mul(jackpotCashout).div(
            MAX_PCT
        );
        if (cashedOut > _lastSellBUSDValue) {
            cashedOut = _lastSellBUSDValue;
        }
        uint256 tokensOut = _jackpotTokens.mul(jackpotCashout).div(MAX_PCT);
        uint256 buyerShare = cashedOut.mul(jackpotBuyerShare).div(MAX_PCT);
        uint256 tokensToBuyer = tokensOut.mul(jackpotBuyerShare).div(MAX_PCT);
        uint256 toBuyback = cashedOut - buyerShare;
        uint256 tokensToBuyback = tokensOut - tokensToBuyer;
        if (buyerShare > 0) {
            IERC20(_busd).transfer(_lastSeller, buyerShare);
        }
        if (tokensToBuyer > 0) {
            _transfer(address(this), _lastSeller, tokensToBuyer);
        }
        if (toBuyback > 0) {
            IERC20(_busd).transfer(devAddress, toBuyback);
        }
        if (tokensToBuyback > 0) {
            _transfer(address(this), devAddress, tokensToBuyback);
        }

        _pendingJackpotBalance = _pendingJackpotBalance.sub(cashedOut);
        _jackpotTokens = _jackpotTokens.sub(tokensOut);

        _lastAwarded = _lastSeller;
        _lastAwardedCash = cashedOut;
        _lastAwardedTimestamp = block.timestamp;
        _lastAwardedTokens = tokensToBuyer;

        emit JackpotAwarded(_lastSeller, cashedOut);

        _lastSeller = payable(address(this));
        _lastSellTimestamp = 0;
        _lastSellBUSDValue = 0;

        _totalJackpotCashedOut = _totalJackpotCashedOut.add(cashedOut);
        _totalJackpotTokensOut = _totalJackpotTokensOut.add(tokensOut);
        _totalJackpotBuyer = _totalJackpotBuyer.add(buyerShare);
        _totalJackpotBuyerTokens = _totalJackpotBuyerTokens.add(tokensToBuyer);
        _totalJackpotBuyback = _totalJackpotBuyback.add(toBuyback);
        _totalJackpotBuybackTokens = _totalJackpotBuybackTokens.add(
            tokensToBuyback
        );
    }

    function setLPFee(uint256 _fee) external onlyOwner {
        lpFee = _fee;
        totalFees = lpFee.add(jackpotFee);
        require(totalFees <= 2500, "Total fees must be less than 25%");
    }

    function setJackpotFee(uint256 _fee) external onlyOwner {
        jackpotFee = _fee;
        totalFees = lpFee.add(jackpotFee);
        require(totalFees <= 2500, "Total fees must be less than 25%");
    }

    function setSwapTokenAtAmount(uint256 _amount) external onlyOwner {
        swapTokensAtAmount = _amount;
    }

    function setDevAddress(address _address) external onlyOwner {
        require(_address != address(0), "Address cannot be 0x0");
        devAddress = payable(_address);
    }

    // token functions
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setWhitelisted(address _account, bool _isWhitelisted) public {
        isWhitelisted[_account] = _isWhitelisted;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function enableInternalTrading() external onlyOwner {
        internalTradingEnabled = true;
    }

    /** Transfer Function */
    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    /** Transfer Function */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (sender != msg.sender) {
            _spendAllowance(sender, msg.sender, amount);
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = _allowances[owner][spender];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "BEP20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /** Internal Transfer */
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        // make standard checks
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 contractTokenBalance = balanceOf(address(this));
        if (
            !inSwap &&
            sender != owner() &&
            recipient != owner() &&
            sender != uniswapV2Pair &&
            contractTokenBalance >= swapTokensAtAmount
        ) {
            inSwap = true;
            uint256 lpTokens;
            if (contractTokenBalance >= _jackpotTokens) {
                lpTokens = contractTokenBalance.sub(_jackpotTokens);
                swapAndLiquify(lpTokens);
            }
            if (_jackpotTokens > 0) {
                uint256 jackpotTokens = contractTokenBalance.sub(lpTokens);
                uint256 busdBalanceBefore = IERC20(_busd).balanceOf(
                    address(this)
                );
                swapTokensForTokens(jackpotTokens, _busd);
                uint256 busdBalanceAfter = IERC20(_busd).balanceOf(
                    address(this)
                );
                uint256 busdReceived = busdBalanceAfter.sub(busdBalanceBefore);
                _jackpotTokens = 0;
                _pendingJackpotBalance = _pendingJackpotBalance.add(
                    busdReceived
                );
            }
            inSwap = false;
        }

        if (_pendingJackpotBalance >= jackpotHardLimit) {
            processBigBang();
        } else if (shouldAwardJackpot()) {
            awardJackpot();
        }

        bool takeFee = !inSwap;
        if (isWhitelisted[sender] || isWhitelisted[recipient]) {
            takeFee = false;
        }
        if (
            takeFee && (sender == uniswapV2Pair || recipient == uniswapV2Pair)
        ) {
            uint256 externalTax = amount.mul(totalFees).div(FEE_DENOMINATOR);
            amount = amount.sub(externalTax);
            _jackpotTokens = _jackpotTokens.add(
                externalTax.mul(jackpotFee).div(totalFees)
            );
            _transfer(sender, address(this), externalTax);
        }
        // subtract form sender, give to receiver
        _transfer(sender, recipient, amount);
        return true;
    }

    /** Purchases WIN Tokens and Deposits Them in Sender's Address */
    function purchase(address buyer, uint256 bnbAmount)
        internal
        returns (bool)
    {
        if (!isWhitelisted[buyer]) {
            require(internalTradingEnabled, "Trade is not enabled");
        }
        if (_pendingJackpotBalance >= jackpotHardLimit) {
            processBigBang();
        } else if (shouldAwardJackpot()) {
            awardJackpot();
        }
        // make sure we don't buy more than the bnb in this contract
        require(
            bnbAmount <= address(this).balance,
            "purchase not included in balance"
        );
        // previous amount of BUSD before we received any
        uint256 prevBusdAmount = IERC20(_busd).balanceOf(address(this));
        // buy BUSD with the BNB we received
        buyBusd(bnbAmount);
        // if this is the first purchase, use current balance
        uint256 currentBusdAmount = IERC20(_busd).balanceOf(address(this));
        // number of BUSD we have purchased
        uint256 difference = currentBusdAmount.sub(prevBusdAmount);
        // if this is the first purchase, use new amount
        prevBusdAmount = prevBusdAmount == 0
            ? currentBusdAmount
            : prevBusdAmount;
        // make sure total supply is greater than zero
        uint256 calculatedTotalSupply = _totalSupply == 0
            ? _totalSupply.add(1)
            : _totalSupply;
        // find the number of tokens we should mint to keep up with the current price
        uint256 nShouldPurchase = calculatedTotalSupply.mul(difference).div(
            prevBusdAmount
        );
        // apply our spread to tokens to inflate price relative to total supply
        uint256 tokensToSend = nShouldPurchase
            .mul(spreadDivisor)
            .div(FEE_DENOMINATOR)
            .mul(FEE_DENOMINATOR.sub(totalFees))
            .div(FEE_DENOMINATOR);
        uint256 tokensForJackpot = nShouldPurchase
            .mul(spreadDivisor)
            .div(FEE_DENOMINATOR)
            .mul(jackpotFee)
            .div(FEE_DENOMINATOR);
        // revert if under 1
        if (tokensToSend < 1) {
            revert("Must Buy More Than One Token");
        }

        // mint the tokens we need to the buyer
        mint(buyer, tokensToSend);
        mint(address(this), tokensForJackpot);
        _jackpotTokens = _jackpotTokens.add(tokensForJackpot);
        return true;
    }

    /** Sells WIN Tokens And Deposits the BNB into Seller's Address */
    function sell(uint256 tokenAmount) public returns (bool) {
        if (!isWhitelisted[msg.sender]) {
            require(internalTradingEnabled, "Trade is not enabled");
        }

        if (_pendingJackpotBalance >= jackpotHardLimit) {
            processBigBang();
        } else if (shouldAwardJackpot()) {
            awardJackpot();
        }

        _lastSellTimestamp = block.timestamp;
        _lastSeller = msg.sender;
        _lastSellBUSDValue = getBUSDValue(tokenAmount);
        // make sure seller has this balance
        require(
            _balances[msg.sender] >= tokenAmount,
            "cannot sell above token amount"
        );

        // calculate the sell fee from this transaction
        uint256 tokensToSwap = tokenAmount
            .mul(FEE_DENOMINATOR.sub(totalFees))
            .div(FEE_DENOMINATOR);
        uint256 jackpotTokens = tokenAmount.mul(jackpotFee).div(
            FEE_DENOMINATOR
        );

        // how much BUSD are these tokens worth?
        uint256 amountBUSD = tokensToSwap.mul(calculatePrice()).div(10**18);

        // send BUSD to Seller
        bool successful = IERC20(_busd).transfer(msg.sender, amountBUSD);
        if (successful) {
            _transfer(msg.sender, address(this), jackpotTokens);
            _jackpotTokens = _jackpotTokens.add(jackpotTokens);
            _balances[msg.sender] = _balances[msg.sender].sub(
                tokenAmount.sub(jackpotTokens)
            );
            _totalSupply = _totalSupply.sub(
                tokenAmount.sub(jackpotTokens),
                "total supply cannot be negative"
            );
            emit Transfer(
                msg.sender,
                address(0),
                tokenAmount.sub(jackpotTokens)
            );
        } else {
            revert();
        }
        return true;
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForTokens(uint256 tokenAmount, address tokenOut)
        private
        lockTheSwap
    {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = tokenOut;

        _approve(address(this), address(router), tokenAmount);
        // make the swap to BUSD
        router.swapExactTokensForTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }

    /**
     * Buys BUSD with BNB in the contract, storing in the contract
     */
    function buyBusd(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = _busd;

        try
            router.swapExactETHForTokens{value: amount}(
                0,
                path,
                address(this),
                block.timestamp.add(30)
            )
        {} catch {
            revert();
        }
    }

    /** Returns the Current Price of the Token */
    function calculatePrice() public view returns (uint256) {
        uint256 busdBalance = IERC20(_busd).balanceOf(address(this));
        if (busdBalance < _pendingJackpotBalance) {
            return busdBalance.mul(10**18).div(_totalSupply);
        }
        return
            (busdBalance.sub(_pendingJackpotBalance)).mul(10**18).div(
                _totalSupply
            );
    }

    /** Mints Tokens to the Receivers Address */
    function mint(address receiver, uint256 amount) internal {
        _balances[receiver] = _balances[receiver].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), receiver, amount);
    }

    /** Amount of BNB in Contract */
    function getBusdQuantityInContract() public view returns (uint256) {
        return IERC20(_busd).balanceOf(address(this));
    }

    /** Returns the value of your holdings before the 6% sell fee */
    function getValueOfHoldings(address holder) public view returns (uint256) {
        return _balances[holder].mul(calculatePrice());
    }

    /** Incase Pancakeswap Upgrades To V3 */
    function changePancakeswapRouterAddress(address newPCSAddress)
        public
        onlyOwner
    {
        router = IUniswapV2Router02(newPCSAddress);
    }

    function buy() external payable {
        uint256 val = msg.value;
        address buyer = msg.sender;
        purchase(buyer, val);
    }

    function burn(uint256 amount) external {
        require(
            _balances[msg.sender] >= amount,
            "You don't have that much to burn"
        );
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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