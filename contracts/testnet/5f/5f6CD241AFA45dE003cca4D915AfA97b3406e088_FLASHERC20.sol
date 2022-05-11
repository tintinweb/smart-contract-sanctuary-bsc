/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    // 返回存在的代币数量
    function totalSupply() external view returns (uint256);

    // 返回 account 拥有的代币数量
    function balanceOf(address account) external view returns (uint256);

    // 将 amount 代币从调用者账户移动到 recipient
    // 返回一个布尔值表示操作是否成功
    // 发出 {Transfer} 事件
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    // 返回 spender 允许 owner 通过 {transferFrom}消费剩余的代币数量
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    // 调用者设置 spender 消费自己amount数量的代币
    function approve(address spender, uint256 amount) external returns (bool);

    // 将amount数量的代币从 sender 移动到 recipient ，从调用者的账户扣除 amount
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    // 当value数量的代币从一个form账户移动到另一个to账户
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 当调用{approve}时，触发该事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    // 返回代币名称
    function name() external view returns (string memory);

    // 返回代币符号
    function symbol() external view returns (string memory);

    // 返回代币的精度（小数位数）
    function decimals() external view returns (uint8);
}

interface IUniswapRouter {
     function factory() external view returns (address);
    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapFactory {
     event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function expectPairFor(address token0, address token1) external view returns (address);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external pure returns (bytes32);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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


contract FLASHERC20 is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    mapping(address => bool) public isTxFeeExempt;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isMarketPair;

    uint256 constant _baseFee = 100;
    uint256 private _sellMarketingFee = 0;

    uint256 private _destroyFee = 5;
    uint256 private _reflowUsdtFee = 10;
    uint256 private _reflowLpFee = 0;
    uint256 private _lpDividendFee = 0;
    uint256 private _foundingFee = 0;
    uint256 private _marketingFee = 0;
    uint256 private _luckyFee = 0;
    uint256 private _totalFee = 15;
    uint256 private _totalSellFee = 15;

    address public _luckyAddress = 0x2e05051e145AD952c0Fd7d7649B60d237728b5E4; //account14
    address public _marketingAddress =
        0x367eB0AFd414FAfcD76E94Cba4bBC043CF7284af; 
    address public _foundingAddress =
        0x367eB0AFd414FAfcD76E94Cba4bBC043CF7284af;
    address public _lpDividendAddress =
        0x367eB0AFd414FAfcD76E94Cba4bBC043CF7284af;
    address public _reflowAddres = 0x367eB0AFd414FAfcD76E94Cba4bBC043CF7284af;
    uint256 public _sellLimitRatio = 99;
    address public uniswapPair;
    IUniswapRouter uniswapRouter;
    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "FLASH: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(
       
    ) {
        _name = "FLASH";
        _symbol = "FLASH-PT";
        uniswapRouter = IUniswapRouter(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );
        uniswapPair = IUniswapFactory(uniswapRouter.factory()).createPair(
            address(this),
            0xf5Eacdee153A7247aC93A35FFD7cCF1Aec89fac2
        );
        isMarketPair[address(uniswapPair)] = true;
        isTxFeeExempt[msg.sender] = true;
        isTxFeeExempt[address(this)] = true;
        isTxFeeExempt[_luckyAddress] = true;
        isTxFeeExempt[_marketingAddress] = true;
        isTxFeeExempt[_foundingAddress] = true;
        isTxFeeExempt[_lpDividendAddress] = true;
        isTxFeeExempt[_reflowAddres] = true;

        isTxLimitExempt[address(uniswapPair)] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[_luckyAddress] = true;
        isTxLimitExempt[_marketingAddress] = true;
        isTxLimitExempt[_foundingAddress] = true;
        isTxLimitExempt[_lpDividendAddress] = true;
        isTxLimitExempt[_reflowAddres] = true;

        _totalSupply = 90000000 * 10**18;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        // _burn(initialAddress_, initialDestroyAmount_ * 10**18);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
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

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        _transfer(sender, recipient, amount);
        return true;
    }

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
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function validSellLimit(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (bool) {
        if (!isMarketPair[recipient]) {
            return true;
        }
        if (isTxLimitExempt[sender]) {
            return true;
        }
        uint256 sellMaxAmount = _balances[sender].mul(_sellLimitRatio).div(
            _baseFee
        );
        return sellMaxAmount >= amount;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            validSellLimit(sender, recipient, amount),
            "ERC20: Exceeding the maximum selling limit"
        );
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        uint256 finalAmount = takeFinalAmount(sender, recipient, amount);
        _balances[recipient] += finalAmount;
        emit Transfer(sender, recipient, finalAmount);
        _afterTokenTransfer(sender, recipient, amount);
    }

