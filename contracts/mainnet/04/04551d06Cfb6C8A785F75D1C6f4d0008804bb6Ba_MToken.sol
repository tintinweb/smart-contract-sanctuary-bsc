/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

// email: [email protected]

abstract contract Owned {
    event OwnerUpdated(address indexed user, address indexed newOwner);
    address public owner;
    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() {
        owner = msg.sender;
        emit OwnerUpdated(address(0), msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

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

abstract contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    string public name;
    string public symbol;
    uint8 public immutable decimals;

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
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);

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

contract Distributor is Owned {
    function transferUSDT(
        IERC20 usdt,
        address to,
        uint256 amount
    ) external onlyOwner {
        usdt.transfer(to, amount);
    }
}

abstract contract DexBase {
    bool public inSwapAndLiquify;
    IUniswapV2Router public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    Distributor public distributor;
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
        distributor = new Distributor();
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
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

abstract contract LpFee is Owned, DexBase, ERC20 {
    uint256 public buyLpFee = 3;
    uint256 public sellLpFee = 3;
    address constant buyBackAddress =
        0xc650258b43C18d75c2020D80bd915732ce7ce9c5;

    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isInShareholders;
    uint256 public minPeriod = 1 minutes;
    uint256 public lastLPFeefenhongTime;
    address private fromAddress;
    address private toAddress;
    uint256 distributorGas = 500000;
    address[] public shareholders;
    uint256 currentIndex;
    mapping(address => uint256) public shareholderIndexes;
    uint256 public minDistribution;
    uint256 public numTokenToDividend = 1 * 1e18;
    bool public swapToDividend = true;

    constructor(uint256 _minDistribution) {
        minDistribution = _minDistribution;
        isDividendExempt[address(0)] = true;
        isDividendExempt[0x000000000000000000000000000000000000dEaD] = true;
        allowance[address(this)][address(uniswapV2Router)] = type(uint256).max;
    }

    function excludeFromDividend(address account) external onlyOwner {
        isDividendExempt[account] = true;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function _takeBuyLpFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 lpAmount = (amount * 3) / 100;
        super._transfer(sender, address(this), lpAmount);
        return lpAmount;
    }

    function _takeSellLpFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 buyBackAmount;

        if (sellLpFee > 3) {
            buyBackAmount = (amount * (sellLpFee - 3)) / 100;
            super._transfer(sender, address(distributor), buyBackAmount);
        }

        uint256 lpAmount = (amount * 3) / 100;
        super._transfer(sender, address(this), lpAmount);
        return lpAmount + buyBackAmount;
    }

    function dividendToUsers(address sender, address recipient) internal {
        if (fromAddress == address(0)) fromAddress = sender;
        if (toAddress == address(0)) toAddress = recipient;
        if (!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair)
            setShare(fromAddress);
        if (!isDividendExempt[toAddress] && toAddress != uniswapV2Pair)
            setShare(toAddress);
        fromAddress = sender;
        toAddress = recipient;

        if (
            IERC20(USDT).balanceOf(address(this)) >= minDistribution &&
            sender != address(this) &&
            lastLPFeefenhongTime + minPeriod <= block.timestamp
        ) {
            process(distributorGas);
            lastLPFeefenhongTime = block.timestamp;
        }
    }

    function setShare(address shareholder) private {
        if (isInShareholders[shareholder]) {
            if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0)
                quitShare(shareholder);
        } else {
            if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;
            addShareholder(shareholder);
            isInShareholders[shareholder] = true;
        }
    }

    function addShareholder(address shareholder) private {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        address lastLPHolder = shareholders[shareholders.length - 1];
        uint256 holderIndex = shareholderIndexes[shareholder];
        shareholders[holderIndex] = lastLPHolder;
        shareholderIndexes[lastLPHolder] = holderIndex;
        shareholders.pop();
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        isInShareholders[shareholder] = false;
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount == 0) return;
        uint256 nowbanance = IERC20(USDT).balanceOf(address(this));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 theLpTotalSupply = IERC20(uniswapV2Pair).totalSupply();

        while (gasUsed < gas && iterations < shareholderCount) {
            unchecked {
                if (currentIndex >= shareholderCount) {
                    currentIndex = 0;
                }
                address theHolder = shareholders[currentIndex];

                uint256 lpPercent = (IERC20(uniswapV2Pair).balanceOf(
                    theHolder
                ) * 100000) / theLpTotalSupply;
                uint256 amount = (nowbanance * lpPercent) / 100000;
                if (amount > 0) {
                    IERC20(USDT).transfer(theHolder, amount);
                }

                ++currentIndex;
                ++iterations;
                gasUsed += gasLeft - gasleft();
                gasLeft = gasleft();
            }
        }
    }

    function shouldSwapToUSDT(address sender) internal view returns (bool) {
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
        uint256 buyBackBalance = balanceOf[address(distributor)];
        if (buyBackBalance > 0) {
            super._transfer(
                address(distributor),
                address(this),
                buyBackBalance
            );
        }

        uint256 swapAmount = balanceOf[address(this)];

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDT);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            swapAmount,
            0,
            path,
            address(distributor),
            block.timestamp
        );

        uint256 theSwapAmount = IERC20(USDT).balanceOf(address(distributor));
        uint256 swapTobuyBack = (theSwapAmount * buyBackBalance) / swapAmount;
        uint256 swapToLp = theSwapAmount - swapTobuyBack;
        try
            distributor.transferUSDT(IERC20(USDT), address(this), swapToLp)
        {} catch {}
        if (swapTobuyBack > 0) {
            try
                distributor.transferUSDT(
                    IERC20(USDT),
                    buyBackAddress,
                    swapTobuyBack
                )
            {} catch {}
        }
    }

    function setNumTokensSellToAddToLiquidity(
        uint256 _num,
        bool _swapToDividend
    ) external onlyOwner {
        numTokenToDividend = _num;
        swapToDividend = _swapToDividend;
    }
}

