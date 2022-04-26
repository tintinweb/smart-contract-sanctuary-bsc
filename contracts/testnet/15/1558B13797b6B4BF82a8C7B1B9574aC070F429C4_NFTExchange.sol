pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier: SimPL-2.0


import "../Utils/IERC20.sol";
import "../Utils/IERC721.sol";
import "../Utils/SafeMath.sol";
import "../Utils/SafeERC20.sol";
import "../Manager/Member.sol";


interface INFT{
    struct starAttributesStruct{
      address origin;   //发布者
      string  IphsHash;//hash
      uint256 power;//nft等级
      uint256 price;   //价格
      uint256 stampFee;  //版税
      bool offical;
      uint256 createTime;  //鑄造時間
    }
    function transferFrom(address _from,address _to,uint256 _tokenId)external;
    function approve(address _approved,uint256 _tokenId) external;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;
    function viewTokenID() view external returns(uint256);
    function setTokenTypeAttributes(uint256 _tokenId,uint8 _typeAttributes,uint256 _tvalue) external;
    function transferList(address _to,uint256[] calldata _tokenIdList) external;
    function ownerOf(uint256 _tokenID) external returns (address _owner);
    function getStarAttributes(uint256 _tokenID) external view returns(starAttributesStruct memory nftAttr);
}


