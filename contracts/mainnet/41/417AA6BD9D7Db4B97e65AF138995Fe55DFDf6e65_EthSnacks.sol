/************************************************************
 *
 * Autor: Zoinks
 *
 * 446576656c6f7065723a20416e746f6e20506f6c656e79616b61 ****/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "./abstract/SnacksBase.sol";

contract EthSnacks is SnacksBase {
    // ================= Library using =================================================================

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ================= Constants =====================================================================

    uint256 public constant SNACKS_MULTIPLIER = 0.00000001 * 10**18; // 18 - decimals()
    uint256 public constant FEE_PULSE = 15;
    uint256 public constant FEE_MASTERCHEF = 20;
    uint256 public constant FEE_SNACKS_STAKING = 15;
    uint256 public constant FEE_BTCETH_SNACK_HOLDERS = 20;
    uint256 public constant FEE_SNACK_HOLDERS = 15;
    uint256 public constant FEE_ZOINKS_STAKING = 0;
    uint256 public constant FEE_SENIORAGE = 15;

    // ================= Attributies/Properties ========================================================

    address public snacks; // Snacks contract address (Snack Holders)

    // ================= Constructors ===================================================================

    constructor(
        IERC20 eth_,
        address pulse_,
        address masterChef_,
        address snacksStakingPool_,
        address seniorageAddress_
    )
        SnacksBase(
            eth_,
            pulse_,
            masterChef_,
            snacksStakingPool_,
            "ETHSNACKS",
            "ETHSNACKS",
            SNACKS_MULTIPLIER,
            seniorageAddress_,
            FEE_PULSE,
            FEE_MASTERCHEF,
            FEE_SNACKS_STAKING,
            FEE_BTCETH_SNACK_HOLDERS,
            FEE_SNACK_HOLDERS,
            FEE_ZOINKS_STAKING,
            FEE_SENIORAGE
        )
    {
        isInitilized = false;
    }

    // ================= Methods: Publics/External ======================================================

    function init(address snacks_) external onlyOwner {
        require(!isInitilized, "ERROR: Contract is already initilized!");
        snacks = snacks_;
        isInitilized = true;
    }

    function _beforeDistributeFee(
        uint256 feeEthSnacks_,
        uint256 totalEthHoldersBalance_
    ) internal override {
        if (feeEthSnacks_ > 0) {
            // % EthSnacks holders
            uint256 feeToHolders = feeEthSnacks_
                .mul(feeBTCETHSnacksHolders)
                .div(100);
            // Calculate and give fee of snacks to every holder
            // Check if we have any holder with balance, if is not correct, we save this fee to next lap
            if (totalEthHoldersBalance_ > 0) {
                for (uint256 i = 0; i < holderList.length; i++) {
                    uint256 holderBalance = balanceOf(holderList[i]);
                    uint256 holderFee = feeToHolders.mul(holderBalance).div(
                        totalEthHoldersBalance_
                    );
                    _selfTokenSnacks.transfer(holderList[i], holderFee);
                }
            }
            // % Snacks holders
            if (feeSnacksHolders > 0) {
                _selfTokenSnacks.transfer(
                    snacks,
                    feeEthSnacks_.mul(feeSnacksHolders).div(100)
                );
            }
        }
    }
}

/************************************************************
 *
 * Autor: Zoinks
 *
 * 446576656c6f7065723a20416e746f6e20506f6c656e79616b61 ****/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "./Ownable.sol";
import "../common/ERC20.sol";
import "../librarys/SafeMath.sol";
import "../librarys/SafeERC20.sol";

