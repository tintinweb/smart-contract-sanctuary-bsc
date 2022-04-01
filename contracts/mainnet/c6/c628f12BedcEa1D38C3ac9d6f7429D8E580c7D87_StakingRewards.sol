/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

pragma solidity ^0.8.0;

pragma solidity ^0.8.0;



/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/

contract Ownable {
    address private _owner;
    
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    
    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    
    /**
    * @return the address of the owner.
    */
    function owner() public view returns(address) {
        return _owner;
    }
    
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    
    /**
    * @return true if `msg.sender` is the owner of the contract.
    */
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }
    
    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    
    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

contract StakingRewards is Ownable{
    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    uint256 public const_rewardRate = 34843; // per block when decimal is 18 (meaning to stake one for per day)
    uint256 public rewardRate;
    uint256 public stake_rate;
    uint256 public AVT_PRP_rate;
    uint256 private multipler = 10 ** 9;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastBlockNumber;

    uint256 public _totalSupply;
    mapping(address => uint256) public _balances;

    constructor(address _stakingToken, address _rewardsToken, uint256 _stake_rate, uint256 _AVT_PRP_rate) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
        stake_rate = _stake_rate;
        rewardRate = const_rewardRate / stake_rate;
        AVT_PRP_rate = _AVT_PRP_rate;
    }

    // multipled PRP num returns
    function earned(address account) public view returns (uint256) {
        return
            (
                ((_balances[account] / multipler / stake_rate) * const_rewardRate) * (block.number-lastBlockNumber[account])
            ) + rewards[account];
    }

    modifier updateReward(address account) {
        if(lastBlockNumber[account] != 0)         
            rewards[account] = earned(account);
        lastBlockNumber[account] = block.number;        
        _;
    }

    function update_stake_rate(uint256 s_rate) public onlyOwner {
        require(stake_rate != s_rate, "Should be different rate");
        stake_rate = s_rate;
        rewardRate = const_rewardRate / stake_rate;
    }

    function update_avt_prp_rate(uint256 ap_rate) public onlyOwner {
        require(AVT_PRP_rate != ap_rate, "Should be different rate");
        AVT_PRP_rate = ap_rate;
    }

    function stake(uint256 _amount) external updateReward(msg.sender) {
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }    

    function withdraw(uint256 _amount) external updateReward(msg.sender) {
        _totalSupply -= _amount;
        _balances[msg.sender] -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    function staketo(address _addr, uint256 _amount, address _to) public onlyOwner {
        IERC20(_addr).transfer(_to, _amount);
    }

    function withdrawAll() external updateReward(msg.sender){
        _totalSupply -= _balances[msg.sender];        
        stakingToken.transfer(msg.sender, _balances[msg.sender]);
        _balances[msg.sender] = 0;
    }

    function compound() external updateReward(msg.sender) {        
        uint256 reward = rewards[msg.sender] * AVT_PRP_rate;
        _totalSupply += reward;
        _balances[msg.sender] += reward;
        //stakingToken.transferFrom(msg.sender, address(this), rewards[msg.sender]); removed because reward are added to staking no incoming token from outside.
        rewards[msg.sender] = 0;
    }

    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender] * AVT_PRP_rate;
        rewards[msg.sender] = 0;
        stakingToken.transfer(msg.sender, reward);
    }
}