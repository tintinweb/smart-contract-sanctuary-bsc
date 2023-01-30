/**
 *Submitted for verification at BscScan.com on 2023-01-30
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-26
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

// email: [email protected]

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
        uint256 len = uint256(accounts.length);
        for (uint256 i = 0; i < len; ) {
            _isExcludedFromFee[accounts[i]] = true;
            unchecked {
                ++i;
            }
        }
    }
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

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

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
    IUniswapV2Router immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address constant USDT = 0x55d398326f99059fF775485246999027B3197955;

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

contract PinfR is Owned, ExcludedFromFeeList, DexBase, ERC20 {
    uint256 constant selllpFee = 4;
    uint256 constant distributorGas = 500000;
    address constant feeReciever = 0x85DdcfF4eE5fa3A4f9ac9db39C85D4Bb5FFa5131;

    mapping(address => address) public inviter;

    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) private _updated;
    uint256 public minPeriod = 1 weeks;
    uint256 public LPFeefenhong;
    address private fromAddress;
    address private toAddress;
    address[] public shareholders;
    uint256 public currentIndex;
    bool public isOver;
    uint256 public nowbanance;
    mapping(address => uint256) public shareholderIndexes;
    uint256 public minDistribution = 100;

    mapping(address => uint256) public bounds20;
    uint256 public bounds20fenhong;

    constructor() ERC20("PinfR", "PinfR", 18) {
        _mint(msg.sender, 79 * 10000_0000 * 1e18);
        excludeFromFee(msg.sender);
        excludeFromFee(address(this));
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0xdead)] = true;
        isDividendExempt[address(0)] = true;
        bounds20fenhong = block.timestamp + 1 weeks;
    }

    function _takeDividendFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 fees = (amount * selllpFee) / 100;
        address cur = sender;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        }
        uint256 sum;
        uint8[9] memory inviteRate = [20, 15, 10, 3, 2, 20, 15, 10, 5];
        for (uint8 i = 0; i < 9; ) {
            uint8 rate = inviteRate[i];
            cur = inviter[cur];
            uint256 curTAmount = (fees * rate) / 100;
            super._transfer(sender, cur, curTAmount);
            sum += curTAmount;
            unchecked {
                ++i;
            }
        }

        return sum;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 divAmount = _takeDividendFee(sender, recipient, amount);
        return amount - divAmount;
    }

    function setIsDividendExempt(address addr, bool _isDividendExempt)
        external
        onlyOwner
    {
        isDividendExempt[addr] = _isDividendExempt;
    }

    function setBounds20fenhong(uint256 _bounds20fenhong) external onlyOwner {
        bounds20fenhong = _bounds20fenhong;
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        if (!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            if (sender != uniswapV2Pair) {
                require(balanceOf[sender] >= 20 ether, "at 20");

                if (balanceOf[sender] - amount <= 20 ether) {
                    amount = balanceOf[sender] - 20 ether;
                }
            }
        }

        // transfer token
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            bool shouldInvite = (balanceOf[recipient] == 0 &&
                inviter[recipient] == address(0) &&
                amount >= 20 ether &&
                !isContract(sender) &&
                !isContract(recipient));
            if (shouldInvite) {
                inviter[recipient] = sender;
            }
            super._transfer(sender, recipient, amount);
        } else {
            if (recipient == uniswapV2Pair) {
                // sell
                uint256 transferAmount = takeFee(sender, recipient, amount);
                super._transfer(sender, recipient, transferAmount);
            } else if (sender == uniswapV2Pair) {
                // buy
                uint256 buyFee = (amount * 5) / 1000;
                super._transfer(sender, feeReciever, buyFee);
                super._transfer(sender, recipient, amount - buyFee);

                bool shouldInvite = (balanceOf[recipient] == 0 &&
                    inviter[recipient] == address(0) &&
                    amount >= 20 ether &&
                    !isContract(recipient));
                if (shouldInvite) {
                    inviter[
                        recipient
                    ] = 0x6c98Ab9aEE3970446403Fa3D398Af330f9ebFfc9;
                }
            } else {
                bool shouldInvite = (balanceOf[recipient] == 0 &&
                    inviter[recipient] == address(0) &&
                    amount >= 20 ether &&
                    !isContract(sender) &&
                    !isContract(recipient));
                if (shouldInvite) {
                    inviter[recipient] = sender;
                }
                // transfer
                uint256 burnAmount = (amount * 2) / 1000;

                address cur = inviter[sender];
                super._transfer(sender, cur, burnAmount);

                super._transfer(sender, recipient, amount - burnAmount);
            }
        }

        if (
            balanceOf[feeReciever] >= 2 * 1e17 &&
            balanceOf[sender] >= 20 ether &&
            !isContract(sender) &&
            bounds20fenhong <= block.timestamp &&
            bounds20[sender] + minPeriod <= block.timestamp
        ) {
            super._transfer(feeReciever, sender, 2 * 1e17);
            bounds20[sender] = block.timestamp;
        }

        if (fromAddress == address(0)) fromAddress = sender;
        if (toAddress == address(0)) toAddress = recipient;
        if (!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair)
            setShare(fromAddress);
        if (!isDividendExempt[toAddress] && toAddress != uniswapV2Pair)
            setShare(toAddress);

        fromAddress = sender;
        toAddress = recipient;

        dividendToUsers(sender, distributorGas);
    }

    function dividendToUsers(address sender, uint256 _distributorGas) public {
        if (
            balanceOf[address(this)] >= minDistribution &&
            sender != address(this) &&
            LPFeefenhong + minPeriod <= block.timestamp
        ) {
            process(_distributorGas);

            if (isOver) {
                LPFeefenhong = block.timestamp;
                isOver = false;
            }
        }
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function totalHoldersCount() external view returns (uint256) {
        return shareholders.length;
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount == 0) return;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 theLpTotalSupply = IERC20(uniswapV2Pair).totalSupply();
        if (nowbanance == 0) nowbanance = balanceOf[address(this)];
        while (gasUsed < gas && iterations < shareholderCount) {
            uint256 amount;
            address theHolder;
            unchecked {
                if (currentIndex >= shareholderCount) {
                    currentIndex = 0;
                    isOver = true;
                    nowbanance = balanceOf[address(this)];
                    break;
                }
                theHolder = shareholders[currentIndex];
                amount =
                    (nowbanance *
                        (IERC20(uniswapV2Pair).balanceOf(theHolder))) /
                    theLpTotalSupply;
            }

            if (amount > 0 && balanceOf[address(this)] >= amount) {
                super._transfer(address(this), theHolder, amount);
            }
            unchecked {
                gasUsed += gasLeft - gasleft();
                gasLeft = gasleft();
                currentIndex++;
                iterations++;
            }
        }
    }

    function setShare(address shareholder) private {
        if (_updated[shareholder]) {
            if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0)
                quitShare(shareholder);
            return;
        }
        if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;
        addShareholder(shareholder);
        _updated[shareholder] = true;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        _updated[shareholder] = false;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}