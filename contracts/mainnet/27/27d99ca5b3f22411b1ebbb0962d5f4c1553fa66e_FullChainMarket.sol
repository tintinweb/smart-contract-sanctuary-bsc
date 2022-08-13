/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

library SafeMath {
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


interface IERC721{
    function totalSupply() external view returns (uint256);
    function owner() external view returns (address);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


contract FullChainMarket {

    using SafeMath for uint256;

    uint256 public  _protocolFee = 2;
    uint256 public  _discountRate = 90;
    address public _owner;
    address public _offerToken;
    address private _receiver;

    //Discount
    address[] public _discount;

    //WhiteList switch
    bool public _useWL;

    //WhiteList
    mapping(address => bool) private _contracts;
    //Royalty
    mapping(address => uint256) private _royalty;
    //Index: tokenId + contract address
    mapping(bytes32 => SellList) private _sellList;
    //Index: tokenId + contract address + maker
    mapping(bytes32 => ItemOffer) private _itemOffers;
    //Index: contract address + maker
    mapping(bytes32 => CollectionOffer) private _collectionOffers;

    event ListOrder(address maker_, address token_, uint256 price_, uint256 tokenId_, uint256 endTime_);

    event EditOrder(address maker_, address token_, uint256 price_, uint256 tokenId_, uint256 endTime_);

    event CancelOrder(address maker_, address token_, uint256 tokenId_);

    event BuyOrder(
        address seller_,
        address buyer_,
        address token_,
        uint256 price_,
        uint256 tokenId_
    );

    event ItemOfferOrder(
        address maker_,
        address token_,
        uint32 endTime_,
        uint256 price_,
        uint256 tokenId_
    );

    event CancelItemOffer(address maker_, address token_, uint256 tokenId_);

    event CollectionOfferOrder(
        address maker_,
        address token_,
        uint32 endTime_,
        uint256 price_
    );

    event CancelCollectionOffer(address maker_, address token_);

    event AcceptItemOrder(
        address seller_,
        address buyer_,
        address token_,
        uint256 price_,
        uint256 tokenId_
    );

    event AcceptCollectionOrder(
        address seller_,
        address buyer_,
        address token_,
        uint256 price_,
        uint256 tokenId_
    );

    constructor() {
        _receiver = msg.sender;
        _owner = msg.sender;
    }

    struct SellList{
        address _maker;
        address _token;
        uint32 _endTime;
        uint256 _price;
        uint256 _tokenId;
    }

    struct ItemOffer{
        address _maker;
        address _token;
        uint32 _endTime;
        uint256 _price;
        uint256 _tokenId;
    }

    struct CollectionOffer{
        address _maker;
        address _token;
        uint32 _endTime;
        uint256 _price;
    }
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }

    modifier checkWL(address token) {
        if(_useWL){
            require(_contracts[token], "Not in the whitelist");
        }
        _;
    }

    function setReceiver(address receiver) external onlyOwner {
        _receiver = receiver;
    }

    function setOwner(address owner) external onlyOwner {
        _owner = owner;
    }

    function setOfferToken(address offerToken) external onlyOwner() {
        _offerToken = offerToken;
    }

    function setProtocolFee(uint256 percent) external onlyOwner {
        require(percent <= 10, "The maximum is 10 percent");
        _protocolFee = percent;
    }

    function setDiscountRate(uint256 rate) external onlyOwner {
        require(rate <= 90, "The minimum discount is 90 percent");
        _discountRate = rate;
    }

    function setRoyalty(address token, uint256 rate) external onlyOwner {
        _royalty[token] = rate;
    }

    function addDiscount(address token) external onlyOwner {
        _discount.push(token);
    }

    function initDiscount(address[] memory discountArray) external onlyOwner {
        _discount = discountArray;
    }

    function enableWL() external onlyOwner {
        _useWL = true;
    }

    function disableWL() external onlyOwner {
        _useWL = false;
    }

    function addWhite(address token) external onlyOwner {
        _contracts[token] = true;
    }

    function delWhite(address token) external onlyOwner {
        _contracts[token] = false;
    }

    function isWhiteList(address token) public view returns (bool){
       return _contracts[token];
    }

    function isTokenOwner(address token, uint256 tokenId) public view returns (bool){
        address tokenOwner = IERC721(token).ownerOf(tokenId);
        if (msg.sender == tokenOwner) {
            return true;
        } else {
            return false;
        }
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function listOrder(
        address token,
        uint256 price,
        uint256 tokenId,
        uint32 endTime
    ) external checkWL(token) returns (bool) {
        //Verify params
        require(price > 0, "Price cannot be zero");
        require(endTime > block.timestamp, "Time expired");
        require(isTokenOwner(token,tokenId), "Address mismatch");
        //Gen index
        bytes32 indexId = keccak256(abi.encodePacked(tokenId, token));
        //Check exist
        SellList storage seller = _sellList[indexId];
        require(seller._endTime == 0 || seller._endTime < block.timestamp, "Order already exists");
	    _sellList[indexId] = SellList({_maker: msg.sender, _token: token, _price: price, _tokenId: tokenId, _endTime: endTime});

        emit ListOrder(msg.sender, token, seller._price, tokenId, endTime);
        return true;
    }

    function editOrder(
        address token,
        uint256 price,
        uint256 tokenId,
        uint32 endTime
    ) external checkWL(token) returns (bool) {
        require(price > 0, "Price cannot be zero");
        require(isTokenOwner(token,tokenId), "Address mismatch");
        bytes32 indexId = keccak256(abi.encodePacked(tokenId, token));
        SellList storage seller = _sellList[indexId];
        //Check exist
        require(seller._endTime > 0, "The original order does not exist");
        seller._price = price;
        if(endTime > block.timestamp){
            seller._endTime = endTime;
        }

        emit EditOrder(msg.sender, token, price, tokenId, seller._endTime);
        return true;
    }

    function cancelOrder(address token, uint256 tokenId) external returns (bool) {
        require(isTokenOwner(token,tokenId), "Address mismatch");
        bytes32 indexId = keccak256(abi.encodePacked(tokenId, token));
        SellList memory seller = _sellList[indexId];
        //Check exist
        require(seller._endTime > 0, "The original order does not exist");
        //Check order maker
        require(seller._maker == msg.sender, "You are not the maker");
	    delete _sellList[indexId];

        emit CancelOrder(msg.sender, token, tokenId);
        return true;
    }

    function buyOrder(address token, uint256 tokenId) payable external checkWL(token) returns (bool) {
        //Check tokenId status
        bytes32 indexId = keccak256(abi.encodePacked(tokenId, token));
	    SellList memory seller = _sellList[indexId];
        require(seller._price > 0, "Order is invalid");
        require(seller._endTime > block.timestamp, "Order is expire");
        //Check price
        require(msg.value == seller._price, "Price is wrong");
        //Transfer BNB
        uint256 protocolFee = SafeMath.div(SafeMath.mul(_protocolFee, seller._price), 100);
        //Check discount
        for (uint256 i = 0; i < _discount.length; i++) {
            uint256 balances = IERC721(token).balanceOf(msg.sender);
            if (balances > 0) {
                protocolFee= SafeMath.div(SafeMath.mul(protocolFee, _discountRate), 100);
                break;
            }
        }
        (bool feeSent, ) = _receiver.call{value: protocolFee}("");
        require(feeSent, "Failed to transfer protocolFee");
        //Royalty
        uint256 royalty = _royalty[token];
        uint256 royaltyFee = 0;
        if(royalty > 0){
            address tokenOwner = IERC721(token).owner();
            royaltyFee = SafeMath.div(SafeMath.mul(royalty, seller._price), 100);
            (bool royaltyFeeSent, ) = tokenOwner.call{value: royaltyFee}("");
            require(royaltyFeeSent, "Failed to transfer royaltyFee");
        }
        //Maker
        uint256 makerAmount = SafeMath.sub(SafeMath.sub(msg.value, protocolFee), royaltyFee);
        (bool makerSent, ) = seller._maker.call{value: makerAmount}("");
        require(makerSent, "Failed to transfer maker");
        //Transfer token
        IERC721(token).safeTransferFrom(seller._maker,msg.sender,seller._tokenId);
        //Delete seller
        delete _sellList[indexId];

        emit BuyOrder(seller._maker, msg.sender, token, msg.value, tokenId);
        return true;
    }

    function itemOffer(
        address token,
        uint256 price,
        uint256 tokenId,
        uint32 endTime
    ) external checkWL(token) returns (bool) {
        //Verify params
        require(price > 0, "Price cannot be zero");
        require(endTime > block.timestamp, "Time expired");
        //Check allowance
        uint256 allowances = IERC20(_offerToken).allowance(msg.sender,address(this));
        require(allowances > price, "Insufficient authorization quantity");
        //Check balance
        uint256 balances = IERC20(_offerToken).balanceOf(msg.sender);
        require(balances > price, "Insufficient balance");
        //Save offer
        bytes32 indexId = keccak256(abi.encodePacked(tokenId, token, msg.sender));
	    _itemOffers[indexId] = ItemOffer({_maker: msg.sender, _token: token, _price: price, _tokenId: tokenId, _endTime: endTime});

        emit ItemOfferOrder(msg.sender, token, endTime, price, tokenId);
        return true;
    }

    function cancelItemOffer(address token, uint256 tokenId) external checkWL(token) returns (bool) {
        bytes32 indexId = keccak256(abi.encodePacked(tokenId, token, msg.sender));
        ItemOffer memory offerer = _itemOffers[indexId];
        //Check exist
        require(offerer._endTime > 0, "The original offer does not exist");
        //Check offer maker
        require(offerer._maker == msg.sender, "You are not the maker");
	    delete _itemOffers[indexId];

        emit CancelItemOffer(msg.sender, token, tokenId);
        return true;
    }

    function collectionOffer(
        address token,
        uint256 price,
        uint32 endTime
    ) external checkWL(token) returns (bool) {
        //Verify params
        require(price > 0, "Price cannot be zero");
        require(endTime > block.timestamp, "Time expired");
        //Check allowance
        uint256 allowances = IERC20(_offerToken).allowance(msg.sender,address(this));
        require(allowances > price, "Insufficient authorization quantity");
        //Check balance
        uint256 balances = IERC20(_offerToken).balanceOf(msg.sender);
        require(balances > price, "Insufficient balance");
        //Save offer
        bytes32 indexId = keccak256(abi.encodePacked(token, msg.sender));
	    _collectionOffers[indexId] = CollectionOffer({_maker: msg.sender, _token: token, _price: price, _endTime: endTime});

        emit CollectionOfferOrder(msg.sender, token, endTime, price);
        return true;
    }

    function cancelCollectionOffer(address token) external checkWL(token) returns (bool) {
        bytes32 indexId = keccak256(abi.encodePacked(token, msg.sender));
        CollectionOffer memory offerer = _collectionOffers[indexId];
        //Check exist
        require(offerer._endTime > 0, "The original offer does not exist");
        //Check offer maker
        require(offerer._maker == msg.sender, "You are not the maker");
	    delete _collectionOffers[indexId];

        emit CancelCollectionOffer(msg.sender, token);
        return true;
    }

    function acceptItemOffer(address token, uint256 tokenId, address maker) external checkWL(token) returns (bool) {
        //Check owner
        require(isTokenOwner(token,tokenId), "Address mismatch");
        //Check offer status
        bytes32 indexId = keccak256(abi.encodePacked(tokenId, token, maker));
	    ItemOffer memory offerer = _itemOffers[indexId];
        //Check endTime
        require(offerer._endTime > block.timestamp, "ItemOffer is expire");
        //ProtocolFee
        uint256 protocolFee = SafeMath.div(SafeMath.mul(_protocolFee, offerer._price), 100);
        //Check discount
        for (uint256 i = 0; i < _discount.length; i++) {
            uint256 balances = IERC721(token).balanceOf(msg.sender);
            if (balances > 0) {
                protocolFee= SafeMath.div(SafeMath.mul(protocolFee, _discountRate), 100);
                break;
            }
        }
        require(IERC20(_offerToken).transferFrom(offerer._maker, _receiver, protocolFee),"Failed to transfer protocolFee");
        //Royalty
        uint256 royalty = _royalty[token];
        uint256 royaltyFee = 0;
        if(royalty > 0){
            address tokenOwner = IERC721(token).owner();
            royaltyFee = SafeMath.div(SafeMath.mul(royalty, offerer._price), 100);
            require(IERC20(_offerToken).transferFrom(offerer._maker, tokenOwner, royaltyFee),"Failed to transfer royaltyFee");
        }
        //TokenId owner
        uint256 ownerAmount = SafeMath.sub(SafeMath.sub(offerer._price, protocolFee), royaltyFee);
        require(IERC20(_offerToken).transferFrom(offerer._maker, msg.sender, ownerAmount),"Failed to transfer seller");
        //Transfer token
        IERC721(token).safeTransferFrom(msg.sender, offerer._maker, tokenId);
        //Delete seller
        bytes32 sellIndexId = keccak256(abi.encodePacked(tokenId, token));
        delete _sellList[sellIndexId];
        //Delete offer
        delete _itemOffers[indexId];

        emit AcceptItemOrder(msg.sender, offerer._maker, token, offerer._price, tokenId);
        return true;
    }

    function acceptCollectionOffer(address token, address maker, uint256 tokenId) external checkWL(token) returns (bool) {
        //Check owner
        require(isTokenOwner(token,tokenId), "Address mismatch");
        //Check offer status
        bytes32 indexId = keccak256(abi.encodePacked(token, maker));
	    CollectionOffer memory offerer = _collectionOffers[indexId];
        //Check endTime
        require(offerer._endTime > block.timestamp, "CollectionOffer is expire");
        //ProtocolFee
        uint256 protocolFee = SafeMath.div(SafeMath.mul(_protocolFee, offerer._price), 100);
        //Check discount
        for (uint256 i = 0; i < _discount.length; i++) {
            uint256 balances = IERC721(token).balanceOf(msg.sender);
            if (balances > 0) {
                protocolFee= SafeMath.div(SafeMath.mul(protocolFee, _discountRate), 100);
                break;
            }
        }
        require(IERC20(_offerToken).transferFrom(offerer._maker, _receiver, protocolFee),"Failed to transfer protocolFee");
        //Royalty
        uint256 royalty = _royalty[token];
        uint256 royaltyFee = 0;
        if(royalty > 0){
            address tokenOwner = IERC721(token).owner();
            royaltyFee = SafeMath.div(SafeMath.mul(royalty, offerer._price), 100);
            require(IERC20(_offerToken).transferFrom(offerer._maker, tokenOwner, royaltyFee),"Failed to transfer royaltyFee");
        }
        //TokenId owner
        uint256 ownerAmount = SafeMath.sub(SafeMath.sub(offerer._price, protocolFee), royaltyFee);
        require(IERC20(_offerToken).transferFrom(offerer._maker, msg.sender, ownerAmount),"Failed to transfer seller");
        //Transfer token
        IERC721(token).safeTransferFrom(msg.sender, offerer._maker, tokenId);
        //Delete seller
        bytes32 sellIndexId = keccak256(abi.encodePacked(tokenId, token));
        delete _sellList[sellIndexId];
        //Delete offer
        delete _collectionOffers[indexId];

        emit AcceptCollectionOrder(msg.sender, offerer._maker, token, offerer._price, tokenId);
        return true;
    }

}