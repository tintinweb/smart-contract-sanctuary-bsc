// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "../Lib/Ownable.sol";
import "./PaymentComp.sol";
import "./OrderComp.sol";
import "./FeeComp.sol";
import "./TokenHelperComp.sol";
import "../MintComp/IMintComp.sol";

contract Exchange is Ownable, PaymentComp, OrderComp, TokenHelperComp, FeeComp{
    event PaymentEvent(uint256 indexed orderId,address indexed user,uint256 amount);

    IMintComp public mintComp;

    constructor (address mintComp_,address receiver, uint256 rate, address metaTx) 
    FeeComp(receiver,rate) 
    ERC2771Context(metaTx)
    {
        mintComp = IMintComp(mintComp_);
    }

    function setMintComp(address mintComp_) public onlyOwner{
        mintComp = IMintComp(mintComp_);
    }

    function setFee( address receiver,uint256 rate) public onlyOwner{
        _setFee(receiver, rate);
    }

    // function for seller
    function createOrder(InputOrder memory order) public{
        if(order.asset.assetType == AssetType.ERC721){
            erc721ResourcesVerify(order.asset.token, _msgSender(), order.asset.tokenId);
        }else if(order.asset.assetType == AssetType.ERC1155){
            erc1155ResourcesVerify(order.asset.token, _msgSender(), order.asset.tokenId, order.asset.value);
        }else{
            revert("createOrder: Asset type invalid");
        }

        _crateOrder(_msgSender(), order);
    }

    function createOrderWithGift(InputOrder memory order,Asset memory gift) public{
        if(order.asset.assetType == AssetType.ERC721){
            erc721ResourcesVerify(order.asset.token, _msgSender(), order.asset.tokenId);
        }else if(order.asset.assetType == AssetType.ERC1155){
            erc1155ResourcesVerify(order.asset.token, _msgSender(), order.asset.tokenId, order.asset.value);
        }else{
            revert("createOrder: Asset type invalid");
        }

        // 是否持有赠品Token验证
        if(gift.assetType == AssetType.ERC721){
            erc721ResourcesVerify(gift.token, _msgSender(), gift.tokenId);
        }else if(gift.assetType == AssetType.ERC1155){
            erc1155ResourcesVerify(gift.token, _msgSender(), gift.tokenId, gift.value);
        }else{
            revert("createOrder: Asset type invalid");
        }

        _crateOrderWithGift(_msgSender(), order,gift);
    }

     function rent(uint256 orderId,uint256 renttime) public {
         // 验证交易订单有效性
        _verifyOrder(orderId);
        Order storage order = _orders[orderId];
        require(order.orderType == OrderType.Rent, "rent: Only be used for Rent orders");
        require(renttime<=order.rentDaysScope,"rent: beyond the lease time rent");
        (uint256 theRentPrice,uint256 allPrice)=calculateRent(orderId,renttime);
        erc20ResourcesVerify(order.paymentToken, _msgSender(), allPrice);
        _deduction(orderId, order.paymentToken, _msgSender() , allPrice);
         uint256 paymentId = _addPayment(orderId, Payment(payable(_msgSender()), order.paymentToken,theRentPrice , block.timestamp));
         order.rentStartTime=block.timestamp;
        order.rentEndTime=block.timestamp+renttime;
        // modify
        order.lastPayment = paymentId;
        order.payments.push(paymentId);

        _swap(orderId, paymentId);
        _orders[orderId].orderStatus = OrderStatus.Renting;

     }

     function calculateRent(uint256 orderId,uint256 renttime) internal view returns(uint256 theRentPrice,uint256 allPrice){
          Order storage order = _orders[orderId];
          
           theRentPrice=order.price*order.rentPrice*renttime/864000000;//租金=抵押金*每天的基于抵押金百分比的租金*租用的天数
           allPrice=order.price+order.price*order.rentPrice*renttime/864000000;//租赁者总付款=抵押金+租金
           return (theRentPrice,allPrice);
     }

     function returnft(uint256 orderId) public {
          Order storage order = _orders[orderId];
         Payment memory lastPayment = getPayment(order.lastPayment);
         require(order.orderStatus == OrderStatus.Renting,"_verifyTransaction: The order is Renting");
         require(lastPayment.payor==_msgSender(),"return:This order is not yours");//确定要归还的订单是否是调用者的
          if(order.asset.assetType == AssetType.ERC721){
            erc721ResourcesVerify(order.asset.token, _msgSender(), order.asset.tokenId);
        }else if(order.asset.assetType == AssetType.ERC1155){
            erc1155ResourcesVerify(order.asset.token, _msgSender(), order.asset.tokenId, order.asset.value);
        }else{
            revert("createOrder: Asset type invalid");
        }
        //验证归还者是否将nft approve给这个合约
         
        rentswap(orderId);

         order.txPayment = order.lastPayment;
        _orderComplete(orderId);

     }

      function rentswap(uint256 orderId) internal{
           Order storage order = _orders[orderId];
            Payment memory lastPayment = getPayment(order.lastPayment);
          require(block.timestamp >= order.rentStartTime,"return: This order has not started rent");
        uint256 returnadvance;
        uint256 overdue;
        if(block.timestamp <= order.rentEndTime){// 提前归还和超时归还
                returnadvance= order.price;
            }else{
                overdue=(block.timestamp-order.rentEndTime)*order.price*order.rentPrice*3/864000000;//逾期费=未逾期租赁费的3倍
                if(order.price-overdue>0){
                returnadvance= order.price-overdue;
               //将逾期款给租赁方
                }else{
                    returnadvance=0;
                    overdue=order.price;
                   }
                 _erc20Transfer(order.paymentToken, order.seller, overdue);
            }

         if(order.asset.assetType == AssetType.ERC721){
            _erc721TransferFrom(order.asset.token,lastPayment.payor,order.seller, order.asset.tokenId);
        }else if(order.asset.assetType == AssetType.ERC1155){
            _erc1155TransferFrom(order.asset.token,lastPayment.payor,order.seller, order.asset.tokenId, order.asset.value,"burble exchange");
        }//归还nft给租赁方
        
       _erc20Transfer(order.paymentToken, lastPayment.payor, returnadvance);//归还抵押金
      }

      function renterRetrieve(uint256 orderId)public {//当租赁者超时未归还，且未归还的逾期费大于抵押金时，将押金给调用方法的被租赁者
          Order storage order = _orders[orderId];
          require(order.orderStatus == OrderStatus.Renting,"_verifyTransaction: The order is Renting");
           require(order.seller==_msgSender(),"return:This order is not yours");//确定要索要的订单是否是租赁者的
           require(block.timestamp >= order.rentStartTime,"sellerRetrieve: This order has not started rent");
           require(block.timestamp >= order.rentEndTime,"sellerRetrieve:This order has not time out");// 超时未归还
               
                uint256 overdue=(block.timestamp-order.rentEndTime)*order.price*order.rentPrice*3/864000000;//逾期费=未逾期租赁费的3倍
                require(order.price-overdue<=0,"sellerRetrieve:The overdue should more than the order price");//逾期费大于抵押金

                 _erc20Transfer(order.paymentToken, order.seller, order.price);
               //将抵押金给租赁方
       }

    // function for buyer,Only be used for FixedPrice orders 
    function buy(uint256 orderId) public {
        // 验证交易订单有效性
        _verifyOrder(orderId);

        Order storage order = _orders[orderId];
        require(order.orderType == OrderType.FixedPrice, "buy: Only be used for FixedPrice orders");

        // 直接扣款，无需验证
        //erc20ResourcesVerify(order.paymentToken, _msgSender(), amount);
        // 扣除资金
        _deduction(orderId, order.paymentToken, _msgSender() , order.price);

        uint256 paymentId = _addPayment(orderId, Payment(payable(_msgSender()), order.paymentToken, order.price, block.timestamp));

        // modify
        order.lastPayment = paymentId;
        order.payments.push(paymentId);

        _swap(orderId, paymentId);
    }

    // function for buyer, for FixedPrice and OpenForBids mode orders
    function makeOffer(uint256 orderId, uint256 amount, uint256 endtime) public{
        _verifyOrder(orderId);
        Order storage order = _orders[orderId];

        require(order.orderType != OrderType.TimedAuction, "makeOffer: Cannot be used for TimedAuction orders");

        if (order.orderType ==  OrderType.OpenForBids){
            require(amount >= order.price, "makeOffer: Price is lower than the lowest price set by the seller");
        }

        // 验证购买人资金充足
        erc20ResourcesVerify(order.paymentToken, _msgSender(), amount);

        uint256 paymentId = _addPayment(orderId, Payment(payable(_msgSender()), order.paymentToken, amount, endtime));

        order.lastPayment = paymentId;
        order.payments.push(paymentId);
    }

    function auction(uint256 orderId, uint256 amount) public{
        _verifyOrder(orderId);

        Order storage order = _orders[orderId];

        require(order.orderType == OrderType.TimedAuction, "auction: Only be used for TimedAuction orders");
        require(amount >= order.price, "auction: Price is lower than the lowest price set by the seller");

        require(_isHigherBid(order.lastPayment, amount), "auction: The bid is lower than the last time");

        // 直接扣款，无需验证
        //erc20ResourcesVerify(order.paymentToken, _msgSender(), amount);
        // 扣除资金
        _deduction(orderId, order.paymentToken, _msgSender(), amount);

        // 返还上一次竞拍人资金
        if(order.lastPayment != 0){
            Payment memory lastPayment = getPayment(order.lastPayment);
            _refund(order.paymentToken, lastPayment.payor, lastPayment.amount);
        }

        uint256 paymentId = _addPayment(orderId,Payment(payable(_msgSender()),order.paymentToken, amount, order.endTime));

        order.lastPayment = paymentId;
        order.payments.push(paymentId);
    }

    // function for seller, for FixedPrice and OpenForBids mode order
    function accept(uint256 orderId, uint256 paymentId) public{
        _verifyOrder(orderId);

        Order memory order = _orders[orderId];
        Payment memory payment = getPayment(paymentId);

        require(_msgSender() == order.seller,"accept: You are not the seller");
        require(block.timestamp <= payment.endtime,"accept: offer has expired");

        // 扣款
        _deduction(orderId, order.paymentToken, payment.payor, payment.amount);

        _swap(orderId, paymentId);
    }

    // function for buyer, when the auction is ended call this function
    function auctionConfirm(uint256 orderId) public{
        Order memory order = _orders[orderId];

        require(order.orderType == OrderType.TimedAuction, "auctionConfirm: Only be used for TimedAuction orders");

        // 判断订单状态是否正常可交易
        require(order.orderStatus == OrderStatus.Opened,"auctionConfirm: The order is closed");
        require(block.timestamp > order.endTime,"auctionConfirm: The auction has not ended yet");

        Payment memory payment = getPayment(order.lastPayment);
        require(_msgSender() == payment.payor,"auctionConfirm: The last bidder is not you");

        _swap(orderId, order.lastPayment);
    }

    // function for seller, cancel the order before the order confirmed
    function cancel(uint256 orderId) public{
        Order memory order = _orders[orderId];

        require(order.seller == _msgSender(),"cancel: You are not the seller");
        require(order.orderStatus == OrderStatus.Opened,"cancel: The current state has no cancellation");

        if(order.orderType == OrderType.TimedAuction && order.lastPayment != 0){
            Payment memory lastPayment = getPayment(order.lastPayment);
            _refund(order.paymentToken, lastPayment.payor, lastPayment.amount);
        }

        _orderCancel(orderId);
    }

    function orderReview(uint256 orderId, bool pass) public onlyOwner{
        _orderReview(orderId, pass);
    }

    function _swap(uint256 orderId,uint256 paymentId) internal{
        Order storage order = _orders[orderId];
        Payment memory payment = getPayment(paymentId);
        
        // 资金分配
        _allocationFunds(orderId, payment.amount);
        
        if(order.asset.assetType == AssetType.ERC721){
            _erc721TransferFrom(order.asset.token, order.seller, payment.payor, order.asset.tokenId);
        }else if(order.asset.assetType == AssetType.ERC1155){
            _erc1155TransferFrom(order.asset.token, order.seller, payment.payor, order.asset.tokenId, order.asset.value,"burble exchange");
        }

        // 如果订单有赠品，则赠送
        if(order.gift.token != address(0)){
            if(order.gift.assetType == AssetType.ERC721){
                _erc721TransferFrom(order.gift.token, order.seller, payment.payor, order.gift.tokenId);
            }else if(order.gift.assetType == AssetType.ERC1155){
                _erc1155TransferFrom(order.gift.token, order.seller, payment.payor, order.gift.tokenId, order.gift.value,"burble exchange gift");
            }
        }
        
        order.txPayment = order.lastPayment;
        _orderComplete(orderId);
    }

    // 扣款
    function _deduction(uint256 orderId,address token, address from, uint256 amount) internal{
        _erc20TransferFrom(token, from, address(this), amount);

        emit PaymentEvent(orderId, from, amount);
    }

    // 资金返还
    function _refund(address token,address lastByuer, uint256 amount) internal{
        _erc20Transfer(token,lastByuer,amount);
    }

    // 资金分配
    function _allocationFunds(uint256 orderId,uint256 txAmount) internal{
        Order memory order = _orders[orderId];

        uint256 totalFee;
        
        // 平台手续费
        address feeReceiver;
        uint256 feeRate;
        (feeReceiver,feeRate) = getFee();
        uint256 feeAmount = txAmount * feeRate / 10000;
        _erc20Transfer(order.paymentToken, feeReceiver, feeAmount);
        totalFee += feeAmount;

        // 版税
        address royaltyMaker;
        uint256 royaltyRate;
        (royaltyMaker,royaltyRate) = mintComp.getRoyalty(order.asset.token, order.asset.tokenId);
        if (royaltyMaker != address(0)) {
            uint256 royaltyAmount = royaltyRate * txAmount / 10000;
            _erc20Transfer(order.paymentToken, royaltyMaker, royaltyAmount);
            totalFee += royaltyAmount;
        }

        // 剩余全部转给 卖家
        _erc20Transfer(order.paymentToken, order.seller, txAmount - totalFee);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (metatx/ERC2771Context.sol)

pragma solidity ^0.8.0;

import "../Lib/Context.sol";

/**
 * @dev Context variant with ERC2771 support.
 */
abstract contract ERC2771Context is Context {
    address private _trustedForwarder;

    constructor(address trustedForwarder) {
        _trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

abstract contract IMintComp {
    event MintERC721(address indexed token,uint256 indexed tokenId);
    event MintERC1155(address indexed token,uint256 indexed tokenId);

    struct Royalty{
        address maker;
        uint256 rate;
    }

    function mintERC721(address to, string memory uri, uint256 rate) virtual external;
    function mintERC1155(address to, uint256 value, string memory uri, uint256 rate) virtual public;

    function getRoyalty(address token, uint256 id) virtual public view returns(address maker,uint256 rate);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../meta-tx/ERC2771Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is ERC2771Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../Lib/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "../Lib/IERC20.sol";
import "../Lib/IERC1155.sol";
import "../Lib/IERC721.sol";

contract TokenHelperComp {

    function erc20ResourcesVerify(address token, address from, uint256 amount) public view{
        IERC20 erc20 = IERC20(token);
        require(erc20.balanceOf(from) >= amount,"_verifyFunds: Payment token insufficient balance");
        require(erc20.allowance(from,address(this)) >= amount,"_verifyFunds: Payment token not approve");
    }

    function erc721ResourcesVerify(address token, address from, uint256 tokenId) public view{
        IERC721 erc721 = IERC721(token);

        require(erc721.ownerOf(tokenId) == from,"ResourcesVerify: You don't have to have this token");
        require(erc721.isApprovedForAll(from,address(this)),"ResourcesVerify: Platform unauthorized");
    }

    function erc1155ResourcesVerify(address token, address from, uint256 tokenId, uint256 value) public view{
        IERC1155 erc1155 = IERC1155(token);

        require(erc1155.balanceOf(from, tokenId) >= value,"ResourcesVerify: You dont have this token, or the balance is insufficient");
        require(erc1155.isApprovedForAll(from, address(this)),"ResourcesVerify: Platform unauthorized");
    }
 
    function _erc20Transfer(address token,address to, uint256 amount) internal {
        IERC20 erc20 = IERC20(token);
        erc20.transfer(to,amount);
    }

    function _erc20TransferFrom(address token, address from, address to, uint256 amount) internal {
        IERC20 erc20 = IERC20(token);
        erc20.transferFrom(from,to,amount);
    }

    function _erc721TransferFrom(address token, address from, address to, uint256 id) internal {
        IERC721 erc721 = IERC721(token);
        erc721.transferFrom(from,to,id);
    }

    function _erc1155TransferFrom(address token, address from, address to, uint256 id,uint256 amount,bytes memory data) internal {
        IERC1155 erc1155 = IERC1155(token);
        erc1155.safeTransferFrom(from,to,id,amount,data);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

contract PaymentComp {
    struct Payment{
        address payable payor;
        address token;
        uint256 amount;
        uint256 endtime;
    }

    event AddPayment(uint256 orderId,uint256 paymentId);

    mapping(uint256 => Payment) internal _payments;
    uint256 internal paymentCount;

    mapping(address => uint256[]) internal _paymentsOfAddress;
    
    function _addPayment(uint256 orderId, Payment memory payment) internal returns(uint256 paymentId){
        paymentCount++;
        
        paymentId = paymentCount;
        _payments[paymentId] = payment;

        _paymentsOfAddress[payment.payor].push(paymentId);

        emit AddPayment(orderId,paymentId);
    }

    function _isHigherBid(uint256 lastPaymentId,uint256 amount) internal view returns(bool){
        Payment memory lastPayment =  _payments[lastPaymentId];
        return amount > lastPayment.amount;
    }

    function getPayment(uint256 paymentId) public view returns(Payment memory payment){
        payment = _payments[paymentId];
    }

    function getPayments(uint256[] memory paymentIds) public view returns(Payment[] memory payments_){
        payments_ = new Payment[](paymentIds.length);
        for(uint256 i = 0; i < paymentIds.length; i++){
            payments_[i] = _payments[paymentIds[i]];
        }
    }

    function userPayments(address user) public view returns(Payment[] memory payments_){
        uint256[] memory paymentIds =  _paymentsOfAddress[user];

        payments_ = new Payment[](paymentIds.length);
        for(uint256 i = 0; i < paymentIds.length; i++){
            payments_[i] = _payments[paymentIds[i]];
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

contract OrderComp{
    enum AssetType{
        ETH,
        ERC20,
        ERC721,
        ERC1155
    }

    struct Asset {
        address token;  // token contract address
        uint256 tokenId;
        uint256 value;  // ERC1155
        AssetType assetType;
    }

    enum OrderType{
        FixedPrice,     // 一口价售卖
        TimedAuction,   // 限时拍卖
        OpenForBids,     // 公开竞标
        Rent              //租赁
    }

    enum OrderStatus{
        Checking,   // 审核中
        NoPass,     // 审核不通过
        Opened,     // 开放交易中
        Canceled,   // 订单已取消
        Completed,   // 订单已交易完成
        Renting     //订单租赁中
    }

    struct InputOrder{
        OrderType orderType;
        Asset asset;
        address paymentToken;   // 支付token
        uint256 price;          // 售价，最低报价（限时拍卖），押金（租赁）
        uint256 startTime;      // 开始时间（限时拍卖）
        uint256 endTime;        // 结束时间（限时拍卖）
        uint256 rentPrice;       //租金（租赁） =押金*比例(每天)
        uint256 rentdaysScope;    //租赁时间范围
    }
    
    struct Order{
        OrderType orderType;
        Asset asset;
        address seller;
        address paymentToken;
        uint256 price;
        uint256 startTime;
        uint256 endTime;
        uint256 lastPayment;    // 最后一个交易
        uint256 txPayment;      // 成交交易信息
        uint256[] payments;
        OrderStatus orderStatus;
        uint256 rentPrice;       //租金（租赁）
        uint256 rentDaysScope;        //租赁时间范围(秒)
        uint256 rentStartTime;       //租赁开始时间
        uint256 rentEndTime;       //租赁到期时间
        Asset gift;
    }

    event CreateOrder(address indexed seller, uint256 indexed orderId);
    event OrderCancel(uint256 indexed orderId);
    event OrderComplete(uint256 indexed orderId);
    event OrderReview(uint256 indexed orderId, bool indexed pass);

    mapping(uint256 => Order) internal _orders;
    uint256 internal orderCount;

    function _crateOrder(address creator,InputOrder memory inputOrder) internal returns(uint256 orderId){
        orderId = _crateOrderWithGift(creator, inputOrder, Asset(address(0),0,0,AssetType.ETH));
    }

    function _crateOrderWithGift(address creator,InputOrder memory inputOrder,Asset memory gift) internal returns(uint256 orderId){
        uint256[] memory payments;

        orderCount++;
        orderId = orderCount;
        
        _orders[orderId] = Order({
            orderType: inputOrder.orderType,
            asset: inputOrder.asset,
            seller: creator,
            paymentToken: inputOrder.paymentToken,
            price: inputOrder.price,
            startTime: inputOrder.startTime,
            endTime: inputOrder.endTime,
            lastPayment: 0,
            txPayment: 0,
            payments: payments,
            orderStatus: OrderStatus.Checking,
            rentPrice: inputOrder.rentPrice,
            rentDaysScope: inputOrder.rentdaysScope,
            rentStartTime: 0,
            rentEndTime: 0,
            gift:gift
        });

        emit CreateOrder(creator,orderId);
    }

    function _verifyOrder(uint256 orderId) internal view{
        Order memory order = _orders[orderId];

        // 判断订单状态是否正常可交易
        require(order.orderStatus == OrderStatus.Opened,"_verifyTransaction: The order is closed");
        require(block.timestamp >= order.startTime,"_verifyTransaction: This order has not started selling");
        require(block.timestamp <= order.endTime,"_verifyTransaction: This order has ended");
    }

    function _orderReview(uint256 orderId,bool pass) internal{
        if(pass){
            _orders[orderId].orderStatus = OrderStatus.Opened;
        }else{
            _orders[orderId].orderStatus = OrderStatus.NoPass;
        }
        emit OrderReview(orderId, pass);
    }

    function _orderComplete(uint256 orderId) internal{
        _orders[orderId].orderStatus = OrderStatus.Completed;
        _orders[orderId].endTime = block.timestamp;
        emit OrderComplete(orderId);
    }

    function _orderCancel(uint256 orderId) internal{
        _orders[orderId].orderStatus = OrderStatus.Canceled;
        _orders[orderId].endTime = block.timestamp;
        emit OrderCancel(orderId);
    }

    function getOrder(uint256 orderId) public view returns(Order memory order){
        order = _orders[orderId];
    }

    function getOrderPayments(uint256 orderId) public view returns(uint256[] memory paymentIds){
        return _orders[orderId].payments;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

abstract contract FeeComp {
    struct Fee{
        address receiver;
        uint256 rate;
    }

    Fee private _baseFee;

    // 保留了两位小数，例： 收取 1.55%的手续费，则rate为155
    constructor (address receiver,uint256 rate) {        
       _setFee(receiver,rate);
    }

    function _setFee(address receiver,uint256 rate) internal{
        _baseFee = Fee(
            receiver,
            rate
        );
    }

    function getFee() public view returns(address receiver,uint256 rate){
        receiver = _baseFee.receiver;
        rate = _baseFee.rate;
    }
}