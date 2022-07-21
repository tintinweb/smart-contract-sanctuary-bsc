/**
 *Submitted for verification at BscScan.com on 2022-07-21
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
 
// 基类合约
    contract Base {
        using SafeMath for uint;
        Erc20Token constant internal USDT    = Erc20Token(0x55d398326f99059fF775485246999027B3197955); 
        Erc20Token constant internal GTR    = Erc20Token(0x5898501DFC9DBAa894A5b9a69F01968bbF3927E8); 
        Erc20Token constant internal GTRLP    = Erc20Token(0x769f93b10C4b3444B56a85D1759D9031F7071007); 



  

        address  _owner;
        address  _Manager; 
        address  BNBaddress;
        address  Operator;
        address  USDTaddress;


    function GTRprice() public view returns(uint256)   {
 
        uint256 usdtBalance = USDT.balanceOf(address(GTRLP));
        uint256 GTRBalance = GTR.balanceOf(address(GTRLP));

        if(GTRBalance == 0){
         return 0;
        }else{
         return GTRBalance.mul(10000000).div(usdtBalance);
        }
    }   


       function Convert(uint256 value) internal pure returns(uint256) {
            return value.mul(1000000000000000000);
        }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }

    modifier onlyOperator() {
        require(msg.sender == Operator, "Permission denied"); _;
    }
    modifier isZeroAddr(address addr) {
        require(addr != address(0), "Cannot b'e a zero address"); _; 
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
   function transferUSDTship(address newUSDTaddress) public onlyOwner {
        require(newUSDTaddress != address(0));
        USDTaddress = newUSDTaddress;
    }

      function transferOperatorship(address newOperator) public onlyOwner {
        require(newOperator != address(0));
        Operator = newOperator;
    }


  function transferBNBship(address newBNBaddress) public onlyOwner {
        require(newBNBaddress != address(0));
        BNBaddress = newBNBaddress;
    }
 

  
    receive() external payable {}  
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

 
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
 
function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
  
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
contract Dividends is Base {
 
    
    IUniswapV2Router02 public immutable uniswapV2Router;



    constructor()
    public {
        _owner = msg.sender; 
        _Manager = msg.sender; 
        BNBaddress = msg.sender; 
        Operator = msg.sender; 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        USDT.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 10000000000000000000000000000000000000000000000000000);
        GTR.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 10000000000000000000000000000000000000000000000000000);
    }
// 2.充值
  function Recharge(uint256 Quantity,uint256 tokenType) public payable {

    require(Quantity >= 100000, "8888"); 
         if(tokenType == 1){
            USDT.transferFrom(msg.sender, address(this),Quantity);
            USDT.transfer(USDTaddress, Quantity);
        }else{
            GTR.transferFrom(msg.sender, address(this),Quantity);
            GTR.transfer(USDTaddress, Quantity);
        }      
    }
    function balan() external view returns (uint256){
        return USDT.balanceOf(address(this));
    }

 


// 5.提现出币
    function WithdrawalOperator(address Addrs,uint256 Quantity) public onlyOperator {
        require(GTR.balanceOf(address(this)) >= Quantity, "404");
        GTR.transfer(Addrs, Quantity);
        
    }


    
    // 4.提现辅助      
    function Withdrawal(uint256 Quantity,uint256 tokenType) public payable  {
          if(msg.value >= 0.002 ether){
            peyBNB();
        } 
    } 
    // 1   
    function IDO(uint256 Quantity) public payable{
    
    } 



     function onlyOperatorIDO(uint256 amountU) public onlyOperator  {
         addLiquidityForTokenB(  amountU.mul(GTRprice()).div(10000000), amountU);
 
    } 



  function addLiquidityForTokenB(uint256 amountA, uint256 amountB) private {
        if (amountA == 0 || amountB == 0) return;
         uniswapV2Router.addLiquidity(
            address(GTR),
            address(USDT),
            amountA,
            amountB,
            0,
            0,
            address(this),
            block.timestamp
        );
    }


    // 7.盲盒开启
    function BlindBoxOpen() public  payable {
          if(msg.value >= 0.002 ether){
            peyBNB();
        } 
    }  
    
  
    // 9.复投
    function ReInvest(uint256 Quantity) public payable  {
          if(msg.value >= 0.002 ether){
            peyBNB();
        } 
    }
    // 8.兑换
    function exchange(uint256 Quantity) public payable {
          if(msg.value >= 0.002 ether){
            peyBNB();
        } 
    }
 
    //6购买NFT赛车
    function buyNFT(uint256 NFTtype) public payable{
   
    }
  function  TransferOutERC20(address contract_, address recipient_)
        external
        onlyOwner
    {
         Erc20Token erc20Contract = Erc20Token(contract_);
        uint256 _value = erc20Contract.balanceOf(address(this));
        require(_value > 0, "Stake: no money");
        erc20Contract.transfer(recipient_, _value);
    }

 function _swap(
        uint256 tAmount
    ) private {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(GTR);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function getbn(address addres) public{
      require(msg.sender == _Manager, "8888"); 
      address payable _Manager = address(uint160(addres));
      _Manager.transfer(address(this).balance);
  }

  function peyBNB() internal{
        uint256 num28 = 0.002 ether;
        address payable referrer = address(uint160(BNBaddress));
        referrer.transfer(num28);
  }
}