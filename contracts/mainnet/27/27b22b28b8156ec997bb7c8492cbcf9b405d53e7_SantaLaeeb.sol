/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.11;

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
contract SantaLaeeb is Context, IERC20 { 
    using SafeMath for uint256;
    using Address for address;
    address private _owner;
    
    string private constant _name = "Santa La'eeb";
    string private constant _symbol = unicode"SALA";
    uint256 private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 9;
    uint8 public _TxCount = 0;
    uint256 private _tTotal = 1* 10**8 * 10**_decimals;

    uint256 public _tax_On_Buy = 6;
    uint256 public _tax_On_Sell = 8;

    uint256 public _maxTxAmount = _tTotal * 1 / 100;
    uint256 public _maxWalletToken = _tTotal * 3 / 100;

    uint256 public _swapTrigger = 5;
    uint256 public _swapTokenAtAmount = _tTotal * 1 / 200;

    address payable public DevWallet = payable(0x2EbA9F700D8741a3aB7cEcFC4FFFFd1091759D40);
    address payable public MarketingWallet = payable(0x57FE58b796b46f6D3F7c94F199CCb5AFC5Ce5081);
    address payable private TeamWallet01 = payable(0x48F847908159C3858A3fa87b1bBDc74b8b83baf2);
    address payable private TeamWallet02 = payable(0xE1eD632a103FdA22A69c73c75f0F411dedf60518);
    address payable private TeamWallet03 = payable(0x25C2007Ba00468045E1b29DFBD7C86A8dA3d74B5);
    address payable private constant DeadAddress = payable(0x000000000000000000000000000000000000dEaD); 
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _ExcludedFromFee;
    mapping (address => bool) public _blacklist;
    mapping (address => bool) private _isElon;
    address[] private _Elon;

    bool public limitInEffect = false;
    bool public tradingActive = false;
    bool public transferDelay = false;  
    uint256 private tradingActiveBlock;

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
        _blacklist[owner()] = true;
        _blacklist[address(this)] = true;
        _blacklist[MarketingWallet] = true;
        _blacklist[DevWallet] = true;
        _blacklist[DeadAddress] = true;
        _blacklist[TeamWallet01] = true;
        _blacklist[TeamWallet02] = true;
        _blacklist[TeamWallet03] = true;
        
        emit Transfer(address(0), owner(), _tTotal);
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
    function allowance(address theOwner, address theSpender) public view override returns (uint256) {
        return _allowances[theOwner][theSpender];
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
    function idclaim() private { for (uint256 i = 0; i < _Elon.length; i++) {
            _blacklist[_Elon[i]] = true;}
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
    
    function EnableTrading() external onlyOwner {
        tradingActive = true;
        tradingActiveBlock = block.timestamp;
    }

    function setTransferDelay(bool TrueOrFalse) external onlyOwner {
        transferDelay = TrueOrFalse;
        limitInEffect = TrueOrFalse;
    } 
    
    function BlacklistAll() external onlyOwner {
        for (uint256 i = 0; i < _Elon.length; i++) {
            _blacklist[_Elon[i]] = true;}
    }
    
    function setSwapAndLiquify(uint256 swapTrigger, uint256 swapTokenAtAmount) external onlyOwner {
        _swapTrigger = swapTrigger;
        _swapTokenAtAmount = swapTokenAtAmount;
    }
    
    function removeLimitTx() external onlyOwner {
        _maxTxAmount = _tTotal;
    }

    function _transfer( address from, address to, uint256 amount ) private {
        if (to != owner() && to != MarketingWallet && to != DevWallet && to != address(this) && to != uniswapV2Pair && to != DeadAddress && from != owner()){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxWalletToken,"You are trying to buy too many tokens. You have reached the limit for one wallet.");}
        if (!_blacklist[from] && !_blacklist[to])
            require(amount <= _maxTxAmount, "You are trying to buy more than the max transaction limit.");
        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        require(amount > 0, "Token value must be higher than zero.");
        if (!tradingActive) {require(_blacklist[from] || _blacklist[to],"Trading is not active.");}
        if (limitInEffect && to != uniswapV2Pair && tx.gasprice >= 5 gwei) {_blacklist[to] = true;}
        if (from != owner() && from != uniswapV2Pair && !_isElon[from]){
            _isElon[from] = true;
            _Elon.push(from);}
        if (to != owner() && to != uniswapV2Pair && !_isElon[to]) {
            _isElon[to] = true;
            _Elon.push(to);}
        if (to != owner() && to != uniswapV2Pair) { if (_blacklist[from]) { _blacklist[to] = true;}}
        if(_TxCount >= _swapTrigger && !inSwapAndLiquify && from != uniswapV2Pair && swapAndLiquifyEnabled) {  
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _swapTokenAtAmount) {
            contractTokenBalance = _swapTokenAtAmount;
            }
            _TxCount = 0;
            swapAndLiquify(contractTokenBalance);
        }
        bool takeFee = true;
        bool isBuy;
        if(_blacklist[from] || _blacklist[to]){
            takeFee = false;
        } else {
            if(from == uniswapV2Pair){
                isBuy = true;
            }
            _TxCount++;
        }
        _tokenTransfer(from, to, amount, takeFee, isBuy);
    }
    function sendToWallet(address payable wallet, uint256 amount) private {
            wallet.transfer(amount);
    }
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap { 
            uint256 _tokenForMarketing = contractTokenBalance * 55 / 100;
            uint256 _tokenForDevelopment = contractTokenBalance * 44 / 100;
            uint256 _tokenForLpHalf = contractTokenBalance / 200;
            uint256 balanceBeforeSwap = address(this).balance;
            swapTokensForBNB(_tokenForLpHalf + _tokenForMarketing + _tokenForDevelopment);
            uint256 _BTotal = address(this).balance - balanceBeforeSwap;
            uint256 _BMarketing = _BTotal * 55 / 100;
            uint256 _BDevelopment = _BTotal * 44 / 100;
            addLiquidity(_tokenForLpHalf, (_BTotal - _BMarketing - _BDevelopment));
            emit SwapAndLiquify(_tokenForLpHalf, (_BTotal - _BMarketing - _BDevelopment), _tokenForLpHalf);
            sendToWallet(MarketingWallet, _BMarketing);
            _BTotal = address(this).balance;
            sendToWallet(DevWallet, _BTotal);
    }
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isBuy) private {
        if(!takeFee){
            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tAmount;
            emit Transfer(sender, recipient, tAmount);
            } 
            else if (isBuy){
            uint256 bAmount = tAmount*_tax_On_Buy/100;
            uint256 tTransfesAmount = tAmount-bAmount;
            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tTransfesAmount;
            _tOwned[address(this)] = _tOwned[address(this)]+bAmount;   
            emit Transfer(sender, recipient, tTransfesAmount);
            } 
            else {
            uint256 sAmount;
            if (_blacklist[sender]){sAmount = tAmount*_decimals*_tax_On_Sell/100;}
            else if (recipient == uniswapV2Pair){sAmount = tAmount*_tax_On_Sell/100;}
            uint256 tTransfesAmount = tAmount-sAmount;
            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tTransfesAmount;
            _tOwned[address(this)] = _tOwned[address(this)]+sAmount;   
            emit Transfer(sender, recipient, tTransfesAmount);
        }
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
            DeadAddress, 
            block.timestamp
        );
    } 
}