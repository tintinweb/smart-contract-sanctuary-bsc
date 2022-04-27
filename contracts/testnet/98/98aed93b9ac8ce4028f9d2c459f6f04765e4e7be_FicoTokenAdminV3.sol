// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(msg.sender);
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./security/ReentrancyGuard.sol";
import "./access/Runnable.sol";
import "./access/Ownable.sol";

contract FicoTokenAdminV3 is Ownable, ReentrancyGuard, Runnable {
    struct Transaction {
        string id;
        bool enable;
        bool claimed;
        address userAddress;
        uint256 amount;
        uint256 fee;
    }

    address public _ficoTokenAddress;
    address public _devAddress;
    uint256 public _externalFee;
    mapping(string => Transaction) _transactions;
    mapping(address => bool) public _operators;

    modifier onlyOperator() {
        require(_operators[msg.sender], "Forbidden");
        _;
    }

    constructor(
        address ficoTokenAddress,
        address devAddress,
        uint256 externalFee
    ) {
        require(
            ficoTokenAddress != address(0),
            "ficoTokenAddress is zero address"
        );
        _operators[msg.sender] = true;
        _ficoTokenAddress = ficoTokenAddress;
        _devAddress = devAddress;
        _externalFee = externalFee;
    }

    function addTransaction(
        string memory id,
        address to,
        uint256 amount,
        uint256 fee
    ) external nonReentrant onlyOperator {
        bytes memory strBytes = bytes(id);
        require(strBytes.length > 0, "Invalid id");
        require(!_transactions[id].enable, "Already added");
        require(to != address(0), "Zero address");
        require(amount > 0, "Invalid amount");

        _transactions[id] = Transaction(id, true, false, to, amount, fee);
    }

    function addTransactions(
        string[] memory ids,
        address[] memory addrs,
        uint256[] memory amounts,
        uint256[] memory fees
    ) external nonReentrant onlyOperator {
        require(addrs.length == amounts.length, "Invalid input 1");
        require(ids.length == amounts.length, "Invalid input 2");
        require(fees.length == amounts.length, "Invalid input 3");

        for (uint256 i = 0; i < ids.length; i++) {
            bytes memory strBytes = bytes(ids[i]);
            if (
                strBytes.length > 0 &&
                !_transactions[ids[i]].enable &&
                addrs[i] != address(0) &&
                amounts[i] > 0
            ) {
                _transactions[ids[i]] = Transaction(
                    ids[i],
                    true,
                    false,
                    addrs[i],
                    amounts[i],
                    fees[i]
                );
            }
        }
    }

    function claim(string memory id) external payable nonReentrant {
        bytes memory strBytes = bytes(id);
        require(strBytes.length > 0, "Invalid id");
        require(msg.value >= _externalFee, "Not enough external fee");

        Transaction memory transaction = _transactions[id];
        require(transaction.enable, "Not found");
        require(!transaction.claimed, "Already claimed");
        require(msg.sender == transaction.userAddress, "Forbidden");

        IERC20 ficoToken = IERC20(_ficoTokenAddress);
        require(
            ficoToken.balanceOf(address(this)) >=
                transaction.amount + transaction.fee,
            "Over amount"
        );

        _transactions[id].claimed = true;
        require(
            IERC20(_ficoTokenAddress).transfer(
                transaction.userAddress,
                transaction.amount
            )
        );
        if (transaction.fee > 0) {
            require(
                IERC20(_ficoTokenAddress).transfer(_devAddress, transaction.fee)
            );
        }
        emit Claimed(id);
    }

    function setFicoTokenAddress(address ficoTokenAddress) external onlyOwner {
        require(
            ficoTokenAddress != address(0),
            "ficoTokenAddress is zero address"
        );
        _ficoTokenAddress = ficoTokenAddress;
    }

    function setDevAddress(address devAddress) external onlyOwner {
        require(devAddress != address(0), "Zero address");
        _devAddress = devAddress;
    }

    function setExternalFee(uint256 externalFee) external onlyOwner {
        _externalFee = externalFee;
    }

    function setOperator(address operatorAddress, bool value)
        external
        onlyOwner
    {
        require(
            operatorAddress != address(0),
            "operatorAddress is zero address"
        );
        _operators[operatorAddress] = value;
        emit OperatorSetted(operatorAddress, value);
    }

    function withdrawToken(address tokenAddress, address recepient)
        external
        onlyOwner
    {
        IERC20 token = IERC20(tokenAddress);
        require(
            token.transfer(recepient, token.balanceOf(address(this))),
            "Failure withdraw"
        );
    }

    function withdrawBnb() external onlyOwner {
        address payable sender = payable(msg.sender);
        sender.transfer(address(this).balance);
    }

    event OperatorSetted(address operatorAddress, bool value);
    event Claimed(string id);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function burn(uint256 amount) external;

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

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

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Ownable.sol";

contract Runnable is Ownable {
    modifier whenRunning() {
        require(_isRunning, "Paused");
        _;
    }

    modifier whenNotRunning() {
        require(!_isRunning, "Running");
        _;
    }

    bool public _isRunning;

    constructor() {
        _isRunning = true;
    }

    function toggleRunning() external onlyOwner {
        _isRunning = !_isRunning;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable {
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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
        emit Paused(msg.sender);
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
        emit Unpaused(msg.sender);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }
}