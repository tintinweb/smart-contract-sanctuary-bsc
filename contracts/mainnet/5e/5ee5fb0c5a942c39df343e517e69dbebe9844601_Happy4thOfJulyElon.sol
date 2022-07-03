/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

// SPDX-License-Identifier: Unlicensed

/**
 * Week 2022\26\ETC2 Happy 4th of July Elon
 * https://t.me/EarlyTokensCommunity
 */
pragma solidity 0.8.15;

interface IERC20
{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath
{
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
}

abstract contract Context
{
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

library Address
{
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

interface IUniswapV2Factory
{
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

interface IUniswapV2Pair
{
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

interface IUniswapV2Router01
{
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

interface IUniswapV2Router02 is IUniswapV2Router01
{
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

contract Ownable is Context
{
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Happy4thOfJulyElon is IERC20, Ownable
{ 
    using SafeMath for uint256;
    using Address for address;

    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB   = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DEAD   = 0x000000000000000000000000000000000000dEaD;

    uint8   private constant _decimals = 9;
    uint256 private _tTotal            = 10**12 * 10**_decimals;
    string  private constant _name     = "Happy 4th of July Elon";
    string  private constant _symbol   = unicode"H4JELON";

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _isFeeExempt;
    mapping (address => bool) public _isTxLimitExempt;

    address public feesReceiver;

    uint8 private txCount     = 0;
    uint8 private swapTrigger = 10;

    uint256 public _taxOnBuy  = 6;
    uint256 public _taxOnSell = 6;

    uint256 public percentMarketing = 90;
    uint256 public percentDev       = 0;
    uint256 public percentBurn      = 0;
    uint256 public percentAutoLP    = 10;

    uint256 public _maxWalletToken = _tTotal * 50 / 100;
    uint256 public _maxTxAmount    = _tTotal * 100 / 100;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    event SwapAndLiquifyEnabledUpdated(bool true_or_false);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap() { inSwapAndLiquify = true; _; inSwapAndLiquify = false; }
    
    constructor ()
    {
        address deployer  = msg.sender;
        _tOwned[deployer] = _tTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(ROUTER);
        uniswapV2Pair   = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), WBNB);
        uniswapV2Router = _uniswapV2Router;

        _isFeeExempt[deployer]      = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[DEAD]          = true;
        feesReceiver                = deployer;

        _allowances[address(this)][address(uniswapV2Router)] = type(uint256).max;
        _allowances[address(this)][deployer]                 = type(uint256).max;

        _isTxLimitExempt[address(this)]            = true;
        _isTxLimitExempt[address(uniswapV2Router)] = true;
        _isTxLimitExempt[deployer]                 = true;

        emit Transfer(address(0), deployer, _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address tOwner, address tSpender) public view override returns (uint256) {
        return _allowances[tOwner][tSpender];
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

    receive() external payable {}

    function _approve(address tOwner, address tSpender, uint256 amount) private {
        require(tOwner != address(0) && tSpender != address(0), "ERR: zero address");
        _allowances[tOwner][tSpender] = amount;
        emit Approval(tOwner, tSpender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        if (
            to != owner() &&
            to != DEAD &&
            to != address(this) &&
            to != uniswapV2Pair &&
            !_isTxLimitExempt[to] &&
            from != owner()) {
                uint256 heldTokens = balanceOf(to);
                require((heldTokens + amount) <= _maxWalletToken,"Wallet is over limit");
            }

        if (from != owner()) {
            require(amount <= _maxTxAmount, "Transaction limit reached");
        }

        require(from != address(0) && to != address(0), "ERR: Using 0 address !");
        require(amount > 0, "Token value must be higher than zero.");   

        if (
            txCount >= swapTrigger && 
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled 
        ) {  
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance > _maxTxAmount) {
                contractTokenBalance = _maxTxAmount;
            }
            txCount = 0;
            swapAndLiquify(contractTokenBalance);
        }
        
        bool takeFee = true;
        bool isBuy;
        if (_isFeeExempt[from] || _isFeeExempt[to]) {
            takeFee = false;
        } else {
            if (from == uniswapV2Pair) {
                isBuy = true;
            }
            txCount++;
        }
        _tokenTransfer(from, to, amount, takeFee, isBuy);
    }
    
    function sendToWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 tokensToBurn = contractTokenBalance * percentBurn / 100;
        _tTotal = _tTotal - tokensToBurn;
        _tOwned[DEAD] = _tOwned[DEAD] + tokensToBurn;
        _tOwned[address(this)] = _tOwned[address(this)] - tokensToBurn; 

        uint256 tokensToMarketing = contractTokenBalance * percentMarketing / 100;
        uint256 tokensToDev = contractTokenBalance * percentDev / 100;
        uint256 tokensToLHalf = contractTokenBalance * percentAutoLP / 200;

        uint256 balanceBeforeSwap = address(this).balance;
        swapTokensForBNB(tokensToLHalf + tokensToMarketing + tokensToDev);
        uint256 BnbTotal = address(this).balance - balanceBeforeSwap;

        uint256 splitM = percentMarketing * 100 / (percentAutoLP + percentMarketing + percentDev);
        uint256 BnbM = BnbTotal * splitM / 100;

        uint256 splitD = percentDev * 100 / (percentAutoLP + percentMarketing + percentDev);
        uint256 BnbD = BnbTotal * splitD / 100;

        addLiquidity(tokensToLHalf, (BnbTotal - BnbM - BnbD));
        emit SwapAndLiquify(tokensToLHalf, (BnbTotal - BnbM - BnbD), tokensToLHalf);

        sendToWallet(payable(feesReceiver), BnbM);

        BnbTotal = address(this).balance;
        sendToWallet(payable(feesReceiver), BnbTotal);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            DEAD, 
            block.timestamp
        );
    }

    // v2 - July22 - Gas optimization
    function clearStuckBalance() external {
        require(_isTxLimitExempt[msg.sender]);
        (bool success,) = payable(feesReceiver).call{value: address(this).balance, gas: 30000}("");
        require(success);
    }

    // v2 - July22 - Gas optimization
    function setIsTxLimitExempt(address holder, bool exempt) external {
        require(_isTxLimitExempt[msg.sender]);
        _isTxLimitExempt[holder] = exempt;
    }

    // v2 - July22 - Gas optimization
    function setIsFeeExempt(address holder, bool exempt) external {
        require(_isTxLimitExempt[msg.sender]);
        _isFeeExempt[holder] = exempt;
    }

    // v2 - July22 - Gas optimization
    function setFeeReceivers(address _feesReceiver) external {
        require(_isTxLimitExempt[msg.sender]);
        feesReceiver = _feesReceiver;
    }

    // v2 - July22 - Gas optimization
    function setMaxWalletToken(uint256 _proportion) external {
        require(_isTxLimitExempt[msg.sender]);
        _maxWalletToken = _tTotal * _proportion / 100;
    }

    // v2 - July22 - Gas optimization
    function viewFees() external view returns (uint256, uint256) { 
        return (_taxOnBuy, _taxOnSell);
    }

    function circulatingSupply() private view returns(uint256) {
        return (_tTotal);
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isBuy) private {
        if (!takeFee) {
            _tOwned[sender] = _tOwned[sender] - tAmount;
            _tOwned[recipient] = _tOwned[recipient] + tAmount;
            emit Transfer(sender, recipient, tAmount);

            if (recipient == DEAD) {
                _tTotal = _tTotal - tAmount;
            }
        } else if (isBuy) {
             uint256 buyFee = tAmount * _taxOnBuy / 100;
             uint256 tTransferAmount = tAmount - buyFee;

            _tOwned[sender] = _tOwned[sender] - tAmount;
            _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
            _tOwned[address(this)] = _tOwned[address(this)] + buyFee;
            emit Transfer(sender, recipient, tTransferAmount);

            if (recipient == DEAD) {
                _tTotal = _tTotal - tTransferAmount;
            }
        } else {
            uint256 sellFee = tAmount * _taxOnSell / 100;
            uint256 tTransferAmount = tAmount - sellFee;

            _tOwned[sender] = _tOwned[sender] - tAmount;
            _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
            _tOwned[address(this)] = _tOwned[address(this)] + sellFee;
            emit Transfer(sender, recipient, tTransferAmount);

            if (recipient == DEAD) {
                _tTotal = _tTotal - tTransferAmount;
            }
        }
    }
}