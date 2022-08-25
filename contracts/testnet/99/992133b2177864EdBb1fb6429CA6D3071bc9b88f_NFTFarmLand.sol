// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./Callerable.sol";

contract NFTFarmLand is ERC721, Callerable {

    uint256 private constant max_land_number = 80000;
    uint256 private currentTokenId;

    struct LandProperty {
        uint256 area;//bigger area means bigger volume
        uint256 fertility;//high fertility means high apy, default to the same high-level, 3-high, 2-medium, 1-low
    }

    //land price list
    uint256 [] private land_price_list;

    //land container
    //key: tokenId => LandProperty
    mapping(uint256 => LandProperty) mapLandProperty;

    constructor(string memory name_, string memory symbol_, address _auth) Callerable(_auth) ERC721(name_, symbol_) {
        land_price_list = [100, 200, 500, 1000, 2000, 5000, 10000];
    }

    function setLandPriceList(uint256 [] memory priceList) external onlyOwner {
        land_price_list = priceList;
    }

    function getLandPriceList() external view returns (uint256 [] memory res) {
        res = land_price_list;
    }

    function mintLand(uint256 price, address toAccount) external {
        require(mapCaller[msg.sender], "caller only");
        require(currentTokenId <= max_land_number, "have no land left to be mint");
        (bool b, uint256 area) = _getLandArea(price);
        require(b, "out of price"); 
        _mint(toAccount, ++currentTokenId);
        mapLandProperty[currentTokenId] = LandProperty(
            area,
            3
        );
    }

    function getLandArea(uint256 price) external view returns (bool res, uint256 area) {
        (res, area) = _getLandArea(price);
    }

    function _getLandArea(uint256 price) internal view returns (bool res, uint256 area) {
        if(price < land_price_list[0]) {
            res = false;
        } else {
            for(uint256 i = land_price_list.length - 1; i >= 0; --i) {
                if(price >= land_price_list[i]) {
                    res = true;
                    area = land_price_list[i];
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

    function getLandProperty(uint256 tokenId) external view returns (bool res, uint256 area, uint256 fertility) {
        if(mapLandProperty[tokenId].area > 0) {
            res = true;
            area = mapLandProperty[tokenId].area;
            fertility = mapLandProperty[tokenId].fertility;
        }
    }
}