/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// File: @openzeppelin\contracts\utils\Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol

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

// File: contracts\TriflePrototype.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;
contract TriflePrototype is Ownable {
    uint256 public totalColleteralInSC;
    uint256 public totalBorrowed;

    address[] public LPaddress = [
        0xDd5D160C42a604285577989d7974A5793e7f1B53,
        0x37373daB8c1D3B01C3B48BFf42c051feDe91Ec7a,
        0x0E68928a81fe2a3982ED5F14C4eb9906199DB8a5
    ];

    address public SCaddress = 0xc00Ff5736Daf7f7BB8f335CFf7599dAAb520722D;
    IERC20 SCtoken = IERC20(0xc00Ff5736Daf7f7BB8f335CFf7599dAAb520722D);

    mapping(address => uint256) private lpPrice;

    IERC20[] public LPtoken = [
        IERC20(0xDd5D160C42a604285577989d7974A5793e7f1B53),
        IERC20(0x37373daB8c1D3B01C3B48BFf42c051feDe91Ec7a),
        IERC20(0x0E68928a81fe2a3982ED5F14C4eb9906199DB8a5)
    ];

    // lp >> wallet >> collateral
    mapping(address => mapping(address => uint256)) public collateralizedLP;

    mapping(address => uint256) public borrower;

    event CollateralProvided(address _account, uint256 _amount);
    event CollateralWithdraw(address _account, uint256 _amount);

    constructor() {
        lpPrice[0xDd5D160C42a604285577989d7974A5793e7f1B53] = 1;
        lpPrice[0x37373daB8c1D3B01C3B48BFf42c051feDe91Ec7a] = 2;
        lpPrice[0x0E68928a81fe2a3982ED5F14C4eb9906199DB8a5] = 3;
    }

    function getLPindex(address _address) private pure returns (uint256 index) {
        if (_address == 0xDd5D160C42a604285577989d7974A5793e7f1B53) return 0;
        if (_address == 0x37373daB8c1D3B01C3B48BFf42c051feDe91Ec7a) return 1;
        if (_address == 0x0E68928a81fe2a3982ED5F14C4eb9906199DB8a5) return 2;
    }

    function provideCollateral(address _lpAddress, uint256 _amount) public {
        uint256 lpIndex = getLPindex(_lpAddress);

        IERC20 _LPtoken = LPtoken[lpIndex];

        require(
            _LPtoken.allowance(msg.sender, address(this)) >= _amount,
            "Vault must have enough allowance."
        );
        require(
            _LPtoken.balanceOf(msg.sender) >= _amount,
            "Must have enough LP to provide"
        );
        _LPtoken.transferFrom(msg.sender, address(this), _amount);
        collateralizedLP[_lpAddress][msg.sender] += _amount;

        totalColleteralInSC += _amount * lpPrice[_lpAddress];

        emit CollateralProvided(msg.sender, _amount);
    }

    function calCollateralValue(address account) public view returns (uint256) {
        uint256 sumValue = 0;
        for (uint256 i = 0; i < LPaddress.length; i++) {
            address _lpaddress = LPaddress[i];
            sumValue += (collateralizedLP[_lpaddress][account] *
                lpPrice[_lpaddress]);
        }

        return sumValue;
    }

    function calLockedValue(address account) public view returns (uint256) {
        uint256 SCborrowed = borrower[account];

        uint256 halfCeling = (SCborrowed + 1) / (2);
        uint256 calcLocked = halfCeling * 3;

        return calcLocked;
    }

    function getMaxWithdrawAllowed(address account, address lpToken)
        public
        view
        returns (uint256)
    {
        return
            (calCollateralValue(account) - calLockedValue(account)) /
            lpPrice[lpToken];
    }

    function withdrawCollateral(address _lpAddress, uint256 _withdrawAmount)
        public
        returns (bool)
    {
        uint256 lpIndex = getLPindex(_lpAddress);

        IERC20 _LPtoken = LPtoken[lpIndex];

        uint256 amount;
        uint256 maxAmount = getMaxWithdrawAllowed(
            msg.sender,
            address(_LPtoken)
        );

        if (_withdrawAmount == 0) {
            amount = maxAmount;
        } else {
            amount = _withdrawAmount;
        }

        require(maxAmount >= amount, "Trying to withdraw too much");

        require(
            collateralizedLP[_lpAddress][msg.sender] >= amount,
            "you are trying to withdraw more collateral than you have locked"
        );

        _LPtoken.transfer(msg.sender, amount);

        totalColleteralInSC -= amount * lpPrice[_lpAddress];

        return true;
    }

    function borrowSC(uint256 _borrowAmount) public {
        uint256 borrowLimit = calcBorrowLimit(calCollateralValue(msg.sender));
        uint256 borrowAmountAllowed = borrowLimit - borrower[msg.sender];

        require(
            borrowAmountAllowed >= _borrowAmount,
            "Cannot borrow more than borrow limit"
        );

        require(
            SCtoken.balanceOf(address(this)) > _borrowAmount,
            "out of SC in stock"
        );

        SCtoken.transfer(msg.sender, _borrowAmount);
        borrower[msg.sender] += _borrowAmount;

        totalBorrowed += _borrowAmount;
    }

    function repayBorrow(uint256 _repayAmount) public payable {
        require(msg.value == _repayAmount);
        require(
            borrower[msg.sender] >= _repayAmount,
            "Cannot repay more than borrow"
        );

        borrower[msg.sender] -= _repayAmount;

        totalBorrowed -= _repayAmount;
    }

    function viewTotalColleteralValue() public view returns (uint256) {
        uint256 sumValue = 0;
        for (uint256 i = 0; i < LPaddress.length; i++) {
            address _lpaddress = LPaddress[i];
            sumValue += (collateralizedLP[_lpaddress][msg.sender] *
                lpPrice[_lpaddress]);
        }

        return sumValue;
    }

    function viewTotalBorrowedValue(address _account)
        public
        view
        returns (uint256)
    {
        return borrower[_account];
    }

    function viewColleteral(address _LPaddress) public view returns (uint256) {
        return collateralizedLP[_LPaddress][msg.sender];
    }

    function viewSCValue() public view returns (uint256) {
        return SCtoken.balanceOf(address(this));
    }

    function calcBorrowLimit(uint256 _collateralValue)
        public
        pure
        returns (uint256)
    {
        uint256 thirdCollatVal = _collateralValue / (3);
        return thirdCollatVal + thirdCollatVal;
    }

    function viewBorrowLimit() public view returns (uint256) {
        uint256 sumValue = 0;
        for (uint256 i = 0; i < LPaddress.length; i++) {
            address _lpaddress = LPaddress[i];
            sumValue += (collateralizedLP[_lpaddress][msg.sender] *
                lpPrice[_lpaddress]);
        }

        return calcBorrowLimit(sumValue);
    }
}