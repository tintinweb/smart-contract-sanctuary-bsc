//SPDX-License-Identifier: No License

pragma solidity ^0.8.15;

import "./abstracts/Auth.sol";
import "./interfaces/IDEXRouter.sol";
import "./interfaces/IBEP20.sol";
import "./interfaces/IERC721.sol";
import "./interfaces/IWETH.sol";
import "./abstracts/MarketRewards.sol";
import "./ERC721Holder.sol";

contract GhostOffers is Auth, ERC721Holder {
    /* Constants */
    bytes32 public constant ACTIVE_STATUS = "active";
    bytes32 public constant FINALIZED_STATUS = "finalized";
    bytes32 public constant CANCELLED_STATUS = "cancelled";
    bytes32 public constant REJECTED_STATUS = "rejected";
    bytes32 public constant REMOVED_STATUS = "removed";

    /* Acceptable tokens and NFTs */
    address[] private acceptablePaymentTokens;
    address[] private acceptablePaymentNFTs;
    address[] private acceptableOfferedNFTs;

    /* NFT Offers */
    mapping(address => mapping(uint256 => NftOffer[])) // (collection address) -> (nftid -> offer)
        public _nftOffersByCollection;
    NftOffer[] public nftOffers;
    uint256 public nftOfferId = 0;

    /* Token Offers */
    mapping(address => mapping(uint256 => TokenOffer[])) // (collection address) -> (nftid -> offer)
        public _tokenOffersByCollection;
    TokenOffer[] public tokenOffers;
    uint256 public tokenOfferId = 0;

    /* Minimum Offers */
    mapping(address => uint256) public globalMinimumOffers; // (token address) -> (minimum offer)
    mapping(address => mapping(uint256 => mapping(address => uint256))) // (collection address) -> (nftid -> (token address -> minimum offer))
        public minimumOffers;

    /* Access control */
    mapping(address => bool) public blacklist;
    bool public offerPaused = false;

    /* Rewards & Taxes */
    IDEXRouter public router;
    address payable public _devWallet;
    MarketRewards public marketRewards;
    mapping(address => uint256) public pendingRewards;

    address public immutable wbnbAddress;

    /* Structs */
    struct TokenOffer {
        uint256 tokenOfferId;
        address tokenAddress;
        uint256 nftId;
        address nftAddress;
        uint256 price;
        address buyer;
        bytes32 status;
        uint256 index;
    }

    struct NftOffer {
        uint256 nftOfferId;
        address buyer;
        address soldNftAddress;
        uint256[] soldNftIds;
        address wantedNftAddress;
        uint256 wantedNftId;
        bytes32 status;
        uint256 index;
    }

    /* Events */
    event TokenOfferCreated(
        uint256 indexed tokenOfferId,
        address indexed nftAddress,
        uint256 indexed nftId,
        address tokenAddress,
        uint256 price,
        address buyer,
        uint256 index
    );

    event TokenOfferUpdated(
        uint256 indexed tokenOfferId,
        address indexed nftAddress,
        uint256 indexed nftId,
        address tokenAddress,
        uint256 price,
        address buyer,
        bytes32 status
    );

    event NftOfferCreated(
        uint256 indexed nftOfferId,
        address indexed wantedNftAddress,
        uint256 indexed wantedNftId,
        address soldNftAddress,
        uint256[] soldNftIds,
        address buyer,
        uint256 index
    );

    event NftOfferUpdated(
        uint256 indexed nftOfferId,
        address indexed wantedNftAddress,
        uint256 indexed wantedNftId,
        address soldNftAddress,
        uint256[] soldNftIds,
        address buyer,
        bytes32 status
    );

    constructor(
        address wbnbAddress_,
        address rewardsContractAddress_,
        address routerAddress_,
        address devWallet_
    ) Auth(msg.sender) {
        /* Set WBNB*/
        wbnbAddress = wbnbAddress_;

        /* Set reward contract */
        marketRewards = MarketRewards(rewardsContractAddress_);

        /* Set router */
        router = IDEXRouter(routerAddress_);

        /* Set dev wallet */
        _devWallet = payable(devWallet_);
    }

    function createTokenOffer(
        address _nftAddress,
        uint256 _nftId,
        address offeredToken,
        uint256 offeredAmount
    ) external {
        require(offeredAmount > 0, "Please make an appropriate offer");
        if (
            globalMinimumOffers[offeredToken] >
            minimumOffers[_nftAddress][_nftId][offeredToken]
        ) {
            require(
                offeredAmount >= globalMinimumOffers[offeredToken],
                "You cannot offer less than the minimum offer value"
            );
        } else {
            require(
                offeredAmount >=
                    minimumOffers[_nftAddress][_nftId][offeredToken],
                "You cannot offer less than the minimum offer value"
            );
        }

        require(
            !blacklist[msg.sender],
            "You have been banned from making offers"
        );
        require(!offerPaused, "Trading has been paused");
        require(
            isAcceptablePaymentToken(offeredToken),
            "Payment token not accepted"
        );
        require(
            isAcceptableOfferedNFT(_nftAddress),
            "You cannot create an offer on this NFT."
        );

        IBEP20 token = IBEP20(offeredToken);

        token.transferFrom(msg.sender, address(this), offeredAmount);

        tokenOfferId = tokenOfferId + 1;
        uint256 index = _tokenOffersByCollection[_nftAddress][_nftId].length;
        _tokenOffersByCollection[_nftAddress][_nftId].push(
            TokenOffer({
                tokenOfferId: tokenOfferId,
                tokenAddress: offeredToken,
                nftId: _nftId,
                nftAddress: _nftAddress,
                price: offeredAmount,
                buyer: msg.sender,
                status: ACTIVE_STATUS,
                index: index
            })
        );

        tokenOffers.push(_tokenOffersByCollection[_nftAddress][_nftId][index]);

        emit TokenOfferCreated(
            tokenOfferId,
            _nftAddress,
            _nftId,
            offeredToken,
            offeredAmount,
            msg.sender,
            index
        );
    }

    function createNFTOffer(
        address _nftAddress,
        uint256 _nftId,
        address _paymentNFT,
        uint256[] calldata _offeredIds
    ) external {
        require(!offerPaused, "Trading has been paused");
        require(
            !blacklist[msg.sender],
            "You have been banned from making offers"
        );

        IERC721 paymentNftAddress = IERC721(_paymentNFT);
        IERC721 desiredNftAddress = IERC721(_nftAddress);

        require(
            isAcceptablePaymentNFT(_paymentNFT),
            "Unacceptable payment NFT"
        );
        require(
            isAcceptableOfferedNFT(_nftAddress),
            "You cannot create an offer on this NFT."
        );
        require(
            desiredNftAddress.ownerOf(_nftId) != msg.sender,
            "Cannot make an offer to yourself"
        );

        for (uint256 i = 0; i < _offeredIds.length; i++) {
            require(
                paymentNftAddress.ownerOf(_offeredIds[i]) == msg.sender,
                "Not owner."
            );
            paymentNftAddress.transferFrom(
                msg.sender,
                address(this),
                _offeredIds[i]
            );
        }

        nftOfferId = nftOfferId + 1;
        uint256 index = _nftOffersByCollection[_nftAddress][_nftId].length;
        _nftOffersByCollection[_nftAddress][_nftId].push(
            NftOffer({
                nftOfferId: nftOfferId,
                buyer: msg.sender,
                soldNftAddress: _paymentNFT,
                soldNftIds: _offeredIds,
                wantedNftAddress: _nftAddress,
                wantedNftId: _nftId,
                status: ACTIVE_STATUS,
                index: index
            })
        );

        nftOffers.push(_nftOffersByCollection[_nftAddress][_nftId][index]);

        emit NftOfferCreated(
            nftOfferId,
            _nftAddress,
            _nftId,
            _paymentNFT,
            _offeredIds,
            msg.sender,
            index
        );
    }

    function rejectTokenOffer(
        address _nftAddress,
        uint256 _nftId,
        uint256 _offerIndex,
        uint256 _offerId
    ) external {
        IERC721 n = IERC721(_nftAddress);
        require(n.ownerOf(_nftId) == msg.sender, "Not NFT owner");
        require(
            _tokenOffersByCollection[_nftAddress][_nftId][_offerIndex].buyer !=
                msg.sender,
            "You cannot reject an offer you made."
        );
        require(!offerPaused, "Trading has been paused");

        IBEP20 token = IBEP20(
            _tokenOffersByCollection[_nftAddress][_nftId][_offerIndex]
                .tokenAddress
        );

        token.transfer(
            _tokenOffersByCollection[_nftAddress][_nftId][_offerIndex].buyer,
            _tokenOffersByCollection[_nftAddress][_nftId][_offerIndex].price
        );

        removeTokenOffer(
            _nftAddress,
            _nftId,
            _offerIndex,
            _offerId,
            REJECTED_STATUS
        );
    }

    function rejectNFTOffer(
        address _nftAddress,
        uint256 _nftId,
        uint256 _offerIndex,
        uint256 _offerId
    ) external {
        IERC721 n = IERC721(_nftAddress);
        require(n.ownerOf(_nftId) == msg.sender, "You don't own this NFT.");
        require(
            _nftOffersByCollection[_nftAddress][_nftId][_offerIndex].buyer !=
                msg.sender,
            "You cannot reject an offer you made."
        );
        require(!offerPaused, "Trading has been paused");

        IERC721 soldNftAddress = IERC721(
            _nftOffersByCollection[_nftAddress][_nftId][_offerIndex]
                .soldNftAddress
        );

        uint256 expectedTokenAmount = _nftOffersByCollection[_nftAddress][
            _nftId
        ][_offerIndex].soldNftIds.length;

        //transfer the nfts from the contract to the person who accepted them
        for (uint256 i = 0; i < expectedTokenAmount; i++) {
            soldNftAddress.safeTransferFrom(
                address(this),
                _nftOffersByCollection[_nftAddress][_nftId][_offerIndex].buyer,
                _nftOffersByCollection[_nftAddress][_nftId][_offerIndex]
                    .soldNftIds[i]
            );
        }

        //lastly remove the nft offer
        removeNFTOffer(
            _nftAddress,
            _nftId,
            _offerIndex,
            _offerId,
            REJECTED_STATUS
        );
    }

    function acceptTokenOffer(
        address _nftAddress,
        uint256 _nftId,
        uint256 _offerIndex,
        uint256 _offerId
    ) external {
        require(!offerPaused, "Trading has been paused");

        IERC721 nft = IERC721(_nftAddress);
        IBEP20 token = IBEP20(
            _tokenOffersByCollection[_nftAddress][_nftId][_offerIndex]
                .tokenAddress
        );
        TokenOffer memory offer = _tokenOffersByCollection[_nftAddress][_nftId][
            _offerIndex
        ];

        uint256 rewardFee = (offer.price * 1000) / 10000; //10%

        require(
            nft.ownerOf(_nftId) == msg.sender,
            "You are not the owner to accept this offer."
        );

        require(
            offer.buyer != msg.sender,
            "You cannot accept the offer you made."
        );

        nft.transferFrom(msg.sender, offer.buyer, _nftId);
        token.transfer(msg.sender, offer.price - rewardFee);
        pendingRewards[offer.tokenAddress] += rewardFee;

        removeTokenOffer(
            _nftAddress,
            _nftId,
            _offerIndex,
            _offerId,
            FINALIZED_STATUS
        );
    }

    function acceptNFTOffer(
        address _nftAddress,
        uint256 _nftId,
        uint256 _offerIndex,
        uint256 _offerId
    ) external {
        require(!offerPaused, "Trading has been paused");

        IERC721 nft = IERC721(_nftAddress);
        IERC721 soldNftAddress = IERC721(
            _nftOffersByCollection[_nftAddress][_nftId][_offerIndex]
                .soldNftAddress
        );
        NftOffer memory offer = _nftOffersByCollection[_nftAddress][_nftId][
            _offerIndex
        ];

        require(
            nft.ownerOf(_nftId) == msg.sender,
            "You are not the owner to accept this offer."
        );

        require(
            offer.buyer != msg.sender,
            "You cannot accept the offer you made."
        );

        //transfer the wanted nft to the offerer
        nft.transferFrom(
            msg.sender,
            _nftOffersByCollection[_nftAddress][_nftId][_offerIndex].buyer,
            _nftId
        );

        uint256 expectedTokenAmount = _nftOffersByCollection[_nftAddress][
            _nftId
        ][_offerIndex].soldNftIds.length;

        //transfer the nfts from the contract to the person who accepted them
        for (uint256 i = 0; i < expectedTokenAmount; i++) {
            soldNftAddress.safeTransferFrom(
                address(this),
                msg.sender,
                _nftOffersByCollection[_nftAddress][_nftId][_offerIndex]
                    .soldNftIds[i]
            );
        }

        //lastly remove the nft offer
        removeNFTOffer(
            _nftAddress,
            _nftId,
            _offerIndex,
            _offerId,
            FINALIZED_STATUS
        );
    }

    function cancelTokenOffer(
        address _nftAddress,
        uint256 _nftId,
        uint256 _offerIndex,
        uint256 _offerId
    ) external {
        require(!offerPaused, "Trading has been paused");

        IBEP20 token = IBEP20(
            _tokenOffersByCollection[_nftAddress][_nftId][_offerIndex]
                .tokenAddress
        );

        require(
            msg.sender ==
                _tokenOffersByCollection[_nftAddress][_nftId][_offerIndex]
                    .buyer,
            "You are not the person who made the offer."
        );

        token.transfer(
            msg.sender,
            _tokenOffersByCollection[_nftAddress][_nftId][_offerIndex].price
        );

        removeTokenOffer(
            _nftAddress,
            _nftId,
            _offerIndex,
            _offerId,
            CANCELLED_STATUS
        );
    }

    function cancelNFTOffer(
        address _nftAddress,
        uint256 _nftId,
        uint256 _offerIndex,
        uint256 _offerId
    ) external {
        require(!offerPaused, "Trading has been paused");

        IERC721 soldNftAddress = IERC721(
            _nftOffersByCollection[_nftAddress][_nftId][_offerIndex]
                .soldNftAddress
        );

        require(
            msg.sender ==
                _nftOffersByCollection[_nftAddress][_nftId][_offerIndex].buyer,
            "You are not the person who made the offer."
        );

        uint256 expectedTokenAmount = _nftOffersByCollection[_nftAddress][
            _nftId
        ][_offerIndex].soldNftIds.length;

        //transfer the nfts from the contract to the person who accepted them
        for (uint256 i = 0; i < expectedTokenAmount; i++) {
            soldNftAddress.safeTransferFrom(
                address(this),
                msg.sender,
                _nftOffersByCollection[_nftAddress][_nftId][_offerIndex]
                    .soldNftIds[i]
            );
        }

        //lastly remove the nft offer
        removeNFTOffer(
            _nftAddress,
            _nftId,
            _offerIndex,
            _offerId,
            CANCELLED_STATUS
        );
    }

    function setMinimumOfferByCollectionAndId(
        address _nftAddress,
        uint256 _nftId,
        address _tokenAddress,
        uint256 _minimumValue
    ) external {
        IERC721 nftAddress = IERC721(_nftAddress);

        require(
            isAcceptablePaymentNFT(_nftAddress),
            "This NFT is not supported."
        );
        require(
            nftAddress.ownerOf(_nftId) == msg.sender,
            "You are not the owner of this NFT"
        );

        minimumOffers[_nftAddress][_nftId][_tokenAddress] = _minimumValue;
    }

    function setMinimumOffersByCollection(
        address nftAddress_,
        uint256[] calldata nftIds_,
        address tokenAddress_,
        uint256 minimumValue_
    ) external {
        require(
            isAcceptablePaymentNFT(nftAddress_),
            "This NFT is not supported."
        );
        IERC721 NFT_ = IERC721(nftAddress_);

        uint256 nftId_;
        for (uint256 i = 0; i < nftIds_.length; i++) {
            nftId_ = nftIds_[i];
            require(
                NFT_.ownerOf(nftId_) == msg.sender,
                "You are not the owner of this NFT"
            );

            minimumOffers[nftAddress_][nftId_][tokenAddress_] = minimumValue_;
        }
    }

    /* Public functions */
    function viewNftOffersLengthByCollectionAndId(
        address _nftAddress,
        uint256 _nftId
    ) external view returns (uint256 size) {
        return _nftOffersByCollection[_nftAddress][_nftId].length;
    }

    function viewTokenOffersLengthByCollectionAndId(
        address _nftAddress,
        uint256 _nftId
    ) external view returns (uint256 size) {
        return _tokenOffersByCollection[_nftAddress][_nftId].length;
    }

    function viewTokenOffersByCollectionAndId(
        address _nftAddress,
        uint256 _nftId,
        uint256 _cursor,
        uint256 _size
    ) external view returns (TokenOffer[] memory _offers, uint256) {
        uint256 length = _size;

        if (
            length >
            _tokenOffersByCollection[_nftAddress][_nftId].length - _cursor
        ) {
            length =
                _tokenOffersByCollection[_nftAddress][_nftId].length -
                _cursor;
        }

        _offers = new TokenOffer[](length);
        for (uint256 i = 0; i < length; i++) {
            _offers[i] = _tokenOffersByCollection[_nftAddress][_nftId][
                _cursor + i
            ];
        }

        return (_offers, _cursor + length);
    }

    function viewNftOffersByCollectionAndId(
        address _nftAddress,
        uint256 _nftId,
        uint256 _cursor,
        uint256 _size
    ) external view returns (NftOffer[] memory _offers, uint256) {
        uint256 length = _size;

        if (
            length >
            _nftOffersByCollection[_nftAddress][_nftId].length - _cursor
        ) {
            length =
                _nftOffersByCollection[_nftAddress][_nftId].length -
                _cursor;
        }

        _offers = new NftOffer[](length);
        for (uint256 i = 0; i < length; i++) {
            _offers[i] = _nftOffersByCollection[_nftAddress][_nftId][
                _cursor + i
            ];
        }

        return (_offers, _cursor + length);
    }

    function viewNftOffersLength() external view returns (uint256 size) {
        return nftOffers.length;
    }

    function viewTokenOffersLength() external view returns (uint256 size) {
        return tokenOffers.length;
    }

    function viewTokenOfferAt(uint256 _index)
        external
        view
        returns (TokenOffer memory _tokenOffer)
    {
        return tokenOffers[_index];
    }

    function viewNftOfferAt(uint256 _index)
        external
        view
        returns (NftOffer memory _nftOffer)
    {
        return nftOffers[_index];
    }

    function getAcceptablePaymentTokens()
        external
        view
        returns (address[] memory)
    {
        return acceptablePaymentTokens;
    }

    function getAcceptablePaymentNFTs()
        external
        view
        returns (address[] memory)
    {
        return acceptablePaymentNFTs;
    }

    function getAcceptableOfferedNFTs()
        external
        view
        returns (address[] memory)
    {
        return acceptableOfferedNFTs;
    }

    /* Admin actions */
    function setMarketReward(address addr_) external onlyOwner {
        require(addr_ != address(0), "Can not be the zero address.");
        marketRewards = MarketRewards(addr_);
    }

    function adminRemoveNFTOffer(
        address _nftAddress,
        uint256 _nftId,
        uint256 _offerIndex,
        uint256 _offerId
    ) external authorized {
        IERC721 soldNftAddress = IERC721(
            _nftOffersByCollection[_nftAddress][_nftId][_offerIndex]
                .soldNftAddress
        );

        uint256 expectedTokenAmount = _nftOffersByCollection[_nftAddress][
            _nftId
        ][_offerIndex].soldNftIds.length;

        //transfer the nfts from the contract to the person who accepted them
        for (uint256 i = 0; i < expectedTokenAmount; i++) {
            soldNftAddress.safeTransferFrom(
                address(this),
                _nftOffersByCollection[_nftAddress][_nftId][_offerIndex].buyer,
                _nftOffersByCollection[_nftAddress][_nftId][_offerIndex]
                    .soldNftIds[i]
            );
        }

        //lastly remove the nft offer
        removeNFTOffer(
            _nftAddress,
            _nftId,
            _offerIndex,
            _offerId,
            REMOVED_STATUS
        );
    }

    function setIsOfferPaused(bool _paused) external onlyOwner {
        offerPaused = _paused;
    }

    function adminSetMinimumOffer(address _tokenAddress, uint256 _minimumValue)
        external
        onlyOwner
    {
        globalMinimumOffers[_tokenAddress] = _minimumValue;
    }

    function adminRemoveTokenOffer(
        address _nftAddress,
        uint256 _nftId,
        uint256 _offerIndex,
        uint256 _offerId
    ) external authorized {
        IBEP20 token = IBEP20(
            _tokenOffersByCollection[_nftAddress][_nftId][_offerIndex]
                .tokenAddress
        );

        token.transfer(
            _tokenOffersByCollection[_nftAddress][_nftId][_offerIndex].buyer,
            _tokenOffersByCollection[_nftAddress][_nftId][_offerIndex].price
        );

        removeTokenOffer(
            _nftAddress,
            _nftId,
            _offerIndex,
            _offerId,
            REMOVED_STATUS
        );
    }

    function transferToDevWallet() external onlyOwner {
        _devWallet.transfer(address(this).balance);
    }

    function setRouter(address addr) external authorized {
        require(addr != address(0), "Can not be the zero address.");
        router = IDEXRouter(addr);
    }

    function setDevWallet(address addr) external onlyOwner {
        require(addr != address(0), "Can not be the zero address.");
        _devWallet = payable(addr);
    }

    function addBNBToRewardContract() external onlyOwner {
        uint256 minterReward = address(this).balance / 4;
        uint256 holderReward = address(this).balance / 2;

        marketRewards.reflectToHolders{value: holderReward}();
        marketRewards.reflectToMinters{value: minterReward}();
    }

    function swapForRewards(address addr_) external onlyOwner {
        require(isAcceptablePaymentToken(addr_), "Token not supported");
        uint256 amountToSwap_ = pendingRewards[addr_];

        if (addr_ == wbnbAddress) {
            if (amountToSwap_ > 0) {
                IWETH(wbnbAddress).withdraw(amountToSwap_);
                pendingRewards[wbnbAddress] = 0;
            }
        } else if (amountToSwap_ > 0) {
            sellToken(addr_, amountToSwap_);
        }
    }

    function swapForRewards() external onlyOwner {
        address paymentToken_;
        uint256 pendingReward_;
        for (uint256 i = 0; i < acceptablePaymentTokens.length; i++) {
            paymentToken_ = acceptablePaymentTokens[i];
            pendingReward_ = pendingRewards[paymentToken_];
            if (paymentToken_ == wbnbAddress) {
                if (pendingReward_ > 0) {
                    pendingRewards[wbnbAddress] = 0;
                    IWETH(wbnbAddress).withdraw(pendingReward_);
                }
            } else if (pendingReward_ > 0) {
                sellToken(paymentToken_, pendingReward_);
            }
        }

        uint256 minterReward = address(this).balance / 4;
        uint256 holderReward = address(this).balance / 2;
        uint256 devReward = (address(this).balance -
            (minterReward + holderReward));

        //Transfer 25% to minters and 50% to holders to the Reward Contract
        marketRewards.reflectToHolders{value: holderReward}();
        marketRewards.reflectToMinters{value: minterReward}();

        //Transfer 25% to the development wallet
        _devWallet.transfer(devReward);
    }

    function setAcceptablePaymentToken(address addr_, bool acceptable_)
        external
        authorized
    {
        require(addr_ != address(0), "Can not be the zero address.");
        if (acceptable_) {
            addAcceptablePaymentToken(addr_);
        } else {
            removeAcceptablePaymentToken(addr_);
        }
    }

    function setAcceptablePaymentNFT(address addr_, bool acceptable_)
        external
        authorized
    {
        require(addr_ != address(0), "Can not be the zero address.");
        if (acceptable_) {
            addAcceptablePaymentNFT(addr_);
        } else {
            removeAcceptablePaymentNFT(addr_);
        }
    }

    function setAcceptableOfferedNFT(address addr_, bool acceptable_)
        external
        authorized
    {
        require(addr_ != address(0), "Can not be the zero address.");
        if (acceptable_) {
            addAcceptableOfferedNFT(addr_);
        } else {
            removeAcceptableOfferedNFT(addr_);
        }
    }

    /* Helper functions */
    function removeTokenOffer(
        address _nftAddress,
        uint256 _nftId,
        uint256 _offerIndex,
        uint256 _offerId,
        bytes32 _status
    ) private {
        require(
            _offerIndex < _tokenOffersByCollection[_nftAddress][_nftId].length,
            "Offer index out of range"
        );
        require(
            _tokenOffersByCollection[_nftAddress][_nftId][_offerIndex]
                .tokenOfferId == _offerId,
            "The offers have updated."
        );

        TokenOffer memory lastOffer = _tokenOffersByCollection[_nftAddress][
            _nftId
        ][_tokenOffersByCollection[_nftAddress][_nftId].length - 1];

        // Update removed offer status
        tokenOffers[_offerId - 1].status = _status;

        emit TokenOfferUpdated(
            _offerId,
            _nftAddress,
            _nftId,
            tokenOffers[_offerId - 1].tokenAddress,
            tokenOffers[_offerId - 1].price,
            tokenOffers[_offerId - 1].buyer,
            _status
        );

        _tokenOffersByCollection[_nftAddress][_nftId][_offerIndex] = lastOffer;
        // Update index
        tokenOffers[lastOffer.tokenOfferId - 1].index = _offerIndex;

        _tokenOffersByCollection[_nftAddress][_nftId].pop();
    }

    function removeNFTOffer(
        address _nftAddress,
        uint256 _nftId,
        uint256 _offerIndex,
        uint256 _offerId,
        bytes32 _status
    ) private {
        require(
            _offerIndex < _nftOffersByCollection[_nftAddress][_nftId].length,
            "Offer index out of range"
        );
        require(
            _nftOffersByCollection[_nftAddress][_nftId][_offerIndex]
                .nftOfferId == _offerId,
            "The offers have updated."
        );

        NftOffer memory lastOffer = _nftOffersByCollection[_nftAddress][_nftId][
            _nftOffersByCollection[_nftAddress][_nftId].length - 1
        ];

        // Update removed offer status
        nftOffers[_offerId - 1].status = _status;

        emit NftOfferUpdated(
            _offerId,
            _nftAddress,
            _nftId,
            nftOffers[_offerId - 1].soldNftAddress,
            nftOffers[_offerId - 1].soldNftIds,
            nftOffers[_offerId - 1].buyer,
            _status
        );

        _nftOffersByCollection[_nftAddress][_nftId][_offerIndex] = lastOffer;
        // Update index
        nftOffers[lastOffer.nftOfferId - 1].index = _offerIndex;

        _nftOffersByCollection[_nftAddress][_nftId].pop();
    }

    function sellToken(address contractAddress, uint256 amount) private {
        pendingRewards[contractAddress] = 0;

        address[] memory path = new address[](2);
        path[0] = contractAddress;
        path[1] = router.WETH();

        IBEP20(contractAddress).approve(address(router), amount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addAcceptablePaymentToken(address addr_) private {
        if (!isAcceptablePaymentToken(addr_)) {
            acceptablePaymentTokens.push(addr_);
        }
    }

    function addAcceptablePaymentNFT(address addr_) private {
        if (!isAcceptablePaymentNFT(addr_)) {
            acceptablePaymentNFTs.push(addr_);
        }
    }

    function addAcceptableOfferedNFT(address addr_) private {
        if (!isAcceptableOfferedNFT(addr_)) {
            acceptableOfferedNFTs.push(addr_);
        }
    }

    function removeAcceptablePaymentToken(address addr_) private {
        for (uint256 i = 0; i < acceptablePaymentTokens.length; i++) {
            if (acceptablePaymentTokens[i] == addr_) {
                acceptablePaymentTokens[i] = acceptablePaymentTokens[
                    acceptablePaymentTokens.length - 1
                ];
                acceptablePaymentTokens.pop();
                break;
            }
        }
    }

    function removeAcceptablePaymentNFT(address addr_) private {
        for (uint256 i = 0; i < acceptablePaymentNFTs.length; i++) {
            if (acceptablePaymentNFTs[i] == addr_) {
                acceptablePaymentNFTs[i] = acceptablePaymentNFTs[
                    acceptablePaymentNFTs.length - 1
                ];
                acceptablePaymentNFTs.pop();
                break;
            }
        }
    }

    function removeAcceptableOfferedNFT(address addr_) private {
        for (uint256 i = 0; i < acceptableOfferedNFTs.length; i++) {
            if (acceptableOfferedNFTs[i] == addr_) {
                acceptableOfferedNFTs[i] = acceptableOfferedNFTs[
                    acceptableOfferedNFTs.length - 1
                ];
                acceptableOfferedNFTs.pop();
                break;
            }
        }
    }

    function isAcceptablePaymentToken(address addr_)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < acceptablePaymentTokens.length; i++) {
            if (acceptablePaymentTokens[i] == addr_) {
                return true;
            }
        }
        return false;
    }

    function isAcceptablePaymentNFT(address addr_) public view returns (bool) {
        for (uint256 i = 0; i < acceptablePaymentNFTs.length; i++) {
            if (acceptablePaymentNFTs[i] == addr_) {
                return true;
            }
        }
        return false;
    }

    function isAcceptableOfferedNFT(address addr_) public view returns (bool) {
        for (uint256 i = 0; i < acceptableOfferedNFTs.length; i++) {
            if (acceptableOfferedNFTs[i] == addr_) {
                return true;
            }
        }
        return false;
    }

    /* Fallback */
    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;

        emit Authorized(adr);
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;

        emit Unauthorized(adr);
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
    event Authorized(address adr);
    event Unauthorized(address adr);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountETH,
            uint liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: No License

pragma solidity ^0.8.15;

abstract contract MarketRewards {
    function reflectToMinters() public payable virtual;

    function reflectToHolders() public payable virtual;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./interfaces/IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}