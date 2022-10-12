/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

/*  
 * CrazyApez3D
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

interface ICCVRF{
    function requestRandomness(uint256 requestID, uint256 howManyNumbers) external payable;
}

interface I2D{
    function getBestTierOfHolder(address holder) external view returns (uint256);
}

interface IDEXRouter {
    function WETH() external pure returns (address);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;
}

contract CrazyApez3D is ERC721, ERC721Enumerable {
    using Strings for uint256;
    string private baseURI = "https://api.crazyapez.com/nft/3d/";
    string private _fileExtension;
    uint256 private _nonce;
    address private _admin;
    uint256 public constant MAX_NFT_SUPPLY = 18552;
    uint256 public batchSize = 1288;
    uint256 public alreadyMinted = 0;
    uint256 private _mintsStarted;
    uint256 public pendingCount = batchSize;
    uint256 private _totalSupply;
    uint256[MAX_NFT_SUPPLY+1] private _pendingIds;
    mapping(uint256 => address) minterAtNonce;
    mapping(uint256 => bool) nonceFulfilled;
    mapping(address => bool) public limitlessAddress;
    mapping(address => bool) private hasAdminRights;
    mapping(address => bool) private isPlatform;
    mapping(address => bool) private isChainLink;
    IDEXRouter private router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    ICCVRF public randomnessSupplier = ICCVRF(0xC0de0aB6E25cc34FB26dE4617313ca559f78C0dE);
    I2D public free2d = I2D(0x88880FE6B31c9a25C1c91C183aB879EdE59f6969);
    uint256 public vrfCost = 0.002 ether;

    uint256 public mintPriceBnb = 0.2 ether;
    mapping(uint256 => address) public minters;
    uint256 private prizePoolWon;
    bool public mintEnabled;
    bool public lotteryFinished;
    mapping (address => address) public referrerOf;
    mapping (address => uint256) public referralsTotal;
    uint256 public dailyPrizePool;
    uint256 public dailyPrizePoolMax = 12 ether; 
    bool public dailyPrizePoolFull;
    uint256 public lastDailyJackpot;
    uint256 public dailyPrizeAmount = 100 ether;
    uint256[] public bananaJackpots;
    uint256[] public bananaMilestones;
    bool public theresStillSomeJackpotLeftInTheEnd;
    uint256 public carryOverPriceMoney;
    uint256 private bnbToDivide;

    uint256 private totalTickets;
    uint256[] public addedTickets;
    uint256[] public idTicketIndex;
    address[] public poolGlass;
    address[] public poolSilver;
    address[] public poolGold;
    mapping(address => bool) public isInPoolGlass;
    mapping(address => bool) public isInPoolSilver;
    mapping(address => bool) public isInPoolGold;
    
    modifier onlyVRF() {if(msg.sender != address(randomnessSupplier)) return; _;}
    modifier onlyOwner() {if(!hasAdminRights[msg.sender]) return; _;}
    modifier onlyChainLink() {if(!isChainLink[msg.sender]) return; _;}
    
    
    event NftMinted(address indexed user, uint256 indexed tokenId);
    event BananaWinner(address winner, uint256 amountInUsd, uint256 timestamp);
    event DailyWinner(address winner, uint256 timestamp);
    event KongWinners(address[] kongWinners);

    constructor(address admin_, string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        _admin = admin_;
        hasAdminRights[_admin] = true;
        limitlessAddress[_admin] = true;
        bananaJackpots.push(7777);
        bananaJackpots.push(5777);
        bananaJackpots.push(3777);
        bananaJackpots.push(1777);
        bananaJackpots.push(777);
        bananaJackpots.push(0);
        bananaJackpots.push(377);
        bananaJackpots.push(0);
    }

    receive() external payable {
        bnbToDivide += msg.value;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable){super._beforeTokenTransfer(from, to, tokenId);}
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool){return super.supportsInterface(interfaceId);}

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, tokenId.toString(), _fileExtension));
    }
    
    function setBaseUri(string memory uri) external onlyOwner {
        baseURI = uri;
    }

	function setFileExtension(string memory ext) external onlyOwner {
        _fileExtension = ext;
    }
    function _transfer(address from,address to, uint256 tokenId) internal override{
        super._transfer(from,to,tokenId);
        if(balanceOf(to) > 23) addToPools(to);
    }

    function _mintToken(address _to, uint256 _tokenId) internal returns (uint256) {
        _mint(_to, _tokenId);
        if(balanceOf(_to) > 23) addToPools(_to);
        return _tokenId;
    }

    function _popPendingAtIndex(uint256 _index) internal returns (uint256) {
        uint256 tokenId = _pendingIds[_index] + _index;
        if (_index != pendingCount+alreadyMinted) _pendingIds[_index] = _pendingIds[pendingCount+alreadyMinted] + pendingCount + alreadyMinted - _index;
        pendingCount--;
        return tokenId;
    }

    function mint(uint256 numberOfNfts, address referrer) external payable{
        require(numberOfNfts > 0 && numberOfNfts <= 48, "Can only mint 1 to 48 NFTs in one transaction");

        uint256 price = mintPriceBnb * numberOfNfts;
        require(msg.value >= price, "msg.value too low");

        numberOfNfts += numberOfNfts / 6;

        if(_mintsStarted + numberOfNfts > batchSize) {
            numberOfNfts = batchSize - _mintsStarted;
            uint256 freeMints;
            if(numberOfNfts/7>0) freeMints = numberOfNfts/7;
            price = (numberOfNfts - freeMints) * mintPriceBnb;
            payable(msg.sender).transfer(msg.value - price);
        }

        for(uint i = 0; i < numberOfNfts; i++) {
            minterAtNonce[_nonce] = msg.sender;
            _mintsStarted++;
            if(_mintsStarted == batchSize / 2 || _mintsStarted == batchSize){
                randomnessSupplier.requestRandomness{value: vrfCost}(_nonce, 2);
            } else {
                randomnessSupplier.requestRandomness{value: vrfCost}(_nonce, 1);
            }          
            _nonce++;
        }
        bnbToDivide += price;
        
        if(referrer == msg.sender) referrer = address(0);
        if(referrerOf[msg.sender] != address(0)) referrer = referrerOf[msg.sender];
        else referrerOf[msg.sender] = referrer;

        if(referrer != address(0)) {
            payable(referrer).transfer(price * 7 / 100);
            referralsTotal[referrer] += price / mintPriceBnb;
        }

        if(referrerOf[referrer] != address(0)) payable(referrerOf[referrer]).transfer(price * 3 / 100);

        if(dailyPrizePool < dailyPrizePoolMax && !dailyPrizePoolFull) dailyPrizePool += price / 20;
        else dailyPrizePoolFull = true;
    }

    function mintFromAnotherChain(address minter, uint256 qty, address referrer) external onlyOwner{
        require(qty > 0, "numberOfNfts cannot be 0");

        uint256 price = mintPriceBnb * qty;
        qty += qty/6;

        if(_mintsStarted + qty > batchSize) {
            qty = batchSize - _mintsStarted;
            uint256 freeMints;
            uint256 refundBnb;
            if(qty/7>0) freeMints = qty/7;
            refundBnb = price - ((qty - freeMints) * mintPriceBnb);
            price = (qty - freeMints) * mintPriceBnb;
            payable(msg.sender).transfer(refundBnb);
        }

        for (uint i = 0; i < qty; i++) {
            minterAtNonce[_nonce] = minter;
             _mintsStarted++;
            if(_mintsStarted == batchSize / 2 || _mintsStarted == batchSize){
                randomnessSupplier.requestRandomness{value: vrfCost}(_nonce, 2);
            } else {
                randomnessSupplier.requestRandomness{value: vrfCost}(_nonce, 1);
            }          
            _nonce++;
        }
        
        if(referrerOf[minter] != address(0)) referrer = referrerOf[minter];
        else referrerOf[minter] = referrer;

        if(referrer != address(0)) {
            payable(referrer).transfer(price * 7 / 100);
            referralsTotal[referrer] += price / mintPriceBnb;
        }

        if(referrerOf[referrer] != address(0)) payable(referrerOf[referrer]).transfer(price * 3 / 100);
        
        if(dailyPrizePool < dailyPrizePoolMax && !dailyPrizePoolFull) dailyPrizePool += price / 20;
        else dailyPrizePoolFull = true;
    }

    function drawCrazyDailyWinner() external onlyOwner {
        randomnessSupplier.requestRandomness{value: vrfCost}(_nonce, 1);
        lastDailyJackpot = block.timestamp;
        _nonce++;
    }

    function dailyCrazyDrawPoweredByChainLinkAutomation() external onlyChainLink {
        require(dailyPrizePoolFull, "DailyCrazyLottery only starts when the PrizePool is full");
        require(block.timestamp - lastDailyJackpot > 23 hours, "Can only run once a day"); 
        randomnessSupplier.requestRandomness{value: vrfCost}(_nonce, 1);
        lastDailyJackpot = block.timestamp;
       _nonce++;
   }

    function drawKongWinners() external onlyOwner {
        randomnessSupplier.requestRandomness{value: vrfCost}(_nonce, 6);
        _nonce++;
    }

    function drawBananaJackpotIfTheresStillLeftAfterLastJackpot() external onlyOwner {
        require(theresStillSomeJackpotLeftInTheEnd, "Can only call this if there's money left in the jackpot");
        randomnessSupplier.requestRandomness{value: vrfCost}(_nonce, 2);
        _nonce++;
    }

    function manuallyTopUpDailyPrizePool() external payable {
        dailyPrizePool += msg.value;
    }

    function automaticallyTopUpDailyPrizePool(uint256 topUpAmount) external onlyOwner {
        dailyPrizePool += topUpAmount;
    }

    function reactivateDailyPricePoolAutoFill(uint256 maxLimit) external onlyOwner {
        dailyPrizePoolFull = false;
        dailyPrizePoolMax = maxLimit * 1 ether;
    }

    function supplyRandomness(uint256 nonce, uint256[] memory randomNumbers) external onlyVRF {
        if(nonceFulfilled[nonce]) return;
        nonceFulfilled[nonce] = true;
        if(minterAtNonce[nonce] == address(0)){
            if(randomNumbers.length == 1){
                uint256 bnbAmount = busdToBnb(dailyPrizeAmount);
                address dailyWinner = getARandomWinner(randomNumbers[0]);
                payable(dailyWinner).transfer(bnbAmount);
                dailyPrizePool -= bnbAmount;
                emit DailyWinner(dailyWinner, block.timestamp);
                return;               
            } else if(randomNumbers.length == 6) {
                address[] memory kongWinners = new address[](6);
                for(uint256 i = 0; i<6; i++){
                    if(i<3) kongWinners[i] = poolGlass[randomNumbers[i] % poolGlass.length];
                    else if(i<5) kongWinners[i] = poolSilver[randomNumbers[i] % poolSilver.length];
                    else if(i<6) kongWinners[i] = poolGold[randomNumbers[i] % poolGold.length];
                }
                emit KongWinners(kongWinners);
                return;
            } else if(randomNumbers.length == 2){
                address bananaWinner = getARandomBananaWinner(randomNumbers[1]);
                uint256 bnbAmount = carryOverPriceMoney;
                carryOverPriceMoney = 0;
                uint256 divisorOfWinner = getDivisorOfHolder(bananaWinner);
                uint256 paidPrizeMoney = bnbAmount/divisorOfWinner;
                payable(bananaWinner).transfer(paidPrizeMoney);
                if(divisorOfWinner > 1) {
                    carryOverPriceMoney = bnbAmount - paidPrizeMoney;
                } else { 
                    theresStillSomeJackpotLeftInTheEnd = false;
                }
                emit BananaWinner(bananaWinner, paidPrizeMoney, block.timestamp);
                return;
            }

        } else {
            address _to = minterAtNonce[nonce];
            uint256 index = (randomNumbers[0] % pendingCount) + 1 + alreadyMinted;
            uint256 tokenId = _popPendingAtIndex(index);
            _totalSupply++;
            _mintToken(_to, tokenId);
            addTicketsToList(tokenId);
            emit NftMinted(_to, tokenId);
        }

        if(randomNumbers.length == 2) {
            address bananaWinner = getARandomBananaWinner(randomNumbers[1]);
            uint256 bnbAmount = busdToBnb(bananaJackpots[bananaJackpots.length - 1]);
            bnbAmount += carryOverPriceMoney;
            if(bnbAmount == 0) return;
            carryOverPriceMoney = 0;
            uint256 divisorOfWinner = getDivisorOfHolder(bananaWinner);
            uint256 paidPrizeMoney = bnbAmount/divisorOfWinner;
            payable(bananaWinner).transfer(paidPrizeMoney);
            bananaJackpots.pop();
            if(divisorOfWinner > 1) {
                if(bananaJackpots.length == 0) {
                    bananaJackpots.push(0);
                    theresStillSomeJackpotLeftInTheEnd = true;
                }
                carryOverPriceMoney = bnbAmount - paidPrizeMoney;
            }
            emit BananaWinner(bananaWinner, paidPrizeMoney, block.timestamp);
        }
    }

    function addToPools(address wallet) internal {
        uint256 walletBalance = balanceOf(wallet);
        if(isPlatform[wallet]) return;
        if(walletBalance > 23 && !isInPoolGlass[wallet]){
            isInPoolGlass[wallet] = true;
            poolGlass.push(wallet);
        }
        if(walletBalance > 35 && !isInPoolSilver[wallet]){
            isInPoolSilver[wallet] = true;
            poolSilver.push(wallet);
        }
        if(walletBalance > 47 && !isInPoolGold[wallet]){
            isInPoolGold[wallet] = true;
            poolGold.push(wallet);
        }
    }

    function getARandomBananaWinner(uint256 randomNumber) internal view returns(address) {
        address winningAddress = ownerOf(idTicketIndex[randomNumber % (idTicketIndex.length)]);
        return winningAddress;
    }

    function getARandomWinner(uint256 randomNumber) internal view returns(address) {
        address winningAddress = ownerOf(idTicketIndex[findIdOfWinningTicket(randomNumber % totalTickets)]);
        return winningAddress;
    }

    function findIdOfWinningTicket(uint256 winningTicket) internal view returns(uint256) {
        uint256 low;
        uint256 high = addedTickets.length;

        while(low < high) {
            uint256 mid = (low & high) + (low ^ high) / 2;
            if(addedTickets[mid] > winningTicket) high = mid;
            else low = mid + 1;
        }

        if(low > 0 && addedTickets[low-1] == winningTicket) return low - 1;
        else return low;
    }

    function addTicketsToList(uint256 id) internal {
        totalTickets += getTicketsOfId(id);
        addedTickets.push(totalTickets);
        idTicketIndex.push(id);
    }

    function registerBridgedNftForLotteries(uint256 id) external {
        require(ownerOf(id) == msg.sender && !isPlatform[ownerOf(id)], "Can only register your NFT if you are the owner and you're not a platform");
        bool alreadyRegistered;
        for(uint256 i = 0; i<idTicketIndex.length; i++){
            if(idTicketIndex[i] == id) alreadyRegistered = true;
        }
        require(!alreadyRegistered, "Don't try to cheat");
        addTicketsToList(id);
    }

    function busdToBnb(uint256 busdAmount) public view returns (uint256) {
        address[] memory pathFromBUSDToBNB = new address[](2);
        pathFromBUSDToBNB[0] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        pathFromBUSDToBNB[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        return router.getAmountsOut(busdAmount, pathFromBUSDToBNB)[1];
    }

    function getDivisorOfHolder(address holder) public view returns (uint256) {
        return free2d.getBestTierOfHolder(holder);
    }

    function getTicketsOfId(uint256 id) public pure returns(uint256) {
        uint256 rank = id % 100;
        if(rank > 50 || rank == 0) return 1;
        if(rank > 25) return 2;
        if(rank > 5) return 5;
        return 20;
    }

    function setVrfCost(uint256 value) external onlyOwner {
        vrfCost = value;
    }

    function setLimitlessAddress(address limitlessWallet, bool status) external onlyOwner {
        limitlessAddress[limitlessWallet] = status;
    }

    function setAdminAddress(address adminWallet, bool status) external onlyOwner {
        hasAdminRights[adminWallet] = status;
    }

    function setPlatformAddress(address platformWallet, bool status) external onlyOwner {
        isPlatform[platformWallet] = status;
    }

    function setChainLinkAddress(address chainLinkWallet, bool status) external onlyOwner {
        isChainLink[chainLinkWallet] = status;
    }

    function setBatch(uint256 _alreadyMinted, uint256  _batchSize) external onlyOwner {
        batchSize = _batchSize;
        alreadyMinted = _alreadyMinted;
        pendingCount = batchSize;
        _mintsStarted = 0;
    }

    // admin functions to be used by the bridge
    function batchMintToWallets(address[] calldata wallets, uint256[] calldata ids) external onlyOwner {
        for (uint i = 0; i < wallets.length; i++) _mint(wallets[i], ids[i]);
    }

    function mintToWallet(address wallet, uint256 id) external onlyOwner {
        _mint(wallet, id);
    }

    // Integrated marketplace, just in case
    uint256[] public nftsForSale;
    mapping (uint256 => bool) public idForSale;
    mapping (uint256 => uint256) public priceOfId;
    mapping(uint256 => uint256) private nftForSaleIndexes; 
    uint256 public taxForMarketplace = 3;   
    event NftOffered(address seller, uint256 id, uint256 price);
    event NftSold(address seller, address buyer, uint256 id, uint256 price);

    function buy(uint256 id) external payable {
        address seller = ownerOf(id);
        uint256 price = priceOfId[id];
        require(msg.value >= price, "Pay the price please");
        require(idForSale[id], "Can only buy listed NFTs");
        idForSale[id] = false;
        removeNftForSale(id);
        payable(seller).transfer(price * (100-taxForMarketplace) / 100);
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
    
    function addNftForSale(uint256 _nftForSale) internal {
        nftForSaleIndexes[_nftForSale] = nftsForSale.length;
        nftsForSale.push(_nftForSale);
    }

    function removeNftForSale(uint256 _nftForSale) internal {
        nftsForSale[nftForSaleIndexes[_nftForSale]] = nftsForSale[nftsForSale.length - 1];
        nftForSaleIndexes[nftsForSale[nftsForSale.length - 1]] = nftForSaleIndexes[_nftForSale];
        nftsForSale.pop();
    }


    //////////////// Team Salary section ////////////////////
    address private teamMember1 = 0x04B5294925279a0D0218a3D401dE01b6cb1d7f19;
    address private teamMember2 = 0xc43E6f8EaD35172E4df9f73E7Fc00238Bd401992;
    address private teamMember3 = 0x1Bef63ba031d8aD924D2a98f1a1225a9A5a150a5;
    address private teamMember4 = 0xc0de2d009aa6b2F37469902D860fa64ca4DCc0DE;
    address private teamMember5 = 0x22a65db6e25073305484989aE55aFf0687E68566;
    
    uint256 private dividendShare1 = 20;
    uint256 private dividendShare2 = 15;
    uint256 private dividendShare3 = 10;
    uint256 private dividendShare4 = 18;

    uint256 private dividendStep1 = 5000 * mintPriceBnb * dividendShare1 / 1000;
    uint256 private dividendStep2 = dividendStep1 + (5000 * mintPriceBnb * dividendShare2 / 1000);

    uint256 private fixedAmount = 2300 ether;
    uint256 private totalBnbRaised;
    uint256 private dividendsPaidSoFar;

    function bnbToBusd(uint256 bnbAmount) internal view returns (uint256) {
        address[] memory pathFromBNBToBUSD = new address[](2);
        pathFromBNBToBUSD[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        pathFromBNBToBUSD[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        return router.getAmountsOut(bnbAmount, pathFromBNBToBUSD)[1];
    }

    function sendSalaryToTeam() external {
        if(bnbToDivide == 0) return;
        totalBnbRaised += bnbToDivide;
        uint256 fractionOfBnbToDivide = bnbToDivide / 1000;
        uint256 bnbValueEqualToFixedAmount;
        if(fixedAmount > 1 ether){
            bnbValueEqualToFixedAmount = busdToBnb(fixedAmount);
        }
        
        if(dividendsPaidSoFar < dividendStep1) {
            dividendsPaidSoFar += fractionOfBnbToDivide * dividendShare1;
            payable(teamMember1).transfer(fractionOfBnbToDivide * dividendShare1);
            payable(teamMember2).transfer(fractionOfBnbToDivide * dividendShare1);
            payable(teamMember3).transfer(fractionOfBnbToDivide * dividendShare1);
            payable(teamMember4).transfer(fractionOfBnbToDivide * (dividendShare1 + dividendShare4));
        } else if(dividendsPaidSoFar < dividendStep2) {
            dividendsPaidSoFar += fractionOfBnbToDivide * dividendShare2;
            payable(teamMember1).transfer(fractionOfBnbToDivide * dividendShare2);
            payable(teamMember2).transfer(fractionOfBnbToDivide * dividendShare2);
            payable(teamMember3).transfer(fractionOfBnbToDivide * dividendShare2);
            payable(teamMember4).transfer(fractionOfBnbToDivide * (dividendShare2 + dividendShare4));
        } else {
            payable(teamMember1).transfer(fractionOfBnbToDivide * dividendShare3);
            payable(teamMember2).transfer(fractionOfBnbToDivide * dividendShare3);
            payable(teamMember3).transfer(fractionOfBnbToDivide * dividendShare3);
            payable(teamMember4).transfer(fractionOfBnbToDivide * (dividendShare3 + dividendShare4));   
        }

        if(bnbValueEqualToFixedAmount > 0) {
            if(address(this).balance > bnbValueEqualToFixedAmount + 1 ether) {
                payable(teamMember5).transfer(bnbValueEqualToFixedAmount);
                fixedAmount = 0;
            } else if(address(this).balance > 1 ether) {
                uint256 paidAmount = address(this).balance - 1 ether;
                payable(teamMember5).transfer(paidAmount);     
                fixedAmount -= bnbToBusd(paidAmount);
            }
        }
        bnbToDivide = 0;
    }

    function sendSalaryToTeamAndSomeToProject(uint256 amountToBeSentToProject) external onlyOwner{
        if(bnbToDivide == 0) return;
        totalBnbRaised += bnbToDivide;
        uint256 fractionOfBnbToDivide = bnbToDivide / 1000;
        uint256 bnbValueEqualToFixedAmount;
        if(fixedAmount > 1 ether){
            bnbValueEqualToFixedAmount = busdToBnb(fixedAmount);
        }
        
        if(dividendsPaidSoFar < dividendStep1) {
            dividendsPaidSoFar += fractionOfBnbToDivide * dividendShare1;
            payable(teamMember1).transfer(fractionOfBnbToDivide * dividendShare1);
            payable(teamMember2).transfer(fractionOfBnbToDivide * dividendShare1);
            payable(teamMember3).transfer(fractionOfBnbToDivide * dividendShare1);
            payable(teamMember4).transfer(fractionOfBnbToDivide * (dividendShare1 + dividendShare4));
        } else if(dividendsPaidSoFar < dividendStep2) {
            dividendsPaidSoFar += fractionOfBnbToDivide * dividendShare2;
            payable(teamMember1).transfer(fractionOfBnbToDivide * dividendShare2);
            payable(teamMember2).transfer(fractionOfBnbToDivide * dividendShare2);
            payable(teamMember3).transfer(fractionOfBnbToDivide * dividendShare2);
            payable(teamMember4).transfer(fractionOfBnbToDivide * (dividendShare2 + dividendShare4));
        } else {
            payable(teamMember1).transfer(fractionOfBnbToDivide * dividendShare3);
            payable(teamMember2).transfer(fractionOfBnbToDivide * dividendShare3);
            payable(teamMember3).transfer(fractionOfBnbToDivide * dividendShare3);
            payable(teamMember4).transfer(fractionOfBnbToDivide * (dividendShare3 + dividendShare4));   
        }

        if(bnbValueEqualToFixedAmount > 0) {
            if(address(this).balance > bnbValueEqualToFixedAmount + 1 ether) {
                payable(teamMember5).transfer(bnbValueEqualToFixedAmount);
                fixedAmount = 0;
            } else if(address(this).balance > 1 ether) {
                uint256 paidAmount = address(this).balance - 1 ether;
                payable(teamMember5).transfer(paidAmount);     
                fixedAmount -= bnbToBusd(paidAmount);
            }
        }
        bnbToDivide = 0;

        if(address(this).balance > amountToBeSentToProject + 1 ether) {
                payable(_admin).transfer(amountToBeSentToProject);
        } else if(address(this).balance > 1 ether) {
                uint256 paidAmount = address(this).balance - 1 ether;
                payable(_admin).transfer(paidAmount);
            }
    }

    function withdrawAllFundsAfterMintIsClosed() external onlyOwner{
        if(bnbToDivide != 0) {
            totalBnbRaised += bnbToDivide;
            uint256 fractionOfBnbToDivide = bnbToDivide / 1000;
            uint256 bnbValueEqualToFixedAmount;
            if(fixedAmount > 1 ether){
                bnbValueEqualToFixedAmount = busdToBnb(fixedAmount);
            }

            if(dividendsPaidSoFar < dividendStep1) {
                dividendsPaidSoFar += fractionOfBnbToDivide * dividendShare1;
                payable(teamMember1).transfer(fractionOfBnbToDivide * dividendShare1);
                payable(teamMember2).transfer(fractionOfBnbToDivide * dividendShare1);
                payable(teamMember3).transfer(fractionOfBnbToDivide * dividendShare1);
                payable(teamMember4).transfer(fractionOfBnbToDivide * (dividendShare1 + dividendShare4));
            } else if(dividendsPaidSoFar < dividendStep2) {
                dividendsPaidSoFar += fractionOfBnbToDivide * dividendShare2;
                payable(teamMember1).transfer(fractionOfBnbToDivide * dividendShare2);
                payable(teamMember2).transfer(fractionOfBnbToDivide * dividendShare2);
                payable(teamMember3).transfer(fractionOfBnbToDivide * dividendShare2);
                payable(teamMember4).transfer(fractionOfBnbToDivide * (dividendShare2 + dividendShare4));
            } else {
                payable(teamMember1).transfer(fractionOfBnbToDivide * dividendShare3);
                payable(teamMember2).transfer(fractionOfBnbToDivide * dividendShare3);
                payable(teamMember3).transfer(fractionOfBnbToDivide * dividendShare3);
                payable(teamMember4).transfer(fractionOfBnbToDivide * (dividendShare3 + dividendShare4));   
            }

            if(bnbValueEqualToFixedAmount > 0) {
                if(address(this).balance > bnbValueEqualToFixedAmount + 1 ether) {
                    payable(teamMember5).transfer(bnbValueEqualToFixedAmount);
                    fixedAmount = 0;
                } else if(address(this).balance > 1 ether) {
                    uint256 paidAmount = address(this).balance - 1 ether;
                    payable(teamMember5).transfer(paidAmount);     
                    fixedAmount -= bnbToBusd(paidAmount);
                }
            }
        }
        bnbToDivide = 0;
        payable(_admin).transfer(address(this).balance);     
    }

    // emergency functions just in case
    function rescueAnyToken(address tokenToRescue) external onlyOwner {
        IBEP20(tokenToRescue).transfer(msg.sender, IBEP20(tokenToRescue).balanceOf(address(this)));
    }

    function rescueBnb() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}