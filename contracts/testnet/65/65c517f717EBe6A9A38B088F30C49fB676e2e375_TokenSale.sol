/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: MIT

// File: contracts/Context.sol



pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: contracts/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }


    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }




    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/interfaces/IBEP20.sol




pragma solidity ^0.8.0;


interface IBEP20 {

    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: contracts/TokenSale.sol


pragma solidity ^0.8.9;



contract Whitelist {
    mapping(address => bool) public whitelist;

    function _addToWhitelist(address _beneficiary) internal {
        whitelist[_beneficiary] = true;
    }

    function _addManyToWhitelist(address[] memory _beneficiaries) internal {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = true;
        }
    }

    function _removeFromWhitelist(address _beneficiary) internal {
        whitelist[_beneficiary] = false;
    }

    function _removeManyFromWhitelist(address[] memory _beneficiaries)
        internal
    {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = false;
        }
    }
}

contract Pausable {
    bool public paused;

    modifier whenNotPaused() {
        require(!paused, "sale is paused");
        _;
    }

    function _pauseSale() internal {
        require(!paused, "Sale already paused");
        paused = true;
    }

    function _unPauseSale() internal {
        require(paused, "Sale is not paused");
        paused = false;
    }
}

contract TokenSale is Whitelist, Ownable, Pausable {
    uint256 public presaleRate;
    uint256 public publicsaleRate;

    uint256 public presaleTimestamp;
    uint256 public publicsaleStartTimestamp;
    uint256 public publicsaleEndTimestamp;

    uint256 public unverifiedLimit;
    uint256 public verifiedLimit;

    uint256 public walletCut;
    uint256 public charityCut;

    address payable public wallet;
    address payable public charityWallet;
    address public whitelister;

    IBEP20 public token;

    mapping(address => uint256) public contributions;

    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    constructor(
        uint256 _publicsaleRate,
        uint256 _presaleRate,
        uint256 _presaleTimestamp,
        uint256 _publicsaleStartTimestamp,
        uint256 _publicsaleEndTimestamp,
        uint256 _unverifiedLimit,
        uint256 _verifiedLimit,
        uint256 _walletCut,
        uint256 _charityCut,
        address payable _wallet,
        address payable _charityWallet,
        address _token
    ) {
        require(_publicsaleRate > 0);
        require(_presaleRate > 0);
        require(_wallet != address(0) && _charityWallet != address(0));
        require(address(_token) != address(0));

        presaleRate = _presaleRate;
        publicsaleRate = _publicsaleRate;

        unverifiedLimit = _unverifiedLimit;
        verifiedLimit = _verifiedLimit;

        presaleTimestamp = _presaleTimestamp;
        publicsaleStartTimestamp = _publicsaleStartTimestamp;
        publicsaleEndTimestamp = _publicsaleEndTimestamp;

        setCuts(_walletCut, _charityCut);

        whitelister = msg.sender;
        charityWallet = _charityWallet;
        wallet = _wallet;

        token = IBEP20(_token);
    }

    modifier onlyWhitelister() {
        require(msg.sender == whitelister, "only Whitelister");
        _;
    }

    function setWhiteListerAddress(address _whitelister) external onlyOwner {
        whitelister = _whitelister;
    }

    function pauseSale() external onlyOwner {
        _pauseSale();
    }

    function unPauseSale() external onlyOwner {
        _unPauseSale();
    }

    function setCuts(uint256 _walletCut, uint256 _charityCut) public onlyOwner {
        /*
        sets the Cuts for The fundsWallet and the charityWallet
            Percentages are calculated in Bips (Basis Points)
            Examples : 
                100 % = 10000 pibs
                15.5% = 1550 pibs
                2.57% = 257 pibs
        Note: Sum of the Cuts should be 10000 
        */
        require(_walletCut + _charityCut == 10000, "cuts should sum to 10000");
        walletCut = _walletCut;
        charityCut = _charityCut;
    }

    function buyTokens(address beneficiary)
        public
        payable
        whenNotPaused
        
    {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);
        uint256 tokens = _getTokenAmount(weiAmount);
        _updatePurchasingState(beneficiary, weiAmount);
        _processPurchase(beneficiary, tokens);
        _forwardFunds();

        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    }

    function _preValidatePurchase(address beneficiary, uint256 _weiAmount)
        internal
        view
    {
        require(block.timestamp > presaleTimestamp, "sale hasn't started");
        require(block.timestamp < publicsaleEndTimestamp, "sale is over");
        require(beneficiary != address(0));
        require(_weiAmount != 0);

        uint256 total = contributions[beneficiary] + _weiAmount;
        require(total <= verifiedLimit, "Exceed max amount");

        if (total > unverifiedLimit) {
            require(whitelist[beneficiary], "Not verified");
        }

    }

    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount)
        internal
    {
        contributions[_beneficiary] += _weiAmount;
    }

    function _getTokenAmount(uint256 _weiAmount)
        internal
        view
        returns (uint256)
    {
        return _weiAmount * getRate();
    }

    function getRate() public view returns (uint256) {
        if (block.timestamp < publicsaleStartTimestamp) {
            return presaleRate;
        }
        return publicsaleRate;
    }

    function _processPurchase(address _beneficiary, uint256 _tokenAmount)
        internal
    {
        bool success = token.transfer(_beneficiary, _tokenAmount);
        require(success, "Transfer Failed");
    }

    function _forwardFunds() internal {
        _splitFunds(msg.value);
    }

    function withdrowFunds() external onlyOwner {
        uint256 amount = address(this).balance;
        _splitFunds(amount);
    }

    function _splitFunds(uint256 _amount) internal {
        uint256 walletAmount = (_amount * walletCut) / 10000;
        uint256 charityAmount = (_amount * charityCut) / 10000;
        _safeTransfer(charityWallet, charityAmount);
        _safeTransfer(wallet, walletAmount);
    }

    function _safeTransfer(address _to, uint256 _value) internal {
        (bool success, ) = _to.call{value: _value}("");
        require(success, "Transfer Failed.");
    }

    function addToWhitelist(address _beneficiary) external onlyWhitelister {
        _addToWhitelist(_beneficiary);
    }

    function addManyToWhitelist(address[] memory _beneficiaries)
        external
        onlyWhitelister
    {
        _addManyToWhitelist(_beneficiaries);
    }

    function removeFromWhitelist(address _beneficiary)
        external
        onlyWhitelister
    {
        _removeFromWhitelist(_beneficiary);
    }

    function removeManyFromWhitelist(address[] memory _beneficiaries)
        external
        onlyWhitelister
    {
        _removeManyFromWhitelist(_beneficiaries);
    }

    function setPresaleTimeStamp(uint256 _newTimestamp) external onlyOwner {
        require(block.timestamp < presaleTimestamp, "presale already started");
        presaleTimestamp = _newTimestamp;
    }

    function setPublicsaleStartTimeStamp(uint256 _newTimestamp)
        external
        onlyOwner
    {
        require(
            block.timestamp < publicsaleStartTimestamp,
            "publicsale Already started"
        );

        require(
            _newTimestamp > presaleTimestamp,
            "Publicsale should be after presale"
        );
        require(
            block.timestamp < _newTimestamp,
            "Timestamp should be in the future"
        );
        publicsaleStartTimestamp = _newTimestamp;
    }

    function setPublicsaleEndTimeStamp(uint256 _newTimestamp)
        external
        onlyOwner
    {
        require(block.timestamp < publicsaleEndTimestamp, "sale finished");

        require(
            _newTimestamp > publicsaleStartTimestamp,
            "Publicsale should be after publicsale start timestamp"
        );
        require(
            block.timestamp < _newTimestamp,
            "Timestamp should be in the future"
        );
        publicsaleStartTimestamp = _newTimestamp;
    }

    function setUnverifiedLimit(uint256 _newLimit) external onlyOwner {
        require(_newLimit != unverifiedLimit, "new limit equals old limit");
        require(_newLimit != 0, "new limit = 0");

        unverifiedLimit = _newLimit;
    }

    function setVerifiedLimit(uint256 _newLimit) external onlyOwner {
        require(_newLimit != verifiedLimit, "new limit equals old limit");
        require(_newLimit != 0, "new limit = 0");

        verifiedLimit = _newLimit;
    }

    function setWallet(address payable _newWallet) external onlyOwner {
        require(_newWallet != address(0), "address 0");
        wallet = _newWallet;
    }

    function setCharityWallet(address payable _newWallet) external onlyOwner {
        require(_newWallet != address(0), "address 0");
        charityWallet = _newWallet;
    }

    function claimRemainingTokens() external onlyOwner {
        require(
            block.timestamp > publicsaleEndTimestamp,
            "sale is not finished"
        );
        bool success = token.transfer(
            msg.sender,
            token.balanceOf(address(this))
        );
        require(success, "Transfer Failed");
    }

    function recoverBEP20(address tokenAddress, uint256 tokenAmount)
        public
        onlyOwner
    {
        require(tokenAddress != address(token));
        IBEP20(tokenAddress).transfer(msg.sender, tokenAmount);
    }

    fallback() external payable {
        buyTokens(msg.sender);
    }

    receive() external payable {
        buyTokens(msg.sender);
    }
}

