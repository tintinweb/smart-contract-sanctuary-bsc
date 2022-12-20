// SPDX-License-Identifier: AGPL-3.0-or-later


pragma solidity ^0.8.0;

interface ERC20Interface {
    function balanceOf(address user) external view returns (uint256);
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeToken {
    function myBalance(address token) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(address(this));
    }

    function balanceOf(address token, address user) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(user);
    }

    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }

    function safeTransferETH(address to, uint256 val) internal {
        (bool success,) = to.call{value : val}(new bytes(0));
        require(success, "!safeTransferETH");
    }
}

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

interface IOwnable {
    function policy() external view returns (address);

    function renounceManagement() external;

    function pushManagement(address newOwner_) external;

    function pullManagement() external;
}

contract Ownable is IOwnable {

    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPushed(address(0), _owner);
    }

    function policy() public view override returns (address) {
        return _owner;
    }

    modifier onlyPolicy() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceManagement() public virtual override onlyPolicy() {
        emit OwnershipPushed(_owner, address(0));
        _owner = address(0);
    }

    function pushManagement(address newOwner_) public virtual override onlyPolicy() {
        require(newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed(_owner, newOwner_);
        _newOwner = newOwner_;
    }

    function pullManagement() public virtual override {
        require(msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled(_owner, _newOwner);
        _owner = _newOwner;
    }
}


interface IgDED {
    function create_lock(address _addr, uint256 _value, uint256 _unlock_time) external;
    function checkpoint() external;

    function increase_amount(address _addr, uint256 _value) external;

    function increase_unlock_time(address _addr, uint256 _unlock_time) external;

}

interface IEdeDistributor {
    function checkpointOtherUser(address _addr) external;
    function getYieldUser(address _addr) external returns (uint256 yield0);
}


interface IRewardRouter {
    function withdrawToEDEPool() external;
}

contract veStakeHelper is Ownable {
    using SafeToken for address;
    using SafeMath for uint256;

    IgDED public gEde;
    IEdeDistributor public distributor_EDE;
    IEdeDistributor public distributor_FEE;
    IRewardRouter public rewardRouter;

    constructor (IgDED _gEde, IEdeDistributor _distributorEDE, IEdeDistributor _distributorFEE, IRewardRouter _rewardRouter) {
        gEde = _gEde;
        distributor_EDE = _distributorEDE;
        distributor_FEE = _distributorFEE;
        rewardRouter = _rewardRouter;
    }

    function create_lock_helper(uint256 _value, uint256 _unlock_time) external {
        gEde.create_lock(msg.sender, _value, _unlock_time);
        gEde.checkpoint();
        distributor_EDE.checkpointOtherUser(msg.sender);
        distributor_FEE.checkpointOtherUser(msg.sender);
        withdrawToEDEPool();
    }

    function increase_amount_helper(uint256 _value) external {
        gEde.increase_amount(msg.sender, _value);
        gEde.checkpoint();
        distributor_EDE.checkpointOtherUser(msg.sender);
        distributor_FEE.checkpointOtherUser(msg.sender);
        withdrawToEDEPool();
    }

    function increase_unlock_time_helper(uint256 _unlock_time) external {
        gEde.increase_unlock_time(msg.sender, _unlock_time);
        distributor_EDE.checkpointOtherUser(msg.sender);
        distributor_FEE.checkpointOtherUser(msg.sender);
        withdrawToEDEPool();
    }

    function getYield_helper() external {
        distributor_EDE.getYieldUser(msg.sender);
        distributor_FEE.getYieldUser(msg.sender);
        withdrawToEDEPool();
    }



    function withdrawToEDEPool() public {
        rewardRouter.withdrawToEDEPool();
    }

    function setRewardRouter(address _rewardRouter) external onlyPolicy {
        rewardRouter = IRewardRouter(_rewardRouter);
    }

}