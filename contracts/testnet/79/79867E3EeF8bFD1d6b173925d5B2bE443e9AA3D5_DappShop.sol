/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

pragma solidity 0.8.0;

contract DappShop{

    struct Product{
        uint256 id;
        string title;
        uint256 price;
        uint256 stock;
        string image;
        string description;

    }

    struct Order{
        uint256 id;
        address user;
        uint256 date;
        uint256 amount;
        string status;
        uint256[] productsID;
        uint256[] productsCount;
    }

    struct User{
        address wallet;
        string fullName;
        string email;
        string postAddress;
        uint256 totalPaid;
        uint256 totalOrders;
    }

    uint256 public productCount=1;
    uint256 orderCount=1;
    mapping(uint256=>Product) public Products;
    mapping(uint256=>Order) Orders;
    mapping(address=>uint256[]) UserOrders;
    mapping(address=>User) Users;

     address  payable public owner;
    
    event AddProdcutEvent(uint256 _id,string _title,address _address);
    event EditProdcutEvent(uint256 _id,string _title,address _address);
    event RemoveProdcutEvent(uint256 _id,address _address);
    event AddOrderEvent(uint256 _id,address _address,uint256 _amount);
    event EditOrderEvent(uint256 _id,string _status);

    constructor(){
        owner=payable(msg.sender);
    }

    modifier onlyAdmin(){
        require(msg.sender==owner,"access denied");
        _;
    }

    function addProduct(string memory _title,uint256 _price,uint256 _stock,string memory _image,string memory _description) public onlyAdmin{
        Products[productCount]=Product(
            productCount,
            _title,
            _price,
            _stock,
            _image,
            _description
        );
        emit AddProdcutEvent(productCount,_title,msg.sender);
        productCount++;
    }

    function editProduct(uint256 _id,string memory _title,uint256 _price,uint256 _stock,string memory _image,string memory _description) public onlyAdmin{
        Products[_id].title=_title;
        Products[_id].price=_price;
        Products[_id].stock=_stock;
        Products[_id].image=_image;
        Products[_id].description=_description;
        emit EditProdcutEvent(_id,_title,msg.sender);
    }

    function deleteProduct(uint256 _id) public onlyAdmin{
        delete Products[_id];
        emit RemoveProdcutEvent(_id,msg.sender);
    }

    function productList() public view returns (Product[] memory)
   {
      Product[] memory list=new Product[](productCount);
      for (uint256 i=1;i<productCount;i++){
          Product memory obj=Products[i];
          list[i-1]=obj;
      }
      return list;
   }

function addOrder(uint256[] memory _productsID,uint256[] memory _productsCount,string memory _fullName,string memory _email,string memory _postAddress) public payable{
    uint256 amount=0;
    for(uint256 i=0;i<_productsID.length;i++){
        require(Products[_productsID[i]].stock>=_productsCount[i],"out of stock");
        amount+=(Products[_productsID[i]].price*_productsCount[i]);

    }
    require(amount==msg.value);
    for(uint256 i=0;i<_productsID.length;i++){
        Products[_productsID[i]].stock-=_productsCount[i];
    }

    Orders[orderCount]=Order(
        orderCount,
        msg.sender,
        block.timestamp,
        amount,
        "waiting",
        _productsID,
        _productsCount
    );

    User memory user=Users[msg.sender];
    user.wallet=msg.sender;
    user.fullName=_fullName;
    user.email=_email;
    user.postAddress=_postAddress;
    user.totalOrders+=1;
    user.totalPaid+=amount;

    owner.transfer(msg.value);
    UserOrders[msg.sender].push(orderCount);

    emit AddOrderEvent(orderCount,msg.sender,amount);
    orderCount++;
}

function editOrderStatus(uint256 _id,string memory _status) public onlyAdmin{
    Orders[_id].status=_status;
    emit EditOrderEvent(_id,_status);
}

function orderDetails(uint256 _id) public view onlyAdmin returns(Order memory){
    return Orders[_id];
}

function myOrders() public view returns (Order[] memory){
    Order[] memory list=new Order[](UserOrders[msg.sender].length);

    for (uint256 i=0;i<UserOrders[msg.sender].length;i++){
        Order memory obj=Orders[UserOrders[msg.sender][i]];
        list[i]=obj;
    }
    return list;
}

function orderList()public onlyAdmin view returns(Order[] memory){
     Order[] memory list=new Order[](orderCount);
     for(uint256 i=1;i<orderCount;i++){
         Order memory obj=Orders[i];
        list[i]=obj;
     }
     return list;
}

}