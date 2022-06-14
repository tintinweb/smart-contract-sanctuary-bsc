/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

pragma solidity ^0.6.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakePair {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract ARTLP {
    
    event Withdraw(address indexed account,uint256 amount);
    event Deposit(address indexed account,uint256 amount);

    struct PledgeRecord {
        uint256 timestamp;
        uint256 amount;
        uint8 isRelease;
    }
    struct ReleaseRecord{
        uint256 timestamp;
        uint256 amount;
        uint256 releaseTimestamp;
    }

    mapping (address => PledgeRecord[]) public _pledgeRecords;
    mapping (address => ReleaseRecord[]) public _releaseRecords;

    address payable private _master;
    using SafeMath  for uint;

    address private PAIR_ART_USDT = 0x381D7CFCD728b1fBba2802546444250330C80686;

    mapping (address => uint256) private _balances;
    uint256 private _totalSupply;
    uint256 private _minTimestamp = 30*86400;

    constructor () public{
        _master = msg.sender;
    }

    function withdraw() payable public  {
        _master.transfer(msg.value);
        emit Withdraw(msg.sender,msg.value);
    }
    function deposit() payable public{
        _master.transfer(msg.value);
        emit Deposit(msg.sender,msg.value);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function pledge(uint256 amount) public returns(bool status){
        require(amount > 0 ,"error");
        require(IPancakePair(PAIR_ART_USDT).transferFrom(msg.sender,_master,amount),"transfer error");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);

        uint256 timestamp = block.timestamp;
        uint8 isRelase = 1;
        (isRelase,) = findRecord(msg.sender,timestamp);
        if(isRelase == 0){timestamp=timestamp.add(1);}

        PledgeRecord memory pledgeRecord= PledgeRecord(timestamp,amount,0);
        _pledgeRecords[msg.sender].push(pledgeRecord);

        return true;
    }

    function release(uint256 timestamp) public returns(bool status){
        uint8 isRelease;uint256 amount;
        (isRelease,amount) = findRecord(msg.sender,timestamp);
        require(amount>0,"Pledge not found");
        require( block.timestamp.sub(timestamp) > _minTimestamp ,"Time is not up");

        require(IPancakePair(PAIR_ART_USDT).transferFrom(_master,msg.sender,amount),"transfer error");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        updateRecord(msg.sender,timestamp);

        ReleaseRecord memory releaseRecord = ReleaseRecord(timestamp,amount,block.timestamp);
        _releaseRecords[msg.sender].push(releaseRecord);
        return true;
    }

    function getMaster() public view returns (address){
        return _master;
    }

    function setMaster(address payable addr) public {
        require(msg.sender == _master);
        _master = addr;
    }

    function setPair(address addr) public{
        require(msg.sender == _master);
        PAIR_ART_USDT = addr;
    }

    function getPair() public view returns (address){
        return PAIR_ART_USDT;
    }

    function setMinTimestamp(uint256 timeInval) public {
        require(msg.sender == _master);
        _minTimestamp=timeInval;
    }

    function getMinTimestamp() public view returns (uint256) {
        return _minTimestamp;
    }

    function updateRecord(address account,uint256 timestamp) private {
        PledgeRecord[] memory records = _pledgeRecords[account];  
        for(uint i = 0;i < records.length;i++){
            if(records[i].timestamp==timestamp){
                records[i].isRelease = 1;
                break;
            }
        }
    }

    function findRecord(address account,uint256 timestamp)view public returns(uint8 isRelease,uint256 amount){
        isRelease = 1;
        amount = 0;
        PledgeRecord[] memory records = _pledgeRecords[account];  
        for(uint i=0;i < records.length;i++){
            if(records[i].timestamp == timestamp){
                isRelease = records[i].isRelease;
                amount = records[i].amount;
                break;
            }
        }
    }

    function getReleaseRecordSizes() view public returns(uint256 size){
        return _releaseRecords[msg.sender].length;
    }

    function getReleaseRecords()view public returns(uint256 [] memory pledgeTimeList,
        uint256 [] memory amountList,
        uint256 [] memory realeaseTimestampList){
        
        ReleaseRecord[] memory records = _releaseRecords[msg.sender];

        uint256 leng = records.length;
       
        pledgeTimeList = new uint256[](leng);
        amountList = new uint256[](leng);
        realeaseTimestampList=new uint256[](leng);
      
        for(uint256 i=0;i < leng;i++){
            pledgeTimeList[i]=records[i].timestamp;
            realeaseTimestampList[i]=records[i].releaseTimestamp;
            amountList[i]=records[i].amount;
            i++;
        }
    }

    function getPledgeRecordsSize() view public returns(uint256 size){
       return _pledgeRecords[msg.sender].length;
    }

    function getPledgeRecords() view public returns (uint256 [] memory pledgeTimeList,uint256 [] memory amountList){
        PledgeRecord[] memory records = _pledgeRecords[msg.sender];
        uint256 leng = records.length;
        pledgeTimeList=new uint256[](leng);
        amountList=new uint256[](leng);
         for(uint256 i=0;i < leng;i++){
            pledgeTimeList[i]=records[i].timestamp;
            amountList[i]=records[i].amount;
            i++;
        }
    }

}