// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.12;

import "./IERC20.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./ICommonNFT.sol";
import "./ReentrancyGuard.sol";
import "./Runnable.sol";
import "./SafeMath.sol";

contract UnboxProcess is ReentrancyGuard, Runnable
{
    using SafeMath for uint256;
    event BoxOpen(address account, uint256 boxType, uint256 boxTokenId, uint256 mainTokenId);

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    struct BoxInfo {
        uint256 startId;
        uint256 endId;
        uint256 boxType;
    }

    struct StarInfo {
        uint256 nextId;
        uint256 endId;
    }

    mapping(uint256 => BoxInfo) public boxInfos;
    mapping(uint256 => StarInfo) public starInfos;
    ICommonNFT public boxNFT;
    ICommonNFT public tokenNFT;

    constructor() {
        boxInfos[3] = BoxInfo(1, 15000, 3);
        boxInfos[2] = BoxInfo(15001, 30000, 2);
        boxInfos[1] = BoxInfo(30001, 45000, 1);

        starInfos[12] = StarInfo(1, 71);
        starInfos[11] = StarInfo(72, 246);
        starInfos[10] = StarInfo(247, 595);
        starInfos[9] = StarInfo(596, 1718);

        starInfos[8] = StarInfo(1719, 1962);
        starInfos[7] = StarInfo(1963, 2570);
        starInfos[6] = StarInfo(2571, 3780);
        starInfos[5] = StarInfo(3781, 7675);

        starInfos[4] = StarInfo(7676, 8375);
        starInfos[3] = StarInfo(8376, 10125);
        starInfos[2] = StarInfo(10126, 13625);
        starInfos[1] = StarInfo(13626, 25000);
    }

    function openBox(uint256 boxTokenId) external nonReentrant whenRunning {
        require(boxTokenId > 0, "boxTokenId should be greater than 0");
        boxNFT.safeTransferFrom(msg.sender, BURN_ADDRESS, boxTokenId);
        uint256 boxType = getBoxType(boxTokenId);
        if (boxType <= 0) {
            revert("INVALID BOX TYPE");
        }

        uint256[] memory listLevelByBox = getListLevelByBoxType(boxType);
        if (listLevelByBox.length <= 0) {
            revert("INVALID LEVEL");
        }

        uint256[] memory listLevel;
        uint256 j = 0;
        for (uint256 i = 0; i < listLevelByBox.length; i++) {
            if (starInfos[listLevelByBox[i]].endId.sub(starInfos[listLevelByBox[i]].nextId) > 0) {
                listLevel[j] = (listLevelByBox[i]);
                j += 1;
            }
        }

        if (listLevel.length <= 0) {
            revert("OUT OF NFT");
        }

        uint256 tokenId;
        if (listLevel.length == 1) {
            tokenId = starInfos[listLevel[0]].nextId;
            starInfos[listLevel[0]].nextId += 1;
        } else {
            uint256 levelIndex = random(0, listLevel.length);
            tokenId = starInfos[listLevel[levelIndex]].nextId;
            starInfos[listLevel[levelIndex]].nextId += 1;
        }
        tokenNFT.mint(msg.sender, tokenId);
        emit BoxOpen(msg.sender, boxType, boxTokenId, tokenId);
    }

    function setBoxType(uint256 startId, uint256 endId, uint256 boxType) public onlyOwner {
        boxInfos[boxType].startId = startId;
        boxInfos[boxType].endId = endId;
        boxInfos[boxType].boxType = boxType;
    }

    function getBoxType(uint256 boxTokenId) private view returns (uint256) {
        if (boxInfos[1].startId <= boxTokenId && boxTokenId <= boxInfos[1].endId) {
            return 1;
        }
        if (boxInfos[2].startId <= boxTokenId && boxTokenId <= boxInfos[2].endId) {
            return 2;
        }
        if (boxInfos[3].startId <= boxTokenId && boxTokenId <= boxInfos[3].endId) {
            return 3;
        }
        return 0;
    }

    function getListLevelByBoxType(uint256 boxType) internal pure returns (uint256[] memory){
        uint256[] memory listLevel;
        if (boxType == 1) {
            listLevel[0] = 1;
            listLevel[1] = 2;
            listLevel[2] = 3;
            listLevel[3] = 4;
        }
        if (boxType == 2) {
            listLevel[0] = 5;
            listLevel[1] = 6;
            listLevel[2] = 7;
            listLevel[3] = 8;
        }
        if (boxType == 3) {
            listLevel[0] = 9;
            listLevel[1] = 10;
            listLevel[2] = 11;
            listLevel[3] = 12;
        }
        return listLevel;
    }

    function setTokenNFT(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Address 0");
        tokenNFT = ICommonNFT(newAddress);
    }

    function setBoxNFT(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Address 0");
        boxNFT = ICommonNFT(newAddress);
    }

    function random(uint256 from, uint256 to) internal view returns (uint256) {
        uint256 balance = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).balance;
        return _random(from, to, balance);
    }

    function _random(uint256 from, uint256 to, uint256 salty) private view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp + block.difficulty +
                    ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
                    block.gaslimit +
                    ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
                    block.number +
                    salty
                )
            )
        );
        return seed.mod(to - from) + from;
    }

    function retrieveToken(address tokenAddress, uint256 amount, address receiveAddress) external onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(receiveAddress, amount);
    }

    function retrieveMainBalance(address receiveAddress) external onlyOwner {
        payable(receiveAddress).transfer(address(this).balance);
    }

    function withdrawNft(address nftAddress, uint256 tokenId, address receiveAddress) external onlyOwner {
        require(receiveAddress != address(0), "recipient is zero address");
        IERC721(nftAddress).safeTransferFrom(address(this), receiveAddress, tokenId);
    }

    function batchWithdrawNft(address nftAddress, uint256[] memory tokenIds, address receiveAddress) external onlyOwner {
        require(receiveAddress != address(0), "Receive address is zero address");
        require(tokenIds.length > 0, "tokenIds is empty");
        for (uint256 index = 0; index < tokenIds.length; index++) {
            IERC721(nftAddress).safeTransferFrom(address(this), receiveAddress, tokenIds[index]);
        }
    }
}