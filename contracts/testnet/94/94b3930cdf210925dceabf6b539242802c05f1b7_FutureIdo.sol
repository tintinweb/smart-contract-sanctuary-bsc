/**
 *Submitted for verification at BscScan.com on 2022-08-13
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
}

contract FutureIdo is Ownable {
    using SafeMath for uint256;

    IBEP20 public futToken = IBEP20(0xe730A1Cdd3a9768d59375775B21990A743c31614);
    IBEP20 public usdtToken = IBEP20(0xb5Af8648EfF53FdAA680552Ef564c1F79d321a34);
    IERC721 public futNft1 = IERC721(0x377685D5A638Ac88982352eE8d0F44457D2e809C);
    IERC721 public futNft2 = IERC721(0x4910D59491C7fB4e63F97afA9E7BA2220B944E95);
    IERC721 public futNft3 = IERC721(0xEe080CF77512A1E81632BB1ef98a9dc7d6bF75BE);
    IPancakePair futPancakePair = IPancakePair(0x8751A14EB094eECddE7073dcF96A2d8E7a514560);
    address private receiveAddr = 0xA41d4e94861D5415B9070F964f98D290E3CbD95B;
    uint256 public futNftNum = 1000;
    uint256 public futNft1Price = 500 * 10**18;//IDO产品USDT金额 288U
    mapping(address => uint256) public futNft1BuyMap;

    uint256 public nodePrice = 288 * 10**18;//IDO产品USDT金额 288U
    uint256 public futIdoPrice = 1 * 10**18 / 10;//IDO价格0.1U
    uint256 public idoTotalAmount = 0;//IDO总金额
    uint256 public idoTotalNode = 0;//IDO总节点数
    uint256 public idoTotalUser = 0;//IDO总人数
    uint256 public idoStartTime = 0;
    uint256 public idoEndTime = 0;

    mapping(address => PledgeData) public pledgeMap;
    mapping(address => RecordData[]) public pledgeRecordMap;
    uint256 public pledgeTotalPower = 0;//质押总算力
    uint256 public pledgeTotalRewardPower = 0;//质押总算力
    uint256 public pledgeTotalUser = 0;//质押总人数
    uint256 public dailyOutput = 1000 * 10**18;//日总产量1000
    mapping(address => IdoData) public idoMap;
    
    struct IdoData {
        uint256 nodeNum;//节点数量
        uint256 nodeLevel;//节点等级
        uint256 inviteNodeNum;//邀请的节点总数量
        uint256 futGetAmount;//获得FUT总金额
        uint256 nft1Num;//NFT奖励
        uint256 nft2Num;//NFT奖励
        uint256 nft3Num;//NFT奖励
        address parent;
    }

    struct PledgeData {
        uint256 myPower;//我的算力
        uint256 rewardPower;//奖励算力
        uint256 takeTime;//最近领取时间
        uint256 totalTake;//总收益
    }

    struct RecordData {
        uint256 amount;
        uint256 time;
    }

    function join(address ref,uint256 nodeNum) public{
        require(nodeNum <= 5,"param error");
        require(block.timestamp > idoStartTime && block.timestamp < idoEndTime,"out ido time");
        require(idoMap[msg.sender].nodeNum + nodeNum <= 5,"out node num range");

        //扣除USDT
        uint256 usdtAmount = nodeNum * nodePrice;
        usdtToken.transferFrom(address(msg.sender),receiveAddr,usdtAmount);

        //获得FUT
        uint256 futAmount = usdtAmount * 10**18 / futIdoPrice;
        futToken.transfer(address(msg.sender),futAmount);

        //如果是新增
        if(idoMap[msg.sender].nodeNum == 0){
            //总人数增加
            idoTotalUser = idoTotalUser + 1;
            if(ref == msg.sender || ref == address(0) || idoMap[ref].nodeNum <= 0) {
                ref = receiveAddr;
            }
            idoMap[msg.sender].parent = ref;
            idoMap[msg.sender].nodeLevel = 1;
        }

        //更新节点数、消耗USDT数量、获得FUT数量
        idoMap[msg.sender].nodeNum = idoMap[msg.sender].nodeNum + nodeNum;
        idoMap[msg.sender].futGetAmount = idoMap[msg.sender].futGetAmount + futAmount;

        //增加IDO总金额、总节点、总人数
        idoTotalAmount = idoTotalAmount + usdtAmount;
        idoTotalNode = idoTotalNode + nodeNum;

        //更新直推数据
        idoMap[ref].inviteNodeNum = idoMap[ref].inviteNodeNum + nodeNum;
        //给直推奖励10%的币
        if(idoMap[ref].nodeLevel > 0){
            futToken.transfer(address(ref),futAmount/10);
        }
        //给直推升级，并奖励NFT
        if(idoMap[ref].nodeLevel == 1 && idoMap[ref].inviteNodeNum >= 10){
            idoMap[ref].nodeLevel = 2;
            idoMap[ref].nft2Num = 1;
            futNft2.mintForByGame(ref,1);
        }
    }

    function pledgeJoin(address ref,uint256 usdtAmount) public{
        require(usdtAmount > 0,"params error");
        uint256 futPrice = calcFutPrice();
        uint256 futAmount = usdtAmount * 10**18 / futPrice;

        futToken.transferFrom(address(msg.sender),address(this),futAmount);
        usdtToken.transferFrom(address(msg.sender),receiveAddr,usdtAmount);

        pledgeTotalPower = pledgeTotalPower+usdtAmount*2;
        if(pledgeMap[msg.sender].myPower <= 0){
            pledgeTotalUser = pledgeTotalUser + 1;
        }
        pledgeMap[msg.sender].myPower = pledgeMap[msg.sender].myPower+usdtAmount*2;
        address level1;
        if(idoMap[msg.sender].parent == address(0)){
            if(idoMap[ref].nodeNum > 0){
                level1 = ref;
            }
        }else{
            level1 = idoMap[msg.sender].parent;
        }
        if(level1 != address(0)){
            uint256 rewardPower = usdtAmount*2*20/100;
            pledgeMap[level1].rewardPower = pledgeMap[level1].rewardPower + rewardPower;
            pledgeTotalRewardPower = pledgeTotalRewardPower + rewardPower;
        }
        address level2 = idoMap[level1].parent;
        if(level2 != address(0)){
            uint256 rewardPower = usdtAmount*2*10/100;
            pledgeMap[level2].rewardPower = pledgeMap[level2].rewardPower + rewardPower;
            pledgeTotalRewardPower = pledgeTotalRewardPower + rewardPower;
        }
        address level3 = idoMap[level2].parent;
        if(level3 != address(0)){
            uint256 rewardPower = usdtAmount*2*5/100;
            pledgeMap[level3].rewardPower = pledgeMap[level3].rewardPower + rewardPower;
            pledgeTotalRewardPower = pledgeTotalRewardPower + rewardPower;
        }
    }

    function pledgeTake() public {
        require(block.timestamp - pledgeMap[msg.sender].takeTime >= 86400,"Less than one day");
        uint256 additionRate = 0;
        if(idoMap[msg.sender].nft3Num > 0){
            additionRate = 50;
        }else if(idoMap[msg.sender].nft2Num > 0){
            additionRate = 40;
        }else if(idoMap[msg.sender].nft1Num > 0){
            additionRate = 30;
        }
        uint256 realMyPower = pledgeMap[msg.sender].myPower * (additionRate+100) / 100 + pledgeMap[msg.sender].rewardPower;
        uint256 realTotalPower = pledgeTotalPower + pledgeTotalRewardPower;
        uint256 takeAmount = dailyOutput * realMyPower / realTotalPower;
        futToken.transfer(address(msg.sender),takeAmount);
        pledgeMap[msg.sender].takeTime = block.timestamp;
        pledgeMap[msg.sender].totalTake = pledgeMap[msg.sender].totalTake + takeAmount;
        RecordData memory recordData = RecordData({amount:takeAmount,time:block.timestamp});
        pledgeRecordMap[msg.sender].push(recordData);
    }

    function calcFutPrice() public view returns(uint256){
        (uint256 _reserve0, uint256 _reserve1,) = futPancakePair.getReserves();
        uint256 tokenPrice =  _reserve0*1000000000000000000/_reserve1;
        return tokenPrice;
    }

    function getUserIdoData(address userAddress) public view returns(IdoData memory){
        return idoMap[userAddress];
    }

    function buyNft() public {
        require(futNftNum > 0,"NFT balance out");
        require(futNft1BuyMap[msg.sender]  == 0,"limit buy one");
        usdtToken.transferFrom(address(msg.sender),receiveAddr,futNft1Price);
        idoMap[msg.sender].nft1Num = 1;
        futNft1.mintForByGame(msg.sender,1);
        futNftNum = futNftNum - 1;
        futNft1BuyMap[msg.sender] = futNft1BuyMap[msg.sender] + 1;
    }

    function addCreatorNode(address target) public {
        require(idoMap[target].nodeNum == 0,"is node");
        idoMap[target].nodeNum = 5;
        idoMap[target].parent = receiveAddr;
        idoMap[target].nodeLevel = 3;
        idoMap[target].nft3Num = 1;
        futNft3.mintForByGame(target,1);
    }

    function setIdoParam(uint256 _idoStartTime,uint256 _idoEndTime) public onlyOwner{
        require(_idoEndTime>_idoStartTime,"end time must big than start time");
        idoStartTime = _idoStartTime;
        idoEndTime = _idoEndTime;
    }
}