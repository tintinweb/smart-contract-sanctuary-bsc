/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

pragma solidity^0.4.22;

// 贷款合约
contract Product { 

    string public name;         //贷款名称
	address public bankAddr;  // 商业银行的地址
	uint256 public marketFee;    // 贷款利率
    uint256 public usedQuota;    // 当前放贷额度
    uint256 public allQuota;    // 总额度
	uint public commitTime;     // 贷款的时间周期
  
	modifier onlySeller() {
		require(
			bankAddr == msg.sender,
			"账号地址错误!"
		);
		_;
	}

	constructor(uint _price, uint _commitTime,string _name,uint _usedQuota,uint _allQuota)
		public
	{
		require(
			_price != 0 && _commitTime != 0,
			"参数信息不完整"
		);
		bankAddr = msg.sender; 
		marketFee = _price;
        name = _name;
        usedQuota = _usedQuota;
        allQuota = _allQuota;
		commitTime = _commitTime;
	}
 
     //设置贷款利率
	function setPrice(uint256 _price)
		public
		onlySeller
	{
		marketFee = _price;
	}
    
	//设置贷款周期
	function setCommitTime(uint _commitTime)
		public
		onlySeller
	{
		commitTime = _commitTime;
	}
	//获取贷款合约的信息
	function getLoan() public view  returns (address ,uint256,uint,string,uint,uint) {
        return (bankAddr, marketFee, commitTime,name,usedQuota,allQuota);
    } 
}