//SPDX-License-Identifier: MIT
// contracts/ERC721.sol
// upgradeable contract

pragma solidity >=0.8.0;

import "./ERC721Upgradeable.sol";
import "./Counters.sol";


interface beans {
    function transferFrom(address src, address dst, uint wad) external returns (bool);
}

interface goose {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

interface nest {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function allNestRun(uint256) external view returns (
        uint256 tokenId,
        address mintedBy,
        address currentOwner,
        uint256 previousPrice,
        uint256 price,
        uint256 numberOfTransfers,
        bool forSale,
        uint forSalLog,
        uint quality
    );
}

contract GoldenEggRunMain is ERC721Upgradeable {
    beans be = beans(0x14cd36e207B79D1848F3A367B55a43035bCC00F5);
    goose ge = goose(0x8E966b5E2987233ecF7De45b47942352ad2E5Cf0);
    nest ne = nest(0x87685e6585CB871E6E8978F7378BB1F61d535f74);
    // define GoldenEgg struct
    struct GoldenEggRun {
        uint256 tokenId;
        address currentOwner;
        uint256 price;
        bool forSale;
        uint forSalLog;
        uint goldenEggAmount;
    }

    struct Research {
        uint256 timeInDays;
        uint256 initBlock; //Block when research started
        bool discovered;
        uint256 tokenId;
        address owner;
    }

    //goose
    mapping(uint256 => Research) public gooseResearchs;
    //nest
    mapping(uint256 => Research) public nestResearchs;


    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // map id to GoldenEgg obj
    mapping(uint256 => GoldenEggRun) public allGoldenEggRun;

    // implement the IERC721Enumerable which no longer come by default in openzeppelin 4.x
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    // Royalty
    address private _owner;
    address private _royaltiesAddr; // royality receiver
    uint256 public royaltyPercentage; // royalty based on sales price
    // NFT Meta data
    string public baseURL;

    event setpriceforsale(uint256 tokenId, uint256 newPrice, bool isForSale);

    event BuyToken(uint256 tokenId);    

    function initialize(
        address _contractOwner,
        address _royaltyReceiver,
        uint256 _royaltyPercentage,
        string memory _baseURL
    ) public initializer {
        __ERC721_init("GOLDENEGG", "GOLDENEGG");
        royaltyPercentage = _royaltyPercentage;
        _owner = _contractOwner;
        _royaltiesAddr = _royaltyReceiver;
        baseURL = _baseURL;
    }

    function changeUrl(string memory url) external {
        require(_msgSender() == _owner, "Only owner");
        baseURL = url;
    }

    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    function setPriceForSale(
        uint256 _newPrice,
        uint256 _goldenEgg
        ) external {
        require(_newPrice > 0);
        require(_goldenEgg > 0);
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(_msgSender(), newItemId);
        //Transfer GoldenEgg eggs to management
        _goldenEggTransferTokens(_msgSender(), _royaltiesAddr, _goldenEgg); 
        GoldenEggRun memory egg = allGoldenEggRun[newItemId];
        egg.tokenId = newItemId;
        egg.currentOwner = _msgSender();
        egg.price = _newPrice;
        egg.forSale = true;
        egg.forSalLog = block.timestamp;
        egg.goldenEggAmount = _goldenEgg;
        allGoldenEggRun[newItemId] = egg;
        emit setpriceforsale(newItemId, _newPrice, true);
    }

    function cancelTheSale(
        uint256 _tokenId
        ) external {
        require(_exists(_tokenId));
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner == _msgSender());
        GoldenEggRun memory egg = allGoldenEggRun[_tokenId];
        require(egg.forSale == true);
        //Transfer GoldenEgg eggs to users
        _goldenEggTransferTokens(_royaltiesAddr, _msgSender(), egg.goldenEggAmount); 
        _transfer(_msgSender(), _royaltiesAddr, _tokenId);
        egg.price = 0;
        egg.forSale = false;
        egg.forSalLog = block.timestamp;
        egg.goldenEggAmount = 0;
        allGoldenEggRun[_tokenId] = egg;
        emit setpriceforsale(_tokenId, egg.price, false);
    }

