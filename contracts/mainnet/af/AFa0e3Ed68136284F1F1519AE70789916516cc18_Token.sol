/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}
interface IPancakeRouter01 {
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
interface IPancakeRouter02 is IPancakeRouter01 {
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
interface IPancakePair {
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
library PancakeLibrary {
    using SafeMath for uint;
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            ))));
    }
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

contract Token is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _balances;
    uint256 private _tTotal = 630000000 * 10**18;
    string private _name = "GPT";
    string private _symbol = "GPT";
    uint8  public _decimals = 18;
    bool public swapOpen = false;
    address public _coinAddress = address(0x55d398326f99059fF775485246999027B3197955);//U合约地址
    address public _baseAddress1 = address(0x8b652767fd42bCaD41BaA8cdc623b47E546760CF);//地址1
    address public _deadAddress1 = address(0x000000000000000000000000000000000000dEaD);//黑洞地址
    IPancakeRouter02 public uniswapV2Router;
    address public uniswapV2Pair;
    event DepositToken(address user, address token, uint256 tokenAmount);
    event AddLiquidity(address user, uint256 busdAmount, uint256 bmsAmount);
    event BuyToken(address user, uint256 busdAmount);
    event SellToken(address user, uint256 busdAmount);
    event RemoveLiquidity(address user, uint256 busdAmount);
    constructor () public {
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _coinAddress);
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _balances[owner()] = _tTotal;
        emit Transfer(address(0),owner(), _tTotal);
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    function setSwapOpen(bool opem) public onlyOwner {
        swapOpen = opem;
    }
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    receive() external payable {}
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(
        address from,address to,uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(from != to, "Transfer amount must be greater than zero");

        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            if(from == uniswapV2Pair){
                require(swapOpen, "zero");
            }
        }

        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            if(from == uniswapV2Pair || to == uniswapV2Pair){
                uint256 amount1 = amount.mul(3).div(100);
                uint256 amount2 = amount.mul(5).div(100);
                uint256 amount12 = amount.sub(amount1).sub(amount2);
                _balances[_baseAddress1] = _balances[_baseAddress1].add(amount1);
                emit Transfer(from, _baseAddress1, amount1);
                _balances[_deadAddress1] = _balances[_deadAddress1].add(amount2);
                emit Transfer(from, _deadAddress1, amount2);
                _balances[to] = _balances[to].add(amount12);
                emit Transfer(from, to, amount12);
                return;
            }
        }
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }
    function buy(uint256 amount,uint256 minTokenAmount) public {
        IERC20(_coinAddress).transferFrom(_msgSender(),address(this), amount);
        IERC20(_coinAddress).approve(address(uniswapV2Router), ~uint256(0));
        address[] memory path = new address[](2);
        path[0] = _coinAddress;
        path[1] = address(this);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            minTokenAmount,
            path,
            _msgSender(),
            block.timestamp
        );
        emit BuyToken(_msgSender(),amount);
    }
    function sell(uint256 amount,uint256 minTokenAmount) public {
        _checkAllowance(amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _coinAddress;
        _approve(address(this), address(uniswapV2Router), amount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            minTokenAmount, 
            path,
            _msgSender(),
            block.timestamp
        );
        emit SellToken(_msgSender(), amount);
    }
     function removeLiquidityU(uint256 amount) public {
         IPancakePair(uniswapV2Pair).transferFrom(_msgSender(),address(this), amount);
         IPancakePair(uniswapV2Pair).approve(address(uniswapV2Router), ~uint256(0));
         uniswapV2Router.removeLiquidity(
            _coinAddress,
            address(this),
            amount,
            0,
            0,
            _msgSender(),
            block.timestamp
        );
        emit RemoveLiquidity(_msgSender(), amount);
    }
    function addLiquidity(uint256 amountUSDT, uint256 amountTOKEN) public {
        uint256 balanceTOKENReal = balanceOf(_msgSender());
        uint256 balanceUSDTReal = IERC20(_coinAddress).balanceOf(_msgSender());
        require(balanceTOKENReal >= amountTOKEN && balanceUSDTReal >= amountUSDT, "exceeds of balance 1");
        uint256 usdt4liquidity;
        uint256 token4liquidity;
        if (IPancakePair(uniswapV2Pair).totalSupply() > 0) {
            uint256 amountTOKENReal = getLiquidityTOKENAmountFromUSDTAmount(amountUSDT);
            uint256 amountUSDTReal = getLiquidityUSDTAmountFromTOKENAmount(amountTOKEN);
            require(balanceTOKENReal >= amountTOKENReal || balanceUSDTReal >= amountUSDTReal, "exceeds of balance 2");
            if (balanceTOKENReal >= amountTOKENReal) {
                usdt4liquidity = amountUSDT;
                token4liquidity = amountTOKENReal;
            } else {
                usdt4liquidity = amountUSDTReal;
                token4liquidity = amountTOKEN;
            }
        } else {
            usdt4liquidity = amountUSDT;
            token4liquidity = amountTOKEN;
        }
        _checkAllowance(token4liquidity);
        _checkAnyTokenAllowance(_coinAddress, usdt4liquidity);
        _addLiquidityAndDistributeLP(usdt4liquidity, token4liquidity);
    }
    function _addLiquidityAndDistributeLP(uint256 usdt4liquidity, uint256 token4liquidity) private {
        (,,uint liquidity) = _addLiquidityReal(usdt4liquidity, token4liquidity);
        _distributeLP(liquidity);
    }
    function _approveUSDT(uint256 amount) private {
        if (IERC20(_coinAddress).allowance(address(this), address(uniswapV2Router)) < amount)
            IERC20(_coinAddress).approve(address(uniswapV2Router), ~uint256(0));
    }
    function _approveTOKEN(uint256 amount) private {
        if (allowance(address(this), address(uniswapV2Router)) < amount)
            _approve(address(this), address(uniswapV2Router), ~uint256(0));
    }
    function _addLiquidityReal(uint256 amountUSDTReal, uint256 amountTOKENReal) private returns (uint amountA, uint amountB, uint liquidity) {
        _approveUSDT(amountUSDTReal);
        _approveTOKEN(amountTOKENReal);
        (amountA, amountB, liquidity) = uniswapV2Router.addLiquidity(
            address(this),
            _coinAddress,
            amountTOKENReal,
            amountUSDTReal,
            0,
            0,
            address(this),
            block.timestamp
        );
        emit AddLiquidity(_msgSender(), amountUSDTReal, amountTOKENReal);
    }
    function _distributeLP(uint liquidity) private {
        uint256 fee = liquidity * 100 / 10000;
        IPancakePair(uniswapV2Pair).transfer(owner(), fee);
        IPancakePair(uniswapV2Pair).transfer(_msgSender(), liquidity - fee);
    }
    function _move(address sender, address recipient, uint256 amount) internal virtual {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _checkAllowance(uint256 amount) private {
        require(balanceOf(_msgSender()) >= amount, "exceeds of balance");
        _move(_msgSender(), address(this), amount);
    }
    function _checkAnyTokenAllowance(address token, uint256 amount) private {
        IERC20 TokenAny = IERC20(token);
        require(TokenAny.allowance(_msgSender(), address(this)) >= amount, "exceeds of token allowance");
        require(TokenAny.transferFrom(_msgSender(), address(this), amount), "allowance transferFrom failed");
        emit DepositToken(_msgSender(), token, amount);
    }
    function getPoolInfo(address _pair) public view returns (uint112 ThisAmount, uint112 TOKENAmount) {
        (uint112 _reserve0, uint112 _reserve1,) = IPancakePair(_pair).getReserves();
        ThisAmount = _reserve1;
        TOKENAmount = _reserve0;
        if (IPancakePair(_pair).token0() == address(this)) {
            ThisAmount = _reserve0;
            TOKENAmount = _reserve1;
        }
    }
    function getLiquidityUSDTAmountFromTOKENAmount(uint256 amountTOKEN) public view returns (uint256 amountUSDT) {
        (uint112 tokenAmount, uint112 usdtAmount) = getPoolInfo(uniswapV2Pair);
        if (tokenAmount == 0 || usdtAmount == 0) return 0;
        return amountTOKEN * usdtAmount / tokenAmount;
    }
    function getLiquidityTOKENAmountFromUSDTAmount(uint256 amountUSDT) public view returns (uint256 amountTOKEN) {
        (uint112 tokenAmount, uint112 usdtAmount) = getPoolInfo(uniswapV2Pair);
        if (tokenAmount == 0 || usdtAmount == 0) return 0;
        return amountUSDT * tokenAmount / usdtAmount;
    }
}