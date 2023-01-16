/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

// SPDX-License-Identifier: UNLICENSED

// File: contracts\libraries\SafeMath.sol

pragma solidity =0.5.16;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts\interfaces\IERC20.sol

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

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

    function mint(address to, uint256 amount) external returns (bool);

    function burn(uint256 amount) external returns (bool);
}

pragma solidity =0.5.16;

contract WexSwap is Ownable {
    using SafeMath for uint256;

    bytes4 private constant SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)")));

    uint256 public reserve;
    address public stableToken;
    address public usdtToken;

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "Pancake: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(SELECTOR, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "Pancake: TRANSFER_FAILED"
        );
    }

    event Buy(address indexed sender, uint256 amount);
    event Sell(address indexed sender, uint256 amount);

    constructor() public {
        stableToken = address(0x1dDa5A10A5fEd668807bD9Bb192095eaE8C36b8e);
        usdtToken = address(0x55d398326f99059fF775485246999027B3197955);
    }

    function buy(address to) external lock {
        require(to != address(this), "Pancake: INVALID_TO");
        uint256 balance = IERC20(usdtToken).balanceOf(address(this));
        uint256 amount = balance.sub(reserve);
        if (amount > 0) {
            IERC20(stableToken).mint(to, amount);
            reserve = balance;
        }
    }

    function sell(address to) external lock {
        require(to != address(this), "Pancake: INVALID_TO");
        uint256 balance = IERC20(stableToken).balanceOf(address(this));
        if (balance > 0) {
            IERC20(stableToken).burn(balance);
            IERC20(usdtToken).transfer(to, balance);

            reserve = IERC20(usdtToken).balanceOf(address(this));
        }
    }

    function removeUSDT(uint256 amount) external lock onlyOwner {
        require(
            amount <= IERC20(usdtToken).balanceOf(address(this)),
            "Pancake: INVALID_AMOUNT"
        );

        IERC20(usdtToken).transfer(msg.sender, amount);
        reserve = IERC20(usdtToken).balanceOf(address(this));
    }

    function recoverLostTokensExceptOurTokens(address _token, uint256 amount)
        public
        onlyOwner
    {
        require(_token != usdtToken, "INVALID_TOKEN");
        IERC20(_token).transfer(msg.sender, amount);
    }
}