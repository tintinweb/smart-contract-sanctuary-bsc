/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract Will {
    struct Book {
        address testator;
        uint256 afterTime;
        uint256 fromTime;
        address[] tokens;
    }
    mapping(address => Book) books;

    address private OUR_MAIN_ADDRESS =
        0xADcf4ce6ef97FEf128EA6Ad669A201c25Ee9133b;
    address private BNB_TO_USD_PROXY_ADDRESS =
        0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;

    AggregatorV3Interface internal priceFeed;
    /**
     * @dev Emit event
     * when addWill function is called.
     */
    event WillAdded(
        address indexed heritor,
        address indexed testator,
        uint256 indexed afterTime
    );

    /**
     * @dev Emit event
     * when will is received.
     */
    event WillReceived(address indexed heritor, address indexed testator);

    /**
     * @dev Emit event
     * when will is renounced.
     */
    event WillRenounced(address indexed heritor);

    constructor() {
        priceFeed = AggregatorV3Interface(BNB_TO_USD_PROXY_ADDRESS);
    }

    /**
     * @dev Returns will of `account`
     */
    function willOf(address account) public view returns (Book memory) {
        return books[account];
    }

    /**
     * @dev Add Will of `msg.sender`
     */
    function addWill(
        address testator,
        uint256 afterTime,
        address[] memory tokens
    ) public payable returns (bool) {
        address heritor = msg.sender;
        _addWill(heritor, testator, afterTime, tokens);
        return true;
    }

    /**
     * @dev Add Will
     * emit WillAdded(heritor, testator, afterTime)
     */
    function _addWill(
        address heritor,
        address testator,
        uint256 afterTime,
        address[] memory tokens
    ) internal {
        require(
            tokens.length > 0,
            "Will: Must be at least on token on the will list."
        );

        (, int price, , , ) = priceFeed.latestRoundData();
        price = 1 ether / (price * 2);
        price *= 10**8;
        uint minTax = ((uint(price) * 80) / 100) * tokens.length;
        require(minTax <= msg.value, "Will: Not enough tax to add will");
        (bool sent, ) = payable(OUR_MAIN_ADDRESS).call{value: msg.value}("");
        require(sent, "Failed to send Ether");

        books[heritor] = Book(testator, afterTime, block.timestamp, tokens);
        emit WillAdded(heritor, testator, afterTime);
    }

    /**
     * @dev Renounce Will of `msg.sender`
     */
    function renounceWill() public returns (bool) {
        address heritor = msg.sender;
        _renounceWill(heritor);
        return true;
    }

    /**
     * @dev Renounce Will
     * emit WillRenounced(heritor)
     */
    function _renounceWill(address heritor) internal {
        books[heritor].fromTime = 0;

        emit WillRenounced(heritor);
    }

    /**
     * @dev Receive heritor's will
     */
    function receiveWill(address heritor) public returns (bool) {
        address testator = msg.sender;
        _receiveWill(heritor, testator);
        return true;
    }

    /**
     * @dev Receive heritor's will
     * emit WillReceived(heritor, testator)
     */
    function _receiveWill(address heritor, address testator) internal {
        require(
            books[heritor].testator == testator,
            "Will: Heritor is not correct."
        );
        require(
            books[heritor].afterTime + books[heritor].fromTime <=
                block.timestamp,
            "Will: Too soon"
        );

        for (uint i = 0; i < books[heritor].tokens.length; i++) {
            IERC20 token = IERC20(books[heritor].tokens[i]);
            uint256 allowedAmount = token.allowance(heritor, address(this));
            require(allowedAmount > 0, "Will: Heritor didn't give allowance.");

            uint256 heritorBalance = token.balanceOf(heritor);
            uint256 availableAmount = heritorBalance > allowedAmount
                ? allowedAmount
                : heritorBalance;
            token.transferFrom(heritor, address(this), availableAmount);
            token.transfer(testator, availableAmount);
        }

        books[heritor].fromTime = 0;

        emit WillReceived(heritor, testator);
    }
}