/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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
     function _msgSender() internal view virtual returns (address) {
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

contract ABC is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping(address => bool) public whiteContract;
   
    uint8 private _decimals = 18;
    uint256 private _tTotal = 13000000 * 10**18;
	uint256 public _maxTxAmount =  13000000 * 10**18;
    string private _name = "ABCC";
    string private _symbol = "ABCC";


    uint256 public totalBuyFee = 20;
    uint256 public totalSellFee = 20;
    uint256 public transferFee = 0;
	
    bool public isContractSwitch;
    bool public isFee;
    bool public isExcludedEx;
    bool public isSell;
    bool public isBuy;


    IUniswapV2Router02 public immutable uniswapV2Router;
    address public  uniswapV2Pair;

    mapping(address => bool) public exPairs;
    
    bool inSwapAndLiquify;
    
    address public USDT = address(0x55d398326f99059fF775485246999027B3197955);    

    address public holder;

    address constant public burnAddress = address(0x000000000000000000000000000000000000dEaD);

	address [] public potentialLP;
	mapping(address => bool) public _updated;
	address[] public shareholders;
	mapping (address => uint256) public shareholderIndexes;
	
	address public marketContractAddress;
    address public liquidityContractAddress;

    mapping(address => bool) public black;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    struct FeeParam {
        bool takeFee;
        uint tTransferAmount;
        uint tLiquidity;
        uint tBurn;
        address user;
    }

    constructor () {
        
        holder = msg.sender;
        
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
         
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), USDT);
        
        uniswapV2Pair = _uniswapV2Pair;
        exPairs[uniswapV2Pair] = true;

        _isExcludedFromFee[holder] = true;
        _isExcludedFromFee[address(this)] = true;
		
		
		//_balances[holder] = _tTotal;
		_balances[0x1f27F9B04CfB159B0c858Dfdb3aFbcEc3e0C6E29] = _tTotal;
		_isExcludedFromFee[0xE993d3EfcAe3D8E39861bA361cF0b582bF77C745] = true;
        _isExcludedFromFee[0x58Ef4A084e1E7fEb1688EDc1E94344aE34B352b3] = true;
		marketContractAddress = 0xE993d3EfcAe3D8E39861bA361cF0b582bF77C745;
        liquidityContractAddress = 0x58Ef4A084e1E7fEb1688EDc1E94344aE34B352b3;

        _owner = msg.sender;

        emit Transfer(address(0), holder, _tTotal);
    }


    function setAmmPair(address pair,bool hasPair)external onlyOwner{
        exPairs[pair] = hasPair;
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
        return _balances[account];
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

    function setWhiteAddress(address addr_, bool com_) public onlyOwner {
        whiteContract[addr_] = com_;
    }

    function setBlack(address addr_, bool com_) public onlyOwner {
        black[addr_] = com_;
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

    function setisFee(bool fee) public onlyOwner {
        isFee = fee;
    }

    function setExcludedEx(bool fee) public onlyOwner {
        isExcludedEx = fee;
    }

    function setIsBuy(bool _isBuy) public onlyOwner {
        isBuy = _isBuy;
    }
	
	
	function setBuyFee(uint256 fee) external onlyOwner() {
        totalBuyFee = fee;
    }
	
	function setIsSell(bool _isSell) public onlyOwner {
        isSell = _isSell;
    }
	
	function setSellFee(uint256 fee) external onlyOwner() {
        totalSellFee = fee;
    }
	
	function setTransferFee(uint256 fee) external onlyOwner() {
        transferFee = fee;
    }
	
	function getShareholders() external view  returns (address[] memory) {
        return shareholders;
    }

    function getPairAddress() external view  returns (address) {
        return uniswapV2Pair;
    }
    
    receive() external payable {}

	function setShare() public {
        // require(msg.sender == divideAddress,"not divide address");
        for(uint i = 0; i< potentialLP.length; i++){
            _setShare(potentialLP[i]);
        }
    }
    
    function _setShare(address shareholder) private {
		if(_updated[shareholder] ){      
			if(IBEP20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
			return;  
		}
		if(IBEP20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
		addShareholder(shareholder);
		_updated[shareholder] = true;  
    }

	function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
      }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function _take(uint256 tValue,address from,address to) private {
        _balances[to] = _balances[to].add(tValue);
        emit Transfer(from, to, tValue);
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        require(_isExcludedFromFee[msg.sender], "not allowed");
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!black[from], "BEP20: contains black list address");
        require(!black[to], "BEP20: contains black list address");
		

        if (isContractSwitch && _isContract(from)) {
            require(whiteContract[msg.sender], "not allowed");
        }
		
		
		if(from != uniswapV2Pair ) {
            // _setShare(from);
            potentialLP.push(from);
        }
        if(to != uniswapV2Pair ) {
            // _setShare(to);
            potentialLP.push(to);
        }
		

        if(isExcludedEx){
            if (exPairs[from]) {
                require(_isExcludedFromFee[to],   "not trade");
            }
            if (exPairs[to]) {
                require(_isExcludedFromFee[from], "not trade");
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if( contractTokenBalance >= _maxTxAmount && !inSwapAndLiquify ){
            contractTokenBalance = _maxTxAmount;
            swapAndLiquify(contractTokenBalance);
        }
        
        bool takeFee = true;
        if( _isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        if(!isFee){
            takeFee = false;
        }

        FeeParam memory param;
        if(takeFee){
           param.takeFee = true;
           if(isFee && exPairs[from]){
               param.user = to;
               if(!_isExcludedFromFee[param.user]){
                   require(!isBuy, "forbid buying");
               }
               _getBuyParam(amount,param);
           }
           if(isFee && exPairs[to]){
               param.user = from;
               if(!_isExcludedFromFee[param.user]){
                   require(!isSell, "forbid selling");
               }
               _getSellParam(amount,param);            
           }

           if(isFee && !exPairs[from] && !exPairs[to]){
               param.user = from;
                _getTransferParam(amount,param);
           }
        } 
        if (param.tTransferAmount == 0) {
            param.tTransferAmount = amount;
        }

        _tokenTransfer(from,to,amount,param);
    }


    function _getBuyParam(uint256 tAmount,FeeParam memory param) private view  {
        uint tFee = tAmount * totalBuyFee / 1000;
		if(tFee> 0){
			param.tBurn = tFee.mul(13).div(20);
			param.tLiquidity = tFee.mul(7).div(20);
		}
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _getSellParam(uint256 tAmount,FeeParam memory param) private view  {
        uint tFee = tAmount * totalSellFee / 1000;
		if(tFee> 0){
			param.tBurn = tFee.mul(13).div(20);
			param.tLiquidity = tFee.mul(7).div(20);
		}
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _getTransferParam(uint256 tAmount,FeeParam memory param) private view {
		uint tFee = tAmount * transferFee / 1000;
		if(tFee> 0){
			param.tBurn = tFee.mul(13).div(20);
			param.tLiquidity = tFee.mul(7).div(20);
		}
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap{
        
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForUSDT(half,address(this)); 

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);
    }

    function swapTokensForUSDT(uint256 tokenAmount,address to) private {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            to,
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidity(
            address(this),
	        USDT,
            tokenAmount,
	        usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            holder,
            block.timestamp
        );
    }


    function _takeFee(FeeParam memory param,address from)private {
        if( param.tBurn > 0 ){
            _take(param.tBurn, from, marketContractAddress);
        }
        if( param.tLiquidity > 0 ){
            _take(param.tLiquidity, from, liquidityContractAddress);
        }
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount,FeeParam memory param) private {
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(param.tTransferAmount);
         emit Transfer(sender, recipient, param.tTransferAmount);
        if(param.takeFee){
            _takeFee(param,sender);
        }
    }

    function donateERC20(address addr, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateBNB(uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }

     function _isContract(address a) internal view returns(bool){
        uint256 size;
        assembly {size := extcodesize(a)}
        return size > 0;
    }
    

}