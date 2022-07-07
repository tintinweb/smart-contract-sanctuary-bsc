/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
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

library EnumerableSet {
   
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

    
            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }


    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

   
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }

    
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }


    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

   
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

   
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

contract TokenReceiver{
    constructor (address token) public{
        IERC20(token).approve(msg.sender,10 ** 12 * 10**18);
    }
}


contract TOPToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    uint8 private _decimals = 18;
    uint256 private _tTotal = 1880000 * 10 ** 18;

    string private _name = "OSK-TOP";
    string private _symbol = "OSK-TOP";
    
    uint256 public _burnFee = 2; //销毁
    uint256 public _fundFee = 28; //基金
    uint256 public _lQFee = 10;  //底池
    uint256 public _nodeFee = 20; //节点

    uint256 public reserveFee = 1; //保留
    uint256 public totalFee = 60;
    uint256 public dayTime = 86400;
    IUniswapV2Router02 public uniswapV2Router;

    mapping(address => bool) public ammPairs;

    mapping (address => address) public recommerMapping;

    mapping (address => uint256) public transferIn;

    mapping (address => uint256) public transferOut;

    bool inSwapAndLiquify;
    bool inSwapLiquify;

    address public uniswapV2Pair;
    address public tokenReceiver;
    address public holder;

    uint public addPriceTokenAmount = 1e6;
    uint public maxTxAmount = 10e18;
    uint public recommeCondition = 1e18;
    uint public lQAmount;
    uint public fundAmount;
    address public fundAddress;
    address public reflow;
    address public nodeAddress;
    address public topAddress;
    address public usdt;
    uint public burnLimit = 1838000e18;

    constructor (
        address _route, 
        address _usdt,
        address _holder, //收款人
        address _fundAddress, //基金收款地址收USDT
        address _reflow, //回流地址
        address _nodeAddress //节点地址
        
        ) public {
        
        holder = _holder;
        usdt = _usdt;
        fundAddress = _fundAddress;
        nodeAddress = _nodeAddress;
        reflow = _reflow;
        _tOwned[holder] = _tTotal;
        
        _isExcludedFromFee[holder] = true;
        _isExcludedFromFee[address(this)] = true;
        topAddress=msg.sender;
        
        uniswapV2Router = IUniswapV2Router02(_route);
         
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), usdt);
        
        ammPairs[uniswapV2Pair] = true;

        recommerMapping[holder] = topAddress;

        recommerMapping[address(this)] = topAddress;

        recommerMapping[uniswapV2Pair] = topAddress;

        _owner = msg.sender;

        tokenReceiver = address(new TokenReceiver(address(usdt)));
        emit Transfer(address(0), _holder, _tTotal);
    }

    
    function setAmmPair(address pair,bool hasPair)external onlyOwner{
        ammPairs[pair] = hasPair;
    }

  
    function setAmount(uint mta,uint alv)external onlyOwner{
        maxTxAmount = mta;
        addPriceTokenAmount = alv;
    }
    
    function setFundAddress(address addr)external onlyOwner{
        fundAddress = addr;
    }
    
    function setNodeAddress(address addr)external onlyOwner{
        nodeAddress = addr;
    }
    
  function setrecommeCondition(uint fee)external onlyOwner{
         recommeCondition = fee;
    }

    function setDayTime(uint fee)external onlyOwner{
         dayTime = fee;
    }

   function setReflowAddress(address addr)external onlyOwner{
         reflow = addr;
    }

    function setReserve(uint256 fee)external onlyOwner{
            reserveFee = fee;
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

    function getRelation(address account) public view returns(address) {
        return recommerMapping[account];
    }
     
    function getTransferIn(address account) public view returns(uint256) {
        return transferIn[account];
    }

      function getTransferOut(address account) public view returns(uint256) {
        return transferOut[account];
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

    function addRelationEx(address recommer,address user) internal {
        if( 
            recommer != user 
            && recommerMapping[user] == address(0x0) 
            && recommerMapping[recommer] != address(0x0) ){
                recommerMapping[user] = recommer;
        }       
    }



    struct Param{
        bool takeFee;
        uint tTransferAmount;
        uint tLQ;
        uint tBurn;
        uint tFund;
        uint nFund;
    }

     function _initParam(uint256 tAmount,Param memory param) private view  {
        param.tLQ = tAmount * _lQFee / 1000;
        param.tBurn = tAmount * _burnFee / 1000;//
        param.tFund = tAmount * _fundFee / 1000; //基金
        param.nFund = tAmount * _nodeFee / 1000;//
        uint tFee = tAmount * totalFee / 1000; //总手续费
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param,address from)private {
        //回流和基金
        if( (param.tLQ+param.tFund) > 0 ){
            _take((param.tLQ+param.tFund), from, address(this));
            lQAmount += param.tLQ;
            fundAmount += param.tFund;
        }


        if( param.tBurn > 0 ){
            _take(param.tBurn, from, address(0));
        }
        //节点
        if( (param.nFund) > 0 ){
             _take(param.nFund,from,nodeAddress);
        }
    }

      function _isLiquidity(address from,address to)internal view returns(bool isAdd,bool isDel){
        address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
        (uint r0,,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));
        if( ammPairs[to] ){
            if( token0 != address(this) && bal0 > r0 ){
                isAdd = bal0 - r0 > addPriceTokenAmount;
            }
        }
        if( ammPairs[from] ){
            if( token0 != address(this) && bal0 < r0 ){
                isDel = r0 - bal0 > 0; 
            }
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        //保留
        if(reserveFee>0){
              uint  reserveFeeAmount =  amount*reserveFee/ 10000;
              amount = amount.sub(reserveFeeAmount);
        }
      
          if( 
            !isContract(to) 
            && recommerMapping[to] == address(0) 
            && amount >= recommeCondition){
                if( ammPairs[from]  ){
                addRelationEx(holder,to);
            }else{
                addRelationEx(from,to);
            }
        } 

        bool isAddLiquidity;
        bool isDelLiquidity;
        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);

        if( 
              from != address(this) 
            && lQAmount >= maxTxAmount
            && lQAmount <= balanceOf(address(this))
            && !isAddLiquidity
            && !inSwapAndLiquify 
            && !ammPairs[from] 
            && IERC20(uniswapV2Pair).totalSupply() > 1000 ){

                inSwapAndLiquify = true;
                uint v = lQAmount;
                lQAmount = 0;
                swapAndLiquify(v);
                inSwapAndLiquify = false;
            }
        
    if( 
              from != address(this) 
            && fundAmount >= maxTxAmount
            && fundAmount <= balanceOf(address(this))
            && !isAddLiquidity
            && !inSwapLiquify 
            && !ammPairs[from] 
            && IERC20(usdt).totalSupply() > 1000 ){

                inSwapLiquify = true;
                uint  fv= fundAmount;
                fundAmount = 0;
                swapTokensForEth(fv,fundAddress); 
                inSwapLiquify = false;
            }

      if(!_isExcludedFromFee[from] && !ammPairs[from]){
           uint256 timeAddr;
           uint256 timediff;
           uint256 day;
          if(transferIn[from]>transferOut[from]){
              timeAddr=transferIn[from];
            }else{
               timeAddr=transferOut[from];
            }
            if(timeAddr>0){
              timediff=block.timestamp-timeAddr;
              day=timediff.div(dayTime);
            }

          if(day>0 && balanceOf(address(0)) < burnLimit){
            uint  dayamount=amount*11/10000;
            amount = amount.sub(dayamount);
            _take(dayamount,from,address(0));
        }
            
        transferIn[to]=block.timestamp;
        transferOut[from]=block.timestamp;

        }


        Param memory param;
        param.tTransferAmount = amount;

        bool takeFee = false;

        if( ammPairs[from] && !_isExcludedFromFee[to] && !isDelLiquidity){
            takeFee = true;
        }

        if( ammPairs[to] && !_isExcludedFromFee[from] && !isAddLiquidity){
            takeFee = true;
        }

        if( takeFee && balanceOf(address(0)) >= burnLimit){
            takeFee = false;
        }

  
        param.takeFee = takeFee;
        if( takeFee ){
            _initParam(amount,param);
        }
  
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

     function swapAndLiquify(uint256 contractTokenBalance) private  {
        
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        swapTokensForEth(half,tokenReceiver); 

        uint256 newBalance = IERC20(usdt).balanceOf(tokenReceiver);

        addLiquidity(otherHalf, newBalance);
    }
 
 
    function swapTokensForEth(uint256 tokenAmount,address receiver) private {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            receiver,
            block.timestamp
        );
    }


    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        IERC20(usdt).transferFrom(tokenReceiver,address(this),ethAmount);

        IERC20(usdt).approve(address(uniswapV2Router), ethAmount);

        uniswapV2Router.addLiquidity(
            address(this),
            usdt,
            tokenAmount,
            ethAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            reflow,
            block.timestamp
        );
    }


    function donateDust(address addr, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }

       function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}