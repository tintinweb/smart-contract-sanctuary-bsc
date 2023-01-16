/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

// File: Twitter.sol


pragma solidity ^0.8.11;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.8.11;
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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.11;

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

pragma solidity ^0.8.11;

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
        uint32 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint32) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint32 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

pragma solidity ^0.8.11;

contract Twitter is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;

    address private adminAddress;
    uint256 private _PRICE = 0.0008 ether; //800000000000000
    Counters.Counter private currentLotteryId;

    enum Status {
        Close,
        Open
    }

    struct Lottery {
        Status status;
    }

    mapping(uint32 => Lottery) private _lotteries;

	mapping(uint32 => uint256) private _number;

    mapping(address => mapping(uint32 => bool)) private _addresPartipant;

    mapping(uint32 => address[]) private _gamblers;

    mapping(uint32 => address) private _winner;

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Not Admin");
        _;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    event Participate(address indexed participant, uint32 indexed LotteryId, uint256 time);

    event Winner(address indexed participant, uint32 indexed LotteryId, uint256 time);

    constructor(address _adminAddress) {
        adminAddress = _adminAddress;
    }

    receive() external payable {}

    fallback() external payable {}

    function participate() external payable notContract nonReentrant { 
        uint32 _lotteryId = currentLotteryId.current();
        address _sender = msg.sender;
        uint256 _value = msg.value;
		require(_lotteries[_lotteryId].status == Status.Open, "Lottery not open");
        require(_sender != address(0), "Address 0");
        require(_addresPartipant[_sender][_lotteryId] == false, "You are already participating");
        require(_value >= _PRICE, "Value < Price");

            // Mark as participating
            _addresPartipant[_sender][_lotteryId] = true;

            _gamblers[_lotteryId].push(_sender);     
    
            emit Participate(_sender, _lotteryId, block.timestamp);

    }

    function closeLottery() external onlyAdmin nonReentrant {
        uint32 _lotteryId = currentLotteryId.current();
        uint256 _gamers = _gamblers[_lotteryId].length;
        require(_lotteries[_lotteryId].status == Status.Open, "Lottery not open");

        _lotteries[_lotteryId].status = Status.Close;

        uint256 ran = _arrayRandom(_gamers);

		_number[_lotteryId] = ran;

        _winner[_lotteryId] = (_gamblers[_lotteryId][ran]);

        emit Winner(_winner[_lotteryId], _lotteryId, block.timestamp);
    }

    function startLottery() external onlyAdmin nonReentrant {
        require(_lotteries[currentLotteryId.current()].status == Status.Close, "Lottery is not close");

        currentLotteryId.increment();
        uint32 _lotteryId = currentLotteryId.current();

        _lotteries[_lotteryId] = Lottery({
        status: Status.Open
        });          

    }

    function balanceBNB() external view onlyAdmin returns (uint256) {

        return address(this).balance;
    }

    function recoverBNB() external payable onlyAdmin returns (bool success) {

        ( success, ) = payable(msg.sender).call{value: address(this).balance}("");
        if(success) return success;
    }

    function _isContract(address account) internal view returns (bool) {
        return account.code.length > 0;    
    }

    function _arrayRandom(uint256 _length) private view returns (uint256) {

        address _coin = block.coinbase;
        uint256 _time = block.timestamp;
        uint256 _diff = block.difficulty;

        uint256 winner = (uint256(keccak256(abi.encode(_coin, _time, _diff))) % _length);

        return winner;        

    }

    function win(uint32 _id) external view returns (address) {

        return _winner[_id];

    }

	function gambler(uint32 _lotteryId, uint256 _ran) external view returns (address) {
        
        return _gamblers[_lotteryId][_ran];
    }

	function numberWin(uint32 _lotteryId) external view returns (uint32) {
        
        return uint32(_number[_lotteryId]);
    }

    function numberGamblers() external view returns (uint32) {
        
        return uint32(_gamblers[currentLotteryId.current()].length);
    }

    function price() external view returns (uint256) {
        
        return _PRICE;
    }

    function changePrice(uint256 _value) external onlyAdmin {

        _PRICE = _value;

    }

    function viewAdmin() external view onlyAdmin returns (address) {
        return adminAddress;
    }

    function setAdmin(address _adminAddress) external onlyAdmin {
        require(_adminAddress != address(0), "Cannot be zero address");

        adminAddress = _adminAddress;
    }

    function viewCurrentLotteryId() external view returns(uint32) {
        return currentLotteryId.current();
    }

    function isLotteryOpen() external view returns (bool) {
        
        if(_lotteries[currentLotteryId.current()].status == Status.Open) {
            return true;
        }
        return false;
    }

    function participating() external view returns (bool) {

        if(_addresPartipant[msg.sender][currentLotteryId.current()] == true) {
            return true;
        }
        return false;        
    }

}