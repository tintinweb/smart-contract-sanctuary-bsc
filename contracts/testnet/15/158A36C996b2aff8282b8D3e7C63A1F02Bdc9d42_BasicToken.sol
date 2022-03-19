// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

// Solidity version we chose is 0.8.4, its not too new and not too old.
// https://ethereum.stackexchange.com/questions/115382/rules-on-choosing-a-solidity-version/115407

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


interface IPancakeRouter {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakePair {

}

contract BasicToken is ERC20, ERC20Burnable, Pausable, Ownable, ReentrancyGuard {

    uint256 private constant MAX_NR_FEE_RECIPIENTS = 10;
    uint256 private constant MAX_BASIS_POINTS = 10000;

    // A struct to hold data per fee recipient. A fee recipient is a wallet address that is
    // entitled to receive a fee for each transaction that occurs with this token.
    // The fee is expressed in basis points, which is 1/10000.
    // See https://www.investopedia.com/terms/b/basispoint.asp
    struct FeeRecipient {
        uint16 basispoints; // Should be a maximum of 10000, therefore uint16 suffices.this
        bool exists;        // Must always be true so we can test for the recipient to exist
        bool swap;          // Set to true if the user will receive fees in BNB
        uint256 amountToSwapDeposit;    // fee balance collected for the recipient and not yet swapped to BNB and paid
    }

    // Mapping and array with feeRecipients. Note that the mapping and array must be kept in sync.
    // We need both the mapping and the array to be able to add / update / delete fee recipients
    // and loop through them.
    mapping(address => FeeRecipient) public feeRecipients;

    // Array of feeRecipientAddresses so we can loop through them, that is not possible with the feeRecipients mapping
    address[] public feeRecipientAddresses;

    // Mapping of nonFeePayers. We don't need to loop through them, therefore we don't need an array.
    mapping(address => bool) public nonFeePayers;

    uint16 public burnFee;              // Burn fee in basis points

    uint16 public liquidityFee;         // Liquidity fee in basis points

    uint256 public minLPDeposit;        // Minimum amount (threshold) to do addLiquidity to liquidityPool

    // The amount of tokens withhold by the contract that must be added to the liquidityPool (when higher than or equals to minLPDeposit)
    uint256 public liquidityFeeDeposit;

    uint256 public minSwappedDeposit;   // Minimum amount (threshold) to pay back fees after being swapped

    IPancakeRouter public pancakeRouter;// The pancakeRouter uses to swap token <-> BNB
    IPancakePair public pancakePair;    // The pancakePair for token <-> BNB

    uint256 public mintedAmount;        // Amount minted when initializing the contract

    bool noFeesApplied;

    // Does owner pay fees?
    bool public ownerPaysFees = true;

    // Maximum value for a transaction;
    // if higher, the transaction is reverted
    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;

    event SetBurnFee(uint16 oldFee, uint16 newFee);
    event SetLiquidityFee(uint16 oldFee, uint16 newFee);
    event SetMinLPDeposit(uint256 minLPDeposit, uint256 newMinLpDeposit);
    event SetMinSwappedDeposit(uint256 minSwappedDeposit, uint256 newMinSwappedDeposit);
    event AddFeeRecipient(address recipient, uint16 basisPoints, bool swap);
    event UpdateFeeRecipient(address recipient, uint16 basisPoints, bool swap);
    event SetMaxBuyAmount(uint256 oldFee, uint256 newFee);
    event SetMaxSellAmount(uint256 oldFee, uint256 newFee);
    event RemoveFeeRecipient(address recipient);
    event AddNonFeePayer(address recipient);
    event RemoveNonFeePayer(address recipient);
    event PayFeesInBnb(address recipient, uint256 bnbAmount);

    // Initialize token with _name and _symbol, and mint _amount tokens to caller address
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 mintAmount,
        address controller,
        uint16 burnFee_,
        uint16 liquidityFee_,
        uint256 minLPDeposit_,
        address pancakeRouter_
    ) ERC20(name_, symbol_) {
        // Execute the initializers of the parent contracts
        // ERC20(name_, symbol_);
        // __ERC20Burnable_init();
        // __Pausable_init();
        // __Ownable_init();

        // Mint an initial amount of tokens to the controller account
        _mint(controller, mintAmount);

        // Store the amount minted, to be used in tracking burned amount
        mintedAmount = mintAmount;

        // Immediately transfer the ownership to the "controller"
        transferOwnership(controller);

        // Initialize state variables explicitly
        burnFee = burnFee_;
        liquidityFee = liquidityFee_;
        minLPDeposit = minLPDeposit_;
        minSwappedDeposit = 0;
        maxBuyAmount = 0;
        maxSellAmount = 0;

        // Create the pancake pair and write the address into the immutable contract variable
        // The pair created is between this token and the Wrapped Native token (wBnb really) in Pancake
        pancakeRouter = IPancakeRouter(pancakeRouter_);
        pancakePair = IPancakePair(IPancakeFactory(pancakeRouter.factory()).createPair(address(this), pancakeRouter.WETH()));
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    )
    internal override
    whenNotPaused
    {




        
        // Check first if the sender or recipients is excluded from paying fees
        // Also do not charge fees if pancakePair is transfering an amount
        uint256 amountRemaining = amount;

        // Buy transaction
        if (maxBuyAmount > 0 && sender == address(pancakePair)) {
            require(amount <= maxBuyAmount, "maxBuyAmount Limit Exceeded");
        // Sell transaction
        } else if (maxSellAmount > 0 && recipient == address(pancakePair)) {
            require(amount <= maxSellAmount, "maxSellAmount Limit Exceeded");
        }

        if (
            !nonFeePayers[sender]               // is sender not on the nonFeePayers?
            && !nonFeePayers[recipient]         // is recipient not on the nonFeePayers?
            // Is sender or recipient the owner?
            && (ownerPaysFees || (sender != owner() && recipient != owner()))
            && !noFeesApplied      // do not charge fees when we are in the middle of adding liquidity (reentrant)
        ) {


            // Send fees to feeRecipients
            uint256 fee;
            for (uint8 i = 0; i < feeRecipientAddresses.length; i++) {// Note uint8: we only support 256 feeRecipients

                address feeRecipientAddress = feeRecipientAddresses[i];

                FeeRecipient memory feeRecipient = feeRecipients[feeRecipientAddress];
                // Note, it is possible that there is an empty entry in feeRecipientAddresses after a feeRecipient is removed.
                // Therefore we need to check that feeRecipient.exists. Empty entries will have been cleared and therefore
                // feeRecipient.exists will return false in that case.
                if (feeRecipient.exists) {
                    fee = (amount * feeRecipient.basispoints) / MAX_BASIS_POINTS;
                    if (fee > 0 && fee <= amountRemaining) {
                        amountRemaining = amountRemaining - fee;
                        // Pay fees in BNB; same logic as the block above, but 
                        // happens after the token transfer is made
                        if (feeRecipient.swap) {
                            feeRecipient.amountToSwapDeposit = fee + feeRecipient.amountToSwapDeposit;
                            feeRecipients[feeRecipientAddress] = feeRecipient;                            
                            feeRecipientAddress = address(this);
                        }

                        super._transfer(sender, feeRecipientAddress, fee);

                    }
                }
            }
            // Burn fees
            if (burnFee > 0) {
                fee = (amount * burnFee) / MAX_BASIS_POINTS;
                if (fee > 0 && fee <= amountRemaining) {

                    _burn(sender, fee);

                    amountRemaining -= fee;
                }
            }
            if (liquidityFee > 0) {
                fee = (amount * liquidityFee) / MAX_BASIS_POINTS;
                if (fee > 0 && fee <= amountRemaining) {

                    super._transfer(sender, address(this), fee);

                    // Send the fee to this contract
                    amountRemaining -= fee;
                    liquidityFeeDeposit += fee;
                }
                if (
                    liquidityFeeDeposit >= minLPDeposit    // enough tokens to start adding liquidity
                ) {                    
                    if (sender != address(pancakePair)) {

                        addLiquidity(liquidityFeeDeposit);

                    }
                }
            }
        }
        super._transfer(sender, recipient, amountRemaining);

    }

