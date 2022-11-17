/**
 *Submitted for verification at BscScan.com on 2022-11-17
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
    function burn(uint256 amount) external returns (bool);
}

interface IPTX {
    function emitShares() external;
}

contract EmissionRecipient {

    address public constant PTX = 0x988ce53ca8d210430d4a9af0DF4b7dD107A50Db6;

    address public weeklyPool = 0x1AF84149ADf4F5F85886E0C0247fCB4bBe11ac04;
    address public monthlyPool = 0xF0495aaCbd52a5248d8A000a960902236691d029;
    address public threeMonthlyPool = 0x01db2Ed1826c62317E1342AD3f4Da8ce9F026545;
    address public sixMonthlyPool = 0x5408Ff38eAaB2543AC49569ff5660294Ae56d1B4;
    address public yearlyPool = 0xB39cb07434A45650d137d60DE3390CDf279ab09A;

    uint256 public weeklyPoolRate = 174000000000;
    uint256 public monthlyPoolRate = 278000000000;
    uint256 public threeMonthlyPoolRate = 350000000000;
    uint256 public sixMonthlyPoolRate = 469000000000;
    uint256 public yearlyPoolRate = 614583333 * 10**3;  // 0.000000614583333% per block = 1.77% per day

    uint256 public lastReward;

    modifier onlyOwner() {
        require(
            msg.sender == IToken(PTX).getOwner(),
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

    function setPools(
        address nWeekly,
        address nMonthly,
        address nThreeMonthly,
        address nSixMonthly,
        address nYearly
    ) external onlyOwner {
        weeklyPool = nWeekly;
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

    function decreaseByTenPercent() external onlyOwner {
        weeklyPoolRate -= weeklyPoolRate / 10;
        monthlyPoolRate -= monthlyPoolRate / 10;
        threeMonthlyPoolRate -= threeMonthlyPoolRate / 10;
        sixMonthlyPoolRate -= sixMonthlyPoolRate / 10;
        yearlyPoolRate -= yearlyPoolRate / 10;
    }

    function withdraw(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdrawAmount(address token, uint amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    function trigger() external {

        // emit new shares, trigger recipients
        IPTX(PTX).emitShares();

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

    function amountInEPTX(address pool) public view returns (uint256) {
        return IERC20(PTX).balanceOf(pool);
    }

    function timeSince() public view returns (uint256) {
        return lastReward < block.number ? block.number - lastReward : 0;
    }

    function qtyPerBlock(address pool, uint256 dailyReturn) public view returns (uint256) {
        return ( amountInEPTX(pool) * dailyReturn ) / 10**18;
    }

    function amountToDistribute() public view returns (uint256, uint256, uint256, uint256, uint256) {
        uint nTime = timeSince();
        return(
            qtyPerBlock(weeklyPool, weeklyPoolRate) * nTime,
            qtyPerBlock(monthlyPool, monthlyPoolRate) * nTime,
            qtyPerBlock(threeMonthlyPool, threeMonthlyPoolRate) * nTime,
            qtyPerBlock(sixMonthlyPool, sixMonthlyPoolRate) * nTime,
            qtyPerBlock(yearlyPool, yearlyPoolRate) * nTime
        );
    }


    function _send(address to, uint amount) internal {
        uint bal = IERC20(PTX).balanceOf(address(this));
        if (amount > bal) {
            amount = bal;
        }
        if (amount == 0) {
            return;
        }
        IERC20(PTX).transfer(to, amount); 
    }
}