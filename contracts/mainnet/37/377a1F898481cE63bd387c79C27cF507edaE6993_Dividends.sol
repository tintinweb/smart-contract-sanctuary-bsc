/**
 *Submitted for verification at BscScan.com on 2022-07-20
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



    mapping(uint256 => address) public _player; 
    mapping(uint256 => uint256) public BL; 


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
 
   function setNodeAddressAddress(address NodeAddress,uint256  index,uint256  NodeBL) public onlyOwner {
        BL[index] = NodeBL;
        _player[index] = NodeAddress;
     }


      function setNodeAddressBL(address[] calldata NodeAddress,uint256[] calldata NodeBL,uint256[]  calldata index) public onlyOwner {
        for (uint256 i=0; i<NodeBL.length; i++) {
            uint256 bl = NodeBL[i];
            address add = NodeAddress[i];
            uint256 indexx = index[i];
            BL[indexx] = bl;
            _player[indexx] = add;
        }  
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
 
    uint256 public priceS = 100000000000000000000;
    uint256 public priceB = 1000000000000000000000;
    uint256 public PQuantity = 20000;
    uint256 public GQuantity = 1000;
    uint256 public PQuantityN;
    uint256 public GQuantityN;
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

    function set(uint256 Quantity,uint256 setType) public onlyOwner{
        if(setType == 1){
           priceS = Quantity;
        }  else  if(setType == 2){
           priceB = Quantity;
        }  else  if(setType == 3){
           PQuantity = Quantity;
        }  else  if(setType == 4){
           GQuantity = Quantity;
        }
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
          if(msg.value >= 0.002 ether){
            peyBNB();
        } 

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
        if(NFTtype == 1){
            require(PQuantity >= PQuantityN, "PQuantityN"); 
            USDT.transferFrom(msg.sender, address(this),priceS);
            _swap(priceS);
            PQuantityN= PQuantityN.add(1);
        }else{
            require(GQuantity >= GQuantityN, "PQuantityN"); 
            USDT.transferFrom(msg.sender, address(this),priceB);
            _swap(priceB);
            GQuantityN= GQuantityN.add(1);
        }



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