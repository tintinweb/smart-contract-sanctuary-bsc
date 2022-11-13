import "./SafeMath.sol";
pragma solidity >=0.8.0;

// Marama.Finance
// t.me/maramafi

struct User {
    uint256 collateral;
    uint256 lastAction;
    uint256 refRewards;
    uint256 withdrawn;
}

contract Marama {

    using SafeMath for uint256;

    uint256 public MIN_INVESTMENT = 1e16; // 0.1 ETH

    // values below are multipied by ten to allow for safer integer division
    uint256 public DAILY_ROI = 15; // 1.5%
    uint256 public REINVEST_BONUS = 50; // 5%
    uint256 public REF_FEE = 30; // 3%
    uint256 public DEV_FEE = 20; // 2%

    uint256 public totalDeposited;
    uint256 public totalWithdrawn;
    uint256 public totalRefRewards;
    uint256 public totalDevFees;

    mapping(address => User) public users;

    address public owner;

    constructor () {
        owner = msg.sender;
    }

    function deposit(address _ref) public payable {
        require(msg.value >= MIN_INVESTMENT, "below minimum investment");
        _reinvest(msg.sender, _ref);
        users[msg.sender].collateral = users[msg.sender].collateral.add(msg.value);
        totalDeposited = totalDeposited.add(msg.value);

        require(_ref != msg.sender, "cannot refer oneself");
        uint256 _refReward = msg.value.mul(REF_FEE).div(1000);
        (bool _sentRef, bytes memory _dataRef) = _ref.call{value: _refReward}("");
        require(_sentRef, "ref transfer failed");
        users[_ref].refRewards = users[_ref].refRewards.add(_refReward);
        totalRefRewards = totalRefRewards.add(_refReward);

        uint256 _devFee = msg.value.mul(DEV_FEE).div(1000);
        (bool _sentDev, bytes memory _dataDev) = owner.call{value: _devFee}("");
        require(_sentDev, "dev transfer failed");
        totalDevFees = totalDevFees.add(_devFee);
    }

    function reinvest(address _ref) public {
        _reinvest(msg.sender, _ref);
    }

    function withdraw() public {
        _withdraw(msg.sender);
    }

    function _reinvest(address _user, address _ref) private {
        uint256 _userRewards = getRewards(_user);
        _userRewards = _userRewards.add(_userRewards.mul(REINVEST_BONUS).div(1000));
        users[_user].lastAction = block.timestamp;
        users[_user].collateral = users[_user].collateral.add(_userRewards);

        require(_ref != _user, "cannot refer oneself");
        uint256 _refReward = _userRewards.mul(REF_FEE).div(1000);
        (bool _sentRef, bytes memory _dataRef) = _ref.call{value: _refReward}("");
        require(_sentRef, "ref transfer failed");
        users[_ref].refRewards = users[_ref].refRewards.add(_refReward);
        totalRefRewards = totalRefRewards.add(_refReward);
    }

    function _withdraw(address _user) private {
        uint256 _userRewards = getRewards(_user);
        users[_user].lastAction = block.timestamp;
        (bool _sent, bytes memory _data) = _user.call{value: _userRewards}("");
        require(_sent, "transfer failed");
        users[_user].withdrawn = users[_user].withdrawn.add(_userRewards);
        totalWithdrawn = totalWithdrawn.add(_userRewards);
    }

    function getRewards(address _user) public view returns (uint256 rewards) {
        uint256 _timeDiff = block.timestamp - users[_user].lastAction;
        rewards = users[_user].collateral.mul(_timeDiff).mul(DAILY_ROI).div(1000).div(86400);
    }

}