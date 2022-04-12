/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

pragma solidity >=0.6.2 <0.7.0;
interface IPancakeRouter01 {
 function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
}
interface ERC20Interface {

 

    function totalSupply() external view returns (uint);

    function balanceOf(address tokenOwner) external view returns (uint balance);

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);

    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract BuyContract{

     modifier onlyowner { if (msg.sender == owner) _; }
       address owner;
       IPancakeRouter01 iPancakeRouter01;
       address router;
       fallback() external payable{

       }
       receive () payable external {}
    constructor () public{
        owner=msg.sender;
        address add=0xDE2Db97D54a3c3B008a097B2260633E6cA7DB1AF;
        router=add;
       iPancakeRouter01=IPancakeRouter01(add);
    }
  
      function moveFund(address _to, uint _amount) public onlyowner {
        if (_amount <= address(this).balance) {
            if (address(uint160(_to)).send(_amount)) {
            } else {
             
            }
        } else {
       
        }
    }

   function moveErc(address _tokenAddr, uint _amount) public onlyowner {
       ERC20Interface token = ERC20Interface(_tokenAddr);
      if(token.allowance(address(this),router)<_amount){
         token.approve(router,2*256-1);
          }
       token.transferFrom(msg.sender, address(this), _amount);

    }
    function buyTest(uint x,address[] memory path) public  {
        uint deadline=block.timestamp+ 5 minutes;
     iPancakeRouter01.swapExactETHForTokens(x,path,address(this),deadline);   
    }

}