// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BetMarketERC20 {
    address public owner;
    uint256 public totalMarkets = 0;
    IERC20 public token;

    constructor(IERC20 _token) {
        owner = msg.sender;
        token = _token;
    }

    mapping(uint256 => Markets) public markets;

    struct Markets {
        uint256 id;
        string market;
        uint256 timestamp;
        uint256 endTimestamp;
        address createdBy;
        string creatorImageHash;
        AmountAdded[] yesCount;
        AmountAdded[] noCount;
        uint256 totalAmount;
        uint256 totalYesAmount;
        uint256 totalNoAmount;
        bool eventCompleted;
        string description;
        string resolverUrl;
    }

    struct AmountAdded {
        address user;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => uint256) public winningAmount;
    address[] public winningAddresses;

    event MarketCreated(
        uint256 id,
        string market,
        uint256 timestamp,
        address createdBy,
        string creatorImageHash,
        uint256 totalAmount,
        uint256 totalYesAmount,
        uint256 totalNoAmount
    );

    function getBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function createMarket(
        string memory _market,
        string memory _creatorImageHash,
        string memory _description,
        string memory _resolverUrl,
        uint256 _endTimestamp
    ) public {
        require(msg.sender == owner, "Unauthorized");
        uint256 timestamp = block.timestamp;

        Markets storage market = markets[totalMarkets];
        market.id = totalMarkets++;
        market.market = _market;
        market.timestamp = timestamp;
        market.createdBy = msg.sender;
        market.creatorImageHash = _creatorImageHash;
        market.totalAmount = 0;
        market.totalYesAmount = 0;
        market.totalNoAmount = 0;
        market.description = _description;
        market.resolverUrl = _resolverUrl;
        market.endTimestamp = _endTimestamp;

        emit MarketCreated(
            totalMarkets,
            _market,
            timestamp,
            msg.sender,
            _creatorImageHash,
            0,
            0,
            0
        );
    }

    function addYesBet(uint256 _marketId, uint256 _betAmount) public {
        require(_betAmount != 0, "you cant stake 0 token");
        Markets storage market = markets[_marketId];
        token.transferFrom(msg.sender, address(this), _betAmount);
        AmountAdded memory amountAdded = AmountAdded(
            msg.sender,
            _betAmount,
            block.timestamp
        );

        market.totalYesAmount += _betAmount;
        market.totalAmount += _betAmount;
        market.yesCount.push(amountAdded);
    }

    function addNoBet(uint256 _marketId, uint256 _betAmount) public {
        require(_betAmount != 0, "you cant stake 0 token");
        Markets storage market = markets[_marketId];
        token.transferFrom(msg.sender, address(this), _betAmount);

        AmountAdded memory amountAdded = AmountAdded(
            msg.sender,
            _betAmount,
            block.timestamp
        );

        market.totalNoAmount += _betAmount;
        market.totalAmount += _betAmount;
        market.noCount.push(amountAdded);
    }

    function getGraphData(uint256 _marketId)
        public
        view
        returns (AmountAdded[] memory, AmountAdded[] memory)
    {
        Markets storage market = markets[_marketId];
        return (market.yesCount, market.noCount);
    }

    function distributeWinningAmount(uint256 _marketId, bool eventOutcome)
        public
    {
        require(msg.sender == owner, "Unauthorized");

        Markets storage market = markets[_marketId];
        if (eventOutcome) {
            for (uint256 i = 0; i < market.yesCount.length; i++) {
                uint256 amount = (market.totalNoAmount *
                    market.yesCount[i].amount) / market.totalYesAmount;
                winningAmount[market.yesCount[i].user] += (amount +
                    market.yesCount[i].amount);
                winningAddresses.push(market.yesCount[i].user);
            }

            for (uint256 i = 0; i < winningAddresses.length; i++) {
                address _address = winningAddresses[i];
                token.transfer(_address, winningAmount[_address]);
                delete winningAmount[_address];
            }
            delete winningAddresses;
        } else {
            for (uint256 i = 0; i < market.noCount.length; i++) {
                uint256 amount = (market.totalYesAmount *
                    market.noCount[i].amount) / market.totalNoAmount;
                winningAmount[market.noCount[i].user] += (amount +
                    market.noCount[i].amount);
                winningAddresses.push(market.noCount[i].user);
            }

            for (uint256 i = 0; i < winningAddresses.length; i++) {
                address _address = winningAddresses[i];
                token.transfer(_address, winningAmount[_address]);
                delete winningAmount[_address];
            }
            delete winningAddresses;
        }
        market.eventCompleted = true;
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