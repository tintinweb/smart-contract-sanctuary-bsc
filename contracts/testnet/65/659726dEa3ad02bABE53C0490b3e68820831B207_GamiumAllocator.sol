// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GamiumToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20Contract {
  function mint(address _to, uint256 _amount) external;
}

contract GamiumAllocator  is Ownable {
    event ERC20Released(string category, address to, uint256 amount);
    
    // total distributed
    uint public totalMinted;

    // token contract
    address public tokenContract;

    // Distribution structure
    struct Distribution {
        address  _beneficiary;
        uint _tgeAmount;
        uint _linearAmount;
        uint64 _start;
        uint64 _duration;
    }

    // UNIX dates
    uint64 private constant _TGE = 1_648_641_600; // TGE = Wed Mar 30 2022 12:00:00 GMT+0000
    uint64 private constant _Month1 = 1_651_320_000; // Month 1 = Sat Apr 30 2022 12:00:00 GMT+0000
    uint64 private constant _Month3 = 1_656_590_400; // Month 3 = Thu Jun 30 2022 12:00:00 GMT+0000
    uint64 private constant _Month6 = 1_664_539_200; // Month 6 = Fri Sep 30 2022 12:00:00 GMT+0000

    // durations
    uint64 private constant _0_months = 0; // 0 months
    uint64 private constant _6_months = 15_780_000; // 6 months
    uint64 private constant _12_months = 31_560_000; // 12 months
    uint64 private constant _24_months = 63_120_000; // 24 months

    // addresses
    address public constant airdropAddress = 0x1c8D49c8E65fB894aC061801CBE1360A81c45213;
    address public constant earlyAdoptersAddress = 0x1c8D49c8E65fB894aC061801CBE1360A81c45213;
    address public constant privateAddress = 0x1c8D49c8E65fB894aC061801CBE1360A81c45213;
    address public constant publicAddress = 0x1c8D49c8E65fB894aC061801CBE1360A81c45213;
    address public constant communityAddress = 0x1c8D49c8E65fB894aC061801CBE1360A81c45213;
    address public constant advisorsAddress = 0x1c8D49c8E65fB894aC061801CBE1360A81c45213;
    address public constant stakingAddress = 0x1c8D49c8E65fB894aC061801CBE1360A81c45213;
    address public constant liquidityAddress = 0x1c8D49c8E65fB894aC061801CBE1360A81c45213;
    address public constant treasuryAddress = 0x1c8D49c8E65fB894aC061801CBE1360A81c45213;
    address public constant marketingAddress = 0x1c8D49c8E65fB894aC061801CBE1360A81c45213;
    address public constant teamAddress = 0x1c8D49c8E65fB894aC061801CBE1360A81c45213;
    address public constant exchangesReserveAddress = 0x1c8D49c8E65fB894aC061801CBE1360A81c45213;

    // decimal base
    uint private constant decimalBase = 1e18;

    // tge distribution values
    uint private constant airdropTGEValue = 0 * decimalBase;
    uint private constant earlyAdoptersTGEValue = 50_000_000 * decimalBase;
    uint private constant privateTGEValue = 750_000_000 * decimalBase;
    // Unlock all TGE, because launchpads distribute them for their users following vesting
    uint private constant publicTGEValue = 1_500_000_000 * decimalBase;
    uint private constant communityTGEValue = 200_000_000 * decimalBase;
    uint private constant advisorsTGEValue = 0 * decimalBase; 
    uint private constant stakingTGEValue = 0 * decimalBase; 
    uint private constant liquidityTGEValue = 500_000_000 * decimalBase;
    uint private constant treasuryTGEValue = 250_000_000 * decimalBase; 
    uint private constant marketingTGEValue = 180_000_000 * decimalBase;
    uint private constant teamTGEValue = 0 * decimalBase;
    uint private constant exchangesTGEValue = 1_500_000_000 * decimalBase;

    // linear distribution values
    uint private constant airdropLinearValue = 500_000_000 * decimalBase; // 500M (TOTAL)
    uint private constant earlyAdoptersLinearValue = 450_000_000 * decimalBase; // 500M (TOTAL)
    uint private constant privateLinearValue = 6_750_000_000 * decimalBase; // 7500M (TOTAL)
    uint private constant publicLinearValue = 0 * decimalBase; // 1500M (TOTAL)
    uint private constant communityLinearValue = 800_000_000 * decimalBase; // 1000M (TOTAL)
    uint private constant advisorsLinearValue = 3_000_000_000 * decimalBase; // 3000M (TOTAL)
    uint private constant stakingLinearValue = 3_500_000_000 * decimalBase; // 2500M (TOTAL)
    uint private constant liquidityLinearValue = 0 * decimalBase; // 0
    uint private constant treasuryLinearValue = 12_250_000_000 * decimalBase; // 12500M (TOTAL) - 2% TGE
    uint private constant marketingLinearValue = 8_820_000_000 * decimalBase; // 9000M (TOTAL) - 2% TGE
    uint private constant teamLinearValue = 9_000_000_000 * decimalBase; // 9000M (TOTAL) 
    uint private constant exchangesLinearValue = 0 * decimalBase; // 0

    // creating linear distributions config
    Distribution private _airdrop = Distribution(airdropAddress, airdropTGEValue, airdropLinearValue, _Month1, _0_months);
    Distribution private _earlyAdopters = Distribution(earlyAdoptersAddress, earlyAdoptersTGEValue, earlyAdoptersLinearValue, _Month3, _24_months);
    Distribution private _private = Distribution(privateAddress, privateTGEValue, privateLinearValue, _Month3, _24_months);
    Distribution private _public = Distribution(publicAddress, publicTGEValue, publicLinearValue, _TGE, _0_months);
    Distribution private _community = Distribution(communityAddress, communityTGEValue, communityLinearValue, _Month3, _12_months);
    Distribution private _advisors = Distribution(advisorsAddress, advisorsTGEValue, advisorsLinearValue, _Month6, _24_months);
    Distribution private _staking = Distribution(stakingAddress, stakingTGEValue, stakingLinearValue, _Month3, _24_months);
    Distribution private _liquidity = Distribution(liquidityAddress, liquidityTGEValue, liquidityLinearValue, _TGE, _0_months);
    Distribution private _treasury = Distribution(treasuryAddress, treasuryTGEValue, treasuryLinearValue, _TGE, _24_months);
    Distribution private _marketing = Distribution(marketingAddress, marketingTGEValue, marketingLinearValue, _TGE, _24_months);
    Distribution private _team = Distribution(teamAddress, teamTGEValue, teamLinearValue, _Month6, _24_months);
    Distribution private _exchanges = Distribution(exchangesReserveAddress, exchangesTGEValue, exchangesLinearValue, _TGE, _0_months);

    // categories of tokenomics
    string[12] private categories = ["Airdrop", "Seed", "Private", "Public", "Community", "Advisors", "Staking", "Liquidity", "Treasury", "Marketing", "Team", "Exchanges"];
    
    // Distributions mapping depending on the category
    mapping(string => uint) public GMMReleased;
    mapping(string => uint8) private _categoriesMap;
    mapping(string => bool) private _categoryExist;

    // Distributions array
    Distribution[12] private _distributions;

    constructor(address _tokenContract) {
        tokenContract = _tokenContract;
        _setDefaultValues();
    }

    /**
     * @dev Set up arrays and mappings.
     */
    function _setDefaultValues() private {
        _distributions[0] = _airdrop;
        _distributions[1] = _earlyAdopters;
        _distributions[2] = _private;
        _distributions[3] = _public;
        _distributions[4] = _community;
        _distributions[5] = _advisors;
        _distributions[6] = _staking;
        _distributions[7] = _liquidity;
        _distributions[8] = _treasury;
        _distributions[9] = _marketing;
        _distributions[10] = _team;
        _distributions[11] = _exchanges;
        
        _categoriesMap["Airdrop"] = 0;
        _categoriesMap["Seed"] = 1;
        _categoriesMap["Private"] = 2;
        _categoriesMap["Public"] = 3;
        _categoriesMap["Community"] = 4;
        _categoriesMap["Advisors"] = 5;
        _categoriesMap["Staking"] = 6;
        _categoriesMap["Liquidity"] = 7;
        _categoriesMap["Treasury"] = 8;
        _categoriesMap["Marketing"] = 9;
        _categoriesMap["Team"] = 10;
        _categoriesMap["Exchanges"] = 11;
        
        _categoryExist["Airdrop"] = true;
        _categoryExist["Seed"] = true;
        _categoryExist["Private"] = true;
        _categoryExist["Public"] = true;
        _categoryExist["Community"] = true;
        _categoryExist["Advisors"] = true;
        _categoryExist["Staking"] = true;
        _categoryExist["Liquidity"] = true;
        _categoryExist["Treasury"] = true;
        _categoryExist["Marketing"] = true;
        _categoryExist["Team"] = true;
        _categoryExist["Exchanges"] = true;
    }

    /**
     * @dev Mint tokenContract tokens.
     *
     * Emits a {ERC20Released} event.
     */
     function mintTokens(address beneficiary, uint256 releasable, string memory category) private {
        if (releasable > 0) {
            IERC20Contract gmmContract = IERC20Contract(tokenContract);

            GMMReleased[category] += releasable;
            totalMinted += releasable;
            gmmContract.mint(beneficiary, releasable);
            emit ERC20Released(category, beneficiary, releasable);
        }
     }

    /**
     * @dev Release the tokens used for liquidity and exchanges reserve.
     *
     * Emits a {ERC20Released} event.
     */
    function unlockLiquidity() external onlyOwner {
        uint256 releasableLiquidity = categoryReleasable("Liquidity");
        mintTokens(liquidityAddress, releasableLiquidity, "Liquidity");

        uint256 releasableExchanges = categoryReleasable("Exchanges");
        mintTokens(exchangesReserveAddress, releasableExchanges, "Exchanges");

        uint256 releasablePublic = categoryReleasable("Public");
        mintTokens(publicAddress, releasablePublic, "Public");
    }

    /**
     * @dev Release all the tokens that are releasable.
     *
     * Emits a {ERC20Released} event.
     */
    function releaseTokens() external virtual {
        require(_TGE < uint64(block.timestamp), "TGE event did not start yet");

        for (uint i = 0; i < categories.length; i++) {
            address beneficiary = _distributions[i]._beneficiary;
            uint256 releasable = categoryReleasable(categories[i]);

            mintTokens(beneficiary, releasable, categories[i]);
        }
    }

    function totalTokens() public view virtual returns (uint) {
        uint total = 0;
        for (uint i = 0; i < categories.length; i++) {

            uint tgeAmount = _distributions[i]._tgeAmount;
            uint linearAmount = _distributions[i]._linearAmount;

            total += (tgeAmount + linearAmount);
        }
        return total;
    }
    
    /**
     * @dev Calculates the amount of tokens that are releasable for certain category.
     */
    function categoryReleasable(string memory _category) public view virtual returns (uint256) {
        require(_categoryExist[_category], "Category does not exist");
        uint8 i = _categoriesMap[_category];
        
        uint tgeAmount = _distributions[i]._tgeAmount;
        uint linearAmount = _distributions[i]._linearAmount;
        uint64 start = _distributions[i]._start;
        uint64 duration = _distributions[i]._duration;
        
        uint256 vestingReleasable = _vestingSchedule(start, duration, linearAmount, uint64(block.timestamp));
        uint256 releasable = vestingReleasable + tgeAmount - GMMReleased[_category];
        return releasable;
    }

    /**
     * @dev Virtual implementation of the vesting formula. This returns the amout vested, as a function of time, for
     * an asset given its total historical allocation.
       check https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/finance/VestingWallet.sol
     */
    function _vestingSchedule(uint64 start, uint64 duration, uint linearAllocation, uint64 timestamp) internal view virtual returns (uint256) {
        if (timestamp < start) {
            return 0;
        } else if (timestamp > start + duration) {
            return linearAllocation;
        } else {
            return (linearAllocation * (timestamp - start)) / duration;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface _AntiBotContract {
    function applyAntiBot(address sender, address recipient, uint256 amount) external;
}

contract GamiumToken is ERC20Capped, Ownable, Pausable {
    // Antibot object
    _AntiBotContract antiBotContract;
    bool public antiBotEnabled;

    // minter address
    address public minter;

    // events
    event TokensMinted(address _to, uint256 _amount);
    event LogNewMinter(address _minter);

    // max total Supply to be minted
    uint256 private _capToken = 50 * 10 ** 9 * 1e18;

    constructor() ERC20("Gamium", "GMM") ERC20Capped(_capToken) {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Throws if called by any account other than the minter.
     */
    modifier onlyMinter() {
        require(_msgSender() != address(0), "GamiumToken: minting from the zero address");
        require(_msgSender() == minter, "GamiumToken: Caller is not the minter");
        _;
    }
    
    /**
     * @param newMinter The address of the new minter.
     */
    function setMinter(address newMinter) external onlyOwner {
        require(newMinter != address(0), "GamiumToken: Cannot set zero address as minter.");
        minter = newMinter;
        emit LogNewMinter(minter);
    }
    
    /**
     * @dev minting function.
     *
     * Emits a {TokensMinted} event.
     */
    function mint(address to, uint256 amount) external onlyMinter {
        super._mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /**
     * @param status The status of the antibot.
     */
    function setAntiBot(bool status) external onlyOwner {
        antiBotEnabled = status;
    }

    /**
     * @param antiBotAddress The address of the antibot.
     */
    function setAntiBotAddress(address antiBotAddress) external onlyOwner {
        antiBotContract = _AntiBotContract(antiBotAddress);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        if (antiBotEnabled) {
            // call antibot contract
            antiBotContract.applyAntiBot(from, to, amount);
        }
        super._beforeTokenTransfer(from, to, amount);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Capped.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
abstract contract ERC20Capped is ERC20 {
    uint256 private immutable _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor(uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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