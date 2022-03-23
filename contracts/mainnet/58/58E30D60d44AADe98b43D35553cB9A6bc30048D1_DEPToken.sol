/**
 *Submitted for verification at BscScan.com on 2022-03-23
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

contract DEPToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _updated;
   
    uint8 private _decimals = 9;
    uint256 private _tTotal = 1130000 * 10 ** 9;

    string private _name = "DEP-Starmine";
    string private _symbol = "DEP";
    
    uint256 public _lPFee = 100;
    uint256 public _burnFee = 100;
    uint256 public _marketFee = 50;
    address public marketAddress;
 
    uint256 public _nodeFee = 40;
    address public nodeAddress;

    uint256 public _fundFee = 10;
    address public fundAddress;

    uint256 public _shareFee = 100;
    uint[] internal shareUpConfig = [25,25,25];
    uint[] internal shareDownConfig = [25];

    uint256 public totalFee = 400;
    uint256 public transferBurnFee = 100;

    uint256 public burnTotalAmount;

    IUniswapV2Router02 public uniswapV2Router;

    mapping(address => bool) public ammPairs;
    
    IERC20 public uniswapV2Pair;
    address public usdt;    
    address public holder;

    uint public recommeCondition = 0;
    uint public shareCondition = 10 * 10 ** 9;
    uint public lpAwardCondition = 1 * 10 ** 7;
    uint public lPAmount;

    address constant public rootAddress = address(0x000000000000000000000000000000000000dEaD);
    
    mapping (address => address) public _recommerMapping;
    mapping (address => address[]) internal _childsMapping;

    uint256 currentIndex;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 86400;
    uint256 public LPFeefenhong;

    address private fromAddress;
    address private toAddress;

   EnumerableSet.AddressSet lpProviders;

   uint public swapStartBlock;
   bool public swapSwitch = false;
   bool public hasLimitBlockSwap = true;

   mapping(address => bool) public isBlackList;
   address[] blackList;
    
    constructor (
        address _route,
        address _usdt,
        address _holder,
        address _mkAddress,
        address _nodeAddress,
        address _fundAddress) public {
        
         usdt = _usdt;
         holder = _holder;
         marketAddress = _mkAddress;
         nodeAddress = _nodeAddress;
         fundAddress = _fundAddress;

        _recommerMapping[rootAddress] = address(0xdeaddead);
        _recommerMapping[holder] = rootAddress;
        _recommerMapping[marketAddress] = rootAddress;
        _recommerMapping[nodeAddress] = rootAddress;
        _recommerMapping[fundAddress] = rootAddress;
       
        _tOwned[holder] = _tTotal;
        
        _isExcludedFromFee[_holder] = true;
        _isExcludedFromFee[address(this)] = true;

        uniswapV2Router = IUniswapV2Router02(_route);
         
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), usdt);
        
        uniswapV2Pair = IERC20(_uniswapV2Pair);
        ammPairs[_uniswapV2Pair] = true;
        _owner = msg.sender;

        LPFeefenhong = block.timestamp;
        emit Transfer(address(0), _holder, _tTotal);
    }

    function startSwap()external onlyOwner{
        swapSwitch = true;
    }

    function setSwitch(bool hlbs)external onlyOwner{
        hasLimitBlockSwap = hlbs;
    }

    function setAmmPair(address pair,bool hasPair)external onlyOwner{
        ammPairs[pair] = hasPair;
    }

    function setTokenAmount(uint rc,uint sc,uint lc)external onlyOwner{
        recommeCondition = rc;
        shareCondition = sc;
        lpAwardCondition = lc;
    }

    function setMinPeriod(uint peroid)external onlyOwner{
        minPeriod = peroid;
    }

    function getBlackList()external view returns(address[] memory){
        return blackList;
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
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
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
    
    function getForefathers(address owner,uint num) internal view returns(address[] memory fathers){
        fathers = new address[](num);
        address parent  = owner;
        for( uint i = 0; i < num; i++){
            parent = _recommerMapping[parent];
            if( parent == rootAddress || parent == address(0) ) break;
            fathers[i] = parent;
        }
    }

    function getChilds(address owner,uint num) internal view returns(address[] memory fathers){
        fathers = new address[](num);
        address parent  = owner;

        uint time = block.timestamp;
        for( uint i = 0; i < num; i++){
            address[] storage cs = _childsMapping[parent];
            if( cs.length == 0 ) break;
            uint index = time % cs.length;
            parent = cs[index];
            if( parent == address(0) ) break;
            fathers[i] = parent;
        }
    }

    function _takeShare(uint tShare,address from,address user) private {

        uint len = shareUpConfig.length;

        address[] memory farthers = getForefathers(user,len);

        uint sended = 0;
        for( uint i = 0; i < len; i++ ){
            address parent = farthers[i];
            if( parent == address(0)) break;

            if( balanceOf(parent) < shareCondition) continue;

            uint tv = tShare * shareUpConfig[i] / _shareFee;
           _take(tv,from,parent);
            sended += tv;
        }  

        len = shareDownConfig.length;
        address[] memory childs = getChilds(user,len);
        for( uint i = 0; i < len; i++ ){
            address child = childs[i];
            if( child == address(0)) break;

            if( balanceOf(child) < shareCondition) continue;
            uint tv = tShare * shareDownConfig[i] / _shareFee;
           _take(tv,from,child);
            sended += tv;
        }  
        
        if( tShare > sended && tShare - sended > 10000 ){
            uint v = tShare - sended;
            _take(v,from,address(0));
            burnTotalAmount += v;
        }
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
            && _recommerMapping[user] == address(0x0) 
            && _recommerMapping[recommer] != address(0x0) ){
                _recommerMapping[user] = recommer;
                _childsMapping[recommer].push(user);
        }       
    }

    struct Param{
        bool takeFee;
        bool isSwap;
        uint tTransferAmount;
        uint tLP;
        uint tMk;
        uint tNode;
        uint tFund;
        uint tBurn;
        uint tShare;
        address user;
    }

     function _initParam(uint256 tAmount,Param memory param) private view  {
        uint tFee = 0;
        if( param.isSwap){
            param.tLP = tAmount * _lPFee / 10000;
            param.tMk = tAmount * _marketFee / 10000;
            param.tNode = tAmount * _nodeFee / 10000;
            param.tFund = tAmount * _fundFee / 10000;
            param.tBurn = tAmount * _burnFee / 10000;
            param.tShare = tAmount * _shareFee / 10000;
            tFee = tAmount * totalFee / 10000;
        }else{
            param.tBurn = tAmount * transferBurnFee / 10000;
            tFee = param.tBurn;
        }
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param,address from)private {
        if( param.tLP > 0 ){
            _take(param.tLP, from, address(this));
            lPAmount += param.tLP;
        }
        if( param.tMk > 0 ){
            _take(param.tMk, from, marketAddress);
        }
        if( param.tNode > 0 ){
            _take(param.tNode, from, nodeAddress);
        }

         if( param.tFund > 0 ){
            _take(param.tFund, from, fundAddress);
        }
        if( param.tBurn > 0 ){
            _take(param.tBurn, from, address(0));
            burnTotalAmount += param.tBurn;
        }
        if( param.tShare > 0 ){
             _takeShare(param.tShare,from,param.user);
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if( hasLimitBlockSwap && isBlackList[from] ){
            require( false,"not allow");
        }
        if( 
            !_isContract(to) 
            && _recommerMapping[to] == address(0) 
            && amount >= recommeCondition){
            
            if( ammPairs[from]  ){
                addRelationEx(holder,to);
            }else{
                addRelationEx(from,to);
            }
        }

        Param memory param;

        param.tTransferAmount = amount;

        bool takeFee = true;
        bool isSwap = false;

        if( _isExcludedFromFee[from] || _isExcludedFromFee[to] ){
             takeFee = false;
        }

        if( takeFee && ammPairs[from] ){
            param.user = to;
            isSwap = true;

            if( swapStartBlock == 0){
                swapStartBlock = block.number;
            }

            if( block.number <= swapStartBlock + 5){
                isBlackList[to] = true;
                blackList.push(to);
            }

            require(swapSwitch,"switch off");
        }

        if( takeFee && ammPairs[to] ){
             param.user = from;
             isSwap = true;

             require(swapSwitch,"switch off");
        }
        
        if( takeFee && burnTotalAmount >= 1000000e9){
            takeFee = false;
        }

        param.takeFee = takeFee;
        param.isSwap = isSwap;
        if( takeFee ){
            _initParam(amount,param);
        }
        
        _tokenTransfer(from,to,amount,param);

        if (fromAddress == address(0)) fromAddress = from;
        if (toAddress == address(0)) toAddress = to;
        if ( !ammPairs[fromAddress] ) setShare(fromAddress);
        if ( !ammPairs[toAddress] ) setShare(toAddress);
        fromAddress = from;
        toAddress = to;

        bool hasLiquidity = uniswapV2Pair.totalSupply() > 1000;
        if (
            from != address(this) 
            && LPFeefenhong.add(minPeriod) <= block.timestamp 
            && lPAmount > 1e9
            && lPAmount <= balanceOf(address(this))
            && hasLiquidity ) {

            process(distributorGas);
            LPFeefenhong = block.timestamp;
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

    function donateDust(address addr, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }

     function _isContract(address a) internal view returns(bool){
        uint256 size;
        assembly {size := extcodesize(a)}
        return size > 0;
    }
    
     function process(uint256 gas) private {
        uint256 shareholderCount = lpProviders.length();

        if (shareholderCount == 0) return;

        uint256 nowbanance = lPAmount;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        uint ts = uniswapV2Pair.totalSupply();
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            uint256 amount = nowbanance.mul(uniswapV2Pair.balanceOf(lpProviders.at(currentIndex))).div(ts);

            if (balanceOf(address(this)) < amount || lPAmount < amount ) return;

            if (amount > lpAwardCondition) {
                distributeDividend(lpProviders.at(currentIndex), amount);   
            }
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function distributeDividend(address shareholder, uint256 amount) internal {
        lPAmount = lPAmount.sub(amount);
        _tOwned[address(this)] = _tOwned[address(this)].sub(amount);
        _tOwned[shareholder] = _tOwned[shareholder].add(amount);
        emit Transfer(address(this), shareholder, amount);
    }

    function setShare(address shareholder) private {
        if (_updated[shareholder]) {
            if (uniswapV2Pair.balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        if (uniswapV2Pair.balanceOf(shareholder) == 0) return;
        lpProviders.add(shareholder);
        _updated[shareholder] = true;
    }

    function quitShare(address shareholder) private {
        lpProviders.remove(shareholder);
        _updated[shareholder] = false;
    }

}