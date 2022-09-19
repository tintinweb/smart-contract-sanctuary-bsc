/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.7;

interface IOwnable {
    function owner() external view returns (address);
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

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

contract Lottery is IOwnable {

    address public override owner;

    uint256 public drawId;
    bool public drawn;
    uint256 public drawnAt;
    uint256 public ticketPrice;
    uint256 public ticketCount;
    uint256 public minSales;
    uint256 public endTime;

    address public first;
    address public second;
    address public third;
    address[] public consolations;

    uint256 public firstPrize;
    uint256 public secondPrize;
    uint256 public thirdPrize;
    uint256 public consolationPrize;
    uint256 public consolationAmount;
    uint256 public marketingAmount;
    uint256 public buybackAmount;

    IERC20 private token;
    Ticket[] private tickets;
    address[] private drawArray;
    uint256 private nonce;

    mapping (address => uint256) public holders;
    mapping (address => bool) public refunds;

    struct Ticket {
        address holder;
        uint256 tokenId;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "can only be called by the contract owner");
        _;
    }

    constructor (
        address _token,
        uint256 _drawId,
        uint256 _ticketPrice,
        uint256 _ticketCount,
        uint256 _minSales,
        uint256 _endTime,
        uint256[] memory _prizes //_firstPrize,
        /*uint256 _secondPrize,
        uint256 _thirdPrize,
        uint256 _consolationPrize,
        uint256 _consolationAmount,
        uint256 _marketingAmount//,
        //uint256 _buybackAmount*/
    ) { 
        owner = msg.sender;
        token = IERC20(_token);
        drawId = _drawId;
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

    function buyTicket(address who, uint256 tokenId) external onlyOwner {
        require(tickets.length < minSales || block.timestamp < endTime, "The entry period for this lottery has ended");
        require(drawn == false, "This lottery has already been drawn");
        require(tickets.length < ticketCount, "All tickets are sold");

        tickets.push(Ticket(who, tokenId));
        drawArray.push(who);
        holders[who]++;
    }

    function drawLotto(address marketing, address buyback, address lottoWallet) external onlyOwner {
        require(tickets.length >= minSales && (block.timestamp >= endTime || tickets.length >= ticketCount), "The end period of the lotto has not been reached and it is not sold out.");
        require(drawn == false, "This lottery has already been drawn");

        token.transfer(buyback, buybackAmount);
        token.transfer(marketing, marketingAmount);

        first = drawWinner();
        token.transfer(first, firstPrize);
        second = drawWinner();
        token.transfer(second, secondPrize);
        third = drawWinner();
        token.transfer(third, thirdPrize);

        for (uint256 i = 0; i < consolationAmount; i++) {
            address cons = drawWinner();
            consolations.push(cons);
            token.transfer(cons, consolationPrize);
        }

        token.transfer(lottoWallet, token.balanceOf(address(this)));

        drawn = true;
        drawnAt = block.timestamp;
    }

    function cancelDraw() external onlyOwner {
        require(drawn == false, "This lotto has already been drawn");
        
        drawn = true;
        
        for (uint256 i = 0; i < drawArray.length; i++) {
            if (refunds[drawArray[i]] == false) {
                refunds[drawArray[i]] = true;
                token.transfer(drawArray[i], ticketPrice * holders[drawArray[i]]);
            }
        }
    }

    function soldTickets() external view onlyOwner returns (uint256) {
        return tickets.length;
    }

    function getConsolations() external view onlyOwner returns (address[] memory winners) {
        winners = new address[](consolations.length);
        for (uint256 i = 0; i < consolations.length; i++) {
            winners[i] = consolations[i];
        }
    }

    function canDraw() external view onlyOwner returns (bool) {
        return tickets.length >= minSales && (block.timestamp >= endTime || tickets.length >= ticketCount) && drawn == false;
    }

    function drawWinner() private returns (address winner) {
        uint256 index = requestRandomWords() % drawArray.length;
        winner = drawArray[index];
        drawArray[index] = drawArray[drawArray.length - 1];
        drawArray.pop();
    }

    function requestRandomWords() private returns (uint256) {
        nonce += 1;
        return uint(keccak256(abi.encodePacked(nonce, block.timestamp)));
    }
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract ERC721 is ERC165, IERC721, IERC721Metadata {
    using Address for address;

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
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

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

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(msg.sender, operator, approved);
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
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner or approved");

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
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
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

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
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

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
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

    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
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

    function _beforeConsecutiveTokenTransfer(
        address from,
        address to,
        uint256, /*first*/
        uint96 size
    ) internal virtual {
        if (from != address(0)) {
            _balances[from] -= size;
        }
        if (to != address(0)) {
            _balances[to] += size;
        }
    }

    function _afterConsecutiveTokenTransfer(
        address, /*from*/
        address, /*to*/
        uint256, /*first*/
        uint96 /*size*/
    ) internal virtual {}
}


contract IndianLotto is ERC721 {

    uint256 private _tokenIdTracker = 1;
    uint256 private _drawIdTracker = 1;

    string private _baseTokenURI;
    IERC20 private _token;

    Lottery[] private _currentLotteries;
    Lottery[] private _pastLotteries;

    mapping(uint256 => string) private _tokenURIs;
    
    address public owner;
    mapping (address => bool) public admins;

    address public marketingWallet;
    address public buybackWallet;
    address public lottoWallet;

    uint256 public marketingPerc = 1500;
    uint256 public buybackPerc = 500;

    struct LottoInfo {
        uint256 drawId;
        uint256 totaltickets;
        uint256 minSales;
        uint256 ticketsPurchased;
        uint256 myTickets;
        uint256 ticketPrice;
        uint256 endTime;
        uint256 winnerPrize;
        uint256 secondPrize;
        uint256 thirdPrize;
        uint256 consPrize;
        uint256 consAmount;
        bool canDraw;
    }

    struct CompletedLottoInfo {
        uint256 drawId;
        uint256 totaltickets;
        uint256 ticketsPurchased;
        uint256 myTickets;
        uint256 ticketPrice;
        uint256 endTime;
        address first;
        uint256 firstPrize;
        address second;
        uint256 secondPrize;
        address third;
        uint256 thirdPrize;
        address[] consolations;
        uint256 consPrize;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "can only be called by the contract owner");
        _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "can only be called by an admin");
        _;
    }

