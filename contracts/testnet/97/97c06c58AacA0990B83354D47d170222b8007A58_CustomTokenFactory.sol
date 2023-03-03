// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./ERC20.sol";
import "./Ownable.sol";

contract ERC20MintableBurnable is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}
    
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
    
    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

    function transferTokenOwnership(address newOwner) public onlyOwner {
        transferOwnership(newOwner);
    }
}

contract CustomTokenFactory {
    mapping(string => address) private _tokenAddresses;
    address payable private _developerAddress;
    
    event TokenCreated(address indexed tokenAddress, string name, string symbol, uint256 initialSupply);
    
    constructor() {
        _developerAddress = payable(msg.sender);
    }

function createToken(string memory name, string memory symbol, uint256 initialSupply) external payable {
    require(msg.value == 0.01 ether, "Please pay exactly 1 BNB");
    require(_tokenAddresses[symbol] == address(0), "Token with the same symbol already exists");
    
    ERC20MintableBurnable token = new ERC20MintableBurnable{salt: keccak256(abi.encodePacked(symbol))}(name, symbol);
    token.mint(msg.sender, initialSupply);
    token.transferTokenOwnership(msg.sender);
    _developerAddress.transfer(msg.value);
    
    _tokenAddresses[symbol] = address(token);
    
    emit TokenCreated(address(token), name, symbol, initialSupply);
    
    // Transfer the token and its contract to the caller
    (bool success,) = msg.sender.delegatecall(
        abi.encodeWithSignature("receiveToken(address,uint256)", address(token), initialSupply)
    );
    require(success, "Failed to send token and its contract to the caller");
}

    
    function getTokenAddress(string memory symbol) external view returns (address) {
        return _tokenAddresses[symbol];
    }
}