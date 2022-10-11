// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./StableSwap.sol";

contract StableSwapFactory is Ownable {
    struct StableSwapPairInfo {
        address swapContract;
        address[] tokens;
        address LPContract;
    }
    mapping(uint256 => StableSwapPairInfo) stableSwapPairInfo;
    mapping(uint256 => address) public swapPairContract;

    uint256 public pairLength;

    event NewStableSwapPair(address indexed swapContract, address[] indexed tokens);

    constructor() {}

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function checkZeroAddress(address[] memory _tokenList) internal pure {
        uint256 length = _tokenList.length;
        for(uint i = 0; i <length; ++i){
            require(_tokenList[i] != address(0), "Zero");
        }
    }

    /**
     * @notice createSwapPair
     * @param _tokenList: Addresses of ERC20 conracts .
     * @param _A: Amplification coefficient multiplied by n * (n - 1)
     * @param _fee: Fee to charge for exchanges
     * @param _admin_fee: Admin fee
     */
    function createSwapPair(
        address[] memory _tokenList,
        uint256 _A,
        uint256 _fee,
        uint256 _admin_fee
    ) external onlyOwner {
        checkZeroAddress(_tokenList);
        StableSwapPairInfo storage info = stableSwapPairInfo[pairLength];
        require(info.swapContract == address(0), "Pair already exists");
        address[] memory coins = _tokenList;
        // create swap contract
        bytes memory bytecode = type(StableSwap).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_tokenList, msg.sender, block.timestamp, block.chainid));
        address swapContract;
        assembly {
            swapContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        StableSwap(swapContract).initialize(coins, _A, _fee, _admin_fee, msg.sender);

        swapPairContract[pairLength] = swapContract;

        info.swapContract = swapContract;
        info.tokens = _tokenList;
        info.LPContract = address(StableSwap(swapContract).token());
        pairLength += 1;

        emit NewStableSwapPair(swapContract, _tokenList);
    }

    function getPairInfo(address _tokenA, address _tokenB) external view returns (StableSwapPairInfo memory info) {
        //(address t0, address t1) = sortTokens(_tokenA, _tokenB);
        //info = stableSwapPairInfo[t1];
    }
}