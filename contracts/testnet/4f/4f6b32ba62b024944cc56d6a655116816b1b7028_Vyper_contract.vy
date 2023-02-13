# AVONFT [ART]

# @version 0.3.1

# interface for a ERC-721 token
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


# interface for the ERC-20 
interface MarketCoin:
    def totalSupply() -> uint256: view
    def balanceOf(_owner: address) -> uint256: view
    def allowance(_owner: address, _spender: address) -> uint256: view
    def setOwner(_newOwner: address): nonpayable
    def transfer(_to: address, _value: uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _value: uint256) -> bool: nonpayable
    def approve(_spender: address, _value: uint256) -> bool: nonpayable
    # def mint(_to: address, _amount: uint256): nonpayable
    # def burn(_amount: uint256) -> bool: nonpayable


# interface for the MarketNFT NFT
interface MarketNFT:
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
marketCoin: public(address)  # Address of MarketCoin
marketNFT: public(address)  # Address of MarketNFT


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
    self.marketCoin = _marketCoinAddress

@external
def setMarketNFT(_marketNFTAddress: address):
    assert msg.sender == self.owner, "MarketPlace: Only the owner can do that"
    self.marketNFT = _marketNFTAddress


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
def _transferMarketCoin(_to: address, _value: uint256):
    MarketCoin(self.marketCoin).transfer(_to, _value)


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

    # Mint some MarketCoin token
    self._transferMarketCoin(seller, price/10)
    self._transferMarketCoin(msg.sender, price/10)

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
    mintPrice: uint256 = MarketNFT(self.marketNFT).mintPrice()
    MarketCoin(self.marketCoin).transferFrom(msg.sender, self.marketplace, mintPrice)
    # Mint the NFT
    MarketNFT(self.marketNFT).mint(msg.sender)