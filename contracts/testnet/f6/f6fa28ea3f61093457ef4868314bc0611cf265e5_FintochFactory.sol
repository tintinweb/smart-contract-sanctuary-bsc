pragma solidity =0.6.12;

import './Fintoch.sol';

contract FintochFactory {
    bytes32 public constant INIT_CODE_FINTOCH_HASH = keccak256(abi.encodePacked(type(Fintoch).creationCode));

    uint256 private createNonce;

    address[] public allBorrowAddrs;

    event FintochCreated(address indexed sender, uint256 nonce, address newBorrowAddr, uint256 l);

    event FintochPledged(address indexed sender, address indexed pledgeAddr, address tokenAddr, uint256 amount);

    function borrowPledgeETH(address payable pledgeAddr, address[] memory _owners, uint _required) external payable returns (address payable newBorrowAddr) {
        require(pledgeAddr != address(0), "Cannot be zero address");
        require(pledgeAddr != address(this), "Cannot be factory address");
        bytes memory bytecode = type(Fintoch).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, createNonce));
        assembly {
            newBorrowAddr := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Fintoch(newBorrowAddr).initialize(_owners, _required);
        allBorrowAddrs.push(newBorrowAddr);
        emit FintochCreated(msg.sender, createNonce, newBorrowAddr, allBorrowAddrs.length);
        createNonce++;
        pledgeAddr.transfer(msg.value);
        emit FintochPledged(msg.sender, pledgeAddr, address(0x0), msg.value);
    }

    function borrowPledge(address tokenAddr, address pledgeAddr, uint256 pledgeAmount, address[] memory _owners, uint _required) external returns (address payable newBorrowAddr) {
        require(pledgeAddr != address(0), "Cannot be zero address");
        require(pledgeAddr != address(this), "Cannot be factory address");
        bytes memory bytecode = type(Fintoch).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, createNonce));
        assembly {
            newBorrowAddr := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Fintoch(newBorrowAddr).initialize(_owners, _required);
        allBorrowAddrs.push(newBorrowAddr);
        emit FintochCreated(msg.sender, createNonce, newBorrowAddr, allBorrowAddrs.length);
        createNonce++;
        Erc20(tokenAddr).transferFrom(msg.sender, pledgeAddr, pledgeAmount);
        emit FintochPledged(msg.sender, pledgeAddr, tokenAddr, pledgeAmount);
    }

}