    // Swaps 50% of an amount of tokens to BNB, then deposits
    // the tokens and BNB in the pancakeswap pool
    function addLiquidity(uint256 amount) private doNotApplyFees {

        // swap 50% of the amount to bnb
        uint256 half = amount / 2;

        uint256 bnbAmount = swapToBNB(half);

        if (bnbAmount > 0) {

            // add liquidity
            require(this.approve(address(pancakeRouter), (amount - half)), "Approval 1 failed");

            pancakeRouter.addLiquidityETH{value: bnbAmount}(
                address(this), // Token
                    (amount - half), // amountTokenDesired
                    0, // amountTokenMin
                    0, // amountETHMin
                    owner(), // to
                block.timestamp  // deadline
            );

            liquidityFeeDeposit = 0;

        }
    }

    function payFeesInBnb() external onlyOwner doNotApplyFees nonReentrant {
        for (uint8 i = 0; i < feeRecipientAddresses.length; i++) {
            address feeRecipientAddress = feeRecipientAddresses[i];
            FeeRecipient memory feeRecipient = feeRecipients[feeRecipientAddress];
            if (feeRecipient.amountToSwapDeposit > minSwappedDeposit) {
                uint256 bnbAmount = swapToBNB(feeRecipient.amountToSwapDeposit);
                if (bnbAmount > 0) {
                    (bool ret,) = payable(feeRecipientAddress).call{value: bnbAmount}("");
                    require(ret, "Payment failed");
                    feeRecipient.amountToSwapDeposit = 0;

                    emit PayFeesInBnb(feeRecipientAddress, bnbAmount);
                }
            }
        }
    }

