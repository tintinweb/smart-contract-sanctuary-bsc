// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./lib/IERC20.sol";
import "./lib/Ownable.sol";

interface IAmbassadors {
    function deposit(address, uint256, uint256) external;
    function withdraw(uint256) external;
    function emergencyWithdraw(uint256) external;

    event Deposit(address, uint256, uint256);
    event Withdraw(uint256);
    event EmergencyWithdraw(uint256);
}

contract Ambassadors is IAmbassadors, Ownable {
    address public token;

    struct DepositStruct {
        address wallet;
        uint256 amount;
        uint256 unlockBlock;
        bool status;
    }

    mapping(uint256 => DepositStruct) public deposits;
    uint256 public depositsLength = 0;

    mapping(address => uint256[]) public depositsByWallet;

    constructor(address _token) public {
        token = _token;
    }

    modifier checkDeposit(uint256 id) {
        require(deposits[id].status, 'Deposit is already withdrawn');
        require(deposits[id].wallet == msg.sender, 'Wrong sender');
        require(deposits[id].unlockBlock <= block.number, 'Deposit is locked');
        _;
    }

    function deposit(address wallet, uint256 amount, uint256 unlockBlock) external override {
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        deposits[depositsLength] = DepositStruct(wallet, amount, unlockBlock, true);
        depositsByWallet[wallet].push(depositsLength);
        depositsLength++;

        emit Deposit(wallet, amount, unlockBlock);
    }

    function withdraw(uint256 id) external override checkDeposit(id) {
        deposits[id].status = false;

        IERC20(token).transfer(deposits[id].wallet, deposits[id].amount);
        emit Withdraw(id);
    }

    function emergencyWithdraw(uint256 id) external override onlyOwner {
        deposits[id].status = false;

        IERC20(token).transfer(owner(), deposits[id].amount);
        emit EmergencyWithdraw(id);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./Context.sol";


abstract contract Ownable is Context {
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}