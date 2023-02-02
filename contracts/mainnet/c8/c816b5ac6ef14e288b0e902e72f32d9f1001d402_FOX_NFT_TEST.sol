/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

/*
 * FOX NFT
 * 
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.16;

library Address {
    function isContract(address account) internal view returns (bool) {bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    mapping(bytes4 => bool) private _supportedInterfaces;
    constructor () {_registerInterface(_INTERFACE_ID_ERC165);}
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {return _supportedInterfaces[interfaceId];}
    function _registerInterface(bytes4 interfaceId) internal virtual {require(interfaceId != 0xffffffff, "ERC165: invalid interface id");_supportedInterfaces[interfaceId] = true;}
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

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0)  return "0";
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

contract ERC721 is ERC165, IERC721, IERC721Metadata {
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
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Metadata).interfaceId || super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    function name() public view virtual override returns (string memory) {return _name;}
    function symbol() public view virtual override returns (string memory) {return _symbol;}
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
    function _baseURI() internal view virtual returns (string memory) {return "";}
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);
        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved) public virtual override {_setApprovalForAll(msg.sender, operator, approved);}
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {return _operatorApprovals[owner][operator];}
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner or approved");
        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {safeTransferFrom(from, to, tokenId, "");}
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {return _owners[tokenId] != address(0);}
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }
    function _safeMint(address to, uint256 tokenId) internal virtual {_safeMint(to, tokenId, "");}
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, data),"ERC721: transfer to non ERC721Receiver implementer");
    }
    function _mint(address to, uint256 tokenId) internal virtual {
        require(!_exists(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        _balances[to]++;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        delete _tokenApprovals[tokenId];
        _balances[owner] -= 1;
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        _beforeTokenTransfer(from, to, tokenId);
        delete _tokenApprovals[tokenId];
        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) revert("ERC721: transfer to non ERC721Receiver implementer");
                else assembly {revert(add(32, reason), mload(reason))}
            }
        } else return true;
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual {}
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

    function totalSupply() public view virtual override returns (uint256) {return _allTokens.length;}

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        if (from == address(0)) _addTokenToAllTokensEnumeration(tokenId);
        else if (from != to) _removeTokenFromOwnerEnumeration(from, tokenId);
        if (to == address(0)) _removeTokenFromAllTokensEnumeration(tokenId);
        else if (to != from) _addTokenToOwnerEnumeration(to, tokenId);
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
            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];
        uint256 lastTokenId = _allTokens[lastTokenIndex];
        _allTokens[tokenIndex] = lastTokenId;
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

interface ICCVRF{
    function requestRandomness(uint256 requestID, uint256 howManyNumbers) external payable;
}

interface IDEXRouter {
    function WETH() external pure returns (address);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract FOX_NFT_TEST is ERC721, ERC721Enumerable {
    using Strings for uint256;
    string private baseURI;
    string private _fileExtension;
    address private CEO = 0xc3fC2A765FC09158f365cA381c7A1a0939Ed978a;
    ICCVRF public randomnessSupplier = ICCVRF(0xC0de0aB6E25cc34FB26dE4617313ca559f78C0dE);
    uint256 vrfCost = 0.002 ether;
    uint256 vrfReserve = 0.01 ether;

    mapping(address => bool) public isFox;
    
    uint256 private _totalSupply;

    IBEP20 public constant BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IBEP20 public constant USDT = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IBEP20 public constant FOX = IBEP20(0x16a7460B9246AE508f18e87bDa4e5B4C1AE8F112);
    IBEP20 public constant WBNB = IBEP20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address public constant FOX_BNB_POOL = 0x4d3d40BEaF014a68ac8a24978438F2Ce7B6a286b;
    address public constant BUSD_BNB_POOL = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;

    uint256 public totalMintFeesInBusd;
    uint256 public totalMintFeesInUsdt;
    uint256 public totalMintFeesInFox;
    uint256 public totalMintFeesInBnb;

    uint256 public totalUpgradePointFeesInBusd;
    uint256 public totalUpgradePointFeesInUsdt;
    uint256 public totalUpgradePointFeesInFox;
    uint256 public totalUpgradePointFeesInBnb;

    uint256 public totalRarityUpgradeFeesInBusd;
    uint256 public totalRarityUpgradeFeesInUsdt;
    uint256 public totalRarityUpgradeFeesInFox;
    uint256 public totalRarityUpgradeFeesInBnb;

    uint256 private constant MULTIPLIER = 10**18;

    mapping (uint256 => uint256) public priceOfType;
    mapping (uint256 => uint256) public maxNftsOfType;
    mapping (uint256 => uint256) public nftsLeftOfType;
    mapping (uint256 => uint256) public totalSupplyOfType;
    mapping (uint256 => uint256) public openTimeOfType;
    mapping (uint256 => uint256) public closeTimeOfType;
    mapping (uint256 => bool) public isRandomRarity;
    mapping (uint256 => uint256) public rarityOfType;

    mapping (uint256 => uint256) public typeOfNft;
    mapping (uint256 => uint256) public upgradePoints;
    
    struct attributes{
        uint256 power;
        uint256 stamina;
        uint256 agility;
        uint256 luck;
        uint256 dexterity;
        uint256 intellect;
    }

    mapping (uint256 => attributes) public statsOfNft;

    mapping (uint256 => uint256) public priceOfUpgradePoints;
    mapping (uint256 => uint256) public priceForReroll;
    mapping (uint256 => uint256) public priceForRarityUpgrade;

    mapping (uint256 => uint256) public rarityWeight;
    uint256 public rarityDivisor = 10000;

    uint256 private _nonce;
    mapping (uint256 => uint256) public idOfNonce;
    mapping (uint256 => bool) public nonceIsMint;


    modifier onlyCEO() {
        require(msg.sender == CEO, "Only the CEO can do that");
        _;
    }
    
    modifier onlyFox() {
        require(isFox[msg.sender], "Only Fox can do that");
        _;
    }

    modifier onlyVRF() {
        if(msg.sender != address(randomnessSupplier)) return; 
        _;
    }

    event NftMinted(
        uint256 id,
        uint256 typeMinted,
        uint256 rarity,
        uint256 totalStats,
        uint256 power,
        uint256 stamina,
        uint256 agility,
        uint256 luck,
        uint256 dexterity,
        uint256 intellect,
        uint256 upgradePoints
    );

    event NftUpdated(
        uint256 _id,
        uint256 _type,
        uint256 _rarity,
        uint256 _totalStats,
        uint256 _power,
        uint256 _stamina,
        uint256 _agility,
        uint256 _luck,
        uint256 _dexterity,
        uint256 _intellect,
        uint256 _upgradePoints
    );

    event NftMintInitiated(address minter, uint256 idOfMintedNFT, uint256 typeMinted, uint256 price);
    event NftRerollInitiated(address minter, uint256 idOfRerolledNft, uint256 price);   
    event UpgradePointsBought(address _from, uint256 _id, uint256 _price);
    event NftRarityUpgraded(address _from, uint256 _id, uint256 _price);
    event NftLevelUpgraded(address _from, uint256 _id, uint256 _TotalIncrease, uint256 _upgradePoints);

    event NewTypeCreated(uint256 newType, uint256 price, uint256 maxSupply, uint256 openingTime, uint256 closingTime, bool random, uint256 rarity);
    event TypeModified(uint256 typeToModify, uint256 price, uint256 maxSupply, uint256 openingTime, uint256 closingTime, bool typeIsRandom, uint256 rarity);
    event FoxWalletSet(address foxWallet, bool status);

    constructor() ERC721("Fox Test NFT", "FOXTEST") {
        rarityWeight[1] = 3500;
        rarityWeight[2] = 6500;
        rarityWeight[3] = 8800;
        rarityWeight[4] = 9800;
        rarityWeight[5] = 10000;
        isFox[CEO] = true;
    }

    receive() external payable {}

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable){super._beforeTokenTransfer(from, to, tokenId);}
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool){return super.supportsInterface(interfaceId);}
    function tokenURI(uint256 tokenId) public view override returns (string memory) {return string(abi.encodePacked(baseURI, tokenId.toString(), _fileExtension));}
    function setBaseUri(string memory uri) external onlyCEO {baseURI = uri;}
	function setFileExtension(string memory ext) external onlyCEO {_fileExtension = ext;}
    function _transfer(address from,address to, uint256 tokenId) internal override {super._transfer(from,to,tokenId);}

    function _mintToken(address _to, uint256 _tokenId) internal returns (uint256) {
        _mint(_to, _tokenId);
        return _tokenId;
    }

    function bnbAmountEqualToBusd(uint256 busdAmount) public view returns (uint256 bnbNeeded) {
        return WBNB.balanceOf(BUSD_BNB_POOL) * busdAmount / BUSD.balanceOf(BUSD_BNB_POOL);
    }

    function foxAmountEqualToBusd(uint256 busdAmount) public view returns (uint256 foxNeeded) {
        uint256 bnbNeeded = WBNB.balanceOf(BUSD_BNB_POOL) * busdAmount / WBNB.balanceOf(BUSD_BNB_POOL);
        foxNeeded = FOX.balanceOf(FOX_BNB_POOL) * bnbNeeded / WBNB.balanceOf(FOX_BNB_POOL);
        return foxNeeded;
    }

    function mintPriceInBnb(uint256 typeToMint) public view returns (uint256 bnbNeeded) {
        uint256 price = priceOfType[typeToMint];
        return WBNB.balanceOf(BUSD_BNB_POOL) * price / BUSD.balanceOf(BUSD_BNB_POOL);
    }

    function mintPriceInFox(uint256 typeToMint) public view returns (uint256 foxNeeded) {
        uint256 price = priceOfType[typeToMint];
        uint256 bnbNeeded = WBNB.balanceOf(BUSD_BNB_POOL) * price / WBNB.balanceOf(BUSD_BNB_POOL);
        foxNeeded = FOX.balanceOf(FOX_BNB_POOL) * bnbNeeded / WBNB.balanceOf(FOX_BNB_POOL);
        return foxNeeded;
    }

    function mintWithBusd(uint256 typeToMint) external {
        uint256 price = priceOfType[typeToMint];
        require(BUSD.transferFrom(msg.sender, address(this), price),"BUSD transfer failed");
        totalMintFeesInBusd += price;
        mintToWallet(msg.sender, typeToMint);
    }

    function mintWithUsdt(uint256 typeToMint) external {
        uint256 price = priceOfType[typeToMint];
        require(USDT.transferFrom(msg.sender, address(this), price),"USDT transfer failed");
        totalMintFeesInUsdt += price;
        mintToWallet(msg.sender, typeToMint);
    }

    function mintWithFox(uint256 typeToMint) external {
        uint256 price = priceOfType[typeToMint];
        uint256 priceInFox = foxAmountEqualToBusd(price);
        require(FOX.transferFrom(msg.sender, address(this), priceInFox),"FOX transfer failed");
        totalMintFeesInFox += priceInFox;
        mintToWallet(msg.sender, typeToMint);
    }

    function mintWithBnb(uint256 typeToMint) external payable {
        uint256 price = priceOfType[typeToMint];
        uint256 priceInBnb = bnbAmountEqualToBusd(price);
        require(msg.value >= priceInBnb, "Not enough BNB paid");
        totalMintFeesInBnb += priceInBnb;
        uint256 refund = msg.value - priceInBnb;
        payable(msg.sender).transfer(refund);
        mintToWallet(msg.sender, typeToMint);
    }

    function mintForFree(address to, uint256 typeToMint) public onlyFox {
        mintToWallet(to, typeToMint);
    }

    function mintToWallet(address to, uint256 typeToMint) internal {
        require(openTimeOfType[typeToMint] <= block.timestamp && closeTimeOfType[typeToMint] >= block.timestamp, "type not for sale at the moment");
        require(nftsLeftOfType[typeToMint] > 0, "This type is sold out, sorry.");
        uint256 idOfMintedNFT = _mintToken(to, _totalSupply);
        typeOfNft[idOfMintedNFT] = typeToMint;
        _totalSupply++;
        totalSupplyOfType[typeToMint]++;
        nftsLeftOfType[typeToMint]--;
        idOfNonce[_nonce] = idOfMintedNFT;
        nonceIsMint[_nonce] = true;
        randomnessSupplier.requestRandomness(_nonce, 7);
        _nonce++;
        emit NftMintInitiated(to, idOfMintedNFT, typeToMint, 0);
    }

    function giveUpgradePointsForFree(uint256 id, uint256 howMany) external onlyFox {
        uint256 totalStats = getTotalStatsOfId(id);
        uint256 nextLevel = totalStats / 100 * 100 + 100;
        if(totalStats + upgradePoints[id] + howMany >= nextLevel) howMany = nextLevel - totalStats - upgradePoints[id] - 1;
        upgradePoints[id] += howMany;
        emit UpgradePointsBought(msg.sender, id, 0);
        emitUpdatedNftInfo(id);
    }

    function buyUpgradePointsWithBusd(uint256 id, uint256 howMany) external {
        uint256 totalStats = getTotalStatsOfId(id);
        uint256 nextLevel = totalStats / 100 * 100 + 100;
        if(totalStats + upgradePoints[id] + howMany >= nextLevel) howMany = nextLevel - totalStats - upgradePoints[id] - 1;
        uint256 price = howMany * priceOfUpgradePoints[totalStats/100];
        require(BUSD.transferFrom(msg.sender, address(this), howMany * price),"BUSD transfer failed");
        upgradePoints[id] += howMany;
        totalUpgradePointFeesInBusd += price;
        emit UpgradePointsBought(msg.sender, id, price);
        emitUpdatedNftInfo(id);
    }

    function buyUpgradePointsWithUsdt(uint256 id, uint256 howMany) external {
        uint256 totalStats = getTotalStatsOfId(id);
        uint256 nextLevel = totalStats / 100 * 100 + 100;
        if(totalStats + upgradePoints[id] + howMany >= nextLevel) howMany = nextLevel - totalStats - upgradePoints[id] - 1;
        uint256 price = howMany * priceOfUpgradePoints[totalStats/100];
        require(USDT.transferFrom(msg.sender, address(this), howMany * price),"USDT transfer failed");
        upgradePoints[id] += howMany;
        totalUpgradePointFeesInUsdt += price;
        emit UpgradePointsBought(msg.sender, id, price);
        emitUpdatedNftInfo(id);
    }

    function buyUpgradePointsWithFox(uint256 id, uint256 howMany) external {
        uint256 totalStats = getTotalStatsOfId(id);
        uint256 nextLevel = totalStats / 100 * 100 + 100;
        if(totalStats + upgradePoints[id] + howMany >= nextLevel) howMany = nextLevel - totalStats - upgradePoints[id] - 1;
        uint256 price = howMany * priceOfUpgradePoints[totalStats/100];
        uint256 priceInFox = foxAmountEqualToBusd(price);
        require(FOX.transferFrom(msg.sender, address(this), priceInFox),"FOX transfer failed");
        upgradePoints[id] += howMany;
        totalUpgradePointFeesInFox += price;
        emit UpgradePointsBought(msg.sender, id, price);
        emitUpdatedNftInfo(id);
    }

    function buyUpgradePointsWithBnb(uint256 id, uint256 howMany) external payable {
        uint256 totalStats = getTotalStatsOfId(id);
        uint256 nextLevel = totalStats / 100 * 100 + 100;
        if(totalStats + upgradePoints[id] + howMany >= nextLevel) howMany = nextLevel - totalStats - upgradePoints[id] - 1;
        uint256 price = howMany * priceOfUpgradePoints[totalStats/100];
        uint256 priceInBnb = bnbAmountEqualToBusd(price);
        require(msg.value >= priceInBnb, "Not enough BNB paid");
        totalUpgradePointFeesInBnb += priceInBnb;
        uint256 refund = msg.value - priceInBnb;
        payable(msg.sender).transfer(refund);
        upgradePoints[id] += howMany;
        emit UpgradePointsBought(msg.sender, id, price);
        emitUpdatedNftInfo(id);
    }

    function buyRarityUpgradeWithBusd(uint256 id, uint256 statToUpgrade) external {
        require(ownerOf(id) == msg.sender, "Can't upgrade an NFT that is not owned by you");
        uint256 totalStats = getTotalStatsOfId(id);
        require(totalStats % 100 == 99 && upgradePoints[id] == 0, "Level not high enough to levelUp to next rarity");
        uint256 price = priceForRarityUpgrade[totalStats/100];
        require(BUSD.transferFrom(msg.sender, address(this), price),"BUSD transfer failed");
        if(statToUpgrade == 1) statsOfNft[id].power++;
        if(statToUpgrade == 2) statsOfNft[id].stamina++;
        if(statToUpgrade == 3) statsOfNft[id].agility++;
        if(statToUpgrade == 4) statsOfNft[id].luck++;
        if(statToUpgrade == 5) statsOfNft[id].dexterity++;
        if(statToUpgrade == 6) statsOfNft[id].intellect++;
        totalRarityUpgradeFeesInBusd += price;
        emit NftRarityUpgraded(msg.sender, id, price);
        emitUpdatedNftInfo(id);
    }

    function buyRarityUpgradeWithUsdt(uint256 id, uint256 statToUpgrade) external {
        require(ownerOf(id) == msg.sender, "Can't upgrade an NFT that is not owned by you");
        uint256 totalStats = getTotalStatsOfId(id);
        require(totalStats % 100 == 99 && upgradePoints[id] == 0, "Level not high enough to levelUp to next rarity");
        uint256 price = priceForRarityUpgrade[totalStats/100];
        require(USDT.transferFrom(msg.sender, address(this), price),"USDT transfer failed");
        if(statToUpgrade == 1) statsOfNft[id].power++;
        if(statToUpgrade == 2) statsOfNft[id].stamina++;
        if(statToUpgrade == 3) statsOfNft[id].agility++;
        if(statToUpgrade == 4) statsOfNft[id].luck++;
        if(statToUpgrade == 5) statsOfNft[id].dexterity++;
        if(statToUpgrade == 6) statsOfNft[id].intellect++;
        totalRarityUpgradeFeesInUsdt += price;
        emit NftRarityUpgraded(msg.sender, id, price);
        emitUpdatedNftInfo(id);
    }

    function buyRarityUpgradeWithFox(uint256 id, uint256 statToUpgrade) external {
        require(ownerOf(id) == msg.sender, "Can't upgrade an NFT that is not owned by you");
        uint256 totalStats = getTotalStatsOfId(id);
        require(totalStats % 100 == 99 && upgradePoints[id] == 0, "Level not high enough to levelUp to next rarity");
        uint256 price = priceForRarityUpgrade[totalStats/100];
        uint256 priceInFox = foxAmountEqualToBusd(price);
        require(FOX.transferFrom(msg.sender, address(this), priceInFox),"FOX transfer failed");
        if(statToUpgrade == 1) statsOfNft[id].power++;
        if(statToUpgrade == 2) statsOfNft[id].stamina++;
        if(statToUpgrade == 3) statsOfNft[id].agility++;
        if(statToUpgrade == 4) statsOfNft[id].luck++;
        if(statToUpgrade == 5) statsOfNft[id].dexterity++;
        if(statToUpgrade == 6) statsOfNft[id].intellect++;
        totalRarityUpgradeFeesInFox += price;
        emit NftRarityUpgraded(msg.sender, id, price);
        emitUpdatedNftInfo(id);
    }

    function buyRarityUpgradeWithBnb(uint256 id, uint256 statToUpgrade) external payable {
        require(ownerOf(id) == msg.sender, "Can't upgrade an NFT that is not owned by you");
        uint256 totalStats = getTotalStatsOfId(id);
        require(totalStats % 100 == 99 && upgradePoints[id] == 0, "Level not high enough to levelUp to next rarity");
        uint256 price = priceForRarityUpgrade[totalStats/100];
        uint256 priceInBnb = bnbAmountEqualToBusd(price);
        require(msg.value >= priceInBnb, "Not enough BNB paid");
        uint256 refund = msg.value - priceInBnb;
        payable(msg.sender).transfer(refund);
        if(statToUpgrade == 1) statsOfNft[id].power++;
        if(statToUpgrade == 2) statsOfNft[id].stamina++;
        if(statToUpgrade == 3) statsOfNft[id].agility++;
        if(statToUpgrade == 4) statsOfNft[id].luck++;
        if(statToUpgrade == 5) statsOfNft[id].dexterity++;
        if(statToUpgrade == 6) statsOfNft[id].intellect++;
        totalRarityUpgradeFeesInBnb += price;
        emit NftRarityUpgraded(msg.sender, id, price);
        emitUpdatedNftInfo(id);
    }

    function upgradeNft(uint256 id, uint256 powerUp, uint256 staminaUp, uint256 agilityUp, uint256 luckUp, uint256 dexterityUp, uint256 intellectUp) external {
        require(ownerOf(id) == msg.sender, "Can't upgrade an NFT that is not owned by you");
        require(powerUp + staminaUp + agilityUp + luckUp + dexterityUp + intellectUp<= upgradePoints[id], "You don't have enough points to do that");
        statsOfNft[id].power += powerUp;
        statsOfNft[id].stamina += staminaUp;
        statsOfNft[id].agility += agilityUp;
        statsOfNft[id].luck += luckUp;
        statsOfNft[id].dexterity += dexterityUp;
        statsOfNft[id].intellect += intellectUp;
        upgradePoints[id] -= powerUp + staminaUp + agilityUp + luckUp + dexterityUp + intellectUp;
        emit NftLevelUpgraded(msg.sender,id,powerUp + staminaUp + agilityUp + luckUp + dexterityUp + intellectUp,upgradePoints[id]); 
        emitUpdatedNftInfo(id);
    }
/////////////// Todo Reroll for all currencies

    function rerollNft(uint256 id) external {
        require(ownerOf(id) == msg.sender, "Can't upgrade an NFT that is not owned by you");
        uint256 totalStats = getTotalStatsOfId(id);
        uint256 price = priceForReroll[totalStats/100];
        require(BUSD.transferFrom(msg.sender, address(this), price),"BUSD transfer failed");
        idOfNonce[_nonce] = id;
        nonceIsMint[_nonce] = false;
        randomnessSupplier.requestRandomness(_nonce, 7);
        _nonce++;
        emit NftRerollInitiated(msg.sender, id, price);   
    }

    function supplyRandomness(uint256 nonce, uint256[] memory randomNumbers) external onlyVRF {
        if(nonceIsMint[nonce]) {
            uint256 id = idOfNonce[nonce];
            uint256 typeOfThisId = typeOfNft[id];
            uint256 rarity;

            if(isRandomRarity[typeOfThisId]){
                uint256 rarityRandomness = randomNumbers[0] % rarityDivisor;
                for(uint256 i= 1; i <= 5; i++){
                    if(rarityRandomness < rarityWeight[i]) {
                        rarity = i;
                        break; 
                    }
                }
            } else rarity = rarityOfType[typeOfThisId];
            
            uint256 randomNumbersTotal = randomNumbers[1] + randomNumbers[2] + randomNumbers[3] + randomNumbers[4] + randomNumbers[5] + randomNumbers[6]; 

            statsOfNft[id].power = rarity * 100 * randomNumbers[1] / randomNumbersTotal;
            statsOfNft[id].stamina = rarity * 100 * randomNumbers[2] / randomNumbersTotal;
            statsOfNft[id].agility = rarity * 100 * randomNumbers[3] / randomNumbersTotal;
            statsOfNft[id].luck = rarity * 100 * randomNumbers[4] / randomNumbersTotal;
            statsOfNft[id].dexterity = rarity * 100 * randomNumbers[5] / randomNumbersTotal;
            statsOfNft[id].intellect = rarity * 100 - statsOfNft[id].power - statsOfNft[id].stamina - statsOfNft[id].agility - statsOfNft[id].luck - statsOfNft[id].dexterity;
            emit NftMinted(id, typeOfNft[id], rarity, rarity * 100, statsOfNft[id].power, statsOfNft[id].stamina, statsOfNft[id].agility, statsOfNft[id].luck, statsOfNft[id].dexterity, statsOfNft[id].intellect, 0);
        } else {
            uint256 id = idOfNonce[nonce];
            uint256 totalStats= getTotalStatsOfId(id);
            uint256 randomNumbersTotal = randomNumbers[1] + randomNumbers[2] + randomNumbers[3] + randomNumbers[4] + randomNumbers[5] + randomNumbers[6]; 
            upgradePoints[id] += totalStats % 100;
            totalStats = totalStats / 100 * 100;
            uint256 statsLeft = totalStats;
            statsOfNft[id].power = totalStats * randomNumbers[1] / randomNumbersTotal;
            statsLeft -= statsOfNft[id].power;
            statsOfNft[id].stamina = totalStats * randomNumbers[2] / randomNumbersTotal;
            statsLeft -= statsOfNft[id].stamina;
            statsOfNft[id].agility = totalStats * randomNumbers[3] / randomNumbersTotal;
            statsLeft -= statsOfNft[id].agility;
            statsOfNft[id].luck = totalStats * randomNumbers[4] / randomNumbersTotal;
            statsLeft -= statsOfNft[id].luck;
            statsOfNft[id].dexterity = totalStats * randomNumbers[5] / randomNumbersTotal;
            statsLeft -= statsOfNft[id].dexterity;
            statsOfNft[id].intellect = statsLeft;
            emitUpdatedNftInfo(id);
        }
    }


    function getTotalStatsOfId(uint256 id) public view returns(uint256) {
        uint256 totalStats = statsOfNft[id].power + statsOfNft[id].stamina + statsOfNft[id].agility + statsOfNft[id].luck + statsOfNft[id].dexterity + statsOfNft[id].intellect;
        return totalStats;
    }

    function getRarityOfId(uint256 id) public view returns(uint256) {
        uint256 totalStats = statsOfNft[id].power + statsOfNft[id].stamina + statsOfNft[id].agility + statsOfNft[id].luck + statsOfNft[id].dexterity + statsOfNft[id].intellect;
        return totalStats / 100;
    }

    function getAllStatsOfId(uint256 id) public view returns(uint256, uint256, uint256, uint256, uint256, uint256) {
        return(statsOfNft[id].power, statsOfNft[id].stamina, statsOfNft[id].agility, statsOfNft[id].luck, statsOfNft[id].dexterity, statsOfNft[id].intellect);
    }
    
    function emitUpdatedNftInfo(uint256 id) public {
        uint256 totalStats = statsOfNft[id].power + statsOfNft[id].stamina + statsOfNft[id].agility + statsOfNft[id].luck + statsOfNft[id].dexterity + statsOfNft[id].intellect;
        uint256 rarity = totalStats / 100;
        emit NftUpdated(id, typeOfNft[id], rarity, totalStats, statsOfNft[id].power, statsOfNft[id].stamina, statsOfNft[id].agility, statsOfNft[id].luck, statsOfNft[id].dexterity, statsOfNft[id].intellect, upgradePoints[id]);
    }

    function setUpgradePointCost(uint256 rarity, uint256 priceInBusd) external onlyCEO {
        priceOfUpgradePoints[rarity] = priceInBusd;
    }    
    function setPriceForRarityUpgrade(uint256 rarity, uint256 priceInBusd) external onlyCEO {
        priceForRarityUpgrade[rarity] = priceInBusd;
    }    
    function setPriceForReroll(uint256 rarity, uint256 priceInBusd) external onlyCEO {
        priceForReroll[rarity] = priceInBusd;
    }

    function collectBnb() external onlyCEO {
        (bool success,) = address(CEO).call{value: address(this).balance - vrfReserve}("");
    }    
    
    function rescueBnb() external onlyCEO {
        (bool success,) = address(CEO).call{value: address(this).balance}("");
    }

    function collectBusd() external onlyCEO {
        BUSD.transfer(CEO, BUSD.balanceOf(address(this)));  
    }

    function collectUsdt() external onlyCEO {
        USDT.transfer(CEO, USDT.balanceOf(address(this)));  
    }    
    
    function collectFox() external onlyCEO {
        FOX.transfer(CEO, FOX.balanceOf(address(this)));  
    }    
        
    function setRarityWeights(uint256 common, uint256 uncommon, uint256 rare, uint256 epic, uint256 legendary) external onlyCEO {
        rarityWeight[1] = common;
        rarityWeight[2] = uncommon;
        rarityWeight[3] = rare;
        rarityWeight[4] = epic;
        rarityWeight[5] = legendary;
    }

    function createNewType(uint256 newType, uint256 price, uint256 maxSupply, uint256 openingTime, uint256 closingTime, bool random, uint256 rarity) external onlyCEO {
        require(maxNftsOfType[newType] == 0, "Type already exists");
        priceOfType[newType] = price * 1 ether;
        maxNftsOfType[newType] = maxSupply;
        nftsLeftOfType[newType] = maxSupply;
        openTimeOfType[newType] = openingTime;
        closeTimeOfType[newType] = closingTime;
        isRandomRarity[newType] = random;
        if(!random) rarityOfType[newType] = rarity;
        emit NewTypeCreated(newType, price, maxSupply, openingTime, closingTime, random, rarity);
    }

    function modifyType(uint256 typeToModify, uint256 price, uint256 maxSupply, uint256 openingTime, uint256 closingTime, uint256 rarity) external onlyCEO {
        require(maxNftsOfType[typeToModify] != 0, "Type doesn't exist yet");
        if(maxSupply > maxNftsOfType[typeToModify]) nftsLeftOfType[typeToModify] += maxSupply - maxNftsOfType[typeToModify];
        if(maxSupply < maxNftsOfType[typeToModify]) nftsLeftOfType[typeToModify] -= maxNftsOfType[typeToModify] - maxSupply;
        priceOfType[typeToModify] = price * 1 ether;
        maxNftsOfType[typeToModify] = maxSupply;
        openTimeOfType[typeToModify] = openingTime;
        closeTimeOfType[typeToModify] = closingTime;
        rarityOfType[typeToModify] = rarity;
        emit TypeModified(typeToModify, price, maxSupply, openingTime, closingTime, isRandomRarity[typeToModify], rarity);
    } 

    function setFoxWallet(address FoxWallet, bool status) external onlyCEO {
        isFox[FoxWallet] = status;
        emit FoxWalletSet(FoxWallet, status);
    }

    function transferOwnership(address newCeo) external onlyCEO {
        CEO = newCeo;
    }   
}