// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../Interfaces/IBlacklist.sol";
import "../Interfaces/IWhitelist.sol";
import "../Interfaces/IAdmin.sol";
import "../Interfaces/IEvents.sol";

//todo: At the time of final deployment change the router, factory and token addresses, compensationlimit, DAYS_IN_SECONDS

    /**
    @dev this contract is for xYSL token.
    */

contract xYSL is ERC20, AccessControl, Pausable, IEvents, ReentrancyGuard {

    IERC20 public oldXYSL; // oldXysl token address

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // role byte for minter
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE"); // byte for burner role
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR"); //byte for operator role

    address router; // router address
    address public teamAddress; // Team wallet address
    uint256 public compensationLimit; //Limit for mint xYSL token i.e. set in constructor
    uint256 public deploymentTime; // Time when the contract deploys
    address public burn1=0x000000000000000000000000000000000000dEaD; // Burn token address for old xYSL
    address public burn2=0x0000000000000000000000000000000000000000; // Burn token address for old xYSL
    uint256 public DAYS_IN_SECONDS = 300; // 1 day = 86400; for testing 1 day = 10s
    uint256 public xYSLMigrateDaysLimit = 1500; // Days limit to migrate old xYSL in to new xYSL token
    uint256 public xYSL_Tax = 1500; //Tax always multiply by 100
    uint256 public xYSL_ThresholdLimit = 1000 *10**18; //Amount limit after xYSL swap to BUSD
    uint256 public priceImpactProtection = 10; // Price Impact Protection of xYSL
    uint256 public lockTransactionTime = 900 seconds; 
    uint256[] public xYSL_Tax_Allocation = [500, 500, 500];//index-1 => TemporaryHolding contract, index-2 => xYSL Burn address, index-3 => Treasury; All index value multiply by 100;

    mapping(address => uint256) public restrictTransfer; // last block number when interacted
    mapping(address => uint) public transactionTimeLimit;

    IAdmin public Admin;

    constructor(
        address _admin,
        address _oldXYSL
    ) ERC20("xYSL", "xYSL") {
        Admin = IAdmin(_admin); 
        oldXYSL = IERC20(_oldXYSL);
        router = Admin.ApeswapRouter();
        deploymentTime = block.timestamp;
        compensationLimit = (oldXYSL.totalSupply() - (oldXYSL.balanceOf(burn1)+oldXYSL.balanceOf(burn2))); // Calculate compensation limit using total supply of old xYSL minus  sum of burn tokens from burn address
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(BURNER_ROLE, _msgSender());

    }

    /**
    @dev modifier for minter role
     */

    modifier _isMinter() {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        _;
    }

    /**
    @dev modifier for burner role
    **/

    modifier _isBurner() {
        require(
            hasRole(BURNER_ROLE, msg.sender),
            "xYSL: Caller is not a Burner"
        );
        _;
    }

    /**
    @dev modifier for operator role
    **/
    
    modifier _isOperator(){
        require(Admin.hasRole(OPERATOR_ROLE, msg.sender));
        _;
    }

    /**
    @dev modifier for Admin role
    **/

    modifier _isAdmin(){
        require(Admin.hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        _;
    }

/**
    @dev Function for Pause by an Operator
    **/
     function pause() external nonReentrant _isOperator{
        _pause();
    }

    /**
    @dev Function for UnPause by an Operator
    **/
    function unpause() external nonReentrant _isOperator{
        _unpause();
    }

    /**
    @dev status for minter
    @param _address address to check for minter role
    */

    function isMinter(address _address) external view returns (bool result) {
        result = hasRole(MINTER_ROLE, _address);
        return result;
    }

    /**
    @dev status for burner
    @param _address address to check for burner role
    */

    function isBurner(address _address) external view returns (bool result) {
        result = hasRole(BURNER_ROLE, _address);
        return result;
    }

    /**
    Note only minter role can call 
    @dev mint token called yet compensation limit not reached
    @param account address of receiver
    @param amount amount to mint
     */

    function mint(address account, uint256 amount) external _isMinter whenNotPaused {
         if(balanceOf(account) == 0){
                transactionTimeLimit[account] = block.timestamp;
            }
        _mint(account, amount);
    }

   /**
    Note only minter role can call 
    @dev burn token called yet compensation limit not reached
    @param account address of receiver
    @param amount amount from burn
     */

    function burn(address account, uint256 amount) external _isMinter whenNotPaused {
        _burn(account, amount);
    }

    /**
    Note only admin can call it 
    @dev grant minter role 
    @param _minter address who will get minter role
     */

    function setMinter(address _minter) external _isAdmin {
        require(_minter != address(0), "Null address provided");
        _setupRole(MINTER_ROLE, _minter);
    }

    /**
    Note only admin can call it 
    @dev grant burner role 
    @param _burner address who will get burner role
     */

    function setBurner(address _burner) external _isAdmin {
        require(_burner != address(0), "xYSL: Null address provided");
        _setupRole(BURNER_ROLE, _burner);
    }
    
    /**
    Note only admin can call it 
    @dev revoke minter role 
    @param _minter address whose role will revoke
     */

    function removeMinter(address _minter) external _isAdmin {
        require(_minter != address(0), "Null address provided");
        revokeRole(MINTER_ROLE, _minter);
    }

    /**
    Note User will call migrate only if xYSL days limit not reaches xYSLMigrateDaysLimit or total supply not reaches compensation limit
    @dev user will call it for migrate old xYSL to xYSL token
    */
    function migrate() external nonReentrant {
        require(totalSupply() < compensationLimit,"xYSL: migrate: MINTING LIMIT EXCEEDED");
        uint day = (block.timestamp - deploymentTime)/DAYS_IN_SECONDS;
        require(day <= xYSLMigrateDaysLimit,"xYSL: Days limit exceeded");
        uint amount= oldXYSL.balanceOf(msg.sender);
        oldXYSL.transferFrom(msg.sender,address(this),amount);
        _mint(msg.sender,amount);
        if(totalSupply() >= compensationLimit){
            paused();
        }
    }

    /**
    Note only admin role can call 
    @dev It is called to swap old xYSL in to BUSD and send it to team address
     */
    function swapOldXYSL() external nonReentrant _isAdmin {
        uint day = (block.timestamp - deploymentTime)/DAYS_IN_SECONDS;
        require(day > xYSLMigrateDaysLimit,"xYSL: Days threshold not reached yet");
        address[] memory path = new address[](2);
        path[0] = address(oldXYSL);
        path[1] = Admin.BUSD();
        oldXYSL.approve(router, oldXYSL.balanceOf(address(this)));
        IUniswapV2Router02(router).swapExactTokensForTokens(oldXYSL.balanceOf(address(this)),0,path,Admin.TeamAddress(),block.timestamp+1000)[1];
    }

    /**
    Note only admin role can call 
    @dev It is called to set old xYSL migrate days limit
    @param _xYSLMigrateDaysLimit Days limit for migrate old xYSL in to new xYSL token
     */

    function setMigrateDaysLimit(uint _xYSLMigrateDaysLimit) external _isAdmin{
        require(_xYSLMigrateDaysLimit > 0, 'xYSL: _xYSLMigrateDaysLimit must be greater than zero');
        emit SetterForUint("xYSLToken",address(this),xYSLMigrateDaysLimit,_xYSLMigrateDaysLimit,block.number,block.timestamp);
        xYSLMigrateDaysLimit= _xYSLMigrateDaysLimit;
    }

    /**
    Note allocation point should be equal to tax
        all the values should enter with 100 cofficient
        only admin can call 
    @dev set tax and allocation points
    @param _tax total tax
    @param allocationTax array of allocation point
     */

    function setxYSLAndAllocationTax(
        uint256 _tax,
        uint256[] memory allocationTax
    ) external _isAdmin {
        require(_tax > 0, "xYSL: Tax should be greater than zero");
        require(
            allocationTax.length > 0,
            "xYSL: AllocationTax should not be empty"
        );
        uint256 total;
        for (uint256 i; i < allocationTax.length; i++) {
            total += allocationTax[i];
        }
        require(total == _tax, "xYSL: Tax not equal to sum of allocation tax");
        emit TaxAllocation("xYSLToken", address(this), xYSL_Tax, _tax, xYSL_Tax_Allocation, allocationTax,block.number,block.timestamp);
        xYSL_Tax = _tax;
        xYSL_Tax_Allocation = allocationTax;
    }

    /**
    Note only admin can call
    @dev set thresholdLimit
    @param _xYSL_ThresholdLimit set amount of threshold limit for xYSL
     */

    function setxYSLThresholdLimit(uint256 _xYSL_ThresholdLimit)
        external
        _isAdmin
    {
        require(
            _xYSL_ThresholdLimit > 0,
            "xYSL: Threshold limit for xYSL can not be zero"
        );
        emit SetterForUint("xYSLToken",address(this),xYSL_ThresholdLimit,_xYSL_ThresholdLimit,block.number,block.timestamp);
        xYSL_ThresholdLimit = _xYSL_ThresholdLimit;
    }
    /**
    @dev setter function for Price Impact Protection
     */

    function setPriceImpactProtection(uint value) public _isAdmin {
        require(value > 0,"xYSLToken: Value can't be zero");
        emit SetterForUint("xYSLToken",address(this),priceImpactProtection,value,block.number,block.timestamp);
        priceImpactProtection = value;
    }

    /**
    @dev setter function for LockTransactionTime
     */

    function setLockTransactionTime(uint time) public _isAdmin {
        require(time > 0, 'xYSL: LockTransactionTime  for xYSL can not be zero');
        emit SetterForUint("xYSLToken",address(this),lockTransactionTime,time,block.number,block.timestamp);
        lockTransactionTime = time;
    }

    

    /**
    @dev override transfer function to restrict and apply tax on transfer 
     */

    function _transfer(
        address sender, 
        address recipient, 
        uint256 amount
    ) internal virtual override nonReentrant{

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!(IBlacklist(Admin.Blacklist()).getAddresses(sender)), "xYSL: address is Blacklisted");
        require(!(IBlacklist(Admin.Blacklist()).getAddresses(recipient)), "xYSL: address is Blacklisted");

        isContractwhitelist(sender, recipient);
        if(balanceOf(recipient) == 0){
                transactionTimeLimit[recipient] = block.timestamp;
            }
        if(sender == IUniswapV2Factory(IUniswapV2Router02(router).factory()).getPair(address(this), Admin.BUSD()) || recipient == IUniswapV2Factory(IUniswapV2Router02(router).factory()).getPair(address(this), Admin.BUSD())){
            address user = sender == IUniswapV2Factory(IUniswapV2Router02(router).factory()).getPair(address(this), Admin.BUSD()) ? recipient : sender;
            if(IWhitelist(Admin.whitelist()).getAddressesOfSwap(user)){
                super._transfer(sender, recipient, amount);
            }
            else {
                if(sender == IUniswapV2Factory(IUniswapV2Router02(router).factory()).getPair(address(this), Admin.BUSD())){
                    uint taxAmount = (amount * xYSL_Tax)/ 10000;
                    super._transfer(sender, address(this), taxAmount);
                    amount -= taxAmount;
                    super._transfer(sender, recipient, amount);                    
                    tax(taxAmount);
                    exitRate(sender, amount);
                    blockRestriction(user);

                }
                else {
                    require(transactionTimeLimit[sender] + lockTransactionTime <= block.timestamp,"xYSL: transactionTimeLimit is greater than current time");
                    uint taxAmount = (amount * xYSL_Tax)/ 10000;
                    super._transfer(sender, address(this), taxAmount);
                    amount -= taxAmount;
                    uint256 prevAmount = balanceOf(IUniswapV2Factory(IUniswapV2Router02(router).factory()).getPair(address(this), Admin.BUSD())); 
                    super._transfer(sender, recipient, amount);
                    uint256 currentAmount = balanceOf(IUniswapV2Factory(IUniswapV2Router02(router).factory()).getPair(address(this), Admin.BUSD()));   
                    require(prevAmount + ((prevAmount * priceImpactProtection)/1000) >= currentAmount, "xYSL: priceImpactProtection");
                    tax(taxAmount);
                    exitRate(sender, amount);
                    transactionTimeLimit[user] = block.timestamp;
                    blockRestriction(user);
                }
            }
        }
        else if(IWhitelist(Admin.whitelist()).getAddresses(sender) || IWhitelist(Admin.whitelist()).getAddresses(recipient)){
            super._transfer(sender, recipient, amount);
        }else{
               require(transactionTimeLimit[sender] + lockTransactionTime <= block.timestamp,"xYSL: transactionTimeLimit is greater than current time");
               uint taxAmount = (amount * xYSL_Tax)/10000;
               super._transfer(sender, address(this), taxAmount);
               amount -= taxAmount;
               tax(taxAmount);
               blockRestriction(sender);
               exitRate(sender, amount);
               transactionTimeLimit[sender] = block.timestamp;
               super._transfer(sender, recipient, amount);
        }
    }

    /**
    @dev Function for Block restriction to ensure that User can't interact within same block
    @param user address of User or sender
    */

    function blockRestriction(address user) internal {
        require(restrictTransfer[user] != block.number,"xYSL: you can't interact in same block");
        restrictTransfer[user] = block.number;
    }

    /**
    @dev Function to ensure that Non-WhiteList contract or User can't interact with BYSL.
    @param sender address of Token holder
    @param recipient address of receiver
    **/

    function isContractwhitelist(address sender, address recipient) internal {
        if(isContract(sender)){
            require(IWhitelist(Admin.whitelist()).getAddresses(sender),"xYSL: No external contract interact with xYSL");
        }
        if(isContract(recipient)){
            require(IWhitelist(Admin.whitelist()).getAddresses(recipient),"xYSL: No external contract interact with xYSL");
        }
    }

    /**
    @dev Function to get Tax amount 
    @param taxAmount uint for tax amount.
    **/

    function tax(uint256 taxAmount) internal {
        _burn(address(this),taxAmount * xYSL_Tax_Allocation[0]/xYSL_Tax);
        taxAmount = taxAmount - (taxAmount *xYSL_Tax_Allocation[0]/xYSL_Tax);
        address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = Admin.BUSD();
        if(IUniswapV2Router02(router).getAmountsOut(balanceOf(address(this)),path)[1] >= xYSL_ThresholdLimit){
            IERC20(address(this)).approve(router, taxAmount); //BSC Testnet pancake router address
            uint convertedBUSD = IUniswapV2Router02(router).swapExactTokensForTokens( 
                taxAmount,
                0,
                path,
                address(this),
                block.timestamp + 1000
                )[1];
            IERC20(Admin.BUSD()).transfer(Admin.temporaryHolding(), (convertedBUSD * xYSL_Tax_Allocation[1])/(xYSL_Tax - xYSL_Tax_Allocation[0]));
            IERC20(Admin.BUSD()).transfer(Admin.Treasury(), ((convertedBUSD * xYSL_Tax_Allocation[2])/((xYSL_Tax - xYSL_Tax_Allocation[0]) * 2)));
            IERC20(Admin.BUSD()).transfer(Admin.TeamAddress(), ((convertedBUSD * xYSL_Tax_Allocation[2])/((xYSL_Tax - xYSL_Tax_Allocation[0]) * 2)));
        }
    }

    /**
    @dev Function for calculating Exit Rate
    @param sender address of sender.
    @param amount Uint for amount.
    **/

    function exitRate(address sender, uint256 amount) internal view {
        uint newTime = block.timestamp - transactionTimeLimit[sender];
        uint timeInDays = newTime / DAYS_IN_SECONDS;
        uint exitRateAmount;
        if( timeInDays > 2 ){   
        uint exitRateOfDay = timeInDays - 2 ;
            if(exitRateOfDay >= 100){
                exitRateOfDay = 100;
            }

            exitRateAmount = ((balanceOf(sender) * exitRateOfDay)/100);
        }
        else{
            exitRateAmount = ((balanceOf(sender) * 1)/1000);
            }
        require(exitRateAmount >= amount, "xYSL: Amount is greater than the exitRateAmount");
    }

   

    /**
    @dev To verify contract address
    @param _addr contract address as parameter
    */

    function isContract(address _addr) internal view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts v4.4.0 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/ERC20.sol)

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
// OpenZeppelin Contracts v4.4.0 (security/Pausable.sol)

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
pragma solidity ^0.8.7;

