/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

// File: BUy Competition 20221130/HamBuyC.sol


pragma solidity ^0.8.4;





interface IPancakeRouter02 {
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function WETH() external pure returns (address);
}

contract Contest is Ownable,Pausable{
   
   uint32 public constant MAX_DELAY = 3600*72;
   // Pancake Router Currently for testnet
    IPancakeRouter02 swaper;
    // Token Address
    bool private isDistributed = false;
    address TOKEN_CONTRACT_ADDRESS = 0x679D5b2d94f454c950d683D159b87aa8eae37C9e;
    // Pancake Router Address
    address PANCAKE_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // Fee in BNB or Mainchain 
    uint256 BNB_FEE = 1 * 1e17; // means 0.1BNB // Must call with fuction with a value
    
    address[] private winnerList;
    address[] private participantList;


    struct UserInfo{
        uint256 tokenBalance;
        uint32 buyingTime;
        bool isValid;
    }

    mapping (address => UserInfo) private participant;

    constructor()   {
        swaper = IPancakeRouter02(PANCAKE_ROUTER_ADDRESS);
        _pause();
    }
    function changeOwner(address  newOwner) public onlyOwner{
       _transferOwnership(newOwner);
    }
    function GetContractBalance() public onlyOwner view returns (uint256){
        return IERC20(TOKEN_CONTRACT_ADDRESS).balanceOf(address(this));
    }
    function TransferAllTokens() external onlyOwner{
        IERC20(TOKEN_CONTRACT_ADDRESS).transfer(msg.sender,IERC20(TOKEN_CONTRACT_ADDRESS).balanceOf(address(this)));
    }
    function StartContest() external onlyOwner{
        _unpause();
    }
    function isUserParticipant() public view returns(bool) {
        return participant[msg.sender].isValid;
    }
    function SwapExactBNBForTokens(
        uint amountOut,uint time
    ) external payable whenNotPaused returns(uint256) {
        require(msg.sender != owner() , "Owner cant participate in contest");
        require (participant[msg.sender].isValid == false , "You already participated in pool");
        address[] memory path = new address[](2);
        path[0] = swaper.WETH();
        path[1] = TOKEN_CONTRACT_ADDRESS;
        require(msg.value == BNB_FEE,"Amount should be equal to 0.1 BNB");
        uint[] memory amounts = swaper.swapExactETHForTokens{value: msg.value}(
            amountOut,
            path,
            address(this),
           time
        );
        uint256 outputTokenCount = uint256(amounts[1]);
        participant[msg.sender].isValid = true;
        participant[msg.sender].buyingTime = uint32(block.timestamp);
        participant[msg.sender].tokenBalance = outputTokenCount;
        participantList.push(msg.sender);
        return outputTokenCount;
    }

    function GetAllParticipantsAddresses() public view onlyOwner returns( address[] memory){
        return participantList;
    }
    function SelectWinners(address[] memory winners ) public onlyOwner {
        require(winners.length == 3,"There must be 3 Winners");
        require(isDistributed == false , "Reward already distributed");
        for(uint i=0;i<winners.length;i++){
            require(participant[winners[i]].isValid == true , "Selected Winner is Not a Participant");
        }
        winnerList = winners;
    }
    function GetWinners() public view returns (address[] memory){
        return winnerList;
    }
    function StopContest() public onlyOwner{
       _pause();
    }
    function DistributeReward() public payable onlyOwner{
        require(winnerList.length == 3 , "Winners Not Selected");
        require(isDistributed == false , "Reward Already Distributed");
        for(uint i=0;i<3;i++){
            payable(winnerList[i]).transfer(msg.value/3);
        }
        isDistributed = true;
    }
    function ClaimTokens() public{
        require(participant[msg.sender].isValid == true,"You are not participant");
        require(participant[msg.sender].tokenBalance > 0 , "You dont have anything to claim!");
        require(uint32(block.timestamp) >= participant[msg.sender].buyingTime + MAX_DELAY , "You cant Claim Tokens before 48 Hours");
        IERC20(TOKEN_CONTRACT_ADDRESS).transfer(msg.sender,participant[msg.sender].tokenBalance);
        participant[msg.sender].tokenBalance = 0;
    } 
    function GetTimeLeft() public view returns (uint32){
        if( (participant[msg.sender].buyingTime + MAX_DELAY) > uint32(block.timestamp)){
            return (participant[msg.sender].buyingTime + MAX_DELAY) - uint32(block.timestamp);
        }else{
            return 0;
        }
        
    }
    function IsRewardDistributed() public view returns (bool){
        return isDistributed;
    }
    function canClaim() public view returns (bool){
        if(participant[msg.sender].isValid){
            if(uint32(block.timestamp) >= participant[msg.sender].buyingTime + MAX_DELAY){
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
    function CheckMyBalance() public view returns (uint256) {
        return participant[msg.sender].tokenBalance;
    }
    function isOwner() public view returns(bool){
        return msg.sender == owner();
    }
}