    constructor() ERC721("ZOR", "ZOR") {
        owner = msg.sender;
        admins[msg.sender] = true;
        _baseTokenURI = "https://lotto.com/ticket/";
        _token = IERC20(0xc880D1FA2AcFD2acAb04B8F34Cf0af5Ca2Fc19B6); // TESTNET
        //_token = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // MAINNET

        marketingWallet = 0xA5139A7fb5eC250D2780f2627f6EfD7E1B184700;
        buybackWallet = 0xA5139A7fb5eC250D2780f2627f6EfD7E1B184700;
        lottoWallet = 0xA5139A7fb5eC250D2780f2627f6EfD7E1B184700;
    }

    function tokenURI(uint256 tokenId) public override view returns (string memory) {
        require(_exists(tokenId));
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_exists(tokenId));
        _tokenURIs[tokenId] = uri;
    }


    function buyTicket(uint256 drawId, uint256 numTickets) external
    {
        (Lottery lottery,) = getCurrentLottery(drawId);
        require(numTickets > 0 && numTickets <= lottery.ticketCount() - lottery.soldTickets(), "There are not enough tickets remaining");
        require(_token.allowance(msg.sender, address(this)) >= lottery.ticketPrice() * numTickets, "Contract does not have permission to spend BUSD");
        require(_token.transferFrom(msg.sender, address(lottery), lottery.ticketPrice() * numTickets), "Unable to transfer BUSD");

        for (uint256 i = 0; i < numTickets; i++) {
            uint256 tokenId = _tokenIdTracker;
            lottery.buyTicket(msg.sender, tokenId);
            _mint(msg.sender, tokenId);
            string memory uri = string(abi.encodePacked(_baseTokenURI, uint2str(drawId), "/", uint2str(tokenId)));
            _setTokenURI(tokenId, uri);
            _tokenIdTracker++;
        }
    }

    function startLottery(
        uint256 ticketPrice,
        uint256 ticketCount,
        uint256 minSales,
        uint256 timeSpan,
        uint256[] memory prizes/* firstPrize,
        uint256 secondPrize,
        uint256 thirdPrize,
        uint256 consolationPrize,
        uint256 consolationAmount,
        uint256 marketingAmount,
        uint256 buybackAmount*/
    ) external onlyAdmin {
        require(minSales <= ticketCount, "Cannot require more sales than tickets");
        require(prizes[4] + 3 <= minSales, "Cannot have more prizes than entries");
        require (ticketPrice * minSales >= 
            prizes[0] + prizes[1] + prizes[2] + prizes[5] + prizes[6] + (prizes[3] * prizes[4]), 
            "Error in prize calculations");

        for (uint256 i = 0; i < _currentLotteries.length; i++) {
            require(_currentLotteries[i].ticketPrice() != ticketPrice, "There is already an active lotter of this tier");
        }

        Lottery lottery = new Lottery(
            address(_token),
            _drawIdTracker,
            ticketPrice,
            ticketCount,
            minSales,
            block.timestamp + timeSpan,
            prizes
        );

        _drawIdTracker++;
        _currentLotteries.push(lottery);
    }

    function drawLottery(uint256 drawId) external onlyAdmin { 
        (Lottery lottery, uint256 index) = getCurrentLottery(drawId);

        lottery.drawLotto(marketingWallet, buybackWallet, lottoWallet);

        _currentLotteries[index] = _currentLotteries[_currentLotteries.length - 1];
        _currentLotteries.pop();
        _pastLotteries.push(lottery);
    }

    function cancelLottery(uint256 drawId) external onlyAdmin { 
        (Lottery lottery, uint256 index) = getCurrentLottery(drawId);

        lottery.cancelDraw();

        _currentLotteries[index] = _currentLotteries[_currentLotteries.length - 1];
        _currentLotteries.pop();
    }

    function info() external view returns (
        address currency,
        uint256 balance, 
        uint256 approved, 
        LottoInfo[] memory currentLotteries, 
        CompletedLottoInfo[] memory pastLotteries
       )
    {
        currency = address(_token);
        balance = _token.balanceOf(msg.sender);
        approved = _token.allowance(msg.sender, address(this));

        currentLotteries = new LottoInfo[](_currentLotteries.length);
        for (uint256 i = 0; i < _currentLotteries.length; i++) {
            Lottery lotto = _currentLotteries[i];
            currentLotteries[i] = LottoInfo(
                lotto.drawId(),
                lotto.ticketCount(),
                lotto.minSales(),
                lotto.soldTickets(),
                lotto.holders(msg.sender),
                lotto.ticketPrice(),
                lotto.endTime(),
                lotto.firstPrize(),
                lotto.secondPrize(),
                lotto.thirdPrize(),
                lotto.consolationPrize(),
                lotto.consolationAmount(),
                lotto.canDraw()
            );
        } 

        pastLotteries = new CompletedLottoInfo[](Math.min(3, _pastLotteries.length));
        for (uint256 i = 0; i < pastLotteries.length; i++) {
            Lottery lotto = _pastLotteries[_pastLotteries.length - (i + 1)];
            pastLotteries[i] = CompletedLottoInfo(
                lotto.drawId(),
                lotto.ticketCount(),
                lotto.soldTickets(),
                lotto.holders(msg.sender),
                lotto.ticketPrice(),
                lotto.drawnAt(),
                lotto.first(),
                lotto.firstPrize(),
                lotto.second(),
                lotto.secondPrize(),
                lotto.third(),
                lotto.thirdPrize(),
                lotto.getConsolations(),
                lotto.consolationPrize()
            );
        } 
    }

    function getCurrentLottery(uint256 drawId) private view returns (Lottery lottery, uint256 index) {
        for (uint256 i = 0; i < _currentLotteries.length; i++) {
            if (_currentLotteries[i].drawId() == drawId) {
                lottery = _currentLotteries[i];
                index = i;
                return (lottery, index);
            }
        }

        revert("Unable to find a lottery with this id");
    }

    function setOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Cannot be 0 address");
        owner = newOwner;
    }

    function setAdmin(address admin, bool enabled) external onlyOwner {
        require(admin != address(0), "Cannot be 0 address");
        admins[admin] = enabled;
    }

    function setTaxWallets(address newMarketing, address newBuyback, address newLottoWallet) external onlyOwner {
        require(newMarketing != address(0) && newBuyback != address(0) && newLottoWallet != address(0), "Cannot be 0 address");
        marketingWallet = newMarketing;
        buybackWallet = newBuyback;
        lottoWallet = newLottoWallet;
    }

    function removeBnb() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }
    
    function removeTokens(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner, balance);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
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