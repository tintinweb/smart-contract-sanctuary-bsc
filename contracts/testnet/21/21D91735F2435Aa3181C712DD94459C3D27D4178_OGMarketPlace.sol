// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IBEP20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

interface IBEP165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IBEP721 is IBEP165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

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

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata  data
    ) external;
}

interface IOGNft is IBEP721 {
    function mint(address to, string memory uri) external returns (uint256);

    function burn(uint256 tokenId) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract OGMarketPlace is Ownable {
    IBEP20 public OGToken;
    IOGNft public OGNft;
    uint256 constant public percentDivider = 100_000;
    uint256 public fee_percentage = 2_500;

    struct Ask {
        bool exists;
        address seller;
        uint256 price;
        address to;
        bool eth;
    }

    struct Bid {
        bool exists;
        address buyer;
        uint256 price;
        bool eth;
        address topbider;
        uint256 bidendtime;
        uint256 lastbid;
    }

    struct Price{
        uint256 ethprice;
        uint256 tokenprice;
    }

    struct escrowrecord{
        uint256 tokenamount;
        uint256 ethamount;
    }

    mapping(string => uint256) public tokenPoolCount;
    mapping(string => Price) public tokenPrice;
    mapping(string => Price) public priceInc;
    mapping(string => mapping(address => uint256)) public isWhitelisted;
    mapping(string => mapping(address => bool)) public minterClaimed;
    mapping(address => mapping(string => uint256[])) public uriToId;
    mapping(uint256 => Ask) public asks;
    mapping(uint256 => Bid) public bids;
    mapping(address => escrowrecord) public escrow;
    uint256 [] public askslisted;
    uint256 [] public bidslisted;

    string public constant REVERT_NOT_OWNER_OF_TOKEN_ID =
        "Marketplace::not an owner of token ID";
    string public constant REVERT_NOT_A_CREATOR_OF_BID =
        "Marketplace::not a creator of the bid";
    string public constant REVERT_NOT_A_CREATOR_OF_ASK =
        "Marketplace::not a creator of the ask";
    string public constant REVERT_ASK_DOES_NOT_EXIST =
        "Marketplace::ask does not exist";
    string public constant REVERT_CANT_ACCEPT_OWN_ASK =
        "Marketplace::cant accept own ask";
    string public constant REVERT_ASK_IS_RESERVED =
        "Marketplace::ask is reserved";
    string public constant REVERT_ASK_INSUFFICIENT_VALUE =
        "Marketplace::ask price higher than sent value";

    event CreateAsk(uint256 indexed tokenID, uint256 price, address indexed to);
    event CancelAsk(uint256 indexed tokenID);
    event AcceptAsk(uint256 indexed tokenID, uint256 price, address indexed to);

    event CreateBid(uint256 indexed tokenID, uint256 price);
    event CancelBid(uint256 indexed tokenID);
    event AcceptBid(uint256 indexed tokenID, uint256 price);

    constructor(IOGNft nft, IBEP20 token) {
        OGNft = nft;
        OGToken = token;
    }

    function createAsk(
        uint256  tokenID,
        uint256  price,
        address  to,
        bool _eth
    ) external  {
            require(
                 OGNft.ownerOf(tokenID) == msg.sender,
                REVERT_NOT_OWNER_OF_TOKEN_ID
            );
            OGNft.transferFrom(
                msg.sender,
                address(this),
                tokenID
            );

            asks[tokenID] = Ask({
                exists: true,
                seller: msg.sender,
                price: price,
                to: to,
                eth: _eth
            });

            emit CreateAsk({
                tokenID: tokenID,
                price: price,
                to: to
            });
            askslisted.push(tokenID);
        
    }

    function createBid(uint256  tokenID, uint256  price,bool _eth,uint256 _time)
        external
    {
        require(
                 OGNft.ownerOf(tokenID) == msg.sender,
                REVERT_NOT_OWNER_OF_TOKEN_ID
            );
            OGNft.transferFrom(
                msg.sender,
                address(this),
                tokenID
            );

            bids[tokenID] = Bid({
                exists: true,
                buyer: msg.sender,
                price: price,
                eth: _eth,
                topbider: address(0),
                bidendtime: _time,
                lastbid: price
            });

            emit CreateBid({
                tokenID: tokenID,
                price: price
            });
            bidslisted.push(tokenID);

        
    }

    function cancelAsk(uint256  tokenID) external  {
        
            
            require(
                asks[tokenID].seller == msg.sender,
                REVERT_NOT_A_CREATOR_OF_ASK
            );
            OGNft.transferFrom(
                address(this),
                msg.sender,
                tokenID
            );
            delete asks[tokenID];
            for(uint256 i = 0; i < askslisted.length; i++){
                if(askslisted[i] == tokenID){
                    delete askslisted[i];
                }
            }

            emit CancelAsk({ tokenID: tokenID});
        
    }

    function cancelBid(uint256  tokenID) external  {
        
            
            require(
                bids[tokenID].buyer == msg.sender,
                REVERT_NOT_A_CREATOR_OF_BID
            );
            OGNft.transferFrom(
                address(this),
                msg.sender,
                tokenID
            );

            delete bids[tokenID];
            for(uint256 i = 0; i < bidslisted.length; i++){
                if(bidslisted[i] == tokenID){
                    delete bidslisted[i];
                }
            }

            emit CancelBid({ tokenID: tokenID});
        
    }

    function acceptAsk(uint256  tokenID) external payable  {
        uint256 totalPrice = 0;
        
            

            require(
                asks[tokenID].exists,
                REVERT_ASK_DOES_NOT_EXIST
            );
            require(
                asks[tokenID].seller != msg.sender,
                REVERT_CANT_ACCEPT_OWN_ASK
            );
            if (asks[tokenID].to != address(0)) {
                require(
                    asks[tokenID].to == msg.sender,
                    REVERT_ASK_IS_RESERVED
                );
            }

            totalPrice += asks[tokenID].price;

            if(asks[tokenID].eth){
                escrow[asks[tokenID].seller].ethamount += _takeFee(
                asks[tokenID].price
            );}else{
                escrow[asks[tokenID].seller].tokenamount += _takeFee(
                asks[tokenID].price
            );
            }

            emit AcceptAsk({
                
                tokenID: tokenID,
                price: asks[tokenID].price,
                to: asks[tokenID].to
            });
            OGNft.transferFrom(
                address(this),
                msg.sender,
                tokenID
            );
            for(uint256 i = 0; i < askslisted.length; i++){
                if(askslisted[i] == tokenID){
                    delete askslisted[i];
                }
            }
            delete asks[tokenID];
            delete bids[tokenID];
        

        if(asks[tokenID].eth){
            require(totalPrice == msg.value, REVERT_ASK_INSUFFICIENT_VALUE);
        }else{
            OGToken.transferFrom(msg.sender,address(this),asks[tokenID].price);
        }
    }

    function acceptBid(uint256  tokenID,uint256 amount) external payable  {
        require(
            bids[tokenID].exists,
            "bid does not exist"
        );
        require(
            bids[tokenID].buyer != msg.sender,
            "cant accept own bid"
        );
        require(block.timestamp < bids[tokenID].bidendtime,"bid expired");
        
        
        if(bids[tokenID].eth){
            require(msg.value >= bids[tokenID].lastbid,
            "bid price need to be higher than sent value");
            if(bids[tokenID].topbider != address(0)){
                escrow[bids[tokenID].topbider].ethamount +=
                bids[tokenID].lastbid;
            }
            
            bids[tokenID].lastbid = msg.value;
        }else{
            require(amount >= bids[tokenID].lastbid,"bid price need to be higher than sent value");
            OGToken.transferFrom(msg.sender,address(this),amount);
            if(bids[tokenID].topbider != address(0)){
                escrow[bids[tokenID].topbider].tokenamount +=
                bids[tokenID].lastbid;
            }
            bids[tokenID].lastbid = amount;
        }
        bids[tokenID].topbider = msg.sender;

    }

    function claimbid(uint256 tokenID) external{
        require(
            bids[tokenID].topbider == msg.sender,
            "you are not the top bidder"
        );
        require(block.timestamp > bids[tokenID].bidendtime,
        "bid expired");
        if(bids[tokenID].eth){
            escrow[bids[tokenID].buyer].tokenamount += _takeFee(bids[tokenID].lastbid);
        }else{
            escrow[bids[tokenID].buyer].ethamount += _takeFee(bids[tokenID].lastbid);
        }
        delete bids[tokenID];
        for(uint256 i = 0; i < bidslisted.length; i++){
            if(bidslisted[i] == tokenID){
                delete bidslisted[i];
            }
        }
        OGNft.transferFrom(
                address(this),
                msg.sender,
                tokenID
            );
    }

    function withdraw(bool _eth) external  {
        if(_eth){
            uint256 amount = escrow[msg.sender].ethamount;
        escrow[msg.sender].ethamount = 0;
        payable(msg.sender).transfer(amount);
        }else{
            uint256 amount = escrow[msg.sender].tokenamount;
        escrow[msg.sender].tokenamount = 0;
        OGToken.transferFrom(address(this),msg.sender,amount);
        }
    }

    function _takeFee(uint256 totalPrice) internal virtual returns (uint256) {
        return totalPrice-((totalPrice*fee_percentage)/percentDivider);
    }

    function buyNFT(string memory uri,bool eth) payable public {
        uint256 tokenId = OGNft.mint(msg.sender, uri);
        uriToId[msg.sender][uri].push(tokenId);
        tokenPoolCount[uri]--;
        if(!eth){
            IBEP20(OGToken).transferFrom(
            msg.sender,
            address(this),
            tokenPrice[uri].tokenprice
        );
        }else{
            require(msg.value == tokenPrice[uri].ethprice, "wrong price");
            payable(owner()).transfer(msg.value);
        }
        tokenPrice[uri].ethprice += priceInc[uri].ethprice;
        tokenPrice[uri].tokenprice += priceInc[uri].tokenprice;
    }

    function claimNFT(string memory uri) public {
        require(isWhitelisted[uri][msg.sender] > 0, "Not whitelisted");
        for (uint256 i = 0; i < isWhitelisted[uri][msg.sender]; i++) {
            IOGNft(OGNft).mint(msg.sender, uri);
            tokenPoolCount[uri]--;
            isWhitelisted[uri][msg.sender]--;
        }
    }

    function transferBatch(
        string memory uri,
        address receiver,
        uint256 quantitity
    ) public {
        uint256 tokenId;
        for (uint256 i = 0; i < quantitity; i++) {
            tokenId = uriToId[msg.sender][uri][
                uriToId[msg.sender][uri].length - 1
            ];
            IOGNft(OGNft).safeTransferFrom(msg.sender, receiver, tokenId);
            uriToId[receiver][uri].push(tokenId);
            uriToId[msg.sender][uri].pop;
        }
    }

    function whitelistUsers(
        string memory uri,
        address [] memory users,
        uint256[] memory quantitty
    ) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            isWhitelisted[uri][users[i]] = quantitty[i];
        }
    }

    function setPriceIncrement(string memory uri, uint256 ethamount, uint256 tokenamount) external onlyOwner {
        priceInc[uri].ethprice = ethamount;
        priceInc[uri].tokenprice = tokenamount;
    }

    function addNewToken(
        string memory uri,
        uint256 max,
        uint256 tokenprice,
        uint256 ethprice,
        uint256 ethinc,
        uint256 tokeninc
    ) external onlyOwner {
        require(tokenPrice[uri].ethprice == 0 && tokenPrice[uri].ethprice == 0, "Already listed");
        tokenPoolCount[uri] = max;
        tokenPrice[uri].ethprice = ethprice;
        tokenPrice[uri].tokenprice = tokenprice;
        priceInc[uri].ethprice = ethinc;
        priceInc[uri].tokenprice = tokeninc;
    }

    function changeOGToken(IBEP20 token) external onlyOwner {
        OGToken = token;
    }

    function changeOGNft(IOGNft nft) external onlyOwner {
        OGNft = nft;
    }
}