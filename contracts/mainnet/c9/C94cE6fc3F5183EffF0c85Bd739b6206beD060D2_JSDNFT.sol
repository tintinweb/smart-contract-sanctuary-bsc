/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

pragma solidity >=0.6.0 <0.8.0;
 interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external view returns(uint256);
    function getTeam(address addr)external view returns(address);
    function approve(address spender, uint amount) external returns (bool);
}
interface IPancakeRouter01 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}
contract JSDNFT{
 uint public usdtSum;
 constructor()public{
     ERC20(0x55d398326f99059fF775485246999027B3197955).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E,2 ** 256 - 1);
     //ERC20(USDT).approve(pancakeRouter, 2 ** 256 - 1);
    }
 function getUser(address addr)public view returns(uint){
     uint a=ERC20(0x14d12eeAF52d80921Aebb9547B46026722F1AF6f).balanceOf(addr);
     if(a > 5 ether){
         return 5 ether;
     }else{
         return 0;
     }
 }
 function send()public{
     ERC20(0x55d398326f99059fF775485246999027B3197955).transferFrom(msg.sender,address(this),5 ether);
 }
  function Bridge()public{
        //博饼开盘后买币销毁
        address[] memory path = new address[](2);
        path[0]=0x55d398326f99059fF775485246999027B3197955;
        path[1]=0x738050710753DB53eF237CAa00074051363E42A8;
        IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E).swapExactTokensForTokens(5 ether,0,path,0x000000000000000000000000000000000000dEaD,block.timestamp + 360);
        usdtSum+=5 ether;
        send();
    }
 function BridgeUSDT(address addr,uint256 _value,uint B)public{

 }
}