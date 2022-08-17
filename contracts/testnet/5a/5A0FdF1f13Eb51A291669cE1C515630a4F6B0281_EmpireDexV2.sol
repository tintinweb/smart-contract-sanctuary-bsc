//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./dependencies/Controller.sol";

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IEmpireFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IEmpireRouter {
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

/**
 * @title A contract for the EMPIREv2 token
 * @author SplntyDev, Tranquil Flow, trnhgquan
 * @notice This contract defines the core logic of the EMPIREv2 token
 */
contract EmpireDexV2 is Controller {
    string private _name = "E";
    string private _symbol = "E";
    uint256 private _totalSupply;
    uint8 private _decimals = 18;

    address public pair;
    uint256 public maxWalletLimit;
    uint256 public maxTxLimit;
    uint256 public addLiquidityAmount;
    uint256 public sellCooldownSeconds = 30;
    uint256 public sellPercent = 1000; // 10%
    uint256 public buyLiquidityFee;
    uint256 public buyBurnFee;
    uint256 public sellLiquidityFee;
    uint256 public sellBurnFee;
    uint256 public blockCooldownAmount = 3;
    uint256 public maxSellTransactionAmount;
    uint256 public maxBuyTransactionAmount;
    uint256 public burntAmount;

    address private _owner;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    bool private _inSwap;
    bool public limitsActive = false;
    bool public feeActive = true;
    bool public tradingActive = true;
    bool public transfersActive = true;
    bool public antiBotsActive = true;

    IEmpireRouter private router;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _excludedMaxWallet;
    mapping(address => bool) private _excludedMaxTransaction;
    mapping(address => bool) private _excludedFees;
    mapping(address => bool) private _excludedLimits;
    mapping(address => bool) private _blacklisted;
    mapping(address => bool) public _excludedAntiMev;
    mapping(address => uint256) public antiMevBlock;
    mapping(address => User) public tradeData;
    mapping(address => bool) public automatedMarketMakerPairs;

    struct User {
        uint256 firstTradeTime;
        uint256 lastTradeTime;
        uint256 tradeAmount;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event TransferFees(uint256 amountBurned, uint256 amountLiquidity);
    event LiquidityAdded(uint256 amountToken, uint256 amountETH, uint256 amountLP);
    event ManualBurn(uint256 amount);
    event WithdrawCoin(uint256 coinAmount);
    event WithdrawToken(address tokenAddress, uint256 tokenAmount);
    event ChangeLimits(
        uint256 maxWalletLimit,
        uint256 maxTXLimit,
        uint256 addLiquidityAmount);
    event ChangeFees(
        uint256 buyLiquidityFee,
        uint256 buyBurnFee,
        uint256 sellLiquidityFee, 
        uint256 sellBurnFee);
    event ChangeExcludedMaxTransaction(address addy, bool status);
    event ChangeExcludedMaxWallet(address addy, bool status);
    event ChangeExcludedFees(address addy, bool status);
    event ChangeExcludedLimits(address addy, bool status);
    event ChangeBlacklisted(address addy, bool status);
    event ChangeAutomatedMarketPair(address addy, bool status);
    event ChangeTransfersActive(bool status);
    event ChangeTradingActive(bool status);
    event ChangeMaxBuySellLimits(uint256 buyValue, uint256 sellValue);
    event ChangeSellCooldownSeconds(uint256 value);

    constructor(address eRouter) {
        _owner = msg.sender;
        emit OwnershipTransferred(_owner, msg.sender);

        uint256 totalMint = 100_000 * 10**_decimals;
        _totalSupply += totalMint;
        _balances[_owner] += totalMint;
        emit Transfer(address(0), _owner, totalMint);

        IEmpireRouter _router = IEmpireRouter(eRouter);
        router = _router;

        address _pair = IEmpireFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );

        pair = _pair;

        setAutomatedMarketMakerPair(pair, true);

        maxWalletLimit = _totalSupply;
        maxTxLimit = _totalSupply;
        addLiquidityAmount = 1000 * 10**_decimals;

        buyLiquidityFee = 1000; // 1%
        buyBurnFee = 100; // 0.1%
        sellLiquidityFee = 1000; // 1%
        sellBurnFee = 100; // 0.1%

        maxSellTransactionAmount = _totalSupply;
        maxBuyTransactionAmount = _totalSupply;

        setExcludedAll(address(this));
        setExcludedAll(_owner);
        setExcludedAll(pair);
        setExcludedAll(address(router));

        setExcludedAnitMev(address(this), true);
        setExcludedAnitMev(_owner, true);
    }

    receive() external payable {}

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @notice Low level transfer function that moves tokens from sender to recipient after checking limitations and applying fees on transfer
     * @dev Checks if sender or recipient is blacklisted, checks if trading is active, checks for anti-MEV, checks amount < maxTxLimit, checks amount < maxWalletLimit, checks if transfers are active, checks sender has enough tokens to send, if feeActive = true applies fees on transfer depending on if selling or buying
     * @param sender The address that is sending tokens
     * @param recipient The address that is receiving tokens
     * @param amount The initial amount of tokens being sent, before fees on transfer
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(
            !_blacklisted[sender] && !_blacklisted[recipient],
            "Sender or recipient is blacklisted!"
        );

        //trading active or whitelisted
        require(_excludedLimits[sender] || tradingActive, "Trading not active");

        //anti mev
        if (antiBotsActive) {
            if (!_excludedAntiMev[sender] && !_excludedAntiMev[recipient]) {
                address actor = antiMevCheck(sender, recipient);
                antiMevFreq(actor);
                antiMevBlock[actor] = block.number;
            }
        }

        if (!_excludedMaxTransaction[sender]) {
            require(amount <= maxTxLimit, "Exceeds max transaction limit!");
        }

        if (!_excludedMaxWallet[recipient]) {
            require(
                balanceOf(recipient) + amount <= maxWalletLimit,
                "Exceeds max wallet limit!"
            );
        }

        //only allow buy or sells
        //if not excluded from limits
        if (
            (!_excludedLimits[sender] || !_excludedLimits[recipient]) &&
            (//if not buying or selling
            !automatedMarketMakerPairs[sender] &&
                !automatedMarketMakerPairs[recipient])
        ) {
            //transfers must be turn on
            require(transfersActive, "ERR: Cant transfer right now");
        }

        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount, "Amount exceeds senders balance!");
        _balances[sender] = senderBalance - amount;

        if (feeActive) {
            uint256 blkTime = block.timestamp;

            //if buy add tradedata
            if (
                automatedMarketMakerPairs[sender] && !_excludedFees[recipient]
            ) {
                require(
                    amount <= maxBuyTransactionAmount,
                    "ERR: Cant buy that much"
                );

                if (tradeData[recipient].firstTradeTime == 0) {
                    tradeData[recipient].firstTradeTime = blkTime;
                }

                if (
                    block.timestamp >
                    tradeData[recipient].firstTradeTime +
                        (sellCooldownSeconds * 7)
                ) {
                    tradeData[recipient].firstTradeTime = block.timestamp;
                }

                uint256 liquidityAmount = (amount * buyLiquidityFee) / 100000;
                uint256 burnAmount = (amount * buyBurnFee) / 100000;

                amount -= liquidityAmount;
                _balances[address(this)] += liquidityAmount;
                emit Transfer(sender, address(this), liquidityAmount);
                
                //True Burn Mechanic
                amount -= burnAmount;
                _totalSupply -= burnAmount;
                
                emit TransferFees(burnAmount, liquidityAmount);
            }
            //if sell check amount able to sell for the day
            else if (
                automatedMarketMakerPairs[recipient] && !_excludedFees[sender]
            ) {
                require(
                    amount <= maxSellTransactionAmount,
                    "ERR: Cant sell that much"
                );

                uint256 calcAmount = (balanceOf(sender) * sellPercent) / 100000;
                require(amount <= calcAmount, "ERR: Cant sell that much");

                if (
                    blkTime >
                    tradeData[sender].lastTradeTime + sellCooldownSeconds
                ) {
                    tradeData[sender].lastTradeTime = blkTime;
                    tradeData[sender].tradeAmount = amount;
                } else if (
                    (blkTime <
                        tradeData[sender].lastTradeTime +
                            sellCooldownSeconds) &&
                    ((blkTime > tradeData[sender].lastTradeTime))
                ) {
                    require(
                        tradeData[sender].tradeAmount + amount <= calcAmount,
                        "ERR: Cant sell that much"
                    );
                    tradeData[sender].tradeAmount =
                        tradeData[sender].tradeAmount +
                        amount;
                }

                uint256 liquidityAmount = (amount * sellLiquidityFee) / 100000;
                uint256 burnAmount = (amount * sellBurnFee) / 100000;

                if (
                    blkTime <
                    tradeData[sender].firstTradeTime + (sellCooldownSeconds * 7)
                ) {
                    liquidityAmount = liquidityAmount * 2;
                    burnAmount = burnAmount * 2;
                }

                amount -= liquidityAmount;
                _balances[address(this)] += liquidityAmount;
                emit Transfer(sender, address(this), liquidityAmount);

                swapAddLiquidity();

                //True Burn Mechanic
                amount -= burnAmount;
                _totalSupply -= burnAmount;

                emit TransferFees(burnAmount, liquidityAmount);
            }
        }

        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function addLiquidity(uint256 tokenAmount, uint256 amount)
        internal
        virtual
    {
        _approve(address(this), address(router), tokenAmount);
        (uint256 tokAmount,
        uint256 ethAmount,
        uint256 lpAmount) = router.addLiquidityETH{value: amount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
        emit LiquidityAdded(tokAmount, ethAmount, lpAmount);
    }

    function swapTokensForEth(uint256 amount) internal virtual {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), amount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapAddLiquidity() internal virtual {
        uint256 tokenBalance = balanceOf(address(this));
        if (!_inSwap && tokenBalance >= addLiquidityAmount) {
            _inSwap = true;

            uint256 sellAmount = tokenBalance;

            uint256 sellHalf = sellAmount / 2;

            uint256 initialEth = address(this).balance;
            swapTokensForEth(sellHalf);

            uint256 receivedEth = address(this).balance - initialEth;
            addLiquidity(sellAmount - sellHalf, (receivedEth));

            _inSwap = false;
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(
            owner != address(0),
            "Wallet address can not be the zero address!"
        );
        require(spender != address(0), "Spender can not be the zero address!");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Amount exceeds allowance!");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
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
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "Decreased allowance below zero!"
        );
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    /**
     * @notice Function to manually burn tokens from the msg.sender
     * @dev Created to keep flexibility on allowing tokens to be removed from supply
     * @param amount The amount of tokens to be burned
     */
    function manualBurn(uint256 amount) external {
        address accnt = msg.sender;

        uint256 accountBalance = _balances[accnt];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[accnt] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit ManualBurn(amount);
    }

    //anti bot

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function antiMevCheck(address _to, address _from)
        internal
        virtual
        returns (address)
    {
        require(!isContract(_to) || !isContract(_from), "No bots allowed!");
        if (isContract(_to)) return _from;
        else return _to;
    }

    function antiMevFreq(address addr) internal virtual {
        bool isAllowed = antiMevBlock[addr] == 0 ||
            ((antiMevBlock[addr] + blockCooldownAmount) < (block.number + 1));
        require(isAllowed, "Max tx frequency exceeded!");
    }

    //admin

    /**
     * @notice Withdraws native coin from the contract
     * @dev Function is to make sure native coins do not get stuck on the contract
     * @param amount The amount of native coin to withdraw
     */
    function withdraw(uint256 amount) public payable onlyOwner returns (bool) {
        require(
            amount <= address(this).balance,
            "Withdrawal amount exceeds balance!"
        );
        payable(msg.sender).transfer(amount);
        emit WithdrawCoin(amount);
        return true;
    }

    /**
     * @notice Withdraws tokens from the contract
     * @dev Function is to make tokens do not get stuck on the contract
     * @param tokenContract The address of the token to withdraw
     * @param amount The amount of tokens to withdraw
     */
    function withdrawToken(address tokenContract, uint256 amount)
        public
        virtual
        onlyOwner
    {
        IERC20 _tokenContract = IERC20(tokenContract);
        _tokenContract.transfer(msg.sender, amount);
        emit WithdrawToken(tokenContract, amount);
    }

    /**
     * @notice Determines if anti-MEV checks are conducted on transfers
     * @param value Determines the new value for antiBotsActive
     */
    function setAntiBotsActive(bool value) external onlyOwner {
        antiBotsActive = value;
    }

    /**
     * @notice Excludes `addy` from maxWalletLimit, maxTxLimit + excludes from fees on transfer
     * @param addy Defines the address to exclude from all
     */
    function setExcludedAll(address addy) public virtual onlyOwner {
        setExcludedMaxTransaction(addy, true);
        setExcludedMaxWallet(addy, true);
        setExcludedFees(addy, true);
        setExcludedLimits(addy, true);
    }

    /**
     * @notice Defines the new values for maxWalletLimit, maxTxLimit + addLiquidityAmount
     * @dev maxWalletLimit = max tokens 1 wallet can hold, maxTxLimit = max number of tokens a wallet can transfer, addLiquidityAmount = threshold value for how many tokens to hold on contract before selling half to add to liquidity
     * @param _maxWalletLimit Determines the new value for maxWalletLimit
     * @param _maxTxLimit Determines the new value for maxTxLimit
     * @param _addLiquidityAmount Determines the new value for addLiquidityAmount
     */
    function setLimits(
        uint256 _maxWalletLimit,
        uint256 _maxTxLimit,
        uint256 _addLiquidityAmount
    ) public virtual onlyOwner {
        maxWalletLimit = _maxWalletLimit * 10**_decimals;
        maxTxLimit = _maxTxLimit * 10**_decimals;
        addLiquidityAmount = _addLiquidityAmount * 10**_decimals;
        emit ChangeLimits(maxWalletLimit, maxTxLimit, addLiquidityAmount);
    }

    /**
     * @notice Defines the fees on transfer for buys and sells
     * @dev Defines the fees on transfer separetely for buys and sells separately
     * @param _buyLiquidityFee Determines the new value for buyLiquidityFee
     * @param _buyBurnFee Determines the new value for buyBurnFee
     * @param _sellLiquidityFee Determines the new value for sellLiquidityFee
     * @param _sellBurnFee Determines the new value for sellBurnFee
     */
    function setFees(
        uint256 _buyLiquidityFee,
        uint256 _buyBurnFee,
        uint256 _sellLiquidityFee,
        uint256 _sellBurnFee
    ) public virtual onlyOwner {
        buyLiquidityFee = _buyLiquidityFee;
        buyBurnFee = _buyBurnFee;
        sellLiquidityFee = _sellLiquidityFee;
        sellBurnFee = _sellBurnFee;
        emit ChangeFees(_buyLiquidityFee, _buyBurnFee, _sellLiquidityFee, _sellBurnFee);
    }

    /**
     * @notice Defines if an address (`addy`) is exempt from max transaction limit
     * @dev Addresses that are excluded are not restricted by maxTxLimit
     * @param addy Determines the address to be excluded from maxTxLimit limitations
     * @param status Determines if `addy` is excluded from fees maxTxLimit limitations
     */
    function setExcludedMaxTransaction(address addy, bool status)
        public
        virtual
        onlyOwner
    {
        _excludedMaxTransaction[addy] = status;
        emit ChangeExcludedMaxTransaction(addy, status);
    }

    /**
     * @notice Defines if an address (`addy`) is exempt from holding more than `maxWalletLimit` in wallet
     * @dev Addresses that are excluded are not restricted by maxWalletLimit
     * @param addy Determines the address to be excluded from maxWalletLimit limitations
     * @param status Determines if `addy` is excluded from fees maxWalletLimit limitations
     */
    function setExcludedMaxWallet(address addy, bool status)
        public
        virtual
        onlyOwner
    {
        _excludedMaxWallet[addy] = status;
        emit ChangeExcludedMaxWallet(addy, status);
    }

    /**
     * @notice Defines if an address (`addy`) is exempt from fees on transfer
     * @param addy Determines the address to be excluded from fees on transfer
     * @param status Determines if `addy` is excluded from fees on transfer
     */
    function setExcludedFees(address addy, bool status)
        public
        virtual
        onlyOwner
    {
        _excludedFees[addy] = status;
        emit ChangeExcludedFees(addy, status);
    }

    /**
     * @notice Defines if an address (`addy`) is exempt from anti-MEV checks
     * @param addy Determines the address to be excluded from anti-MEV checks
     * @param status Determines if `addy` is excluded from anti-MEV checks
     */
    function setExcludedAnitMev(address addy, bool status)
        public
        virtual
        onlyOwner
    {
        _excludedAntiMev[addy] = status;
    }

    /**
     * @notice Defines if an address (`addy`) is allowed to transfer tokens
     * @param addy Determines the address to be excluded from token transfers
     * @param status Determines if `addy` is excluded from token transfers
     */
    function setBlacklistWallet(address addy, bool status)
        public
        virtual
        onlyOwner
    {
        _blacklisted[addy] = status;
        emit ChangeBlacklisted(addy, status);
    }

    /**
     * @notice Defines if an address (`addy`) is a DEX trading pair for the EMPIRE token
     * @param addy Determines the address of the market maker pair
     * @param status Determines if `addy` is a market maker pair
     */
    function setAutomatedMarketMakerPair(address addy, bool status)
        public
        virtual
        onlyOwner
    {
        automatedMarketMakerPairs[addy] = status;
        emit ChangeAutomatedMarketPair(addy, status);
    }

    /**
     * @notice Defines if an address (`addy`) is allowed to transfer/trade, bypassing other locks on transfers/trades
     * @dev Function allows to define an address that can transfer/trade even if transfersActive + tradingActive are false
     * @param addy Determines the address to be excluded from limits
     * @param status Determines if `addy` is excluded or not
     */
    function setExcludedLimits(address addy, bool status)
        public
        virtual
        onlyOwner
    {
        _excludedLimits[addy] = status;
        emit ChangeExcludedLimits(addy, status);
    }

    /**
     * @notice Changes the transfersActive variable, which determines if transfers of the token are enabled
     * @param status Determines the new value for transfersActive
     */
    function setTransfersActive(bool status) external onlyOwner {
        transfersActive = status;
        emit ChangeTransfersActive(status);
    }

    /**
     * @notice Changes the tradingActive variable, which determines if trading on a DEX is enabled
     * @param status Determines the new value for tradingActive
     */
    function setTradingActive(bool status) external onlyOwner {
        tradingActive = status;
        emit ChangeTradingActive(status);
    }

    /**
     * @notice Changes the maxBuyTransactionAmount + maxSellTransactionAmount variables, which determine the max number of tokens can be bought/sold respectively
     * @param buyValue Determines the new value for maxBuyTransactionAmount
     * @param sellValue Determines the new value for maxSellTransactionAmount
     */
    function setMaxBuySellLimits(uint256 buyValue, uint256 sellValue)
        external
        onlyOwner
    {
        maxBuyTransactionAmount = buyValue;
        maxSellTransactionAmount = sellValue;
        emit ChangeMaxBuySellLimits(buyValue, sellValue);
    }

    /**
     * @notice Changes the setBlockCooldown variable, which determines how many blocks can elapse between transfers
     * @dev Used to determine anti-MEV logic
     * @param value Determines the new value for setBlockCooldown
     */
    function setBlockCooldown(uint256 value) external onlyOwner {
        blockCooldownAmount = value;
    }

    /**
     * @notice Changes the sellCooldownSeconds variable, which determines how many seconds can elapse between sells
     * @param value Determines the new value for sellCooldownSeconds
     */
    function setSellCooldownSeconds(uint256 value) external onlyOwner {
        sellCooldownSeconds = value;
        emit ChangeSellCooldownSeconds(value);
    }

    /**
     * @notice Distributes tokens to multiple `recipients` with differing `values` amount
     * @param recipients An array that defines the addresses that are being distributed tokens
     * @param values An array that defines the amount of tokens to be distributed to the `recipients`
     */
    function airdrop(address[] calldata recipients, uint256[] calldata values)
        external
        onlyOwner
    {
        require(
            recipients.length < 501,
            "Max airdrop limit is 500 addresses per tx"
        );
        require(
            values.length == recipients.length,
            "Mismatch between length of recipients and values"
        );

        _approve(owner(), owner(), totalSupply());
        for (uint256 i = 0; i < recipients.length; i++) {
            transferFrom(msg.sender, recipients[i], values[i]);
        }
    }

    // BRIDGE OPERATOR ONLY REQUIRES 2BA - TWO BLOCKCHAIN AUTHENTICATION //
    function unlock(address account, uint256 amount) external onlyOperator {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function lock(address account, uint256 amount) external onlyOperator {
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Controller is Ownable {
    mapping(address => bool) operator;
    event operatorCreated(address _operator, bool _whiteList);

    modifier onlyOperator() {
        require(operator[msg.sender], "Only-operator");
        _;
    }

    constructor() {
        operator[msg.sender] = true;
    }

    function setOperator(address _operator, bool _whiteList) public onlyOwner {
        operator[_operator] = _whiteList;
        emit operatorCreated(_operator, _whiteList);
    }
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