//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IProxy{
    function isMintableAccount(address _address) external view returns(bool);
    function isBurnAccount(address _address) external view returns(bool);
    function isTransferAccount(address _address) external view returns(bool);
    function isPauseAccount(address _address) external view returns(bool);
}

interface IVault{
    function transferToMarketplace(address market, address seller, uint256 _tokenId) external;
}

contract YLNFTMarketplace is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _auctionIds;

    IProxy public proxy;
    IERC721 public ylnft;
    
    address public _marketplaceOwner;
    uint256 public marketfee = 0.5 ether;
    uint256 public marketcommission = 5; // = 5%

    enum State { Active, Inactive, Release}
    enum AuctionState {Active, Release}

    struct MarketItem {
        uint256 itemId;
        uint256 tokenId;
        address seller;
        address owner;
        uint256 price;
        State state;
    }

    struct AuctionItem {
        uint256 auctionId;
        uint256 tokenId;
        uint256 auStart;
        uint256 auEnd;
        uint256 highestBid;
        address owner;
        address highestBidder;
        AuctionState state;
    }

    event AdminListedNFT(address user, uint256 tokenId, uint256 price, uint256 timestamp);
    event UserlistedNFTtoMarket(address user, uint256 tokenId, uint256 price, address market, uint256 timestamp);
    event UserNFTDirectTransferto(address user, uint256 tokenId, address to, uint256 price, uint256 gas, uint256 commission, uint256 timestamp);
    event AdminPauselistedNFT(address user, uint256 tokenId, address marketplace, uint256 timestamp);
    event AdminUnpauselistedNFT(address user, uint256 tokenId, address marketplace, uint256 timestamp);
    event PurchasedNFT(address user, uint256 tokenId, uint256 amount, uint256 price, uint256 commission, uint256 gas);
    event SoldNFT(uint256 tokenId, uint256 amount, address market, uint256 timestamp);
    event UserNFTtoMarketSold(uint256 tokenId, address user, uint256 price, uint256 commission, uint256 timestamp);
    event AdminWithdrawFromEscrow(address admin, uint256 amount, uint256 timestamp);
    event EscrowTransferFundsToSeller(address market, uint256 price, address user); //???
    event WithdrawNFTfromMarkettoWallet(uint256 tokenId, address user, uint256 commission, uint256 timestamp);
    event TransferedNFTfromMarkettoVault(uint256 tokenId, address vault, uint256 timestamp);
    event TransferedNFTfromVaulttoMarket(uint256 tokenId, address vault, uint256 timestamp);
    event AdminApprovalNFTwithdrawtoWallet(address admin, uint256 tokenId, address user, uint256 commission, uint256 timestamp);
    event DepositNFTFromWallettoMarketApproval(uint256 tokenId, address user, uint256 commission, address admin, uint256 timestamp);
    event DepositNFTFromWallettoTeamsApproval(uint256 tokenId, address user, uint256 commission, address admin, uint256 timestamp);
    event RevertDepositFromWalletToTeams(uint256 tokenId, address user, address admin, uint256 timestamp);
    event RevertDepositFromWalletToMarket(uint256 tokenId, address user, address admin, uint256 timestamp);
    event AdminTransferNFT(address admin, uint256 tokenId, uint256 amount, address user, uint256 timestamp);
    event MarketPerCommissionSet(address admin, uint256 commission, uint256 timestamp);
    event MarketVCommisionSet(address admin, uint256 commission, uint256 timestamp);
    event AdminSetBid(address admin, uint256 period, uint256 tokenId, uint256 amount, uint256 timestamp);
    event UserSetBid(address user, uint256 period, uint256 tokenId, uint256 amount, uint256 timestamp);
    event UserBidoffer(address user, uint256 price, uint256 tokenId, uint256 amount, uint256 bidId, uint256 timestamp);
    event BidWinner(address user, uint256 auctionId, uint256 tokenId, uint256 timestamp);
    event BidNull(uint256 auctionId, uint256 tokenId, uint256 amount, address owner, uint256 timestamp);

    mapping(uint256 => MarketItem) private idToMarketItem;
    mapping(uint256 => AuctionItem) private idToAuctionItem;
    mapping(address => bool) private marketplaceOwners;
    mapping(address => mapping(uint256 => bool)) depositUsers;
    mapping(address => mapping(uint256 => bool)) withdrawUsers;
    mapping(address => mapping(uint256 => bool)) depositTeamUsers;

    modifier ylOwners() {
        require(marketplaceOwners[msg.sender] == true, "You aren't the owner of marketplace");
        _;
    }

    constructor(IERC721 _ylnft, IProxy _proxy) {
        ylnft = _ylnft;
        proxy = _proxy;
        _marketplaceOwner = msg.sender;
        marketplaceOwners[msg.sender] = true;
    }

    //get itemId
    function getItemId() public view returns(uint256) {
        return _itemIds.current();
    }

    //get item data
    function getItem(uint256 _itemId) public view returns(MarketItem memory) {
        return idToMarketItem[_itemId];
    }

    //get owner
    function getOwner(address _owner) public view returns(bool) {
        return marketplaceOwners[_owner];
    }

    // Setting Market Fee
    function setMarketFee(uint256 _fee) public ylOwners {
        marketfee = _fee;
        emit MarketVCommisionSet(msg.sender, marketfee, block.timestamp);
    }

    // Setting Market commission
    function setMarketcommission(uint256 _commission) public ylOwners {
        marketcommission = _commission;
        emit MarketVCommisionSet(msg.sender, marketcommission, block.timestamp);
    }

    //c. Marketplace Credential
    function allowCredential(address _mOwner, bool _flag) public ylOwners returns(bool) {
        marketplaceOwners[_mOwner] = _flag;
        return true;
    }

    //a. Minter listed NFT to Marketplace
    function minterListedNFT(uint256 _tokenId, uint256 _price) public returns(uint256) {
        require(ylnft.ownerOf(_tokenId) == msg.sender, "User haven't this token ID.");
        require(proxy.isMintableAccount(msg.sender), "You aren't Minter account");
        require(ylnft.getApproved(_tokenId) == address(this), "NFT must be approved to market");

        ylnft.transferFrom(msg.sender, address(this), _tokenId);

        uint256 _itemId = 0;
        for(uint i = 1; i <= _itemIds.current(); i++) {
            if(idToMarketItem[i].tokenId == _tokenId) {
                _itemId = idToMarketItem[i].itemId;
                break;
            }
        }

        if(_itemId == 0) {
            _itemIds.increment();
            _itemId = _itemIds.current();
            idToMarketItem[_itemId] = MarketItem(
                _itemId,
                _tokenId,
                msg.sender,
                address(this),
                _price,
                State.Active
            );
        } else {
            idToMarketItem[_itemId].state = State.Active;
            idToMarketItem[_itemId].owner = address(this);
            idToMarketItem[_itemId].seller = msg.sender;
            idToMarketItem[_itemId].price = _price;
        }

        emit AdminListedNFT(msg.sender, _tokenId, _price, block.timestamp);
        return _itemId;
    }

    //b. Buyer listed NFT to Marketplace
    function buyerListedNFT(uint256 _tokenId, uint256 _price) public payable returns(uint256) {
        require(ylnft.ownerOf(_tokenId) == msg.sender, "User haven't this token ID.");
        require(depositUsers[msg.sender][_tokenId] == true, "This token has not been approved by administrator.");
        require(ylnft.getApproved(_tokenId) == address(this), "NFT must be approved to market");
        require(msg.value >= marketfee, "Insufficient Fund.");

        ylnft.transferFrom(msg.sender, address(this), _tokenId);

        uint256 _itemId = 0;
        for(uint i = 1; i <= _itemIds.current(); i++) {
            if(idToMarketItem[i].tokenId == _tokenId) {
                _itemId = idToMarketItem[i].itemId;
                break;
            }
        }

        if(_itemId == 0) {
            _itemIds.increment();
            _itemId = _itemIds.current();
            idToMarketItem[_itemId] = MarketItem(
                _itemId,
                _tokenId,
                msg.sender,
                address(this),
                _price,
                State.Active
            );
        } else {
            idToMarketItem[_itemId].state = State.Active;
            idToMarketItem[_itemId].owner = address(this);
            idToMarketItem[_itemId].seller = msg.sender;
            idToMarketItem[_itemId].price = _price;
        }

        emit UserlistedNFTtoMarket(msg.sender, _tokenId, _price, address(this), block.timestamp);
        return _itemId;
    }

    //d. to transfer multi nft
    function transferMinterNFT(uint256[] memory _inputItemIds, address _to) public ylOwners nonReentrant {
        require(proxy.isMintableAccount(msg.sender),"You aren't Minter");

        uint256 len = _inputItemIds.length;
        for(uint i = 1; i <= len; i++ ) {
            if(ylnft.ownerOf(idToMarketItem[_inputItemIds[i]].tokenId) == address(this)) {
                ylnft.transferFrom(address(this), _to, idToMarketItem[_inputItemIds[i]].tokenId);
                idToMarketItem[_inputItemIds[i]].owner = _to;
                idToMarketItem[_inputItemIds[i]].state = State.Release;
            }
        }
    }

    //e. To transfer Direct
    function directTransferToBuyer(address _from, uint256 _tokenId, uint256 _price) public payable nonReentrant {
        uint256 startGas = gasleft();
        require(ylnft.ownerOf(_tokenId) == _from, "You haven't this NFT.");
        require(msg.value > _price + marketfee, "Insufficient fund in marketplace");
        require(ylnft.getApproved(_tokenId) == address(this), "NFT must be approved to market");

        ylnft.transferFrom(_from, msg.sender, _tokenId);

        (bool sent,) = payable(_from).call{value: _price}("");
        require(sent, "Failed to send Ether");

        uint256 gasUsed = startGas - gasleft();
        emit UserNFTDirectTransferto(_from, _tokenId, msg.sender, _price, gasUsed, marketfee, block.timestamp);
    }

    //f.
    function bidMinterNFT(uint256 _tokenId, uint256 _price, uint256 _period) public ylOwners returns(uint256) {
        require(ylnft.ownerOf(_tokenId) == msg.sender, "You haven't this token");
        
        ylnft.transferFrom(msg.sender, address(this), _tokenId);
        _auctionIds.increment();
        uint256 _auctionId = _auctionIds.current();
        idToAuctionItem[_auctionId] = AuctionItem(
            _auctionId,
            _tokenId,
            block.timestamp,
            block.timestamp + _period * 86400,
            _price,
            msg.sender,
            msg.sender,
            AuctionState.Active
        );

        emit AdminSetBid(msg.sender, _period, _tokenId, 1, block.timestamp);

        return _auctionId;
    }

    //g.
    function bidBuyerNFT(uint256 _tokenId, uint256 _price, uint256 _period) public returns(uint256) {
        require(ylnft.ownerOf(_tokenId) == msg.sender, "You haven't this token");

        ylnft.transferFrom(msg.sender, address(this), _tokenId);

        _auctionIds.increment();
        uint256 _auctionId = _auctionIds.current();
        idToAuctionItem[_auctionId] = AuctionItem (
            _auctionId,
            _tokenId,
            block.timestamp,
            block.timestamp + _period * 86400,
            _price,
            msg.sender,
            msg.sender,
            AuctionState.Active
        );

        emit UserSetBid(msg.sender, _period, _tokenId, 1, block.timestamp);
        return _auctionId;    
    }

    function userBidOffer(uint256 _auctionId, uint256 _price) public {
        require(ylnft.ownerOf(idToAuctionItem[_auctionId].tokenId) == msg.sender, "This token don't exist in market.");
        require(idToAuctionItem[_auctionId].auEnd > block.timestamp, "The bidding period has already passed.");
        require(idToAuctionItem[_auctionId].highestBid < _price, "The bid price must be higher than before.");
        idToAuctionItem[_auctionId].highestBid = _price;
        idToAuctionItem[_auctionId].highestBidder = msg.sender;

        emit UserBidoffer(msg.sender, _price, idToAuctionItem[_auctionId].tokenId, 1, _auctionId, block.timestamp);
    }

    function withdrawBid(uint256 _auctionId) public payable nonReentrant {
        require(ylnft.ownerOf(idToAuctionItem[_auctionId].tokenId) == msg.sender, "This token don't exist in market.");
        require(idToAuctionItem[_auctionId].auEnd < block.timestamp, "The bidding period have to pass.");
        require(idToAuctionItem[_auctionId].highestBidder == msg.sender, "The highest bidder can withdraw this token.");

        if(idToAuctionItem[_auctionId].owner == msg.sender) {
            require(msg.value >= marketfee, "insufficient fund");
            ylnft.transferFrom(address(this), msg.sender, idToAuctionItem[_auctionId].tokenId);
            emit BidNull(_auctionId, idToAuctionItem[_auctionId].tokenId, 1, msg.sender, block.timestamp);
        } else {
            require(msg.value >= idToAuctionItem[_auctionId].highestBid + marketfee, "Insufficient fund");
            ylnft.transferFrom(address(this), msg.sender, idToAuctionItem[_auctionId].tokenId);
            (bool sent,) = payable(idToAuctionItem[_auctionId].owner).call{value: idToAuctionItem[_auctionId].highestBid}("");
            require(sent, "Failed to send Ether to the seller");
            emit BidWinner(msg.sender, _auctionId, idToAuctionItem[_auctionId].tokenId, block.timestamp);
        }
    }

    //h. Pause
    function adminPauseToggle(uint256 _itemId, bool _flag) public {
        uint256 _tokenId = idToMarketItem[_itemId].tokenId;
        require(ylnft.ownerOf(_tokenId) == address(this), "You haven't this tokenID.");
        require(idToMarketItem[_itemId].seller == msg.sender || marketplaceOwners[msg.sender] == true);
        if(_flag == true) {
            idToMarketItem[_itemId].state = State.Inactive;
            emit AdminPauselistedNFT(msg.sender, _tokenId, address(this), block.timestamp);
        } else {
            idToMarketItem[_itemId].state = State.Active;
            emit AdminUnpauselistedNFT(msg.sender, _tokenId, address(this), block.timestamp);
        }
    }

    //i. withdraw NFT
    function withdrawNFT721(uint256 itemId) public payable nonReentrant {
        uint256 _tokenId = idToMarketItem[itemId].tokenId;
        require(idToMarketItem[itemId].seller == msg.sender, "You haven't this NFT");
        require(msg.value >= marketfee, "insufficient fund");
        require(withdrawUsers[msg.sender][itemId] == true, "This token has not been approved by admin");
        ylnft.transferFrom(address(this), msg.sender, _tokenId);
        idToMarketItem[itemId].state = State.Release;
        idToMarketItem[itemId].owner = msg.sender;

        emit WithdrawNFTfromMarkettoWallet(_tokenId, msg.sender, marketfee, block.timestamp);
    }

    //j. deposit NFT
    function depositNFT721(uint256 _tokenId, uint256 _price) public payable returns(uint256) {
        require(ylnft.ownerOf(_tokenId) == msg.sender, "You haven't this NFT");
        require(msg.value >= marketfee, "Insufficient Fund.");
        require(depositUsers[msg.sender][_tokenId] == true, "This token has not been approved by admin.");
        ylnft.transferFrom(msg.sender, address(this), _tokenId);
        _itemIds.increment();
        uint256 itemId = _itemIds.current();
        idToMarketItem[itemId] = MarketItem(
            itemId,
            _tokenId,
            payable(msg.sender),
            payable(address(this)),
            _price,
            State.Active
        );
        return itemId;
    }

    // deposit approval from Admin
    function depositApproval(address _user, uint256 _tokenId, bool _flag) public ylOwners {
        require(ylnft.ownerOf(_tokenId) == _user, "The User aren't owner of this token.");
        depositUsers[_user][_tokenId] = _flag;
        if(_flag == true) {
            emit DepositNFTFromWallettoMarketApproval(_tokenId, _user, marketfee, msg.sender, block.timestamp);
        } else {
            emit RevertDepositFromWalletToMarket(_tokenId, _user, msg.sender, block.timestamp);
        }
    }

    // withdraw approval from Admin
    function withdrawApproval(address _user, uint256 _itemId, bool _flag) public ylOwners {
        require(idToMarketItem[_itemId].seller == _user, "You don't owner of this NFT.");
        require(ylnft.ownerOf(idToMarketItem[_itemId].tokenId) == address(this), "This token don't exist in market.");
        withdrawUsers[_user][_itemId] = _flag;
        if(_flag == true) {
            emit AdminApprovalNFTwithdrawtoWallet(msg.sender, idToMarketItem[_itemId].tokenId, _user, marketfee, block.timestamp);
        }
    }

    //k. To transfer the NFTs to his team(vault)
    function transferToVault(uint256 _itemId, address _vault) public nonReentrant returns(uint256) {
        uint256 _tokenId = idToMarketItem[_itemId].tokenId;
        require(ylnft.ownerOf(_tokenId) == address(this), "This token didn't list on marketplace");
        require(idToMarketItem[_itemId].seller == msg.sender, "You don't owner of this token");
        require(depositTeamUsers[msg.sender][_itemId] == true, "This token has not been approved by admin");
        
        ylnft.transferFrom(address(this), _vault, _tokenId);
        idToMarketItem[_itemId].state = State.Release;
        idToMarketItem[_itemId].owner = _vault;

        emit TransferedNFTfromMarkettoVault(_tokenId, _vault, block.timestamp);
        return _tokenId;
    }

    // team approval
    function depositTeamApproval(address _user, uint256 _itemId, bool _flag) public ylOwners {
        require(ylnft.ownerOf(idToMarketItem[_itemId].tokenId) == address(this), "This token don't exist in market");
        require(idToMarketItem[_itemId].seller == _user, "The user isn't the owner of token");
        depositTeamUsers[_user][_itemId] = _flag;
        if(_flag == true) {
            emit DepositNFTFromWallettoTeamsApproval(idToMarketItem[_itemId].tokenId, _user, marketfee, msg.sender, block.timestamp);
        } else {
            emit RevertDepositFromWalletToTeams(idToMarketItem[_itemId].tokenId, _user, msg.sender, block.timestamp);
        }
    }

    //l. transfer from vault to marketplace
    function transferFromVaultToMarketplace(uint256 _tokenId, address _vault, uint256 _price) public {
        require(ylnft.ownerOf(_tokenId) == _vault, "The team haven't this token.");
        IVault vault = IVault(_vault);
        vault.transferToMarketplace(address(this), msg.sender, _tokenId);// Implement this function in the Vault Contract.

        uint256 _itemId = 0;
        for(uint i = 1; i <= _itemIds.current(); i++) {
            if(idToMarketItem[i].tokenId == _tokenId) {
                _itemId = idToMarketItem[i].itemId;
                break;
            }
        }

        if(_itemId == 0) {
            _itemIds.increment();
            _itemId = _itemIds.current();
            idToMarketItem[_itemId] = MarketItem(
                _itemId,
                _tokenId,
                msg.sender,
                address(this),
                _price,
                State.Active
            );
        } else {
            idToMarketItem[_itemId].state = State.Active;
            idToMarketItem[_itemId].owner = address(this);
            idToMarketItem[_itemId].seller = msg.sender;
        }

        emit TransferedNFTfromVaulttoMarket(_tokenId, _vault, block.timestamp);
    }
    //m. = e.
    //n. = h.

    //o.
    function adminTransfer(address _to, uint256 _itemId) public payable ylOwners {
        require(ylnft.ownerOf(idToMarketItem[_itemId].tokenId) == address(this), "This contract haven't this NFT.");
        require(msg.value >= idToMarketItem[_itemId].price, "Insufficient fund.");
        uint256 _tokenId = idToMarketItem[_itemId].tokenId;
        ylnft.transferFrom(address(this), _to, _tokenId);
        idToMarketItem[_itemId].owner = _to;
        idToMarketItem[_itemId].state = State.Release;

        emit AdminTransferNFT(msg.sender, _tokenId, 1, _to, block.timestamp);
    }

    // Marketplace Listed NFTs
    function fetchMarketItems() public view returns(MarketItem[] memory) {
        uint256 total = _itemIds.current();
        
        uint256 itemCount = 0;
        for(uint i = 1; i <= total; i++) {
            if(idToMarketItem[i].state == State.Active && idToMarketItem[i].owner == address(this) && ylnft.getApproved(idToMarketItem[i].tokenId) == address(this)) {
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        uint256 index = 0;
        for(uint i = 1; i <= total; i++) {
            if(idToMarketItem[i].state == State.Active && idToMarketItem[i].owner == address(this) && ylnft.getApproved(idToMarketItem[i].tokenId) == address(this)) {
                items[index] = idToMarketItem[i];
                index++;
            }
        }

        return items;
    }

    // My listed NFTs
    function fetchMyItems() public view returns(MarketItem[] memory) {
        uint256 total = _itemIds.current();

        uint itemCount = 0;
        for(uint i = 1; i <= total; i++) {
            if( idToMarketItem[i].state == State.Active 
                && idToMarketItem[i].seller == msg.sender
                && idToMarketItem[i].owner == address(this)
                && ylnft.getApproved(idToMarketItem[i].tokenId) == address(this)) {
                
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        uint256 index = 0;
        for(uint i = 1; i <= total; i++) {
            if( idToMarketItem[i].state == State.Active 
                && idToMarketItem[i].seller == msg.sender
                && idToMarketItem[i].owner == address(this)
                && ylnft.getApproved(idToMarketItem[i].tokenId) == address(this)) {
                
                items[index] = idToMarketItem[i];
                index++;
            }
        }

        return items;
    }

    // Purchased NFT
    function MarketItemSale(uint256 itemId) public payable nonReentrant returns(uint256) {
        uint256 startGas = gasleft();

        require(msg.value >= idToMarketItem[itemId].price + marketfee, "insufficient fund");
        require(idToMarketItem[itemId].seller != msg.sender, "This token is your NFT.");
        require(idToMarketItem[itemId].owner == address(this), "This NFT don't exist in market");
        // require(ylnft.getApproved(idToMarketItem[itemId].tokenId) == address(this), "NFT must be approved to market");

        ylnft.transferFrom(address(this), msg.sender, idToMarketItem[itemId].tokenId);
        (bool sent,) = payable(idToMarketItem[itemId].seller).call{value: idToMarketItem[itemId].price}("");
        require(sent, "Failed to send Ether to the seller");
        idToMarketItem[itemId].state = State.Release;
        idToMarketItem[itemId].owner = msg.sender;

        uint256 gasUsed = startGas - gasleft();

        emit UserNFTtoMarketSold(idToMarketItem[itemId].tokenId, idToMarketItem[itemId].seller, idToMarketItem[itemId].price, marketfee, block.timestamp);
        emit SoldNFT(idToMarketItem[itemId].tokenId, 1, address(this), block.timestamp);
        emit PurchasedNFT(msg.sender, idToMarketItem[itemId].tokenId, 1, idToMarketItem[itemId].price, marketfee, gasUsed);

        return idToMarketItem[itemId].tokenId;
    }

    //withdraw ether
    function withdrawEther(uint256 _amount) public ylOwners nonReentrant {
        require(address(this).balance >= _amount, "insufficient fund");
        (bool sent,) = payable(msg.sender).call{value: _amount}("");
        require(sent, "Failed to send Ether");
        emit AdminWithdrawFromEscrow(msg.sender, _amount, block.timestamp);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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