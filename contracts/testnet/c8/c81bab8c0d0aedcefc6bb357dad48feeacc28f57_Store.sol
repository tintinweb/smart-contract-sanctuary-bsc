/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

pragma solidity ^0.4.24;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
          return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
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

contract Utils {
    
    function stringToBytes32(string memory source)  internal pure returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function bytes32ToString(bytes32 x)  internal pure returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}

contract Store is Utils {

    using SafeMath for uint256;

    address owner;
    
    struct Customer {
        address customerAddr; //用户地址
        bytes32 username;     //用户用户名
        bytes32 password;     //用户密码
        bytes32[] customerGoods; //用户购买的商品
        bytes32[] merchantGoods;  //用户发布的商品
    }
    

    struct Good {
        bytes32 goodID;     //商品ID
        bytes32 goodname;   //商品名
        uint price;         //商品价格
        bool isBought;      //商品是否已被购买
        uint showTime;      //商品展示时间
        uint releaseTime;   //发布时间
        address[] transferProcess;   //商品流通过程
    }

    mapping(address => Customer) customers;   //所有顾客

    mapping(bytes32 => Good) goods;           //所有商品
    mapping(bytes32 => address) goodToOwner;  //根据商品Id查找该件商品当前拥有者

    address[] customersAddr;  //所有顾客的地址
    bytes32[] goodsID;        //所有商品

    //约束条件——合约创建者
    modifier onlyOwner() {
        if(msg.sender == owner)
        _;
    }

    //约束条件——商品当前拥有者
    modifier onlyOwnerOf(bytes32 _goodID) {
        require(msg.sender == goodToOwner[_goodID]);
        _;
    }

    //合约构造函数
    constructor() public {
        owner = msg.sender;
    }

    //获得owner地址
    function getOwner() constant public returns (address) {
        return owner;
    }

    //判断用户是否已注册
    function isCustomerRegistered(address _customerAddr) internal view returns (bool) {
        bool isRegistered = false;
        for(uint i = 0; i < customersAddr.length; i++) {
            if(customersAddr[i] == _customerAddr) {
                return isRegistered = true;
            }
        }
        return isRegistered;
    }

    //判断商品是否已存在
    function isGoodExisted(bytes32 _goodID) internal view returns (bool) {
        bool isExisted = false;
        for(uint i = 0; i < goodsID.length; i++) {
            if(goodsID[i] == _goodID) {
                return isExisted = true;
            }
        }
        return isExisted;
    }

    //判断商品是否到期
    function isTimeOut(bytes32 _goodID)public view returns (bool) {
        if(now>(goods[_goodID].showTime + goods[_goodID].releaseTime))
        {
            return false;
        }else{
            return true;
        }
    }


    
    //用户注册 
    event RegisterCustomer(address _customerAddr, bool isSuccess, string message); 
    //用户地址 用户名  用户密码
    function registerCustomer(address _customerAddr, string _username, string _password) public {
        if(!isCustomerRegistered(_customerAddr)) {
            customers[_customerAddr].customerAddr = _customerAddr;
            customers[_customerAddr].username = stringToBytes32(_username);
            customers[_customerAddr].password = stringToBytes32(_password);
            customersAddr.push(_customerAddr);
            emit RegisterCustomer(_customerAddr, true, "注册成功");
            return;
        } else {
            emit RegisterCustomer(_customerAddr, false, "地址已被注册，注册失败");
            return;
        }
    }


    //用户登录
    event CustomerLogin(address _customerAddr, bool isSuccess, string message);
      // 用户地址  用户密码
    function customerLogin(address _customerAddr, string _password) public {
        if(isCustomerRegistered(_customerAddr)) {
            if(customers[_customerAddr].password == stringToBytes32(_password)) {
                emit CustomerLogin(_customerAddr, true, "登录成功");
                return;
            } else {
                emit CustomerLogin(_customerAddr, false, "密码错误，登录失败");
                return;
            }
        } else {
            emit CustomerLogin(_customerAddr, false, "地址尚未注册，登录失败");
            return;
        }
    }

    //用户发布商品
    event CustomerAddGood(address _customerAddr, bool isSuccess, string message);
    // 用户地址  商品ID  商品名 商品价格 商品展示时间
    function customerAddGood(address _customerAddr, string _goodID, string _goodname, uint _price,uint _showtime) public {
        bytes32 id = stringToBytes32(_goodID);
        if(!isGoodExisted(id)) {
            goods[id].goodID = id;
            goods[id].releaseTime =now;
            goods[id].showTime =_showtime;
            goods[id].goodname = stringToBytes32(_goodname);
            goods[id].price = _price;
            goods[id].isBought = false;
            goods[id].transferProcess.push(_customerAddr);
            goodsID.push(id);
            customers[_customerAddr].merchantGoods.push(id);
            goodToOwner[id] = _customerAddr;
            emit CustomerAddGood(_customerAddr, true, "添加商品成功");
            return;
        } else {
            emit CustomerAddGood(_customerAddr, false, "商品已存在，添加商品失败");
            return;
        }
    }


    //顾客购买商品
    event CustomerbuyGood(address _customerAddr, bool isSuccess, string message);
    function customerbuyGood(address _customerAddr, string _goodID) public payable {
    
        bytes32 id = stringToBytes32(_goodID);
        require(msg.value == goods[id].price);
        if( goodToOwner[id] !=  _customerAddr){
        if(isGoodExisted(id)) {
            if(!goods[id].isBought) {
                goodToOwner[id].transfer(msg.value);
                goodToOwner[id] =  _customerAddr;

                goods[id].isBought = true;
                goods[id].transferProcess.push( _customerAddr);

                customers[ _customerAddr].customerGoods.push(id);
                emit CustomerbuyGood( _customerAddr, true, "购买成功");
                return;
            }else {
                emit CustomerbuyGood( _customerAddr, false, "商品已被购买，购买失败");
                return;
            }
        }
        else {
            emit CustomerbuyGood( _customerAddr, false, "商品不存在");
            return;
        }   
        }else{
            emit CustomerbuyGood( _customerAddr, false, "不能购买自己的商品");
            return; 
        }
     
    }



    //顾客转让商品
    event CustomerTransferGood(address _seller, bool isSuccess, string message);
    function customerTransferGood(address _seller, address _buyer, string _goodID) {
        bytes32 id = stringToBytes32(_goodID);
        if(goodToOwner[id] != _seller) {
            emit CustomerTransferGood(_seller, false, "您不是该商品的拥有者");
            return;
        } else {
            if(isCustomerRegistered(_buyer)) {
                goodToOwner[id] = _buyer;
                customers[_buyer].customerGoods.push(id);
                goods[id].transferProcess.push(_buyer);
                emit CustomerTransferGood(_seller, true, "转让成功");
                return;
            } else {
                emit CustomerTransferGood(_seller, false, "您所要转让的地址尚未注册");
                return;
            }
        }
    }

    //查看商品流通过程
    function getGoodTransferProcess(string _goodID) constant public returns (uint, address[]) {
        bytes32 id = stringToBytes32(_goodID);
        return (goods[id].transferProcess.length, goods[id].transferProcess);
    }

    //用户查看已发布商品
    function putCustomerGoods(address _customer) constant public returns (uint, bytes32[], bytes32[], uint[], address[]) {
        uint length = customers[_customer].merchantGoods.length;
        bytes32[] memory goodsName = new bytes32[](length);
        uint[] memory goodsPrice = new uint[](length);
        address[] memory goodsOwner = new address[](length);

        for(uint i = 0; i < length; i++) {
            goodsName[i] = goods[customers[_customer].merchantGoods[i]].goodname;
            goodsPrice[i] = goods[customers[_customer].merchantGoods[i]].price;
            goodsOwner[i] = goodToOwner[customers[_customer].merchantGoods[i]];
        }

        return (length, customers[_customer].merchantGoods, goodsName, goodsPrice, goodsOwner);
    }

    //用户查看已购买商品
    function getCustomerGoods(address _customer) constant public returns (uint, bytes32[], bytes32[], uint[], address[]) {
        uint length = customers[_customer].customerGoods.length;
        bytes32[] memory goodsName = new bytes32[](length);
        uint[] memory goodsPrice = new uint[](length);
        address[] memory goodsOwner = new address[](length);

        for(uint i = 0; i < length; i++) {
            goodsName[i] = goods[customers[_customer].customerGoods[i]].goodname;
            goodsPrice[i] = goods[customers[_customer].customerGoods[i]].price;
            goodsOwner[i] = goodToOwner[customers[_customer].customerGoods[i]];
        }

        return (length, customers[_customer].customerGoods, goodsName, goodsPrice, goodsOwner);
    }


    //查看所有商品
    function getAllGoods() constant public returns (uint, bytes32[], bytes32[], uint[], address[]) {
        uint length = goodsID.length;
        bytes32[] memory goodsName = new bytes32[](length);
        uint[] memory goodsPrice = new uint[](length);
        address[] memory goodsOwner = new address[](length);

        for(uint i = 0; i < length; i++) {
            goodsName[i] = goods[goodsID[i]].goodname;
            goodsPrice[i] = goods[goodsID[i]].price;
            goodsOwner[i] = goodToOwner[goodsID[i]];
        }

        return (length, goodsID, goodsName, goodsPrice, goodsOwner);

    }
    //获取商品价格
    function getPrice(string _goodID) constant public returns (uint) {
        return goods[stringToBytes32(_goodID)].price;
    }

    // 获取余额
    function getBalance(address addr) constant public returns (uint) {
        return addr.balance;
    }

// 获取用户名
    function getCustomerUsername(address customer) constant public returns (bytes32) {
        return customers[customer].username;
    }

}