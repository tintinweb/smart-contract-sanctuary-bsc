// SPDX-License-Identifier: none

pragma solidity >=0.8.0 <0.9.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

// SPDX-License-Identifier: none

pragma solidity >=0.8.0 <0.9.0;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: none

pragma solidity >=0.8.0 <0.9.0;

interface IRestrictable {
    struct limit{
        uint256 limitAmount;
        uint256 delay;
    }

    function bannedUser(
        address[] memory user
    ) external;
    function getOwner() external view returns(address);
    function isAdministrator(
        address user
    ) external view returns(bool);
    function isBanned(
        address user
    ) external view returns(bool);
    function limitInfo() external view returns(limit memory);
    function lockUser(
        address[] memory user,
        uint256 deadline
    ) external;
    function pause() external;
    function paused() external view returns(bool);
    function restrictUser(
        address[] memory user,
        address[] memory whitelist
    ) external;
    function setLimit(
        uint256 amount,
        uint256 delays
    ) external;
    function unbannedUser(
        address[] memory user
    ) external;
    function unlockUser(
        address[] memory user
    ) external;
    function unpause() external;
    function unrestrictUser(
        address[] memory user
    ) external;
    function unsetLimit() external;
    function userTotalWhitelist(
        address user
    ) external view returns(uint256);
    function userWhitelistView(
        address user,
        uint256 index
    ) external view returns(address);
}

// SPDX-License-Identifier: none

pragma solidity >=0.8.0 <0.9.0;

