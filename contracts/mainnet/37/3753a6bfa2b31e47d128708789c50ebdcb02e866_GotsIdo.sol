/**
 *Submitted for verification at BscScan.com on 2022-08-07
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

contract GotsIdo is Ownable {
    using SafeMath for uint256;

    IBEP20 public gotsToken = IBEP20(0x750fc4A5A16678B3303a51fC1A511C8D5f89Fc86);
    IBEP20 public usdtToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IERC721 public gotsNft1 = IERC721(0xEb0B2E2C0f041d4F3D91F4A436A316B99536D6E7);
    IERC721 public gotsNft2 = IERC721(0x3AECAEcd33bC42c88EE2E401DD670ECe5e205838);
    IERC721 public gotsNft3 = IERC721(0x173d538328A031F29A226bDb38a0C2FAA50D9d34);
    address private devAddress = 0xaEF50344Edc1AB084717986b91aAFbB52ea9cba7;

    uint256[] public idoItems = [50,100,200,500,1000];
    uint256[] public boxOpenRate = [3,5,8,12,20];
    uint256[] public gotsAmountConfig = [2500,5000,10000,65000,150000];
    uint256[] public inviteNumConf = [20,15,10,5,10];
    uint256[] public inviteProfitRate = [10,8,6,5,5];
    uint256 public idoTotal = 0;
    uint256 public idoUser = 0;
    uint256 public releaseTimeLimit = 864000;
    uint256 public giveProfit = 10 * 10**18;

    uint256 public idoStartTime = 0;
    uint256 public idoEndTime = 0;
    uint256 public gotsNft1ForIdo = 1500;
    uint256 public gotsNft2ForIdo = 250;
    uint256 public gotsNft3ForIdo = 50;
    uint256 public gotsNft1ForBox = 500;

    mapping(address => IdoData) public idoMap;
    mapping(address => IdoRecord[]) public idoRecordMap;
    mapping(address => InviteData) public inviteMap;
    mapping(address => BoxRecord[]) public boxRecordMap;
   
    struct IdoData {
        bool isConf;
        uint256 idoAmount;
        uint256 idoLevel;
        uint256 idoTime;
        uint256 idoGotsAmount;
        uint256 takeAmount;
        uint256 lockedAmount;
        uint256 releaseRate;
        address parent;
    }

    struct IdoRecord {
        uint256 takeAmount;
        uint256 takeTime;
    }

    struct InviteData {
        uint256 totalAmount;
        uint256 totalCount;
        uint256 level1Sum;
        uint256 level2Sum;
        uint256 level3Sum;
        uint256 level4Sum;
        uint256 level5Sum;
        uint256 boxProfit;
        uint256 boxOpen;
        uint256 nftProfit;
        uint256 gotsProfit;
        uint256 gotsProfitTake;
    }
    
    struct BoxRecord {
        uint256 prizeType;
        uint256 prizeAmount;
        uint256 openTime;
    }

    function join(address ref,uint256 idoLevel) public{
        require(idoLevel > 0 && idoLevel<=5,"params error");
        require(block.timestamp > idoStartTime && block.timestamp < idoEndTime,"out ido time");
        require(!idoMap[msg.sender].isConf,"has join");

        uint256 usdtAmount = idoItems[idoLevel-1].mul(10**18);
        usdtToken.transferFrom(address(msg.sender),devAddress,usdtAmount);

        uint256 gotsAmount = gotsAmountConfig[idoLevel-1].mul(10**18);
        uint256 lockedAmount = 0;
        uint256 releaseRate = 100;
        if(idoLevel>3){
            lockedAmount = gotsAmount.div(2);
            releaseRate = 10;
        }
        idoTotal = idoTotal + usdtAmount;
        idoUser = idoUser + 1;
        if(ref == msg.sender || ref == address(0)) {
            ref = devAddress;
        }
        IdoData memory idoData = IdoData({
            isConf:true,
            idoAmount:usdtAmount,
            idoLevel:idoLevel,
            idoTime:block.timestamp,
            idoGotsAmount:gotsAmount,
            takeAmount:0,
            lockedAmount:lockedAmount,
            releaseRate:releaseRate,
            parent:ref
        });
        idoMap[msg.sender] = idoData;
        inviteMap[msg.sender].gotsProfit = giveProfit;
        inviteMap[msg.sender].boxProfit = 1;

        inviteMap[ref].totalCount = inviteMap[ref].totalCount + 1;
        inviteMap[ref].totalAmount = inviteMap[ref].totalAmount + usdtAmount;
        if(idoLevel == 1){
            inviteMap[ref].level1Sum = inviteMap[ref].level1Sum + 1;
        }else if(idoLevel == 2){
            inviteMap[ref].level2Sum = inviteMap[ref].level2Sum + 1;
        }else if(idoLevel == 3){
            inviteMap[ref].level3Sum = inviteMap[ref].level3Sum + 1;
        }else if(idoLevel == 4){
            inviteMap[ref].level4Sum = inviteMap[ref].level4Sum + 1;
        }else{
            inviteMap[ref].level5Sum = inviteMap[ref].level5Sum + 1;
        }

        profitInvite(ref,gotsAmount);
    }

    function profitInvite(address ref,uint256 gotsAmount) public {
        uint256 idoLevel = idoMap[ref].idoLevel;
        if(idoLevel <= 0){
            return;
        }
        inviteMap[ref].gotsProfit = inviteMap[ref].gotsProfit + giveProfit;

        uint256 profitAmount = inviteProfitRate[idoLevel-1] * gotsAmount/ 100;
        inviteMap[ref].gotsProfit = inviteMap[ref].gotsProfit + profitAmount;

        if(inviteMap[ref].totalCount == inviteNumConf[idoLevel - 1]){
            inviteMap[ref].boxProfit = inviteMap[ref].boxProfit + 1;
            if(idoLevel <= 3 && gotsNft1ForIdo > 0){
                gotsNft1.mintForByGame(ref,1);
                inviteMap[ref].nftProfit = inviteMap[ref].nftProfit + 1;
                gotsNft1ForIdo = gotsNft1ForIdo - 1;
            }else if(idoLevel == 4 && gotsNft2ForIdo > 0){
                gotsNft2.mintForByGame(ref,1);
                inviteMap[ref].nftProfit = inviteMap[ref].nftProfit + 1;
                gotsNft2ForIdo = gotsNft2ForIdo - 1;
            }else if(idoLevel == 5 && gotsNft3ForIdo > 0){
                gotsNft3.mintForByGame(ref,1);
                inviteMap[ref].nftProfit = inviteMap[ref].nftProfit + 1;
                gotsNft3ForIdo = gotsNft3ForIdo - 1;
            }

            if(idoLevel > 3){
                idoMap[msg.sender].releaseRate = 20;
            }
        }
    }

    function openBox() public {
        require(inviteMap[msg.sender].boxProfit > inviteMap[msg.sender].boxOpen,"no box");
        uint256 prizeType = 0;
        if(gotsNft1ForBox > 0){
            uint256 myOpenRate = boxOpenRate[idoMap[msg.sender].idoLevel-1];
            uint256 openRandNum = rand(100);
            if(openRandNum <= myOpenRate){
                prizeType = 1;
                gotsNft1.mintForByGame(msg.sender,1);
                gotsNft1ForBox = gotsNft1ForBox - 1;
            }
        }
        BoxRecord memory boxRecord = BoxRecord({prizeType:0,prizeAmount:1,openTime:block.timestamp});
        boxRecordMap[msg.sender].push(boxRecord);
        inviteMap[msg.sender].boxOpen = inviteMap[msg.sender].boxOpen + 1;
    }

    function rand(uint256 length) public view returns(uint256) {
        require(length > 0,"rand error");
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        uint256 result = random % length;
        return result +1;
    }

    function takeIdoProfit() public {
        uint256 leaveReleaseAmount = getLeaveReleaseAmount(msg.sender);
        uint256 leaveInviteProfit = getLeaveInviteProfit(msg.sender);
        uint256 nowTakeAmount = leaveReleaseAmount + leaveInviteProfit;
        require(nowTakeAmount> 0,"no profit");
        gotsToken.transfer(address(msg.sender),nowTakeAmount);
        idoMap[msg.sender].takeAmount = idoMap[msg.sender].takeAmount + leaveReleaseAmount;
        inviteMap[msg.sender].gotsProfitTake = inviteMap[msg.sender].gotsProfitTake + leaveInviteProfit;
        IdoRecord memory idoRecord = IdoRecord({takeAmount:nowTakeAmount,takeTime:block.timestamp});
        idoRecordMap[msg.sender].push(idoRecord);
    }

    function getLeaveReleaseAmount(address userAddress) public view returns (uint256) {
        IdoData memory idoData = idoMap[userAddress];
        if(block.timestamp < idoEndTime || !idoData.isConf){
            return 0;
        }else if(idoData.takeAmount >= idoData.idoGotsAmount){
            return 0;
        }else if(idoData.idoLevel <= 3){
            return idoData.idoGotsAmount;
        }else{
            uint256 totalReleaseRate = 50;
            uint256 releaseTimes = (block.timestamp - idoEndTime) / releaseTimeLimit;
            if(releaseTimes >= 1){
                totalReleaseRate = totalReleaseRate + releaseTimes * idoData.releaseRate;
                if(totalReleaseRate > 100){
                    totalReleaseRate = 100;
                }
            }
            uint256 nowReleaseAmount = totalReleaseRate * idoData.idoGotsAmount / 100;
            uint256 leaveReleaseAmount = 0;
            if(nowReleaseAmount > idoData.takeAmount){
                leaveReleaseAmount = nowReleaseAmount - idoData.takeAmount;
            }
            return leaveReleaseAmount;
        }
    }

    function getLeaveInviteProfit(address userAddress) public view returns (uint256) {
        IdoData memory idoData = idoMap[userAddress];
        InviteData memory inviteData = inviteMap[userAddress];
        if(block.timestamp < idoEndTime || !idoData.isConf){
            return 0;
        }else if(inviteData.gotsProfitTake >= inviteData.gotsProfit){
            return 0;
        }else{
            return inviteData.gotsProfit - inviteData.gotsProfitTake;
        }
    }

    function getUserInfo(address userAddress) public view returns (IdoData memory){
        return idoMap[userAddress];
    }

    function getIdoParam() public view returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256){
        return (idoTotal,idoUser,idoStartTime,idoEndTime,gotsNft1ForIdo,gotsNft2ForIdo,gotsNft3ForIdo,gotsNft1ForBox);
    }

    function getUserIdoRecord(address userAddress) public view returns (IdoRecord[] memory){
        return idoRecordMap[userAddress];
    }

    function getUserBoxRecord(address userAddress) public view returns (BoxRecord[] memory){
        return boxRecordMap[userAddress];
    }

    function getUserInviteData(address userAddress) public view returns (InviteData memory){
        return inviteMap[userAddress];
    }

    function setIdoParam(uint256 _idoStartTime) public onlyOwner{
        idoStartTime = _idoStartTime;
        idoEndTime = _idoStartTime + releaseTimeLimit;
    }
}