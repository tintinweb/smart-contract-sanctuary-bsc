/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

pragma solidity 0.7.6;
// SPDX-License-Identifier: GPL-3.0-only

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

contract StakeNativePortal {
    using SafeMath for uint256;

    // Events
    event Stake(
        address staker,
        address stakePool,
        uint256 amount,
        uint8 chainId,
        bytes32 stafiRecipient,
        address destRecipient
    );
    event RecoverStake(bytes32 txHash, bytes32 stafiRecipient);

    uint256 public minAmount;
    uint256 public relayFee;
    address public owner;
    bool public stakeSwitch;

    mapping(address => bool) public stakePoolAddressExist;
    mapping(uint8 => bool) public chainIdExist;
    mapping(uint8 => uint256) public bridgeFee;

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    constructor(
        address[] memory _stakePoolAddressList,
        uint8[] memory _chainIdList,
        uint256 _minAmount,
        uint256 _relayFee
    ) {
        for (uint256 i = 0; i < _stakePoolAddressList.length; i++) {
            stakePoolAddressExist[_stakePoolAddressList[i]] = true;
        }

        for (uint256 i = 0; i < _chainIdList.length; i++) {
            chainIdExist[_chainIdList[i]] = true;
        }

        minAmount = _minAmount;
        relayFee = _relayFee;
        owner = msg.sender;
        stakeSwitch = true;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "new owner is the zero address");
        owner = _newOwner;
    }

    function addStakePool(
        address[] memory _stakePoolAddressList
    ) external onlyOwner {
        for (uint256 i = 0; i < _stakePoolAddressList.length; i++) {
            stakePoolAddressExist[_stakePoolAddressList[i]] = true;
        }
    }

    function rmStakePool(address _stakePoolAddress) external onlyOwner {
        delete stakePoolAddressExist[_stakePoolAddress];
    }

    function addChainId(uint8[] memory _chaindIdList) external onlyOwner {
        for (uint256 i = 0; i < _chaindIdList.length; i++) {
            chainIdExist[_chaindIdList[i]] = true;
        }
    }

    function rmChainId(uint8 _chaindId) external onlyOwner {
        delete chainIdExist[_chaindId];
    }

    function setMinAmount(uint256 _minAmount) external onlyOwner {
        minAmount = _minAmount;
    }

    function setRelayFee(uint256 _relayFee) external onlyOwner {
        relayFee = _relayFee;
    }

    function setBridgeFee(
        uint8 _chainId,
        uint256 _bridgeFee
    ) external onlyOwner {
        require(chainIdExist[_chainId], "chain id not exit");
        bridgeFee[_chainId] = _bridgeFee;
    }

    function toggleSwitch() external onlyOwner {
        stakeSwitch = !stakeSwitch;
    }

    function withdrawFee() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "failed to withdraw");
    }

    function stake(
        address _stakePoolAddress,
        uint256 _amount,
        uint8 _destChainId,
        bytes32 _stafiRecipient,
        address _destRecipient
    ) public payable {
        require(stakeSwitch, "stake not open");
        require(chainIdExist[_destChainId], "dest chain id not exit");
        require(_amount >= minAmount, "amount < minAmount");
        require(
            msg.value >= _amount.add(relayFee).add(bridgeFee[_destChainId]),
            "value not enough"
        );
        require(
            stakePoolAddressExist[_stakePoolAddress],
            "stake pool not exist"
        );
        require(
            _stafiRecipient != bytes32(0) && _destRecipient != address(0),
            "wrong recipient"
        );

        (bool success, ) = _stakePoolAddress.call{value: _amount}("");
        require(success, "transfer failed");

        emit Stake(
            msg.sender,
            _stakePoolAddress,
            _amount,
            _destChainId,
            _stafiRecipient,
            _destRecipient
        );
    }

    function recoverStake(bytes32 _txHash, bytes32 _stafiRecipient) public {
        require(
            _txHash != bytes32(0) && _stafiRecipient != bytes32(0),
            "wrong txHash or recipient"
        );

        emit RecoverStake(_txHash, _stafiRecipient);
    }
}