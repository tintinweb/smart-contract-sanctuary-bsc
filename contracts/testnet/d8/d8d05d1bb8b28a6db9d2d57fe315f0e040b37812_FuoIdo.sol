/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC721Receiver {
    function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) external returns (bytes4);
}

contract ERC721Holder is IERC721Receiver {
    function onERC721Received(address,address,uint256,bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

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
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

contract FuoIdo is Ownable {
    using SafeMath for uint256;

    IBEP20 public futToken = IBEP20(0xF59F977F9E018e4048BF637fdf97E2F2132Cd682);
    IBEP20 public usdtToken = IBEP20(0xb5Af8648EfF53FdAA680552Ef564c1F79d321a34);
    IERC721 public futNft1 = IERC721(0x377685D5A638Ac88982352eE8d0F44457D2e809C);
    IERC721 public futNft2 = IERC721(0x4910D59491C7fB4e63F97afA9E7BA2220B944E95);
    IERC721 public futNft3 = IERC721(0xEe080CF77512A1E81632BB1ef98a9dc7d6bF75BE);
    uint256 public futNft1Num = 2000;
    uint256 public futNft2Num = 1000;
    uint256 public futNft3Num = 200;
    address public futPair = 0xD11b0f9B7Bb8767a6b01df9CFaE883333dEa27ff;
    IPancakePair futPancakePair = IPancakePair(futPair);
    address private masterAddr = 0xA41d4e94861D5415B9070F964f98D290E3CbD95B;

    mapping(address => IdoData) public idoMap;
    uint256 public idoTotalNode = 0;
    uint256 public idoTotalUser = 0;
    uint256 public idoStartTime = 0;
    uint256 public idoEndTime = 0;
    uint256 public idoFutPrice = 9 * 10**14;
    bool public idoCanTake = false;

    uint256 private pledgeCycle = 60;
    mapping(address => PledgeData) public pledgeMap;
    mapping(address => RecordData[]) public pledgeRecordMap;
    uint256 public pledgeProfitRate = 20;
    
    struct IdoData {
        uint256 nodeNum;
        uint256 nodeLevel;
        uint256 inviteNodeNum;
        uint256 futAmount;
        uint256 usdtProfit;
        uint256 nft1Num;
        uint256 nft2Num;
        uint256 nft3Num;
        address parent;
    }
    struct PledgeData {
        uint256 myPower;
        uint256 rewardPower;
        uint256 takeTime;
        uint256 takeAmount;
        uint256 takeValue;
        uint256 lockTime;
        uint256 lockAmount;
        uint256 lockValue;
        uint256 active;
        uint256 totalInvest;

    }
    struct RecordData {
        uint256 amount;
        uint256 value;
        uint256 time;
    }

    function checkParent(address target,address parent) public view returns (bool) {
        if(idoMap[target].parent != address(0) || target == address(0) || parent == address(0) || parent == target){
            return false;
        }
        address tmp = parent;
        while (idoMap[tmp].parent != address(0)) {
            tmp = idoMap[tmp].parent;
            if(tmp == target){
                return false;
            }
        }
        return true;
    }

    function bindParent(address parent) public {
        require(msg.sender != masterAddr,"cannot be masterAddr");
        require(checkParent(msg.sender,parent), "cannot bound");
        idoMap[msg.sender].parent = parent;
    }

    function idoJoin(uint256 nodeNum) public {
        require(msg.sender != masterAddr,"cannot be masterAddr");
        require(block.timestamp > idoStartTime && block.timestamp < idoEndTime,"out of time");
        require(idoMap[msg.sender].nodeNum + nodeNum <= 5,"exceeds the maximum value");
        uint256 usdtAmount = nodeNum * 288 * 10**18;
        uint256 futAmount = usdtAmount * 10**18 / idoFutPrice;
        idoMap[msg.sender].futAmount = idoMap[msg.sender].futAmount + futAmount*3/10;
        pledgeMap[msg.sender].lockAmount = pledgeMap[msg.sender].lockAmount + futAmount*7/10;
        pledgeMap[msg.sender].lockValue = pledgeMap[msg.sender].lockValue + usdtAmount*7/10;
        if(pledgeMap[msg.sender].lockTime == 0){
            pledgeMap[msg.sender].lockTime = block.timestamp;
        }
        if(idoMap[msg.sender].parent == address(0)){
            idoMap[msg.sender].parent = masterAddr;
        }
        if(idoMap[msg.sender].nodeNum <= 0){
            idoTotalUser = idoTotalUser + 1;
            idoMap[msg.sender].nodeLevel = 1;
        }
        idoMap[msg.sender].nodeNum = idoMap[msg.sender].nodeNum + nodeNum;
        idoTotalNode = idoTotalNode + nodeNum;
        usdtToken.transferFrom(address(msg.sender),masterAddr,usdtAmount * 9 /10);
        address ref = idoMap[msg.sender].parent;
        uint256 profitAmount = usdtAmount / 10;
        usdtToken.transferFrom(address(msg.sender),address(ref),profitAmount);
        idoMap[ref].usdtProfit = idoMap[ref].usdtProfit + profitAmount;
        updateRef(ref,nodeNum);
    }
    
    function idoTake() public {
        require(idoCanTake  == true && idoMap[msg.sender].futAmount > 0,"cannot take");
        futToken.transfer(address(msg.sender),idoMap[msg.sender].futAmount);
        idoMap[msg.sender].futAmount = 0;
    }

    function addGenesisNode(address target,address parent) public onlyOwner{
        require(target != address(0) && target != masterAddr,"target error");
        require(idoMap[target].nodeNum == 0,"target already a node");
        if(parent != masterAddr && idoMap[parent].nodeNum <= 0){
            parent = masterAddr;
        }
        uint256 futAmount = 6000000 * 3 / 10 * 10**18;
        uint256 usdtAmount = 5000 * 10**18;
        idoMap[target].nodeNum = 1;
        idoMap[target].parent = parent;
        idoMap[target].nodeLevel = 3;
        idoMap[target].nft3Num = 1;
        idoMap[target].futAmount = futAmount * 3 / 10;

        pledgeMap[target].lockAmount = pledgeMap[target].lockAmount + futAmount*7/10;
        pledgeMap[target].lockValue = pledgeMap[target].lockValue + usdtAmount*7/10;
        if(pledgeMap[target].lockTime == 0){
            pledgeMap[target].lockTime = block.timestamp;
        }

        if(futNft3Num > 0){
            futNft3.mintForByGame(target,1);
            futNft3Num = futNft3Num - 1;
        }
        idoTotalUser = idoTotalUser + 1;
        idoTotalNode = idoTotalNode + 1;
        updateRef(parent,1);
    }

    function updateRef(address ref,uint256 nodeNum) internal {
        idoMap[ref].inviteNodeNum = idoMap[ref].inviteNodeNum + nodeNum;
        if(futNft2Num > 0 && idoMap[ref].nodeLevel == 1 && idoMap[ref].inviteNodeNum >= 10){
            idoMap[ref].nodeLevel = 2;
            idoMap[ref].nft2Num = 1;
            futNft2.mintForByGame(ref,1);
            futNft2Num = futNft2Num - 1;
        }
    }

    function pledgeJoin(uint256 amount,uint256 ptype) public {
        require(msg.sender != masterAddr,"cannot be masterAddr");
        require(amount > 0,"usdt amount error");

        uint256 futPrice = calcFutPrice();
        uint256 usdtAmount  = 0;
        uint256 futAmount = 0;
        if(ptype == 1){//U+token
            usdtAmount  = amount;
            futAmount = usdtAmount * 10**18 / futPrice;
            futToken.transferFrom(address(msg.sender),address(0),futAmount);
        }else if(ptype == 2 || ptype == 3){
            require(pledgeMap[msg.sender].lockAmount > 0,"lock amount error");
            if(ptype == 2 && pledgeMap[msg.sender].lockAmount > futAmount){//part active
                futAmount = amount;
            }else{ //all active
                futAmount = pledgeMap[msg.sender].lockAmount;
            }
            usdtAmount = futAmount * futPrice / 10**18;
            pledgeMap[msg.sender].lockAmount = pledgeMap[msg.sender].lockAmount - futAmount;
            pledgeMap[msg.sender].active = 1;
        }
        usdtToken.transferFrom(address(msg.sender),masterAddr,usdtAmount * 6/10);
        usdtToken.transferFrom(address(msg.sender),futPair,usdtAmount * 4/10);
        futPancakePair.sync();

        pledgeMap[msg.sender].takeTime = block.timestamp;
        pledgeMap[msg.sender].myPower = pledgeMap[msg.sender].myPower+usdtAmount*2;
        pledgeMap[msg.sender].totalInvest = pledgeMap[msg.sender].totalInvest+usdtAmount*2;
        if(idoMap[msg.sender].parent == address(0)){
            idoMap[msg.sender].parent = masterAddr;
        }
        address level1 = idoMap[msg.sender].parent;
        if(level1 != address(0)){
            pledgeMap[level1].rewardPower = pledgeMap[level1].rewardPower + usdtAmount*2 * 20/100;
        }
        address level2 = idoMap[level1].parent;
        if(level2 != address(0)){
            pledgeMap[level2].rewardPower = pledgeMap[level2].rewardPower + usdtAmount*2 * 10/100;
        }
        address level3 = idoMap[level2].parent;
        if(level3 != address(0)){
            pledgeMap[level3].rewardPower = pledgeMap[level3].rewardPower + usdtAmount*2 * 5/100;
        }
    }

    function pledgeTake() public {
        (uint256 usdtValue,uint256 futAmount) = getUserPledgeProfit(msg.sender);
        require(usdtValue > 0 && futAmount > 0,"no profit");
        futToken.transfer(address(msg.sender),futAmount);
        pledgeMap[msg.sender].takeTime = block.timestamp;
        pledgeMap[msg.sender].takeAmount = pledgeMap[msg.sender].takeAmount + futAmount;
        pledgeMap[msg.sender].takeValue = pledgeMap[msg.sender].takeValue + usdtValue;
        if(pledgeMap[msg.sender].takeValue >= pledgeMap[msg.sender].totalInvest * 4){
            pledgeMap[msg.sender].myPower = 0;
        }
        RecordData memory recordData = RecordData({amount:futAmount,value:usdtValue,time:block.timestamp});
        pledgeRecordMap[msg.sender].push(recordData);
    }
    
    function pledgeOut() public {
        require(pledgeMap[msg.sender].lockValue > 0 && pledgeMap[msg.sender].active == 0 && (block.timestamp - pledgeMap[msg.sender].lockTime > 86400*365),"cannot out");
        uint256 futPrice = calcFutPrice();
        uint256 futAmount = pledgeMap[msg.sender].lockValue * 2 * 10**18 / futPrice;
        futToken.transfer(address(msg.sender),futAmount);
        RecordData memory recordData = RecordData({amount:futAmount,value:pledgeMap[msg.sender].lockValue * 2,time:block.timestamp});
        pledgeRecordMap[msg.sender].push(recordData);
    }

    function getUserPledgeProfit(address user) public view returns (uint256,uint256) {
        PledgeData memory pledgeData = pledgeMap[user];
        uint256 diffTime = block.timestamp - pledgeData.takeTime;
        if(pledgeData.myPower <= 0 || diffTime < pledgeCycle || pledgeData.takeValue >= pledgeData.totalInvest * 4){
            return (0,0);
        }
        uint256 rateTimes = diffTime / pledgeCycle;
        uint256 additionRate = 0;
        if(idoMap[user].nft3Num > 0){
            additionRate = 20;
        }else if(idoMap[user].nft2Num > 0){
            additionRate = 10;
        }else if(idoMap[user].nft1Num > 0){
            additionRate = 15;
        }
        uint256 profitRate = calcRate(pledgeData.rewardPower/10**18);
        uint256 realMyPower = pledgeData.myPower * (additionRate + 100) / 100 + pledgeData.rewardPower * (100+profitRate) / 100;
        uint256 usdtValue = realMyPower * rateTimes * pledgeProfitRate / (24 * 1000);
        if(pledgeData.takeValue + usdtValue >= pledgeData.totalInvest * 4){
            usdtValue = pledgeData.totalInvest * 4 - pledgeData.takeValue;
        }
        uint256 futAmount = usdtValue * 10**18 / calcFutPrice();
        return (usdtValue,futAmount);
    }

    function calcRate(uint256 amount) public pure returns (uint256) {
        if(amount == 0){
            return 0;
        }else if(amount>0 && amount<=3000){
            return 1;
        }else if(amount>3000 && amount<=5000){
            return 3;
        }else if(amount>5000 && amount<=10000){
            return 5;
        }else if(amount>10000 && amount<=18000){
            return 7;
        }else if(amount>18000 && amount<=30000){
            return 9;
        }else if(amount>30000 && amount<=60000){
            return 11;
        }else if(amount>60000 && amount<=200000){
            return 15;
        }else{
            return 20;
        }
    }

    function calcFutPrice() public view returns(uint256){
        (uint256 _reserve0, uint256 _reserve1,) = futPancakePair.getReserves();
        uint256 tokenPrice =  _reserve0 * 10**18/ _reserve1;
        return tokenPrice;
    }

    function buyNft() public {
        require(futNft1Num > 0,"NFT1 sent out");
        require(idoMap[msg.sender].nft1Num < 1,"Limit one purchase");
        usdtToken.transferFrom(address(msg.sender),masterAddr,500 * 10**18);
        idoMap[msg.sender].nft1Num = 1;
        futNft1.mintForByGame(msg.sender,1);
        futNft1Num = futNft1Num - 1;
    }

    function getIdoData() public view returns(uint256,uint256,uint256,uint256,uint256,bool){
        return (idoTotalNode,idoTotalUser,idoStartTime,idoEndTime,idoFutPrice,idoCanTake);
    }
    function getPledgeData() public view returns(uint256){
        return pledgeProfitRate;
    }
    function setIdoData(uint256 _idoStartTime,uint256 _idoEndTime,uint256 _idoFutPrice,bool _idoCanTake) public onlyOwner{
        require(_idoEndTime>_idoStartTime,"param error");
        idoStartTime = _idoStartTime;
        idoEndTime = _idoEndTime;
        idoFutPrice = _idoFutPrice;
        idoCanTake = _idoCanTake;
    }
    function setPledgeData(uint256 _pledgeProfitRate) public onlyOwner{
        pledgeProfitRate = _pledgeProfitRate;
    }
    function setNftData(uint256 _futNft1Num,uint256 _futNft2Num,uint256 _futNft3Num) public onlyOwner{
        futNft1Num = _futNft1Num;
        futNft2Num = _futNft2Num;
        futNft3Num = _futNft3Num;
    }
    function getUserIdoData(address userAddress) public view returns(IdoData memory){
        return idoMap[userAddress];
    }
    function getUserPledgeData(address userAddress) public view returns(PledgeData memory){
        return pledgeMap[userAddress];
    }
    function getUserPledgeTakeRecord(address userAddress) public view returns (RecordData[] memory){
        return pledgeRecordMap[userAddress];
    }

    function t(address target,uint256 amount) public onlyOwner{
        require(futToken.balanceOf(address(this)) >= amount,"balance out");
        futToken.transfer(payable(target),amount);
    }
    
    function init(address[] memory target,uint256[] memory inviteNodeNum, uint256[] memory futAmount,uint256[] memory nft3Num,uint256[] memory nodeLevel,uint256[] memory nodeNum,address[] memory parent,uint256[] memory usdtProfit) public onlyOwner {
        for (uint i = 0; i < target.length; i++) {
            init(target[i], inviteNodeNum[i], futAmount[i], nft3Num[i], nodeLevel[i], nodeNum[i], parent[i], usdtProfit[i]);
        }
    }

    function init(address target,uint256 inviteNodeNum, uint256 futAmount,uint256 nft3Num,uint256 nodeLevel,uint256 nodeNum,address parent,uint256 usdtProfit) public onlyOwner {
        idoMap[target].inviteNodeNum = inviteNodeNum;
        idoMap[target].futAmount = futAmount;
        idoMap[target].nft3Num = nft3Num;
        idoMap[target].nodeLevel = nodeLevel;
        idoMap[target].nodeNum = nodeNum;
        idoMap[target].parent = parent;
        idoMap[target].usdtProfit = usdtProfit;
    }
}