//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Sale {

    // User Structure
    struct User {
        uint256 donated;
        uint256 toReceive;
    }
    // Address => User
    mapping ( address => User ) public donors;

    // List Of All Donors
    address[] private _allDonors;

    // Total Amount Donated
    uint256 private _totalDonated;

    // Receiver Of Donation
    address private constant receiver = 0x27DF7e6A705270e088447eb09A273cdC81cB39b6;
    address private constant presaleReceiver = 0x27DF7e6A705270e088447eb09A273cdC81cB39b6;

    // maximum contribution
    uint256 public constant max_contribution = 5000 * 10**18;
    uint256 public constant min_contribution = 50 * 10**18;

    // soft / hard cap
    uint256 public constant hardCap = 705_000 * 10**18;

    // exchange rates
    uint256 public constant exchangeRate = 2127 * 10**16; // 1 BUSD => 21.27 Tokens => 0.047 BUSD/Token

    // time duration
    uint256 public constant duration = 15 * 60; // 3 days
    uint256 public endBlock;

    // sale has ended
    bool public hasStarted;
    bool public claimEnabled;

    // donor index
    uint256 private donorIndex;
    uint256 private constant allowedIterations = 100;

    // token for sale
    // Mainnet
    // IERC20 public token = IERC20(0xd9075d050cA8905c6e14053C52A09244E3049124);
    // Testnet
    IERC20 public token = IERC20(0xE68fcc69a5958B905F3ca49C9877BF19D89E40A3);

    // Mainnet
    // IERC20 public BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    // Testnet
    IERC20 public BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

    // Donation Event, Trackers Donor And Amount Donated
    event Donated(address donor, uint256 amountDonated, uint256 totalInSale);

    modifier onlyReceiver(){
        require(msg.sender == receiver, 'Only Receiver');
        _;
    }

    function startSale() external onlyReceiver {
        hasStarted = true;
        endBlock = block.number + duration;
    }

    function enableClaiming() external onlyReceiver {
        claimEnabled = true;
    }

    function withdraw(IERC20 token_) external onlyReceiver {
        require(hasEnded(), 'Sale Still Ongoing');
        token_.transfer(receiver, token_.balanceOf(address(this)));
    }

    function massAirdrop() external onlyReceiver {

        uint len = _allDonors.length;
        for (uint i = 0; i < allowedIterations;) {

            if (donorIndex >= len) {
                break;
            }
            _send(_allDonors[donorIndex], donors[_allDonors[donorIndex]].toReceive);
            donors[_allDonors[donorIndex]].toReceive = 0;

            donorIndex++;
            unchecked{ ++i; }
        }
    }

    function claim() external {
        require(
            hasEnded(),
            'Sale Has Not Ended'
        );
        require(
            claimEnabled,
            'Claiming Is Disabled'
        );
        require(
            donors[msg.sender].toReceive > 0,
            'Zero To Receive'
        );
        _send(msg.sender, donors[msg.sender].toReceive);
        donors[msg.sender].toReceive = 0;
    }

    function donate(uint256 amount) external {
        uint received = _transferIn(amount);
        _process(msg.sender, received);
    }

    function donated(address user) external view returns(uint256) {
        return donors[user].donated;
    }

    function tokensToReceive(address user) external view returns(uint256) {
        return donors[user].toReceive;
    }

    function allDonors() external view returns (address[] memory) {
        return _allDonors;
    }

    function donorAtIndex(uint256 index) external view returns (address) {
        return _allDonors[index];
    }

    function numberOfDonors() external view returns (uint256) {
        return _allDonors.length;
    }

    function totalDonated() external view returns (uint256) {
        return _totalDonated;
    }

    function _process(address user, uint amount) internal {
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            hasStarted,
            'Sale Has Not Started'
        );
        require(
            hasEnded() == false,
            'Sale Has Ended'
        );

        // add to donor list if first donation
        if (donors[user].donated == 0) {
            _allDonors.push(user);
        }

        // increment amounts donated
        donors[user].donated += amount;
        _totalDonated += amount;

        // give exchange amount
        donors[user].toReceive += ( amount * exchangeRate ) / 10**18;

        require(
            donors[user].donated <= max_contribution,
            'Exceeds Max Contribution'
        );
        require(
            donors[user].donated >= min_contribution,
            'Contribution too low'
        );
        require(
            _totalDonated <= hardCap,
            'Hard Cap Reached'
        );
        require(
            BUSD.transfer(
                presaleReceiver,
                amount
            ),
            'Failure On BUSD Transfer'
        );
        emit Donated(user, amount, _totalDonated);
    }

    function _send(address user, uint amount) internal {
        if (amount == 0) {
            return;
        }
        require(
            token.transfer(
                user,
                amount
            ),
            'Error On Token Transfer'
        );
    }

    function _transferIn(uint amount) internal returns (uint256) {
        uint before = BUSD.balanceOf(address(this));
        require(
            BUSD.transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            'Failure On BUSD Transfer'
        );
        uint After = BUSD.balanceOf(address(this));
        require(
            After > before,
            'No Tokens Received'
        );
        return After - before;
    }

    function hasEnded() public view returns (bool) {
        return endBlock <= block.number;
    }

    function timeLeftUntilExpiration() public view returns (uint256) {
        if (hasEnded()) { return 0; }
        return endBlock - block.number;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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