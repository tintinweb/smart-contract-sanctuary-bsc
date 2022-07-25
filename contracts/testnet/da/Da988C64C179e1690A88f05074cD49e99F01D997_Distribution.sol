/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

// SPDX-License-Identifier: LianZi
pragma solidity ^0.8.0;


library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

 
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

interface IBEP20 {
 
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}



// DeerToken with Governance.
contract Distribution {
  
    address public ownerFather;

    //初始化
    constructor()  {
        ownerFather = msg.sender;
    }

     //确认是不是合约部署者调用
    modifier onlyOwnerFather(){
        require(msg.sender==ownerFather,"not Owner");
        _;
    }

    
    //设置新的合约权限使用者
    function setOwnerFather(address _newOwner)external onlyOwnerFather{
        //防止合约权限锁死（不允许丢给0地址）
        require(_newOwner !=address(0),"invalid address");
        ownerFather=_newOwner;
    }

    
    //查询合约权限使用者
    function getOwnerFather()external view returns (address){
        return ownerFather;
    }


    //储存邀请关系
    mapping(address =>address ) private  addressRelation;
    //绑定邀请关系
    function setAddressRelation(address fatherAddress)public returns (bool){
        require(fatherAddress!=address(0),"father address not 0");
        require(fatherAddress!=msg.sender,"father address not is my address");
        require(addressRelation[fatherAddress]!=address(0),"father address not is regist");
        require(addressRelation[msg.sender]==address(0),"address existing");
        addressRelation[msg.sender]=fatherAddress;
        return true;
    }

    //查看父级地址（直推）
    function getAddressRelation(address _owner)public view  returns (address){
        return addressRelation[_owner];
    }

    //接收ETH主币
     receive() external payable {}

      function batch_transfer(address _token, address[] memory to, uint amount) public {
        IBEP20 token = IBEP20(_token);
        for (uint i = 0; i < to.length; i++) {
            require(token.transfer(to[i], amount), "error");
        }
    }

    function batch_transfer2(address _token, address[] memory to, uint[] memory amount) public {
        IBEP20 token = IBEP20(_token);
        for (uint i = 0; i < to.length; i++) {
            require(token.transfer(to[i], amount[i]), "error");
        }
    }




    

    

    

}