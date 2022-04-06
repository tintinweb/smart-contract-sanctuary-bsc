/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

// File: contracts/DWGame2.sol


pragma solidity >=0.4.16 <0.9.0;

interface Peach {
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool);

    function transfer(address _to, uint256 _amount) external returns (bool);

    function getCurrentPrice() external view returns (uint256);
}

contract DWGamified {
    uint256[] public licensePrice = [7, 13, 26];
    uint256[] public licenseDays = [7, 15, 30];
    uint256 public decimalMultiplier = 10**21;
    uint256 public mintUnitGas = 3 * 10**15 wei;
    uint256 public harvestGas = 4 * 10**15 wei;
    uint256 public marketplaceGas = 2 * 10**15 wei;
    uint256 public healGas = 2 * 10**15 wei;
    uint256 public repairGas = 2 * 10**15 wei;
    uint256 public licenseGas = 2 * 10**15 wei;
    uint256 public rewardComission = 5;

    Peach peach;
    address support = msg.sender;
    // Pools
    address payable public bella;
    address payable public refillPool;
    address payable public rewardPool;
    mapping(address => bool) games;

    constructor(
        address payable _bella,
        address payable _refill,
        address payable _reward
    ) {
        // TODO: Change reward to stabilizer array
        bella = _bella;
        refillPool = _refill;
        rewardPool = _reward;
    }

    modifier onlyGame() {
        require(games[msg.sender], "You are not a game");
        _;
    }
    modifier onlySupport() {
        require(msg.sender == support, "You are not a game");
        _;
    }

    function setSupport(address _support) external onlySupport {
        support = _support;
    }

    function setGame(address _game) external onlySupport {
        games[_game] = true;
    }

    function setPeach(address _peachAddress) external onlySupport {
        peach = Peach(_peachAddress);
    }

    function unsetGame(address _game) external onlySupport {
        games[_game] = false;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external onlyGame {
        peach.transferFrom(_from, _to, _amount);
    }
}