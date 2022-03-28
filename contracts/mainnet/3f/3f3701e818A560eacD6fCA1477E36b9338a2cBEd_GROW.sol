/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.12;

interface IUniswapV2Factory {
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

interface IUniswapV2Router01 {
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
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

contract GROW is IBEP20, Ownable {
    event Fee(address indexed sender, uint256 tokenAmount, uint256 ethAmount);
    event ShouldSwapFeeForEthUpdated(bool indexed enabled);
    event UniswapV2RouterUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );
    event CouncilUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );
    event DividendUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromIncomingFee;
    mapping(address => bool) private _isExcludedFromOutgoingFee;

    uint256 private _totalSupply;
    uint256 private _initialSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    address public council;
    address public dividend;
    bool public shouldSwapFeeForEth;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    constructor() {
        uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
        emit UniswapV2RouterUpdated(address(0), address(uniswapV2Router));

        _name = "GROW";
        _symbol = "GROW";
        _decimals = 8;
        _initialSupply = 100000000000000000; // 1 billion
        _totalSupply = _initialSupply;
        shouldSwapFeeForEth = false;
        emit ShouldSwapFeeForEthUpdated(shouldSwapFeeForEth);
        _balances[owner()] = _initialSupply;
        _isExcludedFromIncomingFee[owner()] = true;
        _isExcludedFromOutgoingFee[owner()] = true;
        _isExcludedFromIncomingFee[address(this)] = true;
        _isExcludedFromOutgoingFee[address(this)] = true;
        // exclude the uniswapV2Pair from outgoing fees so we don't tax the pool
        _isExcludedFromOutgoingFee[uniswapV2Pair] = true;

        emit Transfer(address(0), owner(), _initialSupply);
    }

    receive() external payable {}

    /**
     * @dev Sets if we should swap our fees for ETH or not
     */
    function setShouldSwapFeeForEth(bool shouldSwap) external onlyOwner {
        shouldSwapFeeForEth = shouldSwap;
        emit ShouldSwapFeeForEthUpdated(shouldSwap);
    }

    /**
     * @dev Sets true value for `account` in `_isExcludedFromIncomingFee`
     */
    function excludeFromIncomingFee(address account) external onlyOwner {
        _isExcludedFromIncomingFee[account] = true;
    }

    /**
     * @dev Sets false value for `account` in `_isExcludedFromIncomingFee`
     */
    function includeInIncomingFee(address account) external onlyOwner {
        _isExcludedFromIncomingFee[account] = false;
    }

    /**
     * @dev Checks if `account` is excluded from incoming fees
     */
    function isExcludedFromIncomingFee(address account)
        external
        view
        returns (bool)
    {
        return _isExcludedFromIncomingFee[account];
    }

    /**
     * @dev Sets true value for `account` in `_isExcludedFromOutgoingFee`
     */
    function excludeFromOutgoingFee(address account) external onlyOwner {
        _isExcludedFromOutgoingFee[account] = true;
    }

    /**
     * @dev Sets false value for `account` in `_isExcludedFromOutgoingFee`
     */
    function includeInOutgoingFee(address account) external onlyOwner {
        _isExcludedFromOutgoingFee[account] = false;
    }

    /**
     * @dev Checks if `account` is excluded from outgoing fees
     */
    function isExcludedFromOutgoingFee(address account)
        external
        view
        returns (bool)
    {
        return _isExcludedFromOutgoingFee[account];
    }

    /**
     * @dev Sets the council address and excludes it from fees
     */
    function setCouncil(address newCouncil) external onlyOwner {
        require(
            council != newCouncil,
            "GROW: council address cannot be the same"
        );
        _isExcludedFromOutgoingFee[newCouncil] = true;
        _isExcludedFromIncomingFee[newCouncil] = true;
        emit CouncilUpdated(council, newCouncil);
        council = newCouncil;
    }

    /**
     * @dev Sets the council address and excludes it from fees
     */
    function setDividend(address newDividend) external onlyOwner {
        require(
            dividend != newDividend,
            "GROW: dividend address cannot be the same"
        );
        _isExcludedFromOutgoingFee[newDividend] = true;
        _isExcludedFromIncomingFee[newDividend] = true;
        emit DividendUpdated(dividend, newDividend);
        dividend = newDividend;
    }

