/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

contract OmniousX {
    IERC20 token;
    address private owner;
    address private tokenAddress; // BUSD Address
    address private walletDev1;
    address private walletDev2;
    uint256 payFullAmount = 25000000000000000000;
    uint256 payPartialAmount = 15000000000000000000;
    uint256 payReferrerAmount = 20000000000000000000;
    uint256 activateFee = 50000000000000000000;
    uint256[] prices = [
        20000000000000000000,
        30000000000000000000,
        40000000000000000000,
        50000000000000000000
    ];
    address[] private users;

    mapping(address => uint256) public referrerContributions;
    mapping(address => address[]) public referredAddresses;
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public multiplier;

    constructor(address _tokenAddress, address _walletDev1, address _walletDev2) {
        tokenAddress = _tokenAddress;
        walletDev1 = _walletDev1;
        walletDev2 = _walletDev2;
        token = IERC20(tokenAddress);
        owner = msg.sender;
    }

    receive() external payable {
        uint256 amountSplit = msg.value / uint(2);
        SplitPayment(msg.sender, amountSplit);
    }

    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function GetAllowance() public view returns (uint256) {
        return token.allowance(msg.sender, address(this));
    }

    function GetUserTokenBalance() public view returns (uint256) {
        return token.balanceOf(msg.sender);
    }

    function activateWallet(address referrer) public payable {
        require(referrer != msg.sender, "OmniousX: self referral not allowed");
        require(
            multiplier[msg.sender] == 0,
            "OmniousX: you are already registered"
        );
        require(
            multiplier[referrer] != 0,
            "OmniousX: referrer is not registered"
        );
        require(
            GetAllowance() >= activateFee,
            "OmniousX: Please approve tokens before transferring"
        );
        require(
            GetUserTokenBalance() >= activateFee,
            "OmniousX: Not enough BUSD"
        );
        addUser(msg.sender, referrer);
    }

    function activateWalletWithoutReferrer() public payable {
        require(
            multiplier[msg.sender] == 0,
            "OmniousX: you are already registered"
        );
        require(
            GetAllowance() >= activateFee,
            "OmniousX: Please approve tokens before transferring"
        );
        require(
            GetUserTokenBalance() >= activateFee,
            "OmniousX: Not enough BUSD"
        );
        addUser(msg.sender, address(0));
    }

    function addUser(address beneficiary, address referrer) internal {
        users.push(beneficiary);
        startTime[beneficiary] = block.timestamp;
        multiplier[beneficiary] = 1;

        if (referrer != address(0) && multiplier[referrer] != 0) {
            referrerContributions[referrer] =
                referrerContributions[referrer] +
                (payReferrerAmount);
            referredAddresses[referrer].push(beneficiary);
            SplitPaymentWithReferrer(
                beneficiary,
                referrer,
                payPartialAmount,
                payReferrerAmount
            );
        } else {
            SplitPayment(beneficiary, payFullAmount);
        }
    }

    function IncreaseMultiplier(uint256 multiplierAmount) public payable {
        require(
            multiplierAmount >= 1 && multiplierAmount <= 10,
            "OmniousX: invalid multiplier amount"
        );
        require(multiplier[msg.sender] >= 1, "OmniousX: please register first");

        uint256 amount = 0;

        for (
            uint256 i = multiplier[msg.sender] + 1;
            i <= multiplier[msg.sender] + multiplierAmount;
            i++
        ) {
            if (i <= 10) {
                amount = amount + prices[0];
            }
            if (i > 10 && i <= 20) {
                amount = amount + prices[1];
            }
            if (i > 20 && i <= 30) {
                amount = amount + prices[2];
            }
            if (i > 30) {
                amount = amount + prices[3];
            }
        }
        multiplier[msg.sender] = multiplier[msg.sender] + multiplierAmount;
        uint256 amountSplit = amount / uint(2);
        SplitPayment(msg.sender, amountSplit);
    }

    function SplitPaymentWithReferrer(
        address beneficiary,
        address referrer,
        uint256 beneficiaryAmount,
        uint256 referrerAmount
    ) internal {
        require(
            GetAllowance() >= activateFee,
            "OmniousX: Please approve tokens before transferring"
        );

        token.transferFrom(beneficiary, address(referrer), referrerAmount);
        token.transferFrom(beneficiary, address(walletDev1), beneficiaryAmount);
        token.transferFrom(beneficiary, address(walletDev2), beneficiaryAmount);
    }

    function SplitPayment(address beneficiary, uint256 beneficiaryAmount)
        internal
    {
        require(
            GetAllowance() >= beneficiaryAmount,
            "OmniousX: Please approve tokens before transferring"
        );
        token.transferFrom(beneficiary, address(walletDev1), beneficiaryAmount);
        token.transferFrom(beneficiary, address(walletDev2), beneficiaryAmount);
    }

    function GetUsers() public OnlyOwner view returns (address[] memory) {
        return users;
    }

    function GetUsersLength() public view returns (uint256) {
        return users.length;
    }

    function GetReferredAddresses(address referrerAddr)
        public
        view
        returns (address[] memory)
    {
        return referredAddresses[referrerAddr];
    }

    function GetMultiplier(address beneficiary) public view returns (uint256) {
        return multiplier[beneficiary];
    }

    function GetReferrerContributions(address beneficiary)
        public
        view
        returns (uint256)
    {
        return referrerContributions[beneficiary];
    }

    function GetUserStartTime(address beneficiary)
        public
        view
        returns (uint256)
    {
        return startTime[beneficiary];
    }

    function ChangeFullAmount(uint256 newPayFullAmount) public OnlyOwner {
        payFullAmount = newPayFullAmount;
    }

    function ChangeActivateFee(uint256 newActivateFee) public OnlyOwner {
        activateFee = newActivateFee;
    }

    function ChangePayReferrerAmount(uint256 newPayReferrerAmount)
        public
        OnlyOwner
    {
        payReferrerAmount = newPayReferrerAmount;
    }

    function ChangePayPartialAmount(uint256 newPayPartialAmount)
        public
        OnlyOwner
    {
        payPartialAmount = newPayPartialAmount;
    }
}