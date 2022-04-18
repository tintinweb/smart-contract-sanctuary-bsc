/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

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

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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
     * by making the `nonReentrant` function external, and making it call a
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

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract SamuraiLocker is ReentrancyGuard, Ownable {
    
    address samurai = 0xbC832492afc102F36f7752F0D325e1f68648614F;
    address BUSD    = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    uint256 launchTime;

    mapping (address => uint256) public samuraiBalanceOf;
    mapping (address => uint256) public initialSamuraiBalanceOf;
    mapping (address => uint256) public lastWithdraw;

    constructor() {
        launchTime = block.timestamp;

        _setBalances();
    }

    function harvestBUSD() external nonReentrant {
        require(msg.sender == 0x9FC5F5546962DbF47f6b7b4e62D309367e447C6D ||
                msg.sender == 0xF1f1481afc7b3Dd10fc5cBAb4D7d63545f9cAb7B ||
                msg.sender == 0xC25aB8e2273cfAeD644Ab55e9c8675d5966664DE ||
                msg.sender == 0xfC348b61bDdE67C49e7caEAA6E3fDa843F0057e0 ||
                msg.sender == 0x1D202195A3fa9fF141d3e0D8b631EE39E72243f2);
                
        uint256 busdBalance = IERC20(BUSD).balanceOf(address(this));
        IERC20(BUSD).transfer(msg.sender, busdBalance);
    }

    function withdrawnableBUSD() public view returns (uint256) {
        return IERC20(BUSD).balanceOf(address(this));
    }

    function unlockTokens() external nonReentrant {
        if (msg.sender == 0x9FC5F5546962DbF47f6b7b4e62D309367e447C6D) {
                require(block.timestamp - launchTime > 365 days, "Cannot unlock tokens before a year after launch");
                require(samuraiBalanceOf[msg.sender] > 0, "No tokens to unlock");
                
                IERC20(samurai).transfer(msg.sender, samuraiBalanceOf[msg.sender]);
                samuraiBalanceOf[msg.sender] = 0;
        }

        if (msg.sender == 0xfC348b61bDdE67C49e7caEAA6E3fDa843F0057e0 ||
            msg.sender == 0x1D202195A3fa9fF141d3e0D8b631EE39E72243f2) {
                require(block.timestamp - launchTime > 90 days, "Cannot unlock tokens before three months after launch");
                require(block.timestamp - lastWithdraw[msg.sender] > 7 days, "Cannot withdraw twice in less than a week");

                uint256 twoPercent = initialSamuraiBalanceOf[msg.sender] / 50;
                
                require(samuraiBalanceOf[msg.sender] >= twoPercent, "Not enough balance left to withdraw");

                IERC20(samurai).transfer(msg.sender, twoPercent);
                samuraiBalanceOf[msg.sender] -= twoPercent;
                lastWithdraw[msg.sender] = block.timestamp;
        }

        if (msg.sender == 0xF1f1481afc7b3Dd10fc5cBAb4D7d63545f9cAb7B ||
            msg.sender == 0xC25aB8e2273cfAeD644Ab55e9c8675d5966664DE) {
                require(block.timestamp - launchTime > 30 days, "Cannot unlock tokens before a month after launch");
                require(block.timestamp - lastWithdraw[msg.sender] > 7 days, "Cannot withdraw twice in less than a week");
                
                uint256 onePercent = initialSamuraiBalanceOf[msg.sender] / 100;
                
                require(samuraiBalanceOf[msg.sender] >= onePercent, "Not enough balance left to withdraw");

                IERC20(samurai).transfer(msg.sender, onePercent);
                samuraiBalanceOf[msg.sender] -= onePercent;
                lastWithdraw[msg.sender] = block.timestamp;
        }
    }

    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function _setBalances() internal {
        samuraiBalanceOf[0x9FC5F5546962DbF47f6b7b4e62D309367e447C6D] = 200000000 * (10**18);
        samuraiBalanceOf[0xF1f1481afc7b3Dd10fc5cBAb4D7d63545f9cAb7B] =  30000000 * (10**18);
        samuraiBalanceOf[0xC25aB8e2273cfAeD644Ab55e9c8675d5966664DE] =  30000000 * (10**18);
        samuraiBalanceOf[0xfC348b61bDdE67C49e7caEAA6E3fDa843F0057e0] =  50000000 * (10**18);
        samuraiBalanceOf[0x1D202195A3fa9fF141d3e0D8b631EE39E72243f2] =  50000000 * (10**18);

        initialSamuraiBalanceOf[0x9FC5F5546962DbF47f6b7b4e62D309367e447C6D] = 200000000 * (10**18);
        initialSamuraiBalanceOf[0xF1f1481afc7b3Dd10fc5cBAb4D7d63545f9cAb7B] =  30000000 * (10**18);
        initialSamuraiBalanceOf[0xC25aB8e2273cfAeD644Ab55e9c8675d5966664DE] =  30000000 * (10**18);
        initialSamuraiBalanceOf[0xfC348b61bDdE67C49e7caEAA6E3fDa843F0057e0] =  50000000 * (10**18);
        initialSamuraiBalanceOf[0x1D202195A3fa9fF141d3e0D8b631EE39E72243f2] =  50000000 * (10**18);
    }
}