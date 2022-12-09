/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

/*  
 * ARK LEGACY NFT
 * 
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.17;

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

interface IVAULT {
    function accountReachedMaxPayout(address investor) external view returns (bool);
    function addSparkPlayer(address investor) external;
}

contract ARK_LEGACY is ERC721, ERC721Enumerable {
    using Strings for uint256;
    string private baseURI;
    string private _fileExtension;
    address private constant CEO = 0x52C244bD8864Dd760643249f2DCDD550F6b4485A;
    IVAULT public vault;
    
    mapping(address => bool) public isArk;
    
    uint256 private _totalSupply;

    IBEP20 public constant BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    uint256 public totalContributions;
    uint256 private constant MULTIPLIER = 10**18;

    mapping (uint256 => uint256) public levelOfNft;
    mapping (uint256 => uint256) public nftPriceOfLevel;
    mapping (uint256 => uint256) public maxNftsOfLevel;
    mapping (uint256 => uint256) public nftsLeftOfLevel;
    mapping (uint256 => uint256) public totalSupplyOfLevel;
    mapping (uint256 => uint256) public cwrOfLevel;
    mapping (uint256 => uint256) public votesOfLevel;
    mapping (uint256 => uint256) public levelsOfLevel;
    mapping (uint256 => uint256) public sharesOfLevel;
    mapping (uint256 => uint256) public pricePaidForId;
    mapping (uint256 => bool) public locked;

	uint256 public totalShares;
    uint256 public totalRewardsPerShare;
    uint256 public lastDistribution;
    uint256 public dailyRewardPercent = 2;
    uint256 public rewardsPool;
    uint256 public rewardsPercent = 20;
    uint256 private veryBigNumber = 10 ** 36;

    uint256 public maxCwrWithoutNft = 1500;
    uint256 public openingHour = type(uint256).max;

    mapping (uint256 => uint256) public claimedRewards;
	mapping (uint256 => uint256) public shares;
    mapping (uint256 => uint256) public excluded;

    event RewardsAdded(uint256 rewardsToBeAdded);
    event RewardsDistributed(uint256 rewardsToBeAdded);
    event RewardsClaimed(address investor, uint256 claimableNow);
    event VaultSet(address vaultAddress);
    event ArkWalletSet(address arkWallet, bool status);

    modifier onlyCEO() {
        require(msg.sender == CEO, "Only the CEO can do that");
        _;
    }
    
    modifier onlyArk() {
        require(isArk[msg.sender], "Only ARK can do that");
        _;
    }

    event NftMinted(address indexed user, uint256 indexed tokenId, uint256 level, uint256 price);
    event NftLevelledUp(address indexed user, uint256 indexed tokenId, uint256 oldLevel , uint256 newLevel, uint256 priceOfLevelUp);

    constructor() ERC721("ARK Legacy NFT", "ARKLEGACY") {
        nftPriceOfLevel[1] = 1000 ether;
        nftPriceOfLevel[2] = 4000 ether;
        nftPriceOfLevel[3] = 10000 ether;
        maxNftsOfLevel[1] = 3000;
        maxNftsOfLevel[2] = 500;
        maxNftsOfLevel[3] = 100;
        nftsLeftOfLevel[1] = 3000;
        nftsLeftOfLevel[2] = 500;
        nftsLeftOfLevel[3] = 100;
        cwrOfLevel[1] = 2500;
        cwrOfLevel[2] = 6000;
        cwrOfLevel[3] = 13000;
        votesOfLevel[1] = 1;
        votesOfLevel[2] = 4;
        votesOfLevel[3] = 10;
        levelsOfLevel[1] = 3;
        levelsOfLevel[2] = 9;
        levelsOfLevel[3] = 15;
        sharesOfLevel[1] = 1;
        sharesOfLevel[2] = 4;
        sharesOfLevel[3] = 10;
        isArk[CEO] = true;             
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable){super._beforeTokenTransfer(from, to, tokenId);}
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool){return super.supportsInterface(interfaceId);}
    function tokenURI(uint256 tokenId) public view override returns (string memory) {return string(abi.encodePacked(baseURI, tokenId.toString(), _fileExtension));}
    function setBaseUri(string memory uri) external onlyCEO {baseURI = uri;}
	function setFileExtension(string memory ext) external onlyCEO {_fileExtension = ext;}
    function _transfer(address from,address to, uint256 tokenId) internal override {
        require(!locked[tokenId], "NFT is locked");
        _claim(from);
        require(balanceOf(to) == 0, "Max NFT per wallet exceeded");
        super._transfer(from,to,tokenId);
    }

    function _mintToken(address _to, uint256 _tokenId) internal returns (uint256) {
        _mint(_to, _tokenId);
        return _tokenId;
    }

    function mint(uint256 level) external {
        require(balanceOf(msg.sender) == 0, "Max NFT per wallet exceeded");
        require(openingHour <= block.timestamp, "Sale not open yet");
        require(nftsLeftOfLevel[level] > 0, "This level is sold out, sorry.");
        uint256 price = nftPriceOfLevel[level];
        require(BUSD.transferFrom(msg.sender, address(this), price),"BUSD transfer failed");
        totalContributions += price;
        uint256 idOfMintedNFT = _mintToken(msg.sender, _totalSupply);
        pricePaidForId[idOfMintedNFT] = price;
        levelOfNft[idOfMintedNFT] = level;
        _totalSupply++;
        totalSupplyOfLevel[level]++;
        nftsLeftOfLevel[level]--;
        uint256 rewardsShare = price * rewardsPercent / 100;
        rewardsPool += rewardsShare;
        totalShares += sharesOfLevel[level];
        shares[idOfMintedNFT] = sharesOfLevel[level];
        require(BUSD.transfer(CEO, price - rewardsShare),"BUSD transfer failed");
        emit NftMinted(msg.sender, idOfMintedNFT, level, price);
    }

    function mintToWallet(address to, uint256 level) external onlyCEO {
        require(balanceOf(to) == 0, "Max NFT per wallet exceeded");
        require(nftsLeftOfLevel[level] > 0, "This level is sold out, sorry.");
        uint256 price = nftPriceOfLevel[level];
        uint256 idOfMintedNFT = _mintToken(to, _totalSupply);
        pricePaidForId[idOfMintedNFT] = price;
        levelOfNft[idOfMintedNFT] = level;
        _totalSupply++;
        totalSupplyOfLevel[level]++;
        nftsLeftOfLevel[level]--;
        totalShares += sharesOfLevel[level];
        shares[idOfMintedNFT] = sharesOfLevel[level];
        emit NftMinted(to, idOfMintedNFT, level, price);
    }

    function mintToWalletPaid(address to, uint256 level) external onlyCEO {
        require(balanceOf(to) == 0, "Max NFT per wallet exceeded");
        require(nftsLeftOfLevel[level] > 0, "This level is sold out, sorry.");
        uint256 price = nftPriceOfLevel[level];
        require(BUSD.transferFrom(msg.sender, address(this), price),"BUSD transfer failed");
        totalContributions += price;
        uint256 idOfMintedNFT = _mintToken(to, _totalSupply);
        pricePaidForId[idOfMintedNFT] = price;
        levelOfNft[idOfMintedNFT] = level;
        _totalSupply++;
        totalSupplyOfLevel[level]++;
        nftsLeftOfLevel[level]--;
        uint256 rewardsShare = price * rewardsPercent / 100;
        rewardsPool += rewardsShare;
        totalShares += sharesOfLevel[level];
        shares[idOfMintedNFT] = sharesOfLevel[level];
        require(BUSD.transfer(CEO, price - rewardsShare),"BUSD transfer failed");
        emit NftMinted(to, idOfMintedNFT, level, price);
    }

    function getPriceForLevelUp(uint256 id) public view returns(uint256) {
        uint256 currentLevel = levelOfNft[id];
        uint256 nextLevel = currentLevel + 1;
        uint256 priceForLevelUp = nftPriceOfLevel[nextLevel] - pricePaidForId[id];
        return priceForLevelUp;
    }

    function levelUp(uint256 id) external {
        require(ownerOf(id) == msg.sender, "Can't upgrade an NFT that is not owned by you");
        uint256 currentLevel = levelOfNft[id];
        uint256 nextLevel = currentLevel + 1;
        uint256 priceForLevelUp = nftPriceOfLevel[nextLevel] - pricePaidForId[id];
        require(nftsLeftOfLevel[nextLevel] > 0, "This level is sold out, sorry.");
        _claim(msg.sender);
        require(BUSD.transferFrom(msg.sender, address(this), priceForLevelUp),"BUSD transfer failed");
        totalContributions += priceForLevelUp;
        pricePaidForId[id] += priceForLevelUp;
        levelOfNft[id] = nextLevel;
        totalSupplyOfLevel[nextLevel]++;
        totalSupplyOfLevel[currentLevel]--;
        nftsLeftOfLevel[nextLevel]--;
        nftsLeftOfLevel[currentLevel]++;
        uint256 rewardsShare = priceForLevelUp * rewardsPercent / 100;
        rewardsPool += rewardsShare;
        totalShares -= sharesOfLevel[currentLevel];
        totalShares += sharesOfLevel[nextLevel];
        shares[id] = sharesOfLevel[nextLevel];
        require(BUSD.transfer(CEO, priceForLevelUp - rewardsShare),"BUSD transfer failed");
        emit NftLevelledUp(msg.sender, id, currentLevel, nextLevel, priceForLevelUp);
    }

    function lockNft() external {
        uint256 id = tokenOfOwnerByIndex(msg.sender, 0);
        require(!locked[id], "NFT already locked");
        vault.addSparkPlayer(msg.sender);
        locked[id] = true;
    }

    function unlockNft() external {
        uint256 id = tokenOfOwnerByIndex(msg.sender, 0);
        require(locked[id], "NFT already unlocked");
        require(vault.accountReachedMaxPayout(ownerOf(id)), "Can't unlock an NFT before reaching maxPayout");
        locked[id] = false;
    }

    function adminUnlockNft(uint256 id) external onlyCEO{
        locked[id] = false;
    }

    function createNewLevel(uint256 level, uint256 price, uint256 maxSupply, uint256 cwr, uint256 votes, uint256 levels, uint256 share) external onlyCEO {
        require(nftPriceOfLevel[level] == 0, "Level already exists");
        nftPriceOfLevel[level] = price * 1 ether;
        maxNftsOfLevel[level] = maxSupply;
        nftsLeftOfLevel[level] = maxSupply;
        cwrOfLevel[level] = cwr;
        votesOfLevel[level] = votes;
        levelsOfLevel[level] = levels;
        sharesOfLevel[level] = share;
    } 

    function modifyLevel(uint256 level, uint256 price, uint256 maxSupply, uint256 cwr, uint256 votes, uint256 levels) external onlyCEO {
        if(maxSupply > maxNftsOfLevel[level]) {
            uint256 additionalNfts = maxSupply - maxNftsOfLevel[level];
            nftsLeftOfLevel[level] += additionalNfts;
        }

        if(maxSupply < maxNftsOfLevel[level]) {
            uint256 lessNfts = maxNftsOfLevel[level] - maxSupply;
            nftsLeftOfLevel[level] -= lessNfts;
        }

        nftPriceOfLevel[level] = price * 1 ether;
        maxNftsOfLevel[level] = maxSupply;
        cwrOfLevel[level] = cwr;
        votesOfLevel[level] = votes;
        levelsOfLevel[level] = levels;
    } 

    function getCwr(address investor) external view returns(uint256) {
        if(balanceOf(investor) == 0) return maxCwrWithoutNft;
        uint256 id = tokenOfOwnerByIndex(investor, 0);
        uint256 level = levelOfNft[id];
        uint256 cwr = locked[id] ? cwrOfLevel[level] : maxCwrWithoutNft;
        return cwr;
    }

    function getLevels(address investor) external view returns(uint256) {
        if(balanceOf(investor) == 0) return 0;        
        uint256 id = tokenOfOwnerByIndex(investor, 0);
        uint256 level = levelOfNft[id];
        uint256 levels = locked[id] ? levelsOfLevel[level] : 0;
        return levels;
    }

    function setUpLaunch(uint256 openingTimestamp) external onlyCEO {
        require(openingHour == type(uint256).max, "Can't close minting");
        lastDistribution = openingTimestamp;
        openingHour = openingTimestamp;
    }

    function increaseLimitOfNFTs(uint256 level, uint256 howMany) external onlyCEO {
        maxNftsOfLevel[level] += howMany;
        nftsLeftOfLevel[level] += howMany;
    }

    function setArkWallet(address arkWallet, bool status) external onlyCEO {
        isArk[arkWallet] = status;
        emit ArkWalletSet(arkWallet, status);
    }

    function setVaultAddress(address vaultAddress) external onlyCEO {
        vault = IVAULT(vaultAddress);
        IBEP20(BUSD).approve(address(vault), type(uint256).max);
        emit VaultSet(vaultAddress);
    }

    // Integrated marketplace
    uint256[] public nftsForSale;
    mapping (uint256 => bool) public idForSale;
    mapping (uint256 => uint256) public priceOfId;
    mapping(uint256 => uint256) private nftForSaleIndexes; 
    event NftOffered(address seller, uint256 id, uint256 price);
    event NftSold(address seller, address buyer, uint256 id, uint256 price);

    function buy(uint256 id) external {
        address seller = ownerOf(id);
        uint256 price = priceOfId[id];
        require(idForSale[id], "Can only buy listed NFTs");
        require(BUSD.transferFrom(msg.sender, seller, price),"BUSD transfer failed");
        idForSale[id] = false;
        removeNftForSale(id);
        _transfer(seller, msg.sender, id);
        emit NftSold(seller, msg.sender, id, price);
    }

    function sell(uint256 id, uint256 price) external {
        require(ownerOf(id) == msg.sender, "Can't transfer a token that is not owned by you");
        require(!locked[id], "NFT is locked");
        idForSale[id] = true;
        priceOfId[id] = price;
        addNftForSale(id);
        emit NftOffered(msg.sender, id, price);
    }
    
    function getAllIdsForSale() public view returns(uint256[] memory) {
        return nftsForSale;
    }
    
    function addNftForSale(uint256 _nftForSale) internal {
        nftForSaleIndexes[_nftForSale] = nftsForSale.length;
        nftsForSale.push(_nftForSale);
    }

    function removeNftForSale(uint256 _nftForSale) internal {
        nftsForSale[nftForSaleIndexes[_nftForSale]] = nftsForSale[nftsForSale.length - 1];
        nftForSaleIndexes[nftsForSale[nftsForSale.length - 1]] = nftForSaleIndexes[_nftForSale];
        nftsForSale.pop();
    }

///////////////// NFT Rewards Pool
    function addToRewards(uint256 busdAmount) external {
        require(BUSD.transferFrom(msg.sender, address(this), busdAmount),"BUSD transfer failed");
        rewardsPool += busdAmount;
        emit RewardsAdded(busdAmount);
    }

    function distributeRewards() external {
        if(lastDistribution + 24 hours > block.timestamp) return;
        lastDistribution = block.timestamp;
        uint256 rewardsToBeAdded = rewardsPool * dailyRewardPercent / 100;
        totalRewardsPerShare += rewardsToBeAdded * veryBigNumber / totalShares;
        rewardsPool -= rewardsToBeAdded;
        emit RewardsDistributed(rewardsToBeAdded);
    }

    function claimRewards() external {
        _claim(msg.sender);
    }

    function claimRewardsFor(address investor) external onlyArk {
        _claim(investor);
    }

    function _claim(address investor) internal {
        if(balanceOf(investor) == 0) return;        
        uint256 id = tokenOfOwnerByIndex(investor, 0);
        uint256 claimedAlready = excluded[id];
        if(claimedAlready >= totalRewardsPerShare * shares[id]) return;
        uint256 claimableNow = shares[id] * (totalRewardsPerShare - claimedAlready) / veryBigNumber;
        claimedRewards[id] += claimableNow;
        excluded[id] = totalRewardsPerShare;
        require(BUSD.transfer(investor, claimableNow),"BUSD transfer failed");
        emit RewardsClaimed(investor, claimableNow);
    }

    function getClaimableRewards(address investor) public view returns(uint256) {
        if(balanceOf(investor) == 0) return 0;        
        uint256 id = tokenOfOwnerByIndex(investor, 0);
        uint256 claimedAlready = excluded[id];
        if(claimedAlready >= totalRewardsPerShare * shares[id]) return 0;
        uint256 claimableNow = shares[id] * (totalRewardsPerShare - claimedAlready) / veryBigNumber;
        return claimableNow;
    }

    function getShares(address investor) public view returns(uint256) {
        if(balanceOf(investor) == 0) return 0;        
        uint256 id = tokenOfOwnerByIndex(investor, 0);
        return shares[id];
    }
    
/////// emergency function just in case
    function rescueAnyToken(address tokenToRescue) external onlyCEO {
        require(IBEP20(tokenToRescue).transfer(msg.sender, IBEP20(tokenToRescue).balanceOf(address(this))),"Failed");
    }
}