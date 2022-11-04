/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

/*  
 * ARK PrivateSale
 * 
 * Written by: MrGreenCrypto
 * Co-Founder of CodeCraftrs.com
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

interface IDEXRouter {
    function WETH() external pure returns (address);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

contract ARK_PRIVATE_SALE is ERC721, ERC721Enumerable {
    using Strings for uint256;
    string private baseURI;
    string private _fileExtension;
    address private CEO = 0x236e437177A19A0729E44f8612B2fDF2A3578FE8;
    uint256 public constant MAX_NFT_SUPPLY = 1111;
    uint256 public nftsLeft = 1111;
    uint256 private _totalSupply;
    mapping(address => bool) public limitlessAddress;
    mapping(address => bool) private hasAdminRights;
    mapping(address => bool) public hasMinted;
    mapping(address => bool) public whitelisted;
    IDEXRouter private router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IBEP20 public constant BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    uint256 public minContribution = 250 * 10**18;
    uint256 public maxContribution = 1000 * 10**18;
    uint256 public totalContributions;
    uint256 public maxTotalContributionAmount = 275_000 * 10**18;
    mapping (uint256 => address) public referrerOf;
    uint256[] public idsWithoutReferrer;
    mapping (uint256 => uint256) public contributionAmountOfId;
    
    modifier onlyOwner() {if(!hasAdminRights[msg.sender]) return; _;}

    event NftMinted(address indexed user, uint256 indexed tokenId, address referrer, uint256 usdAmount);

    constructor() ERC721("ArkPrivateSale", "APS") {
        hasAdminRights[CEO] = true;
        limitlessAddress[CEO] = true;
    }

    receive() external payable {}
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable){super._beforeTokenTransfer(from, to, tokenId);}
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool){return super.supportsInterface(interfaceId);}
    function tokenURI(uint256 tokenId) public view override returns (string memory) {return string(abi.encodePacked(baseURI, tokenId.toString(), _fileExtension));}
    function setBaseUri(string memory uri) external onlyOwner {baseURI = uri;}
	function setFileExtension(string memory ext) external onlyOwner {_fileExtension = ext;}
    function _transfer(address from,address to, uint256 tokenId) internal override{
        if(!limitlessAddress[to]) require(balanceOf(to) == 0, "Max 1 NFT per wallet");
        super._transfer(from,to,tokenId);
    }
    function _mintToken(address _to, uint256 _tokenId) internal returns (uint256) {
        _mint(_to, _tokenId);
        return _tokenId;
    }

    function mint(uint256 contributionAmountInBUSD, address referrer) external {
        require(whitelisted[msg.sender], "This private sale is invite only");
        require(balanceOf(msg.sender) == 0 && !hasMinted[msg.sender], "Only one NFT per wallet");
        require(contributionAmountInBUSD >= minContribution && contributionAmountInBUSD <= maxContribution, "Out of bounds for contributionAmount");
        require(nftsLeft > 0 && totalContributions < maxTotalContributionAmount, "Sold out, sorry. Join the Presale.");
        
        BUSD.transferFrom(msg.sender, address(this), contributionAmountInBUSD);
        totalContributions += contributionAmountInBUSD;
        uint256 idOfMintedNFT = _mintToken(msg.sender, _totalSupply);
        contributionAmountOfId[idOfMintedNFT] = contributionAmountInBUSD;

        _totalSupply++;
        nftsLeft--;
        hasMinted[msg.sender] = true;
        
        if(referrer == msg.sender || referrer == address(0)) {idsWithoutReferrer.push(idOfMintedNFT);} 
        else referrerOf[idOfMintedNFT] = referrer;

        emit NftMinted(msg.sender, idOfMintedNFT, referrerOf[idOfMintedNFT], contributionAmountInBUSD);
    }

    function mintToWallet(address minter, uint256 contributionAmountInBUSD, address referrer) internal {
        require(whitelisted[minter], "This private sale is invite only");
        require(balanceOf(minter) == 0 && !hasMinted[minter], "Only one NFT per wallet");
        require(contributionAmountInBUSD >= minContribution && contributionAmountInBUSD <= maxContribution, "Out of bounds for contributionAmount");
        require(nftsLeft > 0 && totalContributions < maxTotalContributionAmount, "Sold out, sorry. Join the Presale.");
        uint256 idOfMintedNFT = _mintToken(minter, _totalSupply);
        contributionAmountOfId[idOfMintedNFT] = contributionAmountInBUSD;
        totalContributions += contributionAmountInBUSD;
        _totalSupply++;
        nftsLeft--;
        hasMinted[minter] = true;
        if(referrer == minter || referrer == address(0)) {idsWithoutReferrer.push(idOfMintedNFT);} 
        else referrerOf[idOfMintedNFT] = referrer;
        emit NftMinted(minter, idOfMintedNFT, referrerOf[idOfMintedNFT], contributionAmountInBUSD);
    }

    function mintWithAnyToken(address token, uint256 amountInAnyToken, address referrer) external {
        uint256 balanceBefore = BUSD.balanceOf(address(this));
        
        IBEP20(token).transferFrom(msg.sender, address(this), amountInAnyToken);
        IBEP20(token).approve(address(router), type(uint256).max);
        
        address[] memory path = new address[](3);
        path[0] = token;
        path[1] = router.WETH();
        path[2] = address(BUSD);
        
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountInAnyToken,
            0,
            path,
            address(this),
            block.timestamp
        );
        mintToWallet(msg.sender, BUSD.balanceOf(address(this)) - balanceBefore, referrer);
    }

    function mintWithAnyTokenPairedWithBUSD(address token, uint256 amountInAnyToken, address referrer) external {
        uint256 balanceBefore = BUSD.balanceOf(address(this));
        
        IBEP20(token).transferFrom(msg.sender, address(this), amountInAnyToken);
        IBEP20(token).approve(address(router), type(uint256).max);
        
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = address(BUSD);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountInAnyToken,
            0,
            path,
            address(this),
            block.timestamp
        );

        mintToWallet(msg.sender, BUSD.balanceOf(address(this)) - balanceBefore, referrer);
    }

    function mintWithBnb(address referrer) external payable {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BUSD);
        
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );
        mintToWallet(msg.sender, BUSD.balanceOf(address(this)) - balanceBefore, referrer);
    }

    function setLimitlessAddress(address limitlessWallet, bool status) external onlyOwner {
        limitlessAddress[limitlessWallet] = status;
    }

    function setAdminAddress(address adminWallet, bool status) external onlyOwner {
        hasAdminRights[adminWallet] = status;
    }

    function increaseLimitOfNFTs(uint256 howManyMore) external onlyOwner {
        if(nftsLeft + _totalSupply + howManyMore > MAX_NFT_SUPPLY) howManyMore = MAX_NFT_SUPPLY - nftsLeft - _totalSupply;
        nftsLeft += howManyMore;
    }

    function increaseMaxContributionLimit(uint256 howManyMoreBUSD) external onlyOwner {
        maxTotalContributionAmount += howManyMoreBUSD * 10**18;
    }

    function closePrivateSale() external onlyOwner {
        nftsLeft = 0;
        BUSD.transfer(CEO, BUSD.balanceOf(address(this)));
    }

    function addWalletsToWhitelist(address[] calldata wallets) external onlyOwner {
        uint totalWallets = wallets.length;
        for (uint i = 0; i < totalWallets; i++) whitelisted[wallets[i]] = true;
    }

    function airdropToEarlyInvestors(address[] calldata wallets, uint256[] calldata amounts, address guardian) external onlyOwner {
        for (uint i = 0; i < wallets.length; i++) mintToWallet(wallets[i], amounts[i], guardian);
    }

    function assignReferrersToIdsWithoutReferrer(address[] memory referrers) external onlyOwner {
        uint256 rand;
        uint256 i;
        while (idsWithoutReferrer.length > 0 && i < referrers.length) {
            rand = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, idsWithoutReferrer, referrers)));
            rand %= idsWithoutReferrer.length;
            referrerOf[idsWithoutReferrer[rand]] = referrers[i];
            idsWithoutReferrer.pop();
            i++;
        }
    }

    function removeIdWithoutReferrer(uint256 index) internal {
        idsWithoutReferrer[index] = idsWithoutReferrer[idsWithoutReferrer.length - 1];
        idsWithoutReferrer.pop();
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
        BUSD.transferFrom(msg.sender, seller, price);
        idForSale[id] = false;
        removeNftForSale(id);
        _transfer(seller, msg.sender, id);
        emit NftSold(seller, msg.sender, id, price);
    }

    function sell(uint256 id, uint256 price) external {
        require(ownerOf(id) == msg.sender, "Can't transfer a token that is not owned by you");
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

    // emergency functions just in case
    function rescueAnyToken(address tokenToRescue) external onlyOwner {
        IBEP20(tokenToRescue).transfer(msg.sender, IBEP20(tokenToRescue).balanceOf(address(this)));
    }
    
    function collectFunds() external onlyOwner {
        BUSD.transfer(CEO, BUSD.balanceOf(address(this)));
    }

    function rescueBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}