pragma solidity ^0.8.7;

contract StakingMultiRewardsRedeem {
    address stakingAddress;
    address token;

    constructor(address stakingContract, address _token) {
        stakingAddress = stakingContract;
        token = _token;
    }

    function withdrawMulti(address[] memory list) external {
        (bool success, bytes memory result) = (stakingAddress.staticcall(abi.encodeWithSignature("currentRound()")));
        require(success, "Failed get current round!");
        uint256 lastRound = abi.decode(result, (uint256));
        for (uint256 i = 0; i <= list.length; i++) {
            address current = list[i];
            (success, result) = (stakingAddress.staticcall(abi.encodeWithSignature("getLastClaimedRound(address)", current)));
            require(success, "Failed get person round!");
            uint256 lastAddressRound = abi.decode(result, (uint256));
            if (lastAddressRound >= lastRound)
                continue;
            (success, result) = (stakingAddress.staticcall(abi.encodeWithSignature("pendingReflections(address,address)", token, current)));
            require(success, "Failed get person pending reflections!");
            uint256 tokenRewards = abi.decode(result, (uint256));
            if (tokenRewards > 0) {
                (success, result) = (stakingAddress.call(abi.encodeWithSignature("claimPendingReflectionsFor(address)", current)));
                require(success, "Failed claim person pending reflections!");
            }
            (success, result) = (stakingAddress.staticcall(abi.encodeWithSignature("getPendingRewards(address,address)", token, current)));
            require(success, "Failed get person pending token rewards!");
            uint256 pendingToken = abi.decode(result, (uint256));
            
            (success, result) = (stakingAddress.staticcall(abi.encodeWithSignature("getPendingRewards(address,address)", address(0), current)));
            require(success, "Failed get person pending token rewards!");
            uint256 pendingNative = abi.decode(result, (uint256));
            if (pendingToken > 0){
                (bool success, ) = (stakingAddress.call(abi.encodeWithSignature("withdrawTokenRewardForReceiver(address,address)", token, current)));
                require(success, "Failed withdraw of token!");
            }
            if (pendingNative > 0) {
                (bool success, ) = stakingAddress.call(abi.encodeWithSignature("withdrawTokenRewardForReceiver(address,address)", address(0), current));
                require(success, "Failed withdraw of token!");
            }
        }
    }

    function currentRoundTest(address[] memory list) public view returns(uint256) {
        (bool success, bytes memory result) = (stakingAddress.staticcall(abi.encodeWithSignature("currentRound()")));
        require(success, "Failed get current round!");
        return abi.decode(result, (uint256));
    }

    function getLastClaimedRoundTest(address[] memory list) public view returns(uint256) {
        for (uint256 i = 0; i <= list.length; i++) {
            address current = list[i];
            (bool success, bytes memory result) = (stakingAddress.staticcall(abi.encodeWithSignature("getLastClaimedRound(address)", current)));
            require(success, "Failed get person round!");
            uint256 lastAddressRound = abi.decode(result, (uint256));
        }
        return 0;
    }

     function pendingReflectionsTest(address[] memory list) public view returns(uint256) {
        for (uint256 i = 0; i <= list.length; i++) {
            address current = list[i];
            (bool success, bytes memory result) = (stakingAddress.staticcall(abi.encodeWithSignature("pendingReflections(address,address)", token, current)));
            require(success, "Failed get person pending reflections!");
            uint256 tokenRewards = abi.decode(result, (uint256));
        }
        return 0;
    }

    function claimPendingReflectionsForTest(address[] memory list) public {
        for (uint256 i = 0; i <= list.length; i++) {
            address current = list[i];
            (bool success, bytes memory result) = (stakingAddress.staticcall(abi.encodeWithSignature("claimPendingReflectionsFor(address)", current)));
            require(success, "Failed claim person pending reflections!");
        }
    }

    function withdrawTokenRewardForReceiverTokenTest(address[] memory list) public {
        for (uint256 i = 0; i <= list.length; i++) {
            address current = list[i];
            (bool success, ) = stakingAddress.call(abi.encodeWithSignature("withdrawTokenRewardForReceiver(address,address)", token, current));
            require(success, "Failed withdraw of token!");
        }
    }

    function withdrawTokenRewardForReceiverNativeTest(address[] memory list) public {
        for (uint256 i = 0; i <= list.length; i++) {
            address current = list[i];
            (bool success, ) = stakingAddress.call(abi.encodeWithSignature("withdrawTokenRewardForReceiver(address,address)", address(0), current));
            require(success, "Failed withdraw of token!");
        }
    }
}