// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Timelock {
    uint public constant LOCKPEROID = 180 days;
    uint public constant MONTHLOCK = 18;
    uint public immutable deployed_time;
    address admin;
    address owner;
    IERC20 public CMFX;

    struct Record {
        uint depositTime;
        uint amount;
        uint withdrew;
    }

    mapping(address => Record) public records;

    event Deposited(address _address, uint amount, uint depositeTime); // Event
    event OwnerChange(address _newOwner);
    event AdminChange(address _newAdmin);

    constructor(address _tokenAddress) {
        deployed_time = block.timestamp;
        admin = msg.sender;
        owner = msg.sender;
        CMFX = IERC20(_tokenAddress);
    }

    /**
     * @dev Contract might receive/hold ETH as part of the maintenance process.
     */
    receive() external payable {}

    function deposit(address _address, uint256 _amount) external {
        require(msg.sender == owner, "Only owner can deposite token");
        require(records[_address].amount == 0, "Record already exist");
        uint256 _balance = CMFX.balanceOf(msg.sender);
        require(_balance >= _amount, "Insufficient balance");

        bool success = CMFX.transferFrom(msg.sender,address(this), _amount);
        require(success, "Transfer falied");
        Record memory _record = Record({depositTime: block.timestamp, amount: _amount, withdrew: 0});
        records[_address] = _record;
        emit Deposited(_address, _record.amount, _record.depositTime);
    }

    function balanceOf(address _beneficiary) public view returns (uint256) {
        Record memory _record = records[_beneficiary];
        return _record.amount;
    }

    function withdrawToken() public returns (bool) {
        uint256 _share = percent(msg.sender);
        Record memory _record = records[msg.sender];
        require(_record.amount > 0, "Insufficiant Balance");
        require(_share > 0, "No share to withdraw");

        uint256 _withdrawAble = ((_record.amount * _share) / 100) - _record.withdrew; // round down the withdrawAble
        require(_withdrawAble > 0, "Insufficiant Balance");

        bool success = CMFX.transfer(msg.sender, _withdrawAble);
        require(success, "Unable to withdraw");
        records[msg.sender].withdrew = records[msg.sender].withdrew + _withdrawAble;
        return true;
    }

    function daysSinceStartUnlock(address _beneficiary) public view returns (uint256 _days) {
        Record memory _record = records[_beneficiary];
        require(_record.amount != 0, "Record does not exists!");
        return _daysSinceStartUnlock(_beneficiary);
    }

    function percent(address _beneficiary) public view returns (uint256 _percent) {
        Record memory _record = records[_beneficiary];
        require(_record.amount != 0, "Record does not exists!");
        uint256 _share = _daysSinceStartUnlock(_beneficiary) / 30;
        if (_share > MONTHLOCK) {
            _share = 100;
        }
        return _share;
    }

    function _daysSinceStartUnlock(address _beneficiary) internal view returns (uint256 _days) {
        Record memory _record = records[_beneficiary];
        if (block.timestamp < (_record.depositTime + LOCKPEROID)) {
            return 0;
        }
        return (block.timestamp - (_record.depositTime + LOCKPEROID)) / 1 days;
    }

    function changeOwner(address _newOwner) public returns (bool) {
        require(msg.sender == admin, "Only admin can change owner");
        owner = _newOwner;
        emit OwnerChange(owner);
        return true;
    }

    function changeAdmin(address _newAdmin) public returns (bool) {
        require(msg.sender == admin, "Only admin can change");
        admin = _newAdmin;
        emit AdminChange(admin);
        return true;
    }

    function checkOwner() public view returns (address) {
        return owner;
    }

    function checkAdmin() public view returns (address) {
        return admin;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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