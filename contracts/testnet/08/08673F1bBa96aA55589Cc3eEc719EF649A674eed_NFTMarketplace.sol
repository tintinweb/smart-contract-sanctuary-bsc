//SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./IERC20.sol";
import "./INFTContract.sol";


contract NFTMarketplace is Ownable {
using SafeMath for uint256;
using Address for address;

enum EOrderType{
    None,
    Fixed,
    Auction
}

enum EOrderStatus{
    None,
    OpenForTheMarket,
    MarketCancelled,
    MarketClosed
}


struct Market{
    address contractAddress;
    uint256 tokenId;
    EOrderType orderType;
    EOrderStatus orderStatus;
    uint256 askAmount;
    uint256 maxAskAmount;
    address payable currentOwner;
    address newOwner;
    uint256 platFormFeePercentage;
} 


IERC20 public _wrapToken;
uint256 public _feePercentage;
address  payable public _feeDestinationAddress;
mapping (bytes32 => Market) public markets;


constructor(address wrapToken,
            uint256 feePercentage,
            address payable feeDestinationAddress){
    _feePercentage = feePercentage;
    _feeDestinationAddress = feeDestinationAddress;
    _wrapToken = IERC20(wrapToken);
}

function setFeePercentage (uint256 value) external onlyOwner{
    if(value < 2 || value > 25){
        revert("value must be between 2 to 25!");
    }
    _feePercentage = value; 
}

function setFeeDestinationAddress (address payable value) external onlyOwner{
    _feeDestinationAddress = value; 
}

function getPrivateUniqueKey(address nftContractId, uint256 tokenId) private pure returns (bytes32){
    return keccak256(abi.encodePacked(nftContractId, tokenId));
}

function openMarketForFixedType(address nftContractId, uint256 tokenId, uint256 price, uint256 platFormFeePercentage) external{
   openMarket(nftContractId,tokenId,price,EOrderType.Fixed, 0,  platFormFeePercentage);
}

function openMarketForAuctionType(address nftContractId, uint256 tokenId, uint256 price, uint256 maxPrice, uint256 platFormFeePercentage) external{
    openMarket(nftContractId,tokenId,price,EOrderType.Auction, maxPrice, platFormFeePercentage);
}

function openMarket(address nftContractId, uint256 tokenId, uint256 price, EOrderType orderType, uint256 maxPrice,  uint256 platFormFeePercentage) private{
    bytes32 uniqueKey = getPrivateUniqueKey(nftContractId,tokenId);

    if(markets[uniqueKey].orderStatus == EOrderStatus.OpenForTheMarket){
        revert ("Market order is already opened");
    }
    if(price <= 0){
        revert ("Price Should be greater then 0");
    }

    if(orderType == EOrderType.Auction && price > maxPrice){
        revert ("end Price Should be greater then price");
    }

    markets[uniqueKey].orderStatus = EOrderStatus.OpenForTheMarket;
    markets[uniqueKey].orderType = orderType;
    markets[uniqueKey].askAmount = price;
    markets[uniqueKey].maxAskAmount = maxPrice;
    markets[uniqueKey].contractAddress = nftContractId;
    markets[uniqueKey].tokenId = tokenId;
    markets[uniqueKey].currentOwner = payable(msg.sender);
    markets[uniqueKey].platFormFeePercentage = platFormFeePercentage;
}

function closeMarketForFixedType(address nftContractId, uint256 tokenId, uint256 price) external { 
    bytes32 uniqueKey = getPrivateUniqueKey(nftContractId,tokenId);
    
    if(markets[uniqueKey].orderStatus == EOrderStatus.OpenForTheMarket){

        if(markets[uniqueKey].orderType == EOrderType.None){
            revert ("nft not opened");
        }
        else if(markets[uniqueKey].orderType == EOrderType.Fixed){
            if(markets[uniqueKey].askAmount < price){
                revert ("Value not matched");
            }
        }else if (markets[uniqueKey].orderType == EOrderType.Auction){
           if(markets[uniqueKey].maxAskAmount < price){
                revert ("Value not matched");
            }
        }

        INFTContract nftContract = INFTContract(markets[uniqueKey].contractAddress);
        (uint256 royality, address creator) = nftContract.getRoyalityDetails(tokenId);

        //platform fee
        uint256 restAmount = price;

        uint256 fee = 0;

        if(markets[uniqueKey].platFormFeePercentage > 0){
            fee = getFeePercentage(restAmount, markets[uniqueKey].platFormFeePercentage);
        }
        else{
            fee = getFeePercentage(restAmount, _feePercentage);
        }
        _wrapToken.transferFrom(msg.sender,_feeDestinationAddress,fee);

        restAmount = restAmount.sub(fee);

        //Royality profit
        if(msg.sender != creator){
            uint256 royalityFee = getFeePercentage(price, royality);
            payable(creator).transfer(royalityFee);

            restAmount = restAmount.sub(royalityFee);
        }

        //seller amouynt trans 
        _wrapToken.transferFrom(msg.sender,markets[uniqueKey].currentOwner,restAmount);
        
        // transfer nft to new user 
        nftContract.safeTransferFrom(markets[uniqueKey].currentOwner, msg.sender, tokenId);

        // nft market close
        markets[uniqueKey].orderStatus = EOrderStatus.MarketClosed;
        markets[uniqueKey].newOwner = msg.sender;

    }else{
        revert ("Market order is not opened");
    }
}

function closeMarketForAuctionType(address nftContractId, uint256 tokenId, uint256 price, address buyerAccount ) external{
    bytes32 uniqueKey = getPrivateUniqueKey(nftContractId,tokenId);

    if(markets[uniqueKey].currentOwner != msg.sender){
        revert ("only for market operator");
    }    
    if(markets[uniqueKey].orderStatus == EOrderStatus.OpenForTheMarket){

        if(markets[uniqueKey].askAmount < price){
            INFTContract nftContract = INFTContract(markets[uniqueKey].contractAddress);
            (uint256 royality, address creator) = nftContract.getRoyalityDetails(tokenId);

            //platform fee
            uint256 restAmount = price;

            uint256 fee = 0;

            if(markets[uniqueKey].platFormFeePercentage > 0){
                fee = getFeePercentage(restAmount, markets[uniqueKey].platFormFeePercentage);
            }
            else{
                fee = getFeePercentage(restAmount, _feePercentage);
            }

            _wrapToken.transferFrom(buyerAccount,_feeDestinationAddress,fee);

            restAmount = restAmount.sub(fee);

            //Royality profit
            if(msg.sender != creator){
                uint256 royalityFee = getFeePercentage(price, royality);
                _wrapToken.transferFrom(buyerAccount,creator,royalityFee);

                restAmount = restAmount.sub(royalityFee);
            }

            //seller amount trans 
            _wrapToken.transferFrom(buyerAccount,markets[uniqueKey].currentOwner,restAmount);

            // transfer nft to new user 
            nftContract.safeTransferFrom(markets[uniqueKey].currentOwner, buyerAccount, tokenId);

            // nft market close
            markets[uniqueKey].orderStatus = EOrderStatus.MarketClosed;
            markets[uniqueKey].newOwner = buyerAccount;

        }else{
            revert ("Value not matched");
        }
    }else{
        revert ("Market order is not opened");
    }
}

function getFeePercentage(uint256 price, uint256 percent) private pure returns (uint256){
    return price.mul(percent).div(100);
}

function cancel (address nftContractId,  uint256 tokenId) external{
    bytes32 uniqueKey = getPrivateUniqueKey(nftContractId,tokenId);
  
    if(markets[uniqueKey].currentOwner != msg.sender){
        revert ("only for market operator");
    }  

    if(markets[uniqueKey].orderStatus == EOrderStatus.OpenForTheMarket){
        markets[uniqueKey].orderStatus =  EOrderStatus.MarketCancelled;
    }else{
        revert ("Market order is not opened");
    }
}

}