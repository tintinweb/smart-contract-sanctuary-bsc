/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScoreBet {
    address public owner;
    address payable public treasury;

    uint8 public winningTeam;
    uint256 public betPool = 0;

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
    function Bet(uint256 _amount, uint8 _selectedTeam) external payable {
        uint256 fee = _amount / 100;
        uint256 amtFee = _amount + fee;

        require(_amount != 0, "Amount Can't Be Zero");
        require(_selectedTeam != 0, "Need to choose a team");
        require(msg.value == amtFee, "Insufficient Balance To Bet");
        require(msg.sender != address(0), "Invalid Address");
        require(!isBetting[msg.sender], "You already take a bet");

        betValue[msg.sender] = _amount;
        isBetting[msg.sender] = true;
        selectedTeam[msg.sender] = _selectedTeam;

        payable(address(this)).transfer(amtFee);
        treasury.transfer(fee);
        betPool = betPool + _amount;

        if (_selectedTeam == 1) {
            betA.push(msg.sender);
        } else {
            betB.push(msg.sender);
        }

        emit Betting(msg.sender, _amount);
    }

    // Set the winner of each match, since we can't use any APIs in solidity to get the matches winners
    // The owner need to set the value itself
    // This will aslo need community involvement to make sure that the winner is right!
    function setWin(uint8 _isWin) external onlyOwner returns (uint256) {
        require(_isWin != 0, "Can't be empty");
        winningTeam = _isWin;
        return winningTeam;
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
        betPool = betPool - winVal;
        emit Win(msg.sender, winVal);
    }

    // Transfer contract ownership
    function transferOwnership(address _newOwner)
        external
        onlyOwner
        returns (bool)
    {
        require(_newOwner != address(0), "Can't set new owner to 0 address");
        require(_newOwner != owner, "New owner can't be the same as previous");

        owner = _newOwner;
        return true;
    }

    // Change treasury address
    function changeTreasury(address payable _treasury)
        external
        onlyOwner
        returns (bool)
    {
        require(_treasury != address(0), "Can't set new owner to 0 address");
        require(
            _treasury != treasury,
            "New treasury can't be the same as previous"
        );

        treasury = _treasury;
        return true;
    }
}