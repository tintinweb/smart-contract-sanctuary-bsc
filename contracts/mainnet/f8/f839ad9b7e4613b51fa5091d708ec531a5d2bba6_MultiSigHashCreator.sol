/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

contract MultiSigHashCreator{
    enum proposal{
        undefined,
        pause,
        limit,
        banned,
        lock,
        restrict,
        burn,
        transfer,
        signer
    }

    function createBannedHash(
        uint256 proposalId,
        address[] memory userBannedParams,
        bool userStatusParam
    ) public pure returns(bytes32){
        unchecked{
            bytes32 tempHash = keccak256(
                abi.encodePacked(
                    proposalId,
                    proposal.banned,
                    userBannedParams,
                    userStatusParam
                )
            );

            return tempHash;
        }
    }
    function createLockHash(
        uint256 proposalId,
        address[] memory userLockParams,
        uint256 deadlineLockParam
    ) public pure returns(bytes32){
        unchecked{
            bytes32 tempHash = keccak256(
                abi.encodePacked(
                    proposalId,
                    proposal.lock,
                    userLockParams,
                    deadlineLockParam
                )
            );

            return tempHash;
        }
    }
    function createRestrictHash(
        uint256 proposalId,
        address[] memory userRestrictParams,
        address[] memory whitelistParams
    ) public pure returns(bytes32){
        unchecked{
            bytes32 tempHash = keccak256(
                abi.encodePacked(
                    proposalId,
                    proposal.restrict,
                    userRestrictParams,
                    whitelistParams
                )
            );

            return tempHash;
        }
    }
    function createLimitHash(
        uint256 proposalId,
        uint256 amountTransferLimitParam,
        uint256 longTimeDelayParam
    ) public pure returns(bytes32){
        unchecked{
            bytes32 tempHash = keccak256(
                abi.encodePacked(
                    proposalId,
                    proposal.limit,
                    amountTransferLimitParam,
                    longTimeDelayParam
                )
            );

            return tempHash;
        }
    }
    function createPauseHash(
        uint256 proposalId,
        bool pauseStatusParam
    ) public pure returns(bytes32){
        unchecked{
            bytes32 tempHash = keccak256(
                abi.encodePacked(
                    proposalId,
                    proposal.pause,
                    pauseStatusParam
                )
            );

            return tempHash;
        }
    }
    function createBurnHash(
        uint256 proposalId,
        uint256 burnAmountParam
    ) public pure returns(bytes32){
        unchecked{
            bytes32 tempHash = keccak256(
                abi.encodePacked(
                    proposalId,
                    proposal.burn,
                    burnAmountParam
                )
            );

            return tempHash;
        }
    }
    function createSignerHash(
        uint256 proposalId,
        address signerParam,
        bool signerStatusParam
    ) public pure returns(bytes32){
        unchecked{
            bytes32 tempHash = keccak256(
                abi.encodePacked(
                    proposalId,
                    proposal.signer,
                    signerParam,
                    signerStatusParam
                )
            );

            return tempHash;
        }
    }

    function _asSingletonBytesArray(bytes memory element) private pure returns (bytes[] memory) {
        bytes[] memory array = new bytes[](1);
        array[0] = element;

        return array;
    }
}