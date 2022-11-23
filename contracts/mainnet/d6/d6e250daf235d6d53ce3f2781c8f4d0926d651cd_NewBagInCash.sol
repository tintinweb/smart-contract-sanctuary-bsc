/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

contract ReentrancyGuard {
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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
    * @dev Prevents a contract from calling itself, directly or indirectly.
    * Calling a `nonReentrant` function from another `nonReentrant`
    * function is not supported. It is possible to prevent this from happening
    * by making the `nonReentrant` function external, and make it call a
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

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

contract NewBagInCash is ReentrancyGuard{
    using SafeERC20 for IERC20;
    // stake with Busd
    // each Stakes gives 0.0001 BAG/1BUSD amount of token
    struct Players{
        uint256 _totalStaked;
        uint256 _totalProfit;
        uint256 _activeStake;
        uint256 _harvested;
        uint256 _totalCommsn;
        uint256 _lastHarvest;
        address _sponsor;
        address[] _refs;
    }

    uint256 immutable _snapshot = 1668661272;

    OLDBAGNCASH immutable internal OLD = OLDBAGNCASH(0x29Dd6D1b8F1AEFE3fc069EA79d29e7B9899903e6);
    IERC20 immutable internal BAG = IERC20(0xa71edFD63d06D3BD24F70E29073505e1865d8e30);
    IERC20 immutable internal BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // testnet 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814 mainnet 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    
    uint256 constant internal TIME_STEP = 1 minutes;
    uint256 constant internal MIN_STAKE = 10;
    uint256 constant internal COMMI = 500;
    uint256 constant internal PRO_STAKE = 5000;
    uint256 constant internal INS_RWRD = 1500;
    uint256 constant internal MKT_FEE = 300;
    uint256 constant internal DEV_FEE = 200;
    uint256 constant internal STKE_TERM = 300;
    uint256 constant internal DAILY_PERCENT = 500;
    uint256 constant internal DIVIDER = 10000;

    address internal dev_;
    address immutable public owner = 0x29D4113fb7947FD508AA25df9138250a4D4abF21;

    uint256 public totalStaker;
    uint256 public totalStaked;
    uint256 public totalHarvested;
    uint256 public totalCommissions;

    address[] public playerslist;

    mapping(address => Players) public players;

    bool public _migrated;

    constructor() { 
        dev_ = msg.sender;
    }

    function insertRecord(uint256 _amount) private{
        address _user = msg.sender;
        // Harvest if Pending 
        if(players[_user]._activeStake > 0 && block.timestamp >= players[_user]._lastHarvest + TIME_STEP){
            harvest();
        }
        uint256 _stakeReward = _amount * PRO_STAKE / DIVIDER;
        players[_user]._totalStaked += _amount;
        players[_user]._totalProfit += _stakeReward;
        players[_user]._activeStake += _amount + _stakeReward - (_amount * INS_RWRD / DIVIDER);
        players[_user]._lastHarvest = block.timestamp;
        totalStaked += _amount;
    }

    function disburse(uint256 _amount) private{
        // 5% affiliate commission
        address _sponsor = players[msg.sender]._sponsor;
        uint256 _commission = _amount * COMMI / DIVIDER;
        BUSD.safeTransfer(_sponsor, _commission);
        players[_sponsor]._totalCommsn += _commission;
        totalCommissions += _commission;
        // DevFees & Marketing
        uint256 _devFees = _amount * DEV_FEE / DIVIDER; // 2% dev fees
        uint256 _marketing = _amount * MKT_FEE / DIVIDER; // 3% marketing fee
        BUSD.safeTransfer(owner, _marketing);
        BUSD.safeTransfer(dev_, _devFees);
        // 15% instant reward.
        uint256 _instantReward = _amount * INS_RWRD / DIVIDER;
        BUSD.safeTransfer(msg.sender, _instantReward);
        players[msg.sender]._harvested += _instantReward;
        // send BAG Tokens to stakers
        BAG.safeTransferFrom(owner, msg.sender, _amount);
    }

    function register(address _ref) private{
        address _user = msg.sender;
        if(_ref != _user && _ref != address(0) && players[_ref]._totalStaked < 0){
            _ref = dev_;
        }
        else{
            _ref = dev_;
        }
        players[_user]._sponsor = _ref;
        players[_ref]._refs.push(_user);
        playerslist.push(_user);
        totalStaker++;
    }

    function stake(address _ref, uint256 _amount) public {
        require(!isContract(msg.sender), 'NotAllowed');
        require(_amount >= MIN_STAKE, 'MinAmount');
        address _user = msg.sender;
        BUSD.safeTransferFrom(_user, address(this), _amount);
        if(players[_user]._sponsor == address(0)){
            register(_ref);
        }
        disburse(_amount);
        insertRecord(_amount);
    }

    function harvest() public{
        address _user = msg.sender;
        require(!isContract(_user), 'NotAllowed');
        require(players[_user]._activeStake > 0, 'NotAllowed');
        require(block.timestamp >= players[_user]._lastHarvest + TIME_STEP, 'NotAllowed');
        // last harvest >= 24hrs
        uint256 _checkpoint = players[_user]._lastHarvest;
        // Get amount to Harvest
        uint256 _pendingH = players[_user]._activeStake;
        uint256 _amounth;
        uint256 _daysPassed = (block.timestamp - _checkpoint) / TIME_STEP >= STKE_TERM ? STKE_TERM : (block.timestamp - _checkpoint) / TIME_STEP;
        if(_daysPassed > 0){
            for(uint256 i = 1; i <= _daysPassed; i++){
                uint256 _hamount = _pendingH * DAILY_PERCENT / DIVIDER;
                _pendingH -= _hamount;
                _amounth += _hamount;
            }
        }
        // contract balance >= 2x amount withdrawing
        uint256 _allowH = _amounth * 2;
        uint256 _contractBalance = BUSD.balanceOf(address(this));
        if(_amounth > 0 && _contractBalance >= _allowH){
            players[_user]._harvested += _amounth;
            players[_user]._activeStake -= _amounth;
            BUSD.safeTransfer(_user, _amounth);
            players[_user]._lastHarvest = block.timestamp;
            totalHarvested += _amounth;
        }
    }

    function moveOld() public{
        require(msg.sender == dev_ && !_migrated, 'Done!');
        uint256 oldPlayers = OLD.totalDepositer();
        if(oldPlayers > 0){
            for(uint256 i = 0; i < oldPlayers; i++){
                address _player = OLD.stakers(i);
                if(OLD.staking_start_time(_player) < _snapshot){
                    // register old user
                    Players storage player = players[_player];
                    player._sponsor = OLD.myUpline(_player);
                    player._totalStaked += OLD.stakingBalance(_player);
                    player._activeStake += OLD.Remainingstaking(_player);
                    player._totalCommsn += OLD.myCommission(_player);
                    player._harvested += OLD.myProfit(_player) - OLD.Remainingstaking(_player);
                    player._totalProfit += OLD.myProfit(_player) - OLD.stakingBalance(_player);
                    totalStaked += OLD.stakingBalance(_player);
                    totalHarvested += OLD.myProfit(_player) - OLD.Remainingstaking(_player);
                    totalCommissions += OLD.myCommission(_player);
                    playerslist.push(_player);
                    totalStaker++;
                }
            }
        }
        _migrated = true;
    }

    function isContract(address addr) private view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

contract OLDBAGNCASH {
    address[] public stakers;
    uint256 public  totalDepositer;
    mapping(address => address) public myUpline;
    mapping(address => uint256) public myProfit;
    mapping(address => uint256) public myCommission;
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public Remainingstaking;
    mapping(address => uint256) public staking_start_time;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(isContract(address(token)), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}