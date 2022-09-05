/**
 *Submitted for verification at BscScan.com on 2022-09-05
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

    IBEP20 public futToken = IBEP20(0x7d0714210F8C365964c7851572b904C60C6bEfC7);
    IBEP20 public usdtToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IERC721 public futNft1 = IERC721(0x01B4A0fA85C32D4a61D086FaD50c51B3741D5Cd9);
    IERC721 public futNft2 = IERC721(0x942096E16962528ab96A63a0a7f2c8E8637ccEd5);
    IERC721 public futNft3 = IERC721(0x7bAAb0E07179BBFD98eEd2531421FAAf8335d757);
    uint256 public futNft1Num = 2000;
    uint256 public futNft2Num = 1000;
    uint256 public futNft3Num = 198;
    address public futPair = 0xBAbC0046f04a4116EacDfcEF446183EFb78674b4;
    IPancakePair futPancakePair = IPancakePair(futPair);
    address private masterAddr = 0x31C69e6791C51E3a21edfF6c257Fe3FFA1801B73;
    
    uint256[] public amountList = [0,3000,5000,10000,18000,30000,60000,200000];
    uint256[] public rateList = [1,3,5,7,9,11,15,20];
    mapping(address => IdoData) public idoMap;
    uint256 public idoTotalNode = 0;
    uint256 public idoTotalUser = 0;
    uint256 public idoStartTime = 0;
    uint256 public idoEndTime = 0;
    uint256 public idoFutPrice = 9 * 10**14;
    bool public idoCanTake = false;

    mapping(address => PledgeData) public pledgeMap;
    mapping(address => RecordData[]) public pledgeRecordMap;
    uint256 public pledgeProfitRate = 20;
    
    struct IdoData {
        uint256 nodeNum;
        uint256 nodeLevel;
        uint256 inviteNodeNum;
        uint256 futAmount;
        uint256 profitUsdtAmount;
        uint256 nft1Num;
        uint256 nft2Num;
        uint256 nft3Num;
        address parent;
    }
    struct PledgeData {
        uint256 myPower;
        uint256 rewardPower;
        uint256 takeTime;
        uint256 totalTake;
        uint256 myFutAmount;
        bool stop;
    }
    struct RecordData {
        uint256 amount;
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
        idoMap[msg.sender].futAmount = idoMap[msg.sender].futAmount + futAmount;
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
        idoMap[ref].profitUsdtAmount = idoMap[ref].profitUsdtAmount + profitAmount;
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
        idoMap[target].nodeNum = 1;
        idoMap[target].parent = parent;
        idoMap[target].nodeLevel = 3;
        idoMap[target].nft3Num = 1;
        idoMap[target].futAmount = 6000000 * 10**18;
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

    function pledgeJoin(uint256 usdtAmount) public {
        require(msg.sender != masterAddr,"cannot be masterAddr");
        require(usdtAmount > 0,"params error");
        require(pledgeMap[msg.sender].stop == false,"is stoped");
        uint256 futPrice = calcFutPrice();
        uint256 futAmount = usdtAmount * 10**18 / futPrice;
        futToken.transferFrom(address(msg.sender),address(this),futAmount);
        usdtToken.transferFrom(address(msg.sender),masterAddr,usdtAmount * 6/10);
        usdtToken.transferFrom(address(msg.sender),futPair,usdtAmount * 4/10);
        futPancakePair.sync();
        pledgeMap[msg.sender].takeTime = block.timestamp;
        pledgeMap[msg.sender].myPower = pledgeMap[msg.sender].myPower+usdtAmount*2;
        pledgeMap[msg.sender].myFutAmount = pledgeMap[msg.sender].myFutAmount + futAmount;
        pledgeMap[msg.sender].stop = false;
        if(idoMap[msg.sender].parent == address(0)){
            idoMap[msg.sender].parent = masterAddr;
        }
        address level1 = idoMap[msg.sender].parent;
        if(level1 != address(0)){
            uint256 rewardPower = usdtAmount*2 * 20/100;
            pledgeMap[level1].rewardPower = pledgeMap[level1].rewardPower + rewardPower;
        }
        address level2 = idoMap[level1].parent;
        if(level2 != address(0)){
            uint256 rewardPower = usdtAmount*2 * 10/100;
            pledgeMap[level2].rewardPower = pledgeMap[level2].rewardPower + rewardPower;
        }
        address level3 = idoMap[level2].parent;
        if(level3 != address(0)){
            uint256 rewardPower = usdtAmount*2 * 5/100;
            pledgeMap[level3].rewardPower = pledgeMap[level3].rewardPower + rewardPower;
        }
    }

    function pledgeExist() public {
        PledgeData memory pledgeData = pledgeMap[msg.sender];
        require(pledgeData.myPower > 0 && pledgeData.myFutAmount > 0  && pledgeData.stop == false,"cannot exist");
        futToken.transfer(address(msg.sender),pledgeData.myFutAmount);
        pledgeMap[msg.sender].stop = true;
        pledgeMap[msg.sender].takeTime = block.timestamp;
    }

    function pledgeRecharge() public {
        PledgeData memory pledgeData = pledgeMap[msg.sender];
        require(pledgeData.myPower > 0 && pledgeData.myFutAmount > 0  && pledgeData.stop == true,"not need recharge");
        futToken.transferFrom(address(msg.sender),address(this),pledgeData.myFutAmount);
        pledgeMap[msg.sender].stop = false;
        pledgeMap[msg.sender].takeTime = block.timestamp;
    }

    function pledgeTake() public {
        uint256 profitAmount = getUserPledgeProfit(msg.sender);
        require(profitAmount > 0,"no profit");
        futToken.transfer(address(msg.sender),profitAmount);
        pledgeMap[msg.sender].takeTime = block.timestamp;
        pledgeMap[msg.sender].totalTake = pledgeMap[msg.sender].totalTake + profitAmount;
        RecordData memory recordData = RecordData({amount:profitAmount,time:block.timestamp});
        pledgeRecordMap[msg.sender].push(recordData);
    }

    function getUserPledgeProfit(address userAddress) public view returns (uint256) {
        PledgeData memory pledgeData = pledgeMap[userAddress];
        uint256 diffTime = block.timestamp - pledgeData.takeTime;
        if(pledgeMap[msg.sender].stop || pledgeData.myPower <= 0 || diffTime < 3600){
            return 0;
        }
        uint256 rateTimes = diffTime / 3600;
        uint256 additionRate = 0;
        if(idoMap[userAddress].nft3Num > 0){
            additionRate = 20;
        }else if(idoMap[userAddress].nft2Num > 0){
            additionRate = 10;
        }else if(idoMap[userAddress].nft1Num > 0){
            additionRate = 15;
        }
        uint256 profitRate = calcRate(pledgeData.rewardPower/10**18);
        uint256 realMyPower = pledgeData.myPower * (additionRate + 100) / 100 + pledgeData.rewardPower * (100+profitRate) / 100;
        uint256 profitValue = realMyPower * rateTimes * 2 / (24 * 100);
        uint256 takeFutAmount = profitValue * 10**18 / calcFutPrice();
        return takeFutAmount;
    }

    function calcRate(uint256 amount) public view returns (uint256) {
        for (uint i = 0; i < amountList.length; i++) {
            if(i==amountList.length-1){
                if(amount>=amountList[i]){
                    return rateList[i];
                }
            }else{
                if(amount >= amountList[i] && amount <amountList[i+1]){
                    return rateList[i];
                }
            }
        }
        return 0;
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

    function setNftData(uint256 _futNft1Num,uint256 _futNft2Num,uint256 _futNft3Num) public onlyOwner{
        futNft1Num = _futNft1Num;
        futNft2Num = _futNft2Num;
        futNft3Num = _futNft3Num;
    }

    function getIdoData() public view returns(uint256,uint256,uint256,uint256,uint256,bool){
        return (idoTotalNode,idoTotalUser,idoStartTime,idoEndTime,idoFutPrice,idoCanTake);
    }

    function setIdoData(uint256 _idoStartTime,uint256 _idoEndTime,uint256 _idoFutPrice,bool _idoCanTake) public onlyOwner{
        require(_idoEndTime>_idoStartTime,"param error");
        idoStartTime = _idoStartTime;
        idoEndTime = _idoEndTime;
        idoFutPrice = _idoFutPrice;
        idoCanTake = _idoCanTake;
    }

    function getUserIdoData(address userAddress) public view returns(IdoData memory){
        return idoMap[userAddress];
    }
    
    function setPledgeData(uint256 _pledgeProfitRate) public onlyOwner{
        require(_pledgeProfitRate > 0 && _pledgeProfitRate < 1000,"param error");
        pledgeProfitRate = _pledgeProfitRate;
    }

    function getPledgeData() public view returns(uint256){
        return pledgeProfitRate;
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
}