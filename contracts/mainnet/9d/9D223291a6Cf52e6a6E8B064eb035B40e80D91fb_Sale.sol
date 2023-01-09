/**
 *Submitted for verification at BscScan.com on 2023-01-09
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

contract Sale {
    uint256 private constant ONE_Month = 60 * 60 * 24 * 30;
    uint256 private constant LockWarehouse = 10000 * (10**18);
    address public Uaddress;
    using SafeMath for uint256;
    Erc20Token internal constant _USDTAddr =
        Erc20Token(0x55d398326f99059fF775485246999027B3197955);
    Erc20Token internal constant _DOTCAddr =
        Erc20Token(0xE56D5478250251f84760E769E911fa5F0dca196F);
    mapping(address => uint256) public _playerAddrMap;
    uint256 public _playerCount;
    address[] public node;
    uint256 public maxNodeLength = 500;
    bool public _LOCK = false;
    bool public _nodeLOCK = true;
    uint256 public nodePrice = 30000 * (10**18);
    address _owner;
    address _nodeDividendOwner;

    uint256 public dotcPrice = 50;
    bool public openBuy = true;

    mapping(uint256 => Player) public _playerMap;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied");
        _;
    }

    modifier onlyPermission() {
        require(
            msg.sender == _owner || msg.sender == _nodeDividendOwner,
            "Permission denied"
        );
        _;
    }

    modifier isRealPlayer() {
        uint256 id = _playerAddrMap[msg.sender];
        require(id > 0, "userDoesNotExist");
        _;
    }

    modifier isLOCK() {
        require(_LOCK, "islock");
        _;
    }

    modifier isOpenBuy() {
        require(openBuy, "isNotOpen");
        _;
    }

    function nodeLOCK(bool LOCK) public onlyOwner {
        _nodeLOCK = LOCK;
    }

    function stop(bool LOCK) public onlyOwner {
        _LOCK = LOCK;
    }

    function setUaddressship(address newaddress) public onlyOwner {
        require(newaddress != address(0));
        Uaddress = newaddress;
    }

    function setMaxNodeLength(uint256 _l) public onlyOwner {
        maxNodeLength = _l;
    }

    function setNodePrice(uint256 _price) public onlyOwner {
        nodePrice = _price * (10**18);
    }

    function setDOTCPrice(uint256 _price) public onlyOwner {
        dotcPrice = _price;
    }

    function setOpenBuy(bool open) public onlyOwner {
        openBuy = open;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function transferNodeDividendOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _nodeDividendOwner = newOwner;
    }

    struct Player {
        uint256 id;
        address addr;
        uint256 investTime;
        uint256 Available;
        uint256 LockWarehouse;
    }

    constructor() {
        _owner = msg.sender;
        _nodeDividendOwner = msg.sender;
    }

    function registry(address playerAddr) internal {
        uint256 id = _playerAddrMap[playerAddr];
        require(id == 0, "nodeAlreadyExists");
        require(node.length <= maxNodeLength, "NodeSoldOut");
        _playerCount++;
        _playerAddrMap[playerAddr] = _playerCount;
        _playerMap[_playerCount].id = _playerCount;
        _playerMap[_playerCount].addr = playerAddr;
        _playerMap[_playerCount].investTime = block.timestamp;
        _playerMap[_playerCount].LockWarehouse = LockWarehouse;
        node.push(playerAddr);
    }

    function buyNode() public payable {
        require(_nodeLOCK, "isnodeLOCK");
        uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
        require(_usdtBalance >= nodePrice, "9999");
        _USDTAddr.transferFrom(msg.sender, address(Uaddress), nodePrice);
        registry(msg.sender);
    }

    // 当前时间-买节点的时间 / 1个月  * 1000
    function settleStatic() external isRealPlayer {
        uint256 id = _playerAddrMap[msg.sender];
        uint256 dif = getReceiveAmount(msg.sender);
        require(dif >= 1000 * (10**18), "ThereAreNoONE_MonthToSettle");
        if (dif > _playerMap[_playerCount].LockWarehouse) {
            _DOTCAddr.transfer(
                msg.sender,
                _playerMap[_playerCount].LockWarehouse
            );
            _playerMap[_playerCount].LockWarehouse = 0;
        } else {
            _DOTCAddr.transfer(msg.sender, dif);
            _playerMap[_playerCount].LockWarehouse = _playerMap[_playerCount]
                .LockWarehouse
                .sub(dif);
        }
        _playerMap[id].investTime = block.timestamp;
    }

    function getReceiveAmount(address a) public view returns (uint256) {
        uint256 id = _playerAddrMap[a];
        uint256 difTime = block.timestamp.sub(_playerMap[id].investTime);
        return difTime.div(ONE_Month).mul(1000 * (10**18));
    }

    // 节点分红
    function nodeDividend(uint256 amount) public onlyPermission {
        for (uint256 i = 0; i < node.length; i++) {
            _DOTCAddr.transfer(node[i], amount);
        }
    }

    function buyDOTC(uint256 amount) public isOpenBuy {
        require(_DOTCAddr.balanceOf(address(this)) >= amount, "1");
        uint256 usdtAmount = amount.mul(dotcPrice).div(100);
        require(_USDTAddr.balanceOf(msg.sender) >= usdtAmount, "2");
        _USDTAddr.transferFrom(msg.sender, address(this), usdtAmount);
        _DOTCAddr.transfer(msg.sender, amount);
    }

    function buyUSDT(uint256 amount) public isOpenBuy {
        require(_USDTAddr.balanceOf(address(this)) >= amount, "1");
        uint256 doctAmount = amount.div(dotcPrice).mul(100);
        require(_DOTCAddr.balanceOf(msg.sender) >= doctAmount, "2");
        _DOTCAddr.transferFrom(msg.sender, address(this), doctAmount);
        _USDTAddr.transfer(msg.sender, amount);
    }

    function withdrawDOTC(address account, uint256 amount) public onlyOwner {
        _DOTCAddr.transfer(account, amount);
    }

    function withdrawUSDT(address account, uint256 amount) public onlyOwner {
        _USDTAddr.transfer(account, amount);
    }
}