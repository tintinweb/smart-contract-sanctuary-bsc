// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


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

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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
        return payable(msg.sender);
    }
 
    function _msgData() internal view virtual returns (bytes memory) {
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
 
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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


contract KK is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    using Address for address;
 
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 10000000000 * 10**18;
 
    string private _name = "tKK Coin";
    string private _symbol = "tKK";
    
    uint256 private _commonDiv = 100; //Fee DIV

    uint256 private _burnFee = 2;// 2% burn
    uint256 private _nodeFee = 1; // 1%
    uint256 private _communityFee = 1;// 1%
    uint256 private _lpFee = 2; //2%

    uint256 public totalFee = 6;//6%

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
 
    mapping(address => bool) public ammPairs;
    
    bool public swapAndLiquidityEnabled;
    bool inSwapAndLiquify;

    uint256 public _maxTxAmount = 10 * 10**18; // test
    // uint256 public _maxTxAmount = 100000 * 10**18; // prod

    // address private _router = address(0xc5017BE80b4446988e8686168396289a9A62668E); //sushi router
    // address private _router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E); //prod
    address private _router = address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //bsc test

    // address public usdtAddress = address(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);// polygon usdt
    // address public usdtAddress = address(0x55d398326f99059fF775485246999027B3197955); // prod
    address public usdtAddress = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684); // bsc test
    // address public wbnbAddress = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd); //bnb test

    address public nodeFeeAddress = address(0x130C1D3785e03738579FF3dF51438792F97606bE);
    address public communityAddress = address(0xA8FbF094fb1CE3aD9bADbe3A76abEC0F2fcEff9f);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor (){
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Router = _uniswapV2Router;

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), usdtAddress);
        uniswapV2Pair = _uniswapV2Pair;

        address _uniswapV2Pair_BNB = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        ammPairs[uniswapV2Pair] = true;
        ammPairs[_uniswapV2Pair_BNB] = true;

        _isExcludedFromFee[address(this)] = true;
        swapAndLiquidityEnabled = true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
        
    receive() external payable {}

    function excludeFromFees(address[] memory accounts) public onlyOwner{
        uint len = accounts.length;
        for( uint i = 0; i < len; i++ ){
            _isExcludedFromFee[accounts[i]] = true;
        }
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setAmmPair(address pair,bool hasPair)external onlyOwner{
        require(pair != address(0), "Amm pair must be a address");
        ammPairs[pair] = hasPair;
    }

    function setNodeFeeAddress(address account) public onlyOwner{
        require(account != nodeFeeAddress, "Node fee must be a new address");
        nodeFeeAddress = account;
    }

    function setCommunityAddress(address account) public onlyOwner{
        require(account != communityAddress, "Community fee address must be a new address");
        communityAddress = account;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        require(_isExcludedFromFee[msg.sender], "Not allowed");
        return _isExcludedFromFee[account];
    }

    event SwapAndLiquidityEnabledUpdated(bool _enabled);
    function setSwapAndLiquidityEnabled(bool _enabled) public onlyOwner {
        swapAndLiquidityEnabled = _enabled;
        emit SwapAndLiquidityEnabledUpdated(_enabled);
    }


    function getUSDTBalance() public view returns(uint256) {
        uint256 ubalance = IERC20(usdtAddress).balanceOf(address(this));
        return ubalance;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
 
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function getOwner() public view returns(address){
        return owner();
    }
 
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
 
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
 
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
 
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    struct Param{
        bool takeFee;
        uint256 tTransferAmount;
        uint256 tBurnFee;
        uint256 tNodeFee;
        uint256 tCommunityFee;
        uint256 tLpFee;
    }

    function _transfer(address from,address to,uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 contractTokenBalance = balanceOf(address(this));
        if( contractTokenBalance >= _maxTxAmount 
            && !inSwapAndLiquify && swapAndLiquidityEnabled){
            contractTokenBalance = _maxTxAmount;
            swapAndLiquidity(contractTokenBalance);
        }

        bool takeFee = true;
        if( _isExcludedFromFee[from] || _isExcludedFromFee[to] 
            || from ==  address(uniswapV2Router) ){
            takeFee = false;
        }

        Param memory param;
        if( takeFee ){
            if(!ammPairs[from] && !ammPairs[to]){
                param.takeFee = false;
                param.tTransferAmount = amount;
            } else {
                param.takeFee = true;
                _getSwapParam(amount,param);   //swap or addLiquidity
            }
        } else {
            param.takeFee = false;
            param.tTransferAmount = amount;
        }
        _tokenTransfer(from, to, amount, param);
    }

    function _getSwapParam(uint256 tAmount,Param memory param) private view  {
        param.tBurnFee = tAmount.mul(_burnFee).div(_commonDiv);
        param.tNodeFee = tAmount.mul(_nodeFee).div(_commonDiv);
        param.tCommunityFee = tAmount.mul(_communityFee).div(_commonDiv);
        param.tLpFee = tAmount.mul(_lpFee).div(_commonDiv);

        uint256 tFee = tAmount.mul(totalFee).div(_commonDiv);
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _take(uint256 tValue,address from,address to) private {
        _balances[to] = _balances[to].add(tValue);
        emit Transfer(from, to, tValue);
    }

    function _takeFee(Param memory param, address from) private {
        if( param.tBurnFee > 0 ){
            _take(param.tBurnFee, from, address(0));
        }
        if( param.tNodeFee > 0 ){
            _take(param.tNodeFee, from, nodeFeeAddress);
        }
        if( param.tCommunityFee > 0 ){
            _take(param.tCommunityFee, from, communityAddress);
        }
        if( param.tLpFee > 0 ){
            _take(param.tLpFee, from, address(this));
        }
    }

    event _param(address indexed sender,uint256 tBurnFee,
    uint256 tNodeFee,uint256 tCommunityFee,uint256 tLpFee,uint256 tTransferAmount,string a);
 
    function _tokenTransfer(address sender, address recipient, uint256 tAmount,Param memory param) private {
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(param.tTransferAmount);
         emit Transfer(sender, recipient, param.tTransferAmount);

        if( param.takeFee ){
            emit _param(sender,
            param.tBurnFee,
            param.tNodeFee,
            param.tCommunityFee,
            param.tLpFee,
            param.tTransferAmount,"takeFee true");

            _takeFee(param,sender);
        }
    }

    function swapAndLiquidity(uint256 contractTokenBalance) private lockTheSwap{
        uint256 half = contractTokenBalance.div(2);
        // uint256 otherHalf = contractTokenBalance.sub(half); //.sub(half.mul(totalFee).div(_commonDiv))
        
        // uint256 initialUsdtBalance = IERC20(usdtAddress).balanceOf(address(this));//address(this).balance;
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half, address(this));
        uint256 newBalance_bnb = address(this).balance.sub(initialBalance);

        swapEthForToken(newBalance_bnb, address(this));// to usdt
        //swapTokensForUSDT();
        // swapTokensForUSDT(half,address(this)); 
        // uint256 newUsdtBalance = IERC20(usdtAddress).balanceOf(address(this));
        // uint256 newBalance = newUsdtBalance.sub(initialUsdtBalance);
    }

    function swapTokensForEth(uint256 tokenAmount,address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            to,
            block.timestamp
        );
    }

    function swapEthForToken(uint256 ethAmount,address to) private {
        address[] memory path = new address[](2);
        path[1] = usdtAddress;
        path[0] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactETHForTokens{value:ethAmount}(
            0, // accept any amount of token
            path,
            to,
            block.timestamp + 300
        );
    }

    function swapTokensForUSDT(uint256 tokenAmount,address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtAddress;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            to,
            block.timestamp + 300);
    }

    function addLiquidityByOwner() public onlyOwner{
        uint256 contractTokenBalance = balanceOf(address(this));
        require(_maxTxAmount <= contractTokenBalance, "Insufficient Balance");
        uint256 kkBalance = _maxTxAmount;
        uint256 newUsdtBalance = IERC20(usdtAddress).balanceOf(address(this));
        addLiquidity(kkBalance, newUsdtBalance);
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        // _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(address(this)).approve(address(uniswapV2Router), tokenAmount);
        IERC20(usdtAddress).approve(address(uniswapV2Router), usdtAmount);
        // TransferHelper.safeApprove(usdtAddress, address(uniswapV2Router), usdtAmount);
        uniswapV2Router.addLiquidity(
            address(this),
	        usdtAddress,
            tokenAmount,
	        usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp + 300
        );
    }

}