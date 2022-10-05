/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.7;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom( address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom( address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface VRFCoordinatorV2Interface {
  function getRequestConfig() external view returns (uint16, uint32, bytes32[] memory);
  function requestRandomWords(bytes32 keyHash, uint64 subId, uint16 minimumRequestConfirmations, uint32 callbackGasLimit, uint32 numWords) external returns (uint256 requestId);
  function createSubscription() external returns (uint64 subId);
  function getSubscription(uint64 subId) external view returns (uint96 balance, uint64 reqCount, address owner, address[] memory consumers);
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;
  function addConsumer(uint64 subId, address consumer) external;
  function removeConsumer(uint64 subId, address consumer) external;
  function cancelSubscription(uint64 subId, address to) external;
}

interface LinkTokenInterface is IERC20 {
  function decimals() external view returns (uint8 decimalPlaces);
  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);
  function increaseApproval(address spender, uint256 subtractedValue) external;
  function name() external view returns (string memory tokenName);
  function symbol() external view returns (string memory tokenSymbol);
  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

library String {
    function toString(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}

contract Lottery {

    address private owner;

    uint256 immutable public drawId;
    uint256 immutable public drawType;
    bool private drawn;
    bool private cancelled;
    bool private prepared;
    uint256 private drawnAt;
    uint256 immutable public ticketPrice;
    uint256 immutable public ticketCount;
    uint256 immutable public minSales;
    uint256 immutable public endTime;

    Ticket private first;
    Ticket private second;
    Ticket private third;
    Ticket[] private consolations;

    uint256 immutable public firstPrize;
    uint256 immutable public secondPrize;
    uint256 immutable public thirdPrize;
    uint256 immutable public consolationPrize;
    uint256 immutable public consolationAmount;
    uint256 immutable private marketingAmount;
    uint256 immutable private buybackAmount;

    IERC20 private token;
    IERC721 private nfts;

    Ticket[] private tickets;
    uint256[] private drawArray;
    uint256[] private randomWords;

    struct Ticket {
        address holder;
        uint256 tokenId;
    }
    
    struct LottoInfo {
        uint256 drawId;
        uint256 drawType;
        bool cancelled;
        uint256 totaltickets;
        uint256 ticketsPurchased;
        uint256 ticketPrice;
        uint256 endTime;
        Ticket first;
        uint256 firstPrize;
        Ticket second;
        uint256 secondPrize;
        Ticket third;
        uint256 thirdPrize;
        Ticket[] consolations;
        uint256 consPrize;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "owner only");
        _;
    }

    constructor (
        address _token,
        uint256 _drawId,
        uint256 _drawType,
        uint256 _ticketPrice,
        uint256 _ticketCount,
        uint256 _minSales,
        uint256 _endTime,
        uint256[] memory _prizes
    ) { 
        owner = msg.sender;
        token = IERC20(_token);
        nfts = IERC721(msg.sender);
        drawId = _drawId;
        drawType = _drawType;
        ticketPrice = _ticketPrice;
        ticketCount = _ticketCount;
        minSales = _minSales;
        endTime = _endTime;
        firstPrize = _prizes[0];
        secondPrize = _prizes[1];
        thirdPrize = _prizes[2];
        consolationPrize = _prizes[3];
        consolationAmount = _prizes[4];
        marketingAmount = _prizes[5];
        buybackAmount = _prizes[6];
    }

    function buyTicket(address who, uint256 tokenId) external onlyOwner returns (uint256) {
        require(tickets.length < minSales || block.timestamp < endTime, "entry period ended");
        require(drawn == false, "lottery already drawn");
        require(tickets.length < ticketCount, "All tickets sold");

        tickets.push(Ticket(who, tokenId));
        drawArray.push(tokenId);
        return tickets.length;
    }

    function prepareLotto(uint256[] memory words) external onlyOwner {
        require (words.length >= consolationAmount + 3, "Not enough words supplied");
        randomWords = words;
        prepared = true;
    }

    function drawLotto(address marketing, address buyback, address lottoWallet) external onlyOwner {
        require(tickets.length >= minSales && (block.timestamp >= endTime || tickets.length >= ticketCount), "cannot draw yet");
        require(prepared, "lotto not prepared");
        require(drawn == false, "lotto already drawn");

        token.transfer(buyback, buybackAmount);
        token.transfer(marketing, marketingAmount);

        first = drawWinner();
        token.transfer(first.holder, firstPrize);
        second = drawWinner();
        token.transfer(second.holder, secondPrize);
        third = drawWinner();
        token.transfer(third.holder, thirdPrize);

        for (uint256 i = 0; i < consolationAmount; i++) {
            Ticket memory cons = drawWinner();
            consolations.push(cons);
            token.transfer(cons.holder, consolationPrize);
        }

        token.transfer(lottoWallet, token.balanceOf(address(this)));

        drawn = true;
        drawnAt = block.timestamp;
    }

    function cancelDraw() external onlyOwner {
        require(drawn == false, "lotto already drawn");
        
        drawn = true;
        cancelled = true;
        
        for (uint256 i = 0; i < tickets.length; i++) {
            token.transfer(nfts.ownerOf(tickets[i].tokenId), ticketPrice);
        }
    }

    function soldTickets() external view onlyOwner returns (uint256) {
        return tickets.length;
    }

    function info() external view returns (LottoInfo memory) {
        return LottoInfo(
            drawId,
            drawType,
            cancelled,
            ticketCount,
            tickets.length,
            ticketPrice,
            endTime,
            first,firstPrize,
            second,secondPrize,
            third,thirdPrize,
            getConsolations(),
            consolationPrize
        );
    }

    function getConsolations() private view returns (Ticket[] memory winners) {
        winners = new Ticket[](consolations.length);
        for (uint256 i = 0; i < consolations.length; i++) {
            winners[i] = consolations[i];
        }
    }

    function canBuy() external view onlyOwner returns (bool) {
        return tickets.length < ticketCount && (block.timestamp < endTime || tickets.length < minSales) && drawn == false && prepared == false;
    }

    function canDraw() external view onlyOwner returns (bool) {
        return tickets.length >= minSales && (block.timestamp >= endTime || tickets.length >= ticketCount) && prepared && drawn == false;
    }

    function canPrepare() external view onlyOwner returns (bool) {
        return tickets.length >= minSales && (block.timestamp >= endTime || tickets.length >= ticketCount) && prepared == false && drawn == false;
    }

    function drawWinner() private returns (Ticket memory winner) {
        uint256 index = requestRandomWords() % drawArray.length;
        uint256 tokenId = drawArray[index];
        drawArray[index] = drawArray[drawArray.length - 1];
        drawArray.pop();
        return Ticket(nfts.ownerOf(tokenId), tokenId);
    }

    function requestRandomWords() private returns (uint256) {
        uint256 word = randomWords[randomWords.length - 1];
        randomWords.pop();
        return word;
    }
}

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address internal vrfCoordinator;

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

abstract contract ERC721 is IERC721, IERC721Metadata {
    using Address for address;

    string public override name;
    string public override symbol;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) external view virtual override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function balanceOf(address owner) external view virtual override returns (uint256) {
        require(owner != address(0), "address zero is not a valid owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "invalid token ID");
        return owner;
    }

    function approve(address to, uint256 tokenId) external virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "approval to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "approve caller is not token owner or approved for all");
        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external virtual override {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) external virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "caller is not token owner or approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "transfer to non ERC721Receiver implementer");
    }

    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "mint to the zero address");
        require(!_exists(tokenId), "token already minted");
        require(!_exists(tokenId), "token already minted");

        unchecked {
            _balances[to] += 1;
        }

        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "transfer from incorrect owner");
        require(to != address(0), "transfer to the zero address");
        require(ERC721.ownerOf(tokenId) == from, "transfer from incorrect owner");
        delete _tokenApprovals[tokenId];

        unchecked {
            _balances[from] -= 1;
            _balances[to] += 1;
        }

        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "invalid token ID");
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}

