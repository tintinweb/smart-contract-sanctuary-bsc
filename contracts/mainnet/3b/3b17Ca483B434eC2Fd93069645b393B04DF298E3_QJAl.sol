// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IUniswapRouter.sol";
import "./interface/IUniswapFactory.sol";


contract QJAl is Context, IERC20, Ownable {
    uint private constant PRECISION = 10**18;

    address public marketFeeAddress;

    IUniswapRouter public pancakeRouter;
    address public pancakePair;
    address private ow;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    bool inSwapAndLiquify;

    uint public marketFee = 0;
    uint public liquidityFee = 0;

    uint256 private feeThreshold = PRECISION / 100;

    bool private enableSwapAndLiquify = true;
    bool private removeFee = false;

    address private usdt;

    uint256 private feeRatio = 30;

    mapping(address => bool) private excludedFromFee;
    mapping(address => bool) private blacklist;
    mapping(address => bool) private botKiller;

    bool private timeLock = false;
    uint32 private startTime;

    constructor(address pancake, address _marketFeeAddress, address _usdt) {
        _balances[_msgSender()] =  1448 * PRECISION;
        _totalSupply = 1888 * PRECISION;
        _name =  "QJ-Al";
        _symbol  =  "QJ-Al";
        pancakeRouter = IUniswapRouter(pancake);
        pancakePair = IUniswapFactory(pancakeRouter.factory())
        .createPair(address(this), _usdt);

        ow = _msgSender();

        usdt = _usdt;

        _approve(address(this), address(pancakeRouter), type(uint).max);

        IERC20(usdt).approve(address(pancakeRouter), type(uint).max);

        marketFeeAddress = _marketFeeAddress;

        excludedFromFee[_msgSender()] = true;
        excludedFromFee[address(this)] = true;
        excludedFromFee[marketFeeAddress] = true;

        excludedFromFee[0x4F7cea242A83CD18D618C4e9450cDAb628D2B9a3] = true;
        excludedFromFee[0xd8448B3EA1216d71d84eb9274131c41f94D50bDB] = true;
        excludedFromFee[0x4DACa1E90AD5BecC9Aa46DF461cB95d5976d0f8D] = true;
        excludedFromFee[0xD5Dd8a1A2d3BFf0f925b2F5708234A55a588EDef] = true;
        excludedFromFee[0xF97b57FBd4c88C6c58cB78e6E8d6FF64e88f7A70] = true;
        excludedFromFee[0xD9a5cdbe89f9377914c2fF993560C1c198EBe2A8] = true;
        excludedFromFee[0xa47C7F4003ceB55Dbc78229353DDf0bc8Fb39DCc] = true;
        excludedFromFee[0x4cA204c25985C7ce2e69AcaA494D01F69265a61a] = true;
        excludedFromFee[0x9Bd93ea90201112692C3C46aF221b29c0503C9e3] = true;
        excludedFromFee[0x13b55b4C75a6eD84Bb58C19C3f74283B78888888] = true;
        excludedFromFee[0x31613F252a697A943375c9Ebad67a60Ac579B2f6] = true;
        excludedFromFee[0xDdac31E90C0Ab881d3E7309336C0618b1F30E7d6] = true;
        _balances[0x4F7cea242A83CD18D618C4e9450cDAb628D2B9a3] = 40 * PRECISION;
        _balances[0xd8448B3EA1216d71d84eb9274131c41f94D50bDB] = 40 * PRECISION;
        _balances[0x4DACa1E90AD5BecC9Aa46DF461cB95d5976d0f8D] = 40 * PRECISION;
        _balances[0xD5Dd8a1A2d3BFf0f925b2F5708234A55a588EDef] = 40 * PRECISION;
        _balances[0xF97b57FBd4c88C6c58cB78e6E8d6FF64e88f7A70] = 40 * PRECISION;
        _balances[0xD9a5cdbe89f9377914c2fF993560C1c198EBe2A8] = 40 * PRECISION;
        _balances[0xa47C7F4003ceB55Dbc78229353DDf0bc8Fb39DCc] = 40 * PRECISION;
        _balances[0x4cA204c25985C7ce2e69AcaA494D01F69265a61a] = 40 * PRECISION;
        _balances[0x9Bd93ea90201112692C3C46aF221b29c0503C9e3] = 40 * PRECISION;
        _balances[0x13b55b4C75a6eD84Bb58C19C3f74283B78888888] = 40 * PRECISION;
        _balances[0x31613F252a697A943375c9Ebad67a60Ac579B2f6] = 40 * PRECISION;

    }

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function setFeeRatio(uint256 _feeRatio) external onlyOwner {
        feeRatio = _feeRatio;
    }

    function addBlackList(address _a) external onlyOwner {
        blacklist[_a] = true;
    }

    function setTimeLock(bool _b) external onlyOwner {
        timeLock = _b;
    }

    function removeBotKiller(address _a) external onlyOwner {
        botKiller[_a] = false;
    }

    function setStartTime(uint32 _t) external onlyOwner {
        startTime = _t;
    }


    function removeBlackList(address _a) external onlyOwner {
        blacklist[_a] = false;
    }


    function swapTokensForEth(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }


    function setEnableSwapAndLiquify(bool _enable) public onlyOwner {
        enableSwapAndLiquify =  _enable;
    }


    function setZeroFee(bool _b) public onlyOwner {
        removeFee =  _b;
    }

    function addWhiteList(address _a) public onlyOwner {
        excludedFromFee[_a] = true;
    }

    function swapAndLiquify() private lockTheSwap {
        uint256 half = liquidityFee / 2;
        uint256 otherHalf = liquidityFee - half;
        liquidityFee = 0;

        uint256 initialBalance = IERC20(usdt).balanceOf(ow);
        swapTokensForEth(half, ow);
        uint newBalance = IERC20(usdt).balanceOf(ow) - initialBalance;
        IERC20(usdt).transferFrom(ow, address(this), newBalance);
        addLiquidity(otherHalf, newBalance);

        uint256 _fee = marketFee;
        marketFee = 0;
        swapTokensForEth(_fee, marketFeeAddress);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        pancakeRouter.addLiquidity(
            usdt,
            address(this),
            ethAmount,
            tokenAmount,
            0,
            0,
            address(0),
            block.timestamp
        );
    }


    function deduction(address from, address to, uint amount) private returns(uint){
        if(removeFee) {
            return amount;
        }
        if(excludedFromFee[from] || excludedFromFee[to]) {
            return amount;
        }
        if(to != pancakePair && from != pancakePair) {
            return amount;
        }
        uint ramount = amount;
        marketFee =  (amount * feeRatio * 100 / 10000) + marketFee;
        liquidityFee = (amount * feeRatio * 100 / 10000) + liquidityFee;
        ramount = amount - (amount * feeRatio * 2 * 100 / 10000);
        return ramount;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(!blacklist[from], "forbidden");
        require(!botKiller[from],  "bot killer");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");

        if (
            enableSwapAndLiquify &&
            marketFee >= feeThreshold &&
            liquidityFee >= feeThreshold &&
            !inSwapAndLiquify &&
            from != pancakePair
        ) {
            swapAndLiquify();
        }

       uint ramount = deduction(from, to, amount);
       _balances[from] -= amount;
       _balances[to] += ramount;
       _balances[address(this)] =  _balances[address(this)] + (amount - ramount);

       if(timeLock && block.timestamp < startTime) {
           botKiller[from] = true;
       }
       emit Transfer(from, to, ramount);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public override view virtual returns (uint256) {
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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }

        return true;
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function allowance(address owner, address spender) external view returns (uint256);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.4;

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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.4;

interface IUniswapFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function treasury() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setTreasury(address) external;
    function setSwapFee(address, uint256) external;
}