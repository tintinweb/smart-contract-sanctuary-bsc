/**
 *Submitted for verification at BscScan.com on 2022-07-30
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
        IERC20(token).approve(msg.sender,uint256(-1));
    }
}

contract KOIToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _isExcludedFromFee;

    uint8 private _decimals = 9;
    uint256 private _tTotal = 10000000 * 10 ** 9;

    string private _name = "KOI";
    string private _symbol = "KOI";
    
    uint public _buyShareFee = 30;
    uint public _buyLpFee = 20;
    uint public _buyMkFee = 10;
    uint public totalBuyFee = 60;
    
    uint public _sellLpFee = 30;
    uint public _sellLqFee = 20;
    uint public _sellMkFee = 10;
    uint public totalSellFee = 60;

    uint public _transFee = 50;
    address transReceiver;
    address lpReceiver;
    address buyMkAddress;
    address sellMkAddress;
    address shareReceiver;
    
    address public tokenReceiver;
    
    IUniswapV2Router02 public uniswapV2Router;
    mapping(address => bool) public ammPairs;

    bool inSwapAndLiquify;
    address public uniswapV2Pair;
    address public token;   
    address public awardToken; 
    address  holder;

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

    uint public lpAmount;
    uint public lqAmount;
    uint public txAmount = 100e9;
    uint public buyMkAmount;
    uint public sellMkAmount;
    uint public mkTxAmount = 10e9;

    uint public swapStartTime;
    uint public addPriceTokenAmount = 1e18;

    mapping (address => address) public recommerMapping;

    mapping(address => address[]) internal childMapping;

    struct SendData {
		address fromAddress;
		bool status;
    }
	
	mapping(address => mapping(address => SendData)) public waitInviter;

    mapping(address => mapping(uint => uint)) public sellAmountPerDays;

    uint public sellRatio = 10;

    constructor (
        address _route,
        address _holder,
        address _token,
        address _awardToken) public {
        
        holder = _holder;
        _tOwned[holder] = _tTotal;
        token = _token;
        awardToken = _awardToken;
        _isExcludedFromFee[_holder] = true;
        _isExcludedFromFee[address(this)] = true;

        uniswapV2Router = IUniswapV2Router02(_route);
         
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), token);
        
        ammPairs[uniswapV2Pair] = true;

        tokenReceiver = address(new TokenReceiver(token));

        _owner = msg.sender;
        lpInterest.token = IERC20(uniswapV2Pair);
        lpInterest.lastSendTime = block.timestamp;
        lpInterest.minAward = 1e3;
        lpInterest.period = 14400;
        lpInterest.sendCount = 100;
        emit Transfer(address(0), _holder, _tTotal);
    }


    function setsellRatio(uint _sellRatio)external onlyOwner{
        sellRatio = _sellRatio;
    }

     function setSwapStartTime(uint _swapStartTime)external onlyOwner{
        swapStartTime = _swapStartTime;
    }


    function setInterset(uint _minAward,uint _period,uint _sendCount)external onlyOwner{
        lpInterest.minAward = _minAward;
        lpInterest.period = _period;
        lpInterest.sendCount = _sendCount;
    }

    function setLpTxAmount(uint _txAmount,uint _mkTxAmount)external onlyOwner{
        txAmount = _txAmount;
        mkTxAmount = _mkTxAmount;
    }

    function setAddress(
            address _transReceiver,
            address _lpReceiver,
            address _buyMkAddress,
            address _sellMkAddress,
            address _shareReceiver
    )external onlyOwner{
        transReceiver = _transReceiver;
        lpReceiver = _lpReceiver;
        buyMkAddress = _buyMkAddress;
        sellMkAddress = _sellMkAddress;
        shareReceiver = _shareReceiver;
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
        bool isTransfer;
        bool isSwapBuy;
        uint tTransferAmount;
        uint tLp;
        uint tLq;
        uint tBuyMk;
        uint tSellMk;
        uint tShare;
        uint tTrans;
        address user;
    }

    function _takeShare(uint tShare,address from,address user) private {
        address parent = recommerMapping[user];
        if( parent != address(0) ){
            _take(tShare,from,parent);
        }else{
             _take(tShare,from,shareReceiver);
        }
    }
	
	function _setInvite(address to, address from) private {
		if (recommerMapping[from] != to){
			recommerMapping[to] = from;
            childMapping[from].push(to);
		}
	}


    function _initParam(uint256 tAmount,Param memory param) private view  {
        uint tFee = 0;
        if( param.takeFee ){
            if( param.isTransfer){
                param.tTrans = tAmount * _transFee / 1000;
                tFee = param.tTrans;
            }else{
                if( param.isSwapBuy){
                    param.tShare = tAmount * _buyShareFee / 1000;
                    param.tLp = tAmount * _buyLpFee / 1000;
                    param.tBuyMk = tAmount * _buyMkFee / 1000;
                    tFee = tAmount * totalBuyFee / 1000;
                }else{
                    param.tLp = tAmount * _sellLpFee / 1000;
                    param.tLq = tAmount * _sellLqFee / 1000;
                    param.tSellMk = tAmount * _sellMkFee / 1000;
                    tFee = tAmount * totalSellFee / 1000;
                }
            }
        }
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param,address from)private {
        if( param.tBuyMk > 0 ){
            _take(param.tBuyMk, from, address(this));
            buyMkAmount += param.tBuyMk;
        }
        if( param.tSellMk > 0 ){
            _take(param.tSellMk, from, address(this));
            sellMkAmount += param.tSellMk;
        }
        if( param.tLq > 0 ){
            _take(param.tLq, from, address(this));
            lqAmount = param.tLq;
        }
        if( param.tLp > 0 ){
            _take(param.tLp, from, address(this));
            lpAmount += param.tLp;
        }
        if( param.tShare > 0 ){
            _takeShare(param.tShare, from, param.user);
        }
         if( param.tTrans > 0 ){
            _take(param.tTrans, from, transReceiver);
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

    function _sellableAmount(address owner,uint zero)internal view returns(uint v){
        uint selled = sellAmountPerDays[owner][zero];
        uint total = balanceOf(owner) + selled;
        uint sellable = total * sellRatio / 100;
        if( sellable > selled) {
            v = sellable.sub(selled);
        } 
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

         if(
            !from.isContract() 
            && !to.isContract() 
            && to != address(0) 
            && (recommerMapping[to] == address(0) 
                || recommerMapping[from] == address(0))){

            SendData memory sendData = waitInviter[from][to];
			bool doubleCheck = false;
			if (sendData.fromAddress == to){
				if (sendData.status && recommerMapping[from] == address(0)){
					_setInvite(from, to);
				}
				doubleCheck = true;
			}
			
			if (!doubleCheck && recommerMapping[to] == address(0)){
				SendData memory mySend = SendData(from, true);
				waitInviter[to][from] = mySend;
			}
        }

        bool isAddLiquidity;
        bool isDelLiquidity;
        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);

         if( block.timestamp < swapStartTime  ){
            if(ammPairs[from] && !isDelLiquidity){
                require(_isExcludedFromFee[to] ,"swap no start");
            }

            if(ammPairs[to] && !isAddLiquidity){
                require(_isExcludedFromFee[from] ,"swap no start");
            }
        }


        if( 
            from != address(this)
            && !inSwapAndLiquify 
            && !isAddLiquidity
            && !ammPairs[from] 
            &&  ammPairs[to]
            && IERC20(uniswapV2Pair).totalSupply() > 10000 ){
            
            inSwapAndLiquify = true;

            if( lqAmount >= txAmount && lqAmount <= balanceOf(address(this))){
                uint v = lqAmount;
                lqAmount = 0;
                swapAndLiquify(v);
            }

            if( buyMkAmount >= mkTxAmount && buyMkAmount <= balanceOf(address(this))){
                uint v = buyMkAmount;
                buyMkAmount = 0;
                swapTokensForAward(v,buyMkAddress);
            }

            if( sellMkAmount >= mkTxAmount && sellMkAmount <= balanceOf(address(this))){
                uint v = sellMkAmount;
                sellMkAmount = 0;
                swapTokensForAward(v,sellMkAddress);
            }

            if( lpAmount >= txAmount && lpAmount <= balanceOf(address(this))){
                uint v = lpAmount;
                lpAmount = 0;
                swapAndLpAward(v);
            }
            inSwapAndLiquify = false;
        }

        Param memory param;
       
        bool takeFee = true;

        if( 
            _isExcludedFromFee[from] 
            || _isExcludedFromFee[to] 
            || isAddLiquidity 
            || isDelLiquidity  ){

                takeFee = false;
            }

        param.takeFee = takeFee;

        if( takeFee ){

            bool isTrans = !ammPairs[from] && !ammPairs[to];
            param.isTransfer = isTrans;

            if( !isTrans){

                if( ammPairs[from]){
                    param.isSwapBuy = true;
                    param.user = to;
                }

                if( ammPairs[to]){
                    param.user = from;

                    uint zero = block.timestamp / 1 days * 1 days;
                    uint sellable = _sellableAmount(from, zero);

                    require(sellable > 0 ,"not sell quota");
                    amount = amount > sellable ? sellable : amount;

                    sellAmountPerDays[from][zero] += amount;
                }
            }
        }
        _initParam(amount,param);
        
        _tokenTransfer(from,to,amount,param);

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

        if (

            from != address(this) 
            && lpInterest.lastSendTime + lpInterest.period < block.timestamp 
            && lpInterest.award > 100000
            && lpInterest.award <= IERC20(awardToken).balanceOf(address(this))
            && lpInterest.token.totalSupply() > 1e5 ) {

            lpInterest.lastSendTime = block.timestamp;
            processEst();
        }
    }

     function swapAndLpAward(uint256 v) private  {    
        uint256 bal = IERC20(awardToken).balanceOf(address(this));
        swapTokensForAward(v,address(this)); 
        uint256 newBalance = IERC20(awardToken).balanceOf(address(this)).sub(bal);
        lpInterest.award += newBalance;
    }

     function swapTokensForAward(uint256 tokenAmount,address to) private {
        
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = token;
        path[2] = awardToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            to,
            block.timestamp
        );
    }

    function swapAndLiquify(uint256 contractTokenBalance) private  {    
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        swapTokensForEth(half,tokenReceiver); 

        uint256 newBalance = IERC20(token).balanceOf(tokenReceiver);

        addLiquidity(otherHalf, newBalance);
    }

    function swapTokensForEth(uint256 tokenAmount,address to) private {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = token;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            to,
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        IERC20(token).transferFrom(tokenReceiver,address(this),ethAmount);

        IERC20(token).approve(address(uniswapV2Router), ethAmount);

        uniswapV2Router.addLiquidity(
            address(this),
            token,
            tokenAmount,
            ethAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            lpReceiver,
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount,Param memory param) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
         emit Transfer(sender, recipient, param.tTransferAmount);
        if(param.takeFee){
            _takeFee(param,sender);
        }
    }

    function processEst() private {
        uint256 shareholderCount = lpInterest.tokenHolder.length();

        if (shareholderCount == 0) return;

        uint256 nowbanance = lpInterest.award;
        uint256 surplusAmount = nowbanance;
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

            if (
                IERC20(awardToken).balanceOf(address(this)) < amount 
                ||  surplusAmount < amount ) break;

            if (amount >= 1e3) {
                surplusAmount -= amount;
                IERC20(awardToken).transfer(shareholder, amount);
            }
            sendedCount ++;
            iterations++;
            index ++;
        }
        lpInterest.index = index;
        lpInterest.award = surplusAmount;
    }

    function setEst(address owner) private {
       
        if( lpInterest.tokenHolder.contains(owner) ){
            if( lpInterest.token.balanceOf(owner) == 0 ) {
                lpInterest.tokenHolder.remove(owner);
            }
            return;
        }

        if( lpInterest.token.balanceOf(owner) > 0 ){
            lpInterest.tokenHolder.add(owner);
        }
    }
}