/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract custodiy {
    address private owner;
    mapping(address => user) private users;
    mapping(string => myContract) private contracts;
    mapping(string => mySafeBox) mySafeBoxes;


    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    struct user {
        address userId;
        string name;
        string lastname;
        string password;
        string email;
        string privateKey;
        bool isExist;
    }

    struct mySafeBox {
        string safeBoxId;
        string files;
        string name;
        string Date;
        address ownersb;
        address[] Approver;
        string status;
    }

    struct myContract {
        string contractId;
        string Amount;
        address Transfer;
        address Beneficiary;
        string Date;
        address Approver;
        string status;
    }

    function addSafeBox(
        string safeBoxId,
        string files,
        string name,
        string Date,
        address ownersb,
        address[] Approver,
        string status
    ) public {
        mySafeBoxes[safeBoxId] = mySafeBox(
            safeBoxId,
            files,
            name,
            Date,
            ownersb,
            Approver,
            status
        );
    }

    function getSafeBox(string safeBoxId)
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            address,
            address[],
            string memory
        )
    {
        return (
            mySafeBoxes[safeBoxId].files,
            mySafeBoxes[safeBoxId].name,
            mySafeBoxes[safeBoxId].Date,
            mySafeBoxes[safeBoxId].ownersb,
            mySafeBoxes[safeBoxId].Approver,
            mySafeBoxes[safeBoxId].status
        );
    }

    function updateSafeBox(
        string safeBoxId,
        string _status
    ) public {
        mySafeBoxes[safeBoxId].status = _status;
    }
    function register(
        address userId,
        string memory name,
        string memory lastname,
        string password,
        string email,
        string privatekey
    ) public onlyOwner {
        require(
            users[userId].isExist == false,
            'user details already registered and cannot be altered'
        );
        users[userId] = user(userId, name, lastname, password, email, privatekey, true);
    }

    function getuserDetails(address userId, string password)
        public
        view
        onlyOwner
        returns (
            address,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        require(
            keccak256(abi.encodePacked(users[userId].password)) ==
                keccak256(abi.encodePacked(password))
        );
        return (
            users[userId].userId,
            users[userId].name,
            users[userId].lastname,
            users[userId].password,
            users[userId].email
        );
    }

    function getPrivateKey(address userId, string memory email)
        public
        view
        onlyOwner
        returns (string)
    {
        require(users[userId].isExist == true, 'User not found!');
        require(
            keccak256(abi.encodePacked(users[userId].email)) == keccak256(abi.encodePacked(email)),
            'User not found!'
        );
        return users[userId].privateKey;
    }

    function changePassword(
        address userId,
        string memory email,
        string memory oldPassword,
        string memory newPassword
    ) public {
        require(users[userId].isExist == true, 'User not found!');
        require(
            keccak256(abi.encodePacked(users[userId].email)) == keccak256(abi.encodePacked(email)),
            'User not found!'
        );
        require(
            keccak256(abi.encodePacked(users[userId].password)) ==
                keccak256(abi.encodePacked(oldPassword)),
            'Password not correct!'
        );
        users[userId].password = newPassword;
    }

    function resetPassword(
        address userId,
        string email,
        string password
    ) public onlyOwner {
        require(users[userId].isExist == true, 'User not found!');
        require(
            keccak256(abi.encodePacked(users[userId].email)) == keccak256(abi.encodePacked(email)),
            'User not found!'
        );
        users[userId].password = password;
    }

    function addContract(
        string contractId,
        string Amount,
        address Transfer,
        address Beneficiary,
        string Date,
        address Approver,
        string status
    ) public {
        contracts[contractId] = myContract(
            contractId,
            Amount,
            Transfer,
            Beneficiary,
            Date,
            Approver,
            status
        );
    }

    function getContract(address _userId, string contractId)
        public
        view
        returns (
            string memory,
            string memory,
            address,
            address,
            string memory,
            address,
            string memory
        )
    {
        require(users[_userId].isExist == true, 'User not found!');
        require(
            keccak256(abi.encodePacked(contracts[contractId].Transfer)) ==
                keccak256(abi.encodePacked(_userId)),
            'User not found!'
        );
        return (
            contracts[contractId].contractId,
            contracts[contractId].Amount,
            contracts[contractId].Transfer,
            contracts[contractId].Beneficiary,
            contracts[contractId].Date,
            contracts[contractId].Approver,
            contracts[contractId].status
        );
    }

    function changeStatus(
        address _userId,
        string _contractId,
        string _status
    ) public {
        require(users[_userId].isExist == true, 'User not found!');
        require(
            keccak256(abi.encodePacked(contracts[_contractId].Transfer)) ==
                keccak256(abi.encodePacked(_userId)),
            'User not found!'
        );
        require(
            keccak256(abi.encodePacked(contracts[_contractId].contractId)) ==
                keccak256(abi.encodePacked(_contractId)),
            'User not found!'
        );

        contracts[_contractId].status = _status;
    }

    function _transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}