// SPDX-License-Identifier: MIT

// COPIED FROM https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/GovernorAlpha.sol
// Copyright 2020 Compound Labs, Inc.
// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Ctrl+f for XXX to see all the modifications.

// XXX: pragma solidity ^0.5.16;
pragma solidity >=0.6.12;

// XXX: import "./SafeMath.sol";
import "../libraries/SafeMath.sol";

contract Timelock {
    using SafeMath for uint;

    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint indexed newDelay);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint eta);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint eta);
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);

    uint public constant GRACE_PERIOD = 14 days;
    uint public constant MINIMUM_DELAY = 6 hours;
    uint public constant MAXIMUM_DELAY = 30 days;

    address public admin;
    address public pendingAdmin;
    uint public delay;
    bool public admin_initialized;

    mapping (bytes32 => bool) public queuedTransactions;


    constructor(address admin_, uint delay_) {
        require(delay_ >= MINIMUM_DELAY, "Timelock::constructor: Delay must exceed minimum delay.");
        require(delay_ <= MAXIMUM_DELAY, "Timelock::constructor: Delay must not exceed maximum delay.");

        admin = admin_;
        delay = delay_;
        admin_initialized = false;
    }

    // XXX: function() external payable { }
    receive() external payable { }

    function setDelay(uint delay_) public {
        require(msg.sender == address(this), "Timelock::setDelay: Call must come from Timelock.");
        require(delay_ >= MINIMUM_DELAY, "Timelock::setDelay: Delay must exceed minimum delay.");
        require(delay_ <= MAXIMUM_DELAY, "Timelock::setDelay: Delay must not exceed maximum delay.");
        delay = delay_;

        emit NewDelay(delay);
    }

    function acceptAdmin() public {
        require(msg.sender == pendingAdmin, "Timelock::acceptAdmin: Call must come from pendingAdmin.");
        admin = msg.sender;
        pendingAdmin = address(0);

        emit NewAdmin(admin);
    }

    function setPendingAdmin(address pendingAdmin_) public {
        // allows one time setting of admin for deployment purposes
        if (admin_initialized) {
            require(msg.sender == address(this), "Timelock::setPendingAdmin: Call must come from Timelock.");
        } else {
            require(msg.sender == admin, "Timelock::setPendingAdmin: First call must come from admin.");
            admin_initialized = true;
        }
        pendingAdmin = pendingAdmin_;

        emit NewPendingAdmin(pendingAdmin);
    }

    function queueTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public returns (bytes32) {
        require(msg.sender == admin, "Timelock::queueTransaction: Call must come from admin.");
        require(eta >= getBlockTimestamp().add(delay), "Timelock::queueTransaction: Estimated execution block must satisfy delay.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, eta);
        return txHash;
    }

    function cancelTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public {
        require(msg.sender == admin, "Timelock::cancelTransaction: Call must come from admin.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }

    function executeTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public payable returns (bytes memory) {
        require(msg.sender == admin, "Timelock::executeTransaction: Call must come from admin.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], "Timelock::executeTransaction: Transaction hasn't been queued.");
        require(getBlockTimestamp() >= eta, "Timelock::executeTransaction: Transaction hasn't surpassed time lock.");
        require(getBlockTimestamp() <= eta.add(GRACE_PERIOD), "Timelock::executeTransaction: Transaction is stale.");

        queuedTransactions[txHash] = false;

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");

        emit ExecuteTransaction(txHash, target, value, signature, data, eta);

        return returnData;
    }

    function getBlockTimestamp() internal view returns (uint) {
        // solium-disable-next-line security/no-block-members
        return block.timestamp;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

import '../core/Timelock.sol';
import './MasterChef.sol';
import '../interfaces/IBEP20.sol';

contract MasterChefTimelock is Timelock {

    mapping(address => bool) public existsPools;
    mapping(address => uint) public pidOfPool;
    mapping(uint256 => bool) public isExcludedPidUpdate;
    MasterChef masterChef;

    struct SetMigratorData {
        address migrator;
        uint timestamp;
        bool exists;
    }
    SetMigratorData setMigratorData;

    struct TransferOwnershipData {
        address newOwner;
        uint timestamp;
        bool exists;
    }
    TransferOwnershipData transferOwnershipData;

    struct TransferBabyTokenOwnershipData {
        address newOwner;
        uint timestamp;
        bool exists;
    }
    TransferBabyTokenOwnershipData transferBabyTokenOwnerShipData;

    struct TransferSyrupTokenOwnershipData {
        address newOwner;
        uint timestamp;
        bool exists;
    }
    TransferSyrupTokenOwnershipData transferSyrupTokenOwnerShipData;

    constructor(MasterChef masterChef_, address admin_, uint delay_) Timelock(admin_, delay_) {
        require(address(masterChef_) != address(0), "illegal masterChef address");
        require(admin_ != address(0), "illegal admin address");
        masterChef = masterChef_;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Timelock::cancelTransaction: Call must come from admin.?");
        _;
    }

    function excludedPidUpdate(uint256 _pid) external onlyAdmin{
        isExcludedPidUpdate[_pid] = true;
    }
    
    function includePidUpdate(uint256 _pid) external onlyAdmin{
        isExcludedPidUpdate[_pid] = false;
    }
    

    function addExistsPools(address pool, uint pid) external onlyAdmin {
        require(existsPools[pool] == false, "Timelock:: pair already exists");
        existsPools[pool] = true;
        pidOfPool[pool] = pid;
    }

    function delExistsPools(address pool) external onlyAdmin {
        require(existsPools[pool] == true, "Timelock:: pair not exists");
        delete existsPools[pool];
        delete pidOfPool[pool];
    }

    function updateMultiplier(uint256 multiplierNumber) external onlyAdmin {
        masterChef.updateMultiplier(multiplierNumber);
    }

    function add(uint256 _allocPoint, IBEP20 _lpToken, bool _withUpdate) external onlyAdmin {
        require(address(_lpToken) != address(0), "_lpToken address cannot be 0");
        require(existsPools[address(_lpToken)] == false, "Timelock:: pair already exists");
        _lpToken.balanceOf(msg.sender);
        uint pid = masterChef.poolLength();
        masterChef.add(_allocPoint, _lpToken, false);
        if(_withUpdate){
            massUpdatePools();
        }
        pidOfPool[address(_lpToken)] = pid;
        existsPools[address(_lpToken)] = true;
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) external onlyAdmin {
        require(_pid < masterChef.poolLength(), 'Pool does not exist');

        masterChef.set(_pid, _allocPoint, false);
        if(_withUpdate){
            massUpdatePools();
        }
    }

    function massUpdatePools() public {
        uint256 length = masterChef.poolLength();
        for (uint256 pid = 0; pid < length; ++pid) {
            if(!isExcludedPidUpdate[pid]){
                masterChef.updatePool(pid);
            }
        }
    }

    function setMigrator(IMigratorChef _migrator) external onlyAdmin {
        require(address(_migrator) != address(0), "_migrator address cannot be 0");
        if (setMigratorData.exists) {
            cancelTransaction(address(masterChef), 0, "", abi.encodeWithSignature("setMigrator(address)", address(_migrator)), setMigratorData.timestamp);
        }
        queueTransaction(address(masterChef), 0, "", abi.encodeWithSignature("setMigrator(address)", address(_migrator)), block.timestamp + delay);
        setMigratorData.migrator = address(_migrator);
        setMigratorData.timestamp = block.timestamp + delay;
        setMigratorData.exists = true;
    }

    function executeSetMigrator() external onlyAdmin {
        require(setMigratorData.exists, "Timelock::setMigrator not prepared");
        executeTransaction(address(masterChef), 0, "", abi.encodeWithSignature("setMigrator(address)", address(setMigratorData.migrator)), setMigratorData.timestamp);
        setMigratorData.migrator = address(0);
        setMigratorData.timestamp = 0;
        setMigratorData.exists = false;
    }
    /*
    function transferBabyTokenOwnerShip(address newOwner_) external onlyAdmin { 
        masterChef.transferBabyTokenOwnerShip(newOwner_);
    }

    function transferSyrupOwnerShip(address newOwner_) external onlyAdmin { 
        masterChef.transferSyrupOwnerShip(newOwner_);
    }
    */

    function transferBabyTokenOwnerShip(address newOwner) external onlyAdmin {
        if (transferBabyTokenOwnerShipData.exists) {
            cancelTransaction(address(masterChef), 0, "", abi.encodeWithSignature("transferBabyTokenOwnerShip(address)", transferBabyTokenOwnerShipData.newOwner), transferBabyTokenOwnerShipData.timestamp);
        }
        queueTransaction(address(masterChef), 0, "", abi.encodeWithSignature("transferBabyTokenOwnerShip(address)", address(newOwner)), block.timestamp + delay);
        transferBabyTokenOwnerShipData.newOwner = newOwner;
        transferBabyTokenOwnerShipData.timestamp = block.timestamp + delay;
        transferBabyTokenOwnerShipData.exists = true;
    }

    function executeTransferBabyOwnership() external onlyAdmin {
        require(transferBabyTokenOwnerShipData.exists, "Timelock::setMigrator not prepared");
        executeTransaction(address(masterChef), 0, "", abi.encodeWithSignature("transferBabyTokenOwnerShip(address)", address(transferBabyTokenOwnerShipData.newOwner)), transferBabyTokenOwnerShipData.timestamp);
        transferBabyTokenOwnerShipData.newOwner = address(0);
        transferBabyTokenOwnerShipData.timestamp = 0;
        transferBabyTokenOwnerShipData.exists = false;
    }

    function transferSyrupTokenOwnerShip(address newOwner) external onlyAdmin {
        if (transferSyrupTokenOwnerShipData.exists) {
            cancelTransaction(address(masterChef), 0, "", abi.encodeWithSignature("transferSyrupOwnerShip(address)", transferSyrupTokenOwnerShipData.newOwner), transferSyrupTokenOwnerShipData.timestamp);
        }
        queueTransaction(address(masterChef), 0, "", abi.encodeWithSignature("transferSyrupOwnerShip(address)", address(newOwner)), block.timestamp + delay);
        transferSyrupTokenOwnerShipData.newOwner = newOwner;
        transferSyrupTokenOwnerShipData.timestamp = block.timestamp + delay;
        transferSyrupTokenOwnerShipData.exists = true;
    }

    function executeTransferSyrupOwnership() external onlyAdmin {
        require(transferSyrupTokenOwnerShipData.exists, "Timelock::setMigrator not prepared");
        executeTransaction(address(masterChef), 0, "", abi.encodeWithSignature("transferSyrupOwnerShip(address)", address(transferSyrupTokenOwnerShipData.newOwner)), transferSyrupTokenOwnerShipData.timestamp);
        transferSyrupTokenOwnerShipData.newOwner = address(0);
        transferSyrupTokenOwnerShipData.timestamp = 0;
        transferSyrupTokenOwnerShipData.exists = false;
    }

    function transferOwnership(address newOwner) external onlyAdmin {
        if (transferOwnershipData.exists) {
            cancelTransaction(address(masterChef), 0, "", abi.encodeWithSignature("transferOwnership(address)", transferOwnershipData.newOwner), transferOwnershipData.timestamp);
        }
        queueTransaction(address(masterChef), 0, "", abi.encodeWithSignature("transferOwnership(address)", address(newOwner)), block.timestamp + delay);
        transferOwnershipData.newOwner = newOwner;
        transferOwnershipData.timestamp = block.timestamp + delay;
        transferOwnershipData.exists = true;
    }

    function executeTransferOwnership() external onlyAdmin {
        require(transferOwnershipData.exists, "Timelock::setMigrator not prepared");
        executeTransaction(address(masterChef), 0, "", abi.encodeWithSignature("transferOwnership(address)", address(transferOwnershipData.newOwner)), transferOwnershipData.timestamp);
        transferOwnershipData.newOwner = address(0);
        transferOwnershipData.timestamp = 0;
        transferOwnershipData.exists = false;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

import '../libraries/SafeMath.sol';
import '../interfaces/IBEP20.sol';
import '../token/SafeBEP20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import "../token/BabyToken.sol";
import "./SyrupBar.sol";

// import "@nomiclabs/buidler/console.sol";

interface IMigratorChef {
    // Perform LP token migration from legacy PancakeSwap to CakeSwap.
    // Take the current LP token address and return the new LP token address.
    // Migrator should have full access to the caller's LP token.
    // Return the new LP token address.
    //
    // XXX Migrator must have allowance access to PancakeSwap LP tokens.
    // CakeSwap must mint EXACTLY the same amount of CakeSwap LP tokens or
    // else something bad will happen. Traditional PancakeSwap does not
    // do that so be careful!
    function migrate(IBEP20 token) external returns (IBEP20);
}

// MasterChef is the master of Cake. He can make Cake and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once CAKE is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of CAKEs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accCakePerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accCakePerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. CAKEs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that CAKEs distribution occurs.
        uint256 accCakePerShare; // Accumulated CAKEs per share, times 1e12. See below.
    }

    // The CAKE TOKEN!
    BabyToken public cake;
    // The SYRUP TOKEN!
    SyrupBar public syrup;
    // CAKE tokens created per block.
    uint256 public cakePerBlock;
    // Bonus muliplier for early cake makers.
    uint256 public BONUS_MULTIPLIER = 1;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigratorChef public migrator;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when CAKE mining starts.
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        BabyToken _cake,
        SyrupBar _syrup,
        uint256 _cakePerBlock,
        uint256 _startBlock
    ) {
        cake = _cake;
        syrup = _syrup;
        cakePerBlock = _cakePerBlock;
        startBlock = _startBlock;

        // staking pool
        poolInfo.push(PoolInfo({
            lpToken: _cake,
            allocPoint: 1000,
            lastRewardBlock: startBlock,
            accCakePerShare: 0
        }));

        totalAllocPoint = 1000;

    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IBEP20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accCakePerShare: 0
        }));
        updateStakingPool();
    }

    // Update the given pool's CAKE allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
            updateStakingPool();
        }
    }

    function updateStakingPool() internal {
        uint256 length = poolInfo.length;
        uint256 points = 0;
        for (uint256 pid = 1; pid < length; ++pid) {
            points = points.add(poolInfo[pid].allocPoint);
        }
        if (points != 0) {
            points = points.div(2);
            totalAllocPoint = totalAllocPoint.sub(poolInfo[0].allocPoint).add(points);
            poolInfo[0].allocPoint = points;
        }
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IBEP20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IBEP20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending CAKEs on frontend.
    function pendingCake(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accCakePerShare = pool.accCakePerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 cakeReward = multiplier.mul(cakePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accCakePerShare = accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }


    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 cakeReward = multiplier.mul(cakePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        cake.mintFor(address(syrup), cakeReward);
        pool.accCakePerShare = pool.accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for CAKE allocation.
    function deposit(uint256 _pid, uint256 _amount) public {

        require (_pid != 0, 'deposit CAKE by staking');

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeCakeTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {

        require (_pid != 0, 'withdraw CAKE by unstaking');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeCakeTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Stake CAKE tokens to MasterChef
    function enterStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeCakeTransfer(msg.sender, pending);
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);

        syrup.mint(msg.sender, _amount);
        emit Deposit(msg.sender, 0, _amount);
    }

    // Withdraw CAKE tokens from STAKING.
    function leaveStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeCakeTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);

        syrup.burn(msg.sender, _amount);
        emit Withdraw(msg.sender, 0, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        if (_pid == 0) {
            syrup.burn(msg.sender, amount);
        }
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Safe cake transfer function, just in case if rounding error causes pool to not have enough CAKEs.
    function safeCakeTransfer(address _to, uint256 _amount) internal {
        syrup.safeCakeTransfer(_to, _amount);
    }

    function transferBabyTokenOwnerShip(address newOwner_) public onlyOwner { 
        require(newOwner_ != address(0), 'illegal address');
        cake.transferOwnership(newOwner_);
    }

    function transferSyrupOwnerShip(address newOwner_) public onlyOwner { 
        require(newOwner_ != address(0), 'illegal address');
        syrup.transferOwnership(newOwner_);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import '../interfaces/IBEP20.sol';
import '../libraries/SafeMath.sol';
import '../libraries/Address.sol';

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >0.6.6;

import "./BEP20.sol";

// CakeToken with Governance.
contract BabyToken is BEP20('BabySwap Token', 'BABY') {
    using SafeMath for uint256;
    uint256 public constant maxSupply = 10 ** 27;
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mintFor(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        require(totalSupply() <= maxSupply, "reach max supply");
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function mint(uint256 amount) public override onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        require(totalSupply() <= maxSupply, "reach max supply");
        return true;
    }

    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    mapping (address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

      /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

   /**
    * @notice Delegate votes from `msg.sender` to `delegatee`
    * @param delegatee The address to delegate votes to
    */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "CAKE::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "CAKE::delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "CAKE::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "CAKE::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying CAKEs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "CAKE::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

import "../token/BEP20.sol";

import "../token/BabyToken.sol";

// SyrupBar with Governance.
contract SyrupBar is BEP20('SyrupBar Token', 'SYRUP') {
    using SafeMath for uint256;
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function burn(address _from ,uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
        _moveDelegates(_delegates[_from], address(0), _amount);
    }

    // The CAKE TOKEN!
    BabyToken public cake;


    constructor(
        BabyToken _cake
    ) {
        cake = _cake;
    }

    // Safe cake transfer function, just in case if rounding error causes pool to not have enough CAKEs.
    function safeCakeTransfer(address _to, uint256 _amount) public onlyOwner {
        uint256 cakeBal = cake.balanceOf(address(this));
        if (_amount > cakeBal) {
            cake.transfer(_to, cakeBal);
        } else {
            cake.transfer(_to, _amount);
        }
    }

    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    mapping (address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

      /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

   /**
    * @notice Delegate votes from `msg.sender` to `delegatee`
    * @param delegatee The address to delegate votes to
    */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "CAKE::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "CAKE::delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "CAKE::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "CAKE::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying CAKEs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "CAKE::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";
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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

import '../interfaces/IBEP20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '../libraries/SafeMath.sol';
import '../libraries/Address.sol';

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-BEP20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of BEP20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
contract BEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token name.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, 'BEP20: transfer amount exceeds allowance')
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, 'BEP20: decreased allowance below zero')
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) public virtual onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');

        _balances[sender] = _balances[sender].sub(amount, 'BEP20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'BEP20: burn amount exceeds balance');
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, 'BEP20: burn amount exceeds allowance')
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

import '../interfaces/IBabyERC20.sol';
import '../libraries/SafeMath.sol';
import './SafeBEP20.sol';
import './BEP20.sol';

contract TokenLocker {
    using SafeMath for uint256;

    ///@notice every block cast 3 seconds
    uint256 public constant SECONDS_PER_BLOCK = 3;

    ///@notice the token to lock
    IBEP20 public immutable token;

    ///@notice who will receive this token
    address public immutable receiver;

    ///@notice the blockNum of last release, the init value would be the timestamp the contract created
    uint256 public lastReleaseAt;

    ///@notice how many block must be passed before next release
    uint256 public immutable interval;

    ///@notice the amount of one release time
    uint256 public immutable releaseAmount;

    ///@notice the total amount till now
    uint256 public totalReleasedAmount;

    constructor(
        address _token, address _receiver, uint256 _intervalSeconds, uint256 _releaseAmount
    ) {
        require(_token != address(0), "illegal token");
        token = IBEP20(_token);
        receiver = _receiver; 
        //lastReleaseAt = block.number;
        require(_intervalSeconds > SECONDS_PER_BLOCK, 'illegal interval');
        uint256 interval_ = _intervalSeconds.add(SECONDS_PER_BLOCK).sub(1).div(SECONDS_PER_BLOCK);
        interval = interval_;
        uint256 lastReleaseAt_ = block.number.sub(interval_);
        lastReleaseAt = lastReleaseAt_;
        require(_releaseAmount > 0, 'illegal releaseAmount');
        releaseAmount = _releaseAmount;
    }

    function getClaimInfo() internal view returns (uint256, uint256) {
        uint currentBlockNum = block.number;
        uint intervalBlockNum = currentBlockNum - lastReleaseAt;
        if (intervalBlockNum < interval) {
            return (0, 0);
        }
        uint times = intervalBlockNum.div(interval);
        uint amount = releaseAmount.mul(times);
        if (token.balanceOf(address(this)) < amount) {
            amount = token.balanceOf(address(this));
        }
        return (amount, times);
    }

    function claim() external {
        (uint amount, uint times) = getClaimInfo();
        if (amount == 0 || times == 0) {
            return;
        }
        lastReleaseAt = lastReleaseAt.add(interval.mul(times));
        totalReleasedAmount = totalReleasedAmount.add(amount);
        SafeBEP20.safeTransfer(token, receiver, amount);
    }

    ///@notice return the amount we can claim now, and the next timestamp we can claim next time
    function lockInfo() external view returns (uint256 amount, uint256 timestamp) {
        (amount, ) = getClaimInfo();
        if (amount == 0) {
            timestamp = block.timestamp.add(interval.sub(block.number.sub(lastReleaseAt)).mul(SECONDS_PER_BLOCK));
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IBabyERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC1155.sol";
import "./IERC1155MetadataURI.sol";
import "./IERC1155Receiver.sol";
import "../../utils/Context.sol";
import "../../introspection/ERC165.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 *
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using SafeMath for uint256;
    using Address for address;

    // Mapping from token ID to account balances
    mapping (uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping (address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /*
     *     bytes4(keccak256('balanceOf(address,uint256)')) == 0x00fdd58e
     *     bytes4(keccak256('balanceOfBatch(address[],uint256[])')) == 0x4e1273f4
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,uint256,bytes)')) == 0xf242432a
     *     bytes4(keccak256('safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)')) == 0x2eb2c2d6
     *
     *     => 0x00fdd58e ^ 0x4e1273f4 ^ 0xa22cb465 ^
     *        0xe985e9c5 ^ 0xf242432a ^ 0x2eb2c2d6 == 0xd9b67a26
     */
    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    /*
     *     bytes4(keccak256('uri(uint256)')) == 0x0e89341c
     */
    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    /**
     * @dev See {_setURI}.
     */
    constructor (string memory uri_) public {
        _setURI(uri_);

        // register the supported interfaces to conform to ERC1155 via ERC165
        _registerInterface(_INTERFACE_ID_ERC1155);

        // register the supported interfaces to conform to ERC1155MetadataURI via ERC165
        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) external view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `account` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] = _balances[id][account].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens of token type `id`.
     */
    function _burn(address account, uint256 id, uint256 amount) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        virtual
    { }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "../../introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../introspection/IERC165.sol";

/**
 * _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {

    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "./IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Enumerable.sol";
import "./IERC721Receiver.sol";
import "../../introspection/ERC165.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";
import "../../utils/EnumerableSet.sol";
import "../../utils/EnumerableMap.sol";
import "../../utils/Strings.sol";

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;

    // Base URI
    string private _baseURI;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c5 ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    /**
    * @dev Returns the base URI set via {_setBaseURI}. This will be
    * automatically added as a prefix in {tokenURI} to each token's URI, or
    * to the token ID if no specific URI is set for that token ID.
    */
    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     d*
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId); // internal owner

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own"); // internal owner
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI},
     * or to the token ID if {tokenURI} is empty.
     */
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId); // internal owner
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */
library EnumerableMap {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        // Storage of map keys and values
        MapEntry[] _entries;

        // Position of the entry defined by a key in the `entries` array, plus 1
        // because index 0 means a key is not in the map.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            // The entry is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)
            // To delete a key-value pair from the _entries array in O(1), we swap the entry to delete with the last one
            // in the array, and then remove the last entry (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;

            // When the entry to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            MapEntry storage lastEntry = map._entries[lastIndex];

            // Move the last entry to the index where the entry to delete is
            map._entries[toDeleteIndex] = lastEntry;
            // Update the index for the moved entry
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved entry was stored
            map._entries.pop();

            // Delete the index for the deleted slot
            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

   /**
    * @dev Returns the key-value pair stored at position `index` in the map. O(1).
    *
    * Note that there are no guarantees on the ordering of entries inside the
    * array, and it may change when more entries are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

   /**
    * @dev Returns the element stored at position `index` in the set. O(1).
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` representation.
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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "../../introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

import '@openzeppelin/contracts/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import '../interfaces/IERC721Mintable.sol';
import '../libraries/TransferHelper.sol';
import '../interfaces/IWETH.sol';

contract RewardClaim is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event NewRewardToken(IERC20 oldRewardToken, IERC20 newRewardToken);
    event NewVault(address oldVault, address newVault);
    event NewDispatcher(address oldDispatcher, address newDispatcher);
    event NewVerifier(address oldVerifier, address newVerifier);
    event NewCaller(address oldCaller, address newCaller);
    event NewDispatchReward(address from, address to, uint amount);
    event NewErc20ClaimAmount(uint loop, address user, address token, uint amount);
    event NewErc721ClaimAmount(uint loop, address user, address token, uint tokenId, bool claimed);
    event NewErc1155ClaimAmount(uint loop, address user, address token, uint tokenId, uint amount);
    event ClaimFlag(uint loop, bool flag);

    address public vault;
    address public verifier;
    mapping(uint => bool) public claimDisabled;
    //loop->user->token => amount
    mapping(uint => mapping(address => mapping(address => uint))) public erc20Claimed;
    //loop->user->token->tokenId=>claimed
    mapping(uint => mapping(address => mapping(address => mapping(uint => bool)))) public erc721Claimed;
    //loop->user->token->tokenId=>amount
    mapping(uint => mapping(address => mapping(address => mapping(uint => uint)))) public erc1155Claimed;
    IWETH immutable public WETH;
    mapping(address => bool) public mintContract;

    enum TokenType{
        ERC20,
        ERC721,
        ERC1155
    }

    function setMintContract(address _contract) external onlyOwner {
        mintContract[_contract] = true;
    }

    function delMintContract(address _contract) external onlyOwner {
        delete mintContract[_contract];
    }

    function setVault(address _vault) external onlyOwner {
        emit NewVault(vault, _vault);
        vault = _vault;
    }

    function setVerifier(address _verifier) external onlyOwner {
        emit NewVerifier(verifier, _verifier);
        verifier = _verifier;
    }

    function claimDisable(uint _loop) external onlyOwner {
        claimDisabled[_loop] = true;
        emit ClaimFlag(_loop, true);
    }

    function claimEnable(uint _loop) external onlyOwner {
        delete claimDisabled[_loop];
        emit ClaimFlag(_loop, false);
    }

    function setUserErc20Claimed(uint _loop, address _user, address _token, uint _amount) external onlyOwner {
        erc20Claimed[_loop][_user][_token] = _amount;
        emit NewErc20ClaimAmount(_loop, _user, _token, _amount);
    }

    function setUserErc721Claimed(uint _loop, address _user, address _token, uint _tokenId, bool _claimed) external onlyOwner {
        if (_claimed) {
            erc721Claimed[_loop][_user][_token][_tokenId] = true; 
        } else {
            delete erc721Claimed[_loop][_user][_token][_tokenId];
        }
        emit NewErc721ClaimAmount(_loop, _user, _token, _tokenId, _claimed);
    }

    function setUserErc1155Claimed(uint _loop, address _user, address _token, uint _tokenId, uint _amount) external onlyOwner {
        erc1155Claimed[_loop][_user][_token][_tokenId] = _amount;
        emit NewErc1155ClaimAmount(_loop, _user, _token, _tokenId, _amount);
    }

    constructor(address _vault, address _verifier, address _WETH) {
        emit NewVault(vault, _vault);
        vault = _vault;
        emit NewVerifier(verifier, _verifier);
        verifier = _verifier;
        WETH = IWETH(_WETH);
    }

    function getEncodePacked(uint _loop, address _contract, address _token, uint _type, address _user, uint _tokenId, uint _amount, uint _timestamp) public pure returns (bytes memory) {
        return abi.encodePacked(_loop, _contract, _token, _type, _user, _tokenId, _amount, _timestamp);
    }

    function getHash(uint _loop, address _contract, address _token, uint _type, address _user, uint _tokenId, uint _amount, uint _timestamp) public pure returns (bytes32) {
        return keccak256(getEncodePacked(_loop, _contract, _token, _type, _user, _tokenId, _amount, _timestamp));
    }

    function getHashToSign(uint _loop, address _contract, address _token, uint _type, address _user, uint _tokenId, uint _amount, uint _timestamp) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", getHash(_loop, _contract, _token, _type, _user, _tokenId, _amount, _timestamp)));
    }

    function verify(uint _loop, address _contract, address _token, uint _type, address _user, uint _tokenId, uint _amount, uint _timestamp, uint8 _v, bytes32 _r, bytes32 _s) public view returns (bool) {
        return ecrecover(getHashToSign(_loop, _contract, _token, _type, _user, _tokenId, _amount, _timestamp), _v, _r, _s) == verifier;
    }

    function claimErc20(uint _loop, address _token, address _user, uint _amount) internal {
        _amount = _amount.sub(erc20Claimed[_loop][_user][_token]);
        erc20Claimed[_loop][_user][_token] = erc20Claimed[_loop][_user][_token].add(_amount);
        if (_amount > 0) {
            if (_token == address(WETH)) {
                SafeERC20.safeTransferFrom(IERC20(_token), vault, address(this), _amount);
                WETH.withdraw(_amount);
                TransferHelper.safeTransferETH(_user, _amount);
            } else {
                SafeERC20.safeTransferFrom(IERC20(_token), vault, _user, _amount);
            }
        }
    }

    function claimErc721(uint _loop, address _token, address _user, uint _tokenId) internal {
        if (!erc721Claimed[_loop][_user][_token][_tokenId]) {
            erc721Claimed[_loop][_user][_token][_tokenId] = true;
            if (!mintContract[_token]) {
                IERC721(_token).safeTransferFrom(vault, _user, _tokenId);
            } else {
                IERC721Mintable(_token).mint(_user, _tokenId);
            }
        }
    }

    function claimErc1155(uint _loop, address _token, address _user, uint _tokenId, uint _amount) internal {
        _amount = _amount.sub(erc1155Claimed[_loop][_user][_token][_tokenId]);
        erc1155Claimed[_loop][_user][_token][_tokenId] = erc1155Claimed[_loop][_user][_token][_tokenId].add(_amount);
        if (_amount > 0) {
            IERC1155(_token).safeTransferFrom(vault, _user, _tokenId, _amount, new bytes(0));
        }
    }

    function claim(uint _loop, address _contract, address _token, uint _type, address _user, uint _tokenId, uint _amount, uint _timestamp, uint8 _v, bytes32 _r, bytes32 _s) external {
        require(!claimDisabled[_loop], "loop already finish");
        require(_contract == address(this), "illegal target");
        require(_timestamp > block.timestamp, "signature expired");
        require(verify(_loop, _contract, _token, _type, _user, _tokenId, _amount, _timestamp, _v, _r, _s), "signature illegal");
        if (TokenType(_type) ==TokenType.ERC20) {
            claimErc20(_loop, _token, _user, _amount);
        } else if (TokenType(_type) == TokenType.ERC721) {
            claimErc721(_loop, _token, _user, _tokenId);
        } else if (TokenType(_type) == TokenType.ERC1155) {
            claimErc1155(_loop, _token, _user, _tokenId, _amount);
        } else {
            revert("illegal type");
        }
    }

    function transferContractOwnership(address _contract, address _to) external onlyOwner {
        Ownable(_contract).transferOwnership(_to);
    }

    receive () external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IERC721Mintable {
    function mint(address to, uint256 tokenId) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.4;

import "@openzeppelin/contracts/proxy/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/IMarketFeeManager.sol";
import "../interfaces/IWETH.sol";
import "../token/VBabyToken.sol";

contract MarketFeeDispatcher is Ownable, Initializable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    uint constant public PERCENT_RATIO = 1e6;

    IMarketFeeManager public manager;
    mapping(address => bool) public callers;
    address public receiver;
    uint public percent;
    IWETH public WETH;

    function initialize(address _manager, IWETH _WETH, address _receiver, uint _percent) external initializer onlyOwner {
        WETH = _WETH;
        manager = IMarketFeeManager(_manager);
        receiver = _receiver;
        percent = _percent;
        callers[_manager] = true;
    }

    function addCaller(address _caller) external onlyOwner {
        callers[_caller] = true;
    }

    function delCaller(address _caller) external onlyOwner {
        delete callers[_caller];
    }

    modifier onlyOwnerOrCaller() {
        require(msg.sender == owner() || callers[msg.sender], "illegal operator");
        _;
    }

    function getBalance(IERC20 _token) internal returns(uint) {
        if (address(_token) == address(WETH)) {
            uint balance = _token.balanceOf(address(this));
            WETH.withdraw(balance);
            return address(this).balance;
        } else {
            return _token.balanceOf(address(this));
        }
         
    }

    function transfer(IERC20 _token, address _to, uint _amount) internal {
        if (address(_token) == address(WETH)) {
            _to.call{value:_amount}(new bytes(0));
        } else {
            _token.safeTransfer(_to, _amount);
        }
    }

    function dispatch(IERC20[] memory tokens) external onlyOwnerOrCaller {
        for (uint i = 0; i < tokens.length; i ++) {
            IERC20 token = tokens[i];
            uint balance = getBalance(token);
            uint dispatchAmount = balance.mul(percent).div(PERCENT_RATIO);
            uint remainAmount = balance.sub(dispatchAmount);
            if (dispatchAmount > 0) {
                transfer(token, receiver, dispatchAmount);
            }
            if (remainAmount > 0) {
                transfer(token, address(manager), remainAmount);
            }
        }
    }

    function withdraw(IERC20[] memory tokens) external onlyOwnerOrCaller {
        for (uint i = 0; i < tokens.length; i ++) {
            IERC20 token = tokens[i];
            uint balance = getBalance(token);
            if (balance > 0) {
                transfer(token, address(manager), balance);
            }
        }
    }

    function setPercent(uint _percent) external onlyOwnerOrCaller {
        require(_percent <= PERCENT_RATIO, "illegal _percent value");
        percent = _percent;
    }

    receive () external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IMarketFeeManager {
}

// SPDX-License-Identifier: MIT

pragma solidity =0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/DecimalMath.sol";

contract vBABYToken is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Storage(ERC20) ============

    string public name = "vBABY Membership Token";
    string public symbol = "vBABY";
    uint8 public decimals = 18;

    mapping(address => mapping(address => uint256)) internal _allowed;

    // ============ Storage ============

    address public _babyToken;
    address public _babyTeam;
    address public _babyReserve;
    address public _babyTreasury;
    bool public _canTransfer;
    address public constant hole = 0x000000000000000000000000000000000000dEaD;

    // staking reward parameters
    uint256 public _babyPerBlock;
    uint256 public constant _superiorRatio = 10**17; // 0.1
    uint256 public constant _babyRatio = 100; // 100
    uint256 public _babyFeeBurnRatio = 30 * 10**16; //30%
    uint256 public _babyFeeReserveRatio = 20 * 10**16; //20%
    uint256 public _feeRatio = 10 * 10**16; //10%;
    // accounting
    uint112 public alpha = 10**18; // 1
    uint112 public _totalBlockDistribution;
    uint32 public _lastRewardBlock;

    uint256 public _totalBlockReward;
    uint256 public _totalStakingPower;
    mapping(address => UserInfo) public userInfo;

    uint256 public _superiorMinBABY = 100e18; //The superior must obtain the min BABY that should be pledged for invitation rewards

    struct UserInfo {
        uint128 stakingPower;
        uint128 superiorSP;
        address superior;
        uint256 credit;
        uint256 creditDebt;
    }

    // ============ Events ============

    event MintVBABY(
        address user,
        address superior,
        uint256 mintBABY,
        uint256 totalStakingPower
    );
    event RedeemVBABY(
        address user,
        uint256 receiveBABY,
        uint256 burnBABY,
        uint256 feeBABY,
        uint256 reserveBABY,
        uint256 totalStakingPower
    );
    event DonateBABY(address user, uint256 donateBABY);
    event SetCanTransfer(bool allowed);

    event PreDeposit(uint256 babyAmount);
    event ChangePerReward(uint256 babyPerBlock);
    event UpdateBABYFeeBurnRatio(uint256 babyFeeBurnRatio);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    // ============ Modifiers ============

    modifier canTransfer() {
        require(_canTransfer, "vBABYToken: not the allowed transfer");
        _;
    }

    modifier balanceEnough(address account, uint256 amount) {
        require(
            availableBalanceOf(account) >= amount,
            "vBABYToken: available amount not enough"
        );
        _;
    }

    event TokenInfo(uint256 babyTokenSupply, uint256 babyBalanceInVBaby);
    event CurrentUserInfo(
        address user,
        uint128 stakingPower,
        uint128 superiorSP,
        address superior,
        uint256 credit,
        uint256 creditDebt
    );

    function logTokenInfo(IERC20 token) internal {
        emit TokenInfo(token.totalSupply(), token.balanceOf(address(this)));
    }

    function logCurrentUserInfo(address user) internal {
        UserInfo storage currentUser = userInfo[user];
        emit CurrentUserInfo(
            user,
            currentUser.stakingPower,
            currentUser.superiorSP,
            currentUser.superior,
            currentUser.credit,
            currentUser.creditDebt
        );
    }

    // ============ Constructor ============

    constructor(
        address babyToken,
        address babyTeam,
        address babyReserve,
        address babyTreasury
    ) {
        _babyToken = babyToken;
        _babyTeam = babyTeam;
        _babyReserve = babyReserve;
        _babyTreasury = babyTreasury;
        changePerReward(2 * 10**18);
    }

    // ============ Ownable Functions ============`

    function setCanTransfer(bool allowed) public onlyOwner {
        _canTransfer = allowed;
        emit SetCanTransfer(allowed);
    }

    function changePerReward(uint256 babyPerBlock) public onlyOwner {
        _updateAlpha();
        _babyPerBlock = babyPerBlock;
        logTokenInfo(IERC20(_babyToken));
        emit ChangePerReward(babyPerBlock);
    }

    function updateBABYFeeBurnRatio(uint256 babyFeeBurnRatio) public onlyOwner {
        _babyFeeBurnRatio = babyFeeBurnRatio;
        emit UpdateBABYFeeBurnRatio(_babyFeeBurnRatio);
    }

    function updateBABYFeeReserveRatio(uint256 babyFeeReserve)
        public
        onlyOwner
    {
        _babyFeeReserveRatio = babyFeeReserve;
    }

    function updateTeamAddress(address team) public onlyOwner {
        _babyTeam = team;
    }

    function updateTreasuryAddress(address treasury) public onlyOwner {
        _babyTreasury = treasury;
    }

    function updateReserveAddress(address newAddress) public onlyOwner {
        _babyReserve = newAddress;
    }

    function setSuperiorMinBABY(uint256 val) public onlyOwner {
        _superiorMinBABY = val;
    }

    function emergencyWithdraw() public onlyOwner {
        uint256 babyBalance = IERC20(_babyToken).balanceOf(address(this));
        IERC20(_babyToken).safeTransfer(owner(), babyBalance);
    }

    // ============ Mint & Redeem & Donate ============

    function mint(uint256 babyAmount, address superiorAddress) public {
        require(
            superiorAddress != address(0) && superiorAddress != msg.sender,
            "vBABYToken: Superior INVALID"
        );
        require(babyAmount >= 1e18, "vBABYToken: must mint greater than 1");

        UserInfo storage user = userInfo[msg.sender];

        if (user.superior == address(0)) {
            require(
                superiorAddress == _babyTeam ||
                    userInfo[superiorAddress].superior != address(0),
                "vBABYToken: INVALID_SUPERIOR_ADDRESS"
            );
            user.superior = superiorAddress;
        }

        if (_superiorMinBABY > 0) {
            uint256 curBABY = babyBalanceOf(user.superior);
            if (curBABY < _superiorMinBABY) {
                user.superior = _babyTeam;
            }
        }

        _updateAlpha();

        IERC20(_babyToken).safeTransferFrom(
            msg.sender,
            address(this),
            babyAmount
        );

        uint256 newStakingPower = DecimalMath.divFloor(babyAmount, alpha);

        _mint(user, newStakingPower);

        logTokenInfo(IERC20(_babyToken));
        logCurrentUserInfo(msg.sender);
        logCurrentUserInfo(user.superior);
        emit MintVBABY(
            msg.sender,
            superiorAddress,
            babyAmount,
            _totalStakingPower
        );
    }

    function redeem(uint256 vBabyAmount, bool all)
        public
        balanceEnough(msg.sender, vBabyAmount)
    {
        _updateAlpha();
        UserInfo storage user = userInfo[msg.sender];

        uint256 babyAmount;
        uint256 stakingPower;

        if (all) {
            stakingPower = uint256(user.stakingPower).sub(
                DecimalMath.divFloor(user.credit, alpha)
            );
            babyAmount = DecimalMath.mulFloor(stakingPower, alpha);
        } else {
            babyAmount = vBabyAmount.mul(_babyRatio);
            stakingPower = DecimalMath.divFloor(babyAmount, alpha);
        }

        _redeem(user, stakingPower);

        (
            uint256 babyReceive,
            uint256 burnBabyAmount,
            uint256 withdrawFeeAmount,
            uint256 reserveAmount
        ) = getWithdrawResult(babyAmount);

        IERC20(_babyToken).safeTransfer(msg.sender, babyReceive);

        if (burnBabyAmount > 0) {
            IERC20(_babyToken).safeTransfer(hole, burnBabyAmount);
        }
        if (reserveAmount > 0) {
            IERC20(_babyToken).safeTransfer(_babyReserve, reserveAmount);
        }

        if (withdrawFeeAmount > 0) {
            alpha = uint112(
                uint256(alpha).add(
                    DecimalMath.divFloor(withdrawFeeAmount, _totalStakingPower)
                )
            );
        }

        logTokenInfo(IERC20(_babyToken));
        logCurrentUserInfo(msg.sender);
        logCurrentUserInfo(user.superior);
        emit RedeemVBABY(
            msg.sender,
            babyReceive,
            burnBabyAmount,
            withdrawFeeAmount,
            reserveAmount,
            _totalStakingPower
        );
    }

    function donate(uint256 babyAmount) public {
        IERC20(_babyToken).safeTransferFrom(
            msg.sender,
            address(this),
            babyAmount
        );

        alpha = uint112(
            uint256(alpha).add(
                DecimalMath.divFloor(babyAmount, _totalStakingPower)
            )
        );
        logTokenInfo(IERC20(_babyToken));
        emit DonateBABY(msg.sender, babyAmount);
    }

    function totalSupply() public view returns (uint256 vBabySupply) {
        uint256 totalBaby = IERC20(_babyToken).balanceOf(address(this));
        (, uint256 curDistribution) = getLatestAlpha();

        uint256 actualBaby = totalBaby.add(curDistribution);
        vBabySupply = actualBaby / _babyRatio;
    }

    function balanceOf(address account)
        public
        view
        returns (uint256 vBabyAmount)
    {
        vBabyAmount = babyBalanceOf(account) / _babyRatio;
    }

    function transfer(address to, uint256 vBabyAmount) public returns (bool) {
        _updateAlpha();
        _transfer(msg.sender, to, vBabyAmount);
        return true;
    }

    function approve(address spender, uint256 vBabyAmount)
        public
        canTransfer
        returns (bool)
    {
        _allowed[msg.sender][spender] = vBabyAmount;
        emit Approval(msg.sender, spender, vBabyAmount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 vBabyAmount
    ) public returns (bool) {
        require(
            vBabyAmount <= _allowed[from][msg.sender],
            "ALLOWANCE_NOT_ENOUGH"
        );
        _updateAlpha();
        _transfer(from, to, vBabyAmount);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(
            vBabyAmount
        );
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowed[owner][spender];
    }

    // ============ Helper Functions ============

    function getLatestAlpha()
        public
        view
        returns (uint256 newAlpha, uint256 curDistribution)
    {
        if (_lastRewardBlock == 0) {
            curDistribution = 0;
        } else {
            curDistribution = _babyPerBlock * (block.number - _lastRewardBlock);
        }
        if (_totalStakingPower > 0) {
            newAlpha = uint256(alpha).add(
                DecimalMath.divFloor(curDistribution, _totalStakingPower)
            );
        } else {
            newAlpha = alpha;
        }
    }

    function availableBalanceOf(address account)
        public
        view
        returns (uint256 vBabyAmount)
    {
        vBabyAmount = balanceOf(account);
    }

    function babyBalanceOf(address account)
        public
        view
        returns (uint256 babyAmount)
    {
        UserInfo memory user = userInfo[account];
        (uint256 newAlpha, ) = getLatestAlpha();
        uint256 nominalBaby = DecimalMath.mulFloor(
            uint256(user.stakingPower),
            newAlpha
        );
        if (nominalBaby > user.credit) {
            babyAmount = nominalBaby - user.credit;
        } else {
            babyAmount = 0;
        }
    }

    function getWithdrawResult(uint256 babyAmount)
        public
        view
        returns (
            uint256 babyReceive,
            uint256 burnBabyAmount,
            uint256 withdrawFeeBabyAmount,
            uint256 reserveBabyAmount
        )
    {
        uint256 feeRatio = _feeRatio;

        withdrawFeeBabyAmount = DecimalMath.mulFloor(babyAmount, feeRatio);
        babyReceive = babyAmount.sub(withdrawFeeBabyAmount);

        burnBabyAmount = DecimalMath.mulFloor(
            withdrawFeeBabyAmount,
            _babyFeeBurnRatio
        );
        reserveBabyAmount = DecimalMath.mulFloor(
            withdrawFeeBabyAmount,
            _babyFeeReserveRatio
        );

        withdrawFeeBabyAmount = withdrawFeeBabyAmount.sub(burnBabyAmount);
        withdrawFeeBabyAmount = withdrawFeeBabyAmount.sub(reserveBabyAmount);
    }

    function setRatioValue(uint256 ratioFee) public onlyOwner {
        _feeRatio = ratioFee;
    }

    function getSuperior(address account)
        public
        view
        returns (address superior)
    {
        return userInfo[account].superior;
    }

    // ============ Internal Functions ============

    function _updateAlpha() internal {
        (uint256 newAlpha, uint256 curDistribution) = getLatestAlpha();
        uint256 newTotalDistribution = curDistribution.add(
            _totalBlockDistribution
        );
        require(
            newAlpha <= uint112(-1) && newTotalDistribution <= uint112(-1),
            "OVERFLOW"
        );
        alpha = uint112(newAlpha);
        _totalBlockDistribution = uint112(newTotalDistribution);
        _lastRewardBlock = uint32(block.number);

        if (curDistribution > 0) {
            IERC20(_babyToken).safeTransferFrom(
                _babyTreasury,
                address(this),
                curDistribution
            );

            _totalBlockReward = _totalBlockReward.add(curDistribution);
            logTokenInfo(IERC20(_babyToken));
            emit PreDeposit(curDistribution);
        }
    }

    function _mint(UserInfo storage to, uint256 stakingPower) internal {
        require(stakingPower <= uint128(-1), "OVERFLOW");
        UserInfo storage superior = userInfo[to.superior];
        uint256 superiorIncreSP = DecimalMath.mulFloor(
            stakingPower,
            _superiorRatio
        );
        uint256 superiorIncreCredit = DecimalMath.mulFloor(
            superiorIncreSP,
            alpha
        );

        to.stakingPower = uint128(uint256(to.stakingPower).add(stakingPower));
        to.superiorSP = uint128(uint256(to.superiorSP).add(superiorIncreSP));

        superior.stakingPower = uint128(
            uint256(superior.stakingPower).add(superiorIncreSP)
        );
        superior.credit = uint128(
            uint256(superior.credit).add(superiorIncreCredit)
        );

        _totalStakingPower = _totalStakingPower.add(stakingPower).add(
            superiorIncreSP
        );
    }

    function _redeem(UserInfo storage from, uint256 stakingPower) internal {
        from.stakingPower = uint128(
            uint256(from.stakingPower).sub(stakingPower)
        );

        uint256 userCreditSP = DecimalMath.divFloor(from.credit, alpha);
        if (from.stakingPower > userCreditSP) {
            from.stakingPower = uint128(
                uint256(from.stakingPower).sub(userCreditSP)
            );
        } else {
            userCreditSP = from.stakingPower;
            from.stakingPower = 0;
        }
        from.creditDebt = from.creditDebt.add(from.credit);
        from.credit = 0;

        // superior decrease sp = min(stakingPower*0.1, from.superiorSP)
        uint256 superiorDecreSP = DecimalMath.mulFloor(
            stakingPower,
            _superiorRatio
        );
        superiorDecreSP = from.superiorSP <= superiorDecreSP
            ? from.superiorSP
            : superiorDecreSP;
        from.superiorSP = uint128(
            uint256(from.superiorSP).sub(superiorDecreSP)
        );
        uint256 superiorDecreCredit = DecimalMath.mulFloor(
            superiorDecreSP,
            alpha
        );

        UserInfo storage superior = userInfo[from.superior];
        if (superiorDecreCredit > superior.creditDebt) {
            uint256 dec = DecimalMath.divFloor(superior.creditDebt, alpha);
            superiorDecreSP = dec >= superiorDecreSP
                ? 0
                : superiorDecreSP.sub(dec);
            superiorDecreCredit = superiorDecreCredit.sub(superior.creditDebt);
            superior.creditDebt = 0;
        } else {
            superior.creditDebt = superior.creditDebt.sub(superiorDecreCredit);
            superiorDecreCredit = 0;
            superiorDecreSP = 0;
        }
        uint256 creditSP = DecimalMath.divFloor(superior.credit, alpha);

        if (superiorDecreSP >= creditSP) {
            superior.credit = 0;
            superior.stakingPower = uint128(
                uint256(superior.stakingPower).sub(creditSP)
            );
        } else {
            superior.credit = uint128(
                uint256(superior.credit).sub(superiorDecreCredit)
            );
            superior.stakingPower = uint128(
                uint256(superior.stakingPower).sub(superiorDecreSP)
            );
        }

        _totalStakingPower = _totalStakingPower
            .sub(stakingPower)
            .sub(superiorDecreSP)
            .sub(userCreditSP);
    }

    function _transfer(
        address from,
        address to,
        uint256 vBabyAmount
    ) internal canTransfer balanceEnough(from, vBabyAmount) {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(from != to, "transfer from same with to");

        uint256 stakingPower = DecimalMath.divFloor(
            vBabyAmount * _babyRatio,
            alpha
        );

        UserInfo storage fromUser = userInfo[from];
        UserInfo storage toUser = userInfo[to];

        _redeem(fromUser, stakingPower);
        _mint(toUser, stakingPower);

        logTokenInfo(IERC20(_babyToken));
        logCurrentUserInfo(from);
        logCurrentUserInfo(fromUser.superior);
        logCurrentUserInfo(to);
        logCurrentUserInfo(toUser.superior);
        emit Transfer(from, to, vBabyAmount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

library MySafeMath {
    using SafeMath for uint256;

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = a.div(b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }
}

library DecimalMath {
    using SafeMath for uint256;

    uint256 internal constant ONE = 10**18;
    uint256 internal constant ONE2 = 10**36;

    function mulFloor(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(d) / (10**18);
    }

    function mulCeil(uint256 target, uint256 d) internal pure returns (uint256) {
        return MySafeMath.divCeil(target.mul(d), 10**18);
    }

    function divFloor(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(10**18).div(d);
    }

    function divCeil(uint256 target, uint256 d) internal pure returns (uint256) {
        return MySafeMath.divCeil(target.mul(10**18), d);
    }

    function reciprocalFloor(uint256 target) internal pure returns (uint256) {
        return uint256(10**36).div(target);
    }

    function reciprocalCeil(uint256 target) internal pure returns (uint256) {
        return MySafeMath.divCeil(uint256(10**36), target);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.4;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/IMarketFeeDispatcher.sol";
import "../interfaces/IBabyRouter.sol";
import "./MarketFeeDispatcher.sol";
import "../interfaces/IWETH.sol";
import "../token/VBabyToken.sol";

contract MarketFeeManager is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    uint constant public PERCENT_RATIO = 1e6;
    IBabyRouter immutable public router;

    bytes32 public INIT_CODE_HASH = keccak256(type(MarketFeeDispatcher).creationCode);

    IERC20[] public tokens;
    mapping(address => IMarketFeeDispatcher) public dispatchers;
    IMarketFeeDispatcher[] public dispatcherList;
    mapping(IMarketFeeDispatcher => bool) public dispatcherBlacklist;
    mapping(address => uint) public receiverPercent;
    mapping(address => IERC20) public receiverToken;
    address[] public receivers;
    address public ownerReceiver;
    IWETH public WETH;
    mapping(address => bool) public callers;

    function addCaller(address _caller) external onlyOwner {
        callers[_caller] = true;
    }

    function delCaller(address _caller) external onlyOwner {
        delete callers[_caller];
    }

    modifier onlyOwnerOrCaller() {
        require(msg.sender == owner() || callers[msg.sender], "illegal operator");
        _;
    }
    
    function addToken(IERC20 _token) external onlyOwner {
        tokens.push(_token);
    }

    function delToken(IERC20 _token) external onlyOwner {
        require(tokens.length > 0, "illegal token");
        uint index = 0;
        for (; index < tokens.length; index ++) {
            if (tokens[index] == _token) {
                break;
            }
        }
        require(index < tokens.length, "token not exists");
        if (index < tokens.length - 1) {
            tokens[index] = tokens[tokens.length - 1];
        }
        tokens.pop();
    }

    function tokenLength() external view returns (uint) {
        return tokens.length;
    }

    function addDispatcherBlacklist(address _receiver) external onlyOwner {
        require(address(dispatchers[_receiver]) != address(0), "not exist");
        IMarketFeeDispatcher dispatcher = dispatchers[_receiver];
        require(!dispatcherBlacklist[dispatcher], "already in blacklist");
        dispatcherBlacklist[dispatcher] = true;
    }

    function delDispatcherBlacklist(address _receiver) external onlyOwner {
        require(address(dispatchers[_receiver]) != address(0), "not exist");
        IMarketFeeDispatcher dispatcher = dispatchers[_receiver];
        require(dispatcherBlacklist[dispatcher], "not in blacklist");
        delete dispatcherBlacklist[dispatcher];
    }

    function addReceiver(address _receiver, uint _percent, IERC20 _receiverToken) external onlyOwner {
        require(_receiver != address(0), "illegal receiver");
        require(receiverPercent[_receiver] == 0, "receiver already exists");
        require(_percent > 0, "illegal percent");
        receivers.push(_receiver);
        uint totalPercent = 0;
        for (uint i = 0; i < receivers.length; i ++) {
            totalPercent = totalPercent.add(receiverPercent[receivers[i]]);
        }
        receiverPercent[_receiver] = _percent;
        receiverToken[_receiver] = _receiverToken;
        require(totalPercent <= PERCENT_RATIO, "illegal percent");
    }

    function delReceiver(address _receiver) external onlyOwner {
        require(receiverPercent[_receiver] != 0, "receiver not exists");
        uint index = 0;
        for ( ; index < receivers.length; index ++) {
            if (receivers[index] == _receiver) {
                break;
            }
        }
        require(index < receivers.length, "receiver not exists");
        if (index < receivers.length - 1) {
            receivers[index] = receivers[receivers.length - 1];
        }
        receivers.pop();
        delete receiverPercent[_receiver];
        delete receiverToken[_receiver];
    }
    
    function receiverLength() external view returns (uint) {
        return receivers.length;
    }

    function setOwnerReceiver(address _receiver) external onlyOwner {
        ownerReceiver = _receiver;
    }

    constructor(IWETH _WETH, IBabyRouter _router, address _ownerReceiver, IERC20[] memory _tokens) {
        WETH = _WETH;
        router = _router;
        require(_ownerReceiver != address(0), "illegal receiver address");
        ownerReceiver = _ownerReceiver;
        tokens = _tokens;
    }

    function createDispatcher(address _receiver, uint _percent) external onlyOwner {
        require(address(dispatchers[_receiver]) == address(0), "already created");
        bytes memory bytecode = type(MarketFeeDispatcher).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_receiver));
        address dispatcher;
        assembly {
            dispatcher := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        require(dispatcher != address(0), "create2 failed");
        IMarketFeeDispatcher(dispatcher).initialize(address(this), WETH, _receiver, _percent);
        IMarketFeeDispatcher(dispatcher).transferOwnership(owner());
        dispatchers[_receiver] = IMarketFeeDispatcher(dispatcher);
        dispatcherList.push(IMarketFeeDispatcher(dispatcher));
    }

    function expectDispatcher(address _receiver) external view returns (address dispatcher) {
         dispatcher = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                address(this),
                keccak256(abi.encodePacked(_receiver)),
                INIT_CODE_HASH
            ))));
    }

    function getBalance(IERC20 _token) internal returns(uint) {
        if (address(_token) == address(WETH)) {
            uint balance = _token.balanceOf(address(this));
            WETH.withdraw(balance);
            return address(this).balance;
        } else {
            return _token.balanceOf(address(this));
        }
         
    }

    function transfer(IERC20 _token, address _to, uint _amount) internal {
        if (address(_token) == address(WETH)) {
            _to.call{value:_amount}(new bytes(0));
        } else {
            _token.safeTransfer(_to, _amount);
        }
    }

    function swapAndSend(IERC20 _token, IERC20 _receiveToken, address _to, uint _amount) internal {
        if (address(_receiveToken) == address(0)) {
            _receiveToken = _token;
        }
        if (_token == _receiveToken) {
            transfer(_token, _to, _amount);
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(_token); path[1] = address(_receiveToken);
        if (address(_token) == address(WETH)) {
            router.swapExactETHForTokens{value: _amount}(
                0,
                path,
                _to,
                block.timestamp
            );
        } else if (address(_receiveToken) == address(WETH)) {
            _token.approve(address(router), _amount);
            router.swapExactTokensForETH(
                _amount,
                0,
                path,
                _to,
                block.timestamp
            );
        } else {
            _token.approve(address(router), _amount);
            router.swapExactTokensForTokens(
                _amount,
                0,
                path,
                _to,
                block.timestamp
            );
        }
    }

    function dispatch(address _receiver) external onlyOwnerOrCaller {
        IMarketFeeDispatcher dispatcher = dispatchers[_receiver];
        for (uint i = 0; i < tokens.length; i ++) {
            IERC20 token = tokens[i];
            uint balance = getBalance(token);
            for (uint j = 0; j < receivers.length; j ++) {
                address receiver = receivers[j]; 
                uint sendAmount = balance.mul(receiverPercent[receiver]).div(PERCENT_RATIO);
                if (sendAmount > 0) {
                    swapAndSend(token, receiverToken[receiver], receiver, sendAmount);
                }
            }
        }
    }

    function dispatchAll() external onlyOwnerOrCaller {
        for (uint i = 0; i < dispatcherList.length; i ++) {
            IMarketFeeDispatcher dispatcher = dispatcherList[i];
            if (dispatcherBlacklist[dispatcher]) {
                continue;
            }
            dispatcher.dispatch(tokens);
        }
        for (uint i = 0; i < tokens.length; i ++) {
            IERC20 token = tokens[i];
            uint balance = getBalance(token);
            for (uint j = 0; j < receivers.length; j ++) {
                address receiver = receivers[j]; 
                uint sendAmount = balance.mul(receiverPercent[receiver]).div(PERCENT_RATIO);
                if (sendAmount > 0) {
                    swapAndSend(token, receiverToken[receiver], receiver, sendAmount);
                }
            }
        }
    }

    function withdraw(address _receiver) external onlyOwner {
        IMarketFeeDispatcher dispatcher = dispatchers[_receiver];
        require(address(dispatcher) != address(0), "illegal receiver");
        dispatcher.withdraw(tokens);
        for (uint i = 0; i < tokens.length; i ++) {
            IERC20 token = tokens[i];
            uint balance = getBalance(token);
            if (balance > 0) {
                transfer(token, ownerReceiver, balance);
            }
        }
    }

    function withdrawAll() external onlyOwner {
        for (uint i = 0; i < dispatcherList.length; i ++) {
            IMarketFeeDispatcher dispatcher = dispatcherList[i];
            dispatcher.withdraw(tokens);
        }
        for (uint i = 0; i < tokens.length; i ++) {
            IERC20 token = tokens[i];
            uint balance = getBalance(token);
            if (balance > 0) {
                transfer(token, ownerReceiver, balance);
            }
        }
    }

    function setPercent(address _user, uint _percent) external onlyOwner {
        require(address(dispatchers[_user]) != address(0), "_user not exist");
        dispatchers[_user].setPercent(_percent);
    }

    receive () external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IWETH.sol";

interface IMarketFeeDispatcher {

    function initialize(address manager, IWETH WETH, address receiver, uint percent) external;

    function dispatch(IERC20[] memory tokens) external;

    function withdraw(IERC20[] memory tokens) external;

    function transferOwnership(address newOwner) external;

    function setPercent(uint _percent) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

import './IBabyRouter02.sol';

interface IBabyRouter is IBabyRouter02 {
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

    constructor () internal {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

import './IBabyRouter01.sol';

interface IBabyRouter02 is IBabyRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

interface IBabyRouter01 {
    function factory() external view returns (address);
    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../token/VBabyToken.sol";

contract vBabyNFTFee is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable baby;
    vBABYToken public immutable vBaby;
    uint256 public totalSupply;

    event ExecteEvent(uint256 value);

    constructor(IERC20 baby_, vBABYToken vBaby_) {
        baby = baby_;
        vBaby = vBaby_;
    }

    function execteDonate() external nonReentrant {
        uint256 babyBalance = baby.balanceOf(address(this));
        baby.approve(address(vBaby), babyBalance);
        vBaby.donate(babyBalance);
        totalSupply = totalSupply + babyBalance;

        emit ExecteEvent(babyBalance);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../token/VBabyToken.sol";

contract VBabyDonateSchedule is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public vault;
    address public caller;
    uint256 public donationsPerDay;
    vBABYToken public vBaby;
    IERC20 public babyToken;
    bool public isPause;
    mapping(uint256 => bool) public isExecuted;

    event NewDonations(uint256 oldValue, uint256 newValue);
    event NewVault(address oldVault, address newVault);
    event NewCaller(address oldCaller, address newCaller);
    event SwitchDonate(bool isPause);
    event DonateExecuted(uint256 value);

    constructor(
        vBABYToken vBaby_,
        IERC20 babyToken_,
        address vault_,
        address caller_,
        uint256 donationsPerDay_
    ) {
        vBaby = vBaby_;
        babyToken = babyToken_;
        vault = vault_;
        caller = caller_;
        donationsPerDay = donationsPerDay_;
    }

    function setVault(address _vault) external onlyOwner {
        emit NewVault(vault, _vault);
        vault = _vault;
    }

    function switchDonate() external onlyOwner {
        isPause = !isPause;
        emit SwitchDonate(isPause);
    }

    function setCaller(address _caller) external onlyOwner {
        emit NewCaller(caller, _caller);
        caller = _caller;
    }

    function setDonationsPerDay(uint256 _donationsPerDay) external onlyOwner {
        emit NewDonations(donationsPerDay, _donationsPerDay);
        donationsPerDay = _donationsPerDay;
    }

    modifier onlyCaller() {
        require(msg.sender == caller, "only the caller can do this action");
        _;
    }

    function execDonate() external onlyCaller {
        require(!isExecuted[block.timestamp.div(1 days)], "executed today");
        require(!isPause, "task paused");
        isExecuted[block.timestamp.div(1 days)] = true;
        babyToken.safeTransferFrom(vault, address(this), donationsPerDay);
        babyToken.approve(address(vBaby), donationsPerDay);
        vBaby.donate(donationsPerDay);

        emit DonateExecuted(donationsPerDay);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../interfaces/IBabyWonderlandMintable.sol";

contract SmartMintableInitializable is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    // The address of the smart minter factory
    address public immutable SMART_MINTER_FACTORY;
    IBabyWonderlandMintable public babyWonderlandToken;
    IERC20 public payToken;
    bool public isInitialized;
    address payable public reserve;
    uint256 public price;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public supply;
    uint256 public remaning;
    uint256 public poolLimitPerUser;
    uint256 public plotsCapacity;
    bool public hasWhitelistLimit;
    mapping(address => uint256) public numberOfUsersMinted;

    event MintPlots(address account, uint256 startTokenId, uint256 number);
    event NewReserve(address oldReserve, address newReserve);

    constructor() {
        SMART_MINTER_FACTORY = msg.sender;
    }

    function initialize(
        address _babyWonderlandToken,
        address payable _reserve,
        address _payToken,
        uint256 _price,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _supply,
        uint256 _poolLimitPerUser,
        uint256 _plotsCapacity,
        bool _hasWhitelistLimit
    ) external {
        require(!isInitialized, "Already initialized the contract");
        require(msg.sender == SMART_MINTER_FACTORY, "Not factory");
        require(_reserve != address(0), "_reserve can not be address(0)");
        require(_price > 0, "price can not be 0");
        require(_startTime <= _endTime, "invalid time params");
        require(_poolLimitPerUser > 0, "_poolLimitPerUser can not be 0");
        require(_plotsCapacity > 0, "_plotsCapacity can not be 0");
        // Make this contract initialized
        isInitialized = true;
        babyWonderlandToken = IBabyWonderlandMintable(_babyWonderlandToken);
        reserve = _reserve;
        payToken = IERC20(_payToken);
        price = _price;
        startTime = _startTime;
        endTime = _endTime;
        supply = _supply;
        remaning = _supply;
        poolLimitPerUser = _poolLimitPerUser;
        hasWhitelistLimit = _hasWhitelistLimit;
        plotsCapacity = _plotsCapacity;
    }

    function mint() external payable nonReentrant onlyWhitelist {
        require(
            numberOfUsersMinted[msg.sender] < poolLimitPerUser,
            "purchase limit reached"
        );
        require(remaning > 0, "insufficient remaining");
        require(block.timestamp > startTime, "has not started");
        require(block.timestamp < endTime, "has expired");
        numberOfUsersMinted[msg.sender] += 1;
        if (address(payToken) == address(0)) {
            require(msg.value == price, "not enough tokens to pay");
            Address.sendValue(reserve, price);
        } else {
            payToken.safeTransferFrom(msg.sender, reserve, price);
        }
        remaning -= 1;
        babyWonderlandToken.batchMint(msg.sender, plotsCapacity);

        emit MintPlots(
            msg.sender,
            babyWonderlandToken.totalSupply() + 1,
            plotsCapacity
        );
    }

    function batchMint(uint256 number) external payable nonReentrant onlyWhitelist {
        require(block.timestamp > startTime, "has not started");
        require(block.timestamp < endTime, "has expired");
        require(
            numberOfUsersMinted[msg.sender].add(number) <= poolLimitPerUser,
            "purchase limit reached"
        );
        numberOfUsersMinted[msg.sender] += number;
        for (uint256 i = 0; i != number; i++) {
            require(remaning > 0, "insufficient remaining");
            if (address(payToken) == address(0)) {
                require(
                    msg.value == price.mul(number),
                    "not enough tokens to pay"
                );
                Address.sendValue(reserve, price);
            } else {
                payToken.safeTransferFrom(msg.sender, reserve, price);
            }
            remaning -= 1;
            babyWonderlandToken.batchMint(msg.sender, plotsCapacity);

            emit MintPlots(
                msg.sender,
                babyWonderlandToken.totalSupply() + 1,
                plotsCapacity
            );
        }
    }

    modifier onlyWhitelist() {
        require(
            !hasWhitelistLimit ||
                BabyWonderlandMakeFactory(SMART_MINTER_FACTORY).whitelist(
                    msg.sender
                ),
            "available only to whitelisted users"
        );

        _;
    }
}

contract BabyWonderlandMakeFactory is Ownable {
    uint256 private nonce;

    address immutable public babyWonderlandToken;

    mapping(address => bool) public isAdmin;
    mapping(address => bool) public whitelist;

    event NewSmartMintableContract(address indexed smartChef);
    event SetAdmin(address account, bool enable);
    event AddWhitelist(address account);
    event DelWhitelist(address account);

    constructor(address _babyWonderlandToken) {
        require(_babyWonderlandToken != address(0), "illegal token address");
        babyWonderlandToken = _babyWonderlandToken;
    }

    function addWhitelist(address account) public onlyAdmin {
        whitelist[account] = true;
        emit AddWhitelist(account);
    }

    function batchAddWhitelist(address[] memory accounts) external onlyAdmin {
        for (uint256 i = 0; i != accounts.length; i++) {
            addWhitelist(accounts[i]);
        }
    }

    function delWhitelist(address account) public onlyAdmin {
        whitelist[account] = false;
        emit DelWhitelist(account);
    }

    function batchDelWhitelist(address[] memory accounts) external onlyAdmin {
        for (uint256 i = 0; i != accounts.length; i++) {
            delWhitelist(accounts[i]);
        }
    }

    function setAdmin(address admin, bool enable) external onlyOwner {
        require(
            admin != address(0),
            "BabyWonderlandMakeFactory: address is zero"
        );
        isAdmin[admin] = enable;
        emit SetAdmin(admin, enable);
    }

    modifier onlyAdmin() {
        require(
            isAdmin[msg.sender],
            "BabyWonderlandMakeFactory: caller is not the admin"
        );
        _;
    }

    function deployMintable(
        address payable _reserve,
        address _payToken,
        uint256 _price,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _supply,
        uint256 _poolLimitPerUser,
        uint256 _plotsCapacity,
        bool _hasWhitelistLimit
    ) external onlyAdmin {
        nonce = nonce + 1;
        bytes memory bytecode = type(SmartMintableInitializable).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(nonce));
        address smartMintableAddress;

        assembly {
            smartMintableAddress := create2(
                0,
                add(bytecode, 32),
                mload(bytecode),
                salt
            )
        }
        SmartMintableInitializable(smartMintableAddress).initialize(
            babyWonderlandToken,
            _reserve,
            _payToken,
            _price,
            _startTime,
            _endTime,
            _supply,
            _poolLimitPerUser,
            _plotsCapacity,
            _hasWhitelistLimit
        );
        emit NewSmartMintableContract(smartMintableAddress);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IBabyWonderlandMintable {
    function mint(address to) external;

    function batchMint(address _recipient, uint256 _number) external;

    function totalSupply() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/IBabyWonderlandMintable.sol";

contract BabyWonderlandAirdrop is Ownable {
    using SafeMath for uint256;
    
    IBabyWonderlandMintable public rewardToken;

    uint256 public remaining;

    mapping(address => uint256) public rewardList;
    mapping(address => uint256) public claimedNumber;

    struct RewardConfig {
        address account;
        uint256 number;
    }
    event SetRewardList(address account, uint256 number);
    event Claimed(address account, uint256 number);

    constructor(IBabyWonderlandMintable _rewardToken) {
        require(address(_rewardToken) != address(0), "rewardToken is zero");
        rewardToken = _rewardToken;
        remaining = 2000;
    }

    function setRewardList(RewardConfig[] calldata list) external onlyOwner {
        for (uint256 i = 0; i != list.length; i++) {
            RewardConfig memory config = list[i];
            rewardList[config.account] = config.number;

            emit SetRewardList(config.account, config.number);
        }
    }

    function claim() external {
        if (rewardList[msg.sender] > claimedNumber[msg.sender]) {
            uint256 number = rewardList[msg.sender].sub(
                claimedNumber[msg.sender]
            );
            remaining = remaining.sub(number, "insufficient supply");
            claimedNumber[msg.sender] = rewardList[msg.sender];
            rewardToken.batchMint(msg.sender, number);
            emit Claimed(msg.sender, number);
        }
    }
}

// SPDX-License-Identifier: MIT

//This is the test contract
pragma solidity 0.7.4;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ScratchOffTickets is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    
    uint256 public constant pauseCountdown = 1 hours;

    address public verifier;
    mapping(address => uint256) public exhangeTotalPerUser;
    uint256 public startTime;
    uint256 public supplyPerRound;
    uint256 public ticketPrice;
    mapping(uint256 => uint256) public exhangeTotalPerRound;

    event NewSupplyPerRound(uint256 oldTotal, uint256 newTotal);
    event NewVerifier(address oldVerifier, address newVerifier);
    event ExchangeScratchOff(address account, uint256 amount);
    event NewTicketPrice(uint256 oldPrice, uint256 newPrice);

    function setVerifier(address _verifier) external onlyOwner {
        emit NewVerifier(verifier, _verifier);
        verifier = _verifier;
    }

    function setTicketPrice(uint256 _ticketPrice) external onlyOwner {
        emit NewTicketPrice(ticketPrice, _ticketPrice);
        ticketPrice = _ticketPrice;
    }

    function setSupplyPerRound(uint256 _supplyPerRound) external onlyOwner {
        emit NewSupplyPerRound(supplyPerRound, _supplyPerRound);
        supplyPerRound = _supplyPerRound;
    }

    function currentRound() public view returns(uint256) {
        return now().sub(startTime).div(1 weeks).add(1);
    }

    constructor(uint256 _ticketPrice, uint256 _startTime, uint256 _supplyPerRound, address _verifier) {
        startTime = _startTime;
        emit NewTicketPrice(ticketPrice, _ticketPrice);
        ticketPrice = _ticketPrice;
        emit NewSupplyPerRound(supplyPerRound, _supplyPerRound);
        supplyPerRound = _supplyPerRound;
        emit NewVerifier(verifier, _verifier);
        verifier = _verifier;
    }

    function getEncodePacked(address user, uint balance) public pure returns (bytes memory) {
        return abi.encodePacked(user, balance);
    }

    function getHash(address user, uint balance) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, balance));
    }

    function getHashToSign(address user, uint balance) external pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(user, balance))));
    }

    function verify(address user, uint balance, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
        return ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(user, balance)))), v, r, s) == verifier;
    }

    function exchange(uint balance, uint number, uint8 v, bytes32 r, bytes32 s) external {
        address user = msg.sender;
        require(verify(user, balance, v, r, s), "illegal verifier.");
        uint _round = currentRound();
        uint nextRound = now().add(pauseCountdown).sub(startTime).div(1 weeks).add(1);
        require(nextRound == _round, "exchange on hold");
        uint amount = ticketPrice.mul(number);
        exhangeTotalPerRound[_round] = exhangeTotalPerRound[_round].add(number);
        require(exhangeTotalPerRound[_round] <= supplyPerRound, "exceeded maximum limit");
        require(exhangeTotalPerUser[user].add(amount) <= balance, "insufficient balance");
        exhangeTotalPerUser[user] = exhangeTotalPerUser[user].add(amount);
        emit ExchangeScratchOff(user, number);
    }

    uint256 public extraTime;

    function fastForward(uint256 s) external onlyOwner {
        extraTime = extraTime.add(s);
    }

    function now() public view returns(uint256) {
        return block.timestamp.add(extraTime);
    }
}

// SPDX-License-Identifier: MIT

//This is the test contract
pragma solidity 0.7.4;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract LotteryTicket is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant pauseCountdown = 30 minutes;

    uint256 public startTime;
    uint256 public supplyPerRound;
    address public vault;
    
    mapping(uint256 => uint256) public exchangeTotalPerRound;
    mapping(address => uint256) public ticketPriceUsingToken;
    mapping(address => mapping(uint256 => uint256)) public userExhangeTotalPerRound;

    event NewSupplyPerRound(uint256 oldTotal, uint256 newTotal);
    event NewVault(address oldVault, address newVault);
    event ExchangeLotteryTicket(address account, uint256 amount, address token, uint256 );
    event NewTicketPrice(address token, uint256 oldPrice, uint256 newPrice);


    function setTicketPrice(address _token, uint256 _ticketPrice) external onlyOwner {
        require(_token != address(0), "token cannot be zero address, check it");
        emit NewTicketPrice(_token, ticketPriceUsingToken[_token], _ticketPrice);
        ticketPriceUsingToken[_token] = _ticketPrice;
    }

    function setSupplyPerRound(uint256 _supplyPerRound) external onlyOwner {
        emit NewSupplyPerRound(supplyPerRound, _supplyPerRound);
        supplyPerRound = _supplyPerRound;
    }

    function setVault(address _vault) external onlyOwner {
        require(_vault != address(0), "vault cannot be zero address");
        emit NewVault(vault, _vault);
        vault = _vault;
    }

    function currentRound() public view returns(uint256) {
        return now().sub(startTime).div(1 weeks).add(1);
    }

    constructor(address _vault, uint256 _startTime, uint256 _supplyPerRound) {
        startTime = _startTime;
        emit NewVault(vault, _vault);
        vault = _vault;
        emit NewSupplyPerRound(supplyPerRound, _supplyPerRound);
        supplyPerRound = _supplyPerRound;
    }

    function exchange(address token,  uint number) external nonReentrant {
        address user = msg.sender;
        uint _round = currentRound();
        uint nextRound = now().add(pauseCountdown).sub(startTime).div(1 weeks).add(1);
        require(nextRound == _round, "exchange on hold");
        require(ticketPriceUsingToken[token] > 0, "unsupported token");
        uint amount = ticketPriceUsingToken[token].mul(number);
        IERC20(token).safeTransferFrom(user, vault, amount);
        exchangeTotalPerRound[_round] = exchangeTotalPerRound[_round].add(number);
        require(exchangeTotalPerRound[_round] <= supplyPerRound, "exceeded maximum limit");
        userExhangeTotalPerRound[user][_round] = userExhangeTotalPerRound[user][_round].add(number);
        emit ExchangeLotteryTicket(user, number, token, amount);
    }

    uint public extraTime;

    function fastForward(uint256 s) external onlyOwner {
        extraTime = extraTime.add(s);
    }

    function now() public view returns(uint256) {
        return block.timestamp.add(extraTime);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

contract PoolInstanceV2 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // The address of the smart chef factory
    address public POOL_FACTORY;

    // Whether a limit is set for users
    bool public hasUserLimit;

    // Whether it is initialized
    bool public isInitialized;

    // Accrued token per share
    uint256 public accTokenPerShare;

    // The block number when CAKE mining ends.
    uint256 public bonusEndBlock;

    // The block number when CAKE mining starts.
    uint256 public startBlock;

    // The block number of the last pool update
    uint256 public lastRewardBlock;

    // The pool limit (0 if none)
    uint256 public poolLimitPerUser;

    // CAKE tokens created per block.
    uint256 public rewardPerBlock;

    // The precision factor
    uint256 public PRECISION_FACTOR;

    // The reward token
    IERC20 public rewardToken;

    // The staked token
    IERC20 public stakedToken;

    // The amount user staked
    uint256 public stakedAmount;

    // Info of each user that stakes tokens (stakedToken)
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
    }

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event NewRewardPerBlock(uint256 rewardPerBlock);
    event NewPoolLimit(uint256 poolLimitPerUser);
    event RewardsStop(uint256 blockNumber);
    event Withdraw(address indexed user, uint256 amount);

    constructor() {
        POOL_FACTORY = msg.sender;
    }

    function initialize(
        IERC20 _stakedToken,
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _poolLimitPerUser,
        address _admin
    ) external {
        require(!isInitialized, "Already initialized the contract");
        require(msg.sender == POOL_FACTORY, "Not factory");

        // Make this contract initialized
        isInitialized = true;

        stakedToken = _stakedToken;
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;

        if (_poolLimitPerUser > 0) {
            hasUserLimit = true;
            poolLimitPerUser = _poolLimitPerUser;
        }

        uint256 decimalsRewardToken = uint256(ERC20(address(rewardToken)).decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");

        PRECISION_FACTOR = uint256(10**(uint256(30).sub(decimalsRewardToken)));

        // Set the lastRewardBlock as the startBlock
        lastRewardBlock = startBlock;

        // Transfer ownership to the admin address who becomes owner of the contract
        transferOwnership(_admin);
    }
    
    function deposit(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        if (hasUserLimit) {
            require(_amount.add(user.amount) <= poolLimitPerUser, "User amount above limit");
        }

        _updatePool();

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
            if (pending > 0) {
                rewardToken.safeTransfer(address(msg.sender), pending);
            }
        }

        if (_amount > 0) {
            uint beforeBalance = stakedToken.balanceOf(address(this));
            stakedToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint afterBalance = stakedToken.balanceOf(address(this));
            _amount = afterBalance.sub(beforeBalance);
            if (_amount > 0) {
                user.amount = user.amount.add(_amount);
                stakedAmount = stakedAmount.add(_amount);
            }
        }

        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR);

        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");

        _updatePool();

        uint256 pending = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            stakedToken.safeTransfer(address(msg.sender), _amount);
            stakedAmount = stakedAmount.sub(_amount);
        }

        if (pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }

        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR);

        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amountToTransfer = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        if (amountToTransfer > 0) {
            stakedToken.safeTransfer(address(msg.sender), amountToTransfer);
        }

        emit EmergencyWithdraw(msg.sender, amountToTransfer);
    }

    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        rewardToken.safeTransfer(address(msg.sender), _amount);
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(stakedToken), "Cannot be staked token");
        require(_tokenAddress != address(rewardToken), "Cannot be reward token");

        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    function stopReward() external onlyOwner {
        bonusEndBlock = block.number;
    }

    function updatePoolLimitPerUser(bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {
        require(hasUserLimit, "Must be set");
        if (_hasUserLimit) {
            require(_poolLimitPerUser > poolLimitPerUser, "New limit must be higher");
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            hasUserLimit = _hasUserLimit;
            poolLimitPerUser = 0;
        }
        emit NewPoolLimit(poolLimitPerUser);
    }

    function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        require(block.number < startBlock, "Pool has started");
        rewardPerBlock = _rewardPerBlock;
        emit NewRewardPerBlock(_rewardPerBlock);
    }

    function updateStartAndEndBlocks(uint256 _startBlock, uint256 _bonusEndBlock) external onlyOwner {
        require(block.number < startBlock, "Pool has started");
        require(_startBlock < _bonusEndBlock, "New startBlock must be lower than new endBlock");
        require(block.number < _startBlock, "New startBlock must be higher than current block");

        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;

        // Set the lastRewardBlock as the startBlock
        lastRewardBlock = startBlock;

        emit NewStartAndEndBlocks(_startBlock, _bonusEndBlock);
    }

    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 stakedTokenSupply = stakedAmount; 
        if (block.number > lastRewardBlock && stakedTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
            uint256 cakeReward = multiplier.mul(rewardPerBlock);
            uint256 adjustedTokenPerShare =
                accTokenPerShare.add(cakeReward.mul(PRECISION_FACTOR).div(stakedTokenSupply));
            return user.amount.mul(adjustedTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
        } else {
            return user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
        }
    }

    function _updatePool() internal {
        if (block.number <= lastRewardBlock) {
            return;
        }

        uint256 stakedTokenSupply = stakedAmount;

        if (stakedTokenSupply == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
        uint256 cakeReward = multiplier.mul(rewardPerBlock);
        accTokenPerShare = accTokenPerShare.add(cakeReward.mul(PRECISION_FACTOR).div(stakedTokenSupply));
        lastRewardBlock = block.number;
    }

    function _getMultiplier(uint256 _from, uint256 _to) internal view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from);
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock.sub(_from);
        }
    }
    
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './PoolInstanceV2.sol';

contract PoolFactoryV2 is Ownable {
    event NewPoolInstance(address indexed pool);

    /*
     * @notice Deploy the pool
     * @param _stakedToken: staked token address
     * @param _rewardToken: reward token address
     * @param _rewardPerBlock: reward per block (in rewardToken)
     * @param _startBlock: start block
     * @param _endBlock: end block
     * @param _poolLimitPerUser: pool limit per user in stakedToken (if any, else 0)
     * @param _admin: admin address with ownership
     * @return address of new smart chef contract
     */
    function deployPool(
        IERC20 _stakedToken,
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _poolLimitPerUser,
        address _admin
    ) external onlyOwner {
        require(_stakedToken.totalSupply() >= 0 && _rewardToken.totalSupply() >= 0);

        bytes memory bytecode = type(PoolInstanceV2).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_stakedToken, _rewardToken, _startBlock));
        address poolInstanceAddress;

        assembly {
            poolInstanceAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        
        PoolInstanceV2(poolInstanceAddress).initialize(
            _stakedToken,
            _rewardToken,
            _rewardPerBlock,
            _startBlock,
            _bonusEndBlock,
            _poolLimitPerUser,
            _admin
        );
        
        emit NewPoolInstance(poolInstanceAddress);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.4;
pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IMasterChef.sol";

contract NFTFarmV3 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    event Stake(address user, uint256 tokenId, uint256 amount);
    event Unstake(address user, uint256 tokenId, uint256 amount);
    event Claim(address user, uint256 amount);
    event NewNFTInfo(uint256 index, address token, uint256 babyValue);
    event NewVault(address vault);
    event DelNFTInfo(uint256 index);

    uint256 public constant RATIO = 1e18;

    struct PoolInfo {
        uint256 totalShares;
        uint256 accBabyPerShare;
    }

    struct UserInfo {
        uint256 amount;
        uint256 debt;
        uint256 pending;
    }

    struct NFTInfo {
        ERC721 nftToken;
        uint256 babyValue;
    }

    PoolInfo public poolInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(address => mapping(address => EnumerableSet.UintSet)) holderTokens;
    EnumerableMap.UintToAddressMap tokenOwners;
    NFTInfo[] private _nftInfos;
    mapping(address => bool) public isNFTExist;
    mapping(address => mapping(uint256 => uint256)) tokenWeight;
    ERC20 public immutable babyToken;
    IMasterChef immutable masterChef;
    address public vault;
    mapping(address => uint256) public babyValue;

    constructor(
        ERC20 _babyToken,
        IMasterChef _masterChef,
        address _vault
    ) {
        require(
            address(_babyToken) != address(0),
            "_babyToken address cannot be 0"
        );
        require(
            address(_masterChef) != address(0),
            "_masterChef address cannot be 0"
        );
        require(_vault != address(0), "_vault address cannot be 0");
        babyToken = _babyToken;
        masterChef = _masterChef;
        vault = _vault;
        emit NewVault(_vault);
    }

    function addNFTInfo(ERC721 _nftToken, uint256 _babyValue)
        external
        onlyOwner
    {
        require(
            address(_nftToken) != address(0),
            "_nftToken address cannot be 0"
        );
        require(!isNFTExist[address(_nftToken)], "nft already exists");
        _nftInfos.push(NFTInfo({nftToken: _nftToken, babyValue: _babyValue}));
        isNFTExist[address(_nftToken)] = true;
        emit NewNFTInfo(_nftInfos.length - 1, address(_nftToken), _babyValue);
    }

    function setNFTInfo(
        uint256 _index,
        ERC721 _nftToken,
        uint256 _babyValue
    ) external onlyOwner {
        require(
            address(_nftToken) != address(0),
            "_nftToken address cannot be 0"
        );
        require(_index < _nftInfos.length, "illegal index");
        require(isNFTExist[address(_nftToken)], "nft does not exist");
        _nftInfos[_index] = NFTInfo({nftToken: _nftToken, babyValue: _babyValue});
        emit NewNFTInfo(_index, address(_nftToken), _babyValue);
    }

    function delNFTInfo(uint256 _index) external onlyOwner {
        require(_index < _nftInfos.length, "illegal index");
        if (_index < _nftInfos.length - 1) {
            NFTInfo memory _lastNFTInfo = _nftInfos[_nftInfos.length - 1];
            _nftInfos[_index] = _nftInfos[_nftInfos.length - 1];
            emit NewNFTInfo(
                _index,
                address(_lastNFTInfo.nftToken),
                _lastNFTInfo.babyValue
            );
        }
        _nftInfos.pop();
        emit DelNFTInfo(_nftInfos.length);
    }

    function setVault(address _vault) external onlyOwner {
        vault = _vault;
        emit NewVault(_vault);
    }

    function stake(uint256 _tokenId, uint256 _idx) public nonReentrant {
        require(_idx < _nftInfos.length, "illegal idx");
        NFTInfo memory nftInfo = _nftInfos[_idx];
        uint256 stakeBaby = nftInfo.babyValue;
        SafeERC20.safeTransferFrom(babyToken, vault, address(this), stakeBaby);
        nftInfo.nftToken.transferFrom(msg.sender, address(this), _tokenId);

        PoolInfo memory _poolInfo = poolInfo;
        UserInfo memory _userInfo = userInfo[msg.sender];
        uint256 balanceBefore = babyToken.balanceOf(address(this));
        masterChef.enterStaking(0);
        uint256 balanceAfter = babyToken.balanceOf(address(this));
        uint256 _pending = balanceAfter.sub(balanceBefore);
        if (_pending > 0 && _poolInfo.totalShares > 0) {
            poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(
                _pending.mul(RATIO).div(_poolInfo.totalShares)
            );
            _poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(
                _pending.mul(RATIO).div(_poolInfo.totalShares)
            );
        }
        if (_userInfo.amount > 0) {
            userInfo[msg.sender].pending = _userInfo.pending.add(
                _userInfo.amount.mul(_poolInfo.accBabyPerShare).div(RATIO).sub(
                    _userInfo.debt
                )
            );
        }
        babyToken.approve(address(masterChef), stakeBaby.add(_pending));
        masterChef.enterStaking(stakeBaby.add(_pending));
        userInfo[msg.sender].amount = _userInfo.amount.add(stakeBaby);
        holderTokens[msg.sender][address(nftInfo.nftToken)].add(_tokenId);
        tokenOwners.set(_tokenId, msg.sender);
        tokenWeight[address(nftInfo.nftToken)][_tokenId] = stakeBaby;
        poolInfo.totalShares = _poolInfo.totalShares.add(stakeBaby);
        userInfo[msg.sender].debt = _poolInfo
            .accBabyPerShare
            .mul(_userInfo.amount.add(stakeBaby))
            .div(RATIO);
        emit Stake(msg.sender, _tokenId, stakeBaby);
    }

    function stakeAll(uint256[] memory _tokenIds, uint _idx) external {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            stake(_tokenIds[i],_idx);
        }
    }

    function unstake(uint256 _tokenId, uint256 _idx) public nonReentrant {
        require(_idx < _nftInfos.length, "illegal idx");
        NFTInfo memory nftInfo = _nftInfos[_idx];
        require(tokenOwners.get(_tokenId) == msg.sender, "illegal tokenId");

        PoolInfo memory _poolInfo = poolInfo;
        UserInfo memory _userInfo = userInfo[msg.sender];

        uint256 balanceBefore = babyToken.balanceOf(address(this));
        masterChef.leaveStaking(0);
        uint256 balanceAfter = babyToken.balanceOf(address(this));
        uint256 _pending = balanceAfter.sub(balanceBefore);
        if (_pending > 0 && _poolInfo.totalShares > 0) {
            poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(
                _pending.mul(RATIO).div(_poolInfo.totalShares)
            );
            _poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(
                _pending.mul(RATIO).div(_poolInfo.totalShares)
            );
        }

        uint256 _userPending = _userInfo.pending.add(
            _userInfo.amount.mul(_poolInfo.accBabyPerShare).div(RATIO).sub(
                _userInfo.debt
            )
        );
        uint256 _stakeAmount = tokenWeight[address(nftInfo.nftToken)][_tokenId];
        uint256 _totalPending = _userPending.add(_stakeAmount);

        if (_totalPending >= _pending) {
            masterChef.leaveStaking(_totalPending.sub(_pending));
        } else {
            babyToken.approve(address(masterChef), _pending.sub(_totalPending));
            masterChef.enterStaking(_pending.sub(_totalPending));
        }

        if (_userPending > 0) {
            SafeERC20.safeTransfer(babyToken, msg.sender, _userPending);
            emit Claim(msg.sender, _userPending);
        }
        if (_totalPending > _userPending) {
            SafeERC20.safeTransfer(
                babyToken,
                vault,
                _totalPending.sub(_userPending)
            );
        }

        poolInfo.totalShares = _poolInfo.totalShares.sub(_stakeAmount);
        userInfo[msg.sender].amount = _userInfo.amount.sub(_stakeAmount);
        userInfo[msg.sender].pending = 0;
        userInfo[msg.sender].debt = _userInfo
            .amount
            .sub(_stakeAmount)
            .mul(_poolInfo.accBabyPerShare)
            .div(RATIO);
        tokenOwners.remove(_tokenId);
        holderTokens[msg.sender][address(nftInfo.nftToken)].remove(_tokenId);
        nftInfo.nftToken.transferFrom(address(this), msg.sender, _tokenId);
        delete tokenWeight[address(nftInfo.nftToken)][_tokenId];
        emit Unstake(msg.sender, _tokenId, _stakeAmount);
    }

    function unstakeAll(uint256[] memory _tokenIds, uint _idx) external {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            unstake(_tokenIds[i], _idx);
        }
    }

    function claim(address _user) external nonReentrant {
        PoolInfo memory _poolInfo = poolInfo;
        UserInfo memory _userInfo = userInfo[_user];

        uint256 balanceBefore = babyToken.balanceOf(address(this));
        masterChef.leaveStaking(0);
        uint256 balanceAfter = babyToken.balanceOf(address(this));
        uint256 _pending = balanceAfter.sub(balanceBefore);
        if (_pending > 0 && _poolInfo.totalShares > 0) {
            poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(
                _pending.mul(RATIO).div(_poolInfo.totalShares)
            );
            _poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(
                _pending.mul(RATIO).div(_poolInfo.totalShares)
            );
        }
        uint256 _userPending = _userInfo.pending.add(
            _userInfo.amount.mul(_poolInfo.accBabyPerShare).div(RATIO).sub(
                _userInfo.debt
            )
        );
        if (_userPending == 0) {
            return;
        }
        if (_userPending >= _pending) {
            masterChef.leaveStaking(_userPending.sub(_pending));
        } else {
            babyToken.approve(address(masterChef), _pending.sub(_userPending));
            masterChef.enterStaking(_pending.sub(_userPending));
        }
        SafeERC20.safeTransfer(babyToken, _user, _userPending);
        emit Claim(_user, _userPending);
        userInfo[_user].debt = _userInfo
            .amount
            .mul(_poolInfo.accBabyPerShare)
            .div(RATIO);
        userInfo[_user].pending = 0;
    }

    function pending(address _user) external view returns (uint256) {
        uint256 _pending = masterChef.pendingCake(0, address(this));
        if (poolInfo.totalShares == 0) {
            return 0;
        }
        uint256 acc = poolInfo.accBabyPerShare.add(
            _pending.mul(RATIO).div(poolInfo.totalShares)
        );
        uint256 userPending = userInfo[_user].pending.add(
            userInfo[_user].amount.mul(acc).div(RATIO).sub(userInfo[_user].debt)
        );
        return userPending;
    }

    function balanceOf(address owner,uint256 nftIdx) external view returns (uint256) {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return holderTokens[owner][address(_nftInfos[nftIdx].nftToken)].length();
    }

    function tokenOfOwnerByIndex(address owner,uint256 nftIdx, uint256 index)
        external
        view
        returns (uint256)
    {
        return holderTokens[owner][address(_nftInfos[nftIdx].nftToken)].at(index);
    }

    function nftInfos() public view returns(NFTInfo[] memory){
        return _nftInfos;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

interface IMasterChef {

    function userInfo(uint pid, address user) external returns (uint, uint);

    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.4;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IMasterChef.sol";

contract NFTFarmV2 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    event Stake(address user, uint256 tokenId, uint256 amount);
    event Unstake(address user, uint256 tokenId, uint256 amount);
    event Claim(address user, uint256 amount);
    event NewNFTValue(uint256 babyValue);

    uint256 public constant RATIO = 1e18;

    struct PoolInfo {
        uint256 totalShares;
        uint256 accBabyPerShare;
    }

    struct UserInfo {
        uint256 amount;
        uint256 debt;
        uint256 pending;
    }

    PoolInfo public poolInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(address => EnumerableSet.UintSet) holderTokens;
    EnumerableMap.UintToAddressMap tokenOwners;
    mapping(uint256 => uint256) public tokenWeight;
    ERC20 public immutable babyToken;
    ERC721 public immutable nftToken;
    IMasterChef immutable masterChef;
    address public vault;
    uint256 public babyValue;

    constructor(
        ERC20 _babyToken,
        ERC721 _nftToken,
        IMasterChef _masterChef,
        address _vault
    ) {
        require(
            address(_babyToken) != address(0),
            "_babyToken address cannot be 0"
        );
        require(
            address(_nftToken) != address(0),
            "_nftToken address cannot be 0"
        );
        require(
            address(_masterChef) != address(0),
            "_masterChef address cannot be 0"
        );
        require(_vault != address(0), "_vault address cannot be 0");
        babyToken = _babyToken;
        nftToken = _nftToken;
        masterChef = _masterChef;
        vault = _vault;
    }

    function setNFTValue(uint256 _babyValue) external onlyOwner {
        require(_babyValue > 0, "error value");
        babyValue = _babyValue;
        emit NewNFTValue(_babyValue);
    }

    function setVault(address _vault) external onlyOwner {
        require(_vault != address(0), "address is zero");
        vault = _vault;
    }

    function stake(uint256 _tokenId) public nonReentrant {
        uint256 stakeBaby = babyValue;
        SafeERC20.safeTransferFrom(babyToken, vault, address(this), stakeBaby);
        nftToken.transferFrom(msg.sender, address(this), _tokenId);

        PoolInfo memory _poolInfo = poolInfo;
        UserInfo memory _userInfo = userInfo[msg.sender];
        //uint _pending = masterChef.pendingCake(0, address(this));
        uint256 balanceBefore = babyToken.balanceOf(address(this));
        masterChef.enterStaking(0);
        uint256 balanceAfter = babyToken.balanceOf(address(this));
        uint256 _pending = balanceAfter.sub(balanceBefore);
        if (_pending > 0 && _poolInfo.totalShares > 0) {
            poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(
                _pending.mul(RATIO).div(_poolInfo.totalShares)
            );
            _poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(
                _pending.mul(RATIO).div(_poolInfo.totalShares)
            );
        }
        if (_userInfo.amount > 0) {
            userInfo[msg.sender].pending = _userInfo.pending.add(
                _userInfo.amount.mul(_poolInfo.accBabyPerShare).div(RATIO).sub(
                    _userInfo.debt
                )
            );
        }
        babyToken.approve(address(masterChef), stakeBaby.add(_pending));
        masterChef.enterStaking(stakeBaby.add(_pending));
        userInfo[msg.sender].amount = _userInfo.amount.add(stakeBaby);
        holderTokens[msg.sender].add(_tokenId);
        tokenOwners.set(_tokenId, msg.sender);
        tokenWeight[_tokenId] = stakeBaby;
        poolInfo.totalShares = _poolInfo.totalShares.add(stakeBaby);
        userInfo[msg.sender].debt = _poolInfo
            .accBabyPerShare
            .mul(_userInfo.amount.add(stakeBaby))
            .div(RATIO);
        emit Stake(msg.sender, _tokenId, stakeBaby);
    }

    function stakeAll(uint256[] memory _tokenIds) external {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            stake(_tokenIds[i]);
        }
    }

    function unstake(uint256 _tokenId) public nonReentrant {
        require(tokenOwners.get(_tokenId) == msg.sender, "illegal tokenId");

        PoolInfo memory _poolInfo = poolInfo;
        UserInfo memory _userInfo = userInfo[msg.sender];

        //uint _pending = masterChef.pendingCake(0, address(this));
        uint256 balanceBefore = babyToken.balanceOf(address(this));
        masterChef.leaveStaking(0);
        uint256 balanceAfter = babyToken.balanceOf(address(this));
        uint256 _pending = balanceAfter.sub(balanceBefore);
        if (_pending > 0 && _poolInfo.totalShares > 0) {
            poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(
                _pending.mul(RATIO).div(_poolInfo.totalShares)
            );
            _poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(
                _pending.mul(RATIO).div(_poolInfo.totalShares)
            );
        }

        uint256 _userPending = _userInfo.pending.add(
            _userInfo.amount.mul(_poolInfo.accBabyPerShare).div(RATIO).sub(
                _userInfo.debt
            )
        );
        uint256 _stakeAmount = tokenWeight[_tokenId];
        uint256 _totalPending = _userPending.add(_stakeAmount);

        if (_totalPending >= _pending) {
            masterChef.leaveStaking(_totalPending.sub(_pending));
        } else {
            //masterChef.leaveStaking(0);
            babyToken.approve(address(masterChef), _pending.sub(_totalPending));
            masterChef.enterStaking(_pending.sub(_totalPending));
        }

        if (_userPending > 0) {
            SafeERC20.safeTransfer(babyToken, msg.sender, _userPending);
            emit Claim(msg.sender, _userPending);
        }
        if (_totalPending > _userPending) {
            SafeERC20.safeTransfer(
                babyToken,
                vault,
                _totalPending.sub(_userPending)
            );
        }

        poolInfo.totalShares = _poolInfo.totalShares.sub(_stakeAmount);
        userInfo[msg.sender].amount = _userInfo.amount.sub(_stakeAmount);
        userInfo[msg.sender].pending = 0;
        userInfo[msg.sender].debt = _userInfo
            .amount
            .sub(_stakeAmount)
            .mul(_poolInfo.accBabyPerShare)
            .div(RATIO);
        tokenOwners.remove(_tokenId);
        holderTokens[msg.sender].remove(_tokenId);
        nftToken.transferFrom(address(this), msg.sender, _tokenId);
        delete tokenWeight[_tokenId];
        emit Unstake(msg.sender, _tokenId, _stakeAmount);
    }

    function unstakeAll(uint256[] memory _tokenIds) external {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            unstake(_tokenIds[i]);
        }
    }

    function claim(address _user) external nonReentrant {
        PoolInfo memory _poolInfo = poolInfo;
        UserInfo memory _userInfo = userInfo[_user];

        uint256 balanceBefore = babyToken.balanceOf(address(this));
        masterChef.leaveStaking(0);
        uint256 balanceAfter = babyToken.balanceOf(address(this));
        uint256 _pending = balanceAfter.sub(balanceBefore);
        if (_pending > 0 && _poolInfo.totalShares > 0) {
            poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(
                _pending.mul(RATIO).div(_poolInfo.totalShares)
            );
            _poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(
                _pending.mul(RATIO).div(_poolInfo.totalShares)
            );
        }
        uint256 _userPending = _userInfo.pending.add(
            _userInfo.amount.mul(_poolInfo.accBabyPerShare).div(RATIO).sub(
                _userInfo.debt
            )
        );
        if (_userPending == 0) {
            return;
        }
        if (_userPending >= _pending) {
            masterChef.leaveStaking(_userPending.sub(_pending));
        } else {
            //masterChef.leaveStaking(0);
            babyToken.approve(address(masterChef), _pending.sub(_userPending));
            masterChef.enterStaking(_pending.sub(_userPending));
        }
        SafeERC20.safeTransfer(babyToken, _user, _userPending);
        emit Claim(_user, _userPending);
        userInfo[_user].debt = _userInfo
            .amount
            .mul(_poolInfo.accBabyPerShare)
            .div(RATIO);
        userInfo[_user].pending = 0;
    }

    function pending(address _user) external view returns (uint256) {
        uint256 _pending = masterChef.pendingCake(0, address(this));
        if (poolInfo.totalShares == 0) {
            return 0;
        }
        uint256 acc = poolInfo.accBabyPerShare.add(
            _pending.mul(RATIO).div(poolInfo.totalShares)
        );
        uint256 userPending = userInfo[_user].pending.add(
            userInfo[_user].amount.mul(acc).div(RATIO).sub(userInfo[_user].debt)
        );
        return userPending;
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return holderTokens[owner].length();
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256)
    {
        return holderTokens[owner].at(index);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../libraries/SafeMath.sol";
import "../libraries/BabyLibrary.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IBabyFactory.sol";
import "../interfaces/IBabyPair.sol";
import "../token/BabyToken.sol";

interface IOracle {
    function update(address tokenA, address tokenB) external;

    function consult(address tokenIn, uint amountIn, address tokenOut) external view returns (uint amountOut);
}

contract SwapMining is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _whitelist;

    // MDX tokens created per block
    uint256 public babyPerBlock;
    // The block number when MDX mining starts.
    uint256 public startBlock;
    // How many blocks are halved
    uint256 public halvingPeriod = 5256000;
    // Total allocation points
    uint256 public totalAllocPoint = 0;
    IOracle public oracle;
    // router address
    address public router;
    // factory address
    IBabyFactory public factory;
    // babytoken address
    BabyToken public babyToken;
    // Calculate price based on BUSD
    address public targetToken;
    // pair corresponding pid
    mapping(address => uint256) public pairOfPid;

    constructor(
        BabyToken _babyToken,
        IBabyFactory _factory,
        IOracle _oracle,
        address _router,
        address _targetToken,
        uint256 _babyPerBlock,
        uint256 _startBlock
    ) {
        require(address(_babyToken) != address(0), "illegal token address");
        babyToken = _babyToken;
        require(address(_factory) != address(0), "illegal address");
        factory = _factory;
        require(address(_oracle) != address(0), "illegal address");
        oracle = _oracle;
        require(_router != address(0), "illegal address");
        router = _router;
        targetToken = _targetToken;
        babyPerBlock = _babyPerBlock;
        startBlock = _startBlock;
    }

    struct UserInfo {
        uint256 quantity;       // How many LP tokens the user has provided
        uint256 blockNumber;    // Last transaction block
    }

    struct PoolInfo {
        address pair;           // Trading pairs that can be mined
        uint256 quantity;       // Current amount of LPs
        uint256 totalQuantity;  // All quantity
        uint256 allocPoint;     // How many allocation points assigned to this pool
        uint256 allocMdxAmount; // How many MDXs
        uint256 lastRewardBlock;// Last transaction block
    }

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;


    function poolLength() public view returns (uint256) {
        return poolInfo.length;
    }


    function addPair(uint256 _allocPoint, address _pair, bool _withUpdate) public onlyOwner {
        require(_pair != address(0), "_pair is the zero address");
        if (_withUpdate) {
            massMintPools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
        pair : _pair,
        quantity : 0,
        totalQuantity : 0,
        allocPoint : _allocPoint,
        allocMdxAmount : 0,
        lastRewardBlock : lastRewardBlock
        }));
        pairOfPid[_pair] = poolLength() - 1;
    }

    // Update the allocPoint of the pool
    function setPair(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massMintPools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // Set the number of baby produced by each block
    function setBabyPerBlock(uint256 _newPerBlock) public onlyOwner {
        massMintPools();
        babyPerBlock = _newPerBlock;
    }

    // Only tokens in the whitelist can be mined MDX
    function addWhitelist(address _addToken) public onlyOwner returns (bool) {
        require(_addToken != address(0), "SwapMining: token is the zero address");
        return EnumerableSet.add(_whitelist, _addToken);
    }

    function delWhitelist(address _delToken) public onlyOwner returns (bool) {
        require(_delToken != address(0), "SwapMining: token is the zero address");
        return EnumerableSet.remove(_whitelist, _delToken);
    }

    function getWhitelistLength() public view returns (uint256) {
        return EnumerableSet.length(_whitelist);
    }

    function isWhitelist(address _token) public view returns (bool) {
        return EnumerableSet.contains(_whitelist, _token);
    }

    function getWhitelist(uint256 _index) public view returns (address){
        require(_index <= getWhitelistLength() - 1, "SwapMining: index out of bounds");
        return EnumerableSet.at(_whitelist, _index);
    }

    function setHalvingPeriod(uint256 _block) public onlyOwner {
        halvingPeriod = _block;
    }

    function setRouter(address newRouter) public onlyOwner {
        require(newRouter != address(0), "SwapMining: new router is the zero address");
        router = newRouter;
    }

    function setOracle(IOracle _oracle) public onlyOwner {
        require(address(_oracle) != address(0), "SwapMining: new oracle is the zero address");
        oracle = _oracle;
    }

    // At what phase
    function phase(uint256 blockNumber) public view returns (uint256) {
        if (halvingPeriod == 0) {
            return 0;
        }
        if (blockNumber > startBlock) {
            return (blockNumber.sub(startBlock).sub(1)).div(halvingPeriod);
        }
        return 0;
    }

    function phase() public view returns (uint256) {
        return phase(block.number);
    }

    function reward(uint256 blockNumber) public view returns (uint256) {
        uint256 _phase = phase(blockNumber);
        return babyPerBlock.div(2 ** _phase);
    }

    function reward() public view returns (uint256) {
        return reward(block.number);
    }

    // Rewards for the current block
    function getBabyReward(uint256 _lastRewardBlock) public view returns (uint256) {
        require(_lastRewardBlock <= block.number, "SwapMining: must little than the current block number");
        uint256 blockReward = 0;
        uint256 n = phase(_lastRewardBlock);
        uint256 m = phase(block.number);
        // If it crosses the cycle
        while (n < m) {
            n++;
            // Get the last block of the previous cycle
            uint256 r = n.mul(halvingPeriod).add(startBlock);
            // Get rewards from previous periods
            blockReward = blockReward.add((r.sub(_lastRewardBlock)).mul(reward(r)));
            _lastRewardBlock = r;
        }
        blockReward = blockReward.add((block.number.sub(_lastRewardBlock)).mul(reward(block.number)));
        return blockReward;
    }

    // Update all pools Called when updating allocPoint and setting new blocks
    function massMintPools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            mint(pid);
        }
    }

    function mint(uint256 _pid) public returns (bool) {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return false;
        }
        uint256 blockReward = getBabyReward(pool.lastRewardBlock);
        if (blockReward <= 0) {
            return false;
        }
        // Calculate the rewards obtained by the pool based on the allocPoint
        uint256 mdxReward = blockReward.mul(pool.allocPoint).div(totalAllocPoint);
        // Increase the number of tokens in the current pool
        pool.allocMdxAmount = pool.allocMdxAmount.add(mdxReward);
        pool.lastRewardBlock = block.number;
        return true;
    }

    modifier onlyRouter() {
        require(msg.sender == router, "SwapMining: caller is not the router");
        _;
    }

    // swapMining only router
    function swap(address account, address input, address output, uint256 amount) public onlyRouter returns (bool) {
        require(account != address(0), "SwapMining: taker swap account is the zero address");
        require(input != address(0), "SwapMining: taker swap input is the zero address");
        require(output != address(0), "SwapMining: taker swap output is the zero address");

        if (poolLength() <= 0) {
            return false;
        }

        if (!isWhitelist(input) || !isWhitelist(output)) {
            return false;
        }

        address pair = BabyLibrary.pairFor(address(factory), input, output);
        PoolInfo storage pool = poolInfo[pairOfPid[pair]];
        // If it does not exist or the allocPoint is 0 then return
        if (pool.pair != pair || pool.allocPoint <= 0) {
            return false;
        }

        uint256 quantity = getQuantity(output, amount, targetToken);
        if (quantity <= 0) {
            return false;
        }

        mint(pairOfPid[pair]);

        pool.quantity = pool.quantity.add(quantity);
        pool.totalQuantity = pool.totalQuantity.add(quantity);
        UserInfo storage user = userInfo[pairOfPid[pair]][account];
        user.quantity = user.quantity.add(quantity);
        user.blockNumber = block.number;
        return true;
    }

    function getQuantity(address outputToken, uint256 outputAmount, address anchorToken) public view returns (uint256) {
        uint256 quantity = 0;
        if (outputToken == anchorToken) {
            quantity = outputAmount;
        } else if (IBabyFactory(factory).getPair(outputToken, anchorToken) != address(0)) {
            quantity = IOracle(oracle).consult(outputToken, outputAmount, anchorToken);
        } else {
            uint256 length = getWhitelistLength();
            for (uint256 index = 0; index < length; index++) {
                address intermediate = getWhitelist(index);
                if (factory.getPair(outputToken, intermediate) != address(0) && factory.getPair(intermediate, anchorToken) != address(0)) {
                    uint256 interQuantity = IOracle(oracle).consult(outputToken, outputAmount, intermediate);
                    quantity = IOracle(oracle).consult(intermediate, interQuantity, anchorToken);
                    break;
                }
            }
        }
        return quantity;
    }

    // The user withdraws all the transaction rewards of the pool
    function takerWithdraw() public {
        uint256 userSub;
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            UserInfo storage user = userInfo[pid][msg.sender];
            if (user.quantity > 0) {
                mint(pid);
                // The reward held by the user in this pool
                uint256 userReward = pool.allocMdxAmount.mul(user.quantity).div(pool.quantity);
                pool.quantity = pool.quantity.sub(user.quantity);
                pool.allocMdxAmount = pool.allocMdxAmount.sub(userReward);
                user.quantity = 0;
                user.blockNumber = block.number;
                userSub = userSub.add(userReward);
            }
        }
        if (userSub <= 0) {
            return;
        }
        babyToken.transfer(msg.sender, userSub);
    }

    // Get rewards from users in the current pool
    function getUserReward(uint256 _pid, address _user) public view returns (uint256, uint256){
        require(_pid <= poolInfo.length - 1, "SwapMining: Not find this pool");
        uint256 userSub;
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        if (user.quantity > 0) {
            uint256 blockReward = getBabyReward(pool.lastRewardBlock);
            uint256 mdxReward = blockReward.mul(pool.allocPoint).div(totalAllocPoint);
            userSub = userSub.add((pool.allocMdxAmount.add(mdxReward)).mul(user.quantity).div(pool.quantity));
        }
        //Mdx available to users, User transaction amount
        return (userSub, user.quantity);
    }

    // Get details of the pool
    function getPoolInfo(uint256 _pid) public view returns (address, address, uint256, uint256, uint256, uint256){
        require(_pid <= poolInfo.length - 1, "SwapMining: Not find this pool");
        PoolInfo memory pool = poolInfo[_pid];
        address token0 = IBabyPair(pool.pair).token0();
        address token1 = IBabyPair(pool.pair).token1();
        uint256 mdxAmount = pool.allocMdxAmount;
        uint256 blockReward = getBabyReward(pool.lastRewardBlock);
        uint256 mdxReward = blockReward.mul(pool.allocPoint).div(totalAllocPoint);
        mdxAmount = mdxAmount.add(mdxReward);
        //token0,token1,Pool remaining reward,Total /Current transaction volume of the pool
        return (token0, token1, mdxAmount, pool.totalQuantity, pool.quantity, pool.allocPoint);
    }

    function ownerWithdraw(address _to, uint256 _amount) public onlyOwner {
        safeCakeTransfer(_to, _amount);
    }

    function safeCakeTransfer(address _to, uint256 _amount) internal {
        uint256 balance = babyToken.balanceOf(address(this));
        if (_amount > balance) {
            _amount = balance;
        }
        babyToken.transfer(_to, _amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import '../interfaces/IBabyPair.sol';
import "./SafeMath.sol";

library BabyLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'LibraryLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'LibraryLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'48c8bec5512d397a5d512fbb7d83d515e7b6d91e9838730bd1aa1b16575da7f5'
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IBabyPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'LibraryLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'LibraryLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'LibraryLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'LibraryLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'LibraryLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'LibraryLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'LibraryLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'LibraryLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IBabyFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function expectPairFor(address token0, address token1) external view returns (address);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IBabyPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '../interfaces/IBabyFactory.sol';
import '../interfaces/IBabyRouter.sol';
//import '../libraries/BabyLibrary.sol';
import '../interfaces/IBabyPair.sol';

contract BabySwapFeeV3 is Ownable {
    using SafeMath for uint;
    using Address for address;
    using SafeERC20 for IERC20;

    event NewReceiver(address receiver, uint percent, IERC20 token);
    event NewCaller(address oldCaller, address newCaller);
    event NewSupportToken(address token);
    event DelSupportToken(address token);
    event NewDestroyPercent(uint oldPercent, uint newPercent);
    event Claim(address receiver, address token, uint amount, uint remainAmount);

    IBabyFactory public immutable factory;
    IBabyRouter public immutable router;
    address public immutable middleToken;
    address[] public supportTokenList;
    mapping(address => bool) public supportToken;

    address public constant hole = 0x000000000000000000000000000000000000dEaD;  //destroy address
    address[] public receivers;
    mapping(address => uint) public receiverFees;
    mapping(address => IERC20) public receiverTokens;
    uint public totalPercent;
    uint public constant FEE_BASE = 1e6;
    address public immutable ownerReceiver;                                               //any token can be got by this address

    address public caller;

    function addSupportToken(address _token) external onlyOwner {
        require(_token != address(0), "token address is zero");
        for (uint i = 0; i < supportTokenList.length; i ++) {
            require(supportTokenList[i] != _token, "token already exist");
        }
        //require(!supportToken[_token], "token already supported");
        supportTokenList.push(_token);
        supportToken[_token] = true;
        emit NewSupportToken(_token);
    }

    function delSupportToken(address _token) external onlyOwner {
        uint currentId = 0;
        for (; currentId < supportTokenList.length; currentId ++) {
            if (supportTokenList[currentId] == _token) {
                break;
            }
        }
        require(currentId < supportTokenList.length, "receiver not exist");
        delete supportToken[_token];
        supportTokenList[currentId] = supportTokenList[supportTokenList.length - 1];
        supportTokenList.pop();
        emit DelSupportToken(_token);
    }

    function addReceiver(address _receiver, uint _percent, IERC20 _token) external onlyOwner {
        require(_receiver != address(0), "receiver address is zero");
        require(_percent <= FEE_BASE, "illegal percent");
        for (uint i = 0; i < receivers.length; i ++) {
            require(receivers[i] != _receiver, "receiver already exist");
        }
        require(totalPercent <= FEE_BASE.sub(_percent), "illegal percent");
        totalPercent = totalPercent.add(_percent);
        receivers.push(_receiver);
        receiverFees[_receiver] = _percent;
        receiverTokens[_receiver] = _token;
        emit NewReceiver(_receiver, _percent, _token);
    }

    function delReceiver(address _receiver) external onlyOwner {
        uint currentId = 0;
        for (; currentId < receivers.length; currentId ++) {
            if (receivers[currentId] == _receiver) {
                break;
            }
        }
        require(currentId < receivers.length, "receiver not exist");
        totalPercent = totalPercent.sub(receiverFees[_receiver]);
        delete receiverFees[_receiver];
        delete receiverTokens[_receiver];
        receivers[currentId] = receivers[receivers.length - 1];
        receivers.pop();
        emit NewReceiver(_receiver, 0, IERC20(address(0)));
    }

    function setCaller(address _caller) external onlyOwner {
        emit NewCaller(caller, _caller);
        caller = _caller; 
    }
    modifier onlyOwnerOrCaller() {
        require(owner() == _msgSender() || caller == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor(IBabyFactory _factory, IBabyRouter _router, address _middleToken, address _ownerReceiver) {
        require(address(_factory) != address(0), "factory address is zero");
        factory = _factory;
        require(address(_router) != address(0), "router address is zero");
        router = _router;
        require(_middleToken != address(0), "middleToken address is zero");
        middleToken = _middleToken;
        require(_ownerReceiver != address(0), "ownerReceiver address is zero");
        ownerReceiver = _ownerReceiver;
    }

    function canRemove(IBabyPair pair) internal view returns (bool) {
        address token0 = pair.token0();
        address token1 = pair.token1();
        uint balance0 = IERC20(token0).balanceOf(address(pair));
        uint balance1 = IERC20(token1).balanceOf(address(pair));
        uint totalSupply = pair.totalSupply();
        if (totalSupply == 0) {
            return false;
        }
        uint liquidity = pair.balanceOf(address(this));
        uint amount0 = liquidity.mul(balance0) / totalSupply; // using balances ensures pro-rata distribution
        uint amount1 = liquidity.mul(balance1) / totalSupply; // using balances ensures pro-rata distribution
        if (amount0 == 0 || amount1 == 0) {
            return false;
        }
        return true;
    }

    function doHardwork(address[] calldata pairs, uint minAmount) external onlyOwnerOrCaller {
        for (uint i = 0; i < pairs.length; i ++) {
            IBabyPair pair = IBabyPair(pairs[i]);
            if (!supportToken[pair.token0()] && !supportToken[pair.token1()]) {
                continue;
            }
            uint balance = pair.balanceOf(address(this));
            if (balance == 0) {
                continue;
            }
            if (balance < minAmount) {
                continue;
            }
            if (!canRemove(pair)) {
                continue;
            }
            pair.approve(address(router), balance);
            router.removeLiquidity(
                pair.token0(),
                pair.token1(),
                balance,
                0,
                0,
                address(this),
                block.timestamp
            );
            address swapToken = supportToken[pair.token0()] ? pair.token1() : pair.token0();
            address targetToken = supportToken[pair.token0()] ? pair.token0() : pair.token1();
            address[] memory path = new address[](2);
            path[0] = swapToken; path[1] = targetToken;
            balance = IERC20(swapToken).balanceOf(address(this));
            IERC20(swapToken).approve(address(router), balance);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                balance,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
        claimAll();
    }

    function claimAll() public onlyOwnerOrCaller {
        address[] memory path = new address[](2);
        uint balance = 0;
        for (uint i = 0; i < supportTokenList.length; i ++) {
            IERC20 token = IERC20(supportTokenList[i]);
            balance = token.balanceOf(address(this));
            if (balance == 0) {
                continue;
            }
            if (address(token) != middleToken) {
                path[0] = address(token);path[1] = middleToken;
                IERC20(token).approve(address(router), balance);
                router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    balance,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
            }
        }
        balance = IERC20(middleToken).balanceOf(address(this));
        uint claimAmount = 0;
        for (uint i = 0; i < receivers.length; i ++) {
            uint amount = balance.mul(receiverFees[receivers[i]]).div(FEE_BASE);
            if (amount > 0) {
                IERC20 token = receiverTokens[receivers[i]];
                if (address(token) == address(0)) {
                    token = IERC20(middleToken);
                }
                if (address(token) == middleToken) {
                    IERC20(middleToken).safeTransfer(receivers[i], amount);
                } else {
                    path[0] = middleToken;path[1] = address(token);
                    IERC20(middleToken).approve(address(router), amount);
                    router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        amount,
                        0,
                        path,
                        receivers[i],
                        block.timestamp
                    );
                }
                claimAmount = claimAmount.add(amount);
                emit Claim(receivers[i], address(token), amount, balance.sub(claimAmount));
            }
        }
    }

    function transferOut(address token, uint amount) external onlyOwner {
        IERC20 erc20 = IERC20(token);
        uint balance = erc20.balanceOf(address(this));
        if (balance < amount) {
            amount = balance;
        }
        require(ownerReceiver != address(0), "ownerReceiver is zero");
        SafeERC20.safeTransfer(erc20, ownerReceiver, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '../interfaces/IBabyFactory.sol';
import '../interfaces/IBabyRouter.sol';
//import '../libraries/BabyLibrary.sol';
import '../interfaces/IBabyPair.sol';

contract BabySwapFeeV2 is Ownable {
    using SafeMath for uint;
    using Address for address;
    using SafeERC20 for IERC20;

    event NewReceiver(address receiver, uint percent, IERC20 token);
    event NewCaller(address oldCaller, address newCaller);
    event NewSupportToken(address token);
    event DelSupportToken(address token);
    event NewDestroyPercent(uint oldPercent, uint newPercent);

    IBabyFactory public immutable factory;
    IBabyRouter public immutable router;
    address public immutable middleToken;
    address[] public supportTokenList;
    mapping(address => bool) public supportToken;

    address public constant hole = 0x000000000000000000000000000000000000dEaD;  //destroy address
    address[] public receivers;
    mapping(address => uint) public receiverFees;
    mapping(address => IERC20) public receiverTokens;
    uint public totalPercent;
    uint public constant FEE_BASE = 1e6;
    address public immutable ownerReceiver;                                               //any token can be got by this address

    address public caller;
    address public immutable destroyToken;
    uint public destroyPercent;

    function addSupportToken(address _token) external onlyOwner {
        require(_token != address(0), "token address is zero");
        for (uint i = 0; i < supportTokenList.length; i ++) {
            require(supportTokenList[i] != _token, "token already exist");
        }
        //require(!supportToken[_token], "token already supported");
        supportTokenList.push(_token);
        supportToken[_token] = true;
        emit NewSupportToken(_token);
    }

    function delSupportToken(address _token) external onlyOwner {
        uint currentId = 0;
        for (; currentId < supportTokenList.length; currentId ++) {
            if (supportTokenList[currentId] == _token) {
                break;
            }
        }
        require(currentId < supportTokenList.length, "receiver not exist");
        delete supportToken[_token];
        supportTokenList[currentId] = supportTokenList[supportTokenList.length - 1];
        supportTokenList.pop();
        emit DelSupportToken(_token);
    }

    function addReceiver(address _receiver, uint _percent, IERC20 _token) external onlyOwner {
        require(_receiver != address(0), "receiver address is zero");
        require(_percent <= FEE_BASE, "illegal percent");
        for (uint i = 0; i < receivers.length; i ++) {
            require(receivers[i] != _receiver, "receiver already exist");
        }
        require(totalPercent <= FEE_BASE.sub(_percent), "illegal percent");
        totalPercent = totalPercent.add(_percent);
        receivers.push(_receiver);
        receiverFees[_receiver] = _percent;
        receiverTokens[_receiver] = _token;
        emit NewReceiver(_receiver, _percent, _token);
    }

    function delReceiver(address _receiver) external onlyOwner {
        uint currentId = 0;
        for (; currentId < receivers.length; currentId ++) {
            if (receivers[currentId] == _receiver) {
                break;
            }
        }
        require(currentId < receivers.length, "receiver not exist");
        totalPercent = totalPercent.sub(receiverFees[_receiver]);
        delete receiverFees[_receiver];
        delete receiverTokens[_receiver];
        receivers[currentId] = receivers[receivers.length - 1];
        receivers.pop();
        emit NewReceiver(_receiver, 0, IERC20(address(0)));
    }

    function setCaller(address _caller) external onlyOwner {
        emit NewCaller(caller, _caller);
        caller = _caller; 
    }

    function setDestroyPercent(uint _percent) external onlyOwner {
        require(_percent <= FEE_BASE, "illegam percent");
        emit NewDestroyPercent(destroyPercent, _percent);
        destroyPercent = _percent;
    }

    modifier onlyOwnerOrCaller() {
        require(owner() == _msgSender() || caller == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor(IBabyFactory _factory, IBabyRouter _router, address _middleToken, address _destroyToken, address _ownerReceiver) {
        require(address(_factory) != address(0), "factory address is zero");
        factory = _factory;
        require(address(_router) != address(0), "router address is zero");
        router = _router;
        require(_middleToken != address(0), "middleToken address is zero");
        middleToken = _middleToken;
        require(_destroyToken != address(0), "destroyToken address is zero");
        destroyToken = _destroyToken;
        require(_ownerReceiver != address(0), "ownerReceiver address is zero");
        ownerReceiver = _ownerReceiver;
    }

    function canRemove(IBabyPair pair) internal view returns (bool) {
        address token0 = pair.token0();
        address token1 = pair.token1();
        uint balance0 = IERC20(token0).balanceOf(address(pair));
        uint balance1 = IERC20(token1).balanceOf(address(pair));
        uint totalSupply = pair.totalSupply();
        if (totalSupply == 0) {
            return false;
        }
        uint liquidity = pair.balanceOf(address(this));
        uint amount0 = liquidity.mul(balance0) / totalSupply; // using balances ensures pro-rata distribution
        uint amount1 = liquidity.mul(balance1) / totalSupply; // using balances ensures pro-rata distribution
        if (amount0 == 0 || amount1 == 0) {
            return false;
        }
        return true;
    }

    function doHardwork(address[] calldata pairs, uint minAmount) external onlyOwnerOrCaller {
        for (uint i = 0; i < pairs.length; i ++) {
            IBabyPair pair = IBabyPair(pairs[i]);
            if (!supportToken[pair.token0()] && !supportToken[pair.token1()]) {
                continue;
            }
            uint balance = pair.balanceOf(address(this));
            if (balance == 0) {
                continue;
            }
            if (balance < minAmount) {
                continue;
            }
            if (!canRemove(pair)) {
                continue;
            }
            pair.approve(address(router), balance);
            router.removeLiquidity(
                pair.token0(),
                pair.token1(),
                balance,
                0,
                0,
                address(this),
                block.timestamp
            );
            address swapToken = supportToken[pair.token0()] ? pair.token1() : pair.token0();
            address targetToken = supportToken[pair.token0()] ? pair.token0() : pair.token1();
            address[] memory path = new address[](2);
            path[0] = swapToken; path[1] = targetToken;
            balance = IERC20(swapToken).balanceOf(address(this));
            IERC20(swapToken).approve(address(router), balance);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                balance,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function destroyAll() external onlyOwner {
        address[] memory path = new address[](2);
        uint balance = 0;
        for (uint i = 0; i < supportTokenList.length; i ++) {
            IERC20 token = IERC20(supportTokenList[i]);
            balance = token.balanceOf(address(this));
            if (balance == 0) {
                continue;
            }
            if (address(token) != middleToken) {
                path[0] = address(token);path[1] = middleToken;
                IERC20(token).approve(address(router), balance);
                router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    balance,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
            }
        }
        balance = IERC20(middleToken).balanceOf(address(this));
        uint feeAmount = balance.mul(FEE_BASE.sub(destroyPercent)).div(FEE_BASE);
        for (uint i = 0; i < receivers.length; i ++) {
            uint amount = feeAmount.mul(receiverFees[receivers[i]]).div(FEE_BASE);
            if (amount > 0) {
                IERC20 token = receiverTokens[receivers[i]];
                if (address(token) == address(0)) {
                    token = IERC20(middleToken);
                }
                if (address(token) == middleToken) {
                    IERC20(middleToken).safeTransfer(receivers[i], amount);
                } else {
                    path[0] = middleToken;path[1] = address(token);
                    IERC20(middleToken).approve(address(router), amount);
                    router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        amount,
                        0,
                        path,
                        receivers[i],
                        block.timestamp
                    );
                }
            }
        }
        uint destroyAmount = balance.sub(feeAmount);
        path[0] = middleToken;path[1] = destroyToken;
        IERC20(middleToken).approve(address(router), destroyAmount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            destroyAmount,
            0,
            path,
            hole,
            block.timestamp
        );
    }

    function transferOut(address token, uint amount) external onlyOwner {
        IERC20 erc20 = IERC20(token);
        uint balance = erc20.balanceOf(address(this));
        if (balance < amount) {
            amount = balance;
        }
        require(ownerReceiver != address(0), "ownerReceiver is zero");
        SafeERC20.safeTransfer(erc20, ownerReceiver, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

import './BabyPair.sol';
import '../libraries/BabyLibrary.sol';
import '../interfaces/IBabyRouter.sol';
import '../interfaces/IBabyFactory.sol';
import '../interfaces/IBabyPair.sol';
import '../libraries/SafeMath.sol';
import '../token/SafeBEP20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '../libraries/Address.sol';

contract BabySwapFee is Ownable {
    using SafeMath for uint;
    using Address for address;

    address public constant hole = 0x000000000000000000000000000000000000dEaD;
    address public bottle;
    address public vault;
    IBabyRouter public immutable router;
    IBabyFactory public immutable factory;
    address public immutable WBNB;
    address public immutable BABY;
    address public immutable USDT;
    address public receiver;
    address public caller;

    constructor(address bottle_, address vault_, IBabyRouter router_, IBabyFactory factory_, address WBNB_, address BABY_, address USDT_, address receiver_, address caller_) {
        bottle = bottle_; 
        vault = vault_;
        router = router_;
        factory = factory_;
        WBNB = WBNB_;
        BABY = BABY_;
        USDT = USDT_;
        receiver = receiver_;
        caller = caller_;
    }

    function setCaller(address newCaller_) external onlyOwner {
        require(newCaller_ != address(0), "caller is zero");
        caller = newCaller_;
    }

    function setVault(address newVault_) external onlyOwner {
        require(newVault_ != address(0), "vault is zero");
        vault = newVault_;
    }

    function setBottle(address newBottle_) external onlyOwner {
        require(newBottle_ != address(0), "vault is zero");
        bottle = newBottle_;
    }

    function setReceiver(address newReceiver_) external onlyOwner {
        require(newReceiver_ != address(0), "receiver is zero");
        receiver = newReceiver_;
    }

    function transferToVault(IBabyPair pair, uint balance) internal returns (uint balanceRemained) {
        uint balanceUsed = balance.div(3);
        balanceRemained = balance.sub(balanceUsed);
        SafeBEP20.safeTransfer(IBEP20(address(pair)), vault, balanceUsed);
    }

    function transferToBottle(address token, uint balance) internal returns (uint balanceRemained) {
        uint balanceUsed = balance.div(2);
        balanceRemained = balance.sub(balanceUsed);
        SafeBEP20.safeTransfer(IBEP20(token), bottle, balanceUsed);
    }

    function doHardwork(address[] calldata pairs, uint minAmount) external {
        require(msg.sender == caller, "illegal caller");
        for (uint i = 0; i < pairs.length; i ++) {
            IBabyPair pair = IBabyPair(pairs[i]);
            if (pair.token0() != USDT && pair.token1() != USDT) {
                continue;
            }
            uint balance = pair.balanceOf(address(this));
            if (balance == 0) {
                continue;
            }
            if (balance < minAmount) {
                continue;
            }
            balance = transferToVault(pair, balance);
            address token = pair.token0() != USDT ? pair.token0() : pair.token1();
            pair.approve(address(router), balance);
            router.removeLiquidity(
                token,
                USDT,
                balance,
                0,
                0,
                address(this),
                block.timestamp
            );
            address[] memory path = new address[](2);
            path[0] = token;path[1] = USDT;
            balance = IBEP20(token).balanceOf(address(this));
            IBEP20(token).approve(address(router), balance);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                balance,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function destroyAll() external onlyOwner {
        uint balance = IBEP20(USDT).balanceOf(address(this));
        balance = transferToBottle(USDT, balance);
        address[] memory path = new address[](2);
        path[0] = USDT;path[1] = BABY;
        balance = IBEP20(USDT).balanceOf(address(this));
        IBEP20(USDT).approve(address(router), balance);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            balance,
            0,
            path,
            address(this),
            block.timestamp
        );
        balance = IBEP20(BABY).balanceOf(address(this));
        SafeBEP20.safeTransfer(IBEP20(BABY), hole, balance);
    }

    function transferOut(address token, uint amount) external {
        IBEP20 bep20 = IBEP20(token);
        uint balance = bep20.balanceOf(address(this));
        if (balance < amount) {
            amount = balance;
        }
        SafeBEP20.safeTransfer(bep20, receiver, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

import '../interfaces/IBabyPair.sol';
import '../token/BabyERC20.sol';
import '../libraries/Math.sol';
import '../libraries/UQ112x112.sol';
import '../interfaces/IERC20.sol';
import '../interfaces/IBabyFactory.sol';
import '../interfaces/IBabyCallee.sol';

contract BabyPair is BabyERC20 {
    using SafeMath  for uint;
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;
    address public token0;
    address public token1;

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'Baby: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Baby: TRANSFER_FAILED');
    }

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor() {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, 'Baby: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'Baby: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IBabyFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint denominator = rootK.mul(3).add(rootKLast);
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'Baby: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external lock returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                // gas savings
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        require(_totalSupply != 0, "influence balance");
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'Baby: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        require(amount0Out > 0 || amount1Out > 0, 'Baby: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'Baby: INSUFFICIENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        { // scope for _token{0,1}, avoids stack too deep errors
        address _token0 = token0;
        address _token1 = token1;
        require(to != _token0 && to != _token1, 'Baby: INVALID_TO');
        if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
        if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
        if (data.length > 0) IBabyCallee(to).babyCall(msg.sender, amount0Out, amount1Out, data);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'Baby: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(2));
        uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(2));
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'Baby: K');
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // force balances to match reserves
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
    }

    // force reserves to match balances
    function sync() external lock {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

import '../interfaces/IBabyERC20.sol';
import '../libraries/SafeMath.sol';

contract BabyERC20 is IBabyERC20 {
    using SafeMath for uint256;

    string public override constant name = 'Baby LPs';
    string public override constant symbol = 'Baby-LP';
    uint8 public override constant decimals = 18;
    uint  public override totalSupply;
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;

    bytes32 public override DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public override constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) public override nonces;

    //event Approval(address indexed owner, address indexed spender, uint value);
    //event Transfer(address indexed from, address indexed to, uint value);

    constructor() {
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external override {
        require(deadline >= block.timestamp, 'Baby: EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'Baby: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

// a library for performing various math operations

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IBabyCallee {
    function babyCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity =0.7.4;
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IBEP20.sol";
import "../libraries/SafeMath.sol";
import "../libraries/Address.sol";

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has ids similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

contract IFO is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    struct IFOInfo {
        uint256 id;
        IBEP20 exhibits;
        IBEP20 currency;
        address recipient;
        uint256 price;
        uint256 totalSupply;
        uint256 totalAmount;
        uint256 startTime;
        uint256 duration;
        uint256 hardcap;
        uint256 incomeTotal;
        mapping(address => uint256) payAmount;
        mapping(address => bool) isCollected;
    }
    uint256 public constant MAX = uint256(-1);
    uint256 public constant ROUND = 10**18;
    uint256 public idIncrement = 0;
    mapping(uint256 => IFOInfo) public ifoInfos;
    mapping(uint256 => bool) private isWithdraw;
    event IFOLaunch(
        uint256 id,
        address exhibits,
        address currency,
        address recipient,
        uint256 price,
        uint256 hardcap,
        uint256 totalSupply,
        uint256 totalAmount,
        uint256 startTime,
        uint256 duration
    );
    event Staked(uint256 id, address account, uint256 value);
    event Collected(
        uint256 id,
        address account,
        uint256 ifoValue,
        uint256 fee,
        uint256 backValue
    );
    event IFOWithdraw(uint256 id, uint256 receiveValue, uint256 leftValue);

    event IFORemove(uint256 id);

    function launch(
        IBEP20 exhibits,
        IBEP20 currency,
        address recipient,
        uint256 totalAmount,
        uint256 totalSupply,
        uint256 hardcap,
        uint256 startTime,
        uint256 duration
    ) external onlyOwner {
        require(
            address(recipient) != address(0),
            "IFO: recipient address cannot be 0"
        );
        require(
            startTime > block.timestamp,
            "IFO: startTime should be later than now"
        );
        require(
            block.timestamp >
                ifoInfos[idIncrement].startTime.add(
                    ifoInfos[idIncrement].duration
                ),
            "IFO: ifo is not over yet."
        );
        require(
            address(exhibits) != address(0),
            "IFO: exhibits address cannot be 0"
        );
        require(
            address(currency) != address(0),
            "IFO: currency address cannot be 0"
        );
  

        idIncrement = idIncrement.add(1);
        IFOInfo storage ifo = ifoInfos[idIncrement];
        ifo.id = idIncrement;
        ifo.exhibits = exhibits;
        ifo.currency = currency;
        ifo.recipient = recipient;
        ifo.totalAmount = totalAmount;
        ifo.price = totalAmount.mul(ROUND).div(totalSupply);
        ifo.hardcap = hardcap;
        ifo.totalSupply = totalSupply;
        ifo.startTime = startTime;
        ifo.duration = duration;

        exhibits.safeTransferFrom(msg.sender, address(this), totalSupply);
        emit IFOLaunch(
            idIncrement,
            address(exhibits),
            address(currency),
            recipient,
            ifo.price,
            hardcap,
            totalSupply,
            totalAmount,
            startTime,
            duration
        );
    }

    function removeIFO() external onlyOwner {
        require(
            ifoInfos[idIncrement].startTime > block.timestamp,
            "IFO: there is no ifo that can be deleted"
        );
        ifoInfos[idIncrement].exhibits.safeTransfer(
            msg.sender,
            ifoInfos[idIncrement].totalSupply
        );
        delete ifoInfos[idIncrement];
        emit IFORemove(idIncrement);
        idIncrement = idIncrement.sub(1);
    }

    function withdraw(uint256 id) external onlyOwner {
        IFOInfo storage record = ifoInfos[id];
        require(id <= idIncrement && id > 0, "IFO: ifo that does not exist.");
        require(!isWithdraw[id], "IFO: cannot claim repeatedly.");
        require(
            block.timestamp > record.startTime.add(record.duration),
            "IFO: ifo is not over yet."
        );

        uint256 receiveValue;
        uint256 backValue;

        isWithdraw[id] = true;

        uint256 prop = record.incomeTotal.mul(ROUND).mul(ROUND).div(
            record.totalSupply.mul(record.price)
        );
        if (prop >= ROUND) {
            receiveValue = record.totalSupply.mul(record.price).div(ROUND);
            record.currency.safeTransfer(record.recipient, receiveValue);
        } else {
            receiveValue = record.incomeTotal;
            record.currency.safeTransfer(record.recipient, receiveValue);
            backValue = record.totalSupply.sub(
                record.totalSupply.mul(prop).div(ROUND)
            );
            record.exhibits.safeTransfer(record.recipient, backValue);
        }

        emit IFOWithdraw(id, receiveValue, backValue);
    }

    function stake(uint256 value) external {
        require(idIncrement > 0, "IFO: ifo that does not exist.");
        IFOInfo storage record = ifoInfos[idIncrement];
        require(
            block.timestamp > record.startTime &&
                block.timestamp < record.startTime.add(record.duration),
            "IFO: ifo is not in progress."
        );
        require(
            record.payAmount[msg.sender].add(value) <= record.hardcap,
            "IFO: limit exceeded"
        );

        record.payAmount[msg.sender] = record.payAmount[msg.sender].add(value);
        record.incomeTotal = record.incomeTotal.add(value);
        record.currency.safeTransferFrom(msg.sender, address(this), value);
        emit Staked(idIncrement, msg.sender, value);
    }

    function available(address account, uint256 id)
        public
        view
        returns (uint256 _ifoAmount, uint256 _sendBack)
    {
        IFOInfo storage record = ifoInfos[id];
        require(id <= idIncrement && id > 0, "IFO: ifo that does not exist.");

        uint256 prop = record.incomeTotal.mul(ROUND).mul(ROUND).div(
            record.totalSupply.mul(record.price)
        );

        if (prop > ROUND) {
            _ifoAmount = record
                .payAmount[account]
                .mul(ROUND)
                .mul(ROUND)
                .div(prop)
                .div(record.price);
            _sendBack = record
                .payAmount[account]
                .mul(ROUND.sub(ROUND.mul(ROUND).add(prop).sub(1).div(prop)))
                .div(ROUND);
        } else {
            _ifoAmount = record.payAmount[account].mul(ROUND).div(record.price);
        }
    }

    function userPayValue(uint256 id, address account)
        public
        view
        returns (uint256)
    {
        return ifoInfos[id].payAmount[account];
    }

    function isCollected(uint256 id, address account)
        public
        view
        returns (bool)
    {
        return ifoInfos[id].isCollected[account];
    }

    function collect(uint256 id) external {
        require(id <= idIncrement && id > 0, "IFO: ifo that does not exist.");
        IFOInfo storage record = ifoInfos[id];
        require(
            block.timestamp > ifoInfos[id].startTime.add(record.duration),
            "IFO: ifo is not over yet."
        );
        require(
            !record.isCollected[msg.sender],
            "IFO: cannot claim repeatedly."
        );

        uint256 ifoAmount;
        uint256 sendBack;

        record.isCollected[msg.sender] = true;

        (ifoAmount, sendBack) = available(msg.sender, id);

        record.exhibits.safeTransfer(msg.sender, ifoAmount);
        uint256 fee;
        if (sendBack > 0) {
            uint256 rateFee = getFeeRate(id);
            fee = sendBack.mul(rateFee).div(ROUND);
            if (fee > 0) {
                record.currency.safeTransfer(owner(), fee);
                sendBack = sendBack.sub(fee);
            }
            record.currency.safeTransfer(msg.sender, sendBack);
        }

        emit Collected(id, msg.sender, ifoAmount, fee, sendBack);
    }

    function getFeeRate(uint256 id) public view returns (uint256) {
        if (ifoInfos[id].hardcap != MAX) {
            return 0;
        }
        uint256 x = ifoInfos[id].incomeTotal.div(ifoInfos[id].totalAmount);
        if (x >= 500) {
            return ROUND.mul(20).div(10000);
        } else if (x >= 250) {
            return ROUND.mul(25).div(10000);
        } else if (x >= 100) {
            return ROUND.mul(30).div(10000);
        } else if (x >= 50) {
            return ROUND.mul(50).div(10000);
        } else {
            return ROUND.mul(100).div(10000);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/BabyLibrarySmartRouter.sol";
import "../interfaces/IBabySmartRouter.sol";
import "../libraries/TransferHelper.sol";
import "../interfaces/ISwapMining.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IWETH.sol";
import "./BabyBaseRouter.sol";

contract BabySmartRouter is BabyBaseRouter, IBabySmartRouter {
    using SafeMath for uint;

    address immutable public normalRouter;

    constructor(
        address _factory, 
        address _WETH, 
        address _swapMining, 
        address _routerFeeReceiver,
        address _normalRouter
    ) BabyBaseRouter(_factory, _WETH, _swapMining, _routerFeeReceiver) {
        normalRouter = _normalRouter;
    }

    function routerFee(address _factory, address _user, address _token, uint _amount) internal returns (uint) {
        if (routerFeeReceiver != address(0) && _factory == factory) {
            uint fee = _amount.mul(1).div(1000);
            if (fee > 0) {
                if (_user == address(this)) {
                    TransferHelper.safeTransfer(_token, routerFeeReceiver, fee);
                } else {
                    TransferHelper.safeTransferFrom(
                        _token, msg.sender, routerFeeReceiver, fee
                    );
                }
                _amount = _amount.sub(fee);
            }
        }
        return _amount;
    }

    fallback() external payable {
        babyRouterDelegateCall(msg.data);
    }

    function babyRouterDelegateCall(bytes memory data) internal {
        (bool success, ) = normalRouter.delegatecall(data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 { revert(free_mem_ptr, returndatasize()) }
            default { return(free_mem_ptr, returndatasize()) }
        }
    }

    function _swap(
        uint[] memory amounts, 
        address[] memory path, 
        address[] memory factories, 
        address _to
    ) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = BabyLibrarySmartRouter.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            if (swapMining != address(0)) {
                ISwapMining(swapMining).swap(msg.sender, input, output, amountOut);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? address(this) : _to;
            IBabyPair(BabyLibrarySmartRouter.pairFor(factories[i], input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
            if (i < path.length - 2) {
                amounts[i + 1] = routerFee(factories[i + 1], address(this), path[i + 1], amounts[i + 1]);
                TransferHelper.safeTransfer(path[i + 1], BabyLibrarySmartRouter.pairFor(factories[i + 1], output, path[i + 2]), amounts[i + 1]);
            }
        }
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address[] memory factories,
        uint[] memory fees,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = BabyLibrarySmartRouter.getAggregationAmountsOut(factories, fees, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        amounts[0] = routerFee(factories[0], msg.sender, path[0], amounts[0]);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, factories, to);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] memory path,
        address[] memory factories,
        uint[] memory fees,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = BabyLibrarySmartRouter.getAggregationAmountsIn(factories, fees, amountOut, path);
        require(amounts[0] <= amountInMax, 'BabyRouter: EXCESSIVE_INPUT_AMOUNT');
        amounts[0] = routerFee(factories[0], msg.sender, path[0], amounts[0]);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, factories, to);
    }

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] memory path, 
        address[] memory factories, 
        uint[] memory fees, 
        address to, 
        uint deadline
    ) external virtual override payable ensure(deadline) returns (uint[] memory amounts) {
        require(path[0] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrarySmartRouter.getAggregationAmountsOut(factories, fees,  msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        amounts[0] = routerFee(factories[0], address(this), path[0], amounts[0]);
        assert(IWETH(WETH).transfer(BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amounts[0]));
        _swap(amounts, path, factories, to);
    }

    function swapTokensForExactETH(
        uint amountOut, 
        uint amountInMax, 
        address[] memory path, 
        address[] memory factories, 
        uint[] memory fees, 
        address to, 
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path[path.length - 1] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrarySmartRouter.getAggregationAmountsIn(factories, fees, amountOut, path);
        require(amounts[0] <= amountInMax, 'BabyRouter: EXCESSIVE_INPUT_AMOUNT');
        amounts[0] = routerFee(factories[0], msg.sender, path[0], amounts[0]);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, factories, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] memory path, 
        address[] memory factories, 
        uint[] memory fees, 
        address to, 
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path[path.length - 1] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrarySmartRouter.getAggregationAmountsOut(factories, fees, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        amounts[0] = routerFee(factories[0], msg.sender, path[0], amounts[0]);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, factories, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapETHForExactTokens(
        uint amountOut, 
        address[] memory path, 
        address[] memory factories, 
        uint[] memory fees, 
        address to, 
        uint deadline
    ) external virtual override payable ensure(deadline) returns (uint[] memory amounts) {
        require(path[0] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrarySmartRouter.getAggregationAmountsIn(factories, fees, amountOut, path);
        require(amounts[0] <= msg.value, 'BabyRouter: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        uint oldAmount = amounts[0];
        amounts[0] = routerFee(factories[0], address(this), path[0], amounts[0]);
        assert(IWETH(WETH).transfer(BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amounts[0]));
        _swap(amounts, path, factories, to);
        // refund dust eth, if any
        if (msg.value > oldAmount) TransferHelper.safeTransferETH(msg.sender, msg.value.sub(oldAmount));
    }

    function _swapSupportingFeeOnTransferTokens(
        address[] memory path, 
        address[] memory factories, 
        uint[] memory fees, 
        address _to
    ) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = BabyLibrarySmartRouter.sortTokens(input, output);
            IBabyPair pair = IBabyPair(BabyLibrarySmartRouter.pairFor(factories[i], input, output));
            //uint amountInput;
            //uint amountOutput;
            uint[] memory amounts = new uint[](2);
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amounts[0] = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            amounts[1] = BabyLibrarySmartRouter.getAmountOutWithFee(amounts[0], reserveInput, reserveOutput, fees[i]);
            }
            if (swapMining != address(0)) {
                ISwapMining(swapMining).swap(msg.sender, input, output, amounts[1]);
            }
            (amounts[0], amounts[1]) = input == token0 ? (uint(0), amounts[1]) : (amounts[1], uint(0));
            address to = i < path.length - 2 ? address(this) : _to;
            pair.swap(amounts[0], amounts[1], to, new bytes(0));
            if (i < path.length - 2) {
                routerFee(factories[i + 1], address(this), output, IERC20(output).balanceOf(address(this)));
                TransferHelper.safeTransfer(path[i + 1], BabyLibrarySmartRouter.pairFor(factories[i + 1], output, path[i + 2]), IERC20(output).balanceOf(address(this)));
            }
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address[] memory factories,
        uint[] memory fees,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        amountIn = routerFee(factories[0], msg.sender, path[0], amountIn);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, factories, fees,  to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'BabyRouter:INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] memory path,
        address[] memory factories,
        uint[] memory fees,
        address to,
        uint deadline
    ) external virtual override payable ensure(deadline) {
        require(path[0] == WETH, 'BabyRouter');
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        amountIn = routerFee(factories[0], address(this), path[0], amountIn);
        assert(IWETH(WETH).transfer(BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, factories, fees, to);
        uint balanceAfter = IERC20(path[path.length - 1]).balanceOf(to);
        require(
            balanceAfter.sub(balanceBefore) >= amountOutMin,
            'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address[] memory factories,
        uint[] memory fees,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        require(path[path.length - 1] == WETH, 'BabyRouter: INVALID_PATH');
        amountIn = routerFee(factories[0], msg.sender, path[0], amountIn);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, factories, fees, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import '../interfaces/IBabyFactory.sol';
import '../interfaces/IBabyPair.sol';
import "./SafeMath.sol";

library BabyLibrarySmartRouter {
    using SafeMath for uint;

    uint constant FEE_BASE = 1000000;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'BabyLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'BabyLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal view returns (address pair) {
        return IBabyFactory(factory).getPair(tokenA, tokenB);
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IBabyPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'BabyLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'BabyLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'BabyLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BabyLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountOutWithFee(uint amountIn, uint reserveIn, uint reserveOut, uint fee) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'BabyLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BabyLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(FEE_BASE.sub(fee));
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(FEE_BASE).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'BabyLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BabyLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountInWithFee(uint amountOut, uint reserveIn, uint reserveOut, uint fee) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'BabyLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BabyLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(FEE_BASE);
        uint denominator = reserveOut.sub(amountOut).mul(FEE_BASE.sub(fee));
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'BabyLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAggregationAmountsOut(address[] memory factories, uint[] memory fees, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2 && path.length - 1 == factories.length && factories.length == fees.length, 'BabyLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factories[i], path[i], path[i + 1]);
            amounts[i + 1] = getAmountOutWithFee(amounts[i], reserveIn, reserveOut, fees[i]);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'BabyLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAggregationAmountsIn(address[] memory factories, uint[] memory fees, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2 && path.length - 1 == factories.length && factories.length == fees.length, 'BabyLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factories[i - 1], path[i - 1], path[i]);
            amounts[i - 1] = getAmountInWithFee(amounts[i], reserveIn, reserveOut, fees[i - 1]);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

interface IBabySmartRouter {

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address[] calldata factories,
        uint[] calldata fees,
        address to,
        uint deadline
    ) external  returns (uint[] calldata amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address[] calldata factories,
        uint[] calldata fees,
        address to,
        uint deadline
    ) external  returns (uint[] calldata amounts);

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address[] calldata factories, 
        uint[] calldata fees, 
        address to, 
        uint deadline
    ) external  payable returns (uint[] calldata amounts);

    function swapTokensForExactETH(
        uint amountOut, 
        uint amountInMax, 
        address[] calldata path, 
        address[] calldata factories, 
        uint[] calldata fees, 
        address to, 
        uint deadline
    ) external  returns (uint[] calldata amounts);

    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address[] calldata factories, 
        uint[] calldata fees, 
        address to, 
        uint deadline
    ) external  returns (uint[] calldata amounts);

    function swapETHForExactTokens(
        uint amountOut, 
        address[] calldata path, 
        address[] calldata factories, 
        uint[] calldata fees, 
        address to, 
        uint deadline
    ) external  payable returns (uint[] calldata amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address[] calldata factories,
        uint[] calldata fees,
        address to,
        uint deadline
    ) external ;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address[] calldata factories,
        uint[] calldata fees,
        address to,
        uint deadline
    ) external  payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address[] calldata factories,
        uint[] calldata fees,
        address to,
        uint deadline
    ) external ;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

interface ISwapMining {
    function swap(address account, address input, address output, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IBabyBaseRouter.sol";
import "../libraries/SafeMath.sol";

contract BabyBaseRouter is IBabyBaseRouter, Ownable {
    using SafeMath for uint;

    address public immutable override factory;
    address public immutable override WETH;
    address public override swapMining;
    address public override routerFeeReceiver;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'BabyRouter: EXPIRED');
        _;
    }

    function setSwapMining(address _swapMininng) public onlyOwner {
        swapMining = _swapMininng;
    }
    
    function setRouterFeeReceiver(address _receiver) public onlyOwner {
        routerFeeReceiver = _receiver;
    }

    constructor(address _factory, address _WETH, address _swapMining, address _routerFeeReceiver) {
        factory = _factory;
        WETH = _WETH;
        swapMining = _swapMining;
        routerFeeReceiver = _routerFeeReceiver;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

interface IBabyBaseRouter {

    function factory() external view returns (address);
    function WETH() external view returns (address);
    function swapMining() external view returns (address);
    function routerFeeReceiver() external view returns(address);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

import "../interfaces/IBabyNormalRouter.sol";
import "../libraries/TransferHelper.sol";
import "../interfaces/IBabyFactory.sol";
import "../interfaces/ISwapMining.sol";
import "../libraries/BabyLibrary.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IWETH.sol";
import "./BabyBaseRouter.sol";

contract BabyNormalRouter is BabyBaseRouter, IBabyNormalRouter {
    using SafeMath for uint;

    constructor(
        address _factory, 
        address _WETH, 
        address _swapMining,
        address _routerFeeReceiver
    ) BabyBaseRouter(_factory, _WETH, _swapMining, _routerFeeReceiver) {
    }

    function routerFee(address _user, address _token, uint _amount) internal returns (uint) {
        if (routerFeeReceiver != address(0)) {
            uint fee = _amount.mul(1).div(1000);
            if (fee > 0) {
                if (_user == address(this)) {
                    TransferHelper.safeTransfer(_token, routerFeeReceiver, fee);
                } else {
                    TransferHelper.safeTransferFrom(
                        _token, msg.sender, routerFeeReceiver, fee
                    );
                }
                _amount = _amount.sub(fee);
            }
        }
        return _amount;
    }
    //liquidity    
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        if (IBabyFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IBabyFactory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = BabyLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = BabyLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'BabyRouter:INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = BabyLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'BabyRouter: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = BabyLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IBabyPair(pair).mint(to);
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external virtual override payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = BabyLibrary.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IBabyPair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value.sub(amountETH));
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = BabyLibrary.pairFor(factory, tokenA, tokenB);
        IBabyPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IBabyPair(pair).burn(to);
        (address token0,) = BabyLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'BabyRouter: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'BabyRouter: INSUFFICIENT_B_AMOUNT');
    }

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountA, uint amountB) {
        address pair = BabyLibrary.pairFor(factory, tokenA, tokenB);
        uint value = approveMax ? uint(-1) : liquidity;
        IBabyPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountToken, uint amountETH) {
        address pair = BabyLibrary.pairFor(factory, token, WETH);
        uint value = approveMax ? uint(-1) : liquidity;
        IBabyPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountETH) {
        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountETH) {
        address pair = BabyLibrary.pairFor(factory, token, WETH);
        uint value = approveMax ? uint(-1) : liquidity;
        IBabyPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token, liquidity, amountTokenMin, amountETHMin, to, deadline
        );
    }
    //swap
    function _swap(
        uint[] memory amounts, 
        address[] memory path, 
        address _to
    ) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = BabyLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            if (swapMining != address(0)) {
                ISwapMining(swapMining).swap(msg.sender, input, output, amountOut);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? address(this) : _to;
            IBabyPair(BabyLibrary.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
            if (i < path.length - 2) {
                amounts[i + 1] = routerFee(address(this), path[i + 1], amounts[i + 1]);
                TransferHelper.safeTransfer(path[i + 1], BabyLibrary.pairFor(factory, output, path[i + 2]), amounts[i + 1]);
            }
        }
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = BabyLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        amounts[0] = routerFee(msg.sender, path[0], amounts[0]);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] memory path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = BabyLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'BabyRouter: EXCESSIVE_INPUT_AMOUNT');
        amounts[0] = routerFee(msg.sender, path[0], amounts[0]);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapExactETHForTokens(uint amountOutMin, address[] memory path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts
    ) {
        require(path[0] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrary.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        amounts[0] = routerFee(address(this), path[0], amounts[0]);
        assert(IWETH(WETH).transfer(BabyLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] memory path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts
    ) {
        require(path[path.length - 1] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'BabyRouter: EXCESSIVE_INPUT_AMOUNT');
        amounts[0] = routerFee(msg.sender, path[0], amounts[0]);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] memory path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts
    ) {
        require(path[path.length - 1] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        amounts[0] = routerFee(msg.sender, path[0], amounts[0]);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapETHForExactTokens(uint amountOut, address[] memory path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts
    ) {
        require(path[0] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, 'BabyRouter: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        uint oldAmount = amounts[0];
        amounts[0] = routerFee(address(this), path[0], amounts[0]);
        assert(IWETH(WETH).transfer(BabyLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > oldAmount) TransferHelper.safeTransferETH(msg.sender, msg.value - oldAmount);
    }

    function _swapSupportingFeeOnTransferTokens(
        address[] memory path, 
        address _to
    ) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = BabyLibrary.sortTokens(input, output);
            IBabyPair pair = IBabyPair(BabyLibrary.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            amountOutput = BabyLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            if (swapMining != address(0)) {
                ISwapMining(swapMining).swap(msg.sender, input, output, amountOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            //address to = i < path.length - 2 ? BabyLibrary.pairFor(factory, output, path[i + 2]) : _to;
            //address to = i < path.length - 2 ? address(this) : _to;
            pair.swap(amount0Out, amount1Out, i < path.length - 2 ? address(this) : _to, new bytes(0));
            if (i < path.length - 2) {
                amountOutput = IERC20(output).balanceOf(address(this));
                routerFee(address(this), output, amountOutput);
                TransferHelper.safeTransfer(path[i + 1], BabyLibrary.pairFor(factory, output, path[i + 2]), IERC20(output).balanceOf(address(this)));
            }
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        amountIn = routerFee(msg.sender, path[0], amountIn);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) external virtual override payable ensure(deadline) {
        require(path[0] == WETH, 'BabyRouter: INVALID_PATH');
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        amountIn = routerFee(address(this), path[0], amountIn);
        assert(IWETH(WETH).transfer(BabyLibrary.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        require(path[path.length - 1] == WETH, 'BabyRouter: INVALID_PATH');
        amountIn = routerFee(msg.sender, path[0], amountIn);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }
    //helper
    function quote(
        uint amountA, 
        uint reserveA, 
        uint reserveB
    ) public pure virtual override returns (uint amountB) {
        return BabyLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint amountIn, 
        uint reserveIn, 
        uint reserveOut
    ) public pure virtual override returns (uint amountOut) {
        return BabyLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint amountOut, 
        uint reserveIn, 
        uint reserveOut
    ) public pure virtual override returns (uint amountIn) {
        return BabyLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(
        uint amountIn, 
        address[] memory path
    ) public view virtual override returns (uint[] memory amounts) {
        return BabyLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(
        uint amountOut, 
        address[] memory path
    ) public view virtual override returns (uint[] memory amounts) {
        return BabyLibrary.getAmountsIn(factory, amountOut, path);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

interface IBabyNormalRouter {

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] calldata amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] calldata amounts);

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] calldata amounts);

    function swapTokensForExactETH(
        uint amountOut, 
        uint amountInMax, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] calldata amounts);

    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] calldata amounts);

    function swapETHForExactTokens(
        uint amountOut, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] calldata amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function quote(
        uint amountA, 
        uint reserveA, 
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn, 
        uint reserveIn, 
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut, 
        uint reserveIn, 
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn, 
        address[] calldata path
    ) external view returns (uint[] calldata amounts);

    function getAmountsIn(
        uint amountOut, 
        address[] calldata path
    ) external view returns (uint[] calldata amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import '../interfaces/IBabyFactory.sol';
import '../interfaces/IBabyRouter02.sol';
import '../libraries/TransferHelper.sol';
import '../libraries/BabyLibrary.sol';
import '../libraries/SafeMath.sol';
import '../interfaces/IERC20.sol';
import '../interfaces/IWETH.sol';

interface ISwapMining {
    function swap(address account, address input, address output, uint256 amount) external returns (bool);
}


contract BabyRouter is IBabyRouter02, Ownable {
    using SafeMath for uint;

    address public immutable override factory;
    address public immutable override WETH;
    address public swapMining;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'BabyRouter: EXPIRED');
        _;
    }

    function setSwapMining(address _swapMininng) public onlyOwner {
        swapMining = _swapMininng;
    }

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        // create the pair if it doesn't exist yet
        if (IBabyFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IBabyFactory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = BabyLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = BabyLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'BabyRouter: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = BabyLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'BabyRouter: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = BabyLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IBabyPair(pair).mint(to);
    }
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external virtual override payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = BabyLibrary.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IBabyPair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = BabyLibrary.pairFor(factory, tokenA, tokenB);
        IBabyPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IBabyPair(pair).burn(to);
        (address token0,) = BabyLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'BabyRouter: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'BabyRouter: INSUFFICIENT_B_AMOUNT');
    }
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountA, uint amountB) {
        address pair = BabyLibrary.pairFor(factory, tokenA, tokenB);
        uint value = approveMax ? uint(-1) : liquidity;
        IBabyPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountToken, uint amountETH) {
        address pair = BabyLibrary.pairFor(factory, token, WETH);
        uint value = approveMax ? uint(-1) : liquidity;
        IBabyPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountETH) {
        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountETH) {
        address pair = BabyLibrary.pairFor(factory, token, WETH);
        uint value = approveMax ? uint(-1) : liquidity;
        IBabyPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token, liquidity, amountTokenMin, amountETHMin, to, deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = BabyLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            if (swapMining != address(0)) {
                ISwapMining(swapMining).swap(msg.sender, input, output, amountOut);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? BabyLibrary.pairFor(factory, output, path[i + 2]) : _to;
            IBabyPair(BabyLibrary.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = BabyLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = BabyLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'BabyRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrary.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(BabyLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'BabyRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, 'BabyRouter: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(BabyLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = BabyLibrary.sortTokens(input, output);
            IBabyPair pair = IBabyPair(BabyLibrary.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            amountOutput = BabyLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            if (swapMining != address(0)) {
                ISwapMining(swapMining).swap(msg.sender, input, output, amountOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? BabyLibrary.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        payable
        ensure(deadline)
    {
        require(path[0] == WETH, 'BabyRouter: INVALID_PATH');
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(BabyLibrary.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        ensure(deadline)
    {
        require(path[path.length - 1] == WETH, 'BabyRouter: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB) {
        return BabyLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountOut)
    {
        return BabyLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountIn)
    {
        return BabyLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return BabyLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return BabyLibrary.getAmountsIn(factory, amountOut, path);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

import './BabyPair.sol';
import '../libraries/BabyLibrary.sol';

contract BabyFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(BabyPair).creationCode));

    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function expectPairFor(address token0, address token1) public view returns (address) {
        return BabyLibrary.pairFor(address(this), token0, token1);
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'Baby: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Baby: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'Baby: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(BabyPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IBabyPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'Baby: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Baby: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

import '@openzeppelin/contracts/access/Ownable.sol';
import '../swap/BabyFactory.sol';
import './Oracle.sol';

contract OracleCaller is Ownable {
    
    event Update(address tokenA, address tokenB);

    Oracle oracle;
    uint constant CRYCLE = 30 minutes;
    BabyFactory factory;

    function setOracle(Oracle _oracle) external {
        oracle = _oracle;
    }

    function setFactory(BabyFactory _factory) external {
        factory = _factory;
    }

    constructor(Oracle _oracle, BabyFactory _factory) {
        oracle = _oracle;
        factory = _factory;
    }

    address[] tokenA;
    address[] tokenB;
    address[] pairs;
    mapping(address => bool) pairMap;
    mapping(address => uint) timestamp;

    function pairExists(address pair) external view returns(bool) {
        return pairMap[pair];
    }

    function pairLength() external view returns (uint) {
        return pairs.length;
    }

    function addPair(address _tokenA, address _tokenB) external onlyOwner {
        address pair = factory.expectPairFor(_tokenA, _tokenB);
        require(!pairMap[pair], "pair already exist");
        tokenA.push(_tokenA);
        tokenB.push(_tokenB);
        pairs.push(pair);
        pairMap[pair] = true;
    }

    function delPair(uint _id) external onlyOwner {
        require(_id < tokenA.length && tokenA.length != tokenB.length, "illegal id");
        uint lastIndex = tokenA.length - 1;
        if (lastIndex > _id) {
            tokenA[_id] = tokenA[lastIndex];
            tokenB[_id] = tokenB[lastIndex];
            pairs[_id] = pairs[lastIndex];
        }
        tokenA.pop();
        tokenB.pop();
        pairs.pop();
    }

    function update() external {
        uint current = block.timestamp;
        for(uint i = 0; i < tokenA.length; i ++) {
            if (current - timestamp[pairs[i]] < CRYCLE) {
                continue;
            }
            oracle.update(tokenA[i], tokenB[i]);
            //timestamp[pairs[i]] = current;
            //emit Update(tokenA[i], tokenB[i]);
        }
    }

    function updateTokens(address[] memory tokens, address base) external {
        for (uint i = 0; i < tokens.length; i ++) {
            oracle.update(tokens[i], base);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6;

import "../interfaces/IBabyFactory.sol";
import "../interfaces/IBabyPair.sol";
import "../libraries/BabyLibrary.sol";

library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }
}

library BabyOracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IBabyPair(pair).price0CumulativeLast();
        price1Cumulative = IBabyPair(pair).price1CumulativeLast();

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IBabyPair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            // counterfactual
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}

contract Oracle {
    using FixedPoint for *;
    using SafeMath for uint;

    struct Observation {
        uint timestamp;
        uint price0Cumulative;
        uint price1Cumulative;
    }

    address public immutable factory;
    uint public constant CYCLE = 30 minutes;

    // mapping from pair address to a list of price observations of that pair
    mapping(address => Observation) public pairObservations;

    constructor(address factory_) {
        factory = factory_;
    }


    function update(address tokenA, address tokenB) external {
        if (IBabyFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            return;
        }
        address pair = IBabyFactory(factory).expectPairFor(tokenA, tokenB);

        Observation storage observation = pairObservations[pair];
        uint timeElapsed = block.timestamp - observation.timestamp;
        require(timeElapsed >= CYCLE, 'MDEXOracle: PERIOD_NOT_ELAPSED');
        (uint price0Cumulative, uint price1Cumulative,) = BabyOracleLibrary.currentCumulativePrices(pair);
        observation.timestamp = block.timestamp;
        observation.price0Cumulative = price0Cumulative;
        observation.price1Cumulative = price1Cumulative;
    }


    function computeAmountOut(
        uint priceCumulativeStart, uint priceCumulativeEnd,
        uint timeElapsed, uint amountIn
    ) private pure returns (uint amountOut) {
        // overflow is desired.
        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
            uint224((priceCumulativeEnd - priceCumulativeStart) / timeElapsed)
        );
        amountOut = priceAverage.mul(amountIn).decode144();
    }


    function consult(address tokenIn, uint amountIn, address tokenOut) external view returns (uint amountOut) {
        address pair = IBabyFactory(factory).expectPairFor(tokenIn, tokenOut);
        Observation storage observation = pairObservations[pair];
        uint timeElapsed = block.timestamp - observation.timestamp;
        (uint price0Cumulative, uint price1Cumulative,) = BabyOracleLibrary.currentCumulativePrices(pair);
        (address token0,) = BabyLibrary.sortTokens(tokenIn, tokenOut);

        if (token0 == tokenIn) {
            return computeAmountOut(observation.price0Cumulative, price0Cumulative, timeElapsed, amountIn);
        } else {
            return computeAmountOut(observation.price1Cumulative, price1Cumulative, timeElapsed, amountIn);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IBEP20.sol";
import "../libraries/SafeMath.sol";
import "../libraries/Address.sol";

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

contract IDO is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    struct IDORecord {
        uint256 issue;
        IBEP20 idoToken;
        IBEP20 receiveToken;
        uint256 price;
        uint256 idoTotal;
        uint256 startTime;
        uint256 duration;
        uint256 maxLimit;
        uint256 receivedTotal;
        mapping(address => uint256) payAmount;
        mapping(address => bool) isWithdraw;
    }

    uint256 public IDOIssue = 0;
    mapping(uint256 => IDORecord) public IDODB;
    mapping(uint256 => bool) private isCharge;
    event IDOCreate(
        uint256 issue,
        address idoToken,
        address receiveToken,
        uint256 price,
        uint256 maxLimit,
        uint256 idoTotal,
        uint256 startTime,
        uint256 duration
    );
    event Staked(uint256 issue, address account, uint256 value);
    event Withdraw(
        uint256 issue,
        address account,
        uint256 idoValue,
        uint256 backValue
    );
    event IDOCharge(uint256 issue, uint256 receiveValue, uint256 leftValue);

    event IDORemove(uint256 issue);

    function createIDO(
        IBEP20 idoToken,
        IBEP20 receiveToken,
        uint256 price,
        uint256 idoTotal,
        uint256 maxLimit,
        uint256 startTime,
        uint256 duration
    ) external onlyOwner {
        require(
            block.timestamp >
                IDODB[IDOIssue].startTime.add(IDODB[IDOIssue].duration),
            "ido is not over yet."
        );
        require(
            address(idoToken) != address(0),
            "idoToken address cannot be 0"
        );
        require(
            address(receiveToken) != address(0),
            "receiveToken address cannot be 0"
        );

        IDOIssue = IDOIssue.add(1);
        IDORecord storage ido = IDODB[IDOIssue];
        ido.issue = IDOIssue;
        ido.idoToken = idoToken;
        ido.receiveToken = receiveToken;
        ido.price = price;
        ido.maxLimit = maxLimit;
        ido.idoTotal = idoTotal;
        ido.startTime = startTime;
        ido.duration = duration;

        idoToken.safeTransferFrom(msg.sender, address(this), idoTotal);
        emit IDOCreate(
            IDOIssue,
            address(idoToken),
            address(receiveToken),
            price,
            maxLimit,
            idoTotal,
            startTime,
            duration
        );
    }

    function removeIDO() external onlyOwner {
        require(
            IDODB[IDOIssue].startTime > block.timestamp,
            "There is no ido that can be deleted."
        );
        IDODB[IDOIssue].idoToken.safeTransfer(
            msg.sender,
            IDODB[IDOIssue].idoTotal
        );
        delete IDODB[IDOIssue];
        emit IDORemove(IDOIssue);
        IDOIssue = IDOIssue.sub(1);
    }

    function chargeIDO(uint256 issue) external onlyOwner {
        IDORecord storage record = IDODB[issue];
        require(issue <= IDOIssue && issue > 0, "IDO that does not exist.");
        require(!isCharge[issue], "Cannot claim repeatedly.");
        require(
            block.timestamp > record.startTime.add(record.duration),
            "ido is not over yet."
        );

        uint256 receiveValue;
        uint256 backValue;

        isCharge[issue] = true;

        uint256 prop = record.receivedTotal.mul(1e36).div(
            record.idoTotal.mul(record.price)
        );
        if (prop >= 1e18) {
            receiveValue = record.idoTotal.mul(record.price).div(1e18);
            record.receiveToken.safeTransfer(msg.sender, receiveValue);
        } else {
            receiveValue = record.receivedTotal;
            record.receiveToken.safeTransfer(msg.sender, record.receivedTotal);
            backValue = record.idoTotal.sub(
                record.idoTotal.mul(prop).div(1e18)
            );
            record.idoToken.safeTransfer(msg.sender, backValue);
        }

        emit IDOCharge(issue, receiveValue, backValue);
    }

    function stake(uint256 value) external {
        require(IDOIssue > 0, "IDO that does not exist.");
        IDORecord storage record = IDODB[IDOIssue];
        require(
            block.timestamp > record.startTime &&
                block.timestamp < record.startTime.add(record.duration),
            "IDO is not in progress."
        );
        require(
            record.payAmount[msg.sender].add(value) <= record.maxLimit,
            "Limit Exceeded"
        );

        record.payAmount[msg.sender] = record.payAmount[msg.sender].add(value);
        record.receivedTotal = record.receivedTotal.add(value);
        record.receiveToken.safeTransferFrom(msg.sender, address(this), value);
        emit Staked(IDOIssue, msg.sender, value);
    }

    function available(address account, uint256 issue)
        public
        view
        returns (uint256 _idoAmount, uint256 _sendBack)
    {
        IDORecord storage record = IDODB[issue];
        require(issue <= IDOIssue && issue > 0, "IDO that does not exist.");

        uint256 prop = record.receivedTotal.mul(1e36).div(
            record.idoTotal.mul(record.price)
        );

        if (prop > 1e18) {
            _idoAmount = record.payAmount[account].mul(1e36).div(prop).div(
                record.price
            );

            _sendBack = record.payAmount[account].sub(
                _idoAmount.mul(record.price).div(1e18)
            );
        } else {
            _idoAmount = record.payAmount[account].mul(1e18).div(record.price);
        }
    }

    function userPayValue(uint256 issue, address account)
        public
        view
        returns (uint256)
    {
        return IDODB[issue].payAmount[account];
    }

    function isWithdraw(uint256 issue, address account)
        public
        view
        returns (bool)
    {
        return IDODB[issue].isWithdraw[account];
    }

    function withdraw(uint256 issue) external {
        require(issue <= IDOIssue && issue > 0, "IDO that does not exist.");
        IDORecord storage record = IDODB[issue];
        require(
            block.timestamp > IDODB[issue].startTime.add(record.duration),
            "ido is not over yet."
        );
        require(!record.isWithdraw[msg.sender], "Cannot claim repeatedly.");

        uint256 idoAmount;
        uint256 sendBack;

        record.isWithdraw[msg.sender] = true;

        (idoAmount, sendBack) = available(msg.sender, issue);

        record.idoToken.safeTransfer(msg.sender, idoAmount);
        if (sendBack > 0) {
            record.receiveToken.safeTransfer(msg.sender, sendBack);
        }

        emit Withdraw(issue, msg.sender, idoAmount, sendBack);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

import '../libraries/SafeMath.sol';
import '../interfaces/IBEP20.sol';
import '../token/SafeBEP20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import "../token/BabyToken.sol";
import "./SyrupBar.sol";

// import "@nomiclabs/buidler/console.sol";

contract ILO is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    struct UserInfo {
        uint256 amount;     
        uint256 lastTime;
    }
    struct PoolInfo {
        IBEP20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. CAKEs to distribute per block.
        uint256 totalAmount;
    }

    BabyToken public cake;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public endBlock;
    
    function setStartBlock(uint256 blockNumber) public onlyOwner {
        startBlock = blockNumber;
    }

    function setEndBlock(uint256 blockNumber) public onlyOwner {
        endBlock = blockNumber;
    }
    
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        BabyToken _cake,
        uint256 _startBlock,
        uint256 _endBlock
    ) {
        cake = _cake;
        startBlock = _startBlock;
        endBlock = _endBlock;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IBEP20 _lpToken) external onlyOwner {
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            totalAmount: 0
        }));
    }

    function pendingBaby(uint256 _pid, address _user) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 balance = cake.balanceOf(address(this));
        if (balance == 0) {
            return 0; 
        }
        uint256 poolBalance = balance.mul(pool.allocPoint).div(totalAllocPoint);
        if (poolBalance == 0) {
            return 0;
        }
        if (pool.totalAmount == 0) {
            return 0;
        }
        return balance.mul(pool.allocPoint).mul(user.amount).div(totalAllocPoint).div(pool.totalAmount);
    }

    function deposit(uint256 _pid, uint256 _amount) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(block.number >= startBlock, "ILO not begin");
        require(block.number <= endBlock, "ILO already finish");
        require(_amount > 0, "illegal amount");

        //if (_amount > 0) {
            user.amount = user.amount.add(_amount);
            user.lastTime = block.timestamp;
            pool.totalAmount = pool.totalAmount.add(_amount);
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        //}

        emit Deposit(msg.sender, _pid, _amount);
    }



    function withdraw(uint256 _pid) external {
        require(block.number > endBlock, "Can not claim now");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 pendingAmount = pendingBaby(_pid, msg.sender);
        if (pendingAmount > 0) {
            safeCakeTransfer(msg.sender, pendingAmount);
            emit Claim(msg.sender, _pid, pendingAmount);
        }
        if (user.amount > 0) {
            uint _amount = user.amount;
            user.amount = 0;
            user.lastTime = block.timestamp;
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            emit Withdraw(msg.sender, _pid, _amount);
        }
    }

    function ownerWithdraw(address _to, uint256 _amount) public onlyOwner {
        require(block.number < startBlock || block.number >= endBlock + 403200, "ILO already start");  //after a week can withdraw
        safeCakeTransfer(_to, _amount);
    }

    // Safe cake transfer function, just in case if rounding error causes pool to not have enough CAKEs.
    function safeCakeTransfer(address _to, uint256 _amount) internal {
        uint256 balance = cake.balanceOf(address(this));
        if (_amount > balance) {
            _amount = balance;
        }
        IBEP20(address(cake)).safeTransfer(_to, _amount);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

import '../libraries/SafeMath.sol';
import '../interfaces/IBEP20.sol';
import '../token/SafeBEP20.sol';
import './MasterChef.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

contract Bottle is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    event NewVote(uint256 indexed voteId, uint256 beginAt, uint256 voteAt, uint256 unlockAt, uint256 finishAt);
    event DeleteVote(uint256 indexed voteId);
    event Deposit(uint256 indexed voteId, address indexed user, address indexed forUser, uint256 amount);
    event Withdraw(uint256 indexed voteId, address indexed user, address indexed forUser,  uint256 amount);
    event Claim(uint256 indexed voteId, address indexed user, address indexed forUser, uint256 amount);

    MasterChef immutable public masterChef;
    IBEP20 immutable public babyToken;
    uint256 immutable public beginAt;
    uint256 constant public PREPARE_DURATION = 4 days;
    uint256 constant public VOTE_DURATION = 1 days; 
    uint256 constant public CLEAN_DURATION = 2 days - 1;
    /*
    uint256 constant public PREPARE_DURATION = 1 hours;
    uint256 constant public VOTE_DURATION = 1 hours; 
    uint256 constant public CLEAN_DURATION = 1 hours - 1;
    */
    uint256 constant public RATIO = 1e18;
    uint256 totalShares = 0;
    uint256 accBabyPerShare = 0; 

    struct PoolInfo {
        bool avaliable;
        uint startAt;
        uint voteAt;
        uint unlockAt;
        uint finishAt;
        uint256 totalAmount;
    }

    function poolState() external view returns (uint) {
        PoolInfo storage pool = poolInfo[currentVoteId];
        if (block.timestamp >= pool.startAt && block.timestamp <= pool.voteAt) {
            return 1;
        } else if (block.timestamp >= pool.voteAt && block.timestamp <= pool.unlockAt) {
            return 2;
        } else if (block.timestamp >= pool.unlockAt && block.timestamp <= pool.finishAt) {
            return 3;
        } else {
            return 4;
        }
    }
    /*
    function debugChangeStartAt(uint timestamp) external {
        poolInfo[currentVoteId].startAt = timestamp; 
    }

    function debugChangeVoteAt(uint timestamp) external {
        poolInfo[currentVoteId].voteAt = timestamp; 
    }

    function debugChangeUnlockAt(uint timestamp) external {
        poolInfo[currentVoteId].unlockAt = timestamp;
    }

    function debugChangeFinishAt(uint timestamp) external {
        poolInfo[currentVoteId].finishAt = timestamp;
    }

    function debugTransfer(uint amount) external {
        uint balance = babyToken.balanceOf(address(this));
     if (amount > balance) {
            amount = balance;
        }
        if (balance > 0) {
            babyToken.transfer(owner(), amount);
        }
    }
    */
    mapping(uint256 => PoolInfo) public poolInfo;
    uint public currentVoteId;
    
    function createPool() public returns (uint256) {
        uint _currentVoteId = currentVoteId; 
        PoolInfo memory _currentPool = poolInfo[_currentVoteId];
        if (block.timestamp >= _currentPool.finishAt) {
            PoolInfo memory _pool;    
            _pool.startAt = _currentPool.finishAt.add(1);
            _pool.voteAt = _pool.startAt.add(PREPARE_DURATION);
            _pool.unlockAt = _pool.voteAt.add(VOTE_DURATION);
            _pool.finishAt = _pool.unlockAt.add(CLEAN_DURATION);
            _pool.avaliable = true;
            currentVoteId = _currentVoteId + 1;
            poolInfo[_currentVoteId + 1] = _pool;
            if (_currentPool.totalAmount == 0) {
                //delete poolInfo[_currentVoteId];
                emit DeleteVote(_currentVoteId);
            }
            emit NewVote(_currentVoteId + 1, _pool.startAt, _pool.voteAt, _pool.unlockAt, _pool.finishAt);
            return _currentVoteId + 1;
        }
        return _currentVoteId;
    }

    constructor(
        MasterChef _masterChef,
        BabyToken _babyToken,
        uint256 _beginAt
    ) {
        require(block.timestamp <= _beginAt.add(PREPARE_DURATION), "illegal beginAt");
        require(address(_masterChef) != address(0), "_masterChef address cannot be 0");
        require(address(_babyToken) != address(0), "_babyToken address cannot be 0");
        masterChef = _masterChef;
        babyToken = _babyToken;
        beginAt = _beginAt;
        PoolInfo memory _pool;
        _pool.startAt = _beginAt;
        _pool.voteAt = _pool.startAt.add(PREPARE_DURATION);
        _pool.unlockAt = _pool.voteAt.add(VOTE_DURATION);
        _pool.finishAt = _pool.unlockAt.add(CLEAN_DURATION);
        _pool.avaliable = true;
        accBabyPerShare = 0;
        currentVoteId = currentVoteId + 1;
        poolInfo[currentVoteId] = _pool;
        emit NewVote(0, _pool.startAt, _pool.voteAt, _pool.unlockAt, _pool.finishAt);
    }

    struct UserInfo {
        uint256 amount;     
        uint256 rewardDebt; 
        uint256 pending;
    }
    mapping (uint256 => mapping(address => mapping(address => UserInfo))) public userInfo;
    //mapping (uint256 => mapping (address => mapping(address => uint256))) public userVoted;
    mapping (uint256 => mapping (address => uint256)) public getVotes;

    function deposit(uint256 _voteId, address _for, uint256 amount) external nonReentrant {
        require(address(_for) != address(0), "_for address cannot be 0");
        createPool();
        PoolInfo memory _pool = poolInfo[_voteId];
        require(_pool.avaliable, "illegal voteId");
        require(block.timestamp >= _pool.voteAt && block.timestamp <= _pool.unlockAt, "not the right time");
        SafeBEP20.safeTransferFrom(babyToken, msg.sender, address(this), amount);

        //uint _pending = masterChef.pendingCake(0, address(this));
        uint256 balanceBefore = babyToken.balanceOf(address(this));
        masterChef.leaveStaking(0);
        uint256 balanceAfter = babyToken.balanceOf(address(this));
        uint256 _pending = balanceAfter.sub(balanceBefore);
        babyToken.approve(address(masterChef), amount.add(_pending));
        masterChef.enterStaking(amount.add(_pending));
        uint _totalShares = totalShares;
        if (_pending > 0 && _totalShares > 0) {
            accBabyPerShare = accBabyPerShare.add(_pending.mul(RATIO).div(_totalShares));
        }
        UserInfo memory _userInfo = userInfo[_voteId][msg.sender][_for];
        if (_userInfo.amount > 0) {
            userInfo[_voteId][msg.sender][_for].pending = _userInfo.pending.add(_userInfo.amount.mul(accBabyPerShare).div(RATIO).sub(_userInfo.rewardDebt));
        }

        userInfo[_voteId][msg.sender][_for].amount = _userInfo.amount.add(amount);
        userInfo[_voteId][msg.sender][_for].rewardDebt = accBabyPerShare.mul(_userInfo.amount.add(amount)).div(RATIO);
        poolInfo[_voteId].totalAmount = _pool.totalAmount.add(amount);
        totalShares = _totalShares.add(amount);
        getVotes[_voteId][_for] = getVotes[_voteId][_for].add(amount);
        emit Deposit(_voteId, msg.sender, _for, amount);
    }

    function withdraw(uint256 _voteId, address _for) external nonReentrant {
        createPool();
        //require(currentVoteId <= 4 || _voteId >= currentVoteId - 4, "illegal voteId");
        PoolInfo memory _pool = poolInfo[_voteId];
        require(_pool.avaliable, "illegal voteId");
        require(block.timestamp > _pool.unlockAt, "not the right time");
        UserInfo memory _userInfo = userInfo[_voteId][msg.sender][_for];
        require (_userInfo.amount > 0, "illegal amount");

        //uint _pending = masterChef.pendingCake(0, address(this));
        uint256 balanceBefore = babyToken.balanceOf(address(this));
        masterChef.leaveStaking(0);
        uint256 balanceAfter = babyToken.balanceOf(address(this));
        uint256 _pending = balanceAfter.sub(balanceBefore);
        uint _totalShares = totalShares;
        if (_pending > 0 && _totalShares > 0) {
            accBabyPerShare = accBabyPerShare.add(_pending.mul(RATIO).div(_totalShares));
        }
        
        uint _userPending = _userInfo.pending.add(_userInfo.amount.mul(accBabyPerShare).div(RATIO).sub(_userInfo.rewardDebt));
        uint _totalPending = _userPending.add(_userInfo.amount);

        if (_totalPending >= _pending) {
            masterChef.leaveStaking(_totalPending.sub(_pending));
        } else {
            //masterChef.leaveStaking(0);
            babyToken.approve(address(masterChef), _pending.sub(_totalPending));
            masterChef.enterStaking(_pending.sub(_totalPending));
        }

        //if (_totalPending > 0) {
            SafeBEP20.safeTransfer(babyToken, msg.sender, _totalPending);
        //}

        if (_userPending > 0) {
            emit Claim(_voteId, msg.sender, _for, _userPending);
        }

        totalShares = _totalShares.sub(_userInfo.amount);
        poolInfo[_voteId].totalAmount = _pool.totalAmount.sub(_userInfo.amount);

        delete userInfo[_voteId][msg.sender][_for];
        if (poolInfo[_voteId].totalAmount == 0) {
            //delete poolInfo[_voteId];
            emit DeleteVote(_voteId);
        }
        emit Withdraw(_voteId, msg.sender, _for, _userInfo.amount);
    }

    function claim(uint256 _voteId, address _user, address _for) public nonReentrant {
        createPool();
        //require(currentVoteId <= 4 || _voteId >= currentVoteId - 4, "illegal voteId");
        PoolInfo memory _pool = poolInfo[_voteId];
        require(_pool.avaliable, "illeagl voteId");
        UserInfo memory _userInfo = userInfo[_voteId][_user][_for];

        //uint _pending = masterChef.pendingCake(0, address(this));
        uint256 balanceBefore = babyToken.balanceOf(address(this));
        masterChef.leaveStaking(0);
        uint256 balanceAfter = babyToken.balanceOf(address(this));
        uint256 _pending = balanceAfter.sub(balanceBefore);
        uint _totalShares = totalShares;
        if (_pending > 0 && _totalShares > 0) {
            accBabyPerShare = accBabyPerShare.add(_pending.mul(RATIO).div(_totalShares));
        }
        uint _userPending = _userInfo.pending.add(_userInfo.amount.mul(accBabyPerShare).div(RATIO).sub(_userInfo.rewardDebt));
        if (_userPending == 0) {
            return;
        }
        if (_userPending >= _pending) {
            masterChef.leaveStaking(_userPending.sub(_pending));
        } else {
            //masterChef.leaveStaking(0);
            babyToken.approve(address(masterChef), _pending.sub(_userPending));
            masterChef.enterStaking(_pending.sub(_userPending));
        }
        SafeBEP20.safeTransfer(babyToken, _user, _userPending);
        emit Claim(_voteId, _user, _for, _userPending);
        userInfo[_voteId][_user][_for].rewardDebt = _userInfo.amount.mul(accBabyPerShare).div(RATIO);
        userInfo[_voteId][_user][_for].pending = 0;
    }

    function claimAll(uint256 _voteId, address _user, address[] memory _forUsers) external {
        for (uint i = 0; i < _forUsers.length; i ++) {
            claim(_voteId, _user, _forUsers[i]);
        }
    }

    function pending(uint256 _voteId, address _for, address _user) external view returns (uint256) {
        /*
        if (currentVoteId > 4 && _voteId < currentVoteId - 4) {
            return 0;
        }
        */
        uint _pending = masterChef.pendingCake(0, address(this));
        if (totalShares == 0) {
            return 0;
        }
        uint acc = accBabyPerShare.add(_pending.mul(RATIO).div(totalShares));
        uint userPending = userInfo[_voteId][_user][_for].pending.add(userInfo[_voteId][_user][_for].amount.mul(acc).div(RATIO).sub(userInfo[_voteId][_user][_for].rewardDebt));
        return userPending;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

import '../libraries/SafeMath.sol';
import '../interfaces/IBEP20.sol';
import '../token/SafeBEP20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

// import "@nomiclabs/buidler/console.sol";

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}

contract BnbStaking is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        bool inBlackList;
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. CAKEs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that CAKEs distribution occurs.
        uint256 accCakePerShare; // Accumulated CAKEs per share, times 1e12. See below.
    }

    // The REWARD TOKEN
    IBEP20 public rewardToken;

    // adminAddress
    address public adminAddress;


    // WBNB
    address public immutable WBNB;

    // CAKE tokens created per block.
    uint256 public rewardPerBlock;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfo;
    // limit 10 BNB here
    uint256 public limitAmount = 10000000000000000000;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when CAKE mining starts.
    uint256 public startBlock;
    // The block number when CAKE mining ends.
    uint256 public bonusEndBlock;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(
        IBEP20 _lp,
        IBEP20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        address _adminAddress,
        address _wbnb
    ) {
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;
        adminAddress = _adminAddress;
        WBNB = _wbnb;

        // staking pool
        poolInfo.push(PoolInfo({
            lpToken: _lp,
            allocPoint: 1000,
            lastRewardBlock: startBlock,
            accCakePerShare: 0
        }));

        totalAllocPoint = 1000;

    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "admin: wut?");
        _;
    }

    receive() external payable {
        assert(msg.sender == WBNB); // only accept BNB via fallback from the WBNB contract
    }

    // Update admin address by the previous dev.
    function setAdmin(address _adminAddress) public onlyOwner {
        adminAddress = _adminAddress;
    }

    function setBlackList(address _blacklistAddress) public onlyAdmin {
        userInfo[_blacklistAddress].inBlackList = true;
    }

    function removeBlackList(address _blacklistAddress) public onlyAdmin {
        userInfo[_blacklistAddress].inBlackList = false;
    }

    // Set the limit amount. Can only be called by the owner.
    function setLimitAmount(uint256 _amount) public onlyOwner {
        limitAmount = _amount;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from);
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock.sub(_from);
        }
    }

    // View function to see pending Reward on frontend.
    function pendingReward(address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[_user];
        uint256 accCakePerShare = pool.accCakePerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 cakeReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accCakePerShare = accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 cakeReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accCakePerShare = pool.accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }


    // Stake tokens to SmartChef
    function deposit() public payable {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];

        require (user.amount.add(msg.value) <= limitAmount, 'exceed the top');
        require (!user.inBlackList, 'in black list');

        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                rewardToken.safeTransfer(address(msg.sender), pending);
            }
        }
        if(msg.value > 0) {
            IWBNB(WBNB).deposit{value: msg.value}();
            assert(IWBNB(WBNB).transfer(address(this), msg.value));
            user.amount = user.amount.add(msg.value);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);

        emit Deposit(msg.sender, msg.value);
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{gas: 23000, value: value}("");
        // (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    // Withdraw tokens from STAKING.
    function withdraw(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0 && !user.inBlackList) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            IWBNB(WBNB).withdraw(_amount);
            safeTransferBNB(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);

        emit Withdraw(msg.sender, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Withdraw reward. EMERGENCY ONLY.
    function emergencyRewardWithdraw(uint256 _amount) public onlyOwner {
        require(_amount < rewardToken.balanceOf(address(this)), 'not enough token');
        rewardToken.safeTransfer(address(msg.sender), _amount);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts/math/SafeMath.sol';
import '../interfaces/IBabyPair.sol';
import '../interfaces/IFactory.sol';

contract CalculateRouter is Ownable {
    using SafeMath for uint;

    uint constant FEE_RATIO = 1e6;

    struct Path {
        bool exist;
        IFactory[] factories;
        uint[] fees;
        address[] paths;
    }

    IFactory[] factories;
    address[] middleTokens;
    mapping(address => bool) isMiddleToken;
    mapping(IFactory => uint) fees;
    mapping(address => mapping(address => Path)) fixRouters;

    function checkFactoryExist(IFactory _factory) internal view returns (bool) {
        for (uint i = 0; i < factories.length; i ++) {
            if (address(factories[i]) == address(_factory)) {
                return true;
            }
        }
        return false;
    }

    function addFactory(IFactory _factory, uint _fee) external onlyOwner {
        for (uint i = 0; i < factories.length; i ++) {
            require(address(factories[i]) != address(_factory), "the factory already exists");
        }
        factories.push(_factory);
        fees[_factory] = _fee;
    }

    function delFactory(IFactory _factory) external onlyOwner {
        //the length of factories will not be too big, so the foreach is ok
        //for the delete, we don't want to change the sort of the factories
        //so the easies way is foreach
        IFactory[] memory newFactories = new IFactory[](factories.length);
        uint index = 0;
        for (uint i = 0; i < factories.length; i ++) {
            if (address(factories[i]) != address(_factory)) {
                newFactories[index ++] = factories[i];
            }
        }
        if (index < factories.length) {
            assembly {
                mstore(newFactories, index)
            }
            factories = newFactories;
            delete fees[_factory];
        }
    }

    function addMiddleToken(address _token) external onlyOwner {
        for (uint i = 0; i < middleTokens.length; i ++) {
            require(middleTokens[i] != _token, "already exists");
        }
        middleTokens.push(_token);
        isMiddleToken[_token] = true;
    }

    function delMiddleToken(address _token) external onlyOwner {
        address[] memory newMiddleTokens = new address[](middleTokens.length);
        uint index = 0;
        for (uint i = 0; i < middleTokens.length; i ++) {
            if (middleTokens[i] != _token) {
                newMiddleTokens[index ++] = middleTokens[i];
            }
        }
        if (index < newMiddleTokens.length) {
            assembly {
                mstore(newMiddleTokens, index)
            }
            middleTokens = newMiddleTokens;
        }
        delete isMiddleToken[_token];
    }

    function addFixRouter(address _tokenA, address _tokenB, IFactory[] memory _factories, address[] memory _paths) external onlyOwner {
        require(!fixRouters[_tokenA][_tokenB].exist, "already exists");
        require(_paths.length >= 2 && _factories.length == _paths.length - 1, "illegal param");
        require(_paths[0] == _tokenA && _paths[_paths.length - 1] == _tokenB, "illegal path");
        uint[] memory factoryFees = new uint[](_factories.length);
        for (uint i = 0; i < _factories.length; i ++) {
            require(checkFactoryExist(_factories[i]), "factory not exist");
            factoryFees[i] = fees[_factories[i]];
            require(_factories[i].getPair(_paths[i], _paths[i + 1]) != address(0), "path not exist in factory");
        }
        Path memory path;
        path.factories = _factories;
        path.fees = factoryFees;
        path.paths = _paths;
        path.exist = true;
        fixRouters[_tokenA][_tokenB] = path;
        Path memory reservePath;
        reservePath.factories = new IFactory[](_factories.length);
        reservePath.fees = new uint[](_factories.length);
        reservePath.paths = new address[](_paths.length);
        reservePath.exist = true;
        uint factoryIndex = 0;
        uint pathIndex = 0;
        reservePath.paths[pathIndex ++] = _paths[_paths.length - 1];
        for (uint i = _factories.length; i > 0; i --) {
            reservePath.fees[factoryIndex] = factoryFees[i - 1];
            reservePath.factories[factoryIndex ++] = _factories[i - 1];
            reservePath.paths[pathIndex ++] = _paths[i - 1];
        }
        fixRouters[_tokenB][_tokenA] = reservePath;
    }

    function delFixRouter(address _tokenA, address _tokenB) external onlyOwner {
        delete fixRouters[_tokenA][_tokenB];
        delete fixRouters[_tokenB][_tokenA];
    }

    function getFactory(uint _idx) external view onlyOwner returns (IFactory factory, uint fee) { //only owner can read
        require(_idx < factories.length, "illegal idx");
        factory = factories[_idx];
        fee = fees[factory];
    }

    function getMiddleToken(uint _idx) external view onlyOwner returns (address) { //only owner can read
        require(_idx < middleTokens.length, "illegal idx");
        return middleTokens[_idx];
    }

    function getFixRouter(address _tokenA, address _tokenB) external view onlyOwner returns (Path memory) { //only owner can read
        return fixRouters[_tokenA][_tokenB];
    }

    function middleTokenExist(address _token) external view onlyOwner returns (bool) {
        return isMiddleToken[_token];
    }

    function factoryExist(IFactory _factory) external view onlyOwner returns (bool) {
        for (uint i = 0; i < factories.length; i ++) {
            if(address(factories[i]) == address(_factory)) {
                return true;
            }
        }
        return false;
    }

    struct EndPath {
        IFactory factory;
        address token;
    }

    function getEndPath(address _token) internal view returns (EndPath[] memory paths) {
        paths = new EndPath[](factories.length * middleTokens.length);
        uint pathIndex = 0;
        for (uint i = 0; i < middleTokens.length; i ++) {
            address middleToken = middleTokens[i];
            for (uint j = 0; j < factories.length; j ++) {
                IFactory factory = factories[j];
                if (factory.getPair(_token, middleToken) != address(0)) {
                    paths[pathIndex].factory = factory;
                    paths[pathIndex].token = middleToken;
                    pathIndex ++;
                }
            }
        }
        if (pathIndex < paths.length) {
            assembly {
                mstore(paths, pathIndex)
            }
        }
    }

    struct SwapPath {
        IFactory[] factories;
        uint[] fees;
        address[] path;
    }

    function combionPath(address _tokenA, address _tokenB, EndPath memory leftPath, EndPath memory rightPath, SwapPath[] memory paths, uint pathIndex) internal view returns (uint) {
        Path memory fixPath;
        if (leftPath.token != rightPath.token) {
            fixPath = fixRouters[leftPath.token][rightPath.token];
        }
        IFactory[] memory pathFactories = new IFactory[](2 + fixPath.factories.length);
        uint[] memory pathFees = new uint[](2 + fixPath.factories.length);
        address[] memory pathPath = new address[](2 + fixPath.factories.length + 1);
        uint factoryIndex = 0;
        uint currentPathIndex = 0;
        if (address(leftPath.factory) == address(0)) {
            //paths[pathIndex].path[currentPathIndex ++] = _tokenA;
        } else {
            pathFees[factoryIndex] = fees[leftPath.factory];
            pathFactories[factoryIndex ++] = leftPath.factory;
            pathPath[currentPathIndex ++] = _tokenA;
            pathPath[currentPathIndex ++] = leftPath.token;
        }
        if (fixPath.factories.length > 0) {
            //pathPath[currentPathIndex ++] = fixPath.paths[0];
            for (uint m = 0; m < fixPath.factories.length; m ++) {
                pathFees[factoryIndex] = fixPath.fees[m];
                pathFactories[factoryIndex ++] = fixPath.factories[m];
                pathPath[currentPathIndex ++] = fixPath.paths[m + 1];
            }
        }
        if (address(rightPath.factory) == address(0)) {
            //paths[pathIndex].path[currentPathIndex ++] = _tokenB;
        } else {
            pathFees[factoryIndex] = fees[rightPath.factory];
            pathFactories[factoryIndex ++] = rightPath.factory;
            //paths[pathIndex].path[currentPathIndex ++] = rightPath.token;
            pathPath[currentPathIndex ++] = _tokenB;
        }
        if (factoryIndex < pathFees.length) {
            assembly {
                mstore(pathFees, factoryIndex)
                mstore(pathFactories, factoryIndex)
            }
        }
        if (currentPathIndex < pathPath.length) {
            assembly {
                mstore(pathPath, currentPathIndex)
            }
        }
        paths[pathIndex].factories = pathFactories;
        paths[pathIndex].fees = pathFees;
        paths[pathIndex].path = pathPath;
        bool crycle = false;
        for (uint m = 1; m < paths[pathIndex].path.length - 1; m ++) {
            if (paths[pathIndex].path[m] == _tokenA || paths[pathIndex].path[m] == _tokenB) {
                crycle = true;
                break;
            }
        }
        if (!crycle) {
            pathIndex ++;
        }
        return pathIndex;
    }

    function directPath(address _tokenA, address _tokenB, SwapPath[] memory paths, uint pathIndex) internal view returns(uint) {
        if (isMiddleToken[_tokenA] || isMiddleToken[_tokenB]) {
            return pathIndex;
        }
        for (uint i = 0; i < factories.length; i ++) {
            IFactory factory = factories[i];
            if (factory.getPair(_tokenA, _tokenB) != address(0)) {
                paths[pathIndex].factories = new IFactory[](1);
                paths[pathIndex].factories[0] = factory;
                paths[pathIndex].fees = new uint[](1);
                paths[pathIndex].fees[0] = fees[factory];
                paths[pathIndex].path = new address[](2);
                paths[pathIndex].path[0] = _tokenA; paths[pathIndex].path[1] = _tokenB;
                pathIndex ++;
            }
        }
        return pathIndex;
    }


    function getPath(address _tokenA, address _tokenB) public view returns (SwapPath[] memory paths) {
        require(_tokenA != _tokenB, "illegal token");
        if (fixRouters[_tokenA][_tokenB].exist) {
            paths = new SwapPath[](1);
            paths[0].factories = fixRouters[_tokenA][_tokenB].factories;
            paths[0].fees = fixRouters[_tokenA][_tokenB].fees;
            paths[0].path = fixRouters[_tokenA][_tokenB].paths;
            return paths;
        }
        EndPath[] memory leftPaths = getEndPath(_tokenA);
        EndPath[] memory rightPaths = getEndPath(_tokenB);
        paths = new SwapPath[](leftPaths.length * rightPaths.length + 1);
        uint pathIndex = 0;
        for (uint i = 0; i < leftPaths.length; i ++) {
            EndPath memory leftPath = leftPaths[i];
            if (leftPath.token == _tokenB) {
                //if the left middleToken is the deserved token, we don't neeed to continue
                paths[pathIndex].factories = new IFactory[](1);
                paths[pathIndex].factories[0] = leftPath.factory;
                paths[pathIndex].fees = new uint[](1);
                paths[pathIndex].fees[0] = fees[leftPath.factory];
                paths[pathIndex].path = new address[](2);
                paths[pathIndex].path[0] = _tokenA; paths[pathIndex].path[1] = _tokenB;
                pathIndex ++;
                continue;
            }
            for (uint j = 0; j < rightPaths.length; j ++) {
                EndPath memory rightPath = rightPaths[j];
                if (rightPath.token == _tokenA) {
                    //if the middleToken is the input token, we don't need to deeal the left
                    paths[pathIndex].factories = new IFactory[](1);
                    paths[pathIndex].factories[0] = rightPath.factory;
                    paths[pathIndex].fees = new uint[](1);
                    paths[pathIndex].fees[0] = fees[rightPath.factory];
                    paths[pathIndex].path = new address[](2);
                    paths[pathIndex].path[0] = _tokenA; paths[pathIndex].path[1] = _tokenB;
                    pathIndex ++;
                    continue;
                }
                pathIndex = combionPath(_tokenA, _tokenB, leftPath, rightPath, paths, pathIndex);
            }
        }
        pathIndex = directPath(_tokenA, _tokenB, paths, pathIndex);
        if (pathIndex < paths.length) {
            assembly {
                mstore(paths, pathIndex)
            }
        }
    }

    function getAmountOutWithFee(uint _amountIn, uint _reserveIn, uint _reserveOut, uint _fee) internal pure returns (uint amountOut) {
        assert(_amountIn > 0);
        if (_reserveIn <= 0 || _reserveOut <= 0) return 0;
        uint amountInWithFee = _amountIn.mul(FEE_RATIO.sub(_fee));
        uint numerator = amountInWithFee.mul(_reserveOut);
        uint denominator = _reserveIn.mul(FEE_RATIO).add(amountInWithFee);
        if (denominator <= 0) {
            return 0;
	}
        amountOut = numerator.div(denominator);
    }

    function getAmountInWithFee(uint _amountOut, uint _reserveIn, uint _reserveOut, uint _fee) internal pure returns (uint amountIn) {
        assert(_amountOut > 0);
        if (_reserveIn <= 0 || _reserveOut <= 0) return 0;
        uint numerator = _reserveIn.mul(_amountOut).mul(FEE_RATIO);
        if (_reserveOut <= _amountOut) {
            return 0;
        }
        uint denominator = _reserveOut.sub(_amountOut).mul(FEE_RATIO.sub(_fee));
        if (denominator <= 0) {
            return 0;
	}
        amountIn = numerator.div(denominator).add(1);
    }

    function sortTokens(address _tokenA, address _tokenB) internal pure returns (address token0, address token1) {
        assert(_tokenA != _tokenB);
        (token0, token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
        assert(token0 != address(0));
    }

    function getReserves(IFactory _factory, address _tokenA, address _tokenB) internal view returns (uint reserveA, uint reserveB, address pair) {
        (address token0,) = sortTokens(_tokenA, _tokenB);
        pair = _factory.getPair(_tokenA, _tokenB);
        (uint reserve0, uint reserve1,) = IBabyPair(pair).getReserves();
        (reserveA, reserveB) = _tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }
    
    function getAmountsOut(IFactory[] memory _factories, uint[] memory _fees, uint _amountIn, address[] memory _path) internal view returns (uint[] memory amounts, uint[] memory impact, address[] memory pairs) {
        assert(_path.length >= 2 && _factories.length == _fees.length && _factories.length + 1 == _path.length);
        amounts = new uint[](_path.length);
        impact = new uint[](_path.length - 1);
        pairs = new address[](_path.length - 1);
        amounts[0] = _amountIn;
        for (uint i; i < _path.length - 1; i++) {
            (uint reserveIn, uint reserveOut, address pair) = getReserves(_factories[i], _path[i], _path[i + 1]);
            pairs[i] = pair;
            amounts[i + 1] = getAmountOutWithFee(amounts[i], reserveIn, reserveOut, _fees[i]);
            if (amounts[i + 1] <= 0) {
                return (new uint[](0), new uint[](0), new address[](0));
            }
            impact[i] = amounts[i + 1].mul(1e18).div(reserveOut.sub(amounts[i + 1]));
        }
    }

    function getAmountsIn(IFactory[] memory _factories, uint[] memory _fees, uint amountOut, address[] memory _path) internal view returns (uint[] memory amounts, uint[] memory impact, address[] memory pairs) {
        assert(_path.length >= 2 && _factories.length == _fees.length && _factories.length + 1 == _path.length);
        amounts = new uint[](_path.length);
        impact = new uint[](_path.length - 1);
        pairs = new address[](_path.length - 1);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = _path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut, address pair) = getReserves(_factories[i - 1], _path[i - 1], _path[i]);
            pairs[i - 1] = pair;
            amounts[i - 1] = getAmountInWithFee(amounts[i], reserveIn, reserveOut, _fees[i - 1]);
            if (amounts[i - 1] <= 0) {
                return (new uint[](0), new uint[](0), new address[](0));
            }
            impact[i - 1] = amounts[i].mul(1e18).div(reserveOut.sub(amounts[i]));
        }
    }

    struct RouteInfo {
        uint[] amounts;
        IFactory[] factories;
        address[] pairs;
        uint[] fees;
        uint[] impact;
        address[] path;
    }

    function calculateAmountOut(address _tokenA, address _tokenB, uint _amountIn) external view returns (RouteInfo[] memory routes) {
        SwapPath[] memory paths = getPath(_tokenA, _tokenB);
        routes = new RouteInfo[](paths.length);
        uint routeIndex = 0;
        for (uint i = 0; i < paths.length; i ++) {
            SwapPath memory path = paths[i];
            (uint[] memory amountsOut, uint[] memory impact, address[] memory pairs) = getAmountsOut(path.factories, path.fees, _amountIn, path.path);
            if (amountsOut.length == 0) {
                continue;
	        }
            routes[routeIndex].amounts = amountsOut;
            routes[routeIndex].impact = impact;
            routes[routeIndex].factories = path.factories;
            routes[routeIndex].fees = path.fees;
            routes[routeIndex].path = path.path;
            routes[routeIndex].pairs = pairs;
	        routeIndex ++;
        }
        if (routeIndex < routes.length) {
            assembly {
                mstore(routes, routeIndex)
            }
        }
    }

    function calculateAmountIn(address _tokenA, address _tokenB, uint _amountOut) external view returns (RouteInfo[] memory routes) {
        SwapPath[] memory paths = getPath(_tokenA, _tokenB);
        routes = new RouteInfo[](paths.length);
        uint routeIndex = 0;
        for (uint i = 0; i < paths.length; i ++) {
            SwapPath memory path = paths[i];
            (uint[] memory amountsIn, uint[] memory impact, address[] memory pairs) = getAmountsIn(path.factories, path.fees, _amountOut, path.path);
            if (amountsIn.length == 0) {
                continue;
	        }
            routes[routeIndex].amounts = amountsIn;
            routes[routeIndex].impact = impact;
            routes[routeIndex].factories = path.factories;
            routes[routeIndex].fees = path.fees;
            routes[routeIndex].path = path.path;
            routes[routeIndex].pairs = pairs;
	        routeIndex ++;
        }
        if (routeIndex < routes.length) {
            assembly {
                mstore(routes, routeIndex)
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

interface IFactory {
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function expectPairFor(address token0, address token1) external view returns (address);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '../interfaces/IBabyPair.sol';
import '../interfaces/IFactory.sol';

contract MultHelperV2 is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint constant public PRICE_BASE = 1e18;

    IFactory[] public factories;
    address public defaultBaseToken;
    address[] public middleTokens;

    constructor(IFactory[] memory _factories, address[] memory _middleTokens, address _defaultBaseToken) {
        factories = _factories;
        middleTokens = _middleTokens;
        defaultBaseToken = _defaultBaseToken;
    }

    function setDefaultBaseToken(address _defaultBaseToken) external onlyOwner {
        defaultBaseToken = _defaultBaseToken;
    }

    function addFactory(IFactory _factory) external onlyOwner {
        factories.push(_factory);
    }

    function delFactory(IFactory _factory) external onlyOwner {
        uint index = uint(-1);
        for (uint i = 0; i < factories.length; i ++) {
            if (factories[i] == _factory) {
                index = i;
                break;
            }
        }
        if (index != uint(-1)) {
            if (index == factories.length - 1) {
                factories[index] = factories[factories.length - 1];
            }
            factories.pop();
        }
    }

    function addMiddleTokens(address _middleToken) external onlyOwner {
        middleTokens.push(_middleToken);
    }

    function delMiddleTokens(address _middleToken) external onlyOwner {
        uint index = uint(-1);
        for (uint i = 0; i < middleTokens.length; i ++) {
            if (middleTokens[i] == _middleToken) {
                index = i;
                break;
            }
        }
        if (index != uint(-1)) {
            if (index == middleTokens.length - 1) {
                middleTokens[index] = middleTokens[middleTokens.length - 1];
            }
            middleTokens.pop();
        }
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'LibraryLibraryE: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'LibraryLibraryE: ZERO_ADDRESS');
    }

    function getPriceByPair(address pair, address token, address baseToken) internal view returns (uint price, uint tokenReserve) {
        (uint reserve0, uint reserve1, ) = IBabyPair(pair).getReserves();
        (address token0, ) = sortTokens(token, baseToken);
        if (token0 != token) {
            (reserve0, reserve1) = (reserve1, reserve0);
        }
        if (reserve0 == 0 || reserve1 == 0) {
            return (0, 0);
        }
        uint tokenDecimal = ERC20(token).decimals();
        uint baseTokenDecimal = ERC20(baseToken).decimals();
        if (tokenDecimal < baseTokenDecimal) {
            price = reserve1.mul(PRICE_BASE).div(reserve0).div(10 ** (baseTokenDecimal - tokenDecimal));
        } else {
            price = reserve1.mul(PRICE_BASE).mul(10 ** (baseTokenDecimal - tokenDecimal)).div(reserve0);
        }
        tokenReserve = reserve0;
    }

    function getMiddleTokenPrice(address token, address baseToken) public view returns (uint price) {
        if (token == baseToken) {
            return PRICE_BASE;
        }
        uint maxReserve;
        for (uint i = 0; i < factories.length; i ++) {
            address pair = factories[i].getPair(token, baseToken);
            if (pair == address(0)) {
                continue;
            }
            (uint currentPrice, uint currentReserve) = getPriceByPair(pair, token, baseToken);
            if (currentReserve > maxReserve) {
                price = currentPrice;
                maxReserve = currentReserve;
            }
        }
    }

    function getTokenPrice(address token, address baseToken) public view returns (uint price) {
        if (token == baseToken) {
            return PRICE_BASE;
        }
        uint maxReserve;
        for (uint i = 0; i < factories.length; i ++) {
            for (uint j = 0; j < middleTokens.length; j ++) {
                address pair = factories[i].getPair(token, middleTokens[j]);
                if (pair == address(0)) {
                    continue;
                }
                (uint currentPrice, uint currentReserve) = getPriceByPair(pair, token, middleTokens[j]);
                if (currentReserve > maxReserve) {
                    price = currentPrice.mul(getMiddleTokenPrice(middleTokens[j], baseToken)).div(PRICE_BASE); 
                    maxReserve = currentReserve;
                }
            }
        }
    }

    function getLpPrice(address lp, address baseToken) public view returns (uint price) {
        (uint reserve0, uint reserve1, ) = IBabyPair(lp).getReserves();
        uint value = 0;
        address token = IBabyPair(lp).token0();
        price = getTokenPrice(token, baseToken);
        if (price != 0) {
            uint decimals = ERC20(token).decimals();
            value = reserve0.mul(price).mul(2).div(PRICE_BASE).div(10 ** decimals);
        } else {
            token = IBabyPair(lp).token1();
            price = getTokenPrice(token, baseToken);
            if (price == 0) {
                return 0;
            }
            uint decimals = ERC20(token).decimals();
            value = reserve1.mul(price).mul(2).div(PRICE_BASE).div(10 ** decimals);
        }
        uint totalSupply = IBabyPair(lp).totalSupply();
        return value.mul(PRICE_BASE).mul(PRICE_BASE).div(totalSupply);
    }

    function getTokenPrices(address[] memory tokens, address baseToken) external view returns(uint[] memory prices) {
        prices = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i ++) {
            prices[i] = getTokenPrice(tokens[i], baseToken);
        }
    }

    function getLpPrices(address[] memory tokens, address baseToken) external view returns(uint[] memory prices) {
        prices = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i ++) {
            prices[i] = getLpPrice(tokens[i], baseToken);
        }
    }

    function getDefaultTokenPrices(address[] memory tokens) external view returns(uint[] memory prices) {
        prices = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i ++) {
            prices[i] = getTokenPrice(tokens[i], defaultBaseToken);
        }
    }

    function getDefaultLpPrices(address[] memory tokens) external view returns(uint[] memory prices) {
        prices = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i ++) {
            prices[i] = getLpPrice(tokens[i], defaultBaseToken);
        }
    }

    function getBalanceAndDefaultTokenPrices(address user, address[] memory tokens) external view returns(uint[] memory balances, uint[] memory prices, uint[] memory decimals) {
        balances = new uint[](tokens.length);
        prices = new uint[](tokens.length);
        decimals = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i ++) {
            balances[i] = IERC20(tokens[i]).balanceOf(user);
            balances[i] = IERC20(tokens[i]).balanceOf(user);
            decimals[i] = ERC20(tokens[i]).decimals();
            prices[i] = getTokenPrice(tokens[i], defaultBaseToken);
        }
    }

    function getBalanceAndDefaultLpPrices(address user, address[] memory tokens) external view returns(uint[] memory balances, uint[] memory prices, uint[] memory decimals) {
        balances = new uint[](tokens.length);
        prices = new uint[](tokens.length);
        decimals = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i ++) {
            balances[i] = IERC20(tokens[i]).balanceOf(user);
            balances[i] = IERC20(tokens[i]).balanceOf(user);
            decimals[i] = ERC20(tokens[i]).decimals();
            prices[i] = getLpPrice(tokens[i], defaultBaseToken);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '../interfaces/IBabyPair.sol';
import '../interfaces/IFactory.sol';

contract MultHelper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint constant public PRICE_BASE = 1e18;

    IFactory[] public factories;
    address public immutable defaultBaseToken;

    constructor(IFactory[] memory _factories, address _defaultBaseToken) {
        factories = _factories;
        defaultBaseToken = _defaultBaseToken;
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'LibraryLibraryE: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'LibraryLibraryE: ZERO_ADDRESS');
    }

    function getPrice(address token, address baseToken) public view returns (uint) {
        if (token == baseToken) {
            return PRICE_BASE;
        }
        uint price;
        uint maxReserve0;
        for (uint i = 0; i < factories.length; i ++) {
            address pair = factories[i].getPair(token, baseToken);
            if (pair == address(0)) {
                continue;
            }
            (uint reserve0, uint reserve1, ) = IBabyPair(pair).getReserves();
            (address token0, ) = sortTokens(token, baseToken);
            if (token0 == baseToken) {
                (reserve0, reserve1) = (reserve1, reserve0);
            }
            if (reserve0 > maxReserve0) {
                uint tokenDecimal = ERC20(token).decimals();
                uint baseTokenDecimal = ERC20(baseToken).decimals();
                if (tokenDecimal < baseTokenDecimal) {
                    price = reserve1.mul(PRICE_BASE).div(reserve0).div(10 ** (baseTokenDecimal - tokenDecimal));
                } else {
                    price = reserve1.mul(PRICE_BASE).mul(10 ** (baseTokenDecimal - tokenDecimal)).div(reserve0);
                }
                maxReserve0 = reserve0;
            }
        }
        return price;
    }

    function getPrices(address[] memory tokens, address baseToken) external view returns(uint[] memory prices) {
        prices = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i ++) {
            prices[i] = getPrice(tokens[i], baseToken);
        }
    }

    function getDefaultPrices(address[] memory tokens) external view returns(uint[] memory prices) {
        prices = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i ++) {
            prices[i] = getPrice(tokens[i], defaultBaseToken);
        }
    }

    function getBalanceAndDefaultPrices(address user, address[] memory tokens) external view returns(uint[] memory balances, uint[] memory prices, uint[] memory decimals) {
        balances = new uint[](tokens.length);
        prices = new uint[](tokens.length);
        decimals = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i ++) {
            balances[i] = IERC20(tokens[i]).balanceOf(user);
            balances[i] = IERC20(tokens[i]).balanceOf(user);
            decimals[i] = ERC20(tokens[i]).decimals();
            prices[i] = getPrice(tokens[i], defaultBaseToken);
        }
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.4;

import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/EnumerableMap.sol';
import '@openzeppelin/contracts/utils/EnumerableSet.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '../interfaces/IMasterChef.sol';

contract NFTFarm is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    event Stake(address user, uint256 tokenId, uint256 amount);
    event Unstake(address user, uint256 tokenId, uint256 amount);
    event Claim(address user, uint256 amount);
    event NewRangeInfo(uint index, uint startIndex, uint endIndex, uint babyValue, uint weight);
    event DelRangeInfo(uint index);

    uint constant public WEIGHT_BASE = 1e2;
    uint256 constant public RATIO = 1e18;

    struct PoolInfo {
        ERC721 token;
        uint256 totalShares;
        uint256 accBabyPerShare;
    }

    struct UserInfo {
        uint256 amount;
        uint256 debt;
        uint256 pending;
    }

    struct RangeInfo {
        uint startIndex;
        uint endIndex;
        uint babyValue;
        uint weight;
    }

    PoolInfo public poolInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(address => EnumerableSet.UintSet) holderTokens;
    EnumerableMap.UintToAddressMap tokenOwners;
    mapping(uint256 => uint256) public tokenWeight;
    RangeInfo[] public rangeInfo;
    ERC20 public immutable babyToken;
    ERC721 public immutable nftToken;
    IMasterChef immutable masterChef;
    address public vault;

    constructor(ERC20 _babyToken, ERC721 _nftToken, IMasterChef _masterChef, address _vault) {
        require(address(_babyToken) != address(0), "_babyToken address cannot be 0");
        require(address(_nftToken) != address(0), "_nftToken address cannot be 0");
        require(address(_masterChef) != address(0), "_masterChef address cannot be 0");
        require(_vault != address(0), "_vault address cannot be 0");
        babyToken = _babyToken;
        nftToken = _nftToken;
        masterChef = _masterChef;
        vault = _vault;
    }

    function addRangeInfo(uint _startIndex, uint _endIndex, uint _babyValue, uint _weight) external onlyOwner {
        require(_startIndex <= _endIndex, "error index");
        rangeInfo.push(RangeInfo({
            startIndex: _startIndex,
            endIndex: _endIndex,
            babyValue: _babyValue,
            weight: _weight
        }));
        emit NewRangeInfo(rangeInfo.length - 1, _startIndex, _endIndex, _babyValue, _weight);
    }

    function setRangeInfo(uint _index, uint _startIndex, uint _endIndex, uint _babyValue, uint _weight) external onlyOwner {
        require(_index < rangeInfo.length, "illegal index");
        require(_startIndex <= _endIndex, "error index");
        rangeInfo[_index] = RangeInfo({
            startIndex: _startIndex,
            endIndex: _endIndex,
            babyValue: _babyValue,
            weight: _weight
        });
        emit NewRangeInfo(_index, _startIndex, _endIndex, _babyValue, _weight);
    }

    function delRangeInfo(uint _index) external onlyOwner {
        require(_index < rangeInfo.length, "illegal index"); 
        if (_index < rangeInfo.length - 1) {
            RangeInfo memory _lastRangeInfo = rangeInfo[rangeInfo.length - 1];
            rangeInfo[_index] = rangeInfo[rangeInfo.length - 1];
            emit NewRangeInfo(_index, _lastRangeInfo.startIndex, _lastRangeInfo.endIndex, _lastRangeInfo.babyValue, _lastRangeInfo.weight);
        }
        rangeInfo.pop();
        emit DelRangeInfo(rangeInfo.length);
    }

    function stake(uint _tokenId, uint _idx) public nonReentrant {
        require(_idx < rangeInfo.length, "illegal idx");
        RangeInfo memory _rangeInfo = rangeInfo[_idx];
        require(_tokenId >= _rangeInfo.startIndex && _tokenId <= _rangeInfo.endIndex, "illegal tokenId");
        uint stakeBaby = _rangeInfo.babyValue.mul(_rangeInfo.weight).div(WEIGHT_BASE);
        SafeERC20.safeTransferFrom(babyToken, vault, address(this), stakeBaby);
        nftToken.transferFrom(msg.sender, address(this), _tokenId);

        PoolInfo memory _poolInfo = poolInfo;
        UserInfo memory _userInfo = userInfo[msg.sender];
        //uint _pending = masterChef.pendingCake(0, address(this));
        uint balanceBefore = babyToken.balanceOf(address(this));
        masterChef.enterStaking(0);
        uint balanceAfter = babyToken.balanceOf(address(this));
        uint _pending = balanceAfter.sub(balanceBefore);
        if (_pending > 0 && _poolInfo.totalShares > 0) {
            poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(_pending.mul(RATIO).div(_poolInfo.totalShares));
            _poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(_pending.mul(RATIO).div(_poolInfo.totalShares));
        }
        if (_userInfo.amount > 0) {
            userInfo[msg.sender].pending = _userInfo.pending.add(_userInfo.amount.mul(_poolInfo.accBabyPerShare).div(RATIO).sub(_userInfo.debt));
        }
        babyToken.approve(address(masterChef), stakeBaby.add(_pending));
        masterChef.enterStaking(stakeBaby.add(_pending));
        userInfo[msg.sender].amount = _userInfo.amount.add(stakeBaby);
        holderTokens[msg.sender].add(_tokenId);
        tokenOwners.set(_tokenId, msg.sender);
        tokenWeight[_tokenId] = stakeBaby;
        poolInfo.totalShares = _poolInfo.totalShares.add(stakeBaby);
        userInfo[msg.sender].debt = _poolInfo.accBabyPerShare.mul(_userInfo.amount.add(stakeBaby)).div(RATIO);
        emit Stake(msg.sender, _tokenId, stakeBaby);
    }

    function stakeAll(uint[] memory _tokenIds, uint[] memory _idxs) external {
        require(_tokenIds.length == _idxs.length, "illegal array length");
        for (uint i = 0; i < _idxs.length; i ++) {
            stake(_tokenIds[i], _idxs[i]);
        }
    }

    function unstake(uint _tokenId) public nonReentrant {
        require(tokenOwners.get(_tokenId) == msg.sender, "illegal tokenId");

        PoolInfo memory _poolInfo = poolInfo;
        UserInfo memory _userInfo = userInfo[msg.sender];

        //uint _pending = masterChef.pendingCake(0, address(this));
        uint balanceBefore = babyToken.balanceOf(address(this));
        masterChef.leaveStaking(0);
        uint balanceAfter = babyToken.balanceOf(address(this));
        uint _pending = balanceAfter.sub(balanceBefore);
        if (_pending > 0 && _poolInfo.totalShares > 0) {
            poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(_pending.mul(RATIO).div(_poolInfo.totalShares));
            _poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(_pending.mul(RATIO).div(_poolInfo.totalShares));
        }

        uint _userPending = _userInfo.pending.add(_userInfo.amount.mul(_poolInfo.accBabyPerShare).div(RATIO).sub(_userInfo.debt));
        uint _stakeAmount = tokenWeight[_tokenId];
        uint _totalPending = _userPending.add(_stakeAmount);

        if (_totalPending >= _pending) {
            masterChef.leaveStaking(_totalPending.sub(_pending));
        } else {
            //masterChef.leaveStaking(0);
            babyToken.approve(address(masterChef), _pending.sub(_totalPending));
            masterChef.enterStaking(_pending.sub(_totalPending));
        }

        if (_userPending > 0) {
            SafeERC20.safeTransfer(babyToken, msg.sender, _userPending);
            emit Claim(msg.sender, _userPending);
        }
        if (_totalPending > _userPending) {
            SafeERC20.safeTransfer(babyToken, vault, _totalPending.sub(_userPending));
        }

        poolInfo.totalShares = _poolInfo.totalShares.sub(_stakeAmount);
        userInfo[msg.sender].amount = _userInfo.amount.sub(_stakeAmount);
        userInfo[msg.sender].pending = 0;
        userInfo[msg.sender].debt = _userInfo.amount.sub(_stakeAmount).mul(_poolInfo.accBabyPerShare).div(RATIO);
        tokenOwners.remove(_tokenId);
        holderTokens[msg.sender].remove(_tokenId);
        nftToken.transferFrom(address(this), msg.sender, _tokenId);
        delete tokenWeight[_tokenId];
        emit Unstake(msg.sender, _tokenId, _stakeAmount);
    }

    function unstakeAll(uint[] memory _tokenIds) external {
        for (uint i = 0; i < _tokenIds.length; i ++) {
            unstake(_tokenIds[i]);
        }
    }

    function claim(address _user) external nonReentrant {
        PoolInfo memory _poolInfo = poolInfo;
        UserInfo memory _userInfo = userInfo[_user];

        //uint _pending = masterChef.pendingCake(0, address(this));
        uint balanceBefore = babyToken.balanceOf(address(this));
        masterChef.leaveStaking(0);
        uint balanceAfter = babyToken.balanceOf(address(this));
        uint _pending = balanceAfter.sub(balanceBefore);
        if (_pending > 0 && _poolInfo.totalShares > 0) {
            poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(_pending.mul(RATIO).div(_poolInfo.totalShares));
            _poolInfo.accBabyPerShare = _poolInfo.accBabyPerShare.add(_pending.mul(RATIO).div(_poolInfo.totalShares));
        }
        uint _userPending = _userInfo.pending.add(_userInfo.amount.mul(_poolInfo.accBabyPerShare).div(RATIO).sub(_userInfo.debt));
        if (_userPending == 0) {
            return;
        }
        if (_userPending >= _pending) {
            masterChef.leaveStaking(_userPending.sub(_pending));
        } else {
            //masterChef.leaveStaking(0);
            babyToken.approve(address(masterChef), _pending.sub(_userPending));
            masterChef.enterStaking(_pending.sub(_userPending));
        }
        SafeERC20.safeTransfer(babyToken, _user, _userPending);
        emit Claim(_user, _userPending);
        userInfo[_user].debt = _userInfo.amount.mul(_poolInfo.accBabyPerShare).div(RATIO);
        userInfo[_user].pending = 0;
    }

    function pending(address _user) external view returns (uint256) {
        uint _pending = masterChef.pendingCake(0, address(this));
        if (poolInfo.totalShares == 0) {
            return 0;
        }
        uint acc = poolInfo.accBabyPerShare.add(_pending.mul(RATIO).div(poolInfo.totalShares));
        uint userPending = userInfo[_user].pending.add(userInfo[_user].amount.mul(acc).div(RATIO).sub(userInfo[_user].debt));
        return userPending;
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return holderTokens[owner].length();
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        return holderTokens[owner].at(index);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.7.4;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '../interfaces/IVBabyOwner.sol';
import '../interfaces/IMasterChef.sol';
import '../interfaces/IBabyToken.sol';

contract VBabyFarmer is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IBabyToken;

    uint constant public PERCENT_BASE = 1e6;

    IMasterChef immutable public masterChef;
    IBabyToken immutable public babyToken;
    IVBabyOwner immutable public vBabyOwner;
    mapping(address => bool) public operators;

    modifier onlyOperator() {
        require(operators[msg.sender], "only the operator can do this");
        _;
    }

    constructor(IMasterChef _masterChef, IVBabyOwner _vBabyOwner) {
        masterChef = _masterChef;
        vBabyOwner = _vBabyOwner;
        babyToken = _vBabyOwner.babyToken();
    }

    function addOperator(address _operator) external onlyOwner {
        operators[_operator] = true;
    }

    function delOperator(address _operator) external onlyOwner {
        operators[_operator] = false;
    }

    function _repay() internal {
        (uint amount, ) = masterChef.userInfo(0, address(this));
        if (amount > 0) {
            masterChef.leaveStaking(amount);
        }
        uint balance = babyToken.balanceOf(address(this));
        if (balance > 0) {
            babyToken.approve(address(vBabyOwner), balance);
            vBabyOwner.repay(balance);
        }
    }

    function repay() public onlyOwner {
        _repay();
    }

    function _borrow() internal {
        vBabyOwner.borrow();
        uint balance = babyToken.balanceOf(address(this));
        uint pending = masterChef.pendingCake(0, address(this));
        uint amount = balance.add(pending);
        if (amount > 0) {
            babyToken.approve(address(masterChef), amount);
            masterChef.enterStaking(amount);
        }
    }

    function borrow() public onlyOwner {
        _borrow();
    }

    function doHardWork() external onlyOperator {
        _repay();
        _borrow();
    }

    function contractCall(address _contract, bytes memory _data) public onlyOwner {
        (bool success, ) = _contract.call(_data);
        require(success, "response error");
        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 { revert(free_mem_ptr, returndatasize()) }
            default { return(free_mem_ptr, returndatasize()) }
        }
    }

    function masterChefCall(bytes memory _data) external onlyOwner {
        contractCall(address(masterChef), _data);
    }

    function babyTokenCall(bytes memory _data) external onlyOwner {
        contractCall(address(babyToken), _data);
    }

    function vBabyOwnerCall(bytes memory _data) external onlyOwner {
        contractCall(address(vBabyOwner), _data);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './IBabyToken.sol';

interface IVBabyOwner {

    function babyToken() external returns (IBabyToken);

    function repay(uint amount) external returns (uint, uint);

    function borrow() external returns (uint);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IBabyToken is IERC20 {

}

// SPDX-License-Identifier: MIT

pragma solidity =0.7.4;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '../interfaces/IVBabyToken.sol';
import '../interfaces/IBabyToken.sol';

contract VBabyOwner is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IBabyToken;

    event Borrow(address user, uint amount, uint userBorrowed, uint totalBorrowed, uint currentBalance);
    event Repay(address user, uint repayAmount, uint donateAmount, uint userBorrowed, uint totalBorrowed, uint currentBalance);

    uint constant public PERCENT_BASE = 1e6;
    uint constant public MAX_BORROW_PERCENT = 8e5;

    IBabyToken immutable public babyToken;
    IVBabyToken immutable public vBabyToken;
    mapping(address => uint) public farmers;
    mapping(address => bool) public isFarmer;
    uint public totalPercent;
    mapping(address => uint) public farmerBorrow;
    uint public totalBorrow;
    uint public totalDonate;

    constructor(IVBabyToken _vBabyToken) {
        vBabyToken = _vBabyToken;
        babyToken = IBabyToken(_vBabyToken._babyToken());
    }

    modifier onlyFarmer() {
        require(isFarmer[msg.sender], "only farmer can do this");
        _;
    }

    function vBabySetCanTransfer(bool allowed) external onlyOwner {
        vBabyToken.setCanTransfer(allowed);
    }

    function vBabyChangePerReward(uint256 babyPerBlock) external onlyOwner {
        vBabyToken.changePerReward(babyPerBlock);
    }

    function vBabyUpdateBABYFeeBurnRatio(uint256 babyFeeBurnRatio) external onlyOwner {
        vBabyToken.updateBABYFeeBurnRatio(babyFeeBurnRatio);
    }

    function vBabyUpdateBABYFeeReserveRatio(uint256 babyFeeReserve) external onlyOwner {
        vBabyToken.updateBABYFeeReserveRatio(babyFeeReserve);
    }

    function vBabyUpdateTeamAddress(address team) external onlyOwner {
        vBabyToken.updateTeamAddress(team);
    }

    function vBabyUpdateTreasuryAddress(address treasury) external onlyOwner {
        vBabyToken.updateTreasuryAddress(treasury);
    }

    function vBabyUpdateReserveAddress(address newAddress) external onlyOwner {
        vBabyToken.updateReserveAddress(newAddress);
    }

    function vBabySetSuperiorMinBABY(uint256 val) external onlyOwner {
        vBabyToken.setSuperiorMinBABY(val);
    }

    function vBabySetRatioValue(uint256 ratioFee) external onlyOwner {
        vBabyToken.setRatioValue(ratioFee);
    }

    function vBabyEmergencyWithdraw() external onlyOwner {
        vBabyToken.emergencyWithdraw();
        uint currentBalance = babyToken.balanceOf(address(this));
        if (currentBalance > 0) {
            babyToken.safeTransfer(owner(), currentBalance);
        }
    }

    function vBabyTransferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "illegal newOwner");
        vBabyToken.transferOwnership(_newOwner);
    }

    function contractCall(address _contract, bytes memory _data) public onlyOwner {
        (bool success, ) = _contract.call(_data);
        require(success, "response error");
        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 { revert(free_mem_ptr, returndatasize()) }
            default { return(free_mem_ptr, returndatasize()) }
        }
    }

    function babyTokenCall(bytes memory _data) external onlyOwner {
        contractCall(address(babyToken), _data);
    }

    function vBabyTokenCall(bytes memory _data) external onlyOwner {
        contractCall(address(vBabyToken), _data);
    }

    function setFarmer(address _farmer, uint _percent) external onlyOwner {
        require(_farmer != address(0), "illegal farmer");
        require(_percent <= PERCENT_BASE, "illegal percent");
        totalPercent = totalPercent.sub(farmers[_farmer]).add(_percent);
        farmers[_farmer] = _percent;
        require(totalPercent <= MAX_BORROW_PERCENT, "illegal percent value");
    }

    function addFarmer(address _farmer) external onlyOwner {
        isFarmer[_farmer] = true;
    }

    function delFarmer(address _farmer) external onlyOwner {
        isFarmer[_farmer] = false;
    }

    function borrow() external onlyFarmer returns (uint) {
        uint totalBaby = babyToken.balanceOf(address(vBabyToken)).add(totalBorrow);
        uint maxBorrow = totalBaby.mul(farmers[msg.sender]).div(PERCENT_BASE);
        if (maxBorrow > farmerBorrow[msg.sender]) {
            maxBorrow = maxBorrow.sub(farmerBorrow[msg.sender]);
        } else {
            maxBorrow = 0;
        }
        if (maxBorrow > 0) {
            farmerBorrow[msg.sender] = farmerBorrow[msg.sender].add(maxBorrow);
            vBabyToken.emergencyWithdraw();
            uint currentBalance = babyToken.balanceOf(address(this));
            require(currentBalance >= maxBorrow, "illegal baby balance");
            totalBorrow = totalBorrow.add(maxBorrow);
            babyToken.safeTransfer(msg.sender, maxBorrow);
            babyToken.safeTransfer(address(vBabyToken), currentBalance.sub(maxBorrow));
        }
        emit Borrow(msg.sender, maxBorrow, farmerBorrow[msg.sender], totalBorrow, babyToken.balanceOf(address(vBabyToken)));
        return maxBorrow;
    }

    function repay(uint _amount) external onlyFarmer returns (uint, uint) {
        babyToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint repayAmount; 
        uint donateAmount;
        if (_amount > farmerBorrow[msg.sender]) {
            repayAmount = farmerBorrow[msg.sender];
            donateAmount = _amount.sub(repayAmount);
        } else {
            repayAmount = _amount;
        }
        require(_amount == repayAmount.add(donateAmount), "repay error");
        if (repayAmount > 0) {
            totalBorrow = totalBorrow.sub(repayAmount);
            farmerBorrow[msg.sender] = farmerBorrow[msg.sender].sub(repayAmount);
            babyToken.safeTransfer(address(vBabyToken), repayAmount);
        }
        if (donateAmount > 0) {
            babyToken.approve(address(vBabyToken), donateAmount);            
            totalDonate = totalDonate.add(donateAmount);
            vBabyToken.donate(donateAmount);
        }
        emit Repay(msg.sender, repayAmount, donateAmount, farmerBorrow[msg.sender], totalBorrow, babyToken.balanceOf(address(vBabyToken)));
        return (repayAmount, donateAmount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

interface IVBabyToken {

    function setCanTransfer(bool allowed) external;

    function changePerReward(uint256 babyPerBlock) external;

    function updateBABYFeeBurnRatio(uint256 babyFeeBurnRatio) external;

    function updateBABYFeeReserveRatio(uint256 babyFeeReserve) external;

    function updateTeamAddress(address team) external;

    function updateTreasuryAddress(address treasury) external;

    function updateReserveAddress(address newAddress) external;

    function setSuperiorMinBABY(uint256 val) external;

    function _babyToken() external returns (address);

    function emergencyWithdraw() external;

    function transferOwnership(address newOwner) external;

    function setRatioValue(uint256 ratioFee) external;

    function donate(uint256 babyAmount) external;

}

// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at BscScan.com on 2021-06-02
 */

/**

           /\ /|
          |||| |
           \ | \
       _ _ /  @ @
     /    \   =>X<=
   /|      |   /
   \|     /__| |
     \_____\ \__\

   # Hare Token features:
   ⤏ 5% fee distributed to all holders every transaction
   ⤏ 5% fee auto added to the liquidity pool every transaction
   ⤏ 50% Supply is burned at start.
   ⤏ Liquidity pool is locked 
   ⤏ Ownership will be renounced after presale
   ⤏ Release will be on PancakeSwap V2
   # Website : haretoken.finance
 */

pragma solidity >=0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./TOYSwap.sol";

contract TOYToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromSwapAndLiquify;
    mapping(address => bool) private _isExcludedToSwapAndLiquify;
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1 * 10**18 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "Toy Doge Coin";
    string private constant _symbol = "TOYDOGE";
    uint8 private constant _decimals = 9;

    uint256 public _taxFee = 5;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _liquidityFee = 7;
    uint256 private _previousLiquidityFee = _liquidityFee;

    TOYSwap public toySwap;
    address public uniswapV2Pair;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public _maxTxAmount = _tTotal;
    uint256 private constant numTokensSellToAddToLiquidity =
        350 * 10**8 * 10**9;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);

    constructor() {
        _rOwned[_msgSender()] = _rTotal;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function setSwap(address swap) external onlyOwner {
        require(address(swap) != address(0), "swap address cannot be 0");
        _isExcludedFromFee[swap] = true;
        toySwap = TOYSwap(swap);
        uniswapV2Pair = toySwap.uniswapV2Pair();
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) external {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) external onlyOwner {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(toySwap)] = _rOwned[address(toySwap)].add(rLiquidity);
        if (_isExcluded[address(toySwap)])
            _tOwned[address(toySwap)] = _tOwned[address(toySwap)].add(
                tLiquidity
            );
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_liquidityFee).div(10**2);
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;

        _taxFee = 0;
        _liquidityFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from != owner() && to != owner())
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        swapAndLiquify();

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify() public {
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(toySwap));

        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (overMinTokenBalance && !inSwapAndLiquify && swapAndLiquifyEnabled) {
            inSwapAndLiquify = true;

            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            toySwap.swapAndLiquify(contractTokenBalance.mul(5).div(7));
            toySwap.swapAndLiquifyForBaby(contractTokenBalance.mul(2).div(7));

            inSwapAndLiquify = false;
        }
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

interface IERC20 {

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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
 
library SafeMath {
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }
}



// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}



// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract TOYSwap{
    
    using SafeMath for uint256;
    
    IERC20 public constant usdtToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
    
    IERC20 public constant babyToken = IERC20(0x53E562b9B7E5E94b81f10e96Ee70Ad06df3D2657);
   
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    IERC20 public immutable toyToken;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    constructor (IERC20 _toyToken)  {
        toyToken = _toyToken;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x325E343f1dE602396E256B67eFd1F61C3A6B38Bd);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(_toyToken), address(usdtToken));

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
    }
    
    function swapAndLiquify(uint256 contractTokenBalance) external {
        require(msg.sender == address(toyToken));
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = usdtToken.balanceOf(address(this));

        // swap tokens for ETH
        swapTokensForToken(half,address(toyToken),address(usdtToken)); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = usdtToken.balanceOf(address(this)).sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(toyToken, otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapAndLiquifyForBaby(uint256 contractTokenBalance) external  {
        require(msg.sender == address(toyToken));
    
        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalanceUSDT = usdtToken.balanceOf(address(this));
        // swap tokens for ETH
        swapTokensForToken(contractTokenBalance,address(toyToken),address(usdtToken)); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
        // how much ETH did we just swap into?
        uint256 newBalanceUSDT = usdtToken.balanceOf(address(this)).sub(initialBalanceUSDT);
        uint256 initialBalanceBaby = babyToken.balanceOf(address(this));
        swapTokensForToken(newBalanceUSDT.div(2),address(usdtToken),address(babyToken)); 

        uint256 newBalanceBaby = babyToken.balanceOf(address(this)).sub(initialBalanceBaby);
        // add liquidity to uniswap
        addLiquidity(babyToken, newBalanceBaby, newBalanceUSDT.div(2));
        
        emit SwapAndLiquify(newBalanceBaby, newBalanceUSDT.div(2), newBalanceBaby);
    }

    function swapTokensForToken(uint256 tokenAmount,address path0,address path1) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = path0;
        path[1] = path1;

        IERC20(path[0]).approve(address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(IERC20 token1,uint256 tokenAmount, uint256 usdtAmount) private {
        // approve token transfer to cover all possible scenarios
        token1.approve(address(uniswapV2Router), tokenAmount);
        usdtToken.approve(address(uniswapV2Router), usdtAmount);
        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(token1),
            address(usdtToken),
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }
    
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

import '@openzeppelin/contracts/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "@openzeppelin/contracts/access/Ownable.sol";

contract VBabyDispatch is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event NewRewardToken(IERC20 oldRewardToken, IERC20 newRewardToken);
    event NewVault(address oldVault, address newVault);
    event NewDispatcher(address oldDispatcher, address newDispatcher);
    event NewVerifier(address oldVerifier, address newVerifier);
    event NewCaller(address oldCaller, address newCaller);
    event NewDispatchReward(address from, address to, uint amount);
    event Claim(address user, uint amount, uint totalAmount);
    event NewClaimAmount(address user, uint amount);

    IERC20 public rewardToken;
    address public vault;
    address public dispatcher;
    address public verifier;
    address public caller;
    uint public totalReward;
    uint public remainReward;

    mapping(address => uint) public claimed;

    function setRewardToken(IERC20 _token) external onlyOwner {
        emit NewRewardToken(rewardToken, _token);
        rewardToken = _token;
    }

    function setVault(address _vault) external onlyOwner {
        emit NewVault(vault, _vault);
        vault = _vault;
    }

    function setDispatcher(address _dispatcher) external onlyOwner {
        emit NewDispatcher(dispatcher, _dispatcher);
        dispatcher = _dispatcher;
    }

    function setVerifier(address _verifier) external onlyOwner {
        emit NewVerifier(verifier, _verifier);
        verifier = _verifier;
    }

    function setCaller(address _caller) external onlyOwner {
        emit NewCaller(caller, _caller);
        caller = _caller;
    }

    function setUserClaimed(address _user, uint _amount) external onlyOwner {
        claimed[_user] = _amount;
        emit NewClaimAmount(_user, _amount);
    }

    function setTotalReward(uint _totalReward) external onlyOwner {
        totalReward = _totalReward;
    }

    function setRemainReward(uint _remainReward) external onlyOwner {
        remainReward = _remainReward;
    }

    constructor(IERC20 _token, address _vault, address _dispatcher, address _verifier, address _caller) {
        emit NewRewardToken(rewardToken, _token);
        rewardToken = _token;
        emit NewVault(vault, _vault);
        vault = _vault;
        emit NewDispatcher(dispatcher, _dispatcher);
        dispatcher = _dispatcher;
        emit NewVerifier(verifier, _verifier);
        verifier = _verifier;
        emit NewCaller(caller, _caller);
        caller = _caller;
    }

    modifier onlyCaller() {
        require(msg.sender == caller, "only caller can do this action");
        _;
    }

    function dispatchReward(uint _amount) external onlyCaller {
        rewardToken.safeTransferFrom(vault, dispatcher, _amount);
        totalReward = totalReward.add(_amount);
        remainReward = remainReward.add(_amount);
        emit NewDispatchReward(vault, dispatcher, _amount);
    }

    function getEncodePacked(address user, uint amount) public pure returns (bytes memory) {
        return abi.encodePacked(user, amount);
    }

    function getHash(address user, uint amount) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, amount));
    }

    function getHashToSign(address user, uint amount) external pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(user, amount))));
    }

    function verify(address user, uint amount, uint8 v, bytes32 r, bytes32 s) external view returns (bool) {
        return ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(user, amount)))), v, r, s) == verifier;
    }

    function claim(address user, uint amount, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 hash = keccak256(abi.encodePacked(user, amount));
        bytes32 hashToSign = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        require(ecrecover(hashToSign, v, r, s) == verifier, "illegal verifier");
        uint realAmount = amount.sub(claimed[user]);
        rewardToken.safeTransferFrom(dispatcher, user, realAmount);
        claimed[user] = claimed[user].add(realAmount);
        remainReward = remainReward.sub(realAmount);
        emit Claim(user, realAmount, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Profile is ERC721("Profile", "Profile"), Ownable {
    using SafeERC20 for IERC20;

    mapping(address => bool) public isMinted;

    uint256 public mintFee;

    IERC20 public immutable babyToken;

    uint256 public immutable startMintTime;

    address public constant hole = 0x000000000000000000000000000000000000dEaD;

    uint256 public supplyHard = 10000;
    uint256 public mintTotal;

    mapping(address => uint256) public avatar;

    mapping(uint256 => address) public mintOwners;

    mapping(address => bool) public isAdmin;

    event Mint(uint256 orderId, address account);
    event Grant(uint256 orderId, address account, uint256 tokenId);
    event SetAvatar(address account, uint256 tokenId);

    constructor(
        IERC20 _babyToken,
        uint256 _mintFee,
        uint256 _startMintTime
    ) {
        babyToken = _babyToken;
        mintFee = _mintFee;
        startMintTime = _startMintTime;
    }

    function setAdmin(address admin, bool enable) external onlyOwner {
        require(admin != address(0), "Profile: address is zero");
        isAdmin[admin] = enable;
    }

    function setMintFee(uint256 _mintFee) external onlyOwner {
        mintFee = _mintFee;
    }

    function setSupplyHard(uint256 _supplyHard) external onlyOwner {
        require(
            _supplyHard >= mintTotal,
            "Profile: Supply must not be less than what has been produced"
        );
        supplyHard = _supplyHard;
    }

    function mint() external {
        require(!isMinted[msg.sender], "Profile: mint already involved");
        require(mintTotal <= supplyHard, "Profile: token haven't been minted.");
        require(
            block.timestamp > startMintTime,
            "Profile: It's not the start time"
        );
        isMinted[msg.sender] = true;
        mintTotal = mintTotal + 1;
        mintOwners[mintTotal] = msg.sender;
        babyToken.safeTransferFrom(msg.sender, hole, mintFee);
        emit Mint(mintTotal, msg.sender);
    }

    function grant(uint256 orderId, uint256 tokenId) external onlyAdmin {
        require(!_exists(tokenId), "Profile: token already exists");
        require(
            mintOwners[orderId] != address(0),
            "Profile: token already exists"
        );
        require(tokenId > 0, "Profile: tokenId is invalid");
        _mint(mintOwners[orderId], tokenId);

        emit Grant(orderId, mintOwners[orderId], tokenId);
        delete mintOwners[orderId];
    }

    function setBaseURI(string memory baseUri) external onlyOwner {
        _setBaseURI(baseUri);
    }

    function setAvatar(uint256 tokenId) external {
        require(
            ownerOf(tokenId) == msg.sender || tokenId == 0,
            "set avator of token that is not own"
        );
        avatar[msg.sender] = tokenId;
        emit SetAvatar(msg.sender, tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        if (avatar[from] == tokenId) {
            avatar[from] = 0;
            emit SetAvatar(msg.sender, 0);
        }
        super._transfer(from, to, tokenId);
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Profile: caller is not the admin");
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract GamePadBox is ERC721("BABY-BOX", "BABY-BOX"), Ownable {
    using SafeERC20 for IERC20;

    uint256 public mintFee;

    IERC20 public exchangeToken;

    uint256 public startMintTime;

    address payable public tokenReceiver;

    bool initialized = false;

    uint256 public supplyHard;
    uint256 public mintTotal;

    string private _tokenName;

    string private _tokenSymbol;

    function name() public view virtual override returns (string memory) {
        return _tokenName;
    }

    function symbol() public view virtual override returns (string memory) {
        return _tokenSymbol;
    }

    event Mint(address account, uint256 tokenId);

    function initialize(
        IERC20 _exchangeToken,
        uint256 _mintFee,
        uint256 _startMintTime,
        address payable _tokenReceiver,
        uint256 _supplyHard,
        string memory _name,
        string memory _symbol,
        string memory baseUri,
        address admin
    ) external {
        require(!initialized);
        initialized = true;

        exchangeToken = _exchangeToken;
        mintFee = _mintFee;
        startMintTime = _startMintTime;
        tokenReceiver = _tokenReceiver;
        supplyHard = _supplyHard;
        _setBaseURI(baseUri);
        _tokenName = _name;
        _tokenSymbol = _symbol;
        transferOwnership(admin);
    }

    function setBaseUri(string memory _baseUri) external onlyOwner{
        _setBaseURI(_baseUri);
    }

    function setSupplyHard(uint256 _supplyHard) external onlyOwner {
        require(
            _supplyHard >= mintTotal,
            "GamePadBox: Supply must not be less than what has been produced"
        );
        supplyHard = _supplyHard;
    }

    function mint() external payable {
        require(
            mintTotal < supplyHard,
            "GamePadBox: token haven't been minted."
        );
        require(
            block.timestamp > startMintTime,
            "GamePadBox: It's not the start time"
        );
        mintTotal = mintTotal + 1;
        uint256 tokenId = mintTotal;
        _mint(msg.sender, tokenId);
        if (address(exchangeToken) == address(0)) {
            require(msg.value == mintFee, "GamePadBox: Insufficient payment");
            tokenReceiver.transfer(msg.value);
        } else {
            exchangeToken.safeTransferFrom(msg.sender, tokenReceiver, mintFee);
        }
        emit Mint(msg.sender, tokenId);
    }
}

contract BoxFactory is Ownable {
    event CreateBox(uint256 gid, address boxAddress);
    event CreateGame(uint256 gid, string name);
    event DelGame(uint256 gid);
    event DelBox(uint256 gid, uint256 idx);

    struct GameInfo {
        uint256 gid;
        string name;
        address[] boxes;
    }
    uint256 public gamePadBoxesNumber;
    mapping(uint256 => GameInfo) private gameInfos;

    function gameInfo(uint256 gid)
        public
        view
        returns (string memory name, address[] memory boxes)
    {
        name = gameInfos[gid].name;
        boxes = gameInfos[gid].boxes;
    }

    function createGame(string memory _name) external onlyOwner {
        gamePadBoxesNumber++;
        gameInfos[gamePadBoxesNumber].gid = gamePadBoxesNumber;
        gameInfos[gamePadBoxesNumber].name = _name;

        emit CreateGame(gamePadBoxesNumber, _name);
    }

    function delGame() external onlyOwner {
        require(
            gameInfos[gamePadBoxesNumber].boxes.length == 0,
            "BoxFactory: state that cannot be deleted"
        );

        delete gameInfos[gamePadBoxesNumber];
        emit DelGame(gamePadBoxesNumber--);
    }

    function delBox(uint256 _gid, uint256 _idx) external onlyOwner {
        GameInfo storage info = gameInfos[_gid];
        require(_idx < info.boxes.length, "BoxFactory: index out");
        info.boxes[_idx] = info.boxes[info.boxes.length - 1];
        info.boxes.pop();
        emit DelBox(_gid, _idx);
    }

    function deployPool(
        uint256 gid,
        IERC20 _exchangeToken,
        uint256 _mintFee,
        uint256 _startMintTime,
        address payable _tokenReceiver,
        uint256 _supplyHard,
        string memory _name,
        string memory _symbol,
        string memory baseUri
    ) external onlyOwner {
        GameInfo storage info = gameInfos[gid];
        require(info.gid > 0, "BoxFactory: game has not been created");
        bytes memory bytecode = type(GamePadBox).creationCode;
        bytes32 salt = keccak256(
            abi.encodePacked(
                _exchangeToken,
                _mintFee,
                _startMintTime,
                _tokenReceiver,
                gamePadBoxesNumber,
                block.number
            )
        );
        address boxAddress;
        assembly {
            boxAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        GamePadBox(boxAddress).initialize(
            _exchangeToken,
            _mintFee,
            _startMintTime,
            _tokenReceiver,
            _supplyHard,
            _name,
            _symbol,
            baseUri,
            owner()
        );
        info.boxes.push(boxAddress);
        emit CreateBox(info.gid, boxAddress);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTTricket is ERC721("BABY-TRICKET", "BABY-TRICKET"), Ownable {
    string private _tokenName;

    string private _tokenSymbol;

    // Whether it is initialized
    bool public isInitialized;
    // The address of the smart chef factory
    address public SMART_TICKE_FACTORY;
    bool public canTransfer;
    mapping(address => bool) public _isExcludedFrom;
    mapping(address => bool) public _isExcludedTo;

    constructor() {
        SMART_TICKE_FACTORY = _msgSender();
    }

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function initialize(
        string memory name_,
        string memory symbol_,
        address _owner
    ) public {
        require(!isInitialized, "Already initialized");
        require(msg.sender == SMART_TICKE_FACTORY, "Not the  factory ");
        // Make this contract initialized
        isInitialized = true;

        _tokenName = name_;
        _tokenSymbol = symbol_;
        _isExcludedFrom[address(0)] = true;
        transferOwnership(_owner);
    }

    function switchTransfer(bool onOff) external onlyOwner {
        canTransfer = onOff;
    }

    function excludeFrom(address account) external onlyOwner {
        _isExcludedFrom[account] = true;
    }

    function includeInFrom(address account) external onlyOwner {
        _isExcludedFrom[account] = false;
    }

    function excludeTo(address account) external onlyOwner {
        _isExcludedTo[account] = true;
    }

    function includeInTo(address account) external onlyOwner {
        _isExcludedTo[account] = false;
    }

    function name() public view virtual override returns (string memory) {
        return _tokenName;
    }

    function symbol() public view virtual override returns (string memory) {
        return _tokenSymbol;
    }

    function mint(address to, uint256 tokenId) external {
        require(
            _msgSender() == SMART_TICKE_FACTORY,
            "NFTTicket: No permission"
        );
        _mint(to, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 
    ) internal virtual override {
        require(
            canTransfer || _isExcludedFrom[from] || _isExcludedTo[to],
            "NFTTicket: transfer prohibited"
        );
    }
}

contract INO is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct INOInfo {
        uint256 id;
        uint256 totalSupply;
        uint256 hardcapPerUser;
        address nftTicket;
        uint256 uintPrice;
        uint256 supplied;
        address payable recipient;
        address currency;
        uint256 startTime;
        uint256 duration;
        address vault;
        mapping(address => uint256) mintQuantity;
    }

    uint256 public inoIds;
    mapping(uint256 => INOInfo) public inoInfos;

    event Mint(uint256 id, address account, uint256 number);

    function mintQuantity(uint256 id, address account)
        public
        view
        returns (uint256)
    {
        return inoInfos[id].mintQuantity[account];
    }

    function createINO(
        uint256 totalSupply,
        uint256 hardcapPerUser,
        uint256 uintPrice,
        address currency,
        address vault,
        address payable recipient,
        address nftTicket,
        uint256 startTime,
        uint256 duration,
        string memory name,
        string memory symbol
    ) external onlyOwner {
        if (nftTicket == address(0) || vault == address(0)) {
            require(nftTicket == vault, "INO: Vault cannot be set up");
        }
        inoIds += 1;
        inoInfos[inoIds].id = inoIds;
        inoInfos[inoIds].totalSupply = totalSupply;
        inoInfos[inoIds].hardcapPerUser = hardcapPerUser;
        inoInfos[inoIds].uintPrice = uintPrice;
        inoInfos[inoIds].recipient = recipient;
        inoInfos[inoIds].currency = currency;
        inoInfos[inoIds].startTime = startTime;
        inoInfos[inoIds].duration = duration;

        address nftTicketAddress;
        if (nftTicket == address(0)) {
            bytes memory bytecode = type(NFTTricket).creationCode;
            bytes32 salt = keccak256(abi.encodePacked(inoIds));
            assembly {
                nftTicketAddress := create2(
                    0,
                    add(bytecode, 32),
                    mload(bytecode),
                    salt
                )
            }
            NFTTricket(nftTicketAddress).initialize(name, symbol, msg.sender);
        } else {
            inoInfos[inoIds].vault = vault;
            nftTicketAddress = nftTicket;
        }

        inoInfos[inoIds].nftTicket = nftTicketAddress;
    }

    function mint(uint256 id, uint256 number) external payable {
        INOInfo storage inoInfo = inoInfos[id];
        require(
            inoInfo.supplied.add(number) <= inoInfo.totalSupply,
            "INO: insufficient supply"
        );
        require(block.timestamp >= inoInfo.startTime, "INO: has not started");
        require(
            block.timestamp < inoInfo.startTime.add(inoInfo.duration),
            "INO: ino is over"
        );
        require(
            inoInfo.mintQuantity[_msgSender()].add(number) <=
                inoInfo.hardcapPerUser,
            "INO: Exceed the purchase limit"
        );
        inoInfo.mintQuantity[_msgSender()] = inoInfo
            .mintQuantity[_msgSender()]
            .add(number);

        if (inoInfo.currency == address(0)) {
            require(
                msg.value == number.mul(inoInfo.uintPrice),
                "INO: wrong payment amount"
            );
            inoInfo.recipient.transfer(msg.value);
        } else {
            IERC20(inoInfo.currency).safeTransferFrom(
                _msgSender(),
                inoInfo.recipient,
                number.mul(inoInfo.uintPrice)
            );
        }
        for (uint256 i = 0; i != number; i++) {
            inoInfo.supplied = inoInfo.supplied.add(1);
            if (inoInfo.vault == address(0)) {
                NFTTricket(inoInfo.nftTicket).mint(
                    _msgSender(),
                    inoInfo.supplied
                );
            } else {
                mintForVault(
                    inoInfo.vault,
                    _msgSender(),
                    ERC721(inoInfo.nftTicket)
                );
            }
        }

        emit Mint(id, _msgSender(), number);
    }

    function mintForVault(
        address vault,
        address to,
        ERC721 nftAddress
    ) internal {
        uint256 balance = nftAddress.balanceOf(vault);
        require(balance > 0, "INO: Insufficient balance in the vault");
        uint256 idx = uint256(
            keccak256(
                abi.encodePacked(block.difficulty, block.timestamp, balance)
            )
        ) % balance;
        uint256 tokenId = nftAddress.tokenOfOwnerByIndex(vault, idx);
        nftAddress.transferFrom(vault, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

contract HoldStake is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct HoldPool {
        IERC20 token;
        uint256 hardcap;
        uint256 preUserHardcap;
        uint256 apy; //100% = 1 * 10**6
        uint256 depositTotal;
        uint256 interest;
        uint256 finishTime;
    }

    struct DepositInfo {
        uint256 pid;
        uint256 value;
        uint256 duration;
        uint256 earned;
        uint256 unlockTime;
        bool present;
    }

    mapping(uint256 => uint256) private finalCompleTime;

    mapping(uint256 => uint256) private interestHardcap;
    mapping(uint256 => address) public interestProvider;

    mapping(uint256 => uint256) public lockDuration;
    mapping(uint256 => HoldPool) public holdPools;
    mapping(address => mapping(uint256 => DepositInfo)) public depositInfos;
    uint256 public pid;

    event AddHoldPool(
        uint256 pid,
        address token,
        uint256 hardcap,
        uint256 preUserHardcap,
        uint256 apy
    );

    event Deposit(
        uint256 indexed pid,
        address indexed account,
        uint256 indexed duration,
        uint256 value
    );

    event Harvest(uint256 indexed pid, address indexed account, uint256 earned);

    event Withdraw(uint256 indexed pid, address indexed account, uint256 value);

    event AnnounceEndTime(uint256 indexed pid, uint256 indexed finishTime);

    event InterestInjection(
        uint256 indexed pid,
        address indexed provider,
        uint256 value
    );
    event InterestRefund(
        uint256 indexed pid,
        address indexed recipient,
        uint256 value
    );

    constructor() {
        lockDuration[1] = 15 days;
        lockDuration[2] = 30 days;
        lockDuration[3] = 60 days;
        lockDuration[4] = 90 days;
    }

    function addPool(
        IERC20 token,
        uint256 hardcap,
        uint256 preUserHardcap,
        uint256 apy
    ) external onlyOwner {
        require(address(token) != address(0), "Hold: Token address is zero");
        token.balanceOf(address(this)); //Check ERC20
        pid++;
        HoldPool storage holdPool = holdPools[pid];
        holdPool.apy = apy;
        holdPool.token = token;
        holdPool.hardcap = hardcap;
        holdPool.preUserHardcap = preUserHardcap;

        emit AddHoldPool(pid, address(token), hardcap, preUserHardcap, apy);
    }

    function injectInterest(uint256 _pid) external {
        require(_pid > 0 && _pid <= pid, "Hold: Can't find this pool");
        HoldPool memory holdPool = holdPools[_pid];
        require(
            interestHardcap[_pid] == 0 && interestProvider[_pid] == address(0),
            "Hold: The pool interest has been injected"
        );
        uint256 interestTotal = holdPool
            .hardcap
            .mul(holdPool.apy)
            .mul(lockDuration[4])
            .div(365 days)
            .div(1e6);
        interestHardcap[_pid] = interestTotal;
        interestProvider[_pid] = msg.sender;
        holdPool.token.safeTransferFrom(
            msg.sender,
            address(this),
            interestTotal
        );

        emit InterestInjection(_pid, msg.sender, interestTotal);
    }

    function deposit(
        uint256 _pid,
        uint256 value,
        uint256 opt
    ) external checkFinish(_pid, lockDuration[opt]) {
        require(_pid > 0 && _pid <= pid, "Hold: Can't find this pool");
        require(lockDuration[opt] > 0, "Hold: Without this option");
        require(
            holdPools[_pid].depositTotal < holdPools[_pid].hardcap,
            "Hold: Hard cap limit"
        );
        if (holdPools[_pid].depositTotal.add(value) > holdPools[_pid].hardcap) {
            value = holdPools[_pid].hardcap.sub(holdPools[_pid].depositTotal);
        }
        require(
            value <= holdPools[_pid].preUserHardcap,
            "Hold: Personal hard cap limit"
        );
        require(
            !depositInfos[msg.sender][_pid].present,
            "Hold: Individuals can only invest once at the same time"
        );
        holdPools[_pid].depositTotal = holdPools[_pid].depositTotal.add(value);
        depositInfos[msg.sender][_pid].present = true;
        depositInfos[msg.sender][_pid].value = value;
        depositInfos[msg.sender][_pid].pid = _pid;
        depositInfos[msg.sender][_pid].duration = lockDuration[opt];
        depositInfos[msg.sender][_pid].unlockTime = lockDuration[opt].add(
            block.timestamp
        );
        depositInfos[msg.sender][_pid].earned = value
            .mul(holdPools[_pid].apy)
            .mul(lockDuration[opt])
            .div(365 days)
            .div(1e6);
        holdPools[_pid].interest = holdPools[_pid].interest.add(
            depositInfos[msg.sender][_pid].earned
        );
        holdPools[_pid].token.safeTransferFrom(
            msg.sender,
            address(this),
            value
        );
        emit Deposit(_pid, msg.sender, lockDuration[opt], value);
    }

    function harvest(uint256 _pid) external {
        require(_pid > 0 && _pid <= pid, "Hold: Can't find this pool");
        DepositInfo storage depositInfo = depositInfos[msg.sender][_pid];
        require(
            block.timestamp > depositInfo.unlockTime,
            "Hold: Unlocking time is not reached"
        );
        require(depositInfo.earned > 0, "Hold: There is no income to receive");
        uint256 earned = depositInfo.earned;
        depositInfo.earned = 0;
        holdPools[depositInfo.pid].token.safeTransfer(msg.sender, earned);

        emit Harvest(depositInfo.pid, msg.sender, earned);
    }

    function withdraw(uint256 _pid) external {
        require(_pid > 0 && _pid <= pid, "Hold: Can't find this pool");
        DepositInfo storage depositInfo = depositInfos[msg.sender][_pid];
        require(
            block.timestamp > depositInfo.unlockTime,
            "Hold: Unlocking time is not reached"
        );
        require(depositInfo.value > 0, "Hold: There is no deposit to receive");
        uint256 value = depositInfo.value;
        depositInfo.value = 0;
        depositInfo.present = false;
        holdPools[depositInfo.pid].token.safeTransfer(msg.sender, value);
        emit Withdraw(depositInfo.pid, msg.sender, value);
    }

    modifier checkFinish(uint256 _pid, uint256 duration) {
        _;
        if (block.timestamp.add(duration) > finalCompleTime[_pid]) {
            finalCompleTime[_pid] = block.timestamp.add(duration);
        }
        if (holdPools[_pid].hardcap == holdPools[_pid].depositTotal) {
            holdPools[_pid].finishTime = finalCompleTime[_pid];
            emit AnnounceEndTime(_pid, holdPools[_pid].finishTime);

            uint256 interestLeft = interestHardcap[_pid].sub(
                holdPools[_pid].interest
            );
            if (interestLeft > 0) {
                holdPools[_pid].token.safeTransfer(
                    interestProvider[_pid],
                    interestLeft
                );
                emit InterestRefund(_pid, interestProvider[_pid], interestLeft);
            }
        }
    }

    function holdInProgress() external view returns (HoldPool[] memory) {
        uint256 len;
        for (uint256 i = 1; i <= pid; i++) {
            if (holdPools[i].finishTime > block.timestamp) {
                len++;
            }
        }
        HoldPool[] memory pools = new HoldPool[](len);
        for (uint256 i = 1; i <= pid; i++) {
            if (holdPools[i].finishTime > block.timestamp) {
                pools[i] = holdPools[i];
            }
        }
        return pools;
    }

    function holdInFinished() external view returns (HoldPool[] memory) {
        uint256 len;
        for (uint256 i = 1; i <= pid; i++) {
            if (holdPools[i].finishTime <= block.timestamp) {
                len++;
            }
        }
        HoldPool[] memory pools = new HoldPool[](len);
        for (uint256 i = 1; i <= pid; i++) {
            if (holdPools[i].finishTime <= block.timestamp) {
                pools[i] = holdPools[i];
            }
        }
        return pools;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function pendingCake(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function userInfo(uint256 _pid, address _user)
        external
        view
        returns (uint256, uint256);

    function emergencyWithdraw(uint256 _pid) external;
}

contract AutoBabyPool is Ownable, Pausable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct UserInfo {
        uint256 shares; // number of shares for a user
        uint256 lastDepositedTime; // keeps track of deposited time for potential penalty
        uint256 babyAtLastUserAction; // keeps track of baby deposited at the last user action
        uint256 lastUserActionTime; // keeps track of the last user action time
    }

    IERC20 public immutable token; // Baby token
    IERC20 public immutable receiptToken; // Syrup token

    IMasterChef public immutable masterchef;

    mapping(address => UserInfo) public userInfo;

    uint256 public totalShares;
    uint256 public lastHarvestedTime;
    address public admin;
    address public treasury;

    uint256 public constant MAX_PERFORMANCE_FEE = 500; // 5%
    uint256 public constant MAX_CALL_FEE = 100; // 1%
    uint256 public constant MAX_WITHDRAW_FEE = 100; // 1%
    uint256 public constant MAX_WITHDRAW_FEE_PERIOD = 72 hours; // 3 days

    uint256 public performanceFee = 200; // 2%
    uint256 public callFee = 25; // 0.25%
    uint256 public withdrawFee = 10; // 0.1%
    uint256 public withdrawFeePeriod = 72 hours; // 3 days

    event Deposit(
        address indexed sender,
        uint256 amount,
        uint256 shares,
        uint256 lastDepositedTime
    );
    event Withdraw(address indexed sender, uint256 amount, uint256 shares);
    event Harvest(
        address indexed sender,
        uint256 performanceFee,
        uint256 callFee
    );
    event Pause();
    event Unpause();

    /**
     * @notice Constructor
     * @param _token: Baby token contract
     * @param _receiptToken: Syrup token contract
     * @param _masterchef: MasterChef contract
     * @param _admin: address of the admin
     * @param _treasury: address of the treasury (collects fees)
     */
    constructor(
        IERC20 _token,
        IERC20 _receiptToken,
        IMasterChef _masterchef,
        address _admin,
        address _treasury
    ) {
        require(
            address(_token) != address(0),
            "_token should not be address(0)"
        );
        require(
            address(_receiptToken) != address(0),
            "_receiptToken should not be address(0)"
        );
        require(
            address(_masterchef) != address(0),
            "_masterchef should not be address(0)"
        );
        require(_admin != address(0), "_admin should not be address(0)");
        require(_treasury != address(0), "_treasury should not be address(0)");

        token = _token;
        receiptToken = _receiptToken;
        masterchef = _masterchef;
        admin = _admin;
        treasury = _treasury;

        // Infinite approve
        IERC20(_token).safeApprove(address(_masterchef), uint256(-1));
    }

    /**
     * @notice Checks if the msg.sender is the admin address
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "admin: wut?");
        _;
    }

    /**
     * @notice Checks if the msg.sender is a contract or a proxy
     */
    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    /**
     * @notice Deposits funds into the Baby Vault
     * @dev Only possible when contract not paused.
     * @param _amount: number of tokens to deposit (in Baby)
     */
    function deposit(uint256 _amount)
        external
        whenNotPaused
        notContract
        nonReentrant("deposit")
    {
        require(_amount > 0, "Nothing to deposit");

        uint256 pool = balanceOf();
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 currentShares = 0;
        if (totalShares != 0) {
            currentShares = (_amount.mul(totalShares)).div(pool);
        } else {
            currentShares = _amount;
        }
        UserInfo storage user = userInfo[msg.sender];

        user.shares = user.shares.add(currentShares);
        user.lastDepositedTime = block.timestamp;

        totalShares = totalShares.add(currentShares);

        user.babyAtLastUserAction = user.shares.mul(balanceOf()).div(
            totalShares
        );
        user.lastUserActionTime = block.timestamp;

        _earn();

        emit Deposit(msg.sender, _amount, currentShares, block.timestamp);
    }

    /**
     * @notice Withdraws all funds for a user
     */
    function withdrawAll() external notContract {
        withdraw(userInfo[msg.sender].shares);
    }

    /**
     * @notice Reinvests Baby tokens into MasterChef
     * @dev Only possible when contract not paused.
     */
    function harvest()
        external
        notContract
        whenNotPaused
        nonReentrant("harvest")
    {
        IMasterChef(masterchef).leaveStaking(0);

        uint256 bal = available();
        uint256 currentPerformanceFee = bal.mul(performanceFee).div(10000);
        token.safeTransfer(treasury, currentPerformanceFee);

        uint256 currentCallFee = bal.mul(callFee).div(10000);
        token.safeTransfer(msg.sender, currentCallFee);

        _earn();

        lastHarvestedTime = block.timestamp;

        emit Harvest(msg.sender, currentPerformanceFee, currentCallFee);
    }

    /**
     * @notice Sets admin address
     * @dev Only callable by the contract owner.
     */
    function setAdmin(address _admin) external onlyOwner {
        require(_admin != address(0), "Cannot be zero address");
        admin = _admin;
    }

    /**
     * @notice Sets treasury address
     * @dev Only callable by the contract owner.
     */
    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Cannot be zero address");
        treasury = _treasury;
    }

    /**
     * @notice Sets performance fee
     * @dev Only callable by the contract admin.
     */
    function setPerformanceFee(uint256 _performanceFee) external onlyAdmin {
        require(
            _performanceFee <= MAX_PERFORMANCE_FEE,
            "performanceFee cannot be more than MAX_PERFORMANCE_FEE"
        );
        performanceFee = _performanceFee;
    }

    /**
     * @notice Sets call fee
     * @dev Only callable by the contract admin.
     */
    function setCallFee(uint256 _callFee) external onlyAdmin {
        require(
            _callFee <= MAX_CALL_FEE,
            "callFee cannot be more than MAX_CALL_FEE"
        );
        callFee = _callFee;
    }

    /**
     * @notice Sets withdraw fee
     * @dev Only callable by the contract admin.
     */
    function setWithdrawFee(uint256 _withdrawFee) external onlyAdmin {
        require(
            _withdrawFee <= MAX_WITHDRAW_FEE,
            "withdrawFee cannot be more than MAX_WITHDRAW_FEE"
        );
        withdrawFee = _withdrawFee;
    }

    /**
     * @notice Sets withdraw fee period
     * @dev Only callable by the contract admin.
     */
    function setWithdrawFeePeriod(uint256 _withdrawFeePeriod)
        external
        onlyAdmin
    {
        require(
            _withdrawFeePeriod <= MAX_WITHDRAW_FEE_PERIOD,
            "withdrawFeePeriod cannot be more than MAX_WITHDRAW_FEE_PERIOD"
        );
        withdrawFeePeriod = _withdrawFeePeriod;
    }

    /**
     * @notice Withdraws from MasterChef to Vault without caring about rewards.
     * @dev EMERGENCY ONLY. Only callable by the contract admin.
     */
    function emergencyWithdraw() external onlyAdmin {
        IMasterChef(masterchef).emergencyWithdraw(0);
    }

    /**
     * @notice Withdraw unexpected tokens sent to the Baby Vault
     */
    function inCaseTokensGetStuck(address _token) external onlyAdmin {
        require(
            _token != address(token),
            "Token cannot be same as deposit token"
        );
        require(
            _token != address(receiptToken),
            "Token cannot be same as receipt token"
        );

        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }

    /**
     * @notice Triggers stopped state
     * @dev Only possible when contract not paused.
     */
    function pause() external onlyAdmin whenNotPaused {
        _pause();
        emit Pause();
    }

    /**
     * @notice Returns to normal state
     * @dev Only possible when contract is paused.
     */
    function unpause() external onlyAdmin whenPaused {
        _unpause();
        emit Unpause();
    }

    /**
     * @notice Calculates the expected harvest reward from third party
     * @return Expected reward to collect in Baby
     */
    function calculateHarvestBabyRewards() external view returns (uint256) {
        uint256 amount = IMasterChef(masterchef).pendingCake(0, address(this));
        amount = amount.add(available());
        uint256 currentCallFee = amount.mul(callFee).div(10000);

        return currentCallFee;
    }

    /**
     * @notice Calculates the total pending rewards that can be restaked
     * @return Returns total pending baby rewards
     */
    function calculateTotalPendingBabyRewards()
        external
        view
        returns (uint256)
    {
        uint256 amount = IMasterChef(masterchef).pendingCake(0, address(this));
        amount = amount.add(available());

        return amount;
    }

    /**
     * @notice Calculates the price per share
     */
    function getPricePerFullShare() external view returns (uint256) {
        return totalShares == 0 ? 1e18 : balanceOf().mul(1e18).div(totalShares);
    }

    /**
     * @notice Withdraws from funds from the Baby Vault
     * @param _shares: Number of shares to withdraw
     */
    function withdraw(uint256 _shares)
        public
        notContract
        nonReentrant("withdraw")
    {
        UserInfo storage user = userInfo[msg.sender];
        require(_shares > 0, "Nothing to withdraw");
        require(_shares <= user.shares, "Withdraw amount exceeds balance");

        uint256 currentAmount = (balanceOf().mul(_shares)).div(totalShares);
        user.shares = user.shares.sub(_shares);
        totalShares = totalShares.sub(_shares);

        uint256 bal = available();
        if (bal < currentAmount) {
            uint256 balWithdraw = currentAmount.sub(bal);
            IMasterChef(masterchef).leaveStaking(balWithdraw);
            uint256 balAfter = available();
            uint256 diff = balAfter.sub(bal);
            if (diff < balWithdraw) {
                currentAmount = bal.add(diff);
            }
        }

        if (block.timestamp < user.lastDepositedTime.add(withdrawFeePeriod)) {
            uint256 currentWithdrawFee = currentAmount.mul(withdrawFee).div(
                10000
            );
            token.safeTransfer(treasury, currentWithdrawFee);
            currentAmount = currentAmount.sub(currentWithdrawFee);
        }

        if (user.shares > 0) {
            user.babyAtLastUserAction = user.shares.mul(balanceOf()).div(
                totalShares
            );
        } else {
            user.babyAtLastUserAction = 0;
        }

        user.lastUserActionTime = block.timestamp;

        token.safeTransfer(msg.sender, currentAmount);

        emit Withdraw(msg.sender, currentAmount, _shares);
    }

    /**
     * @notice Custom logic for how much the vault allows to be borrowed
     * @dev The contract puts 100% of the tokens to work.
     */
    function available() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
     * @notice Calculates the total underlying tokens
     * @dev It includes tokens held by the contract and held in MasterChef
     */
    function balanceOf() public view returns (uint256) {
        (uint256 amount, ) = IMasterChef(masterchef).userInfo(0, address(this));
        return token.balanceOf(address(this)).add(amount);
    }

    /**
     * @notice Deposits tokens into MasterChef to earn staking rewards
     */
    function _earn() internal {
        uint256 bal = available();
        if (bal > 0) {
            IMasterChef(masterchef).enterStaking(bal);
        }
    }

    /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    mapping(string => bool) private _methodStatus;
    modifier nonReentrant(string memory methodName) {
        require(!_methodStatus[methodName], "reentrant call");
        _methodStatus[methodName] = true;
        _;
        _methodStatus[methodName] = false;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";

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
    constructor () internal {
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

// SPDX-License-Identifier: MIT

pragma solidity >0.6.6;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

contract BabyERC1155 is ERC1155, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    uint256 private _currentTokenID = 0;
    mapping(uint256 => uint256) public tokenSupply;
    mapping(uint256 => uint256) public tokenMaxSupply;
    mapping(uint256 => address) public creators;
    string public name;
    string public symbol;
    mapping(uint256 => string) private uris;
    string public baseMetadataURI;

    modifier onlyOwnerOrCreator(uint256 id) {
        require(msg.sender == owner() || msg.sender == creators[id], "only owner or creator can do this");
        _;
    }

    constructor(string memory _uri, string memory name_, string memory symbol_) ERC1155(_uri) {
        name = name_;
        symbol = symbol_;
        baseMetadataURI = _uri;
    }

    function setURI(string memory newuri) external {
        _setURI(newuri);
    }

    function uri(uint256 _id) public override view returns (string memory) {
        require(_exists(_id), "ERC1155#uri: NONEXISTENT_TOKEN");

        if(bytes(uris[_id]).length > 0){
            return uris[_id];
        }
        return string(abi.encodePacked(baseMetadataURI, _id.toString(), ".json"));
    }

    function _exists(uint256 _id) internal view returns (bool) {
        return creators[_id] != address(0);
    }

    function updateUri(uint256 _id, string calldata _uri) external onlyOwnerOrCreator(_id) {
        if (bytes(_uri).length > 0) {
            uris[_id] = _uri;
            emit URI(_uri, _id);
        }
        else{
            delete uris[_id];
            emit URI(string(abi.encodePacked(baseMetadataURI, _id.toString(), ".json")), _id);
        }
    }

    function createDefault(
        uint256 _maxSupply,
        uint256 _initialSupply
    ) external returns (uint256 tokenId) {
        require(_initialSupply <= _maxSupply, "Initial supply cannot be more than max supply");
        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();
        creators[_id] = msg.sender;

        emit URI(string(abi.encodePacked(baseMetadataURI, _id.toString(), ".json")), _id);

        if (_initialSupply != 0) _mint(msg.sender, _id, _initialSupply, "0x");
        tokenSupply[_id] = _initialSupply;
        tokenMaxSupply[_id] = _maxSupply;
        return _id;
    }

    function create(
        uint256 _maxSupply,
        uint256 _initialSupply,
        string calldata _uri,
        bytes calldata _data
    ) external returns (uint256 tokenId) {
        require(_initialSupply <= _maxSupply, "Initial supply cannot be more than max supply");
        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();
        creators[_id] = msg.sender;

        if (bytes(_uri).length > 0) {
            uris[_id] = _uri;
            emit URI(_uri, _id);
        }
        else{
            emit URI(string(abi.encodePacked(baseMetadataURI, _id.toString(), ".json")), _id);
        }

        if (_initialSupply != 0) _mint(msg.sender, _id, _initialSupply, _data);
        tokenSupply[_id] = _initialSupply;
        tokenMaxSupply[_id] = _maxSupply;
        return _id;
    }

    function _getNextTokenID() private view returns (uint256) {
        return _currentTokenID.add(1);
    }

    function _incrementTokenTypeId() private {
        _currentTokenID++;
    }
    
    function mint(address to, uint256 _id, uint256 _quantity, bytes memory _data) public onlyOwnerOrCreator(_id) {
        uint256 tokenId = _id;
        require(tokenSupply[tokenId].add(_quantity) <= tokenMaxSupply[tokenId], "Max supply reached");
        _mint(to, _id, _quantity, _data);
        tokenSupply[_id] = tokenSupply[_id].add(_quantity);
    }

    function multiSafeTransferFrom(address from, address[] memory tos, uint256 id, uint256[] memory amounts, bytes memory data) external {
        require(tos.length == amounts.length, "illegal num");
        for (uint i = 0; i < tos.length; i ++) {
            safeTransferFrom(from, tos[i], id, amounts[i], data);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >0.6.6;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

// CakeToken with Governance.
contract BabyERC721 is ERC721, Ownable {

    using Strings for uint256;

    constructor (string memory baseURI_, string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _setBaseURI(baseURI_); 
    }

    function mint(address to, uint256 tokenId) external onlyOwner {
        _mint(to, tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyOwner {
        _setTokenURI(tokenId, _tokenURI);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _setBaseURI(baseURI_);
    }

    function safeMint(address to, uint256 tokenId, bytes memory _data) external onlyOwner {
        _safeMint(to, tokenId, _data);
    }

    function multiMint(address[] memory tos, uint256[] memory tokenIds, bytes memory _data) external onlyOwner {
        if (false) {
            _data;
        }
        require(tos.length == tokenIds.length, "illegal length");
        for (uint i = 0; i < tos.length; i ++) {
            _mint(tos[i], tokenIds[i]);
        }
    }

    function multiSafeMint(address[] memory tos, uint256[] memory tokenIds, bytes memory _data) external onlyOwner {
        require(tos.length == tokenIds.length, "illegal length");
        for (uint i = 0; i < tos.length; i ++) {
            _safeMint(tos[i], tokenIds[i], _data);
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory uri = super.tokenURI(tokenId);
        return string(abi.encodePacked(uri, ".json"));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >0.6.6;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

// CakeToken with Governance.
contract MockERC721 is ERC721, Ownable {

    using Strings for uint256;

    constructor (string memory baseURI_, string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _setBaseURI(baseURI_); 
    }

    function mint(address to, uint256 tokenId) external onlyOwner {
        _mint(to, tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyOwner {
        _setTokenURI(tokenId, _tokenURI);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _setBaseURI(baseURI_);
    }

    function safeMint(address to, uint256 tokenId, bytes memory _data) external onlyOwner {
        _safeMint(to, tokenId, _data);
    }

    function multiMint(address[] memory tos, uint256[] memory tokenIds, bytes memory _data) external onlyOwner {
        if (false) {
            _data;
        }
        require(tos.length == tokenIds.length, "illegal length");
        for (uint i = 0; i < tos.length; i ++) {
            _mint(tos[i], tokenIds[i]);
        }
    }

    function multiSafeMint(address[] memory tos, uint256[] memory tokenIds, bytes memory _data) external onlyOwner {
        require(tos.length == tokenIds.length, "illegal length");
        for (uint i = 0; i < tos.length; i ++) {
            _safeMint(tos[i], tokenIds[i], _data);
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory uri = super.tokenURI(tokenId);
        return string(abi.encodePacked(uri, ".json"));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.4;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/access/Ownable.sol';

contract MockToken is ERC20, Ownable {
    constructor(string memory name_, string memory symbol_, uint8 decimals_) ERC20(name_, symbol_) {
        if (decimals_ != 18) {
            _setupDecimals(decimals_);
        }
    }

    function mint (address to_, uint amount_) public {
        _mint(to_, amount_);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BabyWonderland is ERC721("Baby Wonderland", "BLand"), Ownable {
    mapping(address => bool) public isMinter;

    event Mint(address account, uint256 tokenId);
    event NewMinter(address account);
    event DelMinter(address account);

    function addMinter(address _minter) external onlyOwner {
        require(
            _minter != address(0),
            "BabyWonderland: minter is zero address"
        );
        isMinter[_minter] = true;
        emit NewMinter(_minter);
    }

    function delMinter(address _minter) external onlyOwner {
        require(
            _minter != address(0),
            "BabyWonderland: minter is the zero address"
        );
        isMinter[_minter] = false;
        emit DelMinter(_minter);
    }

    function mint(address _recipient) public onlyMinter {
        require(
            _recipient != address(0),
            "BabyWonderland: recipient is zero address"
        );
        uint256 _tokenId = totalSupply() + 1;
        _mint(_recipient, _tokenId);
        emit Mint(_recipient, _tokenId);
    }

    function batchMint(address _recipient, uint256 _number)
        external
        onlyMinter
    {
        for (uint256 i = 0; i != _number; i++) {
            mint(_recipient);
        }
    }

    function batchTransferFrom(
        address from,
        address to,
        uint256[] memory tokenIds
    ) external {
        for (uint256 i = 0; i != tokenIds.length; ++i) {
            transferFrom(from, to, tokenIds[i]);
        }
    }

    function setBaseURI(string memory baseUri) external onlyOwner {
        _setBaseURI(baseUri);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        string memory uri = super.tokenURI(tokenId);
        return string(abi.encodePacked(uri, ".json"));
    }

    modifier onlyMinter() {
        require(
            isMinter[msg.sender],
            "BabyWonderland: caller is not the minter"
        );
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >0.6.6;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

// CakeToken with Governance.
contract MockNFT is ERC721 {


    constructor (string memory baseURI_, string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _setBaseURI(baseURI_); 
    }

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external {
        _setTokenURI(tokenId, _tokenURI);
    }

    function setBaseURI(string memory baseURI_) external {
        _setBaseURI(baseURI_);
    }

    function safeMint(address to, uint256 tokenId, bytes memory _data) external {
        _safeMint(to, tokenId, _data);
    }

    function multiMint(address[] memory tos, uint256[] memory tokenIds, bytes memory _data) external {
        if (false) {
            _data;
        }
        require(tos.length == tokenIds.length, "illegal length");
        for (uint i = 0; i < tos.length; i ++) {
            _mint(tos[i], tokenIds[i]);
        }
    }

    function multiSafeMint(address[] memory tos, uint256[] memory tokenIds, bytes memory _data) external {
        require(tos.length == tokenIds.length, "illegal length");
        for (uint i = 0; i < tos.length; i ++) {
            _safeMint(tos[i], tokenIds[i], _data);
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory uri = super.tokenURI(tokenId);
        return string(abi.encodePacked(uri, ".json"));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

import '@openzeppelin/contracts/access/Ownable.sol';

interface GameLevel {
    function sortedAttributes(uint256 _tokenId) external view returns (uint16[6] memory);
}
interface GameNFTProxy {
    function level(uint256 _tokenId) external view returns (uint16);
}

contract MockLevel is Ownable {

    GameLevel gameLevel;
    GameNFTProxy nftProxy;

    constructor(GameLevel _gameLevel, GameNFTProxy _nftProxy) {
        gameLevel = _gameLevel;
        nftProxy = _nftProxy;
    }

    function setGameLevel(GameLevel _gameLevel) external onlyOwner {
        gameLevel = _gameLevel;
    }

    function setNftProxy(GameNFTProxy _nftProxy) external onlyOwner {
        nftProxy = _nftProxy;
    }

    event UpgradeLevel(uint256 indexed tokenId, uint16 newLevel, uint16[6] attributes);

    function updateLevel(uint[] memory tokenId, uint16[] memory newLevel, uint16[] memory attributes) external onlyOwner {
        require(tokenId.length == newLevel.length, "illegal length");
        require(tokenId.length * 6 == attributes.length, "illegal attributes length");
        uint attributeIndex = 0;
        for (uint i = 0; i < tokenId.length; i ++) {
            uint16[6] memory currentAttributes = [attributes[attributeIndex + 0], attributes[attributeIndex + 1], attributes[attributeIndex + 2], attributes[attributeIndex + 3], attributes[attributeIndex + 4], attributes[attributeIndex + 5]];
            emit UpgradeLevel(tokenId[i], newLevel[i], currentAttributes);
            attributeIndex = attributeIndex + 6;
        }
    }

    function syncLevel(uint[] memory tokenIds) external onlyOwner {
        for (uint i = 0; i < tokenIds.length; i ++) {
            uint tokenId = tokenIds[i];
            uint16 level = nftProxy.level(tokenId);
            uint16[6] memory attributes = gameLevel.sortedAttributes(tokenId);
            emit UpgradeLevel(tokenId, level, attributes);
        }
    }

}