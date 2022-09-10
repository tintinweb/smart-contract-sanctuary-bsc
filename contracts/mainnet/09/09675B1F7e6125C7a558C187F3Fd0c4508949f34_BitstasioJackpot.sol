/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT

/**
 * Website: https://app.bitstasio.com
 */

pragma solidity ^0.8.0; // solhint-disable-line

contract BitstasioJackpot {
    struct Winner {
        address wallet;
        uint256 prize;
        uint256 blockNumber;
    }

    bool public active;

    uint256 public round;
    address public admin;
    address public marketing;
    address public influencer;
    address public dispatcher;

    uint256 public constant FEE_DEPOSIT_ADMIN = 150; // 1.5%
    uint256 public constant FEE_DEPOSIT_DISPATCHER = 100; // 1%
    uint256 public constant FEE_DEPOSIT_MARKETING = 150; // 1.5%
    uint256 public constant FEE_DEPOSIT_INFLUENCER = 100; // 1%

    uint256 public constant FEE_VICTORY_ADMIN = 300; // 3%
    uint256 public constant FEE_VICTORY_DISPATCHER = 100; // 1%
    uint256 public constant FEE_VICTORY_MARKETING = 400; // 4%
    uint256 public constant FEE_VICTORY_INFLUENCER = 200; // 2%

    uint256 public constant MIN_DEPOSIT = 0.042 ether;
    uint256 public constant MAX_DEPOSIT = 1.0 ether;
    uint256 public constant BLOCKS_TO_WIN = 14400; // about 12 hours

    uint256 internal constant PERCENT_ACCURATE = 10000;

    address public lastDepositWallet;
    uint256 public lastDepositBlock;

    Winner[] public winners;

    constructor(
        address _influencer,
        address _marketing,
        address _dispatcher
    ) {
        round = 0;
        admin = msg.sender;
        influencer = _influencer;
        marketing = _marketing;
        dispatcher = _dispatcher;
        lastDepositBlock = block.number;
        lastDepositWallet = address(0x0);
    }

    event Participate(address indexed participant, uint256 deposited);
    event Start(address indexed admin);
    event Win(address indexed winner, uint256 value);

    modifier isActive() {
        require(active == true, "Jackpot is not active.");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "You are not admin.");
        _;
    }

    modifier onlyWinner() {
        require(getIsVictory(), "Victory block not reached.");
        require(msg.sender == lastDepositWallet, "You are not last deposit.");
        _;
    }

    function setAdmin(address _admin) external onlyAdmin {
        admin = _admin;
    }

    function setDispatcher(address _dispatcher) external onlyAdmin {
        dispatcher = _dispatcher;
    }

    function setInfluencer(address _influencer) external onlyAdmin {
        influencer = _influencer;
    }

    function setMarketing(address _marketing) external onlyAdmin {
        marketing = _marketing;
    }

    function getPercentage(uint256 value, uint256 percent)
        internal
        pure
        returns (uint256)
    {
        return (value * percent) / PERCENT_ACCURATE;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getFeeDeposit(uint256 value) public payable returns (uint256) {
        uint256 feeAdmin = getPercentage(value, FEE_DEPOSIT_ADMIN);
        uint256 feeMarketing = getPercentage(value, FEE_DEPOSIT_MARKETING);
        uint256 feeDispatcher = getPercentage(value, FEE_DEPOSIT_DISPATCHER);
        uint256 feeInfluencer = getPercentage(value, FEE_DEPOSIT_INFLUENCER);

        payable(admin).transfer(feeAdmin);
        payable(dispatcher).transfer(feeDispatcher);
        payable(influencer).transfer(feeInfluencer);
        payable(marketing).transfer(feeMarketing);

        return value - feeAdmin - feeMarketing - feeInfluencer - feeDispatcher;
    }

    function getFeeVictory(uint256 value) public payable returns (uint256) {
        uint256 feeAdmin = getPercentage(value, FEE_VICTORY_ADMIN);
        uint256 feeMarketing = getPercentage(value, FEE_VICTORY_MARKETING);
        uint256 feeDispatcher = getPercentage(value, FEE_VICTORY_DISPATCHER);
        uint256 feeInfluencer = getPercentage(value, FEE_VICTORY_INFLUENCER);

        payable(admin).transfer(feeAdmin);
        payable(dispatcher).transfer(feeDispatcher);
        payable(influencer).transfer(feeInfluencer);
        payable(marketing).transfer(feeMarketing);

        return value - feeAdmin - feeMarketing - feeInfluencer - feeDispatcher;
    }

    function getWinnerHistory() external view returns (Winner[] memory) {
        return winners;
    }

    function getIsVictory() public view returns (bool) {
        return getRemainingBlocks() == 0;
    }

    function getRemainingBlocks() public view returns (uint256) {
        return
            lastDepositBlock + BLOCKS_TO_WIN >= block.number
                ? lastDepositBlock + BLOCKS_TO_WIN - block.number
                : 0;
    }

    function start() public onlyAdmin {
        require(active == false, "Already started.");
        active = true;
        round++;

        lastDepositWallet = address(0x0);
        lastDepositBlock = block.number;

        emit Start(admin);
    }

    function participate() public payable isActive {
        require(
            msg.value >= MIN_DEPOSIT && msg.value <= MAX_DEPOSIT,
            "Tx value is too low or too high."
        );

        lastDepositWallet = msg.sender;
        lastDepositBlock = block.number;

        uint256 value = getFeeDeposit(msg.value);

        emit Participate(msg.sender, value);
    }

    function win() public isActive onlyWinner {
        require(lastDepositWallet != address(0x0), "There needs a winner.");

        Winner[] storage _winners = winners;

        active = false;

        uint256 balance = address(this).balance;
        uint256 reward = getFeeVictory(balance);

        _winners.push(Winner(msg.sender, reward, block.number));

        payable(msg.sender).transfer(reward);

        emit Win(msg.sender, reward);
    }
}