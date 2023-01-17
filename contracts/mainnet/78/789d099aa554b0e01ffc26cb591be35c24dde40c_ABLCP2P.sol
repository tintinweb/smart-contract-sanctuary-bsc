/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

// File: contracts/BItBrick/P2P Trading.sol

/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/**
*@title Decentralized P2P Trading
*@author BitBrick Technology Pvt Ltd. 
*@dev This Contract wcan be used to Perform P2P Trading of ABLC Token,
*       With USDT, BUSD and BNB
*
*/

interface IERC20{
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
        address orderCreator;
        address  BaseToken;
        address quoteToken;
        uint256 baseAmount;
        uint256 quoteAmount;
    }

    uint256 public ordercounter;
    address public owner;
    address public ablc=0x557a09f2a257e7ea0C9EdD45F4ABc1F5Eca05dfF;
    //address public ablc=0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99;
    //address public  usdt=0xd2a5bC10698FD955D1Fe6cb468a17809A08fd005;

    address public  usdt=0x55d398326f99059fF775485246999027B3197955;
    address public  busd= 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 ;
    address public  bnb= 0x242a1fF6eE06f2131B7924Cacb74c7F9E3a5edc9;
    

    mapping(address=>Order) public Orders;
    Order[] public OrderBook;

    uint256 public UsdtPrice=1;
    uint256 public BnbPrice=1;
    uint256 public BusdPrice=1;

    event OrderCreated(
        uint256  indexed id,
        string _orderType,
        address _tokenA,
        address _tokenB,
        uint256 _baseAmount,
        uint256 _quoteAmount,
        address OrderCreator
        );

    event OrderCancelled(
        uint256 indexed id,
        address person
        );

    event OrderExchanged(
        address indexed  buyer,
        address seller,
        uint256 id,
        uint256 bamount,
        uint256 quoteAmout
        );

    fallback() external payable {
       // custom function code
    }

    receive() external payable {
        // custom function code
    }

    constructor (){
        owner=msg.sender;
    }

    

