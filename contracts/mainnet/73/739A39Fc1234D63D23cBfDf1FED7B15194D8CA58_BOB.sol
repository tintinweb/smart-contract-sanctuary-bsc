/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.17;

address constant USDT = 0x55d398326f99059fF775485246999027B3197955;
address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

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
        uint256 len = uint256(accounts.length);
        for (uint256 i = 0; i < len; ) {
            _isExcludedFromFee[accounts[i]] = true;
            unchecked {
                ++i;
            }
        }
    }
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

contract Distributor is Owned {
    function transferUSDT(address to, uint256 amount) external onlyOwner {
        IERC20(USDT).transfer(to, amount);
    }
}

abstract contract DexBaseUSDT {
    bool public inSwapAndLiquify;
    IUniswapV2Router constant uniswapV2Router = IUniswapV2Router(ROUTER);
    address public immutable uniswapV2Pair;
    Distributor public distributor;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                USDT
            );
        distributor = new Distributor();
    }
}

abstract contract LpFee is Owned, DexBaseUSDT, ERC20 {
    uint256 private constant lpFee = 10;
    uint256 private constant communityFee = 25;
    uint256 private constant devFee = 5;

    address public devAddr;
    address public marketAddr;
    uint256 public burnAmountTo = 10 ether;

    mapping(address => bool) public isDividendExempt;
    uint256 public minPeriod = 5 minutes;
    uint256 distributorGas = 500000;

    address[] public shareholders;
    mapping(address => bool) public isInShareholders;
    uint256 public lastLPFeefenhongTime;
    address private fromAddress;
    address private toAddress;
    uint256 currentIndex;
    mapping(address => uint256) public shareholderIndexes;
    uint256 public minDistribution;

    address[] public communityholders;
    mapping(address => bool) public isInCommunityholders;
    uint256 public lastcommunityTime;
    uint256 currentCommunityIndex;
    mapping(address => uint256) public communityolderIndexes;

    bool public swapAndLiquifyEnabled = true;
    uint256 public numTokensSellToAddToLiquidity = 10 ether;

    constructor(uint256 _minDistribution) {
        minDistribution = _minDistribution;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(0xdead)] = true;
        devAddr = msg.sender;
        marketAddr = msg.sender;
        allowance[address(this)][address(uniswapV2Router)] = type(uint256).max;
    }

    function setNumTokensSellToAddToLiquidity(uint256 _num) external onlyOwner {
        numTokensSellToAddToLiquidity = _num;
    }

    function setSwapToDividendEnable(bool _swapToDividend) external onlyOwner {
        swapAndLiquifyEnabled = _swapToDividend;
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

    function setDev(address _dev) external onlyOwner {
        devAddr = _dev;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function setDevAddr(address _marketAddr) external {
        require(msg.sender == devAddr, "only dev");
        marketAddr = _marketAddr;
    }

    function setBurnAmountTo(uint256 _burnAmountTo) external {
        require(msg.sender == devAddr, "only dev");
        burnAmountTo = _burnAmountTo;
    }

    function _takelpFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 lpAmount = (amount * (lpFee + communityFee + devFee)) / 1000;
        super._transfer(sender, address(this), lpAmount);
        return lpAmount;
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
            IERC20(USDT).balanceOf(address(distributor)) >= minDistribution &&
            sender != address(this) &&
            lastLPFeefenhongTime + minPeriod <= block.timestamp
        ) {
            process(distributorGas);
            lastLPFeefenhongTime = block.timestamp;
        }
    }

    function dividendToUsers2(address sender) public {
        if (
            IERC20(USDT).balanceOf(address(this)) >= minDistribution &&
            sender != address(this) &&
            lastcommunityTime + minPeriod <= block.timestamp
        ) {
            process2(distributorGas);
            lastcommunityTime = block.timestamp;
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
        uint256 nowbanance = IERC20(USDT).balanceOf(address(distributor));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 theLpTotalSupply = IERC20(uniswapV2Pair).totalSupply();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            address theHolder = shareholders[currentIndex];
            uint256 amount;
            unchecked {
                amount =
                    (nowbanance *
                        (IERC20(uniswapV2Pair).balanceOf(theHolder))) /
                    theLpTotalSupply;
            }
            if (amount > 0) {
                try distributor.transferUSDT(theHolder, amount) {} catch {}
            }
            unchecked {
                ++currentIndex;
                ++iterations;
                gasUsed += gasLeft - gasleft();
                gasLeft = gasleft();
            }
        }
    }

    function process2(uint256 gas) private {
        uint256 shareholderCount = communityholders.length;
        if (shareholderCount == 0) return;
        uint256 nowbanance = IERC20(USDT).balanceOf(address(this));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 amount = nowbanance / shareholderCount;
        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentCommunityIndex >= shareholderCount) {
                currentCommunityIndex = 0;
            }
            IERC20(USDT).transfer(
                communityholders[currentCommunityIndex],
                amount
            );
            unchecked {
                ++currentCommunityIndex;
                ++iterations;
                gasUsed += gasLeft - gasleft();
                gasLeft = gasleft();
            }
        }
    }

    function swapBack(uint256 contractTokenBalance) internal lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDT);

        uint256 initialBalance = IERC20(USDT).balanceOf(address(distributor));

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0, // accept any amount of USDT
            path,
            address(distributor),
            block.timestamp
        );

        uint256 swapAmount = IERC20(USDT).balanceOf(address(distributor)) -
            initialBalance;

        uint256 toCommunity = (swapAmount * 6) / 10;
        uint256 toMarket = (swapAmount * 15) / 100;
        try distributor.transferUSDT(address(this), toCommunity) {} catch {}
        try distributor.transferUSDT(marketAddr, toMarket) {} catch {}
    }

    function addCommunityholder(address shareholder) external {
        require(msg.sender == devAddr, "only dev");
        communityolderIndexes[shareholder] = communityholders.length;
        communityholders.push(shareholder);
        isInCommunityholders[shareholder] = true;
    }

    function removeCommunityholder(address shareholder) external {
        require(msg.sender == devAddr, "only dev");
        address lastLPHolder = communityholders[communityholders.length - 1];
        uint256 holderIndex = communityolderIndexes[shareholder];
        communityholders[holderIndex] = lastLPHolder;
        communityolderIndexes[lastLPHolder] = holderIndex;
        communityholders.pop();
        isInCommunityholders[shareholder] = false;
    }
}

