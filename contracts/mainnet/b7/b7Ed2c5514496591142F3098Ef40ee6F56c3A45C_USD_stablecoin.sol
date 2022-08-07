/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: USD stablecoin
 
pragma solidity ^0.5.5;
/*Math operations with safety checks */
contract SafeMath { 
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;  
    }
  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {  
    return a/b;  
    }
  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;  
    }
  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;  
    }  
  function safePower(uint a, uint b) internal pure returns (uint256) {
      uint256 c = a**b;
      return c;  
    }

  function sqrt(uint x) internal pure returns(uint) {
    uint z = (x + 1 ) / 2;
    uint y = x;
    while(z < y){
      y = z;
      z = ( x / z + z ) / 2;
    }
    return y;
  }
}

interface IToken {
  function transfer(address _to, uint256 _value) external;
  function transferFrom(address _from, address _to, uint256 _value) external  returns (bool success) ;
  function burn(uint256 _value) external returns (bool success);
  function balanceOf(address account) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function totalSupply() external view returns (uint256);
  function mint(address _to,uint256 _mintAmount) external;
  function limitSupply() external view returns (uint256);
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

    interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
    }

    interface ISwapAndCheck {
    function isIncludFromFee(address _account) external view returns (bool);
    function isIncludToFee(address _account) external view returns (bool);
    function addTokenBalanceSwapBrun(uint _add) external;
    function transferCheck(address _from) external;
    }

contract USD_stablecoin is SafeMath{
    string public name;    
    string public symbol;    
    uint8   public decimals;    
    uint256 public totalSupply;  
    address payable public owner;
    address payable public ownerTemp;
    uint256 blocknumberLastAcceptOwner;
    uint256 public liquidityFee = 8; //0.8%
    ISwapAndCheck  public iSwapAndCheck;
    uint256 public limitSupply;
       
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);  
    event Approval(address indexed owner, address indexed spender, uint256 value);  
    event SetOwner(address user);
    event AcceptOwner(address user);
    event ISwapAndCheckUpdate(address iSwapAndCheck);
    event LiquidityFeeUpdate(uint fee);
    event LimitSupplyUpdate(uint limit);
 
    constructor () public{
        totalSupply = 5 * 10**26;    // Update total supply
        name = 'USD stablecoin v1.0 produced by sha network';  // Set the name for display purposes
        symbol = 'USDs';        // Set the symbol for display purposes
        decimals = 18;          // Amount of decimals for display purposes
        owner = msg.sender;       
        balanceOf[address(this)] = totalSupply;
        limitSupply = 6 * 10**26;
    }
    
    function _transfer(address _from,address _to, uint256 _value) private  returns (bool success){/* Send coins */
        require (_value >= 0) ;                                                                 
        require (balanceOf[_from] >= _value) ;                                                          // Check if the sender has enough
        require (safeAdd(balanceOf[_to] , _value) >= balanceOf[_to]) ;                                  // Check for overflows
        if(address(iSwapAndCheck) != address(0x0))
            iSwapAndCheck.transferCheck(_from);
        balanceOf[_from] = safeSub(balanceOf[_from], _value);                                           // Subtract from the sender
        if (address(iSwapAndCheck) != address(0x0) && 
        (iSwapAndCheck.isIncludFromFee(_from) || iSwapAndCheck.isIncludToFee(_to) || _from == _to) && 
        (_from != address(this) && _to != address(this) && _from != address(iSwapAndCheck) && _to != address(iSwapAndCheck))) {
            balanceOf[_to] = safeAdd(balanceOf[_to], _value*(1000-liquidityFee)/1000);                      // Add  to the recipient
            balanceOf[address(iSwapAndCheck)] = safeAdd(balanceOf[address(iSwapAndCheck)], _value * liquidityFee / 1000);        // Add  to this
            iSwapAndCheck.addTokenBalanceSwapBrun(_value * liquidityFee / 1000);
            emit Transfer(_from, _to, _value*(1000-liquidityFee)/1000);                                     // Notify anyone listening that this transfer took place        
        }
        else{
            balanceOf[_to] = safeAdd(balanceOf[_to], _value);    // Add the same to the recipient
            emit Transfer(_from, _to, _value);                   // Notify anyone listening that this transfer took place
        }
        return true;
    }

    function transfer(address _to, uint256 _value) public  returns (bool success){/* Send coins */
       return _transfer(msg.sender,_to,_value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {/* Allow another contract to spend some tokens in your behalf */
        allowance[msg.sender][_spender] = _value;   
        emit Approval(msg.sender, _spender, _value);
        return true;    
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {/* A contract attempts to get the coins */
        allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);
        return _transfer(_from,_to,_value);
      }
   
    function _mint(address _to,uint256 _mintAmount) private returns (bool success) {
        require(limitSupply >= safeAdd(totalSupply ,_mintAmount),'limitSupply');
        require(_mintAmount>=0);
        balanceOf[_to] = safeAdd(balanceOf[_to],_mintAmount);
        totalSupply = safeAdd(totalSupply,_mintAmount);
        emit Transfer(address(0x0), _to, _mintAmount);
        return true;
    } 

    function mint(address _to,uint256 _mintAmount) public returns (bool success) {
        require(msg.sender == address(iSwapAndCheck));
        return _mint( _to, _mintAmount);
    } 

    function burn(uint256 _value) public returns (bool success) {
        _burn(msg.sender,_value);
        return true;
    } 

    function _burn(address _from,uint256 _value) private returns (bool success) {
        require (balanceOf[_from] >= _value) ;                           // Check if the sender has enough
        require (_value >= 0) ; 
        balanceOf[_from] = safeSub(balanceOf[_from], _value);            // Subtract from the sender
        totalSupply = safeSub(totalSupply,_value);                       // Updates totalSupply
        emit Burn(_from, _value);          
        emit Transfer(_from, address(0x0), _value);
        return true;
    } 

    function limitSupplyUpdate(uint _limit) public{
        require(msg.sender == owner);
        limitSupply = _limit;
        emit LimitSupplyUpdate(_limit);
        return ;
    }

    function setOwner(address payable _add) public{
        require (msg.sender == owner && _add != address(0x0)) ;
        ownerTemp = _add ;   
        blocknumberLastAcceptOwner = block.number + 201600;
        emit SetOwner(_add);
    }
    
    function acceptOwner()public{
        require (msg.sender == ownerTemp && block.number < blocknumberLastAcceptOwner && block.number > blocknumberLastAcceptOwner - 172800) ;
        owner = ownerTemp ;
        emit AcceptOwner(owner);
    }

    function iSwapAndCheckUpdate(address _iSwapAndCheck) public{
        require (msg.sender == owner && _iSwapAndCheck != address(0x0)) ;
        iSwapAndCheck = ISwapAndCheck(_iSwapAndCheck) ;
        emit ISwapAndCheckUpdate(_iSwapAndCheck);
    }  
    
    // can accept ether 
    function() external payable  {}
    
    // transfer token balance to address
    function transferOut(address _token,address payable _to, uint _amount) public{
      require(msg.sender == owner);
      if (_token == address(0x0)) 
        _to.transfer(_amount); 
      else 
        IToken(_token).transfer(_to, _amount);
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}