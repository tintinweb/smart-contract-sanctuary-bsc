/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract ScoreBet {
    address public owner;
    address payable public treasury;
    address public constant tokenAddress =
        0x0D466E98D5A864b30EF2CaA4e312E5E63aA9A762;

    uint8 public winningTeam;
    uint256 public betPool = 0;
    bool public openBet = false;

    //Differentiate sides
    address[] betA;
    address[] betB;

    mapping(address => uint256) public betValue;
    mapping(address => bool) public isBetting;
    mapping(address => uint8) public selectedTeam;

    event Betting(address indexed _better, uint256 _value);
    event Win(address indexed _better, uint256 _value);

    constructor(address payable _treasury) {
        owner = msg.sender;
        treasury = _treasury;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    receive() external payable {}

    // Bet Function
    function Bet(uint8 _selectedTeam) external payable {
        // Get and set the minimum token hold to be able to bet
        uint256 totsupp = IERC20(tokenAddress).totalSupply();
        uint256 betterBalance = IERC20(tokenAddress).balanceOf(msg.sender);
        uint256 minimumBet = totsupp / 2 / 100;

        uint256 fee = msg.value / 100;
        uint256 amtFee = msg.value + fee;

        require(msg.value == amtFee, "Insufficient Balance To Bet");
        require(msg.value != 0, "Amount can't be 0");
        require(msg.sender != address(0), "Invalid Address");
        require(betterBalance >= minimumBet, "Need to hold minimum of 0.5%");
        require(_selectedTeam != 0, "Need to choose a team");
        require(!isBetting[msg.sender], "You already take a bet");
        require(openBet, "Bet is close");

        betValue[msg.sender] = msg.value;
        isBetting[msg.sender] = true;
        selectedTeam[msg.sender] = _selectedTeam;

        payable(address(this)).transfer(amtFee);
        treasury.transfer(fee);
        betPool = betPool + msg.value;

        if (_selectedTeam == 1) {
            betA.push(msg.sender);
        } else {
            betB.push(msg.sender);
        }

        emit Betting(msg.sender, msg.value);
    }

    // Get betters on each sides
    function getBetters(uint8 _sides) external view returns (address[] memory) {
        require(_sides != 0, "Invalid Sides");
        if (_sides == 1) {
            return betA;
        } else {
            return betB;
        }
    }

    // Set the winner of each match, since we can't use any APIs in solidity to get the matches winners
    // The owner need to set the value itself
    // This will aslo need community involvement to make sure that the winner is right!
    function setWin(uint8 _isWin) external onlyOwner returns (uint8) {
        require(_isWin != 0, "Can't be empty");
        winningTeam = _isWin;
        return winningTeam;
    }

    // Open / closing bet stage
    function oepnGame(bool _isOpen) external onlyOwner returns (bool) {
        require(_isOpen != openBet, "Value can't be the same!");
        openBet = _isOpen;
        return openBet;
    }

    // Withdraw winning balance
    function Winner() external {
        require(winningTeam != 0, "No Winner Selected");
        require(selectedTeam[msg.sender] == winningTeam, "You didn't win");
        require(isBetting[msg.sender], "You didn't bet");

        uint256 winVal;

        if (winningTeam == 1) {
            winVal = betPool / betA.length;
        } else {
            winVal = betPool / betB.length;
        }

        payable(msg.sender).transfer(winVal);
        emit Win(msg.sender, winVal);
    }

    // Transfer contract ownership
    function transferOwnership(address _newOwner)
        external
        onlyOwner
        returns (address)
    {
        require(_newOwner != address(0), "Can't set new owner to 0 address");
        require(_newOwner != owner, "New owner can't be the same as previous");

        owner = _newOwner;
        return owner;
    }

    // Change treasury address
    function changeTreasury(address payable _treasury)
        external
        onlyOwner
        returns (address)
    {
        require(_treasury != address(0), "Can't set new treasury to 0 address");
        require(
            _treasury != treasury,
            "New treasury can't be the same as previous"
        );

        treasury = _treasury;
        return treasury;
    }

    // Emergency withdrawal for stuck BNB in contract
    // Use with caution, this will clear all contract balance which hold all betters money!
    function clearPool() external onlyOwner {
        require(address(this).balance != 0, "Pool is empty");
        require(openBet, "Bet hasn't been close");
        treasury.transfer(address(this).balance);
    }
}