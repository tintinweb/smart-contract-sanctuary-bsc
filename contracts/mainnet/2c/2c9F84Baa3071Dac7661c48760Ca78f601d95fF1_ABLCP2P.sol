/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;


interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
//TODO
//set Owner
//set fee collector
//set price valuator

contract ABLCP2P{
    struct Order{
        string orderType;
        address  BaseToken;
        address quoteToken;
        uint256 baseAmount;
        uint256 quoteAmount;
    }
    uint256 public ordercounter;
    address public owner=0x774B716ee5176f7f4eE429F62F688e0AC2e6d504;
    address public ablc=0x557a09f2a257e7ea0C9EdD45F4ABc1F5Eca05dfF;
    address public  usdt=0x55d398326f99059fF775485246999027B3197955;
    // address[] quoteTokens=[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56,0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c];
    address public TAX_FEE_WALLET=0x774B716ee5176f7f4eE429F62F688e0AC2e6d504;
    mapping  (address=>Order) private Orders;
    Order[] public OrderBook;
    uint256 public UsdtPrice=40000000000000000;
    uint256 public BnbPrice=40000000000000000;
    uint256 public BusdPrice=40000000000000000;
    event OrderCreated(uint256  indexed id,string _orderType,
    address _tokenA,address _tokenB,
    uint256 _baseAmount,
    uint256 _quoteAmount,address OrderCreator);
    event OrderCancelled(uint256 indexed id,address person);
    event OrderExchanged(address indexed  buyer, address seller ,uint256 id , uint256 bamount,uint256 quoteAmout);
    constructor (){
        owner=msg.sender;
    }

//modifiers
    //only admin
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    //only makers
    modifier onlyExchangers() {
        Order memory userOrder=Orders[msg.sender];
        require(userOrder.quoteAmount>0 && userOrder.baseAmount>0, "NOt an Exchanger");
        _;
    }
    function CreateOrder(string memory  _orderType,
    address _tokenA,address _tokenB,
    uint256 _baseAmount,
    uint256 _quoteAmount)public payable {
        IERC20 tokenA=IERC20(_tokenA);
        require(_tokenA!=0x0000000000000000000000000000000000000000 &&  _tokenB!=0x0000000000000000000000000000000000000000,"Dead tokens");
        require(tokenA.balanceOf(msg.sender)>=_baseAmount,"Balance too Low for P2P");
        Order storage order = Orders[msg.sender];
        order.baseAmount=_baseAmount;
        order.quoteAmount=_quoteAmount;
        order.BaseToken=_tokenA;
        order.quoteToken=_tokenB;
        order.orderType=_orderType;
        OrderBook.push(Order(_orderType,_tokenA,_tokenB,_baseAmount,_quoteAmount));
        tokenA.transferFrom(msg.sender, address(this), _baseAmount);
        emit OrderCreated(OrderBook.length, _orderType,_tokenA, _tokenB,_baseAmount,_quoteAmount,msg.sender);
    }
    function cancelOrder(uint256 id)public onlyExchangers{
        Order storage order = Orders[msg.sender];
        IERC20 tokenA=IERC20(order.BaseToken);
        tokenA.transfer(msg.sender, order.baseAmount);
        order.baseAmount=0;
        order.quoteAmount=0;
        order.BaseToken=0x0000000000000000000000000000000000000000;
        order.quoteToken=0x0000000000000000000000000000000000000000;
        order.orderType="0";
        delete OrderBook[id];
        emit OrderCancelled(id,msg.sender);
    }
    function setTokenPriceUsdt(uint256 _newPrice)public onlyOwner returns(uint256){
        UsdtPrice=_newPrice;
        return _newPrice;
    }
    function setTokenPriceBnb(uint256 _newPrice)public onlyOwner returns(uint256){
        BnbPrice=_newPrice;
        return _newPrice;
    }
    function setTokenPriceBusd(uint256 _newPrice)public onlyOwner returns(uint256){
        BusdPrice=_newPrice;
        return _newPrice;
    }
    
    function Exchange(address _wallet,uint256 id)public{
        //get order
        Order storage order = Orders[_wallet];
        IERC20 tokenA=IERC20(order.BaseToken);
        IERC20 tokenB=IERC20(order.quoteToken);
        //transfer from msg.sender to this contract
        tokenB.transferFrom(msg.sender, address(this), order.quoteAmount);
        // transfer from contract to this ordermaker
        uint256 quoteAmount=order.quoteAmount;
        uint256 onePercent=quoteAmount/100;
        uint256 pointFivePercent=onePercent/2;
        uint256 pointZeroFivePercent=pointFivePercent/10;
        uint256 amountToRemit=quoteAmount-pointZeroFivePercent;
        tokenB.transfer(TAX_FEE_WALLET, pointZeroFivePercent);
        tokenB.transfer(_wallet, amountToRemit);

        //transfer from contract to msg.sender
        tokenA.transfer(msg.sender, order.baseAmount);
        //delete order
       
        order.BaseToken=0x0000000000000000000000000000000000000000;
        order.quoteToken=0x0000000000000000000000000000000000000000;
        order.orderType="0";
        delete OrderBook[id];
        emit OrderExchanged(msg.sender, _wallet, id, order.baseAmount,order.quoteAmount);
         order.baseAmount=0;
        order.quoteAmount=0;
    }
    function getAllOrders()public view returns ( Order[] memory ){
        //Item[] memory itemsarray= new Item[](itemsCount)
        uint256 OrderCount=0;
      uint orderIndex = 0;
      //get user address
      //loop through items mapping
      for(uint256 i=0;i<=OrderBook.length;i++){
            OrderCount++;
      }
        Order[] memory itemsarray= new Order[](OrderCount) ;
          for (uint i = 0; i <=OrderBook.length; i++) {
          uint currentId = i + 1;
          Order memory currentItem = OrderBook[currentId];
          itemsarray[orderIndex] = currentItem;
          orderIndex += 1;
      }
      //save user data in an array
      //return the array
      return itemsarray;
    }

    function transferOwnerShip(address _newOwner) public  onlyOwner{
        owner=_newOwner;
    }
}