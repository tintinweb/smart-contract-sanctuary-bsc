/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

// SPDX-License-Identifier: MIT

/** Not All Storms Come To Disrupt Your Life, Some Come to Clean Your Path...
WTC is Going To Bring Back The Thunderstorm of Green Crypto Market */

pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Owner is Context {

    address private _owner;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        require(_owner == _msgSender(), "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnerSet(address(0), msgSender);
    }

    /**
     * @dev Change owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Return owner address 
     */
    function getOwner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Renounce ownership 
     */
    function renounceOwnership() public virtual isOwner {
        _owner = (address(0));
    }
}

interface IERC20 {   
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity ^0.8.10;

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

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity ^0.8.10;

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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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


pragma solidity ^0.8.10;
contract WorldCupThunder is ERC20, Owner {
    using SafeMath for uint256;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    bool private swapping;
    
    uint256 private launchtimestamp; // FOR LAUNCH TIMESTAMP

    address payable private marketingWallet;
    address payable private devWallet;

    uint256 private maxTransactionAmount;
    uint256 private swapTokensAtAmount;
    uint256 private maxWallet;
    uint256 private TotalSupply = totalSupply();

    bool private tradingActive = false;
    bool private swapEnabled = false;

    uint256 public buyTotalFees;
    uint256 public buyMarketingFee;
    uint256 public buyDevFee;

    uint256 public sellTotalFees;
    uint256 public sellMarketingFee;
    uint256 public sellDevFee;

    uint256 private tokensForMarketing;
    uint256 private tokensForDev;


    address private constant deadAddress = address(0xdead);
    
    bool private tradingEnabled = false;

    mapping(address => bool) private canTransferBeforeTradingIsEnabled;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedMaxTransactionAmount;
    mapping(address => bool) private _isBot;

    event TradingEnabled();
    event updateMarketingWallet(address wallet);
    event updateDevWallet(address wallet);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event blackList(address); // TO BLACKLIST THE BOT
    event unblackList(address); // TO REMOVE THE BLACKLISTED BOTevent SwapAndLiquify(
    event OwnerForcedSwapBack(uint256 timestamp);
    

     constructor(uint256 initialSupply) ERC20("World Cup Thunder", "WCT") {
        marketingWallet = payable(0x3536b1aA369eD69Ec2764276cafcE8345300BBB8);
        devWallet = payable(0x3536b1aA369eD69Ec2764276cafcE8345300BBB8);      
        /*
            _mint is an internal function in that is only called here,
            and CANNOT be called ever again
        */
        _mint(msg.sender, initialSupply);

        uint256 _buyMarketingFee = 25;
        uint256 _buyDevFee = 2;

        uint256 _sellMarketingFee = 25;
        uint256 _sellDevFee = 3;
        
        maxTransactionAmount = (TotalSupply * 100) / 10000; // 1% maxTransactionAmountTxn
        maxWallet = (TotalSupply * 200) / 10000; // 2% maxWallet
        swapTokensAtAmount = (TotalSupply * 5) / 10000; // 0.05% swap wallet

        buyMarketingFee = _buyMarketingFee;
        buyDevFee = _buyDevFee;
        buyTotalFees = buyMarketingFee + buyDevFee;

        sellMarketingFee = _sellMarketingFee;
        sellDevFee = _sellDevFee;
        sellTotalFees = sellMarketingFee + sellDevFee;

        // exclude from paying fees or having max transaction amount
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[devWallet] = true;
        _isExcludedFromFees[marketingWallet] = true;

        _isExcludedMaxTransactionAmount[address(this)] = true;
        _isExcludedMaxTransactionAmount[msg.sender] = true;
        _isExcludedMaxTransactionAmount[devWallet] = true;
        _isExcludedMaxTransactionAmount[marketingWallet] = true;

        canTransferBeforeTradingIsEnabled[getOwner()] = true;
        canTransferBeforeTradingIsEnabled[address(this)] = true;
    }


    receive() external payable {}

    function enableTrading() external isOwner {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
        swapEnabled = true;
        launchtimestamp = block.timestamp;
        emit TradingEnabled();
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        excludeFromMaxTransaction(address(_uniswapV2Router), true);

        uniswapV2Router = _uniswapV2Router;

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        excludeFromMaxTransaction(address(uniswapV2Pair), true);
    }
  
    function updateBuyFees(uint256 _marketingFee, uint256 _devFee) external isOwner {
        buyMarketingFee = _marketingFee;
        buyDevFee = _devFee;
        buyTotalFees = buyMarketingFee + buyDevFee;

        require(buyTotalFees <= 25, "Cannot set buy fee more than 25%");
    }

    function updateSellFees(uint256 _marketingFee, uint256 _devFee) external isOwner {
        sellMarketingFee = _marketingFee;
        sellDevFee = _devFee;
        sellTotalFees = sellMarketingFee + sellDevFee;

        require(sellTotalFees <= 50, "Cannot set sell fee more than 25%");
    }

    function excludeFromFees(address account, bool excluded) public isOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) public isOwner{
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    function setCanTransferBefore(address wallet, bool enable) external isOwner {
        canTransferBeforeTradingIsEnabled[wallet] = enable;
    }

    function setMarketingWallet(address wallet) external isOwner {
        _isExcludedFromFees[wallet] = true;
        marketingWallet = payable(wallet);
        emit updateMarketingWallet(wallet);
    }

    function setDevWallet(address wallet) external isOwner {
        _isExcludedFromFees[wallet] = true;
        devWallet = payable(wallet);
        emit updateDevWallet(wallet);
    }

    function isBot(address account) public view returns (bool) {
        return _isBot[account];
    }

    function addBot(address account) public isOwner {
        _isBot[account] = true;
        emit blackList(account);
    }

    function removeBot(address account) public isOwner {
        _isBot[account] = false;
        emit unblackList(account);
    }

    function _transfer(address from, address to, uint256 amount) internal override {

        require(from != address(0), "IERC20: transfer from the zero address");
        require(to != address(0), "IERC20: transfer to the zero address");
        require(!_isBot[from] && !_isBot[to]);
        
        if (!canTransferBeforeTradingIsEnabled[from]) {
            require(tradingEnabled, "Trading not enabled yet");          
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (
                from != getOwner() &&
                to != getOwner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !swapping
            ) {
                if (!tradingEnabled) {
                    require(
                        _isExcludedFromFees[from] || _isExcludedFromFees[to],
                        "Trading is not active."
                    );
                }
            }
            //when buy
        if (
          from == uniswapV2Pair && !_isExcludedMaxTransactionAmount[to]
        ) {
          require(
            amount <= maxTransactionAmount,
            "Buy transfer amount exceeds the maxTransactionAmount."
          );
          require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded 1");
        }

        //when sell
        else if (
          to == uniswapV2Pair &&
          !_isExcludedMaxTransactionAmount[from]
        ) {
          require(
            amount <= maxTransactionAmount,
            "Sell transfer amount exceeds the maxTransactionAmount."
          );
        } else if (!_isExcludedMaxTransactionAmount[to]) {
          require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded 2");
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

            if (
            canSwap &&
            swapEnabled &&
            !swapping &&
            to == uniswapV2Pair &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
            ) {
            swapping = true;  

            swapBack();

            swapping = false;   
            }

        bool takeFee = !swapping;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
        takeFee = false;
        }

            uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            // on sell
            if (to == uniswapV2Pair && sellTotalFees > 0) {
                fees = amount.mul(sellTotalFees).div(100);
                tokensForDev += (fees * sellDevFee) / sellTotalFees;
                tokensForMarketing += (fees * sellMarketingFee) / sellTotalFees;
            }
            // on buy
            else if (from == uniswapV2Pair && buyTotalFees > 0) {
                fees = amount.mul(buyTotalFees).div(100);
                tokensForDev += (fees * buyDevFee) / buyTotalFees;
                tokensForMarketing += (fees * buyMarketingFee) / buyTotalFees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }
        super._transfer(from, to, amount);    
    }

    function swapTokensForETH(uint256 tokenAmount) private {
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
    
    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForMarketing +
        tokensForDev;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
        return;
        }

    
        uint256 initialETHBalance = address(this).balance;

        swapTokensForETH(contractBalance);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForMarketing = ethBalance.mul(tokensForMarketing).div(
        totalTokensToSwap
        );
        uint256 ethForDev = ethBalance.mul(tokensForDev).div(totalTokensToSwap);

        tokensForMarketing = 0;
        tokensForDev = 0;

        (bool success, ) = address(marketingWallet).call{ value: ethForMarketing }(
        ""
        );
        (success, ) = address(devWallet).call{ value: ethForDev }("");

    }

    // force Swap back if slippage above 49% for launch. fix router clog
    function forceSwapBack() external isOwner {
        uint256 contractBalance = balanceOf(address(this));
        require(
        contractBalance >= totalSupply() / 100,
        "Can only swap back if more than 1% of tokens stuck on contract"
        );
        swapping = true;
        swapBack();
        swapping = false;

        emit OwnerForcedSwapBack(block.timestamp);
    }

}