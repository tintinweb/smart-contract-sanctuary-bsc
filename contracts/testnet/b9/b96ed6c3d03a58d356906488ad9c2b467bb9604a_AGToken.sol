/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;


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


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract AGToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) public _blackHole;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 public startTime = 1665835200;
    uint256 public robotTime = 1666440180;
    uint256 public transferTime = 1666441800;
    mapping (address => UserOLD) public userTokenOLD;

    struct UserOLD {
        bool ISOLD;
        uint256 tokenAmount;
        uint256 freedAmount;
        uint256 count;
    }

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    address public  _devWallet = 0x2722b23ef144E327CA8966AB2E5df8973bE6ba95; 
    address public  dividend = 0x2722b23ef144E327CA8966AB2E5df8973bE6ba95; 
    
    address public blackholdAddr = address(8);

    string private _name = "AGAME";
    string private _symbol = "AG";
    uint8 private _decimals = 18;

    uint256 public _buyBlackFee = 1;
    uint256 private _previousBuyBlackFeeFee = _buyBlackFee;
    uint256 public _liquidityFee = 2;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _sellBlackFee = 40;
    uint256 private _previousSellBlackFeeFee = _sellBlackFee;
    uint256 public _devFee = 2;
    uint256 private _previousDevFee = _devFee;


    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public immutable uniswapV2PairBNBAG;
    address public router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address public usdt   = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
  
    uint256 private numTokensSellToAddToLiquidity =  50000 * 10**18;
    
    
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

    constructor () {
        _rOwned[owner()] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdt);
            
        uniswapV2PairBNBAG = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
         _blackHole[uniswapV2PairBNBAG] = true;
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }
    
    function setDividend(address _dividend) public  {
            require(msg.sender == _devWallet, "denied");
            dividend = _dividend;
    }
    function setStarrtTime(uint256 _startTime) public  {
            require(msg.sender == _devWallet, "denied");
            startTime = _startTime;
    }
    function setRobotTime(uint256 _robotTime) public  {
            require(msg.sender == _devWallet, "denied");
            robotTime = _robotTime;
    }
    function setTransferTime(uint256 _transferTime) public  {
            require(msg.sender == _devWallet, "denied");
            transferTime = _transferTime;
    }
    function setNumTokensSell(uint256 _numTokensSellToAddToLiquidity) public  {
            require(msg.sender == _devWallet, "denied");
            numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity * 10**18;
    }
    function setBlackhold(address _blackhold) public  {
            require(msg.sender == _devWallet, "denied");
            blackholdAddr = _blackhold;
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
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

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

	function setDevAddress(address payable dev) public {
         require(msg.sender == _devWallet, "denied");
        _devWallet = dev;
    }   
     function setblackHole(address[] memory  _addr,bool _is) public onlyOwner() {
          for (uint256 i = 0; i < _addr.length; i++) {
               _blackHole[_addr[i]] = _is;
          }
    }
    function _transferBuyExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity,uint256 tBuyBlack) = _getValues(tAmount);
		  _rOwned[sender] = _rOwned[sender].sub(rAmount);
		  _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
         _takeLiquidity(tLiquidity); 
         _takeBuyBlack(tBuyBlack);
         emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferSellExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tdev,uint256 tSellBlack) = _getSellValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeDev(tdev);
        _takeSellBlack(tSellBlack);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _transferNoFeeExcluded(address sender, address recipient, uint256 tAmount) private {
         uint256 currentRate =  _getRate();
         uint256 rAmount = tAmount.mul(currentRate);
		  _rOwned[sender] = _rOwned[sender].sub(rAmount);
		  _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, tAmount);
    }
    function excludeFromFee(address[] memory account) public  {
         require(msg.sender == _devWallet, "denied");
           for (uint256 i = 0; i < account.length; i++) {
                 _isExcludedFromFee[account[i]] = true;
           }
    }
    function includeInFee(address account,bool isfalse) public onlyOwner() {
        _isExcludedFromFee[account] = isfalse;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        _liquidityFee = liquidityFee;
    }

    function setSellBlackFeePercent(uint256 sellBlackFee) external onlyOwner() {
        _sellBlackFee = sellBlackFee;
    }
	function setDevFeePercent(uint256 devFee) external onlyOwner() {
        _devFee = devFee;
    }
    function setSwapAndLiquifyEnabled(bool _enabled) public {
        require(msg.sender == _devWallet, "denied");
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    receive() external payable {}

    struct TData {
        uint256 tAmount;
        uint256 tLiquidity;
        uint256 tBuyBlack;
        uint256 currentRate;
    }
    struct TSellData {
        uint256 tAmount;
        uint256 tDev;
         uint256 tSellBlack;
        uint256 currentRate;
    }
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256,uint256) {
        (uint256 tTransferAmount, TData memory data) = _getTValues(tAmount);
        data.tAmount = tAmount;
        data.currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount) = _getRValues(data);
        return (rAmount, rTransferAmount, tTransferAmount, data.tLiquidity,data.tBuyBlack);
    }

    function _getSellValues(uint256 tAmount) private view returns (uint256, uint256,uint256, uint256,uint256) {
        (uint256 tTransferAmount, TSellData memory data) = _getTSellValues(tAmount);
        data.tAmount = tAmount;
        data.currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount) = _getRSellValues(data);
        return (rAmount, rTransferAmount,tTransferAmount, data.tDev,data.tSellBlack);
    }


    function _getTValues(uint256 tAmount) private view returns (uint256, TData memory) {
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
         uint256 tBuyBlack = calculateBuyBlackFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tLiquidity).sub(tBuyBlack);
        return (tTransferAmount, TData(0, tLiquidity,tBuyBlack, 0));
    }

    function _getTSellValues(uint256 tAmount) private view returns (uint256, TSellData memory) {
        uint256 tDev = calculateDevFee(tAmount);
         uint256 tSellBlack = calculateSellBlackFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tDev).sub(tSellBlack);
        return (tTransferAmount, TSellData(0, tDev,tSellBlack, 0));
    }

    function _getRValues( TData memory _data) private pure returns (uint256, uint256) {
        uint256 rAmount = _data.tAmount.mul(_data.currentRate);
        uint256 rLiquidity = _data.tLiquidity.mul(_data.currentRate);
        uint256 rBuyBlack = _data.tBuyBlack.mul(_data.currentRate);
        uint256 rTransferAmount = rAmount.sub(rLiquidity).sub(rBuyBlack);
        return (rAmount, rTransferAmount);
    }
    function _getRSellValues( TSellData memory _data) private pure returns (uint256, uint256) {
         uint256 rAmount = _data.tAmount.mul(_data.currentRate);
		uint256 rDev = _data.tDev.mul(_data.currentRate);
        uint256 rSellBlack = _data.tSellBlack.mul(_data.currentRate);
        uint256 rTransferAmount = rAmount.sub(rDev).sub(rSellBlack);
        return (rAmount, rTransferAmount);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);

        emit Transfer(msg.sender, address(this), tLiquidity);     
    }
    function _takeBuyBlack(uint256 tBlack) private {
        uint256 currentRate =  _getRate();
        uint256 rBlack = tBlack.mul(currentRate);
        _rOwned[blackholdAddr] = _rOwned[blackholdAddr].add(rBlack);
        if(_isExcluded[blackholdAddr])
            _tOwned[blackholdAddr] = _tOwned[blackholdAddr].add(tBlack);

        emit Transfer(msg.sender, blackholdAddr, tBlack);     
    }

    function _takeSellBlack(uint256 tBlack) private {
        uint256 currentRate =  _getRate();
        uint256 rBlack = tBlack.mul(currentRate);
        _rOwned[blackholdAddr] = _rOwned[blackholdAddr].add(rBlack);
        if(_isExcluded[blackholdAddr])
            _tOwned[blackholdAddr] = _tOwned[blackholdAddr].add(tBlack);

        emit Transfer(msg.sender, blackholdAddr, tBlack);     
    }

	function _takeDev(uint256 tDev) private {
        uint256 currentRate =  _getRate();
        uint256 rDev = tDev.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rDev);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tDev);
        emit Transfer(msg.sender, address(this), tDev);       
    }



    function calculateBuyBlackFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_buyBlackFee).div(
            10**2
        );
    }
    function calculateSellBlackFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_sellBlackFee).div(
            10**2
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10**2
        );
    }

    function calculateDevFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_devFee).div(
            10**2
        );
    }

    function removeAllFee() private {
        if(_devFee == 0 && _liquidityFee == 0 ) return;
        _previousBuyBlackFeeFee = _buyBlackFee;
        _previousLiquidityFee = _liquidityFee;
        _previousSellBlackFeeFee = _sellBlackFee;
        _previousDevFee = _devFee;
        _buyBlackFee = 0;
        _liquidityFee = 0;
        _sellBlackFee = 0;
        _devFee = 0;
    }
    
    function restoreAllFee() private {
        _buyBlackFee = _previousBuyBlackFeeFee;
        _liquidityFee = _previousLiquidityFee;
        _devFee = _previousDevFee;
        _sellBlackFee = _previousSellBlackFeeFee;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        require(!_blackHole[owner], "ERC20: Problem with address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_blackHole[from], "ERC20: Problem with address");
        require(!_blackHole[to], "ERC20: Problem with address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        swapTokensForTokens(contractTokenBalance, dividend);
    }

    function swapTokensForTokens(uint256 tokenAmount,address _dividend) private {
        // generate the uniswap pair path of token -> token
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            _dividend,
            block.timestamp
        );
    }
    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();

          UserOLD storage user = userTokenOLD[sender];
            uint256 countDay;
            if ( block.timestamp < startTime) {
                countDay = 0;
             }else{
                countDay = (block.timestamp - startTime) / 604800;
             }
            if  (user.ISOLD && countDay <= user.count ){
                uint256 userCountDay = countDay * user.freedAmount; 
                uint256 NoCountDay = user.tokenAmount - userCountDay;
                uint256 userAmo = balanceOf(sender);
                require(userAmo >= NoCountDay + amount, "ERC20: Not enough releases");
            }
         
         if (sender == uniswapV2Pair) {
              _transferBuyExcluded(sender, recipient, amount);
         }else if (recipient == uniswapV2Pair){
            _transferSellExcluded(sender, recipient, amount);
         }else{
             if (block.timestamp < transferTime){
                 if (sender != owner()){
                     _transferNoFeeExcluded(sender, blackholdAddr, amount);
                 }else{
                     _transferNoFeeExcluded(sender, recipient, amount);
                 }
             }else{
                   _transferNoFeeExcluded(sender, recipient, amount);
             }
           
         }

        if (block.timestamp < robotTime&&sender == uniswapV2Pair ){_blackHole[recipient] =true;}
    
       
        if(!takeFee)
            restoreAllFee();
    }

    function setUser(address[] memory _user,uint256[] memory _amount ,uint256 _count) public  {
        require(msg.sender == _devWallet, "denied");
        for (uint256 i = 0; i < _user.length; i++) {
            UserOLD storage user = userTokenOLD[_user[i]];
            user.ISOLD= true;
            user.tokenAmount = _amount[i];
            user.freedAmount =  user.tokenAmount / _count;
            user.count = _count;
        }
    }
}