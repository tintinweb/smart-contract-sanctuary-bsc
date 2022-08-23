// SPDX-License-Identifier: Logicalis
pragma solidity >=0.7.0 <0.9.0;

import "./Wallet.sol";
import "./Transaction.sol";

contract Factory {
    address owner;

    struct wallet_struct {
        Wallet wallet;
        bool exists;
    }


    mapping(string => wallet_struct) public wallets;
    string[] public all_wallets;

    constructor() {
        owner = msg.sender;
    }

    function createWallet(
        string memory _email,
        uint256 _points,
        uint256 _neutralizationPoints,
        uint256 _createdAt
    ) public {
        require(wallets[_email].exists == false, "user already has a wallet");
        Wallet wallet = new Wallet(
            _points,
            _neutralizationPoints,
            _email,
            _createdAt
        );
        wallets[_email] = wallet_struct(wallet, true);
        all_wallets.push(_email);
    }

    function addCredits(
        address _wallet,
        uint256 _points,
        uint256 _neutralizationPoints,
        uint256 _timestamp
    ) public {
        Wallet wallet = Wallet(_wallet);
        Transaction transaction = new Transaction(
            address(this),
            _wallet,
            _points,
            _neutralizationPoints,
            "Buy credit",
            true,
            _timestamp
        );
        wallet.addCredits(
            _points,
            _neutralizationPoints,
            address(transaction),
            _timestamp
        );
    }

    function createWalletTransaction(
        address _origin,
        address _target,
        uint256 _points,
        uint256 _neutralizationPoints,
        uint256 _timestamp
    ) public {
        Wallet origin = Wallet(_origin);
        Wallet target = Wallet(_target);
        uint256 originAmount = origin.getPoints();
        require(
            originAmount >= _points,
            "origin wallet doesnt have enough points"
        );
        Transaction transaction = new Transaction(
            _origin,
            _target,
            _points,
            _neutralizationPoints,
            "Wallet transaction",
            false,
            _timestamp
        );
        origin.addDebits(
            _points,
            _neutralizationPoints,
            address(transaction),
            _timestamp
        );
        target.addCredits(
            _points,
            _neutralizationPoints,
            address(transaction),
            _timestamp
        );
    }
}