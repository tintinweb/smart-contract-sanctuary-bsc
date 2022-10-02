/**
 *Submitted for verification at BscScan.com on 2022-10-01
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

// File: contracts/token/IFishdomToken.sol


pragma solidity ^0.8.9;


interface IFishdomToken is IERC20 {
    function burn(uint256 amount) external;
}

// File: contracts/FishdomStaking.sol


pragma solidity ^0.8.9;


contract FishdomStaking {
    uint256 constant unitToSecond = 60 * 60;
    uint256 public totalStaked;

    struct Package {
        uint256 apr;
        uint256 duration;
        uint8 id;
    }

    /**
     * @param owner: address of user staked
     * @param timestamp: last time check
     * @param amount: amount that user spent
     */
    struct Stake {
        uint256 stakeId;
        address owner;
        uint256 timestamp;
        uint256 amount;
        uint256 duration;
        uint256 apr;
    }

    event Staked(
        uint256 indexed stakeId,
        address indexed owner,
        uint256 amount,
        uint256 duration,
        uint256 apr
    );

    event Unstaked(
        uint256 indexed stakeId,
        address indexed owner,
        uint256 claimed
    );

    event Claimed(
        uint256 indexed stakeId,
        address indexed owner,
        uint256 indexed amount
    );

    IFishdomToken FishdomToken;
    address _owner;

    // maps address of user to stake
    Stake[] vault;
    Package[4] packages;

    constructor(address token_) {
        FishdomToken = IFishdomToken(token_);
        _owner = msg.sender;
    }

    function initialize() external onlyOwner {
        packages[0].apr = 100;
        packages[0].duration = 30;
        packages[0].id = 0;
        packages[1].apr = 138;
        packages[1].duration = 90;
        packages[1].id = 1;
        packages[2].apr = 220;
        packages[2].duration = 180;
        packages[2].id = 2;
        packages[3].apr = 5;
        packages[3].duration = 0;
        packages[3].id = 3;
    }

    function getListPackage() public view returns (Package[4] memory) {
        return packages;
    }

    function _calculateEarned(uint256 stakingId, bool isGetAll)
        internal
        view
        returns (uint256)
    {
        Stake memory ownerStaking = vault[stakingId];
        uint256 finalApr = ownerStaking.apr;
        if (ownerStaking.duration == 0) {
            uint256 stakedTimeClaim = (block.timestamp -
                ownerStaking.timestamp) / 1 days;
            uint256 earned = (ownerStaking.amount *
                finalApr *
                stakedTimeClaim) /
                100 /
                12 /
                30; // tiền lãi theo ngày * số ngày

            return isGetAll ? ownerStaking.amount + earned : earned;
        } else {
            return
                ownerStaking.amount +
                ((ownerStaking.duration * ownerStaking.amount * finalApr) /
                    100 /
                    30 /
                    12); // tiền lãi theo ngày * số ngày
        }
    }

    /**
     * @param _stakingId: 0 fixed - 30, 1 fixed - 90, 2 fixed - 180, 3: unfixed
     * @param _amount: amount user spent
     */
    function stake(uint8 _stakingId, uint256 _amount) external {
        Package memory finalPackage = packages[_stakingId];

        uint256 allowance = FishdomToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "FishdomStaking: Over allowance");
        FishdomToken.transferFrom(msg.sender, address(this), _amount);

        totalStaked += _amount;
        uint256 newStakeId = vault.length;
        vault.push(
            Stake(
                newStakeId,
                msg.sender,
                block.timestamp,
                _amount,
                finalPackage.duration,
                finalPackage.apr
            )
        );
        emit Staked(
            newStakeId,
            msg.sender,
            _amount,
            finalPackage.duration,
            finalPackage.apr
        );
    }

    function claim(uint256 _stakingId) external {
        Stake memory staked = vault[_stakingId];
        require(msg.sender == staked.owner, "Ownable: Not owner");
        uint256 lastTimeCheck = staked.timestamp;
        uint256 stakeDuration = staked.duration;
        if (stakeDuration != 0) {
            require(
                block.timestamp >=
                    (lastTimeCheck + (staked.duration * unitToSecond)),
                "Staking locked"
            );
        }
        uint256 earned = _calculateEarned(_stakingId, false);
        if (stakeDuration != 0) {
            totalStaked -= staked.amount;
            delete vault[_stakingId];
        } else {
            vault[_stakingId].timestamp = uint32(block.timestamp);
        }
        if (earned > 0) {
            FishdomToken.transfer(msg.sender, earned);
            emit Claimed(_stakingId, msg.sender, earned);
        }
    }

    function unstake(uint256 _stakingId) external {
        Stake memory staked = vault[_stakingId];
        require(staked.duration == 0, "Cannot unstake fixed staking package");
        require(msg.sender == staked.owner, "Ownable: Not owner");
        // xoá staking
        uint256 earned = _calculateEarned(_stakingId, true);
        totalStaked -= staked.amount;
        delete vault[_stakingId];
        emit Unstaked(_stakingId, msg.sender, earned);
        if (earned > 0) {
            FishdomToken.transfer(msg.sender, earned);
            emit Claimed(_stakingId, msg.sender, earned);
        }
    }

    function getEarned(uint256 stakingId) external view returns (uint256) {
        return _calculateEarned(stakingId, true);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        _owner = newOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "FishdomStaking: Not owner");
        _;
    }
}