// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "./interfaces/IMasterContract.sol";

interface IOwnable {
    function transferOwnership(address newOwner) external;
}

contract BaseFactory  {
    function transferOwnership(address owned, address newOwner) external {
        IOwnable(owned).transferOwnership(newOwner);
    }

    function deploy(address masterContract, bytes calldata data) public payable returns (address cloneAddress) {
        require(masterContract != address(0), 'BaseFactory: No masterContract');
        bytes20 targetBytes = bytes20(masterContract); // Takes the first 20 bytes of the masterContract's address

        // each masterContract has different code already. So clones are distinguished by their data only.
        bytes32 salt = keccak256(data);

        // Creates clone, more info here: https://blog.openzeppelin.com/deep-dive-into-the-minimal-proxy-contract/
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            cloneAddress := create2(0, clone, 0x37, salt)
        }
        IMasterContract(cloneAddress).init{value: msg.value}(data);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMasterContract {
    function init(bytes calldata data) external payable;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import './BaseFactory.sol';

contract W3ToolsFactory  {
    BaseFactory public immutable factory;
    address public immutable w3toolsErc20Impl;
    address public immutable w3toolsErc721Impl;

    event Erc20Created(address indexed sender, address indexed proxy);
    event Erc721Created(address indexed sender, address indexed proxy);

    constructor(BaseFactory _factory, address _w3toolsErc20Impl, address _w3toolsErc721Impl) {
        factory = _factory;
        w3toolsErc20Impl = _w3toolsErc20Impl;
        w3toolsErc721Impl = _w3toolsErc721Impl;
    }

    function createErc20(string memory name, string memory symbol) public {
        bytes memory data = abi.encode(name, symbol);
        address proxy = factory.deploy(w3toolsErc20Impl, data);
        factory.transferOwnership(proxy, msg.sender);

        emit Erc20Created(msg.sender, proxy);
    }
    
    function createErc721(string memory name, string memory symbol, string memory baseURI) public {
        bytes memory data = abi.encode(name, symbol, baseURI);
        address proxy = factory.deploy(w3toolsErc721Impl, data);
        factory.transferOwnership(proxy, msg.sender);

        emit Erc721Created(msg.sender, proxy);
    }
}