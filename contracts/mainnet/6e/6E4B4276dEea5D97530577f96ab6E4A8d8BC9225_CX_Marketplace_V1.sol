// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "@openzeppelin/contracts/interfaces/IERC1155.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

import "./CXERC2771ContextUpgradeable.sol";
import "./registry/ProxyRegistry.sol";
import "./registry/AuthenticatedProxy.sol";

contract CX_Marketplace_V1 is Initializable, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable, CXERC2771ContextUpgradeable {
    // Contract name
    string public constant name = "CryptoXpress NFT Marketplace";
    // Contract symbol
    string public constant symbol = "CX_NFT_MARKET";
    // Contract version
    string public version;

    /* User registry. */
    ProxyRegistry public registry;

    uint public constant percentBasisPoints = 10000; // bps for percentage calculation

    // enum for different types of listings possible. none = not listed. auctions must be handled off-chain.
    enum LISTING_TYPE {
        NONE,
        FIXED_PRICE, 
        AUCTION
    }

    struct Listing {
        bool initialized; // just a check field
        address nftContract; // address of ERC1155/ERC721 contract
        address owner; // address of owner of token
        uint tokenId; // id of token in the given ERC1155/ERC721 contract
        LISTING_TYPE listingType;
        uint listedQuantity; // max quantity that others can purchase (0 <= listedQuantity <= tokenBalance)
        uint price; // price per asset
        address paymentToken; // payment ERC20 token address; 0 address for native token
        uint startTime; // list start time (not active until start)
        uint endTime; // list end time (no longer active once ended); 0 for indefinite
        address approvedBidder; // approved address who could buy the token in an auction listing
    }

    // used as params for Trade function
    struct BuyData {
        uint tokenId;
        uint quantity;
        address nftContract;
        address fromAddress;
    }

    // used as params for List function
    struct ListData {
        uint tokenId;
        address nftContract;
        uint price;
        address paymentToken;
        uint listQuantity;
        LISTING_TYPE listingType;
        uint startTime;
        uint endTime;
    }

    // Using the below struct to avoid Stack too deep error
    struct TradeInfo {
        address payable buyer;
        address payable owner;
        address payable royaltyReceiver;
        uint totalPrice;
        uint royalty;
        uint commission;
        uint pricePayable;
    }

    /* A call, convenience struct. */
    struct Call {
        /* Target */
        address target;
        /* How to call */
        AuthenticatedProxy.HowToCall howToCall;
        /* Calldata */
        bytes data;
    }

    // CX's commission on every trade of NFT
    uint public commissionPercentage; // 100 = 1%; 10000 = 100%
    address payable public commissionPayoutAddress;

    // do not apply commission to excluded addresses
    mapping (address => bool) public commissionExclusionAccounts;
    // apply a specific commission on sales for these addresses; value if 0, apply global commission 
    mapping (address => uint) public customCommissionAccounts;

    mapping(bytes32 => Listing) private listings;

    // BEP20 tokens that are allowed to be used for sale transactions
    mapping (address => bool) public allowedPaymentTokens;

    // ERC165 interface IDs
    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    mapping(address => bool) private bannedContracts;
    mapping(address => bool) private bannedAccounts;
    mapping(address => mapping(uint256 => bool)) private bannedTokens;

    event Purchase(address indexed nftContract, address indexed from, address indexed to, uint totalPrice, address paymentToken, uint royalty, uint commission, uint quantity, uint nftID);

    // only emitted when updating FIXED_PRICE listing
    event PriceUpdate(address indexed nftContract, address indexed owner, uint oldPrice, uint newPrice, uint nftID, address paymentToken);

    // only emitted when updating FIXED_PRICE listing
    event ListedQuantityUpdate(address indexed nftContract, address indexed owner, uint oldQuantity, uint newQuantity, uint nftID);

    // only emitted when updating/removing bidder and bid in AUCTION listing. When bidder updated, type will be 'ADDED', when removed type will be 'REMOVED'
    event BidderUpdate(address indexed nftContract, address indexed owner, uint bidId, address indexed bidder, uint bid, uint nftID, string updateType);

    event NftListStatus(address indexed nftContract, address indexed owner, uint nftID, LISTING_TYPE listingType, uint listedQuantity, uint price, address paymentToken, uint startTime, uint endTime);

    event TokenBanSet(address indexed nftContract, uint nftID, bool banned);
    event ContractBanSet(address indexed nftContract, bool banned);
    event AccountBanSet(address indexed account, bool banned);

    event PaymentTokensModification(address indexed token, bool allowed);

    function initialize(string memory _version, ProxyRegistry registryAddress, address _forwarder) initializer public {
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        __ERC2771Context_init(_forwarder);
        version = _version;
        registry = registryAddress;
        commissionPercentage = 200; // = 2%
        commissionPayoutAddress = payable(_msgSender());
        allowedPaymentTokens[address(0)] = true; // allow native tokens by default
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function updateProxyRegistry(ProxyRegistry addr) external onlyOwner {
        registry = addr;
    }

    function updateTrustedForwarder(address addr) external onlyOwner {
        _trustedForwarder = addr;
    }

    function updateCommission(uint newCommission) public onlyOwner {
        commissionPercentage = newCommission;
    }

    function updateCommissionPayoutAddress(address newAddress) public onlyOwner {
        require(newAddress != address(0), "Commission Payout address cannot be the zero address");
        commissionPayoutAddress = payable(newAddress);
    }

    function setCommissionExclusion(address _address, bool _excluded) public onlyOwner {
        require(commissionExclusionAccounts[_address] != _excluded, "Current commission exclusion value for address is same as given input");
        commissionExclusionAccounts[_address] = _excluded;
    }

    function setCustomCommission(address _address, uint256 _commission) public onlyOwner {
        require(customCommissionAccounts[_address] != _commission, "Given custom commission already applied to address");
        customCommissionAccounts[_address] = _commission;
    }

    function setPaymentTokenAllowed(address token, bool allowed) public onlyOwner {
        require(allowedPaymentTokens[token] != allowed, "Current value for payment token allowance is same as given input");
        allowedPaymentTokens[token] = allowed;
        emit PaymentTokensModification(token, allowed);
    }

    function setTokenBan(address nftContract, uint256 tokenId, bool banned) public onlyOwner {
        require(bannedTokens[nftContract][tokenId] != banned, "Current value for ban of token is same as given input");
        bannedTokens[nftContract][tokenId] = banned;
        emit TokenBanSet(nftContract, tokenId, banned);
    }
    function setContractBan(address nftContract, bool banned) public onlyOwner {
        require(bannedContracts[nftContract] != banned, "Current value for ban of contract is same as given input");
        bannedContracts[nftContract] = banned;
        emit ContractBanSet(nftContract, banned);
    }
    function setAccountBan(address account, bool banned) public onlyOwner {
        require(bannedAccounts[account] != banned, "Current value for ban of account is same as given input");
        bannedAccounts[account] = banned;
        emit AccountBanSet(account, banned);
    }

    function isTokenBanned(address nftContract, uint256 tokenId) public view returns (bool) {
        return bannedTokens[nftContract][tokenId];
    }
    function isContractBanned(address nftContract) public view returns (bool) {
        return bannedContracts[nftContract];
    }
    function isAccountBanned(address account) public view returns (bool) {
        return bannedAccounts[account];
    }

    function _checkAllBans(address account, address nftContract, uint256 tokenId) internal view returns (bool) {
        return isTokenBanned(nftContract, tokenId) || isContractBanned(nftContract) || isAccountBanned(account); 
    }

    function getListingDetails(address nftContract, address owner, uint256 tokenId) public view returns (Listing memory) {
        if (_checkAllBans(owner, nftContract, tokenId)) {
            revert('TokenId, Contract, or Account is banned');
        }
        bytes32 _listingId = computeListingId(nftContract, owner, tokenId);
        return listings[_listingId];
    }

    /**
    * @dev returns false if listing type is none, else true
    */
    function addressHasTokenListed(bytes32 _listingId) public view returns (bool) {
        if (listings[_listingId].initialized != true) { return false; }
        if (listings[_listingId].listingType == LISTING_TYPE.NONE) { return false; }
        if (listings[_listingId].startTime > _currentTime()) return false;
        if (listings[_listingId].listingType == LISTING_TYPE.FIXED_PRICE && (listings[_listingId].endTime != 0 && _currentTime() > listings[_listingId].endTime)) return false;
        return true;
    }

    function getTokenPrice(address nftContract, address owner, uint tokenId) public whenNotPaused view returns (uint) {
        bytes32 _listingId = computeListingId(nftContract, owner, tokenId);
        _isForSale(_listingId);
        return listings[_listingId].price;
    }

    function validateListing(ListData memory _data) public view {
        if (_checkAllBans(_msgSender(), _data.nftContract, _data.tokenId)) {
            revert('TokenId, Contract, or Account is banned from listing');
        }
        bool isERC1155 = _checkContractIsERC1155(_data.nftContract);
        bool isERC721 = _checkContractIsERC721(_data.nftContract);
        require((isERC1155 == true || isERC721 == true) && (isERC1155 != isERC721), "Provided contract address is not a valid ERC1155 or ERC721 contract!");

        require(_data.listingType == LISTING_TYPE.FIXED_PRICE || _data.listingType  == LISTING_TYPE.AUCTION, "Invalid Listing Type");
        require(_data.price > 0 && _data.listQuantity > 0, "Price and List Quantity must be greater than 0");
        if (isERC721) {
            require(_data.listQuantity == 1, "List Quantity must be only 1 for ERC721 Tokens");
        }
        require(allowedPaymentTokens[_data.paymentToken] == true, "Invalid Payment Token");

        if (isERC1155) {
            // balance must be >= than amount to be listed
            require(_balanceOfERC1155(_data.nftContract, _msgSender(), _data.tokenId) >= _data.listQuantity, "Caller has insufficient ERC1155 Token Balance");
        }
        if (isERC721) {
            require(_isOwnerOfERC721(_data.nftContract, _msgSender(), _data.tokenId) == true, "Caller is not owner of ERC721 Token");
        }
        require(_isTokensApproved(_data.nftContract, _msgSender()) == true, "Proxy contract was not approved as operator by caller");
    }

    /**
    * @dev create a listing for the given token and its holder of given ERC1155/ERC721 contract
    */
    function list(ListData memory _data) public whenNotPaused {
        validateListing(_data);

        bytes32 _listingId = computeListingId(_data.nftContract, _msgSender(), _data.tokenId);
        Listing storage _listing = listings[_listingId];

        // Make token of given contract and owner exist if was not already
        if (_listing.initialized != true) {
            _listing.initialized = true;
            _listing.nftContract = _data.nftContract;
            _listing.tokenId = _data.tokenId;
            _listing.owner = _msgSender();
        }

        // Modify listing properties
        _listing.listingType = _data.listingType;
        _listing.listedQuantity = _data.listQuantity;
        _listing.price = _data.price;
        _listing.paymentToken = _data.paymentToken;
        _listing.endTime = _data.endTime;
        _listing.startTime = _data.startTime;
        delete _listing.approvedBidder; // clear any previously approved bidders
        emit NftListStatus(_data.nftContract, _msgSender(), _data.tokenId, _data.listingType, _data.listQuantity, _data.price, _data.paymentToken, _data.startTime, _data.endTime);
    }

    function listBatch(ListData[] memory _data) public whenNotPaused {
        for (uint i =0; i < _data.length; i++) {
            list(_data[i]);
        }
    }

    function delist(address nftContract, uint tokenId) public returns (bool) {
        bytes32 _listingId = computeListingId(nftContract, _msgSender(), tokenId);
        require(listings[_listingId].initialized, "Listing does not exist");
        require(listings[_listingId].listingType != LISTING_TYPE.NONE, "NOT FOR SALE!");
        return _clearListing(_listingId);
    }

    function buy(BuyData memory _data) external nonReentrant whenNotPaused payable {
        // --- Validations ---
        if (_checkAllBans(_msgSender(), _data.nftContract, _data.tokenId)) {
            revert('Not available for purchase');
        }
        require(_msgSender() != _data.fromAddress, "Cannot Purchase From Self");
        bytes32 _listingId = computeListingId(_data.nftContract, _data.fromAddress, _data.tokenId);
        _isForSale(_listingId);
        bool isERC1155 = _checkContractIsERC1155(_data.nftContract);
        bool isERC721 = _checkContractIsERC721(_data.nftContract);
        if (isERC1155) {
            uint sellerTokenBalance = _balanceOfERC1155(_data.nftContract, _data.fromAddress, _data.tokenId);
            // double check seller's ERC1155 token balance
            require(sellerTokenBalance >= _data.quantity, "Seller has insufficient ERC1155 Tokens");
        }
        if (isERC721) {
            // double check contract's ERC721 token ownership
            require(_isOwnerOfERC721(_data.nftContract, _data.fromAddress, _data.tokenId) == true, "Seller is not owner of ERC721 Token");
        }
        if (listings[_listingId].listingType == LISTING_TYPE.AUCTION) {
            // check approval
            require(listings[_listingId].approvedBidder == _msgSender(), "Caller not approved to buy");
            require(listings[_listingId].listedQuantity == _data.quantity, "Buy quantity must be equal to listed quantity in auction!");
        } else {
            require(listings[_listingId].listedQuantity >= _data.quantity, "Insufficient listed token quantity");
        }
        // --- End of Validations ---
        _trade(_listingId, _data.quantity);
    }

    // Approve a bidder and update price to match their bid
    // bid is price per asset and not on the entire listed quantity
    function updateApprovedBidder(address _nftContract, uint _tokenId, address _bidder, uint _bid, uint _bidId) public whenNotPaused {
        require(_msgSender() != _bidder, "CANNOT APPROVE SELF");
        bytes32 _listingId = computeListingId(_nftContract, _msgSender(), _tokenId);
        _isAuction(_listingId);
        if (listings[_listingId].approvedBidder == _bidder && listings[_listingId].price == _bid) { 
            revert("BID ALREADY APPROVED");
        }
        Listing storage _listing = listings[_listingId];
        _listing.approvedBidder = _bidder;
        _listing.price = _bid;
        emit BidderUpdate(_nftContract, _msgSender(), _bidId, _bidder, _bid, _tokenId, "ADDED");
    }

    function removeApprovedBidder(address _nftContract, uint _tokenId, uint _bidId) public whenNotPaused {
        bytes32 _listingId = computeListingId(_nftContract, _msgSender(), _tokenId);
        _isAuction(_listingId);
        Listing storage _listing = listings[_listingId];
        address _bidder = _listing.approvedBidder;
        delete _listing.approvedBidder;
        emit BidderUpdate(_nftContract, _msgSender(), _bidId, _bidder, _listing.price, _tokenId, "REMOVED");
    }

    /**
    * @dev Computes Listing Id for the given Contract, Owner Address, and Token Id
    */
    function computeListingId(address nftContract, address owner, uint256 tokenId)
        public
        pure
        returns(bytes32){
        return keccak256(abi.encodePacked(nftContract, owner, tokenId));
    }

    function _trade(bytes32 _listingId, uint _quantity) internal {
        Listing storage _sellerListing = listings[_listingId];
        TradeInfo memory tradeInfo;
        // get total price from listed price
        tradeInfo.totalPrice = _sellerListing.price * _quantity;
        tradeInfo.owner = payable(_sellerListing.owner);
        tradeInfo.buyer = payable(_msgSender());

        if (_sellerListing.paymentToken != address(0)) {
            // check if sufficient payment token balance exists with buyer
            uint paymentTokenBal = _getBalanceOfERC20Token(_sellerListing.paymentToken, _msgSender());
            require(paymentTokenBal >= tradeInfo.totalPrice, "Caller has insufficient balance of payment tokens");
             // check if sufficient payment tokens were approved for contract to spend
            uint paymentTokenAllowance = _getERC20TokenAllowance(_sellerListing.paymentToken, _msgSender());
            require(paymentTokenAllowance >= tradeInfo.totalPrice, "Contract has insufficient allowance of payment tokens");
        } else {
            // check if sufficient native funds were sent with the transaction
            require(msg.value >= tradeInfo.totalPrice, "Insufficient funds sent with transaction");
        }

        tradeInfo.commission = 0;
        // get commission if buyer and seller not excluded
        if (commissionExclusionAccounts[_msgSender()] == false && commissionExclusionAccounts[_sellerListing.owner] == false) {
            // get custom commission of seller if available
            if (customCommissionAccounts[_sellerListing.owner] != 0) {
                tradeInfo.commission = (tradeInfo.totalPrice * customCommissionAccounts[_sellerListing.owner]) / percentBasisPoints;
            } else if (customCommissionAccounts[_msgSender()] != 0) {
                // get custom commission of buyer if available
                tradeInfo.commission = (tradeInfo.totalPrice * customCommissionAccounts[_msgSender()]) / percentBasisPoints;
            } else {
                // get default commission
                tradeInfo.commission = (tradeInfo.totalPrice * commissionPercentage) / percentBasisPoints;
            }
        }
        
        tradeInfo.royalty = 0;
        // get royalty if supported and neither buyer nor seller is the royalty receiver
        if (_checkContractRoyaltiesSupport(_sellerListing.nftContract) == true) {
            IERC2981 _royaltyContract = IERC2981(_sellerListing.nftContract);
            (address receiver, uint256 royaltyAmount) = _royaltyContract.royaltyInfo(_sellerListing.tokenId, _sellerListing.price);
            if (royaltyAmount > 0 && receiver != _sellerListing.owner && receiver != _msgSender()) {
                if (royaltyAmount > tradeInfo.totalPrice - tradeInfo.commission) {
                    revert("Token has invalid royalty information. Royalty exceeds sale price.");
                }
                tradeInfo.royalty = royaltyAmount;
                tradeInfo.royaltyReceiver =  payable(receiver);
            }
        }

        tradeInfo.pricePayable = tradeInfo.totalPrice - tradeInfo.royalty - tradeInfo.commission;

        // --- Payments ---
        if (_sellerListing.paymentToken != address(0)) { 
            require(_transferERC20Tokens(_sellerListing.paymentToken, tradeInfo.buyer, tradeInfo.owner, tradeInfo.pricePayable), "Payment Failed");
        } else {
             // Transfer funds to seller
            (bool success, ) = tradeInfo.owner.call{value: tradeInfo.pricePayable}("");
            require(success, "Payment Failed");
        }
        // --- End of Payments ---

        // Transfer the ERC1155/721 token
        require(_transferTokens(_sellerListing.nftContract, tradeInfo.owner, tradeInfo.buyer, _sellerListing.tokenId, _quantity), "Transfer of Tokens Failed");

        // --- Royalties & Commission ---
        if (_sellerListing.paymentToken != address(0)) { 
            if (tradeInfo.royalty > 0) {
                // Transfer royalty to royalty receiver
                require(_transferERC20Tokens(_sellerListing.paymentToken, tradeInfo.buyer, tradeInfo.royaltyReceiver, tradeInfo.royalty), "Royalty Payment Failed");
            }
            if (tradeInfo.commission > 0) {
                // Transfer commission to CX
                require(_transferERC20Tokens(_sellerListing.paymentToken, tradeInfo.buyer, commissionPayoutAddress, tradeInfo.commission), "Commission Payment Failed");
            }
        } else {
            if (tradeInfo.royalty > 0) {
                // Transfer royalty to royalty receiver
                (bool success, ) = tradeInfo.royaltyReceiver.call{value: tradeInfo.royalty}("");
                require(success, "Royalty Payment Failed");
            }
            if (tradeInfo.commission > 0) {
                // Transfer commission to CX
                (bool success, ) = commissionPayoutAddress.call{value: tradeInfo.commission}("");
                require(success, "Commission Payment Failed");
            }
            if (msg.value > tradeInfo.totalPrice) {
                // Revert the extra amount sent in transaction back to buyer
                (bool success, ) = tradeInfo.buyer.call{value: msg.value - tradeInfo.totalPrice}("");
                require(success, "Refunding Extra Funds Failed");
            }
        }
        // --- End of Royalties & Commission ---
        
        emit Purchase(_sellerListing.nftContract, _sellerListing.owner, _msgSender(), tradeInfo.totalPrice, _sellerListing.paymentToken, tradeInfo.royalty, tradeInfo.commission, _quantity, _sellerListing.tokenId);

        // --- Post Purchase Modifications ---
        // update seller listing
        if (_sellerListing.listingType == LISTING_TYPE.FIXED_PRICE) {
            uint remainingQuantity = _sellerListing.listedQuantity - _quantity;
            if (remainingQuantity > 0) {
                uint oldQuantity = _sellerListing.listedQuantity;
                _sellerListing.listedQuantity = remainingQuantity;
                emit ListedQuantityUpdate(_sellerListing.nftContract, _sellerListing.owner, oldQuantity, remainingQuantity, _sellerListing.tokenId);
            } else {
                _clearListing(_listingId);
            }
        } else {
            _clearListing(_listingId);
        }
         // --- End of Post Purchase Modifications ---
    }

    /**
    * @dev returns allowance of proxy contract to spend owner's payment tokens
    */
    function _getERC20TokenAllowance(address tokenContract, address owner)
        internal
        view
        returns(uint256){
        IERC20 _token = IERC20(tokenContract);
        return _token.allowance(owner, address(registry.proxies(owner)));
    }

    /**
    * @dev returns ERC20 token balance of queried account
    */
    function _getBalanceOfERC20Token(address tokenContract, address owner)
        internal
        view
        returns(uint256){
        IERC20 _token = IERC20(tokenContract);
        return _token.balanceOf(owner);
    }

    /**
    * @dev validate if listing exists and is made available for purchase
    */
    function _isForSale(bytes32 _listingId) internal view {
        require(listings[_listingId].initialized, "Listing does not exist");
        require(listings[_listingId].listingType != LISTING_TYPE.NONE, "NOT FOR SALE!");
        _isActive(_listingId);
    }

    /**
    * @dev validate if listing exists and is auction
    */
    function _isAuction(bytes32 _listingId) internal view {
        require(listings[_listingId].initialized, "Listing does not exist");
        require(listings[_listingId].listingType == LISTING_TYPE.AUCTION, "LISTING NOT AN AUCTION");
        _isActive(_listingId);
    }

    function _isActive(bytes32 _listingId) internal view {
        require(listings[_listingId].startTime < _currentTime(), "Listing not started");
        if (listings[_listingId].listingType == LISTING_TYPE.FIXED_PRICE && (listings[_listingId].endTime != 0 && _currentTime() > listings[_listingId].endTime)) {
            revert('Listing has expired');
        }
    }

    function _checkContractIsERC1155(address _contract) internal view returns (bool) {
        (bool success) = IERC165(_contract).supportsInterface(_INTERFACE_ID_ERC1155);
        return success;
    }

    function _checkContractIsERC721(address _contract) internal view returns (bool) {
        (bool success) = IERC165(_contract).supportsInterface(_INTERFACE_ID_ERC721);
        return success;
    }

    function _checkContractRoyaltiesSupport(address _contract) internal view returns (bool) {
        (bool success) = IERC165(_contract).supportsInterface(_INTERFACE_ID_ERC2981);
        return success;
    }

    /**
    * @dev checks if proxy contract of owner is approved as operator for given address and ERC1155/ERC721 contract
    */
    function _isTokensApproved(address nftContract, address owner)
        internal
        view
        returns(bool){
        if (_checkContractIsERC1155(nftContract)) {
            IERC1155 _token = IERC1155(nftContract);
            return _token.isApprovedForAll(owner, address(registry.proxies(owner)));
        }
        if (_checkContractIsERC721(nftContract)) {
            IERC721 _token = IERC721(nftContract);
            return _token.isApprovedForAll(owner, address(registry.proxies(owner)));
        }
        return false;
    }

    function _exists(address what)
        internal
        view
        returns (bool)
    {
        uint size;
        assembly {
            size := extcodesize(what)
        }
        return size > 0;
    }

    /**
    * @dev executes smart contract call through user's proxy
    */
    function _executeCall(address maker, Call memory call)
        internal
        returns (bool)
    {
        /* Assert target exists. */
        require(_exists(call.target), "Call target does not exist");

        /* Retrieve delegate proxy contract. */
        OwnableDelegateProxy delegateProxy = registry.proxies(maker);

        /* Assert existence. */
        require(delegateProxy != OwnableDelegateProxy(payable(0)), "Delegate proxy does not exist for maker");

        /* Assert implementation. */
        require(delegateProxy.implementation() == registry.delegateProxyImplementation(), "Incorrect delegate proxy implementation for maker");

        /* Typecast. */
        AuthenticatedProxy proxy = AuthenticatedProxy(payable(delegateProxy));

        /* Execute order. */
        return proxy.proxy(call.target, call.howToCall, call.data);
    }

    /**
    * @dev tries to transfer tokens from this contract to given address 
    */
    function _transferTokens(address nftContract, address from, address to, uint256 tokenId, uint256 amount) internal returns(bool) {
        if (_checkContractIsERC1155(nftContract)) {
            Call memory transferERC1155 = Call(address(nftContract), AuthenticatedProxy.HowToCall.Call, abi.encodeWithSignature("safeTransferFrom(address,address,uint256,uint256,bytes)", from, to, tokenId, amount, "0x"));
            return _executeCall(from, transferERC1155);
        }
        if (_checkContractIsERC721(nftContract)) {           
            Call memory transferERC721 = Call(address(nftContract), AuthenticatedProxy.HowToCall.Call, abi.encodeWithSignature("safeTransferFrom(address,address,uint256,bytes)", from, to, tokenId, "0x"));
            return _executeCall(from, transferERC721);
        }
        return false;
    }

    /**
    * @dev tries to transfer payment tokens from owner to given address
    */
    function _transferERC20Tokens(address tokenContract, address from, address to, uint256 amount) internal returns(bool) {
        Call memory transferCall = Call(address(tokenContract), AuthenticatedProxy.HowToCall.Call, abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount));
        return _executeCall(from, transferCall);
    }

    /**
    * @dev helper function to get ERC1155 token balance of an address
    */
    function _balanceOfERC1155(address nftContract, address owner, uint256 tokenId)
        internal
        view
        returns(uint){
        IERC1155 _token = IERC1155(nftContract);
        return _token.balanceOf(owner, tokenId);
    }

    /**
    * @dev helper function to check owner of ERC721
    */
    function _isOwnerOfERC721(address nftContract, address addr, uint256 tokenId)
        internal
        view
        returns(bool){
        IERC721 _token = IERC721(nftContract);
        address owner = _token.ownerOf(tokenId);
        if (addr == owner) {
            return true;
        }
        return false;
    }

    /**
    * @dev Delete listing properties, and set listing type to None for given listing id
    */
    function _clearListing(bytes32 _listingId) internal returns (bool) {
        Listing storage _listing = listings[_listingId];
        _listing.listingType = LISTING_TYPE.NONE;
        delete _listing.listedQuantity;
        delete _listing.price;
        delete _listing.startTime;
        delete _listing.endTime;
        delete _listing.approvedBidder;
        emit NftListStatus(_listing.nftContract, _listing.owner, _listing.tokenId, LISTING_TYPE.NONE, 0, 0, address(0), 0, 0);
        return true;
    }

    function _currentTime()
        internal
        virtual
        view
        returns(uint256){
        return block.timestamp;
    }

    // The following functions are overrides required by Solidity.

    function _msgSender() internal view virtual override(ContextUpgradeable, CXERC2771ContextUpgradeable) returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override(ContextUpgradeable, CXERC2771ContextUpgradeable) returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1155.sol)

