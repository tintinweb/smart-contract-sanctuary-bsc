#AVO MarketPlace
# @version 0.3.7
#import Avo contract on protocol 1155
MAX_URI_SIZE: constant(uint256) = 1024
BATCH_SIZE: constant(uint256) = 5

interface AVOOpenStore:
    def onERC1155Received(
        _operator: address,
        _from: address,
        _id: uint256,
        _value: uint256,
        _data: uint256
    ) -> bytes32: view

    def onERC1155BatchReceived(
        _operator: address,
        _from: address,
        _ids: uint256[BATCH_SIZE],
        _values: uint256[BATCH_SIZE],
        _data: bytes1[256]
    ) -> bytes32: view

    def safeBatchTransferFrom(
        _from: address,
        _to: address,
        _ids: uint256,
        _values: uint256,
        _data: uint256
    ): nonpayable

    def balanceOf(
        _owner: address,
        _id: uint256
    ) -> uint256: view

    def setUri(_id: uint256, _newUri: String[MAX_URI_SIZE]): nonpayable
    
    def balanceOfBatch(
        _owner: address[BATCH_SIZE],
        _ids: uint256[BATCH_SIZE]
    ) -> uint256[BATCH_SIZE]: nonpayable

    def setApprovalForAll(
        _operator: address,
        _approved: bool
    ): nonpayable

    def mint(
        _to: address,
        _supply: uint256,
        _data: address
    ) -> uint256: nonpayable

    def mintBatch(
        _to: address,
        _supplys: address,
        _data: uint256
    ) -> uint256[BATCH_SIZE]: nonpayable

interface NFToken:
    def onERC721Received(
            _operator: address,
            _from: address,
            _tokenId: uint256,
            _data: Bytes[1024]
        ) -> bytes32: view
    def balanceOf(_owner: address) -> uint256: view
    def ownerOf(_tokenId: uint256) -> address: view
    def getApproved(_tokenId: uint256) -> address: view
    def isApprovedForAll(_owner: address, _operator: address) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _tokenId: uint256): nonpayable
    def safeTransferFrom(_from: address, _to: address, _tokenId: uint256, _data: Bytes[1024]): nonpayable
    def approve(_approved: address, _tokenId: uint256): nonpayable
    def setApprovalForAll(_operator: address, _approved: bool): nonpayable


# interface for the ERC-20 AvoCoin token used to rewarded users
interface AvocadoCoin:
    def totalSupply() -> uint256: view
    def balanceOf(_owner: address) -> uint256: view
    def allowance(_owner: address, _spender: address) -> uint256: view
    def setOwner(_newOwner: address): nonpayable
    def transfer(_to: address, _value: uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _value: uint256) -> bool: nonpayable
    def approve(_spender: address, _value: uint256) -> bool: nonpayable
    def mint(_to: address, _amount: uint256): nonpayable
    def burn(_amount: uint256) -> bool: nonpayable


interface AvoNFT:
    def onERC721Received(
            _operator: address,
            _from: address,
            _tokenId: uint256,
            _data: Bytes[1024]
        ) -> bytes32: view
    def balanceOf(_owner: address) -> uint256: view
    def ownerOf(_tokenId: uint256) -> address: view
    def totalSupply() -> uint256: view
    def mintPrice() -> uint256: view
    def getApproved(_tokenId: uint256) -> address: view
    def isApprovedForAll(_owner: address, _operator: address) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _tokenId: uint256): nonpayable
    def safeTransferFrom(_from: address, _to: address, _tokenId: uint256, _data: Bytes[1024]): nonpayable
    def approve(_approved: address, _tokenId: uint256): nonpayable
    def setApprovalForAll(_operator: address, _approved: bool): nonpayable
    def setMintPrice(_newPrice: uint256): nonpayable
    def mint(_to: address): nonpayable

event Posting:
    _seller: address
    _price: uint256
    _nft: address
    _tokenId: uint256

