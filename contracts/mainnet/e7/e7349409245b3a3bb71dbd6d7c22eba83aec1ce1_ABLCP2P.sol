/**
 *Submitted for verification at BscScan.com on 2022-12-24
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

contract ABLCP2P{

    struct Order{
        string orderType;
        address  BaseToken;
        address quoteToken;
        uint256 baseAmount;
        uint256 quoteAmount;
    }
    uint256 public ordercounter;
    address public owner;

    mapping  (address=>Order) private Orders;
    Order[] public OrderBook;
    
    event OrderCreated(uint256  indexed id,string indexed _orderType,
    address _tokenA,address _tokenB,
    uint256 _baseAmount,
    uint256 _quoteAmount);
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
        emit OrderCreated(OrderBook.length, _orderType,_tokenA, _tokenB,_baseAmount,_quoteAmount);
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
    function Exchange(address _wallet,uint256 id)public{
        //get order
        Order storage order = Orders[_wallet];
        IERC20 tokenA=IERC20(order.BaseToken);
        IERC20 tokenB=IERC20(order.quoteToken);
        //transfer from msg.sender to this contract
        tokenB.transferFrom(msg.sender, address(this), order.quoteAmount);
        // transfer from contract to this ordermaker
        tokenB.transfer(_wallet, order.quoteAmount);
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
}