/**
 *Submitted for verification at BscScan.com on 2023-01-13
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

interface IToken {
    function getOwner() external view returns (address);
}

contract Distributor {

    address public constant TRUTH = 0x55a633B3FCe52144222e468a326105Aa617CC1cc;

    address public weeklyPool = 0xcf8a986a9a7a57A3Daa0085E83DD2B2af5d9B372;
    address public monthlyPool = 0x66AaeB0044A5a5084e1F5aB08B05e2f413415288;
    address public threeMonthlyPool = 0x509865D9A76CdD310651bBcebcaE08C69F3357b9;
    address public sixMonthlyPool = 0x7058903eb501b62bE4A7ADD0B7Ab906Ec5E14EF8;
    address public yearlyPool = 0xC5359c9a55bC5AF6781a02677E61bECA0254e9A6;

    uint256 public weeklyPoolRate       = 200 * 10**18;
    uint256 public monthlyPoolRate      = 330 * 10**18;
    uint256 public threeMonthlyPoolRate = 260 * 10**18;
    uint256 public sixMonthlyPoolRate   = 260 * 10**18;
    uint256 public yearlyPoolRate       = 1200 * 10**18;

    uint256 public lastReward;

    modifier onlyOwner() {
        require(
            msg.sender == IToken(TRUTH).getOwner(),
            'Only Owner'
        );
        _;
    }

    constructor() {
        lastReward = block.number;
    }

    function resetEmissions() external onlyOwner {
        lastReward = block.number;
    }

    function setLastRewardStartTime(uint startBlock) external onlyOwner {
        lastReward = startBlock;
    }

    function setPools(
        address weekly,
        address nMonthly,
        address nThreeMonthly,
        address nSixMonthly,
        address nYearly
    ) external onlyOwner {
        weeklyPool = weekly;
        monthlyPool = nMonthly;
        threeMonthlyPool = nThreeMonthly;
        sixMonthlyPool = nSixMonthly;
        yearlyPool = nYearly;
    }

    function setRates(
        uint256 nWeekly,
        uint256 nMonthly,
        uint256 nThreeMonthly,
        uint256 nSixMonthly,
        uint256 nYearly
    ) external onlyOwner {
        weeklyPoolRate = nWeekly;
        monthlyPoolRate = nMonthly;
        threeMonthlyPoolRate = nThreeMonthly;
        sixMonthlyPoolRate = nSixMonthly;
        yearlyPoolRate = nYearly;
    }

    function withdraw(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdrawAmount(address token, uint amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    function trigger() external {

        // amount to reward
        (
        uint week, uint month, uint threeMonth, uint sixMonth, uint year        
        ) = amountToDistribute();
        
        // reset timer
        lastReward = block.number;

        // send reward to the vault
        _send(weeklyPool, week);
        _send(monthlyPool, month);
        _send(threeMonthlyPool, threeMonth);
        _send(sixMonthlyPool, sixMonth);
        _send(yearlyPool, year);

    }

    function timeSince() public view returns (uint256) {
        return lastReward < block.number ? block.number - lastReward : 0;
    }

    function qtyPerBlock(uint256 rate) public pure returns (uint256) {
        return rate / 28800;
    }

    function amountToDistribute() public view returns (uint256, uint256, uint256, uint256, uint256) {
        uint nTime = timeSince();
        return(
            qtyPerBlock(weeklyPoolRate) * nTime,
            qtyPerBlock(monthlyPoolRate) * nTime,
            qtyPerBlock(threeMonthlyPoolRate) * nTime,
            qtyPerBlock(sixMonthlyPoolRate) * nTime,
            qtyPerBlock(yearlyPoolRate) * nTime
        );
    }

    function _send(address to, uint amount) internal {
        uint bal = IERC20(TRUTH).balanceOf(address(this));
        if (amount > bal) {
            amount = bal;
        }
        if (amount == 0) {
            return;
        }
        IERC20(TRUTH).transfer(to, amount); 
    }
}