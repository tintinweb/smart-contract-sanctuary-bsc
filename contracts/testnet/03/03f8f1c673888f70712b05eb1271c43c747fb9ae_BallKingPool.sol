/**
 *Submitted for verification at BscScan.com on 2022-12-17
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

// File: BallKingPool.sol


pragma solidity ^0.8.17;



interface BallKing {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract BallKingPool  is Ownable {

    //质押token地址
    IERC20 stakeToken;

    struct stakeType {
        uint256 stakeAmount; // 质押数量
        uint256 rewardPerMonth;  // 每日收益
        uint totalShares; // 总份额
        uint stakedShares; // 已质押份额
    }

    struct stakeInfo{
        uint stakeType; // 质押类型
        uint startDate; // 开始时间
        uint endDate; // 结束时间
        uint256 withdrawdReward; // 已提取收益
        uint256 totalReward; // 总收益
    }

    // 某地址质押信息
    mapping(address => stakeInfo) private stakeInfos;

    // 质押类型 0
    // stakeTypes[1] -> 3.6 0.1/month 180份
    // stakeTypes[2] -> 7.2 0.2/month 90份
    // stakeTypes[3] -> 10.8 0.3/month 30份
    mapping(uint => stakeType) private stakeTypes;

    function setParams() 
    external 
    onlyOwner 
    {  
        stakeToken =  IERC20(0xAB225c908D68Ef718749FFa51B3c794A6d150FB0);

        stakeTypes[1].stakeAmount = 3.6 * (10**18);
        stakeTypes[1].rewardPerMonth = 0.1*(10**18);
        stakeTypes[1].totalShares = 180;
        stakeTypes[1].stakedShares = 0;

        stakeTypes[2].stakeAmount = 7.2 * (10**18);
        stakeTypes[2].rewardPerMonth = 0.2*(10**18);
        stakeTypes[2].totalShares = 90;
        stakeTypes[2].stakedShares = 0;

        stakeTypes[3].stakeAmount = 10.8 * (10**18);
        stakeTypes[3].rewardPerMonth = 0.3*(10**18);
        stakeTypes[3].totalShares = 30;
        stakeTypes[3].stakedShares = 0;
    }



    //质押,【外部调用/所有人/不需要支付/读写状态】
    function stakeBallKing(uint _type) public
    {
        stakeType memory _stakeType = stakeTypes[_type];
        require(stakeToken.allowance(msg.sender, address(this)) >= _stakeType.stakeAmount, "Insufficient_allowance");
        // 质押份额未用尽
        require(_stakeType.stakedShares < _stakeType.totalShares, "SHARES_FULL");
        // 当前地址未有质押
        require(stakeInfos[msg.sender].stakeType <= 0, "ADDRESS_ALERADY_STAKED");
        stakeToken.transferFrom(msg.sender, address(this), _stakeType.stakeAmount); 
        // 设置质押信息
        stakeInfos[msg.sender].stakeType = _type; // 质押类型
        stakeInfos[msg.sender].startDate = block.timestamp; // 开始时间
        stakeInfos[msg.sender].endDate = block.timestamp + 1080 days; // 结束时间
        stakeInfos[msg.sender].totalReward = _stakeType.stakeAmount; // 总收益
        // 更新质押份额
        updateTotalShare(_type);
    } 


    //更新质押份额,【内部调用/合约创建者/不需要支付】
    function updateTotalShare(uint _type) 
        internal 
        onlyOwner 
    {  
        stakeTypes[_type].stakedShares += 1;
    }



    //计算已释放奖励,【内部调用/合约创建者/不需要支付/只读】
    function getReleasedReword(address _address) 
        internal
        onlyOwner
        view
        returns(uint256)
    {
        require(stakeInfos[_address].stakeType > 0, "ADDRESS_NO_STAKE_RECORD");
        stakeInfo memory _stakeInfo = stakeInfos[_address];
        stakeType memory _stakeType = stakeTypes[_stakeInfo.stakeType];
        uint monthsDiff = (block.timestamp - _stakeInfo.startDate) / 60 / 60 / 24 / 30;
        return monthsDiff * _stakeType.rewardPerMonth;
    }

    //计算可提取奖励,【内部调用/合约创建者/不需要支付/只读】
    function calculateCanWithdrawReword(address _address) 
        internal
        onlyOwner
        view
        returns(uint256)
    {
        require(stakeInfos[_address].stakeType > 0, "ADDRESS_NO_STAKE_RECORD");
        stakeInfo memory _stakeInfo = stakeInfos[_address];

        return getReleasedReword(_address) - _stakeInfo.withdrawdReward;
    }

    //获取可提取奖励,【内部调用/合约创建者/不需要支付/只读】
    function getCanWithdrawReword() 
        external
        view
        returns(uint256)
    {
        return calculateCanWithdrawReword(msg.sender);
    }

    //提现收益,【外部调用/所有人/不需要支付/读写】
    function withdraw(uint256 _amount) 
        external 
    {
        require(_amount <= calculateCanWithdrawReword(msg.sender), "WITHDRAW_AMOUNT_MORE_CANREWARD");
        require((_amount + stakeInfos[msg.sender].withdrawdReward) <= stakeInfos[msg.sender].totalReward, "WITHDRAW_AMOUNT_MORE_TOTALREWARD");
        
        stakeInfos[msg.sender].withdrawdReward += _amount;
        stakeToken.transferFrom(address(this), msg.sender, _amount); 
    }




    //获取质押份额,【外部调用/所有人/不需要支付/只读】
    function getStakeType(uint _type) 
        external
        view 
        returns(uint a,uint b,uint c,uint d)
    {
        return (stakeTypes[_type].stakeAmount,stakeTypes[_type].rewardPerMonth,stakeTypes[_type].totalShares,stakeTypes[_type].stakedShares);
    }

    //获取质押信息,【外部调用/所有人/不需要支付/只读】
    function getStakeInfo(address _address) 
        external
        view
        returns(uint a,uint b,uint c,uint d,uint e)
    {
        
        return (stakeInfos[_address].stakeType,stakeInfos[_address].startDate,stakeInfos[_address].endDate,stakeInfos[_address].withdrawdReward,stakeInfos[_address].totalReward);
    }
    //获取质押token信息,【外部调用/所有人/不需要支付/只读】
    function getStakeToken() 
        external
        view
        returns(IERC20)
    {
        
        return stakeToken;
    }

}