// Decimals used = default 18
abstract contract SnacksBase is ERC20, Ownable {
    // ================= Library using =================================================================

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ================= Constants =====================================================================

    uint8 public constant TAX_PERCENT_FOR_BUY = 5;
    uint8 public constant TAX_PERCENT_FOR_REDEEM = 10;
    uint256 public constant ONE_SNACK = 1 * 10**18; // 18 - decimals()

    // ================= Attributies/Properties ========================================================

    IERC20 public immutable payToken; // Zoinks, BTC, ETH
    address public immutable pulse; // Pulse contract address (PULSE)
    address public immutable masterChef; // Master Chef contract address (LP PSC)
    address public immutable snacksStakingPool; // Snacks Staking Pool contract address (Snacks Staking)
    IERC20 internal immutable _selfTokenSnacks;
    uint256 public immutable multiplier; // Price step between Snacks
    bool public isInitilized;

    // Configuration of fee distribution (in %)
    uint256 public immutable feePulse; // PULSE
    uint256 public immutable feeMasterChef; // LP PSC
    uint256 public immutable feeSnacksStakingPool; // Snacks Staking
    uint256 public immutable feeBTCETHSnacksHolders; // BTC/ETH Snacks Holders
    uint256 public immutable feeSnacksHolders; // Snacks Holders
    uint256 public immutable feeZoinksStakingPool; // Zoinks Staking
    uint256 public immutable feeSeniorage; // Seniorage

    // Seniorage address
    address public seniorageAddress;
    // All Snacks holders
    address[] public holderList;
    // Addressed to ignore from holder list, because is used for other reasons and is not real holders
    mapping(address => bool) internal _blockedHolders;

    // ================= Events =========================================================================

    event Buy(
        address buyer,
        uint256 startTotalSupply,
        uint256 snacksRealBuyed,
        uint256 snacksFee,
        uint256 zoinksPayed
    );
    event Redeem(
        address seller,
        uint256 currentTotalSupply,
        uint256 snacksRealReturned,
        uint256 snacksFee,
        uint256 zoinksReturned
    );

    // ================= Constructors ===================================================================

    constructor(
        IERC20 payToken_,
        address pulse_,
        address masterChef_,
        address snacksStakingPool_,
        string memory name_,
        string memory symbol_,
        uint256 multiplier_,
        address seniorageAddress_,
        uint256 feePulse_,
        uint256 feeMasterChef_,
        uint256 feeSnacksStakingPool_,
        uint256 feeBTCETHSnacksHolders_,
        uint256 feeSnacksHolders_,
        uint256 feeZoinksStakingPool_,
        uint256 feeSeniorage_
    ) ERC20(name_, symbol_) {
        payToken = payToken_;
        pulse = pulse_;
        masterChef = masterChef_;
        snacksStakingPool = snacksStakingPool_;
        _selfTokenSnacks = IERC20(this);
        multiplier = multiplier_;
        seniorageAddress = seniorageAddress_;

        // Set fee
        feePulse = feePulse_;
        feeMasterChef = feeMasterChef_;
        feeSnacksStakingPool = feeSnacksStakingPool_;
        feeBTCETHSnacksHolders = feeBTCETHSnacksHolders_;
        feeSnacksHolders = feeSnacksHolders_;
        feeZoinksStakingPool = feeZoinksStakingPool_;
        feeSeniorage = feeSeniorage_;

        // We ignore holders, who is contracts/special address and is not real holder of tokens
        _blockedHolders[address(0)] = true;
        _blockedHolders[address(payToken)] = true;
        _blockedHolders[pulse] = true;
        _blockedHolders[masterChef] = true;

        _blockedHolders[snacksStakingPool] = true;
        _blockedHolders[address(_selfTokenSnacks)] = true;
    }

    // ================= Methods: Publics/External ======================================================

    function numberOfHolders() external view returns (uint256) {
        return holderList.length;
    }

    // Description:
    //  Calculate pending undistributed fee in Snacks.
    // Why?
    //  After every buy or redeem, we increase this value, and every 12/24 hours distribute this amount.
    //  In both cases 5% fee buy, 10% fee redeem is same logic by fee distribute configuration.
    function undistributedFeeSnacks() public view returns (uint256) {
        return balanceOf(address(this));
    }

    // Description:
    //  Calculate how many Zoinks we need to pay, for this amount of Snacks
    //  Formula: S m,n = (Am + An) / 2 * (m - n + 1) * d
    // Where:
    //  const d = multiplier; example = 0.000001
    //  An = Start SnackN (Last snack in moment of buy)
    //  Am = End SnackM (Last snack + amount to mint in moment of buy)
    function calculateRedeemAmount(
        uint256 currentTotalSupply,
        uint256 amountSnacksToBurn
    ) public view returns (uint256) {
        uint256 start = currentTotalSupply;
        uint256 end = currentTotalSupply - amountSnacksToBurn + ONE_SNACK;
        uint256 snacksValue = amountSnacksToBurn.mul(start + end).div(2);
        uint256 zoinksToReturn = _unDecimals(snacksValue.mul(multiplier), 2);
        return zoinksToReturn;
    }

    // Description:
    //  Calculate how many Zoinks you need to pay, for mint x amount new Snacks
    //  Formula: S m,n = (Am + An) / 2 * (m - n + 1) * d
    // Where:
    //  const d = multiplier; example = 0.000001
    //  An = Start SnackN (Last snack in moment of buy)
    //  Am = End SnackM (Last snack + amount to mint in moment of buy)
    function calculateBuyAmount(
        uint256 currentTotalSupply,
        uint256 amountSnacksToMint
    ) public view returns (uint256) {
        // amount to mint/buy = amountSnacksToMint
        // price increment (d) = MULTIPLIER
        // current last (n)
        uint256 nextFirstSnack = currentTotalSupply + ONE_SNACK;
        // new last (m)
        uint256 newLastSnack = currentTotalSupply + amountSnacksToMint;
        // zoinks to pay
        uint256 snacksValue = (newLastSnack + nextFirstSnack)
            .mul(newLastSnack - nextFirstSnack + ONE_SNACK)
            .div(2);
        uint256 zoinksToPay = _unDecimals(snacksValue.mul(multiplier), 2);
        return zoinksToPay;
    }

    // Description:
    //  This function not sell snacks from any depostit. It mint all necesary snacks at time, when it needed.
    //  To pay with Zoinks for this new Snacks we use special formula: S m,n = (Am + An) / 2 * (m - n + 1) * d
    // Where:
    //  const d = multiplier; example = 0.000001
    //  An = SnackN (Last snack in moment of buy)
    //  Am = SnackM (Last snack + amount to mint in moment of buy)
    function buy(uint256 amountSnacksToMint) external {
        // Step 0: Check input data
        require(amountSnacksToMint > 0, "ERROR: amount Snacks to buy is zero");
        // Step 1: Calculate how many zoinks we need to pay, for this snacks
        uint256 zoinksAmountToPay = calculateBuyAmount(
            totalSupply(),
            amountSnacksToMint
        );
        // Step 2: Check if user has this amount of Zoinks to pay this Snacks
        require(
            payToken.balanceOf(msg.sender) >= zoinksAmountToPay,
            "ERROR: need many Zoinks to pay Snacks"
        );
        // Step 3: Transfer Zoinks from user to this contract
        payToken.safeTransferFrom(msg.sender, address(this), zoinksAmountToPay); // In this point we have Zoinks in our contract
        // Step 4: Calculate how Snacks we need to transfer to user (buy - taxFee)
        uint256 snacksFeeAmount = amountSnacksToMint
            .mul(TAX_PERCENT_FOR_BUY)
            .div(100);
        // Step 5: We mint new Snacks to distribute in future
        _mint(address(this), snacksFeeAmount);
        // Step 6: We mint new Snacks to buyer
        _mint(address(msg.sender), amountSnacksToMint - snacksFeeAmount);
        // Step 7: We inform about we buy and how many Snacks
        emit Buy(
            msg.sender,
            totalSupply() - amountSnacksToMint,
            amountSnacksToMint,
            snacksFeeAmount,
            zoinksAmountToPay
        );
    }

    // Description:
    //  This function not move snacks to any depostit. It burn all returned snacks at time, when it needed.
    //  To pay with Zoinks for returned Snacks we use special formula: S m,n = (Am + An) / 2 * (m - n + 1) * d
    // Where:
    //  const d = multiplier; example = 0.000001
    //  An = SnackN (Last snack in moment of buy)
    //  Am = SnackM (Last snack + amount to mint in moment of buy)
    function redeem(uint256 amountSnacksToBurn) external {
        // Step 0: Check input data
        require(
            amountSnacksToBurn > 0,
            "ERROR: amount Snacks to redeem is zero"
        );
        require(
            balanceOf(msg.sender) >= amountSnacksToBurn,
            "ERROR: amount exceeds your Snacks"
        );
        // Step 1: Calculate how many Snacks we need to get like fee for redeem
        uint256 snacksFeeAmount = amountSnacksToBurn
            .mul(TAX_PERCENT_FOR_REDEEM)
            .div(100);
        // Step 2: Move Snacks fee to contract like undistributed fee
        transfer(address(this), snacksFeeAmount);
        // Step 3: Calculate how many Zoinks we need to return, for this returned Snacks
        uint256 zoinksAmountToReturn = calculateRedeemAmount(
            totalSupply(),
            amountSnacksToBurn - snacksFeeAmount
        );
        // Step 4: Check if contract has this amount of Zoinks to buy back this Snacks
        require(
            payToken.balanceOf(address(this)) >= zoinksAmountToReturn,
            "ERROR: not Zoinks funds to buy back Snacks"
        );
        // Step 5: Transfer Zoinks from this contract to user
        payToken.safeTransfer(msg.sender, zoinksAmountToReturn); // In this point we have Zoinks in our contract
        // Step 6: We burn returned Snacks
        _burn(msg.sender, amountSnacksToBurn - snacksFeeAmount);
        // Step 7: We inform about we redeem and how many Snacks
        emit Redeem(
            msg.sender,
            totalSupply(),
            amountSnacksToBurn,
            snacksFeeAmount,
            zoinksAmountToReturn
        );
    }

    function _beforeDistributeFee(
        uint256 feeSnacks_,
        uint256 totalHoldersBalance_
    ) internal virtual {}

    // Description:
    //  Distribute all fee pending by configuated options
    function distributeFee() external onlyOwner {
        require(isInitilized, "ERROR: Contract is not initilized!");
        uint256 totalHoldersBalance = _getTotalHoldersBalance();
        uint256 feeSnacks = undistributedFeeSnacks();
        // Pre distribution
        _beforeDistributeFee(feeSnacks, totalHoldersBalance);
        // STEP 1: Distribute fee of Snacks
        if (feeSnacks > 0) {
            // % PULSE
            if (feePulse > 0) {
                _selfTokenSnacks.transfer(
                    pulse,
                    feeSnacks.mul(feePulse).div(100)
                );
            }
            // % LP PCS
            if (feeMasterChef > 0) {
                _selfTokenSnacks.transfer(
                    masterChef,
                    feeSnacks.mul(feeMasterChef).div(100)
                );
            }
            // % Snacks staking pool
            if (feeSnacksStakingPool > 0) {
                _selfTokenSnacks.transfer(
                    snacksStakingPool,
                    feeSnacks.mul(feeSnacksStakingPool).div(100)
                );
            }
            // Rest of % (5% Snacks, 15% BTC/ETH Snacks). Is not exactly %, wee need to use rest of Snacks
            if (feeSeniorage > 0) {
                uint256 feeSnacksSeniorage = undistributedFeeSnacks();
                _selfTokenSnacks.transfer(seniorageAddress, feeSnacksSeniorage);
            }
        }
        // Aditional distributions
        _afterDistributeFee(totalHoldersBalance);
    }

    function _afterDistributeFee(uint256 totalHoldersBalance_)
        internal
        virtual
    {}

    // Description:
    //  Set seniorage address by owner
    function setSeniorage(address seniorage) public onlyOwner {
        seniorageAddress = seniorage;
    }

    // ================= Methods: Private/Internal ======================================================

    // Description:
    //  With this function, after Snacks is transfer, we review holder list to remove 0 balance holders,
    //  and add new holders with new balance
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        // Step 0: Check if amount is to change anything. If is 0, we don't change any list of holders,
        // because really we don't have any change in amounts
        if (amount > 0) {
            // Step 1: Check from account (not accept mint case)
            if (from != address(0) && balanceOf(from) == 0) {
                // This address not has any balance
                _removeHolder(from);
            }
            // Step 2: Check to account
            if (to != address(0) && !_isExist(to)) {
                // Is not burn case. Add holder to list
                _addHolder(to);
            }
        }
    }

    // Description:
    //  Check if holder exist in the list
    function _isExist(address holder_) private view returns (bool) {
        bool result = false;
        for (uint256 i; i < holderList.length; i++) {
            if (holderList[i] == holder_) {
                result = true;
                break;
            }
        }
        return result;
    }

    // Description:
    //  Add new holder to list
    function _addHolder(address holder_) private {
        // Check if holder is allowed
        if (_blockedHolders[holder_] == false) {
            holderList.push(holder_);
        }
    }

    // Description:
    //  Remove one holder from list
    function _removeHolder(address holder_) private {
        for (uint256 i; i < holderList.length; i++) {
            if (holderList[i] == holder_) {
                holderList[i] = holderList[holderList.length - 1];
                holderList.pop();
                break;
            }
        }
    }

    // Description:
    //  Get balance of all holders
    function _getTotalHoldersBalance() private view returns (uint256) {
        uint256 total = 0;
        for (uint32 i = 0; i < holderList.length; i++) {
            total += balanceOf(holderList[i]);
        }
        return total;
    }

    // Description:
    //  Get value without decimals (varios levels of decimals)
    function _unDecimals(uint256 value, uint256 level)
        private
        view
        returns (uint256)
    {
        uint256 result = value;
        for (uint256 i = 0; i < level; i++) {
            result = result.div(10**decimals());
        }
        return result;
    }
}