contract ZoRaffle is ERC721, VRFConsumerBaseV2 {
    using String for uint256;

    uint256 private _tokenIdTracker = 1;
    uint256 private _drawIdTracker = 1;

    string private _baseTokenURI;
    IERC20 private _token;

    Lottery[] private _currentLotteries;
    Lottery[] private pastLotteries;
    mapping(uint256 => TicketInfo) private _tokenInfo;

    address public owner;
    mapping (address => bool) public admins;

    address public marketingWallet;
    address public buybackWallet;
    address public lottoWallet;

    uint256 public marketingPerc = 1500;
    uint256 public buybackPerc = 500;

    // Chainlink
    VRFCoordinatorV2Interface private COORDINATOR;
    LinkTokenInterface private LINKTOKEN;
    uint64 private subscriptionId;
    address private link;
    bytes32 private keyHash;
    uint32 private callbackGasLimit;
    uint16 private requestConfirmations;
    uint32 private numberOfWords;
    mapping(uint256 => uint256) private chainlinkRequests;

    struct TicketInfo {
        uint256 drawId;
        uint256 drawType;
        uint256 ticketPrice;
        uint256 ticketNo;
    }

    struct LottoInfo {
        uint256 drawId;
        uint256 drawType;
        uint256 totaltickets;
        uint256 minSales;
        uint256 ticketsPurchased;
        uint256 ticketPrice;
        uint256 endTime;
        uint256 winnerPrize;
        uint256 secondPrize;
        uint256 thirdPrize;
        uint256 consPrize;
        uint256 consAmount;
        bool canBuy;
        bool canPrepare;
        bool canDraw;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "No Permission");
        _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "No Permission");
        _;
    }

    constructor() ERC721("ZOR", "ZOR") {
        owner = msg.sender;
        admins[msg.sender] = true;
        _baseTokenURI = "https://zor.azurewebsites.net/uri/nft/";

        if (block.chainid == 56) {
            _token = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // MAINNET
            subscriptionId = 510;
            setChainlink(
                0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7,
                2_500_000,
                3,
                50
            );        
            vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
            link = 0x404460C6A5EdE2D891e8297795264fDe62ADBB75;
        } else if (block.chainid == 97) {
            _token = IERC20(0xc880D1FA2AcFD2acAb04B8F34Cf0af5Ca2Fc19B6); // TESTNET
            subscriptionId = 1866;
            setChainlink(
                0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314,
                2_500_000,
                3,
                50
            );
            vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
            link = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;
        } else {
            revert("Unknown Chain ID");
        }

        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        marketingWallet = 0xA5139A7fb5eC250D2780f2627f6EfD7E1B184700;
        buybackWallet = 0xA5139A7fb5eC250D2780f2627f6EfD7E1B184700;
        lottoWallet = 0xA5139A7fb5eC250D2780f2627f6EfD7E1B184700;
    }

    function tokenURI(uint256 tokenId) external override view returns (string memory) {
        require(_exists(tokenId));
        return string(abi.encodePacked(_baseTokenURI, tokenId.toString()));
    }

    function tokenInfo(uint256 tokenId) external view returns (TicketInfo memory) {
        require(_exists(tokenId));
        return _tokenInfo[tokenId];
    }

    function _setTokenInfo(uint256 tokenId, uint256 drawId, uint256 drawType, uint256 ticketPrice, uint256 ticketNo) private {
        require(_exists(tokenId));
        _tokenInfo[tokenId] = TicketInfo(drawId, drawType, ticketPrice, ticketNo);
    }

    function buyTicket(uint256 drawId, uint256 numTickets) external
    {
        (Lottery lottery,) = getCurrentLottery(drawId);
        require(numTickets > 0 && numTickets <= lottery.ticketCount() - lottery.soldTickets(), "Not enough tickets");
        require(_token.allowance(msg.sender, address(this)) >= lottery.ticketPrice() * numTickets, "No permission");
        require(_token.transferFrom(msg.sender, address(lottery), lottery.ticketPrice() * numTickets), "Unable to transfer");

        for (uint256 i = 0; i < numTickets; i++) {
            uint256 ticketNo = lottery.buyTicket(msg.sender, _tokenIdTracker);
            _mint(msg.sender, _tokenIdTracker);
            _setTokenInfo(_tokenIdTracker, drawId, lottery.drawType(), lottery.ticketPrice(), ticketNo);
            _tokenIdTracker++;
        }
    }

    function startLottery(uint256 drawType, uint256 ticketPrice, uint256 ticketCount, uint256 minSales, uint256 timeSpan, uint256[] memory prizes) external onlyAdmin {
        require(minSales <= ticketCount, "Wrong min");
        require(prizes[4] + 3 <= minSales, "Wrong prizes");
        require (ticketPrice * minSales >= prizes[0] + prizes[1] + prizes[2] + prizes[5] + prizes[6] + (prizes[3] * prizes[4]), "Prize error");
        for (uint256 i = 0; i < _currentLotteries.length; i++) {
            require(_currentLotteries[i].drawType() != drawType, "Already active");
        }

        Lottery lottery = new Lottery(
            address(_token),
            _drawIdTracker,
            drawType,
            ticketPrice,
            ticketCount,
            minSales,
            block.timestamp + timeSpan,
            prizes
        );

        _drawIdTracker++;
        _currentLotteries.push(lottery);
    }

    function prepareLottery(uint256 drawId) external onlyAdmin { 
        (Lottery lottery,) = getCurrentLottery(drawId);
        require(lottery.canPrepare(), "Not Ready");
        chainlinkRequests[requestRandomWords()] = lottery.drawId();
    }

    function drawLottery(uint256 drawId) external onlyAdmin { 
        (Lottery lottery, uint256 index) = getCurrentLottery(drawId);
        require(lottery.canDraw(), "Not Ready");
        
        lottery.drawLotto(marketingWallet, buybackWallet, lottoWallet);
 
        _currentLotteries[index] = _currentLotteries[_currentLotteries.length - 1];
        _currentLotteries.pop();
        pastLotteries.push(lottery);
    }

    function cancelLottery(uint256 drawId) external onlyAdmin { 
        (Lottery lottery, uint256 index) = getCurrentLottery(drawId);

        lottery.cancelDraw();

        _currentLotteries[index] = _currentLotteries[_currentLotteries.length - 1];
        _currentLotteries.pop();
        pastLotteries.push(lottery);
    }

    function info() external view returns (address currency, uint256 balance, uint256 approved, LottoInfo[] memory currentLotteries)
    {
        currency = address(_token);
        balance = _token.balanceOf(msg.sender);
        approved = _token.allowance(msg.sender, address(this));

        currentLotteries = new LottoInfo[](_currentLotteries.length);
        for (uint256 i = 0; i < _currentLotteries.length; i++) {
            Lottery lotto = _currentLotteries[i];
            currentLotteries[i] = LottoInfo(
                lotto.drawId(),
                lotto.drawType(),
                lotto.ticketCount(),
                lotto.minSales(),
                lotto.soldTickets(),
                lotto.ticketPrice(),
                lotto.endTime(),
                lotto.firstPrize(),
                lotto.secondPrize(),
                lotto.thirdPrize(),
                lotto.consolationPrize(),
                lotto.consolationAmount(),
                lotto.canBuy(),
                lotto.canPrepare(),
                lotto.canDraw()
            );
        } 
    }

    function pastLottery(uint256 index) external view returns (address) {
        return address(pastLotteries[index]);
    }

    function pastLotteryCount() external view returns (uint256) {
        return pastLotteries.length;
    }

    // Admin Methods
    function setOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Bad address");
        owner = newOwner;
    }

    function setAdmin(address admin, bool enabled) external onlyOwner {
        require(admin != address(0), "Bad address");
        admins[admin] = enabled;
    }

    function setTaxWallets(address newMarketing, address newBuyback, address newLottoWallet) external onlyOwner {
        require(newMarketing != address(0) && newBuyback != address(0) && newLottoWallet != address(0), "Bad address");
        marketingWallet = newMarketing;
        buybackWallet = newBuyback;
        lottoWallet = newLottoWallet;
    }

    function setChainlink(bytes32 hash, uint32 gasLimit, uint16 confirmations, uint32 numWords) public onlyOwner {
        keyHash = hash;
        callbackGasLimit = gasLimit;
        requestConfirmations = confirmations;
        numberOfWords = numWords;
    }
    
    function setChainlinkSubscription(uint64 subId) external onlyOwner {
        subscriptionId = subId;
    }

    function removeBnb() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }
    
    function removeTokens(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner, balance);
    }

    // Private Methods
    function getCurrentLottery(uint256 drawId) private view returns (Lottery lottery, uint256 index) {
        for (uint256 i = 0; i < _currentLotteries.length; i++) {
            if (_currentLotteries[i].drawId() == drawId) {
                lottery = _currentLotteries[i];
                index = i;
                return (lottery, index);
            }
        }

        revert("Wrong id");
    }

    function requestRandomWords() private returns (uint256) {
        return COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numberOfWords
        );
    }
  
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
       (Lottery lottery,) = getCurrentLottery(chainlinkRequests[requestId]);
       lottery.prepareLotto(randomWords);
    }
}