/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;
/*------------------------------------导入头------------------------------------*/
interface IERC20{
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint);
    function deposit() external payable;
    function totalSupply()external view returns(uint256);
    function name()external view returns(string memory );
    function decimals()external view returns(uint8);
}

interface IPancakePair {
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
  function token0()external view returns(address);
  function token1()external view returns(address);
}

interface uniFactory{
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface uniRouter{

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
    ) external;

    function getAmountsOut(
        uint amountIn, 
        address[] calldata path) 
        external view returns (uint[] memory amounts);

}

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

library PancakeLibrary {
    using SafeMath for uint;
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            ))));
    }

//输入A,B返回A,B余额
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }
}

/*-----------------------------------------------------------------------------*/
contract test{
    address public constant router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public constant factory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
    address public constant wbnb = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address public owner;
    event getBalance(address myContract,uint balance);
    event getTransactionFee(uint fee);
    event debug(uint);
/*--------------------------向合约充值/查询/工具函数-----------------------------------*/
    constructor()public{
       owner = msg.sender;
    }

    receive()external payable{

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
    /*receive() external payable {}*/

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


    function getPair(address _tokenA,address _tokenB)public pure returns(address){
        return PancakeLibrary.pairFor(factory, _tokenA, _tokenB);
    }

    function searchTokenBalance(address _token,address _from)public view returns(uint){
        return IERC20(_token).balanceOf(_from);
    }

    function searchTokenInformation(address _token)public view returns(uint256 totalSupply,address pair,string memory name,uint8 decimals){
         totalSupply = IERC20(_token).totalSupply();
         pair = getPair(wbnb,_token);
         name = IERC20(_token).name();
         decimals = IERC20(_token).decimals();
    }

    function searchPairsTokens(address _pair)public view returns(address token0,address token1){
      token0 = IPancakePair(_pair).token0();
      token1 = IPancakePair(_pair).token1();
    }
/*------------------------------------调用swap函数------------------------------------*/

    function SswapExactTokensForTokens(
    address[] memory path,
    uint _amountIn,
    uint _amountOutMin,
    address _to
    ) public {

    uint allowance = IERC20(path[0]).allowance(address(this),router);

    if(allowance == 0){
        IERC20(path[0]).approve(router, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
    }

    IERC20(path[0]).transferFrom(msg.sender, address(this), _amountIn);

    uniRouter(router).swapExactTokensForTokens(
      _amountIn,
      _amountOutMin,
      path,
      _to,
      block.timestamp + 1000
      );
    }

  function SswapExactTokensForTokensSupportingFeeOnTransferTokens(
    address[] memory path,
    uint _amountIn,
    uint _amountOutMin,
    address _to
    ) public {
    uint allowance = IERC20(path[0]).allowance(address(this),router);

    if(allowance == 0){
        IERC20(path[0]).approve(router, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
    }

    IERC20(path[0]).transferFrom(msg.sender, address(this), _amountIn);

    uniRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
      _amountIn,
      _amountOutMin,
      path,
      _to,
      block.timestamp + 1000
      );

  }

    function StestBuyAndTransferToken(
    address[] memory path,
    uint _amountIn,
    uint _amountOutMin
  )public{

    uint pathEnd = path.length - 1;

    SswapExactTokensForTokens(path,_amountIn,_amountOutMin,address(this));

    uint balance = IERC20(path[pathEnd]).balanceOf(address(this));

    uint allowance = IERC20(path[pathEnd]).allowance(address(this),router);
    if(allowance == 0){
        IERC20(path[pathEnd]).approve(router, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
    }

    if(balance > 0){
      require(IERC20(path[pathEnd]).transfer(msg.sender, balance) == true,"cannot transfer token");
      require(false,"success");
    }
    else{
      require(false,"cannot buy the token");
    }

  }

  function StestBuyAndSellToken(
    address[] memory path,
    uint _amountIn,
    uint _amountOutMin,
    uint rate
  )external{
    uint i = 0; 
    uint pathEnd = path.length - 1;
    uint j = pathEnd;
    SswapExactTokensForTokens(path,_amountIn,_amountOutMin,address(this));
  
    uint balance = IERC20(path[pathEnd]).balanceOf(address(this));
    require(balance>0,"cannot buy the token");

    for(;i<path.length/2;){
        address temp = path[i];
        path[i] = path[j];
        path[j] = temp;
        i++;
        j--;
    }

    uint allowance = IERC20(path[0]).allowance(address(this),router);

    if(allowance == 0){
        IERC20(path[0]).approve(router, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
    }

    uint out = getAmountOutMin(path,balance*rate/100);
    
    uniRouter(router).swapExactTokensForTokens(
      balance*rate/100,
      out/10,
      path,
      msg.sender,
      block.timestamp + 1000
    );
    require(false,"success");
  }


 function StestBuyAndSellTokenForFee(
    address[] memory path,
    uint _amountIn,
    uint _amountOutMin,
    uint rate
  )external{

    uint i = 0; 
    uint pathEnd = path.length - 1;
    uint j = pathEnd;
    SswapExactTokensForTokensSupportingFeeOnTransferTokens(path,_amountIn,_amountOutMin,address(this));

    uint balance = IERC20(path[pathEnd]).balanceOf(address(this));
    uint startBalance = IERC20(path[0]).balanceOf(msg.sender);

    require(balance>0,"cannot buy the token");


    for(;i<path.length/2;){
        address temp = path[i];
        path[i] = path[j];
        path[j] = temp;
        i++;
        j--;
    }
    uint allowance = IERC20(path[0]).allowance(address(this),router);

    if(allowance == 0){
        IERC20(path[0]).approve(router, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
    }

    uint out = getAmountOutMin(path,balance*rate/100);

    uniRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
      balance*rate/100,
      out/10,
      path,
      msg.sender,
      block.timestamp + 1000
    );

    uint outAmount = IERC20(path[path.length-1]).balanceOf(msg.sender);
    uint fee = _amountIn-(outAmount-startBalance);
    uint feeRate = fee*100/_amountIn;
    
    if(feeRate==0){
      require(false,"no swap fee");
    }
    if(feeRate<10){
      require(false,"swap fee < 10%");
    }

    if(feeRate<20){
      require(false,"swap 10% <= fee < 20%");
    }

    if(feeRate<30){
      require(false,"swap 20% <= fee < 30%");
    }

    if(feeRate<40){
      require(false,"swap 30% <= fee < 40%");
    }

    if(feeRate<50){
      require(false,"swap 40% <= fee < 50%");
    }

    if(feeRate<60){
      require(false,"swap 50% <= fee < 60%");
    }

    if(feeRate<70){
      require(false,"swap 60% <= fee < 70%");
    }

    if(feeRate<80){
      require(false,"swap 70% <= fee < 80%");
    }

    if(feeRate<90){
      require(false,"swap 80% <= fee < 90%");
    }

    if(feeRate<100){
      require(false,"swap 90% <= fee < 100%");
    }

    if(feeRate==100){
      require(false,"cannot sell the token");
    }
  }

  function getAmountOutMin(
    address[] memory path,
    uint _amountIn
  ) public view returns (uint) {
    // same length as path
    uint[] memory amountOutMins =
      uniRouter(router).getAmountsOut(_amountIn, path);

    return amountOutMins[path.length - 1];
  }

   function StoSwapTokens(
        address  pair,
        uint _amountOutMin
    ) public payable{

      IERC20(wbnb).deposit{value:msg.value}();

      IERC20(wbnb).transfer(pair, msg.value);

      wbnb == IPancakePair(pair).token0()? IPancakePair(pair).swap(0,_amountOutMin,msg.sender,'') :IPancakePair(pair).swap(_amountOutMin,0,msg.sender,'');
      
    }    

    function QtoSellAll(address pair,uint balance ,uint amountOut)public {

         
         if(wbnb == IPancakePair(pair).token0()){
            uint allowance = IERC20(IPancakePair(pair).token1()).allowance(address(this),pair);

            if(allowance == 0){
                IERC20(IPancakePair(pair).token1()).approve(pair, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
            }
            //balance = IERC20(IPancakePair(pair).token1()).balanceOf(msg.sender);
            IERC20(IPancakePair(pair).token1()).transferFrom(msg.sender,pair, balance);
            IPancakePair(pair).swap(amountOut,0,msg.sender,'');
         }
         else{
            uint allowance = IERC20(IPancakePair(pair).token0()).allowance(address(this),pair);

            if(allowance == 0){
                IERC20(IPancakePair(pair).token0()).approve(pair, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
            }
            //balance = IERC20(IPancakePair(pair).token0()).balanceOf(msg.sender);
            IERC20(IPancakePair(pair).token0()).transferFrom(msg.sender,pair, balance);
            IPancakePair(pair).swap(0,amountOut,msg.sender,'');
         }
    }
     

    function StoSellAllBalanceForWbnb(address _token)public {
        uint balance = IERC20(_token).balanceOf(msg.sender);
        address pair = getPair(_token,wbnb);
        (uint reserveA,uint reserveB) = PancakeLibrary.getReserves(factory,_token,wbnb);
	    
		uint allowance = IERC20(_token).allowance(address(this),pair);

        if(allowance == 0){
          IERC20(_token).approve(pair, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
        }
        IERC20(_token).transferFrom(msg.sender,pair, balance);

        uint amountOut = PancakeLibrary.getAmountOut(balance,reserveA,reserveB);
        wbnb<_token? IPancakePair(pair).swap(amountOut,0,msg.sender,'') :IPancakePair(pair).swap(0,amountOut,msg.sender,'');
    }

    function SfeeToSellAllBalanceForWbnb(address _token)public{
        uint balance = IERC20(_token).balanceOf(msg.sender);
        address pair = getPair(_token,wbnb);

      	uint allowance = IERC20(_token).allowance(address(this),pair);

        if(allowance == 0){
          IERC20(_token).approve(pair, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
        }
        IERC20(_token).transferFrom(msg.sender,pair, balance);

        (uint reserveA,uint reserveB) = PancakeLibrary.getReserves(factory,_token,wbnb);
        balance = IERC20(_token).balanceOf(address(pair))-reserveA;

        uint amountOut = PancakeLibrary.getAmountOut(balance,reserveA,reserveB);
        wbnb<_token? IPancakePair(pair).swap(amountOut,0,msg.sender,'') :IPancakePair(pair).swap(0,amountOut,msg.sender,'');
    }

   function StoSwapExactTokensForTokens(
        address  _toBuy,
        uint _amountOutMin
    ) public payable{
      address pair = getPair(wbnb,_toBuy);
      (uint reserveA,uint reserveB) = PancakeLibrary.getReserves(factory,wbnb,_toBuy);

      IERC20(wbnb).deposit{value:msg.value}();

      IERC20(wbnb).transfer(pair, msg.value);

      uint amountOut = PancakeLibrary.getAmountOut(msg.value,reserveA,reserveB);

      require(amountOut>_amountOutMin,"output lower than expect");
      wbnb<_toBuy? IPancakePair(pair).swap(0,amountOut,msg.sender,'') :IPancakePair(pair).swap(amountOut,0,msg.sender,'');
      
    } 
       
}