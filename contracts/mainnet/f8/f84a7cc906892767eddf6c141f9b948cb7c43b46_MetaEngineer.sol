/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/
 
// SPDX-License-Identifier: Unlicensed
 
pragma solidity ^0.8.14;
 
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
    function _msgSender() internal view virtual returns (address ) {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

contract TokenDistributor {
     constructor (address token){
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
         IERC20(token).approve(tx.origin, uint(~uint256(0)));
    }
} 
contract MetaEngineer is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    uint256 private constant MAX = ~uint256(0);
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
 
    mapping (address => bool) private _isExcludedFromFee;
   
    uint8 private _decimals = 9;
    uint256 private _tTotal = 100000 * 10**9;
 
    string private _name = "MetaEngineer";
    string private _symbol = "MEN";
    
    uint256 public _buyLiquidityFee = 10;
    uint256 public _sellLiquidityFee = 10;
 
    uint256 public _buyBurnFee = 10;
    uint256 public _sellBurnFee = 10;
 
    uint256 public _sellMarketFee = 10;
    uint256 public _buyMarketFee = 10;
    address public marketAddress;
    uint256 public _shareFee = 10;
 
    uint[] internal shareConfig = [4,2,1,1,1,1,0,0];
    uint256 shareRank=6;//max is 8
 
    uint256 public totalBuyFee = 40;
    uint256 public totalSellFee = 40;
 
 
    mapping(address => bool) public initPoolAddress;
    //mapping(uint => uint) public dayBuyLimits;
 
    mapping(address => mapping(uint => uint)) public addressBuyAmounts;
 
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public  uniswapV2Pair;
    address public wbnb;
    mapping(address => bool) public ammPairs;
    
    bool inSwapAndLiquify;
    uint256 public numTokensSellToAddToLiquidity = 50 * 10**9;
    uint256 public _burnMax = 90000*10**9;//燃烧的最大数
    uint256 public numLPSellToAddToLiquidity = 0;
    address public holder;
    TokenDistributor private _tokenDistributor;
 
    address constant public rootAddress = address(0x000000000000000000000000000000000000dEaD);
    
    mapping (address => address) public _recommerMapping;
 
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor (
        string memory name_,string memory symbol_,uint256  totalSupply_,
        uint256 minimumTokenBalanceForDividends_,uint256 burnMax_) public {
       
        _name=name_;
        _symbol=symbol_;
        _tTotal=totalSupply_*10**9;
        shareRank=6;
        _shareFee=10;
        _burnMax=burnMax_*10**9;
         wbnb = address(0x55d398326f99059fF775485246999027B3197955);//0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);//usdt wbnb shib
         holder = address(0x38E77e49D404334Bb01d00cf93FF3Ab3d9ef98B2);// owner
         marketAddress = address(0x697efA0D06bd418a8bd8F24354A1E76bfd3Ee82C);
         _buyLiquidityFee=10;
         _sellLiquidityFee=10;
        _buyBurnFee=10;
        _sellBurnFee=10;
        _buyMarketFee=20;
        _sellMarketFee=20;
        numTokensSellToAddToLiquidity=minimumTokenBalanceForDividends_*10**9;
        shareRank=6;
        totalBuyFee=_shareFee;
        totalBuyFee=totalBuyFee.add(_buyLiquidityFee).add(_buyBurnFee).add(_buyMarketFee);
        totalSellFee=_shareFee;
        totalSellFee=totalSellFee.add(_sellLiquidityFee).add(_sellBurnFee).add(_sellMarketFee);
        _recommerMapping[rootAddress] = address(0xdeaddead);
        _recommerMapping[holder] = rootAddress;
        _recommerMapping[marketAddress] = rootAddress;
        _tOwned[holder] = _tTotal;
         IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
         uniswapV2Router = _uniswapV2Router;
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), wbnb);
        _allowances[address(this)][address(_uniswapV2Router)] = MAX;
        IERC20(wbnb).approve(address(_uniswapV2Router), MAX);
        uniswapV2Pair = _uniswapV2Pair;
        ammPairs[uniswapV2Pair] = true;
        _isExcludedFromFee[holder] = true;
        _isExcludedFromFee[address(this)] = true;
        _owner = msg.sender;
        initPoolAddress[address(0xad6C294BDE2f5829FC42072AEB19DB9A7Cc48cA9)] = true;
        initPoolAddress[address(0xad6C294BDE2f5829FC42072AEB19DB9A7Cc48cA9)] = true;
        _tokenDistributor = new TokenDistributor(wbnb);
        emit Transfer(address(0), holder, _tTotal);
    }
   
    function setBurnMax(uint256 burnMax) external onlyOwner{
        _burnMax = burnMax * 10 ** 9;
    }
    function setNumTokensSellToAddToLiquidity(uint256 numTokens) external onlyOwner{
        numTokensSellToAddToLiquidity = numTokens*10** 9;
    }
    function setNumLPSellToAddToLiquidity(uint256 numTokens) external onlyOwner{
        numLPSellToAddToLiquidity = numTokens*10** 9;
    }
    function setTotalBuyFee(uint256 buyLiquidityFee,uint256 buyBurnFee,uint256 buyMarketFee) external onlyOwner{
        _buyLiquidityFee = buyLiquidityFee;
        _buyBurnFee=buyBurnFee;
        _buyMarketFee=buyMarketFee;
        totalBuyFee=_shareFee;
        totalBuyFee=totalBuyFee.add(_buyLiquidityFee).add(_buyBurnFee).add(_buyMarketFee);
        
    }
    function setTotalSellFee(uint256 sellLiquidityFee,uint256 sellBurnFee,uint256 sellMarketFee) external onlyOwner{
        _sellLiquidityFee = sellLiquidityFee;
        _sellBurnFee=sellBurnFee;
        _sellMarketFee=sellMarketFee;
        totalSellFee=_shareFee;
        totalSellFee=totalSellFee.add(_sellLiquidityFee).add(_sellBurnFee).add(_sellMarketFee);
    }
    function setShareFee(uint16 inviterGeneration_,uint16 [4] memory inviterGenerations_) external onlyOwner{
        shareRank=inviterGeneration_;
        _shareFee=0;
        for(uint i=0;i<shareRank;i++){
            if(i>3){
            shareConfig[i]=inviterGenerations_[3];
            }else{
                shareConfig[i]=inviterGenerations_[i];
            }
            _shareFee=_shareFee.add(shareConfig[i]);
        }
        totalSellFee=_shareFee;
        totalSellFee=totalSellFee.add(_sellLiquidityFee).add(_sellBurnFee).add(_sellMarketFee);
         totalBuyFee=_shareFee;
        totalBuyFee=totalBuyFee.add(_buyLiquidityFee).add(_buyBurnFee).add(_buyMarketFee);
        
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
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
 
    function excludeFromFees(address[] memory accounts) public onlyOwner{
        uint len = accounts.length;
        for( uint i = 0; i < len; i++ ){
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
    
    function getForefathers(address owner,uint num) internal view returns(address[] memory fathers){
        fathers = new address[](num);
        address parent  = owner;
        for( uint i = 0; i < num; i++){
            parent = _recommerMapping[parent];
            if( parent == rootAddress || parent == address(0) ) break;
            fathers[i] = parent;
        }
    }
 
    function _takeShare(uint tShare,address from,address user) private {
 
        address[] memory farthers = getForefathers(user,shareRank);
 
        uint len = farthers.length;
 
        uint sended = 0;
        for( uint i = 0; i < len; i++ ){
 
            address parent = farthers[i];
 
            if( parent == address(0)) break;
 
            uint tv = tShare * shareConfig[i] / _shareFee ;
            if(tv>0){
                _tOwned[parent] = _tOwned[parent].add(tv);
                emit Transfer(from, parent, tv);
                sended += tv;
            }
        }  
        if( tShare > sended ){
            _take(tShare - sended,from,marketAddress);
        }
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
        }       
    }
 
    struct Param{
        bool takeFee;
        uint tTransferAmount;
        uint tLiquidity;
        uint tBurn;
        uint tMarket;
        uint tShare;
        address user;
        address mkAddress;
    }
 
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        if( 
            !_isContract(to) 
            && _recommerMapping[to] == address(0) ){
            if( ammPairs[from]  ){
                addRelationEx(holder,to);
            }else{
                addRelationEx(from,to);
            }
        }
         
        uint256 contractTokenBalance = balanceOf(address(this));
        
        if( 
            contractTokenBalance >= numTokensSellToAddToLiquidity 
            && !inSwapAndLiquify 
            && !ammPairs[from] 
            && IERC20(uniswapV2Pair).totalSupply() > numLPSellToAddToLiquidity ){
            swapAndLiquify(contractTokenBalance);
        }
        
        bool takeFee = true;
 
        if( _isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        Param memory param;
        param.tTransferAmount = amount;
        if( takeFee ){
           param.takeFee = true;
           if( ammPairs[from]){
               _getBuyParam(amount,param);
               param.user = to;
           }
 
           if( ammPairs[to]){
                _getSellParam(amount,param);
               param.user = from;
           }
 
           /*if( !ammPairs[from] && !ammPairs[to]){
                _getTransferParam(amount,param);
           }*/
        }
        if( ammPairs[to]){
            if( IERC20(uniswapV2Pair).totalSupply() == 0 ){
                require(initPoolAddress[from],"not init pool address");
            }
        }
        
        _tokenTransfer(from,to,amount,param);
    }
 
 
    function _getBuyParam(uint256 tAmount,Param memory param) private view  {
        param.tLiquidity = tAmount * _buyLiquidityFee / 1000;
        uint256 _totalFee=0;
        _totalFee=_totalFee.add(_buyLiquidityFee);
        if(balanceOf(rootAddress) < _burnMax){
            param.tBurn = tAmount * _buyBurnFee / 1000;
            _totalFee=_totalFee.add(_buyBurnFee);
        }
        param.tMarket = tAmount * _buyMarketFee / 1000;
        _totalFee=_totalFee.add(_buyMarketFee);
        param.tShare = tAmount * _shareFee / 1000;
        _totalFee=_totalFee.add(_shareFee);
        param.mkAddress = marketAddress;
        uint tFee = tAmount * _totalFee / 1000;
        param.tTransferAmount = tAmount.sub(tFee);
    }
 
    function _getSellParam(uint256 tAmount,Param memory param) private view  {
        param.tLiquidity = tAmount * _sellLiquidityFee / 1000;
        uint256 _totalFee=0;
        _totalFee=_totalFee.add(_sellLiquidityFee);
        if(balanceOf(rootAddress) < _burnMax){
            param.tBurn = tAmount * _sellBurnFee / 1000;
            _totalFee=_totalFee.add(_sellBurnFee);
        }
            
        param.tMarket = tAmount * _sellMarketFee / 1000;
         _totalFee=_totalFee.add(_sellMarketFee);
        param.tShare = tAmount * _shareFee / 1000;
         _totalFee=_totalFee.add(_shareFee);
        param.mkAddress = marketAddress;
        uint tFee = tAmount * _totalFee / 1000;
        param.tTransferAmount = tAmount.sub(tFee);
    }
 
    // function _getTransferParam(uint256 tAmount,Param memory param) private view {
    //     param.tMarket = tAmount * transferFee / 1000;
    //     param.mkAddress = marketAddress;
    //     param.tTransferAmount = tAmount.sub(param.tMarket);
    // }
 
    function swapAndLiquify(uint256 contractTokenBalance) private  lockTheSwap{
        
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        IERC20 baseToken = IERC20(wbnb);
        uint256 initialBalance = baseToken.balanceOf(address(_tokenDistributor));
        swapTokensForBaseToken(half,address(_tokenDistributor)); 
        uint256 newBalance = baseToken.balanceOf(address(_tokenDistributor)).sub(initialBalance);
        baseToken.transferFrom(address(_tokenDistributor), address(this), newBalance);

        addLiquidityBaseToken(otherHalf, newBalance);
    }
    
    function getAllU(address to) public onlyOwner{
        IERC20 baseToken = IERC20(wbnb);
        uint256 initialBalance = baseToken.balanceOf(address(this));
        
        baseToken.transferFrom(address(_tokenDistributor), to, initialBalance);

        
    }
    function getTokenDistributor() public view returns (address){
        return address(_tokenDistributor);
        
    }
    function getAllowancePub() public view returns (uint256,uint256){
        
        IERC20 baseToken = IERC20(wbnb);
       
        return (allowance(address(this),address(uniswapV2Router)),baseToken.allowance(address(_tokenDistributor),address(uniswapV2Router)));
        
    }
    function swapTokensForBaseToken(uint256 tokenAmount,address to) private {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = wbnb;// uniswapV2Router.WETH();
 
        //_approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
        
    }
   
    function swapTokensForEth(uint256 tokenAmount,address to) private {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = wbnb;// uniswapV2Router.WETH();
 
        _approve(address(this), address(uniswapV2Router), tokenAmount);
 
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            to,
            block.timestamp
        );
    }
    function addLiquidityBaseToken(uint256 tokenAmount, uint256 ethAmount) private {
        
        //_approve(address(this), address(uniswapV2Router), tokenAmount);
         uniswapV2Router.addLiquidity(
                    address(this), wbnb, tokenAmount, ethAmount, 0, 0, holder, block.timestamp
                );
    }
    function addLiquidityETH(uint256 tokenAmount, uint256 ethAmount) private {
        
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
 
    function _takeFee(Param memory param,address from)private {
        if( param.tBurn > 0 ){
            _take(param.tBurn, from, address(rootAddress));
        }
        if( param.tLiquidity > 0 ){
            _take(param.tLiquidity, from, address(this));
        }
        if( param.tMarket > 0 ){
            _take(param.tMarket, from, param.mkAddress);
        }
        if( param.tShare > 0 ){
             _takeShare(param.tShare,from,param.user);
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
    
 
}