    function takeFinalAmount(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        if (isTxFeeExempt[sender] || isTxFeeExempt[recipient]) {
            return amount;
        }
        uint256 feeAmount;
        if (isMarketPair[recipient]) {//卖
            feeAmount = amount.mul(_totalSellFee).div(_baseFee);
        } else if (isMarketPair[sender]){//买
            feeAmount = amount.mul(_totalFee).div(_baseFee);
        }
        //普通转账不扣
        if (feeAmount > 0) {
            _sellMarketingFeeHandler(sender, recipient, amount);
            _destroyFeeHandler(sender, amount);
            _reflowUsdtHandler(sender, amount);
            _reflowLpHandler(sender, amount);
            _lpDividendHandler(sender, amount);
            _marketingHandler(sender, amount);
            _foundingHandler(sender, amount);
            _luckyHandler(sender, amount);
        }
        return amount.sub(feeAmount);
    }

    function _sellMarketingFeeHandler(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (isMarketPair[recipient]) {
            uint256 _feeAmount = amount.mul(_sellMarketingFee).div(_baseFee);
            if (_feeAmount > 0) {
                _balances[_marketingAddress] += _feeAmount;
                emit Transfer(sender, _marketingAddress, _feeAmount);
            }
        }
    }

    //销毁
    function _destroyFeeHandler(address sender, uint256 amount) internal lock {
        uint256 _feeAmount = amount.mul(_destroyFee).div(_baseFee);
        if (_feeAmount > 0) {
            if (_feeAmount > 0) {
                _balances[address(this)] += _feeAmount;
                emit Transfer(sender, address(this), _feeAmount);
                _burn(address(this), _feeAmount);
            }
        }
    }

   

    //回流usdt
    function _reflowUsdtHandler(address sender, uint256 amount) internal {
        uint256 _feeAmount = amount.mul(_reflowUsdtFee).div(_baseFee);
        if (_feeAmount == 0) {
            return;
        }
        _balances[_reflowAddres] += _feeAmount;
        emit Transfer(sender, _reflowAddres, _feeAmount);
        if (!isMarketPair[sender]) {
            uint256 swapAmount = _balances[_reflowAddres];
            _balances[_reflowAddres] = 0;
            _balances[address(this)] += swapAmount;
            emit Transfer(_reflowAddres, address(this), swapAmount);
            _swapTokensForToken(swapAmount, _reflowAddres);
        }
    }

    //回流
    function _reflowLpHandler(address sender, uint256 amount) internal {
        uint256 _flowLpAmount = amount.mul(_reflowLpFee).div(_baseFee);
        if (_flowLpAmount > 0) {
            _balances[address(uniswapPair)] += _flowLpAmount;
            emit Transfer(sender, address(uniswapPair), _flowLpAmount);
        }
    }

    function _lpDividendHandler(address sender, uint256 amount) internal {
        uint256 _feeAmount = amount.mul(_lpDividendFee).div(_baseFee);
        if (_feeAmount == 0) {
            return;
        }
        _balances[_lpDividendAddress] += _feeAmount;
        emit Transfer(sender, _lpDividendAddress, _feeAmount);
        if (!isMarketPair[sender]) {
            uint256 swapAmount = _balances[_lpDividendAddress];
            _balances[_lpDividendAddress] = 0;
            _balances[address(this)] += swapAmount;
            emit Transfer(_lpDividendAddress, address(this), swapAmount);
            _swapTokensForToken(swapAmount, _lpDividendAddress);
        }
    }

