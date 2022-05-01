/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;

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
    function transferFrom(
        address sender,
        address recipient,
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


pragma solidity >= 0.8.0;

contract MultiTransferTool {

    string version = "1.0.0";
    address public owner;
    uint32 public batchLimit;
    bool public init = false;
    uint256 public seq;
    uint256[] public fees;
    uint256[] public levels;

    uint256 public whitelist_n;
    uint256 public blacklist_n;
    mapping(address => bool) private whitelist;
    mapping(address => bool) private blacklist;

    event MultiTransfer (address indexed token, uint256 total, uint256 fee, uint256 indexed batch, uint256 indexed seq);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (uint256[] memory fees_, uint256[] memory levels_) payable {
        initialize(fees_, levels_);
    }

    function initialize(uint256[] memory fees_, uint256[] memory levels_) public payable {
        require(!init, "The contract has been initialized!");

        owner = msg.sender;
        batchLimit = 1000;
        seq = 0;
        init = true;
        whitelist_n = 0;
        blacklist_n = 0;
        setFees(fees_, levels_);   
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function calcTransferFee(uint256 batch) public view virtual returns (uint256) {
        uint256 n = levels.length;
        require(n>0,"the contract is free");
        for (uint256 i = 0; i < n; ++i) {
            if (batch <= levels[i]) {
                return fees[i];
            }
        }

        return n > 0 ? fees[n - 1] * batch / levels[n - 1] : 0;
    }

    modifier canTransfer() {
        require(whitelist_n == 0 || whitelist[msg.sender], "The caller isn't in white list.");
        require(blacklist_n == 0 || !blacklist[msg.sender], "The caller is in black list.");
        _;
    }

    function multiTransferToken(address token, address[] calldata receivers, uint256[] calldata amounts) external payable canTransfer {
        require(receivers.length == amounts.length);
        require(amounts.length <= batchLimit);

        uint256 fee = calcTransferFee(amounts.length);
        require(msg.value >= fee); 

        uint256 total = 0;
        if (token != address(0)) {
            for (uint256 i = 0; i < amounts.length; ++i) {
                total += amounts[i];
                IERC20(token).transferFrom(msg.sender, receivers[i], amounts[i]);
            }

            fee = msg.value;
        } else {
            for (uint256 i = 0; i < amounts.length; ++i) {
                total += amounts[i];
                payable(receivers[i]).transfer(amounts[i]);
            }

            require(msg.value >= total + fee);
            fee = msg.value - total;
        }

        seq += 1;
        payable(owner).transfer(fee);
        emit MultiTransfer(token, total, fee, amounts.length, seq);
    }

    function setBatchLimit(uint32 limit) external onlyOwner {
        batchLimit = limit;
    }

    function setFees(uint256[] memory fees_, uint256[] memory levels_) public onlyOwner {
        require(fees_.length == levels_.length);

        fees = fees_;
        levels = levels_;
    }

    function transferOwnership(address owner_) external onlyOwner {
        require(owner_ != address(0));

        emit OwnershipTransferred(owner, owner_);
        owner = owner_;
    }

    function addWhitelist(address[] calldata users) external onlyOwner returns (uint256) {
        uint256 n = 0;
        for (uint256 i = 0; i < users.length; ++i) {
            if (!whitelist[users[i]]) {
                whitelist[users[i]] = true;
                ++n;
            }
        }

        whitelist_n += n;
        return n;
    }

    function addBlacklist(address[] calldata users) external onlyOwner returns (uint256) {
        uint256 n = 0;
        for (uint256 i = 0; i < users.length; ++i) {
            if (!blacklist[users[i]]) {
                blacklist[users[i]] = true;
                ++n;
            }
        }

        blacklist_n += n;
        return n;
    }

    function removeWhitelist(address[] calldata users) external onlyOwner returns (uint256) {
        uint256 n = 0;
        for (uint256 i = 0; i < users.length; ++i) {
            if (whitelist[users[i]]) {
                delete whitelist[users[i]];
                ++n;
            }
        }

        require(whitelist_n >= n);
        whitelist_n -= n;
        return n;
    }

    function removeBlacklist(address[] calldata users) external onlyOwner returns (uint256) {
        uint256 n = 0;
        for (uint256 i = 0; i < users.length; ++i) {
            if (blacklist[users[i]]) {
                delete blacklist[users[i]];
                ++n;
            }
        }

        require(blacklist_n >= n);
        blacklist_n -= n;
        return n;
    }

    function isWhitelist(address user) external view onlyOwner returns (bool) {
        return whitelist[user];
    }


    function isBlacklist(address user) external view onlyOwner returns (bool) {
        return blacklist[user];
    }

}