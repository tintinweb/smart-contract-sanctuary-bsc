// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IDEXRouter.sol";
import "./interfaces/IDEXFactory.sol";
import "./interfaces/IDEXPair.sol";


interface IAdmin {
    function isAdmin(address user) external view returns (bool);
}

contract ArborSwapFairLaunch {
    using SafeMath for uint256;

    IDEXRouter public defaultDexRouter;
    IDEXPair public defaultPair;
    uint256 public lpPercentage;
    uint256 public tokensAmountForLiquidity;
    uint256 public BNBAmountForLiquidity;
    uint256 public liquidityUnlockTime;
    uint256 public liquidityLockPeriod;
    uint8 public decimals;
    address public factory;

    // Admin contract
    IAdmin public admin;
    uint256 public serviceFee;
    address public feeAddr;
    bool public saleFinished;
    bool public isSaleSuccessful;
    bool public lpWithdrawn;
    bool public leftoverWithdrawnCancelledSale;
    uint256 public minParticipation;
    uint256 public maxParticipation;
    uint256 public saleStartTime;
    address immutable dead = 0x000000000000000000000000000000000000dEaD;

    struct Sale {
        // Token being sold
        IERC20 token;
        // Is sale created
        bool isCreated;
        // Are earnings withdrawn
        bool earningsWithdrawn;
        // Have tokens been deposited
        bool tokensDeposited;
        // Address of sale owner
        address saleOwner; 
        // Total BNB Raised
        uint256 totalBNBRaised;
        // Sale end time
        uint256 saleEnd;
        // Hard cap in tokens
        uint256 hardCap;
        // soft cap in bnb
        uint256 softCap;
    }

    // Participation structure
    struct Participation {
        uint256 amountBNBPaid;
        bool areTokensWithdrawn;
        bool areBNBsWithdrawn;
        bool areBNBsEmergencyWithdrawn;
    }

    // Sale
    Sale public sale;

    // Number of users participated in the sale.
    uint256 public numberOfParticipants;

    mapping(address => Participation) public userToParticipation;
    // mapping if user is participated or not
    mapping(address => bool) public isParticipated;
   

    // Restricting calls only to sale owner
    modifier onlySaleOwner() {
        require(msg.sender == sale.saleOwner, "Restricted to sale owner.");
        _;
    }

    // Restricting calls only to factory
    modifier onlyFactory() {
        require(msg.sender == factory, "Restricted to factory.");
        _;
    }

    // Restricting calls only to sale owner or Admin
    modifier onlySaleOwnerOrAdmin() {
        require(
            msg.sender == sale.saleOwner || admin.isAdmin(msg.sender),
            "Restricted to sale owner and admin."
        );
        _;
    }

    // Restricting calls only to sale admin
    modifier onlyAdmin() {
        require(
            admin.isAdmin(msg.sender),
            "Only admin can call this function."
        );
        _;
    }

    // Events
    event TokensSold(address user, uint256 amount);
    event TokensWithdrawn(address user, uint256 amount);
    event SaleCreated(
        address saleOwner,
        uint256 saleEnd,
        uint256 _hardCap
    );
    event LogwithdrawUserFundsIfSaleCancelled(address user, uint256 amount);
    event LogFinishSale(bool isSaleSuccessful);
    event RoundAdded(uint256 _tierId, uint256 _startTime);
    event LogWithdrawLP(uint256 amount);
    event LogLockLiquidity(uint256 timeStart, uint256 unlockTime);
    event LogChangeLpPercentage(uint256 _percentage);
    event LogBurn(uint256 _amount);
    event LogEditMaxParticipation(uint256 maxP);
    event LogEditMinParticipation(uint256 minP);
    event LogGrantATier(address user, uint256 tier);
    event LogChangeSaleOwner(address newOwner);
    event LogWithdrawParticipation(address user, uint256 amount);

    constructor(
        address[] memory setupAddys,
        uint256[] memory uints,
        uint256 _serviceFee,
        address _feeAddr
    ) {
        require(setupAddys[0] != address(0), "Address zero validation");
        require(setupAddys[1] != address(0), "Address zero validation");
        require(uints[2] >= 5100 && uints[2] <= 10000, "Min 51%, Max 100%");
        require(
            uints[0] < uints[1],
            "Max participation should be greater than min participation"
        );
        IDEXRouter _dexRouter = IDEXRouter(setupAddys[0]);
        defaultDexRouter = _dexRouter;
        admin = IAdmin(setupAddys[1]);
        feeAddr = _feeAddr;
        serviceFee = _serviceFee;
        minParticipation = uints[0];
        maxParticipation = uints[1];
        lpPercentage = uints[2];
        liquidityLockPeriod = uints[3];
        factory = msg.sender;
        setSaleParams(
            setupAddys[2],
            setupAddys[3],
            uints[4],
            uints[5],
            uints[6],
            uints[7]
        );
    }

    /// @notice     Admin function to set sale parameters
    function setSaleParams(
        address _token,
        address _saleOwner,
        uint256 _saleStart,
        uint256 _saleEnd,
        uint256 _hardCap,
        uint256 _softCap
    ) private {
        require(!sale.isCreated, "Sale already created.");
        require(
            _token != address(0),
            "setSaleParams: Token address can not be 0."
        );
        require(_saleOwner != address(0), "Invalid sale owner address.");
        
        require(
            _saleEnd <= block.timestamp + 8640000,
            "Max sale duration is 100 days"
        );
        require(
            _saleStart >= block.timestamp,
            "Sale start should be in the future"
        );
        require(_saleStart < _saleEnd, "Sale start should be before sale end");

        decimals = IERC20Metadata(_token).decimals();

        // Set params
        sale.token = IERC20(_token);
        sale.isCreated = true;
        sale.saleOwner = _saleOwner;
        sale.saleEnd = _saleEnd;
        sale.hardCap = _hardCap;
        sale.softCap = _softCap;
        saleStartTime = _saleStart;

        // Emit event
        emit SaleCreated(
            sale.saleOwner,
            sale.saleEnd,
            sale.hardCap
        );
    }

    function changeLpPercentage(uint256 _lpPercentage) external onlySaleOwner {
        require(
            _lpPercentage >= 5100 && _lpPercentage <= 10000,
            "Min 51%, Max 100%"
        );
        require(block.timestamp < saleStartTime, "Sale already started");
        lpPercentage = _lpPercentage;
        emit LogChangeLpPercentage(_lpPercentage);
    }

    function changeSaleOwner(address _saleOwner) external onlySaleOwner {
        require(block.timestamp < saleStartTime, "Sale already started");
        require(_saleOwner != sale.saleOwner, "Already set to this value");
        require(_saleOwner != address(0), "Address 0 validation");
        sale.saleOwner = _saleOwner;
        emit LogChangeSaleOwner(_saleOwner);
    }

    
    // Function for owner to deposit tokens, can be called only once.
    function depositTokens() external  {
        // Require that setSaleParams was called
        require(sale.hardCap > 0, "Sale parameters not set.");

        // Require that tokens are not deposited
        require(!sale.tokensDeposited, "Tokens already deposited.");

        // Mark that tokens are deposited
        sale.tokensDeposited = true;

        // max possible amount
        uint256 lpTokens = sale.hardCap;

        uint256 amount = sale.hardCap.add(lpTokens);

        // Perform safe transfer
        sale.token.transferFrom(msg.sender, address(this), amount);
    }

    function withdrawParticipation() external{
        require(isParticipated[msg.sender], "Did not participate.");
        require(block.timestamp < sale.saleEnd, "Sale finished");
        // Retrieve participation from storage
        Participation storage p = userToParticipation[msg.sender];

        uint256 bnbPaid = p.amountBNBPaid;
        uint256 emergencyWithdrawFee = bnbPaid.mul(1000).div(10**4);
        uint256 amountBNBWithdrawing = bnbPaid.sub(emergencyWithdrawFee);

        // Decrease amount of BNB raised
        sale.totalBNBRaised = sale.totalBNBRaised.sub(bnbPaid);

        // Mark user isn't participated
        isParticipated[msg.sender] = false;

        // Decrement number of participants in the Sale.
        numberOfParticipants--;

        // Create new participation object
        p.amountBNBPaid = 0;
        

        safeTransferBNB(msg.sender, amountBNBWithdrawing);
        safeTransferBNB(feeAddr, emergencyWithdrawFee);

        emit LogWithdrawParticipation(msg.sender, amountBNBWithdrawing);
    }

    // Participate function for manual participation
    function participate() external payable {
        require(
            msg.value >= minParticipation,
            "Amount should be greater than minParticipation"
        );
        require(
            msg.value <= maxParticipation,
            "Amount should be not greater than maxParticipation"
        );
        _participate(msg.sender, msg.value);
    }

    // Function to participate in the sales
    function _participate(
        address user,
        uint256 amountBNB
    ) private {
        ///Check user haven't participated before
        require(!isParticipated[user], "Already participated.");
        require(block.timestamp >= saleStartTime, "Sale haven't started yet");
        require(sale.tokensDeposited == true, "Sale tokens were not deposited");
        require(block.timestamp <= sale.saleEnd, "Sale finished");


        // Increase amount of BNB raised
        sale.totalBNBRaised = sale.totalBNBRaised.add(amountBNB);

        // Create participation object
        Participation memory p = Participation({
            amountBNBPaid: amountBNB,
            areTokensWithdrawn: false,
            areBNBsWithdrawn: false,
            areBNBsEmergencyWithdrawn: false
        });

        // Add participation for user.
        userToParticipation[user] = p;
        // Mark user is participated
        isParticipated[user] = true;
        // Increment number of participants in the Sale.
        numberOfParticipants++;

        emit TokensSold(user, amountBNB);
    }

    // Expose function where user can withdraw sale tokens.
    function withdraw() external {
        require(block.timestamp > sale.saleEnd, "Sale is running");
        require(
            saleFinished == true && isSaleSuccessful == true,
            "Sale was cancelled"
        );
        require(isParticipated[msg.sender], "User is not a participant.");

        // Retrieve participation from storage
        Participation storage p = userToParticipation[msg.sender];

        require(p.areTokensWithdrawn == false, "Already withdrawn");
        uint256 totalTokens = sale.hardCap / 10**decimals;
        uint256 tokenPrice = sale.totalBNBRaised / totalTokens;

        uint256 amountWithdrawing = (p.amountBNBPaid)
            .mul(uint256(10)**IERC20Metadata(address(sale.token)).decimals())
            .div(tokenPrice);

        p.areTokensWithdrawn = true;

        if (amountWithdrawing > 0) {
            // Transfer tokens to user
            sale.token.transfer(msg.sender, amountWithdrawing);
            // Trigger an event
            emit TokensWithdrawn(msg.sender, amountWithdrawing);
        }
    }

    function editMaxParticipation(uint256 _maxP) external onlySaleOwner {
        require(block.timestamp < saleStartTime, "Sale already started");
        maxParticipation = _maxP;
        emit LogEditMaxParticipation(_maxP);
    }

    function editMinParticipation(uint256 _minP) external onlySaleOwner {
        require(block.timestamp < saleStartTime, "Sale already started");
        minParticipation = _minP;
        emit LogEditMaxParticipation(_minP);
    }

    function finishSale() external onlySaleOwner{
        require(block.timestamp >= sale.saleEnd, "Sale is not finished yet");
        require(saleFinished == false, "The function can be called only once");
        if (sale.totalBNBRaised > sale.softCap) {
            BNBAmountForLiquidity =
                (sale.totalBNBRaised * lpPercentage) /
                10000;
            tokensAmountForLiquidity =
                (sale.hardCap * lpPercentage) /
                10000;
            isSaleSuccessful = true;
            saleFinished = true;
            addLiquidity(tokensAmountForLiquidity, BNBAmountForLiquidity);
            lockLiquidity();
            burnTokens();
        } else {
            isSaleSuccessful = false;
            saleFinished = true;
            withdrawLeftoverIfSaleCancelled();
        }
        emit LogFinishSale(isSaleSuccessful);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        sale.token.approve(address(defaultDexRouter), tokenAmount);
        // add the liquidity
        defaultDexRouter.addLiquidityETH{value: ethAmount}(
            address(sale.token),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp + 60
        );
    }

    function lockLiquidity() private {
        liquidityUnlockTime = block.timestamp + liquidityLockPeriod;
        address _defaultPair = IDEXFactory(defaultDexRouter.factory()).getPair(
            address(sale.token),
            defaultDexRouter.WETH()
        );
        defaultPair = IDEXPair(_defaultPair);
        emit LogLockLiquidity(block.timestamp, liquidityUnlockTime);
    }

    function withdrawLP() external onlySaleOwner {
        require(block.timestamp >= liquidityUnlockTime);
        require(lpWithdrawn != true, "Already withdrawn");
        uint256 amount = defaultPair.balanceOf(address(this));
        lpWithdrawn = true;
        defaultPair.transfer(sale.saleOwner, amount);
        emit LogWithdrawLP(amount);
    }

    // transfers bnb correctly
    function withdrawUserFundsIfSaleCancelled() external {
        require(
            saleFinished == true && isSaleSuccessful == false,
            "Sale wasn't cancelled."
        );
        require(isParticipated[msg.sender], "Did not participate.");
        require(block.timestamp >= sale.saleEnd, "Sale running");
        // Retrieve participation from storage
        Participation storage p = userToParticipation[msg.sender];
        require(p.areBNBsWithdrawn == false, "Already withdrawn");
        p.areBNBsWithdrawn = true;
        uint256 amountBNBWithdrawing = p.amountBNBPaid;
        safeTransferBNB(msg.sender, amountBNBWithdrawing);
        emit LogwithdrawUserFundsIfSaleCancelled(
            msg.sender,
            amountBNBWithdrawing
        );
    }

    function burnTokens() private {
        uint256 all = sale.token.balanceOf(address(this));
        uint256 need = sale.hardCap;
        uint256 amountToBurn = all.sub(need);
        if (amountToBurn > 0) {
            sale.token.transfer(dead, amountToBurn);
        }
        emit LogBurn(amountToBurn);
    }

    // Internal function to handle safe transfer
    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success);
    }

    // Function to withdraw only earnings
    function withdrawEarnings() external onlySaleOwner {
        withdrawEarningsInternal();
    }

    // Function to withdraw earnings
    function withdrawEarningsInternal() private {
        require(
            saleFinished == true && isSaleSuccessful == true,
            "Sale was cancelled"
        );
        // Make sure sale ended
        require(block.timestamp >= sale.saleEnd, "Sale Running");

        // Make sure owner can't withdraw twice
        require(!sale.earningsWithdrawn, "can't withdraw twice");
        sale.earningsWithdrawn = true;
        // Earnings amount of the owner in BNB
        uint256 totalProfit = sale.totalBNBRaised.sub(BNBAmountForLiquidity);
        uint256 totalFee = _calculateServiceFee(totalProfit);
        uint256 saleOwnerProfit = totalProfit.sub(totalFee);

        safeTransferBNB(msg.sender, saleOwnerProfit);
        safeTransferBNB(feeAddr, totalFee);
    }

    function withdrawLeftoverIfSaleCancelled() private {
        require(
            saleFinished == true && isSaleSuccessful == false,
            "Sale wasnt cancelled"
        );
        // Make sure sale ended
        require(block.timestamp >= sale.saleEnd);

        // Make sure owner can't withdraw twice
        require(!leftoverWithdrawnCancelledSale, "can't withdraw twice");
        leftoverWithdrawnCancelledSale = true;

        // Amount of tokens which are not sold
        uint256 leftover = sale.token.balanceOf(address(this));

        if (leftover > 0) {
            sale.token.transfer(msg.sender, leftover);
        }
    }

    /// @notice     Function to get participation for passed user address
    function getParticipation(address _user)
        external
        view
        returns (
            uint256,
            bool,
            bool,
            bool
        )
    {
        Participation memory p = userToParticipation[_user];
        return (
            p.amountBNBPaid,
            p.areTokensWithdrawn,
            p.areBNBsWithdrawn,
            p.areBNBsEmergencyWithdrawn
        );
    }

    /// @notice     Function to remove stuck tokens from sale contract
    function removeStuckTokens(address token, address beneficiary)
        external
        onlyAdmin
    {
        // Require that token address does not match with sale token
        require(token != address(sale.token), "Can't withdraw sale token.");
        require(token != address(defaultPair), "Can't withdraw sale lps.");
        // Safe transfer token from sale contract to beneficiary
        IERC20(token).transfer(
            beneficiary,
            IERC20(token).balanceOf(address(this))
        );
    }

    function _calculateServiceFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(serviceFee).div(10**4);
    }

    function getNumberOfRegisteredUsers() external view returns (uint256) {
        return numberOfParticipants;
    }

    // Function to act as a fallback and handle receiving BNB.
    receive() external payable {}
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

pragma solidity ^0.8.4;

/**
 * Supports the Uniswap V1 + V2 structure
 */

interface IDEXRouter {
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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IDEXFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IDEXPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
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

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

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