/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface Erc20Token {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _who) external view returns (uint256);

    function transfer(address _to, uint256 _value) external;

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external;

    function approve(address _spender, uint256 _value) external;

    function burnFrom(address _from, uint256 _value) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract BFC {
    using SafeMath for uint256;

    address public _owner;

    address public _manager;

    uint256 public releaseRatio = 3;

    uint256 public releaseTimes = 60 * 60 * 24;

    uint256 public playerCount;

    mapping(uint256 => Player) public playerMap;

    mapping(address => uint256) public playerIdMap;

    Erc20Token internal constant _USDTAddr =
        Erc20Token(0x55d398326f99059fF775485246999027B3197955);
    Erc20Token internal constant _EDAOAddr =
        Erc20Token(0x900882Be74c5Cb53eF02D603fCF006CDEf0495c9);

    struct Player {
        uint256 id;
        address _userAddr;
        uint256 registerTime;
        uint256 releaseTime;
        uint256 totalAmount;
        uint256 releaseAmount;
    }

    constructor() {
        _owner = msg.sender;
        _manager = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied");
        _;
    }

    modifier onlyManager() {
        require(
            msg.sender == _owner || msg.sender == _manager,
            "Permission denied"
        );
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function transferManagership(address newManager) public onlyOwner {
        require(newManager != address(0));
        _owner = newManager;
    }

    function setReleaseRatio(uint256 ratio) public onlyOwner {
        releaseRatio = ratio;
    }

    function setReleaseTimes(uint256 times) public onlyOwner {
        releaseTimes = 60 * times;
    }

    function getPriceOfLPEDAO() public view returns (uint256 price) {
        uint256 balanceU = _USDTAddr.balanceOf(
            0x518aA5Dd3bed11Cc8dE0F3e3736BF8f2a2Fec064
        );
        uint256 balanceEDAO = _EDAOAddr.balanceOf(
            0x518aA5Dd3bed11Cc8dE0F3e3736BF8f2a2Fec064
        );
        if (balanceU == 0 || balanceEDAO == 0) return 0;
        price = (balanceEDAO * 10**6) / (balanceU);
    }

    function getPriceOfLPU() public view returns (uint256 price) {
        uint256 balanceU = _USDTAddr.balanceOf(
            0x518aA5Dd3bed11Cc8dE0F3e3736BF8f2a2Fec064
        );
        uint256 balanceEDAO = _EDAOAddr.balanceOf(
            0x518aA5Dd3bed11Cc8dE0F3e3736BF8f2a2Fec064
        );
        if (balanceU == 0 || balanceEDAO == 0) return 0;
        price = (balanceU * 10**6) / (balanceEDAO);
    }

    function register(address _user) private {
        playerCount++;
        playerIdMap[_user] = playerCount;
        playerMap[playerCount].id = playerCount;
        playerMap[playerCount]._userAddr = _user;
        playerMap[playerCount].registerTime = block.timestamp;
    }

    function setUserReleaseAmount(address _userAddr, uint256 _amount)
        public
        onlyManager
    {
        uint256 id = playerIdMap[_userAddr];
        if (id == 0) {
            register(_userAddr);
        }
        id = playerIdMap[_userAddr];
        Player memory player = playerMap[id];
        if (_amount == 0) {
            player.totalAmount = 0;
            player.releaseAmount = 0;
            player.releaseTime = 0;
            player.registerTime = block.timestamp;
        } else {
            player.totalAmount = player.totalAmount.add(_amount);
            player.releaseAmount = player.releaseAmount.add(_amount);
        }
        playerMap[id] = player;
    }

    function setUserReleaseAmountMul(
        address[] calldata _userAddrs,
        uint256[] calldata _amounts
    ) public onlyManager {
        for (uint256 index = 0; index < _userAddrs.length; index++) {
            address userAddr = _userAddrs[index];
            if (userAddr != address(0x0)) {
                setUserReleaseAmount(userAddr, _amounts[index]);
            }
        }
    }

    function receiveProfit() public {
        uint256 id = playerIdMap[msg.sender];
        require(id > 0, "user is not register");
        Player memory player = playerMap[id];
        uint256 time = player.releaseTime == 0
            ? player.registerTime
            : player.releaseTime;
        uint256 difTime = block.timestamp.sub(time);
        require(difTime > releaseTimes, "receive is not in time");
        require(player.totalAmount > 0, "amount is zero");
        uint256 receiveAmount = getReceiveAmount(msg.sender);
        require(receiveAmount > 0, "receive Amount is Zero");
        uint256 receiveAmountEDAO = getPriceOfLPEDAO() == 0
            ? 0
            : receiveAmount.mul(getPriceOfLPEDAO()).div(10**6);
        require(receiveAmountEDAO > 0, "receive EDAO Amount is zero");

        player.releaseAmount = player.releaseAmount.sub(receiveAmount);
        player.releaseTime = block.timestamp;
        playerMap[id] = player;
        _EDAOAddr.transfer(msg.sender, receiveAmountEDAO);
    }

    function getReceiveAmount(address _address) public view returns (uint256) {
        uint256 id = playerIdMap[_address];
        Player memory player = playerMap[id];
        uint256 time = player.releaseTime == 0
            ? player.registerTime
            : player.releaseTime;
        uint256 difTimes = block.timestamp.sub(time);
        uint256 currentReceiveAmount = difTimes.div(releaseTimes).mul(
            (player.totalAmount.mul(releaseRatio)).div(1000)
        );
        uint256 receiveAmount = player.releaseAmount > currentReceiveAmount
            ? currentReceiveAmount
            : player.releaseAmount;
        return player.releaseAmount == 0 ? 0 : receiveAmount;
    }
}