/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);

    function withdraw(address payable recipient, uint256 amount) external;
    function withdrawToken(address tokenAddr, address recipient, uint256 amount) external returns (bool);

}

contract Deposit {
    
    address public belongAddr;
    address public factoryAddr;

    constructor(address _factoryAddr, address _belongAddr) {
        factoryAddr = _factoryAddr;
        belongAddr = _belongAddr;
    }

    function withdraw(address payable recipient, uint256 amount) public {
        require(msg.sender == factoryAddr || msg.sender == belongAddr, "ERC20: Address operation permission is invalid");
        recipient.transfer(amount);
    }

    function withdrawToken(address tokenAddr, address recipient, uint256 amount) public returns (bool) {
        require(msg.sender == factoryAddr || msg.sender == belongAddr, "ERC20: Address operation permission is invalid");
        return IERC20(tokenAddr).transfer(recipient, amount);
    }

    fallback() external payable {}
    receive() external payable {}

}

contract TokenFactory {

    address public owner;
    uint256 public counter = 0;
    address public mintFeeTokenAddr;
    uint256 public mintFeeValue;
    uint256 public tokenCounter = 0;

    mapping(address => address) private depositAddrList;
    mapping(uint256 => address[]) private depositAddrListIterator;
    mapping(address => Token[]) private tokenDeployList;

    struct Token {
        address tokenAddr;
        string tokenLogo;
        uint256 createdAt;
    }

    event tokenCreated(address tokenAddr, bytes bytecode);

    constructor() {
        owner = msg.sender;
    }

    function createTokenByCreationCode(string memory name, 
        string memory logo, 
        string memory symbol, 
        uint256 decimals, 
        uint256 totalSupply, 
        bytes memory creationCode) public payable returns (address tokenAddr) {
        require(depositAddrList[msg.sender] != address(0), "TokenFactory: deposit address not exists");
        require(IERC20(mintFeeTokenAddr).balanceOf(depositAddrList[msg.sender]) >= mintFeeValue, "TokenFactory: Insufficient deposit amount");
        IERC20(depositAddrList[msg.sender]).withdrawToken(mintFeeTokenAddr, owner, mintFeeValue);
        bytes memory ctorCode = abi.encode(name, symbol, decimals, totalSupply, msg.sender);
        bytes memory bytecode = abi.encodePacked(creationCode, ctorCode);
        assembly {
            tokenAddr := create2(0, add(bytecode, 0x20), mload(bytecode), callvalue())
            if iszero(extcodesize(tokenAddr)) {
                revert(0, 0)
            }
        }
        tokenDeployList[msg.sender].push(Token(
            tokenAddr,
            logo,
            block.timestamp
        ));
        tokenCounter++;
        emit tokenCreated(tokenAddr, ctorCode);
    }

    function createDepositAddr(address customer) public returns (address) {
        if (depositAddrList[customer] != address(0)) return depositAddrList[customer];

        address depositAddr = address(new Deposit(address(this), customer));
        depositAddrList[customer] = depositAddr;
        depositAddrListIterator[counter].push(customer);
        depositAddrListIterator[counter].push(depositAddr);
        counter++;
        return depositAddr;
    }

    function getDepositAddr(address customer) public view returns (address) {
        require(depositAddrList[msg.sender] != address(0), "TokenFactory: deposit address not exists");
        return depositAddrList[customer];
    }

    function withdraw(uint256 amount) public {
        require(depositAddrList[msg.sender] != address(0), "TokenFactory: deposit address not exists");
        IERC20(depositAddrList[msg.sender]).withdraw(payable(msg.sender), amount);
    }

    function withdrawToken(address tokenAddr, uint256 amount) public returns (bool) {
        require(depositAddrList[msg.sender] != address(0), "TokenFactory: deposit address not exists");
        return IERC20(depositAddrList[msg.sender]).withdrawToken(tokenAddr, msg.sender, amount);
    }

    function getTokenList(address tokenOwner) public view returns (Token[] memory) {
        return tokenDeployList[tokenOwner];
    }

    function setMintFee(uint256 feeValue) public {
        require(msg.sender == owner, "TokenFactory: permission denied");
        mintFeeValue = feeValue;
    }

    function setMintFeeTokenAddr(address tokenAddr) public {
        require(msg.sender == owner, "TokenFactory: permission denied");
        mintFeeTokenAddr = tokenAddr;
    }

}