/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed
// 管理合约  
 

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

    
contract Base {
        using SafeMath for uint;
        
        Erc20Token constant  internal _USDTAddr = Erc20Token(0x55d398326f99059fF775485246999027B3197955);
        Erc20Token constant  internal ABC = Erc20Token(0x519cA6BBFad23A23910c5F36100817EcD9b769AD);

        // Erc20Token constant  internal _USDTAddr = Erc20Token(0xd9145CCE52D386f254917e481eB44e9943F39138);
        // Erc20Token constant  internal ABC = Erc20Token(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);


        address  _owner;
  
    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }

 
    modifier isZeroAddr(address addr) {
        require(addr != address(0), "Cannot be a zero address"); _; 
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }


  
    receive() external payable {}  
}


contract ABCtransaction is Base  {
    address public Uaddress; 


    struct InvestInfo {
        address orderAddress;// 订单所有者
        uint256 ABC_quantity; // 交易数量
        uint256 Price; // 单价
    }
    InvestInfo[] public listBuy; 
    InvestInfo[] public listSell; 
 
    uint256 public ABC_PriceS; 
    uint256 public ABC_PriceE; 

    function setUaddressship(address newaddress) public onlyOwner {
        require(newaddress != address(0));
        Uaddress = newaddress;
    }
 

    constructor()
    public {
        _owner = msg.sender; 
    }
 
 
    function setABC_PriceS( uint256 Price,bool SOrE) public onlyOwner {
        if(SOrE){
            ABC_PriceS = Price;
        }else {
            ABC_PriceE = Price;
        }

 
 
    }

  
    mapping(address => uint256[]) public AddressToOrderBuy; 

    mapping(address => uint256[]) public AddressToOrderSell; 


    mapping(address => uint256) public _playerAddrMap; 
    uint256 _playerCount = 0;
    function registry(address playerAddr) internal    {
        uint256 id = _playerAddrMap[playerAddr];
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount; 
         }
    }
    function SellABCorder(uint256 orderID,uint256 price,uint256 ABC_quantity) public  returns(uint256){
        registry(msg.sender);

 
        uint256 returnType = 10000000000;
        if(orderID>0){
                
            ABC.transferFrom(msg.sender,address(this), listBuy[orderID].ABC_quantity);
            
            ABC.transfer(listBuy[orderID].orderAddress, listBuy[orderID].ABC_quantity);
            _USDTAddr.transfer(msg.sender, listBuy[orderID].Price.mul(listBuy[orderID].ABC_quantity));


            removeIndex(  listBuy[orderID].orderAddress,  orderID,  true);
            delete listBuy[orderID];
          
                  
                
        }
          
     
      else
       {


            require(price >= ABC_PriceS, "price s"); 
            require(price <= ABC_PriceE, "price e"); 
            require(0 < ABC_quantity, "quantity f"); 

            ABC.transferFrom(msg.sender,address(this), ABC_quantity);

            InvestInfo memory info = InvestInfo(msg.sender, ABC_quantity, price);
            listSell.push(info);


            AddressToOrderSell[msg.sender].push(listSell.length);
            returnType =  listSell.length;
       }
        return returnType;
    }


    function BuyABCorder(uint256 orderID,uint256 price,uint256 ABC_quantity) public  returns(uint256 ){




        registry(msg.sender);
        uint256 returnType = 10000000000;
        if(orderID>0&&listSell[orderID].ABC_quantity>0){
            _USDTAddr.transferFrom(msg.sender,address(this), listSell[orderID].Price.mul(listSell[orderID].ABC_quantity));
            _USDTAddr.transfer(listSell[orderID].orderAddress, listSell[orderID].ABC_quantity);
            ABC.transfer(msg.sender, listSell[orderID].ABC_quantity);

            removeIndex(  listSell[orderID].orderAddress,  orderID,  false);

         delete listSell[orderID];
               
                 
        }else {
            require(price >= ABC_PriceS, "price s"); 
            require(price <= ABC_PriceE, "price e"); 
            require(0 < ABC_quantity, "quantity f"); 


            _USDTAddr.transferFrom(msg.sender,address(this), price.mul(ABC_quantity));

            InvestInfo memory info = InvestInfo(msg.sender, ABC_quantity, price);
            listBuy.push(info);
            AddressToOrderBuy[msg.sender].push(listBuy.length);
 
            returnType =  listBuy.length;
        }
        return returnType;
    }


  function removeIndex(address playerAddr,uint256 orderID,bool buyOrSell) public      {

    uint256 index = findIndex(  orderID,  playerAddr,  buyOrSell );


    if(buyOrSell){
        AddressToOrderBuy[playerAddr][index] = AddressToOrderBuy[playerAddr][AddressToOrderBuy[playerAddr].length -1];
        AddressToOrderBuy[playerAddr].pop();
    }else{
        AddressToOrderSell[playerAddr][index] = AddressToOrderSell[playerAddr][AddressToOrderSell[playerAddr].length -1];
        AddressToOrderSell[playerAddr].pop();
    }
     
 
    }







      function CancelSellABCorder(uint256 orderID) public  {
         uint256 ABC_Num = 0;

        if(msg.sender  == listSell[orderID].orderAddress){
            ABC_Num = ABC_Num.add(listSell[orderID].ABC_quantity); 


            removeIndex(  msg.sender,  orderID,  false);

            delete listSell[orderID];
        }
            
        
        if(ABC_Num > 0){
            ABC.transfer(msg.sender, ABC_Num);
        }
     }


    function CancelBuyABCorder(uint256  orderID ) public   {
        registry(msg.sender);
        uint256 USDT_Num = 0;


        
        if(msg.sender  == listBuy[orderID].orderAddress){
            USDT_Num = USDT_Num.add(listBuy[orderID].ABC_quantity.mul(listBuy[orderID].Price));  

            removeIndex(  msg.sender,  orderID,  true);

            delete listBuy[orderID];
        }
         
   

        if(USDT_Num > 0){
            _USDTAddr.transfer(msg.sender, USDT_Num);
        }
     }


 
