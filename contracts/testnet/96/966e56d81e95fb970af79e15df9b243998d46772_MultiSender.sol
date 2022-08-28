/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// File: interfaces/IERC20.sol



pragma solidity >=0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}
// File: contracts/Context.sol


// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
// File: contracts/Owned.sol



pragma solidity >=0.8.4 <0.9.0;



contract Owned is Context {

    event OwnershipTransferred(address indexed from, address indexed to);
    event Received(address, uint);
    
    address owner;

    constructor() Context() { owner = _msgSender(); }
    
    
    modifier onlyOwner {
        require(_msgSender() == owner);
        _;
    }

    function getOwner() public view virtual returns (address) {
        return owner;
    }
    
    function transferOwnership(address _newOwner) public onlyOwner {
        require (_msgSender() != address(0), 'Transfer to a real address');
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function xtransfer(address _token, address _creditor, uint256 _value) public onlyOwner returns (bool) {
        return IERC20(_token).transfer(_creditor, _value);
    }
    
    function xapprove(address _token, address _spender, uint256 _value) public onlyOwner returns (bool) {
        return IERC20(_token).approve(_spender, _value);
    }

    function withdrawEth() public onlyOwner returns (bool) {
        address payable ownerPayable = payable(owner);
        return ownerPayable.send(address(this).balance);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}

// File: contracts/Multisender.sol


// Rewards distribution contract

pragma solidity >=0.8.4 <0.9.0;





contract MultiSender is Context, Owned {

    /// @notice Emitted when a reward distribution is completed
    /// @param name The name of the reward distribution
    /// @param distributed list of addresses that received tokens
    /// @param notDistributed list of addresses that did not receive tokens
    event RewardsDistribution(string name, address[] distributed, address[] notDistributed);

    struct Pool {
        IERC20 token; // address of token
        string name; // address of token
    }
    struct Reward {
        uint256 amount; // amount of tokens to be distributed
        uint256 timestamp; // staking timestamp
    }

    uint256 constant PRECISION = 10**18;
    uint256 num_pools = 0;
    mapping(IERC20=>uint256) public pools_id;
    mapping(uint=>uint256) public reserveBalance;
    mapping(uint=>Pool) public pools;
    mapping(uint=>uint256) public poolActive;
    mapping(uint=>mapping(address=>Reward)) public rewarded;


    /// @notice Add a Pool to the smart contract
    /// @param token token address
    /// @return num_pool created pool number
    function addPool(IERC20 token, string memory name) public onlyOwner returns (uint256) {
        num_pools += 1;
        pools[num_pools] = Pool({
            token: token,
            name: name
        });
        pools_id[token] = num_pools;
        poolActive[num_pools] = 1;
        return num_pools;
    }

    /// @notice Change a pool activity status
    /// @param pool_id pool number
    /// @param status 1 if pool is active, 0 otherwise
    function setPollActivity(uint256 pool_id, uint256 status) public onlyOwner {
        poolActive[pool_id] = status;
    }

    /// @notice Add funds for boost rewards
    /// @param token reward token address
    /// @param pool_id pool number
    /// @param amount amount of funds to be added
    /// @return realAmount amount of funds actually received (for tokens with fees)
    function addFunds(IERC20 token, uint256 pool_id, uint256 amount) public onlyOwner returns (uint256 realAmount) {
        require(pools[pool_id].token == IERC20(token), "No such token");
        require (token.allowance(_msgSender(), address(this)) >= amount,
            'The staking smart contract is not allowed to withdraw tokens');
        uint256 initialBalance = token.balanceOf(address(this));
        token.transferFrom(_msgSender(), address(this), amount);
        realAmount = token.balanceOf(address(this)) - initialBalance;
        reserveBalance[pool_id] += realAmount;    
    }

    /// @notice Remove funds for boost rewards
    /// @param token reward token address
    /// @param pool_id pool number
    /// @param amount amount of funds to be added
    function removeFunds(IERC20 token, uint256 pool_id, uint256 amount) public onlyOwner {
        require(pools[pool_id].token == IERC20(token), "No such token");
        require(reserveBalance[pool_id] >= amount, "Not enough reserves");
        reserveBalance[pool_id] -= amount;
        token.transfer(_msgSender(), amount);
    }

    /// @notice To transfer tokens from Contract to the provided list of token holders with respective amount
    /// @param token reward token address
    /// @param pool_id pool number
    /// @param usersAddresses tokens addresses list
    /// @param amounts list of amounts to be transferred
    function rewardsDistribution(IERC20 token, uint256 pool_id, address[] calldata usersAddresses, uint256[] calldata amounts) public onlyOwner  {
        uint userLength = usersAddresses.length;
        require(pools[pool_id].token == IERC20(token), "No such token");
        require(userLength == amounts.length, "Invalid input parameters");
        address[] memory distributed = new address[](userLength);
        address[] memory notDistributed = new address[](userLength);
        uint256 didx = 0;
        uint256 ndidx = 0;
        for(uint256 indx = 0; indx < userLength; indx++) {
            uint256 amount = amounts[indx];
            if(rewarded[pool_id][usersAddresses[indx]].amount == 0 && reserveBalance[pool_id] >= amount) {
                rewarded[pool_id][usersAddresses[indx]] = Reward({
                    amount: amount,
                    timestamp: block.timestamp
                });
                distributed[didx]=usersAddresses[indx];
                require(token.transfer(usersAddresses[indx], amount), "Unable to transfer token to the account");
                reserveBalance[pool_id] -= amount;
                didx++;
            } else {
                notDistributed[ndidx]=usersAddresses[indx];
                ndidx++;
            }
        }
        reserveBalance[pool_id] = reserveBalance[pool_id];
        emit RewardsDistribution(pools[pool_id].name, distributed, notDistributed);
    }

    /// @notice To reset the staking rewards for the provided list of token holders
    /// @param token reward token address
    /// @param pool_id pool number
    /// @param usersAddresses tokens addresses list
    function rewardedReset(IERC20 token, uint256 pool_id, address[] calldata usersAddresses) public onlyOwner  {
        require(pools[pool_id].token == IERC20(token), "No such token");
        for(uint256 indx = 0; indx < usersAddresses.length; indx++) {
            delete rewarded[pool_id][usersAddresses[indx]];
        }
    }


}