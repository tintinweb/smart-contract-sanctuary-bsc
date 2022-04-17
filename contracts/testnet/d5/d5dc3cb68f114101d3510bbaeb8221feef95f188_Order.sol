/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

pragma solidity^0.4.22;

// 借款合约
contract Order {
	// 已申请，已放贷，已还款，已逾期, 取消 , 拒绝
	enum Status {
		Apply,Lending, Repayment, Overdue, Cancel,Refuse
	}
    address public token;          //贷款合约地址 
	address public companyAddr;      // 借款企业的地址
	address public bankAddr;     // 银行的地址
	uint public amount;             // 贷款的总价
	uint public commitTime;        // 还款时间
	Status public status;          // 状态
	string public staMsg;          //状态值
	uint public createTime;        // 合约创建时间
	uint public applyTime;        // 贷款申请时间
	uint public mobile;        // 手机号 
	string public username;  // 用户名 
	string public reason;  // 申请原因 
	uint public signTime;          // 放贷时间
	   
	modifier inStatus(Status _status) {
		require(
			status == _status,
			"订单的状态不可操作"
		);
		_;
	}

	modifier onlyBuyer() {
		require(
			companyAddr == msg.sender,
			"借款企业的地址错误!"
		);
		_;
	}

	modifier onlySeller() {
		require(
			bankAddr == msg.sender,
			"银行的地址!"
		);
		_;
	}

     

    //获取借款订单信息
	function getInfo() public view  returns ( uint256,string,string,uint,uint,string) {
        return ( mobile,username, reason,applyTime,amount,staMsg);
    } 


	function getBalance()
		public
		view
		returns(uint _balance)
	{
		return address(this).balance;
	}

	constructor(address _companyAddr,address _bankAddr)
		public
		payable
	{
		companyAddr =  _companyAddr; 
		bankAddr = _bankAddr; 
		createTime = now;
	}


    //借款企业申请贷款
   event Apply(bool isSuccess, string message); 
    function apply(address _token,uint _amount,string _username,uint _mobile,string _reason)
     public 
     onlyBuyer
	 payable
    {
      token =  _token; 
      amount = _amount;
      username = _username; 
	  mobile = _mobile;
      reason = _reason;
      status = Status.Apply;
	  staMsg = "已申请";
	  applyTime = now;
	  emit Apply(true, "申请成功");
      return;
    }
	// 放贷之前用户可以取消
	function abort()
		public
		onlyBuyer
		inStatus(Status.Apply)
		payable 
	{ 	 
		status = Status.Cancel; 
		staMsg = "已取消";
	}


      


	// 银行选择拒绝
	function take()
		public
		onlySeller
		payable 
	{
	  status = Status.Refuse; 
	  staMsg = "已拒绝";
	}

	// 还款
	function payback(address _token,uint _amount)
		public
		onlyBuyer 
	{
		require(
			now - createTime > commitTime,
			"尚未截止期限"
		);
		status = Status.Repayment; 
		staMsg = "已还款";
	}

     

	// 银行输入合约，确认放贷
	function ship(string _token)
		public
		onlySeller
		payable 
	{ 
		status = Status.Lending;  
		staMsg = "已放贷";
	}

 // 过了还款期限，则银行可以确认用户已经逾期
	function confirmBySeller()
		public
		onlySeller
		payable 
	{
		require(
			now - createTime > commitTime,
			"尚未截止期限"
		);
		status = Status.Overdue; 
		staMsg = "已逾期";
	}
 
}