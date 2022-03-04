// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.12;

import "./IERC20.sol";
import "./Ownable.sol";
import "./Runnable.sol";
import "./Math.sol";
import "./ICommonNFT.sol";

contract SellBox is Runnable {

    IERC20 public paymentToken;
    ICommonNFT public boxNFT;
    address public projectAddress;

    struct BoxInfo {
        uint256 nextId;
        uint256 endId;
        uint256 boxType;
    }

    event BuyBox(address userAddress, uint256 tokenId, uint256 tokenAmount, address tokenAddress);

    mapping(uint256 => BoxInfo) public boxInfos;
    mapping(uint256 => uint256) public boxPrice;

    struct BoxRecord {
        uint256 timestamp;
        uint256 tokenId;
    }

    mapping(address => BoxRecord[]) private boxRecords;
    uint256 private round = 1;
    // round => (box type => times)
    mapping(uint256 => mapping(uint256 => uint256)) private _maxTimes;
    // round => boxType => userAddress => times
    mapping(uint256 => mapping(uint256 => mapping(address => uint256))) _roundAddressTimes;

    uint256 private totalNFT;

    constructor() {

        boxInfos[3] = BoxInfo(1, 15000, 3);
        boxInfos[2] = BoxInfo(15001, 30000, 2);
        boxInfos[1] = BoxInfo(30001, 45000, 1);

        boxPrice[3] = 384 * (10 ** 18);
        boxPrice[2] = 224 * (10 ** 18);
        boxPrice[1] = 64 * (10 ** 18);

        _maxTimes[1][1] = 5;
        _maxTimes[1][2] = 3;
        _maxTimes[1][3] = 1;

        _maxTimes[2][1] = 3;
        _maxTimes[2][2] = 2;
        _maxTimes[2][3] = 1;

        _maxTimes[3][1] = 1;
        _maxTimes[3][2] = 1;
        _maxTimes[3][3] = 1;
    }

    function buyStandardBox() public whenRunning {
        buyBox(1);
    }

    function buyMediumBox() public whenRunning {
        buyBox(2);
    }

    function buyExclusiveBox() public whenRunning {
        buyBox(3);
    }

    function buyBox(uint256 boxType) private {
        uint256 currentTime = _roundAddressTimes[round][boxType][msg.sender]++;
        require(currentTime < _maxTimes[round][boxType], "EXCEED MAX TIMES");

        if (boxInfos[boxType].endId < boxInfos[boxType].nextId) {
            revert("OUT OF BOX");
        }
        getBox(boxType, boxInfos[boxType].nextId);
        totalNFT += 1;
    }

    function getBox(uint256 boxType, uint256 tokenId) private {
        uint256 price = boxPrice[boxType];
        paymentToken.transferFrom(msg.sender, projectAddress, price);
        boxNFT.mint(msg.sender, tokenId);
        boxInfos[boxType].nextId += 1;
        boxRecords[msg.sender].push(BoxRecord(uint256(block.timestamp), uint256(tokenId)));
        emit BuyBox(msg.sender, tokenId, price, address(paymentToken));
    }

    function setBoxNFT(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Address 0");
        boxNFT = ICommonNFT(newAddress);
    }

    function setPaymentToken(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Address 0");
        paymentToken = IERC20(newAddress);
    }

    function setProjectAddress(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Address 0");
        projectAddress = newAddress;
    }

    function setPrice(uint256 boxType, uint256 newPrice) public onlyOwner {
        boxPrice[boxType] = newPrice;
    }

    function getPrice() public view returns (uint256, uint256, uint256) {
        return (boxPrice[1], boxPrice[2], boxPrice[3]);
    }

    function setBoxInfo(uint256 boxType, uint256 newNextId, uint256 newEnd) public onlyOwner {
        boxInfos[boxType].nextId = newNextId;
        boxInfos[boxType].endId = newEnd;
    }

    function getBoxInfo(uint256 boxType) public view returns (uint256, uint256, uint256){
        return (boxInfos[boxType].nextId, boxInfos[boxType].endId, boxInfos[boxType].boxType);
    }

    function setRound(uint256 newRound) public onlyOwner {
        round = newRound;
    }

    function roundInfo() public view returns (uint256, uint256, uint256, uint256, uint256) {
        return (totalNFT, round, _maxTimes[round][1], _maxTimes[round][2], _maxTimes[round][3]);
    }

    function setRoundTimes(uint256 roundNumber, uint256 boxType, uint256 newMaxTimes) public onlyOwner {
        _maxTimes[roundNumber][boxType] = newMaxTimes;
    }

    function getBoxesByUserByPage(address user, uint256 pageNum, uint256 pageSize) public view returns (uint256[] memory timestamps, uint256[] memory tokenIds, uint256 total) {
        BoxRecord[] memory rs = boxRecords[user];
        total = rs.length;
        uint256 from = pageNum * pageSize;
        if (total <= from) {
            return (new uint256[](0), new uint256[](0), total);
        }

        uint256 minNum = Math.min(total - from, pageSize);
        from = total - from - 1;

        timestamps = new uint256[](minNum);
        tokenIds = new uint256[](minNum);

        for (uint256 i = 0; i < minNum; i++) {
            timestamps[i] = uint256(rs[from].timestamp);
            tokenIds[i] = uint256(rs[from--].tokenId);
        }
    }

    function getRemainAmount() public view returns (uint256 standard, uint256 medium, uint256 exclusive){
        if (boxInfos[1].nextId > boxInfos[1].endId) {
            standard = 0;
        } else {
            standard = boxInfos[1].endId - boxInfos[1].nextId;
        }

        if (boxInfos[2].nextId > boxInfos[2].endId) {
            medium = 0;
        } else {
            medium = boxInfos[2].endId - boxInfos[2].nextId;
        }

        if (boxInfos[3].nextId > boxInfos[3].endId) {
            exclusive = 0;
        } else {
            exclusive = boxInfos[3].endId - boxInfos[3].nextId;
        }
    }

    function getUserRoundTimes(uint256 roundNumber, uint256 boxType, address userAddress) public view returns (uint256) {
        return _roundAddressTimes[roundNumber][boxType][userAddress];
    }

    function retrieveToken(address tokenAddress, uint256 amount, address receiveAddress) external onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(receiveAddress, amount);
    }

    function retrieveMainBalance(address receiveAddress) external onlyOwner {
        payable(receiveAddress).transfer(address(this).balance);
    }

    function withdrawNft(address nftAddress, uint256 tokenId, address receiveAddress) external onlyOwner {
        require(receiveAddress != address(0), "recipient is zero address");
        ICommonNFT(nftAddress).safeTransferFrom(address(this), receiveAddress, tokenId);
    }

    function batchWithdrawNft(address nftAddress, uint256[] memory tokenIds, address receiveAddress) external onlyOwner {
        require(receiveAddress != address(0), "Receive address is zero address");
        require(tokenIds.length > 0, "tokenIds is empty");
        for (uint256 index = 0; index < tokenIds.length; index++) {
            ICommonNFT(nftAddress).safeTransferFrom(address(this), receiveAddress, tokenIds[index]);
        }
    }
}