//SPDX-License-Identifier: MIT
// contracts/ERC721.sol
// upgradeable contract

pragma solidity >=0.8.0;

import "./ERC721Upgradeable.sol";
import "./Counters.sol";


interface bean {
    function transferFrom(address src, address dst, uint wad) external returns (bool);
}

interface egg {
    function goldenEggTransferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract LandRunMain is ERC721Upgradeable {
    bean be = bean(0x79209967d6D90836D85fa10c07fD640d03165767);
    egg eg = egg(0xD027F342d3FE984ee62A878F2f966F99413021C5);

    // define Land struct
    struct LandRun {
        uint256 tokenId;
        address mintedBy;
        address currentOwner;
        uint256 previousPrice;
        uint256 price;
        uint256 numberOfTransfers;
        bool forSale;
        uint forSalLog;
        uint quality;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // map id to Land obj
    mapping(uint256 => LandRun) public allLandRun;

    //  implement the IERC721Enumerable which no longer come by default in openzeppelin 4.x
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    uint public land1_count;//White
    uint public land2_count;//Red
    uint public land3_count;//black
    uint256 public constant maxSupply = 10000;

    uint8 public constant decimals = 18;

    // Royalty
    address private _owner;
    address private _royaltiesAddr; // royality receiver
    uint256 public royaltyPercentage; // royalty based on sales price
    // cost to mint
    uint256 public mintFeeAmount = 100 * 10 ** uint256(decimals);
    // enable flag for public
    bool public openForPublic;
    // NFT Meta data
    string public baseURL;

    //land 1Common 2Rare 3Epic
    uint[10] private quality = [
        11,
        11,
        12,
        11,
        11,
        13,
        11,
        11,
        12,
        11
    ];

    event setpriceforsale(uint256 tokenId, uint256 newPrice, bool isForSale);

    event Mint(uint256[]  tokenIds);

    event BuyToken(uint256 tokenId);    

    function initialize(
        address _contractOwner,
        address _royaltyReceiver,
        uint256 _royaltyPercentage,
        string memory _baseURL,
        bool _openForPublic
    ) public initializer {
        __ERC721_init("LAND", "LAND");
        royaltyPercentage = _royaltyPercentage;
        _owner = _contractOwner;
        _royaltiesAddr = _royaltyReceiver;
        baseURL = _baseURL;
        openForPublic = _openForPublic;
    }

    function toggleOpenForPublic(bool status) external {
        require(_msgSender() == _owner, "Only owner");
        openForPublic = status;
    }

    function _landRun(uint256 newItemId, address toAddress) private {
        uint rand = uint(keccak256(abi.encodePacked(newItemId)));
        uint random = quality[rand % quality.length];
        uint qua;
        if (land3_count < 1000 && random == 13) {
            land3_count++;
            qua = 3;
        }else if (land2_count < 2000 && random == 12) {
            land2_count++;
            qua = 2;                
        }else if (land1_count < 7000 && random == 11) {
            land1_count++;
            qua = 1;          
        }else if (land3_count < 1000) {
            land3_count++;  
            qua = 3;          
        }else if (land2_count < 2000) {
            land2_count++;
            qua = 2;               
        }else if (land1_count < 7000) {
            land1_count++;
            qua = 1;           
        }
        LandRun memory newLandRun = LandRun(
            newItemId,
            _msgSender(),
            toAddress,
            0,
            mintFeeAmount,
            0,
            false,
            0,
            qua
            );
        // add the token id to the allLandRun
        allLandRun[newItemId] = newLandRun;           
        _safeMint(_msgSender(), newItemId);
    }

    function mint(uint256 numberOfToken) external {
        // check if thic fucntion caller is not an zero address account
        require(openForPublic == true, "not open");
        require(_msgSender() != address(0));
        require(
            _allTokens.length + numberOfToken <= maxSupply,
            "max supply"
        );
        require(numberOfToken > 0, "Min 1");
        require(numberOfToken <= 100, "Max 100");
        uint256 totalBeansCost = 0;
        uint256[] memory tokenIds = new uint[](numberOfToken);
        for (uint256 i = 1; i <= numberOfToken; i++) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            address toAddress = _msgSender();
            totalBeansCost += mintFeeAmount;
            _landRun(newItemId, toAddress);
            tokenIds[i-1]=newItemId;
        }   
        if (totalBeansCost > 0)  eg.goldenEggTransferFrom(_msgSender(), address(this), totalBeansCost); 
        emit Mint(tokenIds);    
    }


    function changeUrl(string memory url) external {
        require(_msgSender() == _owner, "Only owner");
        baseURL = url;
    }

    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    // allow airdrop token to address
    function airdropTokens(uint256 numberOfToken, address toAddress) external {
        require(_msgSender() == _owner, "Only owner");
        require(
            numberOfToken + _allTokens.length < maxSupply,
            "Max supply"
        );
        uint256[] memory tokenIds = new uint[](numberOfToken);
        for (uint256 i = 1; i <= numberOfToken; i++) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();         
            _landRun(newItemId, toAddress);
            tokenIds[i-1]=newItemId;
        }
        emit Mint(tokenIds);
    }

