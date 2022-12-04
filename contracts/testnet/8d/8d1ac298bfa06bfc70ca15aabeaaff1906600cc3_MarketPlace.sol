/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value)external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function burn(uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);

     function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {

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

abstract contract ERC165 is IERC165 {

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    string private _name;
    string private _symbol;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(uint256 => string) internal _uri;

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

        return _uri[tokenId];
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

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

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
        
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
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

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
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

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
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

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

library Counters {
    struct Counter {
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
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract W is ERC721, Ownable{
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private tokenId;
    address public Admin;
    address public Tokenaddress;
    mapping(uint256 => uint256) public islock;

    event onMint(uint256 TokenId, string URI, address creator);
    event onCollectionMint(uint256 collections, uint256 totalIDs, string URI, uint256 royalty);
    event staking(address sender,uint256 amount,uint256 tokenid);
    
    constructor(address _Tokenaddress) ERC721("HOB", "OBC"){
        Admin = _msgSender();
        Tokenaddress = _Tokenaddress;
    }

    uint256[] public pakages = [400,266,200,160,133];

    function changeAdmin(address _Admin,address _Tokenaddress) public onlyOwner returns(bool){
        Admin = _Admin;  // commition collector address
        Tokenaddress = _Tokenaddress;
        return true;
    }

    function Stake(uint256 amount,uint256 _pakages,bytes memory signature) public returns(bool){
        require(pakages.length > _pakages,"is not pakages avalible");
        require(verify(Admin,msg.sender,amount,_pakages,signature),"not user call the function");
        require(IERC20(Tokenaddress).balanceOf(msg.sender) >= amount,"insufficient balance in user");
        require(IERC20(Tokenaddress).transferFrom(msg.sender,address(this),amount),"is not appove the contract");
        require(Mint(msg.sender),"NFT not Minted");
        islock[tokenId.current()] = block.timestamp + (1 days * pakages[_pakages] );
        emit staking(msg.sender,amount,tokenId.current());
        return true;
    }

    function Mint(address _user) private returns(bool){
        tokenId.increment();
        uint256 id = tokenId.current();
        _uri[id] = "";
        _mint(_user, id);
        emit onMint(id, "", _user);
        return true;
    }

    function updateURL(uint256 Tokenid,string memory _url) public returns(bool){
        require(_exists(Tokenid), "ERC721: token not exixts");
        require(ownerOf(Tokenid) == msg.sender,"is not tokenid owner");
        _uri[Tokenid] = _url;
        return true;
    }

    function totalSupply() public view returns(uint256){
        return tokenId.current();
    }
    
    function BurnToken(uint256 _tokenId) public returns(bool){
        require(ownerOf(_tokenId) == _msgSender() ,"is not owner of tokenID");
        require(_exists(_tokenId), "ERC721: token not exixts");
        _burn(_tokenId);
        return true;
    }
    
    function UnLockNFT(uint256 _tokenid,uint256 _pakages,bytes memory signature) public returns(bool){
        require(verify(Admin,msg.sender,_tokenid,_pakages,signature),"not user call the function");
        islock[_tokenid] = _pakages;
        return true;
    }
    function transferFrom(address from,address to,uint256 _tokenId) public override {
        require( block.timestamp >=  islock[_tokenId],"TokenID is Lock");
        super.transferFrom(from,to,_tokenId);
    }
    function safeTransferFrom(address from,address to,uint256 _tokenId) public override {
        safeTransferFrom(from, to, _tokenId, "");
    }
    function safeTransferFrom(address from,address to,uint256 _tokenId,bytes memory data) public override {
        require( block.timestamp >=  islock[_tokenId],"TokenID is Lock");
        super.safeTransferFrom(from, to, _tokenId, data);
    }
    function getMessageHash(
        address from,
        uint _amount,
        uint _pakages
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(from, _amount,_pakages));
    }
    function getEthSignedMessageHash(bytes32 _messageHash)
        private
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    function verify(
        address _signer,
        address from,
        uint _amount,
        uint _pakages,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(from, _amount,_pakages);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        private
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        private
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}

contract MarketPlace is W{

    constructor(address _tokenaddress)
        W(_tokenaddress){
    }

    // ------------------ marketpalce
    mapping(uint256 => bool) public sellstatus;

    mapping(uint256 => Sell) public sellDetails;

    mapping(uint256 => Auction) public auctionDetails;

    struct Sell{
        address seller;
        address buyer;
        uint256 price;
        bool isnative;
        address tokenaddress;
    }

    struct Auction{
        address beneficiary;
        uint256 highestBid;
        address highestBidder;
        uint256 startvalue;
        bool open;
        bool isnative;
        uint256 start;
        uint256 end;
        address tokenaddress;
    }

    event onOffer(
        uint256 Offerid,
        uint256 tokenId,
        address user,
        uint256 price,
        address owner,
        bool fulfilled,
        bool cancelled
    );


    event OfferCancelled(uint256 offerid, address owner,uint256 returnamount);
    event OfferFilled(uint256 offerid, address newOwner);
    event sell_auction_create(uint256 tokenId, address beneficiary, uint256 startTime, uint256 endTime, uint256 reservePrice, bool isNative);
    event onBid(uint256 tokenid, address highestBidder, uint256 highestBid);
    event refund(address previousbidder, uint256 previoushighestbid);
    event onCommision(uint256 tokenid, uint256 adminCommision, uint256 creatorRoyalty, uint256 ownerAmount);
    event closed(uint256 tokenId, uint auctionId);

    uint8 public commision = 100;
    uint8 public nativecommision = 150;
    receive() external payable {}
    function Withdraw(address _address,uint256 _amount,address _contract) public returns (bool) {
        require(msg.sender == owner(),"is not owner !!!");
        if(_contract != address(this)){
            IERC20(_contract).transfer(_address,IERC20(_contract).balanceOf(address(this)));
            return true;
        }else{
            payable(owner()).transfer(_amount);
            return true;
        }
        
    }

    function sell(uint256[] memory _tokenId, uint256[] memory _price, bool[] memory _isnative, address[] memory _tokenaddress) public returns(bool){
        
        require(_tokenId.length == _price.length && _isnative.length == _tokenaddress.length && _tokenaddress.length == _tokenId.length,"all array is not same");
        for(uint256 i=0;i<_tokenId.length;i++){
            
            require(_price[i] > 0, "set to 0");
            require(ownerOf(_tokenId[i])  == msg.sender, "3");
            require(!sellstatus[_tokenId[i]], "4");
            

            sellDetails[_tokenId[i]]= Sell({
                    seller: msg.sender,
                    buyer: address(0x0),
                    price:  _price[i],
                    isnative : _isnative[i],
                    tokenaddress : _tokenaddress[i]
            });

            sellstatus[_tokenId[i]] = true;
            transferFrom(msg.sender, address(this), _tokenId[i]);
            emit sell_auction_create(_tokenId[i], msg.sender, 0, 0, sellDetails[_tokenId[i]].price, _isnative[i]);
        }
        return true;
    }

    function buy(uint256 _tokenId) public returns(bool){
        
        uint256 _price = (sellDetails[_tokenId].price);
        require(msg.sender != sellDetails[_tokenId].seller, "7");
        require(sellstatus[_tokenId], "8");
        require(!sellDetails[_tokenId].isnative,"9");

        address tokenadd = sellDetails[_tokenId].tokenaddress;
        require(IERC20(tokenadd).balanceOf(msg.sender) >= _price,"10");

        uint256 _commision4admin = (_price * commision) / (10000);
        uint256 _amount4owner = _price - (_commision4admin);
        require(IERC20(tokenadd).transferFrom(msg.sender,address(this),_price),"11");
        require(IERC20(tokenadd).transfer(sellDetails[_tokenId].seller,_amount4owner),"12");
        require(IERC20(tokenadd).transfer(owner(),_commision4admin),"13");

        IERC721(address(this)).transferFrom(address(this), msg.sender, _tokenId);


        emit onCommision(_tokenId, _commision4admin, 0, _amount4owner);

        sellstatus[_tokenId] = false;
        sellDetails[_tokenId].buyer = msg.sender;
        return true;
    }

    function nativeBuy(uint256 _tokenId) public payable returns(bool){
        
        uint256 _price = sellDetails[_tokenId].price;
        require(sellstatus[_tokenId],"15");
        require(msg.sender != sellDetails[_tokenId].seller, "16");
        require(msg.value >= _price, "17");
        require(sellDetails[_tokenId].isnative, "18");

        uint256 _commision4admin = uint256((_price * nativecommision) / (10000));
        uint256 _amount4owner = uint256(_price - (uint256(_commision4admin)));


        payable(sellDetails[_tokenId].seller).transfer(_amount4owner);
        payable(owner()).transfer(_commision4admin);

        IERC721(address(this)).transferFrom(address(this), msg.sender, _tokenId);

        emit onCommision(_tokenId, _commision4admin, 0, _amount4owner);

        sellstatus[_tokenId] = false;
        sellDetails[_tokenId].isnative =  false;
        sellDetails[_tokenId].buyer = msg.sender;
        return true;
    }

    function createAuction_(uint256[] memory _tokenId, uint256[] memory _startingTime, uint256[] memory _closingTime, uint256[] memory _reservePrice, bool[] memory _isnativeauciton,address[] memory _tokenaddress) public returns(bool){
        
        require(_tokenId.length == _startingTime.length && _closingTime.length == _reservePrice.length && _startingTime.length == _tokenId.length,"all array is not same");
        for(uint256 i=0;i<_tokenId.length;i++){
            
            
            
            require(_reservePrice[i] > 0, "22");
            require(ownerOf(_tokenId[i]) == msg.sender, "23");
            require(!sellstatus[_tokenId[i]], "24");
            require(_startingTime[i] < _closingTime[i], "25");

            auctionDetails[_tokenId[i]]= Auction({
                            beneficiary: msg.sender,
                            highestBid: 0,
                            highestBidder: address(0x0),
                            startvalue: _reservePrice[i],
                            open: true,
                            isnative: _isnativeauciton[i],
                            start: _startingTime[i],
                            end: _closingTime[i],
                            tokenaddress : _tokenaddress[i]
                        });

            transferFrom(msg.sender, address(this), _tokenId[i]);
            sellstatus[_tokenId[i]] = true;
            emit sell_auction_create(_tokenId[i], msg.sender, _startingTime[i], _closingTime[i], _reservePrice[i], _isnativeauciton[i]);
        }

        return true;
    }

    function bid(uint256 _tokenId, uint256 _price) public returns(bool) {

        require(!auctionDetails[_tokenId].isnative,"27");
        require(sellstatus[_tokenId],"28");
        require(msg.sender != auctionDetails[_tokenId].beneficiary, "29");

        require(auctionDetails[_tokenId].open, "30");
        require(auctionDetails[_tokenId].startvalue < _price ,"31");

        address tokenadd = auctionDetails[_tokenId].tokenaddress;
        require(IERC20(tokenadd).balanceOf(msg.sender) >= _price,"32");

        require(
            block.timestamp >= auctionDetails[_tokenId].start,
            "33"
        );

        require(
            block.timestamp <= auctionDetails[_tokenId].end,
            "34"
        );

        require(
            _price > auctionDetails[_tokenId].highestBid,
            "35"
        );

        if (auctionDetails[_tokenId].highestBid > 0) {
            require(IERC20(tokenadd).transfer(auctionDetails[_tokenId].highestBidder,auctionDetails[_tokenId].highestBid),"36");
            emit refund(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        }

        require(IERC20(tokenadd).transferFrom(msg.sender,address(this),_price),"37");

        auctionDetails[_tokenId].highestBidder = msg.sender;
        auctionDetails[_tokenId].highestBid = _price;

        emit onBid(_tokenId, auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        return true;
    }

    function nativeBid(uint256 _tokenId) public payable returns(bool) {
        
        require(auctionDetails[_tokenId].isnative,"39");
        require(sellstatus[_tokenId],"40");
        require(msg.sender != auctionDetails[_tokenId].beneficiary, "41");
        require(auctionDetails[_tokenId].open, "42");
        require(auctionDetails[_tokenId].startvalue < msg.value,"43");
        require(
            block.timestamp >= auctionDetails[_tokenId].start,
            "44."
        );

        require(
            block.timestamp <= auctionDetails[_tokenId].end,
            "45"
        );

        require(
            msg.value > auctionDetails[_tokenId].highestBid,
            "46"
        );

        if (auctionDetails[_tokenId].highestBid>0) {
            payable(auctionDetails[_tokenId].highestBidder).transfer(auctionDetails[_tokenId].highestBid);
            emit refund(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        }

        auctionDetails[_tokenId].highestBidder = msg.sender;
        auctionDetails[_tokenId].highestBid = msg.value;

        emit onBid(_tokenId, auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        return true;
    }

    function auctionFinalize(uint256 _tokenId) public returns(bool){
        uint256 bid_ = auctionDetails[_tokenId].highestBid;
        require(sellstatus[_tokenId],"47");

        require(auctionDetails[_tokenId].beneficiary == msg.sender || Admin == msg.sender,"48");
        require(auctionDetails[_tokenId].open, "49");
        require(block.timestamp >= auctionDetails[_tokenId].end, "50");

        address from = auctionDetails[_tokenId].beneficiary;

        if(bid_ != 0 ){
            address highestBidder = auctionDetails[_tokenId].highestBidder;
            if(auctionDetails[_tokenId].isnative){
                uint256 amount4admin_ = (bid_ * nativecommision) / (10000);
                uint256 amount4owner_ = (bid_) - (amount4admin_);
                payable(from).transfer( amount4owner_);
                payable(owner()).transfer(amount4admin_);

                IERC721(address(this)).transferFrom(address(this), highestBidder, _tokenId);
                emit onCommision(_tokenId, amount4admin_, 0, amount4owner_);
            }
            else{
                uint256 amount4admin = (bid_ * commision) / (10000);
                uint256 amount4owner = (bid_) - (amount4admin);

                address tokenadd = auctionDetails[_tokenId].tokenaddress;

                require(IERC20(tokenadd).transfer(from,amount4owner),"51");
                require(IERC20(tokenadd).transfer(owner(),amount4admin),"52");

                IERC721(address(this)).transferFrom(address(this), highestBidder, _tokenId);

                emit onCommision(_tokenId, amount4admin, 0, amount4owner);
            }
        }else{

            IERC721(address(this)).transferFrom(address(this), msg.sender, _tokenId);
        }

        auctionDetails[_tokenId].open = false;
        sellstatus[_tokenId] = false;
        auctionDetails[_tokenId].isnative = false;
        return true;
    }

    struct Offer {
        address user;
        uint256 price;
        uint256 tokenid;
        uint256 offerEnd;
        bool fulfilled;
        bool cancelled;
        bool nativeoffer;
        address tokenaddres;
    }
    mapping (uint256 => Offer) public offers;
    uint256 public Offerid;
    mapping(uint256=>bool)public statusoffer;
    

    function makeOffer(uint256 _tokenId, uint256 _endtime, uint256 _price,address _tokenaddress,bool isnativeoffer) public payable returns(bool){
        
        require(_price > 0, "54");
        require(ownerOf(_tokenId) != address(0x0), "55");
        require(ownerOf(_tokenId) != msg.sender, "56");

        
        if(isnativeoffer){
            require(msg.value > 0,"85");
        }else{
            require(IERC20(_tokenaddress).transferFrom(msg.sender,address(this),_price),"57");
        }

        Offerid = Offerid + (1);
        offers[Offerid] = Offer({
            user: msg.sender,
            price: _price,
            tokenid: _tokenId,
            offerEnd: _endtime,
            fulfilled: false,
            cancelled: false,
            nativeoffer : isnativeoffer,
            tokenaddres : _tokenaddress
        });
        statusoffer[Offerid] = true;
        emit onOffer(Offerid,_tokenId, msg.sender, _price, ownerOf(_tokenId), false, false);

        return true;
    }

    function sellfilloffer(uint256 offerid,uint256 _tokenId)public returns(bool){
        require(removeSell(_tokenId),"62");
        return fillOffer(offerid);
    }

    function fillOffer(uint256 offerid) public returns (bool){
        
        require(statusoffer[offerid],"64");
        require(offers[offerid].user != msg.sender, "65");

        require(block.timestamp <= offers[offerid].offerEnd, "66");
        require(!offers[offerid].fulfilled, "67");
        require(!offers[offerid].cancelled, "68");
        uint256 tokenid = offers[offerid].tokenid;
        address towner = ownerOf(tokenid);
        require(towner == msg.sender,"69");


        if(offers[offerid].nativeoffer){
            uint256 amount4admin_ = (offers[offerid].price * nativecommision) / (10000);
            uint256 amount4owner_ = (offers[offerid].price) - (amount4admin_);
            payable(towner).transfer(amount4owner_);
            payable(owner()).transfer(amount4admin_);

        }else{
            uint256 amount4admin = (offers[offerid].price * commision) / (10000);
            uint256 amount4owner = (offers[offerid].price) - (amount4admin);
            address tokenadd = offers[offerid].tokenaddres;

            require(IERC20(tokenadd).transfer(towner,amount4owner),"70");
            require(IERC20(tokenadd).transfer(owner(),amount4admin),"71");

            }
        IERC721(address(this)).transferFrom(msg.sender, offers[offerid].user, tokenid);
        offers[offerid].fulfilled = true;
        statusoffer[offerid] = false;
        offers[offerid].nativeoffer = false;
        emit OfferFilled(offerid, msg.sender);

        return true;
    }

    function withdrawOffer(uint256 offerid) public returns(bool){
        require(statusoffer[offerid],"72");
        require(offers[offerid].user == msg.sender || Admin == msg.sender, "73");
        require(!offers[offerid].fulfilled , "74");
        require(!offers[offerid].cancelled , "75");

        if(offers[offerid].nativeoffer){
            payable(offers[offerid].user).transfer(offers[offerid].price);
        }else{
            address tokenadd = offers[offerid].tokenaddres;
            require(IERC20(tokenadd).transfer(offers[offerid].user,offers[offerid].price),"77");
        }
        statusoffer[offerid] = false;
        offers[offerid].cancelled = true;
        emit OfferCancelled(offerid, offers[offerid].user,offers[offerid].price);

        return true;
    }

    function updateCommission(uint8 _commissionRate,uint8 _nativecommision) public returns (bool){
        require(owner() == msg.sender,"78");
        commision = _commissionRate;
        nativecommision = _nativecommision;
        return true;
    }

    function removeAuction(uint256 _tokenId) external returns(bool success){
        require(sellstatus[_tokenId],"79");
        require(auctionDetails[_tokenId].open, "80");
        require(auctionDetails[_tokenId].beneficiary == msg.sender || Admin == msg.sender,"81");

        if (auctionDetails[_tokenId].highestBid>0) {
            if(auctionDetails[_tokenId].isnative){
                payable(auctionDetails[_tokenId].highestBidder).transfer(auctionDetails[_tokenId].highestBid);
            }else{
                address tokenadd = auctionDetails[_tokenId].tokenaddress;
                require(IERC20(tokenadd).transfer(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid),"82");
            }
            emit refund(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        }

        IERC721(address(this)).transferFrom(address(this), auctionDetails[_tokenId].beneficiary, _tokenId);
        emit closed(_tokenId, _tokenId);
        auctionDetails[_tokenId].open = false;
        sellstatus[_tokenId] = false;
        auctionDetails[_tokenId].isnative = false;
        delete auctionDetails[_tokenId];
        return true;
    }

    function removeSell(uint256 _tokenId) public returns(bool){
        require(sellstatus[_tokenId],"83");
        require(sellDetails[_tokenId].seller == msg.sender || Admin == msg.sender,"84");
        IERC721(address(this)).transferFrom(address(this), sellDetails[_tokenId].seller, _tokenId);
        sellstatus[_tokenId] = false;
        sellDetails[_tokenId].isnative = false;
        delete sellDetails[_tokenId];
        emit closed(_tokenId, _tokenId);
        return true;
    }
}