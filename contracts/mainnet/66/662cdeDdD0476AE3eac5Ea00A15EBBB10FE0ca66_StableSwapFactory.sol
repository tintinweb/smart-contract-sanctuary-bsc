// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./StableSwap.sol";

contract StableSwapFactory is Ownable {
    struct StableSwapPairInfo {
        address swapContract;
        address LPContract;
    }
    StableSwapPairInfo[] public stableSwapPairInfo;

    uint256 public pairLength;

    event NewStableSwapPair(address indexed swapContract, address[] indexed tokens);

    constructor() {}

    /**
     * @notice createSwapPool
     * @param _tokenList: Addresses of ERC20 contracts .
     * @param _A: Amplification coefficient multiplied by n * (n - 1)
     * @param _fee: Fee to charge for exchanges
     * @param _admin_fee: Admin fee
     */
    function createSwapPool(
        address[] memory _tokenList,
        uint256 _A,
        uint256 _fee,
        uint256 _admin_fee
    ) external onlyOwner {

        // create swap contract
        bytes memory bytecode = type(StableSwap).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_tokenList, msg.sender, block.timestamp, block.chainid));
        address swapContract;
        assembly {
            swapContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        StableSwap(swapContract).initialize(_tokenList, _A, _fee, _admin_fee, msg.sender);

        StableSwapPairInfo memory info = StableSwapPairInfo(swapContract, address(StableSwap(swapContract).token()));
        stableSwapPairInfo.push(info);
        pairLength += 1;

        emit NewStableSwapPair(swapContract, _tokenList);
    }

}