event ListingUpdated:
    _id: uint256
    _listing: Listing

event Sale:
    _seller: address
    _buyer: address
    _price: uint256
    _nft: address
    _tokenId: uint256

event BidEvent:
    _listing: uint256
    _bidder: address
    _bid: uint256

struct Bid:
    _bidder: address
    _bid: uint256
    
struct Listing:
    _seller: address
    _nft: address
    _tokenId: uint256
    _price: uint256
    _status: uint8 # 0-DOESNT EXIST, 1-OPEN, 2-SOLD, 3-CANCELED


currentId: public(uint256)
idToListing: public(HashMap[uint256, Listing])
idToBid: public(HashMap[uint256, HashMap[uint256, Bid]])  # listing Id -> bid # -> Bid
listingToBidNumber: public(HashMap[uint256, uint256])  # listing Id -> highest current Bid Id in self.idToBid
postingFee: public(uint256) # in wei
sellingFee: public(uint256) # in %
owner: public(address)
marketplace: public(address)  # self
AvoCoin: public(address)  # Address of MarketCoin
AvocadoNFT: public(address)  # Address of MarketNFT


@external
def __init__():
    self.owner = msg.sender
    self.marketplace = self
    self.currentId = 0
    

@external
def setPostingFee(_newFee: uint256):
    assert msg.sender == self.owner, "MarketPlace: Only the owner can do that"
    self.postingFee = _newFee

@external
def setSellingFee(_newFee: uint256):
    assert msg.sender == self.owner, "MarketPlace: Only the owner can do that"
    self.sellingFee = _newFee

@external
def setMarketCoin(_marketCoinAddress: address):
    assert msg.sender == self.owner, "MarketPlace: Only the owner can do that"
    self.AvoCoin = _marketCoinAddress

@external
def setMarketNFT(_marketNFTAddress: address):
    assert msg.sender == self.owner, "MarketPlace: Only the owner can do that"
    self.AvocadoNFT = _marketNFTAddress


@internal
def _addListing(_seller: address, _nft: address, _tokenId: uint256, _price: uint256) -> uint256:
    listing: Listing = Listing({_seller: _seller, _nft: _nft, _tokenId: _tokenId, _price: _price, _status: 1})
    id: uint256 = self.currentId
    self.idToListing[id] = listing
    self.currentId += 1
    log Posting(_seller, _price, _nft, _tokenId)
    return id


@internal
def _updateListing(_listingId: uint256, _listing: Listing) -> uint256:
    # listing: Listing = _listing
    self.idToListing[_listingId] = _listing
    log ListingUpdated(_listingId, _listing)
    return _listingId

@internal
def transfer(_to: address, _amount: uint256):
    AvocadoCoin(self.AvoCoin).transfer(_to, _amount)


@payable
@external
def sell(_nft: address, _tokenId: uint256, _price: uint256) -> uint256:
    assert msg.value >= self.postingFee, "MarketPlace: Amount sent is below postingFee"
    # check that msg.sender is owner or approved
    owner: address = NFToken(_nft).ownerOf(_tokenId)
    assert msg.sender == owner or msg.sender == NFToken(_nft).getApproved(_tokenId) or NFToken(_nft).isApprovedForAll(owner, msg.sender), "MarketPlace: Only the approved of the token can sell it"

    # Check that we are operator for the seller nft
    assert NFToken(_nft).isApprovedForAll(msg.sender, self), "MarketPlace: The marketplace doesn't have authorization to sell this token for this user"

    id: uint256 = self._addListing(msg.sender, _nft, _tokenId, _price)
    return id
    

@payable
@external
def cancelSell(_id: uint256) -> uint256:
    # assert msg.value >= self.postingFee, "Amount sent is below cancellingFee"
    listing: Listing = self.idToListing[_id]
    assert msg.sender == listing._seller, "MarketPlace: Only the seller can cancel"
    assert listing._status != 2, "MarketPlace: Token already sold"
    assert listing._status == 1, "MarketPlace: Token not for sale (already cancel or doesn't exist)"
    listing._status = 3  # cancel listing
    id: uint256 = self._updateListing(_id, listing)
    return id

