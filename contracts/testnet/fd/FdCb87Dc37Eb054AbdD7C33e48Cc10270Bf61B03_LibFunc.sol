// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../interfaces/IHuukReferral.sol";
import "../interfaces/IHuukExchange.sol";
import "./LibStruct.sol";

library LibFunc {
    function getRefData(address _referralContract, address _user)
        public
        view
        returns (address payable)
    {
        address payable userRef = IHuukReferral(_referralContract).getReferral(
            _user
        );
        return userRef;
    }

    function getERC1155Data() public pure returns (bytes memory) {
        return
            abi.encodePacked(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function getTokenUnique(LibStruct.Token memory _token)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_token.token, _token.id));
    }

    function getOrderUnique(LibStruct.Order memory _order)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    _order.tokenAddress,
                    _order.tokenId,
                    _order.owner
                )
            );
    }

    function estimateUSDT(
        address _exchangeContract,
        address _paymentToken,
        uint256 _paymentAmount
    ) public view returns (uint256) {
        return
            IHuukExchange(_exchangeContract).estimateToUSDT(
                _paymentToken,
                _paymentAmount
            );
    }

    function estimateToken(
        address _exchangeContract,
        address _paymentToken,
        uint256 _usdtAmount
    ) public view returns (uint256) {
        return
            IHuukExchange(_exchangeContract).estimateFromUSDT(
                _paymentToken,
                _usdtAmount
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IHuukReferral {
    function getReferral(address user) external view returns (address payable);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IHuukExchange {
    function estimateToUSDT(address _paymentToken, uint256 _paymentAmount) external view returns (uint256);

    function estimateFromUSDT(address _paymentToken, uint256 _usdtAmount) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

library LibStruct {
    struct Order {
        address owner;
        address paymentToken;
        address tokenAddress;
        uint256 tokenId;
        uint256 quantity;
        uint256 price; // price of 1 NFT in paymentToken
        bool isOnSale; // true: on sale, false: cancel
        bool isERC721;
    }
//    struct CreateBidInput {
//        address _tokenAddress;
//        address _paymentToken; // payment method
//        address _bidder;
//        uint256 _tokenId;
//        uint256 _quantity; // total amount for sale
//        uint256 _price; // price of 1 nft
//        uint256 _expTime;
//    }

    struct Token {
        address owner;
        address token;
        uint256 id;
        string uri;
        uint256 initialSupply;
        uint256 maxSupply;
        uint256 royaltyFee;
        uint256 nonce;
        bool isERC721;
        bytes signature;
    }

    struct LazyOrder {
        Token token; // [new Token] token.id = 0
        uint256 id;
        uint256 quantity;
        uint256 price;
        address paymentToken;
        address representative;
        uint256 nonce;
        bytes signature; // [Old Token] token.id + paymentToken + ... + (token.signature = "")
                         // [New Token] (token.id = 0) + paymentToken + ... + token.signature
    }

    struct LazyBid {
        LazyOrder lazyOrder;
        uint256 id;
        address bidder;
        uint256 quantity;
        uint256 price;
        address paymentToken;
        uint256 expTime;
        bytes signature;
    }

    struct LazyAcceptBid {
        LazyBid lazyBid;
        uint256 nonce;
        uint256 quantity;
        bytes signature;
    }


    struct Bid {
        address bidder;
        address paymentToken;
        uint256 orderId;
//        address tokenAddress;
        uint256 bidPrice;
        uint256 quantity;
        uint256 expTime;
        bool status; // 1: available | 2: done | 3: reject
    }

    struct AcceptBid{
        uint256 bidId; // not used in sign
        uint256 nonce;

        uint256 price;
        address paymentToken;
        uint256 tokenId; // = 0
        address tokenAddress;
        bytes tokenSignature; // use when bidId = 0, not check when bidId != 0
        uint256 quantity;


        bytes signature;
    }
}