// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// https://github.com/fazalmittu/FazeBetting/blob/main/src/contracts/bet.sol
// https://github.com/integral0909/token-betting/blob/master/contracts/BnbPricePrediction.sol
contract OldMan {
    IERC20 public BUSD;
    address public feeAddress;

    uint256 public totalBetMoney = 0;
    address public adminAddress;
    uint256 public minBetAmount;
    uint256 public feeRatio = 10; // 10%

    uint256 constant emptyAnswer = 9999;
    uint256 public answer = emptyAnswer;

    struct Team {
        string name;
        uint256 totalBetAmount;
    }
    Team[] public teams;

    struct BetInfo {
        address player;
        uint256 position;
        uint256 totalBetAmount;
        uint256 timestamp;
        bool claimed; // default false
    }
    BetInfo[] public bets;

    mapping(address => BetInfo[]) playerBetAmount;
    mapping(address => bool) rewardClaimed;

    event MinBetAmountUpdated(uint256 minBetAmount);
    event AnswerUpdated(uint256 answer);
    event FeeAddressUpdated(address feeAddress);
    event NewBet(
        address indexed sender,
        uint256 totalBetAmount,
        uint256 indexed teamId
    );
    event Claim(address indexed sender, uint256 reward);

    constructor(
        address _busd,
        address _adminAddress,
        address _feeAddress,
        uint256 _minBetAmount
    ) {
        BUSD = IERC20(_busd);
        adminAddress = _adminAddress;
        feeAddress = _feeAddress;
        minBetAmount = _minBetAmount;

        // Init pool
        teams.push(Team("2022", 0)); // Index 0
        teams.push(Team("2023", 0)); // Index 1
        teams.push(Team("2024", 0)); // Index 2
        teams.push(Team("2025", 0)); // Index 3
        teams.push(Team("2026", 0)); // Index 4
        teams.push(Team("2027", 0)); // Index 5
        teams.push(Team("2028", 0)); // Index 6
        teams.push(Team("2029", 0)); // Index 7
        teams.push(Team("2030+", 0)); // Index 8
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }
    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "admin: wut?");
        _;
    }

    /**
     * @dev set minBetAmount
     * callable by admin
     */
    function setMinBetAmount(uint256 _minBetAmount) external onlyAdmin {
        minBetAmount = _minBetAmount;
        emit MinBetAmountUpdated(minBetAmount);
    }

    /**
     * @dev set answer
     * callable by admin
     */
    function setAnswer(uint256 _answer) external onlyAdmin {
        require(_answer <= 8, "Answer error.");
        answer = _answer;
        emit AnswerUpdated(answer);
    }

    /**
     * @dev set answer
     * callable by admin
     */
    function setFeeAddress(address _feeAddress) external onlyAdmin {
        require(_feeAddress != address(0), "Address can not be zero.");
        feeAddress = _feeAddress;
        emit FeeAddressUpdated(feeAddress);
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /**
     * @dev Bet
     */
    function bet(uint256 _teamId, uint256 _amount)
        external
        payable
        notContract
    {
        require(answer == emptyAnswer, "Cant bet now");
        require(
            _amount >= minBetAmount,
            "Bet amount must be greater than minBetAmount"
        );
        require(_teamId <= 8, "Team error.");
        require(
            BUSD.balanceOf(msg.sender) >= _amount,
            "Not enough tokens in the reserve"
        );

        uint256 feeAmount = (_amount * feeRatio) / 100;
        uint256 betAmount = _amount - feeAmount;

        // add entry
        bets.push(
            BetInfo(msg.sender, _teamId, betAmount, block.timestamp, false)
        );

        playerBetAmount[msg.sender][_teamId].totalBetAmount += betAmount;
        teams[_teamId].totalBetAmount += betAmount;

        totalBetMoney += betAmount;

        // Bet transfer
        BUSD.transferFrom(msg.sender, address(this), betAmount);
        // Fee transfer
        BUSD.transferFrom(msg.sender, feeAddress, feeAmount);
        emit NewBet(msg.sender, _amount, _teamId);
    }

    /**
     * @dev Claim reward
     */
    function claim() external notContract {
        require(answer != emptyAnswer, "Cant claim now");
        require(!rewardClaimed[msg.sender], "Rewards claimed");
        // Check if win
        require(
            playerBetAmount[msg.sender][answer].totalBetAmount > 0,
            "No Rewards need to claime"
        );

        uint256 reward;
        reward =
            (playerBetAmount[msg.sender][answer].totalBetAmount *
                (1000000 +
                    (totalBetMoney * 1000000) /
                    teams[answer].totalBetAmount)) /
            1000000;

        rewardClaimed[msg.sender] = true;
        BUSD.transferFrom(address(this), address(msg.sender), reward);

        emit Claim(msg.sender, reward);
    }
}

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