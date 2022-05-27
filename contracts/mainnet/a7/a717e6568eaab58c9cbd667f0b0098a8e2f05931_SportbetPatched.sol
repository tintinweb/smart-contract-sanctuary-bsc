// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./Ownable.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";
import "./PRBMathUD60x18.sol";

contract SportbetPatched is Ownable {
    using SafeERC20 for IERC20;
    using PRBMathUD60x18 for uint;
    IERC20 immutable public chipToken;

    // Banker start
    struct Gambling {
        uint[3] stakes;     // 0: aTeam 1:tie 2: bTeam
        uint aTeam;
        uint bTeam;
        uint startTime;
        uint bullseye;      // 0: aTeam 1:tie 2: bTeam
        bool isFinished;

        uint aTeamSpread;
        uint bTeamSpread;
    }

    struct League {
        string name;
        Gambling[] gamblings;
    }

    string[] teams;
    League[] leagues;

    // Investors bet
    struct Bet {
        uint leagueId;
        uint gamblingId;
        uint target;    // 0: aTeam 1:tie 2: bTeam
        uint stake;
        uint reward;
        bool isClaimed;
    }

    mapping(address => Bet[]) bets;

    // Winner Earnings Fee - only earnings apart, excluded principal
    uint earningsFeeBP;
    uint constant earningsFeeDP = 10000;
    address constant nullAddress = 0x794f8A70a6507e8E2DddDf3E26c6130a2016d7dc; //<<UPDATE TO PERSONAL ADDRESS TO TEST <<0x000000000000000000000000000000000000dEaD;

    modifier onlyNotFinished(uint _leagueId, uint _gamblingId){
        require(leagues[_leagueId].gamblings[_gamblingId].isFinished == false, "This gambling has finished!");
        _;
    }

    constructor(IERC20 _chipToken, uint _earningsFeeBP) {
        chipToken = _chipToken;
        earningsFeeBP = _earningsFeeBP;
    }

    function createLeague(string memory _name) external onlyOwner {
        leagues.push().name = _name;
    }

    function createTeam(string memory _name) external onlyOwner {
        teams.push(_name);
    }

    function setTeamName(uint _index, string calldata _name) external onlyOwner {
        teams[_index] = _name;
    }

    function setLeagueName(uint _index, string calldata _leagueName) external onlyOwner {
        leagues[_index].name = _leagueName;
    }

    function setStartTime(uint _leagueId, uint _gamblingId, uint _startTime) external onlyOwner onlyNotFinished(_leagueId, _gamblingId) {
        leagues[_leagueId].gamblings[_gamblingId].startTime = _startTime;
    }

    function setEarningsFeeBP(uint _earningsFeeBP) external onlyOwner {
        require(_earningsFeeBP < 10000, "setEarningsFeeBP: should be less than 10000!");
        earningsFeeBP = _earningsFeeBP;
    }

    function createGambling(uint _leagueId, uint _aTeam, uint _bTeam, uint _startTime, uint _aTeamSpread, uint _bTeamSpread) external onlyOwner {
        leagues[_leagueId].gamblings.push(Gambling({aTeam : _aTeam, bTeam : _bTeam, startTime : _startTime, bullseye : 99, stakes : [uint(0), 0, 0], isFinished : false, aTeamSpread : _aTeamSpread, bTeamSpread : _bTeamSpread}));
    }

    function drawLottery(uint _leagueId, uint _gamblingId, uint _ballot) external onlyOwner onlyNotFinished(_leagueId, _gamblingId) {
        require(leagues[_leagueId].gamblings[_gamblingId].startTime < block.timestamp, "drawLottery: This gambling hasn't started yet!");
        require(_ballot == 0 || _ballot == 1 || _ballot == 2, "Illegal!");

        leagues[_leagueId].gamblings[_gamblingId].bullseye = _ballot;
        leagues[_leagueId].gamblings[_gamblingId].isFinished = true;
    }

    function createBet(uint _leagueId, uint _gamblingId, uint _target, uint _stake) external onlyNotFinished(_leagueId, _gamblingId) {
        require(leagues[_leagueId].gamblings[_gamblingId].startTime > block.timestamp, "createBet: This gambling has started!");

        Bet memory bet;
        bet.leagueId = _leagueId;
        bet.gamblingId = _gamblingId;
        bet.target = _target;
        bet.stake = _stake;

        chipToken.safeTransferFrom(msg.sender, address(this), _stake);
        leagues[_leagueId].gamblings[_gamblingId].stakes[_target] += _stake;

        bets[msg.sender].push(bet);
    }

    function claimBet(uint _leagueId, uint _gamblingId, uint _index) external {
        Gambling storage gambling = leagues[_leagueId].gamblings[_gamblingId];
        Bet storage bet = bets[msg.sender][_index];
        require(bet.target == gambling.bullseye && bet.leagueId == _leagueId && bet.gamblingId == _gamblingId && bet.isClaimed == false, "Illegal!");

        bet.isClaimed = true;
        (uint reward, uint fee) = _getPendingEarnings(gambling, bet);
        bet.reward = reward;
        chipToken.safeTransfer(nullAddress, fee);
        chipToken.safeTransfer(msg.sender, bet.stake + bet.reward - fee);
    }

    // @param _index - the index of MyBets[]
    function getPendingEarnings(uint _leagueId, uint _gamblingId, uint _index) external view returns (uint, uint){
        Gambling storage gambling = leagues[_leagueId].gamblings[_gamblingId];
        Bet storage bet = bets[msg.sender][_index];
        require(bet.target == gambling.bullseye && bet.leagueId == _leagueId && bet.gamblingId == _gamblingId && bet.isClaimed == false, "Illegal!");

        return _getPendingEarnings(leagues[_leagueId].gamblings[_gamblingId], bets[msg.sender][_index]);
    }

    // @param _index - the index of MyBets[]
    function _getPendingEarnings(Gambling storage gambling, Bet storage bet) private view returns (uint, uint){
        uint bonus = gambling.stakes[0] + gambling.stakes[1] + gambling.stakes[2] - gambling.stakes[bet.target];
        uint reward = (bet.stake.fromUint()).div(gambling.stakes[bet.target].fromUint()).mul(bonus.fromUint()).toUint();
        uint fee = reward.fromUint().mul(earningsFeeBP.fromUint()).div(earningsFeeDP.fromUint()).toUint();
        return (reward, fee);
    }

    function getBets() external view returns (Bet[] memory) {
        return bets[msg.sender];
    }

    function getTeams() external view returns (string[] memory) {
        return teams;
    }

    function getLeagues() external view returns (League[] memory) {
        return leagues;
    }
}