// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./Callerable.sol";

contract NFTFarmLand is ERC721, Callerable {

    using Address for address;
    using Strings for uint256;

    uint256 private constant max_land_number = 80000;
    uint256 private currentTokenId;

    struct LandProperty {
        uint256 area;//bigger area means bigger volume
        uint256 fertility;//high fertility means high apy, default to the same high-level, 3-high, 2-medium, 1-low
        string picture;
    }

    //land price list
    uint256 [] private land_price_list;

    //land picture list
    string [] private land_picture_list;

    //sow limitation
    struct LimitData {
        uint256 min;
        uint256 max;
    }
    mapping(uint256 => LimitData) sow_limitation_list;

    //land container
    //key: tokenId => LandProperty
    mapping(uint256 => LandProperty) mapLandProperty;

    constructor(string memory name_, string memory symbol_, address _auth) Callerable(_auth) ERC721(name_, symbol_) {
        land_price_list = [100, 1001, 5001, 10001, 20001, 50001, 100001];
        land_picture_list = [
            "", 
            "",
            "",
            "",
            "",
            "",
            ""];
        sow_limitation_list[0] = LimitData(100, 1000);
        sow_limitation_list[1] = LimitData(1001, 5000);
        sow_limitation_list[2] = LimitData(5001, 10000);
        sow_limitation_list[3] = LimitData(10001, 20000);
        sow_limitation_list[4] = LimitData(20001, 50000);
        sow_limitation_list[5] = LimitData(50001, 100000);
        sow_limitation_list[6] = LimitData(100001, 200000);
    }

    function setLandPriceList(uint256 [] memory priceList) external onlyOwner {
        land_price_list = priceList;
    }

    function getLandPriceList() external view returns (uint256 [] memory res) {
        res = land_price_list;
    }

    function setLandPicture(uint8 index, string memory pic) external onlyOwner {
        land_picture_list[index] = pic;
    }

    function setLandPicutureList(string [] memory pictureList) external onlyOwner {
        land_picture_list = pictureList;
    }

    function getLandPicutureList() external view returns (string [] memory res) {
        res = land_picture_list;
    }

    function setSowLimitationData(uint256 index, uint256 min, uint256 max) external onlyOwner {
        require(max >= min, "max must be >= min");
        sow_limitation_list[index] = LimitData(min, max);
    }

    function getSowLimitationData(uint256 index) external view returns (bool res, uint256 min, uint256 max) {
        (res, min, max) = _getSowLimitationData(index);
    }

    function _getSowLimitationData(uint256 index) internal view returns (bool res, uint256 min, uint256 max) {
        if(sow_limitation_list[index].min > 0) {
            res = true;
            min = sow_limitation_list[index].min;
            max = sow_limitation_list[index].max;
        }
    }

    function cumulateSowAmountRange(uint256 farmLandTokenId) 
        external 
        view 
        returns (
            bool res, 
            uint256 minAmount, 
            uint256 maxAmount) 
    {
        (bool resProps, uint256 area, , ) = _getLandProperty(farmLandTokenId);
        if(resProps) {
            uint256 landIndex = _getLandIndexByArea(area);
            (res, minAmount, maxAmount) = _getSowLimitationData(landIndex);
        }  
    }

    function mintLand(uint256 price, address toAccount) external onlyCaller returns (uint256 tokenId){
        require(currentTokenId <= max_land_number, "have no land left to be mint");
        (bool b, uint256 area, string memory picture) = _getLand(price);
        require(b, "out of price"); 
        _safeMint(toAccount, ++currentTokenId);
        mapLandProperty[currentTokenId] = LandProperty(
            area,
            3,
            picture
        );
        tokenId = currentTokenId;
    }

    function getLand(uint256 price) external view returns (bool res, uint256 area, string memory picture) {
        (res, area, picture) = _getLand(price);
    }

    function _getLand(uint256 price) internal view returns (bool res, uint256 area, string memory picture) {
        if(price < land_price_list[0]) {
            res = false;
        } else {
            for(uint256 i = land_price_list.length - 1; i >= 0; --i) {
                if(price >= land_price_list[i]) {
                    res = true;
                    area = land_price_list[i];
                    picture = land_picture_list[i];
                    break;
                }
            }
        }
    }

    function getLandPriceByIndex(uint256 index) external view returns (bool res, uint256 price) {
        if(index < land_price_list.length) {
            res = true;
            price = land_price_list[index];
        }
    }

    function getLandIndexByArea(uint256 area) external view returns (uint256 index) {
        index = _getLandIndexByArea(area);
    }

    function _getLandIndexByArea(uint256 area) internal view returns (uint256 index) {
        for(uint256 i = land_price_list.length - 1; i >= 0; --i) {
            if(area >= land_price_list[i]) {
                index = i;
                break;
            }
        }
    }

    function getSowLimitationByIndex(uint256 index) external view returns (bool res, uint256 min, uint256 max) {
        if(index < land_price_list.length) {
            res = true;
            min = sow_limitation_list[index].min;
            max = sow_limitation_list[index].max;
        }
    }

    function getLandProperty(uint256 tokenId) external view returns (bool res, uint256 area, uint256 fertility, string memory picture) {
        (res, area, fertility, picture) = _getLandProperty(tokenId);
    }

    function _getLandProperty(uint256 tokenId) internal view returns (bool res, uint256 area, uint256 fertility, string memory picture) {
        if(mapLandProperty[tokenId].area > 0) {
            res = true;
            area = mapLandProperty[tokenId].area;
            fertility = mapLandProperty[tokenId].fertility;
            picture = mapLandProperty[tokenId].picture;
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        (bool uriRes, string memory baseURI) = _thisTokenURI(tokenId);
        if(!uriRes){
            return "";
        }
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _thisTokenURI(uint256 tokenId) internal view  returns (bool res, string memory _uri) {
        if(mapLandProperty[tokenId].area > 0) {
            res = true;
            _uri = mapLandProperty[tokenId].picture;
        }
    }
}