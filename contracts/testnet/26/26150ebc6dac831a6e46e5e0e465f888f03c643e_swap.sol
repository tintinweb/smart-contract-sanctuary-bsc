/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

pragma solidity ^0.8.0;
/*------------------------------------导入头------------------------------------*/
interface IERC20{
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint);
}

interface uniRouter{

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

    function swapETHForExactTokens(
      uint amountOut,
      address[] calldata path, 
      address to, 
      uint deadline
    )external payable returns (uint[] memory amounts);

    function swapExactETHForTokens(
      uint amountOutMin, 
      address[] calldata path, 
      address to, 
      uint deadline
    )external payable returns (uint[] memory amounts);

    function swapExactTokensForETH(
      uint amountIn, 
      uint amountOutMin, 
      address[] calldata path, 
      address to, 
      uint deadline
    )external returns (uint[] memory amounts);

    function getAmountsOut(
      uint amountIn,
      address[] memory path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
      uint amountOut,
      address[] memory path
    ) external view returns (uint[] memory amounts);

}

/*-----------------------------------------------------------------------------*/
contract swap{
    address public router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address public USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address public showAddress;
    address public showAddress1;
    uint256 public showAllowance;
    uint256 public showBalance;
    uint256 public ETHAmount;
    uint256 public contractAm = 0;
    uint256 public senderAm = 0;
    uint256 public userAm = 0;
    uint256 public swapOut = 0;
    uint256 public Out = 0;
    uint256 public usdtOut = 0;
    uint256 public In = 0;
    address public owner;
/*--------------------------向合约充值/查询/工具函数-----------------------------------*/
    constructor(){
       owner = msg.sender;
    }

    modifier onlyOwner(){
      require(msg.sender == owner);
      _;
    }

    function setOwner(address _newOwner)external onlyOwner{
      require(_newOwner!=address(0),"invailed address");
      owner = _newOwner;
    }

    //receive ether, msg.data must be empty
    receive() external payable {}

    //to help contract get weth(new account only has eth)
    function deposit()public payable{
        ETHAmount = msg.value;
        IERC20(WETH).deposit{value:ETHAmount}();
    }

    //approve contract balance for uni to use
    function approve(address _token, address _to, uint _value) external {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
       (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0x095ea7b3, _to, _value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    //send any token to contract (first approve)
    function sendToken(address _token, uint256 _amount) public returns(bool){
        return IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    }

    //get token from contract
    function getToken(address _token) public onlyOwner returns(bool){
        
        // transfer the token from address of this contract
        // to address of the user (executing the withdrawToken() function)
        uint amount = IERC20(_token).balanceOf(address(this));
        return IERC20(_token).transfer(msg.sender, amount);
    }

    //get ether from contract
    function getEther() public onlyOwner returns(bool){
        return payable(msg.sender).send(address(this).balance);
    }

    function searchContractEther()public view returns(uint){
       return address(this).balance;
    }

    //search for contract balance of any token
   function searchContractTokenAmount(address _token)public returns(uint256 balance){
        contractAm =  IERC20(_token).balanceOf(address(this));
        return contractAm;
    //return IERC20(_token).balanceOf(address(this));
    }

    //search for user balance of any token
    function searchUserTokenAmount(address _token,address _User)public returns(uint256 balance){
        userAm = IERC20(_token).balanceOf(_User);
        return userAm;
        //return IERC20(_token).balanceOf(_sender);
    }

    //search for sender balance of any token
    function searchSenderTokenAmount(address _token)public returns(uint256 balance){
        senderAm = IERC20(_token).balanceOf(msg.sender);
        return senderAm;
    }

    //search for allowance 
    function searchAllowance(address _token,address _holder,address _spender)public view returns(uint){
        return IERC20(_token).allowance(_holder,_spender);
    }

/*------------------------------------调用swap函数------------------------------------*/

    function testSwap(
    address _tokenIn,
    address _tokenOut,
    uint _amountIn,
    uint _amountOutMin,
    address _to
  ) external {

    IERC20(_tokenIn).approve(router, _amountIn);

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
    //actual amount out
    usdtOut = getAmountOutMin(WETH,USDT,_amountIn);
    //expect amount out
    swapOut = _amountOutMin;
    uint[] memory amounts1 = uniRouter(router).swapExactTokensForTokens(
      _amountIn,
      0,
      path,
      _to,
      block.timestamp
    );
    //need actual > expect
    require(usdtOut>swapOut,"unexpect values");
  }

    function _swapTokensForExactTokens(
      address _tokenIn,
      address _tokenOut,
      uint _amountOut,
      address _to
    ) external{

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

    //get amount need to send to contract and swap
    In = getAmountInMin(_tokenIn, _tokenOut, _amountOut);
    uint range = 2;
    In = In*range; 
    IERC20(_tokenIn).approve(router, In);
    IERC20(_tokenIn).transferFrom(msg.sender, address(this), In);
    
    uniRouter(router).swapTokensForExactTokens(
      _amountOut,
      In,
      path,
      _to,
      block.timestamp
    ); 

  }

  function _swapETHForExactTokens(
    address _tokenOut,
    uint _amountOut,
    address _to
  )external{
    
    address[] memory path;
    path = new address[](2);
    path[0] = WETH;
    path[1] = _tokenOut;

    //get amount need to send to contract and swap
    In = getAmountInMin(WETH, _tokenOut, _amountOut);
    uint range = 2;
    In = In*range; 
    IERC20(WETH).approve(router, In);
    IERC20(WETH).transferFrom(msg.sender, address(this), In);
    
    uniRouter(router).swapETHForExactTokens(
      _amountOut,
      path,
      _to,
      block.timestamp
    ); 
  }

  function _swapExactETHForTokens(
    address _tokenOut,
    uint _amountIn,
    address _to
  )external{

    IERC20(WETH).approve(router, _amountIn);
    IERC20(WETH).transferFrom(msg.sender, address(this), _amountIn);

    address[] memory path;

    path = new address[](2);
    path[0] = WETH;
    path[1] = _tokenOut;

    //actual amount out
    uint _amountOut = getAmountOutMin(WETH,_tokenOut,_amountIn);
    uniRouter(router).swapExactETHForTokens(
      _amountOut,
      path,
      _to,
      block.timestamp
    );
  }

  function _swapExactTokensForETH(
    address _tokenIn,
    uint _amountIn,
    address _to
  )external{

    IERC20(_tokenIn).approve(router, _amountIn);
    IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);

    address[] memory path;

    path = new address[](2);
    path[0] = WETH;
    path[1] = _tokenIn;

    //actual amount out
    uint _amountOut = getAmountOutMin(_tokenIn,WETH,_amountIn);
    uniRouter(router).swapExactTokensForETH(
      _amountIn,
      _amountOut,
      path,
      _to,
      block.timestamp
    );

  }

  function getAmountOutMin(
    address _tokenIn,
    address _tokenOut,
    uint _amountIn
  ) public view returns (uint) {
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

    // same length as path
    uint[] memory amountOutMins =
      uniRouter(router).getAmountsOut(_amountIn, path);

    return amountOutMins[path.length - 1];
  }

  function getAmountInMin(
    address _tokenIn,
    address _tokenOut,
    uint _amountOut
  )public view returns (uint) {
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
    uint[] memory amountInMins =
      uniRouter(router).getAmountsIn(_amountOut,path);

    return amountInMins[0];
  }
       
}