/**
 *Submitted for verification at BscScan.com on 2022-10-22
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
    uint256 public futNft1Num = 2000;
    address private masterAddr = 0x31C69e6791C51E3a21edfF6c257Fe3FFA1801B73;

    mapping(address => IdoData) public idoMap;
    bool public idoCanTake = false;

    uint256 private pledgeCycle = 3600;
    mapping(address => PledgeData) public pledgeMap;
    mapping(address => RecordData[]) public pledgeRecordMap;
    uint256 public pledgeProfitRate = 20;//1000

    uint256 private excInPrice = 96 * 10**13;
    uint256 private excInFee = 30;//1000
    uint256 private excOutPrice = 96 * 10**13;
    uint256 private excOutFee = 30;//1000
    uint256 private swapPoolAmount = 0;

    uint256 public excTotalUsdt = 0;
    uint256 public excTotalToken = 0;
    
    struct IdoData {
        uint256 futAmount;
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
    function bindParent(address parent) public {
        require(msg.sender != masterAddr,"cannot be masterAddr");
        require(checkParent(msg.sender,parent), "cannot bound");
        idoMap[msg.sender].parent = parent;
    }
    function idoTake() public {
        require(idoCanTake  == true && idoMap[msg.sender].futAmount > 0,"cannot take");
        futToken.transfer(address(msg.sender),idoMap[msg.sender].futAmount);
        idoMap[msg.sender].futAmount = 0;
    }
    function pledgeJoin(uint256 amount,uint256 ptype) public {
        require(msg.sender != masterAddr,"cannot be masterAddr");
        require(amount > 0,"usdt amount error");
        uint256 usdtAmount  = 0;
        uint256 futAmount = 0;
        if(ptype == 1){//U+token
            usdtAmount  = amount;
            futAmount = usdtAmount * 10**18 / excInPrice;
            futToken.transferFrom(address(msg.sender),address(0),futAmount);
        }else if(ptype == 2 || ptype == 3){
            require(pledgeMap[msg.sender].lockAmount > 0,"lock amount error");
            if(ptype == 2 && pledgeMap[msg.sender].lockAmount > futAmount){//part active
                futAmount = amount;
            }else{ //all active
                futAmount = pledgeMap[msg.sender].lockAmount;
            }
            usdtAmount = futAmount * excInPrice / 10**18;
            pledgeMap[msg.sender].lockAmount = pledgeMap[msg.sender].lockAmount - futAmount;
            pledgeMap[msg.sender].active = 1;
        }
        usdtToken.transferFrom(address(msg.sender),masterAddr,usdtAmount);

        uint256 closeUsdtValue = getUserPledgeProfit(msg.sender);
        pledgeMap[msg.sender].waitProfit = pledgeMap[msg.sender].waitProfit + closeUsdtValue;
        pledgeMap[msg.sender].takeTime = block.timestamp;

        pledgeMap[msg.sender].myPower = pledgeMap[msg.sender].myPower + usdtAmount*2;
        pledgeMap[msg.sender].totalInvest = pledgeMap[msg.sender].totalInvest + usdtAmount*2;
        if(idoMap[msg.sender].parent == address(0)){
            idoMap[msg.sender].parent = masterAddr;
        }

        address level1 = idoMap[msg.sender].parent;
        if(level1 != address(0)){
            uint256 closeValue = getUserPledgeProfit(level1);
            pledgeMap[level1].waitProfit = pledgeMap[level1].waitProfit + closeValue;
            pledgeMap[level1].takeTime = block.timestamp;
            uint256 rewardPower = usdtAmount * 2 * 500/10000;
            pledgeMap[level1].totalInvest = pledgeMap[level1].totalInvest + rewardPower;
            pledgeMap[level1].myPower = pledgeMap[level1].myPower + rewardPower;
            pledgeMap[level1].rewardPower = pledgeMap[level1].rewardPower + rewardPower;
        }
        address level2 = idoMap[level1].parent;
        if(level2 != address(0)){
            uint256 closeValue = getUserPledgeProfit(level2);
            pledgeMap[level2].waitProfit = pledgeMap[level2].waitProfit + closeValue;
            pledgeMap[level2].takeTime = block.timestamp;
            uint256 rewardPower = usdtAmount * 2 * 250/10000;
            pledgeMap[level2].totalInvest = pledgeMap[level2].totalInvest + rewardPower;
            pledgeMap[level2].myPower = pledgeMap[level2].myPower + rewardPower;
            pledgeMap[level2].rewardPower = pledgeMap[level2].rewardPower + rewardPower;
        }
        address level3 = idoMap[level2].parent;
        if(level3 != address(0)){
            uint256 closeValue = getUserPledgeProfit(level3);
            pledgeMap[level3].waitProfit = pledgeMap[level3].waitProfit + closeValue;
            pledgeMap[level3].takeTime = block.timestamp;
            uint256 rewardPower = usdtAmount * 2 * 125/10000;
            pledgeMap[level3].totalInvest = pledgeMap[level3].totalInvest + rewardPower;
            pledgeMap[level3].myPower = pledgeMap[level3].myPower + rewardPower;
            pledgeMap[level3].rewardPower = pledgeMap[level3].rewardPower + rewardPower;
        }
    }
    function pledgeTake() public {
        uint256 usdtValue = getUserPledgeProfit(msg.sender);
        if(pledgeMap[msg.sender].waitProfit > 0){
            usdtValue = usdtValue + pledgeMap[msg.sender].waitProfit;
            pledgeMap[msg.sender].waitProfit = 0;
        }
        require(usdtValue > 0,"no profit");
        uint256 futAmount = usdtValue * 10**18 / excInPrice;
        futToken.transfer(address(msg.sender),futAmount);
        pledgeMap[msg.sender].takeTime = block.timestamp;
        pledgeMap[msg.sender].takeAmount = pledgeMap[msg.sender].takeAmount + futAmount;
        pledgeMap[msg.sender].takeValue = pledgeMap[msg.sender].takeValue + usdtValue;
        if(pledgeMap[msg.sender].takeValue >= pledgeMap[msg.sender].totalInvest * 4){
            pledgeMap[msg.sender].myPower = 0;
        }else{
            if(pledgeMap[msg.sender].myPower > usdtValue / 4){
                pledgeMap[msg.sender].myPower = pledgeMap[msg.sender].myPower - usdtValue / 4;
            }else{
                pledgeMap[msg.sender].myPower = 0;
            }
        }
        RecordData memory recordData = RecordData({amount:futAmount,value:usdtValue,time:block.timestamp});
        pledgeRecordMap[msg.sender].push(recordData);
    }
    function pledgeOut() public {
        require(pledgeMap[msg.sender].lockValue > 0 && pledgeMap[msg.sender].active == 0 && (block.timestamp - pledgeMap[msg.sender].lockTime > 86400*365),"cannot out");
        uint256 futAmount = pledgeMap[msg.sender].lockValue * 2 * 10**18 / excInPrice;
        futToken.transfer(address(msg.sender),futAmount);
        RecordData memory recordData = RecordData({amount:futAmount,value:pledgeMap[msg.sender].lockValue * 2,time:block.timestamp});
        pledgeRecordMap[msg.sender].push(recordData);
    }
    function getUserPledgeProfit(address user) public view returns (uint256) {
        PledgeData memory pledgeData = pledgeMap[user];
        uint256 diffTime = block.timestamp - pledgeData.takeTime;
        if(pledgeData.myPower <= 0 || diffTime < pledgeCycle || pledgeData.takeValue >= pledgeData.totalInvest * 4){
            return 0;
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
        uint256 realMyPower = pledgeData.myPower * (additionRate + 100) / 100;
        uint256 usdtValue = realMyPower * rateTimes * pledgeProfitRate / (24 * 1000);
        if(pledgeData.takeValue + usdtValue >= pledgeData.totalInvest * 4){
            usdtValue = pledgeData.totalInvest * 4 - pledgeData.takeValue;
        }
        return usdtValue;
    }
    function buyNft() public {
        require(futNft1Num > 0,"NFT1 sent out");
        require(idoMap[msg.sender].nft1Num < 1,"Limit one purchase");
        usdtToken.transferFrom(address(msg.sender),masterAddr,500 * 10**18);
        idoMap[msg.sender].nft1Num = 1;
        futNft1.mintForByGame(msg.sender,1);
        futNft1Num = futNft1Num - 1;
    }
    function setIdoData(bool _idoCanTake) public onlyOwner{
        idoCanTake = _idoCanTake;
    }
    function setPledgeData(uint256 _pledgeProfitRate) public onlyOwner{
        pledgeProfitRate = _pledgeProfitRate;
    }
    function setNftData(uint256 _futNft1Num) public onlyOwner{
        futNft1Num = _futNft1Num;
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

    function getExchangeParam() public view returns (uint256,uint256,uint256,uint256,uint256){
        return (excInPrice,excInFee,excOutPrice,excOutFee,swapPoolAmount);
    }

    function setExchangeParam(uint256 _excInPrice,uint256 _excInFee,uint256 _excOutPrice,uint256 _excOutFee,uint256 _swapPoolAmount) external onlyOwner {
        require(_excInFee >= 0 && _excInFee <= 1000 && _excOutFee >= 0 && _excOutFee <= 1000,"_excInFee or _excOutFee error");
        require(_excInPrice > 0 && _excOutPrice > 0,"_excInPrice or _excOutPrice error");
        excInPrice = _excInPrice;
        excInFee = _excInFee;
        excOutPrice = _excOutPrice;
        excOutFee = _excOutFee;
        swapPoolAmount = _swapPoolAmount;
    }

    function exchange(uint256 exType,uint256 amount) public {
        require(amount>0, "amount error");
        if(exType == 1){
            excTotalUsdt = excTotalUsdt + amount;
            usdtToken.transferFrom(address(msg.sender),masterAddr,amount);
            uint256 usdtAmount = amount;
            if(excInFee > 0){
               usdtAmount = (1000 - excInFee) * amount / 1000;
            }
            uint256 tokenAmount = usdtAmount * 10**18 / excInPrice;
            futToken.transfer(address(msg.sender),tokenAmount);
        }else{
            excTotalToken = excTotalToken + amount;
            futToken.transferFrom(address(msg.sender),masterAddr,amount);
            uint256 tokenAmount = amount;
            if(excOutFee > 0){
               tokenAmount = (1000 - excOutFee) * amount / 1000;
            }
            uint256 usdtAmount = tokenAmount * excOutPrice / 10**18;
            usdtToken.transfer(address(msg.sender),usdtAmount);
        }
    }
    
    function init(address target,uint256 futAmount,uint256 nft1Num,uint256 nft2Num,uint256 nft3Num,address parent) public onlyOwner {
        idoMap[target].futAmount = futAmount;
        idoMap[target].nft1Num = nft1Num;
        idoMap[target].nft3Num = nft3Num;
        idoMap[target].nft2Num = nft2Num;
        idoMap[target].parent = parent;
    }

    function init2(address target,uint256 myPower,uint256 takeTime,uint256 takeAmount,uint256 takeValue,uint256 lockAmount,uint256 lockValue,uint256 active,uint256 totalInvest,uint256 waitProfit) public onlyOwner {
        pledgeMap[target].myPower = myPower;
        pledgeMap[target].takeTime = takeTime;
        pledgeMap[target].takeAmount = takeAmount;
        pledgeMap[target].takeValue = takeValue;
        pledgeMap[target].lockTime = block.timestamp;
        pledgeMap[target].lockAmount = lockAmount;
        pledgeMap[target].lockValue = lockValue;
        pledgeMap[target].active = active;
        pledgeMap[target].totalInvest = totalInvest;
        pledgeMap[target].waitProfit = waitProfit;
    }
}