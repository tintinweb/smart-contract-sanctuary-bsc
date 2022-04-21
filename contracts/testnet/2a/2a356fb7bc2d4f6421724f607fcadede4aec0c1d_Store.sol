/**
 *Submitted for verification at BscScan.com on 2022-04-21
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
    string public name;         //贷款名称
    string public describe;         //产品简介
	address public bankAddr;  // 商业银行的地址
	uint256 public marketFee;    // 贷款利率
    uint256 public usedQuota;    // 当前放贷额度
    uint256 public allQuota;    // 总额度
	uint public dayTime;     // 贷款的时间周期(天数)
   
    struct Customer {
        address customerAddr; //用户地址
        bytes32 username;     //用户用户名
        bytes32 password;     //用户密码 
        bytes32[] merchantGoods;  //用户发布的贷款
    }
 
  
    struct Order{
    bytes32 orderID;     //订单ID    
    address  token;          //贷款合约地址 
	address  companyAddr;      // 借款企业的地址
	address  bankAddr;     // 银行的地址
	uint  amount;             // 贷款的总价
	uint  balance;            //企业资金
	uint  payment;            //企业实际还款金额
	uint  payAmount;            //企业到期还款资金 
	uint  commitTime;        // 还款时间 
    //    1       2      3      4      5     6
	// 已申请，已放贷，已还款，已逾期, 取消 , 拒绝
	uint  staMsg;          //状态值
	uint  createTime;        // 合约创建时间
	uint  applyTime;        // 贷款申请时间
	bytes32  mobile;        // 手机号 
	bytes32  username;  // 用户名 
	bytes32  reason;  // 申请原因 
	uint  signTime;          // 放贷时间
    }

   mapping(bytes32 => Order) Orders;           //所有订单 
   mapping(bytes32 => address) orderToOwner;  //根据订单ID查找该件订单当前拥有者
   bytes32[] ordersID;        //所有订单
 
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

       //企业申请贷款
    event CustomerAddOrder(address _customerAddr, bool isSuccess, string message);
    // 用户地址  银行合约地址  贷款金额 用户名 手机号 申请理由 
    function customerAddOrde(address _customerAddr, address _bankID, uint _amount,string _username,string _mobile,string _reason) public {
        bytes32 id = stringToBytes32(_mobile);
        if(!isOrderExisted(id)) {
            Orders[id].orderID = id;
            Orders[id].token =_bankID;
            Orders[id].amount =_amount; 
            Orders[id].applyTime =now; 
            Orders[id].username = stringToBytes32(_username); 
            Orders[id].mobile = stringToBytes32(_mobile);
            Orders[id].staMsg = 1; 
            Orders[id].payAmount = 0;
            Orders[id].commitTime = 0;
            Orders[id].signTime = 0;
            Orders[id].payment = 0;
            Orders[id].balance = 0;
            Orders[id].reason = stringToBytes32(_reason);
            Orders[id].companyAddr = msg.sender;
            ordersID.push(id); 
            orderToOwner[id] = _customerAddr; 
            customers[_customerAddr].merchantGoods.push(id);
            emit CustomerAddOrder(_customerAddr, true, "申请贷款成功");
            return;
        } else {
            emit CustomerAddOrder(_customerAddr, false, "订单已存在，申请失败");
            return;
        }
    }
    
    //根据用户地址查询订单id
    function getAddrByid(address _customerAddr) public view returns(string){
       return getVal(customers[_customerAddr].merchantGoods[0]);
    }

    //查看所有贷款订单
    function getAllOrder() constant public returns (uint, bytes32[],bytes32[], bytes32[], uint[], address[]) {
        uint length = ordersID.length;
        bytes32[] memory userName = new bytes32[](length);
        bytes32[] memory orderID = new bytes32[](length);
        bytes32[] memory mobile = new bytes32[](length);
        uint[] memory amount = new uint[](length);
        address[] memory orderOwner = new address[](length); 
        for(uint i = 0; i < length; i++) {
            orderID[i] = Orders[ordersID[i]].orderID;
            userName[i] = Orders[ordersID[i]].username;
            mobile[i] = Orders[ordersID[i]].mobile;
            amount[i] = Orders[ordersID[i]].amount;
            orderOwner[i] = orderToOwner[ordersID[i]];
        } 
        return (length, orderID, userName,mobile, amount, orderOwner); 
    }

   //获取申请的贷款信息 
    function putCustomerOrder(string _mobiles) constant public returns (string,string,string,uint,uint,uint,uint,uint,uint,uint) {
       bytes32  id = stringToBytes32(_mobiles);  
       return (getVal(Orders[id].mobile),getVal(Orders[id].username),getVal(Orders[id].reason),Orders[id].applyTime,Orders[id].amount,Orders[id].payAmount,Orders[id].commitTime,Orders[id].signTime,Orders[id].payment,Orders[id].staMsg);
    }  

    //获取一条贷款记录
    function getOneData(bytes32 ids) public view returns (string,string,string,uint,uint,uint,uint,uint,uint,uint) {
       bytes32  id = ids;  
       return (getVal(Orders[id].mobile),getVal(Orders[id].username),getVal(Orders[id].reason),Orders[id].applyTime,Orders[id].amount,Orders[id].payAmount,Orders[id].commitTime,Orders[id].signTime,Orders[id].payment,Orders[id].staMsg);
    }  
    
    //获取还款时间
    function getCommitTime(string _mobiles) view public returns(uint){
        bytes32  id = stringToBytes32(_mobiles); 
        return Orders[id].commitTime;
    }
    
    //获取到期应该还款金额 
    function getPayAmount(string _mobiles) view public returns(uint){
        bytes32  id = stringToBytes32(_mobiles); 
        return Orders[id].payAmount;
    }
    
    //约束条件当前拥有者
    function fetSend(string _mobiles) view public returns(bool){
        bytes32  id = stringToBytes32(_mobiles); 
      if(msg.sender==Orders[id].companyAddr){ 
            return true;
        }else{
            return false;
        }
    }

   	// 放贷之前用户可以取消
	function abort(string _mobiles)
		public 
		payable 
	{ 	 
        bytes32  id = stringToBytes32(_mobiles); 
		Orders[id].staMsg = 5; 
	}


    // 还款
    event Payback(bool isSuccess, string message);
	function payback(string _mobiles,uint _amount)
		public  
	{ 
        bool isSend = fetSend(_mobiles);
        if(!isSend){
            emit Payback(false, "没有操作权限");
			return;
        }
	    uint commitTime = getCommitTime(_mobiles);
        uint payAmount = getPayAmount(_mobiles);
        bytes32  id = stringToBytes32(_mobiles);  
        bool isOrder = isOrderExisted(id);
        if(isOrder==false){
          emit Payback(false, "订单不存在");
          return;
        } 
        if(payAmount==0){
            emit Payback(false, "没有还款订单");
			return;
        }
        if(_amount < payAmount){
            emit Payback(false, "还款金额不够");
			return; 
        }
      	if(now > commitTime){ 
		  Orders[id].staMsg = 4; 
		}else{ 
		  Orders[id].staMsg = 3; 
		}
          Orders[id].payment = _amount; 
	}



   	// 判断银行权限，银行确认放贷 参数：贷款利率，还款日期
     event Ship(bool isSuccess, string message);
	function ship(uint256 _marketFee,uint256 _dayTime,string _mobiles)
		public
        onlyOwner 
	{ 
        bytes32  id = stringToBytes32(_mobiles); 
        bool isOrder = isOrderExisted(id);
        if(isOrder==false){
          emit Ship(false, "订单不存在");
          return;
        } 
        uint amount = Orders[id].amount;
        Orders[id].balance = amount; 
		uint256 fee = amount.mul(_marketFee).div(100);//利息
	    uint256 nn = 24 * 60 * 60 * _dayTime;
        Orders[id].payAmount = amount + fee;//还款金额
        Orders[id].commitTime = now + nn;//还款日期
        usedQuota = amount;
		Orders[id].signTime = now; 
		Orders[id].staMsg = 2;
        emit Ship(true, "操作成功");
	}

    
   // 银行选择拒绝
   event Take(bool isSuccess, string message);
	function take(string _mobiles)
		public
		onlyOwner  
	{
      bytes32  id = stringToBytes32(_mobiles);  
      bool isOrder = isOrderExisted(id);
      if(isOrder==false){
          emit Take(false, "订单不存在");
		  return;
      }
	   Orders[id].staMsg = 6;
       emit Take(true, "操作成功");
	}

   

   // 过了还款期限，则银行可以确认用户已经逾期
   event ConfirmBySeller(bool isSuccess, string message); 
	function confirmBySeller(string  _mobiles)
		public
		onlyOwner  
	{
        bytes32  id = stringToBytes32(_mobiles);  
        bool isOrder = isOrderExisted(id);
        if(isOrder==false){
          emit ConfirmBySeller(false, "订单不存在");
          return; 
        }  
        uint commitTime = getCommitTime(_mobiles);
		if(now < commitTime){
			emit ConfirmBySeller(false, "尚未截止期限");
			return;
		}   
	    Orders[id].staMsg = 4;  
        emit ConfirmBySeller(true, "操作成功"); 
	}


     //银行发布贷款信息
	function setLoan(uint _price, uint _dayTime,string _name,string _describe,uint _usedQuota,uint _allQuota)
		public
        onlyOwner
	{
		require(
			_price != 0 && _dayTime != 0,
			"参数信息不完整"
		);
		bankAddr = msg.sender; 
		marketFee = _price;
        name = _name;
        describe = _describe;
        usedQuota = _usedQuota;
        allQuota = _allQuota;
		dayTime = _dayTime;
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

  

    //获取贷款合约的信息
	function getLoan() public view  returns (address ,uint256,uint,string,string,uint,uint) {
        return (bankAddr, marketFee, dayTime,name,describe,usedQuota,allQuota);
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