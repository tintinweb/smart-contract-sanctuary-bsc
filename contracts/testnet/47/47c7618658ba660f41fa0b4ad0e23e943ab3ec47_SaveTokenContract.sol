/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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

// File: contracts/Saving.sol

pragma solidity >=0.7.0 <0.9.0;






contract SaveTokenContract is ReentrancyGuard{

    using Counters for Counters.Counter;
    Counters.Counter private _saveIds;

    mapping(uint256 => SaveInfo) savings;

    IERC20 Token; // mã tiền
    
    uint256 vault; // tổng tiền trong kho

    address operator; // address điều hành

    uint32 deltaTime = 86400; //24 * 60 * 60  (seconds one day)

    enum SavingType { // loại đầu tư
        MONTHS, // 10 %
        QUARTERS, // 15 %
        YEARS // 20 %
    }

    struct SaveInfo {
        uint256 saveId; // id sổ gửi
        address payable owner; // chủ sở hữu
        uint256 balance; // số tiền trong ví
        SavingType savingType; // loại đầu tư
        uint256 createdAt; // thời gian tạo ví
        uint256 fluctuation_times; // thời gian tạo ví
    }

    modifier onlyOwner {
        require(msg.sender == operator);
        _;
    }

    event WithsendTokenEvent(address _fromAddress, SavingType _savingType, uint256 _amount);

    event WithdrawTokenEvent(address _toAddress, uint256 _amount);

    constructor(address _tokenAddress, address _operator) {
        operator  = _operator;
        Token = IERC20(_tokenAddress);
    }

    // tạo ví đầu tư
    function createSaving( SavingType _savingType) public payable returns (uint256) {

        require(msg.value > 0, "Amount must be greater than 0 ");

        _saveIds.increment();
        uint256 _saveId = _saveIds.current();

        Token.transferFrom(msg.sender, address(this), msg.value);
        vault += msg.value;

        savings[_saveId] = SaveInfo(
            _saveId,
            payable(msg.sender),
            msg.value,
            _savingType,
            block.timestamp,
            block.timestamp
        );

        emit WithsendTokenEvent(msg.sender, _savingType, msg.value);
        return _saveId;
    }


    function withDrawSaving(uint256 _saveId) public payable nonReentrant {

        require(savings[_saveId].owner == msg.sender, "Permission denied! ");
        require(msg.value > 0, "Amount must be greater than 0!");
        require(savings[_saveId].balance > 0, "Balance must be greater than 0!");
        uint256 balance = getBalance(_saveId);
        
        require(msg.value > balance, "The balance in the account is not enough!");

        Token.transferFrom(address(this), msg.sender, msg.value);

        vault -= msg.value;

        uint256 interestTime = getInterestTime(_saveId);

        balance -= msg.value;
        savings[_saveId].balance = balance;
        savings[_saveId].fluctuation_times += interestTime;

        emit WithdrawTokenEvent(msg.sender, msg.value);
    }


    function getBalance(uint256 _saveId) public view returns (uint256) {

        uint256 balance = savings[_saveId].balance;
        uint256 totalTime = block.timestamp - savings[_saveId].fluctuation_times;
        SavingType savingType = savings[_saveId].savingType;
        uint16 d = uint16 (totalTime / deltaTime) + 1;
        
        if(savingType == SavingType.MONTHS){
            if(d < 30){
                return balance;
            }
            if(d > 30){
                uint16 v = uint16 (d / 30);
                balance = balance + (balance / 100 * 10 * v);
                return balance;
            }
        }

        if(savingType == SavingType.QUARTERS){
            if(d < 120){
                return balance;
            }
            if(d > 120){
                uint16 v = uint16 (d / 120);
                balance = balance + (balance / 100 * 15 * v);
                return balance;
            }
        }

         if(savingType == SavingType.YEARS){
            if(d < 365){
                return balance;
            }
            if(d > 365){
                uint16 v = uint16 (d / 365);
                balance = balance + (balance / 100 * 20 * v);
                return balance;
            }
        }
        return balance;
    }


    function getInterestTime(uint256 _saveId) public view returns (uint256) {

        uint256 interestTime = 0;
        uint256 totalTime = block.timestamp - savings[_saveId].fluctuation_times;
        SavingType savingType = savings[_saveId].savingType;
        uint16 d = uint16 (totalTime / deltaTime) + 1;
        
        if(savingType == SavingType.MONTHS){
            if(d < 30){
                return interestTime;
            }
            if(d > 30){
                uint16 v = uint16 (d / 30);
                interestTime = interestTime * v;
                return interestTime;
            }
        }

        if(savingType == SavingType.QUARTERS){
            if(d < 120){
                return interestTime;
            }
            if(d > 120){
                uint16 v = uint16 (d / 120);
                interestTime = interestTime * v;
                return interestTime;
            }
        }

         if(savingType == SavingType.YEARS){
            if(d < 365){
                return interestTime;
            }
            if(d > 365){
                uint16 v = uint16 (d / 365);
                interestTime = interestTime * v;
                return interestTime;
            }
        }
        return interestTime;
    }

    function getVault() public view returns (uint256) {
        return vault;
    }

    function topUP() public payable onlyOwner {
        Token.transferFrom(msg.sender, address(this), msg.value);
        
    }

    function withDraw() public payable onlyOwner {
        Token.transferFrom(address(this), msg.sender, msg.value);
        
    }
}