// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../Interfaces/IWhitelist.sol";
import "../Interfaces/IReceipt.sol";
import "../Interfaces/IReferralNFT.sol";
import "../Interfaces/IAdmin.sol";
import "../Interfaces/IEvents.sol";
import "../Interfaces/IBlacklist.sol";
import "../Interfaces/IPhoenixNft.sol";
/**
@dev This contract is for BSHARE-BUSD vault.
 */
contract BSHAREBUSDVault is Initializable, ReentrancyGuard, Pausable, IEvents {
    using SafeERC20 for IERC20;

    uint256 public depositTax;//setting deposit tax as uint
    uint256 public withdrawTax; // uint of withdraw tax
    uint256 public exchangeRatio; //setting exchange ratio as uint
    uint256 public currentReward;
    uint256 public percentBSHARE;
    address public router;// router address
    address public BSHAREBUSD_A;//Reciept address
    address public BSHAREBUSD;//Pair address
    address public BUSD;
    address public USDy;
    address public BShare;
    bool public completePause;
    uint public totalDeposit;

    mapping(address => uint256) public ss;
    mapping(address => uint256) public UserDeposit;
    mapping(address => uint) public restrictTransfer; // last block number when interacted
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    IAdmin public Admin;
    mapping(uint256 => uint256) public epochReward;

    modifier _isAdmin(){
        require(Admin.hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        _;
    }

    modifier _lastExchangeRatio(){
        uint256 lastExchangeRatio = exchangeRatio;
        _;
        if(lastExchangeRatio > exchangeRatio){
            _pause();
        }
    }

    modifier _completePause(){
        require(completePause == false,"completely Paused");
        _;
    }

    modifier _securityCheck(address user, address sendto){
        require(!(IBlacklist(Admin.Blacklist()).getAddresses(msg.sender)), "BSHAREBUSDVault:Blacklisted");
        require(IWhitelist(Admin.whitelist()).getAddresses(msg.sender) || user == msg.sender);
        if(_isContract(msg.sender)){
            require(IWhitelist(Admin.whitelist()).getAddresses(msg.sender),"BSHAREBUSDVault:ExternalInteraction");
        }
        if(!IWhitelist(Admin.whitelist()).getAddresses(user)) {
            require(restrictTransfer[user] != block.number, "BSHAREBUSDVault:SameBlock");
        }
        _;
    }
    
    /**
    @dev one time call while deploying
    */

    function initialize(address _admin, address _lp) external initializer {
        Admin = IAdmin(_admin);
        BSHAREBUSD = _lp;
        router = Admin.ApeswapRouter();
        BSHAREBUSD_A = Clones.clone(Admin.masterNTT());
        IReceipt(BSHAREBUSD_A).initialize(_admin,address(this), "BSHARE-LP", "BSHARE-LP");
        depositTax = 10;
        exchangeRatio = 10**18;
        BUSD = Admin.BUSD();
        USDy = Admin.USDy();
        BShare = Admin.BShare();
    }

    

    /**
    @dev Deposit Function used for depositing LP token.
    @param user , User address as parameter.
    @param amount , amount of LP as parameter.
     */

function deposit(address user, uint amount,bool isBUSD) nonReentrant external _lastExchangeRatio whenNotPaused _completePause _securityCheck(user,user){
        require(amount > 0,"BSHAREBUSDVault:0");
        require(isBUSD,"BSHAREBUSDVault:BUSD");
        if(rewards(user) > 0){
            _claimRebaseReward(user);
        } else {
            ss[user] = currentReward;
        }
        IERC20(BUSD).safeTransferFrom(user, address(this), amount);
        _tax(amount);

        uint reserveBshare = IERC20(BShare).balanceOf(
            address(BSHAREBUSD)
        );
        uint reservesBUSD = IERC20(BUSD).balanceOf(address(BSHAREBUSD));
        uint BshareRequire = (reserveBshare * amount * 30)/(reservesBUSD * 100);
        uint USDyLiquidity = (IERC20(USDy).balanceOf(Admin.USDyBUSD()) * (amount * 1/2)/ IERC20(BUSD).balanceOf(Admin.USDyBUSD()));
        uint USDyPrice  = IReceipt(USDy).mintByPrice();
        uint USDyAmount;
        if (IERC20(BShare).balanceOf(address(this)) >= BshareRequire) {
            percentBSHARE = 30;
            USDyAmount = ((2 * amount * (10 ** 18))/USDyPrice);
            IReceipt(USDy).mint(address(this), USDyLiquidity + USDyAmount);
            _convertBUSDToLP(amount * percentBSHARE/100, (reserveBshare * (amount * percentBSHARE/100)) / reservesBUSD, BUSD, BShare, address(BSHAREBUSD));
        }
        else{
            percentBSHARE = 15;
            USDyAmount = (amount * (10**18)) / USDyPrice;
            address[] memory path = new address[](2);
            path[0] = BUSD;
            path[1] = BShare;
            IERC20(BUSD).safeApprove(router, (amount * percentBSHARE/100));
            _swap(
                (amount * percentBSHARE/100),
                path,
                address(this)
            );
            reservesBUSD = IERC20(BUSD).balanceOf(address(BSHAREBUSD));
            IReceipt(USDy).mint(address(this), USDyLiquidity + (amount* (10 ** 18)/USDyPrice));
            if(IERC20(BShare).balanceOf(address(this)) <= (reserveBshare * amount * percentBSHARE)/(reservesBUSD * 100)){
                    _convertBUSDToLP(reservesBUSD * IERC20(BShare).balanceOf(address(this)) / reserveBshare, 
                    IERC20(BShare).balanceOf(address(this)),
                    BUSD, BShare, address(BSHAREBUSD));
                    

            }else{
                _convertBUSDToLP(amount * percentBSHARE/100, 
                    (reserveBshare * amount * percentBSHARE)/(reservesBUSD * 100),
                    BUSD, BShare, address(BSHAREBUSD));
                    IReceipt(BShare).burn(address(this),IERC20(BShare).balanceOf(address(this)));
              
            }
        }
        _convertBUSDToLP((amount * 1/2), USDyLiquidity,BUSD, USDy, Admin.USDyBUSD());
        IERC20(BUSD).safeTransfer(Admin.TeamAddress(), IERC20(BUSD).balanceOf(address(this)));
        exchangeRatio = exchangeRatio == 0 ? 10 ** 18 : exchangeRatio;
        restrictTransfer[msg.sender]= block.number;
        IReceipt(BSHAREBUSD_A).mint(address(this),(USDyAmount * (100 - depositTax) * (10 ** 18))/ (exchangeRatio * 100));
        UserDeposit[user] += (USDyAmount * (100 - depositTax) * (10 ** 18))/ (exchangeRatio * 100);
        totalDeposit += USDyAmount;
        exchangeRatio = totalDeposit * (10 ** 18)/(IERC20(BSHAREBUSD_A).totalSupply());
        emit Deposit("BSHAREBUSD Vault",address(this),user,amount,block.number,block.timestamp);
    }

    function withdraw(address user,uint _amount,address sendTo) external whenNotPaused{
        require(!Admin.buyBackActivation(),"Cannot withdraw while buyBack");
        _withdraw(user, _amount, sendTo);
    }

    function distribute(uint256 _rebaseReward) external nonReentrant{
        require(msg.sender == Admin.USDyVault());
        if(IERC20(BSHAREBUSD_A).totalSupply() != 0){
            currentReward = currentReward + ((_rebaseReward * 10 ** 18)/(IERC20(BSHAREBUSD_A).totalSupply()));
        }
    }

    /**
    @dev Setter Function for depositTax
    @param _depositTax , depositTax amount as parameter.
    */

    function setDepositTax(uint _depositTax) external _isAdmin {
        require(_depositTax != 0, "TaxZero");
        emit SetterForUint(
            "BSHAREBUSDVault",
            address(this),
            depositTax,
            _depositTax,
            block.number,
            block.timestamp
        );
        depositTax = _depositTax;
    }

    function setWithdrawTax(uint _withdrawTax) external _isAdmin {
        require(_withdrawTax != 0, "Taxzero");
        withdrawTax = _withdrawTax;
    }
    function setPause(bool _isPaused) external nonReentrant _isAdmin{
        _isPaused == true? _pause() : _unpause();
    }

    function setCompletePause(bool _completePause) external nonReentrant _isAdmin{
        completePause = _completePause;
    }

    function setRouter(address _router) external _isAdmin{
        require(_router != address(0),"YSL: InvalidData");
        router = _router;
    }

    function emergencyWithdraw() external{
        require(!Admin.buyBackActivation(),"YSL-BUSD: Can't withdraw");
        require(UserDeposit[msg.sender] != 0,"YSL-BUSD: Nothing to withdraw");
        _withdraw(msg.sender, UserDeposit[msg.sender], msg.sender);
    }

    function setBSHAREBUSD(address _BUSDBUSD) external _isAdmin{
        require(_BUSDBUSD != address(0),"YSL-BUSD: InvalidData");
        BSHAREBUSD = _BUSDBUSD;
    }

    /**
    @dev The user can get Bshare Receipt token  by calling this function
    */

    function receiptToken() external view returns (address) {
        return BSHAREBUSD_A;
    }


    /**
        @dev Function is used to claim Rebase Reward
    */
    function claimReward(address user) public nonReentrant whenNotPaused _completePause _securityCheck(user,user){
        _claimRebaseReward(user);
    }


    /**
    @dev The user will get his rewards through this function 
    @param user, address of user 
    */
    function rewards(address user) public view returns (uint reward){
        uint rewardShare = ss[user];
        uint epoch;
        uint epochDuration = Admin.epochDuration();
        IPhoenixNft PhoenixNFT = IPhoenixNft(Admin.PhoenixNFT());
        if(address(PhoenixNFT) != address(0) && IReceipt(address(PhoenixNFT)).balanceOf(user) >= 1){
            if(block.timestamp > (PhoenixNFT.MintTimestamp(PhoenixNFT.Won(msg.sender)) + (PhoenixNFT.expiryTime() * epochDuration))){
                uint m = (Admin.lastEpoch() - (PhoenixNFT.MintTimestamp(PhoenixNFT.Won(msg.sender))) + (PhoenixNFT.expiryTime() * epochDuration)) % epochDuration;
                uint y = epochDuration - m;
                epoch = (PhoenixNFT.MintTimestamp(PhoenixNFT.Won(msg.sender)) + (PhoenixNFT.expiryTime() * epochDuration)) - y;
                reward = (UserDeposit[user] * (epochReward[epoch] - rewardShare)) / 10 **18;
                reward = (reward + (reward / 4));
                rewardShare = epochReward[epoch];
                reward += (UserDeposit[user] * (currentReward - rewardShare)) / 10 **18;
            }
            else{
                epoch = Admin.lastEpoch();
                reward = (UserDeposit[user] * (epochReward[epoch] - ss[user])) / 10 **18;
                reward = (reward + (reward / 4));
            }
        }
        else{
            reward = (UserDeposit[user] * (currentReward - rewardShare)) / 10 **18;
        }

    }

    /**
    @dev Withdraw Function used for Withdrawal of Reciept.
    @param user , user address as parameter.
    @param _amount ,withdraw amount as parameter.
    */

    function _withdraw(address user,uint _amount,address sendTo) nonReentrant internal _lastExchangeRatio _completePause _securityCheck(user,sendTo){
        require(_amount <= UserDeposit[user],"BSHAREBUSDVault: InvalidData");
        address[] memory path = new address[](2);
        path[0] = USDy;
        path[1] = BUSD;
        if (Admin.buyBackActivation()) {
            if (
                Admin.buyBackActivationEpoch() + (3 * Admin.epochDuration()) <
                block.timestamp
            ) {
                98 * 10**16 <=
                    IUniswapV2Router02(router).getAmountsOut(10**18, path)[1]
                    ? Admin.setBuyBackActivation(false)
                    : Admin.setBuyBackActivationEpoch();
            }
        }else{
            if (
                !Admin.buyBackOwnerActivation() &&
                Admin.buyBackActivationEpoch() + (3 * Admin.epochDuration()) <
                block.timestamp &&
                98 * 10**16 >
                IUniswapV2Router02(router).getAmountsOut(10**18, path)[1]
            ) {
                Admin.setBuyBackActivation(true);
            }
        }
        if(rewards(user) > 0){
            _claimRebaseReward(user);
        }
        uint balance = (_amount * exchangeRatio)/10 ** 18;
        IERC20(USDy).safeTransfer(sendTo,balance * (100- withdrawTax)/100); 
        totalDeposit -= balance * (100- withdrawTax)/100;
        IReceipt(BSHAREBUSD_A).burn(address(this),_amount);
        UserDeposit[user] -= _amount;
        restrictTransfer[msg.sender]= block.number; 
        exchangeRatio = totalDeposit * (10 ** 18)/(IERC20(BSHAREBUSD_A).totalSupply());
        emit Withdraw("BSHAREBUSDVault",address(this),user, _amount,block.number,block.timestamp);     

    }
    

    function _convertBUSDToLP(uint amountBUSD,uint amountToken2,address path0,address path1,address lp) internal{
        IERC20(path0).approve(router, amountBUSD);
        IERC20(path1).approve(router, amountToken2);
        IUniswapV2Router02(router).addLiquidity(
            path0,
            path1,
            amountBUSD,
            amountToken2,
            1,
            1,
            Admin.Treasury(),
            block.timestamp + 1678948210
        );
    }


    function _swap(uint256 amount, address[] memory path, address sendTo) internal returns(uint){
        uint amountOut = IUniswapV2Router02(router).swapExactTokensForTokens( 
            amount,
            0,
            path,
            sendTo,
            block.timestamp + 1000
        )[path.length - 1];
        return amountOut;
    }
    

    function _claimRebaseReward(address user) internal {
        IERC20(USDy).safeTransfer(user, rewards(user));
        ss[user] = currentReward; 
    }

    

    function _tax(uint amount) internal {
        address[] memory path = new address[](2);
        path[0] = USDy;
        path[1] = BUSD;
        if (Admin.buyBackActivation()) {
            if (
                Admin.buyBackActivationEpoch() + (3 * Admin.epochDuration()) <
                block.timestamp
            ) {
                98 * 10**16 <=
                    IUniswapV2Router02(router).getAmountsOut(10**18, path)[1]
                    ? Admin.setBuyBackActivation(false)
                    : Admin.setBuyBackActivationEpoch();
            }
            IERC20(BUSD).safeTransfer(
                Admin.TeamAddress(),
                (amount * 20 * 25) / 10000
            );
            path[0] = BUSD;
            path[1] = USDy;
            IERC20(BUSD).safeApprove(router, (amount * 20 * 75) / 10000);
            uint amountOut = IUniswapV2Router02(router)
                .swapExactTokensForTokens(
                    (amount * 20 * 75) / 10000,
                    0,
                    path,
                    address(this),
                    block.timestamp + 1000
                )[path.length - 1];
            IReceipt(USDy).burn(address(this), amountOut);
        } else {
            if (
                !Admin.buyBackOwnerActivation() &&
                Admin.buyBackActivationEpoch() + (3 * Admin.epochDuration()) <
                block.timestamp &&
                98 * 10**16 >
                IUniswapV2Router02(router).getAmountsOut(10**18, path)[1]
            ) {
                Admin.setBuyBackActivation(true);
            }
            IERC20(BUSD).safeTransfer(Admin.Treasury(), amount / 10);
            IReceipt(Admin.bYSL()).calculateProtocolPrice();
            (uint256 BUSDAmount, uint256 leftAmount) = IReferralNFT(
                Admin.Refferal()
            ).rewardDistribution(msg.sender, (amount * 9) / 100, amount);
            if (BUSDAmount != 0) {
                IERC20(BUSD).safeTransfer(msg.sender, (amount * 1) / 100);
                IERC20(BUSD).safeTransfer(Admin.Refferal(), BUSDAmount);
            } else {
                IERC20(BUSD).safeTransfer(
                    Admin.TeamAddress(),
                    (amount * 1) / 100
                );
            }
            if (leftAmount != 0) {
                IERC20(BUSD).safeTransfer(Admin.TeamAddress(), leftAmount);
            }
        }
    }

    function _isContract(address _addr) internal view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function burnOrRemove(uint amount, uint zeroOrOne) external _isAdmin{
        require( zeroOrOne <= 1,"InvalidData");
        if(zeroOrOne == 0){
            IReceipt(Admin.YSL()).burn(address(this),amount);
        }
        else{
            IERC20(Admin.YSL()).transfer(msg.sender,amount);

        }
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
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
// OpenZeppelin Contracts v4.4.0 (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IReceipt {
    function mint(address account, uint amount) external;
    function burn(address account, uint amount) external;
    function setOperator(address _operator) external;
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function mintByPrice() external  returns(uint);
    function initialize(address _admin, address operator, string memory name_, string memory symbol_) external;
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) ;
    function calculateProtocolPrice() external returns(uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IReferralNFT{
    function rewardDistribution(address user, uint _reward, uint volume) external returns(uint amount, uint leftAmount);
    function getReferrer(address user) external returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/IAccessControl.sol";
interface IAdmin is IAccessControl{
    function lpDeposit() external view returns(bool);
    function admin() external view returns(address);
    function operator() external view returns(address);
    function Trigger() external view returns(address);
    function POL() external  view returns(address);
    function Treasury() external view returns(address);
    function BShareBUSDVault() external view returns(address);
    function bYSLVault() external view returns(address);
    function USDyBUSDVault() external view returns(address);
    function USDyVault() external view returns(address);
    function xYSLBUSDVault() external view returns(address);
    function xYSLVault() external view returns(address);
    function xBUSDVault() external view returns(address);
    function YSLBUSDVault() external view returns(address);
    function YSLVault() external view returns(address);
    function BShare() external view returns(address);
    function bYSL() external view returns(address);
    function USDs() external view returns(address);
    function USDy() external view returns(address);
    function YSL() external view returns(address);
    function xYSL() external view returns(address); 
    function USDyBUSD() external view returns(address);
    function xBUSD() external view returns(address);
    function xYSLS() external view returns(address);
    function YSLS() external view returns(address);
    function swapPage() external view returns(address);
    function PhoenixNFT() external view returns(address);
    function Opt1155() external view returns(address);
    function EarlyAccess() external view returns(address);
    function helperSwap() external view returns(address);
    function optVaultFactory() external view returns(address);
    function swap() external view returns(address);
    function temporaryHolding() external view returns(address);
    function whitelist() external view returns(address);
    function Blacklist() external view returns(address);
    function BUSD() external view returns(address);
    function WBNB() external view returns(address);
    function BShareVault() external view returns(address);
    function masterNTT() external view returns (address);
    function biswapRouter() external view returns (address);
    function ApeswapRouter() external view returns (address);
    function pancakeRouter() external view returns (address);
    function TeamAddress() external view returns (address);
    function MasterChef() external view returns (address);
    function Refferal() external view returns (address);
    function liquidityProvider() external view returns(address);
    function temporaryReferral() external view returns(address);
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
    function USDyBUSDRebalancer()external returns(address);
    function BSHAREBUSDRebalancer()external returns(address);
    function BUSDVault()external returns(address);
    function setUSDyBUSDRebalancer(address _USDyBUSDRebalancer)external;
    function setBSHAREBUSDRebalancer(address _BSHAREBUSDRebalancer)external;
    function setBUSDVault(address _BUSDVault)external;
    function setBuyBackActivation(bool _value) external;
    function buyBackActivation() external view returns(bool);
    function buyBackActivationEpoch() external view returns(uint);
    function epochDuration() external view returns(uint);
    function lastEpoch() external view returns(uint);
    function setLastEpoch() external;
    function setEpochDuration(uint _time) external;
    function setUSDyBUSD(address _usdyBusd) external;
    function setBuyBackActivationEpoch() external;
    function vaultsAddresses() external view returns(address[] memory);
    function customVaultMaster() external view returns(address);
    function buyBackOwnerActivation() external view returns(bool);
    function DAI() external view returns(address);
    function USDC() external view returns(address);
    function USDT() external view returns(address);
    function DAIVault() external view returns(address);
    function USDCVault() external view returns(address);
    function USDTVault() external view returns(address);
    function setDAI() external view returns(address);
    function setUSDC() external view returns(address);
    function setUSDT() external view returns(address);
    function setDAIVault() external view returns(address);
    function setUSDCVault() external view returns(address);
    function setUSDTVault() external view returns(address);


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
    event BiddingNFT(string contractName,address user, uint amount,uint totalAmount,uint blocknumber,uint blockTimestamp,uint tokenID);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IBlacklist {
    function getAddresses(address _protocol) external view returns(bool);
    function addBlacklist(address[] calldata _protocol) external;
    function revokeBlacklist(address[] calldata _protocol) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
interface IPhoenixNft is IERC721{
    enum Nft_status {
        INACTIVE,
        ACTIVE
    }
    function expiryTime() external view returns(uint256);
    function MintTimestamp(uint256 tokenid) external view returns(uint256);
    function Winner(uint256 tokenid) external view returns(uint256);
    function Won(address user) external view returns(uint256);
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
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

pragma solidity ^0.8.0;

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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
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