// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./lib/Ownable.sol";
import "./lib/Token/IERC20Mintable.sol";

/**
 *           release amount
 *
 *           │
 *           │
 *           │                                                  **************** total amount
 *           │                                          *********
 *           │                                  *********       │
 *           │                          *********       │       │
 * tgeAmount │***************************       │       │       │
 *           │                          │       │       │       │
 *           │                          │       │       │       │
 *           └──────────────────────────┼───────┼───────┼───────┼──────────────  time
 *           gs                        clf      └  bss  ┘       │
 *                                      │                       │
 *                                      └       duration        ┘
 *
 * gs: genesis timestamp 原点时间戳（可视为代币正式上线的时间点） 用于后续的时间间隔计算
 * clf: cliff 代币在第一次释放前的锁定间隔 例如项目方份额需锁定6个月
 * bss: basis 代币的释放周期 例如每30天释放一次代币
 *
 * @dev Implementation of the {ITokenVesting} interface.
 */
contract TokensVesting is Ownable {

    IERC20Mintable public immutable token; //该合约分发的代币
    uint256 private constant DEFAULT_BASIS = 30 days; //默认的代币释放周期

    uint256 public revokedAmount = 0;
    uint256 public revokedAmountWithdrawn = 0;

	//参与者 不一定全部都需要使用 未在里面体现的也可以添加 例如质押NFT挖矿 根据实际分配情况决定
    enum Participant {
        Unknown, //未知
        PrivateSale, //私募
        PublicSale, //公募
        Team, //项目方
        Advisor, //顾问
        EcosystemFund,
        Incentives, //激励（GameFi的游戏内挖矿）
        CommunityAndMarket,
        Reserve, //预留部分
        OutOfRange //超额部分
    }

    enum Status {
        Inactive,
        Active,
        Revoked
    }

	//代币分配信息 每一个实体代表一块被划分的代币
    struct VestingInfo {
        uint256 genesisTimestamp; //原点时间戳（可视为代币正式上线的时间点） 用于后续的时间间隔计算
        uint256 totalAmount; //总数量
        uint256 tgeAmount; //不锁仓的数量
        uint256 cliff; //锁仓部分的锁定期
        uint256 duration; //锁仓部分的释放期，从开始释放计算
        uint256 releasedAmount; //已经被释放的数量
        uint256 basis; //释放周期
        address beneficiary; //接收这块代币的地址（受益人）
        Participant participant; //参与者
        Status status; //代币状态（未开始释放 释放中 已作废）
    }

    VestingInfo[] private _beneficiaries;

    event BeneficiaryAdded(address indexed beneficiary, uint256 amount);
    event BeneficiaryActivated(uint256 index, address indexed beneficiary);
    event BeneficiaryRevoked(
        uint256 index,
        address indexed beneficiary,
        uint256 amount
    );
    event TokensReleased(address indexed beneficiary, uint256 amount);
    event Withdraw(address indexed receiver, uint256 amount);

    /**
     * @dev Sets the value for {token}.
     *
     * This value are immutable: it can only be set once during
     * construction.
     */
    constructor(address token_) {
        require(
            token_ != address(0),
            "TokensVesting::constructor: token_ is the zero address!"
        );

        token = IERC20Mintable(token_);
    }

    /**
     * @dev Get beneficiary by index_.
     */
    function getBeneficiary(uint256 index_) public view returns (VestingInfo memory) {
        return _beneficiaries[index_];
    }

    /**
     * @dev Get index by beneficiary
     */
    function getIndex(address beneficiary_) public view returns(uint256) {
        uint256 index = 0;
        for(uint256 i = 0; i < _beneficiaries.length; i++) {
            if(_beneficiaries[i].beneficiary == beneficiary_) {
                index = i;
                break;
            }
        }
        return index;
    }

    /**
     * @dev Get total beneficiaries amount
     */
    function getBeneficiaryCount() public view returns (uint256) {
        return _beneficiaries.length;
    }

    /**
     * @dev Get all beneficiaries
     */
    function getAllBeneficiaries() public view returns (VestingInfo[] memory) {
        return _beneficiaries;
    }

    /**
     * @dev Add beneficiary to vesting plan using default basis.
     * @param beneficiary_ recipient address.
     * @param genesisTimestamp_ genesis timestamp
     * @param totalAmount_ total amount of tokens will be vested.
     * @param tgeAmount_ an amount of tokens will be vested at tge.
     * @param cliff_ cliff duration.
     * @param duration_ linear vesting duration.
     * @param participant_ specific type of {Participant}.
     * Waring: Convert vesting monthly to duration carefully
     * eg: vesting in 9 months => duration = 8 months = 8 * 30 * 24 * 60 * 60
     */
    function addBeneficiary(
        address beneficiary_,
        uint256 genesisTimestamp_,
        uint256 totalAmount_,
        uint256 tgeAmount_,
        uint256 cliff_,
        uint256 duration_,
        Participant participant_
    ) public {
        addBeneficiaryWithBasis(
            beneficiary_,
            genesisTimestamp_,
            totalAmount_,
            tgeAmount_,
            cliff_,
            duration_,
            participant_,
            DEFAULT_BASIS
        );
    }

    /**
     * @dev Add beneficiary to vesting plan.
     * @param beneficiary_ recipient address.
     * @param genesisTimestamp_ genesis timestamp
     * @param totalAmount_ total amount of tokens will be vested.
     * @param tgeAmount_ an amount of tokens will be vested at tge.
     * @param cliff_ cliff duration.
     * @param duration_ linear vesting duration.
     * @param participant_ specific type of {Participant}.
     * @param basis_ basis duration for linear vesting.
     * Waring: Convert vesting monthly to duration carefully
     * eg: vesting in 9 months => duration = 8 months = 8 * 30 * 24 * 60 * 60
     */
    function addBeneficiaryWithBasis(
        address beneficiary_,
        uint256 genesisTimestamp_,
        uint256 totalAmount_,
        uint256 tgeAmount_,
        uint256 cliff_,
        uint256 duration_,
        Participant participant_,
        uint256 basis_
    ) public onlyOwner {
        require(
            genesisTimestamp_ >= block.timestamp,
            "TokensVesting::addBeneficiary: genesis too soon!"
        );
        require(
            beneficiary_ != address(0),
            "TokensVesting::addBeneficiary: beneficiary_ is the zero address!"
        );
        require(
            totalAmount_ >= tgeAmount_,
            "TokensVesting::addBeneficiary: totalAmount_ must be greater than or equal to tgeAmount_!"
        );
        require(
            genesisTimestamp_ + cliff_ + duration_ <= type(uint256).max,
            "TokensVesting::addBeneficiary: out of uint256 range!"
        );
        require(
            basis_ > 0,
            "TokensVesting::addBeneficiary: basis_ must be greater than 0!"
        );

        VestingInfo storage info = _beneficiaries.push();
        info.beneficiary = beneficiary_;
        info.genesisTimestamp = genesisTimestamp_;
        info.totalAmount = totalAmount_;
        info.tgeAmount = tgeAmount_;
        info.cliff = cliff_;
        info.duration = duration_;
        info.participant = participant_;
        info.status = Status.Inactive;
        info.basis = basis_;

        emit BeneficiaryAdded(beneficiary_, totalAmount_);
    }

    /**
     * @dev See {ITokensVesting-total}.
     */
    function total() public view returns (uint256) {
        return _getTotalAmount();
    }

    function totalAmountOf(Participant participant) public view returns(uint256) {
        return _getTotalAmountByParticipant(participant);
    }

    /**
     * @dev Activate specific beneficiary by index_.
     *
     * Only active beneficiaries can claim tokens.
     */
    function activate(uint256 index_) public onlyOwner {
        require(
            index_ >= 0 && index_ < _beneficiaries.length,
            "TokensVesting::activate: index_ out of range!"
        );

        _activate(index_);
    }

    /**
     * @dev Activate all of beneficiaries.
     *
     * Only active beneficiaries can claim tokens.
     */
    function activateAll() public onlyOwner {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            _activate(i);
        }
    }

    /**
     * @dev Revoke specific beneficiary by index_.
     *
     * Revoked beneficiaries cannot vest tokens anymore.
     */
    function revoke(uint256 index_) public onlyOwner {
        require(
            index_ >= 0 && index_ < _beneficiaries.length,
            "TokensVesting::revoke: index_ out of range!"
        );

        _revoke(index_);
    }

    /**
     * @dev See {ITokensVesting-releasable}.
     */
    function releasable() public view returns (uint256) {
        uint256 _releasable = 0;

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            VestingInfo storage info = _beneficiaries[i];
            _releasable =
                _releasable +
                _releasableAmount(
                    info.genesisTimestamp,
                    info.totalAmount,
                    info.tgeAmount,
                    info.cliff,
                    info.duration,
                    info.releasedAmount,
                    info.status,
                    info.basis
                );
        }

        return _releasable;
    }

    /**
     * @dev Returns the total releasable amount of tokens for the specific beneficiary by index.
     */
    function releasableOf(uint256 index_) public view returns (uint256) {
        require(
            index_ >= 0 && index_ < _beneficiaries.length,
            "TokensVesting::release: index_ out of range!"
        );

        VestingInfo storage info = _beneficiaries[index_];
        uint256 _releasable = _releasableAmount(
            info.genesisTimestamp,
            info.totalAmount,
            info.tgeAmount,
            info.cliff,
            info.duration,
            info.releasedAmount,
            info.status,
            info.basis
        );

        return _releasable;
    }

    /**
     * @dev See {ITokensVesting-releaseAll}.
     */
    function releaseAll() public onlyOwner {
        uint256 _releasable = releasable();
        require(
            _releasable > 0,
            "TokensVesting::releaseAll: no tokens are due!"
        );

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            _release(i);
        }
    }

    /**
     * @dev Release all releasable amount of tokens for the sepecific beneficiary by index.
     *
     * Emits a {TokensReleased} event.
     */
    function release(uint256 index_) public {
        require(
            index_ >= 0 && index_ < _beneficiaries.length,
            "TokensVesting::release: index_ out of range!"
        );

        VestingInfo storage info = _beneficiaries[index_];
        require(
            _msgSender() == owner() || _msgSender() == info.beneficiary,
            "TokensVesting::release: unauthorised sender!"
        );

        uint256 unreleased = _releasableAmount(
            info.genesisTimestamp,
            info.totalAmount,
            info.tgeAmount,
            info.cliff,
            info.duration,
            info.releasedAmount,
            info.status,
            info.basis
        );

        require(unreleased > 0, "TokensVesting::release: no tokens are due!");

        info.releasedAmount = info.releasedAmount + unreleased;
        token.mint(info.beneficiary, unreleased);
        emit TokensReleased(info.beneficiary, unreleased);
    }

    /**
     * @dev Withdraw revoked tokens out of contract.
     *
     * Withdraw amount of tokens upto revoked amount.
     */
    function withdraw(uint256 amount_) public onlyOwner {
        require(amount_ > 0, "TokensVesting::withdraw: Bad params!");
        require(
            amount_ <= revokedAmount - revokedAmountWithdrawn,
            "TokensVesting::withdraw: Amount exceeded revoked amount withdrawable!"
        );

        revokedAmountWithdrawn = revokedAmountWithdrawn + amount_;
        token.mint(_msgSender(), amount_);
        emit Withdraw(_msgSender(), amount_);
    }

    /**
     * @dev Release all releasable amount of tokens for the sepecific beneficiary by index.
     *
     * Emits a {TokensReleased} event.
     */
    function _release(uint256 index_) private {
        VestingInfo storage info = _beneficiaries[index_];
        uint256 unreleased = _releasableAmount(
            info.genesisTimestamp,
            info.totalAmount,
            info.tgeAmount,
            info.cliff,
            info.duration,
            info.releasedAmount,
            info.status,
            info.basis
        );

        if (unreleased > 0) {
            info.releasedAmount = info.releasedAmount + unreleased;
            token.mint(info.beneficiary, unreleased);
            emit TokensReleased(info.beneficiary, unreleased);
        }
    }

    function _getTotalAmount() private view returns (uint256) {
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            totalAmount = totalAmount + _beneficiaries[i].totalAmount;
        }
        return totalAmount;
    }

    function _getTotalAmountByParticipant(Participant participant_)
        private
        view
        returns (uint256)
    {
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            if (_beneficiaries[i].participant == participant_) {
                totalAmount = totalAmount + _beneficiaries[i].totalAmount;
            }
        }
        return totalAmount;
    }

    function _getReleasedAmount() private view returns (uint256) {
        uint256 releasedAmount = 0;
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            releasedAmount = releasedAmount + _beneficiaries[i].releasedAmount;
        }
        return releasedAmount;
    }

    function _getReleasedAmountByParticipant(Participant participant_)
        private
        view
        returns (uint256)
    {
        require(
            Participant(participant_) > Participant.Unknown &&
                Participant(participant_) < Participant.OutOfRange,
            "TokensVesting::_getReleasedAmountByParticipant: participant_ out of range!"
        );

        uint256 releasedAmount = 0;
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            if (_beneficiaries[i].participant == participant_)
                releasedAmount =
                    releasedAmount +
                    _beneficiaries[i].releasedAmount;
        }
        return releasedAmount;
    }

    function _releasableAmount(
        uint256 genesisTimestamp_,
        uint256 totalAmount_,
        uint256 tgeAmount_,
        uint256 cliff_,
        uint256 duration_,
        uint256 releasedAmount_,
        Status status_,
        uint256 basis_
    ) private view returns (uint256) {
        if (status_ == Status.Inactive) {
            return 0;
        }

        if (status_ == Status.Revoked) {
            return totalAmount_ - releasedAmount_;
        }

        return
            _vestedAmount(genesisTimestamp_, totalAmount_, tgeAmount_, cliff_, duration_, basis_) -
            releasedAmount_;
    }

    function _vestedAmount(
        uint256 genesisTimestamp_,
        uint256 totalAmount_,
        uint256 tgeAmount_,
        uint256 cliff_,
        uint256 duration_,
        uint256 basis_
    ) private view returns (uint256) {
        require(
            totalAmount_ >= tgeAmount_,
            "TokensVesting::_vestedAmount: Bad params!"
        );

        if (block.timestamp < genesisTimestamp_) {
            return 0;
        }

        uint256 timeLeftAfterStart = block.timestamp - genesisTimestamp_;

        if (timeLeftAfterStart < cliff_) {
            return tgeAmount_;
        }

        uint256 linearVestingAmount = totalAmount_ - tgeAmount_;
        if (timeLeftAfterStart >= cliff_ + duration_) {
            return linearVestingAmount + tgeAmount_;
        }

        uint256 releaseMilestones = (timeLeftAfterStart - cliff_) / basis_ + 1;
        uint256 totalReleaseMilestones = (duration_ + basis_ - 1) / basis_ + 1;
        return
            (linearVestingAmount / totalReleaseMilestones) *
            releaseMilestones +
            tgeAmount_;
    }

    function _activate(uint256 index_) private {
        VestingInfo storage info = _beneficiaries[index_];
        if (info.status == Status.Inactive) {
            info.status = Status.Active;
            emit BeneficiaryActivated(index_, info.beneficiary);
        }
    }

    function _activateParticipant(Participant participant_) private {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            VestingInfo storage info = _beneficiaries[i];
            if (info.participant == participant_) {
                _activate(i);
            }
        }
    }

    function _revoke(uint256 index_) private {
        VestingInfo storage info = _beneficiaries[index_];
        if (info.status == Status.Revoked) {
            return;
        }

        uint256 _releasable = _releasableAmount(
            info.genesisTimestamp,
            info.totalAmount,
            info.tgeAmount,
            info.cliff,
            info.duration,
            info.releasedAmount,
            info.status,
            info.basis
        );

        uint256 oldTotalAmount = info.totalAmount;
        info.totalAmount = info.releasedAmount + _releasable;

        uint256 revokingAmount = oldTotalAmount - info.totalAmount;
        if (revokingAmount > 0) {
            info.status = Status.Revoked;
            revokedAmount = revokedAmount + revokingAmount;
            emit BeneficiaryRevoked(index_, info.beneficiary, revokingAmount);
        }
    }

    function _getReleasableByParticipant(Participant participant_)
        private
        view
        returns (uint256)
    {
        uint256 _releasable = 0;

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            VestingInfo storage info = _beneficiaries[i];
            if (info.participant == participant_) {
                _releasable =
                    _releasable +
                    _releasableAmount(
                        info.genesisTimestamp,
                        info.totalAmount,
                        info.tgeAmount,
                        info.cliff,
                        info.duration,
                        info.releasedAmount,
                        info.status,
                        info.basis
                    );
            }
        }

        return _releasable;
    }

    function _releaseParticipant(Participant participant_) private {
        uint256 _releasable = _getReleasableByParticipant(participant_);
        require(
            _releasable > 0,
            "TokensVesting::_releaseParticipant: no tokens are due!"
        );

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            if (_beneficiaries[i].participant == participant_) {
                _release(i);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "./IERC20.sol";

interface IERC20Mintable {
    function mint(address to, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

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
pragma solidity 0.8.8;

import "./Context.sol";
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
    address private _potentialOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnerNominated(address potentialOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
     * @dev Returns the address of the current potentialOwner.
     */
    function potentialOwner() public view returns (address) {
        return _potentialOwner;
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function nominatePotentialOwner(address newOwner) public virtual onlyOwner {
        _potentialOwner = newOwner;
        emit OwnerNominated(newOwner);
    }

    function acceptOwnership () public virtual {
        require(msg.sender == _potentialOwner, 'You must be nominated as potential owner before you can accept ownership');
        emit OwnershipTransferred(_owner, _potentialOwner);
        _owner = _potentialOwner;
        _potentialOwner = address(0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}