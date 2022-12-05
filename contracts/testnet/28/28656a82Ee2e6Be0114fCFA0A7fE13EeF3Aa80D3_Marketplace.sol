// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Marketplace {

    using SafeMath for uint256;
    
    address private admin;

    uint256 public marketplaceFee = 5;

    mapping (uint => address) public recipient;
    mapping (uint => uint) public fee;
    uint256 public recipientCount;

    mapping (uint => SellList) public sales;
    uint256 public salesId;

    mapping (uint => mapping (uint => OfferData)) public offerInfo;
    mapping (uint => uint) public offerCount;

    mapping (address => uint) public escrowAmount;

    mapping (uint => AuctionData) public auction;
    uint256 public auctionId;

    /// @notice This is the Sell struct, the basic structures contain the owner of the selling tokens.
    struct SellList {
        address seller;
        address token;
        uint256 tokenId;
        uint256 amountOfToken;
        uint256 deadline;
        uint256 price;
        bool isSold;
    }

    struct OfferData {
        address offerAddress;
        uint256 offerPrice;
        bool isAccepted;
    }

    struct AuctionData {
        address creator;
        address token;
        address highestBidder;
        uint256 tokenId;
        uint256 amountOfToken;
        uint256 highestBid;
        uint256 startPrice;
        uint256 minIncrement;
        uint256 startDate;
        uint256 duration;
        Action action;
    }

    enum Action {
        RESERVED, STARTED
    }
     /// @notice This is the emitted event, when a offer for a certain amount of tokens.
    event SellEvent (
        address _seller,
        address _token,
        uint256 _offerId,
        uint256 _tokenId,
        uint256 _amount
    );

    /// @notice This is the emitted event, when a sell is canceled.
    event CanceledSell (
        address _seller,
        address _token,
        uint256 _tokenId,
        uint256 _amountOfToken
    );

    /// @notice This is the emitted event, when a buy is made.
    event BuyEvent (
        address _buyer,
        address _token,
        uint256 _tokenId,
        uint256 _amountOfToken,
        uint256 _price
    );

    constructor()  {
        admin = msg.sender;
    }
    /**
        @param _newFee This is new marketplace fee amount
    **/
    function updateTotalFee(
        uint256 _newFee
    ) external onlyAdmin {
        // Set the new Marketplace fee
        marketplaceFee = _newFee;
    }
    
    /** 
        @param _recipient These are the updated recipient addresses of the fees.
        @param _fee These are the updated fees for the recipients to receive.
    **/
    function updateFeeAndRecipient(
        address[] memory _recipient, 
        uint256[] memory _fee
    ) external onlyAdmin {
        // _recipient and _fee counts should be the same
        require(_recipient.length == _fee.length, "updateFee: Not match");
        
        // Reset the recipientCount as updated data
        recipientCount = _fee.length;

        // Reset recipient and fee with newly data
        for (uint i = 0; i < recipientCount; i++) {
            recipient[i] = _recipient[i];
            fee[i] = _fee[i];
        }
    }

    /** 
        @param _token This is the address of the ERC1155 token.
        @param _tokenId This is the ID of the token that's inside of the ERC1155 token.
        @param _amountOfToken This is the amount of tokens that are going to be sold in the offer.
        @param _deadline This is the final date in (seconds) so the offer ends.
        @param _price This is the full price for the amountOfToken that user passed as the param.
        @dev We are making some require for the parameters that needs to be required.
        @return Return true if the sell is created successfully.
    **/
    function createList(
        address _token,
        uint256 _tokenId,
        uint256 _amountOfToken,
        uint256 _deadline,
        uint256 _price
    ) external returns (bool) {
        /*
            Check if amount of token is greater than 0
                full price for token  is greater than 0
                the deadline is longer than 1 hr
        */
        require(_amountOfToken > 0, "The amount of tokens to sell, needs to be greater than 0");
        require(_price > 0, "The full price for the tokens need to be greater than 0");
        require(_deadline > 3600, "The deadline needs to be greater than 1 hour");

        /*
            Add variables to the SellList struct with tokenAddress, seller, tokenId, amountOfToken, deadline, price
        */
        sales[salesId] = SellList (
            msg.sender,
            _token,
            _tokenId,
            _amountOfToken,
            block.timestamp + _deadline,
            _price,
            false
        );
        
        /*
            Add the salesId as increment 1
        */
        salesId ++;

        /*
            Emit the event when a sell is created.
        */
        emit SellEvent(
            msg.sender,
            _token,
            salesId,
            _tokenId,
            _amountOfToken
        );

        return true;
    }

    /**
        @param _sellId This is the ID of the SellList that's stored in mapping function.
    **/
    function buyListToken(
        uint256 _sellId
    ) external payable returns (bool) {
        /*
            Check if the msg.sender is not zero address
            of this sell, and if is sold
            msg.value needs to be greater than the price
        */
        require(msg.sender != address(0), "buyToken: Needs to be a address.");
        require(sales[_sellId].isSold != true, "buyToken: The tokends were bought.");
        require(msg.value >= sales[_sellId].price, "buyToken: Needs to be greater or equal to the price.");

        /*
            Get salePrice and feePrice from the marketplaceFee
        */
        uint256 salePrice = sales[_sellId].price;
        uint256 feePrice = salePrice * marketplaceFee / 100;

        /*
            Transfer salePrice-feePrice to the seller's wallet
        */
        payable(sales[_sellId].seller).transfer(salePrice - feePrice);

        /*
            Distribution feePrice to the recipients' wallets
        */
        for (uint i = 0; i < recipientCount;  i++) {
            payable(recipient[i]).transfer(feePrice * fee[i] / 100);
        }

              
        /* 
            After we send the Matic to the user, we send
            the amountOfToken to the msg.sender.
        */
        IERC1155(sales[_sellId].token).safeTransferFrom(
            sales[_sellId].seller, 
            msg.sender, 
            sales[_sellId].tokenId, 
            sales[_sellId].amountOfToken, 
            "0x0"
        );

        return true;
    }

    /** 
        @param _sellId The ID of the sell that you want to cancel.
    **/
    function cancelList(
        uint256 _sellId
    ) external returns (bool) {
        /*
            Check if the msg.sender is really the owner
            of this sell, and if is not sold yet.
        */
        require(sales[_sellId].seller == msg.sender, "Cancel: should be the owner of the sell.");
        require(sales[_sellId].isSold != true, "Cancel: already sold.");
        /*
            After that checking we can safely delete the sell
            in our marketplace.
        */
        delete sales[_sellId];

        /*
            Emit the event when a sell is cancelled.
        */
        emit CanceledSell(
            sales[_sellId].seller, 
            sales[_sellId].token, 
            sales[_sellId].tokenId,
            sales[_sellId].amountOfToken
        );

        return true;
    }

    /**
        @param _receiver This is the address which will be receive the token.
        @param _token This is the address of the ERC1155 token.
        @param _tokenId This is the ID of the token that's inside of the ERC1155 token.
        @param _amountOfToken This is the amount of tokens that are going to be transferred.
        @dev We are making some require for the parameters that needs to be required.
        @return Return true if the sell is created successfully.
    **/
    function transfer(
        address _receiver,
        address _token,
        uint256 _tokenId,
        uint256 _amountOfToken
    ) external returns (bool) {
        /* 
            Send ERC1155 token to _receiver wallet
            _amountOfToken to the _receiver
        */
        IERC1155(_token).safeTransferFrom(
            msg.sender, 
            _receiver, 
            _tokenId, 
            _amountOfToken, 
            "0x0"
        );

        return true;

    }

    /**
        @param _sellId The ID of the sell that you want to make an offer.
        @param _price The offer price for _sellId.
    **/
    function makeOffer(
        uint256 _sellId,
        uint256 _price
    ) external payable returns (bool) {

        /*
            Check if the msg.value is the same as the _price value of this sell, 
             if the seller is msg.sender
             if it is not sold yet.
        */
        require(msg.value == _price, "makeOffer: msg.value should be the _price");
        require(sales[_sellId].seller != msg.sender, "makeOffer: seller shouldn't offer");
        require(sales[_sellId].isSold != true, "makeOffer: already sold.");

        /*
            Get the offerCount of this _sellId
        */
        uint256 counter = offerCount[_sellId];

        /*
            Add variables to the OfferData struct with offerAddress, offerPrice, offerAcceptable bool value
        */
        offerInfo[_sellId][counter] = OfferData (
            msg.sender,
            msg.value,
            false
        );

        /*
            The offerCount[_sellId] value add +1
        */
        offerCount[_sellId] ++;

        /*
            Add the value to the `escrowAmount[address]`
        */
        escrowAmount[msg.sender] += msg.value;

        return true;
    }

    /**
        @param _sellId The ID of the sell that you want to make an offer.
        @param _offerCount The offer count to be accepted from the seller.
    **/
    function acceptOffer(
        uint256 _sellId,
        uint256 _offerCount
    ) external returns (bool) {

        /*
            Get the offer data from _sellId and _offerCount
        */
        OfferData memory offer = offerInfo[_sellId][_offerCount];

        /*
            Check if the sale NFTs are not sold
             if the seller is msg.sender
             if it is already accepted
             if offerPrice is larger than escrowAmount
        */
        require(sales[_sellId].isSold != true, "acceptOffer: already sold.");
        require(sales[_sellId].seller == msg.sender, "acceptOffer: not seller");
        require(offer.isAccepted == false, "acceptOffer: already accepted");
        require(offer.offerPrice <= escrowAmount[offer.offerAddress], "acceptOffer: lower amount");
    
        /*
            Get offerPrice and feePrice from the marketplaceFee
        */
        uint256 offerPrice = offer.offerPrice;
        uint256 feePrice = offerPrice * marketplaceFee / 100;

        /*
            Transfer offerPrice - feePrice to the seller's wallet
        */
        payable(offer.offerAddress).transfer(offerPrice - feePrice);

        /*
            Distribution feePrice to the recipients' wallets
        */
        for (uint i = 0; i < recipientCount;  i++) {
            payable(recipient[i]).transfer(feePrice * fee[i] / 100);
        }
               
        /*
            Substract the offerPrice from the `escrowAmount[address]`
        */
        escrowAmount[offer.offerAddress] -= offerPrice;

        /* 
            After we send the Matic to the user, we send
            the amountOfToken to the msg.sender.
        */
        IERC1155(sales[_sellId].token).safeTransferFrom(
            sales[_sellId].seller, 
            offer.offerAddress, 
            sales[_sellId].tokenId, 
            sales[_sellId].amountOfToken, 
            "0x0"
        );
        
        /*
            Set the offer data as it is accepted
        */
        offerInfo[_sellId][_offerCount].isAccepted = true;

        return true;

    }


    /**
        @param _sellId The ID of the sell that you want to make an offer.
        @param _offerCount The offer count to be cancelled from the offerAddress.
    **/
    function cancelOffer(
        uint256 _sellId,
        uint256 _offerCount
    ) external returns (bool) {

        /*
            Get the offer data from _sellId and _offerCount
        */
        OfferData memory offer = offerInfo[_sellId][_offerCount];

        /*
            Check if the offer's offerAddress is msg.sender
                if the offer is already accepted
                if the offerPrice is larger than the escrowAmount
        */
        require(msg.sender == offer.offerAddress, "cancelOffer: not offerAddress");
        require(offer.isAccepted == false, "acceptOffer: already accepted");
        require(offer.offerPrice <= escrowAmount[msg.sender], "cancelOffer: lower amount");


        /*
            Transfer offerPrice return to the offerAddress
        */
        payable(offer.offerAddress).transfer(offer.offerPrice);

        /*
            Substract the offerPrice from the `escrowAmount[address]`
        */
        escrowAmount[msg.sender] -= offer.offerPrice;
        
        /*
            After that checking we can safely delete the offerData
            in our marketplace.
        */
        delete offerInfo[_sellId][_offerCount];

        return true;
    }

    /**
        @dev This function used to deposit the Matic on this platform 
    **/
    function depositEscrow() external payable returns (bool) {
        /*
            Add the value to the `escrowAmount[address]`
        */
        escrowAmount[msg.sender] += msg.value;

        return true;

    }

    
    /**
        @dev This function used to withdraw the Matic on this platform 
        @param _amount This is the amount of the Matic to withdraw from the marketplace
    **/
    function withdrawEscrow(
        uint256 _amount
    ) external returns (bool) {
        /*
            The _amount should be smaller than the `escrowAmount[address]` 
        */
        require(_amount < escrowAmount[msg.sender], "withdrawEscrow: lower amount");

        /*
            Transfer _amount to the msg.sender wallet
        */
        payable(msg.sender).transfer(_amount);


        /*
            Substract the _amount from the `escrowAmount[address]`
        */
        escrowAmount[msg.sender] -= _amount;

        return true;

    }


    /** 
        @param _token This is the address of the ERC1155 token.
        @param _tokenId This is the ID of the token that's inside of the ERC1155 token.
        @param _amountOfToken This is the amount of tokens that are going to be created in auction.
        @param _startPrice This is the start Price of the auction.
        @param _minIncrement This is the min increment of the bids in this auction.
        @param _startDate This is the start date in (seconds) so the auction starts.
        @param _duration This is the duration of this auction.
        @param _reserved 1: reserved acution 0: normal auction
        @dev We are making some require for the parameters that needs to be required.
        @return Return true if the auction is created successfully.
    **/
    function createAuction(
        address _token,
        uint256 _tokenId,
        uint256 _amountOfToken,
        uint256 _startPrice,
        uint256 _minIncrement,
        uint256 _startDate,
        uint256 _duration,
        bool _reserved
    ) external returns (bool) {
        /*
            Check if amount of token is greater than 0
                the full price for token  is greater than 0
                the deadline is longer than 1 day
                the startPrice should be larger than 0
                the minIncrement should be larger than 0
                the startDate should be later than now
        */
        require(_amountOfToken > 0, "createAuction: The amount of tokens to sell, needs to be greater than 0");
        require(_startPrice > 0, "createAuction: The startPrice for the tokens need to be greater than 0");
        require(_duration > 86400, "createAuction: The deadline should to be greater than 1 day");
        require(_startPrice > 0, "createAuction: The start Price should be bigger than 0");
        require(_minIncrement > 0, "createAuction: The minIncrement should be bigger than 0");
        require(_startDate > block.timestamp, "createAuction: The start date should be after now");

        Action action;

        if (!_reserved) {
            action = Action.STARTED;
        }
        
        /*
            Add variables to the SellList struct with tokenAddress, seller, tokenId, amountOfToken, deadline, price
        */
        auction[auctionId] = AuctionData (
            msg.sender,
            _token,
            address(0),
            _tokenId,
            _amountOfToken,
            _startPrice - _minIncrement,
            _startPrice,
            _minIncrement,
            _startDate,
            _duration,
            action
        );
        
        /*
            Add the auctionId as increment 1
        */
        auctionId ++;

        return true;

    }

    /*
        @param _auctionId Users can bid to the _auctionId with value
    */
    function placeBid(
        uint256 _auctionId
    ) external payable returns (bool) {
        /*
            Get the auction data from _aucitonId
        */
        AuctionData memory auctionInfo = auction[_auctionId];

        /*
            Check if bidAmount is bigger than the higestBid + minIncrement
                if the creator is msg.sender
                if the bidTime is after the startDate
        */
        require(msg.value >= auctionInfo.highestBid + auctionInfo.minIncrement, "placeBid: Bid amount should be bigger than highestBid");
        require(msg.sender != auctionInfo.creator, "placeBid: Creator can't bid");
        require(block.timestamp >= auctionInfo.startDate, "placeBid: Bid should be after the startDate");
        require(auctionInfo.action == Action.RESERVED || auctionInfo.startDate + auctionInfo.duration > block.timestamp, "placeBid: It is Ended");

        /*
            Send back the highestBid to the highestBidder - who is not zero address
        */
        if (auctionInfo.highestBidder != address(0)) {
            payable(auctionInfo.highestBidder).transfer(auctionInfo.highestBid);
        }

        /*
            If the auction is reserved, set the startDate as now
            action as Action Enum - STARTED
        */
        if (auctionInfo.action == Action.RESERVED) {
            auction[_auctionId].startDate = block.timestamp;
            auction[_auctionId].action = Action.STARTED;
        }

        /*
            Set the auctionData's highest bidder as msg.sender - who is the new bidder
                the auctionData's highest bid as msg.value - what is the new bid value
        */
        auction[_auctionId].highestBidder = msg.sender;
        auction[_auctionId].highestBid = msg.value;

        return true;

    }

    /*
        @param _auctionId The auction Creator can cancel the auction
    */
    function cancelAuction(
        uint256 _auctionId
    ) external returns (bool) {
        /*
            Get the auction data from _aucitonId
        */
        AuctionData memory auctionInfo = auction[_auctionId];

        /*
            Check if the msg.sender should be the auction's creator 
                if the now time should be after auction's endDate
                if the auction's highestBidder should be zero address
        */
        require(msg.sender == auctionInfo.creator, "cancelAuction: Only auction creator can cancel it");
        require(block.timestamp > auctionInfo.startDate + auctionInfo.duration, "cancelAuction: The time should be after endDate");
        require(auctionInfo.highestBidder == address(0), "cancelAuction: There should be not highestBidder");

        /*
            Delete the auctionData from the blockchain
        */
        delete auction[_auctionId];

        return true;

    }

    /*
        @param _auctionId The highest bidder can claim the _auctionId's result
    */
    function claimAuction(
        uint256 _auctionId
    ) external returns (bool) {
        /*
            Get the auction data from _aucitonId
        */
        AuctionData memory auctionInfo = auction[_auctionId];

        /*
            Check if the msg.sender should be the highestBidder
                if the now time should be after auction's endDate
                if the auction's highestBidder should be zero address
        */
        require(msg.sender == auctionInfo.highestBidder, "claimAuction: The msg.sender should be the highest Bidder");
        require(block.timestamp > auctionInfo.startDate + auctionInfo.duration, "claimAuction: The time should be after endDate");
        
        /* 
            Send the amountOfToken to the highest Bidder.
        */
        IERC1155(auctionInfo.token).safeTransferFrom(
            auctionInfo.creator, 
            auctionInfo.highestBidder, 
            auctionInfo.tokenId, 
            auctionInfo.amountOfToken, 
            "0x0"
        );

        /*
            Get bidPrice and feePrice from the marketplaceFee
        */
        uint256 bidPrice = auctionInfo.highestBid;
        uint256 feePrice = bidPrice * marketplaceFee / 100;

        /*
            Transfer bidPrice-feePrice to the creator's wallet
        */
        payable(auctionInfo.creator).transfer(bidPrice - feePrice);

        /*
            Distribution feePrice to the recipients' wallets
        */
        for (uint i = 0; i < recipientCount;  i++) {
            payable(recipient[i]).transfer(feePrice * fee[i] / 100);
        }


        return true;
        
    }



    /**
        @dev This is the modifier to make - only Admin can access the function
    **/
    modifier onlyAdmin{
        require(admin == msg.sender, "OA");
        _;
    }



}