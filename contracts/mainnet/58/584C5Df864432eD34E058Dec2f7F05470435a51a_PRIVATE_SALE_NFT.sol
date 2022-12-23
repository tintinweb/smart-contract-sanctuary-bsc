/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

/*  
 * PrivateSale NFT Generator
 * 
 * Written by: MrGreenCrypto
 * Co-Founder of CodeCraftrs.com
 * 
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.17;




////////////////////////// IGNORE ALL THAT ////////////////////////////////////////////////
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
////////////////////////// IGNORE EVERYTHING ABOVE THAT ////////////////////////////////////////////////







////////////////////////// Generic presale NFT contract to be used for all the pools ////////////////////////////////////////////////

contract PRIVATE_SALE_NFT is ERC721, ERC721Enumerable {
    using Strings for uint256;
    string private baseURI;
    string private _fileExtension;
    address private CEO;
    uint256 private _totalSupply;
    mapping(address => bool) private hasAdminRights; // can execute admin functions
    mapping(address => bool) public whitelisted;  // can buy NFTs while witelistActive == true
    IDEXRouter private router; // router to swap the different currencies to the main presale currency
    IBEP20 public BUSD; // main presale currency

    uint256 public minContribution; // minimum contribution (250 BUSD)
    uint256 public maxContribution; // maximum contribution (1000 BUSD)
    uint256 public totalContributions; // all funds collected so far (in BUSD)
    uint256 public maxTotalContributionAmount; // hardcap of presale
    uint256 public tokenPerUsd; // presale rate (how many tokens per BUSD will be given to the investors)
    mapping (uint256 => uint256) public contributionAmountOfId; // how much BUSD has been paid for this NFT (mapping NFT ID to BUSD)
    mapping(address => uint256) public totalContributionOfInvestor; // how much BUSD has this investor contributed so far

    bool public whitelistActive = true;  // can only whitelisted people buy?
    uint256 public openingHour = type(uint256).max; // launchtime, in unix time stamp, investors can't buy before that time (will be set in the setOpeningHour function)
    
    modifier onlyOwner() {if(!hasAdminRights[msg.sender]) return; _;} 
 
    event NftMinted(address indexed user, uint256 indexed tokenId, uint256 usdAmount, uint256 tokenAmount); // event to let @crtypt0jan know to create the NFT image

    constructor(address _router, address mainCurrency, uint256 minimum, uint256 maximum, uint256 hardcap, uint256 presaleRate, string memory nameOfPresaleNfts, string memory symbolOfPresaleNfts, address ownerOfPresalePool) ERC721(nameOfPresaleNfts, symbolOfPresaleNfts) {
        router = IDEXRouter(_router); // router to swap the different currencies to the main presale currency
        BUSD = IBEP20(mainCurrency); // main presale currency
        minContribution = minimum; // minimum contribution
        maxContribution = maximum; // maximum contribution
        maxTotalContributionAmount = hardcap; // hardcap of presale
        tokenPerUsd = presaleRate; // presale rate (how many tokens per BUSD will be given to the investors)
        CEO = ownerOfPresalePool;
        hasAdminRights[CEO] = true; // giving the CEO admin rights
    }

    receive() external payable {}
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable){super._beforeTokenTransfer(from, to, tokenId);}
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool){return super.supportsInterface(interfaceId);}
    function tokenURI(uint256 tokenId) public view override returns (string memory) {return string(abi.encodePacked(baseURI, tokenId.toString(), _fileExtension));}
    function setBaseUri(string memory uri) external onlyOwner {baseURI = uri;}
	function setFileExtension(string memory ext) external onlyOwner {_fileExtension = ext;}
    
    function _transfer(address from,address to, uint256 tokenId) internal override {
        super._transfer(from,to,tokenId);
    }

    function _mintToken(address _to, uint256 _tokenId) internal returns (uint256) {
        _mint(_to, _tokenId);
        return _tokenId;
    }

    // buy NFT using the main presale currency
    function mint(uint256 contributionAmountInBUSD) external {
        BUSD.transferFrom(msg.sender, address(this), contributionAmountInBUSD);
        mintToWallet(msg.sender, contributionAmountInBUSD);
    }

    // buy NFT using any currency that has a BNB (native) pair on the router 
    function mintWithAnyToken(address token, uint256 amountInAnyToken) external {
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
        mintToWallet(msg.sender, BUSD.balanceOf(address(this)) - balanceBefore);
    }

    // buy NFT using any currency that has a pair with our main presale currency on the router 
    function mintWithAnyTokenPairedWithBUSD(address token, uint256 amountInAnyToken) external {
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

        mintToWallet(msg.sender, BUSD.balanceOf(address(this)) - balanceBefore);
    }


    // buy NFT using BNB (native)
    function mintWithBnb() external payable {
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
        mintToWallet(msg.sender, BUSD.balanceOf(address(this)) - balanceBefore);
    }

    // internal function that mints the NFT to the investor (is used in all mint functions above)
    function mintToWallet(address minter, uint256 contributionAmountInBUSD) internal {
        require(openingHour < block.timestamp, "Presale not open");
        if(whitelistActive) require(whitelisted[minter], "This private sale is invite only");
        require(totalContributionOfInvestor[minter] + contributionAmountInBUSD <= maxContribution, "Can't exceed max Contribution");
        require(totalContributionOfInvestor[minter] + contributionAmountInBUSD >= minContribution, "Must contribute at least min Contribution");
        require(totalContributions + contributionAmountInBUSD <= maxTotalContributionAmount, "Sold out, sorry.");
        uint256 idOfMintedNFT = _mintToken(minter, _totalSupply);
        contributionAmountOfId[idOfMintedNFT] = contributionAmountInBUSD;
        totalContributionOfInvestor[minter] += contributionAmountInBUSD;
        totalContributions += contributionAmountInBUSD;
        _totalSupply++;
        emit NftMinted(minter, idOfMintedNFT, contributionAmountInBUSD, contributionAmountInBUSD * tokenPerUsd / 10**18);
    }

    // allow someone to call admin functions
    function setAdminAddress(address adminWallet, bool status) external onlyOwner {
        hasAdminRights[adminWallet] = status;
    }

    // increase hardcap
    function increaseMaxContributionLimit(uint256 howManyMoreBUSD) external onlyOwner {
        maxTotalContributionAmount += howManyMoreBUSD * 10**18;
    }

    // add lottery winners to whitelist
    function addWalletsToWhitelist(address[] calldata wallets) external onlyOwner {
        uint totalWallets = wallets.length;
        for (uint i = 0; i < totalWallets; i++) whitelisted[wallets[i]] = true;
    }

    // open the presale to the public (deactivate the whitelist only presale)
    function openToPublic() external onlyOwner {
        whitelistActive = false;
    }

    // define the launch time (unix timestamp when the NFTs can be minted)
    function setOpeningHour(uint256 timeStamp) external onlyOwner {
        openingHour = timeStamp;
    }

    // emergency function to rescue any token that was sent to the contract by mistake
    function rescueAnyToken(address tokenToRescue) external onlyOwner {
        IBEP20(tokenToRescue).transfer(msg.sender, IBEP20(tokenToRescue).balanceOf(address(this)));
    }
    
    // collect all the contributions from the NFT purchases
    function collectFunds() external onlyOwner {
        BUSD.transfer(CEO, BUSD.balanceOf(address(this)));
    }

    // rescue any BNB that were sent to this contract by accident
    function rescueBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Integrated marketplace (not needed in most cases, but it's better to have it and not need it than to need it and not have it)
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
}
////////////////////////// Generic presale NFT contract to be used for all the pools ////////////////////////////////////////////////

contract NftPresalePoolCreator{
    address private CEO;
    mapping(address => bool) private hasAdminRights; // can execute admin functions
    address[] public presaleNftContracts; // list of all presaleNftContracts that have been created using this contract

    modifier onlyOwner() {if(!hasAdminRights[msg.sender]) return; _;} 
 
    event NftPresalePoolCreated(address _router, address mainCurrency, uint256 minimum, uint256 maximum, uint256 hardcap, uint256 presaleRate, string nameOfPresaleNfts, string symbolOfPresaleNfts, address ownerOfPresalePool);

    constructor() {
        hasAdminRights[msg.sender] = true;
    }

    function createNewPresaleNftPool(
        address _router,
        address mainCurrency,
        uint256 minimum,
        uint256 maximum,
        uint256 hardcap,
        uint256 presaleRate,
        string memory nameOfPresaleNfts,
        string memory symbolOfPresaleNfts,
        address ownerOfPresalePool
    ) external onlyOwner {
        presaleNftContracts.push(
            address(
                new PRIVATE_SALE_NFT(
                    _router,
                    mainCurrency,
                    minimum,
                    maximum,
                    hardcap,
                    presaleRate,
                    nameOfPresaleNfts,
                    symbolOfPresaleNfts,
                    ownerOfPresalePool
                )
            )
        ); 
    }

    // allow someone to call admin functions
    function setAdminAddress(address adminWallet, bool status) external onlyOwner {
        hasAdminRights[adminWallet] = status;
    }
}