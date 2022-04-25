/**
 *Submitted for verification at BscScan.com on 2022-04-25
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

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
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

contract BKingToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    EnumerableSet.AddressSet isExcludedAddress;

    uint8 private _decimals = 9;
    uint256 private _tTotal = 200000000000 * 10 ** 9;

    string private _name = "Beast king";
    string private _symbol = "BKing";
    
    struct Fee{
        uint256  burnFee;
        uint256  lQFee;
        uint256  lPFee;
        uint256  mkFee1;
        uint256  mkFee2;
        uint256  mkFee3;
        uint256  luckyFee;
        uint256  txFee;
        uint256  totalFee;
        uint256  sedimentRate;
    }

    Fee public fee = Fee(30,40,40,10,10,10,3,7,150,50);

    address public mkAddress1;
    address public mkAddress2;
    address public mkAddress3;
    address public mkAddress4;
    address public mkAddress5;
    address public constant burnAddress = address(0xdead);

    uint public swapLimitRate = 90;
    uint public swapLimitAmount = 35000000e9;

    IUniswapV2Router02 public uniswapV2Router;

    mapping(address => bool) public ammPairs;

    bool inSwapAndLiquify;
    uint public burnLimit = 199900000000e9;
    
    address public uniswapV2Pair;
    address public wbnb;    
    address public usdt;
    address public holder;
    uint256 public lQAmount;
    uint256 public lPAmount;
    uint256 public lkAmount;

    uint public maxTxAmount = 1000e9;
    uint public addLiquidityValue = 1e6;

    uint256 public lastLuckyTime;
    uint256[] internal txFeeConfig = [2,1,1,1,1,1,1];
    uint256[] internal luckyFeeConfig = [1,1,1];
    uint256 public luckyIntervalTime = 86400;

    address[] lastTxArr;
    address[] lastLuckyArr;

    struct Interest{
        uint256 index;
        uint256 period;
        uint256 lastSendTime;
        uint minAward;
        uint award;
        uint sendCount;
        IERC20  token;
        EnumerableSet.AddressSet tokenHolder;
    }
    address  fromAddress;
    address  toAddress;
    Interest internal lpInterest;

    constructor (
        address _route,
        address _usdt,
        address _mk1,
        address _mk2,
        address _mk3,
        address _mk4,
        address _mk5,
        address _holder) public {
        
         holder = _holder;
         usdt = _usdt;
         mkAddress1 = _mk1;
         mkAddress2 = _mk2;
         mkAddress3 = _mk3;
         mkAddress4 = _mk4;
         mkAddress5 = _mk5;
       
        _tOwned[holder] = _tTotal;
        isExcludedAddress.add(holder);
        isExcludedAddress.add(address(this));

        uniswapV2Router = IUniswapV2Router02(_route);
        wbnb = uniswapV2Router.WETH();
        
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), wbnb);
        ammPairs[uniswapV2Pair] = true;
        lpInterest.token = IERC20(uniswapV2Pair);

        _owner = msg.sender;
        lpInterest.lastSendTime = block.timestamp;
        lpInterest.minAward = 1e3;
        lpInterest.period = 86400;
        lpInterest.sendCount = 30;
        emit Transfer(address(0), _holder, _tTotal);
    }

     struct InterestInfo{
        uint period;
        uint lastSendTime;
        uint award;
        uint count;
        uint sendCount;
    }
    function getInterestInfo()external view returns(InterestInfo memory lpI){
        lpI.period = lpInterest.period;
        lpI.lastSendTime = lpInterest.lastSendTime;
        lpI.award = lpInterest.award;
        lpI.sendCount = lpInterest.sendCount;
        lpI.count = lpInterest.tokenHolder.length();
    }

    function setInterset(uint ma,uint pd,uint sc)external onlyOwner{
        lpInterest.minAward = ma;
        lpInterest.period = pd;
        lpInterest.sendCount = sc;
    }

    function setAmmPair(address pair,bool hasPair)external onlyOwner{
        ammPairs[pair] = hasPair;
    }

    function setMaxTx(uint256 maxTx,uint lit) external onlyOwner{
        maxTxAmount = maxTx;
        luckyIntervalTime = lit;
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

    function getWhiteList(uint start,uint end)external view returns(address[] memory addrs,uint count){

        count = isExcludedAddress.length();

        if( end >= count ){
            end = count - 1;

            if( end >= start){
                uint size = end - start + 1;

                addrs = new address[](size);

                for( (uint i,uint k) = (start,0) ; i <= end && k < size; (i ++,k ++)){
                    addrs[k] = isExcludedAddress.at(i);
                }
            }
        }
    }
    
    function excludeFromFee(address account) public onlyOwner {
        isExcludedAddress.add(account);
    }
    
    function includeInFee(address account) public onlyOwner {
       isExcludedAddress.remove(account);
    }

     function isExcludedFromFee(address account) public view returns(bool) {
        return isExcludedAddress.contains(account);
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
        bool isBuy;
        uint tTransferAmount;
        uint tLQ;
        uint tLP;
        uint tBurn;
        uint tMk1;
        uint tMk2;
        uint tMk3;
        uint tLk;
        uint tTx;
    }

     function _initParam(uint256 tAmount,Param memory param) private view  {

        uint tFee = 0;
        if( param.takeFee){
            param.tLQ = tAmount * fee.lQFee / 1000;
            param.tLP = tAmount * fee.lPFee / 1000;
            param.tBurn = tAmount * fee.burnFee / 1000;
            param.tMk1 = tAmount * fee.mkFee1 / 1000;
            param.tMk2 = tAmount * fee.mkFee2 / 1000;
            param.tMk3 = tAmount * fee.mkFee3 / 1000;
            param.tLk = tAmount * fee.luckyFee / 1000;
            param.tTx = tAmount * fee.txFee / 1000;
            tFee = tAmount * fee.totalFee / 1000;
        }
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param,address from)private {
        if( param.tLQ > 0 ){
            _take(param.tLQ, from, address(this));
            lQAmount += param.tLQ;
        }
        if( param.tLP > 0 ){
            _take(param.tLP, from, address(this));
            lPAmount += param.tLP;
        }
        if( param.tBurn > 0 ){
            _take(param.tBurn, from, address(0xdead));
        }
        if( param.tMk1 > 0 ){
            _take(param.tMk1, from, mkAddress1);
        }
        if( param.tMk2 > 0 ){
            _take(param.tMk2, from, mkAddress2);
        }
        if( param.tMk3 > 0 ){
            _take(param.tMk3, from, mkAddress3);
        }

         if( param.tTx > 0 ){
            _takeLastTx(param.tTx, from);
        }
        if( param.tLk > 0 ){
            lkAmount += param.tLk;
            _take(param.tLk, from, address(this));
            if( lastLuckyTime + luckyIntervalTime <= block.timestamp ){
                lastLuckyTime = block.timestamp;
                _takeLucky();
            }   
        }
    }

     function _takeLastTx(uint amount,address from)internal{

        uint len = lastTxArr.length;
        uint sended = 0;

        uint total = fee.txFee;
        uint kLeng = txFeeConfig.length;
        for( (uint i,uint k) = ( len ,0); i > 0 && k < kLeng; (i--,k++) ){
            address a = lastTxArr[i - 1];
            uint v = txFeeConfig[k] * amount / total;
            sended += v;
            _take(v, from, a);
        }

        if( amount > sended ){
            _take(amount - sended, from,burnAddress );
        }
    }

    function _takeLucky()internal{

        uint len = lastLuckyArr.length;
        uint amount = lkAmount;

        uint total = fee.luckyFee;
        uint kLeng = luckyFeeConfig.length;
        for( (uint i,uint k) = ( len ,0); i > 0 && k < kLeng; (i--,k++) ){
            address a = lastLuckyArr[i - 1];
            uint v = luckyFeeConfig[k] * amount / total;
            if( v > balanceOf(address(this)) || lkAmount < v ) return;
            lkAmount = lkAmount.sub(v);
            _take(v, address(this), a);
        }
    }

    function _isLiquidity(address from,address to)internal view returns(bool isAdd,bool isDel){

        if( ammPairs[to] ){
           isAdd = address(uniswapV2Router).balance > addLiquidityValue;
        }

        isDel = ((from == uniswapV2Pair && to == address(uniswapV2Router)) );
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool isAddLiquidity;
        bool isDelLiquidity;
        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);

        uint bal = balanceOf(address(this));
        if( 
            bal >= maxTxAmount
            && !inSwapAndLiquify
            && !isAddLiquidity
            && from != address(uniswapV2Router)
            && !ammPairs[from] 
            && IERC20(uniswapV2Pair).totalSupply() > 1000 ){

            inSwapAndLiquify = true;

            if( lQAmount >= maxTxAmount && lQAmount <= balanceOf(address(this))){
                uint v = lQAmount;
                lQAmount = 0;
                swapAndLiquify(v);
            }

            if( lPAmount >= maxTxAmount && lPAmount <= balanceOf(address(this))){
                uint v = lPAmount;
                lPAmount = 0;
                swapTokensForToken(v);
            }
           inSwapAndLiquify = false;
        }
       
        bool takeFee = false;
       
        if( ammPairs[from] ){
            lastTxArr.push(to);
            if( !isExcludedAddress.contains(to) ){
                takeFee = true;
                if(!isDelLiquidity){
                    require(amount <= swapLimitAmount,"exceed swap limit");
                }
            }
        }

        if( ammPairs[to]   ){
            lastTxArr.push(from);
            if( !isExcludedAddress.contains(from) ){
                takeFee = true;
                if( !isAddLiquidity ){
                    require(amount <= swapLimitAmount,"exceed swap limit");
                }
                require(amount <= balanceOf(from) * swapLimitRate / 100,"exceed sell rate");
            }
           if( isAddLiquidity ){
                lastLuckyTime = block.timestamp;
                lastLuckyArr.push(from);
           }
        }

        if( fee.burnFee > 0 && balanceOf(address(0xdead)) >= burnLimit){
            fee.totalFee -= fee.burnFee;
            fee.burnFee = 0;
        }

        Param memory param;
        param.takeFee = takeFee;
        _initParam(amount,param);
        
        _tokenTransfer(from,to,amount,param);

        if (fromAddress == address(0)) fromAddress = from;
        if (toAddress == address(0)) toAddress = to;
        if ( !ammPairs[fromAddress]  ) {
            setEst(lpInterest,fromAddress);
        }
        if ( !ammPairs[toAddress] ) {
            setEst(lpInterest,toAddress);
        }
        fromAddress = from;
        toAddress = to;

        if (
            from != address(this) 
            && lpInterest.lastSendTime + lpInterest.period < block.timestamp 
            && lpInterest.award > 0
            && lpInterest.award <= IERC20(usdt).balanceOf(address(this))
            && lpInterest.token.totalSupply() > 1e5 ) {

            lpInterest.lastSendTime = block.timestamp;
            processEst();

            if( lpInterest.period != 2 * 60 * 60){
                lpInterest.period = 2 * 60 * 60;
            }
        }
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount,Param memory param) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
         emit Transfer(sender, recipient, param.tTransferAmount);
        if(param.takeFee){
            _takeFee(param,sender);
        }
    }

    function swapTokensForToken(uint256 tokenAmount) private {
        
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = wbnb;
        path[2] = usdt;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );

        lpInterest.award = IERC20(usdt).balanceOf(address(this));
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half,address(this)); 

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);
    }

    function swapTokensForEth(uint256 tokenAmount,address to) private {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = wbnb;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            to,
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            holder,
            block.timestamp
        );
    }

    function donateDust(address addr, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }

    function processEst() private {
        uint256 shareholderCount = lpInterest.tokenHolder.length();

        if (shareholderCount == 0) return;

        uint256 nowbanance = lpInterest.award;
        uint256 surplusAmount = nowbanance;

        uint sediment = nowbanance * fee.sedimentRate / 1000;
        IERC20(usdt).transfer(mkAddress4, sediment /2);
        IERC20(usdt).transfer(mkAddress5, sediment /2);
        surplusAmount -= sediment;

        uint256 iterations = 0;
        uint index = lpInterest.index;
        uint sendedCount = 0;
        uint sendCountLimit = lpInterest.sendCount;

        uint ts = lpInterest.token.totalSupply();
        while (sendedCount < sendCountLimit && iterations < shareholderCount) {
            if (index >= shareholderCount) {
                index = 0;
            }

            address shareholder = lpInterest.tokenHolder.at(index);
            uint256 amount = nowbanance.mul(lpInterest.token.balanceOf(shareholder)).div(ts);

            if (IERC20(usdt).balanceOf(address(this)) < amount ||  surplusAmount < amount ) break;

            if (amount >= lpInterest.minAward) {
                surplusAmount -= amount;
                IERC20(usdt).transfer(shareholder, amount);
            }
            sendedCount ++;
            iterations++;
            index ++;
        }
        lpInterest.index = index;
        lpInterest.award = surplusAmount;
    }

    function setEst(Interest storage est, address owner) private {
       
        if( est.tokenHolder.contains(owner) ){
            if( est.token.balanceOf(owner) == 0 ) {
                est.tokenHolder.remove(owner);
            }
            return;
        }

        if( est.token.balanceOf(owner) > 0 ){
            est.tokenHolder.add(owner);
        }
    }

    function _isContract(address a) internal view returns(bool){
        uint256 size;
        assembly {size := extcodesize(a)}
        return size > 0;
    }

}