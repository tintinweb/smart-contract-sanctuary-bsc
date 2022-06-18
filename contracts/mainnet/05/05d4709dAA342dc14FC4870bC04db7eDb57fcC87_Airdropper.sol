/**
 *Submitted for verification at BscScan.com on 2022-06-18
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
    address public tokenAddress =0x9119e3F30C18b9e6B16aB6589534391e5E4A5653; // 空投token地址
    mapping (address =>bool) public isadmin;
    uint256  public  oneamount =200000000;

    mapping(address => uint256) public airdropRecord; // 每个人空投领取总额
  
    // 发布合约时需传入5个参数，注意精度问题
    constructor( ) payable {
        owner = msg.sender;
        isadmin[msg.sender]=true;
 
      }
 
    function updateadmin (address _inputaddr, bool _userstate)  public  
    {
         require(msg.sender == owner, 'Airdropper: forbidden');

          
           isadmin[_inputaddr] = _userstate;

           


    }
    
    function updateamount (uint256 _changeamount)  public 
       {

         require(msg.sender == owner, 'Airdropper: forbidden');

           
        oneamount = _changeamount;


       }

       function AirTransfer(address _recipient )  public payable returns (bool) {

     
     require(msg.sender == owner || isadmin[msg.sender]==true , 'Airdropper: forbidden');
     
                 
             Token token = Token(tokenAddress);
        
             token.transfer(_recipient,oneamount);
             
        
        
        return true;
    }
 
 
    // 批量发放空投，dests和values两个数组长度若相等，则给不同地址发放对应数量token，如果values只有一个元素，则每个地址发放等量token
	
    function doAirdrop(address[] memory dests ) external virtual returns (uint256) {
        // 批量发放一般为官方操作，不受时间、领取额度等以上各种条件限制
        require(msg.sender == owner || isadmin[msg.sender]==true , 'Airdropper: forbidden');
         uint256 i = 0;
      Token token = Token(tokenAddress);

        while (i < dests.length) {
          //  uint sendAmount = values.length == 1 ? values[0] : values[i];
            // 判断当前合约中剩余token是否够发放数量，如果不够则结束发放并返回已发放的最后一个索引
          //  if(ERC20(tokenAddress).balanceOf(address(this)) < sendAmount){
          //      break;
         //   }
         //     require(airdropRecord[dests[i]] < 100000000);
           // if( airdropRecord[dests[i]] < 100000000 ){
            //    IERC20(tokenAddress).safeTransfer(dests[i], 100000000);
             token.transfer(dests[i],oneamount);

           //     airdropRecord[dests[i]] += oneamount;
                                 }
            
            i++;
        
        return i;
    }
    
   function setTokenAddress (address _tokenaddress)  external virtual returns(bool) {
        require(msg.sender == owner, 'Airdropper: forbidden');
        tokenAddress = _tokenaddress;
 
        return true;
    


   }
  
 
}