/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract Signal {
    address public owner;
    uint256 public subscriptionFee = 1 ether;
    uint256 public totalUsers = 0;
    uint256 public totalWinners = 0;
    uint8 public referrerShare = 10;
    uint256 public totalRef = 0;
    uint256 public lastWin = 0;
    uint256 public currentPrize = 0.5 ether;
    uint256 public oneDay = 24 * 60 * 60;
    uint256 private _rnd = 67;

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }

    struct User {
        uint256 payment;
        address wallet;
        bytes32 telegramId;
        uint256 date;
    }

    struct Winner {
        address wallet;
        uint256 prize;
        uint256 date;
    }

    mapping(uint256 => User) private Users;
    mapping(uint256 => Winner) private Winners;
    mapping(address => uint256) private walletAccounts;
    mapping(address => uint256) private referrals;
    mapping(address => bool) private isUser;
    mapping(address => uint256) private lastEntry;

    event Win(bool);

    /**************************************************************************************************
     * @dev modifiers
     **************************************************************************************************/
    modifier nonContract() {
        require(tx.origin == msg.sender, "Contract not allowed");
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not the owner");
        _;
    }

    modifier minimumPayment() {
        require(msg.value >= subscriptionFee, "Registeration fee is low");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    /**************************************************************************************************
     * @dev  Functions
     **************************************************************************************************/
    function TransferOwnership(address newOwner) external onlyOwner nonContract {
        owner = newOwner;
    }

    function ChangePrizeAmount(uint256 newPrize) external onlyOwner nonContract {
        currentPrize = newPrize;
    }

    function SetSubscriptionFee(uint256 newFee) external onlyOwner nonContract {
        subscriptionFee = newFee;
    }

    function SetReferrerShare(uint8 newShare) external onlyOwner nonContract {
        referrerShare = newShare;
    }

    function GetWinners() external view onlyOwner nonContract returns (Winner[] memory) {
        Winner[] memory winners = new Winner[](totalWinners);
        for (uint256 i = 0; i < totalWinners; i++) {
            winners[i] = Winners[i];
        }
        return winners;
    }

    function GetUsers() external view onlyOwner nonContract returns (User[] memory) {
        User[] memory users = new User[](totalUsers);
        for (uint256 i = 0; i < totalUsers; i++) {
            users[i] = Users[i];
        }
        return users;
    }

    function TransferBNB(address to, uint256 amount) public onlyOwner nonContract {
        _transferTokens(to, amount);
    }

    function _transferTokens(address _to, uint256 _amount)
        private
        onlyOwner
        nonReentrant
        nonContract
    {
        uint256 currentBalance = address(this).balance;
        require(currentBalance >= _amount, "insufficient contract balance");
        payable(_to).transfer(_amount);
    }

    /**************************************************************************************************
     * @user  Functions
     **************************************************************************************************/
    function Register(bytes32 _telegram)
        external
        payable
        nonContract
        nonReentrant
        minimumPayment
    {
        Users[totalUsers] = User({
            payment: msg.value,
            wallet: msg.sender,
            telegramId: _telegram,
            date: block.timestamp
        });
        walletAccounts[msg.sender] = walletAccounts[msg.sender] + 1;
        isUser[msg.sender] = true;
        totalUsers++;
    }

    function RefRegister(bytes32 _telegram, address ref)
        external
        payable
        nonContract
        nonReentrant
        minimumPayment
    {
        Users[totalUsers] = User({
            payment: msg.value,
            wallet: msg.sender,
            telegramId: _telegram,
            date: block.timestamp
        });
        walletAccounts[msg.sender] = walletAccounts[msg.sender] + 1;
        isUser[msg.sender] = true;
        totalUsers++;

        if (isUser[ref] && ref != msg.sender) {
            referrals[ref] = referrals[ref] + 1;
            payable(ref).transfer((msg.value * referrerShare) / 100);
            totalRef++;
        }
    }

    function GetMyInformation() public view returns (User[] memory) {
        uint256 size = walletAccounts[msg.sender];
        User[] memory users = new User[](size);
        uint256 index = 0;

        for (uint256 i = 0; i < totalUsers; i++) {
            if (Users[i].wallet == msg.sender) {
                users[index] = Users[i];
                index++;
            }
        }

        return users;
    }

    function IsAdmin() public view returns (bool) {
        return address(msg.sender) == address(owner);
    }

    function GetMyTotalReferredUsers() public view returns (uint256) {
        return referrals[msg.sender];
    }

    function UserLuckLastParticipate() public view returns (uint256) {
        return lastEntry[msg.sender];
    }

    function IFeelLucky() public payable nonReentrant returns (bool) {
        require(
            block.timestamp - lastEntry[msg.sender] > oneDay,
            "You can only participate once a day"
        );
        require(
            block.timestamp - lastWin > oneDay,
            "We had a winner for today try tomorrow"
        );

        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    block.coinbase,
                    block.timestamp,
                    block.gaslimit,
                    msg.sender,
                    _rnd
                )
            )
        );

        if (randomNumber % 345678941 == 0) {
            Winners[totalWinners] = Winner({
                wallet: msg.sender,
                prize: currentPrize,
                date: block.timestamp
            });
            totalWinners++;
            lastWin = block.timestamp;
            payable(msg.sender).transfer(currentPrize);
            emit Win(true);

            return true;
        }

        lastEntry[msg.sender] = block.timestamp;
        emit Win(false);
        return false;
    }

    function Hudini(uint256 rnd) public returns (uint256) {
        _rnd =
            uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), rnd))) %
            100;
        return _rnd;
    }
}