contract NFTExchange is Member{
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    event CreateOrder(address indexed maker, uint256 indexed tokenid, bool canExchange, uint256 payAmount, uint8 payment);
    event TradeOrder(uint256 indexed tokenid, address maker, address taker, bytes32 orderid, uint256 payAmount, uint8 payment);
    event NewFee(uint8 payment, uint256 payAmount);
    event CancelOrder(uint256 indexed tokenid);
    event ChangeTxFee(uint256 txFees,uint256 newTxFee);
    event CancelBid(uint256 indexed tokenid, uint256 amount, address user);
       


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
    mapping(uint256 => mapping(address=>TakerOrder)) public takerOrders;
    mapping(uint256 => address[]) public auctionOrdersArray;

    mapping(uint256 => ExchangeOrder) public makerOrders;
    mapping(bytes32 => ExchangeOrder) public tradeOrders;
    uint256 public  txFees = 200;

    IERC20 public usdt;
    IERC20 public mp;

    constructor(IERC20 _usdt, IERC20 _mp)
         {
            usdt = _usdt;
            mp = _mp;
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
        INFT.starAttributesStruct memory nftAttr = INFT(manager.members("nft")).getStarAttributes(tokenid);
        if(nftAttr.offical == true) {
            require(payment == 2, "offical NFT can only support MP token");
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

        INFT.starAttributesStruct memory nftAttr = INFT(manager.members("nft")).getStarAttributes(tokenid);

        //收取手续费
        uint256 tradeFee;
        uint256 stampFee;
        uint256 sendAmount;
        {
            uint256 fee = getTxFee(nftAttr.createTime);
            tradeFee = payAmount.mul(fee.sub(nftAttr.stampFee)).div(1000);   // 扣掉版稅，剩下當作手續費
            stampFee = payAmount.mul(nftAttr.stampFee).div(1000);   //收取版税
            sendAmount = payAmount.sub(tradeFee).sub(stampFee);
        }
       
        uint8 payment  = order.payment;
        if (payment == 0) {
            require(msg.value == payAmount);

            // 退還其他拍賣出價
            bidBackBnb(tokenid);
            
            payable(manager.members("funder")).transfer(tradeFee);
            payable(nftAttr.origin).transfer(stampFee);
            payable(order.maker).transfer(sendAmount);
            emit NewFee(payment, tradeFee);
        } else {
            IERC20 token;
            if (payment == 1) {
                token = usdt;
            }
            if (payment == 2) {
                token = mp;
            }

            // 退還其他拍賣出價
            bidBackToken(tokenid, token);

            IERC20(token).safeTransferFrom(msg.sender, manager.members("funder"), tradeFee);
            IERC20(token).safeTransferFrom(msg.sender, nftAttr.origin, stampFee);
            IERC20(token).safeTransferFrom(msg.sender, order.maker, sendAmount);

            emit NewFee(payment, tradeFee);
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
        IERC721(manager.members("nft")).transferFrom(address(this),msg.sender, tokenid);
        uint8 payment = makerOrders[tokenid].payment;
        if(auctionOrdersArray[tokenid].length >0){
            if (payment == 0) {
                for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退還其他拍賣出價
                    address bidder = auctionOrdersArray[tokenid][i];
                    uint256 backAmount = takerOrders[tokenid][bidder].auctionAmount;
                    payable(bidder).transfer(backAmount);
                    delete takerOrders[tokenid][bidder];
                    emit CancelBid(tokenid, backAmount, bidder);
                }
                delete auctionOrdersArray[tokenid];    
            } else {
                IERC20 token;
                if (payment == 1) {
                    token = usdt;
                }
                if (payment == 2) {
                    token = mp;
                }
                for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退還其他拍賣出價
                    address bidder = auctionOrdersArray[tokenid][i];
                    uint256 backAmount = takerOrders[tokenid][bidder].auctionAmount;
                    IERC20(token).transfer(bidder, backAmount);
                    delete takerOrders[tokenid][bidder];
                    emit CancelBid(tokenid, backAmount, bidder);
                }
                delete auctionOrdersArray[tokenid];   
            }
        }
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
        require(newTxFee <= 200, "tx Fee to high!");    // max 20%
        emit ChangeTxFee(txFees,newTxFee);
        txFees = newTxFee;
       
    }

    function getTxFee(uint256 createTime) public view returns(uint256 fee) {
        // 初始手續費20%，以后每15天递减2.5%共遞減6次直至5%後固定，其中2% 作為版权费給 mint holder，其餘项目方。 
         uint256 round =  (block.timestamp.sub(createTime)).div(15 days);
        
        // 最低5%
        if(round >= 6){
            return 50;
        }

        fee = txFees.sub(round.mul(25));
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
                    token = mp;
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
                token = mp;
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
        // IERC20 token = makerOrders[tokenid].payment? usdt:mp;
        uint8 payment = makerOrders[tokenid].payment;
        if (payment == 0) {
            user.transfer(takerOrders[tokenid][user].auctionAmount);
        } else {
            IERC20 token;
            if (payment == 1) {
                token = usdt;
            }
            if (payment == 2) {
                token = mp;
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

            INFT.starAttributesStruct memory nftAttr = INFT(manager.members("nft")).getStarAttributes(tokenid);


            //收取手续费
            uint256 fee = getTxFee(nftAttr.createTime);
            uint256 tradeFee = takerOrders[tokenid][taker].auctionAmount.mul(fee.sub(nftAttr.stampFee)).div(1000);   // 扣掉版稅，剩下當作手續費
            
            uint256 stampFee = takerOrders[tokenid][taker].auctionAmount.mul(nftAttr.stampFee).div(1000);
            uint256 sendAmount = takerOrders[tokenid][taker].auctionAmount.sub(tradeFee).sub(stampFee);
            
            if (payment == 0) {
                payable(manager.members("funder")).transfer(tradeFee);
                payable(nftAttr.origin).transfer(stampFee);
                payable(makerOrders[tokenid].maker).transfer(sendAmount);

                emit NewFee(payment, tradeFee);

                for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退還其他拍賣出價
                    
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
                    token = mp;
                }
                IERC20(token).transfer(manager.members("funder"), tradeFee);
                IERC20(token).transfer(nftAttr.origin, stampFee);
                IERC20(token).transfer(makerOrders[tokenid].maker,sendAmount);

                emit NewFee(payment, tradeFee);

                for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退還其他拍賣出價
                    
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
    function bidBackBnb(uint256 tokenid) internal {
       for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退還其他拍賣出價
            address bidder = auctionOrdersArray[tokenid][i];
            uint256 backAmount = takerOrders[tokenid][bidder].auctionAmount;
            payable(bidder).transfer(backAmount);
            delete takerOrders[tokenid][bidder];
            emit CancelBid(tokenid, backAmount, bidder);
        }
        delete auctionOrdersArray[tokenid];
    }

    function bidBackToken(uint256 tokenid, IERC20 token) internal {
       for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退還其他拍賣出價
            address bidder = auctionOrdersArray[tokenid][i];
            uint256 backAmount = takerOrders[tokenid][bidder].auctionAmount;
            IERC20(token).transfer(bidder, backAmount);
            delete takerOrders[tokenid][bidder];
            emit CancelBid(tokenid, backAmount, bidder);
        }
        delete auctionOrdersArray[tokenid];
    }

    receive() external payable{}
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
    
    function approve(address spender, uint256 value) external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function burn(uint256 amount) external;
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface IERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns(uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns(address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns(address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns(bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./IERC20.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";
import "./Manager.sol";

abstract contract Member is ContractOwner {
    modifier CheckPermit(string memory permit) {
        require(manager.userPermits(msg.sender, permit),
            "no permit");
        _;
    }
    
    Manager public manager;
    
    function setManager(address addr) external ContractOwnerOnly {
        manager = Manager(addr);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity ^0.7.0;
// SPDX-License-Identifier: SimPL-2.0

abstract contract ContractOwner {
    address public contractOwner = msg.sender;
    
    modifier ContractOwnerOnly {
        require(msg.sender == contractOwner, "contract owner only");
        _;
    }
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";

contract Manager is ContractOwner {
    mapping(string => address) public members;
    
    mapping(address => mapping(string => bool)) public userPermits;
    
    function setMember(string memory name, address member)
        external ContractOwnerOnly {
        
        members[name] = member;
    }
    
    function setUserPermit(address user, string memory permit,
        bool enable) external ContractOwnerOnly {
        
        userPermits[user][permit] = enable;
    }
    
    function getTimestamp() external view returns(uint256) {
        return block.timestamp;
    }
}