//modifiers
    //only admin
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }
    //only makers
    modifier onlyExchangers(){
        Order memory userOrder=Orders[msg.sender];
        require(userOrder.quoteAmount!=0 && userOrder.baseAmount!=0, "NOt an Exchanger");
        _;
    }

    function CreateOrder(
        string memory  _orderType,
        address _tokenB,
        uint256 _baseAmount,
        uint256 _quoteAmount
     )
        public
        payable
    {
        IERC20 tokenA=IERC20(ablc);
        require( _tokenB!=0x0000000000000000000000000000000000000000,"Dead tokens");
        require(tokenA.balanceOf(msg.sender)>=_baseAmount,"Balance too Low for P2P");
        Order storage order = Orders[msg.sender];
        order.baseAmount=_baseAmount;
        order.quoteAmount=_quoteAmount;
        order.BaseToken=ablc;
        order.quoteToken=_tokenB;
        order.orderType=_orderType;
        OrderBook.push(Order(_orderType, msg.sender, ablc, _tokenB, _baseAmount, _quoteAmount));
        tokenA.transferFrom(msg.sender, address(this), _baseAmount);
        emit OrderCreated(OrderBook.length, _orderType, ablc, _tokenB,_baseAmount,_quoteAmount,msg.sender);
    }

    function cancelOrder(uint256 id) public onlyExchangers{

        Order storage order = Orders[msg.sender];
        IERC20 tokenA=IERC20(order.BaseToken);
        tokenA.transfer(msg.sender, order.baseAmount);
        order.baseAmount=0;
        order.quoteAmount=0;
        order.BaseToken=0x0000000000000000000000000000000000000000;
        order.quoteToken=0x0000000000000000000000000000000000000000;
        order.orderType="0";
        order.orderCreator = 0x0000000000000000000000000000000000000000;
        delete OrderBook[id];
        emit OrderCancelled(id,msg.sender);
    }

    function setTokenPriceUsdt(uint256 _newPrice) public onlyOwner returns(uint256){

        UsdtPrice=_newPrice;
        return _newPrice;
    }

    function setTokenPriceBnb(uint256 _newPrice) public onlyOwner returns(uint256){

        BnbPrice=_newPrice;
        return _newPrice;
    }

    function setTokenPriceBusd(uint256 _newPrice) public onlyOwner returns(uint256){

        BusdPrice=_newPrice;
        return _newPrice;
    }

    /*
    *@dev This function is only for buyers. In this function, first of all, already present orders of seller will be checked,
    *     if not found then, contract will perform trading.
    *@param Adress of wallet, ID
    */
    
    function Exchange(
        address _quoteToken,
        uint256 _baseAmount
    )
        public
        payable
        returns(string memory)
    {
        //get order
        
        IERC20 tokenA = IERC20(ablc);
        IERC20 tokenB = IERC20(_quoteToken);
        uint256 quoteAmount;
        uint256 totalPrice;
        
       
        bool exchanged = false;

        for(uint i =0; i< OrderBook.length; i++ ){
            if((OrderBook[i].quoteToken == _quoteToken) &&
                (OrderBook[i].baseAmount >= _baseAmount))
            {
                Order storage order = Orders[OrderBook[i].orderCreator];
                quoteAmount = order.quoteAmount;
                totalPrice = quoteAmount * _baseAmount;
                require(IERC20(_quoteToken).balanceOf(msg.sender) >= totalPrice, "LOW Blnc");
                uint256 onePercent=totalPrice/100;
                uint256 pointFivePercent=onePercent/2;
                uint256 pointZeroFivePercent=pointFivePercent/10;
                uint256 amountToRemit=totalPrice-pointZeroFivePercent;
                //transfer from msg.sender to the seller
                //tokenB.transferFrom(msg.sender, OrderBook[i].orderCreator, order.quoteAmount);
                tokenB.approve(address(this), totalPrice);
                tokenB.transfer(owner, pointZeroFivePercent);
                tokenB.transfer( address(this), amountToRemit);
                tokenA.approve(address(this), _baseAmount);
                //transfer from contract to msg.sender
                tokenA.transfer(msg.sender, order.baseAmount);

                order.BaseToken=0x0000000000000000000000000000000000000000;
                order.quoteToken=0x0000000000000000000000000000000000000000;
                order.orderType="0";
                delete OrderBook[i];
                emit OrderExchanged(msg.sender, order.orderCreator, i, order.baseAmount, order.quoteAmount);
                order.baseAmount=0;
                order.quoteAmount=0;
                return("Exchangeeeeeeeeee Done");
                if(order.BaseToken == 0x0000000000000000000000000000000000000000)
                {exchanged = true;}
                break;
            }
            else{}
        }

        require(exchanged = false,"Exchange Done");
        if(_quoteToken == usdt)
        {
            quoteAmount = UsdtPrice;
            totalPrice = quoteAmount * _baseAmount;
        }
        else if (_quoteToken == busd)
        {
            quoteAmount = BusdPrice;
            totalPrice = quoteAmount * _baseAmount;
        }
        else
        {
            quoteAmount = BnbPrice;
            totalPrice = quoteAmount * _baseAmount;
        }

        require(IERC20(_quoteToken).balanceOf(msg.sender) >= totalPrice, "LOW Blnc");

        
        uint256 onePercent=totalPrice/100;
        uint256 pointFivePercent=onePercent/2;
        uint256 pointZeroFivePercent=pointFivePercent/10;
        uint256 amountToRemit=totalPrice-pointZeroFivePercent;
       
        //transfer from msg.sender to this contract
        tokenB.approve(address(this), totalPrice);
        tokenB.transfer(owner, pointZeroFivePercent);
        tokenB.transferFrom(msg.sender, address(this), totalPrice);
        tokenA.approve(address(this),_baseAmount);
        //transfer from contract to msg.sender
        tokenA.transfer(msg.sender, _baseAmount);
        //tokenA.transferFrom(address(this), msg.sender, _baseAmount);
        //delete order 
    }

    /*
    *@dev This function is only for owner of contract.
    *     
    */

    function withdraw(address _tokenToWithdraw) public onlyOwner{
        IERC20 token = IERC20(_tokenToWithdraw);
        token.transfer( msg.sender, token.balanceOf(address(this)));
    }

    function approve(address spender, uint256 amount) external onlyOwner {
        IERC20 tokenA = IERC20(ablc);
        tokenA.approve(spender, amount);
    }
    
    function getAllOrders() public view returns(Order[] memory ){

        //Item[] memory itemsarray= new Item[](itemsCount)
        uint256 OrderCount=0;
        uint orderIndex = 0;
        //get user address
        //loop through items mapping
        for(uint256 i=0;i<=OrderBook.length;i++)
        {
            OrderCount++;
        }
        Order[] memory itemsarray= new Order[](OrderCount) ;
        for (uint i = 0; i <=OrderBook.length; i++) 
        {
            uint currentId = i + 1;
            Order memory currentItem = OrderBook[currentId];
            itemsarray[orderIndex] = currentItem;
            orderIndex += 1;
        }
        //save user data in an array
        //return the array
        return itemsarray;
    }

    function transferOwnerShip(address _newOwner) public onlyOwner{
        owner=_newOwner;
    }

    function contractBalance() public view returns(uint256){
        return address(this).balance;
    }

}