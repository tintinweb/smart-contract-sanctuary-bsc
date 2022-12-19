//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

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

contract Presale {
    uint256 public rate;
    uint256 public raisedBNB;
    uint256 public raisedTokens;
    uint256 public endOfRaise;
    uint256 public minBNB;
    uint256 public maxBNB;
    bool public claimable;
    address payable public collectionWallet;
    address public admin;
    IERC20 public tokenAddress;

    mapping(address => uint256) public purchasedBnb;
    mapping(address => uint256) public purchasedTokens;

    event Deposit(address depositer, uint256 amountBnb, uint256 amountToken);
    event Claim(address claimer, uint256 tokens);
    event ChangeRate(uint256 newRate);
    event ChangeEndOfRaise(uint256 newEndOfRaise);
    event SetClaimState(bool newState);
    event ChangeCollectionWallet(address newWallet);
    event SetAdmin(address newAdmin);
    event ChangeMaxBNB(uint256 newMaxBNB);
    event ChangeMinBNB(uint256 newMinBNB);

    modifier raiseOpen() {
        require(block.timestamp < endOfRaise, "Raise over");
        _;
    }

    modifier untilClaimOpen() {
        require(claimable, "Cannot claim yet");
        _;
    }

    modifier adminOnly() {
        require(msg.sender == admin, "Admin only");
        _;
    }

    fallback() external payable {
        revert();
    }

    receive() external payable {
        revert();
    }

    constructor(
        uint256 initRate,
        uint256 endOfRaiseTime,
        IERC20 initTokenAddress,
        address payable initCollectionWallet,
        uint256 initMinBNB,
        uint256 initMaxBNB
    ) {
        rate = initRate;
        endOfRaise = endOfRaiseTime;
        tokenAddress = initTokenAddress;
        collectionWallet = initCollectionWallet;
        minBNB = initMinBNB;
        maxBNB = initMaxBNB;
        admin = msg.sender;
    }

    function deposit() public payable raiseOpen {
        address depositer = msg.sender;
        uint256 amountBNB = msg.value;

        require(amountBNB >= minBNB, "Lower than min");
        require(amountBNB <= maxBNB, "Higher than max");

        uint256 amountToken = amountBNB * rate;

        purchasedBnb[depositer] += amountBNB;
        purchasedTokens[depositer] += amountToken;

        raisedBNB += amountBNB;
        raisedTokens += amountToken;

        collectionWallet.transfer(amountBNB);

        emit Deposit(depositer, amountBNB, amountToken);
    }

    function claim() public untilClaimOpen {
        address claimer = msg.sender;
        uint256 tokens = purchasedTokens[claimer];

        require(tokens > 0, "No claim");

        purchasedTokens[claimer] = 0;
        tokenAddress.transfer(claimer, tokens);

        emit Claim(claimer, tokens);
    }

    // ADMIN FUNCTIONALITY ONLY

    function changeRate(uint256 newRate) public adminOnly {
        require(rate != 0, "Rate cant be zero");

        rate = newRate;

        emit ChangeRate(newRate);
    }

    function changeEndOfRaise(uint256 newRaiseFinish) public adminOnly {
        endOfRaise = newRaiseFinish;

        emit ChangeEndOfRaise(newRaiseFinish);
    }

    function setClaimState(bool newState) public adminOnly {
        claimable = newState;

        emit SetClaimState(newState);
    }

    function changeCollectionWallet(
        address payable newClaimAddress
    ) public adminOnly {
        require(newClaimAddress != address(0), "No zero address");

        collectionWallet = newClaimAddress;

        emit ChangeCollectionWallet(newClaimAddress);
    }

    function setMinBNB(uint256 newMinBNB) public adminOnly {
        minBNB = newMinBNB;
        emit ChangeMinBNB(newMinBNB);
    }

    function setMaxBNB(uint256 newMaxBNB) public adminOnly {
        maxBNB = newMaxBNB;
        emit ChangeMaxBNB(newMaxBNB);
    }

    function setAdmin(address newAdmin) public adminOnly {
        require(newAdmin != address(0), "No zero address");

        admin = newAdmin;

        emit SetAdmin(newAdmin);
    }
}