    modifier doNotApplyFees {
        noFeesApplied = true;
        _;
        noFeesApplied = false;
    }

    // Receive BNB. Needed for pancake router to send us BNB when we swapToBNB
    receive() external payable {
    }

    // Swaps an amount of this token to BNB using pancake swap
    function swapToBNB(uint256 amount) private returns (uint256 bnbAmount)  {
        // Approve spending the tokens
        require(this.approve(address(pancakeRouter), amount), "Approval 2 failed");
        // Create the path variable that the pancake router requires
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        // Preflight swap, check if the swap is expected to return more than 0 BNB
        uint[] memory amounts = pancakeRouter.getAmountsOut(amount, path);

        if (amounts[1] > 0) {
            // Determine BNB openingBalance before the swap
            uint256 openingBalance = address(this).balance;
            // Execute the swap
            pancakeRouter.swapExactTokensForETH(
            // pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amount, 0, path, address(this), block.timestamp
            );
            // Return the amount of BNB received
            return (address(this).balance - openingBalance);
        } else {
            return 0;
        }
    }

    // Add a new fee recipient with a fee of basisPoints
    function addFeeRecipient(address recipient, uint16 basisPoints, bool swap) external onlyOwner {
        require(recipient != address(0), "Recipient cannot be 0");
        require(!feeRecipients[recipient].exists, "Recipient already exists");
        require(basisPoints != 0, "Basispoints cannot be 0");
        require(basisPoints <= MAX_BASIS_POINTS, "Basispoints cannot be greater than 10000");
        // Note: feeRecipientAddresses.length must be < than MAX_NR_FEE_RECIPIENTS ( not <= )
        // So that after pushing another feeRecipient we have at most MAX_NR_FEE_RECIPIENTS
        require(feeRecipientAddresses.length < MAX_NR_FEE_RECIPIENTS, "Max number of recipients reached");

        // Check if the total fees across all recipients is higher than 100%
        uint256 totalFees = basisPoints + burnFee + liquidityFee;
        for (uint8 i = 0; i < feeRecipientAddresses.length; i++) {
            address feeRecipientAddress = feeRecipientAddresses[i];
            FeeRecipient memory feeRecipient = feeRecipients[feeRecipientAddress];
            totalFees += feeRecipient.basispoints;

        }
        require(totalFees <= 10000, "Reached 100% of fees!");

        feeRecipients[recipient] = FeeRecipient(basisPoints, true, swap, 0);   // Note that 'exists' must always be true
        feeRecipientAddresses.push(recipient);
        emit AddFeeRecipient(recipient, basisPoints, swap);
    }

