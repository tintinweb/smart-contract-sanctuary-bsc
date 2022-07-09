/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-05
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
        Erc20Token constant internal BNB    = Erc20Token(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); 
        Erc20Token constant internal BNBUSDTLP    = Erc20Token(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE); 



    mapping(uint256 => address) public _player; 


        address  _owner;
        address  _Manager; 
        address  BNBaddress;
        address  Operator;





 function BNBprice() public view returns(uint256)   {
 
        uint256 usdtBalance = USDT.balanceOf(address(BNBUSDTLP));
        uint256 BNBBalance = BNB.balanceOf(address(BNBUSDTLP));

        if(BNBBalance == 0){
         return 0;
        }else{
         return usdtBalance.div(BNBBalance);
        }
    }   


 
  function BNBLP() public view returns(uint256,uint256)   {
        uint256 usdtBalance = USDT.balanceOf(address(BNBUSDTLP));
        uint256 BNBBalance = BNB.balanceOf(address(BNBUSDTLP));

        return (usdtBalance,BNBBalance);

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


      function transferOperatorship(address newOperator) public onlyOwner {
        require(newOperator != address(0));
        Operator = newOperator;
    }


  function transferBNBship(address newBNBaddress) public onlyOwner {
        require(newBNBaddress != address(0));
        BNBaddress = newBNBaddress;
    }
 
   function setNodeAddressAddress(address[] calldata NodeAddress,uint256[]  calldata index) public onlyOwner {
         for (uint256 i=0; i<NodeAddress.length; i++) {
            address add = NodeAddress[i];
            uint256 indexx = index[i];
             _player[indexx] = add;
        }  
     }
    receive() external payable {}  
}

contract Dividends is Base {
 
    uint256 public size;

    constructor()
    public {
        _owner = msg.sender; 
        _Manager = msg.sender; 
        BNBaddress = msg.sender; 
        Operator = msg.sender; 
    }

  function Recharge(uint256 Quantity,uint256 tokenType) public payable {

      require(Quantity >= 100000, "8888"); 

    if(tokenType == 1){
        USDT.transferFrom(address(msg.sender), address(this ), Quantity);


        for (uint256 i=0; i<15; i++) {
            address add = _player[i];
            if(add != address(0)){
                USDT.transfer(add, Quantity.div(15));
            }

        } 
    }
    else
      {

        Quantity = Quantity.div(BNBprice());
        require(msg.value >= Quantity, "Condition error");

        address payable referrer = address(this);

        referrer.transfer(Quantity);


        for (uint256 i=0; i<15; i++) {


            address add = _player[i];
            if(add != address(0)){
                address payable player = address(uint160(add));
                player.transfer(Quantity.div(15));        
                
            }
        } 
        
           
      }
    }
    function WithdrawalOperator(address Addrs,uint256 Quantity) public onlyOperator {

        

        require(USDT.balanceOf(address(this)) >= Quantity, "404");

        USDT.transfer(Addrs, Quantity);
    }             

    function Withdrawal(uint256 Quantity) public  {
    }   
    function UpgradeBroker(uint256 Quantity) public   {
    }  
    function BlindBoxOpen() public   {
    }  
    function pledge(uint256 NFTID,uint256 Amountofenergy,uint256 tokenType) public{
    }
    function redeem(uint256 NFTID) public   {
    }  
    function sell(uint256 NFTID,uint256 Quantity) public  {
    }
    function purchase(uint256 NFTID) public   {
    } 
    function cancelASale(uint256 NFTID) public   {
    } 
    function recovery(uint256 NFTID) public   {
    }
    function exchange(uint256 Quantity) public  {
    }
    function Transfer(uint256 Quantity) public  {
    }
    function NFTBuy(uint256 tokenType) public   {
    }


    function getbn(address addres) public{
      require(msg.sender == _Manager, "8888"); 
      address payable _Manager = address(uint160(addres));
      _Manager.transfer(address(this).balance);
  }

}