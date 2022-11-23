// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IERC721.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";

abstract contract AccessCheck {

    mapping(address => bool) private admins;

    function _checkAdmin() internal view {
        require(admins[msg.sender], "admin role required");
    }

    function addAdmin(address _admin) external {
        _checkAdmin();
        _addAdmin(_admin);
    }

    function removeAdmin(address _admin) external {
        _checkAdmin();
        delete admins[_admin];
    }

    function _addAdmin(address _admin)  internal  {
        admins[_admin] = true;
    }

    function isAdmin(address _admin) public view returns (bool){
        return admins[_admin];
    }
}



contract INONFTAccount {
    mapping(address => mapping(address => uint256)) private balances;

    mapping(address => mapping(address => mapping(uint256 => uint256))) private tokens;

    mapping(address => mapping(address => mapping(uint256 => uint256))) private tokenIndex;

    event NFTWithdraw(address indexed owner, address indexed nftContract, uint256 indexed tokenId);



    mapping(address => mapping(uint256 => address)) private owners;

    function balanceOf(address addr, address nftContract) public view returns(uint256) {
        return balances[addr][nftContract];
    }

    function getToken(address addr, uint256 idx, address nftContract) public view returns(uint256) {
        return tokens[addr][nftContract][idx];
    }

    function ownerOf(address nftContract, uint256 tokenId) public view  returns(address) {
        
        IERC721 nft = IERC721(nftContract);
        address owner = nft.ownerOf(tokenId);
        
        if (owner == address(this)) {
            address contractOwner =  owners[nftContract][tokenId];
            return contractOwner;
        } else {
            return owner;
        }
    }

    function deposit(address nftContract, uint256 tokenId) internal {
        address dest = msg.sender;
        IERC721 nft = IERC721(nftContract);
        address owner = nft.ownerOf(tokenId);
        if (owner != address(this)) {
            require(owner == dest, "NFT Ownership is required.");
            require(nft.getApproved(tokenId) == address(this), "NFT Approvement is required.");
            nft.transferFrom(nft.ownerOf(tokenId), address(this), tokenId);
            _addTokenTo(nftContract, tokenId, dest);
        } else {
            require(dest == ownerOf(nftContract, tokenId), "Ownership in market contract is requried.");
        }
    }

    function innerTransfer(address nftContract, uint256 tokenId, address from, address to) internal {
        require(ownerOf(nftContract, tokenId) == from, "inner transfer ownership is required");
        
        _removeFromTokens(nftContract, tokenId, from);

        _addTokenTo(nftContract, tokenId, to);
    }

    function transfer(address nftContract, uint256 tokenId, address to) internal {
        IERC721 nft = IERC721(nftContract);
        address originalOwner = ownerOf(nftContract, tokenId);
        require(originalOwner == msg.sender, "[Transfer]Ownership is required");
        
        nft.safeTransferFrom(address(this), to, tokenId);
        _removeFromTokens(nftContract, tokenId, originalOwner);

        emit NFTWithdraw(to, nftContract, tokenId);
    }


    function _addTokenTo(address nftContract, uint256 tokenId, address to) internal {
        address dest = to;
        tokens[dest][nftContract][balanceOf(dest, nftContract)] = tokenId;
        tokenIndex[dest][nftContract][tokenId] = balanceOf(dest, nftContract);
        balances[dest][nftContract] += 1;
        owners[nftContract][tokenId] = dest;
    }

    function _removeFromTokens(address nftContract, uint256 tokenId, address from) internal {
        
        address originalOwner = ownerOf(nftContract, tokenId);
        require(originalOwner == from, "[Transfer]Ownership is required");

        uint256 index = tokenIndex[originalOwner][nftContract][tokenId];
        uint256 lastTokenId = tokens[originalOwner][nftContract][balanceOf(originalOwner, nftContract)];

        tokens[originalOwner][nftContract][index] = lastTokenId;
        tokenIndex[originalOwner][nftContract][lastTokenId] = index;

        delete tokens[originalOwner][nftContract][balanceOf(originalOwner, nftContract)];
        delete owners[nftContract][tokenId];

        balances[originalOwner][nftContract] -= 1;   
    }

}

