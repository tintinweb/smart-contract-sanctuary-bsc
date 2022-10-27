pragma solidity =0.6.12;

import './Fintoch.sol';

contract FintochFactory {
    bytes32 public constant INIT_CODE_FINTOCH_HASH = keccak256(abi.encodePacked(type(Fintoch).creationCode));

    uint256 private createNonce;

    address[] public allBorrowAddrs;

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'FintochFactory: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    event FintochCreated(address indexed sender, address newBorrowAddr, uint256 nonce);

    event FintochPledged(
        address indexed sender,
        address indexed pledgeAddr,
        address indexed tokenAddr,
        uint256 pledgeAmount,
        string  payload
    );

    function borrowPledgeETH(
        address payable pledgeAddr,
        address[] calldata owners,
        uint required,
        string calldata payload
    ) external lock payable {
        require(pledgeAddr != address(0), "Cannot be zero address");
        require(pledgeAddr != address(this), "Cannot be factory address");
        bytes memory bytecode = type(Fintoch).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, createNonce));
        address payable newBorrowAddr;
        assembly {
            newBorrowAddr := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Fintoch(newBorrowAddr).initialize(owners, required);
        allBorrowAddrs.push(newBorrowAddr);
        emit FintochCreated(msg.sender, newBorrowAddr, createNonce);
        createNonce++;
        pledgeAddr.transfer(msg.value);
        emit FintochPledged(msg.sender, pledgeAddr, address(0x0), msg.value, payload);
    }

    function borrowPledge(
        address tokenAddr,
        address pledgeAddr,
        uint256 pledgeAmount,
        address[] calldata owners,
        uint required,
        string calldata payload
    ) external lock {
        require(pledgeAddr != address(0), "Cannot be zero address");
        require(pledgeAddr != address(this), "Cannot be factory address");
        bytes memory bytecode = type(Fintoch).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, createNonce));
        address payable newBorrowAddr;
        assembly {
            newBorrowAddr := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Fintoch(newBorrowAddr).initialize(owners, required);
        allBorrowAddrs.push(newBorrowAddr);
        emit FintochCreated(msg.sender, newBorrowAddr, createNonce);
        createNonce++;
        Erc20(tokenAddr).transferFrom(msg.sender, pledgeAddr, pledgeAmount);
        emit FintochPledged(msg.sender, pledgeAddr, tokenAddr, pledgeAmount, payload);
    }

}