    function setPriceForSale(
        uint256 _tokenId,
        uint256 _newPrice,
        bool isForSale
    ) external {
        require(_exists(_tokenId));
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner == _msgSender());
        require(_newPrice > 0);
        LandRun memory land = allLandRun[_tokenId];
        land.price = _newPrice;
        land.forSale = isForSale;
        land.forSalLog = block.timestamp;
        allLandRun[_tokenId] = land;
        emit setpriceforsale(_tokenId, _newPrice, isForSale);
    }

    function getAllSaleTokens() public view returns (uint256[] memory) {
        uint256 _totalSupply = totalSupply();
        uint256[] memory _tokenForSales = new uint256[](_totalSupply);
        uint256 counter = 0;
        for (uint256 i = 1; i <= _totalSupply; i++) {
            if (allLandRun[i].forSale == true) {
                _tokenForSales[counter] = allLandRun[i].tokenId;
                counter++;
            }
        }
        return _tokenForSales;
    }


    // by a token by passing in the token's id
    function buyToken(uint256 _tokenId) public {
        // check if the token id of the token being bought exists or not
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // token's owner should not be an zero address account
        require(tokenOwner != address(0));
        // the one who wants to buy the token should not be the token's owner
        require(tokenOwner != _msgSender());
        // get that token from all LandRun mapping and create a memory of it defined as (struct => LandRun)
        LandRun memory land = allLandRun[_tokenId];
        // token should be for sale
        require(land.forSale);
        uint256 amount = land.price;
        uint256 _royaltiesAmount = (amount * royaltyPercentage) / 100;
        uint256 payOwnerAmount = amount - _royaltiesAmount;
        // price sent in to buy should be equal to or more than the token's price
        require(amount >= land.price);
        //beans to the seller
        if (_royaltiesAmount > 0) be.transferFrom(_msgSender(), _royaltiesAddr, _royaltiesAmount);
        //Manage the transfer of golden eggs to buyers
        if (payOwnerAmount > 0) be.transferFrom(_msgSender(), land.currentOwner, payOwnerAmount);
        land.previousPrice = land.price;
        allLandRun[_tokenId] = land;
        _transfer(tokenOwner, _msgSender(), _tokenId);
        emit BuyToken(_tokenId);
    }    

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        returns (uint256)
    {
        require(index < balanceOf(owner), "out of bounds");
        return _ownedTokens[owner][index];
    }

    //  URI Storage override functions
    /** Overrides ERC-721's _baseURI function */
    function _baseURI()
        internal
        view
        virtual
        override(ERC721Upgradeable)
        returns (string memory)
    {
        return baseURL;
    }

    function _burn(uint256 tokenId) internal override(ERC721Upgradeable) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Upgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
        LandRun memory land = allLandRun[tokenId];
        land.currentOwner = to;
        land.numberOfTransfers += 1;
        land.forSale = false;
        allLandRun[tokenId] = land;
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
        uint256 length = balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
        private
    {
        uint256 lastTokenIndex = balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }


}