interface IBEP20Burn{
    function burn(
        uint256 amount
    ) external;
    function balanceOf(
        address account
    ) external view returns (uint256);
    
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: none

pragma solidity >=0.8.0 <0.9.0;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: none

pragma solidity >=0.8.0 <0.9.0;

import "String.sol";

library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

library MultiSigHashCreator{
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
    ) internal pure returns(bytes32){
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
    ) internal pure returns(bytes32){
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
    ) internal pure returns(bytes32){
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
    ) internal pure returns(bytes32){
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
    ) internal pure returns(bytes32){
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
    ) internal pure returns(bytes32){
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
    ) internal pure returns(bytes32){
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

    function _asSingletonBytesArray(bytes memory element) internal pure returns (bytes[] memory) {
        bytes[] memory array = new bytes[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

import "IRestrictable.sol";
import "IBEP20Burn.sol";
import "Context.sol";
import "ReentrancyGuard.sol";
import "ECDSA.sol";
import "MultiSigHashCreator.sol";

contract MultiSigTokenAdmin is Context, ReentrancyGuard{
    uint256 public totalProposal;
    uint256 public totalSigner;
    uint256 public proposalDuration;
    address public managedToken;
    uint256 public nextExecute;
    uint256 public nextExecuteInterval;

    mapping (address => bool) private signerMember;
    mapping (uint256 => proposal) private proposalType;
    mapping (uint256 => proposalCondition) private proposalStatus;
    mapping (uint256 => bannedProposal) private bannedProposalData;
    mapping (uint256 => lockProposal) private lockProposalData;
    mapping (uint256 => restrictProposal) private restrictProposalData;
    mapping (uint256 => limitProposal) private limitProposalData;
    mapping (uint256 => pauseProposal) private pauseProposalData;
    mapping (uint256 => burnProposal) private burnProposalData;
    mapping (uint256 => signerProposal) private signerProposalData;

    struct proposalCondition{
        bool executed;
        uint256 validUntil;
    }
    struct bannedProposal{
        address proposer;
        bytes[] signature;
        address[] userParams;
        bool statusParam;
    }
    struct lockProposal{
        address proposer;
        bytes[] signature;
        address[] userParams;
        uint256 deadlineLockParam;
    }
    struct restrictProposal{
        address proposer;
        bytes[] signature;
        address[] userParams;
        address[] whitelistParams;
    }
    struct limitProposal{
        address proposer;
        bytes[] signature;
        uint256 amountLimitParam;
        uint256 longTimeDelayParam;
    }
    struct pauseProposal{
        address proposer;
        bytes[] signature;
        bool statusParam;
    }
    struct burnProposal{
        address proposer;
        bytes[] signature;
        uint256 amountParam;
    }
    struct signerProposal{
        address proposer;
        bytes[] signature;
        address signerParam;
        bool statusParam;
    }

    enum proposal{
        undefined,
        pause,
        limit,
        banned,
        lock,
        restrict,
        burn,
        signer
    }

    event userBannedProposal(
        uint256 indexed proposalId,
        uint256 indexed timeProposed,
        address indexed proposer,
        address[] userBannedParams,
        bool userStatusParam
    );
    event userLockProposal(
        uint256 indexed proposalId,
        uint256 indexed timeProposed,
        address indexed proposer,
        address[] userLockParams,
        uint256 deadlineLockParam
    );
    event userRestrictProposal(
        uint256 indexed proposalId,
        uint256 indexed timeProposed,
        address indexed proposer,
        address[] userRestrictParams,
        address[] whitelistParams
    );
    event setLimitProposal(
        uint256 indexed proposalId,
        uint256 indexed timeProposed,
        address indexed proposer,
        uint256 amountTransferLimitParam,
        uint256 longTimeDelayParam
    );
    event setPauseProposal(
        uint256 indexed proposalId,
        uint256 indexed timeProposed,
        address indexed proposer,
        bool pauseStatusParam
    );
    event doBurnProposal(
        uint256 indexed proposalId,
        uint256 indexed timeProposed,
        address indexed proposer,
        uint256 burnAmount
    );
    event setSignerProposal(
        uint256 indexed proposalId,
        uint256 indexed timeProposed,
        address indexed proposer,
        address signerParam,
        bool signerStatusParam
    );

    event signProposal(
        uint256 indexed proposalId,
        address indexed signer,
        uint256 indexed timeSignProposal
    );

    event executeProposal(
        uint256 indexed proposalId,
        proposal indexed proposalType,
        uint256 indexed proposalExecuteTime
    );

    constructor(
        address token,
        address secondSigner
    ){
        managedToken = token;
        signerMember[_msgSender()] = true;
        signerMember[secondSigner] = true;
        totalSigner = 2;
        proposalDuration = 3 days;
        nextExecuteInterval = 2 days;
    }

    function createBannedProposal(
        bytes memory proposalSignature,
        address[] memory userBannedParams,
        bool userStatusParam
    ) external isGranted nonReentrant{
        require(
            isSigner(_msgSender()),
            "MultiSigTokenAdmin : You are not signer member"
        );

        uint256 tempId = totalProposal;

        for(uint256 a; a < userBannedParams.length; a++){
            require(
                IRestrictable(managedToken).isBanned(
                    userBannedParams[a]
                ) != userStatusParam,
                "MultiSigTokenAdmin : Some address already on status, please check again"
            );
        }

        require(
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createBannedHash(
                    tempId,
                    userBannedParams,
                    userStatusParam
                )),
                proposalSignature
            ) == _msgSender(),
            "MultiSigTokenAdmin : This address is not proposer"
        );

        bannedProposalData[tempId] = bannedProposal(
            _msgSender(),
            MultiSigHashCreator._asSingletonBytesArray(proposalSignature),
            userBannedParams,
            userStatusParam
        );
        proposalStatus[tempId] = proposalCondition(
            false,
            block.timestamp + proposalDuration
        );
        proposalType[tempId] = proposal.banned;
        totalProposal += 1;

        emit userBannedProposal(
            tempId,
            block.timestamp,
            _msgSender(),
            userBannedParams,
            userStatusParam
        );
    }
    function createLockProposal(
        bytes memory proposalSignature,
        address[] memory userLockParams,
        uint256 deadlineLockParam
    ) external isGranted nonReentrant{
        require(
            isSigner(_msgSender()),
            "MultiSigTokenAdmin : You are not signer member"
        );

        uint256 tempId = totalProposal;

        require(
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createLockHash(
                    tempId,
                    userLockParams,
                    deadlineLockParam
                )),
                proposalSignature
            ) == _msgSender(),
            "MultiSigTokenAdmin : This address is not proposer"
        );

        lockProposalData[tempId] = lockProposal(
            _msgSender(),
            MultiSigHashCreator._asSingletonBytesArray(proposalSignature),
            userLockParams,
            deadlineLockParam
        );
        proposalType[tempId] = proposal.lock;
        proposalStatus[tempId] = proposalCondition(
            false,
            block.timestamp + proposalDuration
        );
        totalProposal += 1;

        emit userLockProposal(
            tempId,
            block.timestamp,
            _msgSender(),
            userLockParams,
            deadlineLockParam
        );
    }
    function createRestrictProposal(
        bytes memory proposalSignature,
        address[] memory userRestrictParams,
        address[] memory whitelistParams
    ) external isGranted nonReentrant{
        require(
            isSigner(_msgSender()),
            "MultiSigTokenAdmin : You are not signer member"
        );

        uint256 tempId = totalProposal;

        require(
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createRestrictHash(
                    tempId,
                    userRestrictParams,
                    whitelistParams
                )),
                proposalSignature
            ) == _msgSender(),
            "MultiSigTokenAdmin : This address is not proposer"
        );

        restrictProposalData[tempId] = restrictProposal(
            _msgSender(),
            MultiSigHashCreator._asSingletonBytesArray(proposalSignature),
            userRestrictParams,
            whitelistParams
        );
        proposalStatus[tempId] = proposalCondition(
            false,
            block.timestamp + proposalDuration
        );
        proposalType[tempId] = proposal.restrict;
        totalProposal += 1;

        emit userRestrictProposal(
            tempId,
            block.timestamp,
            _msgSender(),
            userRestrictParams,
            whitelistParams
        );
    }
    function createLimitProposal(
        bytes memory proposalSignature,
        uint256 amountTransferLimitParam,
        uint256 longTimeDelayParam
    ) external isGranted nonReentrant{
        require(
            isSigner(_msgSender()),
            "MultiSigTokenAdmin : You are not signer member"
        );

        uint256 tempId = totalProposal;

        if(
            IRestrictable(managedToken).limitInfo().limitAmount == 0 &&
            IRestrictable(managedToken).limitInfo().delay == 0
        ){
            require(
                amountTransferLimitParam > 0 &&
                longTimeDelayParam > 0,
                "MultiSigTokenAdmin : Delay and Amount must not zero"
            );
        }else{
            require(
                amountTransferLimitParam == 0 &&
                longTimeDelayParam == 0,
                "MultiSigTokenAdmin : Delay and Amount must zero"
            );
        }

        require(
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createLimitHash(
                    tempId,
                    amountTransferLimitParam,
                    longTimeDelayParam
                )),
                proposalSignature
            ) == _msgSender(),
            "MultiSigTokenAdmin : This address is not proposer"
        );

        limitProposalData[tempId] = limitProposal(
            _msgSender(),
            MultiSigHashCreator._asSingletonBytesArray(proposalSignature),
            amountTransferLimitParam,
            longTimeDelayParam
        );
        proposalStatus[tempId] = proposalCondition(
            false,
            block.timestamp + proposalDuration
        );
        proposalType[tempId] = proposal.limit;
        totalProposal += 1;

        emit setLimitProposal(
            tempId,
            block.timestamp,
            _msgSender(),
            amountTransferLimitParam,
            longTimeDelayParam
        );
    }
    function createPauseProposal(
        bytes memory proposalSignature,
        bool pauseStatusParam
    ) external isGranted nonReentrant{
        require(
            isSigner(_msgSender()),
            "MultiSigTokenAdmin : You are not signer member"
        );

        uint256 tempId = totalProposal;

        require(
            IRestrictable(managedToken).paused() != pauseStatusParam,
            "MultiSigTokenAdmin : This proposal is not needed"
        );

        require(
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createPauseHash(
                    tempId,
                    pauseStatusParam
                )),
                proposalSignature
            ) == _msgSender(),
            "MultiSigTokenAdmin : This address is not proposer"
        );

        pauseProposalData[tempId] = pauseProposal(
            _msgSender(),
            MultiSigHashCreator._asSingletonBytesArray(proposalSignature),
            pauseStatusParam
        );
        proposalStatus[tempId] = proposalCondition(
            false,
            block.timestamp + proposalDuration
        );
        proposalType[tempId] = proposal.pause;
        totalProposal += 1;

        emit setPauseProposal(
            tempId,
            block.timestamp,
            _msgSender(),
            pauseStatusParam
        );
    }
    function createBurnProposal(
        bytes memory proposalSignature,
        uint256 amountBurnParam
    ) external isGranted nonReentrant{
        require(
            isSigner(_msgSender()),
            "MultiSigTokenAdmin : You are not signer member"
        );

        uint256 tempId = totalProposal;

        require(
            IBEP20Burn(managedToken).balanceOf(address(this)) >= amountBurnParam,
            "MultiSigTokenAdmin : Insufficient balance"
        );

        require(
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createBurnHash(
                    tempId,
                    amountBurnParam
                )),
                proposalSignature
            ) == _msgSender(),
            "MultiSigTokenAdmin : This address is not proposer"
        );

        burnProposalData[tempId] = burnProposal(
            _msgSender(),
            MultiSigHashCreator._asSingletonBytesArray(proposalSignature),
            amountBurnParam
        );
        proposalStatus[tempId] = proposalCondition(
            false,
            block.timestamp + proposalDuration
        );
        proposalType[tempId] = proposal.burn;
        totalProposal += 1;

        emit doBurnProposal(
            tempId,
            block.timestamp,
            _msgSender(),
            amountBurnParam
        );
    }
    function createSignerProposal(
        bytes memory proposalSignature,
        address signerParam,
        bool signerStatusParam
    ) external isGranted nonReentrant{
        require(
            isSigner(_msgSender()),
            "MultiSigTokenAdmin : You are not signer member"
        );

        uint256 tempId = totalProposal;

        if(signerStatusParam == false){
            require(
                totalSigner > 2,
                "MultiSigTokenAdmin : Minimum 2 signer is required"
            );
        }
        require(
            signerStatusParam != signerMember[signerParam],
            "MultiSigTokenAdmin : This proposal is not needed"
        );

        require(
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createSignerHash(
                    tempId,
                    signerParam,
                    signerStatusParam
                )),
                proposalSignature
            ) == _msgSender(),
            "MultiSigTokenAdmin : This address is not proposer"
        );

        signerProposalData[tempId] = signerProposal(
            _msgSender(),
            MultiSigHashCreator._asSingletonBytesArray(proposalSignature),
            signerParam,
            signerStatusParam
        );
        proposalStatus[tempId] = proposalCondition(
            false,
            block.timestamp + proposalDuration
        );
        proposalType[tempId] = proposal.signer;
        totalProposal += 1;

        emit setSignerProposal(
            tempId,
            block.timestamp,
            _msgSender(),
            signerParam,
            signerStatusParam
        );
    }

    function signAProposal(
        uint256 proposalId,
        bytes memory upvoteSignature
    ) external isGranted nonReentrant{
        require(
            isSigner(_msgSender()),
            "MultiSigTokenAdmin : You are not signer member"
        );
        require(
            !viewProposalCondition(proposalId).executed &&
            viewProposalCondition(proposalId).validUntil > block.timestamp,
            "MultiSigTokenAdmin : This proposal already executed or expired"
        );
        require(
            isAlreadySigned(
                proposalId,
                upvoteSignature
            ) == false,
            "MultiSigTokenAdmin : You already sign this proposal"
        );

        if(viewProposalType(proposalId) == proposal.banned){
            require(
                ECDSA.recover(
                    ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createBannedHash(
                        proposalId,
                        viewBannedProposal(proposalId).userParams,
                        viewBannedProposal(proposalId).statusParam
                    )),
                    upvoteSignature
                ) == _msgSender(),
                "MultiSigTokenAdmin : This address is not signer"
            );

            bannedProposalData[proposalId].signature.push(upvoteSignature);
        }else if(viewProposalType(proposalId) == proposal.lock){
            require(
                ECDSA.recover(
                    ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createLockHash(
                        proposalId,
                        viewLockProposal(proposalId).userParams,
                        viewLockProposal(proposalId).deadlineLockParam
                    )),
                    upvoteSignature
                ) == _msgSender(),
                "MultiSigTokenAdmin : This address is not signer"
            );

            lockProposalData[proposalId].signature.push(upvoteSignature);
        }else if(viewProposalType(proposalId) == proposal.restrict){
            require(
                ECDSA.recover(
                    ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createRestrictHash(
                        proposalId,
                        viewRestrictProposal(proposalId).userParams,
                        viewRestrictProposal(proposalId).whitelistParams
                    )),
                    upvoteSignature
                ) == _msgSender(),
                "MultiSigTokenAdmin : This address is not signer"
            );

            restrictProposalData[proposalId].signature.push(upvoteSignature);
        }else if(viewProposalType(proposalId) == proposal.limit){
            require(
                ECDSA.recover(
                    ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createLimitHash(
                        proposalId,
                        viewLimitProposal(proposalId).amountLimitParam,
                        viewLimitProposal(proposalId).longTimeDelayParam
                    )),
                    upvoteSignature
                ) == _msgSender(),
                "MultiSigTokenAdmin : This address is not signer"
            );

            limitProposalData[proposalId].signature.push(upvoteSignature);
        }else if(viewProposalType(proposalId) == proposal.pause){
            require(
                ECDSA.recover(
                    ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createPauseHash(
                        proposalId,
                        viewPauseProposal(proposalId).statusParam
                    )),
                    upvoteSignature
                ) == _msgSender(),
                "MultiSigTokenAdmin : This address is not signer"
            );

            pauseProposalData[proposalId].signature.push(upvoteSignature);
        }else if(viewProposalType(proposalId) == proposal.burn){
            require(
                ECDSA.recover(
                    ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createBurnHash(
                        proposalId,
                        viewBurnProposal(proposalId).amountParam
                    )),
                    upvoteSignature
                ) == _msgSender(),
                "MultiSigTokenAdmin : This address is not signer"
            );

            burnProposalData[proposalId].signature.push(upvoteSignature);
        }else if(viewProposalType(proposalId) == proposal.signer){
            require(
                ECDSA.recover(
                    ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createSignerHash(
                        proposalId,
                        viewSignerProposal(proposalId).signerParam,
                        viewSignerProposal(proposalId).statusParam
                    )),
                    upvoteSignature
                ) == _msgSender(),
                "MultiSigTokenAdmin : This address is not signer"
            );

            signerProposalData[proposalId].signature.push(upvoteSignature);
        }else{
            revert(
                "MultiSigTokenAdmin : This proposal is undefined or not proposed before"
            );
        }

        emit signProposal(
            proposalId,
            _msgSender(),
            block.timestamp
        );
    }

    function executeAProposal(
        uint256 proposalId
    ) external isGranted isNextExecuteElapsed nonReentrant{
        require(
            isSigner(_msgSender()),
            "MultiSigTokenAdmin : You are not signer member"
        );
        require(
            !viewProposalCondition(proposalId).executed &&
            viewProposalCondition(proposalId).validUntil > block.timestamp,
            "MultiSigTokenAdmin : This proposal already executed or expired"
        );

        if(viewProposalType(proposalId) == proposal.banned){
            require(
                viewBannedProposal(proposalId).signature.length >= minimalSignedRequired(),
                "MultiSigTokenAdmin : Insufficient minimum required signer"
            );
            for(uint256 a; a < viewBannedProposal(proposalId).signature.length; a++){
                require(
                    isSigner(
                        ECDSA.recover(
                            ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createBannedHash(
                                proposalId,
                                viewBannedProposal(proposalId).userParams,
                                viewBannedProposal(proposalId).statusParam
                            )),
                            viewBannedProposal(proposalId).signature[a]
                        )
                    ),
                    "MultiSigTokenAdmin : Some address is not signer member anymore, this proposal is invalid"
                );
            }

            if(viewBannedProposal(proposalId).statusParam){
                IRestrictable(managedToken).bannedUser(
                    viewBannedProposal(proposalId).userParams
                );
            }else{
                IRestrictable(managedToken).unbannedUser(
                    viewBannedProposal(proposalId).userParams
                );
            }
        }else if(viewProposalType(proposalId) == proposal.lock){
            require(
                viewLockProposal(proposalId).signature.length >= minimalSignedRequired(),
                "MultiSigTokenAdmin : Insufficient minimum required signer"
            );
            for(uint256 a; a < viewLockProposal(proposalId).signature.length; a++){
                require(
                    isSigner(
                        ECDSA.recover(
                            ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createLockHash(
                                proposalId,
                                viewLockProposal(proposalId).userParams,
                                viewLockProposal(proposalId).deadlineLockParam
                            )),
                            viewLockProposal(proposalId).signature[a]
                        )
                    ),
                    "MultiSigTokenAdmin : Some address is not signer member anymore, this proposal is invalid"
                );
            }

            if(viewLockProposal(proposalId).deadlineLockParam > 0){
                IRestrictable(managedToken).lockUser(
                    viewLockProposal(proposalId).userParams,
                    viewLockProposal(proposalId).deadlineLockParam
                );
            }else{
                IRestrictable(managedToken).unlockUser(
                    viewLockProposal(proposalId).userParams
                );
            }
        }else if(viewProposalType(proposalId) == proposal.restrict){
            require(
                viewRestrictProposal(proposalId).signature.length >= minimalSignedRequired(),
                "MultiSigTokenAdmin : Insufficient minimum required signer"
            );
            for(uint256 a; a < viewRestrictProposal(proposalId).signature.length; a++){
                require(
                    isSigner(
                        ECDSA.recover(
                            ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createRestrictHash(
                                proposalId,
                                viewRestrictProposal(proposalId).userParams,
                                viewRestrictProposal(proposalId).whitelistParams
                            )),
                            viewRestrictProposal(proposalId).signature[a]
                        )
                    ),
                    "MultiSigTokenAdmin : Some address is not signer member anymore, this proposal is invalid"
                );
            }

            if(viewRestrictProposal(proposalId).whitelistParams.length > 0){
                IRestrictable(managedToken).restrictUser(
                    viewRestrictProposal(proposalId).userParams,
                    viewRestrictProposal(proposalId).whitelistParams
                );
            }else{
                IRestrictable(managedToken).unrestrictUser(
                    viewRestrictProposal(proposalId).userParams
                );
            }
        }else if(viewProposalType(proposalId) == proposal.limit){
            require(
                viewLimitProposal(proposalId).signature.length >= minimalSignedRequired(),
                "MultiSigTokenAdmin : Insufficient minimum required signer"
            );
            for(uint256 a; a < viewLimitProposal(proposalId).signature.length; a++){
                require(
                    isSigner(
                        ECDSA.recover(
                            ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createLimitHash(
                                proposalId,
                                viewLimitProposal(proposalId).amountLimitParam,
                                viewLimitProposal(proposalId).longTimeDelayParam
                            )),
                            viewLimitProposal(proposalId).signature[a]
                        )
                    ),
                    "MultiSigTokenAdmin : Some address is not signer member anymore, this proposal is invalid"
                );
            }

            if(
                viewLimitProposal(proposalId).amountLimitParam > 0 &&
                viewLimitProposal(proposalId).longTimeDelayParam > 0
            ){
                IRestrictable(managedToken).setLimit(
                    viewLimitProposal(proposalId).amountLimitParam,
                    viewLimitProposal(proposalId).longTimeDelayParam 
                );
            }else{
                IRestrictable(managedToken).unsetLimit();
            }
        }else if(viewProposalType(proposalId) == proposal.pause){
            require(
                viewPauseProposal(proposalId).signature.length >= minimalSignedRequired(),
                "MultiSigTokenAdmin : Insufficient minimum required signer"
            );
            for(uint256 a; a < viewPauseProposal(proposalId).signature.length; a++){
                require(
                    isSigner(
                        ECDSA.recover(
                            ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createPauseHash(
                                proposalId,
                                viewPauseProposal(proposalId).statusParam
                            )),
                            viewPauseProposal(proposalId).signature[a]
                        )
                    ),
                    "MultiSigTokenAdmin : Some address is not signer member anymore, this proposal is invalid"
                );
            }

            if(viewPauseProposal(proposalId).statusParam){
                IRestrictable(managedToken).pause();
            }else{
                IRestrictable(managedToken).unpause();
            }
        }else if(viewProposalType(proposalId) == proposal.burn){
            require(
                viewBurnProposal(proposalId).signature.length >= minimalSignedRequired(),
                "MultiSigTokenAdmin : Insufficient minimum required signer"
            );
            for(uint256 a; a < viewBurnProposal(proposalId).signature.length; a++){
                require(
                    isSigner(
                        ECDSA.recover(
                            ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createBurnHash(
                                proposalId,
                                viewBurnProposal(proposalId).amountParam
                            )),
                            viewBurnProposal(proposalId).signature[a]
                        ) 
                    ),
                    "MultiSigTokenAdmin : Some address is not signer member anymore, this proposal is invalid"
                );
            }

            IBEP20Burn(managedToken).burn(
                viewBurnProposal(proposalId).amountParam
            );
        }else if(viewProposalType(proposalId) == proposal.signer){
            require(
                viewSignerProposal(proposalId).signature.length >= minimalSignedRequired(),
                "MultiSigTokenAdmin : Insufficient minimum required signer"
            );
            for(uint256 a; a < viewSignerProposal(proposalId).signature.length; a++){
                require(
                    isSigner(
                        ECDSA.recover(
                            ECDSA.toEthSignedMessageHash(MultiSigHashCreator.createSignerHash(
                                proposalId,
                                viewSignerProposal(proposalId).signerParam,
                                viewSignerProposal(proposalId).statusParam
                            )),
                            viewSignerProposal(proposalId).signature[a]
                        ) 
                    ),
                    "MultiSigTokenAdmin : Some address is not signer member anymore, this proposal is invalid"
                );
            }

            if(viewSignerProposal(proposalId).statusParam == false){
                signerMember[viewSignerProposal(proposalId).signerParam] = false;
                totalSigner -= 1;
            }else{
                signerMember[viewSignerProposal(proposalId).signerParam] = true;
                totalSigner += 1;
            }
        }else{
            revert(
                "MultiSigTokenAdmin : This proposal is undefined or not proposed before"
            );
        }

        viewProposalCondition(proposalId).executed = true;

        emit executeProposal(
            proposalId,
            viewProposalType(proposalId),
            block.timestamp
        );
    }

    function minimalSignedRequired() public isGranted view returns(uint){
        unchecked{
            if(totalSigner > 3){
                return (totalSigner / 2) + 1;
            }else{
                return 2;
            }
        }
    }

    function isSigner(address user) public isGranted view returns(bool){
        unchecked{
            return signerMember[user];
        }
    }

    function viewProposalType(uint256 proposalId) public isGranted view returns(proposal){
        unchecked{
            return proposalType[proposalId];
        }
    }
    function viewProposalCondition(uint256 proposalId) public isGranted view returns(proposalCondition memory){
        unchecked{
            require(
                viewProposalType(proposalId) != proposal.undefined,
                "MultiSigTokenAdmin : This proposal is not proposed before"
            );
            return proposalStatus[proposalId];
        }
    }
    function viewBannedProposal(uint256 proposalId) public isGranted view returns(bannedProposal memory){
        unchecked{
            require(
                viewProposalType(proposalId) == proposal.banned,
                "MultiSigTokenAdmin : This proposal is not banned type"
            );
            return bannedProposalData[proposalId];
        }
    }
    function viewLockProposal(uint256 proposalId) public isGranted view returns(lockProposal memory){
        unchecked{
            require(
                viewProposalType(proposalId) == proposal.lock,
                "MultiSigTokenAdmin : This proposal is not lock type"
            );
            return lockProposalData[proposalId];
        }
    }
    function viewRestrictProposal(uint256 proposalId) public isGranted view returns(restrictProposal memory){
        unchecked{
            require(
                viewProposalType(proposalId) == proposal.restrict,
                "MultiSigTokenAdmin : This proposal is not restrict type"
            );
            return restrictProposalData[proposalId];
        }
    }
    function viewLimitProposal(uint256 proposalId) public isGranted view returns(limitProposal memory){
        unchecked{
            require(
                viewProposalType(proposalId) == proposal.limit,
                "MultiSigTokenAdmin : This proposal is not limit type"
            );
            return limitProposalData[proposalId];
        }
    }
    function viewPauseProposal(uint256 proposalId) public isGranted view returns(pauseProposal memory){
        unchecked{
            require(
                viewProposalType(proposalId) == proposal.pause,
                "MultiSigTokenAdmin : This proposal is not pause type"
            );
            return pauseProposalData[proposalId];
        }
    }
    function viewBurnProposal(uint256 proposalId) public isGranted view returns(burnProposal memory){
        unchecked{
            require(
                viewProposalType(proposalId) == proposal.burn,
                "MultiSigTokenAdmin : This proposal is not burn type"
            );
            return burnProposalData[proposalId];
        }
    }
    function viewSignerProposal(uint256 proposalId) public isGranted view returns(signerProposal memory){
        unchecked{
            require(
                viewProposalType(proposalId) == proposal.signer,
                "MultiSigTokenAdmin : This proposal is not transfer type"
            );
            return signerProposalData[proposalId];
        }
    }
    function isAlreadySigned(
        uint256 proposalId,
        bytes memory upvoteSignature
    ) private view returns(bool){
        unchecked{
            if(viewProposalType(proposalId) == proposal.banned){
                for(uint256 a; a < viewBannedProposal(proposalId).signature.length; a++){
                    if(
                        keccak256(upvoteSignature) == keccak256(
                            viewBannedProposal(proposalId).signature[a]
                        )
                    ){
                        return true;
                    }
                }
            }else if(viewProposalType(proposalId) == proposal.lock){
                for(uint256 a; a < viewLockProposal(proposalId).signature.length; a++){
                    if(
                        keccak256(upvoteSignature) == keccak256(
                            viewLockProposal(proposalId).signature[a]
                        )
                    ){
                        return true;
                    }
                }
            }else if(viewProposalType(proposalId) == proposal.restrict){
                for(uint256 a; a < viewRestrictProposal(proposalId).signature.length; a++){
                    if(
                        keccak256(upvoteSignature) == keccak256(
                            viewRestrictProposal(proposalId).signature[a]
                        )
                    ){
                        return true;
                    }
                }
            }else if(viewProposalType(proposalId) == proposal.limit){
                for(uint256 a; a < viewLimitProposal(proposalId).signature.length; a++){
                    if(
                        keccak256(upvoteSignature) == keccak256(
                            viewLimitProposal(proposalId).signature[a]
                        )
                    ){
                        return true;
                    }
                }
            }else if(viewProposalType(proposalId) == proposal.pause){
                for(uint256 a; a < viewPauseProposal(proposalId).signature.length; a++){
                    if(
                        keccak256(upvoteSignature) == keccak256(
                            viewPauseProposal(proposalId).signature[a]
                        )
                    ){
                        return true;
                    }
                }
            }else if(viewProposalType(proposalId) == proposal.burn){
                for(uint256 a; a < viewBurnProposal(proposalId).signature.length; a++){
                    if(
                        keccak256(upvoteSignature) == keccak256(
                            viewBurnProposal(proposalId).signature[a]
                        )
                    ){
                        return true;
                    }
                }
            }else if(viewProposalType(proposalId) == proposal.signer){
                for(uint256 a; a < viewSignerProposal(proposalId).signature.length; a++){
                    if(
                        keccak256(upvoteSignature) == keccak256(
                            viewSignerProposal(proposalId).signature[a]
                        )
                    ){
                        return true;
                    }
                }
            }

            return false;
        }
    }

    modifier isNextExecuteElapsed{
        require(
            block.timestamp > nextExecute,
            "MultiSigTokenAdmin : Please wait until next execute period"
        );
        _;
        nextExecute = block.timestamp + nextExecuteInterval;
    }

    modifier isGranted{
        require(
            IRestrictable(managedToken).isAdministrator(address(this)),
            "MultiSigTokenAdmin : This smartcontract not granted as admin"
        );
        _;
    }
}