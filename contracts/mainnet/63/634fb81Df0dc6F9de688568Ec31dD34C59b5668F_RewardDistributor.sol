/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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

interface IDaylight {
    function getOwner() external view returns (address);
}

interface IEmissions {
    function trigger() external;
}

interface IFarm {
    function depositRewards(uint256 amount) external;
}

contract RewardDistributor {

    // daylight token
    address public constant daylight = 0x62529D7dE8293217C8F74d60c8C0F6481DE47f0E;

    // emission distributor
    address public constant emissionDistributor = 0xfA5F9b81Ee35F679d2Cf0C569EfAcf8Cba7b00aC;

    // Yield Farm
    address public apolloBNB = 0xe188b2E114bB8CceEfC21B89c430f1bCa348988d;
    address public apolloDAYL = 0xdF99a11d842E22Ae0428B39A2d7BF6Ad730B0216;
    address public longFarm = 0x8f0E57e961b6B3C767F01A9d045C7457c22d338C;
    address public staking = 0x77fCC833fbb6e1e39262B817466041c183424867;
    address public mdbFarm = 0x6aB99fE4075361CD6063FF1f2B3d1bA2A5850930;

    // Percentages
    uint256 public apolloBNBPercent = 200;
    uint256 public apolloDAYLPercent = 450;
    uint256 public longFarmPercent = 225;
    uint256 public stakingPercent = 75;
    uint256 public mdbFarmPercent = 50;

    // only daylight owner
    modifier onlyOwner() {
        require(
            msg.sender == IDaylight(daylight).getOwner(),
            'Only Daylight Owner'
        );
        _;
    }

    function trigger() external {

        // trigger emission distributor to receive tokens
        IEmissions(emissionDistributor).trigger();

        // get balance
        uint256 balance = IERC20(daylight).balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        // denom for math
        uint256 DENOM = apolloBNBPercent + apolloDAYLPercent + longFarmPercent + stakingPercent + mdbFarmPercent;
        if (DENOM == 0) {
            return;
        }

        // split amounts
        uint256 forApolloBNB = ( balance * apolloBNBPercent ) / DENOM;
        uint256 forApolloDAYL = ( balance * apolloDAYLPercent ) / DENOM;
        uint256 forLongFarm = ( balance * longFarmPercent ) / DENOM;
        uint256 forMDB = ( balance * mdbFarmPercent ) / DENOM;

        if (apolloBNB != address(0) && forApolloBNB > 0) {
            IERC20(daylight).approve(apolloBNB, forApolloBNB);
            IFarm(apolloBNB).depositRewards(forApolloBNB);
        }

        if (apolloDAYL != address(0) && forApolloDAYL > 0) {
            IERC20(daylight).approve(apolloDAYL, forApolloDAYL);
            IFarm(apolloDAYL).depositRewards(forApolloDAYL);
        }

        if (longFarm != address(0) && forLongFarm > 0) {
            IERC20(daylight).approve(longFarm, forLongFarm);
            IFarm(longFarm).depositRewards(forLongFarm);
        }

        if (mdbFarm != address(0) && forMDB > 0) {
            IERC20(daylight).approve(mdbFarm, forMDB);
            IFarm(mdbFarm).depositRewards(forMDB);
        }

        uint256 forStaking = IERC20(daylight).balanceOf(address(this));
        if (staking != address(0) && forStaking > 0) {
            IERC20(daylight).transfer(staking, forStaking);
        }
    }

    function setPercents(uint256 apolloBNB_, uint256 apolloDayl_, uint256 longFarm_, uint256 staking_, uint256 mdb_) external onlyOwner {
        apolloBNBPercent = apolloBNB_;
        apolloDAYLPercent = apolloDayl_;
        longFarmPercent = longFarm_;
        stakingPercent = staking_;
        mdbFarmPercent = mdb_;
    }

    function reset(uint256 decrement) external onlyOwner {
        IERC20(daylight).transfer(emissionDistributor, IERC20(daylight).balanceOf(address(this)) - decrement);
    }

    function setApolloFarms(address apolloBNB_, address apolloDAYL_) external onlyOwner {
        apolloBNB = apolloBNB_;
        apolloDAYL = apolloDAYL_;
    }

    function setLongFarm(address farm_) external onlyOwner {
        longFarm = farm_;
    }

    function setStaking(address staking_) external onlyOwner {
        staking = staking_;
    }

    function setMDBFarm(address mdb_) external onlyOwner {
        mdbFarm = mdb_;
    }

}