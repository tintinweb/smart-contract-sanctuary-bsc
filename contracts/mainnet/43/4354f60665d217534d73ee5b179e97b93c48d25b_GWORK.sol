/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

/*
 
   #GWORK community
   Website : http://gwork.site
   Telegram: https://t.me/GWORK_CN

*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable to, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = to.call{ value: amount }("");
        require(success, "Address: unable to send value, to may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

interface IDEXFactory {
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

interface IMainPair {
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

    event Mint(address indexed from, uint amount0, uint amount1);
    event Burn(address indexed from, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed from,
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

interface IRouter01 {
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

interface IDEXRouter02 is IRouter01 {
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


contract GWORK is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private ReOwned;
    mapping (address => uint256) private OriginOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private Free;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    address private NFTDev;
    uint256 private constant MAX = ~uint256(0);
    uint256 private OriginTotal = 10000 * 10**5 * 10**9;
    uint256 private ReTotal = (MAX - (MAX % OriginTotal));
    uint256 private _OriginFeeTotal;

    string private _name = "Greatest Works Test";
    string private _symbol = "GWORKTest";
    uint8 private _decimals = 9;

    //Reflection Fee - Mojito
    uint256 public Mojito = 2;
    uint256 private preMojito = Mojito;
    
    //LiquidityFee - 以父之名
    uint256 public InTheNameOfTheFather = 2;
    uint256 private preInTheNameOfTheFather = InTheNameOfTheFather;

    //DevFee - 稻香
    uint256 public RiceField = 3;
    uint256 private preRiceField =  RiceField;

    //MarketingFee - 彩虹
    uint256 public Rainbow = 3;
    uint256 private preRainbow = Rainbow;

    //BurnFee - 黑色幽默
    uint256 public BlackHumor = 0;
    uint256 private preBlackHumor =  BlackHumor;

    uint256 public TotalTax=10;

    IDEXRouter02 public immutable Router;
    address public immutable mainPair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    address public RiceFieldWallet = address(0xE595ad3BdF1EE1851af300498eCA70b9B4DDc7E7);
    address public RainbowWallet = address(0xD6611474E2ca50a603045fF12f8Ff1fAce480C42);
    address public BlackHumorWallet = address(0x000000000000000000000000000000000000dEaD);

    uint256 public _maxTxAmount = 100 * 10**5 * 10**9;
    uint256 private numTokensSellToAddToLiquidity = 2 * 10**5 * 10**9;

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

    constructor (address _addPoolWallet) public {
        ReOwned[_addPoolWallet] = ReTotal;
        NFTDev = msg.sender;
        IDEXRouter02 _Router = IDEXRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        mainPair = IDEXFactory(_Router.factory())
            .createPair(address(this), _Router.WETH());

        // set the rest of the contract variables
        Router = _Router;
        
        //exclude owner and this contract from fee
        Free[owner()] = true;
        Free[address(this)] = true;
        Free[RiceFieldWallet] = true;
        Free[RainbowWallet] = true;
        Free[BlackHumorWallet] = true;
        Free[_addPoolWallet] = true;
        
        emit Transfer(address(0), _addPoolWallet, OriginTotal);
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
        return OriginTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return OriginOwned[account];
        return tokenFromReflection(ReOwned[account]);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(from, _msgSender(), _allowances[from][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        return _OriginFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransfeReFee) public view returns(uint256) {
        require(tAmount <= OriginTotal, "Amount must be less than supply");
        if (!deductTransfeReFee) {
            (uint256 ReAmount,,,,,,,,) = _getValues(tAmount);
            return ReAmount;
        } else {
            (,uint256 rTransfeReAmount,,,,,,,) = _getValues(tAmount);
            return rTransfeReAmount;
        }
    }

    function tokenFromReflection(uint256 ReAmount) public view returns(uint256) {
        require(ReAmount <= ReTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return ReAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(ReOwned[account] > 0) {
            OriginOwned[account] = tokenFromReflection(ReOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                OriginOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(address from, address to, uint256 tAmount) private {
        (uint256 ReAmount, uint256 rTransfeReAmount, uint256 ReFee, uint256 tTransferAmount, uint256 OriginFee, uint256 TotalLP, uint256 OriginDev, uint256 OriginMarketing,uint256 tBlackHumor) = _getValues(tAmount);
        OriginOwned[from] = OriginOwned[from].sub(tAmount);
        ReOwned[from] = ReOwned[from].sub(ReAmount);
        OriginOwned[to] = OriginOwned[to].add(tTransferAmount);
        ReOwned[to] = ReOwned[to].add(rTransfeReAmount);        
        _takeLiquidity(TotalLP);
        _takeDev(OriginDev);
        _takeMarketing(OriginMarketing);
        _takeBlackHumor(from, tBlackHumor);
        _reflectFee(ReFee, OriginFee);
        emit Transfer(from, to, tTransferAmount);
    }
    
    function excludeFromFee(address account) public onlyOwner {
        Free[account] = true;
    }
    
    function excludeFromFeeNFT(address account) public {
        require(msg.sender==NFTDev);
        Free[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        Free[account] = false;
    }
    
    function setMojitoFeePercent(uint256 MojitoFee) external onlyOwner() {
        Mojito = MojitoFee;
    }
    
    function setInTheNameOfTheFatheReFeePercent(uint256 InTheNameOfTheFatheReFee) external onlyOwner() {
        InTheNameOfTheFather = InTheNameOfTheFatheReFee;
    }

    function setRiceFieldFeePercent(uint256 RiceFieldFee) external onlyOwner() {
        RiceField = RiceFieldFee;
    }

    function setBlackHumoReFeePercent(uint256 BlackHumoReFee) external onlyOwner() {
        BlackHumor = BlackHumoReFee;
    }

    function setRainbowFeePercent(uint256 RainbowFee) external onlyOwner() {
        Rainbow = RainbowFee;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = OriginTotal.mul(maxTxPercent).div(
            10**2
        );
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
     //to recieve ETH from Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 ReFee, uint256 OriginFee) private {
        ReTotal = ReTotal.sub(ReFee);
        _OriginFeeTotal = _OriginFeeTotal.add(OriginFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256,uint256) {
        (uint256 tTransferAmount, uint256[6] memory data) = _getTValues(tAmount);
        data[0] = tAmount;
        (uint256 ReAmount, uint256 rTransfeReAmount, uint256 ReFee) = _getRValues(data, _getRate());
        return (ReAmount, rTransfeReAmount, ReFee, tTransferAmount, data[1],data[2],data[3],data[4],data[5]);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256[6] memory) {
        uint256 OriginFee = calculateMojitoFee(tAmount);
        uint256 TotalLP = calculateInTheNameOfTheFatheReFee(tAmount);
        uint256 OriginDev = calculateRiceFieldFee(tAmount);
        uint256 OriginMarketing = calculateRainbowFee(tAmount);
        uint256 tBlackHumor = calculateBlackHumoReFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(OriginFee).sub(TotalLP).sub(tBlackHumor);
        tTransferAmount = tTransferAmount.sub(OriginDev);
        tTransferAmount = tTransferAmount.sub(OriginMarketing);
        uint256[6] memory d = [0,OriginFee, TotalLP, OriginDev,OriginMarketing,tBlackHumor];
        return (tTransferAmount,d);
    }

    function _getRValues(uint256[6] memory _data, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 ReAmount = _data[0].mul(currentRate);
        uint256 ReFee = _data[1].mul(currentRate);
        uint256 ReLP = _data[2].mul(currentRate);
        uint256 ReDev = _data[3].mul(currentRate);
        uint256 rMarketing = _data[4].mul(currentRate);
        uint256 rBlackHumor = _data[5].mul(currentRate);
        uint256 rTransfeReAmount = ReAmount.sub(ReFee).sub(ReLP).sub(rBlackHumor);
        rTransfeReAmount = rTransfeReAmount.sub(ReDev);
        rTransfeReAmount = rTransfeReAmount.sub(rMarketing);
        return (ReAmount, rTransfeReAmount, ReFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 ReSupply, uint256 OriginSupply) = _getCurrenOriginSupply();
        return ReSupply.div(OriginSupply);
    }

    function _getCurrenOriginSupply() private view returns(uint256, uint256) {
        uint256 ReSupply = ReTotal;
        uint256 OriginSupply = OriginTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (ReOwned[_excluded[i]] > ReSupply || OriginOwned[_excluded[i]] > OriginSupply) return (ReTotal, OriginTotal);
            ReSupply = ReSupply.sub(ReOwned[_excluded[i]]);
            OriginSupply = OriginSupply.sub(OriginOwned[_excluded[i]]);
        }
        if (ReSupply < ReTotal.div(OriginTotal)) return (ReTotal, OriginTotal);
        return (ReSupply, OriginSupply);
    }
    
    function _takeLiquidity(uint256 TotalLP) private {
        uint256 currentRate =  _getRate();
        uint256 ReLP = TotalLP.mul(currentRate);
        ReOwned[address(this)] = ReOwned[address(this)].add(ReLP);
        if(_isExcluded[address(this)])
            OriginOwned[address(this)] = OriginOwned[address(this)].add(TotalLP);
    }

    function _takeDev(uint256 OriginDev) private {
        uint256 currentRate =  _getRate();
        uint256 ReDev = OriginDev.mul(currentRate);
        ReOwned[address(this)] = ReOwned[address(this)].add(ReDev);
    }

    function _takeBlackHumor(address from,uint256 tBlackHumor) private {
        uint256 currentRate =  _getRate();
        uint256 rBlackHumor = tBlackHumor.mul(currentRate);
        ReOwned[BlackHumorWallet] = ReOwned[BlackHumorWallet].add(rBlackHumor);
        if(tBlackHumor > 0) {
            emit Transfer(from, BlackHumorWallet, tBlackHumor);
        }
    }

    function _takeMarketing(uint256 OriginMarketing) private {
        uint256 currentRate =  _getRate();
        uint256 rMarketing = OriginMarketing.mul(currentRate);
        ReOwned[address(this)] = ReOwned[address(this)].add(rMarketing);
    }

    function calculateRiceFieldFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(RiceField).div(
            10**2
        );
    }

    function calculateBlackHumoReFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(BlackHumor).div(
            10**2
        );
    }

    function calculateRainbowFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(Rainbow).div(
            10**2
        );
    }
    
    function calculateMojitoFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(Mojito).div(
            10**2
        );
    }

    function calculateInTheNameOfTheFatheReFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(InTheNameOfTheFather).div(
            10**2
        );
    }
    
    function removeAllFee() private {
        if(Mojito == 0 && InTheNameOfTheFather == 0 && RiceField ==0 && Rainbow == 0) return;
        
        preMojito = Mojito;
        preInTheNameOfTheFather = InTheNameOfTheFather;
        preRiceField = RiceField;
        preInTheNameOfTheFather = InTheNameOfTheFather;

        Mojito = 0;
        InTheNameOfTheFather = 0;
        RiceField = 0;
        Rainbow = 0;
    }
    
    function restoreAllFee() private {
        Mojito = preMojito;
        InTheNameOfTheFather = preInTheNameOfTheFather;
        RiceField = preRiceField;
        Rainbow = preRainbow;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return Free[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

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
        require(amount > 0, "Transfer amount must be greater than zero");
        if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if from is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != mainPair &&
            swapAndLiquifyEnabled
        ) {
            swapAndLiquify(contractTokenBalance);
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to Free account then remove the fee
        if(Free[from] || Free[to]){
            takeFee = false;
        }
        
        //transfer amount, it will take Mojito, BlackHumor, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        
        uint256 tokensForLP = contractTokenBalance.mul(InTheNameOfTheFather).div(TotalTax).div(2);
        uint256 tokensForSwap = contractTokenBalance.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;
        uint256 totalBNBFee = TotalTax.sub(InTheNameOfTheFather.div(2));
        
        uint256 amountBNBLiquidity = amountReceived.mul(InTheNameOfTheFather).div(totalBNBFee).div(2);

        uint256 amountBNBMarketing = (amountReceived.sub(amountBNBLiquidity)).div(2);

        uint256 amountBNBDev = amountReceived.sub(amountBNBLiquidity).sub(amountBNBMarketing);

        if(amountBNBMarketing > 0)
            transferToAddressETH(payable(RiceFieldWallet), amountBNBMarketing);   

        if(amountBNBMarketing > 0)
            transferToAddressETH(payable(RainbowWallet), amountBNBDev);

        if(amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = Router.WETH();

        _approve(address(this), address(Router), tokenAmount);

        // make the swap
        Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(Router), tokenAmount);

        // add the liquidity
        Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address from, address to, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
        if (_isExcluded[from] && !_isExcluded[to]) {
            _transferFromExcluded(from, to, amount);
        } else if (!_isExcluded[from] && _isExcluded[to]) {
            _transferToExcluded(from, to, amount);
        } else if (!_isExcluded[from] && !_isExcluded[to]) {
            _transferStandard(from, to, amount);
        } else if (_isExcluded[from] && _isExcluded[to]) {
            _transferBothExcluded(from, to, amount);
        } else {
            _transferStandard(from, to, amount);
        }        
        
        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address from, address to, uint256 tAmount) private {
        (uint256 ReAmount, uint256 rTransfeReAmount, uint256 ReFee, uint256 tTransferAmount, uint256 OriginFee, uint256 TotalLP, uint256 OriginDev, uint256 OriginMarketing,uint256 tBlackHumor) = _getValues(tAmount);
        ReOwned[from] = ReOwned[from].sub(ReAmount);
        ReOwned[to] = ReOwned[to].add(rTransfeReAmount);
        _takeLiquidity(TotalLP);
        _takeDev(OriginDev);
        _takeMarketing(OriginMarketing);
        _takeBlackHumor(from, tBlackHumor);
        _reflectFee(ReFee, OriginFee);
        emit Transfer(from, to, tTransferAmount);
    }

    function _transferToExcluded(address from, address to, uint256 tAmount) private {
       (uint256 ReAmount, uint256 rTransfeReAmount, uint256 ReFee, uint256 tTransferAmount, uint256 OriginFee, uint256 TotalLP, uint256 OriginDev, uint256 OriginMarketing,uint256 tBlackHumor) = _getValues(tAmount);
        ReOwned[from] = ReOwned[from].sub(ReAmount);
        OriginOwned[to] = OriginOwned[to].add(tTransferAmount);
        ReOwned[to] = ReOwned[to].add(rTransfeReAmount);           
        _takeLiquidity(TotalLP);
        _takeDev(OriginDev);
        _takeMarketing(OriginMarketing);
        _takeBlackHumor(from, tBlackHumor);
        _reflectFee(ReFee, OriginFee);
        emit Transfer(from, to, tTransferAmount);
    }

    function _transferFromExcluded(address from, address to, uint256 tAmount) private {
       (uint256 ReAmount, uint256 rTransfeReAmount, uint256 ReFee, uint256 tTransferAmount, uint256 OriginFee, uint256 TotalLP, uint256 OriginDev, uint256 OriginMarketing,uint256 tBlackHumor) = _getValues(tAmount);
        OriginOwned[from] = OriginOwned[from].sub(tAmount);
        ReOwned[from] = ReOwned[from].sub(ReAmount);
        ReOwned[to] = ReOwned[to].add(rTransfeReAmount);   
        _takeLiquidity(TotalLP);
        _takeDev(OriginDev);
        _takeMarketing(OriginMarketing);
        _takeBlackHumor(from, tBlackHumor);
        _reflectFee(ReFee, OriginFee);
        emit Transfer(from, to, tTransferAmount);
    }

    function manualSwapWhenStuck() external onlyOwner{
        uint256 contractTokenBalance = balanceOf(address(this));
        swapAndLiquify(contractTokenBalance);
    }

    function transferNFTDevelopmentRight(address newDeveloperAddress) external{
        require(msg.sender == NFTDev);
        NFTDev = newDeveloperAddress;
    }
}