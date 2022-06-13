pragma solidity ^0.8.0;
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) { return functionCall(target, data, "Address: low-level call failed"); }
    function functionCall( address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) { return functionCallWithValue(target, data, 0, errorMessage); }
    function functionCallWithValue( address target, bytes memory data, uint256 value ) internal returns (bytes memory) { return functionCallWithValue( target, data, value, "Address: low-level call with value failed");}
    function functionCallWithValue( address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value,"Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) { return functionStaticCall( target, data, "Address: low-level static call failed"); }
    function functionStaticCall( address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) { return functionDelegateCall( target, data, "Address: low-level delegate call failed" ); }
    function functionDelegateCall( address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult( bool success, bytes memory returndata, string memory errorMessage ) private pure returns (bytes memory) {
        if (success) { return returndata;} else {
            if (returndata.length > 0) {
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender;}
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) { return interfaceId == type(IERC165).interfaceId; }
}
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }
    mapping(bytes32 => RoleData) private _roles;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool){
        return
            interfaceId == type(IAccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    function hasRole(bytes32 role, address account) public view override returns (bool) { return _roles[role].members[account]; }
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) { return _roles[role].adminRole; }
    function grantRole(bytes32 role, address account) public virtual override { 
        require( hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");
        _grantRole(role, account);
    }
    function revokeRole(bytes32 role, address account) public virtual override {
        require( hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");
        _revokeRole(role, account);
    }
    function renounceRole(bytes32 role, address account) public virtual override
    {
        require( account == _msgSender(), "AccessControl: can only renounce roles for self" );
        _revokeRole(role, account);
    }
    function _setupRole(bytes32 role, address account) internal virtual { _grantRole(role, account); }
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }
    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }
    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
library Counters {
    struct Counter {
        uint256 _value;
    }
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    function increment(Counter storage counter) internal {
        counter._value += 1;
    }
    function decrement(Counter storage counter) internal {
        counter._value = counter._value - 1;
    }
} 
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
library SafeERC20 {
    using Address for address;
    function safeTransfer(IERC20 token,address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom( IERC20 token,address from,address to,uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token,address spender,uint256 value) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance( IERC20 token,address spender,uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ClaimV2 is AccessControl {
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    bytes32 public constant CREATOR_ADMIN = keccak256("CREATOR_ADMIN");
    IERC20 public tokenHeroes;
    // ERC20Burnable public burnToken;
    uint256 public startTime;
    bool public paused = true;
    uint256 public totalPool;
    uint256 public totalWithdraw;
    uint256 public vestingPeriod;
    uint256 public period;
    address burnAddress;
    constructor(address minter, address _tokenHeroes, uint256 _startTime, uint256 _vestingPeriod, uint256 _period, address _burnAddress){
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CREATOR_ADMIN, minter);
        tokenHeroes = IERC20(_tokenHeroes);
        startTime = _startTime;
        vestingPeriod = _vestingPeriod;
        // burnToken = ERC20Burnable(_tokenHeroes);
        period = _period;
        burnAddress = _burnAddress;
    }
    mapping(address => uint256) public totalAmount;
    mapping(address => uint256) public withdrawnAmount;
    event ClaimToken(
        address Owner,
        uint256 amount,
        uint256 timeClaim
    );
    event EmergencyWithdraw(
        uint256 amount,
        uint256 timeClaim
    );
    function stopClaim() external {
        require(hasRole(CREATOR_ADMIN, address(msg.sender)), "Caller is not a owner");
        paused = true;
    }
    function changeVestingPeriod(uint256 _vestingPeriod) external {
        require(hasRole(CREATOR_ADMIN, address(msg.sender)), "Caller is not a owner");
        vestingPeriod = _vestingPeriod;
    }
    function addMember(address[] memory member, uint256[] memory _amount) external{
        require(hasRole(CREATOR_ADMIN, address(msg.sender)), "Caller is not a owner");
        uint256 deposit = 0;
        for(uint256 i = 0 ; i < member.length; i++){
            totalAmount[address(member[i])] = totalAmount[address(member[i])].add(_amount[i]);
            deposit = deposit.add(_amount[i]);
        }
        require(tokenHeroes.transferFrom(address(msg.sender), address(this), deposit), "Please add more HE to your account");
        totalPool = totalPool.add(deposit);
        paused = false;
    }
    function claimOption2() external {
        require(!paused, "Please wait until the pool is open");
        require(startTime < block.timestamp, "has not started yet");
        uint256 amount = totalAmount[msg.sender].sub(withdrawnAmount[msg.sender]);
        uint256 amount_burn = amount.div(2);
        require(amount > 0, "Amount > 0");
        withdrawnAmount[msg.sender] = withdrawnAmount[msg.sender].add(amount);
        totalWithdraw = totalWithdraw.add(amount);
        safeHETransfer(msg.sender, amount_burn);
        safeBurn(amount_burn);
        emit ClaimToken(
            msg.sender,
            amount,
            block.timestamp
        );
    }

    function claimOption1() external {
        require(!paused, "Please wait until the pool is open");
        require(startTime < block.timestamp, "has not started yet");
        uint256 amountPeriod = getAvailableAmount1(msg.sender);
        require(amountPeriod > 0, "Amount > 0");
        withdrawnAmount[msg.sender] = withdrawnAmount[msg.sender].add(amountPeriod);
        totalWithdraw = totalWithdraw.add(amountPeriod);
        safeHETransfer(msg.sender, amountPeriod);
        emit ClaimToken(
            msg.sender,
            amountPeriod,
            block.timestamp
        );
    }
    function getAvailableAmount1(address _account) public view returns(uint256){
        uint256 amountAvailable = 0;
        uint256 _timeStamp = block.timestamp;
        if(_timeStamp > startTime){
            uint256 currentVesting = (_timeStamp.sub(startTime)).div(period);
            uint256 percentTime = currentVesting.add(1) > vestingPeriod ? vestingPeriod : currentVesting.add(1);
            uint256 amountPeriod = percentTime.mul(totalAmount[address(_account)]).div(vestingPeriod);
            amountAvailable = amountPeriod > withdrawnAmount[address(_account)] ? amountPeriod.sub(withdrawnAmount[address(_account)]) : 0;
        }
        return amountAvailable;
    }
    function getAvailableAmount2(address _member) external view returns( uint256 ){
        uint256 amount = block.timestamp > startTime ? totalAmount[address(_member)].sub(withdrawnAmount[address(_member)]) : 0 ;
        return amount;
    }
    // convert public to internal
    function safeBurn(uint256 _amount) internal {
        uint256 HEBalance = tokenHeroes.balanceOf(address(this));
        uint256 amount = HEBalance > _amount ? _amount : HEBalance;
        tokenHeroes.transfer(burnAddress, amount);
        // burnToken.burn(amount);
    }
    function safeHETransfer(address _to, uint256 _amount) internal {
        uint256 HEBalance = tokenHeroes.balanceOf(address(this));
        if (_amount > HEBalance) {
            tokenHeroes.transfer(_to, HEBalance);
        } else {
            tokenHeroes.transfer(_to, _amount);
        }
    }

    function emergencyWithdraw(uint256 _amount) external {
        require(hasRole(CREATOR_ADMIN, address(msg.sender)), "Caller is not a owner");
        tokenHeroes.transfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(
            _amount,
            block.timestamp
        );
    }
}