    function setUniswapRouter(address newRouter) external onlyOwner {
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        IUniswapV2Factory factory = IUniswapV2Factory(
            _newPancakeRouter.factory()
        );
        // if the pair hasn't been created it will return address(0), so create it
        if (
            factory.getPair(address(this), _newPancakeRouter.WETH()) ==
            address(0)
        ) {
            uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory())
                .createPair(address(this), _newPancakeRouter.WETH());
        }
        emit UniswapV2RouterUpdated(
            address(uniswapV2Router),
            address(_newPancakeRouter)
        );
        uniswapV2Router = _newPancakeRouter;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-initial}.
     */
    function initialSupply() external view returns (uint256) {
        return _initialSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(
            _allowances[sender][_msgSender()] >= amount,
            "BEP20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        external
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
     * problems described in {BEP20-approve}.
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
        external
        returns (bool)
    {
        require(
            _allowances[_msgSender()][spender] >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "BEP20: transfer amount must be greater than zero");
        require(
            _balances[sender] >= amount,
            "BEP20: transfer amount exceeds balance"
        );

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);

        if (_shouldTakeFee(sender, recipient)) {
            uint256 councilFee = amount / 20; // 5%
            uint256 dividendFee = amount / 20; // 5%
            uint256 totalFee = councilFee + dividendFee;

            require(
                _balances[sender] > totalFee,
                "GROW: transfer amount + fees exceeds balance"
            );

            uint256 ethSwapped = 0;
            if (_shouldSwapFeeForEth(sender, recipient)) {
                uint256 dividendEth = _transferFeeInEth(
                    sender,
                    dividend,
                    dividendFee
                );
                uint256 councilEth = _transferFeeInEth(
                    sender,
                    council,
                    councilFee
                );
                ethSwapped = dividendEth + councilEth;
            } else {
                _transferFeeInToken(sender, dividend, dividendFee);
                _transferFeeInToken(sender, council, councilFee);
            }

            emit Fee(sender, totalFee, ethSwapped);
        }
    }

    /**
     * @dev Checks if we should swap our fees for ETH.
     */
    function _shouldSwapFeeForEth(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        // we don't want to swap fees if it's the liquidityPair
        return
            shouldSwapFeeForEth &&
            sender != uniswapV2Pair &&
            recipient != uniswapV2Pair;
    }

    /**
     * @dev Checks if a fee should be taken from the transaction.
     */
    function _shouldTakeFee(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        return
            !_isExcludedFromIncomingFee[recipient] &&
            !_isExcludedFromOutgoingFee[sender];
    }

    /**
     * @dev Transfers the fee `amount` in equivalent ETH from the `sender` to the `feeWallet`
     */
    function _transferFeeInEth(
        address sender,
        address feeWallet,
        uint256 amount
    ) internal returns (uint256) {
        _balances[sender] = _balances[sender] - amount;
        // uniswap will always swap from the message sender, so we transfer these tokens to the contract
        // which will then transfer them to the fee wallet after swapping tokens
        _balances[address(this)] = _balances[address(this)] + amount;
        return _swapTokensForEth(feeWallet, amount);
    }

    /**
     * @dev Transfers the fee `amount` of GROW tokens from the `sender` to the `feeWallet`
     */
    function _transferFeeInToken(
        address sender,
        address feeWallet,
        uint256 amount
    ) internal {
        _balances[sender] = _balances[sender] - amount;
        _balances[feeWallet] = _balances[feeWallet] + amount;
        emit Transfer(sender, feeWallet, amount);
    }

    /**
     * @dev Swaps the tokens through Uniswap (Pancake) to get the equivalent amount of tokens in ETH
     *
     * This transfers the tokens from the contract to Uniswap, swaps them there,
     * and then Uniswap transfers them in the `to` address
     *
     * It keeps track of the ETH received swapped by getting the balance before and after swap
     */
    function _swapTokensForEth(address to, uint256 tokenAmount)
        private
        returns (uint256)
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uint256 initialBalance = to.balance;
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount back
            path,
            to,
            block.timestamp
        );

        uint256 newBalance = dividend.balance;
        return newBalance - initialBalance;
    }
}