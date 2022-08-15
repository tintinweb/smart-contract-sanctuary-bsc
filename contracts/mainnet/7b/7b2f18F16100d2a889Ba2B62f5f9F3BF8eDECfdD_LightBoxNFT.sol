/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;


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
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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
        require(owner != address(0), "ERC721: balance query for the zero address");
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
        //solhint-disable-next-line max-line-length
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
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
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
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
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
        bytes memory _data
    ) private returns (bool) {
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

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract LightBoxNFT is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Strings for uint256;

    IERC20 public busdToken;

    address private tokenBurner = address(0);

    Counters.Counter private _tokenIdTracker;
    Counters.Counter private _bronzeTracker;
    Counters.Counter private _goldTracker;
    Counters.Counter private _diamondTracker;

    enum TokenType {
        BRONZE,
        GOLD,
        DIAMOND
    }

    uint256 public BRONZE_PRICE = 20 * 10**18;
    uint256 public GOLD_PRICE = 25 * 10**18;
    uint256 public DIAMOND_PRICE = 30 * 10**18;
    uint256 public constant MAX_BY_MINT = 100;
    uint256 public constant MAX_MINT = 23250;
    uint256 public constant BRONZE_LIMIT = 8683;
    uint256 public constant GOLD_LIMIT = 7931;
    uint256 public constant DIAMOND_LIMIT = 6636;

    bool public isPaused = false;

    mapping(address => uint256) private _bronzeClaimed;
    mapping(address => uint256) private _goldClaimed;
    mapping(address => uint256) private _diamondClaimed;
    mapping(uint256 => TokenType) private _type;
    mapping(uint256 => uint256) private _bronzeMap;
    mapping(uint256 => uint256) private _goldMap;
    mapping(uint256 => uint256) private _diamondMap;

    string public baseTokenURI;
    string private _bronzeUri;
    string private _goldUri;
    string private _diamondUri;

    event CreateLightBoxNFT(uint256 indexed id);

    modifier onlyBurner() {
        require(
            tokenBurner == _msgSender(),
            "caller is not authorized to burn tokens."
        );
        _;
    }

    constructor(address token, string memory bronzeUri, string memory goldUri, string memory diamondUri) ERC721("LightBox", "LIGHTBOX") {
        _tokenIdTracker.increment();
        _bronzeTracker.increment();
        _goldTracker.increment();
        _diamondTracker.increment();
        busdToken = IERC20(token);
        _bronzeUri = bronzeUri;
        _goldUri = goldUri;
        _diamondUri = diamondUri;
    }

    function getDiscount() private view returns (uint256) {
        uint256 totalMinted = _tokenIdTracker.current().sub(1);
        if (totalMinted >= 0 && totalMinted <= 2000) {
            return 50;
        } else if (totalMinted >= 2001 && totalMinted <= 4000) {
            return 45;
        } else if (totalMinted >= 4001 && totalMinted <= 6000) {
            return 40;
        } else if (totalMinted >= 6001 && totalMinted <= 8000) {
            return 35;
        } else if (totalMinted >= 8001 && totalMinted <= 10000) {
            return 30;
        } else if (totalMinted >= 10001 && totalMinted <= 12000) {
            return 25;
        } else if (totalMinted >= 12001 && totalMinted <= 14000) {
            return 20;
        } else if (totalMinted >= 14001 && totalMinted <= 16000) {
            return 15;
        } else if (totalMinted >= 16001 && totalMinted <= 18000) {
            return 10;
        } else if (totalMinted >= 18001 && totalMinted <= 20000) {
            return 5;
        } else {
            return 0;
        }
    }

    function getBronzePrice(uint256 count) public view returns (uint256) {
        return
            count.mul(
                BRONZE_PRICE.sub(BRONZE_PRICE.mul(getDiscount()).div(100))
            );
    }

    function getGoldPrice(uint256 count) public view returns (uint256) {
        return
            count.mul(GOLD_PRICE.sub(GOLD_PRICE.mul(getDiscount()).div(100)));
    }

    function getDiamondPrice(uint256 count) public view returns (uint256) {
        return
            count.mul(
                DIAMOND_PRICE.sub(DIAMOND_PRICE.mul(getDiscount()).div(100))
            );
    }

    function _totalSupply() internal view returns (uint256) {
        return _tokenIdTracker.current();
    }

    function totalMint() public view returns (uint256) {
        return _totalSupply();
    }

    function mintBronze(uint256 _count) public {
        //SAFE CHECKS
        uint256 total = _bronzeTracker.current().sub(1);
        require(!isPaused, "Minting is paused.");
        require(total < BRONZE_LIMIT, "All bronze mints are already minted");
        require(total.add(_count) <= BRONZE_LIMIT, "Required mints cross max allowed bronze level mints.");
        require(
            _count <= MAX_BY_MINT,
            "Max mints allowed per transaction is 100."
        );
        require(
            _bronzeClaimed[_msgSender()].add(_count) <= 100,
            "Max mint per type allowed per address is 100."
        );
        if (_msgSender() != owner()) {
            require(
                busdToken.allowance(_msgSender(), address(this)) >=
                    getBronzePrice(_count),
                "Approved amunt is less then total mint price amount."
            );
            require(
                busdToken.balanceOf(_msgSender()) >= getBronzePrice(_count),
                "Value Below Price."
            );
        }

        //MINTING
        for (uint256 i = 0; i < _count; i++) {
            _bronzeClaimed[_msgSender()] += 1;
            _mintAnElement(_msgSender(), TokenType.BRONZE);
        }

        //TRANSFER FUNDS
        busdToken.transferFrom(_msgSender(), owner(), getBronzePrice(_count));
    }

    function mintGold(uint256 _count) public {
        //SAFE CHECKS
        uint256 total = _goldTracker.current().sub(1);
        require(!isPaused, "Minting is paused.");
        require(total < GOLD_LIMIT, "All gold mints are already minted");
        require(total.add(_count) <= GOLD_LIMIT, "Required mints crosses max allowed gold level mints.");
        require(
            _count <= MAX_BY_MINT,
            "Max mints allowed per transaction is 100."
        );
        require(
            _goldClaimed[_msgSender()].add(_count) <= 100,
            "Max mint per type allowed per address is 100."
        );
        if (_msgSender() != owner()) {
            require(
                busdToken.allowance(_msgSender(), address(this)) >=
                    getGoldPrice(_count),
                "Approved amount is less then total mint price amount."
            );
            require(
                busdToken.balanceOf(_msgSender()) >= getGoldPrice(_count),
                "Value Below Price."
            );
        }

        //MINTING
        for (uint256 i = 0; i < _count; i++) {
            _goldClaimed[_msgSender()] += 1;
            _mintAnElement(_msgSender(), TokenType.GOLD);
        }

        //TRANSFER FUNDS
        busdToken.transferFrom(_msgSender(), owner(), getGoldPrice(_count));
    }

    function mintDiamond(uint256 _count) public {
        //SAFE CHECKS
        uint256 total = _diamondTracker.current().sub(1);
        require(!isPaused, "Minting is paused.");
        require(total < DIAMOND_LIMIT, "All diamond mints are already minted");
        require(total.add(_count) <= DIAMOND_LIMIT, "Required mints crosses max allowed diamond level mints.");
        require(
            _count <= MAX_BY_MINT,
            "Max mints allowed per transaction is 100."
        );
        require(
            _diamondClaimed[_msgSender()].add(_count) <= 100,
            "Max mint per type allowed per address is 100."
        );
        if (_msgSender() != owner()) {
            require(
                busdToken.allowance(_msgSender(), address(this)) >=
                    getDiamondPrice(_count),
                "Approved amunt is less then total mint price amount."
            );
            require(
                busdToken.balanceOf(_msgSender()) >= getDiamondPrice(_count),
                "Value Below Price."
            );
        }

        //MINTING
        for (uint256 i = 0; i < _count; i++) {
            _diamondClaimed[_msgSender()] += 1;
            _mintAnElement(_msgSender(), TokenType.DIAMOND);
        }

        //TRANSFER FUNDS
        busdToken.transferFrom(_msgSender(), owner(), getDiamondPrice(_count));
    }

    function airdropNFT(address[] memory winners, TokenType[] memory tokenType ) public onlyOwner {
        uint256 total = _tokenIdTracker.current().sub(1);
        require(total + winners.length <= MAX_MINT, "Max limit");
        require(winners.length == tokenType.length, "Incorrect Input");
        require(
            winners.length > 0,
            "Please provide the list of wallets for the airdrop"
        );
        for (uint256 i = 0; i < winners.length; i++) {
            if(tokenType[i]==TokenType.BRONZE){
                _bronzeClaimed[_msgSender()] += 1;
            }else if(tokenType[i]==TokenType.GOLD){
                _goldClaimed[_msgSender()] += 1;
            }else if(tokenType[i]==TokenType.DIAMOND){
                _diamondClaimed[_msgSender()]+=1;
            }
            _mintAnElement(winners[i], tokenType[i]);
        }
    }

    function redeemNFT(
        uint256 countBronze,
        uint256 countGold,
        uint256 countDiamond,
        address redeemTo
    ) external onlyBurner {
        //mint bronze
        for (uint256 i = 0; i < countBronze; i++) {
            _bronzeClaimed[redeemTo] += 1;
            _mintAnElement(redeemTo, TokenType.BRONZE);
        }

        //mint gold
        for (uint256 i = 0; i < countGold; i++) {
            _goldClaimed[redeemTo] += 1;
            _mintAnElement(redeemTo, TokenType.GOLD);
        }

        //mint Diamond
        for (uint256 i = 0; i < countDiamond; i++) {
            _diamondClaimed[redeemTo] += 1;
            _mintAnElement(redeemTo, TokenType.DIAMOND);
        }
    }

    function balanceOfBronze(address _owner) external view returns (uint256) {
        return _bronzeClaimed[_owner];
    }

    function balanceOfGold(address _owner) external view returns (uint256) {
        return _goldClaimed[_owner];
    }

    function balanceOfDiamond(address _owner) external view returns (uint256) {
        return _diamondClaimed[_owner];
    }

    function _mintAnElement(address _to, TokenType tokenType) private {
        uint256 id = _totalSupply();
        _tokenIdTracker.increment();
        _safeMint(_to, id);
        _type[id] = tokenType;
        if (tokenType == TokenType.BRONZE) {
            _bronzeMap[id] = _bronzeTracker.current();
            _bronzeTracker.increment();
        }
        if (tokenType == TokenType.GOLD) {
            _goldMap[id] = _goldTracker.current();
            _goldTracker.increment();
        }
        if (tokenType == TokenType.DIAMOND) {
            _diamondMap[id] = _diamondTracker.current();
            _diamondTracker.increment();
        }
        emit CreateLightBoxNFT(id);
    }

    function setBronzePrice(uint256 newPrice) external onlyOwner {
        BRONZE_PRICE = newPrice * 1 ether;
    }

    function setGoldPrice(uint256 newPrice) external onlyOwner {
        GOLD_PRICE = newPrice * 1 ether;
    }

    function setDiamondPrice(uint256 newPrice) external onlyOwner {
        DIAMOND_PRICE = newPrice * 1 ether;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function setBronzeURI(string memory uri) public onlyOwner {
        _bronzeUri = uri;
    }

    function setGoldURI(string memory uri) public onlyOwner {
        _goldUri = uri;
    }

    function setDiamondURI(string memory uri) public onlyOwner {
        _diamondUri = uri;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI;

        if (_type[tokenId] == TokenType.BRONZE) {
            currentBaseURI = _bronzeUri;
            return
                bytes(currentBaseURI).length > 0
                    ? string(
                        abi.encodePacked(currentBaseURI, _bronzeMap[tokenId].toString(), ".json")
                    )
                    : "";
        } else if (_type[tokenId] == TokenType.GOLD) {
            currentBaseURI = _goldUri;
            return
                bytes(currentBaseURI).length > 0
                    ? string(
                        abi.encodePacked(currentBaseURI, _goldMap[tokenId].toString(), ".json")
                    )
                    : "";
        } else if (_type[tokenId] == TokenType.DIAMOND) {
            currentBaseURI = _diamondUri;
            return
                bytes(currentBaseURI).length > 0
                    ? string(
                        abi.encodePacked(currentBaseURI, _diamondMap[tokenId].toString(), ".json")
                    )
                    : "";
        }

        return "";
    }

    function walletOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

    function pauseMinting() external onlyOwner {
        isPaused = true;
    }

    function resumeMinting() external onlyOwner {
        isPaused = false;
    }

    function setTokenBurner(address burner) external onlyOwner {
        tokenBurner = burner;
    }

    function getTokenTier(uint256 tokenId) external view returns (TokenType) {
        return _type[tokenId];
    }

    function withdrawAll() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);
        payable(owner()).transfer(balance);
    }
}