/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

//SPDX-License-Identifier: MIT
/*

            @@@                                                                                   
            @@@@@@@                                                                                 
         &    @@@@@@@@                                                                              
       @@@@@    @@@@@@@@                                                                            
     @@@@@@@@     @@@@@@@@        @@@    @@@  @@@@@@        @@@@@@@^      @@@@@@@     @@  @@@     @@
   @@@@@@@@    @    @@@@@@@@        @@  @@.   @@   @@@    @@@     @@@   @@@     @@@   @@  @@@@    @@
 @@@@@@@     @@@@@    @@@@@@@@       @@@@     @@   @@@    @@           @@@       @@@  @@  @@ @@@  @@
 @@@@@@@~    @@@@@    @@@@@@@@       @@@@     @@@@@@      @@           @@@       @@@  @@  @@   @@ @@
   @@@@@@@@    @    @@@@@@@@       @@@  @@@   @@  @@@     @@@     @@@   @@@     @@@   @@  @@    @@@@
     @@@@@@@@     @@@@@@@@        @@@    @@@  @@    @@@     @@@@@@@.      @@@@@@@     @@  @@     @@@
       @@@@@    @@@@@@@@                                                                            
         ~    @@@@@@@@                                                                              
            @@@@@@@                                                                                 
              @@@                                   

            
            WEBSITE:    ---->   xr-coin.net
            E-MAIL:     ---->   [email protected]
            Twitter:    ---->   https://twitter.com/xr_coin
            Instagram:  ---->   https://instagram.com/xr_coin  
            Telegram:   ---->   https://t.me/xr_coin
            Medium:     ---->   https://medium.com/@xr_coin
            Linkedin:   ---->   https://www.linkedin.com/in/xr-coin/
            Discord:    ---->   https://discord.gg/r37xC8WmFS

*/

pragma solidity ^0.8.12;
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

