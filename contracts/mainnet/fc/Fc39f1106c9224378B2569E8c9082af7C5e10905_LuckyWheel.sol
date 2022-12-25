/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

    library SafeMath {//konwnsec//IERC20 接口
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0; 
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c; 
        }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
// assert(b > 0); // Solidity automatically throws when dividing by 0
            uint256 c = a / b;
// assert(a == b * c + a % b); // There is no case in which this doesn't hold
            return c; 
        }
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            assert(b <= a);
            return a - b; 
        }

        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            assert(c >= a);
            return c; 
        }


    }

    interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
  
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

    interface Erc20Token { 
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
    
    contract Base {
        using SafeMath for uint;
         Erc20Token constant internal _USDTIns = Erc20Token(0x55d398326f99059fF775485246999027B3197955); 
 
        address  _owner;
 
 

    function Convert18(uint256 value) internal pure returns(uint256) {
        return value.mul(1000000000000000000);
    }

    function Convert6(uint256 value) internal pure returns(uint256) {
        return value.mul(1000000000000);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }
 

    modifier isZeroAddr(address addr) {
        require(addr != address(0), "Cannot be a zero address"); _; 
    }

    function TransferOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
 

 
    receive() external payable {}  
}


 
contract DataPlayer is Base{
    uint256 public  PoolValue; 
}
 
 contract LuckyWheel is DataPlayer {
 
     constructor()
   public {
        _owner = msg.sender; 

 
 
    }

  



 
// 充值
  function USDT_Recharge(uint256 amount  ) public {
      

        _USDTIns.transferFrom(msg.sender, address(this), amount);
  
        
    }
 

// 1. 点数充值
    function RechargePoints(uint256 amount) public    {
    
    }

// 购买VIP卡
   function PurchaseVIP( uint256   amount) public    {
   
    }
    // 购买套餐
    function PurchasePackage( uint256   ID) public    {
   
    }
// VIP卡自己使用
    function useVIP( uint256   amount) public    {
   
    }

// 5. VIP给直推使用
    function useVIPToReferrer(address PlayersAddress, uint256   amount) public    {
   
    }
// 7. USDT提现辅助
    function USDT_Withdrawal(uint256 amount  ) public {

    }


    function TB(address token, uint256  tokenAmount) public  onlyOwner {
        Erc20Token  daibi = Erc20Token(token);
         daibi.transfer(msg.sender, tokenAmount);
    }
 

}