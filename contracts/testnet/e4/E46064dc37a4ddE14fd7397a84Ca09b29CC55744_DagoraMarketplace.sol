// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
import "./utils/Admin.sol";

import "./interfaces/IDagoraMarketplace.sol";
import "./interfaces/IDagora.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IERC721.sol";

import "./libraries/SafeMath.sol";
import "./libraries/SafeERC20.sol";
import "./libraries/ECDSA.sol";

contract DagoraMarketplace is IDagoraMarketplace, Admin {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // Package info
    struct PackageInfo {
        bool isInitial; // Flag for package
        uint256 claimFee; // Claim fee
        uint256 martketFee; // Market fee
        uint256 listingFee; // Listing fee
        uint256 totalRoyaltyFee; // Total royalty fee
    }

    struct ListingInfo {
        address seller;
        address saleByToken;
        uint256 startPrice;
        uint256 endPrice;
        uint256 expiresAt;
    }

    struct RoyaltyFeeConfig {
        uint32 fee;
        uint256 expiresAt;
    }

    uint constant PERCENT = 10000;
    uint256 public profileFee = 10 ether;
    bytes32 public message = "Dagora";
    address public paymentAddress;
    address override public dagoraRoyaltyFee;
    
    // keccak256(abi.encodePacked(_nfts, _ids)) => ListingInfo (to avoid asset collision)
    mapping(bytes32 => ListingInfo) private _listingInfos;
    mapping(bytes => bool) private _signatureUseds;
    mapping(address => PackageInfo) private _packageInfos;
    mapping(uint256 => RoyaltyFeeConfig) private _royaltyFeeConfigs;

    // using one time each buy action
    mapping(address => bool) private _isTransferRoyaltyFee;

    constructor(address _paymentAddress, address _dagoraRoyaltyFee) {
        // @dev register default package for main token
        registerPackage(address(0),250,0,2000);
        paymentAddress = _paymentAddress;
        dagoraRoyaltyFee = _dagoraRoyaltyFee;
    }

    /**
     * ======================================================================================
     * 
     * MODIFIER
     *
     * ======================================================================================
     */

    modifier isUnuseSignature(bytes memory _signature) {
        require(!_signatureUseds[_signature], "Dagora Marketplace: Invalid signature format");
        _;
    }

    modifier isInitPackage(address _package) {
        require(_packageInfos[_package].isInitial, "Dagora Marketplace: Package not active");
        _;
    }

    modifier isValidTime(uint256 _time) {
        require(block.timestamp <= _time, "Dagora Marketplace: Time over");
        _;
    }

    /**
     * ======================================================================================
     * 
     * PRIVATE FUNCTION
     *
     * ======================================================================================
     */

    /**
     * @dev Return Address contract of CREATE opcode
     * @param _creator creator of contract
     * @param _nonce nonce of create transaction
     * @return address of contract created
     */
    function _getAddressCreate(address _creator, uint _nonce) private pure returns(address) {
        bytes memory data;
        if (_nonce == 0x00) {
            data = abi.encodePacked(byte(0xd6), byte(0x94), _creator, byte(0x80));
        } else if (_nonce <= 0x7f) {
            data = abi.encodePacked(byte(0xd6), byte(0x94), _creator, uint8(_nonce));
        } else if (_nonce <= 0xff) {
            data = abi.encodePacked(byte(0xd7), byte(0x94), _creator, byte(0x81), uint8(_nonce));
        } else if (_nonce <= 0xffff) {
            data = abi.encodePacked(byte(0xd8), byte(0x94), _creator, byte(0x82), uint16(_nonce));
        } else if (_nonce <= 0xffffff) {
            data = abi.encodePacked(byte(0xd9), byte(0x94), _creator, byte(0x83), uint24(_nonce));
        } else {
            data = abi.encodePacked(byte(0xda), byte(0x94), _creator, byte(0x84), uint32(_nonce));
        }
        return address(uint256(keccak256(data)));
    }

    /**
     * @dev Return Address contract of CREATE2 opcode
     * @param _creator creator of contract
     * @param _codeHash keccak256(init code of contract)
     * @param _salt salt when create
     * @return address of contract created
     */
    function _getAddressCreate2(address _creator, bytes32 _codeHash, uint256 _salt) private pure returns(address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), _creator, _salt, _codeHash)))));
    }

    /**
     * @dev validate nft 
     * @param _token ERC721 address
     * @param _owner expect owner of token
     * @param _id token id
     * @param _checkApprove flag for check approve 
     * @return NFT is valid
     */
    function _validateNFT(IERC721 _token, address _owner, uint256 _id, bool _checkApprove) private view returns (bool) {
        if (_getOwnerOfToken(address(_token), _id) != _owner) {
            return false;
        }

        if (_checkApprove) {
            bool isApproveAll = _token.isApprovedForAll(_owner ,address(this));
            if (_token.getApproved(_id) != address(this) && !isApproveAll) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev disable signature 
     * @param _signature signature
     */
    function _disableSignature(bytes memory _signature) private {
        _signatureUseds[_signature] = true;
    }

    /**
     * @dev Sub market fee and stora fee in contract 
     * @param _amount amount of action
     * @param _claimFee Claim fee of package
     * @param _marketFee Market fee of package
     * @return amount after sub fee
     */
    function _subMarketFee(uint256 _amount, uint256 _claimFee, uint256 _marketFee) private pure returns(uint256) {
        uint256 amount = _amount;
        if (_claimFee > 0) {
            amount = amount.sub(_claimFee);
        }
        if (_marketFee > 0) {
            amount = amount.sub(amount.div(PERCENT).mul(_marketFee));
        }

        return amount;
    } 


    /**
     * @dev verify signer of signature is expect signer 
     * @param _metaAddress meta address
     * @param _metaUint meta uint
     * @param _signature signature
     * @param _signerExpected expect signer
     * @return signature is valid
     */
    function _verifySignature(address[] calldata _metaAddress, uint256[] calldata _metaUint, bytes memory _signature, address _signerExpected) private view returns(bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(_metaAddress, _metaUint, message));
        return _verifySignature(messageHash, _signature, _signerExpected);
    }

    /**
     * @dev verify signer of signature is expect signer 
     * @param _messageHash hash of message
     * @param _signature signature
     * @param _signerExpected expect signer
     * @return signature is valid
     */
    function _verifySignature(bytes32 _messageHash, bytes memory _signature, address _signerExpected) private pure returns(bool) {
        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(_messageHash);

        return ECDSA.recover(ethSignedMessageHash, _signature) == _signerExpected;
    }

    /**
     * @dev private safe transfer nft 
     * @param _tokenAddresses list nft addresses to transfer
     * @param _tokenIds list nft id to transfer
     * @param _from from address
     * @param _to to address
     */
    function _safeTransferNFT(address[] memory _tokenAddresses, uint256[] memory _tokenIds, address _from, address _to) private {
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            IERC721 meta = IERC721(_tokenAddresses[i]);
            meta.transferFrom(_from, _to, _tokenIds[i]);
        }
    }


    /**
     * @dev delete listing info 
     * @param _nftHash nft hash to delete
     */
    function _deleteListingInfo(bytes32 _nftHash) private {
        delete _listingInfos[_nftHash];
    }

    /**
     * @dev clear `_isTransferRoyaltyFee` (temp) 
     */
    function _clearTempTransferRoyaltyFee(address[] memory _collections) private {
        for(uint i = 0; i < _collections.length; i++) {
            delete _isTransferRoyaltyFee[_collections[i]];
        }
    }

    /**
     * @dev check valid royalty fee
     */
    function _isValidateRoyaltyFee(uint256 _royaltyFeeId) private view returns(bool) {
        address owner = _getOwnerOfToken(dagoraRoyaltyFee, _royaltyFeeId);
        if (owner == address(0)) {
            return false;
        }

        uint256 expiresAt = _royaltyFeeConfigs[_royaltyFeeId].expiresAt;
        uint256 fee = _royaltyFeeConfigs[_royaltyFeeId].fee;

        if (fee > 0 && (expiresAt > block.timestamp || expiresAt == 0)) {
            return true;
        }
        
        return false;
    }

    /**
     * @dev check all collections are the same
     */
    function _isSameCollection(address[] memory _collections) private pure returns(bool) {
        address _col = _collections[0];
        for (uint i = 0; i < _collections.length; i++) {
            if (_col != _collections[i]) {
                return false;
            }
        }
        return true;
    }

    function _getOwnerOfToken(address _token, uint256 _tokenId) private view returns(address) {
        try IERC721(_token).ownerOf(_tokenId) returns (address _owner) {
            return _owner;
        } catch Error(string memory) {
            return address(0);
        }
    }

    /**
     * @dev transfer royalty fee if it have 
     * @param _collection collection to transfer royalty fee
     * @param _tokenAddress token fee
     * @param _amount amount of action
     */
    function _transferRoyaltyFee(address _collection, address _tokenAddress, uint256 _amount, uint256 _totalPercent) private {
        uint256 royaltyFeeId = uint256(uint160(_collection));

        if (_isValidateRoyaltyFee(royaltyFeeId)) {
            uint256 fee = _royaltyFeeConfigs[royaltyFeeId].fee;

            uint256 feePercent = fee.mul(PERCENT).div(_totalPercent);
            uint256 payment = _amount.mul(feePercent).div(PERCENT); 
            if (_tokenAddress != address(0)) {
                IERC20 token = IERC20(_tokenAddress);
                token.safeTransfer(_getOwnerOfToken(dagoraRoyaltyFee, royaltyFeeId), payment);
            } else {
                payable(_getOwnerOfToken(dagoraRoyaltyFee, royaltyFeeId)).transfer(payment);
            }
        }
    }
    
    /**
     * @dev Sub royalty fee and transfer fee to receiver, each collection will transfer royalty fee one time per transaction 
     * @param _collections list collection
     * @param _tokenAddress token fee
     * @param _amount amount of action
     * @return amount after sub fee
     */
    function _subRoyaltyFee(address[] memory _collections, address _tokenAddress, uint _amount) private returns(uint256) {
        uint256 subAmount = _amount;
        uint256 totalRoyaltyFee = 0;

        if (_isSameCollection(_collections)) {
            uint256 royaltyFeeId = uint256(uint160(_collections[0]));
            if (_isValidateRoyaltyFee(royaltyFeeId)) {
                totalRoyaltyFee = subAmount.mul(_royaltyFeeConfigs[royaltyFeeId].fee).div(PERCENT);
                _transferRoyaltyFee(_collections[0], _tokenAddress, totalRoyaltyFee, _royaltyFeeConfigs[royaltyFeeId].fee);
            }
        } else {
            totalRoyaltyFee = subAmount.mul(_packageInfos[_tokenAddress].totalRoyaltyFee).div(PERCENT);
            uint256 totalPercent = 0;

            for (uint i = 0; i < _collections.length; i++) {
                uint256 royaltyFeeId = uint256(uint160(_collections[i]));
                if (_isValidateRoyaltyFee(royaltyFeeId)) {
                    totalPercent = totalPercent.add(_royaltyFeeConfigs[royaltyFeeId].fee);
                }
            }

            if (totalPercent == 0) {
                return _amount;
            }

            for (uint i = 0; i < _collections.length; i++) {
                if (!_isTransferRoyaltyFee[_collections[i]]) {
                    _transferRoyaltyFee(_collections[i], _tokenAddress, totalRoyaltyFee, totalPercent);
                }
                _isTransferRoyaltyFee[_collections[i]] = true;
            }
            _clearTempTransferRoyaltyFee(_collections);
        }


        return _amount.sub(totalRoyaltyFee);
    }

    /**
     * @dev Get contract address was deploy with param
     * @param _byteCodeHash byte code hash of collection deployed on network
     * @param _nonce nonce of creator when deployed collection of salt if create with CREATE2 opcode
     * @param _isCreate2 is CREATE2 
     * @return address of contract was deploy
     */
    function _getContractAddress(bytes32 _byteCodeHash, uint256 _nonce, bool _isCreate2) private view returns(address) {
        if (_isCreate2) {
            return _getAddressCreate2(msg.sender, _byteCodeHash, _nonce);
        } else {
            return _getAddressCreate(msg.sender, uint(_nonce));
        }
    }

    /**
     * ======================================================================================
     * 
     * PUBLIC FUNCTION
     *
     * ======================================================================================
     */

    /**
     * @dev set new dagora royalty fee
     */
    function setDagoraRoyaltyFee(address _dagoraRoyaltyFee) public onlyOwner {
        dagoraRoyaltyFee = _dagoraRoyaltyFee;
    }

    /**
     * @dev set royalty fee only creator of nft contract can call this action 
     * @param _collection collection to set royalty fee
     * @param _byteCodeHash byte code hash of collection deployed on network
     * @param _nonce nonce of creator when deployed collection of salt if create with CREATE2 opcode
     * @param _isCreate2 is CREATE2 
     * @param _fee fee 
     * @param _expiresAt date of royalty fee 
     */
    function setRoyaltyFeeOwner(address _collection, bytes32 _byteCodeHash, uint256 _nonce, bool _isCreate2,  uint32 _fee, uint256 _expiresAt) external override {
        require(_fee < 10000, "Dagora Marketplace: Invalid input");
        uint256 royaltyFeeId = uint256(uint160(_collection));
        address owner = _getOwnerOfToken(dagoraRoyaltyFee, royaltyFeeId);
        if (owner == address(0)) {
            require(_collection == _getContractAddress(_byteCodeHash, _nonce, _isCreate2), "Dagora Marketplace: Not creator of collection");
            IDagora(dagoraRoyaltyFee).mint(msg.sender, royaltyFeeId);
        } else {
            require(_getOwnerOfToken(dagoraRoyaltyFee, royaltyFeeId) == msg.sender, "Dagora Marketplace: Not owner of royalty fee");
        }

        _royaltyFeeConfigs[royaltyFeeId].fee = _fee;
        _royaltyFeeConfigs[royaltyFeeId].expiresAt = _expiresAt;
        emit UpdateRoyaltyFee(_collection, _fee, _expiresAt);
    }


    /**
     * @dev set royalty fee, admin can call this action
     * @param _collection collection to set royalty fee
     * @param _owner owner of royalty fee
     * @param _fee fee 
     * @param _expiresAt date of royalty fee 
     */
    function setRoyaltyFeeAdmin(address _collection, address _owner, uint32 _fee, uint256 _expiresAt) public onlyAdmin {
        require(_fee < 10000, "Dagora Marketplace: Invalid input");
        uint256 royaltyFeeId = uint256(uint160(_collection));
        address owner = _getOwnerOfToken(dagoraRoyaltyFee, royaltyFeeId);

        if (owner == address(0)) {
            IDagora(dagoraRoyaltyFee).mint(_owner, royaltyFeeId);
        }

        _royaltyFeeConfigs[royaltyFeeId].fee = _fee;
        _royaltyFeeConfigs[royaltyFeeId].expiresAt = _expiresAt;
        emit UpdateRoyaltyFee(_collection, _fee, _expiresAt);
    }
    
    // @dev Change Payment Default token
    function changePaymentToken(address _paymentAddress) public onlyOwner() {
        paymentAddress = _paymentAddress;
    }

    // @dev Register Package for token can sell in dagora 
    function registerPackage(address _token, uint256 _marketFee, uint256 _claimFee, uint256 _totalRoyaltyFee) public onlyOwner() {
        PackageInfo storage packageInfo = _packageInfos[_token];

        packageInfo.isInitial = true;
        packageInfo.martketFee = _marketFee;
        packageInfo.claimFee = _claimFee;
        packageInfo.totalRoyaltyFee = _totalRoyaltyFee;
    }

    // @dev Config Package for token can sell in dagora 
    function configurePackage(address _token, uint256 _marketFee, uint256 _claimFee, uint256 _totalRoyaltyFee) public isInitPackage(_token) onlyOwner() {
        PackageInfo storage packageInfo = _packageInfos[_token];

        packageInfo.martketFee = _marketFee;
        packageInfo.claimFee = _claimFee;
        packageInfo.totalRoyaltyFee = _totalRoyaltyFee;
    }

    // @dev Unregister Package for token can sell in dagora 
    function unRegisterPackage(address _token) public onlyOwner() {
        delete _packageInfos[_token];
    }

    /**
     * @dev Configure fixed variable
     *
     * Requirements:
     *
     * - `profile_fee` the fee charged when change profile on Dagora System.
     */
    function configureFixedVariable(uint256 _profileFee, bytes32 _message) public onlyOwner() {
       profileFee = _profileFee;
       message = _message;
    }

    /**
     * @dev Pay `profile_fee` for change profile on Dagora System
     * Emits a {_pay} event.
     */
    function pay() public {
        IERC20 paymentToken = IERC20(paymentAddress);
        require(paymentToken.transferFrom(msg.sender, address(this), profileFee));
        
        emit DagoraPayment(msg.sender);
    }

    // @dev Buy NFT on dagora with signed signature.
    // @param _metaAddress define with a list of address below [sale by token, seller, buyer, ...erc721 meta token]
    // @param _metaUInt define with a list of Uint below [amount , time, duration, nonce, ...token id]
    // @param _signature signature of seller to sell this list nft
    function buy(address[] calldata _metaAddress, uint256[] calldata _metaUInt, bytes memory _signature) public payable isUnuseSignature(_signature) isInitPackage(_metaAddress[0]) isValidTime(_metaUInt[1] + _metaUInt[2]) {
        require(_verifySignature(_metaAddress, _metaUInt, _signature, _metaAddress[1]), "Dagora Marketplace: Signature not match");
        require(_metaAddress.length >= 4, "Dagora Marketplace: Invalid Input");
        require(_metaAddress.length + 1 == _metaUInt.length, "Dagora Marketplace: Invalid Input");

        address[] memory tokenSaleList = new address[](_metaAddress.length - 3);
        uint256[] memory tokenIdList = new uint256[](_metaUInt.length - 4);

        for (uint256 i = 0; i < _metaAddress.length - 3; i++) {
            tokenSaleList[i] = _metaAddress[i + 3];
            tokenIdList[i] = _metaUInt[i + 4];
        }

        if (_metaAddress[2] != address(0)) {
            require(_metaAddress[2] == msg.sender, "Dagora Marketplace: Only reserve address can make this payment");
        }
         
        // get amount to contract
        if (_metaAddress[0] == address(0)) {
            require(msg.value >= _metaUInt[0], "Dagora Marketplace: Not enough payment");
        } else {
            IERC20(_metaAddress[0]).safeTransferFrom(msg.sender, address(this), _metaUInt[0]);
        }

        // transfer Royalty fee: buyer -> creator
        uint256 amountAfterSubMarketFee = _subMarketFee(_metaUInt[0], _packageInfos[_metaAddress[0]].claimFee, _packageInfos[_metaAddress[0]].martketFee);
        uint256 amountAfterSubRoyaltyFee = _subRoyaltyFee(tokenSaleList, _metaAddress[0], amountAfterSubMarketFee);

        // transfer NFT: seller -> buyer
        _safeTransferNFT(tokenSaleList, tokenIdList, _metaAddress[1], msg.sender);

        // transfer token: contract -> seller
        if (_metaAddress[0] == address(0)) {
            payable(_metaAddress[1]).transfer(amountAfterSubRoyaltyFee);
        } else {
            IERC20(_metaAddress[0]).safeTransfer(_metaAddress[1], amountAfterSubRoyaltyFee);
        }

        _disableSignature(_signature);

        emit Buy(msg.sender, _metaAddress, _metaUInt);
    }

    // @dev cancel signature was sign
    // @param metaAddress define with a list of address below [sale by token, seller, buyer, ...erc721 meta token]
    // @param metaUInt define with a list of Uint below [amount , time, duration, nonce, ...token id]
    // @param _signature signature of seller to sell this list nft
    function cancel(address[] calldata metaAddress, uint256[] calldata metaUInt, bytes memory _signature) public {
        for (uint256 i = 3; i < metaAddress.length; i++) {
            IERC721 meta = IERC721(metaAddress[i]);
            require(_validateNFT(meta, msg.sender, metaUInt[i + 1], false), "Dagora Marketplace: Invalid NFT");
        }
        require(_verifySignature(metaAddress, metaUInt, _signature, msg.sender), "Dagora Marketplace: Signature not match");
        _disableSignature(_signature);
    }

    // @dev Update listing info
    // @param _nftHashs hash of nfts to update
    // @param _startPrice minimun price seller wants to sale
    // @param _endPrice maximun price seller wants to sale
    // @param _expiresAt time of bid
    function updateListingInfo(bytes32 _nftHash, uint256 _startPrice, uint256 _endPrice,  uint256 _expiresAt) public isValidTime(_expiresAt) {
        ListingInfo storage listingInfo = _listingInfos[_nftHash];

        require(listingInfo.seller == msg.sender, "Dagora Marketplace: Only onwer can update listing info");
        require(_startPrice <= listingInfo.startPrice, "Dagora Marketplace: The new sale price must be lower than the current price");

        listingInfo.startPrice = _startPrice;
        listingInfo.endPrice = _endPrice;
        listingInfo.expiresAt = _expiresAt;
    }

    // @dev Listing list nft to market to bid (the bid will be process off chain)
    // @param _saleByToken token sale
    // @param _tokenAddresses list nft addres to listing
    // @param _tokenIds list nft id to listing
    // @param _startPrice minimun price seller wants to sale
    // @param _endPrice maximun price seller wants to sale
    // @param _expiresAt time of bid
    function listing(address _saleByToken, address[] calldata _tokenAddresses, uint256[] calldata _tokenIds, uint256 _startPrice, uint256 _endPrice,  uint256 _expiresAt) public isValidTime(_expiresAt) {
        require (_tokenAddresses.length == _tokenIds.length, "Dagora Marketplace: Invalid Input");
        require(_saleByToken != address(0), "Dagora Marketplace: Native token not support");

        bytes32 nftHash = keccak256(abi.encodePacked(_tokenAddresses, _tokenIds));

        require(_listingInfos[nftHash].seller == address(0), "Dagora Marketplace: List item already listed on dagora");

        _listingInfos[nftHash] = ListingInfo({
            seller: msg.sender,
            saleByToken: _saleByToken,
            startPrice: _startPrice,
            endPrice: _endPrice,
            expiresAt: _expiresAt
        });

        PackageInfo memory package = _packageInfos[_saleByToken];

        // get fee
        if (package.listingFee > 0) {
            IERC20 token = IERC20(_saleByToken);
            token.transferFrom(msg.sender, address(this), package.listingFee);
        }

        // transfer nft to marketplace
        _safeTransferNFT(_tokenAddresses, _tokenIds, msg.sender, address(this));

        emit ListingNFT(msg.sender, _tokenAddresses, _tokenIds, _startPrice, _expiresAt);
    }

    // @dev Cancel listing list nft 
    // @param _tokenAddresses list nft addres to cancel listing
    // @param _tokenIds list nft id to cancel listing
    function cancelListing(address[] calldata _tokenAddresses, uint256[] calldata _tokenIds) public {
        require (_tokenAddresses.length == _tokenIds.length, "Dagora Marketplace: Invalid Input");
        bytes32 nftHash = keccak256(abi.encodePacked(_tokenAddresses, _tokenIds));

        require(_listingInfos[nftHash].seller == msg.sender, "Dagora Marketplace: Sender does not owner");

        _deleteListingInfo(nftHash);
        _safeTransferNFT(_tokenAddresses, _tokenIds, address(this), msg.sender);

        emit CancelListingNFT(msg.sender, nftHash);
    }

    // @dev after bid process, admin will end bid 
    // @param _tokenAddresses list nft addres to cancel listing
    // @param _tokenIds list nft id to cancel listing
    // @param _amount amount of bid
    // @param _buyer buyer address
    // @param _signature signature of buyer accept buy this list nft
    // @param _nonce one time use number
    function endBid(address[] calldata _tokenAddresses, uint256[] calldata _tokenIds, uint256 _amount, address _buyer, bytes memory _signature, uint _nonce) public onlyAdmin isUnuseSignature(_signature) {
        require(_tokenAddresses.length == _tokenIds.length, "Dagora Marketplace: Invalid Input");
        bytes32 nftHash = keccak256(abi.encodePacked(_tokenAddresses, _tokenIds));
        ListingInfo storage listingInfo = _listingInfos[nftHash];
        require(listingInfo.seller != address(0), "Dagora Marketplace: Listing does not exist");
        if (listingInfo.endPrice == 0 || _amount < listingInfo.endPrice) {
            // check bid end
            require(listingInfo.expiresAt < block.timestamp, "Dagora Marketplace: Bid does not end");
        }
        require(listingInfo.startPrice <= _amount, "Dagora Marketplace: Amount should larger than startPrice");

        bytes32 messageHash = keccak256(abi.encodePacked(nftHash, _amount, message, _nonce));
        require(_verifySignature(messageHash, _signature, _buyer), "Dagora Marketplace: Invalid Signature");

        IERC20 saleByToken = IERC20(listingInfo.saleByToken);
        saleByToken.safeTransferFrom(_buyer, address(this), _amount);

        uint256 amountAfterSubMarketFee = _subMarketFee(_amount, _packageInfos[listingInfo.saleByToken].claimFee, _packageInfos[listingInfo.saleByToken].martketFee);
        uint256 amountAfterSubRoyaltyFee = _subRoyaltyFee(_tokenAddresses, listingInfo.saleByToken, amountAfterSubMarketFee);

        saleByToken.safeTransfer(listingInfo.seller, amountAfterSubRoyaltyFee);

        _deleteListingInfo(nftHash);
        _disableSignature(_signature);

        _safeTransferNFT(_tokenAddresses, _tokenIds, address(this), _buyer);

        emit EndBid(_buyer, nftHash, _amount);
    }

    // @dev get listing info
    // @param _nftHash hash of nft list
    // @return listingInfo of nft list
    function getListingInfo(bytes32 _nftHash) public view returns(address, address, uint256, uint256, uint256) {
        ListingInfo memory data = _listingInfos[_nftHash];
        return (data.seller, data.saleByToken, data.startPrice, data.endPrice, data.expiresAt);
    }

    // @dev get package info
    // @param _token token to sell on dagora
    // @return info of package
    function getPackageInfo(address _token) public view returns(bool, uint256, uint256, uint256) {
        PackageInfo memory data = _packageInfos[_token];
        return (data.isInitial, data.claimFee, data.martketFee, data.listingFee);
    }

    // @dev get royalty fee info
    // @param _collection collection
    // @return info of royalty fee
    function getRoyaltyFeeConfig(address _collection) public view returns(uint256, uint256) {
        RoyaltyFeeConfig memory data = _royaltyFeeConfigs[uint256(uint160(_collection))];
        return (data.fee, data.expiresAt);
    }

    function withdrawNFT(uint256 _tokenID, address _tokenAddress) public onlyOwner {
        require(_tokenID > 0);
        IERC721 meta = IERC721(_tokenAddress);
        meta.transferFrom(address(this), msg.sender,_tokenID);
    }

    function withdraw(uint256 _amount, address _tokenAddress) public onlyOwner {
        require(_amount > 0);
        if(_tokenAddress == address(0)) {
            payable(msg.sender).transfer(_amount);
        }else{
            IERC20 _token = IERC20(_tokenAddress);
            _token.safeTransfer(msg.sender, _amount);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";

abstract contract Admin is Ownable {
    mapping (address => bool) _admins;

    constructor() {
        _admins[msg.sender] = true;
    }
    
    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Admin: caller is not the admin");
        _;
    }

    function addAdmin(address _admin) public virtual onlyOwner {
        _admins[_admin] = true;
    }

    function removeAdmin(address _admin) public virtual onlyOwner {
        _admins[_admin] = false;
    }

    function isAdmin(address _admin) public view returns(bool) {
        return _admins[_admin];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./IERC721.sol";

interface IDagoraMarketplace {
    event Pay(address _address, uint256 _time);
    event DagoraPayment(address _address);
    event Buy(address _buyer, address[] _metaAddress,uint256[] _metaUInt);
    event ListingNFT(address _seller, address[] _nfts, uint256[] _ids, uint256 _startPrice, uint256 _expiresAt);
    event CancelListingNFT(address _seller, bytes32 _nftHash);
    event EndBid(address _buyer, bytes32 _nftHash, uint256 _amount);
    event UpdateRoyaltyFee(address _collection, uint32 _fee, uint256 _expiresAt);

    function setRoyaltyFeeOwner(address _collection, bytes32 _byteCodeHash, uint256 _nonce, bool _isCreate2, uint32 _fee, uint256 _expiresAt) external;
    function dagoraRoyaltyFee() external returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IDagora {
    function mint(address _to, uint256 _tokenId) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function getApproved(uint256 tokenId) external view returns (address operator);

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
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../interfaces/IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover-bytes32-bytes-} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function _initialOwner(address _newOwner) internal {
        require(owner() == address(0), "Dagora Onwable: already init");
        _owner = _newOwner;
        emit OwnershipTransferred(_owner, _newOwner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

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
pragma solidity >=0.7.0 <0.9.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}