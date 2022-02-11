// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./ERC20.sol";

import "./BNBPriceHelper.sol";
import "./LandPriceHelper.sol";
import "./ERC721PresetMinterPauser.sol";

contract Payment is Ownable, BNBPriceHelper, LandPriceHelper{
    using SafeMath for uint256;

    uint256 private decimalsMultiplier;
    ERC20 public usdt;
    ERC721PresetMinterPauser public nft;

    uint256 constant maxCityNumber = 10000;
    uint256 constant maxRarity = 1000;

    uint256 private purchaseGas;
    bool private anySuccessfulPurchase;

    event Purchase(address owner, uint256 tokenId, uint256 price, string tokenName);
    event PurchaseFailure(address owner, uint256 tokenId, uint price, string tokenName, string reason);
    event Refund(address owner, uint256 tokenId, uint value, string tokenName);

    constructor(
        address BNBOracle, 
        address usdtAddress, 
        address nftAddress, 
        uint256 _stockUpRate, 
        uint256 _priceUpRate
        )
    BNBPriceHelper(BNBOracle) LandPriceHelper(_stockUpRate, _priceUpRate) 
    {
        usdt = ERC20(usdtAddress);
        nft = ERC721PresetMinterPauser(nftAddress);

        decimalsMultiplier = 1;
        require(18 + priceDecimalsBNB > usdt.decimals(), "Multiplier must be positive");
        for (uint i = 0; i < 18 + priceDecimalsBNB - usdt.decimals(); i++)
            decimalsMultiplier *= 10;
        
        purchaseGas = 162726;
    }

    function updatePurchaseGas(uint256 newGas) public onlyOwner{
        purchaseGas = newGas;
    }


    function queryBatch(uint256[] calldata tokenIds) public view returns (uint256){
        uint256 sum;

        // TODO: calculate price change

        for (uint i = 0; i < tokenIds.length; i++){
            sum = sum.add(querySingle(tokenIds[i]));
        }
        return sum;
    }

    function querySingle(uint256 tokenId) public view returns (uint256){
        // check existance
        // formula here
        uint256 city;
        uint256 rarity;
        (rarity, city) = getRarityAndCityFromId(tokenId);
        require(purchasable(city, rarity), "Sold out.");
        return getPrice(city, rarity);
    }

    function recordSoldTokenId(uint256 tokenId) internal {
        uint256 city;
        uint256 rarity;
        (rarity, city) = getRarityAndCityFromId(tokenId);
        recordLandMint(city, rarity);
    }

    function bnbWeiToUsdt(uint256 bnbValue) public view returns (uint256 usdtValue) {
        return bnbWeiToUsdt(bnbValue, getBNBPrice());
    }

    function bnbWeiToUsdt(uint256 bnbValue, uint256 bnbPrice) public view returns (uint256 usdtValue) {
        usdtValue = bnbValue * bnbPrice / decimalsMultiplier;
    }

    function usdtToBnbWei(uint256 usdtValue) public view returns (uint256 bnbValue) {
        return usdtToBnbWei(usdtValue, getBNBPrice());
    }

    function usdtToBnbWei(uint256 usdtValue, uint256 bnbPrice) public view returns (uint256 bnbValue) {
        bnbValue = usdtValue * decimalsMultiplier / bnbPrice;
    }

    function purchase(uint256[] calldata tokenIds) public payable {
        uint256 bnbPrice = getBNBPrice();
        uint256 remainingUsdt = bnbWeiToUsdt(msg.value, bnbPrice);
        bool payWithBNB = remainingUsdt > 0;
        anySuccessfulPurchase = false;

        for (uint i=0; i<tokenIds.length; i++){
            remainingUsdt = _purchase(tokenIds[i], remainingUsdt, bnbPrice, payWithBNB);
        }

        // require(anySuccessfulPurchase, "Nothing purchased");
        
        if (remainingUsdt > 0){
            uint256 refund = usdtToBnbWei(remainingUsdt, bnbPrice);
            payable(msg.sender).transfer(refund);
            emit Refund(msg.sender, 0, refund, "BNB");
        }

    }

    function _purchase(uint256 tokenId, uint256 remainingUsdt, uint256 bnbPrice, bool payWithBNB) internal returns (uint256 _remainingUsdt) {
        // require enough gas to purchase, or you'll suffer griefing/DoS attack.
        // gas is estimated by ethers.js
        // gas needs to be re-estimated if any modification is applyed.
        if (gasleft() < purchaseGas) {
            emit PurchaseFailure(msg.sender, tokenId, 0, "", "Insufficient gas");
            return remainingUsdt;
        }

        uint256 city;
        uint256 rarity;
        (rarity, city) = getRarityAndCityFromId(tokenId);

        if (!purchasable(city, rarity)) {
            emit PurchaseFailure(msg.sender, tokenId, 0, "", "Sold out");
            return remainingUsdt;
        }
        uint256 price = querySingle(tokenId);

        if (payWithBNB) {

            if (remainingUsdt >= price) {
                try nft.mint(msg.sender, tokenId) {
                    recordSoldTokenId(tokenId);
                    emit Purchase(msg.sender, tokenId, usdtToBnbWei(price, bnbPrice), "BNB");
                    anySuccessfulPurchase = true;
                    return remainingUsdt - price;
                } catch {
                    emit PurchaseFailure(msg.sender, tokenId, usdtToBnbWei(price, bnbPrice), "BNB", "Mint failure");
                    return remainingUsdt;
                }
            } else {
                emit PurchaseFailure(msg.sender, tokenId, price, "BNB", "Insufficient balance");
                return remainingUsdt;
            }

        }else{

            // pay with usdt
            try usdt.transferFrom(msg.sender, address(this), price) {
                try nft.mint(msg.sender, tokenId) {
                    recordSoldTokenId(tokenId);
                    emit Purchase(msg.sender, tokenId, price, "USDT");
                    anySuccessfulPurchase = true;
                    return remainingUsdt;
                } catch {
                    // refund usdt
                    emit PurchaseFailure(msg.sender, tokenId, price, "USDT", "Mint Failure");

                    usdt.transfer(msg.sender, price);
                    emit Refund(msg.sender, tokenId, price, "USDT");

                    return remainingUsdt;
                }
            }catch{
                emit PurchaseFailure(msg.sender, tokenId, price, "USDT", "Transaction failure");
                return remainingUsdt;
            }

        }

    }

    function withdraw(address to) public onlyOwner {
        payable(to).transfer(address(this).balance);
        usdt.transfer(to, usdt.balanceOf(address(this)));
    }

    function getRarityAndCityFromId(uint256 tokenId) public pure returns (uint256 rarity, uint256 city){
        rarity = tokenId % maxRarity;
        city = (tokenId / maxRarity) % maxCityNumber;
    }

}