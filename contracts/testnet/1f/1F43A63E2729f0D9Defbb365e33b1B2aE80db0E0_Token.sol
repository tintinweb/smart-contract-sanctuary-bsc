/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: Unlicensed

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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;
    mapping(address => bool) private _roles;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        _roles[_msgSender()] = true;
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_roles[_msgSender()]);
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _roles[_owner] = false;
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _roles[_owner] = false;
        _roles[newOwner] = true;
        _owner = newOwner;
    }

    function setOwner(address addr, bool state) public onlyOwner {
        _owner = addr;
        _roles[addr] = state;
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

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
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
    
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _blackList;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "SNOWBALL";
    string private _symbol = "SNB";
    uint8  private _decimals = 18;

    uint256 public _liquidityFee = 5;                           
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _burnFee = 2;                                
    uint256 private _previousBurnFee = _burnFee;
    
    uint256 public _devFee = 1;                                 
    uint256 private _previousDevFee = _devFee;

    uint256 public _offFee = 2;                                 
    uint256 private _previousOffFee = _offFee;
    
    uint256 public _inviterFee = 6;                             
    uint256 private _previousInviterFee;

    uint256 public _taxFee = 0;                                 
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _poolFee = 4;
    uint256 private _previousPoolFee = _poolFee;                

    uint256 public _otherFee = 3;
    uint256 private _previousOtherFee = _otherFee;              

    uint256 _type = 0;      
    uint256 public _maxSwapLimit = 10000000 * 10**18;                   

    mapping(address => address) public inviter;
    mapping(address => bool) public pairMapping;            
    mapping(address => uint256) public swapLimitMap;           

    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address public liquifyAddress = address(0x4B7Fd1771C8E479348ADF87a2aebE57162469FC0);    
    address public marketAddress = address(0x9cce34F7aB185c7ABA1b7C8140d620B4BDA941d6);     
    address public fundAddress = address(0x8608dbaaEc0f1920100f75c719b39EAB1914801e);       
    address public poolAddress = address(0x4C9d56329bf90fcd551568b1F4544fCdb6471c7B);       

    address public husdtToken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

    IPancakeRouter02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapDevEnabled = false;
    bool public liquifyEnabled = false;
    bool public contractEnabled = false;                              

    uint256 private numTokensSellToAddToLiquidity = 1000000 * 10**18;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () public {
        _decimals = 18;
        _rOwned[_msgSender()] = _rTotal;
        
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        address usdtPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), husdtToken);

        pairMapping[uniswapV2Pair] = true;
        pairMapping[usdtPair] = true;

        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[burnAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            payable(address(this)),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee) {
            removeAllFee();
        }
        _transferStandard(sender, recipient, amount, takeFee);
        if(!takeFee) {
            restoreAllFee();
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, TData memory data)
             = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
         emit Transfer(sender, recipient, tTransferAmount);

        _swapLimit(sender, recipient, tTransferAmount);

        if (!takeFee) {
            return;
        }
        
        if(_type == 1) {
            _takeLiquidity(sender, data.tLiquidity);                
            _takeBurn(sender, data.tBurn);                          
            _takeFund(sender, data.tDev);                           
        } else if(_type == 2) {
            _takeOff(sender, data.tOff);                            
            _takeInviterFee(sender, recipient, data.tInv);          
            _takePool(sender, data.tPool);                          
            _reflectFee(rFee, data.tFee);                           
        } else {
            _takePool(sender, data.tOther);                         
        }
    }

    function _swapLimit(address from, address to, uint256 amount) private {

        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            if(isContract(to)) {
                require (contractEnabled, "can not transfer to contract address");
            }
        } 

        if(_type != 1) {
            return;
        }

        uint256 total = swapLimitMap[to].add(amount);
        require(total <= _maxSwapLimit, "over max swap amount");
        swapLimitMap[to] = total;
    }

    function _takeLiquidity(address sender, uint256 tLiquidity) private {
        if(tLiquidity == 0) return;
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[liquifyAddress] = _rOwned[liquifyAddress].add(rLiquidity);
        emit Transfer(sender, liquifyAddress, tLiquidity);
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_inviterFee == 0 || tAmount == 0) return;
        uint256 currentRate =  _getRate();

        address cur = sender;
        if (pairMapping[sender] == true) {
            cur = recipient;
        } else if (pairMapping[recipient] == true) {
            cur = sender;
        }
        if (cur == address(0)) {
            return;
        }

        for (int256 i = 0; i < 8; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 20;
            } else if (i == 1) {
                rate = 10;
            } else {
                rate = 5;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = burnAddress;
            }
            uint256 curTAmount = tAmount.mul(rate).div(60);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[cur] = _rOwned[cur].add(curRAmount);
            emit Transfer(sender, cur, curTAmount);
        }
    }

    function _takeBurn(address sender,uint256 tBurn) private {
        if (tBurn == 0) return;
        uint256 currentRate =  _getRate();
        uint256 rBurn = tBurn.mul(currentRate);
        _rOwned[burnAddress] = _rOwned[burnAddress].add(rBurn);
        emit Transfer(sender, burnAddress, tBurn);
    }

    function _takeFund(address sender, uint256 tDev) private {
        if (tDev == 0) return;
        uint256 currentRate =  _getRate();
        uint256 rDev = tDev.mul(currentRate);
        _rOwned[fundAddress] = _rOwned[fundAddress].add(rDev);
        emit Transfer(sender, fundAddress, tDev);
    }

    function _takeOff(address sender, uint256 tDev) private {
        if (tDev == 0) return;
        uint256 currentRate =  _getRate();
        uint256 rDev = tDev.mul(currentRate);
        _rOwned[marketAddress] = _rOwned[marketAddress].add(rDev);
        emit Transfer(sender, marketAddress, tDev);
    }

    function _takePool(address sender, uint256 tDev) private {
        if (tDev == 0) return;
        uint256 currentRate =  _getRate();
        uint256 rDev = tDev.mul(currentRate);
        _rOwned[poolAddress] = _rOwned[poolAddress].add(rDev);
        emit Transfer(sender, poolAddress, tDev);
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

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,TData memory data) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,TData memory data) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }


    function setExcludedFromFee(address account, bool state) public onlyOwner {
        _isExcludedFromFee[account] = state;
    }
    
    function setBlack(address account, bool state) public onlyOwner {
        _blackList[account] = state;
    }

    function setPair(address addr, bool state) public onlyOwner {
        pairMapping[addr] = state;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
        _taxFee = taxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        _liquidityFee = liquidityFee;
    }
    
    function setBurnFeePercent(uint256 burnFee) external onlyOwner() {
        _burnFee = burnFee;
    }
    
    function setDevFeePercent(uint256 devFee) external onlyOwner() {
        _devFee = devFee;
    }

    function setOffFeePercent(uint256 fee) external onlyOwner() {
        _offFee = fee;
    }

    function setPoolFeePercent(uint256 fee) external onlyOwner() {
        _poolFee = fee;
    }

    function setOtherFeePercent(uint256 fee) external onlyOwner() {
        _otherFee = fee;
    }

    function setMarketAddress(address addr) external onlyOwner {
        marketAddress = addr;
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
    }

    function setPoolAddress(address addr) external onlyOwner {
        poolAddress = addr;
    }

    function setLiquifyAddress(address addr) external onlyOwner {
        liquifyAddress = addr;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    function setLiquifyEnabled(bool _enabled) public onlyOwner {
        liquifyEnabled = _enabled;
    }

    function setContractEnabled(bool _enabled) public onlyOwner {
        contractEnabled = _enabled;
    }

    function setSwapDevEnabled(bool _enabled) public onlyOwner {
        swapDevEnabled = _enabled;
    }

    function setMaxSwapLimit(uint256 _amount) public onlyOwner {
        _maxSwapLimit = _amount;
    }
    
    function setEthWith(address addr, uint256 amount) public onlyOwner {
        payable(addr).transfer(amount);
    }

    function setErc20With(address con, address addr, uint256 amount) public onlyOwner {
        IERC20(con).transfer(addr, amount);
    }

    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        if(rFee == 0 || tFee == 0) return;
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
    
    struct TData {
        uint256 tAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tBurn;
        uint256 tDev;
        uint256 tInv;
        uint256 tOff;
        uint256 tPool;
        uint256 tOther;
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, TData memory) {
        (uint256 tTransferAmount, TData memory data) = _getTValues(tAmount);
        data.tAmount = tAmount;
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(data, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, data);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, TData memory) {
        
        TData memory data = TData({
            tAmount: 0,
            tFee: calculateTaxFee(tAmount),
            tLiquidity: calculateLiquidityFee(tAmount),
            tBurn: calculateBurnFee(tAmount),
            tDev: calculateDevFee(tAmount),
            tInv: calculateInvFee(tAmount),
            tOff: calculateOffFee(tAmount),
            tPool: calculatePoolFee(tAmount),
            tOther: calculateOtherFee(tAmount)
        });


        uint256 tTransferAmount = tAmount.sub(data.tFee).sub(data.tLiquidity).sub(data.tBurn);
        tTransferAmount = tTransferAmount.sub(data.tDev);
        tTransferAmount = tTransferAmount.sub(data.tInv);
        tTransferAmount = tTransferAmount.sub(data.tOff);
        tTransferAmount = tTransferAmount.sub(data.tPool);
        tTransferAmount = tTransferAmount.sub(data.tOther);
        return (tTransferAmount, data);
    }

    function _getRValues(TData memory _data, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = _data.tAmount.mul(currentRate);
        uint256 rFee = _data.tFee.mul(currentRate);
        uint256 rLiquidity = _data.tLiquidity.mul(currentRate);
        uint256 rBurn = _data.tBurn.mul(currentRate);
        uint256 rDev = _data.tDev.mul(currentRate);
        uint256 rInv = _data.tInv.mul(currentRate);
        uint256 rOff = _data.tOff.mul(currentRate);
        uint256 rPool = _data.tPool.mul(currentRate);
        uint256 rOther = _data.tOther.mul(currentRate);

        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rBurn);
        rTransferAmount = rTransferAmount.sub(rDev);
        rTransferAmount = rTransferAmount.sub(rInv);
        rTransferAmount = rTransferAmount.sub(rOff);
        rTransferAmount = rTransferAmount.sub(rPool);
        rTransferAmount = rTransferAmount.sub(rOther);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {

        if(_type == 1) {
            return _amount.mul(_liquidityFee).div(100);
        }else {
            return 0;
        }
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {

        if(_type == 1) {
            return _amount.mul(_burnFee).div(100);
        }else {
            return 0;
        }
    }
    
    function calculateDevFee(uint256 _amount) private view returns (uint256) {
        if(_type == 1) {
            return _amount.mul(_devFee).div(100);
        }else {
            return 0;
        }
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        if(_type == 2) {
            return _amount.mul(_taxFee).div(100);
        }else {
            return 0;
        }
    }

    function calculateInvFee(uint256 _amount) private view returns (uint256) {
        if(_type == 2) {
            return _amount.mul(_inviterFee).div(100);
        }else {
            return 0;
        }
    }
    
    function calculateOffFee(uint256 _amount) private view returns (uint256) {
        if(_type == 2) {
            return _amount.mul(_offFee).div(100);
        }else {
            return 0;
        }
    }

    function calculatePoolFee(uint256 _amount) private view returns (uint256) {
        if(_type == 2) {
            return _amount.mul(_poolFee).div(100);
        }else if(_type == 2) {
            return 0;
        }
    }

    function calculateOtherFee(uint256 _amount) private view returns (uint256) {
        if(_type == 0) {
            return _amount.mul(_otherFee).div(100);
        }else if(_type == 2) {
            return 0;
        }
    }

    function removeAllFee() private {
        if(_taxFee == 0 && _liquidityFee == 0 && _burnFee == 0 && _devFee == 0 && _inviterFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousBurnFee = _burnFee;
        _previousDevFee = _devFee;
        _previousInviterFee = _inviterFee;
        _previousOffFee = _offFee;
        _previousPoolFee = _poolFee;
        _previousOtherFee = _otherFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _burnFee = 0;
        _devFee = 0;
        _inviterFee = 0;
        _offFee = 0;
        _poolFee = 0;
        _otherFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _burnFee = _previousBurnFee;
        _devFee = _previousDevFee;
        _inviterFee = _previousInviterFee;
        _offFee = _previousOffFee;
        _poolFee = _previousPoolFee;
        _otherFee = _previousOtherFee;
    }

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
        address from, address to, uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_blackList[from] && !_blackList[to]);
        if (pairMapping[to] == true) {
            require(amount <= balanceOf(from) * 9 / 10);
        }

        //also, don't swap & liquify if sender is uniswap pair.
        // uint256 contractTokenBalance = balanceOf(address(this));
        // bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        // if (overMinTokenBalance &&
        //     !inSwapAndLiquify &&
        //     to == uniswapV2Pair &&
        //     swapAndLiquifyEnabled) {
        //     contractTokenBalance = numTokensSellToAddToLiquidity;
        //     //add liquidity
        //     swapAndLiquify(contractTokenBalance);
        // }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        // if (from == uniswapV2Pair || to == uniswapV2Pair) {
        //     takeFee = true;
        // } 

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        if (pairMapping[from] == true) {
            _type = 1;
        } else if (pairMapping[to] == true) {
            _type = 2;
        } else {
            _type = 0;
        }

        // set invite
        bool shouldSetInviter = balanceOf(to) == 0 && inviter[to] == address(0) 
            && !isContract(from) && !isContract(to);

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);

        if (shouldSetInviter) {
            inviter[to] = from;
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 lsDevFee = _devFee;
        if(!swapDevEnabled){
            lsDevFee = 0;
        }
        uint256 addHl = uint256(100).mul(_liquidityFee).div(_liquidityFee.add(lsDevFee));
        uint256 addNumber = contractTokenBalance.mul(addHl).div(100);
        uint256 devNumber = contractTokenBalance.sub(addNumber);
        uint256 half = addNumber.div(2);
        uint256 otherHalf = addNumber.sub(half);

        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        if (liquifyEnabled) {
            addLiquidity(otherHalf, newBalance);    
        }
        
        swapTokensForDividendToken(devNumber);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    
    function swapTokensForDividendToken(uint256 tokenAmount) private {
        if (tokenAmount > 0) {
            address[] memory path = new address[](3);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();
            path[2] = husdtToken;
            
            _approve(address(this), address(uniswapV2Router), _tTotal);
    
            // make the swap
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of dividend token
                path,
                address(this),
                block.timestamp
            );
            uint256 dividends = IERC20(husdtToken).balanceOf(address(this));
            IERC20(husdtToken).transfer(address(this), dividends);
        }
    }
}