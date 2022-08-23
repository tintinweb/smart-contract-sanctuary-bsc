// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./Ido.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract SalesFactory is Ownable{

    IAdmin public admin;
    address payable public feeAddr;
    uint256 public fee;

    mapping (address => bool) public isSaleCreatedThroughFactory;


    // Expose so query can be possible only by position as well
    address [] public allSales;

    event SaleDeployed(address saleContract);
    event SaleOwnerAndTokenSetInFactory(address sale, address saleOwner, address saleToken);
    event LogSetFee(uint256 newFee);
    event LogsetFeeAddr(address newAddress);

    modifier onlyAdmin {
        require(admin.isAdmin(msg.sender), "Only Admin can deploy sales");
        _;
    }

    constructor (address _adminContract) {
        require(_adminContract != address(0), "Invalid address");
        admin = IAdmin(_adminContract);
        
    }

    function setFee(uint256 _fee) public onlyOwner {
        require(fee != _fee, "Already set to this value");
        fee = _fee;
        emit LogSetFee(_fee);
    }

    function setFeeAddr(address payable _feeAddr) public onlyOwner {
        require(_feeAddr != address(0), "address zero validation");
        
        feeAddr = _feeAddr;
        emit LogsetFeeAddr(_feeAddr);


    }

    function deploySale()
    external 
    payable 
    onlyAdmin
    {   require(msg.value >= fee, "Not enough bnb sent");
        SparklaunchSale sale = new SparklaunchSale(address(admin));

        isSaleCreatedThroughFactory[address(sale)] = true;
        allSales.push(address(sale));
        feeAddr.transfer(msg.value);

        emit SaleDeployed(address(sale));
    }

    // Function to return number of pools deployed
    function getNumberOfSalesDeployed() external view returns (uint) {
        return allSales.length;
    }

    // Function
    function getLastDeployedSale() external view returns (address) {
        //
        if(allSales.length > 0) {
            return allSales[allSales.length - 1];
        }
        return address(0);
    }

    // Function to get all sales
    function getAllSales(uint startIndex, uint endIndex) external view returns (address[] memory) {
        require(endIndex > startIndex, "Bad input");
        require(endIndex < allSales.length, "access out of rage");

        address[] memory sales = new address[](endIndex - startIndex);
        uint index = 0;

        for(uint i = startIndex; i < endIndex; i++) {
            sales[index] = allSales[i];
            index++;
        }

        return sales;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Admin.sol";


interface IAdmin {
    function isAdmin(address user) external view returns (bool);
}

interface ISalesFactory {
    function setSaleOwnerAndToken(address saleOwner, address saleToken) external;
    function isSaleCreatedThroughFactory(address sale) external view returns (bool);
}

contract SparklaunchSale {
    using SafeMath for uint256;

    // Admin contract
    IAdmin public admin;
    ISalesFactory public factory;
    uint256 serviceFee;
    bool isSaleSucsessful;
    
    struct Sale {
        // Token being sold
        IERC20 token;
        // Is sale created
        bool isCreated;
        // Are earnings withdrawn
        bool earningsWithdrawn;
        // Is leftover withdrawn
        bool leftoverWithdrawn;
        // Have tokens been deposited
        bool tokensDeposited;
        // Address of sale owner
        address saleOwner;
        // Price of the token quoted in BNB
        uint256 tokenPriceInBNB;
        // Total tokens being sold
        uint256 totalTokensSold;
        // Total BNB Raised
        uint256 totalBNBRaised;
        // Sale end time
        uint256 saleEnd;
        // Hard cap
        uint256 hardCap;
        // Soft cap
        uint256 softCap;
    }

    // Participation structure
    struct Participation {
        uint256 amountBought;
        uint256 amountBNBPaid;
        uint256 timeParticipated;
        bool[] isPortionWithdrawn;
    }

    

    // Sale
    Sale public sale;
    
    // Number of users participated in the sale.
    uint256 public numberOfParticipants;

    // Array storing IDS of tiers (IDs start from 1, so they can't be mapped as array indexes
    uint256[] public tierIds;
    // Mapping tier Id to tier start time
    mapping(uint256 => uint256) public tierIdToTierStartTime;
   
    mapping(address => Participation) public userToParticipation;
    // mapping if user is participated or not
    mapping(address => bool) public isParticipated;
    // mapping user to tier
    mapping(address => uint256) public tier;
    // Times when portions are getting unlocked
    uint256[] public vestingPortionsUnlockTime;
    // Percent of the participation user can withdraw
    uint256[] public vestingPercentPerPortion;
    //Precision for percent for portion vesting
    uint256 public portionVestingPrecision;
    

    // Restricting calls only to sale owner
    modifier onlySaleOwner() {
        require(msg.sender == sale.saleOwner, "Restricted to sale owner.");
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
        uint256 tokenPriceInBNB,
        uint256 saleEnd,
        uint256 _hardCap,
        uint256 _softCap
    );
    event LogwithdrawUserFundsIfSaleCancelled(address user, uint256 amount);
    event LogFinishSale(bool isSaleSucsessful);
    event LogWithdrawDepositedTokensIfSaleCancelled(address user, uint256 amount);
    
    constructor(address _admin){
        require(_admin != address(0), "Address zero validation");
        admin = IAdmin(_admin);
        factory = ISalesFactory(msg.sender);
    }



    /// @notice     Admin function to set sale parameters
    function setSaleParams(
        address _token,
        address _saleOwner,
        uint256 _tokenPriceInBNB,
        uint256 _saleEnd,
        uint256 _portionVestingPrecision,
        uint256 _hardCap,
        uint256 _softCap
    )
        external
        onlyAdmin
    {
        require(!sale.isCreated, "Sale already created.");
        require(
            _saleOwner != address(0),
            "Invalid sale owner address."
        );
        require(
            _tokenPriceInBNB != 0 &&
            _hardCap != 0 &&
            _softCap != 0 &&
            _saleEnd > block.timestamp,
            "Invalid input."
        );
        require(_portionVestingPrecision >= 100, "Should be at least 100");
        

        // Set params
        sale.token = IERC20(_token);
        sale.isCreated = true;
        sale.saleOwner = _saleOwner;
        sale.tokenPriceInBNB = _tokenPriceInBNB;
        sale.saleEnd = _saleEnd;
        sale.hardCap = _hardCap;
        sale.softCap = _softCap;
        


        // Set portion vesting precision
        portionVestingPrecision = _portionVestingPrecision;
       

        // Emit event
        emit SaleCreated(
            sale.saleOwner,
            sale.tokenPriceInBNB,
            sale.saleEnd,
            sale.hardCap,
            sale.softCap
        );
    }

    function setTierStartTime(uint256 _time, uint256 _tierId) external onlyAdmin {
        require(_time != 0, "Time can not be 0");
        require(_tierId != 0, "Tier id can not be 0");
        tierIdToTierStartTime[_tierId] = _time;
    }

    function grantATierMultiply(address[] memory addys, uint256[] memory tiers) external onlyAdmin {
        require(addys.length == tiers.length, "Invalid input");
        for (uint256 i = 0; i < addys.length; i++){
            grantATier(addys[i], tiers[i]);
        }
    }

    function grantATier(address user, uint256 _tier) public onlyAdmin {
        require(_tier <= 5, "Max tier is 5");
        require(_tier != 0, "Tier can't be 0");
        require(user != address(0), "Zero address validation");
        tier[user] = _tier;
    }

    // Function for owner to deposit tokens, can be called only once.
    function depositTokens()
        external
        onlySaleOwner
    {
        // Require that setSaleParams was called
        require(
            sale.hardCap > 0,
            "Sale parameters not set."
        );

        // Require that tokens are not deposited
        require(
            !sale.tokensDeposited,
            "Tokens already deposited."
        );

        // Mark that tokens are deposited
        sale.tokensDeposited = true;

        // Perform safe transfer
        sale.token.transferFrom(
            msg.sender,
            address(this),
            sale.hardCap
        );
    }

    // Participate function for manual participation
    function participate(
        uint256 amount,
        uint256 tierId
    ) external payable {
        require(tierId != 0 && tierId <= 5, "Invalid tier id");
        

        _participate(msg.sender, msg.value, amount, tierId);
    }

    // Function to participate in the sales
    function _participate(
        address user,
        uint256 amountBNB,
        uint256 amount, 
        uint256 tierId
    ) internal {

        ///Check user haven't participated before
       require(!isParticipated[user], "Already participated.");
       require(tier[user] == tierId, "Wrong Round");
       require(block.timestamp >= tierIdToTierStartTime[tierId], "Your round haven't started yet");

        // Compute the amount of tokens user is buying
        uint256 amountOfTokensBuying =
            (amountBNB).mul(uint(10) ** IERC20Metadata(address(sale.token)).decimals()).div(sale.tokenPriceInBNB);

        // Must buy more than 0 tokens
        require(amountOfTokensBuying > 0, "Can't buy 0 tokens");

        // Check in terms of user allowance
        require(
            amountOfTokensBuying <= amount,
            "Exceeding allowance."
        );

        // Require that amountOfTokensBuying is less than sale token leftover cap
        require(
            amountOfTokensBuying <= sale.hardCap.sub(sale.totalTokensSold),
            "Not enough tokens to sell."
        );

        // Increase amount of sold tokens
        sale.totalTokensSold = sale.totalTokensSold.add(amountOfTokensBuying);

        // Increase amount of BNB raised
        sale.totalBNBRaised = sale.totalBNBRaised.add(amountBNB);

        // Empty bool array used to be set as initial for 'isPortionWithdrawn' 
        // Size determined by number of sale portions
        bool[] memory _empty = new bool[](
            vestingPortionsUnlockTime.length
        );

        // Create participation object
        Participation memory p = Participation({
            amountBought: amountOfTokensBuying,
            amountBNBPaid: amountBNB,
            timeParticipated: block.timestamp,
            isPortionWithdrawn: _empty
        });

        // Add participation for user.
        userToParticipation[user] = p;
        // Mark user is participated
        isParticipated[user] = true;
        // Increment number of participants in the Sale.
        numberOfParticipants++;


        emit TokensSold(user, amountOfTokensBuying);
    }

    // @notice     Function to retroactively set sale token address after initial contract creation has passed.
    //             Added as an option for teams which are not having token at the moment of sale launch.
    function setSaleToken(
        address saleToken
    )
        external
        onlyAdmin
    {
        require(saleToken != address(0), "Invalid token address");
        sale.token = IERC20(saleToken);
    }


 /// @notice         Function to set vesting params
    function setVestingParams(
        uint256[] memory _unlockingTimes,
        uint256[] memory _percents
    )
        external
        onlyAdmin
    {
        require(
            vestingPercentPerPortion.length == 0 &&
            vestingPortionsUnlockTime.length == 0
            ,"vesting already set"
        );
        require(_unlockingTimes.length == _percents.length,"Vesting: arrarys not equal");
        require(portionVestingPrecision > 0, "Sale params not set.");
        

        uint256 sum;

        // Require that locking times are later than sale end
        require(_unlockingTimes[0] > sale.saleEnd, "Unlock time must be after the sale ends.");

        // Set vesting portions percents and unlock times
        for (uint256 i = 0; i < _unlockingTimes.length; i++) {
            if(i > 0) {
                require(_unlockingTimes[i] > _unlockingTimes[i-1], "Unlock time must be greater than previous.");
            }
            vestingPortionsUnlockTime.push(_unlockingTimes[i]);
            require(vestingPortionsUnlockTime.length ==(i+1), "UnlockTime not updated ");
            vestingPercentPerPortion.push(_percents[i]);
            require(vestingPercentPerPortion.length ==(i+1), "Percent not updated ");
            sum = sum.add(_percents[i]);
        }

        require(sum == portionVestingPrecision, "Percent distribution issue.");
    }


    // Expose function where user can withdraw multiple unlocked portions at once.
    function withdrawMultiplePortions(uint256 [] calldata portionIds) external {
        require(isSaleSucsessful = true, "Sale was cancelled");
        uint256 totalToWithdraw = 0;
       
      
         // Retrieve participation from storage
        Participation storage p = userToParticipation[msg.sender];

        for(uint i=0; i < portionIds.length; i++) {
            uint256 portionId = portionIds[i];
            require(portionId < vestingPortionsUnlockTime.length,"should be less than Portions.");

            if (
                !p.isPortionWithdrawn[portionId] &&
                vestingPortionsUnlockTime[portionId] <= block.timestamp
            ) {
                // Mark participation as withdrawn
                p.isPortionWithdrawn[portionId] = true;
                // Compute amount withdrawing
                uint256 amountWithdrawing = p
                    .amountBought
                    .mul(vestingPercentPerPortion[portionId])
                    .div(portionVestingPrecision);
                // Withdraw percent which is unlocked at that portion
                totalToWithdraw = totalToWithdraw.add(amountWithdrawing);
            }
       }

       if  (totalToWithdraw > 0) {
           // Transfer tokens to user
            sale.token.transfer(msg.sender, totalToWithdraw);
            // Trigger an event
            emit TokensWithdrawn(msg.sender, totalToWithdraw);
        }
    }

    function finishSale() public onlyAdmin{
        require(block.timestamp >= sale.saleEnd, "Sale is not finished yet");
        if(sale.totalBNBRaised >= sale.softCap){
            isSaleSucsessful = true;
        } else{
            isSaleSucsessful = false;
        }
        emit LogFinishSale(isSaleSucsessful);
    }

    function withdrawUserFundsIfSaleCancelled() external{
        require(isParticipated[msg.sender], "Did not participate.");
        require(block.timestamp >= sale.saleEnd, "Sale wasn't finished yet");
        require(isSaleSucsessful = false, "Sale wasn't cancelled");
        // Retrieve participation from storage
        Participation storage p = userToParticipation[msg.sender];
        uint256 amountBNBWithdrawing = p.amountBNBPaid;
        safeTransferBNB(msg.sender, amountBNBWithdrawing);
        emit LogwithdrawUserFundsIfSaleCancelled(msg.sender, amountBNBWithdrawing);
    }

    function withdrawDepositedTokensIfSaleCancelled() external onlySaleOwner{
        require(block.timestamp >= sale.saleEnd, "Sale wasn't finished yet");
        require(isSaleSucsessful = false, "Sale wasn't cancelled");
        require(sale.tokensDeposited = true, "Tokens were not deposited.");
        uint256 amountTokensWithdrawing = sale.hardCap;
        safeTransferBNB(msg.sender, amountTokensWithdrawing);
        emit LogWithdrawDepositedTokensIfSaleCancelled(msg.sender, amountTokensWithdrawing);
    }

    // Internal function to handle safe transfer
    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success);
    }

    // Function to withdraw all the earnings and the leftover of the sale contract.
    function withdrawEarningsAndLeftover() external onlySaleOwner {
        withdrawEarningsInternal();
        withdrawLeftoverInternal();
    }

    // Function to withdraw only earnings
    function withdrawEarnings() external onlySaleOwner {
        withdrawEarningsInternal();
    }

    // Function to withdraw only leftover
    function withdrawLeftover() external onlySaleOwner {
        withdrawLeftoverInternal();
    }

    // Function to withdraw earnings
    function withdrawEarningsInternal() internal  {
        require(isSaleSucsessful = true, "Sale was cancelled");
        // Make sure sale ended
        require(block.timestamp >= sale.saleEnd,"Sale Running");

        // Make sure owner can't withdraw twice
        require(!sale.earningsWithdrawn,"can't withdraw twice");
        sale.earningsWithdrawn = true;
        // Earnings amount of the owner in BNB
        uint256 totalProfit = sale.totalBNBRaised;
        uint256 totalFee = _calculateServiceFee(totalProfit);
        uint256 saleOwnerProfit = totalProfit.sub(totalFee);

        safeTransferBNB(msg.sender, saleOwnerProfit);
        safeTransferBNB(msg.sender, totalFee);
    }

    // Function to withdraw leftover
    function withdrawLeftoverInternal() internal {
        // Make sure sale ended
        require(block.timestamp >= sale.saleEnd);
        require(isSaleSucsessful = true, "Sale wasn cancelled");

        // Make sure owner can't withdraw twice
        require(!sale.leftoverWithdrawn,"can't withdraw twice");
        sale.leftoverWithdrawn = true;

        // Amount of tokens which are not sold
        uint256 leftover = sale.hardCap.sub(sale.totalTokensSold);

        if (leftover > 0) {
            sale.token.transfer(msg.sender, leftover);
        }
    }

    // Function where admin can withdraw all unused funds.
    function withdrawUnusedFunds() external onlyAdmin {
        uint256 balanceBNB = address(this).balance;

        uint256 totalReservedForRaise = sale.earningsWithdrawn ? 0 : sale.totalBNBRaised;

        safeTransferBNB(
            msg.sender,
            balanceBNB.sub(totalReservedForRaise)
        );
    }

    /// @notice     Function to get participation for passed user address
    function getParticipation(address _user)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            bool[] memory
        )
    {
        Participation memory p = userToParticipation[_user];
        return (
            p.amountBought,
            p.amountBNBPaid,
            p.timeParticipated,
            p.isPortionWithdrawn
        );
    }

    /// @notice     Function to get all info about vesting.
    function getVestingInfo()
        external
        view
        returns (uint256[] memory, uint256[] memory)
    {
        return (vestingPortionsUnlockTime, vestingPercentPerPortion);
    }

    /// @notice     Function to remove stuck tokens from sale contract
    function removeStuckTokens(
        address token,
        address beneficiary
    )
        external
        onlyAdmin
    {
        // Require that token address does not match with sale token
        require(token != address(sale.token), "Can't withdraw sale token.");
        // Safe transfer token from sale contract to beneficiary
        IERC20(token).transfer(beneficiary, IERC20(token).balanceOf(address(this)));
    }

     function _calculateServiceFee(uint256 _amount)
        public
        view
        returns (uint256)
    {

        return _amount.mul(serviceFee).div(10**4);
    }

    // Function to act as a fallback and handle receiving BNB.
    receive() external payable {}
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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
import "@openzeppelin/contracts/access/Ownable.sol";
pragma solidity ^0.8.11;