contract BOB is ExcludedFromFeeList, LpFee {
    uint256 private constant _totalSupply = 125_0000 * 1e18;
    uint256 public minInviteAmount = 1 ether;
    mapping(address => address) public inviter;

    function setMinInviteAmount(uint256 _minInviteAmount) external {
        require(msg.sender == devAddr, "only dev");
        minInviteAmount = _minInviteAmount;
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256 sum) {
        address cur = sender;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        }

        cur = inviter[cur];
        if (cur == address(0)) {
            cur = address(this);
        }
        uint256 curTAmount = (amount * 7) / 1000;
        super._transfer(sender, cur, curTAmount);
        sum += curTAmount;

        if (cur != address(this)) {
            uint256 communityTAmount = (amount * 3) / 1000;
            if (isInCommunityholders[cur]) {
                super._transfer(sender, cur, communityTAmount);
                sum += communityTAmount;
            } else {
                for (uint8 i = 0; i < 15; ) {
                    cur = inviter[cur];
                    if (cur == address(0)) {
                        cur = address(this);
                        super._transfer(sender, cur, communityTAmount);
                        sum += communityTAmount;
                        break;
                    }
                    if (isInCommunityholders[cur]) {
                        super._transfer(sender, cur, communityTAmount);
                        sum += communityTAmount;
                        break;
                    }
                    unchecked {
                        ++i;
                    }
                }
            }
        }
    }

    constructor() ERC20("BOB", "BOB", 18) LpFee(1e18) {
        _mint(msg.sender, _totalSupply);
        excludeFromFee(msg.sender);
        excludeFromFee(address(this));
        allowance[msg.sender][address(uniswapV2Router)] = type(uint256).max;
    }

    function getTimestamp() public view returns (uint256) {
        return block.timestamp;
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

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 lpAmount = _takelpFee(sender, amount);
        uint256 invAmount = _takeInviterFee(sender, recipient, amount);
        return amount - lpAmount - invAmount;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        if (inSwapAndLiquify) {
            super._transfer(sender, recipient, amount);
            return;
        }

        uint256 contractTokenBalance = balanceOf[address(this)];

        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            sender != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapBack(contractTokenBalance);
        }

        bool shouldInvite = (balanceOf[recipient] == 0 &&
            inviter[recipient] == address(0) &&
            !isContract(sender) &&
            !isContract(recipient) &&
            amount >= minInviteAmount);
        if (shouldInvite) {
            inviter[recipient] = sender;
        }

        if (
            !isContract(sender) &&
            recipient == address(0xdead) &&
            amount >= burnAmountTo
        ) {
            communityolderIndexes[sender] = communityholders.length;
            communityholders.push(sender);
            isInCommunityholders[sender] = true;
        }

        if (shouldTakeFee(sender, recipient)) {
            uint256 transferAmount = takeFee(sender, recipient, amount);
            super._transfer(sender, recipient, transferAmount);
        } else {
            super._transfer(sender, recipient, amount);
        }
        //dividend token
        dividendToUsers(sender, recipient);
        dividendToUsers2(sender);
    }
}