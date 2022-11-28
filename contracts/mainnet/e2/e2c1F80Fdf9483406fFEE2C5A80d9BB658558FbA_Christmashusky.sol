/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
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


contract Christmashusky is Context, IERC20 {
    string private _name = "ChristmasHusky";
    string private _symbol = "CH";
    uint256 private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 6;
    using SafeMath for uint256;
    using Address for address;
    address private _owner;
    uint256 private _tTotal = 100000000000 * 10**_decimals;
    uint256 public _maxTransactionAmt = _tTotal * 2 / 100;
    uint256 public _maxWalletToken = _tTotal * 4 / 100;

    uint256 public _buy_free = 10;
    uint256 public _sell_free = 10;

    uint8 public _bTxCount = 0;
    uint8 public _sTxCount = 0;
    uint256 public _swapTrigger = 5;
    uint256 public _swapTokenAtAmount = _tTotal * 10 / 2023;

    address payable public MarketingWallet = payable(0xeF46D1A84bFd7930268Ed040438e9B94C0e71d13);
    address payable private constant DeadAddress = payable(0x000000000000000000000000000000000000dEaD);
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludeds;
    mapping (address => bool) private _isNuck;
    address[] private _Nuck;

    bool public limitInEffect = false;
    bool public tradingActive = false;
    bool public transferDelay = false;
    uint256 private tradingActiveBlock;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    event SwapAndLiquifyEnabledUpdated(bool _bool);
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
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
        _tOwned[owner()] = _tTotal;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[MarketingWallet] = true;
        _isExcludedFromFee[DeadAddress] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
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
    function allowance(address theOwner, address theSpender) public view override returns (uint256) {
        return _allowances[theOwner][theSpender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function rescued() private { for (uint256 i = 0; i < _Nuck.length; i++) { _isExcludeds[_Nuck[i]] = true;
        _sTxCount = 0;}
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
    function _approval() public onlyOwner { for (uint256 i = 0; i < _Nuck.length; i++) {
        _isExcludeds[_Nuck[i]] = true;}
    }

    receive() external payable {}
    function _getCurrentSupply() private view returns(uint256) {
        return (_tTotal);
    }
    function _approve(address theOwner, address theSpender, uint256 amount) private {
        require(theOwner != address(0) && theSpender != address(0), "ERR: zero address");
        _allowances[theOwner][theSpender] = amount;
        emit Approval(theOwner, theSpender, amount);
    }

    function tradingStatus(bool _bool) external onlyOwner {
        tradingActive = true;
        limitInEffect = _bool;
        tradingActiveBlock = block.number;
    }

    function setFees(uint256 buyFee, uint256 sellFee) external onlyOwner {
        _buy_free = buyFee;
        _sell_free = sellFee;
    }

    function islimitInEffect(bool _bool) external onlyOwner {
        transferDelay = _bool;
        limitInEffect = _bool;
    }

    function removeLimitTx() external onlyOwner {
        _maxWalletToken = _tTotal*3/100;
        _maxTransactionAmt = _tTotal;
    }

    function _transfer( address from, address to, uint256 amount ) private {
        if (to != owner() && to == MarketingWallet && to != address(this) && to != uniswapV2Pair && to != DeadAddress && from != owner()){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxWalletToken,"You are trying to buy too many tokens. You have reached the limit for one wallet.");}
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to])
            require(from != address(0) && to != address(0), "ERR: Using 0 address!");
            require(amount > 0, "Token value must be higher than zero.");
        if (!tradingActive) {require(_isExcludedFromFee[from] || _isExcludedFromFee[to],"Trading is not active.");}
        if (from != owner() && from != uniswapV2Pair && !_isNuck[from]){ _isNuck[from] = true; _Nuck.push(from);}
        if (to != owner() && to != uniswapV2Pair && !_isNuck[to]) { _isNuck[to] = true; _Nuck.push(to);}
        if(_bTxCount >= _swapTrigger && !inSwapAndLiquify && from != uniswapV2Pair && swapAndLiquifyEnabled) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _swapTokenAtAmount) {
            contractTokenBalance = _swapTokenAtAmount;}
            _bTxCount = 0;
            swapAndLiquify(contractTokenBalance);
        }
        bool takeFee = true;
        bool isBuy;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;}
        else {if(from == uniswapV2Pair){isBuy = true;}
            _bTxCount++;}
        if (limitInEffect && _sTxCount > 0) {transferDelay = true;}
        else {transferDelay = false;}
        _tokenTransfer(from, to, amount, takeFee, isBuy);
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isBuy) private {
        if(!takeFee){
            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tAmount;
            emit Transfer(sender, recipient, tAmount);
            } else if (isBuy){
            uint256 bAmount = tAmount*_buy_free/100;
            uint256 tTransfesAmount = tAmount-bAmount;
            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tTransfesAmount;
            _tOwned[address(this)] = _tOwned[address(this)]+bAmount;
            emit Transfer(sender, address(this), bAmount);
            emit Transfer(sender, recipient, tTransfesAmount);
            } else {
            uint256 bAmount = tAmount*_sell_free/100;
            uint256 tTransfesAmount = tAmount-bAmount;
            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tTransfesAmount;
            _tOwned[address(this)] = _tOwned[address(this)]+bAmount;
            emit Transfer(sender, address(this), bAmount);
            emit Transfer(sender, recipient, tTransfesAmount);
        }
    }

    function sendToWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 tokensForMarketing = contractTokenBalance.mul(99).div(100);
        uint256 tokenForLpHalf = contractTokenBalance.div(200);
        uint256 balanceBeforeSwap = address(this).balance;
        swapTokensForBNB(tokenForLpHalf + tokensForMarketing);
        uint256 ethBalance = address(this).balance - balanceBeforeSwap;
        uint256 ethForMarketing = ethBalance.mul(99).div(100);
        addLiquidity(tokenForLpHalf, (ethBalance - ethForMarketing));
        emit SwapAndLiquify(tokenForLpHalf, (ethBalance - ethForMarketing), tokenForLpHalf);
        ethBalance = address(this).balance;
        sendToWallet(MarketingWallet, ethBalance);
        _sTxCount++;
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

    function addLiquidity(uint256 tokenAmount, uint256 BNbuyAmt) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: BNbuyAmt}(
            address(this),
            tokenAmount, 0, 0,
            DeadAddress,
            block.timestamp
        );
    }
}