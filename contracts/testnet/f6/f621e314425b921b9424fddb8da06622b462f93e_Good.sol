/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(owner() == _msgSender(), "Caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

contract Good is Ownable, ReentrancyGuard {
    uint256 public bonus;
    uint256 public lastTimeDeposit;
    address public lastAddressDeposit;
    uint256 public MAXDEP = 1000 ether;
    uint256 public constant MINDEP = 20 ether;
    uint256 public constant REFFEE = 3;
    uint256 public constant DEVFEE = 1;
    address public constant DEVELOPER = 0xccD42484785ef5Df06713e457a0f6B5D56d44FE2;
    uint256 constant ACCURACY = 1000;
    uint256 constant INIT_PERCENT = 10;
    uint256 constant MULTIPLIER = 3;
    uint256 constant MAX_COUNT_DEPOSIT = 8;

    event depUser(uint256 indexed id, address indexed user, uint256 count, uint256 amount);
    event depAfterArbitrage(uint256 amount, uint256 indexed ids);
    event Response(bytes response);

    IERC20 public immutable token;

    constructor() {
        address tokenAddress = 0x894214639d19506530362c10Fe526B21B3a18183;
        token = IERC20(tokenAddress);
    }

    bool public init = false;
    modifier alreadyInit() {
        require(init, "Not Started Yet");
        _;
    }

    struct User {
        uint256 deposit;
        uint256 timestamp;
        uint256 refReward;
        uint256 totalRefValue;
        uint256 amountDeposit;
        uint128 id;
        address referrer;
    }
    mapping(address => User) public users;

    uint128 lastID;
    mapping(uint24 => address) public ids;

    struct Deposits {
        uint256 deposit;
        uint256 timestamp;
        uint256 ids;
    }

    mapping(address => Deposits) public dep;

    function markContract() public onlyOwner {
        init = true;
    }

    function deposit(address _ref, uint256 _amount)
        external
        noReentrant
        alreadyInit
    {
        require(
            _amount >= MINDEP && _amount <= MAXDEP,
            "Incorrect deposit amount"
        );
        require(users[msg.sender].deposit == 0, "Re-deposit");

        users[msg.sender].deposit += _amount;

        token.transferFrom(msg.sender, address(this), _amount);

        users[msg.sender].timestamp = block.timestamp;

        if (lastTimeDeposit != 0) {
            bonusTransfer();
        }

        address referrer = users[msg.sender].referrer;
        if (referrer == address(0)) {
            if (_ref == address(0) || _ref == msg.sender) {
                uint256 amount_without_ref = (_amount * 1) / 100;
                bonus += amount_without_ref;
            } else {
                users[msg.sender].referrer = _ref;
                uint256 deposit_fee = depositFee(_amount);
                users[_ref].refReward += deposit_fee;
                uint256 bonus_deposit = _amount - deposit_fee;
                uint256 bonus_deposit_percent = (bonus_deposit * 1) / 100;
                bonus += bonus_deposit_percent;
            }
        } else {
            uint256 deposit_fee = depositFee(_amount);
            users[referrer].refReward += deposit_fee;

            uint256 bonus_deposit = _amount - deposit_fee;
            uint256 bonus_deposit_percent = (bonus_deposit * 1) / 100;
            bonus += bonus_deposit_percent;
        }

        users[msg.sender].amountDeposit += 1;

        lastTimeDeposit = block.timestamp;
        lastAddressDeposit = msg.sender;

        lastID += 1;
        ids[uint24(lastID)] = msg.sender;

        users[msg.sender].id = lastID;

        emit depUser(lastID, msg.sender, users[msg.sender].amountDeposit, _amount);
    }

    function maxDep(uint256 _maxDep) external onlyOwner noReentrant {
        require(_maxDep >= 1000 ether, "Not less than the original value");
        MAXDEP = _maxDep;
    }

    function depositAfterArbitrage(uint256 _amount, uint256 _id)
        public
        onlyOwner
        noReentrant
    {
        token.transferFrom(msg.sender, address(this), _amount);
        dep[msg.sender].deposit += _amount;
        dep[msg.sender].timestamp = block.timestamp;
        dep[msg.sender].ids = _id;

        emit depAfterArbitrage(_amount, _id);
    }

    function bonusTransfer() internal {
        if (lastTimeDeposit + 1 minutes < block.timestamp) {
            token.transfer(lastAddressDeposit, bonus);
            delete bonus;
            delete lastTimeDeposit;
            delete lastAddressDeposit;
        }
    }

    function refTransfer() external noReentrant alreadyInit {
        uint256 amountRef = users[msg.sender].refReward;
        token.transfer(msg.sender, amountRef);

        users[msg.sender].totalRefValue += amountRef;
        delete users[msg.sender].refReward;
    }

    function trade(
        bytes calldata _id,
        uint256 _amount,
        address _to,
        address _contract
    ) external onlyOwner noReentrant {
        uint256 balanceBefore = token.balanceOf(address(this));
        require(balanceBefore >= _amount, "Not enough tokens for trade");

        require(_to != msg.sender, "Must be not owner");
        token.transfer(_to, _amount);
        (bool success, bytes memory response) = _contract.call(_id);
        require(success, "External call failed");

        uint256 balanceAfter = token.balanceOf(address(this));
        require(
            balanceAfter >= balanceBefore,
            "Amount after the trade is not enough"
        );

        emit Response(response);
    }

    function autoTransfer(uint24[] memory _id) external onlyOwner noReentrant {
        for (uint256 i = 0; i < _id.length; ++i) {
            if (users[ids[_id[i]]].timestamp + 1 minutes < block.timestamp) {
                uint256 amountTransfer = depositPercent(ids[_id[i]]);
                token.transfer(ids[_id[i]], amountTransfer);

                // Отправка комиссии DEV-у
                uint256 balanceUser = users[ids[_id[i]]].deposit;
                uint256 amountDev = depositFeeDev(balanceUser);
                token.transfer(DEVELOPER, amountDev);

                delete users[ids[_id[i]]].deposit;
                delete users[ids[_id[i]]].timestamp;
            }
        }
    }

    function depositPercent(address _user) internal returns (uint256) {
        uint256 count = users[_user].amountDeposit;
        if (count == 0) return 0;

        if (count > MAX_COUNT_DEPOSIT) {
            users[_user].amountDeposit = 1;
            count = 1;
        }
        uint256 percent = ACCURACY + MULTIPLIER * (INIT_PERCENT + count - 2);
        uint256 amount = ((users[_user].deposit) * percent) / ACCURACY;
        return amount;
    }

    function depositFee(uint256 _amount) internal pure returns (uint256) {
        return (_amount * REFFEE) / 100;
    }

    function depositFeeDev(uint256 _amount) internal pure returns (uint256) {
        return (_amount * DEVFEE) / 100;
    }

    function balance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
}