    // Updates an existing fee recipient with a fee of basisPoints
    function updateFeeRecipient(address recipient, uint16 basisPoints, bool swap) external onlyOwner {
        require(recipient != address(0), "Recipient cannot be 0");
        require(feeRecipients[recipient].exists, "Recipient does not exist");
        require(basisPoints != 0, "Basispoints cannot be 0");
        require(basisPoints <= 10000, "Basispoints cannot be greater than 10000");
        feeRecipients[recipient].basispoints = basisPoints;
        feeRecipients[recipient].swap = swap;
        emit UpdateFeeRecipient(recipient, basisPoints, swap);
    }

    // Remove an existing fee recipient
    function removeFeeRecipient(address recipient) external onlyOwner {
        require(recipient != address(0), "Recipient cannot be 0");
        require(feeRecipients[recipient].exists, "Recipient does not exist");

        // Remove the recipient from the mapping
        delete feeRecipients[recipient];
        emit RemoveFeeRecipient(recipient);

        // Loop the array of addresses so we can remove the _recipient
        for (uint256 i = 0; i < feeRecipientAddresses.length; i++) {// Note uint8: we only support 256 recipients

            // If this is not the recipient we're looking for, continue
            if (feeRecipientAddresses[i] != recipient) continue;

            // Check if we're handling the last element (and/or only) in the array
            if (i != feeRecipientAddresses.length - 1) {
                // This is not the last element in the array.
                // First copy last element to position that is being cleared
                feeRecipientAddresses[i] = feeRecipientAddresses[feeRecipientAddresses.length - 1];
            }

            // Remove last element
            feeRecipientAddresses.pop();

            // Return, since recipientAddresses are unique, we're not finding any more.
            return;
        }
    }

    function addNonFeePayer(address nonFeePayer) external onlyOwner {
        require(nonFeePayer != address(0), "_nonFeePayer cannot be 0");
        require(!nonFeePayers[nonFeePayer], "_nonFeePayer already exists");
        nonFeePayers[nonFeePayer] = true;
        emit AddNonFeePayer(nonFeePayer);
    }

    function removeNonFeePayer(address nonFeePayer) external onlyOwner {
        require(nonFeePayer != address(0), "_nonFeePayer cannot be 0");
        require(nonFeePayers[nonFeePayer], "_nonFeePayer does not exist");
        nonFeePayers[nonFeePayer] = false;
        emit RemoveNonFeePayer(nonFeePayer);
    }

    function setBurnFee(uint16 newBurnFee) external onlyOwner {
        require(newBurnFee <= 10000, "_burnFee cannot be greater than 10000");
        emit SetBurnFee(burnFee, newBurnFee);
        burnFee = newBurnFee;
    }

    function setLiquidityFee(uint16 newLiquidityFee) external onlyOwner {
        require(newLiquidityFee <= 10000, "_liquidityFee cannot be greater than 10000");
        emit SetLiquidityFee(liquidityFee, newLiquidityFee);
        liquidityFee = newLiquidityFee;
    }

    function setMinLPDeposit(uint256 newMinLpDeposit) external onlyOwner {
        emit SetMinLPDeposit(minLPDeposit, newMinLpDeposit);
        minLPDeposit = newMinLpDeposit;
    }

    function setMinSwappedDeposit(uint256 newMinSwappedDeposit) external onlyOwner {
        emit SetMinSwappedDeposit(minSwappedDeposit, newMinSwappedDeposit);
        minSwappedDeposit = newMinSwappedDeposit;
    }

    function setMaxBuyAmount(uint256 newMaxBuyAmount) external onlyOwner {
        emit SetMaxBuyAmount(maxBuyAmount, newMaxBuyAmount);
        maxBuyAmount = newMaxBuyAmount;
    }

    function setMaxSellAmount(uint256 newMaxSellAmount) external onlyOwner {
        emit SetMaxSellAmount(maxSellAmount, newMaxSellAmount);
        maxSellAmount = newMaxSellAmount;
    }
    
    function includeOwnerFromFees() external onlyOwner {
        ownerPaysFees = true;
    }
    function excludeOwnerFromFees() external onlyOwner {
        ownerPaysFees = false;
    }

    // Returns the amount that was burned over the lifetime of the token
    function getBurnedSupply() external view returns (uint256) {
        return mintedAmount - totalSupply();
    }
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

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