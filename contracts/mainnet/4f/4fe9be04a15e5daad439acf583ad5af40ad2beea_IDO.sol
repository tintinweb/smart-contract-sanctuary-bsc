/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-28
*/

pragma solidity ^0.8.0;
interface TokenIERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract IDO{ 
      address admin=msg.sender;
      mapping(address=>uint256) buys;
      address[] pts;
      address receiver;
      address she;
      uint256 amount;
      TokenIERC20 USDT=TokenIERC20(address(0x55d398326f99059fF775485246999027B3197955));
      function idos() public{
        require(pts.length<100,"finished");
        require(buys[msg.sender]==0,"finished");
        USDT.transferFrom(msg.sender,receiver,30*1e18);
        pts.push(msg.sender);
        buys[msg.sender]==1;
      }

      function set(address _she,address _rec,uint256 _count)public{
                require(msg.sender==admin,"not admin");
                she=_she;
                receiver=_rec;
                amount=_count;
      }

      function end()public{
                        require(msg.sender==admin,"not admin");
                        uint256 i=pts.length;
                        for(uint256 ii=0;ii<i;ii++){
                        USDT.transfer(pts[ii],amount*1e18);   
                        }
                        USDT.transfer(receiver,USDT.balanceOf(address(this)));              
      }

      function getido()public view returns(uint256){
        return(pts.length);
      }
}