// File: contracts/TokenLocker.sol




pragma solidity ^0.8.9;



contract TokenLocker  is  Ownable{

    struct LockedData {
        uint256 amount;
        uint256 unlockDate;
        bool claimed;
    }

    IBEP20  public immutable  TOKEN;
    mapping(address =>  LockedData []) public records;

    constructor(address _token){
        TOKEN = IBEP20(_token);
        transferOwnership(owner());
    }


    function unlock(uint256 index, address _claimer) public onlyOwner returns(bool){
        require(block.timestamp > records[_claimer][index].unlockDate, "too Early");
        require(!records[_claimer][index].claimed, "already Claimed.");

        LockedData storage frozen_balance = records[_claimer][index];
        frozen_balance.claimed = true;
        uint256 amount = frozen_balance.amount;
        bool sucess = TOKEN.transfer(_claimer, amount);
        require(sucess);
        return sucess;
    }


    function lock(address _locker, uint256 amount, uint256 unlockDate, address _claimer) external onlyOwner returns(bool){
        require(unlockDate > block.timestamp, "unlock date must be in the future");
        require(amount > 0, "amount 0");
        LockedData memory locked_data = LockedData(amount, unlockDate, false);
        records[_claimer].push(locked_data);
        bool sucess = TOKEN.transferFrom(_locker, address(this), amount);
        require(sucess);
        return true;
    }

    function claimable(uint256 index, address _claimer) public view returns(bool, uint){
        if(records[_claimer].length <= index){
            return (false, 0);
        }
        LockedData memory lockedBalance = records[_claimer][index];
        if (lockedBalance.claimed || lockedBalance.unlockDate > block.timestamp){
            return (false, 0);
        }
        return (true, lockedBalance.amount);
    }

    function unlockAllClaimableTokens(address _claimer) external returns(uint256){
        LockedData [] memory lockedData = records[_claimer];
        require(getListLength(_claimer) > 0, "No locked Balance");
        uint256 totalAmount = 0;
        for(uint256 i = 0; i < lockedData.length; i++){
            (bool cond, uint256 amount) = claimable(i, _claimer);
            if(cond){
                unlock(i, _claimer);
                totalAmount += amount;
            }
        }
        require(totalAmount > 0, "No Claimable Tokens");
        return totalAmount;
    }

    function amountOfClaimableTokens(address _claimer) external view returns(uint){
        if(getListLength(_claimer) == 0){
            return 0;
        }

        LockedData [] memory lockedData = records[_claimer];
        uint256 totalAmount = 0;
        for(uint256 i = 0; i < lockedData.length; i++){
            (bool cond, uint256 amount) = claimable(i, _claimer);
            if(cond){
                totalAmount += amount;
            }
        }
        if(totalAmount == 0){
            return 0;
        }
        return totalAmount;
    }

    function getListLength(address _claimer) public view returns(uint256){
        return records[_claimer].length;
    }

}
// File: contracts/interfaces/IBEP20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IBEP20Metadata is IBEP20 {
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

