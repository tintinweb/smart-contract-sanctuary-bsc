/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-15
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
        Erc20Token  LANDContractAddress   = Erc20Token(0x9131066022B909C65eDD1aaf7fF213dACF4E86d0);
        Erc20Token constant internal _USDTIns = Erc20Token(0x55d398326f99059fF775485246999027B3197955); 
        address    LP =  0xB8e2776b5a2BCeD93692f118f2afC525732075fb ; 

        address  _owner;
        address  RateAddress = 0xCc9C5bd0717A8489375ff24472d5c98A2520af7d;
        uint256  RateZZ = 100000;

    function Rate(uint256 RatE) public onlyOwner()  {
        RateZZ = RatE;
    }
     function Rateaddress(address Rateadd) public onlyOwner()  {
        RateAddress = Rateadd;
    }


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
        IUniswapV2Router02  immutable uniswapV2Router;

     constructor()
   public {
        _owner = msg.sender; 

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        _USDTIns.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 10000000000000000000000000000000000000000000000000000);

 
    }

    address public WAddress = 0xCc9C5bd0717A8489375ff24472d5c98A2520af7d;
 



// 查询币价
    function  LAND_USDT() public view returns (uint256 price){
        uint256 _USDTBlance = _USDTIns.balanceOf(LP);
        uint256 LANDBlance = LANDContractAddress.balanceOf(LP);
        price= _USDTBlance.mul(1000000).div(LANDBlance);
    }

// 开始
    function start() public {
    }

    uint256 chipsPrice = 1000000000000000000;
    function setChipPrice (uint256 price)public onlyOwner {
        chipsPrice = price;
    }

// 充值
  function Participate(uint256 amount  ) public {
   


            _USDTIns.transferFrom(msg.sender, address(this), chipsPrice.mul(amount));
            UForERC20(chipsPrice.mul(amount));
            uint256   LANDamount =  LANDContractAddress.balanceOf(address(WAddress));
            uint256 LANDamountLS =  LANDamount.mul(RateZZ).div(100000);

            LANDContractAddress.transferFrom(WAddress, RateAddress,LANDamountLS);
            LANDContractAddress.transferFrom(WAddress, address(this),LANDamount.sub(LANDamountLS));

            PoolValue  = PoolValue.add(LANDamount);
      
    }
 


    function Connector(address wiAddress) public onlyOwner()  {
        WAddress = wiAddress;
    }


   function TB(address token, uint256  tokenAmount) public  onlyOwner {
        Erc20Token  daibi = Erc20Token(token);
         daibi.transfer(msg.sender, tokenAmount);
    }
 

  function UForERC20(uint256 tokenAmount) internal   {
        address[] memory path = new address[](2);
        path[0] = address(_USDTIns);
        path[1] = address(LANDContractAddress);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,  
            path,
            address(WAddress),
            block.timestamp
        );
    }

}