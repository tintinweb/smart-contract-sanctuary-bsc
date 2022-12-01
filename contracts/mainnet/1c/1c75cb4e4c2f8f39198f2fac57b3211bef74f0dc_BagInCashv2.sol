/**
 *Submitted for verification at BscScan.com on 2022-12-01
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

contract BagInCashv2 is ReentrancyGuard{
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

    BagInCashv2 immutable internal OLD = BagInCashv2(0xDA4Aa230eF64a5933F4A4B1082e1159DF553B22B);
    IERC20 immutable internal BAG = IERC20(0xD57c2b67A69D34F528235B4736e2c8808468a465);
    IERC20 immutable internal BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // testnet 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814 mainnet 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    
    uint256 constant internal TIME_STEP = 24 hours;
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
        players[_user]._lastHarvest += TIME_STEP;
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
        require(_checkpoint < block.timestamp, '24hrsHold');
        uint256 _amount = players[_user]._activeStake * DAILY_PERCENT / DIVIDER;
        require(_amount > 0, 'NoEarnings');
        players[_user]._activeStake -= _amount;
        players[_user]._lastHarvest += TIME_STEP;
        players[_user]._harvested += _amount;
        BUSD.safeTransfer(_user, _amount);
        totalHarvested += _amount;
    }

    function nextHarvest(address _player) public view returns(uint256){
        return players[_player]._activeStake * DAILY_PERCENT / DIVIDER;
    }

    function moveOld() public{
        require(msg.sender == dev_ && !_migrated, 'Done!');
        uint256 oldPlayers = OLD.totalStaker();
        if(oldPlayers > 0){
            for(uint256 i = 0; i < oldPlayers; i++){
                address _player = OLD.playerslist(i);
                (uint256 _totalStaked, uint256 _totalProfit, uint256 _activeStake, uint256 _harvested, uint256 _totalCommsn, uint256 _lastHarvest, address _sponsor) = OLD.players(_player);
                // register old user
                Players storage player = players[_player];
                player._sponsor = _sponsor;
                player._totalStaked += _totalStaked;
                player._activeStake += _activeStake;
                player._totalCommsn += _totalCommsn;
                player._harvested += _harvested;
                player._totalProfit += _totalProfit;
                player._lastHarvest = _lastHarvest;
                totalStaked += _totalStaked;
                totalHarvested += _harvested;
                totalCommissions += _totalCommsn;
                playerslist.push(_player);
                players[_sponsor]._refs.push(_player);
                totalStaker++;
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