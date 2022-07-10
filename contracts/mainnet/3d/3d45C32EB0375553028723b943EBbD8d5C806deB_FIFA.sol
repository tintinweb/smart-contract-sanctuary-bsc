/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

 interface Erc20Token {//konwnsec//ERC20 接口
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }
    
   
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
    
// 基类合约
    contract Base {
                using SafeMath for uint;

        Erc20Token constant internal FIFALP    = Erc20Token(0xEDCAEa1D5038279351647553a06eaEe5e7Dd8766); 
        Erc20Token constant internal PTGBNBLP    = Erc20Token(0x07B5158ABd7904955bEa292faac5F0cD12C9EA10); 
        Erc20Token constant internal BNBUSDTLP    = Erc20Token(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE); 
        Erc20Token constant internal BNB    = Erc20Token(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); 

        Erc20Token public FIFA   = Erc20Token(0x9198b2a8FF1F86E48BFe10a0fc3e8C8D89aCfd59);
        Erc20Token public USDT   = Erc20Token(0x55d398326f99059fF775485246999027B3197955);
        Erc20Token public PTG   =  Erc20Token(0x77516E934cadF33Ceb7b96E6FC517a225D962C5e);
        address  _owner;
        address  owManager;
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
    modifier onlyowManager() {
        require(msg.sender == owManager, "Permission denied"); _;
    }
    

     function BNBprice() public view returns(uint256)   {
        uint256 usdtBalance = USDT.balanceOf(address(BNBUSDTLP));
        uint256 BNBBalance = BNB.balanceOf(address(BNBUSDTLP));

        if(BNBBalance == 0){
         return 0;
        }else{
            
         return usdtBalance.div(BNBBalance);
        }
    } 

  function PTGSprice() public view returns(uint256)   {
        uint256 PTGBalance = PTG.balanceOf(address(PTGBNBLP));
        uint256 BNBBalance = BNB.balanceOf(address(PTGBNBLP));
        if(BNBBalance == 0){
         return   0;
        }else{
         return  PTGBalance.mul(1000000).div(BNBBalance).div(BNBprice());
        }
    }

    function FIFASprice() public view returns(uint256)   {
        uint256 FIFABalance = FIFA.balanceOf(address(FIFALP));
        uint256 USDTBalance = USDT.balanceOf(address(FIFALP));
        if(USDTBalance == 0){
         return   0;
        }else{
         return  FIFABalance.mul(1000000).div(USDTBalance);
        }
    } 



    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function setSPS(address newSPS) public onlyOwner {
        require(newSPS != address(0));
        FIFA = Erc20Token(newSPS);
    }

    function transferowManagership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owManager = newOwner;
    }
    receive() external payable {}  
}
contract FIFA is Base {
     constructor()
   public {
        _owner = msg.sender; 
        owManager = msg.sender; 
     }
//   1.充值方法
    function Recharge(uint256 types,uint256 Quantity) public  {
       if(types == 1){
            FIFA.transferFrom(address(msg.sender), address(this), Quantity);
       }else if(types == 2){
            USDT.transferFrom(address(msg.sender), address(this), Quantity);
       }else if(types == 3){
            PTG.transferFrom(address(msg.sender), address(this), Quantity);
       }
     }

    //  提取辅助方法
   function TBSPS(uint256 types,uint256 SPSQuantity) public {
    }

// 3.提取出币方法
   function TXSPS(uint256 types,address playAddress,uint256 Quantity) public onlyowManager   {
        if(types == 1){
            FIFA.transfer(playAddress,Quantity);
        }else if(types == 2){
            USDT.transfer(playAddress,Quantity);
        }else if(types == 3){
            PTG.transfer(playAddress,Quantity);
        }
    }
// USDT 充值辅助
    function USDTRD(uint256 Quantity) public {
    }
    // 密码设置编辑方法
    function EditPassword(uint256 ID) public {

    }
    // 卡牌兑换
    function NFTexchangeSPS(uint256 ID) public {

    }


    // 3.提取出币方法
  function TBSPSOwner(uint256 types) public  onlyOwner   {
        if(types == 1){
            FIFA.transfer(msg.sender,FIFA.balanceOf(address(this)));
        }else if(types == 2){
            USDT.transfer(msg.sender,USDT.balanceOf(address(this)));
        }else if(types == 3){
            PTG.transfer(msg.sender,PTG.balanceOf(address(this)));
        }
    }

 
}