/************************************************************
 *
 * Autor: Zoinks
 *
 * 446576656c6f7065723a20416e746f6e20506f6c656e79616b61 ****/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "./Context.sol";

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
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
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "../abstract/Context.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IERC20Metadata.sol";

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

/************************************************************
 *
 * Autor: Zoinks
 *
 * 446576656c6f7065723a20416e746f6e20506f6c656e79616b61 ****/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

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
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

/************************************************************
 *
 * Autor: Zoinks
 *
 * 446576656c6f7065723a20416e746f6e20506f6c656e79616b61 ****/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "./Address.sol";
import "../interfaces/IERC20.sol";

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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

/************************************************************
 *
 * Autor: Zoinks
 *
 * 446576656c6f7065723a20416e746f6e20506f6c656e79616b61 ****/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/************************************************************
 *
 * Autor: Zoinks
 *
 * 446576656c6f7065723a20416e746f6e20506f6c656e79616b61 ****/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

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

/************************************************************
 *
 * Autor: Zoinks
 *
 * 446576656c6f7065723a20416e746f6e20506f6c656e79616b61 ****/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "./IERC20.sol";

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

/************************************************************
 *
 * Autor: Zoinks
 *
 * 446576656c6f7065723a20416e746f6e20506f6c656e79616b61 ****/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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