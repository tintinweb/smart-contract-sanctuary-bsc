/**
 *Submitted for verification at BscScan.com on 2022-10-20
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

contract CupIdo is Ownable {
    using SafeMath for uint256;

    IBEP20 public platformToken = IBEP20(0xDb16D5dC094a2da1C6DC72C080Fa54F66909B08f);
    IBEP20 public usdtToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IERC721 public nft1Obj = IERC721(0x07b93f82612824ec2e56267BFD53a1b3B9FDd63B);
    IERC721 public nft2Obj = IERC721(0x9d435c224DD9928E49476045bB12F7a298D551a2);
    IERC721 public nft3Obj = IERC721(0xa1d87c96389763eFDcFB8581F6A3aC9cB13eE758);
    IERC721 public nft4Obj = IERC721(0xfC4a07b0d885C273D0F4f12C84eC2d8494823415);

    uint256 public nft1ObjNum = 5000;
    uint256 public nft2ObjNum = 3000;
    uint256 public nft3ObjNum = 2500;
    uint256 public nft4ObjNum = 200;
    address public futPair = 0xd8aEBb44B357be3E39E3a9497c4eB2E37647E24a;
    IPancakePair futPancakePair = IPancakePair(futPair);
    address private masterAddr = 0x4F4A94Ab482c7fa74fdb65966f952375D20F8101;
    
    mapping(address => IdoData) public idoMap;
    uint256 public idoTotalUsdtAmount = 0;
    uint256 public idoTotalUser = 0;
    uint256 public idoStartTime = 0;
    uint256 public idoEndTime = 0;
    uint256 public idoPrice = 1 * 10**16;

    uint256 private pledgeCycle = 86400;
    uint256 public pledgeTotalPower = 0;
    mapping(address => PledgeData) public pledgeMap;
    mapping(address => RecordData[]) public pledgeRecordMap;
    uint256 public pledgeProfitRate = 15;

    struct IdoData {
        uint256 usdtAmount;
        uint256 tokenAmount;
        uint256 profitUsdtAmount;
        uint256 profitTokenAmount;
        uint256 inviteUsdtAmount1;
        uint256 inviteUsdtAmount2;
        address parent;
    }

    struct PledgeData {
        uint256 myPower;
        uint256 takeTime;
        uint256 takeAmount;
        uint256 takeValue;
        uint256 waitProfit;
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

    function bindParent(address parent) public returns (bool) {
        require(msg.sender != masterAddr,"cannot be masterAddr");
        require(checkParent(msg.sender,parent), "cannot bound");
        idoMap[msg.sender].parent = parent;
        return true;
    }

    function idoJoin(uint256 idoType) public{
        require(block.timestamp > idoStartTime && block.timestamp < idoEndTime,"out of time");
        require(idoType >= 1 && idoType <=4,"param eroor");
        require(idoMap[msg.sender].usdtAmount == 0,"has join");
        uint256 usdtAmount = 0;
        if(idoType == 1){
            usdtAmount = 200 * 10**18;
        }else if(idoType == 2){
            usdtAmount = 500 * 10**18;
        }else if(idoType == 3){
            usdtAmount = 1000 * 10**18;
        }else{
            usdtAmount = 3000 * 10**18;
        }
        uint256 tokenAmount = usdtAmount * 10**18 / idoPrice;
        idoMap[msg.sender].tokenAmount = idoMap[msg.sender].tokenAmount + tokenAmount;

        idoMap[msg.sender].usdtAmount = idoMap[msg.sender].usdtAmount + usdtAmount;
        idoTotalUsdtAmount = idoTotalUsdtAmount + usdtAmount;
        idoTotalUser = idoTotalUser + 1;
        if(idoMap[msg.sender].parent == address(0)){
            idoMap[msg.sender].parent = masterAddr;
        }
        
        address parent1 = idoMap[msg.sender].parent;
        if(parent1 != address(0)){
            idoMap[parent1].inviteUsdtAmount1 = idoMap[parent1].inviteUsdtAmount1 + usdtAmount;
            (uint256 rate1,) = calcRate(idoMap[parent1].inviteUsdtAmount1);
            if(rate1>0){
                uint256 profitAmount = usdtAmount * rate1 / 100;
                usdtToken.transferFrom(address(msg.sender),address(parent1),profitAmount);
                idoMap[parent1].profitUsdtAmount = idoMap[parent1].profitUsdtAmount + profitAmount;
                usdtToken.transferFrom(address(msg.sender),masterAddr,(usdtAmount - profitAmount));
            }else{
                usdtToken.transferFrom(address(msg.sender),masterAddr,usdtAmount);
            }
        }else{
            usdtToken.transferFrom(address(msg.sender),masterAddr,usdtAmount);
        }

        address parent2 = idoMap[parent1].parent;
        if(parent2 != address(0)){
            idoMap[parent2].inviteUsdtAmount2 = idoMap[parent2].inviteUsdtAmount2 + usdtAmount;
            (,uint256 rate2) = calcRate(idoMap[parent2].inviteUsdtAmount2);
            if(rate2 > 0){
                uint256 profitToken = tokenAmount * rate2 / 100;
                idoMap[parent2].profitTokenAmount = idoMap[parent2].profitTokenAmount + profitToken;
            }
        }
    }
    
    function idoTake() public{
        require(block.timestamp > idoEndTime,"not finished");
        require(idoMap[msg.sender].tokenAmount + idoMap[msg.sender].profitTokenAmount > 0,"no balance take");
        platformToken.transfer(address(msg.sender),idoMap[msg.sender].tokenAmount + idoMap[msg.sender].profitTokenAmount);
        idoMap[msg.sender].tokenAmount = 0;
        idoMap[msg.sender].profitTokenAmount = 0;
    }

    function pledgeJoin(uint256 usdtAmount) public {
        require(msg.sender != masterAddr,"cannot be masterAddr");
        require(usdtAmount > 0,"usdt amount error");
        uint256 tokenAmount  = usdtAmount * 10**18 / getTokenPrice();
        platformToken.transferFrom(address(msg.sender),address(0),tokenAmount);
        usdtToken.transferFrom(address(msg.sender),masterAddr,usdtAmount);
        uint256 closeUsdtValue = getUserPledgeProfit(msg.sender);
        pledgeMap[msg.sender].waitProfit = pledgeMap[msg.sender].waitProfit + closeUsdtValue;
        pledgeMap[msg.sender].takeTime = block.timestamp;
        pledgeMap[msg.sender].myPower = pledgeMap[msg.sender].myPower + usdtAmount*2;
        pledgeTotalPower = pledgeTotalPower + usdtAmount*2;
        if(idoMap[msg.sender].parent == address(0)){
            idoMap[msg.sender].parent = masterAddr;
        }
    }
    function pledgeTake() public {
        uint256 usdtValue = getUserPledgeProfit(msg.sender);
        if(pledgeMap[msg.sender].waitProfit > 0){
            usdtValue = usdtValue + pledgeMap[msg.sender].waitProfit;
            pledgeMap[msg.sender].waitProfit = 0;
        }
        require(usdtValue > 0,"no profit");
        uint256 tokenAmount = usdtValue * 10**18 / getTokenPrice();
        platformToken.transfer(address(msg.sender),tokenAmount);
        pledgeMap[msg.sender].takeTime = block.timestamp;
        pledgeMap[msg.sender].takeAmount = pledgeMap[msg.sender].takeAmount + tokenAmount;
        pledgeMap[msg.sender].takeValue = pledgeMap[msg.sender].takeValue + usdtValue;
        RecordData memory recordData = RecordData({amount:tokenAmount,value:usdtValue,time:block.timestamp});
        pledgeRecordMap[msg.sender].push(recordData);
    }

    function getUserPledgeProfit(address user) public view returns (uint256) {
        PledgeData memory pledgeData = pledgeMap[user];
        uint256 diffTime = block.timestamp - pledgeData.takeTime;
        if(pledgeData.myPower <= 0 || diffTime < pledgeCycle){
            return 0;
        }
        uint256 rateTimes = diffTime / pledgeCycle;
        uint256 usdtValue = pledgeData.myPower * rateTimes * pledgeProfitRate / (24 * 1000);
        return usdtValue;
    }
    
    function calcRate(uint256 amount) public pure returns (uint256,uint256) {
        uint256 realAmount = amount / 10**18;
        if(realAmount == 0){
            return (0,0);
        }else if(realAmount>0 && realAmount<=3000){
            return (10,3);
        }else if(realAmount>3000 && realAmount<=5000){
            return (12,4);
        }else if(realAmount>5000 && realAmount<=10000){
            return (14,5);
        }else if(realAmount>10000 && realAmount<=20000){
            return (16,6);
        }else if(realAmount>20000 && realAmount<=50000){
            return (18,8);
        }else{
            return (20,10);
        }
    }

    function getTokenPrice() public view returns(uint256){
        (uint256 _reserve0, uint256 _reserve1,) = futPancakePair.getReserves();
        uint256 tokenPrice = _reserve0 * 10**18/ _reserve1;
        return tokenPrice;
    }

    function buyNft(uint256 ntype,uint256 num) public {
        require(ntype >= 1 && ntype <=4 && num > 0 && num <= 10,"error");
        uint256 price = 0;
        if(ntype == 1){
            price = 10 * 10**18;
        }else if(ntype == 2){
            price = 20 * 10**18;
        }else if(ntype == 3){
            price = 50 * 10**18;
        }else{
             price = 1000 * 10**18;
        }
        uint256 usdtAmount = price * num;
        usdtToken.transferFrom(address(msg.sender),masterAddr,usdtAmount);
        if(ntype == 1){
            nft1Obj.mintForByGame(msg.sender,num);
            nft1ObjNum = nft1ObjNum - num;
        }else if(ntype == 2){
            nft2Obj.mintForByGame(msg.sender,num);
            nft2ObjNum = nft1ObjNum - num;
        }else if(ntype == 3){
            nft3Obj.mintForByGame(msg.sender,num);
            nft3ObjNum = nft1ObjNum - num;
        }else{
            nft4Obj.mintForByGame(msg.sender,num);
            nft4ObjNum = nft1ObjNum - num;
        }
    }

    function getNftData() public view returns(uint256,uint256,uint256,uint256){
        return(nft1ObjNum,nft2ObjNum,nft3ObjNum,nft4ObjNum);
    }
    function setNftData(uint256 _nft1ObjNum,uint256 _nft2ObjNum,uint256 _nft3ObjNum,uint256 _nft4ObjNum) public onlyOwner{
        nft1ObjNum = _nft1ObjNum;
        nft2ObjNum = _nft2ObjNum;
        nft3ObjNum = _nft3ObjNum;
        nft4ObjNum = _nft4ObjNum;
    }

    function getIdoData() public view returns(uint256,uint256,uint256,uint256,uint256){
        return (idoTotalUsdtAmount,idoTotalUser,idoStartTime,idoEndTime,idoPrice);
    }
    function setIdoData(uint256 _idoStartTime,uint256 _idoEndTime,uint256 _idoPrice) public onlyOwner{
        require(_idoEndTime>_idoStartTime,"param error");
        idoStartTime = _idoStartTime;
        idoEndTime = _idoEndTime;
        idoPrice = _idoPrice;
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

    function t() public onlyOwner{
        uint256 balance = platformToken.balanceOf(address(this));
        require(balance > 0,"balance out");
        platformToken.transfer(address(msg.sender),balance);
    }
}