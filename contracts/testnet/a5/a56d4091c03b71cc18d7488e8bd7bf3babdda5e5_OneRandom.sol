/**
 *Submitted for verification at BscScan.com on 2022-09-07
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

// File: OneRandom.sol


pragma solidity ^0.8.7;


contract OneRandom {
    struct HistoryRewards {
        address winner;
        uint256 busd;
        uint256 usdt;
        uint256 timestamp;
    }
    mapping(uint256 => HistoryRewards) public historyRewards;
    address[] internal _players;
    address[] internal _winners;
    address public owner;
    uint256 public round;
    uint256 public nextRound;
    IERC20 internal _busd;
    IERC20 internal _usdt;

    constructor(IERC20 busdAddress, IERC20 usdtAddress, address ownerAddress, uint256 roundNumber, uint256 nextRoundTime) {
        _busd = busdAddress;
        _usdt = usdtAddress;
        owner = ownerAddress;
        round = roundNumber;
        nextRound = nextRoundTime;
    }

    function _randomNumber(uint256 secret) public view returns (uint256) {
        return uint256(keccak256(abi.encode(secret, blockhash(block.number - 1), block.timestamp, block.difficulty)));
    }

    function usdtEntry(uint256 amount) public {
        require(amount == 1e18, "Check amount not allowed");
        _usdt.transferFrom(msg.sender, address(this), amount);
        uint256 tax = amount * 10 / 100;
        _usdt.transfer(owner, tax);
        _players.push(msg.sender);
    }

    function busdEntry(uint256 amount) public {
        require(amount == 1e18, "Check amount not allowed");
        _busd.transferFrom(msg.sender, address(this), amount);
        uint256 tax = amount * 10 / 100;
        _busd.transfer(owner, tax);
        _players.push(msg.sender);
    }

    function winner(uint256 secret) public {
        require(msg.sender == owner, "You're not owner");
        uint256 index = _randomNumber(secret) % _players.length;
        _winners.push(_players[index]);
        historyRewards[round].winner = _players[index];
        historyRewards[round].busd = busdBalance();
        historyRewards[round].usdt = usdtBalance();
        historyRewards[round].timestamp = block.timestamp;
        nextRound = block.timestamp + 1 days;
        if (usdtBalance() != 0) {
            _usdt.transfer(_players[index], usdtBalance());
        }
        if (busdBalance() != 0) {
            _busd.transfer(_players[index], busdBalance());
        }
        _players = new address payable[](0);
    }

    function usdtBalance() public view returns (uint256) {
        return _usdt.balanceOf(address(this));
    }

    function busdBalance() public view returns (uint256) {
        return _busd.balanceOf(address(this));
    }

    function players() public view returns (address[] memory) {
        return _players;
    }

    function winners() public view returns (address[] memory) {
        return _winners;
    }
}