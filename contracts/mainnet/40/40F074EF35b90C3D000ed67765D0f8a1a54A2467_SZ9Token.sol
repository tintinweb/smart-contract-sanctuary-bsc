/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @title ERC20 interface
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath#mul: OVERFLOW");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath#sub: UNDERFLOW");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath#add: OVERFLOW");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
        return a % b;
    }

}

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

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

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

contract SZ9Token is Context, IERC20, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = 'SZ9';
    string private _symbol = 'SZ9';
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 200000 * 10**uint256(_decimals);

    address public _fundAddr = address(0x9018aD48959a4e578FFb4B37244A56d4b89c764F);
    address public _nftAddr = address(0xDa7c64F98a3D7B8387C4c1d53506ffC81Fb10a33);
    address public _fomoAddr = address(0x980427cdAf39fBCa61474CFB2e876dfE97B38583);
    address public _lpAddr = address(0x980427cdAf39fBCa61474CFB2e876dfE97B38583);
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2UsdtPair;
    address public uniswapV2BnbPair;

    uint256 private _liquidityFee = 10; // 1%
    uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 private _fundFee = 10; // 1%
    uint256 private _previousFundFee = _fundFee;
    uint256 private _fomoFee = 40; // 4%
    uint256 private _previousFomoFee = _fomoFee;
    uint256 private _nftFee = 30; // 3%
    uint256 private _previousNftFee = _nftFee;
    uint256 public  MAX_STOP_FEE_TOTAL = 1000 * 10**uint256(_decimals);
    uint256 public  _percent = 1000;
    uint256 public  _minRemain = 0.01 ether;
    uint256 public  totalFomoAmount;
    uint256 public  totalLpAmount;

    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public _isBlackList;
    mapping (address => bool) public _isSwapPair;

    bool public _tradeStatus = true;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (address receiveAddress, address routerAddress_, address usdtAddress_) public {
        uniswapV2Router = IUniswapV2Router02(routerAddress_);
        uniswapV2UsdtPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), usdtAddress_);
        uniswapV2BnbPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        _isSwapPair[uniswapV2UsdtPair] = true;
        _isSwapPair[uniswapV2BnbPair] = true;

        _isExcludedFromFee[receiveAddress] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_fundAddr] = true;
        _isExcludedFromFee[_fomoAddr] = true;
        _isExcludedFromFee[_nftAddr] = true;

        _balances[receiveAddress] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    receive () external payable {}

    /**
     * @dev Returns the name of the token.
     */
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
        return _decimals;
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function burn(uint256 amount) external returns (bool success) {
        return _burn(_msgSender(), amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) external returns (bool success) {
        uint256 currentAllowance = _allowances[account][_msgSender()];
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), currentAllowance.sub(amount));
        _burn(account, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_isBlackList[sender] == false, "from is in blacklist");
        require(_isBlackList[recipient] == false, "to is in blacklist");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        require(balanceOf(sender) >= (amount.add(_minRemain)), 'must remain');

        if( _isSwapPair[sender] &&  !_isExcludedFromFee[recipient]   ){
            require(_tradeStatus == true, "Trade not open");
        }

        if( _isSwapPair[recipient] && !_isExcludedFromFee[sender] ){
            require(_tradeStatus == true, "Trade not open");
        }

        if (_totalSupply <= MAX_STOP_FEE_TOTAL) {
            removeAllFee();
            _transferStandard(sender, recipient, amount);
        } else {
            if (_isSwapPair[recipient]) {
                if(
                    _isExcludedFromFee[sender] ||
                    _isExcludedFromFee[recipient]
                ) {
                    removeAllFee();
                }
                _transferStandard(sender, recipient, amount);
                if(
                    _isExcludedFromFee[sender] ||
                    _isExcludedFromFee[recipient]
                ) {
                    restoreAllFee();
                }
            } else {
                removeAllFee();
                _transferStandard(sender, recipient, amount);
                restoreAllFee();
            }
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {

        (uint256 tTransferAmount, uint256 tLiquidity, uint256 tFomo, uint256 tFund, uint256 tNft) = _getValues(tAmount);

        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(tTransferAmount);

        if(
            !_isExcludedFromFee[sender] &&
        !_isExcludedFromFee[recipient]
        ) {
            if (_lpAddr != address(0) && tLiquidity > 0) {
                _balances[_lpAddr] = _balances[_lpAddr].add(tLiquidity);
                totalLpAmount = totalLpAmount.add(tLiquidity);
                emit Transfer(sender, _lpAddr, tLiquidity);
            }

            if (_fundAddr != address(0) && tFund > 0) {
                _balances[_fundAddr] = _balances[_fundAddr].add(tFund);
                emit Transfer(sender, _fundAddr, tFund);
            }

            if (_fomoAddr != address(0) && tFomo > 0) {
                _balances[_fomoAddr] = _balances[_fomoAddr].add(tFomo);
                totalFomoAmount = totalFomoAmount.add(tFomo);
                emit Transfer(sender, _fomoAddr, tFomo);
            }

            if (_nftAddr != address(0) && tNft > 0) {
                _balances[_nftAddr] = _balances[_nftAddr].add(tNft);
                emit Transfer(sender, _nftAddr, tNft);
            }
        }

        emit Transfer(sender, recipient, tTransferAmount);

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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burn(address account, uint256 amount) internal returns (bool success) {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_balances[account] >= amount, "ERC20: burn amount exceeds allowance");
        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
        return true;
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            _percent
        );
    }

    function calculateFundFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_fundFee).div(
            _percent
        );
    }

    function calculateNftFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_nftFee).div(
            _percent
        );
    }

    function calculateFomoFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_fomoFee).div(
            _percent
        );
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tLiquidity, uint256 tFomo, uint256 tFund, uint256 tNft) = _getTValues(tAmount);

        return (tTransferAmount, tLiquidity, tFomo, tFund, tNft);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tFomo = calculateFomoFee(tAmount);
        uint256 tFund = calculateFundFee(tAmount);
        uint256 tNft = calculateNftFee(tAmount);

        uint256 tTotalFee = tLiquidity.add(tFomo).add(tFund).add(tNft);

        uint256 tTransferAmount = tAmount.sub(tTotalFee);

        return (tTransferAmount, tLiquidity, tFomo, tFund, tNft);
    }

    function removeAllFee() private {
        if( _liquidityFee == 0 && _fomoFee == 0 && _fundFee == 0 && _nftFee == 0) return;
        _previousLiquidityFee = _liquidityFee;
        _previousFomoFee = _fomoFee;
        _previousFundFee = _fundFee;
        _previousNftFee = _nftFee;
        _liquidityFee = 0;
        _fomoFee = 0;
        _fundFee = 0;
        _nftFee = 0;
    }

    function restoreAllFee() private {
        _liquidityFee = _previousLiquidityFee;
        _fomoFee = _previousFomoFee;
        _fundFee = _previousFundFee;
        _nftFee = _previousNftFee;
    }

    function excludeFromFee(address account, bool result) public onlyOwner {
        _isExcludedFromFee[account] = result;
    }

    function setBlacklist(address account, bool result) public onlyOwner {
        _isBlackList[account] = result;
    }

    function updateFundAddr(address addr) public onlyOwner {
        _fundAddr = addr;
    }

    function updateFomoAddr(address addr) public onlyOwner {
        _fomoAddr = addr;
    }

    function updateNftAddr(address addr) public onlyOwner {
        _nftAddr = addr;
    }

    function updateLpAddr(address addr) public onlyOwner {
        _lpAddr = addr;
    }

    function setUsdtPairAddress(address uniswapV2Pair_) public onlyOwner {
        uniswapV2UsdtPair = uniswapV2Pair_;
    }

    function setBnbPairAddress(address uniswapV2Pair_) public onlyOwner {
        uniswapV2BnbPair = uniswapV2Pair_;
    }

    function setRouterAddress(address routerAddress_) public onlyOwner {
        uniswapV2Router = IUniswapV2Router02(routerAddress_);
    }

    function setTradeStatus(bool result) public onlyOwner {
        _tradeStatus = result;
    }

    function setSwapPair(address pair, bool result) public onlyOwner {
        _isSwapPair[pair] = result;
    }

    function setFundFee(uint256 fee) public onlyOwner {
        _fundFee = fee;
    }

    function setNftFee(uint256 fee) public onlyOwner {
        _nftFee = fee;
    }

    function setFomoFee(uint256 fee) public onlyOwner {
        _fomoFee = fee;
    }

    function setLiquidityFee(uint256 fee) public onlyOwner {
        _liquidityFee = fee;
    }

    function setMaxStopFee(uint256 amount) public onlyOwner {
        MAX_STOP_FEE_TOTAL = amount;
    }

    function updateMinRemain(uint256 amount) public onlyOwner {
        _minRemain = amount;
    }
}