// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./GaugeVoting.sol";
import "@openzeppelin/contracts-0.8/token/ERC20/ERC20.sol";

/**
 * @title   GaugeVotingLens
 * @author  WombexFinance
 */
contract GaugeVotingLens {
    GaugeVoting public gaugeVoting;

    struct Pool {
        address lpToken;
        address rewards;
        uint256 vlVotes;
        int256 vlDelta;
        bool isActive;
        int256 veWomVotes;
        int256 veWomDelta;
        string name;
        string symbol;
    }

    struct UserReward {
        address lpToken;
        address rewards;
        address rewardToken;
        uint256 rewardAmount;
    }

    constructor(GaugeVoting _gaugeVoting) {
        gaugeVoting = _gaugeVoting;
    }

    function getPools() public view returns (Pool[] memory pools) {
        address[] memory lpTokens = gaugeVoting.getLpTokensAdded();
        (int256[] memory deltas, int256[] memory votes) = gaugeVoting.getVotesDelta();
        if (deltas.length == 0) {
            deltas = new int256[](lpTokens.length);
            votes = new int256[](lpTokens.length);
        }
        pools = new Pool[](lpTokens.length);
        for (uint256 i = 0; i < lpTokens.length; i++) {
            address rewards = gaugeVoting.lpTokenRewards(lpTokens[i]);
            uint256 vlVotes = IERC20(rewards).totalSupply();
            int256 ratio;
            int256 vlDelta;
            if (votes[i] != 0) {
                ratio = int256(vlVotes) * int256(1 ether) / votes[i];
                vlDelta = deltas[i] * ratio / int256(1 ether);
            }
            pools[i] = Pool(lpTokens[i], rewards, vlVotes, vlDelta, uint256(gaugeVoting.lpTokenStatus(lpTokens[i])) == 2, votes[i], deltas[i], ERC20(lpTokens[i]).name(), ERC20(lpTokens[i]).symbol());
        }
    }

    function getUserVotes(address _user) public view returns (uint256[] memory votes) {
        address[] memory lpTokens = gaugeVoting.getLpTokensAdded();
        votes = new uint256[](lpTokens.length);
        for(uint256 i = 0; i < lpTokens.length; i++) {
            votes[i] = IERC20(gaugeVoting.lpTokenRewards(lpTokens[i])).balanceOf(_user);
        }
    }

    function getUserRewards(address _user, uint256 _rewardsPerLpToken) public view returns (UserReward[] memory rewards) {
        address[] memory lpTokens = gaugeVoting.getLpTokensAdded();
        rewards = new UserReward[](lpTokens.length * _rewardsPerLpToken);
        uint256 rIndex = 0;

        for (uint256 j = 0; j < lpTokens.length; j++) {
            address rewardPool = gaugeVoting.lpTokenRewards(lpTokens[j]);
            uint256 rewardPoolBalance = IBribeRewardsPool(rewardPool).balanceOf(_user);

            address[] memory bribeRewardTokens = IBribeRewardsPool(rewardPool).rewardTokensList();
            for (uint256 i = 0; i < bribeRewardTokens.length; i++) {
                bool added = false;
                if (rewardPoolBalance == 0) {
                    for (uint256 k = 0; k < rIndex; k++) {
                        if (rewards[k].rewardToken == bribeRewardTokens[i]) {
                            added = true;
                            break;
                        }
                    }
                }
                if (added) {
                    continue;
                }
                rewards[rIndex] = UserReward(
                    lpTokens[j],
                    rewardPool,
                    bribeRewardTokens[i],
                    rewardPoolBalance == 0 ? 0 : IBribeRewardsPool(rewardPool).earned(bribeRewardTokens[i], _user)
                );
                rIndex++;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./Interfaces.sol";
import "@openzeppelin/contracts-0.8/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-0.8/utils/Address.sol";
import "@openzeppelin/contracts-0.8/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-0.8/access/Ownable.sol";
import "@openzeppelin/contracts-0.8/utils/Address.sol";
import { SafeERC20 } from "@openzeppelin/contracts-0.8/token/ERC20/utils/SafeERC20.sol";

/**
 * @title   GaugeVoting
 * @author  WombexFinance
 */
contract GaugeVoting is Ownable {
    using SafeERC20 for IERC20;

    uint256 public constant DENOMINATOR = 10000;

    IWmxLocker public wmxLocker;
    IBooster public booster;
    IBribeVoter public bribeVoter;
    address public voterProxy;
    IERC20 public veWom;

    ITokenFactory public tokenFactory;
    IBribesRewardFactory public bribeRewardsFactory;
    INftLocker public nftLocker;

    mapping(address => address) public lpTokenRewards;

    enum LpTokenStatus {
        NOT_EXISTS,
        ADDED,
        ACTIVE
    }
    mapping(address => LpTokenStatus) public lpTokenStatus;
    address[] public lpTokensAdded;

    ITokenMinter public stakingToken;
    uint256 public lastVoteAt;
    uint256 public votePeriod;
    uint256 public voteIncentive;
    uint256 public voteThreshold;
    bool public executeOnVote;

    event SetVotingConfig(uint256 votePeriod, uint256 voteThreshold, uint256 voteIncentive, bool executeOnVote);
    event SetNftLocker(address indexed nftLocker);
    event SetFactories(address indexed tokenFactory, address indexed rewardFactory);
    event AddLpToken(address indexed lpToken, address indexed rewards);
    event SetLpTokenStatus(address indexed lpToken, LpTokenStatus indexed status);
    event StakingTokenMigrate(address indexed newOperator);
    event RewardPoolMigrate(address indexed rewards, address indexed newOperator);
    event Vote(address[] lpTokens, int256[] deltas, uint256 availableVotes, uint256 votedAmount);
    event DistributeBribeRewards(address indexed lpToken, address indexed rewardsPool, address indexed bribe, address[] rewardTokens, uint256[] rewardAmounts);
    event ZeroRewards(address indexed lpToken, address indexed bribe, address indexed rewardToken);
    event TransferRewards(address indexed lpToken, address indexed rewardToken, address indexed recipient, uint256 rewardAmount, bool queueRewards);
    event VoteExecute(address[] lpTokens, int256[] deltas, int256[] votes);

    constructor(
        IWmxLocker _wmxLocker,
        IBooster _booster,
        IBribeVoter _bribeVoter
    ) {
        wmxLocker = _wmxLocker;
        booster = _booster;
        voterProxy = _booster.voterProxy();
        veWom = IERC20(IStaker(voterProxy).veWom());
        bribeVoter = _bribeVoter;
    }

    function setVotingConfig(uint256 _votePeriod, uint256 _voteThreshold, uint256 _voteIncentive, bool _executeOnVote) public onlyOwner {
        require(_voteIncentive <= 1000, "voteIncentive>1000");
        votePeriod = _votePeriod;
        voteThreshold = _voteThreshold;
        voteIncentive = _voteIncentive;
        executeOnVote = _executeOnVote;
        emit SetVotingConfig(_votePeriod, _voteThreshold, _voteIncentive, _executeOnVote);
    }

    function setNftLocker(INftLocker _nftLocker) public onlyOwner {
        nftLocker = _nftLocker;
        emit SetNftLocker(address(_nftLocker));
    }

    function setFactories(address _tokenFactory, address _rewardFactory, address _stakingToken) public onlyOwner {
        require(address(tokenFactory) == address(0), "!zero");
        tokenFactory = ITokenFactory(_tokenFactory);
        bribeRewardsFactory = IBribesRewardFactory(_rewardFactory);

        if (_stakingToken == address(0)) {
            stakingToken = ITokenMinter(tokenFactory.CreateBribesVotingToken());
        } else {
            stakingToken = ITokenMinter(_stakingToken);
        }

        emit SetFactories(_tokenFactory, _rewardFactory);
    }

    function approveRewards() external onlyOwner {
        uint256 lpLen = lpTokensAdded.length;
        for (uint256 i = 0; i < lpLen; i++) {
            if (lpTokenStatus[lpTokensAdded[i]] != LpTokenStatus.ACTIVE) {
                continue;
            }
            address rewardPool = lpTokenRewards[lpTokensAdded[i]];

            (, , , , , , address bribe) = bribeVoter.infos(lpTokensAdded[i]);
            address[] memory rewardTokens = IMasterWombatRewarder(bribe).rewardTokens();

            uint256 rtLen = rewardTokens.length;
            for (uint256 j = 0; j < rtLen; j++) {
                IERC20(rewardTokens[j]).approve(rewardPool, 0);
                IERC20(rewardTokens[j]).approve(rewardPool, type(uint256).max);
            }
        }
    }

    function updateBribeRewardsConfig(address[] calldata _rewards, bool _callOperatorOnGetReward) external onlyOwner {
        for(uint256 i = 0; i < _rewards.length; i++) {
            IBribeRewardsPool(_rewards[i]).updateBribesConfig(_callOperatorOnGetReward);
        }
    }

    function updateRatioConfig(address[] calldata _rewards, uint256 _duration, uint256 _newRewardRatio) external onlyOwner {
        require(_duration >= 60 && _duration <= 30 days, "!duration");
        require(_newRewardRatio > 0, "!maxRewardRatio");

        for(uint256 i = 0; i < _rewards.length; i++) {
            IBribeRewardsPool(_rewards[i]).updateRatioConfig(_duration, _newRewardRatio);
        }
    }

    function setRewardTokenPausedInPools(address[] memory _rewardPools, address _token, bool _paused) external onlyOwner {
        for (uint256 i = 0; i < _rewardPools.length; i++) {
            IRewards(_rewardPools[i]).setRewardTokenPaused(_token, _paused);
        }
    }

    function migrateStakingToken(address _newOperator) external onlyOwner {
        stakingToken.updateOperator(_newOperator);
        emit StakingTokenMigrate(_newOperator);
    }

    function migrateRewards(address[] calldata _rewards, address _newOperator) external onlyOwner {
        uint256 len = _rewards.length;

        for (uint256 i = 0; i < len; i++) {
            IRewards(_rewards[i]).updateOperatorData(_newOperator, 0);
            emit RewardPoolMigrate(_rewards[i], _newOperator);
        }
    }

    function registerLpTokens(address[] memory _lpTokens) external onlyOwner {
        uint256 len = _lpTokens.length;
        for (uint256 i = 0; i < len; i++) {
            _registerLpToken(_lpTokens[i]);
        }
    }

    function registerCreatedLpTokens(address[] memory _rewards) external onlyOwner {
        uint256 len = _rewards.length;
        for (uint256 i = 0; i < len; i++) {
            _registerCreatedLpToken(IBribeRewardsPool(_rewards[i]).asset(), _rewards[i]);
        }
    }

    function setLpTokenStatus(address _lpToken, LpTokenStatus _status) public onlyOwner {
        require(lpTokenStatus[_lpToken] != LpTokenStatus.NOT_EXISTS, "already exists");
        lpTokenStatus[_lpToken] = _status;
        emit SetLpTokenStatus(_lpToken, _status);
    }

    function _registerLpToken(address _lpToken) internal {
        _registerCreatedLpToken(_lpToken, bribeRewardsFactory.CreateBribesRewards(address(stakingToken), _lpToken, true));
    }

    function _registerCreatedLpToken(address _lpToken, address _rewards) internal {
        (, , , , , , address bribe) = bribeVoter.infos(_lpToken);
        require(bribe != address(0), "!bribe");

        require(lpTokenStatus[_lpToken] == LpTokenStatus.NOT_EXISTS, "already exists");
        lpTokenStatus[_lpToken] = LpTokenStatus.ACTIVE;

        lpTokensAdded.push(_lpToken);
        lpTokenRewards[_lpToken] = _rewards;

        stakingToken.approve(_rewards, 0);
        stakingToken.approve(_rewards, type(uint256).max);

        emit AddLpToken(_lpToken, _rewards);
    }

    function vote(address[] memory _lpTokens, int256[] memory _deltas) public {
        uint256 len = _lpTokens.length;
        require(len == _deltas.length, "!len");
        uint256 userLockerVotes = boostedUserVotes(msg.sender, true);
        require(userLockerVotes != 0, "no votes");

        int256 lastDelta = 0;

        for (uint256 i = 0; i < len; i++) {
            require(lpTokenStatus[_lpTokens[i]] == LpTokenStatus.ACTIVE, "only active");
            require(i == 0 || _deltas[i] >= lastDelta, "< lastDelta");
            lastDelta = _deltas[i];
            address rewards = lpTokenRewards[_lpTokens[i]];

            IBribeRewardsPool rewardsPool = IBribeRewardsPool(rewards);
            uint256 amount = _deltas[i] < 0 ? uint256(-_deltas[i]) : uint256(_deltas[i]);
            if (_deltas[i] < 0) {
                _rewardPoolWithdraw(rewardsPool, msg.sender, amount, msg.sender);
            } else if (_deltas[i] > 0) {
                _rewardPoolDeposit(rewardsPool, msg.sender, amount, msg.sender);
            }
        }

        uint256 userVoted = getUserVoted(msg.sender);
        require(userVoted <= userLockerVotes, "votes overflow");

        emit Vote(_lpTokens, _deltas, userLockerVotes, userVoted);

        if (executeOnVote && isVoteExecuteReady()) {
            voteExecute(msg.sender);
        }
    }

    function _rewardPoolWithdraw(IBribeRewardsPool _rewardsPool, address _user, uint256 _amount, address _claimFor) internal {
        _rewardsPool.withdrawAndUnwrapFrom(_user, _amount, _claimFor);
        stakingToken.burn(address(_rewardsPool), _amount);
    }

    function _rewardPoolDeposit(IBribeRewardsPool _rewardsPool, address _user, uint256 _amount, address _claimFor) internal {
        stakingToken.mint(address(this), _amount);
        _rewardsPool.stakeFor(_user, _amount);
    }

    function voteExecute(address _incentiveRecipient) public {
        require(isVoteExecuteReady(), "!ready");

        (int256[] memory deltas, int256[] memory votes) = getVotesDelta();
        if (deltas.length == 0) {
            return;
        }

        bytes memory rewardsData = booster.voteExecute(
            address(bribeVoter),
            0,
            abi.encodeWithSelector(IBribeVoter.vote.selector, lpTokensAdded, deltas)
        );

        uint256[][] memory bribeRewards = abi.decode(rewardsData, (uint256[][]));
        for (uint256 i = 0; i < deltas.length; i++) {
            address lpToken = lpTokensAdded[i];
            if (lpTokenStatus[lpToken] != LpTokenStatus.ACTIVE) {
                continue;
            }

            uint256[] memory rewards = bribeRewards[i];
            (, , , , , , address bribe) = bribeVoter.infos(lpToken);
            address[] memory rewardTokens = IMasterWombatRewarder(bribe).rewardTokens();

            uint256 tLen = rewardTokens.length;
            for (uint256 j = 0; j < tLen; j++) {
                uint256 amount = rewards[j];
                if (amount == 0) {
                    emit ZeroRewards(lpToken, bribe, rewardTokens[j]);
                    continue;
                }
                booster.voteExecute(
                    rewardTokens[j],
                    0,
                    abi.encodeWithSelector(IERC20.transfer.selector, address(this), amount)
                );
                uint256 incentiveAmount = amount * voteIncentive / DENOMINATOR;
                if (incentiveAmount > 0) {
                    IERC20(rewardTokens[j]).safeTransfer(_incentiveRecipient, incentiveAmount);
                    emit TransferRewards(lpToken, rewardTokens[j], _incentiveRecipient, incentiveAmount, false);
                }
                IBribeRewardsPool(lpTokenRewards[lpToken]).queueNewRewards(rewardTokens[j], amount - incentiveAmount);
                emit TransferRewards(lpToken, rewardTokens[j], lpTokenRewards[lpToken], amount - incentiveAmount, true);
            }
            emit DistributeBribeRewards(lpToken, lpTokenRewards[lpToken], bribe, rewardTokens, rewards);
        }

        lastVoteAt = block.timestamp;

        emit VoteExecute(lpTokensAdded, deltas, votes);
    }

    function getVotesDelta() public view returns (int256[] memory deltas, int256[] memory votes) {
        uint256 totalVotesAmount = totalVotes();
        if (totalVotesAmount == 0) {
            return (deltas, votes);
        }

        uint256 ratio = veWom.balanceOf(voterProxy) * 1 ether / totalVotesAmount;
        deltas = new int256[](lpTokensAdded.length);
        votes = new int256[](lpTokensAdded.length);
        for (uint256 i = 0; i < deltas.length; i++) {
            address lpToken = lpTokensAdded[i];
            address rewardsPool = lpTokenRewards[lpToken];
            int256 bribeVotes = int256(bribeVoter.votes(voterProxy, lpToken));
            votes[i] = int256(IERC20(rewardsPool).totalSupply() * ratio) / 1 ether;
            deltas[i] = votes[i] - bribeVotes;
        }
    }

    function rewardClaimed(uint256, address _account, uint256, bool) external {
        IBribeRewardsPool rewardsPool = IBribeRewardsPool(msg.sender);
        address asset = rewardsPool.asset();
        require(lpTokenRewards[asset] == msg.sender, "!lpTokenRewards");

        _onVotesChanged(_account, _account, _account);
        if (executeOnVote && isVoteExecuteReady()) {
            voteExecute(_account);
        }
    }

    function onVotesChanged(address _user, address _incentiveRecipient) public {
        address msgSender = msg.sender == address(nftLocker) ? _user : msg.sender;
        _onVotesChanged(_user, _incentiveRecipient, msgSender);
    }

    function _onVotesChanged(address _user, address _incentiveRecipient, address _msgSender) internal {
        if (boostedUserVotes(_user, _user == _msgSender) >= getUserVoted(_user)) {
            return;
        }

        uint256 len = lpTokensAdded.length;
        for (uint256 i = 0; i < len; i++) {
            IBribeRewardsPool rewardsPool = IBribeRewardsPool(lpTokenRewards[lpTokensAdded[i]]);
            _rewardPoolWithdraw(rewardsPool, _user, rewardsPool.balanceOf(_user), _incentiveRecipient);
        }
    }

    function getUserVoted(address _user) public view returns(uint256 voted) {
        uint256 len = lpTokensAdded.length;
        for (uint256 i = 0; i < len; i++) {
            if (lpTokenStatus[lpTokensAdded[i]] != LpTokenStatus.ACTIVE) {
                continue;
            }
            IBribeRewardsPool rewardsPool = IBribeRewardsPool(lpTokenRewards[lpTokensAdded[i]]);
            voted += rewardsPool.balanceOf(_user);
        }
    }

    function isVoteExecuteReady() public view returns(bool) {
        return stakingToken.totalSupply() >= voteThreshold && isPeriodReady();
    }

    function isPeriodReady() public view returns(bool) {
        return lastVoteAt + votePeriod < block.timestamp;
    }

    function totalVotes() public view returns (uint256) {
        return stakingToken.totalSupply();
    }

    function getLpTokensAdded() external view returns (address[] memory) {
        return lpTokensAdded;
    }

    function boostedUserVotes(address _user, bool _locked) public view returns (uint256 userLockerVotes) {
        (uint256 totalBalance, , uint256 lockedBalance, ) = wmxLocker.lockedBalances(_user);
        userLockerVotes = _locked ? lockedBalance : totalBalance;
        if (address(nftLocker) != address(0)) {
            userLockerVotes = userLockerVotes * nftLocker.voteBoost(_user) / 1 ether;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
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
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts-0.8/token/ERC20/IERC20.sol";

interface IWomDepositor {
    function deposit(uint256 _amount, address _stakeAddress) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

interface IAsset is IERC20 {
    function underlyingToken() external view returns (address);

    function pool() external view returns (address);

    function cash() external view returns (uint120);

    function liability() external view returns (uint120);

    function decimals() external view returns (uint8);

    function underlyingTokenDecimals() external view returns (uint8);

    function setPool(address pool_) external;

    function underlyingTokenBalance() external view returns (uint256);

    function transferUnderlyingToken(address to, uint256 amount) external;

    function mint(address to, uint256 amount) external;

    function burn(address to, uint256 amount) external;

    function addCash(uint256 amount) external;

    function removeCash(uint256 amount) external;

    function addLiability(uint256 amount) external;

    function removeLiability(uint256 amount) external;
}

interface IWmxLocker {
    function lock(address _account, uint256 _amount) external;

    function checkpointEpoch() external;

    function epochCount() external view returns (uint256);

    function balanceAtEpochOf(uint256 _epoch, address _user) external view returns (uint256 amount);

    function totalSupplyAtEpoch(uint256 _epoch) external view returns (uint256 supply);

    function queueNewRewards(address _rewardsToken, uint256 reward) external;

    function getReward(address _account, bool _stake) external;

    function getReward(address _account) external;

    function balanceOf(address _account) external view returns (uint256 amount);

    function balances(address _account) external view returns (uint112 locked, uint32 nextUnlockIndex);

    function getVotes(address account) external view returns (uint256);

    function getPastVotes(address account, uint256 timestamp) external view returns (uint256 votes);

    struct LockedBalance {
        uint112 amount;
        uint32 unlockTime;
    }

    function lockedBalances(address _user) external view returns (
        uint256 total,
        uint256 unlockable,
        uint256 locked,
        LockedBalance[] memory lockData
    );
}

interface IBribeVoter {
    function vote(IERC20[] calldata _lpVote, int256[] calldata _deltas) external returns (uint256[][] memory bribeRewards);
    function votes(address _user, address _lpToken) external view returns (uint256);
    function infos(address _lpToken) external view returns (uint104 supplyBaseIndex, uint104 supplyVoteIndex, uint40 nextEpochStartTime, uint128 claimable, bool whitelist, address gaugeManager, address bribe);
}

interface IMasterWombatRewarder {
    function rewardTokens() external view returns (address[] memory tokens);
}

interface IExtraRewardsDistributor {
    function addReward(address _token, uint256 _amount) external;
}

interface IWomDepositorWrapper {
    function getMinOut(uint256, uint256) external view returns (uint256);

    function deposit(
        uint256,
        uint256,
        bool,
        address _stakeAddress
    ) external;
}

interface ITokenFactory{
    function CreateDepositToken(address) external returns(address);
    function CreateBribesVotingToken() external returns(address);
}

interface IBribesRewardFactory {
    function CreateBribesRewards(address _stakingToken, address _lptoken, bool _callOperatorOnGetReward) external returns (address);
}

interface IRewards{
    function asset() external returns(address);
    function stake(address, uint256) external;
    function stakeFor(address, uint256) external;
    function withdraw(address, uint256) external;
    function withdraw(uint256 assets, address receiver, address owner) external;
    function exit(address) external;
    function getReward(address) external;
    function queueNewRewards(address, uint256) external;
    function notifyRewardAmount(uint256) external;
    function addExtraReward(address) external;
    function extraRewardsLength() external view returns (uint256);
    function stakingToken() external view returns (address);
    function rewardToken() external view returns(address);
    function earned(address _token, address _account) external view returns (uint256);
    function updateOperatorData(address operator_, uint256 pid_) external;
    function setRewardTokenPaused(address token_, bool paused_) external;
    function balanceOf(address _account) external view returns (uint256 amount);
    function rewardTokensList() external view returns (address[] memory);
}

interface IGauge {
    function notifyRewardAmount(IERC20 token, uint256 amount) external;
}

interface IBribe {
    function onVote(
        address user,
        uint256 newVote,
        uint256 originalTotalVotes
    ) external returns (uint256[] memory rewards);

    function pendingTokens(address _user) external view returns (uint256[] memory rewards);

    function rewardTokens() external view returns (IERC20[] memory tokens);

    function rewardLength() external view returns (uint256);
}

interface IVe {
    function vote(address user, int256 voteDelta) external;
}

interface INftLocker {
    function voteBoost(address _account) external view returns (uint256);
}

interface IBribeRewardsPool is IRewards {
    function withdrawAndUnwrapFrom(address _from, uint256 _amount, address _claimRecipient) external returns(bool);
    function updateBribesConfig(bool _callOperatorOnGetReward) external;
    function updateRatioConfig(uint256 _duration, uint256 _maxRewardRatio) external;
}

interface ITokenMinter is IERC20 {
    function mint(address,uint256) external;
    function burn(address,uint256) external;
    function setOperator(address) external;
    function updateOperator(address) external;
}

interface IStaker{
    function deposit(address, address) external returns (bool);
    function withdraw(address) external returns (uint256);
    function withdrawLp(address, address, uint256) external returns (bool);
    function withdrawAllLp(address, address) external returns (bool);
    function lock(uint256 _lockDays) external;
    function releaseLock(uint256 _slot) external returns(uint256);
    function getGaugeRewardTokens(address _lptoken, address _gauge) external returns (address[] memory tokens);
    function claimCrv(address, uint256) external returns (address[] memory tokens, uint256[] memory balances);
    function balanceOfPool(address, address) external view returns (uint256);
    function operator() external view returns (address);
    function depositor() external view returns (address);
    function veWom() external view returns (address);
    function execute(address _to, uint256 _value, bytes calldata _data) external returns (bool, bytes memory);
    function setVote(bytes32 hash, bool valid) external;
    function setDepositor(address _depositor) external;
    function setOwner(address _owner) external;
}

interface IPool {
    function deposit(
        address token,
        uint256 amount,
        uint256 minimumLiquidity,
        address to,
        uint256 deadline,
        bool shouldStake
    ) external returns (uint256);

    function withdraw(
        address token,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);

    function quotePotentialSwap(
        address fromToken,
        address toToken,
        int256 fromAmount
    ) external view returns (uint256 potentialOutcome, uint256 haircut);

    function quotePotentialDeposit(
        address token,
        uint256 amount
    ) external view returns (uint256 liquidity, uint256 reward);

    function quotePotentialWithdraw(
        address token,
        uint256 liquidity
    ) external view returns (uint256 amount, uint256 fee);

    function withdrawFromOtherAsset(
        address fromToken,
        address toToken,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);

    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 actualToAmount, uint256 haircut);

    function quoteAmountIn(
        address fromToken,
        address toToken,
        int256 toAmount
    ) external view returns (uint256 amountIn, uint256 haircut);

    function addressOfAsset(address token) external view returns (address);
}

interface IWombatRouter {
    function getAmountOut(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        int256 amountIn
    ) external view returns (uint256 amountOut, uint256[] memory haircuts);

    /**
     * @notice Returns the minimum input asset amount required to buy the given output asset amount
     * (accounting for fees and slippage)
     * Note: This function should be used as estimation only. The actual swap amount might
     * be different due to precision error (the error is typically under 1e-6)
     */
    function getAmountIn(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 amountOut
    ) external view returns (uint256 amountIn, uint256[] memory haircuts);

    function swapExactTokensForTokens(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function swapExactNativeForTokens(
        address[] calldata tokenPath, // the first address should be WBNB
        address[] calldata poolPath,
        uint256 minimumamountOut,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountOut);

    function swapExactTokensForNative(
        address[] calldata tokenPath, // the last address should be WBNB
        address[] calldata poolPath,
        uint256 amountIn,
        uint256 minimumamountOut,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function addLiquidityNative(
        IPool pool,
        uint256 minimumLiquidity,
        address to,
        uint256 deadline,
        bool shouldStake
    ) external payable returns (uint256 liquidity);

    function removeLiquidityNative(
        IPool pool,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);

    function removeLiquidityFromOtherAssetAsNative(
        IPool pool,
        address fromToken,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);
}

interface IBooster {
    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        bool shutdown;
    }

    function crv() external view returns (address);
    function owner() external view returns (address);
    function voterProxy() external view returns (address);
    function poolLength() external view returns (uint256);
    function poolInfo(uint256 _pid) external view returns (PoolInfo memory);
    function depositFor(uint256 _pid, uint256 _amount, bool _stake, address _receiver) external returns (bool);
    function setOwner(address _owner) external;
    function setPoolManager(address _poolManager) external;
    function voterProxyClaimRewards(uint256 _pid, address[] memory pendingTokens) external returns (uint256[] memory pendingRewards);
    function addPool(address _lptoken, address _gauge) external returns (uint256);
    function addCreatedPool(address _lptoken, address _gauge, address _token, address _crvRewards) external returns (uint256);
    function approveDistribution(address _distro, address[] memory _distributionTokens, uint256 _amount) external;
    function approvePoolsCrvRewardsDistribution(address _token) external;
    function distributeRewards(uint256 _pid, address _lpToken, address _rewardToken, address[] memory _transferTo, uint256[] memory _transferAmount, bool[] memory _callQueue) external;
    function lpPendingRewards(address _lptoken, address _token) external returns (uint256);
    function earmarkRewards(uint256 _pid) external;
    function shutdownPool(uint256 _pid) external returns (bool);
    function forceShutdownPool(uint256 _pid) external returns (bool);
    function gaugeMigrate(address _newGauge, uint256[] memory migratePids) external;
    function voteExecute(address _voting, uint256 _value, bytes calldata _data) external returns (bytes memory);
}

interface IBoosterEarmark {
    function earmarkIncentive() external view returns (uint256);
    function distributionByTokenLength(address _token) external view returns (uint256);
    function distributionByTokens(address, uint256) external view returns (address, uint256, bool);
    function distributionTokenList() external view returns (address[] memory);
    function addPool(address _lptoken, address _gauge) external returns (uint256);
    function addCreatedPool(address _lptoken, address _gauge, address _token, address _crvRewards) external returns (uint256);
}

interface ISwapRouter {
    function swapExactTokensForTokens(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 amountIn,
        uint256 minimumamountOut,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function getAmountOut(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        int256 amountIn
    ) external view returns (uint256 amountOut, uint256[] memory haircuts);
}

interface IWomSwapDepositor {
    function pool() external view returns (address);
    function deposit(uint256 _amount, address _stakeAddress, uint256 _minAmountOut, uint256 _deadline) external returns (bool);
}

/**
 * @dev Interface of the MasterWombatV2
 */
interface IMasterWombatV2 {
    function getAssetPid(address asset) external view returns (uint256 pid);

    function poolLength() external view returns (uint256);

    function pendingTokens(uint256 _pid, address _user)
    external
    view
    returns (
        uint256 pendingRewards,
        IERC20[] memory bonusTokenAddresses,
        string[] memory bonusTokenSymbols,
        uint256[] memory pendingBonusRewards
    );

    function rewarderBonusTokenInfo(uint256 _pid)
    external
    view
    returns (IERC20[] memory bonusTokenAddresses, string[] memory bonusTokenSymbols);

    function massUpdatePools() external;

    function updatePool(uint256 _pid) external;

    function deposit(uint256 _pid, uint256 _amount) external returns (uint256, uint256[] memory);

    function multiClaim(uint256[] memory _pids)
    external
    returns (
        uint256 transfered,
        uint256[] memory rewards,
        uint256[][] memory additionalRewards
    );

    function withdraw(uint256 _pid, uint256 _amount) external returns (uint256, uint256[] memory);

    function emergencyWithdraw(uint256 _pid) external;

    function migrate(uint256[] calldata _pids) external;

    function depositFor(
        uint256 _pid,
        uint256 _amount,
        address _user
    ) external;

    function updateFactor(address _user, uint256 _newVeWomBalance) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
        assembly {
            size := extcodesize(account)
        }
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}