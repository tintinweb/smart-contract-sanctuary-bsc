// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WeFund is Ownable {
    enum TokenType {
        USDC,
        USDT,
        BUSD
    }

    enum ProjectStatus {
        DocumentValuation,
        IntroCall,
        IncubationGoalSetup,
        IncubationGoal,
        MilestoneSetup,
        CrowdFundraising,
        MilestoneRelease,
        Completed
    }

    struct IncubationGoalInfo {
        string title;
        string description;
        string start_date;
        string end_date;
        uint256 approved_date;
    }

    struct BackerInfo {
        address addr;
        uint256 usdc_amount;
        uint256 usdt_amount;
        uint256 busd_amount;
        uint256 wfd_amount;
    }

    struct MilestoneInfo {
        uint256 step;
        string name;
        string description;
        string start_date;
        string end_date;
        uint256 amount;
    }

    struct Vote {
        address addr;
        bool vote;
    }

    struct ProjectInfo {
        uint256 id;
        address owner;
        uint256 collected;
        uint256 backed;
        ProjectStatus status;
        IncubationGoalInfo[] incubationGoals;
        uint256 incubationGoalVoteIndex;
        Vote[] wefundVotes;
        BackerInfo[] backers;
        MilestoneInfo[] milestones;
        Vote[] backerVotes;
        uint256 milestoneVotesIndex;
        bool rejected;
    }

    event CommunityAdded(uint256 length);
    event CommunityRemoved(uint256 length);
    event ProjectAdded(uint256 pid);
    event ProjectRemoved(uint256 pid);
    event DocumentValuationVoted(bool voted);
    event ProjectStatusChanged(ProjectStatus status);
    event IntroCallVoted(bool voted);
    event IncubationGoalSetupVoted(bool voted);
    event IncubationGoalAdded(uint256 length);
    event IncubationGoalRemoved(uint256 length, uint256 index);
    event IncubationGoalVoted(bool voted);
    event NextIncubationGoalVoting(uint256 index);
    event MilestoneAdded(uint256 length);
    event MilestoneRemoved(uint256 length, uint256 index);
    event MilestoneSetupVoted(bool voted);
    event NextMilestoneSetupVoting(uint256 index);
    event Backed(TokenType token, uint256 amount);
    event MilestoneReleaseVoted(bool voted);
    event NextMilestoneReleaseVoting(uint256 index);

    address USDC;
    address USDT;
    address BUSD;
    address WEFUND_WALLET;

    mapping(uint256 => ProjectInfo) private projects;
    uint256 private project_id;
    address[] private community;
    uint256 private wefund_id;

    constructor() {
        project_id = 1;
    }

    function setAddress(
        address _usdc,
        address _usdt,
        address _busd,
        address _wefund
    ) public onlyOwner {
        USDC = _usdc;
        USDT = _usdt;
        BUSD = _busd;
        WEFUND_WALLET = _wefund;
    }

    function setWefundID(uint256 _pid) public onlyOwner {
        wefund_id = _pid;
    }

    function addCommunity(address _addr) public onlyOwner {
        for (uint256 i = 0; i < community.length; i++) {
            if (community[i] == _addr) revert("Already Registered");
        }
        community.push(_addr);
        emit CommunityAdded(community.length);
    }

    function removeCommunity(address _addr) public onlyOwner {
        for (uint256 i = 0; i < community.length; i++)
            if (community[i] == _addr) {
                community[i] = community[community.length - 1];
                community.pop();
            }

        emit CommunityRemoved(community.length);
    }

    function addProjectByOwner(
        uint256 _collected,
        ProjectStatus _status,
        MilestoneInfo[] calldata _milestone
    ) public onlyOwner {
        ProjectInfo storage project = projects[project_id];
        project.id = project_id;
        project.owner = msg.sender;
        project.collected = _collected;
        project.status = _status;
        for (uint8 i = 0; i < _milestone.length; i++) project.milestones.push(_milestone[i]);
        project_id++;

        emit ProjectAdded(project_id);
    }

    function addProject(uint256 _collected) public {
        ProjectInfo storage project = projects[project_id];
        project.id = project_id;
        project.owner = msg.sender;
        project.collected = _collected;
        project_id++;

        emit ProjectAdded(project_id);
    }

    function removeProject(uint256 _pid) public onlyOwner {
        delete projects[_pid];

        emit ProjectRemoved(project_id);
    }

    function _getWefundWalletIndex(address _addr) internal view returns (uint8) {
        for (uint8 i = 0; i < community.length; i++) {
            if (community[i] == _addr) {
                return i;
            }
        }
        return type(uint8).max;
    }

    function _getWefundVoteIndex(uint256 pid, address _addr) internal view returns (uint8) {
        for (uint8 i = 0; i < projects[pid].wefundVotes.length; i++) {
            if (projects[pid].wefundVotes[i].addr == _addr) {
                return i;
            }
        }
        return type(uint8).max;
    }

    function _onlyWeFund() internal view {
        require(_getWefundWalletIndex(msg.sender) != type(uint8).max, "Only Wefund");
    }

    function _onlyProjectOwner(uint256 pid) internal view {
        require(projects[pid].owner == msg.sender, "Only Project Owner");
    }

    function _checkStatus(uint256 pid, ProjectStatus status) internal view {
        require(projects[pid].status == status, "Invalid Project Status");
    }

    function _wefundVote(uint256 pid, bool vote) internal {
        _onlyWeFund();

        ProjectInfo storage project = projects[pid];
        uint8 index = _getWefundVoteIndex(pid, msg.sender);
        if (index != type(uint8).max) project.wefundVotes[index].vote = vote;
        else project.wefundVotes.push(Vote({addr: msg.sender, vote: vote}));
    }

    function _isWefundAllVoted(uint256 pid) internal returns (bool) {
        ProjectInfo storage project = projects[pid];
        if (community.length <= project.wefundVotes.length) {
            for (uint8 i = 0; i < community.length; i++) {
                uint8 index = _getWefundVoteIndex(pid, community[i]);
                if (project.wefundVotes[index].vote == false) {
                    project.rejected = true;
                    return false;
                }
            }
            project.rejected = false;
            return true;
        }
        return false;
    }

    function documentValuationVote(uint256 pid, bool vote) public {
        _checkStatus(pid, ProjectStatus.DocumentValuation);
        _wefundVote(pid, vote);
        if (_isWefundAllVoted(pid) == true) {
            ProjectInfo storage project = projects[pid];
            delete project.wefundVotes;
            project.status = ProjectStatus.IntroCall;
            emit ProjectStatusChanged(ProjectStatus.IntroCall);
        }
        emit DocumentValuationVoted(vote);
    }

    function introCallVote(uint256 pid, bool vote) public {
        _checkStatus(pid, ProjectStatus.IntroCall);
        _wefundVote(pid, vote);
        if (_isWefundAllVoted(pid) == true) {
            ProjectInfo storage project = projects[pid];
            delete project.wefundVotes;
            project.status = ProjectStatus.IncubationGoalSetup;
            emit ProjectStatusChanged(ProjectStatus.IncubationGoalSetup);
        }
        emit IntroCallVoted(vote);
    }

    function incubationGoalSetupVote(uint256 pid, bool vote) public {
        _checkStatus(pid, ProjectStatus.IncubationGoalSetup);
        _wefundVote(pid, vote);
        if (_isWefundAllVoted(pid) == true) {
            ProjectInfo storage project = projects[pid];
            delete project.wefundVotes;
            project.status = ProjectStatus.IncubationGoal;
            emit ProjectStatusChanged(ProjectStatus.IncubationGoal);
        }
        emit IncubationGoalSetupVoted(vote);
    }

    function addIncubationGoal(uint256 pid, IncubationGoalInfo calldata _info) public {
        _onlyProjectOwner(pid);
        ProjectInfo storage project = projects[pid];
        project.incubationGoals.push(_info);
        emit IncubationGoalAdded(project.incubationGoals.length);
    }

    function removeIncubationGoal(uint256 pid, uint256 _index) public {
        _onlyProjectOwner(pid);
        ProjectInfo storage project = projects[pid];
        for (uint256 i = _index; i < project.incubationGoals.length - 1; i++) {
            project.incubationGoals[i] = project.incubationGoals[i + 1];
        }
        project.incubationGoals.pop();
        emit IncubationGoalRemoved(project.incubationGoals.length, _index);
    }

    function incubationGoalVote(uint256 pid, bool vote) public {
        _checkStatus(pid, ProjectStatus.IncubationGoal);
        _wefundVote(pid, vote);
        if (_isWefundAllVoted(pid) == true) {
            ProjectInfo storage project = projects[pid];
            delete project.wefundVotes;
            project.incubationGoals[project.incubationGoalVoteIndex].approved_date = block.timestamp;

            if (project.incubationGoalVoteIndex < project.incubationGoals.length - 1) {
                project.incubationGoalVoteIndex++;
                emit NextIncubationGoalVoting(project.incubationGoalVoteIndex);
            } else {
                project.status = ProjectStatus.MilestoneSetup;
                emit ProjectStatusChanged(ProjectStatus.MilestoneSetup);
            }
        }
        emit IncubationGoalVoted(vote);
    }

    function addMilestone(uint256 pid, MilestoneInfo calldata _info) public {
        _onlyProjectOwner(pid);
        ProjectInfo storage project = projects[pid];
        project.milestones.push(_info);
        emit MilestoneAdded(project.milestones.length);
    }

    function removeMilestone(uint256 pid, uint256 _index) public {
        _onlyProjectOwner(pid);
        ProjectInfo storage project = projects[pid];
        for (uint256 i = _index; i < project.milestones.length - 1; i++) {
            project.milestones[i] = project.milestones[i + 1];
        }
        project.milestones.pop();
        emit MilestoneRemoved(project.milestones.length, _index);
    }

    function milestoneSetupVote(uint256 pid, bool vote) public {
        _checkStatus(pid, ProjectStatus.MilestoneSetup);
        _wefundVote(pid, vote);
        if (_isWefundAllVoted(pid) == true) {
            ProjectInfo storage project = projects[pid];
            delete project.wefundVotes;
            if (project.milestoneVotesIndex < project.milestones.length - 1) {
                project.milestoneVotesIndex++;
                emit NextMilestoneSetupVoting(project.milestoneVotesIndex);
            } else {
                project.milestoneVotesIndex = 0;
                project.status = ProjectStatus.CrowdFundraising;
                emit ProjectStatusChanged(ProjectStatus.CrowdFundraising);
            }
        }
        emit MilestoneSetupVoted(vote);
    }

    function back(
        uint256 pid,
        TokenType token_type,
        uint256 amount,
        uint256 wfd_amount
    ) public {
        _checkStatus(pid, ProjectStatus.CrowdFundraising);

        address sender = msg.sender;

        ERC20 token;
        uint256 a_usdc = 0;
        uint256 a_usdt = 0;
        uint256 a_busd = 0;

        if (token_type == TokenType.USDC) {
            token = ERC20(USDC);
            a_usdc = amount / 10**token.decimals();
        } else if (token_type == TokenType.USDT) {
            token = ERC20(USDT);
            a_usdt = amount / 10**token.decimals();
        } else {
            token = ERC20(BUSD);
            a_busd = amount / 10**token.decimals();
        }
        token.transferFrom(sender, WEFUND_WALLET, amount);

        ProjectInfo storage project = projects[pid];
        project.backed += a_usdc + a_usdt + a_busd;

        bool b_exist = false;
        for (uint256 i = 0; i < project.backers.length; i++) {
            if (project.backers[i].addr == sender) {
                project.backers[i].usdc_amount += a_usdc;
                project.backers[i].usdt_amount += a_usdt;
                project.backers[i].busd_amount += a_busd;
                project.backers[i].wfd_amount += wfd_amount;
                b_exist = true;
                break;
            }
        }
        if (!b_exist) {
            project.backers.push(
                BackerInfo({
                    addr: sender,
                    usdc_amount: a_usdc,
                    usdt_amount: a_usdt,
                    busd_amount: a_busd,
                    wfd_amount: wfd_amount
                })
            );
        }
        if (project.backed >= project.collected) {
            project.status = ProjectStatus.MilestoneRelease;
            emit ProjectStatusChanged(ProjectStatus.MilestoneRelease);
        }

        emit Backed(token_type, amount);
    }

    function _getBackerIndex(uint256 pid, address _addr) public view returns (uint8) {
        ProjectInfo memory project = projects[pid];
        for (uint8 i = 0; i < project.backers.length; i++) {
            if (project.backers[i].addr == _addr) {
                return i;
            }
        }
        return type(uint8).max;
    }

    function _getBackerVoteIndex(uint256 pid, address _addr) internal view returns (uint8) {
        ProjectInfo memory project = projects[pid];
        for (uint8 i = 0; i < project.backerVotes.length; i++) {
            if (project.backerVotes[i].addr == _addr) {
                return i;
            }
        }
        return type(uint8).max;
    }

    modifier onlyBacker(uint256 pid) {
        require(_getBackerIndex(pid, msg.sender) != type(uint8).max, "Only Backer");
        _;
    }

    function _backerVote(uint256 pid, bool vote) internal {
        ProjectInfo storage project = projects[pid];
        uint8 index = _getBackerVoteIndex(pid, msg.sender);
        if (index != type(uint8).max) project.backerVotes[index].vote = vote;
        else project.backerVotes.push(Vote({addr: msg.sender, vote: vote}));
    }

    function _isBackerAllVoted(uint256 pid) internal returns (bool) {
        ProjectInfo storage project = projects[pid];
        if (project.backers.length <= project.backerVotes.length) {
            for (uint8 i = 0; i < project.backers.length; i++) {
                uint8 index = _getBackerVoteIndex(pid, project.backers[i].addr);
                if (project.backerVotes[index].vote == false) {
                    project.rejected = true;
                    return false;
                }
            }
            project.rejected = false;
            return true;
        }
        return false;
    }

    function milestoneReleaseVote(uint256 pid, bool vote) public onlyBacker(pid) {
        _checkStatus(pid, ProjectStatus.MilestoneRelease);
        _backerVote(pid, vote);
        if (_isBackerAllVoted(pid) == true) {
            ProjectInfo storage project = projects[pid];
            delete project.backerVotes;
            if (project.milestoneVotesIndex < project.milestones.length - 1) {
                ERC20 token;
                token = ERC20(USDC);

                token.transferFrom(
                    WEFUND_WALLET,
                    project.owner,
                    project.milestones[project.milestoneVotesIndex].amount * 10**token.decimals()
                );

                project.milestoneVotesIndex++;
                emit NextMilestoneReleaseVoting(project.milestoneVotesIndex);
            } else {
                project.status = ProjectStatus.Completed;
                emit ProjectStatusChanged(ProjectStatus.Completed);
            }
        }
        emit MilestoneReleaseVoted(vote);
    }

    function getCommunity() public view returns (address[] memory) {
        return community;
    }

    function getNumberOfProjects() public view returns (uint256) {
        return project_id - 1;
    }

    function getProjectInfo() public view returns (ProjectInfo[] memory) {
        ProjectInfo[] memory info = new ProjectInfo[](project_id - 1);
        for (uint256 i = 1; i < project_id; i++) {
            info[i - 1] = projects[i];
        }
        return info;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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