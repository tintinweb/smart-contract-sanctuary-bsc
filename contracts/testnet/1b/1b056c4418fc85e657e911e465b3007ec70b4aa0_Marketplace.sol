// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library Counters {
    struct Counter {
        uint256 _value;
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

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

interface IWoolFactory {

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Get the minting price of NFTs by tier
    function getMintPriceOf(uint256 _tier) external pure returns (uint256);

    // Get item count of a single tier for one _user
    function totalUserItemsOfTier(address _user, uint256 _tierId) external view returns (uint256);

    // Find a count of all NFTs from all tiers for an address (stored numbers)
    function totalItemsOf(address _user) external view returns (uint256);

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Store numbers of NFTs to calculate earnings from (stops buy-claim exploit)
    function updateItems(address _user) external;

    // Mint the number of tokens to caller calculated by contract
    function claimTokens(address _user) external returns (uint256);
}

interface IDegenNFT {
    function mint(address player) external returns (uint256);
    
    function totalMinted() external view returns (uint256);
    function mintableRemaining() external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, Ownable {
    using Address for address;
    using Strings for uint256;

    IWoolFactory public woolMinter;

    string private _name;
    string private _symbol;

    address public _dev;

    uint public itemsLimit;
    uint public mintingFee;
    uint public royaltyFee;

    address public royaltyToken;
    address public feeRecipient;

    mapping(address => bool) public _isExcluded;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping to indicate royalty-free addresses
    mapping(address => bool) public _royaltyFree;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    event onTransferItem(address _sender, address _recipient, uint256 _tokenId, bool _charged,  uint256 _timestamp);

    constructor(
        string memory name_, 
        string memory symbol_, 
        uint mintLimit_, 
        uint mintPrice_, 
        address paymentToken_, 
        address feeRecipient_,
        address _woolMinter
    ) {
        _dev = msg.sender;
        
        _name = name_;
        _symbol = symbol_;
        
        itemsLimit = mintLimit_;
        mintingFee = mintPrice_;

        royaltyFee = mintPrice_ / 10;

        royaltyToken = paymentToken_;
        feeRecipient = feeRecipient_;

        woolMinter = IWoolFactory(_woolMinter);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function setTxFee(uint amount) public onlyOwner{
        royaltyFee = amount;
    }

    function setPaymentToken(address token) public onlyOwner{
        royaltyToken = token;
    }

    function excludeInclude (address user) public onlyOwner{
        _isExcluded[user] = !_isExcluded[user];
    }

    function setFeeCollector(address collector) public onlyOwner{
        feeRecipient = collector;
    }

    function setRoyaltyFree(address _address, bool _free) public onlyOwner {
        _royaltyFree[_address] = _free;
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
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        require(itemsLimit > 0, 'No more tokens left to mint');

        _beforeTokenTransfer(address(0), to, tokenId);
        
        itemsLimit--;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        
        woolMinter.claimTokens(msg.sender);
        woolMinter.updateItems(msg.sender);

        bool _feeCharged = _isRoyaltyFree(from, to);

        emit onTransferItem(from, to, tokenId, _feeCharged, block.timestamp);
        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _isRoyaltyFree(address _itemSender, address _itemReceiver) internal returns (bool) {

        // if sender is royalty-free
        if(_royaltyFree[_itemSender] == true) {

            // Do nothing...
            return false;

        // Or, if the recipient is royalty free,
        } else if (_royaltyFree[_itemReceiver] == true) {

            // Also do nothing
            return false;

        // Otherwise, 
        } else {

            // Charge the sender a royalty fee
            IERC20(royaltyToken).transferFrom(_itemSender, feeRecipient, royaltyFee);
            return true;
        }
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
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

    function setWoolFactory(address _woolFactory) external onlyOwner() {
        woolMinter = IWoolFactory(_woolFactory);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual {}
}

abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    mapping(uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }

        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

abstract contract Pausable is Context {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract Whitelist is Ownable {
    bool active = true;

    mapping(address => bool) public whitelist;
    
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    modifier onlyWhitelisted() {
        if(active){
            require(whitelist[msg.sender], 'not whitelisted');
        }
        _;
    }

    function addAddressToWhitelist(address addr) public onlyOwner returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }
    function activateDeactivateWhitelist() public onlyOwner {
        active = !active;
    }

    function addAddressesToWhitelist(address[] calldata addrs) public onlyOwner returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    function removeAddressesFromWhitelist(address[] calldata addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract Marketplace is IERC721Receiver, Pausable, Whitelist, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    using Counters for Counters.Counter;

    /////////////
    // STRUCTS //
    /////////////

    struct ItemTier {
        mapping(uint256 => MarketItem) itemListing;

        Counters.Counter _listingIds;
        Counters.Counter _itemsSold;

        uint256 totalMinted;
        uint256 totalListed;
        uint256 totalItems;
    }

    struct MarketItem {
        uint listingId;
        address _contract;
        uint256 _tokenId;
        address _seller;
        uint256 _price;
        bool forSale;
    }

    ////////////////
    // INTERFACES //
    ////////////////

    IERC20    public payableToken;  // SH33P token

    IWoolFactory public woolMinter; // The external

    /////////////////////////////////
    // CONFIGURABLES AND VARIABLES //
    /////////////////////////////////

    address public SHEEPAddress;
    address public reserveAddress;

    address public mintFeeSplitter;

    bool public tradingEnabled;

    uint8 public totalTiers;

    // Extra metrics
    uint256 public totalMinted;
    uint256 public totalListed;
    uint256 public totalResold;
    uint256 public totalProfits;

    //////////////////
    // DATA MAPPING //
    //////////////////

    mapping(uint256 => ItemTier) tierData;

    mapping(uint256 => address) degenNFT;
    mapping(address => bool) isDegenNFT;

    modifier ifTradingActive() {
        require(tradingEnabled == true, "MARKET_DISABLED");
        _;
    }

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event onListItemForSale(
        uint listingId, 
        address _contract, 
        uint256 _tokenId, 
        address _seller, 
        uint256 _price,
        bool _forSale
    );

    event onBuyItem(
        address indexed _caller, 
        address indexed _recipient, 
        uint256 _tierId, 
        uint256 _timestamp
    );

    event onSetMintFeeSplitter(
        address _caller, 
        address _old, 
        address _new, 
        uint256 _timestamp
    );

    event onToggleTrading(
        address _caller, 
        bool _option, 
        uint256 _timestamp
    );

    event onClaimTokens(
        address sender, 
        uint256 _toMint, 
        uint256 timestamp
    );

    ////////////////////////////
    // CONSTRUCTOR & FALLBACK //
    ////////////////////////////

    constructor (
        address _nft1Address, 
        address _nft2Address, 
        address _nft3Address, 
        address _nft4Address, 
        address _nft5Address, 
        address _nft6Address, 
        address _SHEEP, 
        address _mintFeeSplitter,
        address _woolFactory
    ) {
        degenNFT[1] = _nft1Address;
        degenNFT[2] = _nft2Address;
        degenNFT[3] = _nft3Address;
        degenNFT[4] = _nft4Address;
        degenNFT[5] = _nft5Address;
        degenNFT[6] = _nft6Address;

        // tierData[1].totalItems = 83500;
        // tierData[2].totalItems = 41750;
        // tierData[3].totalItems = 20875;
        // tierData[4].totalItems = 10043;
        // tierData[5].totalItems = 5021;
        // tierData[6].totalItems = 2600;

        tierData[1].totalItems = 5;
        tierData[2].totalItems = 5;
        tierData[3].totalItems = 5;
        tierData[4].totalItems = 5;
        tierData[5].totalItems = 5;
        tierData[6].totalItems = 5;

        isDegenNFT[_nft1Address] = true;
        isDegenNFT[_nft2Address] = true;
        isDegenNFT[_nft3Address] = true;
        isDegenNFT[_nft4Address] = true;
        isDegenNFT[_nft5Address] = true;
        isDegenNFT[_nft6Address] = true;

        SHEEPAddress = _SHEEP;

        payableToken = IERC20(SHEEPAddress);

        woolMinter = IWoolFactory(_woolFactory);
        mintFeeSplitter = _mintFeeSplitter;

        totalTiers = 6;
    }

    ///////////////////////////
    // PUBLIC VIEW FUNCTIONS //
    ///////////////////////////

    // Mintable items remaining of a single tier
    function canMint(address _nft) public view returns (bool) {
        uint256 _available = IDegenNFT(_nft).mintableRemaining();
        return (_available > 0);
    }

    // Current listing ID for tier queue
    function listIndex(uint256 _tier) public view returns (uint256) {
        return (tierData[_tier]._listingIds.current());
    }

    // Next item to sell from tier queue
    function sellIndex(uint256 _tier) public view returns (uint256) {
        return (tierData[_tier]._itemsSold.current().add(1));
    }

    // Find how many NFTs of a tier have been minted
    function mintableOf(uint256 _tier) public view returns (uint256) {
        
        uint256 _total = tierData[_tier].totalItems;
        uint256 _minted = tierData[_tier].totalMinted;

        return (_total.sub(_minted));
    }

    function buyableOf(uint256 _tier) public view returns (uint256) {
        uint256 _listed = tierData[_tier].totalListed;
        uint256 _sold = tierData[_tier]._itemsSold.current();

        return (_listed.sub(_sold));
    }

    // Find how many NFTs of a tier have been minted
    function mintedOfTier(uint256 _tier) public view returns (uint256) {
        return (tierData[_tier].totalMinted);
    }

    // Find how many NFTs of a tier can be totally minted
    function totalItemsOfTier(uint256 _tier) public view returns (uint256) {
        return (tierData[_tier].totalItems);
    }

    // Find how many NFTs of a tier are available
    function totalAvailableOfTier(uint256 _tier) public view returns (uint256) {
        uint256 _minted = mintedOfTier(_tier);
        uint256 _total = totalItemsOfTier(_tier);

        return (_total.sub(_minted));
    }

    // Get contract address of one of the NFTs (by Tier ID)
    function getContractOf(uint256 _tier) public view returns (address) {
        if (_tier == 1) {return degenNFT[1];}
        if (_tier == 2) {return degenNFT[2];}
        if (_tier == 3) {return degenNFT[3];}
        if (_tier == 4) {return degenNFT[4];}
        if (_tier == 5) {return degenNFT[5];}
        if (_tier == 6) {return degenNFT[6];}

        return address(0);
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Get item count for all tiers, for one _user
    function getItems(address _user, bool _realtime) external view returns (
        uint256 _tier1Items, uint256 _tier2Items, uint256 _tier3Items, uint256 _tier4Items, uint256 _tier5Items, uint256 _tier6Items
    ) {
        if (_realtime == true) {
            return (
                getUserBalanceOfTier(_user, 1), 
                getUserBalanceOfTier(_user, 2), 
                getUserBalanceOfTier(_user, 3), 
                getUserBalanceOfTier(_user, 4), 
                getUserBalanceOfTier(_user, 5), 
                getUserBalanceOfTier(_user, 6)
            );
        } else {
            return (
                woolMinter.totalUserItemsOfTier(_user, 1), 
                woolMinter.totalUserItemsOfTier(_user, 2), 
                woolMinter.totalUserItemsOfTier(_user, 3), 
                woolMinter.totalUserItemsOfTier(_user, 4), 
                woolMinter.totalUserItemsOfTier(_user, 5), 
                woolMinter.totalUserItemsOfTier(_user, 6)
            );
        }
    }

    // Get count of all items across all tiers for one _user
    function getUserTotalItems(address _user) external view returns (uint256) {
        return (
            woolMinter.totalUserItemsOfTier(_user, 1) + woolMinter.totalUserItemsOfTier(_user, 2) + woolMinter.totalUserItemsOfTier(_user, 3) + 
            woolMinter.totalUserItemsOfTier(_user, 4) + woolMinter.totalUserItemsOfTier(_user, 5) + woolMinter.totalUserItemsOfTier(_user, 6)
        );
    }

    // Items of user as of right now (live balance check)
    function realtimeItemsOf(address _user) external view returns (uint256) {
        uint256 _tier1 = IERC721(degenNFT[1]).balanceOf(_user);
        uint256 _tier2 = IERC721(degenNFT[2]).balanceOf(_user);
        uint256 _tier3 = IERC721(degenNFT[3]).balanceOf(_user);
        uint256 _tier4 = IERC721(degenNFT[4]).balanceOf(_user);
        uint256 _tier5 = IERC721(degenNFT[5]).balanceOf(_user);
        uint256 _tier6 = IERC721(degenNFT[6]).balanceOf(_user);

        return (
            _tier1 + _tier2 + _tier3 + _tier4 + _tier5 + _tier6
        );
    }

    // Get tier of a contract address
    function getTierOf(address _contract) public view returns (uint256 _id) {
        if (_contract == degenNFT[1]) {_id = 1;}
        if (_contract == degenNFT[2]) {_id = 2;}
        if (_contract == degenNFT[3]) {_id = 3;}
        if (_contract == degenNFT[4]) {_id = 4;}
        if (_contract == degenNFT[5]) {_id = 5;}
        if (_contract == degenNFT[6]) {_id = 6;}
    }

    // Get live balance of items, for one _user
    function getUserBalanceOfTier(address _user, uint256 _tierId) public view returns (uint256) {
        address _nft = getContractOf(_tierId);
        return (IERC721(_nft).balanceOf(_user));
    }

    ////////////////////////////////////////////

    // Fetch a market item by tier, then listing ID
    function fetchMarketItem(uint256 _tier, uint listingId) public view returns (MarketItem memory, uint256 _marketItemId) {
        MarketItem memory item = tierData[_tier].itemListing[listingId];
        return (item, item.listingId);
    }

    // Returns all market items that are still for sale.
    function fetchMarketItems(uint256 _tier) public view returns (MarketItem[] memory) {
        uint itemCount = tierData[_tier]._listingIds.current();
        uint unsoldItemCount = tierData[_tier]._listingIds.current() - tierData[_tier]._itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        for (uint i = 0; i < itemCount; i++) {
            if (tierData[_tier].itemListing[i + 1].forSale == true) {
                uint currentId = tierData[_tier].itemListing[i + 1].listingId;
                MarketItem storage currentItem = tierData[_tier].itemListing[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
    
        return items;
    }

    //////////////////////////////////////
    // WRITE FUNCTIONS - THESE COST GAS //
    //////////////////////////////////////

    // Create the market item and transfer the item to this contract
    function listItem(address _contract, uint256 _tokenId, uint256 _markup) ifTradingActive() public nonReentrant {
        require(_markup < 6, "INVALID_RANGE");

        address _seller = address(msg.sender);
        uint256 _tier = getTierOf(_contract);

        tierData[_tier]._listingIds.increment();
        uint256 listingId = tierData[_tier]._listingIds.current();

        uint256 _mintPrice = woolMinter.getMintPriceOf(_tier);
        uint256 _markupFactor = (_markup.mul(5));
        uint256 _actualMarkup = (_mintPrice.mul(_markupFactor).div(100));

        uint256 _price = (_mintPrice + _actualMarkup);
    
        tierData[_tier].itemListing[listingId] = MarketItem(
            listingId, _contract, _tokenId, _seller, _price, true
        );

        tierData[_tier].totalListed += 1;

        IERC721(_contract).transferFrom(_seller, address(this), _tokenId);

        uint256 _claimTotal = woolMinter.claimTokens(msg.sender);
        woolMinter.updateItems(msg.sender);

        // Add 1 to total listed
        totalListed += 1;

        emit onClaimTokens(msg.sender, _claimTotal, block.timestamp);
        emit onListItemForSale(listingId, _contract, _tokenId, _seller, _price, true);
    }

    // Buy an NFT - mints first, sells listed items second
    // Sells listed items in a FIFO-style queue

    function buyItem(address _contract) ifTradingActive() public nonReentrant returns (uint256) {

        // Get the tier of the contract
        uint256 _tier = getTierOf(_contract);

        // Empty uint for token ID
        uint256 _tokenId;

        // Find the mintable and buyable counts of the tier
        uint256 _mintable = mintableOf(_tier);
        uint256 _buyable  = buyableOf(_tier);

        // Require there to be at least something to facilitate the buy
        require(_mintable > 0 || _buyable > 0, "NO_ITEMS_AVAILABLE");

        // If there's mintables,
        if (_mintable > 0) {

            // Mint a new NFT Item to the caller
            _tokenId = buyItemFromMint(_tier, msg.sender);

        // Otherwise, if there's no mintable and there's some buyable...
        } else if (_mintable == 0 && _buyable > 0) {

            // Sell the caller the next NFT in line
            _tokenId = buyItemFromMarket(_tier, msg.sender);
        }

        // Tell the network, successful function
        emit onBuyItem(msg.sender, msg.sender, _tier, block.timestamp);
        return (_tokenId);
    }

    // Buy listed item (by contract address)
    // - Translates to ItemID by contract
    // - Finds first item in sales list for that tier
    // - that item becomes the item being purchased

    function buyItemFromMarket(uint256 _tierId, address _recipient) internal returns (uint256) {

        // Find the contract of the desired tier
        address _contract = getContractOf(_tierId);

        // Find the listing ID of the next item in the queue
        uint256 _listingId = tierData[_tierId]._itemsSold.current().add(1);

        // Get details of the listed item
        uint256 price  = tierData[_tierId].itemListing[_listingId]._price;
        uint256 token  = tierData[_tierId].itemListing[_listingId]._tokenId;
        address seller = tierData[_tierId].itemListing[_listingId]._seller;

        // Collect Payment for listed item
        require(IERC20(SHEEPAddress).transferFrom(_recipient, address(this), price), 'Must pay item price');
        
        // Pay the seller for the item
        IERC20(SHEEPAddress).transfer(seller, price);

        // Then give the recipient their item
        IERC721(_contract).transferFrom(address(this), _recipient, token);
        
        // Reset listing data to empty values
        tierData[_tierId].itemListing[_listingId]._contract = address(0);
        tierData[_tierId].itemListing[_listingId]._tokenId = 0;
        tierData[_tierId].itemListing[_listingId]._seller = address(0);
        tierData[_tierId].itemListing[_listingId].forSale = false;

        // Increment the number of items sold
        tierData[_tierId]._itemsSold.increment();

        // Add 1 to total resold
        totalResold += 1;

        // Add to total profits
        totalProfits += price;

        // Return the token Id of the item sold
        return token;
    }

    // Buy an NFT, specifying recipient and tier.
    // Caller must approve this contract to spend their SH33P

    function buyItemFromMint(uint256 _tierId, address _recipient) internal returns (uint256 _newItemID) {

        // Get contract and mint price
        address _contract = getContractOf(_tierId);
        uint256 _mintPrice = woolMinter.getMintPriceOf(_tierId);

        tierData[_tierId].totalMinted += 1;

        // Collect Mint Payment
        require(IERC20(SHEEPAddress).transferFrom(_recipient, mintFeeSplitter, _mintPrice), 'Must pay minting fee');

        totalMinted += 1;
        totalProfits += _mintPrice;

        return IDegenNFT(_contract).mint(_recipient);
    }

    // Mint tokens, pro-rata of seconds since last claim
    // This contract must be whitelisted to mint the token
    function claimTokens() whenNotPaused() nonReentrant() public returns (uint256) {
        
        uint256 _claimTotal = woolMinter.claimTokens(msg.sender);
        woolMinter.updateItems(msg.sender);

        emit onClaimTokens(msg.sender, _claimTotal, block.timestamp);
        return _claimTotal;
    }

    ////////////////////////////////////////////////////////

    // ERC-721 Receiver function
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    ////////////////////////////////////////////
    // DEV FUNCTIONS - MAINTENANCE & UPGRADES //
    ////////////////////////////////////////////

    // Set the Mint Fee Splitter Address
    function setMintFeeSplitter(address _address) onlyOwner() public returns (bool _success) {
        require(Address.isContract(_address), "INVALID_ADDRESS");
        require(tradingEnabled == false, "MARKET_OPEN");
        
        address _current = mintFeeSplitter;
        mintFeeSplitter = _address;

        emit onSetMintFeeSplitter(msg.sender, _current, mintFeeSplitter, block.timestamp);
        return true;
    }

    // Pause buying and listing of NFT Items
    function toggleMarket(bool _enabled) onlyOwner() public returns (bool _success) {
        
        tradingEnabled = _enabled;

        emit onToggleTrading(msg.sender, _enabled, block.timestamp);
        return true;
    }

    // Pause the claims from the WoolFactory
    // NOTE: If the system is started, balances can still build up
    // NOTE: This stops initial build-up before WoolShed is ready.
    function pauseClaims() onlyOwner() public returns (bool _success) {
        _pause();

        return true;
    }

    // Unpause the claims from the WoolFactory
    // NOTE: Do this only when WoolFactory launches
    function unpauseClaims() onlyOwner() public returns (bool _success) {
        _unpause();

        return true;
    }
}