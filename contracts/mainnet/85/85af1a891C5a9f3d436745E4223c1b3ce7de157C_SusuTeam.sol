// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface Token {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

    constructor () {
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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./utils/Ownable.sol";
import "./libraries/TransferHelper.sol";
import "./libraries/ReentrancyGuard.sol";
import "./interfaces/IERC20.sol";

contract SusuTeam is Ownable, ReentrancyGuard {
    /* ============= VARIABLE SECTION ============= */

    uint256 public lockedTokens; // Tokens that are locked to a team
    Token public susu; // SUSU token

    /* ============= STRUCT SECTION ============= */

    // Struct contains the lock details
    struct LockDetails {
        uint256 totalTokens;
        uint256 tokensClaimed;
        uint256 vestingPercentage;
        uint32 timeInterval;
        uint32 startTime;
        bool isInitialized;
    }
    mapping(address => LockDetails) public lockData;

    /* ============= EVENT SECTION ============= */

    // Emits when a new lock is added
    event LockAdded(
        address indexed userAddress,
        uint256 totalTokens,
        uint256 tokensClaimed,
        uint256 vestingPercentages,
        uint32 startTime,
        uint32 timeInterval
    );

    // Emits when lock is removed
    event LockRemoved(address indexed userAddress);

    // Emits when tokens are claimed
    event TokensClaimed(address userAddress, uint256 tokensClaimed);

    /* ============= CONSTRUCTOR SECTION ============= */

    constructor(Token _tokenAddress) {
        susu = _tokenAddress;
    }

    /* ============= LOCK SECTION ============= */

    // Function sets a new lock
    function setNewLock(
        address _userAddress,
        uint256 _totalTokens,
        uint256 _vestingPercentage,
        uint32 _startTime,
        uint32 _timeInterval
    ) external onlyOwner {
        require(_userAddress != address(0), "User address cannot be zero");

        require(
            !lockData[_userAddress].isInitialized,
            "The user is already active in another lock."
        );

        require(
            lockedTokens + _totalTokens <= susu.balanceOf(address(this)),
            "Contract doesn't have enough balance to assign."
        );

        require(
            10000 % _vestingPercentage == 0,
            "Vesting percentage should be a multiple of 100."
        );

        // Values are set
        LockDetails memory lock = LockDetails({
            totalTokens: _totalTokens,
            tokensClaimed: 0,
            vestingPercentage: _vestingPercentage,
            timeInterval: _timeInterval,
            startTime: _startTime,
            isInitialized: true
        });
        lockData[_userAddress] = lock;
        lockedTokens += _totalTokens;

        // Emits an event
        emit LockAdded(
            _userAddress,
            _totalTokens,
            0,
            _vestingPercentage,
            _startTime,
            _timeInterval
        );
    }

    // Function removes the lock
    function removeLock(address _userAddress) external onlyOwner {
        LockDetails memory lock = lockData[_userAddress];

        require(lock.isInitialized, "Lock doesn't exist.");

        lockedTokens -= (lock.totalTokens - lock.tokensClaimed);

        // Team is deleted
        delete lockData[_userAddress];

        // Event emits
        emit LockRemoved(_userAddress);
    }

    /* ============= CLAIMING SECTION ============= */

    // Function lets the user to claim the tokens
    function claimTokens() external nonReentrant {
        LockDetails storage lock = lockData[msg.sender];

        require(lock.isInitialized, "Cannot claim.");

        // Returns the tokens available and new counter value
        uint256 _tokensToBeClaimed = calculateTokens(msg.sender);

        require(
            susu.balanceOf(address(this)) >= _tokensToBeClaimed,
            "Contract doesn't have enough tokens."
        );

        lock.tokensClaimed += _tokensToBeClaimed;
        lockedTokens -= _tokensToBeClaimed;

        if (lock.totalTokens == lock.tokensClaimed) lock.isInitialized = false;

        TransferHelper.safeTransfer(
            address(susu),
            msg.sender,
            _tokensToBeClaimed
        );

        // Emits an event
        emit TokensClaimed(msg.sender, lock.tokensClaimed);
    }

    // Internal function calculates token that are available to be claimed
    function calculateTokens(address _userAddress)
        public
        view
        returns (uint256)
    {
        LockDetails memory lock = lockData[_userAddress];
        uint256 _calculatedTokens;

        if (block.timestamp > lock.startTime && lock.isInitialized) {
            // Intervals passed
            uint256 _slots = ((block.timestamp - lock.startTime) /
                lock.timeInterval) + 1;

            // Tokens available
            _calculatedTokens =
                _calculatedTokensInVesting(
                    lock.totalTokens,
                    lock.vestingPercentage
                ) *
                _slots;

            if (_calculatedTokens > lock.totalTokens) {
                _calculatedTokens = lock.totalTokens - lock.tokensClaimed;
            } else {
                _calculatedTokens -= lock.tokensClaimed;
            }
        }

        return _calculatedTokens;
    }

    // Function gives the tokens in 1 vesting
    function _calculatedTokensInVesting(
        uint256 _totalTokens,
        uint256 _vestingPercentage
    ) internal pure returns (uint256) {
        return ((_totalTokens * _vestingPercentage) / 10000);
    }

    /* ============= LEFT OVER SECTION SECTION ============= */

    // Function sends extra tokens back to the owner
    function getLeftoverTokens() external onlyOwner {
        uint256 _contractBalance = susu.balanceOf(address(this));
        require(
            _contractBalance > lockedTokens,
            "No extra tokens in the contract."
        );

        TransferHelper.safeTransfer(
            address(susu),
            msg.sender,
            _contractBalance - lockedTokens
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

abstract contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function _setOwner(address newOwner) internal {
        owner = newOwner;
    }
}