// File: contracts/BEP20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




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
contract BEP20 is Context, IBEP20, IBEP20Metadata {
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

// File: contracts/Token.sol


pragma solidity ^0.8.9;






contract Token is BEP20, Ownable {
    TokenLocker public tokenLocker;
    TokenSale public tokenSale;
    mapping(address => uint256) public lockedBalance;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) BEP20(name, symbol) {
        _mint(msg.sender, initialSupply);
        tokenLocker = new TokenLocker(address(this));
    }

    function setTokenSale(address payable tokenSale_) external onlyOwner {
        tokenSale = TokenSale(tokenSale_);
    }

    function setTokenLocker(address tokenLocker_) external onlyOwner {
        require(tokenLocker_ != address(0), "0 address");
        tokenLocker = TokenLocker(tokenLocker_);
    }

    function sendLockedTokens(
        address _account,
        uint256 _timestamp,
        uint256 _amount
    ) external onlyOwner {
        /*
            TokenLocker contract call
            lock(address freezer, uint256 amount, uint256 unlockDate, address _claimer) returns bool
        */
        require(_amount > 0, "amount 0");
        _locked_add(_account, _amount);
        _approve(msg.sender, address(tokenLocker), _amount);
        bool success = tokenLocker.lock(
            msg.sender,
            _amount,
            _timestamp,
            _account
        );
        require(success, "");
    }

    function unlockTokens(address _account, uint256 _index) external {
        /*
            TokenLocker contract call
            unfreez(uint256 index, address _claimer) public returns(uint)
        */
        require(lockedBalance[_account] > 0, "No locked Balance");

        (bool claimable, uint256 amount) = tokenLocker.claimable(
            _index,
            _account
        );
        require(claimable, "not Claimable");
        _locked_sub(_account, amount);
        bool success = tokenLocker.unlock(_index, _account);
        require(success);
        
        
        
    }
    

    function unlockAllTokens(address _account) external {
        require(lockedBalance[_account] > 0, "No locked Balance");
        uint256 amount = tokenLocker.unlockAllClaimableTokens(_account);
        _locked_sub(_account, amount);
        require(amount > 0);
   
    }
    
    function amountOfClaimableTokens(address _account)external view returns (uint){
        return tokenLocker.amountOfClaimableTokens(_account);
    }

    function _locked_add(address _account, uint256 _amount)
        internal
        returns (bool)
    {
        lockedBalance[_account] += _amount;
        return true;
    }

    function _locked_sub(address _account, uint256 _amount)
        internal
        returns (bool)
    {
        lockedBalance[_account] -= _amount;
        return true;
    }

    function recoverBEP20(address tokenAddress, uint256 tokenAmount)
        public
        onlyOwner
    {
        IBEP20(tokenAddress).transfer(msg.sender, tokenAmount);
    }

    fallback() external payable {
        tokenSale.buyTokens{value: msg.value}(msg.sender);
    }

    receive() external payable {
        tokenSale.buyTokens{value: msg.value}(msg.sender);
    }
}