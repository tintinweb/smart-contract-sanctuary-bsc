// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import './IERC20.sol';
import './Ownable.sol';
import './ReentrancyGuard.sol';

contract WithdrawSystem is Ownable, ReentrancyGuard {
    struct Withdraw {
        string id;
        bool enable;
        bool claimed;
        address receiver;
        uint256 amount;
    }

    IERC20 public busdToken;
    mapping(string => Withdraw) _withdraws;

    constructor(address _busdToken) {
        require(_busdToken != address(0), 'zero address');
        busdToken = IERC20(_busdToken);
    }

    function addTransactions(
        string[] memory ids,
        address[] memory addrs,
        uint256[] memory amounts
    ) external nonReentrant onlyOwner {
        require(addrs.length == amounts.length, 'Invalid input');
        require(ids.length == amounts.length, 'Invalid input');

        for (uint256 i = 0; i < ids.length; i++) {
            bytes memory strBytes = bytes(ids[i]);
            if (strBytes.length > 0 && !_withdraws[ids[i]].enable && addrs[i] != address(0) && amounts[i] > 0) {
                _withdraws[ids[i]] = Withdraw(ids[i], true, false, addrs[i], amounts[i]);
            }
        }
    }

    function claim(string memory id) external payable nonReentrant {
        bytes memory strBytes = bytes(id);
        require(strBytes.length > 0, 'Invalid id');

        Withdraw memory withdraw = _withdraws[id];
        require(withdraw.enable, 'Not found');
        require(!withdraw.claimed, 'Already claimed');
        require(msg.sender == withdraw.receiver, 'Forbidden');

        require(busdToken.balanceOf(address(this)) >= withdraw.amount, 'Over amount');

        _withdraws[id].claimed = true;
        require(busdToken.transfer(withdraw.receiver, withdraw.amount));
        emit Claimed(id);
    }

    function setBusdToken(address _busdToken) external onlyOwner {
        require(_busdToken != address(0), 'Zero address');
        busdToken = IERC20(_busdToken);
    }

    function withdrawToken(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(owner(), token.balanceOf(address(this))), 'Failure withdraw');
    }

    function withdrawBnb() external onlyOwner {
        address payable sender = payable(msg.sender);
        sender.transfer(address(this).balance);
    }

    event Claimed(string id);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IERC20 {
    function decimals() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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