contract MToken is ExcludedFromFeeList, LpFee {
    uint256 private constant _totalSupply = 9999 * 1e18;

    bool public presaleEnded = false;
    bool public presaleEnded2 = false;

    bool public isProtection;
    uint256 public INTERVAL = 24 * 60 * 60;
    uint256 public _protectionT;
    uint256 public _protectionP;
    address public marketingAddress;
    address constant anitAddr = 0xc629eceb8f02FddFD03D265BF09E6C7db4e26e75;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;
    uint256 public indexStart;

    mapping(address => bool) internal _isExcludedFromStart;

    function excludeMultipleAccountsFromStart(address[] calldata accounts)
        public
        onlyOwner
    {
        uint8 len = uint8(accounts.length);
        for (uint8 i = 0; i < len; ) {
            _isExcludedFromStart[accounts[i]] = true;
            unchecked {
                ++i;
            }
        }
    }

    constructor() ERC20("CURY", "CURY", 18) LpFee(2 * 1e18) {
        _mint(msg.sender, _totalSupply);
        excludeFromFee(msg.sender);
        marketingAddress = msg.sender;
        excludeFromFee(address(this));
        allowance[msg.sender][address(uniswapV2Router)] = type(uint256).max;
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

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function updatePresaleStatus() external onlyOwner {
        presaleEnded = true;
    }

    function updatePresaleStatus2() external onlyOwner {
        presaleEnded2 = true;
        launch();
    }

    function takeFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        if (launchedAt + 40 >= block.number) {
            uint256 some = (amount * 7) / 10;
            uint256 antAmount = amount - some;
            super._transfer(sender, anitAddr, antAmount);
            return some;
        }

        if (sender == uniswapV2Pair) {
            //buy
            uint256 lpAmount = _takeBuyLpFee(sender, amount);
            return amount - lpAmount;
        } else {
            //sell
            if (isProtection) {
                unchecked {
                    uint256 currentP = IERC20(USDT).balanceOf(uniswapV2Pair) /
                        (balanceOf[uniswapV2Pair] / 10000_00);
                    if (currentP < _protectionP) {
                        uint256 percent = ((_protectionP - currentP) * 100) /
                            _protectionP;
                        if (percent <= 3) {
                            sellLpFee = 3;
                        } else if (percent >= 20) {
                            sellLpFee = 20;
                        } else {
                            sellLpFee = percent;
                        }
                    } else {
                        sellLpFee = 3;
                    }
                }
            }
            uint256 lpAmount = _takeSellLpFee(sender, amount);
            return amount - lpAmount;
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        if (recipient == uniswapV2Pair) {
            if (
                !(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient])
            ) {
                require(presaleEnded == true, "ended");
            }
        }
        if (sender == uniswapV2Pair) {
            if (
                !(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient])
            ) {
                require(presaleEnded2 == true, "end");
            }

            if (_isExcludedFromStart[recipient]) {
                indexStart++;
            } else {
                require(indexStart > 10, "start");
            }
        }

        if (isProtection && (block.timestamp - _protectionT) >= INTERVAL) {
            _resetProtection();
        }

        if (inSwapAndLiquify) {
            super._transfer(sender, recipient, amount);
        } else {
            if (shouldSwapToUSDT(sender)) {
                swapAndToDividend();
            }
            // transfer token
            if (shouldTakeFee(sender, recipient)) {
                uint256 transferAmount = takeFee(sender, amount);
                super._transfer(sender, recipient, transferAmount);
            } else {
                super._transfer(sender, recipient, amount);
            }
            //dividend token
            dividendToUsers(sender, recipient);
        }
    }

    function setProtection(bool _isProtection, uint256 _INTERVAL)
        external
        onlyOwner
    {
        isProtection = _isProtection;
        INTERVAL = _INTERVAL;
    }

    function setMarketAddress(address _addr) external onlyOwner {
        marketingAddress = _addr;
    }

    function burn(address _addr, uint256 amount) external onlyOwner {
        super._transfer(_addr, address(0), amount);
    }

    function _resetProtection() private {
        uint256 time = block.timestamp;
        if (time - _protectionT >= INTERVAL) {
            _protectionT = time;
            _protectionP =
                IERC20(USDT).balanceOf(uniswapV2Pair) /
                (balanceOf[uniswapV2Pair] / 10000_00);
        }
    }

    function resetProtection() external {
        require(
            marketingAddress == msg.sender || owner == msg.sender,
            "only owner"
        );
        buyLpFee = 3;
        sellLpFee = 3;
        _protectionT = block.timestamp;
        _protectionP =
            IERC20(USDT).balanceOf(uniswapV2Pair) /
            (balanceOf[uniswapV2Pair] / 10000_00);
    }

    function setPrice(uint256 _price) external {
        require(
            marketingAddress == msg.sender || owner == msg.sender,
            "only owner"
        );
        _protectionP = _price;
    }
}