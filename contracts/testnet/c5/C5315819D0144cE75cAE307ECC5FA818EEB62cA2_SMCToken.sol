/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

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
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

contract Ownable {
    address public _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract SMCToken is IERC20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  address public uniswapRouterV2Address = address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);  
  address private _usdtAddress = address(0x7F726133f526c9FC1a50725d87dF0483D76701de);  
  address private _gmcAddress =  address(0x47C80c13a7d0EADf73CD907Ae22e9f0E2c964bcE);
  address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);

  IUniswapV2Router02 public immutable uniswapV2Router;
  address public uniswapV2Pair;  
  IERC20 public pair;

  mapping(address => bool) _minter;
  bool private swapping;

  event Transfer2(address indexed from, address indexed to, uint256 value,bool add, bool del);
  event TransferSell(address indexed from, address indexed to,uint256 destroy,
    uint256 swap, uint256 send, uint256 value, bool add, bool del);
  event TransferDel(address indexed from, address indexed to,uint256 destroy,
    uint256 swap, uint256 send, uint256 value, bool add, bool del);

  event PairTest(uint256 bal,uint r);

  constructor() {
    _name = "SMC";
    _symbol = "SMC";
    _decimals = 18;
    _owner = msg.sender;
    _minter[_owner] = true;
    _mint(_owner, 100000000 * 10**uint256(_decimals));
      
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniswapRouterV2Address);
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _usdtAddress);    
    pair = IERC20(uniswapV2Pair);
    uniswapV2Router = _uniswapV2Router;
  }

  function setMinter(address account,bool state) external onlyOwner {
    _minter[account] = state;
  }

  function getOwner() external view returns (address) {
    return owner();
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    bool isAddLdx;
    bool isDelLdx;
    if(recipient == uniswapV2Pair){
        isAddLdx = _isAddLiquidityV1();
    }else if(sender == uniswapV2Pair){
        isDelLdx = _isDelLiquidityV1();
    }
    emit Transfer2(sender, recipient, amount, isAddLdx, isDelLdx);

    if (swapping || _minter[sender] || _minter[recipient]){
        _transferToken(sender,recipient,amount);
    }else if (recipient == uniswapV2Pair && !isAddLdx){ //only sell 
        uint _fee = amount.div(100).mul(5);  
        if (_totalSupply - _fee <= 100000 * 10**uint256(_decimals)){
            _fee = 0;
        }
        _transferToken(sender,_destroyAddress, _fee);       
        uint _swapAmount = amount.div(100).mul(3);
		_transferToken(sender,address(this), _swapAmount);
        swapping = true;
        _swapSMC2GMC();
        swapping = false;
        uint _sendAmount = amount.div(100).mul(2);
        _transferToken(sender,address(this), _sendAmount);
        uint _amount = amount.sub(_fee).sub(_swapAmount).sub(_sendAmount);
        _transferToken(sender,recipient, _amount);         
        //_transferToken(sender,recipient, amount.div(100).mul(90));        
        emit TransferSell(sender,recipient, _fee,_swapAmount,_sendAmount, 
            _amount, isAddLdx, isDelLdx); 
        _splitOtherToken();
    }else if (sender == uniswapV2Pair && isDelLdx){ //only delldx   
        uint _fee = amount.div(100).mul(5);  
        if (_totalSupply - _fee <= 100000 * 10**uint256(_decimals)){
            _fee = 0;
        }
        _transferToken(sender,_destroyAddress, _fee);       
        uint _swapAmount = amount.div(100).mul(3);
		_transferToken(sender,address(this), _swapAmount);
        swapping = true;
        _swapSMC2GMC();
        swapping = false;
        uint _sendAmount = amount.div(100).mul(2);
        _transferToken(sender,address(this), _sendAmount);
        //_transferToken(sender,recipient, amount.div(100).mul(90)); 
        uint _amount = amount.sub(_fee).sub(_swapAmount).sub(_sendAmount);
        _transferToken(sender,recipient, _amount); 
        emit TransferDel(sender,recipient, _fee,_swapAmount,_sendAmount, 
            _amount, isAddLdx, isDelLdx);  
        _splitOtherToken();    
    }else{
      _transferToken(sender,recipient,amount);
    }

    if(!havePush[recipient] && sender == uniswapV2Pair && !isAddLdx){
        havePush[recipient] = true;
        buyUser.push(recipient);
    }    
  }

  function _isAddLiquidityV1()internal view returns(bool ldxAdd){

    address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
    address token1 = IUniswapV2Pair(address(uniswapV2Pair)).token1();
    (uint r0,uint r1,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
    uint bal1 = IERC20(token1).balanceOf(address(uniswapV2Pair));
    uint bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));
    if( token0 == address(this) ){
        if( bal1 > r1){
            uint change1 = bal1 - r1;
            ldxAdd = change1 > 1000;
        }
    }else{
        if( bal0 > r0){
            uint change0 = bal0 - r0;
            ldxAdd = change0 > 1000;
        }
    }
  }

  function _isDelLiquidityV1() internal view returns(bool ldxDel){

    address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
    address token1 = IUniswapV2Pair(address(uniswapV2Pair)).token1();
    (uint r0,uint r1,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
    uint bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));
    uint bal1 = IERC20(token1).balanceOf(address(uniswapV2Pair));
    if( token0 == address(this) ){
        if( bal1 < r1){
            uint change1 = r1 - bal1;
            ldxDel = change1 > 1000;
        }
    }else{
        if( bal0 < r0){
            uint change0 = r0 - bal0;
            ldxDel = change0 > 1000;
        }
    }
  }

  function _transferToken(address sender, address recipient, uint256 amount) private {
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }  
  //sell SMC To GMC
  function _swapSMC2GMC() internal {
    uint256 allAmount = _balances[address(this)];
    address[] memory path = new address[](3);
    path[0] = address(this);
    path[1] = _usdtAddress;
    path[2] = _gmcAddress;

    _approve(address(this), uniswapRouterV2Address, allAmount);
    
    uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
        allAmount,
        0,
        path,
        _destroyAddress,
        block.timestamp
    );  
  }  

  address[] buyUser;
  mapping(address => bool) public havePush;
  uint256 public startIndex;
  function _splitOtherTokenSecond(uint256 sendAmount) private {
        uint256 buySize = buyUser.length;
        if(buySize>0){
            address user;
            uint256 totalAmount = pair.totalSupply();
            if(totalAmount>0){
                uint256 rate;
                if(buySize >10){
                    for(uint256 i=0;i<10;i++){
                        if(startIndex == buySize){
                            startIndex = 0;
                            break;
                        }
                        user = buyUser[startIndex];
                        rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
                        if(rate>0){
                            _transferToken(address(this),user,sendAmount.mul(rate).div(1000000));
                        }
                        startIndex += 1;
                    }
                }else{
                    for(uint256 i=0;i<buySize;i++){
                        user = buyUser[i];
                        rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
                        if(rate>0){
                            _transferToken(address(this),user,sendAmount.mul(rate).div(1000000));
                        }
                    }
                }
            }
            
        }
  }
		
  function _splitOtherToken() private {
    uint256 sendAmount = _balances[address(this)];
    if(sendAmount >= 10**18){
      _splitOtherTokenSecond(sendAmount);
    }
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");
    
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}