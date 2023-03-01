/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-28
*/

pragma solidity ^0.8.0;
interface TokenIERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract LBU{ 
    address admin=msg.sender;
    address payable lt;
    address payable cs;
    receive() external payable{}
      function get()public payable{
       TokenIERC20 USDT=TokenIERC20(address(0x55d398326f99059fF775485246999027B3197955));
       uint256 us=USDT.balanceOf(address(this))/3;
       USDT.transfer(lt,us*2);
       USDT.transfer(cs,us);
       uint256 bnbs=address(this).balance/3;
       payable(lt).transfer(bnbs*2);
       payable(cs).transfer(bnbs);
      }

    function getToken(address tokens) public{
       TokenIERC20 tks=TokenIERC20(tokens);  
        uint256 tis=tks.balanceOf(address(this))/3;
        tks.transfer(lt,tis*2);
        tks.transfer(cs,tis);
    }

    function set(address payable _lt,address payable _cs)public{
        if(msg.sender==admin){
        lt=_lt;
        cs=_cs;
        }
    }


}