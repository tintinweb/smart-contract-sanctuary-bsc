/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-12
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

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed owner, address indexed to, uint value);
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

abstract contract Auth {
    address public owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) public {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    // function getOwner() public view returns (address) {
    //     return owner;
    // }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
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

contract GYLM is Context, IERC20, Auth {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromHave;

    mapping(address => bool) private _updated;
   
    uint8 private _decimals = 18;
    uint256 private _tTotal;
    uint256 public supply = 130000000000 * 10 ** 18;

    string private _name = "GYLM";
    string private _symbol = "GYLM";
    
    uint256 public _buyLpFee = 9;
    uint256 public _sellLpFee = 9;

    uint256 public _buyDaoFee = 1;
    uint256 public _sellDaoFee = 1;
    address public daoAddress = 0xdA77469287fA818b8178114Eb43fF09E881Cc578;

    uint256 public _buyBurnFee = 3;
    uint256 public _sellBurnFee = 3;
    address public burnAddress = 0xA10F2b8662EF253692127c6CEaDB8f7D98f594e4;

    uint256 public _buyCharityFee = 1;
    uint256 public _sellCharityFee = 1;
    address public charityAddress = 0xc0B90ea824fa1bfEBDBB39641a134F9399c85DCE;
 
    uint256 public _buyShareFee = 0;
    uint256 public _sellShareFee = 0;
    uint256 internal _shareConfigNum = 0;
    uint[] internal shareConfig = [0];

    bool buyOpen;

    uint256 public totalBuyFee = 14;
    uint256 public totalSellFee = 14;

    IUniswapV2Router02 public uniswapV2Router;

    mapping(address => bool) public ammPairs;

    IERC20 public uniswapV2Pair;
    address public wbnb;
    address public usdt;

    uint public recommeCondition = 1 * 10 ** 16;
    uint public lpCondition = 1 * 10 ** 16;

    mapping(address => bool) isBlackList;

    uint256 public _maxHavAmount = 130000000000 * 10**18;

    address public initPoolAddress = address(0x450C9be62C1E3a26fd837D5F176D78B69137a7cD);

    address constant rootAddress = address(0x000000000000000000000000000000000000dEaD);
    
    mapping (address => address) public _recommerMapping;

    uint256 currentIndex;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 3600;
    uint256 public LPFeefenhong;

    address private fromAddress;
    address private toAddress;

    uint256 launchedAt = 0;

    EnumerableSet.AddressSet lpProviders;

    bool public swapEnabled = true;
    uint256 public swapThreshold = supply / 10000; // 0.01%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    
    constructor (
        address _route,
        address _usdt) Auth(msg.sender) public {
        
        usdt = _usdt;
        initPoolAddress = 0x450C9be62C1E3a26fd837D5F176D78B69137a7cD;

        _recommerMapping[rootAddress] = address(0x450C9be62C1E3a26fd837D5F176D78B69137a7cD);
        _recommerMapping[owner] = rootAddress;
        _recommerMapping[daoAddress] = rootAddress;
        _recommerMapping[burnAddress] = rootAddress;
        _recommerMapping[charityAddress] = rootAddress;
       
        _tOwned[owner] = supply;
        _tTotal = supply;
        
        _isExcludedFromFee[owner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[rootAddress] = true;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_route);
        uniswapV2Router = _uniswapV2Router;

        address bnbPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        wbnb = _uniswapV2Router.WETH();

        uniswapV2Pair = IERC20(bnbPair);
        ammPairs[bnbPair] = true;

        _isExcludedFromHave[owner] = true;
        _isExcludedFromHave[address(this)] = true;
        _isExcludedFromHave[rootAddress] = true;
        _isExcludedFromHave[address(uniswapV2Pair)] = true;

        LPFeefenhong = block.timestamp;

        emit Transfer(address(0), owner, _tTotal);
    }

    function setAddress(address _daoAddress, address _burnAddress, address _charityAddress)external authorized{
        daoAddress = _daoAddress;
        burnAddress = _burnAddress;
        charityAddress = _charityAddress;
    }

    function addToBlackList(address user) external authorized {
        isBlackList[user] = true;
    }

    function removeFromBlackList(address user) external authorized {
        isBlackList[user] = false;
    }

    function setMaxHavAmount(uint256 maxHavAmount)external authorized{
        _maxHavAmount = maxHavAmount;
    }

    function setBuyOpen() external authorized{
        buyOpen = true;
        launchedAt = block.number;
    }

    function setAmmPair(address pair,bool hasPair)external authorized{
        ammPairs[pair] = hasPair;
    }

    function setCondition(uint rc,uint lc)external authorized{
        recommeCondition = rc;
        lpCondition = lc;
    }

    function setMinPeriod(uint period)external authorized{
        minPeriod = period;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)external authorized{
        swapEnabled = _enabled;
        swapThreshold = _amount;
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
    
    function setExcludeFromFee(address account, bool _isExclude) public authorized {
        _isExcludedFromFee[account] = _isExclude;
    }

    function setExcludedFromHave(address account, bool _isExclude) public authorized {
        _isExcludedFromHave[account] = _isExclude;
    }
    
    receive() external payable {}

    function _take(uint256 tValue,address from,address to) private {
        _tOwned[to] = _tOwned[to].add(tValue);
        emit Transfer(from, to, tValue);
    }
    
    function getForefathers(address owner,uint num) external view returns(address[] memory fathers){
        fathers = new address[](num);
        address parent  = owner;
        for( uint i = 0; i < num; i++){
            parent = _recommerMapping[parent];
            if( parent == rootAddress || parent == address(0) ) break;
            fathers[i] = parent;
        }
    }

    function _takeShare(uint tShare,address from,address user) private {

        address[] memory farthers = this.getForefathers(user,shareConfig.length);

        uint len = farthers.length;

        uint sended = 0;
        for( uint i = 0; i < len; i++ ){
            address parent = farthers[i];
            if( parent == address(0)) break;
            if( isBlackList[parent] ){
                continue;
            }
            uint tv = tShare * shareConfig[i] / _shareConfigNum;
            _tOwned[parent] = _tOwned[parent].add(tv);
            emit Transfer(from, parent, tv);
            sended += tv;
        }  
        
        if( tShare > sended && tShare - sended > 10000 ){
            _take(tShare - sended,from,address(this));
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
        }       
    }

    function setFees(uint256 buyDaoFee, uint256 buyLpFee, uint256 buyShareFee, uint256 buyBurnFee, uint256 buyCharityFee,uint256 sellDaoFee, uint256 sellLpFee, uint256 sellShareFee, uint256 sellBurnFee, uint256 sellCharityFee) external authorized {
        _buyDaoFee = buyDaoFee;
        _buyLpFee = buyLpFee;
        _buyShareFee = buyShareFee;
        _buyBurnFee = buyBurnFee;
        _buyCharityFee = buyCharityFee;
        _sellDaoFee = sellDaoFee;
        _sellLpFee = sellLpFee;
        _sellShareFee = sellShareFee;
        _sellBurnFee = sellBurnFee;
        _sellCharityFee = sellCharityFee;
        totalBuyFee = _buyDaoFee.add(_buyLpFee).add(_buyShareFee).add(_buyBurnFee).add(_buyCharityFee);
        totalSellFee = _sellDaoFee.add(_sellLpFee).add(_sellShareFee).add(_sellBurnFee).add(_sellCharityFee);
    }

    struct Param{
        bool takeFee;
        uint tTransferAmount;
        uint tContract;
        uint tShare;
        address user;
    }

     function _initParam(uint256 tAmount,Param memory param, address to) private view  {
        uint tFee;
        if( ammPairs[to]  ){
            param.tContract = tAmount * (_sellDaoFee.add(_sellBurnFee).add(_sellCharityFee).add(_sellLpFee)) / 100;
            param.tShare = tAmount * _sellShareFee / 100;
            tFee = tAmount * totalSellFee / 100;
        } else{
            param.tContract = tAmount * (_buyDaoFee.add(_buyBurnFee).add(_buyCharityFee).add(_buyLpFee)) / 100;
            param.tShare = tAmount * _buyShareFee / 100;
            tFee = tAmount * totalBuyFee / 100;
        }
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param,address from)private {
        if( param.tContract > 0 ){
            _take(param.tContract, from, address(this));
        }
        if( param.tShare > 0 ){
             _takeShare(param.tShare,from,param.user);
        }
    }

    function shouldSwapBack(address to) internal view returns (bool) {
        return ammPairs[to]
        && !inSwap
        && swapEnabled
        && balanceOf(address(this)) >= swapThreshold;
    }

    function swapBack() internal swapping {
        _allowances[address(this)][address(uniswapV2Router)] = swapThreshold;

        uint256 amountToUsdt = swapThreshold.mul(3).div(10);
        uint256 amountToBnb = swapThreshold.sub(amountToUsdt);
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = wbnb;
        uint256 balanceBefore = address(this).balance;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToBnb,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 amountToDao = amountBNB.mul(1).div(7);
        uint256 amountToBurn = amountBNB.mul(5).div(7);
        uint256 amountToCharity = amountBNB.sub(amountToDao).sub(amountToBurn);

        payable(daoAddress).transfer(amountToDao);
        payable(burnAddress).transfer(amountToBurn);
        payable(charityAddress).transfer(amountToCharity);

        address[] memory pathToUsdt = new address[](3);
        pathToUsdt[0] = address(this);
        pathToUsdt[1] = wbnb;
        pathToUsdt[2] = usdt;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToUsdt,
            0,
            pathToUsdt,
            address(this),
            block.timestamp
        );   
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if( ammPairs[from] ){
            require(buyOpen == true, "buy should be opened");
        }

        if( isBlackList[from] ){
            require(false,"not allow");
        }

        if(!_isExcludedFromHave[to] && !ammPairs[to]){
            require(amount + balanceOf(to) <= _maxHavAmount,"Transfer amount exceeds the maxHavAmount.");
        }

        bool takeFee;

        Param memory param;
        param.tTransferAmount = amount;

        if( ammPairs[from] ){
            param.user = to;
        } else {
            param.user = address(this);
        }

        if( ammPairs[to] && IERC20(to).totalSupply() == 0  ){
            require(from == initPoolAddress,"not allow init");
        }   

        if(inSwap){
            return _tokenTransfer(from,to,amount,param); 
        }

        if (
            launchedAt > 0 &&
            ammPairs[from] &&
            !_isExcludedFromFee[to]
        ) {
            if (block.number - launchedAt < 5) {
                revert("Sniper rejected.");
            }
        }

        if( 
            !isContract(to) 
            && _recommerMapping[to] == address(0) 
            && amount >= recommeCondition){
            
            if( ammPairs[from]  ){
                addRelationEx(owner,to);
            }else{
                addRelationEx(from,to);
            }
        }

        if(ammPairs[to] || ammPairs[from]){
            takeFee = true;
        }

        if(_isExcludedFromFee[to] || _isExcludedFromFee[from]){
            takeFee = false;
        }

        if(shouldSwapBack(to)){ swapBack(); }

        param.takeFee = takeFee;
        if( takeFee ){
            _initParam(amount,param,to);
        }
        
        _tokenTransfer(from,to,amount,param);

        if( address(uniswapV2Pair) != address(0) ){
            if (fromAddress == address(0)) fromAddress = from;
            if (toAddress == address(0)) toAddress = to;
            if ( !ammPairs[fromAddress] ) setShare(fromAddress);
            if ( !ammPairs[toAddress] ) setShare(toAddress);
            fromAddress = from;
            toAddress = to;

            if (
                from != address(this) 
                && LPFeefenhong.add(minPeriod) <= block.timestamp 
                && IBEP20(usdt).balanceOf(address(this)) > 0
                && uniswapV2Pair.totalSupply() > 1000 ) {

                process(distributorGas);
                LPFeefenhong = block.timestamp;
            }
        }
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount,Param memory param) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
        emit Transfer(sender, recipient, param.tTransferAmount);
        if(param.takeFee){
            _takeFee(param,sender);
        }
    }
    
     function process(uint256 gas) private {
        uint256 shareholderCount = lpProviders.length();

        if (shareholderCount == 0) return;

        uint256 nowbanance = IBEP20(usdt).balanceOf(address(this));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        uint ts = uniswapV2Pair.totalSupply();
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            uint256 amount = nowbanance.mul(uniswapV2Pair.balanceOf(lpProviders.at(currentIndex))).div(ts);

            if (IBEP20(usdt).balanceOf(address(this)) < amount ) return;

            if (amount >= lpCondition) {
                IBEP20(usdt).transfer(lpProviders.at(currentIndex), amount);  
            }
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
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