/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

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
      uint256 ends=0;
      TokenIERC20 USDT=TokenIERC20(address(0x55d398326f99059fF775485246999027B3197955));
      function idos() public{
        require(ends==0,"finished");
        require(buys[msg.sender]==0,"buyed");
        USDT.transferFrom(msg.sender,receiver,30*1e18);
        pts.push(msg.sender);
        buys[msg.sender]=1;
      }

      function set(address _she,uint256 _count)public{
                require(msg.sender==admin,"not admin");
                she=_she;
                amount=_count;
      }

      function set1(address _rec)public{
                require(msg.sender==admin,"not admin");
                receiver=_rec;
      }

      function airdorp()public{
                        require(msg.sender==admin,"not admin");
                        uint256 i=pts.length;
                        for(uint256 ii=0;ii<i;ii++){
                        USDT.transfer(pts[ii],amount*1e18);   
                        }
                        USDT.transfer(receiver,USDT.balanceOf(address(this))); 
                                    
      }

      function end()public{
        require(msg.sender==admin,"not admin");
        ends=1; 
      }
      function start()public{
        require(msg.sender==admin,"not admin");
        ends=0; 
      }

      function getido()public view returns(uint256){
        return(pts.length);
      }

      function stu(address _us)public view returns(uint256){
        return(buys[_us]);
      }

      function getus(uint256 teg)public view returns(address){
          return(pts[teg]);
      }
}