pragma solidity ^0.8.0;

import "../token/ERC1155/IERC1155.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC165.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Called with the sale price to determine how much royalty is owed and to whom.
     * @param tokenId - the NFT asset queried for royalty information
     * @param salePrice - the sale price of the NFT asset specified by `tokenId`
     * @return receiver - address of who should be sent the royalty payment
     * @return royaltyAmount - the royalty payment amount for `salePrice`
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (metatx/ERC2771Context.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Context variant with ERC2771 support.
 * Made _trustedForwarder internal instead of the default private
 */
abstract contract CXERC2771ContextUpgradeable is Initializable, ContextUpgradeable {
    address internal _trustedForwarder;

    function __ERC2771Context_init(address trustedForwarder) internal onlyInitializing {
        __Context_init_unchained();
        __ERC2771Context_init_unchained(trustedForwarder);
    }

    function __ERC2771Context_init_unchained(address trustedForwarder) internal onlyInitializing {
        _trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
/*

  Proxy registry; keeps a mapping of AuthenticatedProxy contracts and mapping of contracts authorized to access them. 
  
  Abstracted away from the Exchange (a) to reduce Exchange attack surface and (b) so that the Exchange contract can be upgraded without users needing to transfer assets to new proxies.

*/
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./OwnableDelegateProxy.sol";
import "./ProxyRegistryInterface.sol";

/**
 * @title ProxyRegistry
 */
contract ProxyRegistry is Ownable, ProxyRegistryInterface {

    /* DelegateProxy implementation contract. Must be initialized. */
    address public override delegateProxyImplementation;

    /* Authenticated proxies by user. */
    mapping(address => OwnableDelegateProxy) public override proxies;

    /* Contracts pending access. */
    mapping(address => uint) public pending;

    /* Contracts allowed to call those proxies. */
    mapping(address => bool) public contracts;

    /* Delay period for adding an authenticated contract.
    */
    uint public DELAY_PERIOD = 2 weeks;

    /**
     * Start the process to enable access for specified contract. Subject to delay period.
     *
     * @dev ProxyRegistry owner only
     * @param addr Address to which to grant permissions
     */
    function startGrantAuthentication (address addr)
        public
        onlyOwner
    {
        require(!contracts[addr] && pending[addr] == 0, "Contract is already allowed in registry, or pending");
        pending[addr] = block.timestamp;
    }

    /**
     * End the process to enable access for specified contract after delay period has passed.
     *
     * @dev ProxyRegistry owner only
     * @param addr Address to which to grant permissions
     */
    function endGrantAuthentication (address addr)
        public
        onlyOwner
    {
        require(!contracts[addr] && pending[addr] != 0 && ((pending[addr] + DELAY_PERIOD) < block.timestamp), "Contract is no longer pending or has already been approved by registry");
        pending[addr] = 0;
        contracts[addr] = true;
    }

    /**
     * Revoke access for specified contract. Can be done instantly.
     *
     * @dev ProxyRegistry owner only
     * @param addr Address of which to revoke permissions
     */    
    function revokeAuthentication (address addr)
        public
        onlyOwner
    {
        contracts[addr] = false;
    }

    /**
     * Register a proxy contract with this registry
     *
     * @dev Must be called by the user which the proxy is for, creates a new AuthenticatedProxy
     * @return proxy New AuthenticatedProxy contract
     */
    function registerProxy()
        public
        returns (OwnableDelegateProxy proxy)
    {
        return registerProxyFor(msg.sender);
    }

    /**
     * Register a proxy contract with this registry, overriding any existing proxy
     *
     * @dev Must be called by the user which the proxy is for, creates a new AuthenticatedProxy
     * @return proxy New AuthenticatedProxy contract
     */
    function registerProxyOverride()
        public
        returns (OwnableDelegateProxy proxy)
    {
        proxy = new OwnableDelegateProxy(msg.sender, delegateProxyImplementation, abi.encodeWithSignature("initialize(address,address)", msg.sender, address(this)));
        proxies[msg.sender] = proxy;
        return proxy;
    }

    /**
     * Register a proxy contract with this registry
     *
     * @dev Can be called by any user
     * @return proxy New AuthenticatedProxy contract
     */
    function registerProxyFor(address user)
        public
        returns (OwnableDelegateProxy proxy)
    {
        require(proxies[user] == OwnableDelegateProxy(payable(0)), "User already has a proxy");
        proxy = new OwnableDelegateProxy(user, delegateProxyImplementation, abi.encodeWithSignature("initialize(address,address)", user, address(this)));
        proxies[user] = proxy;
        return proxy;
    }

    /**
     * Transfer access
     */
    function transferAccessTo(address from, address to)
        public
    {
        OwnableDelegateProxy proxy = proxies[from];

        /* CHECKS */
        require(OwnableDelegateProxy(payable(msg.sender)) == proxy, "Proxy transfer can only be called by the proxy");
        require(proxies[to] == OwnableDelegateProxy(payable(0)), "Proxy transfer has existing proxy as destination");

        /* EFFECTS */
        delete proxies[from];
        proxies[to] = proxy;
    }

}

// SPDX-License-Identifier: MIT

/* 

  Proxy contract to hold access to assets on behalf of a user (e.g. ERC20 approve) and execute calls under particular conditions.

*/

pragma solidity ^0.8.2;

import "./ProxyRegistry.sol";
import "./TokenRecipient.sol";
import "./proxy/OwnedUpgradeabilityStorage.sol";

/**
 * @title AuthenticatedProxy
 */
contract AuthenticatedProxy is TokenRecipient, OwnedUpgradeabilityStorage {

    /* Whether initialized. */
    bool initialized = false;

    /* Address which owns this proxy. */
    address public user;

    /* Associated registry with contract authentication information. */
    ProxyRegistry public registry;

    /* Whether access has been revoked. */
    bool public revoked;

    /* Delegate call could be used to atomically transfer multiple assets owned by the proxy contract with one order. */
    enum HowToCall { Call, DelegateCall }

    /* Event fired when the proxy access is revoked or unrevoked. */
    event Revoked(bool revoked);

    /**
     * Initialize an AuthenticatedProxy
     *
     * @param addrUser Address of user on whose behalf this proxy will act
     * @param addrRegistry Address of ProxyRegistry contract which will manage this proxy
     */
    function initialize (address addrUser, ProxyRegistry addrRegistry)
        public
    {
        require(!initialized, "Authenticated proxy already initialized");
        initialized = true;
        user = addrUser;
        registry = addrRegistry;
    }

    /**
     * Set the revoked flag (allows a user to revoke ProxyRegistry access)
     *
     * @dev Can be called by the user only
     * @param revoke Whether or not to revoke access
     */
    function setRevoke(bool revoke)
        public
    {
        require(msg.sender == user, "Authenticated proxy can only be revoked by its user");
        revoked = revoke;
        emit Revoked(revoke);
    }

    /**
     * Execute a message call from the proxy contract
     *
     * @dev Can be called by the user, or by a contract authorized by the registry as long as the user has not revoked access
     * @param dest Address to which the call will be sent
     * @param howToCall Which kind of call to make
     * @param data Calldata to send
     * @return result Result of the call (success or failure)
     */
    function proxy(address dest, HowToCall howToCall, bytes memory data)
        public
        returns (bool result)
    {
        require(msg.sender == user || (!revoked && registry.contracts(msg.sender)), "Authenticated proxy can only be called by its user, or by a contract authorized by the registry as long as the user has not revoked access");
        bytes memory ret;
        if (howToCall == HowToCall.Call) {
            (result, ret) = dest.call(data);
        } else if (howToCall == HowToCall.DelegateCall) {
            (result, ret) = dest.delegatecall(data);
        }
        return result;
    }

    /**
     * Execute a message call and assert success
     * 
     * @dev Same functionality as `proxy`, just asserts the return value
     * @param dest Address to which the call will be sent
     * @param howToCall What kind of call to make
     * @param data Calldata to send
     */
    function proxyAssert(address dest, HowToCall howToCall, bytes memory data)
        public
    {
        require(proxy(dest, howToCall, data), "Proxy assertion failed");
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        assembly {
            size := extcodesize(account)
        }
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./proxy/OwnedUpgradeabilityProxy.sol";

contract OwnableDelegateProxy is OwnedUpgradeabilityProxy {

    constructor(address owner, address initialImplementation, bytes memory data)
    {
        setUpgradeabilityOwner(owner);
        _upgradeTo(initialImplementation);
        (bool success,) = initialImplementation.delegatecall(data);
        require(success, "OwnableDelegateProxy failed implementation");
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./OwnableDelegateProxy.sol";

/**
 * @title ProxyRegistryInterface
 */
interface ProxyRegistryInterface {

    function delegateProxyImplementation() external returns (address);

    function proxies(address owner) external returns (OwnableDelegateProxy);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
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
pragma solidity ^0.8.2;

import "./Proxy.sol";
import "./OwnedUpgradeabilityStorage.sol";

/**
 * @title OwnedUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities
 */
contract OwnedUpgradeabilityProxy is Proxy, OwnedUpgradeabilityStorage {
    /**
     * @dev Event to show ownership has been transferred
     * @param previousOwner representing the address of the previous owner
     * @param newOwner representing the address of the new owner
     */
    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    /**
     * @dev This event will be emitted every time the implementation gets upgraded
     * @param implementation representing the address of the upgraded implementation
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Tells the address of the current implementation
     * @return address of the current implementation
     */
    function implementation() override public view returns (address) {
        return _implementation;
    }

    /**
     * @dev Tells the proxy type (EIP 897)
     * @return proxyTypeId Proxy type, 2 for forwarding proxy
     */
    function proxyType() override public pure returns (uint256 proxyTypeId) {
        return 2;
    }

    /**
     * @dev Upgrades the implementation address
     * @param implementationAddr representing the address of the new implementation to be set
     */
    function _upgradeTo(address implementationAddr) internal {
        require(_implementation != implementationAddr, "Proxy already uses this implementation");
        _implementation = implementationAddr;
        emit Upgraded(implementationAddr);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner(), "Only the proxy owner can call this method");
        _;
    }

    /**
     * @dev Tells the address of the proxy owner
     * @return the address of the proxy owner
     */
    function proxyOwner() public view returns (address) {
        return upgradeabilityOwner();
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferProxyOwnership(address newOwner) public onlyProxyOwner {
        require(newOwner != address(0), "New owner cannot be the null address");
        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
        setUpgradeabilityOwner(newOwner);
    }

    /**
     * @dev Allows the upgradeability owner to upgrade the current implementation of the proxy.
     * @param implementationAddr representing the address of the new implementation to be set.
     */
    function upgradeTo(address implementationAddr) public onlyProxyOwner {
        _upgradeTo(implementationAddr);
    }

    /**
     * @dev Allows the upgradeability owner to upgrade the current implementation of the proxy
     * and delegatecall the new implementation for initialization.
     * @param implementationAddr representing the address of the new implementation to be set.
     * @param data represents the msg.data to bet sent in the low level call. This parameter may include the function
     * signature of the implementation to be called with the needed payload
     */
    function upgradeToAndCall(address implementationAddr, bytes memory data) payable public onlyProxyOwner {
        upgradeTo(implementationAddr);
        (bool success,) = address(this).delegatecall(data);
        require(success, "Call failed after proxy upgrade");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
abstract contract Proxy {
    /**
     * @dev Tells the address of the implementation where every call will be delegated.
     * @return address of the implementation to which it will be delegated
     */
    function implementation() virtual public view returns (address);

    /**
     * @dev Tells the type of proxy (EIP 897)
     * @return proxyTypeId Type of proxy, 2 for upgradeable proxy
     */
    function proxyType() virtual public pure returns (uint256 proxyTypeId);

    function _delegate(address _impl) internal virtual {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    /**
     * @dev Delegates the current call to the address returned by `implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        address _impl = implementation();
        require(_impl != address(0), "Proxy implementation required");
        _beforeFallback();
        _delegate(_impl);
    }

      /**
     * @dev Fallback function that delegates calls to the address returned by `implementation()`.
     * Will run if no other function in the contract matches the call data.
     */
    fallback () external payable {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `implementation()`. Will run if call data is empty.
     */
    receive() external payable {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

/**
 * @title OwnedUpgradeabilityStorage
 * @dev This contract keeps track of the upgradeability owner
 */
contract OwnedUpgradeabilityStorage {

    // Current implementation
    address internal _implementation;

    // Owner of the contract
    address private _upgradeabilityOwner;

    /**
     * @dev Tells the address of the owner
     * @return the address of the owner
     */
    function upgradeabilityOwner() public view returns (address) {
        return _upgradeabilityOwner;
    }

    /**
     * @dev Sets the address of the owner
     */
    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {
        _upgradeabilityOwner = newUpgradeabilityOwner;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title TokenRecipient
 */
contract TokenRecipient {
    event ReceivedEther(address indexed sender, uint amount);
    event ReceivedTokens(address indexed from, uint256 value, address indexed token, bytes extraData);

    /**
     * @dev Receive tokens and generate a log event
     * @param from Address from which to transfer tokens
     * @param value Amount of tokens to transfer
     * @param token Address of token
     * @param extraData Additional data to log
     */
    function receiveApproval(address from, uint256 value, address token, bytes memory extraData) public {
        ERC20 t = ERC20(token);
        require(t.transferFrom(from, address(this), value), "ERC20 token transfer failed");
        emit ReceivedTokens(from, value, token, extraData);
    }

    
    fallback () payable external {
    }

    /**
     * @dev Receive Ether and generate a log event
     */
    receive() external payable {
        emit ReceivedEther(msg.sender, msg.value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}