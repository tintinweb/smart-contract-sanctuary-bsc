/**
 *Submitted for verification at BscScan.com on 2022-03-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
contract zodiacBuyLog{
    //idmapping代表地址与id映射到了一起，namemapping代表id与名字的字符串映射到了一起
    address private author;
    uint256[3][] log;
    mapping(address => mapping(uint256=>uint256[])) internal allowed;
    constructor() {
        author = msg.sender;
    }

    //修改所有者
    function updateAdmin(address sender)  public returns (bool) {
        require(msg.sender == author, "error: update address not owner");
        author = sender;
        return true;
    }

    //获取作者
    function getAdmin()  public view returns (address) {
        return author;
    }

    function trade(address _spender, uint256  buyType,uint256 index,uint256 buyTime,uint256 amount) public returns (bool) {
        
        // string[] memory user_val = allowed[_spender] ;
        // user_val[index] =(_value);
        // allowed[_spender] = user_val; 
        _trade(msg.sender,_spender,buyType,index,buyTime,amount);
        return true;
  }     

  function _trade(address sender,address _spender, uint256  buyType,uint256 index,uint256 buyTime,uint256 amount) internal{
        require(sender == author, "error: update address not owner");
        uint256[] memory  user_val = new uint256[](3) ;
        user_val[0]=buyType;
        user_val[1]=buyTime;
        user_val[2]=amount;
        allowed[_spender][index]=user_val;
  }


    function getOneList(address _spender,uint256 index) public view returns (uint256[] memory){
        uint256[] memory  user_val = new uint256[](3) ;
        // user_val[0]=allowed[_spender][index][0];
        // user_val[1]=allowed[_spender][index][1];
        // user_val[2]=allowed[_spender][index][2]; 
        user_val =allowed[_spender][index]; 
        return user_val;    
    }       


    function getTradeList(address account,uint256 index) public view returns (uint256[3][] memory){
        uint256[3][] memory user_courses_list =new uint256[3][](0);
        uint256 i=0;    
        for(i=0;i<index;i++){
            user_courses_list[i][0]=allowed[account][i][0];
            user_courses_list[i][1]=allowed[account][i][0];
            user_courses_list[i][2]=allowed[account][i][0];
        }
        return user_courses_list;
    }   


}