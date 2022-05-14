//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/ITreasury.sol";
import "./common/PoWProofable.sol";
import "./common/TransferHelper.sol";

contract Airdrop is PoWProofable {
    struct Config {
        address token;
        uint256 value;
        uint256 etherRequired;
    }

    address public admin = msg.sender;
    Config public config;
    ITreasury public treasury;
    mapping(address => bool) public received;

    constructor(ITreasury _treasury) {
        treasury = _treasury;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Airdrop: Only admin");
        _;
    }

    modifier notReceived {
        require(received[msg.sender] == false, "Airdrop: Already received");
        _;
    }

    modifier notContract {
        require(msg.sender == tx.origin, "Airdrop: Call from contract");
        _;
    }

    modifier isActive {
        require(config.token != address(0) && config.value != 0, "Airdrop: disabled");
        _;
    }

    function setConfigAirdrop(
        address _token,
        uint256 _value,
        uint256 _etherRequired
    ) external onlyAdmin {
        config = Config(
            _token,
            _value,
            _etherRequired
        );
    }

    function setDifficulty(uint8 newDifficulty) external onlyAdmin {
        _setDifficulty(newDifficulty);
    }

    function airdrop(bytes32 proof) 
        external 
        payable 
        isActive 
        notReceived 
        verifiedProof(proof) 
        notContract 
    {
        require(msg.value == config.etherRequired, "Airdrop: Invalid msg.value");

        received[msg.sender] = true;
        treasury.withdraw(config.token, msg.sender, config.value);
        TransferHelper.safeTransferETH(address(treasury), address(this).balance);
    }

    function flushToken(address token, uint256 value) external {
        TransferHelper.safeTransfer(token, address(treasury), value);
    }

    function etherRequired() public view returns (uint256) {
        return config.etherRequired;
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface ITreasury {
    function withdrawEth(address to, uint256 value) external;
    function withdraw(address token, address to, uint256 value) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

contract PoWProofable {
    event SetDifficulty(
        uint8 oldDifficulty, 
        uint8 newDifficulty
    );

    event UpdateAccountIndex(
        address account,
        uint256 index
    );

    mapping(address => uint256) public indexes;
    uint8 public difficulty = 10;

    modifier verifiedProof(bytes32 proof) {
        require(
            _verifyProof(msg.sender, indexes[msg.sender]++, proof, difficulty), 
            "PoWProofable: Proof not verified"
        );
        emit UpdateAccountIndex(msg.sender, indexes[msg.sender]);
        _;
    }

    function getProofHash(address caller, uint256 index, bytes32 proof) public pure returns (bytes32 hash) {
        hash = keccak256(abi.encode(uint160(caller), index, proof));
    }

    function _byteDiff(bytes1 b) private pure returns (uint8) {
        uint8 curDiff = 0;
        for (uint8 j = 0; j < 8; j++) {
            if((uint8(b) & 1 << j) == 0) {
                curDiff += 1;
            } else {
                break;
            }
        }
        return curDiff;
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function _check(bytes32 h, uint8 diff) private pure returns (bool) {
        uint8 curDiff = 0;
        for (uint8 i = 0; i <= h.length; i++) {
            uint8 currByteDiff = _byteDiff(h[i]);
            curDiff += currByteDiff;
            if(currByteDiff != 8) break;
        }
        return curDiff >= diff;
    }

    function _verifyProof(address caller, uint256 index, bytes32 proof, uint8 diff) internal pure returns (bool) {
        bytes32 hash = getProofHash(caller, index, proof);
        require(diff <= hash.length, "PoWProofable: Invalid difficulty");
        
        return _check(hash, diff);
    }

    function _setDifficulty(uint8 newDifficulty) internal {
        emit SetDifficulty(difficulty, newDifficulty);
        difficulty = newDifficulty;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: approve"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: transfer"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: transferFrom"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH transfer");
    }
}