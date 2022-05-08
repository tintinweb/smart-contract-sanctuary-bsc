/**
 *Submitted for verification at BscScan.com on 2022-05-08
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IMinter {
    function balanceOf(address owner) external returns (uint256);
    function ownerOf(uint256 tokenId) external returns (address);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function totalSupply() external returns (uint256);
    function TOKEN_ID() external returns (uint);
}

contract MainstreetDistributor is Ownable, ReentrancyGuard {

    address public MAINST_TOKEN;
    address public MINTER;
    uint public CLAIM_TIME_PERIOD = 86400 * 30; // 30 days in seconds

    uint public TOTAL_MAINST_DISTRIBUTED = 0;

    uint public mainstToDistribute = 0;

    // mapping from token id to last claimed at timestamp
    mapping (uint => uint) public lastClaimedInfo;

    constructor(
        address minter,
        address mainst
    ) {
        MINTER = minter;
        MAINST_TOKEN = mainst;
    }

    function setMinterAddress(address minter) public onlyOwner {
        MINTER = minter;
    }

    function setClaimTimePeriod(uint time) public onlyOwner {
        CLAIM_TIME_PERIOD = time;
    }

    // function to set the distribution amount automatically based on total number of holders and contract balance
    function setDistributionAmount() public onlyOwner() {
        mainstToDistribute = IBEP20(MAINST_TOKEN).balanceOf(address(this)) / IMinter(MINTER).totalSupply();
    }

    // function to distribute an arbitrary amount of mainst tokens
    function setDistributionAmount(uint amount) public onlyOwner() {
        mainstToDistribute = amount;
    }

    // to distribute MAINST token wise
    function distributeMainst(uint tokenNumber, uint amount) public onlyOwner() {
        require(tokenNumber <= IMinter(MINTER).TOKEN_ID(), "Token index out of range");
        IBEP20(MAINST_TOKEN).transfer(IMinter(MINTER).ownerOf(tokenNumber), amount);
        updateTotalMainstDistributed(amount);
    }

    // to distribute MAINST in batches to save gas
    function distributeMainstInBatch(uint startingToken, uint endingToken) public onlyOwner() {
        require(startingToken < endingToken && endingToken <= IMinter(MINTER).TOKEN_ID(), "Token index out of range");
        uint amount = 0;
        for(uint index = startingToken; index <= endingToken; index++) {
            address owner = IMinter(MINTER).ownerOf(index);
            if (owner != address(0)) {
                IBEP20(MAINST_TOKEN).transfer(owner, mainstToDistribute);
                amount = amount + mainstToDistribute;
            }
        }
        updateTotalMainstDistributed(amount);
    }

    // claim mainstreet tokens by individual token ids
    function claimMainst(uint[] memory tokenIds) public nonReentrant() {
        uint amount = 0;
        for (uint index = 0; index < tokenIds.length; index++) {
            require(msg.sender == IMinter(MINTER).ownerOf(tokenIds[index]), "not your token");
            require(block.timestamp - lastClaimedInfo[tokenIds[index]] > CLAIM_TIME_PERIOD, "Can only claim once a month");
            lastClaimedInfo[tokenIds[index]] = block.timestamp;
            amount = amount + mainstToDistribute;
        }
        IBEP20(MAINST_TOKEN).transfer(msg.sender, mainstToDistribute);
        updateTotalMainstDistributed(amount);
    }

    // convenience function to claim for all tokens at once without inputting all ids
    function claimMainst() public nonReentrant() {
        uint balance = IMinter(MINTER).balanceOf(msg.sender);
        require(balance > 0, "Balance nil");
        uint amount = 0;
        for (uint index = 0; index < balance; index++) {
            uint tokenId = IMinter(MINTER).tokenOfOwnerByIndex(msg.sender, index);
            require(block.timestamp - lastClaimedInfo[tokenId] > CLAIM_TIME_PERIOD, "Claim period not over yet");
            lastClaimedInfo[tokenId] = block.timestamp;
            amount = amount + mainstToDistribute;
        }
        IBEP20(MAINST_TOKEN).transfer(msg.sender, amount);
        updateTotalMainstDistributed(amount);
    }

    function updateTotalMainstDistributed(uint amount) private {
        TOTAL_MAINST_DISTRIBUTED += amount;
    }

    // emergency withdrawal function in case of any bug
    function withdrawMainst() public onlyOwner() {
        IBEP20(MAINST_TOKEN).transfer(msg.sender, IBEP20(MAINST_TOKEN).balanceOf(address(this)));
    }
}