@payable
@external
def updateSell(_id: uint256, _newPrice: uint256) -> uint256:
    listing: Listing = self.idToListing[_id]
    assert listing._status == 1, "MarketPlace: Token not for sale (already sold, cancel or doesn't exist)"
    assert listing._seller == msg.sender, "MarketPlace: Only the seller can update"
    assert listing._price != _newPrice, "MarketPlace: The price need to be different"

    listing._price = _newPrice
    id: uint256 = self._updateListing(_id, listing)
    return id


@payable
@external
def buy(_id: uint256) -> uint256:
    listing: Listing = self.idToListing[_id]
    # token is for sale
    assert listing._status != 0, "MarketPlace: Listing doesn't exist"
    assert listing._status == 1, "MarketPlace: Token no longer for sale"

    price: uint256 = listing._price
    # enough ether is sent
    assert msg.value >= price, "MarketPlace: Not enough ether sent"

    # Pay the seller
    seller: address = listing._seller
    fee: uint256 = price*self.sellingFee/100
    send(seller, price - fee)

    # Transfer the nft
    nft: address = listing._nft
    tokenId: uint256 = listing._tokenId
    NFToken(nft).transferFrom(seller, msg.sender, tokenId)

    # Transfer some MarketCoin token
    self.transfer(seller, price/10)
    self.transfer(msg.sender, price/10)

    # Update Listing
    newStatus: uint8 = 2
    listing._status = newStatus
    id: uint256 = self._updateListing(_id, listing)

    log Sale(seller, msg.sender, price, nft, listing._tokenId)
    return id

# buy NFT on protocol 1155
@payable
@external
def buy_1155(_id: uint256) -> uint256:
    listing: Listing = self.idToListing[_id]
    # token is for sale
    assert listing._status != 0, "MarketPlace: Listing doesn't exist"
    assert listing._status == 1, "MarketPlace: Token no longer for sale"

    price: uint256 = listing._price
    # enough ether is sent
    assert msg.value >= price, "MarketPlace: Not enough ether sent"

    # Pay the seller
    seller: address = listing._seller
    fee: uint256 = price*self.sellingFee/100
    send(seller, price - fee)

    # Transfer the nft
    nft: address = listing._nft
    tokenId: uint256 = listing._tokenId
    AVOOpenStore(self.AvoCoin).safeBatchTransferFrom(seller, msg.sender, tokenId, price, fee) 

    # Transfer some MarketCoin token
    self.transfer(seller, price/10)
    self.transfer(msg.sender, price/10)

    # Update Listing
    newStatus: uint8 = 2
    listing._status = newStatus
    id: uint256 = self._updateListing(_id, listing)

    log Sale(seller, msg.sender, price, nft, listing._tokenId)
    return id





@external
def withdraw(_amount: uint256):
    assert msg.sender == self.owner, "MarketPlace: Only the owner can withdraw"
    send(self.owner, _amount)


@external
def mintMarketNFT():
    # Receive the marketcoin amount
    mintPrice: uint256 = AvoNFT(self.AvocadoNFT).mintPrice()
    AvocadoCoin(self.AvoCoin).transferFrom(msg.sender, self.marketplace, mintPrice)
    # Mint the NFT 
    AvoNFT(self.AvocadoNFT).mint(msg.sender)

#minting NFT on 1155 protocol
@external
def mintMarket1155NFT():
    # Receive the marketcoin amount
    mintPrice: uint256 = AvoNFT(self.AvocadoNFT).mintPrice()
    AvocadoCoin(self.AvoCoin).transferFrom(msg.sender, self.marketplace, mintPrice)
    # Mint the NFT 
    AVOOpenStore(self.AvoCoin).mint(msg.sender, mintPrice, self.marketplace)