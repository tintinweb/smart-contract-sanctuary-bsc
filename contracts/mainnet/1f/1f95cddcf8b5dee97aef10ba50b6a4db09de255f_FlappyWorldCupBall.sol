/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract FlappyWorldCupBall {
    // Owner of this contract
    address public contractOwner;

    struct PlayerData {
        // Prize of account - WEI Unit
        uint256 prize;
        uint32 score;
        bool collected;
    }

    struct PlayerPrizeDto {
        address wallet;
        // Prize of account - WEI Unit
        uint256 prize;
        bool collected;
    }

    struct PlayerScoreDto {
        address wallet;
        uint32 score;
    }
    // Tournaments Results
    mapping(string => mapping(address => PlayerData)) private tournaments;

    constructor() {
        contractOwner = msg.sender;
    }

    // Modifier to check that the caller is the owner of the contract.
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Not owner");
        _;
    }

    /// @dev Update Player Prize of Tournament
    /// @param _tournamentId Id of tournament
    /// @param _data List played data
    function updatePlayerPrize(
        string calldata _tournamentId,
        PlayerPrizeDto[] calldata _data
    ) public onlyOwner {
        for (uint256 i = 0; i < _data.length; i++) {
            PlayerPrizeDto memory item = _data[i];
            tournaments[_tournamentId][item.wallet].prize = item.prize;
            tournaments[_tournamentId][item.wallet].collected = item.collected;
        }
    }

    /// @dev Update Player Score of Tournament
    /// @param _tournamentId Id of tournament
    /// @param _data List played data
    function updatePlayerScore(
        string calldata _tournamentId,
        PlayerScoreDto[] calldata _data
    ) public onlyOwner {
        for (uint256 i = 0; i < _data.length; i++) {
            PlayerScoreDto memory item = _data[i];
            tournaments[_tournamentId][item.wallet].score = item.score;
        }
    }

    /// @dev Get balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /// @dev Player collect reward of tournament
    /// @param _tournamentId Id of tournament
    function collectReward(string calldata _tournamentId) public payable {
        address account = msg.sender;
        PlayerData memory data = tournaments[_tournamentId][account];
        require(data.prize > 0, "You don't have any rewards");
        require(!data.collected, "Already received the reward");
        require(getBalance() > data.prize, "Contract Balance is not enough");
        payable(msg.sender).transfer(data.prize);
        // Update account collected
        tournaments[_tournamentId][account].collected = true;
    }

    /// @dev View player data in a tournament
    /// @param _tournamentId Id of tournament
    /// @param _wallet Wallet address of player
    function viewAccountResult(string calldata _tournamentId, address _wallet)
        public
        view
        onlyOwner
        returns (PlayerData memory)
    {
        return tournaments[_tournamentId][_wallet];
    }

    /// @dev Deposit to buy alive
    function deposit() public payable {
        require(msg.value > 0);
    }

    /// @dev WithDraw an amount of balance
    /// @param amount Amount of number
    function withDraw(uint256 amount) public payable onlyOwner {
        require(getBalance() > amount);
        payable(msg.sender).transfer(amount);
    }

    /// @dev WithDraw all of smartContract balance
    function withDrawAll() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}