pragma solidity 0.8.12;

import "IDDLpDepositor.sol";
import "IEarner.sol";
import "IERC20.sol";
import "IMasterChef.sol";

contract IncentiveEarner is IEarner {
    address public incentives;
    address public owner;
    address public constant chef = 0x3eB63cff72f8687f8DE64b2f0e40a5B95302D028;
    address public constant lpDepositor = 0x8189F0afdBf8fE6a9e13c69bA35528ac6abeB1af;
    address public constant ddLpToken = 0xbFa075679a6c47D619269F854adD50C965d5cC64;
    address public constant epsLpToken = 0x6B46dFaC1E46f059cea6C0a2D7642d58e8BE71F8;

    constructor() {
        // set to prevent the implementation contract from being initialized
        incentives = address(0xdead);
    }

    function initialize(address _account) external override {
        require(incentives == address(0));
        incentives = msg.sender;
        owner = _account;
        IMasterChef(chef).setClaimReceiver(address(this), _account);
        IERC20(ddLpToken).approve(msg.sender, type(uint256).max);
    }

    function deposit(uint256 _amount) external override {
        require(msg.sender == incentives);
        IMasterChef(chef).deposit(incentives, _amount);
    }

    function withdraw(uint256 _amount) external override {
        require(msg.sender == incentives);
        IMasterChef(chef).withdraw(incentives, _amount);
    }

    function claim_dotdot(uint256 _maxBondAmount) external override {
        require(msg.sender == incentives);
        address[] memory tokens = new address[](1);
        tokens[0] = epsLpToken;
        IDDLpDepositor(lpDepositor).claim(owner, tokens, _maxBondAmount);
    }

    function claim_extra() external override {
        require(msg.sender == incentives);
        IDDLpDepositor(lpDepositor).claimExtraRewards(owner, epsLpToken);
    }
}

pragma solidity 0.8.12;

struct Amounts {
    uint256 epx;
    uint256 ddd;
}

struct ExtraReward {
    address token;
    uint256 amount;
}

interface IDDLpDepositor {
    function deposit(address _user, address _token, uint256 _amount) external;
    function withdraw(address _receiver, address _token, uint256 _amount) external;
    function claimable(address _user, address[] calldata _tokens) external view returns (Amounts[] memory);
    function claimableExtraRewards(address user, address pool) external view returns (ExtraReward[] memory);
    function claim(address _receiver, address[] calldata _tokens, uint256 _maxBondAmount) external;
    function claimExtraRewards(address _receiver, address pool) external;
}

pragma solidity 0.8.12;

interface IEarner {
    function initialize(address _account) external;
    function deposit(uint256 _amount) external;
    function withdraw(uint256 _amount) external;
    function claim_dotdot(uint256 _maxBondAmount) external;
    function claim_extra() external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

/**
 * Based on the OpenZeppelin IER20 interface:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol
 *
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

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

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

pragma solidity 0.8.12;

interface IMasterChef {
    function userBaseClaimable(address _user) external view returns (uint256);
    function claimableReward(address _user, address[] calldata _tokens) external view returns (uint256[] memory);
    function setClaimReceiver(address _user, address _receiver) external;
    function deposit(address _token, uint256 _amount) external;
    function withdraw(address _token, uint256 _amount) external;
    function claim(address _user, address[] calldata _tokens) external;
}