contract XRCoin is ERC20, Ownable {
    using Address for address payable;

    IRouter public router;
    address public pair;
    address public bridgeAddress;

    bool private _liquidityLock = false;
    bool public providingLiquidity = false;
    bool public tradingEnabled = false;

    bool public updateLimit = true;
    bool public transferFeeStatus = true;

    uint256 public tokenLiquidityThreshold;
    uint256 public maxBuyLimit;
    uint256 public maxSellLimit;
    uint256 public maxWalletLimit;

    uint256 public tradingStartBlock;
    uint256 private deadline = 2;
    uint256 private launchFee = 10;
    uint256 private transferFee = 50;

    address private marketingWallet =
        0x51f73D8ed6CFaD4D8E0c38E588BedBc1220E9B3f;
    address private devWallet = 0xE5b65E75C18a30c57FC661334F55f55C464e4e39;
    address private rewardWallet = 0x37673C8FE0A8a461607545C8ee17CA9a15A90ee4;
    address public constant deadWallet =
        0x000000000000000000000000000000000000dEaD;

    struct Fees {
        uint256 marketing;
        uint256 liquidity;
        uint256 dev;
        uint256 reward;
    }

    Fees public buyFees = Fees(4, 2, 2, 0);
    Fees public sellFees = Fees(4, 6, 2, 0);

    mapping(address => bool) public exemptFee;
    mapping(address => bool) public exemptMaxBuyLimit;
    mapping(address => bool) public exemptMaxWalletLimit;
    mapping(address => bool) public exemptMaxSellLimit;
    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public allowedTransfer;

    //Anti Dump
    mapping(address => uint256) private _lastSell;
    bool public coolDownEnabled = false;
    uint256 public coolDownTime = 60 seconds;

    //marketFee multiplier cooldown
    uint256 marketFeeMultiplierCooldown = 0 minutes;
    uint8 marketFeeMultiplier = 4;

    modifier lockLiquidity() {
        if (!_liquidityLock) {
            _liquidityLock = true;
            _;
            _liquidityLock = false;
        }
    }

    constructor(address router_, uint256 chainSupply_)
        ERC20("XR COIN", "XR", 1000000000, 18)
    {
        uint256 _totalSupply = totalSupply();

        tokenLiquidityThreshold = (_totalSupply / 1000) * 1; // .1% liq threshold
        maxBuyLimit = (_totalSupply * 2) / 100; // 2% max buy
        maxSellLimit = (_totalSupply * 2) / 100; // 2% max sell
        maxWalletLimit = (_totalSupply * 2) / 100; // 2% max wallet

        IRouter _router = IRouter(router_);
        // Create a pancake pair for this new token
        address _pair = IFactory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );

        router = _router;
        pair = _pair;

        exemptFee[msg.sender] = true;
        exemptFee[address(this)] = true;
        exemptFee[marketingWallet] = true;
        exemptFee[devWallet] = true;
        exemptFee[rewardWallet] = true;
        exemptFee[deadWallet] = true;

        uint256 tokenAmountToBurn = _totalSupply - (chainSupply_ * 10**decimals());
        _basicTransfer(msg.sender, bridgeAddress, tokenAmountToBurn);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function totalSupply() public view virtual override returns (uint256) {
        if (!bridgeEnabled()) {
            return super.totalSupply();
        }
        return super.totalSupply() - super.balanceOf(bridgeAddress);
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
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
        
        if (sender != pair) {
            require(
                !isBlacklisted[sender] && !isBlacklisted[recipient],
                "Cannot transfer tokens from blacklisted address"
            );
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
        Fees memory currentFees;

        bool useLaunchFee = launchFee > 0 &&
            !exemptFee[sender] &&
            !exemptFee[recipient] &&
            block.number < tradingStartBlock + deadline;

        bool useMarketFeeMultiplier = block.number <
            tradingStartBlock + marketFeeMultiplierCooldown;

        //set fee amount to zero if fees in contract are handled or exempted
        if (_liquidityLock || exemptFee[sender] || exemptFee[recipient])
            feeAmount = 0;

            //calculate fees
        else if (
            sender != pair &&
            recipient != pair &&
            transferFeeStatus &&
            !exemptFee[sender]
        ) {
            if (transferFee > 0) {
                uint256 transferFeeAmount = (amount * transferFee) / 1000;
                 if (transferFeeAmount > 0) {
                super._transfer(sender, marketingWallet, transferFeeAmount);
                super._transfer(sender, recipient, amount - transferFeeAmount);
                }
                return;
            } else {
                feeRatio = 0;
            }
        } else if (sender != pair && recipient != pair && !transferFeeStatus) {
            feeRatio = 0;
        } else if (recipient == pair && !useLaunchFee) {
            uint256 marketingFeeRatio = sellFees.marketing;
            if (useMarketFeeMultiplier) {
                marketingFeeRatio = marketingFeeRatio * marketFeeMultiplier;
            }
            feeRatio =
                sellFees.liquidity +
                marketingFeeRatio +
                sellFees.dev +
                sellFees.reward;
            currentFees = sellFees;
        } else if (!useLaunchFee) {
            feeRatio =
                buyFees.liquidity +
                buyFees.marketing +
                buyFees.dev +
                buyFees.reward;
            currentFees = buyFees;
        } else if (useLaunchFee) {
            feeRatio = launchFee;
        }

        feeAmount = (amount * feeRatio) / 100;

        //send fees if threshold has been reached
        //don't do this on buys, breaks swap
        if (providingLiquidity && sender != pair && feeAmount > 0)
            handleFees(feeRatio, currentFees);
        //rest to recipient
        super._transfer(sender, recipient, amount - feeAmount);
        if (feeAmount > 0 && feeRatio > 0) {
            super._transfer(sender, address(this), feeAmount);
        }
    }

    function handleFees(uint256 feeRatio, Fees memory swapFees)
        private
        lockLiquidity
    {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= tokenLiquidityThreshold) {
            if (tokenLiquidityThreshold > 1) {
                contractBalance = tokenLiquidityThreshold;
            }

            // Split the contract balance into halves
            uint256 denominator = feeRatio * 2;
            uint256 tokensToAddLiquidityWith = (contractBalance *
                swapFees.liquidity) / denominator;
            uint256 toSwap = contractBalance - tokensToAddLiquidityWith;

            uint256 initialBalance = address(this).balance;
            if(toSwap > 0){
            swapTokensForETH(toSwap);
            }

            uint256 deltaBalance = address(this).balance - initialBalance;
            uint256 unitBalance = deltaBalance /
                (denominator - swapFees.liquidity);
            uint256 bnbToAddLiquidityWith = unitBalance * swapFees.liquidity;

            if (bnbToAddLiquidityWith > 0) {
                // Add liquidity to pancake
                addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
            }

            uint256 marketingAmount = unitBalance * 2 * swapFees.marketing;
            if (marketingAmount > 0) {
                payable(marketingWallet).sendValue(marketingAmount);
            }

            uint256 devAmount = unitBalance * 2 * swapFees.dev;
            if (devAmount > 0) {
                payable(devWallet).sendValue(devAmount);
            }

            uint256 rewardAmount = unitBalance * 2 * swapFees.reward;
            if (rewardAmount > 0) {
                payable(rewardWallet).sendValue(rewardAmount);
            }
        }
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
            owner(),
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
        uint256 _liquidity,
        uint256 _dev,
        uint256 _reward
    ) external onlyOwner {
        buyFees = Fees(_marketing, _liquidity, _dev, _reward);
        require(
            (_marketing + _liquidity + _dev + _reward) <= 49,
            "Must keep fees at 49% or less"
        );
    }

    function updateSellFees(
        uint256 _marketing,
        uint256 _liquidity,
        uint256 _dev,
        uint256 _reward
    ) external onlyOwner {
        sellFees = Fees(_marketing, _liquidity, _dev, _reward);
        require(
            (_marketing + _liquidity + _dev + _reward) <= 49,
            "Must keep fees at 49% or less"
        );
    }

    function enableTrading(bool _flag) external onlyOwner {
        require(tradingEnabled != _flag, "You must provide a different status other than the current value in order to update it");
        tradingEnabled = _flag;
        providingLiquidity = _flag;
        tradingStartBlock = block.number;
    }

    function updateDeadline(uint256 _deadline) external onlyOwner {
        require(!tradingEnabled, "Cannot change when trading has started");
        require(
            deadline != _deadline,
            "You must provide a different deadline other than the current value in order to update it"
        );
        deadline = _deadline;
    }

    function updateMarketingWallet(address newWallet) external onlyOwner {
        require(
            marketingWallet != newWallet,
            "You must provide a different address other than the current value in order to update it"
        );
        marketingWallet = newWallet;
    }

    function updateDevWallet(address newWallet) external onlyOwner {
        require(
            devWallet != newWallet,
            "You must provide a different address other than the current value in order to update it"
        );
        devWallet = newWallet;
    }

    function updateRewardWallet(address newWallet) external onlyOwner {
        require(
            rewardWallet != newWallet,
            "You must provide a different address other than the current value in order to update it"
        );
        rewardWallet = newWallet;
    }

    function updateCooldown(bool flag, uint256 time) external onlyOwner {
        coolDownTime = time * 1 seconds;
        coolDownEnabled = flag;
        require(time <= 60, "Cooldown timer cannot exceed 1 minutes");
    }

    function updateIsBlacklisted(address account, bool flag) public onlyOwner {
        require(
            isBlacklisted[account] != flag,
            "You must provide a different exempt address or status other than the current value in order to update it"
        );
        isBlacklisted[account] = flag;
    }

    function bulkUpdateIsBlacklisted(address[] memory accounts, bool flag)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            updateIsBlacklisted(accounts[i], flag);
        }
    }

    function updateExemptFee(address _address, bool flag) external onlyOwner {
        require(
            exemptFee[_address] != flag,
            "You must provide a different exempt address or status other than the current value in order to update it"
        );
        exemptFee[_address] = flag;
    }

    function updateExemptMaxSellLimit(address _address, bool flag)
        external
        onlyOwner
    {
        require(
            exemptMaxSellLimit[_address] != flag,
            "You must provide a different max sell limit other than the current max sell limit in order to update it"
        );
        exemptMaxSellLimit[_address] = flag;
    }

    function updateExemptMaxBuyLimit(address _address, bool flag)
        external
        onlyOwner
    {
        require(
            exemptMaxBuyLimit[_address] != flag,
            "You must provide a different max buy limit other than the current max buy limit in order to update it"
        );
        exemptMaxBuyLimit[_address] = flag;
    }

    function updateExemptMaxWalletLimit(address _address, bool flag)
        external
        onlyOwner
    {
        require(
            exemptMaxWalletLimit[_address] != flag,
            "You must provide a different max wallet limit other than the current max wallet limit in order to update it"
        );
        exemptMaxWalletLimit[_address] = flag;
    }

    function setTransferFeeStatus(bool flag) external onlyOwner {
        require(
            transferFeeStatus != flag,
            "You must provide a different status other than the current transfer fee status in order to update it"
        );
        transferFeeStatus = flag;
    }

    function updateTransferFee(uint256 _ratio) external onlyOwner {
        require(_ratio <= 1000 , "Cannot set transfer fee amount lower than 1000");
        require(
            _ratio != transferFee,
            "You must provide a different ratio other than the current transfer fee in order to update it"
        );
        transferFee = _ratio; // %1000
    }

    function bulkExemptFee(address[] memory accounts, bool flag)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            exemptFee[accounts[i]] = flag;
        }
    }

    function setUpdateLimit(bool flag) external onlyOwner {
        require(
            updateLimit != flag,
            "You must provide a different value other than the current updaleLimit in order to update it"
        );
        updateLimit = flag;
    }

    function updateMaxBuyTxLimit(uint256 maxBuy) external onlyOwner {
        require(
            !updateLimit || maxBuy >= super.totalSupply() / 1000,
            "Cannot set max buy amount lower than 0.1% of tokens"
        );
        require(
            maxBuy * 10**decimals() != maxBuyLimit,
            "You must provide a different amount other than the current max sell limit in order to update it"
        );
        maxBuyLimit = maxBuy * 10**decimals();

    }

    function updateMaxSellTxLimit(uint256 maxSell) external onlyOwner {
        require(
            !updateLimit || maxSell >= super.totalSupply() / 1000,
            "Cannot set max sell amount lower than 0.1% of tokens%"
        );
        require(
            maxSell * 10**decimals() != maxSellLimit,
            "You must provide a different amount other than the current max sell limit in order to update it"
        );
        maxSellLimit = maxSell * 10**decimals();
    }

    function updateMaxWalletLimit(uint256 amount) external onlyOwner {
        require(
            !updateLimit || amount >= super.totalSupply() / 1000,
            "Cannot set max wallet amount lower than 0.1% of tokens"
        );
        require(
            amount * 10**decimals() != maxWalletLimit,
            "You must provide a different amount other than the current max wallet limit in order to update it"
        );
        maxWalletLimit = amount * 10**decimals();
    }

    function updateMarketFeeMultiplier(
        uint256 marketFeeMultiplierCooldown_,
        uint8 marketFeeMultiplier_
    ) external onlyOwner {
        marketFeeMultiplierCooldown = marketFeeMultiplierCooldown_;
        marketFeeMultiplier = marketFeeMultiplier_;
    }

    function changeRouter(address newRouter)
        external
        onlyOwner
        returns (address _pair)
    {
        require(newRouter != address(0), "newRouter address cannot be 0");
        require(
            router != IRouter(newRouter),
            "You must provide a different router other than the current router address in order to update it"
        );
        IRouter _router = IRouter(newRouter);

        _pair = IFactory(_router.factory()).getPair(
            address(this),
            _router.WETH()
        );
        if (_pair == address(0)) {
            // Pair doesn't exist
            _pair = IFactory(_router.factory()).createPair(
                address(this),
                _router.WETH()
            );
        }

        // Set the pair of the contract variables
        pair = _pair;
        // Set the router of the contract variables
        router = _router;
    }

    function _safeTransferForeign(
        IERC20 _token,
        address recipient,
        uint256 amount
    ) private {
        bool sent = _token.transfer(recipient, amount);
        require(sent, "Token transfer failed.");
    }

    function clearStuckBnb(uint256 amount, address receiveAddress)
        external
        onlyOwner
    {
        payable(receiveAddress).transfer(amount);
    }

    function clearStuckToken(
        IERC20 _token,
        address receiveAddress,
        uint256 amount
    ) external onlyOwner {
        _safeTransferForeign(_token, receiveAddress, amount);
    }

    function safeTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        _basicTransfer(sender, recipient, amount);
    }

    // fallbacks
    receive() external payable {}

    function bridgeEnabled() public view returns (bool) {
        return bridgeAddress != address(0);
    }

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

    function bridgeSupply() public view returns (uint256) {
        return super.balanceOf(bridgeAddress);
    }
}

 /*
██╗░░██╗██████╗░  ░█████╗░░█████╗░██╗███╗░░██╗
╚██╗██╔╝██╔══██╗  ██╔══██╗██╔══██╗██║████╗░██║
░╚███╔╝░██████╔╝  ██║░░╚═╝██║░░██║██║██╔██╗██║
░██╔██╗░██╔══██╗  ██║░░██╗██║░░██║██║██║╚████║
██╔╝╚██╗██║░░██║  ╚█████╔╝╚█████╔╝██║██║░╚███║
╚═╝░░╚═╝╚═╝░░╚═╝  ░╚════╝░░╚════╝░╚═╝╚═╝░░╚══╝




        
███╗░░░███╗███████╗████████╗░█████╗░██╗░░░██╗███████╗██████╗░░██████╗███████╗  ░░░░░░  ███╗░░██╗███████╗████████╗
████╗░████║██╔════╝╚══██╔══╝██╔══██╗██║░░░██║██╔════╝██╔══██╗██╔════╝██╔════╝  ░░░░░░  ████╗░██║██╔════╝╚══██╔══╝
██╔████╔██║█████╗░░░░░██║░░░███████║╚██╗░██╔╝█████╗░░██████╔╝╚█████╗░█████╗░░  █████╗  ██╔██╗██║█████╗░░░░░██║░░░
██║╚██╔╝██║██╔══╝░░░░░██║░░░██╔══██║░╚████╔╝░██╔══╝░░██╔══██╗░╚═══██╗██╔══╝░░  ╚════╝  ██║╚████║██╔══╝░░░░░██║░░░
██║░╚═╝░██║███████╗░░░██║░░░██║░░██║░░╚██╔╝░░███████╗██║░░██║██████╔╝███████╗  ░░░░░░  ██║░╚███║██║░░░░░░░░██║░░░
╚═╝░░░░░╚═╝╚══════╝░░░╚═╝░░░╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═════╝░╚══════╝  ░░░░░░  ╚═╝░░╚══╝╚═╝░░░░░░░░╚═╝░░░

███╗░░░███╗░█████╗░██████╗░██╗░░██╗███████╗████████╗██████╗░██╗░░░░░░█████╗░░█████╗░███████╗  ░░░░░░
████╗░████║██╔══██╗██╔══██╗██║░██╔╝██╔════╝╚══██╔══╝██╔══██╗██║░░░░░██╔══██╗██╔══██╗██╔════╝  ░░░░░░
██╔████╔██║███████║██████╔╝█████═╝░█████╗░░░░░██║░░░██████╔╝██║░░░░░███████║██║░░╚═╝█████╗░░  █████╗
██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗░██╔══╝░░░░░██║░░░██╔═══╝░██║░░░░░██╔══██║██║░░██╗██╔══╝░░  ╚════╝
██║░╚═╝░██║██║░░██║██║░░██║██║░╚██╗███████╗░░░██║░░░██║░░░░░███████╗██║░░██║╚█████╔╝███████╗  ░░░░░░
╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚══════╝░░░╚═╝░░░╚═╝░░░░░╚══════╝╚═╝░░╚═╝░╚════╝░╚══════╝  ░░░░░░

██████╗░░█████╗░██╗░░░██╗███╗░░░███╗███████╗███╗░░██╗████████╗  ░██████╗██╗░░░██╗░██████╗████████╗███████╗███╗░░░███╗
██╔══██╗██╔══██╗╚██╗░██╔╝████╗░████║██╔════╝████╗░██║╚══██╔══╝  ██╔════╝╚██╗░██╔╝██╔════╝╚══██╔══╝██╔════╝████╗░████║
██████╔╝███████║░╚████╔╝░██╔████╔██║█████╗░░██╔██╗██║░░░██║░░░  ╚█████╗░░╚████╔╝░╚█████╗░░░░██║░░░█████╗░░██╔████╔██║
██╔═══╝░██╔══██║░░╚██╔╝░░██║╚██╔╝██║██╔══╝░░██║╚████║░░░██║░░░  ░╚═══██╗░░╚██╔╝░░░╚═══██╗░░░██║░░░██╔══╝░░██║╚██╔╝██║
██║░░░░░██║░░██║░░░██║░░░██║░╚═╝░██║███████╗██║░╚███║░░░██║░░░  ██████╔╝░░░██║░░░██████╔╝░░░██║░░░███████╗██║░╚═╝░██║
╚═╝░░░░░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░╚═╝╚══════╝╚═╝░░╚══╝░░░╚═╝░░░  ╚═════╝░░░░╚═╝░░░╚═════╝░░░░╚═╝░░░╚══════╝╚═╝░░░░░╚═╝

░░░░░░  ░██████╗░░█████╗░███╗░░░███╗███████╗███████╗██╗  ░█████╗░███╗░░██╗██████╗░
░░░░░░  ██╔════╝░██╔══██╗████╗░████║██╔════╝██╔════╝██║  ██╔══██╗████╗░██║██╔══██╗
█████╗  ██║░░██╗░███████║██╔████╔██║█████╗░░█████╗░░██║  ███████║██╔██╗██║██║░░██║
╚════╝  ██║░░╚██╗██╔══██║██║╚██╔╝██║██╔══╝░░██╔══╝░░██║  ██╔══██║██║╚████║██║░░██║
░░░░░░  ╚██████╔╝██║░░██║██║░╚═╝░██║███████╗██║░░░░░██║  ██║░░██║██║░╚███║██████╔╝
░░░░░░  ░╚═════╝░╚═╝░░╚═╝╚═╝░░░░░╚═╝╚══════╝╚═╝░░░░░╚═╝  ╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░

███╗░░░███╗░█████╗░██████╗░███████╗
████╗░████║██╔══██╗██╔══██╗██╔════╝
██╔████╔██║██║░░██║██████╔╝█████╗░░
██║╚██╔╝██║██║░░██║██╔══██╗██╔══╝░░
██║░╚═╝░██║╚█████╔╝██║░░██║███████╗
╚═╝░░░░░╚═╝░╚════╝░╚═╝░░╚═╝╚══════╝
*/