pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier: SimPL-2.0


import "./IERC20.sol";
import "./IERC721.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Member.sol";


interface INFT{
    function transferFrom(address _from,address _to,uint256 _tokenId)external;
    function approve(address _approved,uint256 _tokenId) external;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;
    function viewTokenID() view external returns(uint256);
    function setTokenTypeAttributes(uint256 _tokenId,uint8 _typeAttributes,uint256 _tvalue) external;
    function transferList(address _to,uint256[] calldata _tokenIdList) external;
    function ownerOf(uint256 _tokenID) external returns (address _owner);
    function starAttributes(uint256 _tokenID) external view returns(address,string memory,uint256,uint256,uint256,bool);
}


contract NFTExchange is Member{
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    event CreateOrder(address indexed maker, uint256 indexed tokenid, bool canExchange, uint256 payAmount, uint8 payment);
    event TradeOrder(uint256 indexed tokenid, address maker, address taker, bytes32 orderid, uint256 payAmount, uint8 payment);
    event CancelOrder(uint256 indexed tokenid);
    event ChangeTxFee(uint256 txFees,uint256 newTxFee);

       


    // event TradeOrder(uint256 tokenid,address maker,address sender,uint256 orderid,uint256 payamount,uint8 payment);
    // event CreateAuctionOrder(address indexed creater, uint256 tokenid, uint256 acutionAmount);
    event HighestBidIncreased(address bidder, uint amount, uint256 tokenid, uint8 payment);
    event AuctionEnded(address winner, uint amount, uint256 tokenId, uint8 payment);


    // struct AuctionOrder {
    //     address     maker;         //发起者
    //     uint256     nftid;
    //     uint256     auctionAmount;       //拍卖价格
    //     // bool        isBid;       //是否拍卖出去
    //     bool       payment;
       
    // }

    struct ExchangeOrder {
        address     maker;
        address     taker;
        uint256     nftid;
        uint256     payAmount;
        uint256     createTime;
        uint256     tradeTime;
        uint8       payment;
        bool        canExchange;
    }

    struct TakerOrder {
        address     taker;         //发起者
        uint256     auctionAmount;       //拍卖价格
    }


    // mapping(uint256 => AuctionOrder) private auctionOrders;
    mapping(uint256 => mapping(address=>TakerOrder)) private takerOrders;
    mapping(uint256 => address[]) private auctionOrdersArray;

    mapping(uint256 => ExchangeOrder) private makerOrders;
    mapping(bytes32 => ExchangeOrder) private tradeOrders;
    uint256 public  txFees = 25;

    IERC20 public usdt;
    IERC20 public era;

    constructor(IERC20 _usdt, IERC20 _era)
         {
            usdt = _usdt;
            era = _era;
    }

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    
    function createOrder(uint256 tokenid, uint256 tradePrice,uint8 payment, bool canExchange) external {    //创建订单
        require(makerOrders[tokenid].maker == address(0), "Exists Order!");
        if(canExchange == false) {
            require(tradePrice == 2**256 - 1);
        }
        (,,,,,bool isOffical) = INFT(manager.members("nft")).starAttributes(tokenid);
        if(isOffical == true) {
            require(payment == 2, "offical NFT can only support ERA token");
        }
        IERC721(manager.members("nft")).transferFrom(msg.sender, address(this), tokenid);   //调用者转入自身token到本合约
        makerOrders[tokenid].maker = msg.sender;
        makerOrders[tokenid].nftid = tokenid;
        makerOrders[tokenid].payAmount = tradePrice;
        makerOrders[tokenid].payment = payment;
        makerOrders[tokenid].createTime = block.timestamp;
        makerOrders[tokenid].canExchange = canExchange;
        emit CreateOrder(msg.sender, tokenid, canExchange, tradePrice,payment);
    }


    function changePrice(uint256 tokenid, uint256 newPrice) public returns(bool){
        require(block.timestamp > makerOrders[tokenid].createTime,"Time wrong!");
        require(makerOrders[tokenid].maker == msg.sender, "Only Order Creater!");
        require(makerOrders[tokenid].canExchange == true);
        makerOrders[tokenid].payAmount = newPrice;
        makerOrders[tokenid].createTime = block.timestamp;
        return true;
    }

    
    function takeOrder(uint256 tokenid) external payable {
        require(!isContract(msg.sender), "Address: call to non-contract");
        require(msg.sender == tx.origin,"Only EOA!");
        ExchangeOrder memory order = makerOrders[tokenid];
        require(order.maker != address(0), "Not Exists Order!");
        require(makerOrders[tokenid].canExchange == true);
        uint256 payAmount = order.payAmount;
        
        uint256 tradeFee = payAmount.mul(txFees).div(1000);   //收取2.5%的手续费

        (address origin,,,,uint256 stampFees,) = INFT(manager.members("nft")).starAttributes(tokenid);
        
        uint256 stampFee = payAmount.mul(stampFees).div(1000);   //收取版税
        uint256 sendAmount = payAmount.sub(tradeFee).sub(stampFee);
        uint8 payment  = makerOrders[tokenid].payment;
        if (payment == 0) {
            require(msg.value == payAmount);
            payable(manager.members("funder")).transfer(tradeFee);
            payable(origin).transfer(stampFee);
            payable(order.maker).transfer(sendAmount);
        } else {
            IERC20 token;
            if (payment == 1) {
                token = usdt;
            }
            if (payment == 2) {
                token = era;
            }
            IERC20(token).safeTransferFrom(msg.sender, manager.members("funder"), tradeFee);
            IERC20(token).safeTransferFrom(msg.sender, origin, stampFee);
            IERC20(token).safeTransferFrom(msg.sender, order.maker, sendAmount);
        }
        IERC721(manager.members("nft")).transferFrom(address(this), msg.sender, tokenid);  //将nft发送给购买者
        
        order.taker = msg.sender;
        order.tradeTime = block.timestamp;
        bytes32 orderid = keccak256(abi.encode(
            tokenid,
            order.maker,
            order.taker,
            block.number
        ));
        
        delete makerOrders[tokenid];
        tradeOrders[orderid] = order;             //增加订单购买信息
        emit TradeOrder(tokenid, order.maker, msg.sender, orderid, payAmount, payment);
    }
    
    function cancelOrder(uint256 tokenid) external {         //取消订单
        ExchangeOrder memory order = makerOrders[tokenid];
        require(order.maker == msg.sender, "invalid card");
        IERC721(manager.members("nft")).transferFrom(address(this), msg.sender, tokenid);
        delete makerOrders[tokenid];
        emit CancelOrder(tokenid);
    }
    
    function getMakerOrder(uint256 tokenid) external view returns(ExchangeOrder memory) {
        return makerOrders[tokenid];
    }
    
    function getTradeOrder(bytes32 tokenid) external view returns(ExchangeOrder memory) {
        return tradeOrders[tokenid];
    }

    function setTxFee(uint256 newTxFee) public {
        require(msg.sender == manager.members("owner"));
        require(newTxFee <= 200, "tx Fee to high!");
        emit ChangeTxFee(txFees,newTxFee);
        txFees = newTxFee;
       
    }

    function bid(uint256 tokenid, uint256 acutionAmount) public  payable{
        require(!isContract(msg.sender), "Address: call to non-contract");
        require(msg.sender == tx.origin,"Only EOA!");
        address user = msg.sender;
        uint8 payment = makerOrders[tokenid].payment;
        uint256 oldAuctionAmount = takerOrders[tokenid][user].auctionAmount;
        // require(
        //     acutionAmount < makerOrders[tokenid].payAmount,
        //     "You can take order instead of bidding"
        // );
        // require(takerOrders[tokenid][user].taker == address(0), "You have bided!");
        if(!(takerOrders[tokenid][user].taker == address(0))){                  //Rebid
            
            if (payment == 0) {
                
                payable(user).transfer(oldAuctionAmount);
            } else {
                IERC20 token;
                if (payment == 1) {
                    token = usdt;
                }
                if (payment == 2) {
                    token = era;
                } 
                IERC20(token).transfer(user,oldAuctionAmount);
            }
        }
        
        if (payment == 0) {
            require(msg.value == acutionAmount);
            // address(this).transfer(acutionAmount);
        } else {
            IERC20 token;
            if (payment == 1) {
                token = usdt;
            }
            if (payment == 2) {
                token = era;
            } 
            IERC20(token).transferFrom(msg.sender, address(this), acutionAmount);
        }
        takerOrders[tokenid][user].taker = user;
        takerOrders[tokenid][user].auctionAmount = acutionAmount;
   
        // auctionOrders[tokenid].isBid = true;
        if(oldAuctionAmount == 0){           //Only first bid
            auctionOrdersArray[tokenid].push(user);
        } 
        emit HighestBidIncreased(msg.sender, acutionAmount, tokenid, payment);
    }


    // function reBid(uint256 tokenid, uint256 newAcutionAmount) public payable returns(bool){
    //     cancelBid(tokenid);
    //     bid(tokenid,newAcutionAmount);
    //     emit ReBid(tokenid,newAcutionAmount);
    //     return true;
    // }



    function cancelBid(uint256 tokenid) public payable{
        address payable user = msg.sender;
   
        require(takerOrders[tokenid][user].taker == user, "No permission");
        require(auctionOrdersArray[tokenid].length >0, "end!");
        // IERC20 token = makerOrders[tokenid].payment? usdt:era;
        uint8 payment = makerOrders[tokenid].payment;
        if (payment == 0) {
            user.transfer(takerOrders[tokenid][user].auctionAmount);
        } else {
            IERC20 token;
            if (payment == 1) {
                token = usdt;
            }
            if (payment == 2) {
                token = era;
            }
            IERC20(token).transfer(user, takerOrders[tokenid][user].auctionAmount);
        }
        delete takerOrders[tokenid][user];
        uint256 index = 0;
        uint256 indexLast = auctionOrdersArray[tokenid].length - 1; 
        for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){
                if(auctionOrdersArray[tokenid][i] == user){
                    index = i;
                    break;
                }
        }
        address lastuser = auctionOrdersArray[tokenid][indexLast];
        auctionOrdersArray[tokenid][index] = lastuser;
        auctionOrdersArray[tokenid].pop();

    }

    /// 结束拍卖
    function auctionEnd(uint256 tokenid,address taker) public payable{

        require(msg.sender == makerOrders[tokenid].maker, "No permission to end");
        require(msg.sender == tx.origin,"Only EOA!");
        uint8 payment = makerOrders[tokenid].payment;
        if(auctionOrdersArray[tokenid].length >0){
            emit AuctionEnded(taker,takerOrders[tokenid][taker].auctionAmount, tokenid, payment);
            IERC721(manager.members("nft")).transferFrom(address(this),taker,tokenid);

            uint256 tradeFee = takerOrders[tokenid][taker].auctionAmount.mul(txFees).div(1000);   //收取2.5%的手续费

            (address origin,,,,uint256 stampFees,) = INFT(manager.members("nft")).starAttributes(tokenid);

            uint256 stampFee = takerOrders[tokenid][taker].auctionAmount.mul(stampFees).div(1000);
            uint256 sendAmount = takerOrders[tokenid][taker].auctionAmount.sub(tradeFee).sub(stampFee);
            
            if (payment == 0) {
                payable(manager.members("funder")).transfer(tradeFee);
                payable(origin).transfer(stampFee);
                payable(makerOrders[tokenid].maker).transfer(sendAmount);

                for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退还其他拍卖出价
                    
                    if(auctionOrdersArray[tokenid][i] == taker){
                        delete takerOrders[tokenid][auctionOrdersArray[tokenid][i]];
                        continue;                                              //结束此次循环到下次循环
                    }
                    else{
                        address otherTaker = auctionOrdersArray[tokenid][i];
                        uint256 backAmount = takerOrders[tokenid][otherTaker].auctionAmount;
                        payable(otherTaker).transfer(backAmount);
                        delete takerOrders[tokenid][otherTaker];
                    }
                    
                }
            } else {
                IERC20 token;
                if (payment == 1) {
                    token = usdt;
                }
                if (payment == 2) {
                    token = era;
                }
                IERC20(token).transfer(manager.members("funder"), tradeFee);
                IERC20(token).transfer(origin, stampFee);
                IERC20(token).transfer(makerOrders[tokenid].maker,sendAmount);

                for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退还其他拍卖出价
                    
                    if(auctionOrdersArray[tokenid][i] == taker){
                        delete takerOrders[tokenid][auctionOrdersArray[tokenid][i]];
                        continue;                                              //结束此次循环到下次循环
                    } else{
                        address otherTaker = auctionOrdersArray[tokenid][i];
                        uint256 backAmount = takerOrders[tokenid][otherTaker].auctionAmount;
                        IERC20(token).transfer(otherTaker, backAmount);
                        delete takerOrders[tokenid][otherTaker];
                    }
                    
                }
            }
            
        }
        else{       //流拍
            IERC721(manager.members("nft")).transferFrom(address(this),makerOrders[tokenid].maker,tokenid);
        }
        delete makerOrders[tokenid];
        delete auctionOrdersArray[tokenid];
    }




    // function getTakerOrder(uint256 tokenid) public view returns(TakerOrder[] memory) {
    //     TakerOrder[] memory takerorders;
    //     for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){
    //             address taker = auctionOrdersArray[tokenid][i];
    //             TakerOrder memory order = takerOrders[tokenid][taker];
    //             takerorders[i] = order;

    //     }
    //     return takerorders;
    // }

    receive() external payable{}
}