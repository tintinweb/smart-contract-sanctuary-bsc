/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
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
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

contract DLDToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    mapping (address => bool) private _isBlacklist;

    uint8 private _decimals = 18;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 10000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "DLD";
    string private _symbol = "DLD";
    
    uint256 public _liquidityFee = 3;

    uint256 public _burnFee = 1;

    uint256 public _marketFee = 2;
    address public marketAddress;
    address public fundAddress;
    address public liquidityAddress;
    bool public _isOpenTrade = true;

    uint256[] public _perTierFee = [20,10,5,5,5,5,5,5];

    address public  uniswapV2Pair;
        
    uint256 public _maxTradeAmount = 500000 * 10**18;
    
    address public holder;

    address constant public rootAddress = address(0x000000000000000000000000000000000000dEaD);
    
    mapping (address => address) public _recommerMapping;

    mapping( address => uint) public _tierMapping;
    
    constructor (address _holder,address _marketAddress,address _fundAddress, address _liquidityAddress) public {
        _recommerMapping[rootAddress] = address(0xdeaddead);
        _recommerMapping[_holder] = rootAddress;
        _tierMapping[rootAddress] = 0;
        _tierMapping[_holder] = 1;

        _rOwned[_holder] = _rTotal;
                
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_holder] = true;
        _isExcludedFromFee[address(this)] = true;

        holder = _holder;
        marketAddress = _marketAddress;
        fundAddress = _fundAddress;
        liquidityAddress = _liquidityAddress;
        emit Transfer(address(0), _holder, _tTotal);
    }

    function setPair(address pair) external onlyOwner() {
        uniswapV2Pair = pair;
    }

    function setMaxTrade(uint256 maxTx) external onlyOwner() {
        _maxTradeAmount = maxTx;
    }

    function setTradeStatus(bool isOpen) external onlyOwner() {
        _isOpenTrade = isOpen;
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
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
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

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            Param memory param = _getValues(tAmount,false,address(0));
            return param.rAmount;
        } else {
            Param memory param = _getValues(tAmount,false,address(0));
            return param.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isBlacklist(address account) public view returns (bool) {
        return _isBlacklist[account];
    }

    function includeBlacklist(address account) public onlyOwner() {
        _isBlacklist[account] = true;
    }

     function excludeBlacklist(address account) public onlyOwner() {
        _isBlacklist[account] = false;
    }
    
    receive() external payable {}

    struct Param{
        uint rAmount;
        uint rTransferAmount;
        uint tTransferAmount;
        uint tLiquidity;
        uint tBurn;
        uint tMarket;
        uint tShare;
    }


    function _getValues(uint256 tAmount,bool takeFee,address user) private view returns (Param memory param) {

        uint tFee = 0;
        uint256 rFee = 0;
        uint256 currentRate = _getRate();
        if(takeFee){
            param.tLiquidity = tAmount * _liquidityFee / 100;
            param.tBurn = tAmount * _burnFee / 100;
            param.tMarket = tAmount * _marketFee / 100;

            uint tier = _tierMapping[user];
            uint _shareFee = 0;
            if( tier > 1 ){
                // _shareFee = getForeFee(tier-1);
                _shareFee = getTotalShareFee();
                param.tShare = tAmount * _shareFee / 1000;
            }
            uint _totalFee = _liquidityFee * 10 + _burnFee * 10  + _marketFee * 10 + _shareFee;
            
            tFee = tAmount * _totalFee / 1000;
            rFee = tFee.mul(currentRate);
        }
        param.tTransferAmount = tAmount.sub(tFee);
        param.rAmount = tAmount.mul(currentRate);
        param.rTransferAmount = param.rAmount.sub(rFee);
    }


    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity,uint256 currentRate,address from) private {
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[liquidityAddress] = _rOwned[liquidityAddress].add(rLiquidity);
        if(_isExcluded[liquidityAddress]){
            _tOwned[liquidityAddress] = _tOwned[liquidityAddress].add(tLiquidity);
        }
        // emit Transfer(from, liquidityAddress, tLiquidity);
    }
    
    function _takeBurn(uint tBurn,uint256 currentRate,address from) private {
        uint256 rBurn = tBurn.mul(currentRate);
        _rOwned[address(0)] = _rOwned[address(0)].add(rBurn);
        if(_isExcluded[address(0)]){
             _tOwned[address(0)] = _tOwned[address(0)].add(tBurn);
        }    
        emit Transfer(from, address(0), tBurn);
    }

    function _takeMarket(uint tMarket,uint256 currentRate,address from) private {
        uint256 rMarket = tMarket.mul(currentRate);
        _rOwned[marketAddress] = _rOwned[marketAddress].add(rMarket);
        if(_isExcluded[marketAddress]){
             _tOwned[marketAddress] = _tOwned[marketAddress].add(tMarket);
        }    
        //emit Transfer(from, marketAddress, tMarket);
    }

    function _takeFund(uint tFund,uint256 currentRate,address from) private {
        uint256 rFund = tFund.mul(currentRate);
        _rOwned[fundAddress] = _rOwned[fundAddress].add(rFund);
        if(_isExcluded[fundAddress]){
             _tOwned[fundAddress] = _tOwned[fundAddress].add(tFund);
        }    
        //emit Transfer(from, fundAddress, tMarket);
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

    function getForeFee(uint num) internal view returns(uint256){
        num = num > _perTierFee.length ? _perTierFee.length : num;
        uint total = 0;
        for( uint i = 0; i < num; i++){
            total = total.add(_perTierFee[i]);
        }

        return total;
    }

     function getTotalShareFee() internal view returns(uint256){
        uint total = 0;
        for( uint i = 0; i < _perTierFee.length; i++){
            total = total.add(_perTierFee[i]);
        }

        return total;
    }


    function _takeShare(uint tShare,uint256 currentRate,address from,address user) private {

        if( tShare > 0 ){
            uint tier = _tierMapping[user];

            if( tier > 1 ){

                uint size = tier - 1;
                size = size > 8 ? 8 : size;

                address[] memory farthers = getForefathers(user,size);
                uint256 totalRate = getTotalShareFee();

                uint256 remain = tShare;

                for( uint i = 0; i < size; i++ ){

                    address parent = farthers[i];

                    if( parent == rootAddress || parent == address(0)) break;

                    uint tv = tShare.mul(_perTierFee[i]).div(totalRate);
                    remain = remain.sub(tv);
                    uint rv = tv.mul(currentRate);

                    _rOwned[parent] = _rOwned[parent].add(rv);
                    if(_isExcluded[parent]){
                        _tOwned[parent] = _tOwned[parent].add(tv);
                    }    
                    emit Transfer(from, parent, tv);
                }

                if (remain > 0) {
                    _takeFund(remain, currentRate, from);
                }
            }
        }
        
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
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
                _tierMapping[user] = _tierMapping[recommer] + 1;
        }       
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_isBlacklist[from] == false, "from is in blacklist");
        require(_isBlacklist[to] == false, "to is in blacklist");

         if(uniswapV2Pair != address(0) ){
            if( from == uniswapV2Pair &&  !_isExcludedFromFee[to]   ){
                require(_isOpenTrade == true, "TX is not open");
                require(amount <= _maxTradeAmount, "Transfer amount too high");
            }

            if( to == uniswapV2Pair && !_isExcludedFromFee[from] ){
                require(_isOpenTrade == true, "TX is not open");
                require(amount <= _maxTradeAmount, "Transfer amount too high");
            }
        }

        if( 
            !_isContract(to) 
            && _rOwned[to] == 0 
            && _recommerMapping[to] == address(0) ){
            
            if( uniswapV2Pair == from ){
                addRelationEx(holder,to);
            }else{
                addRelationEx(from,to);
            }
        }
         
        
        bool takeFee = false;
        address user = address(0);

        if(uniswapV2Pair != address(0) ){
            if( from == uniswapV2Pair &&  !_isExcludedFromFee[to]   ){
                takeFee = true;
                user = to;
            }

            if( to == uniswapV2Pair && !_isExcludedFromFee[from] ){
                takeFee = true;
                user = from;
            }
        }
        
        _tokenTransfer(from,to,amount,takeFee,user);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee,address user) private {
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount,takeFee,user);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount,takeFee,user);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount,takeFee,user);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount,takeFee,user);
        } else {
            _transferStandard(sender, recipient, amount,takeFee,user);
        }
    }

    function _takeFee(Param memory param,address from,address user)private {
        uint256 currentRate = _getRate();
        _takeLiquidity(param.tLiquidity,currentRate,from);
        _takeBurn(param.tBurn,currentRate,from);
        _takeMarket(param.tMarket,currentRate,from);
        _takeShare(param.tShare,currentRate,from,user);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount,bool takeFee,address user) private {
        Param memory param = _getValues(tAmount,takeFee,user);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(param.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(param.rTransferAmount);        
         emit Transfer(sender, recipient, param.tTransferAmount);
        if(takeFee){
            _takeFee(param,sender,user);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount,bool takeFee,address user) private {
        Param memory param = _getValues(tAmount,takeFee,user);
        _rOwned[sender] = _rOwned[sender].sub(param.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(param.rTransferAmount);
        emit Transfer(sender, recipient, param.tTransferAmount);
        if(takeFee){
            _takeFee(param,sender,user);
        }
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount,bool takeFee,address user) private {
        Param memory param = _getValues(tAmount,takeFee,user);
        _rOwned[sender] = _rOwned[sender].sub(param.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(param.rTransferAmount);   
        emit Transfer(sender, recipient, param.tTransferAmount);
        if(takeFee){
            _takeFee(param,sender,user);
        }
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount,bool takeFee,address user) private {
        Param memory param  = _getValues(tAmount,takeFee,user);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(param.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(param.rTransferAmount);   
        emit Transfer(sender, recipient, param.tTransferAmount);
        if(takeFee){
            _takeFee(param,sender,user);
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
}