/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value,string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target,bytes memory data,string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) internal pure returns (bytes memory) {
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
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
interface IERC721Receiver {
    function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) external returns (bytes4);
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
interface IERC721Metadata{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function transferFrom(address from,address to,uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;
    // Token name
    string private _name;
    // Token symbol
    string private _symbol;
    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;
    // Mapping owner address to token count
    mapping(address => uint256) private _balances;
    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),"ERC721: approve caller is not owner nor approved for all" );
        _approve(to, tokenId);
    }
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(address from,address to,uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from,address to,uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes memory data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }
    function _safeTransfer(address from,address to,uint256 tokenId,bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }
    function _safeMint(address to,uint256 tokenId,bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, data),"ERC721: transfer to non ERC721Receiver implementer");
    }
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
        _afterTokenTransfer(address(0), to, tokenId);
    }
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        // Clear approvals
        _approve(address(0), tokenId);
        _balances[owner] -= 1;
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
        _afterTokenTransfer(owner, address(0), tokenId);
    }
    function _transfer(address from,address to,uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId);
        // Clear approvals from the previous owner
        _approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
        _afterTokenTransfer(from, to, tokenId);
    }
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }
    function _setApprovalForAll(address owner,address operator,bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
    function _checkOnERC721Received(address from,address to,uint256 tokenId,bytes memory data) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
    function _beforeTokenTransfer(address from, address to,uint256 tokenId) internal virtual {}
    function _afterTokenTransfer(address from,address to,uint256 tokenId) internal virtual {}
}
contract NFTCollection is ERC721 {
    struct NFT {
        string name;
        string URI;
    }
    event Mint(uint256 index, address indexed mintedBy);
    NFT[] private allNFTs;
    constructor() ERC721("NFT Collection", "NFTC") {}
    // Mint a new NFT for Sale
    function mintNFT(string memory _nftName, string memory _nftURI) external returns (uint256){
        allNFTs.push(NFT({name: _nftName, URI: _nftURI}));
        uint256 index = allNFTs.length - 1;
        _safeMint(msg.sender, index);
        emit Mint(index, msg.sender);
        return index;
    }
    function transferNFTFrom( address from,address to,uint256 tokenId) public virtual returns (bool) {
        safeTransferFrom(from, to, tokenId);
        return true;
    }
}
interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; 
}
contract ERC20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;
    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    constructor(uint256 initialSupply,string memory tokenName,string memory tokenSymbol) {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
    }
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0));
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Invalid allowance");     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}
contract Marketplace is IERC721Receiver {
    // Name of the marketplace
    string public name;
    // Index of auctions
    uint256 public index = 0;
    // Structure to define auction properties
    struct Auction {
        uint256 index; // Auction Index
        address addressNFTCollection; // Address of the ERC721 NFT Collection contract
        address addressPaymentToken; // Address of the ERC20 Payment Token contract
        uint256 nftId; // NFT Id
        address creator; // Creator of the Auction
        address payable currentBidOwner; // Address of the highest bider
        uint256 currentBidPrice; // Current highest bid for the auction
        uint256 endAuction; // Timestamp for the end day&time of the auction
        uint256 bidCount; // Number of bid placed on the auction
    }
    // Array will all auctions
    Auction[] private allAuctions;
    // Public event to notify that a new auction has been created
    event NewAuction(
        uint256 index,
        address addressNFTCollection,
        address addressPaymentToken,
        uint256 nftId,
        address mintedBy,
        address currentBidOwner,
        uint256 currentBidPrice,
        uint256 endAuction,
        uint256 bidCount
    );
    // Public event to notify that a new bid has been placed
    event NewBidOnAuction(uint256 auctionIndex, uint256 newBid);
    // Public event to notif that winner of an
    // auction claim for his reward
    event NFTClaimed(uint256 auctionIndex, uint256 nftId, address claimedBy);
    // Public event to notify that the creator of
    // an auction claimed for his money
    event TokensClaimed(uint256 auctionIndex, uint256 nftId, address claimedBy);
    // Public event to notify that an NFT has been refunded to the
    // creator of an auction
    event NFTRefunded(uint256 auctionIndex, uint256 nftId, address claimedBy);
    // constructor of the contract
    constructor(string memory _name) {
        name = _name;
    }
    function isContract(address _addr) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
    function createAuction(address _addressNFTCollection,address _addressPaymentToken,uint256 _nftId,uint256 _initialBid,uint256 _endAuction) external returns (uint256) {
        //Check is addresses are valid
        require(isContract(_addressNFTCollection),"Invalid NFT Collection contract address");
        require(isContract(_addressPaymentToken),"Invalid Payment Token contract address");
        // Check if the endAuction time is valid
        require(_endAuction > block.timestamp, "Invalid end date for auction");
        // Check if the initial bid price is > 0
        require(_initialBid > 0, "Invalid initial bid price");
        // Get NFT collection contract
        NFTCollection nftCollection = NFTCollection(_addressNFTCollection);
        // Make sure the sender that wants to create a new auction
        // for a specific NFT is the owner of this NFT
        require(nftCollection.ownerOf(_nftId) == msg.sender,"Caller is not the owner of the NFT");
        // Make sure the owner of the NFT approved that the MarketPlace contract
        // is allowed to change ownership of the NFT
        require(nftCollection.getApproved(_nftId) == address(this),"Require NFT ownership transfer approval");
        // Lock NFT in Marketplace contract
        require(nftCollection.transferNFTFrom(msg.sender, address(this), _nftId));
        //Casting from address to address payable
        address payable currentBidOwner = payable(address(0));
        // Create new Auction object
        Auction memory newAuction = Auction({
            index: index,
            addressNFTCollection: _addressNFTCollection,
            addressPaymentToken: _addressPaymentToken,
            nftId: _nftId,
            creator: msg.sender,
            currentBidOwner: currentBidOwner,
            currentBidPrice: _initialBid,
            endAuction: _endAuction,
            bidCount: 0
        });
        //update list
        allAuctions.push(newAuction);
        // increment auction sequence
        index++;
        // Trigger event and return index of new auction
        emit NewAuction(
            index,
            _addressNFTCollection,
            _addressPaymentToken,
            _nftId,
            msg.sender,
            currentBidOwner,
            _initialBid,
            _endAuction,
            0
        );
        return index;
    }
    function isOpen(uint256 _auctionIndex) public view returns (bool) {
        Auction storage auction = allAuctions[_auctionIndex];
        if (block.timestamp >= auction.endAuction) return false;
        return true;
    }
    function getCurrentBidOwner(uint256 _auctionIndex)public view returns (address){
        require(_auctionIndex < allAuctions.length, "Invalid auction index");
        return allAuctions[_auctionIndex].currentBidOwner;
    }
    function getCurrentBid(uint256 _auctionIndex)public view returns (uint256){
        require(_auctionIndex < allAuctions.length, "Invalid auction index");
        return allAuctions[_auctionIndex].currentBidPrice;
    }
    function bid(uint256 _auctionIndex, uint256 _newBid)external returns (bool) {
        require(_auctionIndex < allAuctions.length, "Invalid auction index");
        Auction storage auction = allAuctions[_auctionIndex];
        // check if auction is still open
        require(isOpen(_auctionIndex), "Auction is not open");
        // check if new bid price is higher than the current one
        require( _newBid > auction.currentBidPrice,"New bid price must be higher than the current bid");
        // check if new bider is not the owner
        require(msg.sender != auction.creator,"Creator of the auction cannot place new bid");
        // get ERC20 token contract
        ERC20 paymentToken = ERC20(auction.addressPaymentToken);
        // new bid is better than current bid!
        // transfer token from new bider account to the marketplace account
        // to lock the tokens
        require(paymentToken.transferFrom(msg.sender, address(this), _newBid), "Tranfer of token failed");
        // new bid is valid so must refund the current bid owner (if there is one!)
        if (auction.bidCount > 0) {
            paymentToken.transfer(
                auction.currentBidOwner,
                auction.currentBidPrice
            );
        }
        // update auction info
        address payable newBidOwner = payable(msg.sender);
        auction.currentBidOwner = newBidOwner;
        auction.currentBidPrice = _newBid;
        auction.bidCount++;
        // Trigger public event
        emit NewBidOnAuction(_auctionIndex, _newBid);
        return true;
    }
    function claimNFT(uint256 _auctionIndex) external {
        require(_auctionIndex < allAuctions.length, "Invalid auction index");
        // Check if the auction is closed
        require(!isOpen(_auctionIndex), "Auction is still open");
        // Get auction
        Auction storage auction = allAuctions[_auctionIndex];
        // Check if the caller is the winner of the auction
        require(auction.currentBidOwner == msg.sender,"NFT can be claimed only by the current bid owner");
        // Get NFT collection contract
        NFTCollection nftCollection = NFTCollection(auction.addressNFTCollection);
        // Transfer NFT from marketplace contract
        // to the winner address
        require(nftCollection.transferNFTFrom(address(this),auction.currentBidOwner,_auctionIndex));
        // Get ERC20 Payment token contract
        ERC20 paymentToken = ERC20(auction.addressPaymentToken);
        // Transfer locked token from the marketplace
        // contract to the auction creator address
        require(paymentToken.transfer(auction.creator, auction.currentBidPrice));
        emit NFTClaimed(_auctionIndex, auction.nftId, msg.sender);
    }
    function claimToken(uint256 _auctionIndex) external {
        require(_auctionIndex < allAuctions.length, "Invalid auction index"); // XXX Optimize
        // Check if the auction is closed
        require(!isOpen(_auctionIndex), "Auction is still open");
        // Get auction
        Auction storage auction = allAuctions[_auctionIndex];
        // Check if the caller is the creator of the auction
        require(auction.creator == msg.sender,"Tokens can be claimed only by the creator of the auction");
        // Get NFT Collection contract
        NFTCollection nftCollection = NFTCollection(auction.addressNFTCollection);
        // Transfer NFT from marketplace contract
        // to the winned of the auction
        nftCollection.transferFrom(address(this),auction.currentBidOwner,auction.nftId);
        // Get ERC20 Payment token contract
        ERC20 paymentToken = ERC20(auction.addressPaymentToken);
        // Transfer locked tokens from the market place contract
        // to the wallet of the creator of the auction
        paymentToken.transfer(auction.creator, auction.currentBidPrice);
        emit TokensClaimed(_auctionIndex, auction.nftId, msg.sender);
    }
    function refund(uint256 _auctionIndex) external {
        require(_auctionIndex < allAuctions.length, "Invalid auction index");
        // Check if the auction is closed
        require(!isOpen(_auctionIndex), "Auction is still open");
        // Get auction
        Auction storage auction = allAuctions[_auctionIndex];
        // Check if the caller is the creator of the auction
        require(auction.creator == msg.sender,"Tokens can be claimed only by the creator of the auction");
        require(auction.currentBidOwner == address(0),"Existing bider for this auction");
        // Get NFT Collection contract
        NFTCollection nftCollection = NFTCollection(auction.addressNFTCollection);
        // Transfer NFT back from marketplace contract
        // to the creator of the auction
        nftCollection.transferFrom(address(this),auction.creator,auction.nftId);
        emit NFTRefunded(_auctionIndex, auction.nftId, msg.sender);
    }
    function onERC721Received(address,address,uint256,bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}