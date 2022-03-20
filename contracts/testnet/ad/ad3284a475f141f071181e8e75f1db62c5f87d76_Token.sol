/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

//import the ERC20 interface

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
  function swapExactTokensForTokens(
  
    //amount of tokens we are sending in
    uint256 amountIn,
    //the minimum amount of tokens we want out of the trade
    uint256 amountOutMin,
    //list of token addresses we are going to trade in.  this is necessary to calculate amounts
    address[] calldata path,
    //this is the address we are going to send the output tokens to
    address to,
    //the last time that the trade is valid for
    uint256 deadline
  ) external returns (uint256[] memory amounts);
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external returns (address);
}

contract Token {
 // All subsequent code will be inside this block
    string public name; // Holds the name of the token
    string public symbol; // Holds the symbol of the token
    uint8 public decimals; // Holds the decimal places of the token
    uint256 public totalSupply; // Holds the total suppy of the token
    address payable public owner; // Holds the owner of the token

    /* This creates a mapping with all balances */
    mapping (address => uint256) public balanceOf;
    /* This creates a mapping of accounts with allowances */
    mapping (address => mapping (address => uint256)) public allowance;

    /* This event is always fired on a successfull call of the
       transfer, transferFrom, mint, and burn methods */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /* This event is always fired on a successfull call of the approve method */
    event Approve(address indexed owner, address indexed spender, uint256 value);


   //address of the uniswap v2 router
    address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    // address private constant UNISWAP_V2_ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;  /// PancakeSwap
    
    //address of WETH token.  This is needed because some times it is better to trade through WETH.  
    //you might get a better price using WETH.  
    //example trading from token A to WETH then WETH to token B might result in a better price
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    

    //this swap function is used to trade from one token to another
    //the inputs are self explainatory
    //token in = the token address you want to trade out of
    //token out = the token address you want as the output of this trade
    //amount in = the amount of tokens you are sending in
    //amount out Min = the minimum amount of tokens you want out of the trade
    //to = the address you want the tokens to be sent to

  function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) external {
      
    //first we need to transfer the amount in tokens from the msg.sender to this contract
    //this contract will have the amount of in tokens
    IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    
    //next we need to allow the uniswapv2 router to spend the token we just sent to this contract
    //by calling IERC20 approve you allow the uniswap contract to spend the tokens in this contract 
    IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

    //path is an array of addresses.
    //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
    //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
    address[] memory path;
    if (_tokenIn == WETH || _tokenOut == WETH) {
      path = new address[](2);
      path[0] = _tokenIn;
      path[1] = _tokenOut;
    } else {
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = WETH;
      path[2] = _tokenOut;
    }
        //then we will call swapExactTokensForTokens
        //for the deadline we will pass in block.timestamp
        //the deadline is the latest time the trade is valid for
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
    }
    
       //this function will return the minimum amount from a swap
       //input the 3 parameters below and it will return the minimum amount out
       //this is needed for the swap function above
     function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) external view returns (uint256) {

       //path is an array of addresses.
       //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
       //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path;
        if (_tokenIn == WETH || _tokenOut == WETH) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WETH;
            path[2] = _tokenOut;
        }
        
        uint256[] memory amountOutMins = IUniswapV2Router(UNISWAP_V2_ROUTER).getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];  
    }  

    constructor() {
        name = "SomPaNoy2"; // Sets the name of the token, i.e Ether
        symbol = "SPN2"; // Sets the symbol of the token, i.e ETH
        decimals = 0; // Sets the number of decimal places
        // uint256 _initialSupply = 2000000000000 * 10 ** 2; // Holds an initial supply of coins
         uint256 _initialSupply = 2000000000000 * 10; // Holds an initial supply of coins

        /* Sets the owner of the token to whoever deployed it */
        owner = payable(msg.sender);

        balanceOf[owner] = _initialSupply; // Transfers all tokens to owner
        totalSupply = _initialSupply; // Sets the total supply of tokens

        /* Whenever tokens are created, burnt, or transfered,
            the Transfer event is fired */
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

     function transfer(address _to, uint256 _value) public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");

        balanceOf[msg.sender] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
      public returns (bool success) {
        uint256 senderBalance = balanceOf[_from];
        // uint256 senderBalance = balanceOf[msg.sender];
        uint256 fromAllowance = allowance[_from][msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");
        require(fromAllowance >= _value, "Not enough allowance");

        balanceOf[_from] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;
        allowance[_from][msg.sender] = fromAllowance - _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

  function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value > 0, "Value must be greater than 0");

        allowance[msg.sender][_spender] = _value;

        emit Approve(msg.sender, _spender, _value);
        return true;
    }

    function mint(uint256 _amount) public returns (bool success) {
        require(msg.sender == owner, "Operation unauthorised");

        totalSupply += _amount;
        balanceOf[msg.sender] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }

      function burn(uint256 _amount) public returns (bool success) {
      require(msg.sender != address(0), "Invalid burn recipient");

      uint256 accountBalance = balanceOf[msg.sender];
      require(accountBalance > _amount, "Burn amount exceeds balance");

      balanceOf[msg.sender] -= _amount;
      totalSupply -= _amount;

      emit Transfer(msg.sender, address(0), _amount);
      return true;
    }

}