// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./WithdrawAll.sol";
import "./OTC.sol";

contract Trader is WithdrawAll {

    struct TraderData {
        uint256 freeze;  // 0 no   1 yes
        uint256 validation;  //  0 no   1 yes
        uint256 status;  //  0 not enabled   1 normal
        string data;
        uint256 bail;
    }

    mapping(address => address) public inviter;
    mapping(address => TraderData) public traderList;

    // settings
    uint256 public defaultBail = 1000 * 1e18;
    uint public minBail = 1 * 1e18;
    uint256 public multiplier = 1;

    IERC20 public usdt;
    OTC public otc;

    event Register(address indexed from, address indexed superior, uint256 timestamp);

    constructor() {}

    function init(address _rootAddress) public onlyOwner {
        _invite(_rootAddress, address(1));
    }

    function inviteOwner(address from, address superior) public onlyOwner returns (bool) {

        require(inviter[from] == address(0), "Trader: The current user has been bound");

        _invite(from, superior);

        return true;
    }

    function register(address superior, uint256 amount, string memory _data) public returns (bool) {
        address from = _msgSender();

        require(inviter[superior] != address(0), "Trader: The current user has been bound");

        if (inviter[from] == address(0)) {
            _invite(from, superior);
        }

       _addBail(amount >= defaultBail ? amount : defaultBail);
        _setTraderData(_data);

        return true;
    }

    function addBail(uint256 amount) public returns (bool) {

        _addBail(amount);
        return true;

    }

    function removeBail(uint256 amount) public returns (bool) {
        _removeBail(amount);
        return true;

    }

    function setTraderData(string calldata _data) public {
        traderList[msg.sender].data = _data;
    }
    
    function getTraderStatus(address _traderAddress) public view returns (bool status){
        TraderData memory _trader = traderList[_traderAddress];

        return _trader.freeze == 0 && _trader.status == 1;
    }

    function _addBail(uint256 amount) private {
        usdt.transferFrom(msg.sender, address(this), amount);

        TraderData storage _trader = traderList[msg.sender];
        _trader.bail += amount;
        _trader.status = 1;
    }

    function _removeBail(uint256 amount) private {
        TraderData storage _trader = traderList[msg.sender];

        require(amount <= _trader.bail, "Trader : amount below minimum deposit");

        usdt.transfer(msg.sender, amount == 0 ? _trader.bail : amount);

        _trader.bail -= amount;
        if (_trader.bail < minBail) {
            address _sender = msg.sender;
            uint adCount = otc.getTraderAdList(_sender).length;
            uint orderCount = otc.getTraderOrderList(_sender).length;

            require(adCount == 0 && orderCount == 0, "Trader: There are unfulfilled orders or advertisements");
            _trader.status = 0;
        }

    }

    function _invite(address from, address superior) private {

        require(from != superior, "Trader: The superior cannot be himself");
        inviter[from] = superior;
        emit Register(from, superior, block.timestamp);
    }

    function _setTraderData(string memory _data) private {
        if (keccak256(abi.encodePacked(_data)) == keccak256(abi.encodePacked(''))) return;

        TraderData storage _trader = traderList[msg.sender];
        _trader.data = _data;

    }

    function setUSDTAddress(IERC20 _usdt) external onlyOwner {
        usdt = _usdt;
    }

    function setOTCAddress(OTC _otc) external onlyOwner {
        otc = _otc;
    }

    function setMinBail(uint256 _minBail) external onlyOwner {
        minBail = _minBail;
    }

    function setDefaultBail(uint256 _defaultBail) external onlyOwner {
        defaultBail = _defaultBail;
    }

    function setMultiplier(uint256 _multiplier) external onlyOwner {
        multiplier = _multiplier;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract WithdrawAll is Ownable {

    function withdrawEth(address payable receiver, uint amount) public onlyOwner payable {
        uint balance = address(this).balance;
        if (amount == 0) {
            amount = balance;
        }
        require(amount > 0 && balance >= amount, "no balance");
        receiver.transfer(amount);
    }

    function withdrawToken(address receiver, address tokenAddress, uint amount) public onlyOwner {
        uint balance = IERC20(tokenAddress).balanceOf(address(this));
        if (amount == 0) {
            amount = balance;
        }

        require(amount > 0 && balance >= amount, "bad amount");
        IERC20(tokenAddress).transfer(receiver, amount);
    }

    function withdrawNft(address receiver, address nftAddress, uint256 tokenId) public onlyOwner {
        IERC721(nftAddress).transferFrom(address(this), receiver, tokenId);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Trader.sol";

contract OTC is Ownable {

    // settings
    uint8 public userMaxOrderCount = 3;
    mapping(address => bool) public userLockStatus; // true: lock false: normal

    uint256 public timeOut = 1800;
    uint256 fiatDecimal = 1e18;
    bool public pause;

    Trader trader;

    mapping(address => uint256[]) traderAdList;
    mapping(address => uint256[]) traderOrderList;
    uint256 public traderMaxOrderCount = 3;
    uint256 public traderMaxAdCount = 3;


    //  AD
    struct Ad {
        uint256 id;
        address owner;
        address token;
        uint256 totalAmount;
        uint256 amount;
        uint256 price;
        uint256 fiat; // fiat type
        uint256 singleMin;
        uint256 singleMax;
        uint256 timestamp;
        uint8 adType;  //0:shell   1:buy
        uint[] pay;
        uint256 endTimestamp;
        uint status;  // 0:cancel 1:ongoing 2:done
    }

    uint256 public counterAdId;
    mapping(uint256 => Ad) public sellAd;
    mapping(uint256 => Ad) public buyAd;

    // order
    struct Order {
        uint256 id;
        address owner;
        address tokenAddress;
        address traderAddress;
        address nextAddress;
        uint256 adId;
        uint256 amount;
        uint256 price;
        uint256 fiat;
        uint256 createTimestamp;
        uint8 orderType; // 0:sell  1:boy
        uint256 payTimestamp;
        uint256 endTimestamp;
        uint8 status; // 0:cancel 1:Waiting payment  2: Waiting for confirmation  3: done  4: freeze

    }

    mapping(uint256 => Order) public sellOrder;
    mapping(uint256 => Order)  public buyOrder;

    uint256 public counterOrderId;
    mapping(address => uint256[]) public userOrderList;

    // event
    // setting event
    event SetUserLockStatus(address userAddress, bool status, uint256 timestamp);
    event SetUserMaxOrderCount(uint8 count, uint256 timestamp);
    event SetTimeOut(uint256 count, uint256 timestamp);

    // ad event
    event CreateAd(address indexed token, address trader, uint256 indexed adId, uint indexed adType, uint256 amount, uint256 price, uint256 fiat, uint[] pay, uint256 singleMin, uint256 singleMax, uint256 timestamp);
    event DeleteAd(address indexed token, address trader, uint256 indexed adId, uint256 amount, uint256 timestamp);

    // order event
    event CreateOrder(address indexed token, uint256 indexed adId, uint256 indexed orderId, uint256 amount, uint256 price, uint256 fiat, uint256 timestamp);
    event ConfirmPayment(uint256 indexed orderId, uint256 timestamp);
    event ConfirmReceive(uint256 indexed orderId, uint256 timestamp);
    event Complaint(uint256 indexed orderId, uint256 timestamp);
    event CancelOrder(uint256 indexed orderId, uint256 timestamp);

    constructor() {
    }

    function createAd(address token, uint8 _adType, uint256 _amount, uint256 _price, uint256 _fiat, uint256 _singleMin, uint256 _singleMax, uint[] memory _pay) external returns (uint256) {
        address _sender = msg.sender;

        require(!pause, "OTC: contract pause !");
        require(_amount > 0, "OTC: create min amount");
        require(trader.getTraderStatus(_sender), "OTC: trader Status Error");
        require(_singleMin <= _singleMax, "OTC: The minimum transaction amount shall be less than the maximum transaction amount");

        //        require(!buyStatus[_sender] && !sellStatus[_sender], "OTC: create cannot be repeated");

        if (_adType == 0) {//shellAd
            uint256 beforeAmount = IERC20(token).balanceOf(address(this));
            IERC20(token).transferFrom(_sender, address(this), _amount);
            uint256 realAmount = IERC20(token).balanceOf(address(this)) - beforeAmount;
            require(realAmount == _amount, 'OTC : Token err');
        }

        counterAdId = ++counterAdId;

        Ad memory ad;

        ad.id = counterAdId;
        ad.owner = _sender;
        ad.token = token;
        ad.totalAmount = _amount;
        ad.amount = _amount;
        ad.price = _price;
        ad.fiat = _fiat;
        ad.singleMin = _singleMin;
        ad.singleMax = _singleMax;
        ad.timestamp = block.timestamp;
        ad.adType = _adType;
        ad.pay = _pay;
        ad.status = 1;

        _adType == 0 ? sellAd[counterAdId] = ad : buyAd[counterAdId] = ad;

        _addTraderAd(_sender, counterAdId);
        emit CreateAd(token, _sender, counterAdId, _adType, _amount, _price, _fiat, _pay, _singleMin, _singleMax, block.timestamp);

        return counterAdId;
    }


    function deleteAd(uint8 _adType, uint256 _adId) external returns (uint256) {

        address _sender = msg.sender;

        require(trader.getTraderStatus(_sender), "OTC: trader Status Error");

        Ad storage ad = _adType == 0 ? sellAd[_adId] : buyAd[_adId];

        uint256 _amount = ad.amount;

        ad.amount = 0;
        ad.status = 0;
        ad.endTimestamp = block.timestamp;

        if (ad.adType == 0) {//shellAd
            require(_amount > 0 && ad.status == 1, "OTC: del not amount");
            require(IERC20(ad.token).balanceOf(address(this)) >= _amount, "OTC : Abnormal balance of contract");

            IERC20(ad.token).transfer(_sender, _amount);
        }


        uint256 id = ad.id;

        _removeTraderAd(_sender, _adId);

        emit DeleteAd(ad.token, ad.owner, id, _amount, block.timestamp);

        return id;
    }


    function _chickOrder(address _sender, Ad memory _ad, uint256 _amount) private view {
        require(!pause, "OTC: contract pause !");
        require(!userLockStatus[_sender], 'OTC : User Status Error');
        require(userOrderList[_sender].length < userMaxOrderCount, "OTC : Excessive user orders");
        require(trader.getTraderStatus(_ad.owner), 'OTC : Trader status error');
        require(_ad.status == 1, 'OTC : The AD amount err');
        require(_ad.amount >= _amount, 'OTC : The purchase amount should be less than the AD amount');

        uint256 amount = _amount * _ad.price / fiatDecimal;
        require(amount >= _ad.singleMin && amount <= _ad.singleMax, "OTC : Transaction amount error");
    }


    function createOrder(uint8 _orderType, uint256 _adId, uint256 _amount) public returns (uint256) {
        address _sender = msg.sender;


        //The sell order is queried in the Buy AD
        Ad storage ad = _orderType == 0 ? buyAd[_adId] : sellAd[_adId];

        _chickOrder(_sender, ad, _amount);
        _beforeCreatOrder(_sender, ad.owner);

        if (_orderType == 0) {// sellOrder  lock token
            uint256 beforeAmount = IERC20(ad.token).balanceOf(address(this));
            IERC20(ad.token).transferFrom(_sender, address(this), _amount);
            uint256 realAmount = IERC20(ad.token).balanceOf(address(this)) - beforeAmount;
            require(realAmount == _amount, 'OTC : Token err');
        }

        ad.amount -= _amount;
        if (ad.amount == 0) {
            ad.status = 2;
            ad.endTimestamp = block.timestamp;
            _removeTraderAd(ad.owner, ad.id);
        }

        Order memory _order;

        counterOrderId = ++counterOrderId;

        _order.id = counterOrderId;
        _order.createTimestamp = block.timestamp;
        _order.amount = _amount;
        _order.price = ad.price;
        _order.adId = ad.id;
        _order.fiat = ad.fiat;
        _order.owner = _sender;
        _order.traderAddress = ad.owner;
        _order.tokenAddress = ad.token;
        _order.orderType = _orderType;
        _order.status = 1;
        _order.nextAddress = _order.orderType == 0 ? ad.owner : _sender;

        _orderType == 0 ? sellOrder[counterOrderId] = _order : buyOrder[counterOrderId] = _order;

        _afterCreatOrder(_order);

        emit CreateOrder(_order.tokenAddress, ad.id, _order.id, _order.amount, _order.price, _order.fiat, block.timestamp);

        return counterOrderId;
    }

    function cancelOrder(uint8 _orderType, uint256 _orderId) public returns (bool){
        Order storage _order = _findOrder(_orderType, _orderId);

        require(_order.status == 1, "OTC: Order status error");

        _order.status = 0;
        _order.endTimestamp = block.timestamp;

        _orderType == 0 ? _cancelSellOrder(_order) : _cancelBuyOrder(_order);

        emit CancelOrder(_orderId, block.timestamp);

        return true;
    }

    function confirmPay(uint8 _orderType, uint256 _orderId) public returns (bool){
        Order storage _order = _findOrder(_orderType, _orderId);

        require(_order.status == 1, "OTC: Order status error, expect waiting payment");
        require(_order.nextAddress == msg.sender, "OTC: Have the right to operate !");

        _order.status = 2;
        _order.payTimestamp = block.timestamp;
        _order.nextAddress = _order.orderType == 0 ? _order.owner : _order.traderAddress;

        emit ConfirmPayment(_orderId, block.timestamp);

        return true;
    }

    function confirmReceive(uint8 _orderType, uint256 _orderId) public returns (bool){
        Order storage _order = _findOrder(_orderType, _orderId);

        require(_order.status == 2, "OTC: Order status error, expect waiting receive");
        require(_order.nextAddress == msg.sender, "OTC: Have the right to operate !");

        address _receive = _orderType == 0 ? _order.traderAddress : _order.owner;

        _endOrder(_order, _receive);

        _afterEndOrder(_order);

        emit ConfirmReceive(_orderId, block.timestamp);

        return true;
    }

    function complaintOrder(uint8 _orderType, uint256 _orderId) public returns (bool){
        Order storage _order = _findOrder(_orderType, _orderId);
        address _sender = _msgSender();

        //        if (_orderType == 0 && _sender == _order.owner) {
        //            require(_order.status == 1 && _order.createTimestamp + timeOut >= block.timestamp, "OTC : Orders are not grievable");
        //
        //        } else if (_orderType == 0 && _sender == _order.traderAddress) {
        //            require(_order.status == 2 && _order.payTimestamp + timeOut >= block.timestamp, "OTC : Orders are not grievable");
        //
        //        } else if (_orderType == 1 && _sender == _order.traderAddress) {
        //            require(_order.status == 1 && _order.createTimestamp + timeOut >= block.timestamp, "OTC : Orders are not grievable");
        //
        //        } else {
        //            require(_order.status == 2 && _order.payTimestamp + timeOut >= block.timestamp, "OTC : Orders are not grievable");
        //        }

        require(_order.status == 1 || _order.status == 2, "");

        require(_order.nextAddress != _sender, "OTC: Have the right to operate !");

        if (_order.status == 1) {
            require(_order.createTimestamp + timeOut >= block.timestamp, "OTC : Orders are not grievable");
        } else {
            require(_order.createTimestamp + timeOut >= block.timestamp, "OTC : Orders are not grievable");
        }

        _order.status = 4;

        emit Complaint(_orderId, block.timestamp);

        return true;
    }


    function rulingOrder(uint8 _orderType, uint256 _orderId, address _receive) public onlyOwner returns (bool){
        Order storage _order = _findOrder(_orderType, _orderId);

        require(_order.status == 4, 'OTC: Order status error, The order was not complaint');

        _endOrder(_order, _receive);
        return true;
    }


    //    mapping(address => uint256[]) public traderAdList;
    //    mapping(address => uint256[]) public traderOrderList;
    function getTraderAdList(address _traderAddress) public view returns (uint256[] memory traderAd){
        return traderAdList[_traderAddress];
    }

    function getTraderOrderList(address _traderAddress) public view returns (uint256[] memory traderOrder){
        return traderOrderList[_traderAddress];
    }

    function _findOrder(uint8 _orderType, uint256 _orderId) internal view returns (Order storage _order){
        _order = _orderType == 0 ? sellOrder[_orderId] : buyOrder[_orderId];
        require(_order.id != 0, "OTC: OrderId error");
    }

    function _cancelSellOrder(Order storage _order) private {
        require(msg.sender == _order.traderAddress, "OTC: Cancellation can only be made by the trader");
        IERC20(address(this)).transfer(_order.owner, _order.amount);
    }

    function _cancelBuyOrder(Order storage _order) private {
        require(msg.sender == _order.owner, "OTC: Cancellation can only be made by the user");
        IERC20(address(this)).transfer(_order.traderAddress, _order.amount);
    }

    function _beforeCreatOrder(address _user, address _trader) private view {

        // trader order
        uint256[] memory _traderOrderList = traderOrderList[_trader];

        uint count;

        for (uint i; i < _traderOrderList.length; i++) {

            uint256 orderId = _traderOrderList[i];
            Order memory _order = sellOrder[orderId];
            if (_order.traderAddress != _trader) {
                _order = buyOrder[orderId];
            }

            if (_order.status == 4) {
                revert("OTC: Abnormal orders of merchants 1 !");
            } else if (_order.status == 1 && _order.orderType == 0) {
                count++;
            } else if (_order.status == 2 && _order.orderType == 1) {
                count++;
            }

            if (count >= traderMaxOrderCount) revert("OTC: Abnormal orders of merchants 2 !");

        }

        // user order
        uint256[] memory _userOrderList = userOrderList[_user];
        for (uint i; i < _userOrderList.length; i++) {

            uint256 orderId = _userOrderList[i];
            Order memory _order = sellOrder[orderId];
            if (_order.owner != _user) {
                _order = buyOrder[orderId];
            }

            if (_order.status == 4) {
                revert("OTC: Abnormal orders of merchants 1 !");
            }
        }
    }


    function _afterCreatOrder(Order memory _order) private {
        _addUserOrder(_order.owner, _order.id);
        _addTraderOrder(_order.traderAddress, _order.id);
    }

    function _afterEndOrder(Order memory _order) private {
        _removeUserOrder(_order.owner, _order.id);
        _removeTraderOrder(_order.traderAddress, _order.id);
    }

    function _addUserOrder(address _user, uint256 _orderId) private {
        uint256[] storage _userOrderList = userOrderList[_user];

        require(_userOrderList.length < userMaxOrderCount, 'OTC: Please complete other orders first');

        _userOrderList.push(_orderId);
    }

    function _addTraderOrder(address _trader, uint256 _orderId) private {
        uint256[] storage _traderOrderList = traderOrderList[_trader];

        _traderOrderList.push(_orderId);
    }

    function _removeUserOrder(address _user, uint256 _orderId) private {
        uint256[] storage _userOrderList = userOrderList[_user];

        uint256 length = _userOrderList.length;
        for (uint i = 0; i < length; i++) {
            if (_userOrderList[i] != _orderId) continue;
            _userOrderList[i] = _userOrderList[length - 1];
            _userOrderList.pop();
            break;
        }
    }

    function _removeTraderOrder(address _trader, uint256 _orderId) private {
        uint256[] storage _traderOrderList = traderOrderList[_trader];

        uint256 length = _traderOrderList.length;
        for (uint i = 0; i < length; i++) {
            if (_traderOrderList[i] != _orderId) continue;
            _traderOrderList[i] = _traderOrderList[length - 1];
            _traderOrderList.pop();
            break;
        }
    }

    function _addTraderAd(address _trader, uint256 _orderId) private {
        uint256[] storage _traderAdList = traderAdList[_trader];

        require(_traderAdList.length < traderMaxAdCount, 'OTC: Please complete other AD first');

        _traderAdList.push(_orderId);
    }

    function _removeTraderAd(address _trader, uint256 _adId) private {
        uint256[] storage _traderAdList = traderAdList[_trader];

        uint256 length = _traderAdList.length;
        for (uint i = 0; i < length; i++) {
            if (_traderAdList[i] != _adId) continue;
            _traderAdList[i] = _traderAdList[length - 1];
            _traderAdList.pop();
            break;
        }
    }

    function _endOrder(Order storage _order, address _receive) private {
        _order.status = 3;
        _order.endTimestamp = block.timestamp;
        _order.nextAddress = address(1);
        IERC20(_order.tokenAddress).transfer(_receive, _order.amount);
    }

    function setUserLockStatus(address user, bool _status) external onlyOwner returns (bool){
        userLockStatus[user] = _status;
        emit SetUserLockStatus(user, _status, block.timestamp);
        return true;
    }

    function setTrader(Trader _trader) external onlyOwner returns (bool){
        trader = _trader;
        return true;
    }

    function setPause(bool _pause) external onlyOwner returns (bool){
        pause = _pause;
        return true;
    }

    function setTimeOut(uint256 _timeOut) external onlyOwner returns (bool){
        timeOut = _timeOut;
        emit SetTimeOut(_timeOut, block.timestamp);
        return true;
    }

    function setUserMaxOrderCount(uint8 _count) external onlyOwner returns (bool){
        userMaxOrderCount = _count;
        emit SetUserMaxOrderCount(_count, block.timestamp);
        return true;
    }

    function setTraderMaxOrderCount(uint256 _count) external onlyOwner returns (bool){
        traderMaxOrderCount = _count;
        return true;
    }

    function setTraderMaxAdCount(uint256 _count) external onlyOwner returns (bool){
        traderMaxAdCount = _count;
        return true;
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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