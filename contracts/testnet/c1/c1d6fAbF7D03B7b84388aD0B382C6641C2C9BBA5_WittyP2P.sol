/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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

contract WittyP2P is ReentrancyGuard, Ownable {
    
    //using SafeMath for uint256;
    struct proposals{
        uint buyerUserCount;
        bool postStatus;
        uint types;
        uint favour;
        address given;
        address expectAddr;
        uint256 totalAmt;
    }
    
    struct tradingDetails {
        uint count;
        uint buyerAmt;
    }
    
    struct userDetails {
        address[] referer;
        uint totalRefererCommission;
    }
    
    // address public owner;
    uint public postId;
    bool public lockStatus;
    uint[10] public refPercent = [15,5,5,5,5,5,5,5,5,5];         
    uint public buyerFee = 1e18;                              
    uint public wittyDiscount = 0.25e18;
    uint8 public tokenLength;
    address public token;
    
    mapping(uint => proposals)public trade;
    mapping(uint => bool)public cancelStatus;
    mapping(uint => uint)public tradeCount;
    mapping(address => mapping(uint => tradingDetails))public traderList;
    mapping(address => uint[])public traderTrades;
    mapping(address => userDetails) public users;
    mapping(uint => address)public tokenList;
    mapping(address => uint)public wittyBalance;
    mapping(address => uint)public adminRevenue;
    mapping(address => mapping(address => uint))public refererCommission;

    event Post(address indexed from,uint post,uint Type,uint favour,uint amt,address expect,address token,uint time);
    event Exchange(address indexed from,uint tradeid,uint tradecount,address sell,uint sellAmount, uint buyAmount, uint time);
    event SellerTransfer(address indexed from,uint tradeid,uint tradeidcount,uint amt,uint time);
    event BuyerTransfer(address indexed from,uint tradeid,uint tradeidcount,uint amt,uint time);
    event SellerCancel(address indexed from,uint tradeid,uint tradeidcount,uint amt, bool status,uint time);
    event SellerActivate(address indexed from,uint tradeid,bool status,uint time);
    event Deposit(address indexed from,address indexed to,address token,uint amt,uint time);
    
    constructor (address _witty)  {
        // owner = _owner;
        token = _witty;
    }
    
    /**
     * @dev Throws if lockStatus is true
     */
    modifier isLock() {
        require(lockStatus == false, "Contract Locked");
        _;
    }
    
    modifier Trade(uint _tradeID) {
        require(_tradeID <= postId && _tradeID > 0,"Invalid trade id");
         _;
    }
    
    receive() payable external {}

    function depositWitty(uint amount)public {
        require(amount > 0,"Invalid params");
        IERC20(token).transferFrom(msg.sender,address(this),amount);
        wittyBalance[msg.sender] += amount;
    }
    
    // Admin can create trade
    function createPost(uint _type,uint _amount,address _given,uint _expectID,uint _favour) public payable onlyOwner isLock {
        require (_type == 1 || _type == 2,"Incorrect type");
        require (_favour == 1 || _favour == 2,"Incorrect favour");
        require (_expectID <= tokenLength && _expectID > 0,"Invalid Expect id");
        require(tokenList[_expectID] != address(0),"Expect address not found");
        require(tokenList[_expectID] != _given,"Expect given not to be same");
        
        postId++;
        proposals storage _Trade = trade[postId];
        
        if (_type == 1) {
            require(_given == address(this), "Token addr should be 0");
            require(_amount == 0 && msg.value > 0, "Invalid amount");

            require(payable(_given).send(msg.value), "Type1 Failed");
            _Trade.given = _given;
            _Trade.postStatus = true;
            _Trade.types = _type;
            _Trade.favour = _favour;
            _Trade.totalAmt =  msg.value;
            _Trade.expectAddr = tokenList[_expectID];

            emit Post(msg.sender, postId, _type, _favour, msg.value, tokenList[_expectID], _given, block.timestamp);
        }
        
        else if (_type == 2) {
            
            require(_given != address(0),"Need token addr");
            require(msg.value == 0 && _amount > 0,"Invalid amount");
            
            require(IERC20(_given).transferFrom(msg.sender, address(this), _amount), "Type 2 failed");
            _Trade.given = _given;
            _Trade.postStatus = true;
            _Trade.types = _type;
            _Trade.favour = _favour;
            _Trade.totalAmt =  _amount;
            _Trade.expectAddr = tokenList[_expectID];

            emit Post(msg.sender, postId, _type, _favour, _amount, tokenList[_expectID], _given, block.timestamp);
        }
    }
    
    // Buyers can exchange here by given tradeid and amount
    function exchange(uint _tradeID, address _sell, uint _sellAmount, uint _buyAmount, address[] memory _ref, uint8 buychoice) public payable isLock Trade(_tradeID) nonReentrant {
        
        proposals storage _Trade = trade[_tradeID];
        require(msg.sender != owner(), "Seller can't exchange");
        require(cancelStatus[_tradeID] == false, "Seller cancel the trade");
        require(refPercent.length == _ref.length, "Incorrect referer values");
        require(_Trade.expectAddr == _sell, "This is not expect addr");
        require(_Trade.totalAmt >= _buyAmount, "Not enough amount left");

        if (_Trade.favour == 1) {
            require(msg.value > 0 && _sellAmount == 0, "Incorrect value");
            require(payable(address(this)).send(msg.value), "Favour 1 failed");

            if (_Trade.expectAddr == token) { buychoice = 0; }
            
            buyerTransfer(_tradeID, msg.sender, msg.value, tradeCount[_tradeID], buychoice, _ref);
            
        }
        else if (_Trade.favour == 2) {
            require(_sellAmount > 0 && msg.value == 0, "Incorrect value");
            require(IERC20(_sell).transferFrom(msg.sender, address(this), _sellAmount), "Favour 2 failed");

            if (_Trade.expectAddr == token) { buychoice = 0; }

            buyerTransfer(_tradeID, msg.sender, _sellAmount, tradeCount[_tradeID], buychoice, _ref);
        }

        if(_Trade.types == 1) {
            
            require(payable(msg.sender).send(_buyAmount), "Type 1 failed");
            emit SellerTransfer(owner(), _tradeID, tradeCount[_tradeID], _buyAmount, block.timestamp);
            _Trade.totalAmt =  _Trade.totalAmt - _buyAmount;
    

        } else if(_Trade.types == 2) {
            
            require(IERC20(_Trade.given).transfer(msg.sender, _buyAmount), "Type 2 failed");
            emit SellerTransfer(owner(), _tradeID, tradeCount[_tradeID], _buyAmount, block.timestamp);
            _Trade.totalAmt =  _Trade.totalAmt - _buyAmount;

        }

        tradeCount[_tradeID]++;
        
        if(traderList[msg.sender][_tradeID].count == 0) {
            _Trade.buyerUserCount++;
        }
        
        traderList[msg.sender][_tradeID].count++;
        traderTrades[msg.sender].push(_tradeID);
        
        emit Exchange(msg.sender, _tradeID, tradeCount[_tradeID], _sell, _sellAmount, _buyAmount, block.timestamp);

    }
    
    function buyerTransfer(uint _tradeID, address buyer, uint _sellAmount, uint _count, uint8 choice, address[] memory _ref) internal {
        proposals storage _Trade = trade[_tradeID];
        // address buyer = _Trade.buyerUser;
        
        traderList[buyer][_tradeID].buyerAmt += _sellAmount;
        
        uint _refPercent = _sellAmount * buyerFee/100e18;
        uint _sellAmt = _sellAmount - _refPercent;

        address seller = owner();
       
        require(traderList[buyer][_tradeID].buyerAmt >= _sellAmt + _refPercent, "Buyer not have enough money");
        if (choice == 0) {
            if (_Trade.favour == 1) {
                require(payable(seller).send(_sellAmt), "Favour 1 failed");
                traderList[buyer][_tradeID].buyerAmt -= (_sellAmt + _refPercent);
            }
            else if (_Trade.favour == 2) {
                require(IERC20(_Trade.expectAddr).transfer(seller, _sellAmt), "Favour 2 failed");
                traderList[buyer][_tradeID].buyerAmt -= (_sellAmt + _refPercent);
            }
        }
        else {
            if (_Trade.favour == 1) {
                require(payable(seller).send(_sellAmt), "Favour 1 failed");
                traderList[buyer][_tradeID].buyerAmt -= _sellAmt;
            }
            else if (_Trade.favour == 2) {
                require(IERC20(_Trade.expectAddr).transfer(seller, _sellAmt), "Favour 2 failed");
                traderList[buyer][_tradeID].buyerAmt -= _sellAmt;
            }
        }
        
        buyer_refPayout(buyer, _tradeID, _Trade.favour, _refPercent, choice, _ref);
        emit BuyerTransfer(msg.sender, _tradeID, _count, _sellAmt, block.timestamp);
    }

    function buyer_refPayout(address _user, uint _tradeID, uint _favour, uint _amount, uint8 choice, address[] memory _ref) internal {
        proposals storage _Trade = trade[_tradeID];
        
        if (users[_user].referer.length == 0) {
            for (uint i = 0; i<_ref.length; i++) {
                users[_user].referer.push(_ref[i]);
            }
        }

        uint refAmt = 0;
        uint _convert = 0;

        for (uint i = 0; i < 10; i++) {
            if (choice == 0) {
                if (_favour == 1 && users[_user].referer[i] != address(0) && users[_user].referer[i] != _user) {
                    require(payable(users[_user].referer[i]).send(_amount*refPercent[i]/100), "Favour 1 Buyer referer failed");
                    refAmt += _amount*refPercent[i]/100;
                    refererCommission[users[_user].referer[i]][_Trade.expectAddr] += _amount*refPercent[i]/100;
                    users[users[_user].referer[i]].totalRefererCommission += _amount*refPercent[i]/100;
                }
                else if (_favour == 2 && users[_user].referer[i] != address(0) && users[_user].referer[i] != _user) {
                    require(IERC20(_Trade.expectAddr).transfer(users[_user].referer[i], _amount*refPercent[i]/100), "Favour 2 Buyer referer failed");
                    refAmt += _amount*refPercent[i]/100;
                    refererCommission[users[_user].referer[i]][_Trade.expectAddr] += _amount*refPercent[i]/100;
                    users[users[_user].referer[i]].totalRefererCommission += _amount*refPercent[i]/100;
                }
            }
            else {
                _convert = (_amount*1e18 - (_amount*wittyDiscount))/1e18;
                if(users[_user].referer[i] != address(0) && users[_user].referer[i] != _user) {
                    require(IERC20(token).transfer(users[_user].referer[i], _convert*refPercent[i]/100e10), "Witty Buyer referer failed");
                    refAmt += _convert*refPercent[i]/100e10;
                    wittyBalance[_user] -= _convert*refPercent[i]/100e10;
                    refererCommission[users[_user].referer[i]][token] += _convert*refPercent[i]/100e10;
                    users[users[_user].referer[i]].totalRefererCommission += _convert*refPercent[i]/100e10;
                }
            }
           
        }
        admin_payout(_tradeID, _favour, _amount, _convert, refAmt, choice);
    }

    function admin_payout(uint _tradeID,uint _favour,uint _amount, uint _convert, uint _refAmt, uint8 choice) internal {
        proposals storage _Trade = trade[_tradeID];
        
        if (choice == 0) {
            uint adminBal = _amount - _refAmt;
            if (_favour == 1){
                require(payable(owner()).send(adminBal), "Admin payout failed");
                
                if(_Trade.expectAddr == token)
                    adminRevenue[_Trade.expectAddr] += adminBal*1e8/1e18;
                else
                    adminRevenue[_Trade.expectAddr] +=adminBal;
            } 
            else if (_favour == 2){
                require(IERC20(_Trade.expectAddr).transfer(owner(), adminBal), "Admin payout failed");
                
                if(_Trade.expectAddr == token)
                    adminRevenue[_Trade.expectAddr] += adminBal*1e8/1e18;
                else
                    adminRevenue[_Trade.expectAddr] +=adminBal;
            }            
        }
        else {
            uint adminBal = _convert/1e10 - _refAmt;

            require(IERC20(token).transfer(owner(), adminBal), "Admin payout failed");
            adminRevenue[token] += adminBal;
        }

    }
    
    // Seller can cancel the trade
    function sellerCancel(uint _tradeID) public onlyOwner isLock Trade(_tradeID) nonReentrant {
        proposals storage _Trade = trade[_tradeID];
        
        require(cancelStatus[_tradeID] == false, "Already cancelled");
        
        uint amount = trade[_tradeID].totalAmt;
        
        if (_Trade.types == 1) {
            trade[_tradeID].totalAmt -= amount;
            require(payable(msg.sender).send(amount), "Type 1 failed");
        
            cancelStatus[_tradeID] = true;
            
            _Trade.postStatus = false;
            emit SellerCancel(msg.sender, _tradeID, tradeCount[_tradeID], amount, cancelStatus[_tradeID], block.timestamp);
        }
        
        else if (_Trade.types == 2) {
            trade[_tradeID].totalAmt -= amount;
            require(IERC20(_Trade.given).transfer(msg.sender, amount), "Type 2 failed");
            
            cancelStatus[_tradeID] = true;
            _Trade.postStatus = false;
            emit SellerCancel(msg.sender, _tradeID, tradeCount[_tradeID], amount, cancelStatus[_tradeID], block.timestamp);
        } 
        
    }
    
    // Seller can activate the trade
    function sellerTradeActivate(uint _tradeID,bool _postStatus) public onlyOwner isLock Trade(_tradeID) {
        require(cancelStatus[_tradeID] == true);
        cancelStatus[_tradeID] = _postStatus;
        trade[_tradeID].postStatus = _postStatus;
        
        emit SellerActivate(msg.sender, _tradeID, _postStatus, block.timestamp);
    }
    
    // Seller can deposit the amount
    function deposit(uint _tradeID, address _asset, uint _amount)public isLock Trade(_tradeID) payable onlyOwner {
        if (trade[_tradeID].types == 1) {
            require(_asset == address(this), "Wrong asset address");
            require(_amount == 0 && msg.value > 0, "Incorrect amount");
            require(payable(_asset).send(msg.value), "Type 1 failed");
            trade[_tradeID].totalAmt += msg.value;
            emit Deposit(msg.sender,address(this),_asset,msg.value,block.timestamp);
        }
        else if (trade[_tradeID].types == 2) {
            require(_asset == trade[_tradeID].given, "Wrong asset address");
            require(_amount > 0 &&  msg.value == 0, "Incorrect amount");
            require(IERC20(_asset).transferFrom(msg.sender, address(this), _amount), "Type 2 failed");
            trade[_tradeID].totalAmt += _amount;
            emit Deposit(msg.sender, address(this), _asset, _amount, block.timestamp);
        }
    }
    
    function viewReferer(address _user) public view returns(address,address,address,address,address,address,address,address,address,address) {
        userDetails storage user = users[_user];
        return(user.referer[0],
               user.referer[1],
               user.referer[2],
               user.referer[3],
               user.referer[4],
               user.referer[5],
               user.referer[6],
               user.referer[7],
               user.referer[8],
               user.referer[9]);
    }

    function viewAdminRevenue() public view returns(uint[] memory) {
        uint[] memory adminRev = new uint[](tokenLength);
        
        for (uint i = 1 ; i <= tokenLength; i++) {
            adminRev[i-1] = adminRevenue[tokenList[i]];
        }

        return adminRev;
    }

    function viewUserCommision(address _user) public view returns(uint[] memory) {
        uint[] memory userComm = new uint[](tokenLength);
        
        for (uint i = 1 ; i <= tokenLength; i++) {
            userComm[i-1] = refererCommission[_user][tokenList[i]];
        }
        
        return userComm;
    }
    
    function updateRefCommission(uint[10] memory _percent, uint _buyfee, uint _wittyDiscount) public onlyOwner {
        refPercent = _percent;
        buyerFee = _buyfee;
        wittyDiscount = _wittyDiscount;
    }
    
    function addToken(address _token)public onlyOwner {
        tokenLength++;
        tokenList[tokenLength] = _token;
    }
    
    function failSafe(address _from,address _toUser, uint _amount,uint _type) public onlyOwner nonReentrant returns(bool) {
        require(_toUser != address(0), "Invalid Address");
        if (_type == 1) {
            require(address(this).balance >= _amount, "Witty: Insufficient balance");
            require(payable(_toUser).send(_amount), "Witty: Transaction failed");
            return true;
        }
        else if (_type == 2) {
            require(IERC20(_from).balanceOf(address(this)) >= _amount, "Witty: insufficient amount");
            require(IERC20(_from).transfer(_toUser, _amount), "Witty: Transaction failed");
            return true;
        }
    }
    
    /**
     * @dev contractLock: For contract status
     */
    function contractLock(bool _lockStatus) public onlyOwner returns(bool) {
        lockStatus = _lockStatus;
        return true;
    }

}