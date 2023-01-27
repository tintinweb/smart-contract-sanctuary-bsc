// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract TaxManager {
    address public selfTaxPool;
    address public rightUpTaxPool;
    address public maintenancePool;
    address public devPool;
    address public rewardAllocationPool;
    address public perpetualPool;
    address public tierPool;
    address public revenuePool;
    address public marketingPool;
    address public admin;

    uint256 public selfTaxRate;
    uint256 public rightUpTaxRate;
    uint256 public maintenanceTaxRate;
    uint256 public protocolTaxRate;
    uint256 public perpetualPoolTaxRate;
    // uint256 public devPoolTaxRate;
    uint256 public rewardPoolTaxRate;
    uint256 public marketingTaxRate;
    uint256 public constant taxBaseDivisor = 10000;
    struct TaxRates {
        uint256 first;
        uint256 second;
        uint256 third;
        uint256 fourth;
    }
    mapping(uint256 => TaxRates) referralRate;
    uint256 public tierPoolRate;

    modifier onlyAdmin() {
        // Change this to a list with ROLE library
        require(msg.sender == admin, "only admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function setAdmin(address account) public onlyAdmin {
        admin = account;
    }

    // Getters and setters for Addresses

    function setSelfTaxPool(address _selfTaxPool) external onlyAdmin {
        selfTaxPool = _selfTaxPool;
    }

    function getSelfTaxPool() external view returns (address) {
        return selfTaxPool;
    }

    function setRightUpTaxPool(address _rightUpTaxPool) external onlyAdmin {
        rightUpTaxPool = _rightUpTaxPool;
    }

    function getRightUpTaxPool() external view returns (address) {
        return rightUpTaxPool;
    }

    function setMaintenancePool(address _maintenancePool) external onlyAdmin {
        maintenancePool = _maintenancePool;
    }

    function getMaintenancePool() external view returns (address) {
        return maintenancePool;
    }

    function setDevPool(address _devPool) external onlyAdmin {
        devPool = _devPool;
    }

    function getDevPool() external view returns (address) {
        return devPool;
    }

    function setRewardAllocationPool(
        address _rewardAllocationPool
    ) external onlyAdmin {
        rewardAllocationPool = _rewardAllocationPool;
    }

    function getRewardAllocationPool() external view returns (address) {
        return rewardAllocationPool;
    }

    function setPerpetualPool(address _perpetualPool) external onlyAdmin {
        perpetualPool = _perpetualPool;
    }

    function getPerpetualPool() external view returns (address) {
        return perpetualPool;
    }

    function setTierPool(address _tierPool) external onlyAdmin {
        tierPool = _tierPool;
    }

    function getTierPool() external view returns (address) {
        return tierPool;
    }

    function setMarketingPool(address _marketingPool) external onlyAdmin {
        marketingPool = _marketingPool;
    }

    function getMarketingPool() external view returns (address) {
        return marketingPool;
    }

    function setRevenuePool(address _revenuePool) external onlyAdmin {
        revenuePool = _revenuePool;
    }

    function getRevenuePool() external view returns (address) {
        return revenuePool;
    }

    // Getters and setters for the Tax Rates

    function setSelfTaxRate(uint256 _selfTaxRate) external onlyAdmin {
        selfTaxRate = _selfTaxRate;
    }

    function getSelfTaxRate() external view returns (uint256) {
        return selfTaxRate;
    }

    function setRightUpTaxRate(uint256 _rightUpTaxRate) external onlyAdmin {
        rightUpTaxRate = _rightUpTaxRate;
    }

    function getRightUpTaxRate() external view returns (uint256) {
        return rightUpTaxRate;
    }

    function setMaintenanceTaxRate(
        uint256 _maintenanceTaxRate
    ) external onlyAdmin {
        maintenanceTaxRate = _maintenanceTaxRate;
    }

    function getMaintenanceTaxRate() external view returns (uint256) {
        return maintenanceTaxRate;
    }

    function setProtocolTaxRate(uint256 _protocolTaxRate) external onlyAdmin {
        protocolTaxRate = _protocolTaxRate;
    }

    function getProtocolTaxRate() external view returns (uint256) {
        return protocolTaxRate + rightUpTaxRate;
    }

    function getTotalTaxAtMint() external view returns (uint256) {
        return protocolTaxRate + rightUpTaxRate + selfTaxRate;
    }

    function setPerpetualPoolTaxRate(
        uint256 _perpetualPoolTaxRate
    ) external onlyAdmin {
        perpetualPoolTaxRate = _perpetualPoolTaxRate;
    }

    function getPerpetualPoolTaxRate() external view returns (uint256) {
        return perpetualPoolTaxRate;
    }

    function getTaxBaseDivisor() external pure returns (uint256) {
        return taxBaseDivisor;
    }

    function setBulkReferralRate(
        uint256 tier,
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external onlyAdmin {
        referralRate[tier].first = first;
        referralRate[tier].second = second;
        referralRate[tier].third = third;
        referralRate[tier].fourth = fourth;
    }

    function getReferralRate(
        uint256 depth,
        uint256 tier
    ) external view returns (uint256) {
        if (depth == 1) {
            return referralRate[tier].first;
        } else if (depth == 2) {
            return referralRate[tier].second;
        } else if (depth == 3) {
            return referralRate[tier].third;
        } else if (depth == 4) {
            return referralRate[tier].fourth;
        }
        return 0;
    }

    // function setDevPoolTaxRate(uint256 _devPoolRate) external {
    //     devPoolTaxRate = _devPoolRate;
    // }

    // function getDevPoolRate() external view returns (uint256) {
    //     return devPoolTaxRate;
    // }

    function setRewardPoolTaxRate(uint256 _rewardPoolRate) external onlyAdmin {
        rewardPoolTaxRate = _rewardPoolRate;
    }

    function getRewardPoolRate() external view returns (uint256) {
        return rewardPoolTaxRate;
    }

    function setTierPoolRate(uint256 _tierPoolRate) external onlyAdmin {
        tierPoolRate = _tierPoolRate;
    }

    function getTierPoolRate() external view returns (uint256) {
        return tierPoolRate;
    }

    function setMarketingTaxRate(uint256 _marketingTaxRate) external onlyAdmin {
        marketingTaxRate = _marketingTaxRate;
    }

    function getMarketingTaxRate() external view returns (uint256) {
        return marketingTaxRate;
    }

    function recoverTokens(address token, address benefactor) public onlyAdmin {
        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(benefactor, tokenBalance);
    }
}