contract INOAccount {
    mapping(address => uint256) private balances;
    address enftContract;
    mapping(address => uint256) private totalEarning;

    event WithdrawEvent(address indexed owner, address indexed to, uint256 amount);
    event IncreaseEvent(address indexed addr, uint256 indexed tokenId, uint256 amount, uint _type);

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "insufficient amount");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit WithdrawEvent(msg.sender, msg.sender, amount);
    }

    function balanceOf(address addr) public view returns(uint256) {
        return balances[addr];
    }

    function _increase(address addr, uint256 amount, uint256 tokenId, uint _type) internal {
        balances[addr] += amount;
        totalEarning[addr] += amount;
        emit IncreaseEvent(addr, tokenId, amount, _type);
    }

    function getTotalEarning(address addr) public view returns(uint256) {
        return totalEarning[addr];
    }
}


contract INOMarketV2 is INOAccount, AccessCheck, INONFTAccount{

    using SafeERC20 for IERC20;

    uint historyShares = 30;
    uint fee = 1;
    
    uint256 expireBlock = 28800 * 2;

    mapping(address => mapping(uint256 => uint256)) currentPrice;
    mapping(address => mapping(uint256 => uint256)) lastDealBlock;
    mapping(address => mapping(uint256 => uint256)) lastDealPrice;
    mapping(address => mapping(uint256 => mapping(uint => address))) historyTraders;
    mapping(address => mapping(uint256 => uint)) historyTradersCount;
    mapping(address => mapping(uint256 => address)) ipOwner; 
    mapping(address => mapping(uint256 => uint256)) airdropAmount;
    mapping(address => mapping(uint256 => address)) airdropContract;
    mapping(address => mapping(uint256 => uint256)) auctionStart;

    address feeTo;

    uint constant TYPE_TRADE = 1;
    uint constant TYPE_FEE = 2;
    uint constant TYPE_HISTORY = 3;
    uint constant TYPE_AUCTION = 4;

    event Trade(address indexed _nftContract, uint256 indexed _tokenId,  address _saller, address indexed _buyer,  uint256 _totalFee);
    event Auction(address indexed _nftContract, uint256 indexed _tokenId, uint256 _price, uint256 startBlock, address airdropContract, uint256 amount);
    event ReAuction(address indexed _nftContract, uint256 indexed _tokenId, uint256 _price, address airdropContract, uint256 amount);
    event WithdrawAirdrop(address indexed _nftContract, uint256 indexed _tokenId, address airdropContract, uint256 amount);

    bool pause;

    mapping(address => bool) unlimitNft;

    mapping(address => mapping(uint256 => uint256)) gmv; 

    constructor() {
        _addAdmin(msg.sender);
        feeTo = msg.sender;
    }

    function isUnlimitPriceNFT(address nftContract) public view returns(bool) {
        return unlimitNft[nftContract];
    }

    function getIpOwner(address nft, uint256 tokenId) public view returns(address) {
        return ipOwner[nft][tokenId];
    }

    function getCurrentPrice(address nftContract, uint256 tokenId) public view returns(uint256) {
        return currentPrice[nftContract][tokenId];
    }

    function getLastDealPrice(address nftContract, uint256 tokenId) public view returns(uint256) {
        return lastDealPrice[nftContract][tokenId];
    }

    function getLastDealBlock(address nftContract, uint256 tokenId) public view returns(uint256) {
        return lastDealBlock[nftContract][tokenId];
    }

    function isTokenLocked(address _nftContract, uint256  _tokenId) public view returns (bool) {
        return lastDealBlock[_nftContract][_tokenId] + expireBlock < block.number;
    }
    
    function isAuctionStart(address nftContract, uint256 tokenId) public view returns(bool) {
        return block.number >= auctionStart[nftContract][tokenId];
    }

    function getHistoryOwnersCount(address nftContract, uint256 tokenId) public view returns(uint) {
        return historyTradersCount[nftContract][tokenId];
    }

    function getHistoryOwner(address nft, uint256 tokenId, uint idx) public view returns(address) {
        return historyTraders[nft][tokenId][idx];
    } 

    function buy(address nftContract, uint256 tokenId) external payable {
        require(!pause, "INO: Trade paused");
        require(msg.value > 0, "Offer must greater than 0");
        require(!isTokenLocked(nftContract, tokenId), "INO: Token had been locked");
        
        uint256 price = currentPrice[nftContract][tokenId];
        require(price > 0, "INO: The price should greater than 0");
        require(msg.value >= price, 'INO: The price offered must greater than the current price');

        require(isAuctionStart(nftContract, tokenId), "INO: Not in auction time");
        
        uint256 tradeAmount = isUnlimitPriceNFT(nftContract) ? msg.value : price;
        
        address _saller = ownerOf(nftContract, tokenId);
        
        require(_saller !=  msg.sender, "INO: The NFT already is yours");

        innerTransfer(nftContract, tokenId, _saller, msg.sender);
        _increase(feeTo, tradeAmount / 100, tokenId, TYPE_TRADE);

        uint traderCount = historyTradersCount[nftContract][tokenId];
        if (traderCount > 0) {
            address ip = ipOwner[nftContract][tokenId];
            if (ip == address(0)) {
                _increase(_saller, tradeAmount * 98 / 100, tokenId, TYPE_TRADE);
            } else {
                _increase(ip, tradeAmount * 3 / 100, tokenId, TYPE_TRADE);
                _increase(_saller, tradeAmount * 95 / 100, tokenId, TYPE_TRADE);
            }
            uint min = historyShares > traderCount ? traderCount : historyShares;
            for (uint i = 0; i < min; i++) {
                address hOwner = historyTraders[nftContract][tokenId][traderCount - 1 - i];
                _increase(hOwner, tradeAmount / 100 / min, tokenId, TYPE_HISTORY);
            }
        } else {
            _increase(_saller, tradeAmount * 99 / 100, tokenId, TYPE_TRADE);
        }

        historyTraders[nftContract][tokenId][traderCount] = msg.sender;
        historyTradersCount[nftContract][tokenId] += 1;
                
        currentPrice[nftContract][tokenId] = tradeAmount * 111 / 100;

        lastDealBlock[nftContract][tokenId] = block.number;

        gmv[nftContract][tokenId] += tradeAmount;

        if (!isUnlimitPriceNFT(nftContract)) {
            if (msg.value - tradeAmount > 0) {
                safeTransferBNB(msg.sender, msg.value - tradeAmount);
            }
        }
        emit Trade(nftContract, tokenId, _saller, msg.sender, tradeAmount);   
    }

    function getTokenGMV(address nftContract, uint256 tokenId) public view returns(uint256){
        return gmv[nftContract][tokenId];
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'INO::safeTransferBNB: BNB transfer failed');
    }

    function withdrawNFT(address nftContract, uint256 tokenId) external {
        require(isTokenLocked(nftContract, tokenId), "Token is in auction");
        transfer(nftContract, tokenId, msg.sender);
    }

    function auction(address nftContract, uint256 tokenId, uint256 initPrice, address ip, address erc20contract, uint256 amount,uint256 startBlock) external {
        IERC721 nft = IERC721(nftContract);
        address addr = nft.getApproved(tokenId);
        require(initPrice > 0 , "INO: init price must greater than 0");
        require(addr == address(this), "INO: Not approved to INO");
        require(currentPrice[nftContract][tokenId] == 0, "INO: Must be first auction");
        require(isTokenLocked(nftContract, tokenId), "Token must be locked");
        require(startBlock >= block.number, "INO: start block must greater than block number");

        address owner = ownerOf(nftContract, tokenId);
        require(owner == msg.sender, "INO: Only owner can auction");

        deposit(nftContract, tokenId);

        ipOwner[nftContract][tokenId] = ip;
        currentPrice[nftContract][tokenId] = initPrice;
        

        if (amount > 0) {
            IERC20 erc20 = IERC20(erc20contract);
            erc20.safeTransferFrom(msg.sender, address(this),  amount);
        
            airdropAmount[nftContract][tokenId] = amount;
            airdropContract[nftContract][tokenId] = erc20contract;
        }
        
        auctionStart[nftContract][tokenId] = startBlock;
        lastDealBlock[nftContract][tokenId] = startBlock;
        
        emit Auction(nftContract, tokenId, initPrice, startBlock, erc20contract, amount);
    }

    function reAuction(address nftContract, uint256 tokenId, uint256 price, address acontract, uint256 amount ) external payable {

        require(isTokenLocked(nftContract, tokenId), "Token must be locked");
        require(price > 0 , "Price asked must be greater than 0");
        require(msg.value >= price / 100, "Re-auction fee is required(1%)");        

        address owner = ownerOf(nftContract, tokenId);
        require(owner == msg.sender, "INO: Only owner can auction");

        deposit(nftContract, tokenId);

        currentPrice[nftContract][tokenId] = price;
        lastDealBlock[nftContract][tokenId] = block.number;

        if (amount > 0) {
            airdropContract[nftContract][tokenId] = acontract;
            IERC20 erc20 = IERC20(acontract);
            erc20.safeTransferFrom(msg.sender, address(this),  amount);
        }
        _increase(feeTo, msg.value, tokenId, TYPE_AUCTION);
        airdropAmount[nftContract][tokenId] = amount;
        emit ReAuction(nftContract, tokenId, price, acontract, amount);
    }

    function withdrawAirdrop(address nftContract, uint256 tokenId, uint256 _amount) external {
        require(isTokenLocked(nftContract, tokenId), "Token must be locked");
        require(historyTradersCount[nftContract][tokenId] > 0 , "Token not trade yet");
        uint256 amount = airdropAmount[nftContract][tokenId];
        require(amount >= _amount, "insufficient airdrop " );
        require(amount > 0, "insufficient airdrop " );
        require(ownerOf(nftContract, tokenId) == msg.sender, "Ownership is required to withdraw airdrop tokens");

        if (airdropContract[nftContract][tokenId] != address(0)) {
            IERC20 token = IERC20(airdropContract[nftContract][tokenId]);
            token.safeTransfer(msg.sender, _amount);
            airdropAmount[nftContract][tokenId] -= _amount;
            emit WithdrawAirdrop(nftContract, tokenId, airdropContract[nftContract][tokenId], _amount);
        }
    }

    function getTokenAirdropAmount(address nftContract, uint256 tokenId) public view returns(uint256) {
        return airdropAmount[nftContract][tokenId];
    }

    function getTokenAirdropContract(address nftContract, uint256 tokenId) public view returns(address) {
        return airdropContract[nftContract][tokenId];
    }

    function setPause(bool _pause) external {
        _checkAdmin();
        pause = _pause;
    }

    function setFeeTo(address addr) external {
        _checkAdmin();
        feeTo = addr;
    }

    function setExpire(uint256 expire) external {
        _checkAdmin();
        expireBlock = expire;
    }

    function getFeeTo() public view returns (address) {
        return feeTo;
    }

    function getAuctionStart(address nftContract, uint256 tokenId) public view returns(uint256) {
        return auctionStart[nftContract][tokenId];
    }

    function addUnlimitPriceNFT(address nftContract) external {
        _checkAdmin();
        unlimitNft[nftContract] = true;
    }

    function removeUnlimitPriceNFT(address nftContract) external {
        _checkAdmin();
        delete unlimitNft[nftContract];
    }

    function getHistoryShares() public view returns(uint) {
        return historyShares;
    }

    function getFee() public view returns(uint) {
        return fee;
    }

    function getExpireBlocks() public view returns(uint) {
        return expireBlock;
    }

    function setHistoryShares(uint shares) external {
        _checkAdmin();
        historyShares = shares;
    }

    function setFee(uint _fee) external {
        _checkAdmin();
        fee = _fee;
    }

}