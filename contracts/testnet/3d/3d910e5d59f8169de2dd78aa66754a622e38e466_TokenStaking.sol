/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
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

// File: contracts/token_staking.sol


pragma solidity ^0.8.2;




contract TokenStaking is ERC721Holder, Ownable {
    IERC20 public token;
    mapping(address => uint256) public lockedBalance;
    mapping(address => uint256) public flexibleBalance;
    mapping(address => uint256) public lockedStakedAt;
    mapping(address => uint256) public flexibleStakedAt;

    mapping(address => bool) public enabled;

    // uint256 public stakingTime = 31556952;
    uint256 public stakingTime = 300;
    uint256 public rewardPercent = 5;
    uint256 public bnbFee = 0.021 ether;
    // uint256 public tokenFee = 50* 10**9;
    // uint256 public minimumLimit = 100* 10**9;
    uint256 public burnFeePrcnt = 30;
    uint256 tokenFee = 50* 10**18;
    uint256 minimumLimit = 100* 10**18;
    uint256 public unstakeFeePrcnt = 5;
    address public masterWallet = 0xD4CE088799056513e12F4FD3C6402dbCD2D1f2e7;
    uint256 public totalReward;
    uint256 public flexibleRewardPrcnt = 5;
    constructor(address _token_address) {
        token = IERC20(_token_address);
    }

    function stake(uint256 _amount, uint stake_type) external {
        require(stake_type<2, "invalid type");
        require(_amount>0,"amount should be more than zero");
        require(enabled[msg.sender], "pool is not enabled");
        require(_amount>=minimumLimit,"stake more than limit");
        uint256 burnFee = (_amount*burnFeePrcnt)/100;
        uint256 remaining = _amount-burnFee;
        token.transferFrom(msg.sender, masterWallet, burnFee);
        token.transferFrom(msg.sender, address(this), remaining);
        if(stake_type==0){
            lockedStakedAt[msg.sender] =  block.timestamp;
            lockedBalance[msg.sender] += remaining;
        }else{
            flexibleStakedAt[msg.sender] =  block.timestamp;
            flexibleBalance[msg.sender]+=remaining;
        }
    }

    function calculateTotal(address _staker) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - lockedStakedAt[_staker];
        uint256 months = timeElapsed/2629746;
        uint256 totalMonths = stakingTime/2629746;
        // uint256 months = timeElapsed/60;
        // uint256 totalMonths = stakingTime/60;
        if(months>totalMonths){
            months=totalMonths;
        }
        uint Principle = lockedBalance[_staker];
        for (uint i=0;i<months;i++) {
          Principle += Principle* rewardPercent/100;
        }
        return Principle;
    }
    
    function unstakeLocked() external {
        require(block.timestamp>lockedStakedAt[msg.sender]+stakingTime,"you cannot unstake before time");
        require(lockedBalance[msg.sender] > 0, "your staked balance is zero");
        uint256 total = calculateTotal(msg.sender);
        uint256 unstakeFee = (total*unstakeFeePrcnt)/100;
        uint256 remaining = total-unstakeFee;
        token.transfer(masterWallet, unstakeFee);
        token.transfer(msg.sender, remaining);
        lockedBalance[msg.sender]=0;
    }

    function unstakeFlexible() external {
        require(block.timestamp>flexibleStakedAt[msg.sender]+stakingTime,"you cannot unstake before time");
        require(flexibleBalance[msg.sender] > 0, "your staked balance is zero");
        uint256 total = flexibleBalance[msg.sender];
        uint256 unstakeFee = (total*unstakeFeePrcnt)/100;
        uint256 remaining = total-unstakeFee;
        token.transfer(masterWallet, unstakeFee);
        token.transfer(msg.sender, remaining);
        flexibleBalance[msg.sender]=0;
    }
    
    function getFlexibleReward() external {
        // require()
        require(flexibleBalance[msg.sender] > 0, "your staked balance is zero");
        uint256 reward = calculateFlexibleReward(msg.sender);
        token.transfer(msg.sender, reward);
    }

    function calculateFlexibleReward(address _staker) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - flexibleStakedAt[_staker];
        uint256 months = timeElapsed/2629746;
        uint256 totalMonths = stakingTime/2629746;
        // uint256 months = timeElapsed/60;
        // uint256 totalMonths = stakingTime/60;
        if(months>totalMonths){
            months=totalMonths;
        }
        uint reward = ((flexibleBalance[msg.sender]*flexibleRewardPrcnt)/100)*months;
        return reward;
    }

    function setStakingTime(uint256 _time) external onlyOwner {
        stakingTime = _time;
    }

    function setRewardPercent(uint256 _percent) external onlyOwner {
        rewardPercent = _percent;
    }

    function setMasterWallet(address master) external onlyOwner {
        masterWallet = master;
    }

    function setMinLimit(uint _limit) external onlyOwner {
        minimumLimit = _limit;
    }

    function getMinLimit() public view returns(uint256) {
        return minimumLimit;
    }

    function enable() external payable {
        require(msg.value==bnbFee,"pay bnb fee");
        token.transferFrom(msg.sender, masterWallet, tokenFee);
        enabled[msg.sender] = true;
    }

    function disable() external onlyOwner {
        enabled[msg.sender] = false;
    }

    function bnbFeeWithdraw() payable public onlyOwner{
        uint amount = address(this).balance;
        require(amount>0, "balance is 0 in contract");
        payable(address(owner())).transfer(amount);
    }

     function tokenFeeWithdraw(uint _amount) public onlyOwner{
        token.transfer(masterWallet, _amount);
    }

    function getTokenFee()public view returns(uint){
        return tokenFee;
    }

    function getBnbFee()public view returns(uint){
        return bnbFee;
    }

    function getUnstakeFee()public view returns(uint){
        return unstakeFeePrcnt;
    }

    function setBnbFee(uint _fee) external onlyOwner {
        bnbFee = _fee;
    }

    function setTokenFee(uint _fee) external onlyOwner {
        tokenFee = _fee;
    }

    function setUnstakeFee(uint prcnt) external onlyOwner {
        unstakeFeePrcnt = prcnt;
    }

    function setFlexibleRewardPrcnt(uint prcnt) external onlyOwner {
        flexibleRewardPrcnt = prcnt;
    }

    function getFlexibleRewardPrcn() public view returns(uint) {
        return flexibleRewardPrcnt;
    }

    function setBurnFee(uint prcnt) external onlyOwner {
        burnFeePrcnt = prcnt;
    }

    function getBurnFee() public view returns(uint) {
        return burnFeePrcnt;
    }

    function isEnabled() public view returns(bool){
        return enabled[msg.sender];
    }

    function getLockedBalance(address _staker)public view returns(uint){
        return lockedBalance[_staker];
    }

    function addReward(uint256 _amount) external {
        token.transferFrom(msg.sender, address(this), _amount);
        totalReward += _amount;
    }
}