interface IBlacklist {
    function getAddresses(address _protocol) external view returns(bool);
    function addBlacklist(address[] calldata _protocol) external;
    function revokeBlacklist(address[] calldata _protocol) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IWhitelist {
    function getAddresses(address _protocol) external view returns(bool);
    function getAddressesOfSwap(address _protocol) external view returns(bool);

    // function getUserAddresses(address _user) external view returns(bool);
    function addWhiteList(address[] calldata _protocol) external;
    function addWhiteListForSwap(address[] calldata _protocol) external;

    // function addUserWhiteList(address[] calldata _user) external;
    function revokeWhiteList(address[] calldata _protocol) external;
    function revokeWhiteListOfSwap(address[] calldata _protocol) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/IAccessControl.sol";
interface IAdmin is IAccessControl{
    function lpDeposit() external returns(bool);
    function admin() external returns(address);
    function operator() external returns(address);
    function Trigger() external returns(address);
    function POL() external  view returns(address);
    function Treasury() external view returns(address);
    function BShareBUSDVault() external returns(address);
    function bYSLVault() external returns(address);
    function USDyBUSDVault() external returns(address);
    function USDyVault() external returns(address);
    function xYSLBUSDVault() external returns(address);
    function xYSLVault() external returns(address);
    function xBUSDVault() external returns(address);
    function YSLBUSDVault() external returns(address);
    function YSLVault() external returns(address);
    function BShare() external returns(address);
    function bYSL() external returns(address);
    function USDs() external returns(address);
    function USDy() external returns(address);
    function YSL() external returns(address);
    function xYSL() external returns(address); 
    function USDyBUSD() external returns(address);
    function xBUSD() external returns(address);
    function xYSLS() external returns(address);
    function YSLS() external returns(address);
    function swapPage() external returns(address);
    function PhoenixNFT() external returns(address);
    function Opt1155() external returns(address);
    function EarlyAccess() external returns(address);
    function helperSwap() external returns(address);
    function optVaultFactory() external returns(address);
    function swap() external returns(address);
    function temporaryHolding() external returns(address);
    function whitelist() external returns(address);
    function Blacklist() external returns(address);
    function BUSD() external view returns(address);
    function WBNB() external returns(address);
    function BShareVault() external returns(address);
    function masterNTT() external returns (address);
    function biswapRouter() external returns (address);
    function ApeswapRouter() external returns (address);
    function pancakeRouter() external returns (address);
    function TeamAddress() external returns (address);
    function MasterChef() external returns (address);
    function Refferal() external returns (address);
    function liquidityProvider() external returns(address);
    function temporaryReferral() external returns(address);
    function initialize(address owner) external;
    function setLpDeposit(bool deposit) external;
    function setRefferal(address _refferal)  external;
    function setWBNB(address _WBNB) external;
    function setBUSD(address _BUSD) external;
    function setLiquidityProvider(address _liquidityProvider) external;
    function setWhitelist(address _whitelist) external;
    function setBlacklist(address _blacklist) external;
    function sethelperSwap(address _helperSwap) external;
    function setTemporaryHolding(address _temporaryHolding) external;
    function setSwap(address _swap) external;
    function setOptVaultFactory(address _optVaultFactory) external;
    function setEarlyAccess(address _EarlyAccess) external;
    function setOpt1155(address _Opt1155) external;
    function setPhoenixNFT(address _PhoenixNFT) external;
    function setSwapPage(address _swapPage) external;
    function setYSL(address _YSL) external;
    function setYSLS(address _YSLS) external;
    function setxYSLs(address _xYSLS) external;
    function setxYSL(address _xYSL) external;
    function setxBUSD(address _xBUSD) external;
    function setUSDy(address _USDy) external;
    function setUSDs(address _USDs) external;
    function setbYSL(address _bYSL) external;
    function setBShare(address _BShare) external;
    function setYSLVault(address _YSLVault) external;
    function setYSLBUSDVault(address _YSLBUSDVault) external;
    function setxYSLVault(address _xYSLVault) external;
    function setxBUSDVault(address _xBUSDVault) external;
    function setxYSLBUSDVault(address _xYSLBUSDVault) external;
    function setUSDyVault(address _USDyVault) external;
    function setUSDyBUSDVault(address _USDyBUSDVault) external;
    function setbYSLVault(address _bYSLVault) external;
    function setBShareBUSD(address _BShareBUSD) external;
    function setPOL(address setPOL) external;
    function setBShareVault(address _BShareVault) external;
    function setTrigger(address _Trigger) external;
    function setmasterNTT(address _masterntt) external;
    function setbiswapRouter(address _biswapRouter)external;
    function setApeswapRouter(address _ApeswapRouter)external;
    function setpancakeRouter(address _pancakeRouter)external;
    function setTeamAddress(address _TeamAddress)external;
    function setMasterChef(address _MasterChef)external;
    function setTemporaryReferral(address _temporaryReferral)external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IEvents{
    event Deposit(string Vault,address receiver,address user,uint amount, uint blocknumber,uint blockTimestamp);
    event Withdraw(string Vault,address receiver,address user,uint amount,uint blocknumber,uint blockTimestamp);
    event PurchaseORSell(string Vault,address user,uint amount,uint blocknumber,uint blockTimestamp);
    event OptDeposit(string Vault,address receiver,address user,uint amount,uint32 level,uint blocknumber,uint blockTimestamp);
    event Optwithdraw(string Vault,address receiver,address user,uint amount,uint blocknumber,uint blockTimestamp);
    event OptAdd(address token, bool isLptoken, bool isAuto, address smartchef,address strat,address instance,uint blocknumber,uint blockTimestamp);
    event OptAddCustomVaults(address token,address vault,uint blocknumber,uint blockTimestamp);
    event CalculateAPR(address vault, uint value,uint blocknumber,uint blockTimestamp);
    event BUSDcollected(uint busdCollected,uint blocknumber,uint blockTimestamp);
    event ControllerFee(address vault,uint amount,uint blocknumber,uint blockTimestamp);
    event OptimizationRewards(address optvault, address user, uint reward,uint blocknumber,uint blockTimestamp);
    event LottoDeposit(string Vault,address user, uint amount,uint blocknumber,uint blockTimestamp);
    event SetterForUint(string contractName,address contractAddress,uint previousValue, uint currentValue,uint blocknumber,uint blockTimestamp);
    event SetterForAddress(string contractName,address contractAddress,address previousAddress, address currentAddress,uint blocknumber,uint blockTimestamp);
    event SetterForReferrer(address user,address RefferAddress,uint blocknumber,uint blockTimestamp);
    event TaxAllocation(string contractName,address contractAddress,uint previousTax,uint currentTax, uint[] perviousAllocationTax,uint[] currentAllocationTax,uint blocknumber,uint blockTimestamp);
    event SetterForMultiplierLevel(string contractName,address contractAddress,uint level,uint multiplierLevel,uint amount, uint blocknumber,uint blockTimestamp);
    event OptMultiplier(string contractName, uint pid, uint32[] number,uint blocknumber,uint blockTimestamp);
    event OptMultiplierLevel(string contractName, address token, uint32[] multiplier,uint32[] deductionValue,uint blocknumber,uint blockTimestamp);
    event SetterForOptimizationTaxFee(string contractName,address contractAddress,uint[3] previousArray,uint[3] currentArray,uint blocknumber,uint blockTimestamp);
    event BiddingNFT(string contractName,address user, uint amount,uint totalAmount,uint blocknumber,uint blockTimestamp);
    event ClaimBID(string contractName, address user, uint wonAddress, uint totalAmount,uint blocknumber,uint blockTimestamp);
    event EndAuction(string contractName, bool rank, address TopofAuction,uint tokenId,uint blocknumber,uint blockTimestamp);
    event ResetNewAuction(string contractName, uint highestbid, address winnerofTokenID,uint biddingArray,uint blocknumber,uint blockTimestamp);
    event Buy(string contractName, uint counter,uint lockPeriod,uint blocknumber,uint blockTimestamp);
    event ReactivateNFT(string contractName, address user,uint userTokenID,uint blocknumber,uint blockTimestamp);
    event RewardDistribute(string contractName,address user, uint reward,uint TotalRewardPercentage,address UserReferrer, uint Leftamount,uint blocknumber,uint blockTimestamp);
    event RewardPercentage(string contractName, address user, uint128[3] amount,uint blocknumber,uint blockTimestamp);
    event Reward_Earning(address user, address beneficiary, uint amount, uint level,uint volume,uint blocknumber,uint blockTimestamp);
    event ReferralEarned(address user,uint blocknumber,uint blockTimestamp);
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/extensions/IERC20Metadata.sol)

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