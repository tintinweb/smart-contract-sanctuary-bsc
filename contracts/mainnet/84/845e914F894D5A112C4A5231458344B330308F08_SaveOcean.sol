// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.16;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IERC20.sol";
import "./IPancakeSwapRouter.sol";
import "./IPancakeSwapFactory.sol";
import "./Ownable.sol";
import "./Context.sol";

contract SaveOcean is Context, IERC20, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private constant _name = "SaveOcean";
    string private constant _symbol = "SOCEAN";

    struct Tax {
        uint256 rewardTax;
        uint256 marketingTax;
        uint256 teamTax;
        uint256 liquidityTax;
        uint256 charityTax;
        uint256 totalTax;
    }

    Tax public buyTax = Tax(30, 30, 30, 20, 20, 130);
    Tax public sellTax = Tax(30, 30, 30, 20, 20, 130);
    Tax public transferTax = Tax(30, 30, 30, 20, 20, 130);
    uint256 public denominator = 1000;
    uint256 public minSwapAmount = 1000 * 10**18;

    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    mapping(address => bool) _isFeeExempt;

    address public rewardReceiver;
    address public marketingReceiver;
    address public teamReceiver;
    address public liquidityReceiver;
    address public charityReceiver;

    address public pair;
    IPancakeSwapRouter public router;
    address public busdContract;

    constructor(
        address _owner,
        address _rewardReceiver,
        address _marketingReceiver,
        address _teamReceiver,
        address _liquidityReceiver,
        address _charityReceiver
    ) {
        require(_owner != address(0));
        require(_rewardReceiver != address(0));
        require(_marketingReceiver != address(0));
        require(_teamReceiver != address(0));
        require(_liquidityReceiver != address(0));
        require(_charityReceiver != address(0));

        rewardReceiver = _rewardReceiver;
        marketingReceiver = _marketingReceiver;
        teamReceiver = _teamReceiver;
        liquidityReceiver = _liquidityReceiver;
        charityReceiver = _charityReceiver;

        if (block.chainid == 56) {
            router = IPancakeSwapRouter(
                0x10ED43C718714eb63d5aA57B78B54704E256024E
            );
            busdContract = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        } else if (block.chainid == 97) {
            router = IPancakeSwapRouter(
                0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
            );
            busdContract = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
        }

        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        _isFeeExempt[rewardReceiver] = true;
        _isFeeExempt[marketingReceiver] = true;
        _isFeeExempt[teamReceiver] = true;
        _isFeeExempt[liquidityReceiver] = true;
        _isFeeExempt[charityReceiver] = true;
        _isFeeExempt[_owner] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[address(router)] = true;

        _allowances[address(this)][address(router)] = type(uint256).max;
        _allowances[address(this)][pair] = type(uint256).max;
        _allowances[address(this)][address(this)] = type(uint256).max;

        _mint(_owner, 10_000_000 * 10**decimals());
        transferOwnership(_owner);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        bool excludedAccount = _isFeeExempt[from] || _isFeeExempt[to];
        uint256 totalTaxAmount;
        if (!excludedAccount && !inSwap) {
            Tax memory tax;
            if (from == pair) {
                tax = buyTax;
            } else if (to == pair) {
                tax = sellTax;
            } else {
                tax = transferTax;
            }
            totalTaxAmount = (amount * tax.totalTax) / denominator;

            //Marketing tax
            uint256 marketingTaxAmount = (amount * tax.marketingTax) /
                denominator;
            _balances[marketingReceiver] += marketingTaxAmount;

            //Team tax
            uint256 teamTaxAmount = (amount * tax.teamTax) / denominator;
            _balances[teamReceiver] += teamTaxAmount;

            //Liquidity tax
            uint256 liquidityTaxAmount = (amount * tax.liquidityTax) /
                denominator;
            _balances[liquidityReceiver] += liquidityTaxAmount;

            //Charity tax
            uint256 charityTaxAmount = (amount * tax.charityTax) / denominator;
            _balances[charityReceiver] += charityTaxAmount;

            _balances[address(this)] +=
                totalTaxAmount -
                marketingTaxAmount -
                teamTaxAmount -
                liquidityTaxAmount -
                charityTaxAmount;

            emit Transfer(from, address(this), totalTaxAmount);

            if (shouldSwapBack()) {
                swapBack();
            }
        }

        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount - totalTaxAmount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = _balances[address(this)];
        if (amountToSwap > 0 && amountToSwap >= minSwapAmount) {
            swapTokenToBusd(amountToSwap, rewardReceiver);
        }
    }

    function swapTokenToBusd(uint256 amountToSwap, address to) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = busdContract;
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function setReceiver(
        address _rewardReceiver,
        address _marketingReceiver,
        address _teamReceiver,
        address _liquidityReceiver,
        address _charityReceiver
    ) external onlyOwner {
        require(_rewardReceiver != address(0));
        require(_marketingReceiver != address(0));
        require(_teamReceiver != address(0));
        require(_liquidityReceiver != address(0));
        require(_charityReceiver != address(0));

        rewardReceiver = _rewardReceiver;
        marketingReceiver = _marketingReceiver;
        teamReceiver = _teamReceiver;
        liquidityReceiver = _liquidityReceiver;
        charityReceiver = _charityReceiver;
    }

    function setBuyTax(
        uint256 _rewardTax,
        uint256 _marketingTax,
        uint256 _teamTax,
        uint256 _liquidityTax,
        uint256 _charityTax
    ) external onlyOwner {
        uint256 totalTax = _rewardTax +
            _marketingTax +
            _teamTax +
            _liquidityTax +
            _charityTax;
        require(totalTax <= 250, "Max 25%");
        buyTax = Tax(
            _rewardTax,
            _marketingTax,
            _teamTax,
            _liquidityTax,
            _charityTax,
            totalTax
        );
    }

    function setSellTax(
        uint256 _rewardTax,
        uint256 _marketingTax,
        uint256 _teamTax,
        uint256 _liquidityTax,
        uint256 _charityTax
    ) external onlyOwner {
        uint256 totalTax = _rewardTax +
            _marketingTax +
            _teamTax +
            _liquidityTax +
            _charityTax;
        require(totalTax <= 250, "Max 25%");
        sellTax = Tax(
            _rewardTax,
            _marketingTax,
            _teamTax,
            _liquidityTax,
            _charityTax,
            totalTax
        );
    }

    function setTransferTax(
        uint256 _rewardTax,
        uint256 _marketingTax,
        uint256 _teamTax,
        uint256 _liquidityTax,
        uint256 _charityTax
    ) external onlyOwner {
        uint256 totalTax = _rewardTax +
            _marketingTax +
            _teamTax +
            _liquidityTax +
            _charityTax;
        require(totalTax <= 250, "Max 25%");
        transferTax = Tax(
            _rewardTax,
            _marketingTax,
            _teamTax,
            _liquidityTax,
            _charityTax,
            totalTax
        );
    }

    function setMinSwapAmount(uint256 _minSwapAmount) external onlyOwner {
        require(_minSwapAmount > 0, "Invalid number");
        minSwapAmount = _minSwapAmount;
    }

    function setBusdContract(address _busdContract) external onlyOwner {
        require(_busdContract != address(0), "Invalid contract");
        busdContract = _busdContract;
    }

    function shouldSwapBack() internal view returns (bool) {
        return !inSwap && msg.sender != pair;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function setFeeExemp(address[] calldata _addrs, bool flag)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addrs.length; i++) {
            _isFeeExempt[_addrs[i]] = flag;
        }
    }

    fallback() external payable {}

    receive() external payable {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IPancakeSwapRouter {
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IPancakeSwapFactory {
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
pragma solidity 0.8.16;

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}