    //Change the listing price
    function changeTheListingPrice(        
        uint256 _tokenId,
        uint256 _newPrice
        ) external {
        require(_newPrice > 0);
        require(_exists(_tokenId));
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner == _msgSender());
        GoldenEggRun memory egg = allGoldenEggRun[_tokenId];
        require(egg.forSale == true);
        egg.price = _newPrice;
        egg.forSalLog = block.timestamp;
        allGoldenEggRun[_tokenId] = egg;
        emit setpriceforsale(_tokenId, egg.price, true);
    }

    function getAllSaleTokens() public view returns (uint256[] memory) {
        uint256 _totalSupply = totalSupply();
        uint256[] memory _tokenForSales = new uint256[](_totalSupply);
        uint256 counter = 0;
        for (uint256 i = 1; i <= _totalSupply; i++) {
            if (allGoldenEggRun[i].forSale == true) {
                _tokenForSales[counter] = allGoldenEggRun[i].tokenId;
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
        // get that token from all GoldenEggRun mapping and create a memory of it defined as (struct => GoldenEggRun)
        GoldenEggRun memory egg = allGoldenEggRun[_tokenId];
        // token should be for sale
        require(egg.forSale);
        uint256 amount = egg.price;
        uint256 _royaltiesAmount = (amount * royaltyPercentage) / 100;
        uint256 payOwnerAmount = amount - _royaltiesAmount;
        // price sent in to buy should be equal to or more than the token's price
        require(amount >= egg.price);
        //beans deduct royalties
        if (_royaltiesAmount > 0) be.transferFrom(_msgSender(), _royaltiesAddr, _royaltiesAmount);
        //beans to the seller
        if (payOwnerAmount > 0) be.transferFrom(_msgSender(), egg.currentOwner, payOwnerAmount);
        //Manage the transfer of GoldenEgg eggs to buyers
        _goldenEggTransferTokens(_royaltiesAddr, _msgSender(), egg.goldenEggAmount); 
        _transfer(tokenOwner, _msgSender(), _tokenId);
        egg.price = 0;
        egg.forSale = false;
        egg.forSalLog = block.timestamp;
        egg.goldenEggAmount = 0;
        allGoldenEggRun[_tokenId] = egg;
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
        GoldenEggRun memory egg = allGoldenEggRun[tokenId];
        egg.currentOwner = to;
        egg.forSale = false;
        allGoldenEggRun[tokenId] = egg;
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

    //goldenEgg
    uint8 public constant decimals = 18;

    uint public goldenEggTotalSupply = 0;

    mapping(address => mapping (address => uint256)) private _goldenEggAllowance;

    mapping(address => uint) public goldenEggBalanceOf;

    event GoldenEggTransfer(address indexed from, address indexed to, uint amount);
    event GoldenEggApproval(address indexed from, address indexed to, uint amount);

    //TODO
    function goldenEggClaim(address ads, uint egg) external {
        _goldenEggMint(ads, egg * 10 ** uint256(decimals));
        //1000000000000000000
    }


    /**
     * @dev See {approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function goldenEggApprove(address spender, uint256 amount) public virtual returns (bool) {
        _goldenEggApprove(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _goldenEggApprove(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _goldenEggAllowance[owner][spender] = amount;
        emit GoldenEggApproval(owner, spender, amount);
    }


    function _goldenEggMint(address dst, uint amount) internal {
        goldenEggTotalSupply += amount;
        goldenEggBalanceOf[dst] += amount;
        emit GoldenEggTransfer(dst, dst, amount);
    }

    function goldenEggTransfer(address to, uint amount) external returns (bool) {
        _goldenEggTransferTokens(_msgSender(), to, amount);
        return true;
    }

    /**
     * @dev See {transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function goldenEggTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _goldenEggTransferTokens(sender, recipient, amount);

        uint256 currentAllowance = _goldenEggAllowance[sender][_msgSender()];
        require(currentAllowance >= amount, "transfer amount exceeds allowance");
        unchecked {
            _goldenEggApprove(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function _goldenEggTransferTokens(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "transfer from the zero address");
        require(recipient != address(0), "transfer to the zero address");

        goldenEggBalanceOf[sender] -= amount;
        goldenEggBalanceOf[recipient] += amount;
        emit GoldenEggTransfer(sender, recipient, amount);
    }

    function  feedTheBeans(uint256 _gooseTokenId, uint256 _nestTokenId) external {
        require(_msgSender() == ge.ownerOf(_gooseTokenId), "Goose Only owner");
        require(_msgSender() == ne.ownerOf(_nestTokenId), "Nest Only owner");
        (,,,,,,,,uint quality) = ne.allNestRun(_nestTokenId);//nest Common、Rare、Epic
        uint256 timeInDays;
        //(initBlock + timeInDays) < block.timestamp
        require(gooseResearchs[_gooseTokenId].initBlock + gooseResearchs[_gooseTokenId].timeInDays < block.timestamp, "not empty or not discovered yet");
        //If empty or already discovered
        require(nestResearchs[_nestTokenId].timeInDays == 0 || nestResearchs[_nestTokenId].discovered == true, "not empty or not discovered yet");
        if (quality == 1) {
            timeInDays =  1 days;//24h
        } else if (quality == 2) {
            timeInDays =  20 hours;//20h 
        } else if (quality == 3) {
            timeInDays =  16 hours;//16h 
        }
        //timeInDays;  block.timestamp  false _gooseTokenId _msgSender()
        gooseResearchs[_gooseTokenId] = Research(timeInDays, block.timestamp, false, _gooseTokenId, _msgSender());
        nestResearchs[_nestTokenId] = Research(timeInDays, block.timestamp, false, _nestTokenId, _msgSender());
        //deduct 20000$BEANS
        be.transferFrom(_msgSender(), _royaltiesAddr, 20000 * 10 ** uint256(decimals));
    }

    function goldenEgg(uint256 _nestTokenId) external {
        require(_msgSender() == ne.ownerOf(_nestTokenId), "Nest Only owner");
        //already discovered or timeInDays>0
        require(!nestResearchs[_nestTokenId].discovered && nestResearchs[_nestTokenId].timeInDays > 0, "already discovered or not initialized");
        //(initBlock + timeInDays) < block.timestamp
        require(nestResearchs[_nestTokenId].initBlock + nestResearchs[_nestTokenId].timeInDays < block.timestamp, "not finish yet");
        //Golden Egg Reward
        nestResearchs[_nestTokenId].discovered = true;
        _goldenEggMint(_msgSender(), 1 * 10 ** uint256(decimals));
    }

    struct status {
        uint id;
        uint timestamp;
        uint status;
    }

    function nestStatus(uint256 _nestTokenId) public view returns (status memory _nets) {
        _nets.id = _nestTokenId;
        // 1In laying eggs,  2golden eggs can be picked up,  3no eggs are laid
        if (!nestResearchs[_nestTokenId].discovered && nestResearchs[_nestTokenId].timeInDays > 0 && nestResearchs[_nestTokenId].initBlock + nestResearchs[_nestTokenId].timeInDays > block.timestamp) {
            _nets.timestamp = (nestResearchs[_nestTokenId].initBlock + nestResearchs[_nestTokenId].timeInDays ) - block.timestamp;
            _nets.status = 1;
        } else if (!nestResearchs[_nestTokenId].discovered && nestResearchs[_nestTokenId].timeInDays > 0 && nestResearchs[_nestTokenId].initBlock + nestResearchs[_nestTokenId].timeInDays < block.timestamp) {
            _nets.status = 2; 
        } else if (nestResearchs[_nestTokenId].timeInDays == 0 || nestResearchs[_nestTokenId].discovered == true) {
            _nets.status = 3;
        }
    }

    function gooseStatus(uint256 _gooseTokenId) public view returns (status memory _goose) {
        _goose.id = _gooseTokenId;
        // 1to cool, 2to feed
        if (!gooseResearchs[_gooseTokenId].discovered && gooseResearchs[_gooseTokenId].timeInDays > 0 && gooseResearchs[_gooseTokenId].initBlock + gooseResearchs[_gooseTokenId].timeInDays > block.timestamp) {
            _goose.timestamp = (gooseResearchs[_gooseTokenId].initBlock + gooseResearchs[_gooseTokenId].timeInDays ) - block.timestamp;
            _goose.status = 1;
        } else if (gooseResearchs[_gooseTokenId].initBlock + gooseResearchs[_gooseTokenId].timeInDays < block.timestamp) {
            _goose.status = 2; 
        }
    }

}