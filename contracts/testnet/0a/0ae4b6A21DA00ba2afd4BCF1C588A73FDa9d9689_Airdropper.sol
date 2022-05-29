/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
 

interface Token {
  function balanceOf(address _owner) external  returns (uint256 );
  function transfer(address _to, uint256 _value) external ;
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

 
contract Airdropper {
  
    address private owner;
    address public tokenAddress; // 空投token地址
    mapping(address => uint256) public airdropRecord; // 每个人空投领取总额
    uint32 public decimals = 5;
       
     constructor( ) payable {
        owner = msg.sender;
       
      }
 
    function change_decimal(uint32 _changev)
    external
    returns (bool)
  {
    decimals = _changev;
    return true;
  }

 
 	
    function doAirdrop(address[] memory dests ) external virtual returns (uint256) {
        // 批量发放一般为官方操作，不受时间、领取额度等以上各种条件限制
        require(msg.sender == owner, 'Airdropper: forbidden');
         uint256 i = 0;
      Token token = Token(tokenAddress);

        while (i < dests.length) {
          //  uint sendAmount = values.length == 1 ? values[0] : values[i];
            // 判断当前合约中剩余token是否够发放数量，如果不够则结束发放并返回已发放的最后一个索引
          //  if(ERC20(tokenAddress).balanceOf(address(this)) < sendAmount){
          //      break;
         //   }
         //     require(airdropRecord[dests[i]] < 10**decial);
            if( airdropRecord[dests[i]] < 10** decimals ){
            //    IERC20(tokenAddress).safeTransfer(dests[i], 100000000);
             token.transfer(dests[i],10** decimals);

                airdropRecord[dests[i]] += 10** decimals;
            }
            
            i++;
        }
        return i;
    }
    
    function  destrop ( ) external virtual returns(bool)

       {

      Token token = Token(tokenAddress);
       token.transfer(owner, token.balanceOf (address(this)));

       return true;

       }



   function setTokenAddress (address _tokenaddress)  external virtual returns(bool) {
        require(msg.sender == owner, 'Airdropper: forbidden');
        tokenAddress = _tokenaddress;
 
        return true;
    


   }
  
 
}