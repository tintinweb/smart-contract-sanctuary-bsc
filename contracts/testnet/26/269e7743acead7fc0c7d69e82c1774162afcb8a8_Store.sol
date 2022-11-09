/**
 *Submitted for verification at BscScan.com on 2022-11-09
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
        bytes32[] merchantGoods;  //用户发布的
    }
 
  
    struct Asset{
	    bytes32 orderID;      
        string name; // 资产名称
        string gbName; // 国标资产名称
        string assetType; // 资产类别
        string specifications; // 规格
        uint256 amount; //数量
        string unit; // 单位
        string value; // 资产价值
        string recorder; // 记录人
        uint8 status; // 资产状态, 0:全新 1:维修 2:报废
        uint256 insertTimestamp; // 记录时间 
        
    }

   mapping(bytes32 => Asset) Orders;           //所有列表
   mapping(bytes32 => address) orderToOwner;  //根据ID查找当前拥有者
   bytes32[] ordersID;        //所有
 
    mapping(address => Customer) customers;   //所有顾客 
    address[] customersAddr;  //所有顾客的地址 

    //约束条件——合约创建者
 	modifier onlyOwner() {
		require(
			owner == msg.sender,
			"权限错误!"
		);
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
 
  
		
    event CustomerAddOrder(address _customerAddr, bool isSuccess, string message);
    
    function customerAddOrde(address _customerAddr,string _name,string _gbName,string _assetType,string _specifications,uint256 _amount,string _unit,string _value,string _recorder,uint8 _status,uint256 _insertTimestamp) public {
        bytes32 id = stringToBytes32(_name);
        if(!isOrderExisted(id)) {
            Orders[id].orderID = id;
            Orders[id].name =_name;  
            Orders[id].gbName = _gbName;  
            Orders[id].assetType = _assetType; 
            Orders[id].specifications = _specifications;
            Orders[id].amount = _amount;
            Orders[id].unit = _unit;
            Orders[id].value = _value;
            Orders[id].recorder = _recorder;
            Orders[id].status = _status;
            Orders[id].insertTimestamp = _insertTimestamp;
            ordersID.push(id); 
            orderToOwner[id] = _customerAddr; 
            customers[_customerAddr].merchantGoods.push(id);
            emit CustomerAddOrder(_customerAddr, true, "添加成功");
            return;
        } else {
            emit CustomerAddOrder(_customerAddr, false, "资产名称已存在");
            return;
        }
    }
    
    //根据用户地址查询订单id
    function getAddrByid(address _customerAddr) public view returns(string){
       return getVal(customers[_customerAddr].merchantGoods[0]);
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

    //判断订单是否已存在
    function isOrderExisted(bytes32 _orderID) internal view returns (bool) {
        bool isExisted = false;
        for(uint i = 0; i < ordersID.length; i++) {
            if(ordersID[i] == _orderID) {
                return isExisted = true;
            }
        }
        return isExisted;
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
 

    // 获取余额
    function getBalance(address addr) constant public returns (uint) {
        return addr.balance;
    }
 

// 获取用户名
    function getCustomerUsername(address customer) constant public returns (string) {
        return bytes32ToString(customers[customer].username);
    }

    function getVal(bytes32 val) view public returns(string){
        return bytes32ToString(val);
    }

}