    function _marketingHandler(address sender, uint256 amount) internal {
        uint256 _feeAmount = amount.mul(_marketingFee).div(_baseFee);
        if (_feeAmount == 0) {
            return;
        }
        _balances[_marketingAddress] += _feeAmount;
        emit Transfer(sender, _marketingAddress, _feeAmount);
        if (!isMarketPair[sender]) {
            uint256 swapAmount = _balances[_marketingAddress];
            _balances[_marketingAddress] = 0;
            _balances[address(this)] += swapAmount;
            emit Transfer(_marketingAddress, address(this), swapAmount);
            _swapTokensForToken(swapAmount, _marketingAddress);
        }
    }

    function _foundingHandler(address sender, uint256 amount) internal {
        uint256 _feeAmount = amount.mul(_foundingFee).div(_baseFee);
        if (_feeAmount == 0) {
            return;
        }
        _balances[_foundingAddress] += _feeAmount;
        emit Transfer(sender, _foundingAddress, _feeAmount);
        if (!isMarketPair[sender]) {
            uint256 swapAmount = _balances[_foundingAddress];
            _balances[_foundingAddress] = 0;
            _balances[address(this)] += swapAmount;
            emit Transfer(_foundingAddress, address(this), swapAmount);
            _swapTokensForToken(swapAmount, _foundingAddress);
        }
    }

    function _luckyHandler(address sender, uint256 amount) internal {
        uint256 _feeAmount = amount.mul(_luckyFee).div(_baseFee);
        if (_feeAmount > 0) {
            _balances[_luckyAddress] += _feeAmount;
            emit Transfer(sender, _luckyAddress, _feeAmount);
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    event SwapTokensForToken(uint256 amountIn, address[] path);

    function _swapTokensForToken(uint256 tokenAmount, address to) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0x55d398326f99059fF775485246999027B3197955;
        _approve(address(this), address(uniswapRouter), _totalSupply);

        uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of token
            path,
            to, // The contract
            block.timestamp
        );
        emit SwapTokensForToken(tokenAmount, path);
    }

    function _refreshTotalFee() internal {
        _totalFee = _reflowUsdtFee
            .add(_reflowLpFee)
            .add(_lpDividendFee)
            .add(_foundingFee)
            .add(_marketingFee)
            .add(_luckyFee);
        _totalSellFee = _totalFee.add(_sellMarketingFee);
    }

    function setReflowUsdtFee(uint256 newValue) external onlyOwner {
        _reflowUsdtFee = newValue;
    }

    function setReflowLpFee(uint256 newValue) external onlyOwner {
        _reflowLpFee = newValue;
    }

    function setLpDividendFee(uint256 newValue) external onlyOwner {
        _lpDividendFee = newValue;
    }

    function setFoundingFee(uint256 newValue) external onlyOwner {
        _foundingFee = newValue;
    }

    function setMarketingFee(uint256 newValue) external onlyOwner {
        _marketingFee = newValue;
    }

    function setLuckyFee(uint256 newValue) external onlyOwner {
        _luckyFee = newValue;
    }

    function setSellLimitRatio(uint256 newValue) external onlyOwner {
        _sellLimitRatio = newValue;
    }

    function setSellMarketingFee(uint256 newValue) external onlyOwner {
        _sellMarketingFee = newValue;
        _refreshTotalFee();
    }

    function setTxFeeExcept(address[] memory users, bool exempt)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < users.length; i++) {
            isTxFeeExempt[users[i]] = exempt;
        }
    }

    function setTxLimitExempt(address[] memory users, bool exempt)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < users.length; i++) {
            isTxLimitExempt[users[i]] = exempt;
        }
    }
}