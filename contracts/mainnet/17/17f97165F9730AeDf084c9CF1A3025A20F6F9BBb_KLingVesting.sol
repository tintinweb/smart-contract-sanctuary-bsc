// SPDX-License-Identifier:UNLICENSED
pragma solidity 0.8.14;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract KLingVesting {

    IERC20 public token;

    address public owner;

    uint256 emergencyWithdrawFeePercenatage = 3;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Vested(address indexed account, uint256 indexed amount);
    event claimed(address indexed account, uint256 indexed phase, uint256 indexed amount);
    event emergencyWithdrawal(address indexed account, uint256 indexed phase, uint256 indexed amount);

    struct Vest {
        uint256 phaseStartTime;
        uint256 phaseAmount;
        uint256 availableToken;
        bool status;
    }

    uint256 public amount;
    uint256 public startTime;
    uint256 public withdrawAmount;
    uint256 public currentPhase;
    uint256 public lastPayout;
    bool public vestingStatus;

    mapping(uint256 => Vest) vestDetail;
    mapping(uint256 => uint256) phases;

    modifier onlyOwner {
        require (owner == msg.sender, "Ownable: caller is not a owner");
        _;
    }

    constructor(IERC20 _token) {
        token = _token;
        owner = msg.sender;
        phases[1] = 20;
        phases[2] = 30;
        phases[3] = 50;
    }

    function transferOwnership(address newOwner) external onlyOwner virtual {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function vest(uint256 _amount) external onlyOwner returns(bool){
        require(!vestingStatus, "already vested");
        uint256 phaseOne = _amount * phases[1] / 100;
        uint256 phaseTwo = _amount * phases[2] / 100;
        uint256 phaseThree = _amount * phases[3] / 100;

        vestDetail[1] = Vest(block.timestamp, phaseOne, phaseOne, false);
        vestDetail[2] = Vest(block.timestamp + 365 days, phaseTwo, phaseTwo, false);
        vestDetail[3] = Vest(block.timestamp + 365 * 2 days, phaseThree, phaseThree, false);

        amount = _amount;
        startTime = block.timestamp;
        currentPhase = 1;
        lastPayout = block.timestamp;
        vestingStatus = true;
        token.transferFrom(msg.sender, address(this), amount);
        emit Vested(msg.sender, amount);
        return true;
    }

    function getPhase(uint256 time) internal view returns(uint256 phase) {
        uint256 timeDiff = block.timestamp - time;
        if(timeDiff <= 365 days)
            return 1;
        if(timeDiff >= 365 days && timeDiff <= 365 days * 2)
            return 2;
        if(timeDiff >= 365 days * 2)
            return 3;
    }

    function cliam() external onlyOwner returns(bool) {
        require(vestingStatus, "not vested");
        uint256 timeDiff = block.timestamp - vestDetail[currentPhase].phaseStartTime;
        require(timeDiff >= 365 days, "time not exceeds");
        uint256 transferAmount = vestDetail[currentPhase].availableToken;
        token.transfer(msg.sender, transferAmount);
        withdrawAmount += transferAmount;
        vestDetail[currentPhase].availableToken -= transferAmount;
        vestDetail[currentPhase].status = true;
        if(withdrawAmount == amount)
            vestingStatus = false;
        currentPhase += 1;
        emit claimed(msg.sender, currentPhase, transferAmount);
        return true;
    }

    function emergencyWithdraw() external onlyOwner returns(bool) {
        require(vestingStatus, "not vested");
        uint256 phase = getPhase(startTime);
        uint256 lastPayoutTimeDiff = block.timestamp - lastPayout;
        uint256 phaseTimeDiff = block.timestamp - vestDetail[phase].phaseStartTime;
        require(lastPayoutTimeDiff >= 30 days && phaseTimeDiff >= 30 days, "time not exceeds");
        uint256 transferAmount = vestDetail[phase].phaseAmount * emergencyWithdrawFeePercenatage / 100;
        token.transfer(msg.sender, transferAmount);
        withdrawAmount += transferAmount;
        vestDetail[phase].availableToken -= transferAmount;
        lastPayout = block.timestamp;
        emit emergencyWithdrawal(msg.sender, phase, amount);
        return true;
    }

    function getDetails() external view returns(Vest[] memory) {
        Vest[] memory data = new Vest[](3);
        for(uint8 i = 1; i <= 3; i++) {
            data[i-1] = vestDetail[i];
        }
        return data;
    }

}

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