//SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import "ERC20.sol";
import "ERC20Burnable.sol";
import "Pausable.sol";
import "Ownable.sol";

/// @custom:security-contact [email protected]

contract MGUToken is ERC20, ERC20Burnable, Pausable, Ownable {
    constructor() ERC20("MetaGreenUniverse", "MGU") {
        _admin = msg.sender;
        _setCategoriesDefault();
        _presaleCount = 0;
    }

    /**
     *@dev ERC20 variables
     */
    string private _name = "MetaGreenUniverse";
    string private _symbol = "MGU";
    address private _admin;
    uint256 private _totalsupply = 11_700_000_000 * 10**decimals();
    uint8 private constant _decimals = 18;

    /**
     *@dev presale variables
     */
    uint256 private constant _PreSaleAmountCap = 234_000_000 * 10**18;
    uint256 private _PreSaleAmount = 234_000_000 * 10**decimals();
    uint256 private _presaleStartAt;

    /**
     *@dev Private Sale variables
     */
    uint256 constant _PrivateSaleAmountCap = 585_000_000 * 10**18;
    uint256 private _PrivateSaleAmount;
    mapping(uint256 => address) private _privateSaleAddress;
    uint256 private _privatecount;

    /**
     *@dev setter and status getter for presale contract address
     */
    address private _preSaleContractAddress;
    bool private _isPreSaleContractSet = false;

    /**
     *@dev gets pause status
     */
    bool private _isPaused = false;

    /**
     *@dev mapping for store paused addresses
     */
    mapping(address => bool) private _isPausedAddress;
    mapping(uint256 => address) private _preSaleAddress;
    uint256 _presaleCount;

    mapping(address => uint256) private whitelisted;
    mapping(address => bool) private _iswhitelisted;

    uint256 _burtAt;
    /**
     *@dev  Define lock time period for Private Sale start after Deployment.
     */
    uint256 private _privateSaleTimePeriod = block.timestamp + 180 days;

    /**
     *@dev struct for define each category detail
     */
    struct details {
        address Address;
        uint256 maxCap;
        uint256 amount;
        uint256 timePeriod;
        uint256 remain;
        uint256 startDistributionAt;
    }
    mapping(string => details) private category;
    /**
     *@dev only for iteration on category names
     */
    string[] private categoriesName;

    /**
     *@dev initializer function only runs at deploy to set the constant values for each category.
     */
    function _setCategoriesDefault() private onlyAdmin {
        category["PublicSale"]
            .Address = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;
        category["PublicSale"].maxCap = 2_808_000_000 * 10**decimals();
        category["PublicSale"].amount = 58_500_000 * 10**decimals();
        category["PublicSale"].timePeriod = 30 days;
        category["PublicSale"].remain = category["PublicSale"].maxCap;
        category["PublicSale"].startDistributionAt = block.timestamp + 60 days;
        categoriesName.push("PublicSale");
        category["Reserved"]
            .Address = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        category["Reserved"].maxCap = 2_106_000_000 * 10**decimals();
        category["Reserved"].amount = 43_875_000 * 10**decimals();
        category["Reserved"].timePeriod = 60 days;
        category["Reserved"].remain = category["Reserved"].maxCap;
        category["Reserved"].startDistributionAt = block.timestamp + 180 days;
        categoriesName.push("Reserved");
        category["Reward"].Address = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
        category["Reward"].maxCap = 2_106_000_000 * 10**decimals();
        category["Reward"].amount = 43_875_000 * 10**decimals();
        category["Reward"].timePeriod = 30 days;
        category["Reward"].remain = category["Reward"].maxCap;
        category["Reward"].startDistributionAt = block.timestamp + 120 days;
        categoriesName.push("Reward");
        category["Finance"]
            .Address = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
        category["Finance"].maxCap = 1_755_000_000 * 10**decimals();
        category["Finance"].amount = 36_562_500 * 10**decimals();
        category["Finance"].timePeriod = 30 days;
        category["Finance"].remain = category["Finance"].maxCap;
        category["Finance"].startDistributionAt = block.timestamp + 60 days;
        categoriesName.push("Finance");
        category["Team"].Address = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;
        category["Team"].maxCap = 1_170_000_000 * 10**decimals();
        category["Team"].amount = 24_375_000 * 10**decimals();
        category["Team"].timePeriod = 90 days;
        category["Team"].remain = category["Team"].maxCap;
        category["Team"].startDistributionAt = block.timestamp + 240 days;
        categoriesName.push("Team");
        category["Advisor"]
            .Address = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;
        category["Advisor"].maxCap = 936_000_000 * 10**decimals();
        category["Advisor"].amount = 19_500_000 * 10**decimals();
        category["Advisor"].timePeriod = 30 days;
        category["Advisor"].remain = category["Advisor"].maxCap;
        category["Advisor"].startDistributionAt = block.timestamp + 120 days;
        categoriesName.push("Advisor");
    }

    // admin modifier
    modifier onlyAdmin() {
        require(_admin == msg.sender, "Admin:You are not Allowed!");
        _;
    }

    /**
     *@dev only Presale Contract Address has Access to presaleDistribution Function
     */
    modifier isPreSaleContract() {
        require(msg.sender != address(0), "Zero Address! Not Allowed");
        require(
            msg.sender == _preSaleContractAddress,
            "This is Not the Right Contract: Not Allowed!"
        );
        _;
    }

    modifier isPresaleEnded() {
        require(_presaleStartAt > 0, "Presale Not set!");
        require(
            block.timestamp > (_presaleStartAt + 30 days),
            "Presale Not Ended"
        );
        _;
    }

    /**
     *@dev In Case of Any ERRORs or BUGs occurred, ONLY Owner and Admin has Right to Pause or UnPause Token
     */
    function pause() public onlyOwner {
        _pause();
        _isPaused = true;
    }

    function unpause() public onlyOwner {
        _unpause();
        _isPaused = false;
    }

    function pauseAdmin() external onlyAdmin {
        pause();
    }

    function unpauseAdmin() external onlyAdmin {
        unpause();
    }

    function pauseAddress(address sender) public onlyAdmin {
        _isPausedAddress[sender] = true;
    }

    function unPauseAddress(address sender) public onlyAdmin {
        _isPausedAddress[sender] = false;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalsupply;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     *@dev has onlyOwner Role. sets the presale contract.
     */
    function setPreSaleContract(address Contract, uint256 _startAt)
        external
        onlyOwner
    {
        require(Contract != address(0), "Zero address");
        require(
            block.timestamp < _startAt,
            "Not Correct Time for Start Presale!"
        );
        _preSaleContractAddress = Contract;
        _isPreSaleContractSet = true;
        _presaleStartAt = _startAt;
    }

    /**
     *@dev has onlyOwner Role. In case of any Error occured this function RESET the presale contract
     */
    function unSetPreSaleContract() external onlyOwner {
        _preSaleContractAddress = address(0);
        _isPreSaleContractSet = false;
    }

    /**
     *@dev gets presale contract address
     */
    function getPreSaleContract() external view returns (address) {
        return _preSaleContractAddress;
    }

    /**
     *@dev checks if 'sender' has paused or not
     */
    function isAddressPaused(address sender)
        external
        view
        returns (string memory)
    {
        require(sender != address(0), "Zero Address!");
        if (_isPausedAddress[sender]) {
            return "Yes,This Address Paused";
        } else {
            return "No,This Address Not Paused";
        }
    }

    /**
     *@dev Get the Categories Detail
     *@param categoryname string type that will be one of the categories's name.
     *       category names: "PublicSale" "Reserved" "Reward" "Finance" "Advisor" "Team"
     *returns tuple(address : category Address,
     *               uint256 : category MaxCap,
     *               uint256 : category Amount,
     *               uint256 : category TimePeriod,
     *               uint256 : category remain,
     *               uint256 : category Next withdrawal Threshold
     *               );
     */
    function getCategoryDetail(string memory categoryname)
        external
        view
        returns (details memory)
    {
        return category[categoryname];
    }

    /**
     *@dev gets the Admin address
     */
    function getAdmin() external view returns (address) {
        return _admin;
    }

    /**
     *@dev sets the new Admin
     *     Calls by onlyOwner
     */
    function setAdmin(address newAdmin)
        public
        onlyOwner
        returns (string memory)
    {
        require(newAdmin != address(0), "Zero Address can not be an Admin");
        _admin = newAdmin;
        return "Admin Changed";
    }

    /**
     *@dev calls by onlyOwner Role and checks if unlock Time arrived for specific category item,
     *     if not reached to its own Cap ,then Distributes token and also calculate
     *     and set the remaining as well as the next unlock Threshold for distribution.
     */
    function mintForCategory(string memory categoryname) external onlyOwner {
        if (checkCategoryName(categoryname)) {
            require(
                block.timestamp >= category[categoryname].startDistributionAt,
                "Admin: Not Available Fund Yet!"
            );
            require(
                category[categoryname].remain - category[categoryname].amount >=
                    0,
                "Admin: Reached MaxCap!"
            );
            _mint(
                category[categoryname].Address,
                category[categoryname].amount
            );
            category[categoryname].remain -= category[categoryname].amount;
            category[categoryname].startDistributionAt =
                block.timestamp +
                category[categoryname].timePeriod;
        } else {
            require(false, "Admin: There is no such a category!");
        }
    }

    /**
     *@dev checks for existence of entered name in category array.
     */
    function checkCategoryName(string memory categoryname)
        private
        view
        returns (bool)
    {
        for (uint256 i = 0; i < categoriesName.length; i++) {
            if (
                keccak256(abi.encode(categoriesName[i])) ==
                keccak256(abi.encode(categoryname))
            ) {
                return true;
            }
        }
        return false;
    }

    /**
     *@dev override the token transfer and checks for:
     *     1) 'from' not to be Paused
     *     2) token not paused
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        require(
            !_isPausedAddress[from],
            "ERC20Pausable: token transfer while paused on address"
        );
        require(!_isPaused, "ERC20Pausable: token transfer while paused");
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev mints the amount token to each corresponding address when the Time Period Arrived and withdrawal unlocked
     * requires that sum of Amounts Not exceeds the Max cap of Private Sale.
     * @param Addresses Token purchaser
     * @param Amounts Amount of tokens purchased
     */
    function mintForPrivateSaleAddresses(
        address[] memory Addresses,
        uint256[] memory Amounts
    ) external onlyOwner returns (bool) {
        uint256 overAllAmount = _PrivateSaleAmountCap;
        require(
            Addresses.length == Amounts.length,
            "Addresses'length with Amounts's length Not Mached!"
        );
        require(
            block.timestamp >= _privateSaleTimePeriod,
            "Time Exception.Nothing to Fund!"
        );
        for (uint256 i = 0; i < Addresses.length; i++) {
            require(
                overAllAmount - Amounts[i] >= 0,
                "Private Sale Amount Reached MaxCap!"
            );
            overAllAmount -= Amounts[i];
            _mint(Addresses[i], Amounts[i]);
            pauseAddress(Addresses[i]);
            _privateSaleAddress[_privatecount] = Addresses[i];
            _privatecount++;
        }
        return true;
    }

    /**
     * @dev mints the amount token to each corresponding address when inside the presale time.
     * requires that sum of Amounts Not exceeds the Max cap of Presale.
     * presale start and end time will be checked in presale contract.
     * @param recipient Token purchaser
     * @param amount Amount of tokens purchased,which calculates in real time inside presale contract
     */
    function transferPresale(address recipient, uint256 amount)
        external
        isPreSaleContract
        returns (bool)
    {
        require(
            _PreSaleAmount - amount >= 0,
            "No more amount allocates for preSale"
        );
        _PreSaleAmount -= amount;
        _mint(recipient, amount);
        pauseAddress(recipient);
        _preSaleAddress[_presaleCount] = recipient;
        _presaleCount++;
        return true;
    }

    /**
     * @dev after presale ends,
     * 1)mints the amount of token to each corresponding address from whitelist.
     * 2)after transfer to the whitelist, it will burn all remaining tokens (if any) after MaxCap of the presale
     */
    function setWhiteList(address[] memory Addresses, uint256[] memory Amounts)
        external
        onlyOwner
        returns (bool)
    {
        require(
            Addresses.length == Amounts.length,
            "Addresses'length with Amounts's length Not Mached!"
        );
        for (uint256 i = 0; i < Addresses.length; i++) {
            whitelisted[Addresses[i]] = (Amounts[i] * 10**18);
            _iswhitelisted[Addresses[i]] = true;
        }
        return true;
    }

    function claimMGU() external payable isPresaleEnded {
        require(_iswhitelisted[msg.sender], "You Are Not in Whitelist");
        require(whitelisted[msg.sender] > 0, "You Claimed before!");
        require(
            _PreSaleAmount - whitelisted[msg.sender] >= 0,
            "No More Token Exists For Claim.Presale Amount Reached MaxCap!"
        );
        _PreSaleAmount -= (whitelisted[msg.sender]);
        _mint(msg.sender, whitelisted[msg.sender]);
        whitelisted[msg.sender] = 0;
    }

    function iswhitelisted(address recipient) external view returns (bool) {
        return _iswhitelisted[recipient];
    }

    function burnRemainingToken() external isPresaleEnded onlyOwner {
        require(
            block.timestamp > _burtAt,
            "Admin:Not Allowed.The time of burning process has not arrived"
        );
        _mint(address(this), _PreSaleAmount);
        _burn(address(this), _PreSaleAmount);
    }

    function unPausePresaleAddress() external isPresaleEnded onlyOwner {
        for (uint256 i = 0; i < _presaleCount; i++) {
            unPauseAddress(_preSaleAddress[i]);
        }
    }

    function unPausePrivateSaleAddress() external onlyOwner {
        require(
            block.timestamp >= _privateSaleTimePeriod,
            "Time Exception.Not Allowed!"
        );
        for (uint256 i = 0; i < _privatecount; i++) {
            unPauseAddress(_privateSaleAddress[i]);
        }
    }

    function setburningDate(uint256 burntime) external onlyOwner {
        _burtAt = burntime;
    }

    function withdraw() external payable onlyOwner {
        (bool os, ) = msg.sender.call{value: address(this).balance}("");
        require(os);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";
import "IERC20Metadata.sol";
import "Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

import "IERC20.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "ERC20.sol";
import "Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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