/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/WFSInvite.sol


pragma solidity 0.8.15;




/**   
*   @dev Invitation for investment business：require 2292
*          Release, Investment, Release Withdrawal, Investment Withdrawal，
*          Query of release order and cumulative investment amount
*          Publish Event, Investment Event, Publish Withdrawal Event, Investment Withdrawal Event
*          Setting of release fee and investment fee
*          WFC currency contract address setting, USDT contract address setting
*/

contract WFSInvite is Context, Ownable {
    // Order No
    uint256 private _orderId = 0;
    // Release the raised deposit proportion, 4-digit precision
    uint256 public cashPledge = 10000;
    // Time of default 
    uint256 public delay = 3 days;
    // Home Currency WFC
    address public tokenA;
    // Exchange currency USDT
    address public tokenB;
    // Order release commission proportion, 4-digit precision
    uint256 public inviteFee;
    // Withdrawal fee proportion, 4-digit precision
    uint256 public withDrawFee;
    // Accumulated service charge
    uint256 private _totalFee;

    // The issuer takes back the raised money, and the order unit price is N% higher than the market price. The precision is 4 digits, and the default is 0.1%
    uint256 public retrievedOverPriceRide = 1000;
    // The issuer takes back the raised funds, and the current market has the highest price of USD18, which defaults to the current highest price of 0USDT
    uint256 public orderMaxPrice = 0;

    // Publishing user corresponding to the order ID
    mapping(uint256 => address) private _initiator;
    // Total amount raised corresponding to the order ID
    mapping(uint256 => uint256) private _tAmt;
    // Raised amount corresponding to order ID
    mapping(uint256 => uint256) private _eAmt;
    // Raising unit price corresponding to the order ID
    mapping(uint256 => uint256) private _initPrice;
    // Raising deadline corresponding to order ID
    mapping(uint256 => uint256) private _deadline;
    // Whether the order is ended, true has ended, false has not ended
    mapping(uint256 => bool) private _ended;
    // Prepaid amount corresponding to order ID(USDT)
    mapping(uint256 => uint256) private _prepaid;
    // Cumulative total investment of a user in an order ID
    mapping(address => mapping(uint256 => uint256)) private _cAmt;
    // Whether the user invests
    mapping(address => bool) private _isInvestment;
    
    // A publisher user manually terminates (withdraws) the remaining amount of private placement（USDT）
    mapping(address => uint256) private _surplusSumPirce;

    // Issue Order Event
    event Invited(uint256 indexed id, address indexed initiator, uint256 amount, uint256 price);
    // Investment Events
    event Investment(uint256 indexed id, address indexed investors, uint256 amount);
    // Order retrieval event
    event Retrieved(address indexed account, uint256 id);
    // Investment claim event
    event Withdraw(address indexed account, uint256 id);

    constructor(address _tokenA, address _tokenB) {
        // WFC Contract address of currency
        tokenA = _tokenA;
        // BSC BEP20_USDT Contract address of currency
        tokenB = _tokenB;

        // Service charge for invitation release 0.5%
        inviteFee = 50;
        // Service charge for user withdrawal 1%
        withDrawFee = 100;
    }
    
    // @dev Service charge setting, release service charge and withdrawal service charge
    function setFee(uint256 _inviteFee, uint256 _withDrawFee) external onlyOwner {
        inviteFee = _inviteFee;
        withDrawFee = _withDrawFee;
    }

    // @dev Set the issuer to retrieve the raised funds. The order unit price is N% higher than the market price. The precision is 4 digits. The default is 0.1%
    function setOverPriceRide(uint256 _retrievedOverPriceRide) external onlyOwner {
        retrievedOverPriceRide = _retrievedOverPriceRide;
    }

    // @dev Query the order details by issuing the order ID
    // @param: _id Order ID
    // @return: _initiator[_id] Publish User
    // @return: _tAmt[_id]      Total amount raised
    // @return: _eAmt[_id]      Raised amount
    // @return: _initPrice[_id] Unit Price
    // @return: _prepaid[_id]   Advance deposit
    // @return: _deadline[_id]  Investment deadline
    // @return: _ended[_id]     End Status
    function getInviteOrder(uint256 _id) public view returns(address, uint256, uint256, uint256, uint256, uint256, bool) {
        return (_initiator[_id], _tAmt[_id], _eAmt[_id], _initPrice[_id], _prepaid[_id], _deadline[_id], _ended[_id]);
    }

    // @dev Query the total investment by user and order number
    // @param _account: User address
    // @param _id: Order ID
    // @return Cumulative investment amount of an order of a user
    function getInjection(address _account, uint256 _id) public view returns(uint256) {
        return _cAmt[_account][_id];
    }

    // @dev The platform checks the service charge received by the contract
    function getFee() external view onlyOwner returns(uint256) {
        return _totalFee;
    }

    // @dev Service charge received from platform withdrawal contract
    function reFee() external onlyOwner returns(bool) {
        uint256 _amount = _totalFee;
        _totalFee = 0;
        IERC20(tokenB).transfer(_msgSender(), _amount);        
        return true;
    }

    // @dev Query the remaining deposit amount after the user withdraws the private placement through the user USDT
    // @param _account: User address
    function getSurplusSumPirce(address _account) public view returns(uint256){
        return _surplusSumPirce[_account];
    }  
        
    // @dev Release investment
    // @param: _amount The total number of WFCs raised should pay attention to the accuracy = 10 ** 8
    // @param: _price Pay attention to the accuracy of the unit price raised = 10 ** 18
    // @param: _date Deadline for raising
    function invited(address _inviter, uint256 _amount, uint256 _price, uint256 _date) public returns(bool) {        

        // USDT to be paid=total amount raised * unit price * deposit (precision of WFC is 8, precision of percentage of deposit is 4:8+4=12)
        uint256 _deposit = (_amount * _price * cashPledge)  / 10 ** 12; 
        // The minimum deposit shall not be less than 1 USDT
        require(_deposit >= 1000000000000000000, "INV1");
        // Service charge=deposit * service charge proportion, with precision of 4:
        uint256 _fee = _deposit * inviteFee / 10000;
        // Total payable amount=USDT payable+service charge USDT
        uint256 _sum = _deposit + _fee;
        
        // Last publisher withdrew the remaining deposit raised USDT 20220905, new
        uint256 _surplusSumPirceEnd = _surplusSumPirce[_inviter];
        //Actual total payable amount USDT=total payable amount - the last issuer withdrew the remaining raised deposit 20220905
        if(_sum <= _surplusSumPirceEnd) {
            _surplusSumPirce[_inviter] = _surplusSumPirceEnd - _sum;
            _sum = 0;    
        }
        if(_sum > _surplusSumPirceEnd){
            _surplusSumPirce[_inviter] = 0;
            _sum = _sum - _surplusSumPirceEnd;
        }
  
        // Order ID
        _orderId++;
        // Use local variables to prevent reentry
        uint256 _id = _orderId;

        // Transfer USDT to the contract
        IERC20(tokenB).transferFrom(_inviter, address(this), _sum);
        
        // Record order information
        // Deposit paid (internal variable of function, handled separately)
        _prepaid[_id] = _deposit;
        // _initiator[_id] Publish User
        // _tAmt[_id]      Total amount raised
        // _initPrice[_id] Unit Price
        // _deadline[_id]  Investment deadline
        // _ended[_id]     End Status
        (_initiator[_id], _tAmt[_id], _initPrice[_id], _deadline[_id],  _ended[_id]) = (_inviter, _amount, _price, _date, false);

        // Increase in total handling charges
        _totalFee += _fee;

        //Set market order maximum price
        if(orderMaxPrice < _price){
            orderMaxPrice = _price;
        }
        
        emit Invited(_id, _inviter, _amount, _price);

        return true;
    }

    // @dev User investment
    // @param: _id     Order No
    // @param: _amount Investment quantity WFC should pay attention to precision=10 * * 8
    function investment(uint256 _id, uint256 _amount) public returns(bool) {
   
        require(_amount > 0 , "INJ1");
        // Raising has not been closed yet
        require(!(_ended[_id]), "INJ2");
        // Invest before the investment deadline
        require(block.timestamp < _deadline[_id], "INJ3");
        // The remaining investment amount of the order is greater than or equal to the investment amount
        require(_tAmt[_id] - _eAmt[_id] >= _amount, "INJ4" );

        address _account = _msgSender();

        // Users can only invest one sum at a time
        require(!(_isInvestment[_account]), "INJ5");     

        // Put the investment money into the contract
        IERC20(tokenA).transferFrom(_account, address(this), _amount);
        // Update the amount raised by the order
        _eAmt[_id] += _amount;
        // Increase the user's investment amount
        _cAmt[_account][_id] += _amount;

        // Users have invested
        _isInvestment[_account] = true;

        emit Investment(_id, _account, _amount);
        
        return true;
    }
    
    // @dev The issuer can retrieve the raised funds at any time (the order will be closed in advance once retrieved)
    // @param: _id Order No
    function retrieved(uint256 _id) public returns(bool) {
        address _retriever = _msgSender();
        // Retriever and publisher are the same person (only their own can be retrieved)
        require(_retriever == _initiator[_id], "RET1");
        // Previously, the order was not closed due to "withdrawal" or "default"
        require(!(_ended[_id]), "RET2");

        // a.Conditions: the invitation order has not expired and the released quantity has not reached
        if(block.timestamp < _deadline[_id] && _eAmt[_id] < _tAmt[_id]){
            //b.Condition: There is a unit price higher than the publisher's invitation order in the market (the platform sets the proportion parameter higher than the unit price)
            uint256 _initPriceRideVal = _initPrice[_id] * retrievedOverPriceRide / 10000;
            uint256 _initPriceEnd = _initPrice[_id] + _initPriceRideVal;
            //The highest price in the current market is not higher than the unit price of previous orders
            require(_initPriceEnd <= orderMaxPrice, "RET3");
        }

        // Paid items
        uint256 _hPay = _prepaid[_id];
        // USDT quantity payable=WFC quantity raised * USDT unit price/WFC precision
        uint256 _sPay = (_eAmt[_id] * _initPrice[_id]) / 10 ** 8;

        // First process the internal data of this contract, then initiate external business
        // Close the raising
        _ended[_id] = true;
        // Update paid amount to payable amount
        _prepaid[_id] = _sPay;

        // If the amount paid is not enough (payable>paid), you need to make up
        if(_sPay > _hPay) {
            uint _amount = _sPay - _hPay;
            IERC20(tokenB).transferFrom(_retriever, address(this), _amount);       
        }
        
        if(block.timestamp >= _deadline[_id] || _eAmt[_id] >= _tAmt[_id]){
            // If more money has been paid (paid>payable), and the refund time is due or the amount reaches the target, the remaining deposit needs to be returned
            if(_hPay > _sPay) {
                uint256 _amount = _hPay - _sPay;
                IERC20(tokenB).transfer(_retriever, _amount);
            }
        }else{
            //If more money has been paid (paid>payable), it will not be refunded, and the remaining deposit will be automatically placed in the next invitation order of the publisher (the deposit cannot be retrieved by the publisher)
            if(_hPay > _sPay) {
                uint256 _amount = _hPay - _sPay;
                uint256 _oldSurplusSumPirce = _surplusSumPirce[_retriever];
                _surplusSumPirce[_retriever] =  _oldSurplusSumPirce + _amount;
            }
        }        
    
        // Transfer the WFC raised to the raising party
        IERC20(tokenA).transfer(_retriever, _eAmt[_id]);

        // Change the investment end time to the current 20220905 new
        _deadline[_id] = block.timestamp;

        emit Retrieved(_retriever, _id);
        
        return true;
    }

    // @dev The user withdraws the investment. If the order is in normal status, the user obtains USDT; If the order exceeds the default time, the user obtains USDT and returns all WFCs invested
    // @param: _id Order No
    function withdraw(uint256 _id) public returns(bool) {
        address _account = _msgSender();
        // This is an effective investor
        require(_isInvestment[_account], "WD0");     
        // It can be withdrawn after the investment is closed+N days of extension
        require(block.timestamp >= (_deadline[_id] + delay), "WD1");
        
        // WFC invested by users
        uint256 _amount = _cAmt[_account][_id];
        // The USDT that the user should share=the deposit paid by the issuer * the total amount of personal investment/the amount of investment received by the order
        uint256 _bouns = _prepaid[_id] * _amount / _eAmt[_id];
        // Service Charge
        uint256 _fee = _bouns * withDrawFee / 10000;

        // WFC invested by users is 0
        _cAmt[_account][_id] = 0;
        // Transfer USDT to investors
        IERC20(tokenB).transfer(_account, (_bouns - _fee));
        // Increase in platform fees
        _totalFee += _fee;
        
        // If the publisher is not normally closed after the expiration, the publisher is deemed to be in breach of contract and needs to return the WFC invested by users
        if(!(_ended[_id])) {
            _ended[_id] = true;
            // Return to user WFC
            IERC20(tokenA).transfer(_account, _amount);
        }
        
        // Mark the investor as not an investor after the investment is withdrawn
        _isInvestment[_account] = false;

        emit Withdraw(_account, _id);

        return true;
    }

}