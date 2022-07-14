/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// Sources flattened with hardhat v2.10.0 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

// SPDX-License-Identifier: MIT
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


// File @openzeppelin/contracts/security/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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


// File contracts/Common/TwoProfitReceiverRescue.sol

pragma solidity 0.8.9;
// TwoProfitReceiverRescue contract
abstract contract TwoProfitReceiverRescue is Ownable {


    address payable internal profitReceiver1;
    address payable internal profitReceiver2;

    constructor(address payable _profitReceiver1, address payable _profitReceiver2) {
        profitReceiver1 = _profitReceiver1;
        profitReceiver2 = _profitReceiver2;
    }



    //Use this in case BNB are sent to the contract by mistake
    function rescueBNB() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "TwoProfitReceiverRescue: balance is 0");
        uint256 halfBalance = balance / 2;
        profitReceiver1.transfer(halfBalance);
        profitReceiver2.transfer(balance - halfBalance);
    }

    // Function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    // Owner cannot transfer out catecoin from this smart contract
    function rescueAnyERC20Tokens(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "TwoProfitReceiverRescue: balance is 0");
        uint256 halfBalance = balance / 2;
        token.transfer(profitReceiver1, halfBalance);
        token.transfer(profitReceiver2, balance - halfBalance);
    }

    receive() external payable{}
}


// File contracts/Interfaces/IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
    function withdraw(uint) external;
}


// File contracts/V2/Bridge/IROCDepositV2.sol

pragma solidity 0.8.9;


interface IROCDepositV2 {

    function deposit(
        uint128 _targetUserId,
        address _tokenAddress,
        uint256 _amount) payable external;
}


// File contracts/V2/Bridge/ROCDepositV2.sol

pragma solidity 0.8.9;
// ROCDepositV2 contract
contract ROCDepositV2 is IROCDepositV2, TwoProfitReceiverRescue, Pausable {

    event Deposited(
        address indexed _fromWallet,
        uint128 indexed _userId,
        address indexed _tokenAddress,
        uint256 _amount
    );
    event SupportedTokenChanged(
        address _tokenAddress,
        bool _enable,
        uint256 _minimum,
        uint256 _maximum
    );
    
    struct SupportedTokenInfo {
        bool enabled;
        uint256 minimum;
        uint256 maximum;
    }

    address private walletAddress;
    IWETH public wBNB;
    mapping(address => SupportedTokenInfo) public supportedTokenMapping;

    constructor(address payable _profitReceiver1, address payable _profitReceiver2, address _walletAddress, IWETH _wBNB)
            TwoProfitReceiverRescue(_profitReceiver1, _profitReceiver2) {
        walletAddress = _walletAddress;
        wBNB = _wBNB;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }


    function addSupportedToken(address[] memory _tokenAddresses, uint256[] memory _minimums, uint256[] memory _maximums)
        public
        onlyOwner
    {
        require(
            _tokenAddresses.length == _minimums.length &&
            _tokenAddresses.length == _maximums.length,
            "ROCDepositV2: tokenAddresses, minimums and maximums must have the same length");
        require(_tokenAddresses.length > 0,
            "ROCDepositV2: tokenAddresses must have at least one element");

        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            require(_minimums[i] <= _maximums[i],
                "ROCDepositV2: minimums must be less or equal to maximums");
            supportedTokenMapping[_tokenAddresses[i]] = SupportedTokenInfo(true, _minimums[i], _maximums[i]);
            emit SupportedTokenChanged(_tokenAddresses[i], true, _minimums[i], _maximums[i]);
        }
    }
    
    function updateSupportedToken(address _tokenAddress, uint256 _minimum, uint256 _maximum)
        public
        onlyOwner
    {
        require(_minimum <= _maximum,
            "ROCDepositV2: minimum must be less or equal to maximum");
        SupportedTokenInfo storage info = supportedTokenMapping[_tokenAddress];
        supportedTokenMapping[_tokenAddress] = SupportedTokenInfo(info.enabled, _minimum, _maximum);
        emit SupportedTokenChanged(_tokenAddress, info.enabled, _minimum, _maximum);
    }

    function removeSupportedToken(address[] memory _tokenAddresses)
        public
        onlyOwner
    {
        require(_tokenAddresses.length > 0,
            "ROCDepositV2: tokenAddresses must have at least one element");
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            SupportedTokenInfo storage info = supportedTokenMapping[_tokenAddresses[i]];
            if (info.enabled) {
                info.enabled = false;
                emit SupportedTokenChanged(
                    _tokenAddresses[i],
                    false,
                    info.minimum,
                    info.maximum
                );
            }
        }
    }

    function isSupportedToken(address _tokenAddress) public view returns (bool) {
        return supportedTokenMapping[_tokenAddress].enabled;
    }


    function deposit(
        uint128 _targetUserId,
        address _tokenAddress,
        uint256 _amount) external override payable whenNotPaused {
        require(
            _targetUserId > 0,
            "ROCDepositV2: targetUserId must be greater than 0"
        );
        require(
            isSupportedToken(_tokenAddress),
            "ROCDepositV2: tokenAddress is not supported"
        );
        SupportedTokenInfo storage info = supportedTokenMapping[_tokenAddress];
        require(
            _amount >= info.minimum && _amount <= info.maximum,
            "ROCDepositV2: amount is less than minimum"
        );
        bool isERC20 = _tokenAddress != address(0);
        uint256 realAmount = _amount;
        if (!isERC20) {
            require(_amount == msg.value,
                "ROCDepositV2: amount must be equal to msg.value");
            wBNB.deposit{value: _amount}();
            wBNB.transfer(walletAddress, _amount);
        } else {
            IERC20 erc20Token = IERC20(_tokenAddress);
            realAmount = erc20Token.balanceOf(walletAddress);
            erc20Token.transferFrom(
                address(msg.sender),
                walletAddress,
                _amount
            );
            realAmount = erc20Token.balanceOf(walletAddress) - realAmount;
        }
        emit Deposited(
            address(msg.sender),
            _targetUserId,
            _tokenAddress,
            realAmount
        );
    }
}