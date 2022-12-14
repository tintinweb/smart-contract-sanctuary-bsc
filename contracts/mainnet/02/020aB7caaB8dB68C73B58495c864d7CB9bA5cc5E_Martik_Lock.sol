/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Martik_Lock {
    address private _owner = msg.sender;

    modifier onlyOwner() {
        require(
            _owner == msg.sender,
            "Ownable: only owner can call this function"
        );
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    address[] Contracts;
    mapping(address => address[]) public ContractLock;
    mapping(address => mapping(address => uint256[])) public Locks;

    function locksview() public view returns (address[] memory) {
        return Contracts;
    }

    function unLock(address _contract) public {
        require(Locks[msg.sender][_contract][0] != 0); //if have lock
        uint256 amount = Locks[msg.sender][_contract][0];
        uint256 endTime = Locks[msg.sender][_contract][1];
        require(block.timestamp > endTime);

        IBEP20(_contract).transfer(msg.sender, amount);

        uint256[] memory per = new uint256[](2);
        per[0] = 0;
        per[1] = 0;
        Locks[msg.sender][_contract] = per;
    }

    function renounceLock(address _contract) external payable {
        Locks[address(0x0000000000000000000000000000000000000000)][
            _contract
        ] = Locks[msg.sender][_contract];

        uint256[] memory per = new uint256[](2);
        per[0] = 0;
        per[1] = 0;
        Locks[msg.sender][_contract] = per;
    }

    function transferLock(address _contract, address _newOwner)
        external
        payable
    {
        require(Locks[msg.sender][_contract][0] != 0);
        require(addOnList(ContractLock[_contract], _newOwner));
        ContractLock[_contract].push(_newOwner);
        Locks[_newOwner][_contract] = Locks[msg.sender][_contract];
        uint256[] memory per = new uint256[](2);
        per[0] = 0;
        per[1] = 0;
        Locks[msg.sender][_contract] = per;
    }

    function updateLock(
        address _contract,
        uint256 _amount,
        uint256 _endTime
    ) external payable {
        require(Locks[msg.sender][_contract][0] != 0); //if have lock

        require(_amount >= Locks[msg.sender][_contract][0]); // if amount is
        require(_endTime >= Locks[msg.sender][_contract][1]); // if time is

        uint256 amtouse = Locks[msg.sender][_contract][0] +
            (_amount - Locks[msg.sender][_contract][0]);

        uint256 oldbalance = IBEP20(_contract).balanceOf(address(this));
        IBEP20(_contract).transferFrom(
            msg.sender,
            address(this),
            _amount - Locks[msg.sender][_contract][0]
        );
        uint256 AM = IBEP20(_contract).balanceOf(address(this)) - oldbalance;
        require(
            AM == _amount - Locks[msg.sender][_contract][0],
            "Send all tokens required"
        );

        uint256[] memory per = new uint256[](2);
        per[0] = amtouse;
        per[1] = _endTime;

        Locks[msg.sender][_contract] = per;
    }

    function addOnList(address[] memory list, address search)
        internal
        pure
        returns (bool)
    {
        for (uint256 v = 0; v < list.length; v++) {
            if (list[v] == search) {
                return false;
            }
        }
        return true;
    }

    function createLock(
        address _locker,
        address _contract,
        uint256 _amount,
        uint256 _endTime
    ) external payable {
        require(_amount > 0);
        require(addOnList(ContractLock[_contract], _locker));

        uint256 oldbalance = IBEP20(_contract).balanceOf(address(this));
        IBEP20(_contract).transferFrom(msg.sender, address(this), _amount);
        uint256 AM = IBEP20(_contract).balanceOf(address(this)) - oldbalance;
        require(AM == _amount, "Send all tokens required");

        uint256[] memory per = new uint256[](2);
        per[0] = _amount;
        per[1] = _endTime;

        Locks[_locker][_contract] = per;

        if (addOnList(Contracts, _contract)) {
            Contracts.push(_contract);
        }
        if (addOnList(ContractLock[_contract], _locker)) {
            ContractLock[_contract].push(_locker);
        }
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
}