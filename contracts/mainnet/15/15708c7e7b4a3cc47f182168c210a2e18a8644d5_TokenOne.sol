/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {uint256 c = a + b; if(c < a) return(false, 0); return(true, c);}}

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b > a) return(false, 0); return(true, a - b);}}

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if (a == 0) return(true, 0); uint256 c = a * b;
        if(c / a != b) return(false, 0); return(true, c);}}

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a / b);}}

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a % b);}}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b <= a, errorMessage); return a - b;}}

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a / b;}}

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a % b;}}
    }

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

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** 
    * _tokengeneration function is used only once when creating the total supply of the token. 
    *
    * It's an internal function so it can never be called from outside.
     */
    function _tokengeneration(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: generation to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract TokenOne is ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address payable;

    IRouter public router;
    address public pair;

    bool private _liquidityMutex = false;
    bool public providingLiquidity = false;
    bool public tradingEnabled = false;

    uint256 _totalSupply = 1e11 * 10**decimals();
    uint256 swapTokenTreshold = 1000000000 * 10**decimals();
    uint256 maxTxLimit = 1000000000 * 10**decimals();
    uint256 maxWalletLimit = 1000000000 * 10**decimals();

    uint256 public genesis_block;
    uint256 private deadline = 5;
    uint256 private launchtax = 99;

    address private marketingWallet;
    address private devWallet;
    address private buybackWallet;
    address private lpFeeReceiver;
    address private teamWallet;

	address public constant deadWallet = 0x000000000000000000000000000000000000dEaD;

    struct Taxes {
        uint256 marketing;
        uint256 liquidity;
        uint256 buyback;
        uint256 dev;
        uint256 team;
    }

    Taxes private buyTaxes = Taxes(4, 4, 0, 0, 0);
    Taxes private sellTaxes = Taxes(4, 4, 0, 0, 0);

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public allowedTransfer;

    //Anti Dump
    mapping(address => uint256) private _lastSell;
    bool public coolDownEnabled = true;
    uint256 public coolDownTime = 60 seconds;

    modifier mutexLock() {
        if (!_liquidityMutex) {
            _liquidityMutex = true;
            _;
            _liquidityMutex = false;
        }
    }

    constructor(
        address _routerAddr,
        address _marketingWallet,
        address _lpFeeReceiver,
        address _teamWallet,
        address _buybackWallet ) ERC20("TestOnetoken2","TOT2") {
        _tokengeneration(msg.sender, _totalSupply);
        isFeeExempt[msg.sender] = true;

        IRouter _router = IRouter(_routerAddr);
        // Create a pancake pair for this new token
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
    
        router = _router;
        pair = _pair;

        marketingWallet = _marketingWallet;
        devWallet = msg.sender;
        lpFeeReceiver = _lpFeeReceiver;
        teamWallet = _teamWallet;
        
        isFeeExempt[address(this)] = true;
        isFeeExempt[_marketingWallet] = true;
        isFeeExempt[_teamWallet] = true;
        isFeeExempt[_buybackWallet] = true;
        isFeeExempt[deadWallet] = true;

        allowedTransfer[address(this)] = true;
        allowedTransfer[owner()] = true;
        allowedTransfer[pair] = true;
        allowedTransfer[_marketingWallet] = true;
        allowedTransfer[_teamWallet] = true;
        allowedTransfer[_buybackWallet] = true;
        allowedTransfer[deadWallet] = true;

    }

     // fallbacks
    receive() external payable {}

    /*==============================================
    BASIC ERC20 FUNCTIONS
    ===============================================*/

      function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        override
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /*==============================================
    Extended custom FUNCTIONS
    ===============================================*/

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require( amount > 0 , "Transfer amount must be greater than zero");

        if(!isFeeExempt[sender] && !isFeeExempt[recipient]) {
            require(tradingEnabled, "Trading not enabled");
        }

        if(sender == pair && !isFeeExempt[recipient] && !_liquidityMutex) {
            require(amount <= maxTxLimit, "You are exceeding maxTxLimit");
            require(balanceOf(recipient).add(amount) <= maxWalletLimit, "You are exceeding maxWalletLimit");
        }

        if(sender != pair && !isFeeExempt[recipient] && !isFeeExempt[sender] && !_liquidityMutex) {
            require(amount <= maxWalletLimit, "You are exceeding maxTxLimit");
            if(recipient != pair) {
                require(balanceOf(recipient).add(amount) <= maxWalletLimit, "You are exceeding maxWalletLimit");
            }
            if(coolDownEnabled) {
                uint256 timePassed = block.timestamp - _lastSell[sender];
                require(timePassed >= coolDownTime, "Cooldown enabled");
                _lastSell[sender] = block.timestamp;
            }
        }

        uint256 feeswap;
        uint256 feesum;
        uint256 fee;
        Taxes memory currentTaxes;

        bool useLaunchFee = !isFeeExempt[sender] &&
            !isFeeExempt[recipient] &&
            block.number < genesis_block + deadline;

        if(_liquidityMutex || isFeeExempt[sender] || isFeeExempt[recipient])
            fee = 0;

        else if(recipient == pair && !useLaunchFee) {
            feeswap = feeswap.add(sellTaxes.liquidity).add(sellTaxes.marketing).add(sellTaxes.team).add(sellTaxes.buyback).add(sellTaxes.dev);
            feesum = feeswap;
            currentTaxes = sellTaxes;
        } else if(!useLaunchFee) {
            feeswap = feeswap.add(buyTaxes.liquidity).add(buyTaxes.marketing).add(buyTaxes.team).add(buyTaxes.buyback).add(buyTaxes.dev);
            feesum = feeswap;
            currentTaxes = buyTaxes;
        } else if(useLaunchFee) {
            feeswap = launchtax;
            feesum = launchtax;
        }

        fee = (amount * feesum) / 100;

        //don't do this on buys, breaks swap
        if (providingLiquidity && sender != pair) handle_fees(feeswap, currentTaxes);

        //rest to recipient
        super._transfer(sender, recipient, amount.sub(fee));
        if (fee > 0) {
            //send the fee to the contract
            if (feeswap > 0) {
                uint256 feeAmount = (amount * feeswap) / 100;
                super._transfer(sender, address(this), feeAmount);
            }

        }
        
    }

    function handle_fees(uint256 feeswap, Taxes memory swapTaxes) private mutexLock {
        uint256 contractBalance = balanceOf(address(this));
        if(contractBalance >= swapTokenTreshold) {
            if(swapTokenTreshold > 1) {
                contractBalance = swapTokenTreshold;
            }

             // split the balance in half
            uint256 denominator = feeswap * 2;
            uint256 tokensToAddLPWith = (contractBalance * swapTaxes.liquidity) / denominator;
            uint256 toSwap = contractBalance.sub(tokensToAddLPWith);

            uint256 initialBalance = address(this).balance;

            swapTokensForBnb(toSwap);

            uint256 deltaBalance = address(this).balance - initialBalance;
            uint256 unitBalance = deltaBalance / (denominator - swapTaxes.liquidity);
            uint256 bnbToAddLiquidityWith = unitBalance * swapTaxes.liquidity;

            if(bnbToAddLiquidityWith > 0 ){
                // add LP
                addLiquidity(tokensToAddLPWith, bnbToAddLiquidityWith);
            }

            uint256 marketingFee = unitBalance * 2 * swapTaxes.marketing;
            if (marketingFee > 0) {
                payable(marketingWallet).sendValue(marketingFee);
            }

            uint256 teamFee = unitBalance * 2 * swapTaxes.team;
            if (teamFee > 0) {
                payable(teamWallet).sendValue(teamFee);
            }

            uint256 buybackFee = unitBalance * 2 * swapTaxes.buyback;
            if (buybackFee > 0) {
                payable(buybackWallet).sendValue(buybackFee);
            }

            uint256 devFee = unitBalance * 2 * swapTaxes.dev;
            if (devFee > 0) {
                payable(devWallet).sendValue(devFee);
            }

        }

    }

    function swapTokensForBnb(uint256 tokenAmount) internal {
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
        router.addLiquidityETH{ value: ethAmount }(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(lpFeeReceiver),
            block.timestamp
        );
    }

    function updateLiquidityProvide(bool state) external onlyOwner {
        //update liquidity providing state
        providingLiquidity = state;
    }

    function updateSwapTokenTreshold(uint256 new_amount) external onlyOwner {
        //update the treshhold
        swapTokenTreshold = new_amount * 10**decimals();
    }

      function SetBuyTaxes(
        uint256 _marketing,
        uint256 _liquidity,
        uint256 _ops,
        uint256 _buyback,
        uint256 _dev
    ) external onlyOwner {
        buyTaxes = Taxes(_marketing, _liquidity,  _ops,  _buyback, _dev);
        require((_marketing + _liquidity + _ops + _buyback + _dev) <= 10, "Must keep fees at 15% or less");
    }

    function SetSellTaxes(
        uint256 _marketing,
        uint256 _liquidity,
        uint256 _ops,
        uint256 _buyback,
        uint256 _dev
    ) external onlyOwner {
        sellTaxes = Taxes(_marketing, _liquidity,  _ops,  _buyback, _dev);
        require((_marketing + _liquidity + _ops + _buyback + _dev) <= 15, "Must keep fees at 30% or less");
    }

      function updateRouterAndPair(address newRouter, address newPair) external onlyOwner {
        router = IRouter(newRouter);
        pair = newPair;
    }

    function EnableTrading() external onlyOwner {
        require(!tradingEnabled, "Cannot re-enable trading");
        tradingEnabled = true;
        providingLiquidity = true;
        genesis_block = block.number;
    }

    function updatedeadline(uint256 _deadline) external onlyOwner {
        require(!tradingEnabled, "Can't change when trading has started");
        deadline = _deadline;
    }

    function updateMarketingWallet(address newWallet) external onlyOwner {
        marketingWallet = newWallet;
    }

    function updateTeamWallet(address newWallet) external onlyOwner {
        teamWallet = newWallet;
    }

    function updateBuybackWallet(address newWallet) external onlyOwner {
        buybackWallet = newWallet;
    }

    function updateDevWallet(address newWallet) external onlyOwner {
        devWallet = newWallet;
    }

    function updateCooldown(bool state, uint256 time) external onlyOwner {
        coolDownTime = time * 1 seconds;
        coolDownEnabled = state;
        require(time <= 300, "cooldown timer cannot exceed 5 minutes");
    }

        function updateAllowedTransfer(address account, bool state) external onlyOwner {
        allowedTransfer[account] = state;
    }

    function bulkAllowedTransfer(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            allowedTransfer[accounts[i]] = state;
        }
    }

    function updateExemptFee(address _address, bool state) external onlyOwner {
        isFeeExempt[_address] = state;
    }

    function bulkExemptFee(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isFeeExempt[accounts[i]] = state;
        }
    }

    function updateMaxTxLimit(uint256 maxTx) external onlyOwner {
        maxTxLimit = maxTx * 10**decimals();
    }

    function updateMaxWalletLimit(uint256 maxWallet ) external onlyOwner {
        maxWalletLimit = maxWallet * 10**decimals();
    }

    function rescueBNB(uint256 weiAmount) external onlyOwner {
        payable(devWallet).transfer(weiAmount);
    }

    function rescueBSC20(address tokenAdd, uint256 amount) external onlyOwner {
        IERC20(tokenAdd).transfer(devWallet, amount);
    }
}