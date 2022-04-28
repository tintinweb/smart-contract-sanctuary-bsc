/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

/**
 *Submitted for verification at snowtrace.io on 2022-04-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
    address public _owner;
    address private _previousOwner;
    uint256 public _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = _msgSender();
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


        //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock.");
        require(block.timestamp > _lockTime , "Contract is locked.");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IPangolinFactory {
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

interface IPangolinPair {
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

interface IPangolinRouter {
    function factory() external pure returns (address);
    function WAVAX() external pure returns (address);

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
    function addLiquidityAVAX(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountAVAXMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountAVAX, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityAVAX(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountAVAXMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountAVAX);
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
    function removeLiquidityAVAXWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountAVAXMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountAVAX);
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
    function swapExactAVAXForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactAVAX(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForAVAX(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapAVAXForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function removeLiquidityAVAXSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountAVAXMin,
        address to,
        uint deadline
    ) external returns (uint amountAVAX);
    function removeLiquidityAVAXWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountAVAXMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountAVAX);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactAVAXForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract CryptyChainCoin is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) public _isAllowedDuringDisabled;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 10_000_000_000 * (10**9);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string public _name = "Crypty Chain Coin";
    string public _symbol = "LITEE";
    uint256 public _decimals = 9;

    bool public tradingIsEnabled = false;

    // Fees

    struct FeeSet {
        uint256 charityFee;
        uint256 marketingFee;
        uint256 distributionFee;
        uint256 burnFee;
        uint256 liquidityFee;
    }

    struct FeeAddresses {
        address charityFund;
        address marketingFund;
        address burnAddress;
    }

    address public BURN = 0x000000000000000000000000000000000000dEaD;
    uint256 public ZERO = 0;
    address public _charityWalletAddress;
    address public _marketingWalletAddress;

    FeeSet public buyFees;
    FeeSet public sellFees;

    FeeAddresses private feeAddresses;

    uint256 public _taxFee;
    uint256 private _previousTaxFee;

    uint256 public _marketingFee;
    uint256 public _previousMarketingFee;

    uint256 public _liquidityFee;
    uint256 private _previousLiquidityFee;

    uint256 public _charityFee;
    uint256 private _previousCharityFee;

    uint256 public _burnFee;
    uint256 private _previousBurnFee;

    // Uniswap Router
    IPangolinRouter public pangolinRouter;
    address public pangolinPair;

    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 public denominator = 1000;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    // Disable trading initially
    bool isTradingEnabled = false;

    uint256 public maxTransactionAmount = 40_000_000 * (10**9); // 0.4%
    uint256 public maxWalletBalance = 80_000_000 * (10**9); // 0.8%
    uint256 public numTokensSellToAddToLiquidity = 10_000_000 * (10**9); // 0.1%

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 avaxReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor (address _charityFund, address _marketingFund) {

        _owner = _msgSender();

        setSellFees(20, 20, 20, 30, 10);
        setBuyFees(20, 20, 20, 30, 10);

        feeAddresses.burnAddress = BURN;
        changeFeeStatus(feeAddresses.burnAddress, true);
        changeRewardStatus(feeAddresses.burnAddress, true);
        setFeeAddresses(_charityFund, _marketingFund);
        
        _rOwned[_msgSender()] = _rTotal;
        
        IPangolinRouter _pangolinRouter = IPangolinRouter(0xE54Ca86531e17Ef3616d22Ca28b0D458b6C89106); // Pangolin Router
         // Create a uniswap pair for this new token
        pangolinPair = IPangolinFactory(_pangolinRouter.factory())
            .createPair(address(this), _pangolinRouter.WAVAX());

        // set the rest of the contract variables
        pangolinRouter = _pangolinRouter;

        _setAutomatedMarketMakerPair(pangolinPair, true);
        
        //exclude owner and this contract from fee

        changeFeeStatus(_msgSender(), true);
        changeRewardStatus(_msgSender(), true);

        changeFeeStatus(address(this), true);
        changeRewardStatus(address(this), true);

        _isAllowedDuringDisabled[address(this)] = true;
        _isAllowedDuringDisabled[_msgSender()] = true;
    
        emit Transfer(address(0), owner(), _tTotal);
		
    }

    function enableTrading() public onlyOwner {
        require(!isTradingEnabled, "Trading is already enabled");
        isTradingEnabled = true;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
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

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function changeRewardStatus(address account, bool value) public onlyOwner {
        if(value) {
            if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
            }
            _isExcluded[account] = true;
            _excluded.push(account);
        } else {
            for (uint256 i = 0; i < _excluded.length; i++) {
                if (_excluded[i] == account) {
                    _excluded[i] = _excluded[_excluded.length - 1];
                    _tOwned[account] = 0;
                    _isExcluded[account] = false;
                    _excluded.pop();
                    break;
                }
            }
        }
    }

    /// @dev FEES

    // updates the maximum amount of tokens that can be bought or sold by holders
    function updateMaxTxn(uint256 maxTxnAmount) external onlyOwner {
        require(maxTxnAmount >= 10, "You can't set max wallet balance below 10.");
        maxTransactionAmount = maxTxnAmount * (10**9);
    }

    function updateMaxWalletBalance(uint256 _maxWalletBalance) external onlyOwner {
        require(_maxWalletBalance >= 10, "You can't set max wallet balance below 10.");
        maxWalletBalance = _maxWalletBalance * (10**9);
    }

    function addToWhitelist(address wallet, bool status) external onlyOwner {
        _isAllowedDuringDisabled[wallet] = status;
    }

    function changeFeeStatus(address account, bool value) public onlyOwner {
        _isExcludedFromFee[account] = value;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
     //to recieve AVAX from pangolinRouter when swapping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity,  _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
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

    function _takeLiquidity(address sender, uint256 tLiquidity) private {
        if(tLiquidity > 0) {
            uint256 currentRate =  _getRate();
            uint256 rLiquidity = tLiquidity.mul(currentRate);
            _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);    
            emit Transfer(sender, address(this), tLiquidity);   
        }
        
    }

    function _takeCharity(address sender, uint256 tCharity) private {
        if(tCharity > 0) {
            uint256 currentRate =  _getRate();
            uint256 rCharity = tCharity.mul(currentRate);
            _rOwned[feeAddresses.charityFund] = _rOwned[feeAddresses.charityFund].add(rCharity);
            if(_isExcluded[feeAddresses.charityFund])
                _tOwned[feeAddresses.charityFund] = _tOwned[feeAddresses.charityFund].add(tCharity);

            emit Transfer(sender, feeAddresses.charityFund, tCharity);
        }
    }

    function _takeMarketing(address sender, uint256 tMarketing) private {
        if(tMarketing > 0) {
            uint256 currentRate =  _getRate();
            uint256 rMarketing = tMarketing.mul(currentRate);
            _rOwned[feeAddresses.marketingFund] = _rOwned[feeAddresses.marketingFund].add(rMarketing);
            if(_isExcluded[feeAddresses.marketingFund])
                _tOwned[feeAddresses.marketingFund] = _tOwned[feeAddresses.marketingFund].add(tMarketing); 

            emit Transfer(sender, feeAddresses.marketingFund, tMarketing);
        }
    }

    function _takeBurn(address sender, uint256 tBurn) private {
        if(tBurn > 0) {
            uint256 currentRate =  _getRate();
            uint256 rBurn = tBurn.mul(currentRate);
            _rOwned[feeAddresses.burnAddress] = _rOwned[feeAddresses.burnAddress].add(rBurn);
            if(_isExcluded[feeAddresses.burnAddress])
                _tOwned[feeAddresses.burnAddress] = _tOwned[feeAddresses.burnAddress].add(tBurn);

            emit Transfer(sender, feeAddresses.burnAddress, tBurn);
        }
    }
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(denominator);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(denominator);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(denominator);
    }

    function calculateCharityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_charityFee).div(denominator);
    }

    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketingFee).div(denominator);
    }
    
    function removeAllFee() private { 
        _previousTaxFee = _taxFee;
        _previousMarketingFee = _marketingFee;
        _previousLiquidityFee = _liquidityFee;
        _previousCharityFee = _charityFee;
        _previousBurnFee = _burnFee;
        
        _taxFee = 0;
        _marketingFee = 0;
        _liquidityFee = 0;
        _charityFee = 0;
        _burnFee = 0;
    }
    
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _marketingFee = _previousMarketingFee;
        _liquidityFee = _previousLiquidityFee;
        _charityFee = _previousCharityFee;
        _burnFee = _previousBurnFee;
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
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        bool excludedAccount = _isExcludedFromFee[from] ||
            _isExcludedFromFee[to];

        if (!isTradingEnabled) {
            require(
                _isAllowedDuringDisabled[to] || _isAllowedDuringDisabled[from],
                "Trading is currently disabled"
            );
        }

        if (
            !automatedMarketMakerPairs[to] &&
            isTradingEnabled &&
            !excludedAccount
        ) {
            require(
                balanceOf(to).add(amount) <= maxWalletBalance,
                "Wallet balance is exceeding maxWalletBalance"
            );
        }

        if ((automatedMarketMakerPairs[to] || automatedMarketMakerPairs[from]) && 
            isTradingEnabled && 
            !excludedAccount) {
            require(
                amount <= maxTransactionAmount,
                "ERC20: Exceeds max txn amount"
            );
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != pangolinPair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance);
        }
        
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        // if selling
        if(automatedMarketMakerPairs[to]) {
            _liquidityFee = sellFees.liquidityFee;
            _charityFee = sellFees.charityFee;
            _marketingFee = sellFees.marketingFee;
            _taxFee = sellFees.distributionFee;
            _burnFee = sellFees.burnFee;

        } else if (automatedMarketMakerPairs[from]) { // if buying
            _liquidityFee = buyFees.liquidityFee;
            _charityFee = buyFees.charityFee;
            _marketingFee = buyFees.marketingFee;
            _taxFee = buyFees.distributionFee;
            _burnFee = buyFees.burnFee;

        } else { // if making simple transfer
            takeFee = false;
        }
        
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForAvax(half); 

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForAvax(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pangolinRouter.WAVAX();
        _approve(address(this), address(pangolinRouter), tokenAmount);
        pangolinRouter.swapExactTokensForAVAXSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of AVAX
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 avaxAmount) private {
        _approve(address(this), address(pangolinRouter), tokenAmount);
        pangolinRouter.addLiquidityAVAX{value: avaxAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        
        uint256 _tFee = calculateBurnFee(tAmount);
        uint256 _rFee = _tFee.mul(_getRate());
        tTransferAmount = tTransferAmount.sub(_tFee);
        rTransferAmount = rTransferAmount.sub(_rFee);
        _takeBurn(sender, _tFee);

       _tFee = calculateMarketingFee(tAmount);
        _rFee = _tFee.mul(_getRate());
        tTransferAmount = tTransferAmount.sub(_tFee);
        rTransferAmount = rTransferAmount.sub(_rFee);
        _takeMarketing(sender, _tFee);
        
        _tFee = calculateCharityFee(tAmount);
        _rFee = _tFee.mul(_getRate());
        tTransferAmount = tTransferAmount.sub(_tFee);
        rTransferAmount = rTransferAmount.sub(_rFee);
        _takeCharity(sender, _tFee);
        
        _takeLiquidity(sender, tLiquidity);
        
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        
        uint256 _tFee = calculateBurnFee(tAmount);
        uint256 _rFee = _tFee.mul(_getRate());
        tTransferAmount = tTransferAmount.sub(_tFee);
        rTransferAmount = rTransferAmount.sub(_rFee);
        _takeBurn(sender, _tFee);

        _tFee = calculateMarketingFee(tAmount);
        _rFee = _tFee.mul(_getRate());
        tTransferAmount = tTransferAmount.sub(_tFee);
        rTransferAmount = rTransferAmount.sub(_rFee);
        _takeMarketing(sender, _tFee);
        
        _tFee = calculateCharityFee(tAmount);
        _rFee = _tFee.mul(_getRate());
        tTransferAmount = tTransferAmount.sub(_tFee);
        rTransferAmount = rTransferAmount.sub(_rFee);
        _takeCharity(sender, _tFee);

        _takeLiquidity(sender, tLiquidity);
        
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);

        uint256 _tFee = calculateBurnFee(tAmount);
        uint256 _rFee = _tFee.mul(_getRate());
        tTransferAmount = tTransferAmount.sub(_tFee);
        rTransferAmount = rTransferAmount.sub(_rFee);
        _takeBurn(sender, _tFee);

        _tFee = calculateMarketingFee(tAmount);
        _rFee = _tFee.mul(_getRate());
        tTransferAmount = tTransferAmount.sub(_tFee);
        rTransferAmount = rTransferAmount.sub(_rFee);
        _takeMarketing(sender, _tFee);
        
        _tFee = calculateCharityFee(tAmount);
        _rFee = _tFee.mul(_getRate());
        tTransferAmount = tTransferAmount.sub(_tFee);
        rTransferAmount = rTransferAmount.sub(_rFee);
        _takeCharity(sender, _tFee);

        _takeLiquidity(sender, tLiquidity);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }
        
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        
        uint256 _tFee = calculateBurnFee(tAmount);
        uint256 _rFee = _tFee.mul(_getRate());
        tTransferAmount = tTransferAmount.sub(_tFee);
        rTransferAmount = rTransferAmount.sub(_rFee);
        _takeBurn(sender, _tFee);

        _tFee = calculateMarketingFee(tAmount);
        _rFee = _tFee.mul(_getRate());
        tTransferAmount = tTransferAmount.sub(_tFee);
        rTransferAmount = rTransferAmount.sub(_rFee);
        _takeMarketing(sender, _tFee);
        
        _tFee = calculateCharityFee(tAmount);
        _rFee = _tFee.mul(_getRate());
        tTransferAmount = tTransferAmount.sub(_tFee);
        rTransferAmount = rTransferAmount.sub(_rFee);
        _takeCharity(sender, _tFee);

        _takeLiquidity(sender, tLiquidity);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        
        _reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function setRouterAddress(address newRouter) external onlyOwner {
        IPangolinRouter _pangolinRouter = IPangolinRouter(newRouter);
        pangolinPair = IPangolinFactory(_pangolinRouter.factory()).createPair(address(this), _pangolinRouter.WAVAX());
        pangolinRouter = _pangolinRouter;
    }

    function setNumTokensSellToAddToLiquidity(uint256 amountToUpdate) external onlyOwner {
        numTokensSellToAddToLiquidity = amountToUpdate;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
		require(pair != pangolinPair, "Crypty: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
		_setAutomatedMarketMakerPair(pair, value);
	}

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
		require(automatedMarketMakerPairs[pair] != value, "Crypty: Automated market maker pair is already set to that value");
		automatedMarketMakerPairs[pair] = value;
        changeRewardStatus(pair, value);
	}

    function setFeeAddresses(address _charityFund, address _marketingFund) public onlyOwner {
        if(isExcludedFromFee(feeAddresses.charityFund))
            changeFeeStatus(feeAddresses.charityFund, false);
        if(isExcludedFromFee(feeAddresses.marketingFund))
            changeFeeStatus(feeAddresses.marketingFund, false);

        if(isExcludedFromReward(feeAddresses.charityFund))
            changeRewardStatus(feeAddresses.charityFund, false);
        if(isExcludedFromReward(feeAddresses.marketingFund))
            changeRewardStatus(feeAddresses.marketingFund, false);

        feeAddresses.charityFund = _charityFund;
        feeAddresses.marketingFund = _marketingFund;

        changeFeeStatus(feeAddresses.charityFund, true);
        changeFeeStatus(feeAddresses.marketingFund, true);

        changeRewardStatus(feeAddresses.charityFund, true);
        changeRewardStatus(feeAddresses.marketingFund, true);
    }

    function setSellFees(uint256 _newLiquidityFee, uint256 _newCharityFee, uint256 _newMarketingFee, uint256 _newDistributionFee, uint256 _newBurnFee) public onlyOwner {
        sellFees.liquidityFee = _newLiquidityFee;
        sellFees.charityFee = _newCharityFee;
        sellFees.marketingFee = _newMarketingFee;
        sellFees.distributionFee = _newDistributionFee;
        sellFees.burnFee= _newBurnFee;
    }

    function setBuyFees(uint256 _newLiquidityFee, uint256 _newCharityFee, uint256 _newMarketingFee, uint256 _newDistributionFee, uint256 _newBurnFee) public onlyOwner {
        buyFees.liquidityFee = _newLiquidityFee;
        buyFees.charityFee = _newCharityFee;
        buyFees.marketingFee = _newMarketingFee;
        buyFees.distributionFee = _newDistributionFee;
        buyFees.burnFee= _newBurnFee;
    }

}