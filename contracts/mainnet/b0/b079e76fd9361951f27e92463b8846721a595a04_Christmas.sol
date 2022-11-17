/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

abstract contract Owned {
    event OwnerUpdated(address indexed user, address indexed newOwner);
    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnerUpdated(address(0), msg.sender);
    }

    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnerUpdated(msg.sender, newOwner);
    }
}

contract ExcludedFromFeeList is Owned {
    mapping(address => bool) internal _isExcludedFromFee;

    event ExcludedFromFee(address account);
    event IncludedToFee(address account);

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludedToFee(account);
    }

    function excludeMultipleAccountsFromFee(address[] calldata accounts)
        public
        onlyOwner
    {
        uint8 len = uint8(accounts.length);
        for (uint8 i = 0; i < len; ) {
            _isExcludedFromFee[accounts[i]] = true;
            unchecked {
                ++i;
            }
        }
    }
}

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max)
            allowance[from][msg.sender] = allowed - amount;

        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        balanceOf[from] -= amount;
        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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
}

abstract contract DexBase {
    bool inSwapAndLiquify;
    IUniswapV2Router public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        uniswapV2Router = IUniswapV2Router(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                USDT
            );
    }
}

contract Distributor is Owned {
    function transferUSDT(
        IERC20 usdt,
        address to,
        uint256 amount
    ) external onlyOwner {
        usdt.transfer(to, amount);
    }
}

abstract contract DividendFee is Owned, DexBase, ERC20 {
    uint256 constant buyMarketingFee = 2;

    uint256 constant sellMarketingFee = 1;
    uint256 constant sellLiqFee = 1;
    uint256 constant sellBoundFee = 4;

    address constant marketingAddr = 0xF4ab25783664d9DAB56B2F963733e818ae5BCD22;
    address constant boundAddr = 0x21DbDf6554F904e91636Cbf33924c16659CDE177;

    Distributor public distributor;

    bool public swapToDividend = true;
    uint256 public numTokenToDividend = 200 * 1e18;
    uint256 public constant distributorGas = 500000;

    constructor() {
        allowance[address(this)][address(uniswapV2Router)] = type(uint256).max;
        distributor = new Distributor();
    }

    function shouldSwapToDiv(address sender) internal view returns (bool) {
        uint256 contractTokenBalance = balanceOf[address(this)];
        bool overMinTokenBalance = contractTokenBalance >= numTokenToDividend;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            sender != uniswapV2Pair &&
            swapToDividend
        ) {
            return true;
        } else {
            return false;
        }
    }

    function swapAndToDividend() internal lockTheSwap {
        uint256 _t_ = buyMarketingFee +
            sellMarketingFee +
            sellLiqFee +
            sellBoundFee;
        uint256 allamount = numTokenToDividend;
        uint256 toLpAmount = (allamount * sellLiqFee) / _t_;
        uint256 toBoundAmount = (allamount * sellBoundFee) / _t_;
        uint256 toMarket = allamount - toLpAmount - toBoundAmount;

        swapAndLiquify(toLpAmount);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDT);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            toMarket + toBoundAmount,
            0,
            path,
            address(distributor),
            block.timestamp
        );

        uint256 usd = IERC20(USDT).balanceOf(address(this));
        if (usd > 1 ether) {
            IERC20(USDT).transfer(marketingAddr, usd);
        }

        uint256 USDAmount = IERC20(USDT).balanceOf(address(distributor));
        uint256 toMarketUSDT = (USDAmount * toMarket) /
            (toMarket + toBoundAmount);

        try
            distributor.transferUSDT(IERC20(USDT), marketingAddr, toMarketUSDT)
        {} catch {}

        try
            distributor.transferUSDT(
                IERC20(USDT),
                boundAddr,
                USDAmount - toMarketUSDT
            )
        {} catch {}
    }

    function swapAndLiquify(uint256 contractTokenBalance) internal lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = IERC20(USDT).balanceOf(address(this));

        // swap tokens for ETH
        swapTokensForTokens(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = IERC20(USDT).balanceOf(address(this)) -
            initialBalance;

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
    }

    function swapTokensForTokens(uint256 tokenAmount) public {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDT);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(distributor),
            block.timestamp
        );
        uint256 amount = IERC20(USDT).balanceOf(address(distributor));
        distributor.transferUSDT(IERC20(USDT), address(this), amount);
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) public {
        // add the liquidity
        IERC20(USDT).approve(address(uniswapV2Router), usdtAmount);
        uniswapV2Router.addLiquidity(
            address(this),
            address(USDT),
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            0x05793B5E58CABf869B1425a503A37D54BBf88DCd,
            block.timestamp
        );
    }

    function _takeDividendFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        if (sender == uniswapV2Pair) {
            uint256 dividendAmount = (amount * buyMarketingFee) / 100;
            super._transfer(sender, address(this), dividendAmount);
            return dividendAmount;
        } else {
            uint256 dividendAmount = (amount *
                (sellMarketingFee + sellLiqFee + sellBoundFee)) / 100;
            super._transfer(sender, address(this), dividendAmount);
            return dividendAmount;
        }
    }

    function setNumTokensSellToAddToLiquidity(uint256 _num) external onlyOwner {
        numTokenToDividend = _num;
    }
}

contract Christmas is ExcludedFromFeeList, DividendFee {
    uint256 private constant _totalSupply = 2100_0000 * 1e18;

    uint256 badBlock = 20;
    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;

    uint256 public _maxHavAmount = 20_0000 * 1e18;
    mapping(address => bool) isHavLimitExempt;

    constructor() ERC20("Christmas", "Christmas", 18) DividendFee() {
        _mint(msg.sender, _totalSupply);
        excludeFromFee(msg.sender);
        excludeFromFee(address(this));

        isHavLimitExempt[msg.sender] = true;
        isHavLimitExempt[address(this)] = true;
        isHavLimitExempt[address(0)] = true;
        isHavLimitExempt[uniswapV2Pair] = true;
    }

    function shouldTakeFee(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            return false;
        }
        if (recipient == uniswapV2Pair || sender == uniswapV2Pair) {
            return true;
        }
        return false;
    }

    function launch() internal {
        require(launchedAt == 0, "Already launched boi");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
    }

    function setIsTxLimitExempt(address holder, bool havExempt)
        external
        onlyOwner
    {
        isHavLimitExempt[holder] = havExempt;
    }

    function setMaxHavAmount(uint256 maxHavAmount) external onlyOwner {
        _maxHavAmount = maxHavAmount;
    }

    function takeFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        if (launchedAt + badBlock >= block.number) {
            uint256 some = amount / (20);
            uint256 antAmount = amount - (some);
            super._transfer(sender, address(this), antAmount);
            return some;
        }

        uint256 divAmount = _takeDividendFee(sender, amount);
        return amount - divAmount;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        if (!launched() && recipient == uniswapV2Pair) {
            require(balanceOf[sender] > 0);
            launch();
        }

        require(
            recipient == uniswapV2Pair ||
                balanceOf[recipient] + amount <= _maxHavAmount ||
                isHavLimitExempt[recipient],
            "HAV Limit Exceeded"
        );

        //swap to dividend
        if (inSwapAndLiquify) {
            super._transfer(sender, recipient, amount);
            return;
        }

        if (shouldSwapToDiv(sender)) {
            swapAndToDividend();
        }
        // transfer token
        if (shouldTakeFee(sender, recipient)) {
            uint256 transferAmount = takeFee(sender, amount);
            super._transfer(sender, recipient, transferAmount);
        } else {
            super._transfer(sender, recipient, amount);
        }
    }
}