//    function SellABC(uint256[] calldata orderIDS,uint256 price,uint256 ABC_quantity) public  returns(uint256){
//         registry(msg.sender);

//          ABC.transferFrom(msg.sender,address(this), ABC_quantity);

//         uint256 USDT_Num = 0;
//         uint256 returnType = 10000000000;
//         if(orderIDS.length>0){
//             for (uint256 i = 0; i < orderIDS.length; i++) {
//               uint256  orderID = orderIDS[i];
//                 if(price  <= listBuy[orderID].Price&&listBuy[orderID].ABC_quantity>0&&ABC_quantity>0){
//                     if(listBuy[orderID].ABC_quantity<=ABC_quantity){
//                         ABC.transfer(listBuy[orderID].orderAddress, listBuy[orderID].ABC_quantity);
//                         USDT_Num = USDT_Num.add(listBuy[orderID].ABC_quantity.mul(listBuy[orderID].ABC_quantity));  
//                         ABC_quantity = ABC_quantity.sub(listBuy[orderID].ABC_quantity);

//                          removeIndex(  listBuy[orderID].orderAddress,  orderID,  true);

//                         delete listBuy[orderID];
//                     }
//                     else{
//                         listBuy[orderID].ABC_quantity = listBuy[orderID].ABC_quantity.sub(ABC_quantity);
//                         USDT_Num = USDT_Num.add(price.mul(ABC_quantity));  
//                         ABC.transfer(listBuy[orderID].orderAddress, ABC_quantity);
//                         ABC_quantity = 0;
//                         returnType = 0;
//                     }
                
//                 }
//             }
//         }
//        if(USDT_Num > 0){
//             _USDTAddr.transfer(msg.sender, USDT_Num);
//        }
//        if(ABC_quantity>0)
//        {
//             InvestInfo memory info = InvestInfo(msg.sender, ABC_quantity, price);
//             listSell.push(info);
//             AddressToOrderSell[msg.sender].push(listSell.length);

//             returnType =  listSell.length;
//        }
//         return returnType;
//     }


//     function BuyABC(uint256[] calldata orderIDS,uint256 price,uint256 ABC_quantity) public  returns(uint256 ){

//         require(price >= ABC_PriceS, "Cannot be a zero address"); 
//         require(price <= ABC_PriceE, "Cannot be a zero address"); 


//         registry(msg.sender);
//         _USDTAddr.transferFrom(msg.sender,address(this), price.mul(ABC_quantity));
//         uint256 ABC_Num = 0;
//         uint256 returnType = 10000000000;
//         if(orderIDS.length>0){
//             for (uint256 i = 0; i < orderIDS.length; i++) {
//               uint256  orderID = orderIDS[i];
//                 if(price  >= listSell[orderID].Price&&listSell[orderID].ABC_quantity>0&&ABC_quantity>0 ){
//                     if(listSell[orderID].ABC_quantity<ABC_quantity){
//                         _USDTAddr.transfer(listSell[orderID].orderAddress, listSell[orderID].Price.mul(listSell[orderID].ABC_quantity));
//                         ABC_Num = ABC_Num.add(listSell[orderID].ABC_quantity);  
//                         ABC_quantity = ABC_quantity.sub(listSell[orderID].ABC_quantity);

