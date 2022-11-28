//SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./ERC721Enumerable.sol";
import "./IERC721Receiver.sol";


interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IFreeper{
    function getTokenIdCreator(uint tokenId) external view returns(address);
}


contract Exchange is Ownable, IERC721Receiver {
    
    using SafeMath for uint256;

    struct Order{
        uint256 tokenId;
        uint256 price;
        uint256 supportedToken;
        uint256 open_time;
        uint256 close_time;
        uint256 status;     
        uint256 orderType;  
        address creator;
        uint256 expiredTime;
       
    }

    struct BidOrder{
        uint256 tokenId;
        uint256 bidPrice;
        uint256 supportedToken;
        uint256 open_time;
        uint256 bid_time;
        address bider;
        uint256 status;
        address creator;
        uint256 buyExpiredTime;
    }

    struct SupportToken{
        address contractAddress;
        bool status;
    }

    address public feeAddress = 0xEcEcb22557Bd58091306BFD2789363363C6FB8cD;
    // address public nftAddress;
    address public freeperAddress;

    mapping(uint256 => SupportToken) public tokens;

    uint256 public creatorFeeRate = 100;    //10%
    uint256 public feeRate = 25;
    
    bool needDeposit = false;
    uint256 depositRate = 100;

    uint public stepTime = 1 days;



    mapping(bytes32=>Order) public orders;
    mapping(bytes32=>BidOrder) public bidOrders;
    mapping(bytes32 => Order) public offerOrder;
    mapping(bytes32 => Order) public targetOrder;
    mapping(uint => bytes32) public linkOrder;

    mapping (uint256 => uint256) tokenInOrder;

    event MakeOrder(address indexed addr, bytes32 indexed orderId, uint256 indexed tokenId, uint256 supportedToken, uint256 price,uint256 expiredTime);
    event MakeOffer(address indexed addr, bytes32 indexed orderId, uint256 indexed tokenId, uint256 supportedToken, uint256 price,uint256 expiredTime);
    event MakeBidOrder(address indexed addr,bytes32 indexed orderId, uint256 indexed tokenId, uint256 supportedToken, uint256 price, uint endTime);


    event DealOrder(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 supportedToken, uint256 price);

    event BidOrderEvent(address indexed bider, bytes32 indexed orderId, uint256 indexed price);

    event CancelOrder(address indexed addr, bytes32 indexed orderId);
    event CancelBidOrder(address indexed addr, bytes32 indexed orderId);
    event CancelOffer(address indexed addr, uint256 tokneId);

    event CreatorReward(address indexed addr, address indexed from, uint amount);

    mapping(address => bool) public isWhitelisted;

    constructor() public {
        freeperAddress = 0x627F254A1F8004FAEC6C34fAd0F5A18d3E15e972;
        isWhitelisted[msg.sender] = true;
    }

    modifier onlyWhiteList(){
        require(isWhitelisted[msg.sender],"not in whiltelist");
        _;
    }

    function setFeeRate(uint rate)public onlyWhiteList{
        require(rate < 1000, "rate is too high");
        feeRate = rate;
    }

    function setCreateFeeRate (uint rate )public onlyWhiteList {
        require(rate < 1000, "rate is too high");
        creatorFeeRate = rate;
    }

    function setFeeAddress(address addr) public onlyWhiteList{
        feeAddress = addr;
    }

    function setSupportedToken(uint256 index, address contractAddress)public onlyWhiteList{
        tokens[index].contractAddress = contractAddress;
        tokens[index].status = true;
    }

    function disableSupportedToken(uint256 index) public onlyWhiteList{
        tokens[index].status = false;
    }

    function makeOffer(uint256 tokenId, uint256 price, uint256 supportedToken, uint256 limitTime) public {
        require(tokens[supportedToken].status, "supported token is not active");
        require(IERC20(tokens[supportedToken].contractAddress).allowance(msg.sender, address(this)) >= price, "not enough allowance");
        require(IERC20(tokens[supportedToken].contractAddress).balanceOf(msg.sender) >= price, "not enough balance");
        address addr = IFreeper(freeperAddress).getTokenIdCreator(tokenId);
        bytes32 id = keccak256(abi.encodePacked(msg.sender,"4",tokenId, block.timestamp));
        require(addr != address(0),"invaild tokenid");
        offerOrder[id].creator = msg.sender;
        offerOrder[id].price = price;
        offerOrder[id].supportedToken = supportedToken;
        offerOrder[id].open_time = block.timestamp;
        offerOrder[id].orderType = 0;
        offerOrder[id].status = 1;
        offerOrder[id].expiredTime = block.timestamp.add(limitTime);
        offerOrder[id].tokenId = tokenId;

        emit MakeOffer(msg.sender, id, tokenId, supportedToken, price,offerOrder[id].expiredTime);
    }

    function dealOfferOrder(bytes32 orderId) public {
        require(offerOrder[orderId].status == 1, "offer has been finished");
        require(offerOrder[orderId].expiredTime > block.timestamp, "offer order times up");
        require(IERC721(freeperAddress).ownerOf(offerOrder[orderId].tokenId) == msg.sender,"not the owner");
        require(IERC721(freeperAddress).getApproved(offerOrder[orderId].tokenId) == address(this) || IERC721(freeperAddress).isApprovedForAll(msg.sender, address(this)),"nft not approved");
        
        IERC721(freeperAddress).safeTransferFrom(msg.sender, offerOrder[orderId].creator, offerOrder[orderId].tokenId);
        address addr = IFreeper(freeperAddress).getTokenIdCreator(offerOrder[orderId].tokenId);
        require(addr != address(0),"invaild tokenid");
        require(IERC20(tokens[offerOrder[orderId].supportedToken].contractAddress).allowance(offerOrder[orderId].creator, address(this)) >= offerOrder[orderId].price, "not enough allowance");
        uint fee =  offerOrder[orderId].price.mul(feeRate).div(1000);
        if(addr != msg.sender){
            uint256 cfee = offerOrder[orderId].price.mul(creatorFeeRate).div(1000);
            IERC20(tokens[offerOrder[orderId].supportedToken].contractAddress).transferFrom(offerOrder[orderId].creator, addr, cfee); 
            emit CreatorReward(addr, msg.sender, cfee);

            IERC20(tokens[offerOrder[orderId].supportedToken].contractAddress).transferFrom(offerOrder[orderId].creator,msg.sender, offerOrder[orderId].price.sub(fee).sub(cfee));
        }else{
            IERC20(tokens[offerOrder[orderId].supportedToken].contractAddress).transferFrom(offerOrder[orderId].creator,msg.sender, offerOrder[orderId].price.sub(fee));
        }
        offerOrder[orderId].status = 0;
        IERC20(tokens[offerOrder[orderId].supportedToken].contractAddress).transferFrom(offerOrder[orderId].creator,feeAddress, fee);
      
        emit DealOrder(msg.sender,  offerOrder[orderId].creator, offerOrder[orderId].tokenId, offerOrder[orderId].supportedToken, offerOrder[orderId].price);
    }

    function cancelOfferOrder(bytes32 orderId) public {
        require(offerOrder[orderId].status == 1, "offer order has been finished");
        require(offerOrder[orderId].creator == msg.sender,"you couldn't cancel this order");
        offerOrder[orderId].status = 2;
        emit CancelOffer(msg.sender, offerOrder[orderId].tokenId);
    }


    function makeOrder(uint256 tokenId, uint price, uint256 supportedToken,uint256 limitTime) public returns (bytes32){
        require(tokens[supportedToken].status, "supported token is not active");
        require(tokenInOrder[tokenId] < block.timestamp,"token has order, can't create new order");
        require(IERC721(freeperAddress).ownerOf(tokenId) == msg.sender,"nft not yours, you can't sell");
        require(IERC721(freeperAddress).getApproved(tokenId) == address(this) || IERC721(freeperAddress).isApprovedForAll(msg.sender, address(this)),"nft not approved");
        bytes32 id = keccak256(abi.encodePacked(msg.sender,"1",tokenId, block.timestamp));
        orders[id].tokenId = tokenId;
        orders[id].price = price;
        orders[id].supportedToken = supportedToken;
        orders[id].open_time = block.timestamp;
        orders[id].status = 1;
        orders[id].orderType = 1;
        orders[id].creator = msg.sender;
        orders[id].expiredTime = block.timestamp.add(limitTime);
        emit MakeOrder(msg.sender,id, tokenId,supportedToken,price,orders[id].expiredTime);
        tokenInOrder[tokenId] = orders[id].expiredTime;
        return id;
    }

    function makeBidOrder(uint256 tokenId, uint bidPrice, uint256 supportedToken, uint256 endTime) public returns (bytes32){
        require(tokens[supportedToken].status, "supported token is not active");
        require(endTime >0 && endTime <=3,"end time is invalid");
        require(tokenInOrder[tokenId] < block.timestamp,"token has order, can't create new order");
        require(bidPrice > 0 , "bid price can not be zero");
        require(IERC721(freeperAddress).ownerOf(tokenId) == msg.sender,"nft not yours, you can't sell");
        require(IERC721(freeperAddress).getApproved(tokenId) == address(this) || IERC721(freeperAddress).isApprovedForAll(msg.sender, address(this)),"nft not approved");
        bytes32 id = keccak256(abi.encodePacked(msg.sender,"2",tokenId, block.timestamp));
        bidOrders[id].tokenId = tokenId;
        bidOrders[id].bidPrice = bidPrice;
        bidOrders[id].supportedToken = supportedToken;
        bidOrders[id].open_time = block.timestamp;
        bidOrders[id].bid_time = block.timestamp + (endTime * stepTime);
        bidOrders[id].bider = address(0);
        bidOrders[id].status = 1;
        bidOrders[id].creator = msg.sender;
        
        
         // only for test, in stable version it will set 24 hours
        bidOrders[id].buyExpiredTime = bidOrders[id].bid_time + stepTime; 



        emit MakeBidOrder(msg.sender, id, tokenId, supportedToken, bidPrice, bidOrders[id].bid_time);
        
        return id;
    }

    function cancelOrder(bytes32 id) public{
        require(orders[id].creator == msg.sender, "this order is not yours");
        require(orders[id].status == 1,"order has been finished");
        orders[id].status = 3;
        tokenInOrder[orders[id].tokenId] = 0;
        emit CancelOrder(msg.sender, id);
    }

    function cancelBidOrder(bytes32 id) public{
        require(bidOrders[id].creator == msg.sender, "this order is not yours");
        require(bidOrders[id].bider == address(0) && bidOrders[id].bid_time < block.timestamp,"this order can't be canceled");
        require(bidOrders[id].status == 1,"this order can't be canceled");
        bidOrders[id].status = 3;
        tokenInOrder[bidOrders[id].tokenId] = 0;
        emit CancelBidOrder(msg.sender, id);
    }

    function dealOrder(bytes32 id)public{
        require(orders[id].status == 1,"order has been finished");
        require(orders[id].creator != msg.sender,"you can not deal self order");
        require(orders[id].expiredTime > block.timestamp,"order reach time limit");
        require(IERC721(freeperAddress).ownerOf(orders[id].tokenId) == orders[id].creator, "nft has been sold");
        require(IERC721(freeperAddress).getApproved(orders[id].tokenId) == address(this) || IERC721(freeperAddress).isApprovedForAll(orders[id].creator, address(this)), "nft not approved, please contract seller");
        
        if(orders[id].orderType==1){ 
            IERC721(freeperAddress).safeTransferFrom(orders[id].creator, msg.sender,orders[id].tokenId); 
            address addr = IFreeper(freeperAddress).getTokenIdCreator(orders[id].tokenId);
            require(addr != address(0),"invaild tokenid");
            uint256 cfee = orders[id].price.mul(creatorFeeRate).div(1000);
            uint256 fee = orders[id].price.mul(feeRate).div(1000);
            IERC20(tokens[orders[id].supportedToken].contractAddress).transferFrom(msg.sender, addr, cfee);  
            emit CreatorReward(addr, msg.sender, cfee);

            IERC20(tokens[orders[id].supportedToken].contractAddress).transferFrom(msg.sender, feeAddress, fee); 
            IERC20(tokens[orders[id].supportedToken].contractAddress).transferFrom(msg.sender, orders[id].creator, orders[id].price.sub(fee).sub(cfee)); //剩余费用给卖家

        }
        orders[id].status = 2;
        tokenInOrder[orders[id].tokenId] = 0;
        emit DealOrder( orders[id].creator,msg.sender, orders[id].tokenId, orders[id].supportedToken, orders[id].price);
        

    }

    function bid(bytes32 id, uint256 price) public{
        require(bidOrders[id].status == 1, "this order has been finished");
        require(bidOrders[id].bid_time > block.timestamp, "it's out of time");
        require(bidOrders[id].bidPrice < price, "bid price is too low");
        require(IERC20(tokens[bidOrders[id].supportedToken].contractAddress).allowance(msg.sender, address(this)) >= price, "not enough allowance");
        require(IERC20(tokens[bidOrders[id].supportedToken].contractAddress).balanceOf(msg.sender) >= price, "not enough balance");
        bidOrders[id].bider = msg.sender;
        bidOrders[id].bidPrice = price;
        tokenInOrder[bidOrders[id].tokenId] = bidOrders[id].buyExpiredTime;
        emit BidOrderEvent(msg.sender, id, price);
    }


    function collectNft(bytes32 id) public{
        require(bidOrders[id].status == 1,"bid order has been finished");
        require(bidOrders[id].bid_time < block.timestamp, "bid order is not reach the time");
        require(bidOrders[id].buyExpiredTime >= block.timestamp, "bid order is reached end time");
        require(IERC721(freeperAddress).ownerOf(bidOrders[id].tokenId) == bidOrders[id].creator, "nft has been sold");
        require(IERC721(freeperAddress).getApproved(bidOrders[id].tokenId) == address(this) || IERC721(freeperAddress).isApprovedForAll(bidOrders[id].creator, address(this)), "nft not approved, please contract seller");
        require(IERC20(tokens[bidOrders[id].supportedToken].contractAddress).allowance(bidOrders[id].bider, address(this)) >= bidOrders[id].bidPrice, "not enough allowance");
        require(IERC20(tokens[bidOrders[id].supportedToken].contractAddress).balanceOf(bidOrders[id].bider) >= bidOrders[id].bidPrice, "not enough balance");

        IERC721(freeperAddress).safeTransferFrom(bidOrders[id].creator, bidOrders[id].bider, bidOrders[id].tokenId); 

        address addr = IFreeper(freeperAddress).getTokenIdCreator(bidOrders[id].tokenId);
        require(addr != address(0),"invaild tokenid");
        uint256 cfee = bidOrders[id].bidPrice.mul(creatorFeeRate).div(1000);
        uint256 fee = bidOrders[id].bidPrice.mul(feeRate).div(1000);

        IERC20(tokens[bidOrders[id].supportedToken].contractAddress).transferFrom(bidOrders[id].bider, addr, cfee);  
        emit CreatorReward(addr, bidOrders[id].creator, cfee);

        IERC20(tokens[bidOrders[id].supportedToken].contractAddress).transferFrom(bidOrders[id].bider, feeAddress, fee); 
        IERC20(tokens[bidOrders[id].supportedToken].contractAddress).transferFrom(bidOrders[id].bider, bidOrders[id].creator, bidOrders[id].bidPrice.sub(fee).sub(cfee)); //剩余费用给卖家
        bidOrders[id].status = 2;
        tokenInOrder[bidOrders[id].tokenId] = 0;
        emit DealOrder(bidOrders[id].creator,bidOrders[id].bider,bidOrders[id].tokenId,bidOrders[id].supportedToken,bidOrders[id].bidPrice);
    }



    function collectProfit(bytes32 id) public{
        collectNft(id);
    }
    
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4){
        return this.onERC721Received.selector;
    }


}