/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

pragma solidity ^0.8.11;
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
contract Staking {
    address public owner;
    IERC20 public TKN;
    address private feeAddress;

    uint256[3] public periods = [30 days, 60 days, 90 days];
    uint16[3] public rates = [450, 1150, 2460];
    uint16 constant public feeRate = 40;
    uint256 public rewardsPool;
    uint256 public MAX_STAKES = 100;

    struct Stake {
        uint8 class;
        uint256 initialAmount;
        uint256 finalAmount;
        uint256 timestamp;
        bool unstaked;
    }

    Stake[] public stakes;
    mapping(address => uint256[]) public stakesOf;
    mapping(uint256 => address) public ownerOf;

    event Staked(address indexed sender, uint8 indexed class, uint256 amount, uint256 finalAmount);
    event Prolonged(address indexed sender, uint8 indexed class, uint256 newAmount, uint256 newFinalAmount);
    event Unstaked(address indexed sender, uint8 indexed class, uint256 amount);
    event TransferOwnership(address indexed previousOwner, address indexed newOwner);
    event IncreaseRewardsPool(address indexed adder, uint256 added, uint256 newSize);

    modifier restricted {
        require(msg.sender == owner, "This function is restricted to owner");
        _;
    }

    function stakesInfo(uint256 _from, uint256 _to) public view returns (Stake[] memory s) {
        s = new Stake[](_to - _from);
        for (uint256 i = _from; i < _to; i++) s[i - _from] = stakes[i];
    }

    function stakesInfoAll() public view returns (Stake[] memory s) {
        s = new Stake[](stakes.length);
        for (uint256 i = 0; i < stakes.length; i++) s[i] = stakes[i];
    }

    function stakesLength() public view returns (uint256) {
        return stakes.length;
    }

    function myStakes(address _me) public view returns (Stake[] memory s, uint256[] memory indexes) {
        s = new Stake[](stakesOf[_me].length);
        indexes = new uint256[](stakesOf[_me].length);
        for (uint256 i = 0; i < stakesOf[_me].length; i++) {
            indexes[i] = stakesOf[_me][i];
            s[i] = stakes[indexes[i]];
        }
    }

    function myActiveStakesCount(address _me) public view returns (uint256 l) {
        uint256[] storage _s = stakesOf[_me];
        for (uint256 i = 0; i < _s.length; i++) if (!stakes[_s[i]].unstaked) l++;
    }

    function stake(uint8 _class, uint _amount) public {
        require(_class < 3, "Wrong class"); // data valid
        require(myActiveStakesCount(msg.sender) < MAX_STAKES, "MAX_STAKES overflow"); // has space for new active stake
        uint256 _finalAmount = _amount + (_amount * rates[_class]) / 10000;
        require(rewardsPool >= _finalAmount - _amount, "Rewards pool is empty for now");
        rewardsPool -= _finalAmount - _amount;
        TKN.transferFrom(msg.sender, address(this), _amount);
        uint256 _index = stakes.length;
        stakesOf[msg.sender].push(_index);
        stakes.push(Stake({
            class: _class,
            initialAmount: _amount,
            finalAmount: _finalAmount,
            timestamp: block.timestamp,
            unstaked: false
        }));
        ownerOf[_index] = msg.sender;
        emit Staked(msg.sender, _class, _amount, _finalAmount);
    }

    function unstake(uint256 _index) public {
        require(msg.sender == ownerOf[_index], "Not correct index");
        Stake storage _s = stakes[_index];
        require(!_s.unstaked, "Already unstaked"); // not unstaked yet
        require(block.timestamp >= _s.timestamp + periods[_s.class], "Staking period not finished"); // staking period finished
        uint256 _reward = (_s.initialAmount * rates[_s.class]) / 10000;
        uint total = _s.initialAmount + _reward;
        uint256 _fee = total * feeRate / 1000;
        total -= _fee;
        TKN.transfer(feeAddress, _fee);
        TKN.transfer(msg.sender, total);
        _s.unstaked = true;
        emit Unstaked(msg.sender, _s.class, _s.finalAmount);
    }

    function transferOwnership(address _newOwner) public restricted {
        require(_newOwner != address(0), "Invalid address: should not be 0x0");
        emit TransferOwnership(owner, _newOwner);
        owner = _newOwner;
    }

    function returnAccidentallySent(IERC20 _TKN) public restricted {
        require(address(_TKN) != address(TKN), "Unable to withdraw staking token");
        uint256 _amount = _TKN.balanceOf(address(this));
        _TKN.transfer(msg.sender, _amount);
    }

    function increaseRewardsPool(uint256 _amount) public {
      TKN.transferFrom(msg.sender, address(this), _amount);
      rewardsPool += _amount;
      emit IncreaseRewardsPool(msg.sender, _amount, rewardsPool);
    }

    function updateMax(uint256 _max) public restricted {
        MAX_STAKES = _max;
    }

    function changeFeeAddress(address newFeeAddress) external restricted {
        require(newFeeAddress != address(0), "Zero address");
        feeAddress = newFeeAddress;
    }

    constructor(IERC20 _TKN, address _feeAddress) {
        owner = msg.sender;
        TKN = _TKN;
        feeAddress = _feeAddress;
    }
}