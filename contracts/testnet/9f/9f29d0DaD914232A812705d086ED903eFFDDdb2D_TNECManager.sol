// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./ERC20.sol";
import "./TNEC.sol";
import "./Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TNECManager is Pausable, ReentrancyGuard {
    using SafeMath for uint256;

    struct ActionType {
        bool created;
        uint256 type_;
        uint256 numberOfSignatures;
    }

    // This is a type for a single proposal.
    struct Proposal {
        uint256 id_; // identifier of the proposal
        uint256 voteCount; // number of accumulated votes
        bool executed; // proposal executed
        address[] voted; // stores a voters that already voted
        ActionType action;
    }

    // A dynamically-sized array of `Proposal` structs.
    Proposal[] private proposals;

    // A dynamically-sized array of `ActionType` structs.
    ActionType[] public actionTypes;

    mapping(uint256 => mapping(address => bool)) allowed;
    mapping(address => uint256) private _voted;
    mapping(address => bool) private _owners;

    Token public token;

    // addresses
    address payable public _presaleWalletAddress; // Wallet presale : Distribution
    address payable public _prelaunchWalletAddress; // Wallet pre-launch : Distribution
    address payable public _reserveWalletAddress; // Wallet trésorie : Paiement
    address payable public _algoWalletAddress; // Wallet algo (for market maker)
    address payable public _DCAWalletAddress; // Wallet DCA : rewards
    address payable public _BBDDWalletAddress; // Wallet BBDD

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event AdminAdded(address newAdmin);
    event VesterAdded(address vester, string vestingType, uint256 amount);
    event ActionTypeAdded(
        uint256 index,
        uint256 numberOfSignatures,
        address[] allowed
    );
    event UpdatedActionType(
        uint256 index,
        uint256 numberOfSignatures,
        address[] allowed
    );
    event ActionTypeRemoved(uint256 index);
    event ProposalAdded(uint256 index, uint256 proposalId);

    ///@dev Throws if called by any account other than the owner.
    modifier onlyOwner() {
        require(_owners[msg.sender], "TNECManager: caller is not owner");
        _;
    }

    ///@dev Verifies that the voter is allowed and hasn't voted yet
    ///@param _id - identifier of the proposal on which the vote is going
    modifier canVoteOnProposal(uint256 _id) {
        require(proposals.length > 0, "TNECManager : Propasal not exist");
        require(
            !proposals[_id].executed,
            "TNECManager : Propasal already executed"
        );
        ActionType storage _action = proposals[_id].action;
        require(
            allowed[_id][msg.sender],
            "TNECManager: Not allowed for the voting to this action type"
        );
        require(!_fetchInTab(_id, msg.sender), "TNECManager: already voted");
        _;
    }

    ///@dev Verifies that the vote is over
    ///@param _id - identifier of the proposal on which the vote is going
    modifier canRemoveProposal(uint256 _id) {
        ActionType storage _action = proposals[_id].action;
        require(
            allowed[_id][msg.sender],
            "TNECManager: Not allowed for the voting to this action type"
        );
        require(
            proposals[_id].executed,
            "TNECManager: too early to remove this proposal"
        );
        _;
    }

    ///@dev Verifies that an action can be executed
    ///@param _index - Type of action (0 : distribution, 1 : paiement, 2 : marketMaker, 3 : DCA, 4 : BBDD)
    ///@param _id - identifier of the proposal on which the vote is going
    modifier canExecuteAction(uint256 _index, uint256 _id) {
        ActionType storage _action = actionTypes[_index];
        require(
            allowed[_id][msg.sender],
            "TNECManager: Not allowed for the voting to this action type"
        );
        require(!proposals[_id].executed, "TNECManager: already executed");
        require(
            proposals[_id].voteCount >= _action.numberOfSignatures,
            "TNECManager: too early to execute this proposal"
        );
        _;
    }

    ///@notice canTransfer, modifier which verify if the from is autorised to do the transfer
    ///@param _index - Type of action (0 : distribution, 1 : paiement, 2 : marketMaker, 3 : DCA, 4 : BBDD)
    ///@param _from - the wallet that will transfer tokens
    modifier canTransfer(uint256 _index, address _from) {
        ActionType storage _action = actionTypes[_index];
        if (_index == 0 && _action.created)
            require(
                _from == _presaleWalletAddress ||
                    _from == _prelaunchWalletAddress,
                "TNECManager: From not allowed to transfer tokens"
            );
        else if (_index == 1 && _action.created)
            require(
                _from == _reserveWalletAddress,
                "TNECManager: From not allowed to transfer tokens"
            );
        else if (_index == 2 && _action.created)
            require(
                _from == _algoWalletAddress,
                "TNECManager: From not allowed to transfer tokens"
            );
        else if (_index == 3 && _action.created)
            require(
                _from == _DCAWalletAddress,
                "TNECManager: From not allowed to transfer tokens"
            );
        else if (_index == 4 && _action.created)
            require(
                _from == _BBDDWalletAddress,
                "TNECManager: From not allowed to transfer tokens"
            );
        _;
    }

    ///@notice isActionType, modifier which verify that a actionType exists
    ///@param _index - Type of action (0 : distribution, 1 : paiement, 2 : marketMaker, 3 : DCA, 4 : BBDD)
    modifier isActionType(uint256 _index) {
        require(
            actionTypes.length > _index,
            "TNECManager: Type not initialized yet"
        );
        require(actionTypes[_index].created, "TNECManager: Type not exist");
        _;
    }

    ///@notice constructor, to initialize the smart contract 
    ///@param token_, token which will be used 
    ///@param wallets_, different wallets for different actions 
    constructor(Token token_, address[] memory wallets_) {
        token = token_;

        _presaleWalletAddress = payable(wallets_[0]);
        _prelaunchWalletAddress = payable(wallets_[1]);
        _reserveWalletAddress = payable(wallets_[2]);
        _algoWalletAddress = payable(wallets_[3]);
        _DCAWalletAddress = payable(wallets_[4]);
        _BBDDWalletAddress = payable(wallets_[5]);

        _setOwner(address(0), msg.sender);
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        _owners[msg.sender] = false;
        _setOwner(msg.sender, address(0));
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner(address _owner) public view returns (bool) {
        return _owners[_owner];
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(msg.sender, _newOwner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function addNewOwner(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(address(0), _newOwner);
    }

    function _setOwner(address _oldOwner, address _newOwner) private {
        _owners[_oldOwner] = false;
        _owners[_newOwner] = true;
        emit OwnershipTransferred(_oldOwner, _newOwner);
    }

    ///@notice setWallet, modify wallets - can be called only by owner
    ///@param _newWallet, new wallet
    ///@param _index, Type of action (0 : distribution, 1 : paiement, 2 : marketMaker, 3 : DCA, 4 : BBDD)
    function setWallet(address _newWallet, uint256 _index) external onlyOwner {
        if (_index == 0) _presaleWalletAddress = payable(_newWallet);
        else if (_index == 1) _prelaunchWalletAddress = payable(_newWallet);
        else if (_index == 2) _reserveWalletAddress = payable(_newWallet);
        else if (_index == 3) _algoWalletAddress = payable(_newWallet);
        else if (_index == 4) _DCAWalletAddress = payable(_newWallet);
        else if (_index == 5) _BBDDWalletAddress = payable(_newWallet);
    }

    ///@notice addActionType, Add a action type
    ///@param _index - Type of action (0 : distribution, 1 : paiement, 2 : marketMaker, 3 : DCA, 4 : BBDD)
    ///@param _numberOfSignatures - number of signatures required
    ///@param _allowed - allowed addresses to vote on this type of action
    function addActionType(
        uint256 _index,
        uint256 _numberOfSignatures,
        address[] calldata _allowed
    ) external onlyOwner whenNotPaused {
        ActionType memory _action;

        _action.created = true;
        _action.type_ = _index;
        _action.numberOfSignatures = _numberOfSignatures;

        for (uint256 i = 0; i < _allowed.length; i++) {
            require(
                _allowed[i] != address(0),
                "TNECManager: address 0 not allowed"
            );
            allowed[_index][_allowed[i]] = true;
        }
        actionTypes.push(_action);

        emit ActionTypeAdded(_index, _numberOfSignatures, _allowed);
    }

    ///@notice allowance, verify if your are allowed to do an action or not
    ///@param _index - Type of action (0 : distribution, 1 : paiement, 2 : marketMaker, 3 : DCA, 4 : BBDD)
    ///@param _allowed - address to check 
    ///@return true or false (allowed or not)
    function allowance(uint256 _index, address _allowed)
        public
        view
        returns (bool)
    {
        return allowed[_index][_allowed];
    }

    ///@notice updateActionType, update action type only called by owner
    ///@param _index - Type of action (0 : distribution, 1 : paiement, 2 : marketMaker, 3 : DCA, 4 : BBDD)
    ///@param _numberOfSignatures - number of signatures required
    ///@param _allowed - allowed addresses to vote on this type of action
    function updateActionType(
        uint256 _index,
        uint256 _numberOfSignatures,
        address[] memory _allowed
    ) external onlyOwner isActionType(_index) whenNotPaused {
        ActionType memory _action;

        _action.created = true;
        _action.type_ = _index;
        _action.numberOfSignatures = _numberOfSignatures;

        for (uint256 i = 0; i < _allowed.length; i++) {
            require(
                _allowed[i] != address(0),
                "TNECManager: address 0 not allowed"
            );
            allowed[_index][_allowed[i]] = true;
        }
        actionTypes[_index] = _action;

        emit UpdatedActionType(_index, _numberOfSignatures, _allowed);
    }

    ///@notice removeActionype, remove a action type only called by owner
    ///@param _index - Type of action (0 : distribution, 1 : paiement, 2 : marketMaker, 3 : DCA, 4 : BBDD)
    function removeActionype(uint256 _index)
        external
        onlyOwner
        isActionType(_index)
        whenNotPaused
    {
        delete actionTypes[_index];
        emit ActionTypeRemoved(_index);
    }

    ///@notice addProposal, add a proposal for an actionType - only called by owner
    ///@param _index - Type of action (0 : distribution, 1 : paiement, 2 : marketMaker, 3 : DCA, 4 : BBDD)
    ///@return index of the proposal
    function addProposal(uint256 _index)
        external
        isActionType(_index)
        onlyOwner
        whenNotPaused
        returns (uint256)
    {
        uint256 _id;

        if (proposals.length > 0) {
            _id = proposals.length;
        } else {
            _id = 0;
        }

        Proposal memory _proposal;

        _proposal.id_ = _id;
        _proposal.voteCount = 0;
        _proposal.action = actionTypes[_index];

        proposals.push(_proposal);

        emit ProposalAdded(_index, _id);

        return _id;
    }

    ///@notice removeProposal, remove a proposal
    ///@param _proposalId, proposal identifier
    function removeProposal(uint256 _proposalId)
        external
        canRemoveProposal(_proposalId)
    {
        delete proposals[_proposalId];
    }

    ///@notice get a proposal
    ///@param _proposalId, proposal identifier
    ///@return a proposal
    function getProposal(uint256 _proposalId)
        public
        view
        returns (Proposal memory)
    {
        return proposals[_proposalId];
    }

    ///@notice _fetchInTab, fetch if a voter already voted
    ///@param _proposalId, proposal identifier
    ///@param _voter, voter address
    ///@return true or false (voted or not)
    function _fetchInTab(uint256 _proposalId, address _voter)
        internal
        view
        returns (bool)
    {
        if (proposals[_proposalId].voted.length == 0) return false;
        else {
            for (uint256 i = 0; i < proposals[_proposalId].voted.length; i++) {
                if (proposals[_proposalId].voted[i] == _voter) return true;
            }
            return false;
        }
    }

    ///@notice removeProposalByOwner, remove a proposal only by owner
    ///@param _proposalId, proposal identifier
    function removeProposalByOwner(uint256 _proposalId) external onlyOwner {
        delete proposals[_proposalId];
    }

    ///@notice vote, vote on a proposal
    ///@param _proposalId, proposal identifier
    function vote(uint256 _proposalId)
        external
        canVoteOnProposal(_proposalId)
        whenNotPaused
    {
        Proposal storage _proposal = proposals[_proposalId];
        _proposal.voteCount++;
        _proposal.voted.push(msg.sender);
        _voted[msg.sender] = _proposal.voted.length.sub(1);
    }

    ///@notice distributeTokens, distribute Tokens for presale, pre-launch ...
    ///@param _from, wallet from which transfer will be done
    ///@param _holders, list of all recipients
    ///@param _values, list of different amounts to be send
    ///@param _actionType - Type of action (0 : distribution, 1 : paiement, 2 : marketMaker, 3 : DCA, 4 : BBDD)
    ///@param _proposalId, proposal identifier
    function distributeTokens(
        address _from,
        address[] calldata _holders,
        uint256[] calldata _values,
        uint256 _actionType,
        uint256 _proposalId
    )
        external
        canExecuteAction(_actionType, _proposalId)
        canTransfer(_actionType, _from)
        nonReentrant
        whenNotPaused
    {
        require(
            _holders.length == _values.length,
            "TNECManager: need to have same length"
        );
        for (uint256 i = 0; i < _holders.length; i++) {
            token.transferFrom(_from, _holders[i], _values[i]);
        }

        proposals[_proposalId].executed = true;
    }

    ///@notice payWithTokens, pay with tokens (marketing, collab, partners ...) - multiple transfer
    ///@param _from, wallet from which transfer will be done
    ///@param _beneficiaries, list of all recipients
    ///@param _values, list of different amounts to be send
    ///@param _actionType - Type of action (0 : distribution, 1 : paiement, 2 : marketMaker, 3 : DCA, 4 : BBDD)
    ///@param _proposalId, proposal identifier
    function payWithTokens(
        address _from,
        address[] calldata _beneficiaries,
        uint256[] calldata _values,
        uint256 _actionType,
        uint256 _proposalId
    )
        external
        canExecuteAction(_actionType, _proposalId)
        canTransfer(_actionType, _from)
        nonReentrant
        whenNotPaused
    {
        require(
            _beneficiaries.length == _values.length,
            "TNECManager: need to have same length"
        );
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            token.transferFrom(_from, _beneficiaries[i], _values[i]);
        }

        proposals[_proposalId].executed = true;
    }

    ///@notice payWithTokens, transfert tokens for market maker or BBDD
    ///@param _from, wallet from which transfer will be done
    ///@param _recipient, recipient address
    ///@param _value, amount to be send
    ///@param _actionType - Type of action (0 : distribution, 1 : paiement, 2 : marketMaker, 3 : DCA, 4 : BBDD)
    ///@param _proposalId, proposal identifier
    function payWithTokens(
        address _from,
        address _recipient,
        uint256 _value,
        uint256 _actionType,
        uint256 _proposalId
    )
        external
        canExecuteAction(_actionType, _proposalId)
        canTransfer(_actionType, _from)
        nonReentrant
        whenNotPaused
    {
        token.transferFrom(_from, _recipient, _value);

        proposals[_proposalId].executed = true;
    }

    ///@notice distributeDCA, distribute Tokens for DCA
    ///@param _from, wallet from which transfer will be done
    ///@param _members, list of all recipients
    ///@param _values, list of different amounts to be send
    ///@param _actionType - Type of action (0 : distribution, 1 : paiement, 2 : marketMaker, 3 : DCA, 4 : BBDD)
    ///@param _proposalId, proposal identifier
    function distributeDCA(
        address _from,
        address[] calldata _members,
        uint256[] calldata _values,
        uint256 _actionType,
        uint256 _proposalId
    )
        external
        canExecuteAction(_actionType, _proposalId)
        canTransfer(_actionType, _from)
        nonReentrant
        whenNotPaused
    {
        require(
            _members.length == _values.length,
            "TNECManager: need to have same length"
        );
        for (uint256 i = 0; i < _members.length; i++) {
            token.transferFrom(_from, _members[i], _values[i]);
        }

        proposals[_proposalId].executed = true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

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
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
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
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "./ERC20.sol";
import "./Pausable.sol";
import "./IPancakeRouter02.sol";
import "./IPancakeV2Pair.sol";
import "./IPancakeV2Factory.sol";

/**
 * @title Token.
 */
contract Token is ERC20, Pausable {
    // Defining tax variables
    uint256 public burnFeesBuy = 100; // percentage to burn when buying
    uint256 public rewardsFeesBuy = 100; // percentage to put aside for stakig rewards when buying
    uint256 public BBDDWalletFeesBuy = 0; // percentage to send to BBDD wallet when buying
    uint256 public tresoWalletFeesBuy = 100; // percentage to send to reserve wallet when buying

    uint256 public burnFeesSell = 100; // percentage to burn when selling
    uint256 public rewardsFeesSell = 200; // percentage to put aside for rewards when selling
    uint256 public BBDDWalletFeesSell = 100; // percentage to send to BBDD wallet when selling
    uint256 public tresoWalletFeesSell = 100; // percentage to send to tresorie wallet when selling
    uint256 public tokensToSwapPercentage = 5000; // percentage to swap TNEC stored on smart contract 

    bool public feesEnabled = true; // enable fees for all swap operations

    uint256 public MAX_TAX = 3000; // maximum allowed tax per transaction
    uint256 public constant DENOMINATOR = 10_000;

    mapping(address => bool) public whitelist; // list of addresses excluded from paying fees
    mapping(address => bool) public isMember; // list of actif members
    mapping(address => bool) private _owners; // list of owners

    address public BBDDWallet; // BBDD wallet
    address public tresoWallet; // Treso wallet
    address public rewardsWallet; // rewards wallet

    uint256 public toBBDD; // BBDD fees to be swapped to USDC
    uint256 public toTreso; // Treso fees to be swapped to USDC
    uint256 public toRewards; // Rewards fees to be swapped to USDC

    address public mainLP; // this LP pair is considered to be the main source of liquidity
    mapping(address => bool) public LPs; // sending to these addresses is considered a token sale

    address public constant USDC = 0x64544969ed7EBf5f083679233325356EbE738930; // USDC smart contract address

    IPancakeRouter02 public router; // router where the token is listed and has most of its USDC liquidity

    /// @notice onlyAuthorized is a modifier to verify if the sender is a member or whitelisted
    modifier onlyAuthorized() {
        require(isMember[msg.sender] || whitelist[msg.sender]);
        _;
    }

    ///@notice Throws if called by any account other than the owner.
    modifier onlyOwner() {
        require(_owners[msg.sender], "TNEC: caller is not owner");
        _;
    }

    ///@notice constructor, to initialize the smart contract
    ///@param _router, router address
    ///@param _BBDDWallet, BBDD wallet
    ///@param _tresoWallet, reserve wallet
    ///@param _totalSupply, total supply token
    constructor(
        address _router,
        address _BBDDWallet,
        address _tresoWallet,
        address _rewardsWallet,
        uint256 _totalSupply
    ) ERC20("Test token", "TEST") {
        _setOwner(address(0), msg.sender);
        setRouter(_router);
        setBBDDWallet(_BBDDWallet);
        settresoWallet(_tresoWallet);
        setRewardWallet(_rewardsWallet);
       _mint(msg.sender, _totalSupply);
        addToWhitelist(msg.sender);
        addToWhitelist(address(this));
        addToWhitelist(BBDDWallet);
        addToWhitelist(tresoWallet);
        addToWhitelist(rewardsWallet);
    }

    ///@notice receive, required to recieve BNB
    receive() external payable {}

    /// @notice withdrawBNB, required to withdraw BNB from this smart contract, only Owner can call this function
    /// @param amount number of BNB to be transfered
    function withdrawBNB(uint256 amount) public onlyOwner {
        if (amount == 0) payable(msg.sender).transfer(address(this).balance);
        else payable(msg.sender).transfer(amount);
    }

    /// @notice transferBNBToAddress, required to transfer BNB from this smart contract to recipient, only Owner can call this function
    /// @param recipient of BNB
    /// @param amount number of tokens to be transfered
    function transferBNBToAddress(address payable recipient, uint256 amount)
        public
        onlyOwner
    {
        recipient.transfer(amount);
    }

    /// @notice withdrawForeignToken, required to withdraw foreign tokens from this smart contract, only Owner can call this function
    /// @param token address of the token to withdraw
    function withdrawForeignToken(address token) public onlyOwner {
        require(
            !LPs[token],
            "Cannot withdraw LP tokens"
        );
        if(token == address(this)){
            uint256 toSend;
            toSend = ERC20(token).balanceOf(address(this));
            require(toSend > toBBDD + toTreso + toRewards, "Cannot withdraw native token, not enough to swap !");
            toSend = toSend - (toBBDD + toTreso + toRewards);
            transfer(msg.sender, toSend);
        }
        ERC20(address(token)).transfer(
            msg.sender,
            ERC20(token).balanceOf(address(this))
        );
    }

    /**
     * @notice Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        _owners[msg.sender] = false;
        _setOwner(msg.sender, address(0));
    }

    /**
     * @notice Returns the address of the current owner.
     */
    function owner(address _owner) public view returns (bool) {
        return _owners[_owner];
    }

    ///@notice Transfers ownership of the contract to a new account (`newOwner`), can only be called by the current owner.
    ///@param _newOwner, addresss of the new owner
    function transferOwnership(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(msg.sender, _newOwner);
    }

    ///@notice addNewOwner, add a new owner
    ///@param _newOwner, addresss of the new owner
    function addNewOwner(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(address(0), _newOwner);
    }

    ///@notice _setOwner, the address of the current owner
    ///@param _newOwner, addresss of the new owner
    ///@param _oldOwner, addresss of the old owner
    function _setOwner(address _oldOwner, address _newOwner) internal {
        _owners[_oldOwner] = false;
        _owners[_newOwner] = true;
    }

    /// @notice lockLiquidity, required to lock liquidity, only Owner can call this function
    /// @param amountADesired number of tokens A to lock
    /// @param amountBDesired number of tokens B to lock
    /// LP Cake tokens with be blocked to this address
    function lockLiquidity(uint256 amountADesired, uint256 amountBDesired)
        external
        onlyOwner
    {
        router.addLiquidity(
            address(this),
            USDC,
            amountADesired,
            amountBDesired,
            0,
            0,
            address(this),
            1e18 // absurdly high value
        );
    }

    /// @notice zeroAllTaxes required to remove all fees, only Owner can call this function
    function zeroAllTaxes() external onlyOwner {
        burnFeesBuy = 0;
        rewardsFeesBuy = 0;
        BBDDWalletFeesBuy = 0;
        tresoWalletFeesBuy = 0;

        burnFeesSell = 0;
        rewardsFeesSell = 0;
        BBDDWalletFeesSell = 0;
        tresoWalletFeesSell = 0;

        feesEnabled = false;
    }

    /// @notice setAllTaxes required to set all fees, only Owner can call this function
    /// @param  _burnFeesBuy, burn fees when buying
    /// @param  _burnFeesSell, burn fees when selling
    /// @param  _rewardsFeesBuy, staking fees when buying
    /// @param  _rewardsFeesSell, staking fees when selling
    /// @param  _BBDDWalletFeesBuy, BBDD fees when buying
    /// @param  _BBDDWalletFeesSell, BBDD fees when selling
    /// @param  _tresoWalletFeesBuy, reserve fees when buying
    /// @param  _tresoWalletFeesSell, reserve fees when selling
    function setAllTaxes(
        uint256 _burnFeesBuy,
        uint256 _burnFeesSell,
        uint256 _rewardsFeesBuy,
        uint256 _rewardsFeesSell,
        uint256 _BBDDWalletFeesBuy,
        uint256 _BBDDWalletFeesSell,
        uint256 _tresoWalletFeesBuy,
        uint256 _tresoWalletFeesSell
    ) external onlyOwner {
        burnFeesBuy = _burnFeesBuy;
        rewardsFeesBuy = _rewardsFeesBuy;
        BBDDWalletFeesBuy = _BBDDWalletFeesBuy;
        tresoWalletFeesBuy = _tresoWalletFeesBuy;
        require(
            burnFeesBuy +
                rewardsFeesBuy +
                BBDDWalletFeesBuy +
                tresoWalletFeesBuy <=
                MAX_TAX,
            "TNEC : Buy fees cannot exceed the MAX"
        );

        burnFeesSell = _burnFeesSell;
        rewardsFeesSell = _rewardsFeesSell;
        BBDDWalletFeesSell = _BBDDWalletFeesSell;
        tresoWalletFeesSell = _tresoWalletFeesSell;
        require(
            burnFeesSell +
                rewardsFeesSell +
                BBDDWalletFeesSell +
                tresoWalletFeesSell <=
                MAX_TAX,
            "TNEC : Buy fees cannot exceed the MAX"
        );

        feesEnabled = true;
    }

    /// @notice setRewardWallet, update the reward wallet, only Owner can call this function
    /// @param  _newRewardWallet, new reward address
    function setRewardWallet(address _newRewardWallet) public onlyOwner {
        require(_newRewardWallet != address(0), "cannot be the zero address");
        rewardsWallet = _newRewardWallet;
    }

    /// @notice setBBDDWallet, update the BBDD wallet, only Owner can call this function
    /// @param  _newBBDDWallet, new BBDD address
    function setBBDDWallet(address _newBBDDWallet) public onlyOwner {
        require(_newBBDDWallet != address(0), "cannot be the zero address");
        BBDDWallet = _newBBDDWallet;
    }

    /// @notice settresoWallet, update the reserve wallet, only Owner can call this function
    /// @param  _newtresoWallet, new reserve address
    function settresoWallet(address _newtresoWallet) public onlyOwner {
        require(_newtresoWallet != address(0), "cannot be the zero address");
        tresoWallet = _newtresoWallet;
    }

    /// @notice addToWhitelist, add an account to the whitelist to pay no fees, only Owner can call this function
    /// @param  account, account to whitelist
    function addToWhitelist(address account) public onlyOwner {
        require(!whitelist[account], "account is already whitelisted");
        whitelist[account] = true;
    }

    /// @notice removeFromWhitelist, remove an account to the whitelist to pay fees, only Owner can call this function
    /// @param  account, account to blacklist
    function removeFromWhitelist(address account) public onlyOwner {
        require(whitelist[account], "account is not whitelisted");
        whitelist[account] = false;
    }

    /// @notice addToMembers, add an account to members list, only Owner can call this function
    /// @param  account, account to members list
    function addToMembers(address account) public onlyOwner {
        require(!isMember[account], "TNEC: account is already a member");
        isMember[account] = true;
    }

    /// @notice removeFromMembers, remove an account to members list, only Owner can call this function
    /// @param  account, account to members list
    function removeFromMembers(address account) public onlyOwner {
        require(isMember[account], "TNEC: account is not a member");
        isMember[account] = false;
    }

    /// @notice addMultipleToMembers, add multiple accounts to members list, only Owner can call this function
    /// @param  accounts, accounts to add to members list
    function addMultipleToMembers(address[] memory accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(
                !isMember[accounts[i]],
                "TNEC: account is already a member"
            );
            isMember[accounts[i]] = true;
        }
    }

    /// @notice removeMultipleFromMembers, remove multiple accounts to members list, only Owner can call this function
    /// @param  accounts, accounts to remove from members list
    function removeMultipleFromMembers(address[] memory accounts)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(isMember[accounts[i]], "TNEC: account is not a member");
            isMember[accounts[i]] = false;
        }
    }

    /// @notice set fees, only Owner can call this function
    /// @param _enabled (true or false)
    function setFees(bool _enabled) public onlyOwner {
        feesEnabled = _enabled;
    }

    /// @notice setTNECPercentagesRewards, only Owner can call this function
    /// @param _percentageTNECrewards, percentage to be swapped to tokens 
    function setTNECPercentagesRewards(uint256 _percentageTNECrewards) public onlyOwner {
        tokensToSwapPercentage = _percentageTNECrewards;
    }

    /// @notice required to apply the correct fees taxes when buying
    /// @param amountIn, value received and to be dispatched
    /// @return amountOut value to be transfered
    /// @return toRewardsWallet value to be transfered to the staking wallet when buying
    /// @return toBBDDWallet value to be transfered to the BBDD wallet when buying
    /// @return toTresoWallet value to be transfered to the reserve wallet when buying
    /// @return toBurn value to be burn when buying
    function applyFeesBuy(uint256 amountIn)
        public
        view
        returns (
            uint256 amountOut,
            uint256 toRewardsWallet,
            uint256 toBBDDWallet,
            uint256 toTresoWallet,
            uint256 toBurn
        )
    {
        toRewardsWallet = (amountIn * rewardsFeesBuy) / DENOMINATOR;
        toBBDDWallet = (amountIn * BBDDWalletFeesBuy) / DENOMINATOR;
        toTresoWallet = (amountIn * tresoWalletFeesBuy) / DENOMINATOR;
        toBurn = (amountIn * burnFeesBuy) / DENOMINATOR;
        amountOut =
            amountIn -
            (toRewardsWallet + toBBDDWallet + toTresoWallet + toBurn);
    }

    /// @notice required to apply the correct fees taxes when selling
    /// @param amountIn, value received and to be dispatched
    /// @return amountOut value to be transfered
    /// @return toRewardsWallet value to be transfered to the staking wallet when selling
    /// @return toBBDDWallet value to be transfered to the BBDD wallet when selling
    /// @return toTresoWallet value to be transfered to the reserve wallet when selling
    /// @return toBurn value to be burn when selling
    function applyFeesSell(uint256 amountIn)
        public
        view
        returns (
            uint256 amountOut,
            uint256 toRewardsWallet,
            uint256 toBBDDWallet,
            uint256 toTresoWallet,
            uint256 toBurn
        )
    {
        toRewardsWallet = (amountIn * rewardsFeesSell) / DENOMINATOR;
        toBBDDWallet = (amountIn * BBDDWalletFeesSell) / DENOMINATOR;
        toTresoWallet = (amountIn * tresoWalletFeesSell) / DENOMINATOR;
        toBurn = (amountIn * burnFeesSell) / DENOMINATOR;
        amountOut =
            amountIn -
            (toRewardsWallet + toBBDDWallet + toTresoWallet + toBurn);
    }

    ///@notice addLPAddress, add an LP address to LPs. Transferring to an address in `LPs` is considered a sale
    ///@param _newLP, new LP address to add
    function addLPAddress(address _newLP) external onlyOwner {
        require(!LPs[_newLP], "already added");
        LPs[_newLP] = true;
    }

    ///@notice removeLPAddress, add an LP address to LPs. Transferring to an address in `LPs` is considered a sale
    ///@param _LP,  LP address to remove
    function removeLPAddress(address _LP) external onlyOwner {
        require(LPs[_LP], "not set");
        require(_LP != mainLP, "cannot remove main LP");
        LPs[_LP] = false;
    }

    ///@notice pause, Pauses functions modified with `whenNotPaused`, can be called only by owner
    function pause() external virtual whenNotPaused onlyOwner {
        _pause();
    }

    ///@notice  Unpauses functions modified with `whenNotPaused`, can be called only by owner
    function unpause() external virtual whenPaused onlyOwner {
        _unpause();
    }

    ///@notice update the router. Updating the router automatically updates the main LP, can be called only by owner
    ///@param _newRouter, new address to add
    function setRouter(address _newRouter) public onlyOwner {
        require(_newRouter != address(0), "cannot be the zero address");
        router = IPancakeRouter02(_newRouter);
        mainLP = IPancakeV2Factory(router.factory()).createPair(
            address(this),
            USDC
        );
        LPs[mainLP] = true;
        _approve(address(this), address(router), type(uint256).max);
        ERC20(USDC).approve(address(router), type(uint256).max);
    }

    ///NB: APPROVE REWARD WALLET 
    ///@notice swapAndTransfer, required to swap tokens for USDC and transfer to specific address. Called only by the owner
    ///@param members, list of members for which the distribution will be done (USDC and TNEC)
    ///@param percentages, list of pourcentages for each member (TNEC and USDC)
    function swapAndTransfer(address[] calldata members, uint256[] calldata percentages) public whenNotPaused onlyOwner {
        uint256 _toTokens = toRewards * tokensToSwapPercentage / DENOMINATOR; 
        uint256 _amount = toBBDD + toTreso + (toRewards - _toTokens);

        address[] memory _path = new address[](2);

        _path[0] = address(this);
        _path[1] = USDC;

        require(members.length == percentages.length, "Not correct length for members and percentages !");
        
        // swap and transfer 
        if (_amount > 0) {
            uint256 _amountBefore = ERC20(USDC).balanceOf(rewardsWallet);
            _swapTokensForUSDCAndTransfer(_amount, rewardsWallet);
            uint256 _amountAfter = ERC20(USDC).balanceOf(rewardsWallet);
            
            ERC20(USDC).transferFrom(rewardsWallet, address(this), _amountAfter - _amountBefore);
            uint256 amountUSDCswapped = _amountAfter - _amountBefore;

            uint256 _toBBDD = toBBDD * amountUSDCswapped / _amount;
            uint256 _toTreso = toTreso * amountUSDCswapped / _amount;
            uint256 _toRewards = (toRewards - _toTokens) * amountUSDCswapped / _amount;

            toBBDD = 0;
            toTreso = 0;
            toRewards = 0;

            // Transfer to BBDD 
            ERC20(USDC).transfer(BBDDWallet, _toBBDD);

            // Transfer to treso 
            ERC20(USDC).transfer(tresoWallet, _toTreso);

            // distribute USDC and TNEC
            for(uint256 i= 0; i < members.length; i++){
                ERC20(USDC).transfer(members[i], _toRewards * percentages[i] / DENOMINATOR);
                super._transfer(address(this), members[i], _toTokens * percentages[i] / DENOMINATOR);
            } 
        }
    }

    /// @notice adds liquidity to the main pool. Liquidity without paying fees taxes
    /// @param amountADesired, The amount of tokenA to add as liquidity if the B/A price is <= amountBDesired/amountADesired (A depreciates).
    /// @param amountBDesired, The amount of tokenB to add as liquidity if the A/B price is <= amountADesired/amountBDesired (B depreciates).
    /// @param amountAMin, Bounds the extent to which the B/A price can go up before the transaction reverts. Must be <= amountADesired.
    /// @param amountBMin, Bounds the extent to which the A/B price can go up before the transaction reverts. Must be <= amountBDesired.
    /// @param to, Recipient of the liquidity tokens.
    /// @param deadline, Unix timestamp after which the transaction will revert.
    function addLiquidityWithoutFees(
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external whenNotPaused onlyAuthorized {
        feesEnabled = false;
        router.addLiquidity(
            address(this),
            USDC,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
        feesEnabled = true;
    }

    /// @notice removes liquidity from the main pool. Liquidity without paying fees taxes
    /// @param liquidity, The amount of liquidity tokens to remove
    /// @param amountAMin, The minimum amount of tokenA that must be received for the transaction not to revert
    /// @param amountBMin, The minimum amount of tokenB that must be received for the transaction not to revert
    /// @param to, Recipient of the underlying assets
    /// @param deadline, Unix timestamp after which the transaction will revert
    function removeLiquidityWithoutFees(
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external whenNotPaused onlyAuthorized {
        feesEnabled = false;
        ERC20(mainLP).approve(address(router), type(uint256).max);
        router.removeLiquidity(
            address(this),
            USDC,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
        feesEnabled = true;
    }

    ///@notice burn, destroys `amount` tokens from the caller
    ///@param amount, the amount of tokens to be sent
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    ///@notice handles the before and after of a token transfer, such as taking fees and firing off a swap and liquify event
    ///@param sender, sender of the transaction
    ///@param recipient, recipient of the transaction
    ///@param amount, the amount of tokens to be sent
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override whenNotPaused {
        if (!whitelist[sender] && !whitelist[recipient] && feesEnabled) {
            if (LPs[sender]) {
                (
                    uint256 _amountOut,
                    uint256 _toRewardsWallet,
                    uint256 _toBBDDWallet,
                    uint256 _toTresoWallet,
                    uint256 _toBurn
                ) = applyFeesBuy(amount);

                amount = _amountOut;
                super._transfer(
                    sender,
                    address(this),
                    _toRewardsWallet + _toBBDDWallet + _toTresoWallet
                );

                // store how many tokens to swap for usdc and to transfer to reward wallet
                toBBDD += _toBBDDWallet;
                toTreso += _toTresoWallet;
                toRewards += _toRewardsWallet;

                _burn(sender, _toBurn);
            } else if (LPs[recipient]) {
                (
                    uint256 _amountOut,
                    uint256 _toRewardsWallet,
                    uint256 _toBBDDWallet,
                    uint256 _toTresoWallet,
                    uint256 _toBurn
                ) = applyFeesSell(amount);

                amount = _amountOut;
                super._transfer(
                    sender,
                    address(this),
                    _toRewardsWallet + _toBBDDWallet + _toTresoWallet
                );

                // store how many tokens to swap for usdc and to transfer to reward wallet
                toBBDD += _toBBDDWallet;
                toTreso += _toTresoWallet;
                toRewards += _toRewardsWallet;

                // burn some tokens
                _burn(sender, _toBurn);
            }
        }

        super._transfer(sender, recipient, amount);
    }

    ///@notice _addUSDCLiquidity, required to add liquidity to the main LP
    ///@param amount, amount to be added to the LP
    function _addUSDCLiquidity(uint256 amount) internal {
        uint256 toUSDC = amount / 2;
        uint256 amountNativeToken = amount - toUSDC;
        uint256 initialUSDCBalance = ERC20(USDC).balanceOf(address(this));
        _swapTokensForUSDCToThisContract(toUSDC);
        uint256 amountUSDCswapped = ERC20(USDC).balanceOf(address(this)) -
            initialUSDCBalance;

        // add liquidity
        router.addLiquidity(
            address(this),
            USDC,
            amountNativeToken,
            amountUSDCswapped,
            0,
            0,
            address(0),
            1e18 // absurdly high value
        );
    }

    ///@notice _swapTokensForUSDCAndTransfer, required to swap tokens for USDC and transfer to specific address
    ///@param amount, amount to be swaped
    ///@param to, address to receiver the amount swaped
    function _swapTokensForUSDCAndTransfer(uint256 amount, address to)
        internal
    {
        if (amount > 0) {
            address[] memory _path = new address[](2);

            _path[0] = address(this);
            _path[1] = USDC;

            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                0,
                _path,
                to,
                1e18
            );
        }
    }

    ///@notice _swapTokensForUSDCToThisContract, swap some tokens for USDC and send them to this contract. The function uses two swaps in order
    // to bypass some router limitation. Function is quite inelegant.
    ///@param amount, amount to be swaped
    function _swapTokensForUSDCToThisContract(uint256 amount) internal {
        if (amount > 0) {
            // 1. Swap NOSTA for BNB
            address[] memory _path = new address[](3);
            _path[0] = address(this);
            _path[1] = USDC;
            _path[2] = router.WETH();

            uint256 _BNBBalance = address(this).balance;
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amount,
                0,
                _path,
                address(this),
                1e18
            );

            _BNBBalance = address(this).balance - _BNBBalance;

            // 2. Swap BNB for USDC
            address[] memory _path2 = new address[](2);
            _path2[0] = router.WETH();
            _path2[1] = USDC;
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: _BNBBalance
            }(0, _path2, address(this), 1e18);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

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
    constructor() {
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

interface IPancakeV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

interface IPancakeV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}