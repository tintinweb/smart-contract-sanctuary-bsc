/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-25
*/

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

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

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
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


contract NBToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    uint8 private _decimals = 9;
    uint256 private _tTotal = 999999 * 10 ** 9;

    string private _name = "NB Miracle";
    string private _symbol = "NB";
    
    uint public _lpFee = 20;
    
    IUniswapV2Router02 public uniswapV2Router;
    mapping(address => bool) public ammPairs;

    bool inSwapAndLiquify;
    address public uniswapV2Pair;
    address public qiToNbV2Pair;

    address public qjToken;
    address public token;    
    address  holder;
    uint public swapStartTime;

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

    Interest internal lpInterestQj;

    mapping(address => Interest) lpTd;

    struct LpAwardCondition{
        uint lpHoldAmount;
        uint balHoldAmount;
    }

    struct lpLock{
        uint amount;
        uint endTime;
        bool used;
    }    

    mapping(address => lpLock[]) qjAddressToLock;

    mapping(address => lpLock[]) usdtAddressToLock;

    LpAwardCondition public lpAwardCondition;

    LpAwardCondition public lpAwardConditionQj;

    uint public addPriceTokenAmount = 1e14;

    constructor (
        address _route,
        address _holder,
        address _qj,
        address _usdt,
        uint _period) public {
        
        lpAwardCondition = LpAwardCondition(1e8,1e8);
        lpAwardConditionQj = LpAwardCondition(1e8,1e8);

        holder = _holder;
        _tOwned[holder] = _tTotal;
        token = _usdt;
        qjToken = _qj;
        _isExcludedFromFee[_holder] = true;
        _isExcludedFromFee[address(this)] = true;

        uniswapV2Router = IUniswapV2Router02(_route);
         
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), token);


        qiToNbV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), qjToken);
        ammPairs[uniswapV2Pair] = true;
        ammPairs[qiToNbV2Pair] = true;


        _owner = msg.sender;
        lpInterest.token = IERC20(uniswapV2Pair);
        lpInterest.lastSendTime = block.timestamp;
        lpInterest.minAward = 1e3;
        lpInterest.period = 1800;
        lpInterest.sendCount = 100;

        lpInterestQj.token = IERC20(qiToNbV2Pair);
        lpInterestQj.lastSendTime = block.timestamp;
        lpInterestQj.minAward = 1e3;
        lpInterestQj.period = _period;
        lpInterestQj.sendCount = 100;

        emit Transfer(address(0), _holder, _tTotal);
    }

    function setAddPriceTokenAmount(uint _addPriceTokenAmount)external onlyOwner{
        addPriceTokenAmount = _addPriceTokenAmount;
    }

    function setlpAwardCondition(uint lpHoldAmount,uint balHoldAmount)external onlyOwner{
        lpAwardCondition.lpHoldAmount = lpHoldAmount;
        lpAwardCondition.balHoldAmount = balHoldAmount;
    }

    function setlpAwardConditionQj(uint lpHoldAmount,uint balHoldAmount)external onlyOwner{
        lpAwardConditionQj.lpHoldAmount = lpHoldAmount;
        lpAwardConditionQj.balHoldAmount = balHoldAmount;
    }

    struct InterestInfo{
        uint period;
        uint lastSendTime;
        uint award;
        uint count;
        uint sendNum;
    }
    function getInterestInfo()external view returns(InterestInfo memory lpI){
        lpI.period = lpInterest.period;
        lpI.lastSendTime = lpInterest.lastSendTime;
        lpI.award = lpInterest.award;
        lpI.count = lpInterest.tokenHolder.length();
        lpI.sendNum = lpInterest.sendCount;
    }

    function getInterestInfoQj()external view returns(InterestInfo memory lpI){
        lpI.period = lpInterestQj.period;
        lpI.lastSendTime = lpInterestQj.lastSendTime;
        lpI.award = lpInterestQj.award;
        lpI.count = lpInterestQj.tokenHolder.length();
        lpI.sendNum = lpInterestQj.sendCount;
    }


    function setswapStartTime(uint _swapStartTime)external onlyOwner{
        swapStartTime = _swapStartTime;
    }

    function setInterset(uint _minAward,uint _period,uint _sendCount)external onlyOwner{
        lpInterest.minAward = _minAward;
        lpInterest.period = _period;
        lpInterest.sendCount = _sendCount;
    }

    function setIntersetQj(uint _minAward,uint _period,uint _sendCount)external onlyOwner{
        lpInterestQj.minAward = _minAward;
        lpInterestQj.period = _period;
        lpInterestQj.sendCount = _sendCount;
    }

    function setAmmPair(address pair,bool hasPair)external onlyOwner{
        ammPairs[pair] = hasPair;
    }
    // struct lpLock{
    //     uint amount;
    //     uint endTime;
    //     bool used;
    // }    

    // mapping(address => lpLock[]) addressToLock;



    function setQjLock(address contractAddress,address walletAddress,uint amount,uint endTime)external onlyOwner{
        lpLock[] storage lpArray = qjAddressToLock[walletAddress];
        lpLock memory lk = lpLock(amount,endTime,true);
        lpArray.push(lk);
    }

    function setUsdtLock(address contractAddress,address walletAddress,uint amount,uint endTime)external onlyOwner{
        lpLock[] storage lpArray = usdtAddressToLock[walletAddress];
        lpLock memory lk = lpLock(amount,endTime,true);
        lpArray.push(lk);
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
        uint tTransferAmount;
        uint tLp;
    }

    function _initParam(uint256 tAmount,Param memory param) private view  {
        uint tFee = 0;
        if( param.takeFee ){
            param.tLp = tAmount * _lpFee / 1000;
            tFee = param.tLp;
            
        }
        param.tTransferAmount = tAmount.sub(tFee);
    }


    function _takeFee(Param memory param,address from,uint _pairFlag)private {
        if( param.tLp > 0 ){
            _take(param.tLp, from, address(this));
            if(_pairFlag == 1){
                lpInterestQj.award += param.tLp;
            }else{
                lpInterest.award += param.tLp;
            }
        }
    }


    function _doTransfer(address sender, address recipient, uint256 tAmount) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
         emit Transfer(sender, recipient, tAmount);
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

    function _isLiquidityQj(address from,address to)internal view returns(bool isAdd,bool isDel){
        address token0 = IUniswapV2Pair(address(qiToNbV2Pair)).token0();
        (uint r0,,) = IUniswapV2Pair(address(qiToNbV2Pair)).getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(qiToNbV2Pair));
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
           
        bool isAddLiquidity;
        bool isDelLiquidity;
        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);

        bool isAddLiquidityQj;
        bool isDelLiquidityQj;

        ( isAddLiquidityQj, isDelLiquidityQj) = _isLiquidityQj(from,to);


        if( block.timestamp < swapStartTime && (ammPairs[from] || ammPairs[to]) ){
            require(false,"swap no start");
        }
        
        Param memory param;
       
        bool takeFee = false;

        if( ammPairs[to] && !_isExcludedFromFee[from] && !isAddLiquidity && !isAddLiquidityQj){
            takeFee = true;
        }

        if( ammPairs[from] && !_isExcludedFromFee[to] && !isDelLiquidity && !isDelLiquidityQj){
            takeFee = true;
        }

        param.takeFee = takeFee;
        _initParam(amount,param);
        if(from == qiToNbV2Pair || to == qiToNbV2Pair){
            _tokenTransfer(from,to,amount,param,1);
        }else{
            _tokenTransfer(from,to,amount,param,2);
        }

        if (fromAddress == address(0)) fromAddress = from;
        if (toAddress == address(0)) toAddress = to;
        if ( !ammPairs[fromAddress] ) {
            setEst(fromAddress);
        }
        if ( !ammPairs[toAddress] ) {
            setEst(toAddress);
        }
        fromAddress = from;
        toAddress = to;

        if(from == uniswapV2Pair || to == uniswapV2Pair){
            if ( 
                from != address(this) 
                && lpInterest.lastSendTime + lpInterest.period < block.timestamp 
                && lpInterest.award > 100000
                && lpInterest.award <= balanceOf(address(this))
                && lpInterest.token.totalSupply() > 1e5 ) {
                lpInterest.lastSendTime = block.timestamp;
                processEst();
            }
        }

        if(from == qiToNbV2Pair || to == qiToNbV2Pair){
            if ( 
                from != address(this) 
                && lpInterestQj.lastSendTime + lpInterestQj.period < block.timestamp 
                && lpInterestQj.award > 100000
                && lpInterestQj.award <= balanceOf(address(this))
                && lpInterestQj.token.totalSupply() > 1e5 ) {
                lpInterestQj.lastSendTime = block.timestamp;
                processEstQj();
            }
        }


    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount,Param memory param,uint pairFlag) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
         emit Transfer(sender, recipient, param.tTransferAmount);
        if(param.takeFee){
            _takeFee(param,sender,pairFlag);
        }
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
        nowbanance = nowbanance.mul(8).div(10);
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

            lpLock[] memory lpArray = usdtAddressToLock[shareholder];
            
            uint256 lpBalance = 0;

            if(lpArray.length > 0){
                for(uint i=0;i<lpArray.length;i++){
                    lpLock memory myLock = lpArray[i];
                    if(myLock.used && block.timestamp < myLock.endTime){
                        lpBalance = lpBalance.add(myLock.amount);
                    }
                }
                lpBalance = lpBalance.add(lpInterest.token.balanceOf(shareholder));
            }else{
                lpBalance = lpInterest.token.balanceOf(shareholder);
            }

            uint256 amount = nowbanance.mul(lpBalance).div(ts);

            if (
                balanceOf(address(this)) < amount 
                ||  surplusAmount < amount ) break;

            if (amount >= 1e4) {
                surplusAmount -= amount;
                _doTransfer(address(this),shareholder, amount);
            }
            sendedCount ++;
            iterations++;
            index ++;
        }
        lpInterest.index = index;
        lpInterest.award = surplusAmount;
    }



    function processEstQj() private {
        uint256 shareholderCount = lpInterestQj.tokenHolder.length();
        if (shareholderCount == 0) return;
        uint256 nowbanance = lpInterestQj.award;
        uint256 surplusAmount = nowbanance;
        nowbanance = nowbanance.mul(8).div(10);
        uint256 iterations = 0;
        uint index = lpInterestQj.index;
        uint sendedCount = 0;
        uint sendCountLimit = lpInterestQj.sendCount;
        uint ts = lpInterestQj.token.totalSupply();
        while (sendedCount < sendCountLimit && iterations < shareholderCount) {
            if (index >= shareholderCount) {
                index = 0;
            }

            address shareholder = lpInterestQj.tokenHolder.at(index);
            lpLock[] memory lpArray = qjAddressToLock[shareholder];
            
            uint256 lpBalance = 0;

            if(lpArray.length > 0){
                for(uint i=0;i<lpArray.length;i++){
                    lpLock memory myLock = lpArray[i];
                    if(myLock.used && block.timestamp < myLock.endTime){
                        lpBalance = lpBalance.add(myLock.amount);
                    }
                }
                lpBalance = lpBalance.add(lpInterestQj.token.balanceOf(shareholder));
            }else{
                lpBalance = lpInterestQj.token.balanceOf(shareholder);
            }

            uint256 amount = nowbanance.mul(lpBalance).div(ts);

            if (
                balanceOf(address(this)) < amount 
                ||  surplusAmount < amount ) break;

            if (amount >= 1e4) {
                surplusAmount -= amount;
                _doTransfer(address(this),shareholder, amount);
            }
            sendedCount ++;
            iterations++;
            index ++;
        }
        lpInterestQj.index = index;
        lpInterestQj.award = surplusAmount;
    }



    function setEst(address owner) private {

            if( lpInterest.tokenHolder.contains(owner) ){
                if( !checkLpAwardCondition(owner) ) {
                    lpInterest.tokenHolder.remove(owner);
                }
                return;
            }
            
            if( checkLpAwardCondition(owner)){
                lpInterest.tokenHolder.add(owner);
            }

            if( lpInterestQj.tokenHolder.contains(owner) ){
                if( !checkLpAwardConditionQj(owner) ) {
                    lpInterestQj.tokenHolder.remove(owner);
                }
                return;
            }
            if( checkLpAwardConditionQj(owner)){
                lpInterestQj.tokenHolder.add(owner);
            }
        
    }

    function checkLpAwardCondition(address owner)internal view returns(bool){

        uint supply = lpInterest.token.totalSupply();
        uint lpAmount = lpInterest.token.balanceOf(owner);

        (,uint r1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        address token1 = IUniswapV2Pair(address(uniswapV2Pair)).token1();

        if(supply > 0){

            if( token1 == address(this) && supply > 0){
                return lpAmount * r1 / supply >= lpAwardCondition.lpHoldAmount 
                    && balanceOf(owner) >= lpAwardCondition.balHoldAmount;
            }
            (uint r0,,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
            address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
             if( token0 == address(this) && supply > 0){  
                return lpAmount * r0 / supply >= lpAwardCondition.lpHoldAmount 
                    && balanceOf(owner) >= lpAwardCondition.balHoldAmount;
            }           

        }
        return false;
    }

    function checkLpAwardConditionQj(address owner)internal view returns(bool){

        uint supply = lpInterestQj.token.totalSupply();
        uint lpAmount = lpInterestQj.token.balanceOf(owner);

        (,uint r1,) = IUniswapV2Pair(qiToNbV2Pair).getReserves();
        address token1 = IUniswapV2Pair(address(qiToNbV2Pair)).token1();

        if(supply > 0){

            if( token1 == address(this) && supply > 0){
                return lpAmount * r1 / supply >= lpAwardConditionQj.lpHoldAmount 
                    && balanceOf(owner) >= lpAwardConditionQj.balHoldAmount;
            }
            (uint r0,,) = IUniswapV2Pair(qiToNbV2Pair).getReserves();
            address token0 = IUniswapV2Pair(address(qiToNbV2Pair)).token0();
             if( token0 == address(this) && supply > 0){   
                return lpAmount * r0 / supply >= lpAwardCondition.lpHoldAmount 
                    && balanceOf(owner) >= lpAwardCondition.balHoldAmount;
            }           

        }
        return false;
    }
}