contract Admin is Ownable{

    // Listing all admins
    address [] public admins;

    // Modifier for easier checking if user is admin
    mapping(address => bool) public isAdmin;

    // Modifier restricting access to only admin
    modifier onlyAdmin {
        require(isAdmin[msg.sender], "Only admin can call.");
        _;
    }

    // Constructor to set initial admins during deployment
    constructor (address [] memory _admins)  {
        for(uint i = 0; i < _admins.length; i++) {
            admins.push(_admins[i]);
            isAdmin[_admins[i]] = true;
        }
    }

    function addAdmin(
        address _adminAddress
    )
    external
    onlyOwner
    {
        // Can't add 0x address as an admin
        require(_adminAddress != address(0x0), "[RBAC] : Admin must be != than 0x0 address");
        // Can't add existing admin
        require(!isAdmin[_adminAddress], "[RBAC] : Admin already exists.");
        // Add admin to array of admins
        admins.push(_adminAddress);
        // Set mapping
        isAdmin[_adminAddress] = true;
    }

    function removeAdmin(
        address _adminAddress
    )
    external
    onlyOwner
    {
        // Admin has to exist
        require(isAdmin[_adminAddress], "address not Admin");
        require(admins.length > 1, "Can not remove all admins since contract becomes unusable.");
        uint i = 0;

        while(admins[i] != _adminAddress) {
            if(i == admins.length) {
                revert("Passed admin address does not exist");
            }
            i++;
        }

        // Copy the last admin position to the current index
        admins[i] = admins[admins.length-1];

        isAdmin[_adminAddress] = false;

        // Remove the last admin, since it's double present
        admins.pop();
    }

    // Fetch all admins
    function getAllAdmins()
    external
    view
    returns (address [] memory)
    {
        return admins;
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