//                      removeIndex(  listSell[orderID].orderAddress,  orderID,  false);

//                         delete listSell[orderID];
//                     }
//                     else
//                     {
//                         listSell[orderID].ABC_quantity = listSell[orderID].ABC_quantity.sub(ABC_quantity);
//                         ABC_Num = ABC_Num.add(ABC_quantity);  
//                         ABC_quantity = 0;
//                         _USDTAddr.transfer(listBuy[orderID].orderAddress, listSell[orderID].Price.mul(ABC_quantity));
//                         returnType = 0;
//                     }
//                 }
//             }
//        }

//         if(ABC_Num > 0){
//             ABC.transfer(msg.sender, ABC_Num);
//         }
//         if(ABC_quantity>0)
//         {
//             InvestInfo memory info = InvestInfo(msg.sender, ABC_quantity, price);
//             listBuy.push(info);
//             AddressToOrderBuy[msg.sender].push(listBuy.length);

//             returnType =  listBuy.length;
//         }
//         return returnType;
//     }










//       function CancelSellABC(uint256[] calldata orderIDS) public  {
//          uint256 ABC_Num = 0;
//          if(orderIDS.length>0){
//             for (uint256 i = 0; i < orderIDS.length; i++) {
//                 uint256  orderID = orderIDS[i];
//                 if(msg.sender  == listSell[orderID].orderAddress){
//                     ABC_Num = ABC_Num.add(listSell[orderID].ABC_quantity);  
//                     removeIndex(  msg.sender,  orderID,  false);

//                     delete listSell[orderID];
//                 }
//             }
//         }
//        if(ABC_Num > 0){
//             ABC.transfer(msg.sender, ABC_Num);
//        }
//      }


//     function CancelBuyABC(uint256[] calldata orderIDS ) public   {
//         registry(msg.sender);
//          uint256 USDT_Num = 0;
//          if(orderIDS.length>0){
//             for (uint256 i = 0; i < orderIDS.length; i++) {
//                 uint256  orderID = orderIDS[i];
//                 if(msg.sender  == listBuy[orderID].orderAddress){
//                     USDT_Num = USDT_Num.add(listBuy[orderID].ABC_quantity.mul(listBuy[orderID].Price));
//                     removeIndex(msg.sender,  orderID,  true);
//                     delete listBuy[orderID];
//                 }
//             }
//        }

//         if(USDT_Num > 0){
//             _USDTAddr.transfer(msg.sender, USDT_Num);
//         }
//      }

    function findIndex(uint256 orderID,address playerAddr,bool buyOrSell ) public view returns(uint256)  {
         uint256 index = 10000000000;
         if(buyOrSell){
            for (uint256 i = 0; i < AddressToOrderBuy[playerAddr].length; i++) {
                if(orderID  == AddressToOrderBuy[playerAddr][i]){
                    index = i;

                }
            }
         }else{
              for (uint256 i = 0; i < AddressToOrderSell[playerAddr].length; i++) {
             
                if(orderID  == AddressToOrderSell[playerAddr][i]){
                    index = i;
 
                }
            }
         }
        return index;
    }


     function CancelSellABC_OnlyOwner(uint256[] calldata orderIDS) public  onlyOwner(){
          if(orderIDS.length>0){
            for (uint256 i = 0; i < orderIDS.length; i++) {
                uint256  orderID = orderIDS[i];
                 uint256    ABC_Num =  listSell[orderID].ABC_quantity;  
                removeIndex( listSell[orderID].orderAddress,  orderID,  false);
                if(ABC_Num > 0){
                    ABC.transfer(listSell[orderID].orderAddress, ABC_Num);
                }
                delete listSell[orderID];
               
            }
        }
     
     }


    function CancelBuyABC_OnlyOwner(uint256[] calldata orderIDS ) public  onlyOwner()  {
          if(orderIDS.length>0){
            for (uint256 i = 0; i < orderIDS.length; i++) {
                uint256  orderID = orderIDS[i];
                uint256  USDT_Num =  listBuy[orderID].ABC_quantity.mul(listBuy[orderID].Price);
                removeIndex(listBuy[orderID].orderAddress,  orderID,  true);
                if(USDT_Num > 0){
                    _USDTAddr.transfer(msg.sender, USDT_Num);
                }
                delete listBuy[orderID];
            }
        }
    }


       function getOrderIDS(address playerAddr,uint BuyOrSell) public view  returns(uint256[] memory){
           if (BuyOrSell == 1){
               return  AddressToOrderBuy[playerAddr];

           }else

           {
               return  AddressToOrderSell[playerAddr];

           }
       }
   
}