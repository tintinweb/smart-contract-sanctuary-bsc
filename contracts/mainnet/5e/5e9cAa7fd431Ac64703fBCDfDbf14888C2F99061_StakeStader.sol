// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./IStaker.sol";

import "./StakeStaderStorage.sol";

contract StakeStader is StakeStaderStorage {
    function setImplementation(address newImplementation) external _onlyAdmin_ {
        require(
            IStaker(newImplementation).nameId() ==
                keccak256(abi.encodePacked("StakeStaderImplementation")),
            "StakeStader.setImplementation: not StakeStader implementation"
        );
        implementation = newImplementation;
        emit NewImplementation(newImplementation);
    }

    fallback() external payable {
        _delegate();
    }

    receive() external payable {}

    function _delegate() internal {
        address imp = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), imp, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "../token/IERC20.sol";
import "../utils/INameVersion.sol";
import "../utils/IAdmin.sol";

interface IStaker is INameVersion, IAdmin {
    function deposit() external payable;

    function convertToBnb(uint256 amountInStakerBnb)
        external
        view
        returns (uint256);

    function convertToStakerBnb(uint256 amountInBnb)
        external
        view
        returns (uint256);

    function requestWithdraw(address, uint256) external;

    function claimWithdraw(address) external;

    function stakerBnb() external returns (IERC20);

    function swapStakerBnbToB0(uint256 amountInStakerBnb)
        external
        returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "../utils/Admin.sol";

abstract contract StakeStaderStorage is Admin {
    event NewImplementation(address newImplementation);

    address public implementation;

    uint256 public withdrawlRequestNum;

    mapping(address => uint256) public withdrawalRequestId;

    mapping(uint256 => address) public withdrawlRequestUser;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface INameVersion {
    function nameId() external view returns (bytes32);

    function versionId() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface IAdmin {
    event NewAdmin(address indexed newAdmin);

    function admin() external view returns (address);

    function setAdmin(address newAdmin) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./IAdmin.sol";

abstract contract Admin is IAdmin {
    address public admin;

    modifier _onlyAdmin_() {
        require(msg.sender == admin, "Admin: only admin");
        _;
    }

    constructor() {
        admin = msg.sender;
        emit NewAdmin(admin);
    }

    function setAdmin(address newAdmin) external _onlyAdmin_ {
        admin = newAdmin;
        emit NewAdmin(newAdmin);
    }
}