/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    address private owner;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IERC1155{
    function balanceOf(address account, uint256 id) external view returns (uint256);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

contract Marketplace is Owner, ReentrancyGuard {

    uint256 public sellFeePercentage; // example: 500 = 5%
    address public walletReceivingSellfee;

    address public charactersContract_1; // parameter to newSellOrder: _type_nft = 1
    address public charactersContract_2; // parameter to newSellOrder: _type_nft = 2
    address public weaponsContract_1;    // parameter to newSellOrder: _type_nft = 3
    address public weaponsContract_2;    // parameter to newSellOrder: _type_nft = 4
    address public landsContract_1;      // parameter to newSellOrder: _type_nft = 5
    address public landsContract_2;      // parameter to newSellOrder: _type_nft = 6
    address public landsContract_3;      // parameter to newSellOrder: _type_nft = 7
    address public spaceShipsContract;   // parameter to newSellOrder: _type_nft = 8

    bool public lockNewSellOrders;
    uint256 public totalOrders;
    mapping(uint256 => SellOrder) public marketList;
    mapping(address => uint256[]) public mySellOrders;

    struct SellOrder {
        uint256 token_id;
        uint256 price;
        address seller;
        bool status; // false:closed, true: open
        address buyer;
        uint128 type_nft; // example: 1 = charactersContract_1
    }

    // Events
    event OrderAdded(
        uint256 order_id,
        uint256 indexed token_id,
        address indexed seller,
        uint256 price,
        uint256 type_nft
    );
    event OrderSuccessful(
        uint256 order_id,
        uint256 indexed token_id,
        address indexed seller,
        uint256 price,
        address indexed buyer,
        uint256 type_nft
    );
    event OrderCanceled(
        uint256 order_id,
        uint256 indexed token_id,
        address indexed seller,
        uint256 price,
        uint256 type_nft
    );
    event SetSellFee(uint256 oldValue, uint256 newValue);

    constructor(address _walletReceivingSellfee, uint256 _sellFeePercentage) {
        setFeeWallets(_walletReceivingSellfee);
        modifySellFeePercentage(_sellFeePercentage);
    }

    function setNFTContracts(address _charactersContract_1, address _charactersContract_2, address _weaponsContract_1, address _weaponsContract_2, address _landsContract_1, address _landsContract_2, address _landsContract_3, address _spaceShipsContract) external isOwner {
        charactersContract_1 = _charactersContract_1;
        charactersContract_2 = _charactersContract_2;
        weaponsContract_1 = _weaponsContract_1;
        weaponsContract_2 = _weaponsContract_2;
        landsContract_1 = _landsContract_1;
        landsContract_2 = _landsContract_2;
        landsContract_3 = _landsContract_3;
        spaceShipsContract = _spaceShipsContract;
    }

    function setFeeWallets(address _walletReceivingSellfee) public isOwner {
        walletReceivingSellfee = _walletReceivingSellfee;
    }

    function modifyLockNewSellOrders(bool _newValue) external isOwner{
        lockNewSellOrders = _newValue;
    }

    function modifySellFeePercentage(uint256 _newVal) public isOwner {
        require(_newVal <= 9900, "the new value should range from 0 to 9900");
        emit SetSellFee(sellFeePercentage, _newVal);
        sellFeePercentage = _newVal;
    }

    function getSellFee(uint256 _amount) public view returns(uint256){
        return (_amount*sellFeePercentage)/(10**4);
    }

    function getNFTContract (uint256 _type_nft) private view returns (address) {
        require(_type_nft >= 1 && _type_nft <= 8, "invalid _type_nft");
        address contractAddress;
        if (_type_nft == 1){
            contractAddress = charactersContract_1;
        }else if (_type_nft == 2){
            contractAddress = charactersContract_2;
        }else if (_type_nft == 3){
            contractAddress = weaponsContract_1;
        }else if (_type_nft == 4){
            contractAddress = weaponsContract_2;
        }else if (_type_nft == 5){
            contractAddress = landsContract_1;
        }else if (_type_nft == 6){
            contractAddress = landsContract_2;
        } else if (_type_nft == 7){
            contractAddress = landsContract_3;
        } else if (_type_nft == 8){
            contractAddress = spaceShipsContract;
        }
        return contractAddress;
    }

    function newSellOrder(uint256 _token_id, uint256 _price, uint128 _type_nft) external returns (uint256) {
        address IERC1155Contract = getNFTContract(_type_nft);
        require(lockNewSellOrders == false, "cannot currently create new sales orders");
        require(IERC1155(IERC1155Contract).balanceOf(msg.sender, _token_id) >= 1, "you don't have enough balance to sell");
        require(_price > 0, "price must be greater than 0");
        IERC1155(IERC1155Contract).safeTransferFrom(
            msg.sender,
            address(this),
            _token_id,
            1,
            ""
        );

        uint256 newOrderId = totalOrders+1;
        marketList[newOrderId] = SellOrder(
            _token_id,
            _price,
            msg.sender,
            true,
            address(0),
            _type_nft
        );
        mySellOrders[msg.sender].push(newOrderId);
        totalOrders = totalOrders + 1;
        emit OrderAdded(newOrderId, _token_id, msg.sender, _price, _type_nft);
        return newOrderId;
    }

    function queryLengthOrdersOf(address _account) external view returns (uint256) {
        return mySellOrders[_account].length;
    }

    function cancelSellOrder(uint256 _orderId) external nonReentrant{
        require(marketList[_orderId].seller == msg.sender, "you are not authorized to cancel this order");
        require(marketList[_orderId].status == true, "this order sell already closed");
        address IERC1155Contract = getNFTContract(marketList[_orderId].type_nft);

        marketList[_orderId].status = false;
        IERC1155(IERC1155Contract).safeTransferFrom(
            address(this),
            marketList[_orderId].seller,
            marketList[_orderId].token_id,
            1,
            ""
        );
        emit OrderCanceled(_orderId, marketList[_orderId].token_id, marketList[_orderId].seller, marketList[_orderId].price, marketList[_orderId].type_nft);
    }

    function buy(uint256 _orderId) external payable nonReentrant{
        require(msg.sender != address(0) && msg.sender != marketList[_orderId].seller, "current sender is already owner of this token");
        require(msg.value >= marketList[_orderId].price, "insufficient balance to purchase the NFT");
        require(marketList[_orderId].status == true, "this sell order is closed");
        address IERC1155Contract = getNFTContract(marketList[_orderId].type_nft);

        marketList[_orderId].status = false;
        marketList[_orderId].buyer = msg.sender;

        uint256 sellFee = getSellFee(marketList[_orderId].price);
        uint256 sellerProfit = marketList[_orderId].price - sellFee;
        payable(marketList[_orderId].seller).transfer(sellerProfit);
        payable(walletReceivingSellfee).transfer(sellFee);

        IERC1155(IERC1155Contract).safeTransferFrom(
            address(this),
            msg.sender,
            marketList[_orderId].token_id,
            1,
            ""
        );
        emit OrderSuccessful(_orderId, marketList[_orderId].token_id, marketList[_orderId].seller, marketList[_orderId].price, msg.sender, marketList[_orderId].type_nft);
    }

    function withdraw() external isOwner{
        payable(msg.sender).transfer(address(this).balance);
    }

    function reverseOrders(uint256[] memory _orders_id) external isOwner{
        address IERC1155Contract;
        for (uint256 i=0; i<_orders_id.length; i++) {
            if(marketList[_orders_id[i]].status == true){
                IERC1155Contract = getNFTContract(marketList[_orders_id[i]].type_nft);
                marketList[_orders_id[i]].status = false;
                IERC1155(IERC1155Contract).safeTransferFrom(
                    address(this),
                    marketList[_orders_id[i]].seller,
                    marketList[_orders_id[i]].token_id,
                    1,
                    ""
                );
                emit OrderCanceled(_orders_id[i], marketList[_orders_id[i]].token_id, marketList[_orders_id[i]].seller, marketList[_orders_id[i]].price, marketList[_orders_id[i]].type_nft);
            }
        }
    }
}