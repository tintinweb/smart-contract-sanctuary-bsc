// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

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

contract LimitTimeAuction is Member {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    mapping(uint256 => AuctionOrder) private makerOrders;
    uint256 public  txFees = 25;
    IERC20 public usdt;
    IERC20 public era;


    event CreateOrder(address indexed creater, uint256 tokenid,uint256 start, uint256 end, uint256 acutionAmount, uint8 payment);
    event HighestBidIncreased(address bidder, uint amount, uint256 tokenid, uint8 payment);
    event AuctionEnded(address winner, uint amount, uint8 payment, uint256 tokenid);
    event ChangeTxFee(uint256 txFees,uint256 newTxFee);
    event ChangeStampFee(uint256 txFees,uint256 newStampFee);
    event CancelAuction(uint256 tokenid,address maker,uint256 timestamp);
  


    struct AuctionOrder {
        address     maker;         //发起者
        address     highestBidder;        //最高拍卖者地址
    
        uint256     nftid;
        uint256     auctionAmount;       //拍卖价格
        uint256     startTime;       //拍卖开始时间
        uint256     endTime;
        bool        isBid;       //是否拍卖出去
        uint8       payment;
    }



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

    function createAuction(uint256 tokenid, uint256 acutionPrice,uint256 auctionStartTime, uint256 auctionEndTime,uint8 payment) external {    //创建订单
        require(makerOrders[tokenid].maker == address(0), "Exists Auction!");
        require(
            block.timestamp < auctionEndTime ,
            "Auction end!"
        );
        (,,,,,bool isOffical) = INFT(manager.members("nft")).starAttributes(tokenid);
        if(isOffical == true) {
            require(payment == 2, "offical NFT can only support ERA token");
        }
        IERC721(manager.members("nft")).transferFrom(msg.sender, address(this), tokenid);   //调用者转入自身token到本合约
        makerOrders[tokenid].maker = msg.sender;
        makerOrders[tokenid].highestBidder = address(0);
        
        makerOrders[tokenid].nftid = tokenid;
        makerOrders[tokenid].auctionAmount = acutionPrice;
        makerOrders[tokenid].startTime = auctionStartTime;
        makerOrders[tokenid].endTime = auctionEndTime;
        makerOrders[tokenid].isBid = false;
        makerOrders[tokenid].payment = payment;
        emit CreateOrder(msg.sender, tokenid, auctionStartTime, auctionEndTime, acutionPrice, payment);
    }



    function bid(uint256 tokenid, uint256 acutionAmount) public payable {
        require(msg.sender == tx.origin,"Only EOA!");
        require(
            block.timestamp >= makerOrders[tokenid].startTime ,
            "Auction not start."
        );
        require(
            block.timestamp <= makerOrders[tokenid].endTime ,
            "Auction already ended."
        );

        // 如果出价不够高，返还你的钱
        require(
            acutionAmount > makerOrders[tokenid].auctionAmount,
            "There already is a higher bid."
        );
        require(!isContract(msg.sender), "Address: call to non-contract");

        uint8 payment = makerOrders[tokenid].payment;
        if (payment == 0) {
            require(msg.value == acutionAmount);
            if (makerOrders[tokenid].highestBidder != address(0)) {
          
                payable(makerOrders[tokenid].highestBidder).transfer(makerOrders[tokenid].auctionAmount);
             }
        } else {
            IERC20 token;
            if (payment == 1) {
                token = usdt;
            }
            if (payment == 2) {
                token = era;
            } 
            IERC20(token).transferFrom(msg.sender, address(this), acutionAmount);
            if (makerOrders[tokenid].highestBidder != address(0)) {
                IERC20(token).transfer(makerOrders[tokenid].highestBidder, makerOrders[tokenid].auctionAmount);
            }
        }
        makerOrders[tokenid].highestBidder = msg.sender;
        makerOrders[tokenid].auctionAmount = acutionAmount;
        makerOrders[tokenid].isBid = true;
        emit HighestBidIncreased(msg.sender, acutionAmount, tokenid, payment);
    }


    function cancelAuction(uint256 tokenid) public {     
        // require(block.timestamp > makerOrders[tokenid].startTime ,"Auction not start.");
        require(block.timestamp < makerOrders[tokenid].endTime, "Auction has ended.");
        require(msg.sender ==  makerOrders[tokenid].maker, "Only maker.");
        uint8 payment = makerOrders[tokenid].payment;
        if(makerOrders[tokenid].isBid){            //if someone bid
            if (payment == 0) {
                
                if (makerOrders[tokenid].highestBidder != address(0)) {
            
                    payable(makerOrders[tokenid].highestBidder).transfer(makerOrders[tokenid].auctionAmount);
                }
            } else {
                IERC20 token;
                if (payment == 1) {
                    token = usdt;
                }
                if (payment == 2) {
                    token = era;
                } 
                
                if (makerOrders[tokenid].highestBidder != address(0)) {
                    IERC20(token).transfer(makerOrders[tokenid].highestBidder, makerOrders[tokenid].auctionAmount);
                }
            }
        }
        IERC721(manager.members("nft")).transferFrom(address(this),makerOrders[tokenid].maker,tokenid);
        emit CancelAuction(tokenid,msg.sender,block.timestamp);
        delete makerOrders[tokenid];
    }

    function getAuctionOrder(uint256 tokenid) external view returns(AuctionOrder memory) {
        return makerOrders[tokenid];
    }

    /// 结束拍卖
    function auctionEnd(uint256 tokenid) public payable {
        require(msg.sender == tx.origin,"Only EOA!");
        require(block.timestamp >= makerOrders[tokenid].endTime, "Auction not yet ended.");
        uint8 payment = makerOrders[tokenid].payment;
        if(makerOrders[tokenid].isBid){
            IERC721(manager.members("nft")).transferFrom(address(this),makerOrders[tokenid].highestBidder,tokenid);

            uint256 tradeFee = makerOrders[tokenid].auctionAmount.mul(txFees).div(1000);   //收取2.5%的手续费

            (address origin,,,,uint256 stampFees,) = INFT(manager.members("nft")).starAttributes(tokenid);

            uint256 stampFee = makerOrders[tokenid].auctionAmount.mul(stampFees).div(1000);
            uint256 sendAmount = makerOrders[tokenid].auctionAmount.sub(tradeFee).sub(stampFee);
            
            if (payment == 0) {
            
                payable(manager.members("funder")).transfer(tradeFee);
                payable(origin).transfer(stampFee);
                payable(makerOrders[tokenid].maker).transfer(sendAmount);
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
            }
        }
        else{       //流拍
            IERC721(manager.members("nft")).transferFrom(address(this),makerOrders[tokenid].maker,tokenid);
        }
        emit AuctionEnded(makerOrders[tokenid].highestBidder,makerOrders[tokenid].auctionAmount, payment, tokenid);        
        delete makerOrders[tokenid];
    }

    function setTxFee(uint256 newTxFee) public {
        require(msg.sender == manager.members("owner"));
        emit ChangeTxFee(txFees,newTxFee);
        txFees = newTxFee;
       
    }




}