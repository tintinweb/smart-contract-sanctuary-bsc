/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library EnumerableSet {
    struct AddressSet {
        address[] _values;
        mapping (address => uint256) _indexes;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        if (!contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            address lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1;
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return set._indexes[value] != 0;
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return set._values.length;
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }
}

interface IBEP20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
}

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function mintForByGame(address to,uint256 num) external;
}

interface IPancakePair {
    function balanceOf(address owner) external view returns (uint);
    function totalSupply() external view returns (uint);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract DawnHome is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    bool public whiteLock = true;
    mapping(address => bool) public whiteList;
    
    mapping(address => IdoData) public idoMap;
    uint256 public idoTotalUsdtAmount = 0;
    uint256 public idoTotalUser = 0;
    uint256 public idoStartTime = 0;
    uint256 public idoEndTime = 0;
    uint256 public idoPrice = 2 * 10**16;
    bool public idoCanTake = false;
    
    IBEP20 public usdtToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);//PRO
    address private initAddr = 0x1D7E2062Abed92825a8443d81C02fe58bF76f054; //PRO
    address private marketAddr = 0xD3ec581CaFe4c2a59C0D8b4ef7Ac6Ad67B913e80; //PRO
    IBEP20 public dawnToken = IBEP20(0x39a38D14a5908d57b234355558eb0Ec1afA574F4);//PRO
    IPancakePair lpToken = IPancakePair(0x5972d6549c78fc8408ADe79ba06518fEDbD0Fd4a);//PRO
    
    EnumerableSet.AddressSet private pledgePool;
    mapping(address => RecordData[]) public pledgeRecordMap;
    uint256 private pledgeCycle = 86400;
    mapping(address => PledgeData) public pledge1Map;
    bool public pledge1Lock = true;
    mapping(address => PledgeData) public pledge2Map;
    
    struct IdoData {
        uint256 usdtAmount;
        uint256 tokenAmount;
        uint256 inviteNum;
        address parent;
        address[] childList;
    }

    struct PledgeData {
        uint256 lpAmount;
        uint256 myPower;
        uint256 outTime;
        uint256 waitProfit;
        uint256 lastTime;
        uint256 totalTake;
    }

    struct RecordData {
        uint256 value;
        uint256 time;
    }

    function setWhiteLock(bool _whiteLock) public onlyOwner {
        whiteLock = _whiteLock;
    }

    function setWhiteList(address[] memory addrList,bool isIn) public onlyOwner {
        require(addrList.length > 0  && addrList.length <= 50);
        for (uint256 i; i < addrList.length; ++i) {
            whiteList[addrList[i]] = isIn;
            if(isIn && idoMap[addrList[i]].parent == address(0)){
                idoMap[addrList[i]].parent = initAddr;
            }
        }
    }
    
    function bindParent(address parent) public {
        require(msg.sender != initAddr,"cannot be initAddr");
        require(!whiteLock || whiteList[parent],"not in white list");
        require(idoMap[parent].parent != address(0),"parent is invalid");
        idoMap[msg.sender].parent = parent;
    }

    function idoJoin() public{
        address parent = idoMap[msg.sender].parent;
        require(parent != address(0),"no parent");
        require(msg.sender != initAddr,"cannot be initAddr");
        require(block.timestamp > idoStartTime && block.timestamp < idoEndTime,"out of time");
        require(idoMap[msg.sender].usdtAmount == 0,"has join");
        uint256 usdtAmount = 50 * 10**18;
        usdtToken.transferFrom(address(msg.sender),marketAddr,usdtAmount);
        uint256 tokenAmount = usdtAmount * 10**18 / idoPrice;
        idoMap[msg.sender].usdtAmount = usdtAmount;
        idoMap[msg.sender].tokenAmount = tokenAmount;
        idoMap[parent].inviteNum = idoMap[parent].inviteNum + 1;
        idoMap[parent].childList.push(msg.sender);
        idoTotalUsdtAmount = idoTotalUsdtAmount + usdtAmount;
        idoTotalUser = idoTotalUser + 1;
    }
    
    function idoTake() public{
        require(idoCanTake == true && idoMap[msg.sender].tokenAmount > 0,"cannot take");
        dawnToken.transfer(address(msg.sender),idoMap[msg.sender].tokenAmount);
        idoMap[msg.sender].tokenAmount = 0;
    }

    function getIdoData() public view returns(uint256,uint256,uint256,bool){
        return (idoStartTime,idoEndTime,idoPrice,idoCanTake);
    }

    function setIdoData(uint256 _idoStartTime,uint256 _idoEndTime,uint256 _idoPrice,bool _idoCanTake) public onlyOwner{
        require(_idoEndTime > _idoStartTime,"param error");
        idoStartTime = _idoStartTime;
        idoEndTime = _idoEndTime;
        idoPrice = _idoPrice;
        idoCanTake = _idoCanTake;
    }

    function getUserIdoData(address userAddress) public view returns(IdoData memory){
        return idoMap[userAddress];
    }

    function pledgeAllot(address addr,uint256 lpAmount) public onlyOwner{
        require(lpAmount > 0,"lp amount error");
        uint256 goesPower = calcLpGoesPower();
        uint256 newPower = lpAmount * goesPower /  10 ** 18;
        pledge1Map[addr].lpAmount = pledge1Map[msg.sender].lpAmount + lpAmount;
        pledge1Map[addr].myPower = pledge1Map[msg.sender].myPower + newPower;
        pledge1Map[addr].lastTime = block.timestamp;
        pledge1Map[addr].outTime = block.timestamp + 90 * 86400;
        if(!pledgePool.contains(addr)){
            pledgePool.add(addr);
        }
    }

    function setPledge1Lock(bool _pledge1Lock) public onlyOwner {
        pledge1Lock = _pledge1Lock;
    }

    function pledgeJoin(uint256 lpAmount) public {
        address parent = idoMap[msg.sender].parent;
        require(parent != address(0),"no parent");
        require(msg.sender != initAddr,"cannot be initAddr");
        require(lpAmount > 0,"lp amount error");
        uint256 goesPower = calcLpGoesPower();
        uint256 newPower = lpAmount * goesPower /  10 ** 18;
        lpToken.transferFrom(address(msg.sender),address(this),lpAmount);
        uint256 newProfit = calcUserNewProfit(2,msg.sender);
        if(newProfit > 0){
            pledge2Map[msg.sender].waitProfit = pledge2Map[msg.sender].waitProfit + newProfit;
        }
        pledge2Map[msg.sender].lastTime = block.timestamp;
        if(pledge2Map[msg.sender].lpAmount == 0){
            pledge2Map[msg.sender].outTime = block.timestamp + 90 * 86400;
        }
        pledge2Map[msg.sender].lpAmount = pledge2Map[msg.sender].lpAmount + lpAmount;
        pledge2Map[msg.sender].myPower = pledge2Map[msg.sender].myPower + newPower;
        
        if(!pledgePool.contains(msg.sender)){
            pledgePool.add(msg.sender);
        }
    }

    function pledgeRelease(uint256 ptype) public{
        // uint256 curTake = 0;
        if(ptype == 1){
            require(!pledge1Lock && pledge1Map[msg.sender].lpAmount > 0,"cannot release");
            // curTake = calcUserNewProfit(1,msg.sender);
            // if(curTake > 0){
            //     usdtToken.transfer(address(msg.sender),curTake);
            //     pledge1Map[msg.sender].totalTake = pledge1Map[msg.sender].totalTake + curTake;
            // }
            lpToken.transfer(address(msg.sender),pledge1Map[msg.sender].lpAmount);
            pledge1Map[msg.sender].lastTime = block.timestamp;
            pledge1Map[msg.sender].lpAmount = 0;
            pledge1Map[msg.sender].myPower = 0;
            pledge1Map[msg.sender].waitProfit = 0;
        }else{
            require(pledge2Map[msg.sender].lpAmount > 0,"cannot release");
            // curTake = calcUserNewProfit(2,msg.sender) + pledge2Map[msg.sender].waitProfit;
            // if(curTake > 0){
            //     usdtToken.transfer(address(msg.sender),curTake);
            //     pledge2Map[msg.sender].totalTake = pledge2Map[msg.sender].totalTake + curTake;
            // }
            lpToken.transfer(address(msg.sender),pledge2Map[msg.sender].lpAmount);
            pledge2Map[msg.sender].lastTime = block.timestamp;
            pledge2Map[msg.sender].lpAmount = 0;
            pledge2Map[msg.sender].myPower = 0;
            pledge2Map[msg.sender].waitProfit = 0;
        }
        // if(curTake > 0){
        //     RecordData memory recordData = RecordData({value:curTake,time:block.timestamp});
        //     pledgeRecordMap[msg.sender].push(recordData);
        // }
    }

    function pledgeTake(uint256 ptype) public {
        uint256 curTake = 0;
        if(ptype == 1){
            curTake = calcUserNewProfit(1,msg.sender);
            require(curTake > 0,"no profit");
            pledge1Map[msg.sender].lastTime = block.timestamp;
            pledge1Map[msg.sender].totalTake = pledge1Map[msg.sender].totalTake + curTake;
        }else{
            curTake = calcUserNewProfit(2,msg.sender) + pledge2Map[msg.sender].waitProfit;
            require(curTake > 0,"no profit");
            pledge2Map[msg.sender].waitProfit = 0;
            pledge2Map[msg.sender].lastTime = block.timestamp;
            pledge2Map[msg.sender].totalTake = pledge2Map[msg.sender].totalTake + curTake;
        }
        usdtToken.transfer(address(msg.sender),curTake * 84 / 100);
        RecordData memory recordData = RecordData({value:curTake,time:block.timestamp});
        pledgeRecordMap[msg.sender].push(recordData);

        uint256 teamRate = 0;
        address level1 = idoMap[msg.sender].parent;
        if(level1 != address(0)){
            (uint256 levelCount1,) = getPledgeCountData(1,level1);
            if(levelCount1 >= 3){
                usdtToken.transfer(address(level1),curTake * 8 / 100);
                teamRate = teamRate + 8;
            }
        }
        address level2 = idoMap[level1].parent;
        if(level2 != address(0)){
            (uint256 levelCount2,) = getPledgeCountData(1,level2);
            if(levelCount2 >= 5){
                usdtToken.transfer(address(level2),curTake * 5 / 100);
                teamRate = teamRate + 5;
            }
        }
        address level3 = idoMap[level2].parent;
        if(level3 != address(0)){
            (uint256 levelCount3,) = getPledgeCountData(1,level2);
            if(levelCount3 >= 8){
                usdtToken.transfer(address(level3),curTake * 3 / 100);
                teamRate = teamRate + 3;
            }
        }
        if(teamRate < 16){
            usdtToken.transfer(address(initAddr),curTake * (16 - teamRate) / 100);
        }
    }

    function calcUserNewProfit(uint256 ptype,address user) public view returns (uint256) {
        if(ptype == 1){
            PledgeData memory pledgeData = pledge1Map[user];
            uint256 realPower = pledgeData.myPower;
            return calcProfit(pledgeData,realPower);
        }else{
            PledgeData memory pledgeData = pledge2Map[user];
            uint256 realPower = pledgeData.myPower + pledgeData.waitProfit;
            return calcProfit(pledgeData,realPower);
        }
    }

    function calcProfit(PledgeData memory pledgeData,uint256 realPower) internal view virtual returns (uint256) {
        if(realPower == 0){
            return 0;
        }
        if(pledgeData.lastTime >= pledgeData.outTime){
            return 0;
        }
        uint256 diffTime = 0;
        if(block.timestamp > pledgeData.outTime){
            diffTime = pledgeData.outTime - pledgeData.lastTime;
        }else{
            diffTime = block.timestamp - pledgeData.lastTime;
        }
        if(diffTime < pledgeCycle){
            return 0;
        }
        uint256 rateTimes = diffTime / pledgeCycle;
        if(rateTimes > 90){
            rateTimes = 90;
        }
        uint256 temp = realPower;
        for(uint256 i=0;i < rateTimes;i++){
            temp = temp * 1015 / 1000;
        }
        return temp-realPower;
    }

    function calcLpGoesPower() public view returns(uint256){
        uint256 lpTotal = lpToken.totalSupply();
        (, uint256 _reserve1,) = lpToken.getReserves();
        uint256 goesPower = 10 ** 18 * _reserve1 / lpTotal;
        return goesPower;
    }

    function getPledgeCountData(uint256 levelNum,address userAddr) public view returns (uint256,uint256) {
        uint256 levelCount = 0;
        uint256 levelAmount = 0;
        for(uint256 i=0;i<pledgePool._values.length;i++){
            address tempAddr = pledgePool._values[i];
            address tempLevel1 = idoMap[tempAddr].parent;
            address tempLevel2 = idoMap[tempLevel1].parent;
            address tempLevel3 = idoMap[tempLevel2].parent;
            if(pledge1Map[tempAddr].lpAmount + pledge2Map[tempAddr].lpAmount == 0){
                continue;
            }
            if((levelNum == 1 && tempLevel1 == userAddr) || (levelNum == 2 && tempLevel2 == userAddr) || (levelNum == 3 && tempLevel3 == userAddr)){
                levelCount = levelCount + 1;
                levelAmount = levelAmount + pledge1Map[tempAddr].lpAmount + pledge2Map[tempAddr].lpAmount;
            }
        }
        return (levelCount,levelAmount);
    }

    function getPledgeRecord(address userAddr) public view returns (RecordData[] memory){
        return pledgeRecordMap[userAddr];
    }

    function t() public onlyOwner{
        uint256 lpBalance = lpToken.balanceOf(address(this));
        if(lpBalance > 0){
            lpToken.transfer(address(msg.sender),lpBalance);
        }
        uint256 dawnBalance = dawnToken.balanceOf(address(this));
        if(dawnBalance > 0){
            dawnToken.transfer(address(msg.sender),dawnBalance);
        }
    }
}