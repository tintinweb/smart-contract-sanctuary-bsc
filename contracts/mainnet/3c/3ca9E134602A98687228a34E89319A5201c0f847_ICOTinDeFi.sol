// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface ITokenVesting{
    function createVestingSchedule(
        address _beneficiary,
        bool _revocable,
        uint256 _amount
    ) external;

    function getAdminAddress() external view returns(address);
}


/** TO-DO
    - Número de compradores en la fase (Individualizado) *
    - Target (inversión en $) para finalizar la ronda *
    - Whitelist
*/

contract ICOTinDeFi is AccessControl, Pausable, ReentrancyGuard{
    using SafeERC20 for IERC20;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant COLLAB_ROLE = keccak256("COLLAB_ROLE");

    bytes32 public constant NORMAL_REFERRAL = keccak256("NORMAL_REFERRAL");
    bytes32 public constant CAPITAL_REFERRAL = keccak256("CAPITAL_REFERRAL");
    bytes32 public constant SUB_REFERRAL_CAPITAL = keccak256("SUB_REFERRAL_CAPITAL");
    bytes32 public constant SUB_REFERRAL_NORMAL = keccak256("SUB_REFERRAL_NORMAL");

    IERC20 immutable private TinDeFiToken;
    ITokenVesting private TokenVesting;
    address private vestingAddress;

    address private ICOWallet;

    struct referralInfo{
        bytes32 refType;
        address reciever;
        uint256 totalPerc;
        uint256 percTokens;
        uint256 percBUSD;
        bool active;
        string superCode;
        uint256 superCut;
    }

    struct buyInfo{
        uint256 timeStamp;
        uint256 weiPerToken;
        uint256 busdAmount;
        uint256 tinAmount;
    }

    struct raised{
        uint256 busdRaised;
        uint256 tokensBought;
    }

    mapping(uint256 => uint256) public weiPerTokenPerPhase;
    mapping(uint256 => uint256) public totalTokensSalePerPhase;
    mapping(uint256 => uint256) public tokensSoldPerPhase;
    mapping(string => referralInfo) private referrals;
    mapping(address => buyInfo[]) public buysPerUser;
    uint256 public currentPhase;
    bool private icoEnded;
    bool private buyCodeInactive;

    mapping(uint256 => uint256) public buyersPerPhase;
    uint256 public totalRaised;
    mapping(uint256 => raised) public raisedPerPhase;
    mapping(uint256 => uint256) public targetICOPerPhase;

    address private BUSD;

    event weiPerTokenChanged(uint256 indexed phase, uint256 indexed weiPerToken);
    event totalTokensSaleChanged(uint256 indexed phase, uint256 indexed totalTokensSale);
    event totalTokensSoldChanged(uint256 indexed phase, uint256 indexed totalTokensSold);
    event icoStatus(bool indexed icoStatus);
    event busdContractChanged(address indexed BUSD);
    event phaseAdded(uint256 indexed phase ,uint256 weiPerToken, uint256 indexed totalTokensSale);
    event phaseChanged(uint256 indexed newPhase);
    event tokensBought(uint256 indexed tokenAmount, address indexed buyer);

    modifier whenICOActive(){
        require(!icoEnded, "ICO has ended");
        _;
    }

    modifier buyCodeCorrect(string calldata code){
        require(buyCodeInactive || referrals[code].active, "The code provided is not correct or active");
        _;
    }

    constructor(address TinToken, address _vestingAddress, address _busdAddress, address _ICOWallet){
        TinDeFiToken = IERC20(TinToken);
        TokenVesting = ITokenVesting(_vestingAddress);
        vestingAddress = _vestingAddress;
        
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(COLLAB_ROLE, msg.sender);

        ICOWallet = _ICOWallet;
        icoEnded = false;
        BUSD = _busdAddress;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function buyTokens(uint256 tokenAmount, string calldata buyCode) public whenICOActive buyCodeCorrect(buyCode) nonReentrant{
        require(tokensSoldPerPhase[currentPhase] + tokenAmount <= totalTokensSalePerPhase[currentPhase], "Max tokens sold for this phase surpassed");
        require(TinDeFiToken.balanceOf(vestingAddress) >= tokenAmount, "Not enough tokens in the contract, transfer more tokens to vesting contract");

        uint256 amountBUSDToBuy = tokenAmount * weiPerTokenPerPhase[currentPhase];
        referralInfo memory refInfo = referrals[buyCode];

        require(IERC20(BUSD).balanceOf(msg.sender) >= amountBUSDToBuy, "User has less BUSD than the amount he is triying to buy");

        if(refInfo.refType == CAPITAL_REFERRAL){
            buyCodeCapital(refInfo, amountBUSDToBuy, tokenAmount);
        }else if(refInfo.refType == NORMAL_REFERRAL){
            buyCodeNormal(refInfo, amountBUSDToBuy, tokenAmount);
        }else if(refInfo.refType == SUB_REFERRAL_CAPITAL){
            buyCodeSubRefCapital(refInfo, amountBUSDToBuy, tokenAmount);
        }else if(refInfo.refType == SUB_REFERRAL_NORMAL){
            buyCodeSubRefNormal(refInfo, amountBUSDToBuy, tokenAmount);
        }
        else{
            TokenVesting.createVestingSchedule(msg.sender, true, tokenAmount);
            IERC20(BUSD).transferFrom(msg.sender, ICOWallet, amountBUSDToBuy);
            buysPerUser[msg.sender].push(buyInfo(block.timestamp, weiPerTokenPerPhase[currentPhase], amountBUSDToBuy, tokenAmount));
        }
        tokensSoldPerPhase[currentPhase] += tokenAmount;
        buyersPerPhase[currentPhase] += 1;
        totalRaised += amountBUSDToBuy;
        raisedPerPhase[currentPhase] = raised(raisedPerPhase[currentPhase].busdRaised+amountBUSDToBuy, raisedPerPhase[currentPhase].tokensBought+tokenAmount);

        emit tokensBought(tokenAmount, msg.sender);
    }

    function buyCodeCapital(referralInfo memory _refInfo, uint256 _amountBusd, uint256 _tokenAmount) private{
        uint256 busdReferral = (((_amountBusd * _refInfo.totalPerc) / 100) * _refInfo.percBUSD) / 100;
        uint256 busdProtocol = _amountBusd - busdReferral;

        uint256 totalToDeductTokens = (_tokenAmount * _refInfo.totalPerc) / 100;
        uint256 tinReferral = ((totalToDeductTokens) * _refInfo.percTokens) / 100;
        uint256 tinBuyer = _tokenAmount - totalToDeductTokens;

        if(busdReferral > 0){
            IERC20(BUSD).transferFrom(msg.sender, _refInfo.reciever, busdReferral);
        }
        IERC20(BUSD).transferFrom(msg.sender, ICOWallet, busdProtocol);

        if(tinReferral > 0){
            TokenVesting.createVestingSchedule(_refInfo.reciever, true, tinReferral);
        }
        TokenVesting.createVestingSchedule(msg.sender, true, tinBuyer);

        buysPerUser[msg.sender].push(buyInfo(block.timestamp, weiPerTokenPerPhase[currentPhase], _amountBusd, tinBuyer));
    }

    function buyCodeNormal(referralInfo memory _refInfo, uint256 _amountBusd, uint256 _tokenAmount) private{
        uint256 busdReferral = (((_amountBusd * _refInfo.totalPerc) / 100) * _refInfo.percBUSD) / 100;
        uint256 busdProtocol = _amountBusd - busdReferral;

        uint256 totalToDeductTokens = (_tokenAmount * _refInfo.totalPerc) / 100;
        uint256 tinReferral = ((totalToDeductTokens) * _refInfo.percTokens) / 100;
        uint256 tinBuyer = _tokenAmount;

        if(busdReferral > 0){
            IERC20(BUSD).transferFrom(msg.sender, _refInfo.reciever, busdReferral);
        }
        IERC20(BUSD).transferFrom(msg.sender, ICOWallet, busdProtocol);

        if(tinReferral > 0){
            TokenVesting.createVestingSchedule(_refInfo.reciever, true, tinReferral);
        }
        TokenVesting.createVestingSchedule(msg.sender, true, tinBuyer);

        buysPerUser[msg.sender].push(buyInfo(block.timestamp, weiPerTokenPerPhase[currentPhase], _amountBusd, _tokenAmount));
    }

    function buyCodeSubRefCapital(referralInfo memory _refInfo, uint256 _amountBusd, uint256 _tokenAmount) private{
        referralInfo memory superInfo = referrals[_refInfo.superCode];
        require(superInfo.active, "The superior level referral is deactivated");
        uint256 busdReferral = (((_amountBusd * _refInfo.totalPerc) / 100) * _refInfo.percBUSD) / 100;
        uint256 busdProtocol = _amountBusd - busdReferral;

        uint256 totalToDeductTokens = (_tokenAmount * _refInfo.totalPerc) / 100;
        uint256 tinReferral = ((totalToDeductTokens) * _refInfo.percTokens) / 100;
        uint256 tinBuyer = _tokenAmount - totalToDeductTokens;

        if(busdReferral > 0){
            uint256 busdSuper = (busdReferral * _refInfo.superCut) / 100;
            IERC20(BUSD).transferFrom(msg.sender, superInfo.reciever, busdSuper);
            IERC20(BUSD).transferFrom(msg.sender, _refInfo.reciever, busdReferral - busdSuper);
        }
        IERC20(BUSD).transferFrom(msg.sender, ICOWallet, busdProtocol);

        if(tinReferral > 0){
            uint256 tinSuper = (tinReferral * _refInfo.superCut) / 100;
            TokenVesting.createVestingSchedule(superInfo.reciever, true, tinSuper);
            TokenVesting.createVestingSchedule(_refInfo.reciever, true, tinReferral - tinSuper);
        }
        TokenVesting.createVestingSchedule(msg.sender, true, tinBuyer);

        buysPerUser[msg.sender].push(buyInfo(block.timestamp, weiPerTokenPerPhase[currentPhase], _amountBusd, tinBuyer));
    }

    function buyCodeSubRefNormal(referralInfo memory _refInfo, uint256 _amountBusd, uint256 _tokenAmount) private{
        referralInfo memory superInfo = referrals[_refInfo.superCode];
        require(superInfo.active, "The superior level referral is deactivated");
        uint256 busdReferral = (((_amountBusd * _refInfo.totalPerc) / 100) * _refInfo.percBUSD) / 100;
        uint256 busdProtocol = _amountBusd - busdReferral;

        uint256 totalToDeductTokens = (_tokenAmount * _refInfo.totalPerc) / 100;
        uint256 tinReferral = ((totalToDeductTokens) * _refInfo.percTokens) / 100;
        uint256 tinBuyer = _tokenAmount;

        if(busdReferral > 0){
            uint256 busdSuper = (busdReferral * _refInfo.superCut) / 100;
            IERC20(BUSD).transferFrom(msg.sender, superInfo.reciever, busdSuper);
            IERC20(BUSD).transferFrom(msg.sender, _refInfo.reciever, busdReferral - busdSuper);
        }
        IERC20(BUSD).transferFrom(msg.sender, ICOWallet, busdProtocol);

        if(tinReferral > 0){
            uint256 tinSuper = (tinReferral * _refInfo.superCut) / 100;
            TokenVesting.createVestingSchedule(superInfo.reciever, true, tinSuper);
            TokenVesting.createVestingSchedule(_refInfo.reciever, true, tinReferral - tinSuper);
        }
        TokenVesting.createVestingSchedule(msg.sender, true, tinBuyer);

        buysPerUser[msg.sender].push(buyInfo(block.timestamp, weiPerTokenPerPhase[currentPhase], _amountBusd, tinBuyer));
    }

    function getCountBuysPerUser(address user) public view returns(uint256){
        return buysPerUser[user].length;
    }

    function getRate(uint256 tokenAmount) public view returns(uint256){
        uint256 amountBUSDToBuy = tokenAmount * weiPerTokenPerPhase[currentPhase];
        return amountBUSDToBuy;
    }

    function getBUSD() public view returns(uint256){
        return IERC20(BUSD).balanceOf(msg.sender);
    }

    function addReferral(string calldata _code, bytes32 _refType, address _reciever, uint256 _totalPerc, uint256 _percTokens, uint256 _percBUSD, string memory _superCode, uint256 _superCut) public onlyRole(COLLAB_ROLE){
        require(_percTokens + _percBUSD == 100, "Percent doesn't add to 100%");
        referrals[_code] = referralInfo(
                            _refType,
                            _reciever,
                            _totalPerc,
                            _percTokens,
                            _percBUSD,
                            true,
                            _superCode,
                            _superCut);
    }

    function deactivateReferral(string calldata _code) public onlyRole(ADMIN_ROLE){
        referrals[_code].active = false;
    }
    
    function getAdminAddress() external view returns(address){
        return TokenVesting.getAdminAddress();
    }

    function withdrawTokens() public onlyRole(ADMIN_ROLE){
        payable(msg.sender).transfer(address(this).balance);
        TinDeFiToken.transfer(msg.sender, TinDeFiToken.balanceOf(address(this)));
    }

    function addPhaseParams(uint256 _phase, uint256 _weiPerTokenPerPhase, uint256 _totalTokensSalePerPhase) public onlyRole(ADMIN_ROLE){
        weiPerTokenPerPhase[_phase] = _weiPerTokenPerPhase;
        totalTokensSalePerPhase[_phase] = _totalTokensSalePerPhase;
        tokensSoldPerPhase[_phase] = 0;
        targetICOPerPhase[_phase] = _totalTokensSalePerPhase * _weiPerTokenPerPhase;
        emit phaseAdded(_phase, _weiPerTokenPerPhase, _totalTokensSalePerPhase);
    }
    function changePhase(uint256 _newPhase) public onlyRole(ADMIN_ROLE){
        currentPhase = _newPhase;
        emit phaseChanged(_newPhase);
    }

    function adjustWeiPerToken(uint256 _phase, uint256 _weiPerToken) public onlyRole(ADMIN_ROLE){
        weiPerTokenPerPhase[_phase] = _weiPerToken;
        targetICOPerPhase[_phase] = totalTokensSalePerPhase[_phase] * _weiPerToken;
        emit weiPerTokenChanged(_phase, _weiPerToken);
    }

    function adjustTotalTokensSale(uint256 _phase, uint256 _totalTokensSale) public onlyRole(ADMIN_ROLE){
        totalTokensSalePerPhase[_phase] = _totalTokensSale;
        targetICOPerPhase[_phase] = _totalTokensSale * weiPerTokenPerPhase[_phase];
        emit totalTokensSaleChanged(_phase, _totalTokensSale);
    }

    function adjustTokensSoldPerPhase(uint256 _phase, uint256 _tokensSold) public onlyRole(ADMIN_ROLE){
        tokensSoldPerPhase[_phase] = _tokensSold;
        emit totalTokensSoldChanged(_phase, _tokensSold);
    }

    function endICO(bool _endICO) public onlyRole(ADMIN_ROLE){
        icoEnded = _endICO;
        emit icoStatus(icoEnded);
    }

    function changeBUSDContract(address _BUSD) public onlyRole(ADMIN_ROLE){
        BUSD = _BUSD;
        emit busdContractChanged(BUSD);
    }

    function changeVestingContract(address _newVesting) public onlyRole(ADMIN_ROLE){
        TokenVesting = ITokenVesting(_newVesting);
        vestingAddress = _newVesting;
    }

    function getWeiPerTokenPerPhase(uint256 _phase) public view returns(uint256){
        return weiPerTokenPerPhase[_phase];
    }

    function getReferral(string calldata code) public view returns(referralInfo memory){
        return referrals[code];
    }


    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function setRoleAdmin(bytes32 role, bytes32 adminRole) public onlyRole(DEFAULT_ADMIN_ROLE){
        _setRoleAdmin(role, adminRole);
    }


    function setICOWallet(address newWallet) public onlyRole(DEFAULT_ADMIN_ROLE){
        require(newWallet != address(0), "Cant set ICO wallet to address 0");
        ICOWallet = newWallet;
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
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

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
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
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
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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