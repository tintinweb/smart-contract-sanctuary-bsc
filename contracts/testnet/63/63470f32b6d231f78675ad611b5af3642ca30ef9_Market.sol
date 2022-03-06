// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.12;

import './EnumerableSet.sol';
import './EnumerableMap.sol';
import './IERC20.sol';
import './IERC721.sol';
import './Math.sol';
import './SafeMath.sol';
import './Ownable.sol';
import './Runnable.sol';

contract Market is Ownable, Runnable {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeMath for uint256;

    address constant public BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    IERC20 public paymentToken;
    IERC721 public tokenNFT;

    uint256 public orderFee = 0;
    uint256 public burnFee = 0;
    address public feeAddress;
    uint256 public coolDownTime;

    //Store the latest time that token was withdrawn from contract
    mapping(uint256 => uint256) public _tokenWithdrawTime;

    EnumerableSet.UintSet private listTokenIdSale;
    mapping(uint256 => uint256) public _tokenPrice;
    mapping(uint256 => address) public _tokenSeller;
    mapping(address => EnumerableSet.UintSet) private _sellerTokens;
    uint256 constant public MULTIPLIER = 1000;

    struct OrderHistory {
        address buyer;
        address seller;
        uint256 timestamp;
        uint256 tokenId;
        uint256 price;
        uint256 receiveAmount;
        uint256 orderFeeAmount;
        uint256 burnFeeAmount;
    }

    mapping(address => OrderHistory[]) private listSellOrder;
    mapping(address => OrderHistory[]) private listCancelOrder;
    mapping(address => OrderHistory[]) private listBuyOrder;

    event MarketSell(address seller, uint256 tokenId, uint256 price, uint256 time);
    event MarketBuy(address buyer, address seller, uint256 tokenId, uint256 price, uint256 receiveAmount, uint256 orderFee, uint256 burnFee, uint256 time);
    event MarketUpdatePrice(uint256 tokenId, uint256 oldPrice, uint256 newPrice);
    event MarketCancel(uint256 tokenId);
    event AdminCancelOrder(uint256 tokenId);

    function marketSell(uint256 tokenId, uint256 price) public whenRunning {
        require(tokenNFT.ownerOf(tokenId) == msg.sender, "YOU ARE NOT OWNER OF THIS TOKEN");
        require(_tokenSeller[tokenId] == address(0), "TOKEN IS IN ORDER");
        require(price > 0, "TOKEN PRICE MUST BE GREATER THAN 0");
        require(_tokenWithdrawTime[tokenId] + coolDownTime <= block.timestamp, "PLEASE WAIT FOR COOL DOWN TIME");

        tokenNFT.transferFrom(msg.sender, address(this), tokenId);
        _tokenPrice[tokenId] = price;
        _tokenSeller[tokenId] = msg.sender;
        _sellerTokens[msg.sender].add(tokenId);
        listTokenIdSale.add(tokenId);
        emit MarketSell(msg.sender, tokenId, price, block.timestamp);
    }

    function marketBuy(uint256 tokenId) public whenRunning {
        require(_tokenPrice[tokenId] > 0, 'TOKEN PRICE NOT FOUND');
        require(_tokenSeller[tokenId] != address(0), "NOT FOUND TOKEN FOR SALE");

        address seller = _tokenSeller[tokenId];

        uint256 price = _tokenPrice[tokenId];
        uint256 orderFeeAmount = 0;
        uint256 burnFeeAmount = 0;
        uint256 receiveAmount = 0;
        if (price > 0) {
            orderFeeAmount = price.mul(orderFee).div(MULTIPLIER);
            burnFeeAmount = price.mul(burnFee).div(MULTIPLIER);
            receiveAmount = price.sub(orderFeeAmount).sub(burnFeeAmount);
            require(paymentToken.transferFrom(msg.sender, seller, receiveAmount), "FAIL TO TRANSFER TO SELLER");
            if (orderFeeAmount > 0) {
                require(paymentToken.transferFrom(msg.sender, feeAddress, orderFeeAmount), "FAIL TO TRANSFER TO FEE ADDRESS");
            }
            if (burnFeeAmount > 0) {
                require(paymentToken.transferFrom(msg.sender, BURN_ADDRESS, burnFeeAmount), "FAIL TO TRANSFER TO BURN ADDRESS");
            }
        }
        tokenNFT.transferFrom(address(this), msg.sender, tokenId);
        delete _tokenPrice[tokenId];
        delete _tokenSeller[tokenId];
        _sellerTokens[seller].remove(tokenId);
        _tokenWithdrawTime[tokenId] = block.timestamp;

        OrderHistory memory orderHistory = OrderHistory(msg.sender, seller, block.timestamp, tokenId, price, receiveAmount, orderFeeAmount, burnFeeAmount);
        listBuyOrder[msg.sender].push(orderHistory);
        listSellOrder[seller].push(orderHistory);
        listTokenIdSale.remove(tokenId);
        emit MarketBuy(msg.sender, seller, tokenId, price, receiveAmount, orderFeeAmount, burnFeeAmount, block.timestamp);
    }

    function marketUpdatePrice(uint256 tokenId, uint256 newPrice) public whenRunning {
        require(_sellerTokens[msg.sender].contains(tokenId), 'ONLY SELLER CAN UPDATE PRICE');
        require(newPrice > 0, "TOKEN PRICE MUST BE GREATER THAN 0");
        uint256 oldPrice = _tokenPrice[tokenId];
        _tokenPrice[tokenId] = newPrice;
        emit MarketUpdatePrice(tokenId, oldPrice, newPrice);
    }

    function marketCancel(uint256 tokenId) public whenRunning {
        require(listTokenIdSale.contains(tokenId), 'TOKEN NOT IN SALE');
        require(_sellerTokens[msg.sender].contains(tokenId), 'ONLY SELLER CAN CANCEL THIS ORDER');
        tokenNFT.transferFrom(address(this), msg.sender, tokenId);

        _sellerTokens[msg.sender].remove(tokenId);
        listCancelOrder[msg.sender].push(OrderHistory(address(0), msg.sender, block.timestamp, tokenId, _tokenPrice[tokenId], 0, 0, 0));
        listTokenIdSale.remove(tokenId);
        delete _tokenPrice[tokenId];
        delete _tokenSeller[tokenId];
        emit MarketCancel(tokenId);
    }

    function adminCancelOrder(uint256 tokenId) public onlyOwner {
        require(listTokenIdSale.contains(tokenId), 'TOKEN NOT IN SALE');
        address seller = _tokenSeller[tokenId];
        tokenNFT.transferFrom(address(this), msg.sender, tokenId);

        _sellerTokens[seller].remove(tokenId);
        listCancelOrder[seller].push(OrderHistory(address(0), seller, block.timestamp, tokenId, _tokenPrice[tokenId], 0, 0, 0));
        listTokenIdSale.remove(tokenId);
        delete _tokenPrice[tokenId];
        delete _tokenSeller[tokenId];
        emit AdminCancelOrder(tokenId);
    }

    function setPaymentToken(address newAddress) public onlyOwner {
        require(newAddress != address(0), "Address 0");
        paymentToken = IERC20(newAddress);
    }

    function setTokenNFT(address newAddress) public onlyOwner {
        require(newAddress != address(0), "Address 0");
        tokenNFT = IERC721(newAddress);
    }

    function setOrderFee(uint256 newValue) public onlyOwner {
        require(newValue <= 1000, "INVALID VALUE");
        orderFee = newValue;
    }

    function setBurnFee(uint256 newValue) public onlyOwner {
        require(newValue <= 1000, "INVALID VALUE");
        burnFee = newValue;
    }

    function setFeeAddress(address payable newFeeAddress) public onlyOwner {
        feeAddress = newFeeAddress;
    }

    function setCoolDownTime(uint256 newValue) public onlyOwner {
        coolDownTime = newValue;
    }

    function marketInfo() public view returns (address receiveFeeAddress, uint256 orderFeePercent, uint256 burnFeePercent, uint256 coolDown, uint256 orderNumber) {
        return (feeAddress, orderFee, burnFee, coolDownTime, listTokenIdSale.length());
    }

    function getOrdersByPage(uint256 pageNum, uint256 pageSize) external view returns (uint256[] memory listTokenId, uint256[] memory listPrice, uint256 total) {
        total = listTokenIdSale.length();
        uint256 from = pageNum * pageSize;

        if (total <= from) {
            return (new uint256[](0), new uint256[](0), total);
        }

        uint256 minNum = Math.min(total - from, pageSize);

        listTokenId = new uint256[](minNum);
        listPrice = new uint256[](minNum);

        for (uint256 i = 0; i < minNum; i++) {
            (listTokenId[i], listPrice[i]) = (listTokenIdSale.at(from), _tokenPrice[listTokenIdSale.at(from)]);
            from++;
        }
    }

    function getOrdersByUserByPage(address userAddress, uint256 pageNum, uint256 pageSize) public view returns (uint256[] memory listTokenId, uint256[] memory listPrice, uint256 total) {
        total = _sellerTokens[userAddress].length();
        uint256 from = pageNum * pageSize;
        if (total <= from) {
            return (new uint256[](0), new uint256[](0), total);
        }
        uint256 minNum = Math.min(total - from, pageSize);

        listTokenId = new uint256[](minNum);
        listPrice = new uint256[](minNum);

        for (uint256 i = 0; i < minNum; i++) {
            listTokenId[i] = _sellerTokens[userAddress].at(from++);
            listPrice[i] = _tokenPrice[listTokenId[i]];
        }
    }

    function getOrdersByUserByTypeByPage(address userAddress, uint256 orderType, uint256 pageNum, uint256 pageSize) public view returns (uint256[] memory timestamps, uint256[] memory tokenIds, uint256[] memory listPrice, uint256[] memory listReceiveAmount, uint256[] memory orderFeeAmount, uint256[] memory burnFeeAmount, uint256 total) {
        OrderHistory[] memory orderHistory;
        if (orderType == 0) {
            orderHistory = listSellOrder[userAddress];
            total = listSellOrder[userAddress].length;
        } else if (orderType == 1) {
            orderHistory = listCancelOrder[userAddress];
            total = listCancelOrder[userAddress].length;
        } else {
            orderHistory = listBuyOrder[userAddress];
            total = listBuyOrder[userAddress].length;
        }

        uint256 from = pageNum * pageSize;
        if (total <= from) {
            return (new uint256[](0), new uint256[](0), new uint256[](0), new uint256[](0), new uint256[](0), new uint256[](0), total);
        }

        uint256 minNum = Math.min(total - from, pageSize);
        from = total - from - 1;

        timestamps = new uint256[](minNum);
        tokenIds = new uint256[](minNum);
        listPrice = new uint256[](minNum);
        listReceiveAmount = new uint256[](minNum);
        orderFeeAmount = new uint256[](minNum);
        burnFeeAmount = new uint256[](minNum);

        for (uint256 i = 0; i < minNum; i++) {
            timestamps[i] = uint256(orderHistory[from].timestamp);
            tokenIds[i] = uint256(orderHistory[from].tokenId);
            listPrice[i] = uint256(orderHistory[from].price);
            listReceiveAmount[i] = uint256(orderHistory[from].receiveAmount);
            orderFeeAmount[i] = uint256(orderHistory[from].orderFeeAmount);
            burnFeeAmount[i] = uint256(orderHistory[from].burnFeeAmount);
            if (from > 0) {
                from--;
            }
        }
    }

    function getOrderByTokenId(uint256 tokenId) external view returns (address, uint256) {
        if (!listTokenIdSale.contains(tokenId)) {
            return (address(0), 0);
        }
        return (_tokenSeller[tokenId], _tokenPrice[tokenId]);
    }

    function listOrderLength(address userAddress, uint256 orderType) external view returns (uint256 total) {
        if (orderType == 0) {
            total = listSellOrder[userAddress].length;
        } else if (orderType == 1) {
            total = listCancelOrder[userAddress].length;
        } else {
            total = listBuyOrder[userAddress].length;
        }
        return total;
    }

    function orderAtIndex(address userAddress, uint256 orderType, uint256 index) external view returns (address buyer,
        address seller,
        uint256 timestamp,
        uint256 tokenId,
        uint256 price,
        uint256 receiveAmount,
        uint256 orderFeeAmount,
        uint256 burnFeeAmount
    ) {
        OrderHistory memory orderHistory;
        if (orderType == 0) {
            orderHistory = listSellOrder[userAddress][index];
        } else if (orderType == 1) {
            orderHistory = listCancelOrder[userAddress][index];
        } else {
            orderHistory = listBuyOrder[userAddress][index];
        }

        return (orderHistory.buyer, orderHistory.seller, orderHistory.timestamp, orderHistory.tokenId, orderHistory.price, orderHistory.receiveAmount, orderHistory.orderFeeAmount, orderHistory.burnFeeAmount);
    }

    function retrieveToken(address tokenAddress, uint256 amount, address receiveAddress) external onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(receiveAddress, amount);
    }

    function retrieveMainBalance(address receiveAddress) external onlyOwner {
        payable(receiveAddress).transfer(address(this).balance);
    }

    function withdrawNft(address nftAddress, uint256 tokenId, address receiveAddress) external onlyOwner {
        require(receiveAddress != address(0), "recipient is zero address");
        IERC721(nftAddress).safeTransferFrom(address(this), receiveAddress, tokenId);
    }

    function batchWithdrawNft(address nftAddress, uint256[] memory tokenIds, address receiveAddress) external onlyOwner {
        require(receiveAddress != address(0), "Receive address is zero address");
        require(tokenIds.length > 0, "tokenIds is empty");
        for (uint256 index = 0; index < tokenIds.length; index++) {
            IERC721(nftAddress).safeTransferFrom(address(this), receiveAddress, tokenIds[index]);
        }
    }
}