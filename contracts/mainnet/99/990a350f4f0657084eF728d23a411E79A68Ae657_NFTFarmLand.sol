// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./Callerable.sol";

contract NFTFarmLand is ERC721, Callerable {

    using Address for address;
    using Strings for uint256;

    uint256 private currentTokenId;

    struct LandProperty {
        uint256 area;//bigger area means bigger volume
        uint256 fertility;//high fertility means high apy, default to the same high-level, 3-high, 2-medium, 1-low
        string picture;
    }

    //land price list
    uint256 [] internal land_price_list;

    //land area list
    uint256 [] internal land_area_list;

    //land picture list
    string [] internal land_picture_list;

    struct MaxNumberData {
        uint256 count;
        uint256 maxNumber;
    }

    mapping(uint256 => MaxNumberData) private max_land_number_list;

    //sow limitation
    struct LimitData {
        uint256 min;
        uint256 max;
    }
    mapping(uint256 => LimitData) private sow_limitation_list;

    //land container
    //key: tokenId => LandProperty
    mapping(uint256 => LandProperty) private mapLandProperty;

    constructor(string memory name_, string memory symbol_, address _auth) Callerable(_auth) ERC721(name_, symbol_) {
        land_price_list = new uint256[](10);
        land_price_list[0] = 100;
        land_price_list[1] = 200;
        land_price_list[2] = 300;
        land_price_list[3] = 400;
        land_price_list[4] = 500;
        land_price_list[5] = 600;
        land_price_list[6] = 700;
        land_price_list[7] = 800;
        land_price_list[8] = 900;
        land_price_list[9] = 1000;

        land_area_list = new uint256[](10);
        land_area_list[0] = 100;
        land_area_list[1] = 200;
        land_area_list[2] = 300;
        land_area_list[3] = 400;
        land_area_list[4] = 500;
        land_area_list[5] = 600;
        land_area_list[6] = 700;
        land_area_list[7] = 800;
        land_area_list[8] = 900;
        land_area_list[9] = 1000;
        
        land_picture_list = new string[](10);
        
        sow_limitation_list[0] = LimitData(
            1, 
            1000);
        sow_limitation_list[1] = LimitData(
            1, 
            2000);
        sow_limitation_list[2] = LimitData(
            1, 
            3000);
        sow_limitation_list[3] = LimitData(
            1, 
            4000);
        sow_limitation_list[4] = LimitData(
            1, 
            5000);
        sow_limitation_list[5] = LimitData(
            1, 
            6000);
        sow_limitation_list[6] = LimitData(
            1, 
            7000);
        sow_limitation_list[7] = LimitData(
            1, 
            8000);
        sow_limitation_list[8] = LimitData(
            1, 
            9000);
        sow_limitation_list[9] = LimitData(
            1, 
            10000); 

        max_land_number_list[0] = MaxNumberData(0, 100000);
        max_land_number_list[1] = MaxNumberData(0, 90000);
        max_land_number_list[2] = MaxNumberData(0, 80000);
        max_land_number_list[3] = MaxNumberData(0, 70000);
        max_land_number_list[4] = MaxNumberData(0, 60000);
        max_land_number_list[5] = MaxNumberData(0, 50000);
        max_land_number_list[6] = MaxNumberData(0, 40000);
        max_land_number_list[7] = MaxNumberData(0, 30000);
        max_land_number_list[8] = MaxNumberData(0, 20000);
        max_land_number_list[9] = MaxNumberData(0, 10000);
    }

    function getMaxLandNumber(uint256 index) external view returns (bool res, uint256 count, uint256 maxNumber) {
        if(max_land_number_list[index].maxNumber > 0) {
            res = true;
            count = max_land_number_list[index].count;
            maxNumber = max_land_number_list[index].maxNumber;
        }
    }

    function setLandPrice(uint8 index, uint256 price) external onlyOwner {
        land_price_list[index] = price;
    }

    function setLandPriceList(uint256 [] memory priceList) external onlyOwner {
        land_price_list = priceList;
    }

    function getLandPrice(uint8 index) external view returns (uint256 res) {
        res = land_price_list[index];
    }

    function getLandPriceList() external view returns (uint256 [] memory res) {
        res = new uint256[](10);
        res = land_price_list;
    }

    function setLandPicture(uint8 index, string memory pic) external onlyOwner {
        land_picture_list[index] = pic;
    }

    function setLandPicutureList(string [] memory pictureList) external onlyOwner {
        land_picture_list = pictureList;
    }

    function getLandPicture(uint8 index) external view returns (string memory res) {
        res = land_picture_list[index];
    }

    function getLandPicutureList() external view returns (string [] memory res) {
        res = new string[](10);
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

    function mintLand(uint256 price, address toAccount) external onlyCaller returns (uint256 tokenId) {
        (bool b, uint256 area, string memory picture, uint256 index) = _getLandPropertyByPrice(price);
        require(b, "out of price"); 
        require(max_land_number_list[index].count <= max_land_number_list[index].maxNumber, "have no land left to be mint");
        ++currentTokenId;
        mapLandProperty[currentTokenId] = LandProperty(
            area,
            3,
            picture
        );
        tokenId = currentTokenId;
        max_land_number_list[index].count ++;
        _safeMint(toAccount, currentTokenId);
    }

    function mintLand(uint8 index, address toAccount) external onlyCaller returns (uint256 tokenId) {
        require(index < 10, "out of index");
        ++currentTokenId;
        mapLandProperty[currentTokenId] = LandProperty(
            land_area_list[index],
            3,
            land_picture_list[index]
        );
        tokenId = currentTokenId;
        max_land_number_list[index].count ++;
        _safeMint(toAccount, currentTokenId);
    }

    function getLandPropertyByPrice(uint256 price) external view returns (bool res, uint256 area, string memory picture, uint256 index) {
        (res, area, picture, index) = _getLandPropertyByPrice(price);
    }

    function _getLandPropertyByPrice(uint256 price) internal view returns (bool res, uint256 area, string memory picture, uint256 index) {
        if(price < land_price_list[0]) {
            res = false;
        } else {
            for(uint256 i = land_price_list.length - 1; i >= 0; --i) {
                if(price >= land_price_list[i]) {
                    res = true;
                    area = land_area_list[i];
                    picture = land_picture_list[i];
                    index = i;
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
        for(uint256 i = land_area_list.length - 1; i >= 0; --i) {
            if(area >= land_area_list[i]) {
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