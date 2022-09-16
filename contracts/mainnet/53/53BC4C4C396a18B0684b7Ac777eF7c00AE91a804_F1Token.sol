/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;


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
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
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
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
     function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
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
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
 

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IPool{
    function addPoolAward(uint amount )external;
}


contract F1Token is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    uint8 private _decimals = 18;
    uint256 private _tTotal = 310000 * 10 ** 18;

    string private _name = "F1";
    string private _symbol = "F1";
    
    uint public _buyFee = 30;
    uint public _sellMkFee = 30;
    uint public _sellFdFee = 20;
    uint public _sellBurnFee = 50;
    
    IUniswapV2Router02 public uniswapV2Router;
    IPool public pool;
    mapping(address => bool) public ammPairs;

    bool inSwapAndLiquify;
    address public uniswapV2Pair;
    address public wbnb;   
    address  holder;
    address public mkAddress;
    address public fdAddress;
    address public poolAddress;

    uint public addPriceTokenAmount = 1e14;
    uint public maxRate = 490;

    mapping(uint => uint) public todayBasePrices;


    constructor (
        address _route,
        address _holder) public {
        
        holder = _holder;
        _tOwned[holder] = _tTotal;
        _isExcludedFromFee[_holder] = true;
        _isExcludedFromFee[address(this)] = true;

        uniswapV2Router = IUniswapV2Router02(_route);

        wbnb = uniswapV2Router.WETH();
         
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), wbnb);
        
        ammPairs[uniswapV2Pair] = true;

        _owner = msg.sender;
        emit Transfer(address(0), _holder, _tTotal);
    }

    function setBurnFee(uint _fee)external onlyOwner{
        _sellBurnFee = _fee;
    }

    function getCurrentPrice() internal view returns(uint){
        (uint r0,uint r1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();

        if( r0 > 0 && r1 > 0){
            if( address(this) == IUniswapV2Pair(uniswapV2Pair).token0()){
                return r1 * 10 ** 18 / r0;
            }else{
                return r0 * 10 ** 18 / r1;
            }
        }
        return 0;
    }

    function _deliveryCurrentProce()internal{
        uint price = getCurrentPrice();

        uint zero = block.timestamp / 1 days * 1 days;
        todayBasePrices[zero] = price;

        if( todayBasePrices[zero - 1 days] == 0){
            todayBasePrices[zero - 1 days] = price;
        }
    }

    function getSellFeeRate(uint zero,uint price)internal view returns(uint){
        uint base = todayBasePrices[zero];

        if( price >= base ) return 0;

        uint rate = (base - price) * 100 / base;

        if( rate > 10){
            uint r =  (rate - 10) * 50;

            r = r > maxRate ? maxRate : r;
            return r;
        }
        return 0;
    }

    function setmaxRate(uint _maxRate)external onlyOwner{
        maxRate = _maxRate;
    }

    function setAddress(address _mkAddress,address _fdAddress,address _poolAddress)external onlyOwner{
        mkAddress = _mkAddress;
        fdAddress = _fdAddress;
        poolAddress = _poolAddress;
    }

    function setpool(address _pool)external onlyOwner{
        pool = IPool(_pool);
    }

    function setaddPriceTokenAmount(uint _addPriceTokenAmount)external onlyOwner{
        addPriceTokenAmount = _addPriceTokenAmount;
    }

    function setAmmPair(address pair,bool hasPair)external onlyOwner{
        ammPairs[pair] = hasPair;
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
        return _tOwned[account];
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
    
    function excludeFromFee(address[] memory accounts) public onlyOwner {
        for( uint i = 0; i < accounts.length; i++ ){
            _isExcludedFromFee[accounts[i]] = true;
        }
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

     function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    receive() external payable {}

    function _take(uint256 tValue,address from,address to) private {
        _tOwned[to] = _tOwned[to].add(tValue);
        emit Transfer(from, to, tValue);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    struct Param{
        bool takeFee;
        bool isSwapBuy;
        uint fee;
        uint tTransferAmount;
        uint tChef;
        uint tMk;
        uint tFd;
        uint tBrun;
        uint tDp;
    }

     function _initParam(uint256 tAmount,Param memory param) private view  {
        uint tFee = 0;
        if( param.takeFee ){

            if( param.fee > 0){
                param.tDp = tAmount * param.fee / 1000;
            }

            if( param.isSwapBuy){
                param.tChef = tAmount * _buyFee / 1000;
                tFee = param.tChef + param.tDp;
            }else{
                param.tMk = tAmount * _sellMkFee / 1000;
                param.tFd = tAmount * _sellFdFee / 1000;
                param.tBrun = tAmount * _sellBurnFee / 1000;
                tFee = param.tMk + param.tFd + param.tBrun + param.tDp;
            }
        }
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param,address from)private {
        if( param.tChef > 0 ){
            if( address(pool) != address(0)){
                pool.addPoolAward(param.tChef);
                _take(param.tChef, from, poolAddress);
            }else{
                _take(param.tChef, from, mkAddress);
            }
        }
        if( param.tMk > 0){
            _take(param.tMk, from, mkAddress);
        }
        if( param.tFd > 0){
            _take(param.tFd, from, fdAddress);
        }
        if( param.tBrun > 0){
            _take(param.tBrun, from, address(0));
        }
        if( param.tDp > 0){
            _take(param.tDp, from, address(0));
        }
    }


    function _doTransfer(address sender, address recipient, uint256 tAmount) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
         emit Transfer(sender, recipient, tAmount);
    }

    function _isLiquidity(address from,address to)internal view returns(bool isAdd,bool isDel){

        if( ammPairs[to] ){
           isAdd = address(uniswapV2Router).balance > addPriceTokenAmount;
        }

        isDel = ((from == address(uniswapV2Pair) && to == address(uniswapV2Router)) );
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
           
        if( IERC20(uniswapV2Pair).totalSupply() > 1000){
            _deliveryCurrentProce();
        }
        bool isAddLiquidity;
        bool isDelLiquidity;
        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);
        
        Param memory param;
       
        bool takeFee = false;

        if( ammPairs[to] && !_isExcludedFromFee[from] && !isAddLiquidity ){
            takeFee = true;
        }

        if( ammPairs[from] && !_isExcludedFromFee[to] && !isDelLiquidity ){
            takeFee = true;
            param.isSwapBuy = true;
        }

        param.takeFee = takeFee;

        if( takeFee ){
            uint zero = block.timestamp / 1 days * 1 days;
            uint price = getCurrentPrice();
            if( !param.isSwapBuy){
                param.fee = getSellFeeRate(zero - 1 days, price);
            }
        }

        _initParam(amount,param);
        _tokenTransfer(from,to,amount,param);
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount,Param memory param) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
         emit Transfer(sender, recipient, param.tTransferAmount);
        if(param.takeFee){
            _takeFee(param,sender);
        }
    }

     function donateDust(address addr, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }
}