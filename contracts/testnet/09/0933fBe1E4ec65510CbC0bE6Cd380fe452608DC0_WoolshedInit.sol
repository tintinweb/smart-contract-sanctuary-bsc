// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {

        uint256 size;

        assembly {
            size := extcodesize(account)
        }

        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
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

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IToken is IERC20 {
    function calculateTransferTaxes(address _from, uint256 _value) external returns (uint256 adjustedValue, uint256 taxAmount);
    function mintedSupply() external returns (uint256);
    function print(uint256 _amount) external;
}

interface IRatesController {
    function getRefBonus(uint8 level) external view returns (uint256);
    function getMaxPayoutOf(address _user, uint256 amount) external view returns (uint256);
    function payOutRateOf(address _addr) external view returns (uint256);
}

interface IWoolshedVault {
    function withdraw(address _token, uint256 _amount) external;
}

abstract contract Initializable {

    bool private _initialized;
    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

abstract contract ContextUpgradeable is Initializable {
    
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

contract ContractGuard {
    mapping(uint256 => mapping(address => bool)) private _status;

    modifier onlyOneBlock() {
        require(!_status[block.number][tx.origin], 'ContractGuard: PROHIBITED');
        _;

        _status[block.number][tx.origin] = true;
    }
}

contract WoolshedInit is OwnableUpgradeable, ContractGuard {
    using SafeMath for uint256;

    struct User {

        //Referral Info
        address upline;

        uint256 referrals;
        uint256 total_structure;

        // Long-term Referral Accounting
        uint256 match_bonus;

        // Deposit Accounting
        uint256 deposits;
        uint256 deposit_time;

        // Payout and Roll Accounting
        uint256 payouts;
        uint256 rolls;

        // Round Robin tracking
        uint256 ref_claim_pos;
        uint256 accumulatedDiv;
    }

    struct Airdrop {
        uint256 pending;
        uint256 airdrops;
        uint256 airdrops_received;
        uint256 last_airdrop;
    }

    struct Custody {
        address manager;
        address beneficiary;
        uint256 last_heartbeat;
        uint256 last_checkin;
        uint256 heartbeat_interval;
    }

    IToken public sheepToken;
    IToken public woolToken;

    IRatesController public ratesController;
    IWoolshedVault private taxVault;

    mapping(address => User) public users;
    mapping(address => Airdrop) public airdrops;
    mapping(address => Custody) public custody;
    
    address public bertha;
    
    uint256 public CompoundTax;
    uint256 public ExitTax;

    uint256 private ref_depth;

    uint256 private minimumAmount;

    uint256 public deposit_bracket_size;
    uint256 private deposit_bracket_max;
    uint256 public max_payout_cap;

    uint256[] public ref_balances;

    uint256 private total_airdrops;
    uint256 private total_users;
    uint256 private total_deposited;
    uint256 private total_withdraw;
    uint256 private total_txs;

    event NewDeposit(address indexed addr, uint256 amount);
    event Leaderboard(address indexed addr, uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure);
    event onPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
    event NewAirdrop(address indexed to, uint256 amount, uint256 timestamp);
    event NewTeamAirdrop(address indexed from, uint256 totalAmount, uint256 timestamp);
    
    event ManagerUpdate(address indexed addr, address indexed manager, uint256 timestamp);
    event BeneficiaryUpdate(address indexed addr, address indexed beneficiary);
    
    event HeartBeat(address indexed addr, uint256 timestamp);
    event Checkin(address indexed addr, uint256 timestamp);

    /* ========== INITIALIZER ========== */

    function initialize(address _sheep, address _wool, address _taxVault, address _rates, address _bertha) external initializer {
        __Ownable_init();

        //Referral Balances
        ref_balances.push(100e18);
        ref_balances.push(250e18);
        ref_balances.push(500e18);
        ref_balances.push(750e18);
        ref_balances.push(1000e18);

        //Br34p
        sheepToken = IToken(_sheep);

        //Drip
        woolToken = IToken(_wool);

        //IWoolshedVault
        taxVault = IWoolshedVault(_taxVault);
        ratesController = IRatesController(_rates);

        //TODO Initialize the rest of the contract variables -- need to call the administrative functions below
        CompoundTax = 5;
        ExitTax = 15;
        ref_depth = 5;

        minimumAmount = 1e18;

        deposit_bracket_size = 1000e18;
        max_payout_cap = 50000e18;
        deposit_bracket_max = 10; 

        total_users = 1;

        bertha = _bertha;
    }

    //@dev Default payable is empty since Faucet executes trades and recieves BNB
    fallback() external payable {
        //Do nothing, BNB will be sent to contract when selling tokens
    }

    receive() external payable {
        //Do nothing, BNB will be sent to contract when selling tokens
    }
}