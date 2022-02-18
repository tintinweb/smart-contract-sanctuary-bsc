pragma solidity 0.6.4;

import "./lib/Memory.sol";
import "./lib/BytesToTypes.sol";
import "./interface/ILightClient.sol";
import "./interface/ISystemReward.sol";
import "./interface/IParamSubscriber.sol";
import "./System.sol";

contract TendermintLightClient is ILightClient, System, IParamSubscriber {
    struct ConsensusState {
        uint64 preValidatorSetChangeHeight;
        bytes32 appHash;
        bytes32 curValidatorSetHash;
        bytes nextValidatorSet;
    }

    mapping(uint64 => ConsensusState) public lightClientConsensusStates;
    mapping(uint64 => address payable) public submitters;
    uint64 public initialHeight;
    uint64 public latestHeight;
    bytes32 public chainID;

    bytes public constant INIT_CONSENSUS_STATE_BYTES =
        "0xb6220ae5130a83030a02080a121442696e616e63652d436861696e2d54696772697318c8a8af6a220b08ba95bc900610a9dcae6528033087b0c2ab023a480a20178368fa0a54781e42d81f51cb56deb4ebd7dea841cfe734ce6d1b023c7f0a0912240801122091853813e7688557204c0dce87674ecd6ce120d913c360c6a14f66a582a574f64220d670283b9158b456664bdfb68cdddd979952e0d1708931c95ed3372878728ee04a20168d5c1c83339e717cf8b51773a8e887edcaef622895949712f14ab1a1609f63522043c53a50d8653ef8cf1e5716da68120fb51b636dc6d111ec3277b098ecd42d495a2043c53a50d8653ef8cf1e5716da68120fb51b636dc6d111ec3277b098ecd42d496220294d8fbd0b94b767a7eba9840f299a3586da7fe6b5dead3b7eecba193c400f936a2052558241bbbbbf0238251c56b04ef0423449fa26a99ceafa080ebbb3d027e2277220873050eee7771493df7da5eafa8ff7a4528fab03193a4401d455560cbc4e389682011471f253e6fea9edd4b4753f5483549fe4f0f3a21c12dc100a480a20fbb657d0ee9c49355d689775ffc51568f71a5db419f064a60a510fe3ca39cce11224080112204d22ae79436c764facd762efbc2a78ac133e09168ea9540894c3b8f97381493e12b701080210c8a8af6a22480a20fbb657d0ee9c49355d689775ffc51568f71a5db419f064a60a510fe3ca39cce11224080112204d22ae79436c764facd762efbc2a78ac133e09168ea9540894c3b8f97381493e2a0c08ba95bc900610d9e1deb50232141175946a48eaa473868a0a6f52e6c66ccaf472ea4240bfc205bf2dc461f934133fafa799d036f2f45b8dbdf4818428fc41018508a56d9c79d71da24a30bf79092922cd665c4f2dcddcb4600e331dcb009cafb2712b0512b901080210c8a8af6a22480a20fbb657d0ee9c49355d689775ffc51568f71a5db419f064a60a510fe3ca39cce11224080112204d22ae79436c764facd762efbc2a78ac133e09168ea9540894c3b8f97381493e2a0c08ba95bc900610d4e0f9a202321414cfce69b645f3f88baf08ea5b77fa521e4480f938014240b0cfaa442a82c842082a317e60f2efb9dd194245f729534ccd5f905128bb019c4b0413a644e70d87335fceb38cbde88c3c2ce6c8076cc2b713ab8163d4acf30412b901080210c8a8af6a22480a20fbb657d0ee9c49355d689775ffc51568f71a5db419f064a60a510fe3ca39cce11224080112204d22ae79436c764facd762efbc2a78ac133e09168ea9540894c3b8f97381493e2a0c08ba95bc900610e690868702321417b42e8f284d3ca0e420262f89cd76c749bb12c938024240c701fe78a57c19dc7427ab7c6455224a907618cc524d46e17cf1488f9f49fc6cfdead2ca5a81fd20e3c16a0b860c0bc38a58ffb18467c60912aa6ac45b44660b12b901080210c8a8af6a22480a20fbb657d0ee9c49355d689775ffc51568f71a5db419f064a60a510fe3ca39cce11224080112204d22ae79436c764facd762efbc2a78ac133e09168ea9540894c3b8f97381493e2a0c08ba95bc900610e8d1a5a30232143cd4aababddeb7abfea9618732e331077a861d2b380342405fe27516c964662fb04de7d2348ff201ae47b462521b5e9c2f66cc2c458ef814209bb0b473446ace74e57b1e62d7565d4f61169c4dbb6bb635a31ad2f47ba10112b901080210c8a8af6a22480a20fbb657d0ee9c49355d689775ffc51568f71a5db419f064a60a510fe3ca39cce11224080112204d22ae79436c764facd762efbc2a78ac133e09168ea9540894c3b8f97381493e2a0c08ba95bc900610cccacc86023214414fb3bba216af84c47e07d6ebaa2dcfc3563a2f380442402ab71d5782d836326a42e0dae58a721fd885aecc9a8c5b3ccf590ebc40e7daf5ff367dac1457aa1ee1d2de7ed3f4573c03cab6476eb78d65618c75ce6c57910212b901080210c8a8af6a22480a20fbb657d0ee9c49355d689775ffc51568f71a5db419f064a60a510fe3ca39cce11224080112204d22ae79436c764facd762efbc2a78ac133e09168ea9540894c3b8f97381493e2a0c08ba95bc900610bcd0a0a202321471f253e6fea9edd4b4753f5483549fe4f0f3a21c380542407acee3fc2c229124f0738807de2601b2ff9fff036baad7d4c9409c1f1beecf0515425a8da8f506b65477abd2363fccd884a5ad93545122d06b0e89251e12100412b901080210c8a8af6a22480a20fbb657d0ee9c49355d689775ffc51568f71a5db419f064a60a510fe3ca39cce11224080112204d22ae79436c764facd762efbc2a78ac133e09168ea9540894c3b8f97381493e2a0c08ba95bc90061099efa6b30232147235ef143d20fc0abc427615d83014bb02d7c06c38064240f87315cd6b21696dec39cdd30a6ab641c3094b3e4d25ebf6a247fdee523de0429063acfc811ef73dfca65eee8f8abfbb83636564b7889daf1aff71905043e50412b901080210c8a8af6a22480a20fbb657d0ee9c49355d689775ffc51568f71a5db419f064a60a510fe3ca39cce11224080112204d22ae79436c764facd762efbc2a78ac133e09168ea9540894c3b8f97381493e2a0c08ba95bc900610acbabda3023214a71e5cd078b8c5c7b1af88bce84dd70b0557d93e3807424002c7301ea0310aa4ba8edb3c10e274c9a6a0ea108aa41f696994a6ab2a7b9d152e08be8e769ffad0600bb30fe6e8349e133a703d7b5fd1f7bcd3167a3f696f0d12b901080210c8a8af6a22480a20fbb657d0ee9c49355d689775ffc51568f71a5db419f064a60a510fe3ca39cce11224080112204d22ae79436c764facd762efbc2a78ac133e09168ea9540894c3b8f97381493e2a0c08ba95bc900610d4ffe184023214a9157b3fa6eb4c1e396b9b746e95327a07dc42e5380842404c00745cf5a41fa3c6c0c46371a8a142cf62921b8ace7aecad79660322bb97cb216d4d1a0da9dbfc0bf86a83f23598f16144ff9019ccbaacd3d1bfb5df59f70112b901080210c8a8af6a22480a20fbb657d0ee9c49355d689775ffc51568f71a5db419f064a60a510fe3ca39cce11224080112204d22ae79436c764facd762efbc2a78ac133e09168ea9540894c3b8f97381493e2a0c08ba95bc900610eebcd786023214b0fbb52ff7ee93cc476dfe6b74fa1fc88584f30d380942407956cc897367bf0ab82d87400859d279107692e3b4388c23f4e70ada2bab48825fd38f502fcd33927b577741cfb6472a766be4b2855ae880358e6d0dec43b00712b901080210c8a8af6a22480a20fbb657d0ee9c49355d689775ffc51568f71a5db419f064a60a510fe3ca39cce11224080112204d22ae79436c764facd762efbc2a78ac133e09168ea9540894c3b8f97381493e2a0c08ba95bc900610e2fbb4b8023214b7707d9f593c62e85bb9e1a2366d12a97cd5dff2380a4240a5da5e3778b10467405f0df490c12b0f3441e056a04cf2173c3cf29d28ec8b8cf9d83067528cf8f80a2e1ac992b2286849af354671b5fd06517069fe2725ab0d12a4070a4f0a141175946a48eaa473868a0a6f52e6c66ccaf472ea12251624de6420d3769d8a1f78b4c17a965f7a30d4181fabbd1f969f46d3c8e83b5ad4845421d81880a094a58d1d2080c0b58cfbdcfdffff010a4b0a1414cfce69b645f3f88baf08ea5b77fa521e4480f912251624de64202ba4e81542f437b7ae1f8a35ddb233c789a8dc22734377d9b6d63af1ca403b611880a094a58d1d2080a094a58d1d0a4b0a1417b42e8f284d3ca0e420262f89cd76c749bb12c912251624de6420df8da8c5abfdb38595391308bb71e5a1e0aabdc1d0cf38315d50d6be939b26061880a094a58d1d2080a094a58d1d0a4b0a143cd4aababddeb7abfea9618732e331077a861d2b12251624de6420b6619edca4143484800281d698b70c935e9152ad57b31d85c05f2f79f64b39f31880a094a58d1d2080a094a58d1d0a4b0a14414fb3bba216af84c47e07d6ebaa2dcfc3563a2f12251624de64209446d14ad86c8d2d74780b0847110001a1c2e252eedfea4753ebbbfce3a22f521880a094a58d1d2080a094a58d1d0a4b0a1471f253e6fea9edd4b4753f5483549fe4f0f3a21c12251624de64200353c639f80cc8015944436dab1032245d44f912edc31ef668ff9f4a45cd05991880a094a58d1d2080a094a58d1d0a4b0a147235ef143d20fc0abc427615d83014bb02d7c06c12251624de6420e81d3797e0544c3a718e1f05f0fb782212e248e784c1a851be87e77ae0db230e1880a094a58d1d2080a094a58d1d0a4b0a14a71e5cd078b8c5c7b1af88bce84dd70b0557d93e12251624de64205e3fcda30bd19d45c4b73688da35e7da1fce7c6859b2c1f20ed5202d24144e3e1880a094a58d1d2080a094a58d1d0a4b0a14a9157b3fa6eb4c1e396b9b746e95327a07dc42e512251624de6420b06a59a2d75bf5d014fce7c999b5e71e7a960870f725847d4ba3235baeaa08ef1880a094a58d1d2080a094a58d1d0a4b0a14b0fbb52ff7ee93cc476dfe6b74fa1fc88584f30d12251624de64200c910e2fe650e4e01406b3310b489fb60a84bc3ff5c5bee3a56d5898b6a8af321880a094a58d1d2080a094a58d1d0a4b0a14b7707d9f593c62e85bb9e1a2366d12a97cd5dff212251624de642071f2d7b8ec1c8b99a653429b0118cd201f794f409d0fea4d65b1b662f2b000631880a094a58d1d2080a094a58d1d124f0a141175946a48eaa473868a0a6f52e6c66ccaf472ea12251624de6420d3769d8a1f78b4c17a965f7a30d4181fabbd1f969f46d3c8e83b5ad4845421d81880a094a58d1d2080c0b58cfbdcfdffff011aa4070a4f0a141175946a48eaa473868a0a6f52e6c66ccaf472ea12251624de6420d3769d8a1f78b4c17a965f7a30d4181fabbd1f969f46d3c8e83b5ad4845421d81880a094a58d1d2080c0b58cfbdcfdffff010a4b0a1414cfce69b645f3f88baf08ea5b77fa521e4480f912251624de64202ba4e81542f437b7ae1f8a35ddb233c789a8dc22734377d9b6d63af1ca403b611880a094a58d1d2080a094a58d1d0a4b0a1417b42e8f284d3ca0e420262f89cd76c749bb12c912251624de6420df8da8c5abfdb38595391308bb71e5a1e0aabdc1d0cf38315d50d6be939b26061880a094a58d1d2080a094a58d1d0a4b0a143cd4aababddeb7abfea9618732e331077a861d2b12251624de6420b6619edca4143484800281d698b70c935e9152ad57b31d85c05f2f79f64b39f31880a094a58d1d2080a094a58d1d0a4b0a14414fb3bba216af84c47e07d6ebaa2dcfc3563a2f12251624de64209446d14ad86c8d2d74780b0847110001a1c2e252eedfea4753ebbbfce3a22f521880a094a58d1d2080a094a58d1d0a4b0a1471f253e6fea9edd4b4753f5483549fe4f0f3a21c12251624de64200353c639f80cc8015944436dab1032245d44f912edc31ef668ff9f4a45cd05991880a094a58d1d2080a094a58d1d0a4b0a147235ef143d20fc0abc427615d83014bb02d7c06c12251624de6420e81d3797e0544c3a718e1f05f0fb782212e248e784c1a851be87e77ae0db230e1880a094a58d1d2080a094a58d1d0a4b0a14a71e5cd078b8c5c7b1af88bce84dd70b0557d93e12251624de64205e3fcda30bd19d45c4b73688da35e7da1fce7c6859b2c1f20ed5202d24144e3e1880a094a58d1d2080a094a58d1d0a4b0a14a9157b3fa6eb4c1e396b9b746e95327a07dc42e512251624de6420b06a59a2d75bf5d014fce7c999b5e71e7a960870f725847d4ba3235baeaa08ef1880a094a58d1d2080a094a58d1d0a4b0a14b0fbb52ff7ee93cc476dfe6b74fa1fc88584f30d12251624de64200c910e2fe650e4e01406b3310b489fb60a84bc3ff5c5bee3a56d5898b6a8af321880a094a58d1d2080a094a58d1d0a4b0a14b7707d9f593c62e85bb9e1a2366d12a97cd5dff212251624de642071f2d7b8ec1c8b99a653429b0118cd201f794f409d0fea4d65b1b662f2b000631880a094a58d1d2080a094a58d1d124f0a141175946a48eaa473868a0a6f52e6c66ccaf472ea12251624de6420d3769d8a1f78b4c17a965f7a30d4181fabbd1f969f46d3c8e83b5ad4845421d81880a094a58d1d2080c0b58cfbdcfdffff01";
    uint256 public constant INIT_REWARD_FOR_VALIDATOR_SER_CHANGE = 1e16;
    uint256 public rewardForValidatorSetChange;

    event initConsensusState(uint64 initHeight, bytes32 appHash);
    event syncConsensusState(
        uint64 height,
        uint64 preValidatorSetChangeHeight,
        bytes32 appHash,
        bool validatorChanged
    );
    event paramChange(string key, bytes value);

    /* solium-disable-next-line */
    constructor() public {}

    function init() external onlyNotInit {
        uint256 pointer;
        uint256 length;

        // pointer ชี้ไปที่ header
        // length คือ ขนาดของ
        (pointer, length) = Memory.fromBytes(INIT_CONSENSUS_STATE_BYTES);

        /* solium-disable-next-line */
        assembly {
            sstore(chainID_slot, mload(pointer))
        }

        ConsensusState memory cs;
        uint64 height;
        (cs, height) = decodeConsensusState(pointer, length, false);
        cs.preValidatorSetChangeHeight = 0;
        lightClientConsensusStates[height] = cs;

        initialHeight = height;
        latestHeight = height;
        alreadyInit = true;
        rewardForValidatorSetChange = INIT_REWARD_FOR_VALIDATOR_SER_CHANGE;

        emit initConsensusState(initialHeight, cs.appHash);
    }

    // header := &common.Header{
    // SignedHeader: commit.SignedHeader,
    // ValidatorSet: tmtypes.NewValidatorSet(validators.Validators),
    // NextValidatorSet: tmtypes.NewValidatorSet(nextvalidators.Validators),
    // }
    // header โดน encode ด้วย MarshalBinaryLengthPrefixed
    function syncTendermintHeader(bytes calldata header, uint64 height)
        external
        onlyRelayer
        returns (bool)
    {
        // เช็คว่า hight นี้จะต้องไม่เคยโดน submit
        require(
            submitters[height] == address(0x0),
            "can't sync duplicated header"
        );
        // เช็คว่า init config block ต้องไม่วิ่งย้อนหลัง
        require(
            height > initialHeight,
            "can't sync header before initialHeight"
        );

        // update block
        uint64 preValidatorSetChangeHeight = latestHeight;

        // มี app hash
        // pre validator
        // next validator
        ConsensusState memory cs = lightClientConsensusStates[
            preValidatorSetChangeHeight
        ];
        // ทำไมไม่ใช้ if วะ
        for (
            ;
            preValidatorSetChangeHeight >= height &&
                preValidatorSetChangeHeight >= initialHeight;

        ) {
            preValidatorSetChangeHeight = cs.preValidatorSetChangeHeight;
            cs = lightClientConsensusStates[preValidatorSetChangeHeight];
        }
        // ถ้่ามันยังไม่มี next
        if (cs.nextValidatorSet.length == 0) {
            // ถ้า bytes ยังไม่มีการกำหนด length
            preValidatorSetChangeHeight = cs.preValidatorSetChangeHeight;
            cs.nextValidatorSet = lightClientConsensusStates[
                preValidatorSetChangeHeight
            ].nextValidatorSet;
            require(
                cs.nextValidatorSet.length != 0,
                "failed to load validator set data"
            );
        }

        
        // | chainID  | height   | appHash  | curValidatorSetHash | [{validator pubkey, voting power}] |
        // | 32 bytes | 8 bytes  | 32 bytes | 32 bytes            | [{32 bytes, 8 bytes}]              |
        // 32 + 8 + 32 + 32 + 32 + cs.nextValidatorSet.length;
        uint256 length = 136 + cs.nextValidatorSet.length;
        bytes memory input = new bytes(length + header.length);
        // + 32 input
        uint256 ptr = Memory.dataPtr(input);
        // check format cs
        require(

          // length = 136 + cs.nextValidatorSet.length
          // ptr = length + header.length + 32
            encodeConsensusState(cs, preValidatorSetChangeHeight, ptr, length),
            "failed to serialize consensus state"
        );

        // write header to input
        uint256 src;
        ptr = ptr + length;
        (src, length) = Memory.fromBytes(header);
        Memory.copy(src, ptr, length);

        length = input.length + 32;
        // Maximum validator quantity is 99
        bytes32[128] memory result;
        /* solium-disable-next-line */
        assembly {
            // call validateTendermintHeader precompile contract
            // Contract address: 0x64

            if iszero(staticcall(not(0), 0x64, input, length, result, 4096)) {
                revert(0, 0)
            }
        }

        //Judge if the validator set is changed
        /* solium-disable-next-line */
        assembly {
            length := mload(add(result, 0))
        }
        bool validatorChanged = false;
        if ((length & (0x01 << 248)) != 0x00) {
            validatorChanged = true;
            ISystemReward(SYSTEM_REWARD_ADDR).claimRewards(
                msg.sender,
                rewardForValidatorSetChange
            );
        }
        length = length & 0xffffffffffffffff;

        /* solium-disable-next-line */
        assembly {
            ptr := add(result, 32)
        }

        uint64 actualHeaderHeight;
        (cs, actualHeaderHeight) = decodeConsensusState(
            ptr,
            length,
            !validatorChanged
        );
        require(
            actualHeaderHeight == height,
            "header height doesn't equal to the specified height"
        );

        submitters[height] = msg.sender;
        cs.preValidatorSetChangeHeight = preValidatorSetChangeHeight;
        lightClientConsensusStates[height] = cs;
        if (height > latestHeight) {
            latestHeight = height;
        }

        emit syncConsensusState(
            height,
            preValidatorSetChangeHeight,
            cs.appHash,
            validatorChanged
        );

        return true;
    }

    function isHeaderSynced(uint64 height)
        external
        view
        override
        returns (bool)
    {
        return submitters[height] != address(0x0) || height == initialHeight;
    }

    function getAppHash(uint64 height)
        external
        view
        override
        returns (bytes32)
    {
        return lightClientConsensusStates[height].appHash;
    }

    function getSubmitter(uint64 height)
        external
        view
        override
        returns (address payable)
    {
        return submitters[height];
    }

    function getChainID() external view returns (string memory) {
        bytes memory chainIDBytes = new bytes(32);
        assembly {
            mstore(add(chainIDBytes, 32), sload(chainID_slot))
        }

        uint8 chainIDLength = 0;
        for (uint8 j = 0; j < 32; j++) {
            if (chainIDBytes[j] != 0) {
                chainIDLength++;
            } else {
                break;
            }
        }

        bytes memory chainIDStr = new bytes(chainIDLength);
        for (uint8 j = 0; j < chainIDLength; j++) {
            chainIDStr[j] = chainIDBytes[j];
        }

        return string(chainIDStr);
    }

    // | length   | chainID   | height   | appHash  | curValidatorSetHash | [{validator pubkey, voting power}] |
    // | 32 bytes | 32 bytes   | 8 bytes  | 32 bytes | 32 bytes            | [{32 bytes, 8 bytes}]              |
    /* solium-disable-next-line */
    function encodeConsensusState(
        ConsensusState memory cs,
        uint64 height,
        uint256 outputPtr,
        uint256 size
    ) internal view returns (bool) {
        outputPtr = outputPtr + size - cs.nextValidatorSet.length;

        uint256 src;
        uint256 length;
        (src, length) = Memory.fromBytes(cs.nextValidatorSet);
        Memory.copy(src, outputPtr, length);
        outputPtr = outputPtr - 32;

        bytes32 hash = cs.curValidatorSetHash;
        /* solium-disable-next-line */
        assembly {
            mstore(outputPtr, hash)
        }
        outputPtr = outputPtr - 32;

        hash = cs.appHash;
        /* solium-disable-next-line */
        assembly {
            mstore(outputPtr, hash)
        }
        outputPtr = outputPtr - 32;

        /* solium-disable-next-line */
        assembly {
            mstore(outputPtr, height)
        }
        outputPtr = outputPtr - 8;

        /* solium-disable-next-line */
        assembly {
            mstore(outputPtr, sload(chainID_slot))
        }
        outputPtr = outputPtr - 32;

        // size doesn't contain length
        size = size - 32;
        /* solium-disable-next-line */
        assembly {
            mstore(outputPtr, size)
        }

        return true;
    }

    // | chainID  | height   | appHash  | curValidatorSetHash | [{validator pubkey, voting power}] |
    // | 32 bytes  | 8 bytes  | 32 bytes | 32 bytes            | [{32 bytes, 8 bytes}]              |
    /* solium-disable-next-line */
    function decodeConsensusState(
        uint256 ptr,
        uint256 size,
        bool leaveOutValidatorSet
    ) internal pure returns (ConsensusState memory, uint64) {
        ptr = ptr + 8;
        uint64 height;
        /* solium-disable-next-line */
        assembly {
            height := mload(ptr)
        }

        ptr = ptr + 32;
        bytes32 appHash;
        /* solium-disable-next-line */
        assembly {
            appHash := mload(ptr)
        }

        ptr = ptr + 32;
        bytes32 curValidatorSetHash;
        /* solium-disable-next-line */
        assembly {
            curValidatorSetHash := mload(ptr)
        }

        ConsensusState memory cs;
        cs.appHash = appHash;
        cs.curValidatorSetHash = curValidatorSetHash;

        if (!leaveOutValidatorSet) {
            uint256 dest;
            uint256 length;
            cs.nextValidatorSet = new bytes(size - 104);
            (dest, length) = Memory.fromBytes(cs.nextValidatorSet);

            Memory.copy(ptr + 32, dest, length);
        }

        return (cs, height);
    }

    function updateParam(string calldata key, bytes calldata value)
        external
        override
        onlyInit
        onlyGov
    {
        if (Memory.compareStrings(key, "rewardForValidatorSetChange")) {
            require(
                value.length == 32,
                "length of rewardForValidatorSetChange mismatch"
            );
            uint256 newRewardForValidatorSetChange = BytesToTypes
                .bytesToUint256(32, value);
            require(
                newRewardForValidatorSetChange > 0 &&
                    newRewardForValidatorSetChange <= 1e18,
                "the newRewardForValidatorSetChange out of range"
            );
            rewardForValidatorSetChange = newRewardForValidatorSetChange;
        } else {
            require(false, "unknown param");
        }
        emit paramChange(key, value);
    }
}

pragma solidity 0.6.4;

library Memory {

    // Size of a word, in bytes.
    uint internal constant WORD_SIZE = 32;
    // Size of the header of a 'bytes' array.
    uint internal constant BYTES_HEADER_SIZE = 32;
    // Address of the free memory pointer.
    uint internal constant FREE_MEM_PTR = 0x40;

    // Compares the 'len' bytes starting at address 'addr' in memory with the 'len'
    // bytes starting at 'addr2'.
    // Returns 'true' if the bytes are the same, otherwise 'false'.
    function equals(uint addr, uint addr2, uint len) internal pure returns (bool equal) {
        assembly {
            equal := eq(keccak256(addr, len), keccak256(addr2, len))
        }
    }

    // Compares the 'len' bytes starting at address 'addr' in memory with the bytes stored in
    // 'bts'. It is allowed to set 'len' to a lower value then 'bts.length', in which case only
    // the first 'len' bytes will be compared.
    // Requires that 'bts.length >= len'
    function equals(uint addr, uint len, bytes memory bts) internal pure returns (bool equal) {
        require(bts.length >= len);
        uint addr2;
        assembly {
            addr2 := add(bts, /*BYTES_HEADER_SIZE*/32)
        }
        return equals(addr, addr2, len);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    // Copy 'len' bytes from memory address 'src', to address 'dest'.
    // This function does not check the or destination, it only copies
    // the bytes.
    function copy(uint src, uint dest, uint len) internal pure {
        // Copy word-length chunks while possible
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += WORD_SIZE;
            src += WORD_SIZE;
        }

        // Copy remaining bytes
        uint mask = 256 ** (WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    // Returns a memory pointer to the provided bytes array.
    function ptr(bytes memory bts) internal pure returns (uint addr) {
        assembly {
            addr := bts
        }
    }

    // Returns a memory pointer to the data portion of the provided bytes array.
    function dataPtr(bytes memory bts) internal pure returns (uint addr) {
        assembly {
            addr := add(bts, /*BYTES_HEADER_SIZE*/32)
        }
    }

    // This function does the same as 'dataPtr(bytes memory)', but will also return the
    // length of the providd bytes array.
    function fromBytes(bytes memory bts) internal pure returns (uint addr, uint len) {
        len = bts.length;
        assembly {
            addr := add(bts, /*BYTES_HEADER_SIZE*/32)
        }
    }

    // Creates a 'bytes memory' variable from the memory address 'addr', with the
    // length 'len'. The function will allocate new memory for the bytes array, and
    // the 'len bytes starting at 'addr' will be copied into that new memory.
    function toBytes(uint addr, uint len) internal pure returns (bytes memory bts) {
        bts = new bytes(len);
        uint btsptr;
        assembly {
            btsptr := add(bts, /*BYTES_HEADER_SIZE*/32)
        }
        copy(addr, btsptr, len);
    }

    // Get the word stored at memory address 'addr' as a 'uint'.
    function toUint(uint addr) internal pure returns (uint n) {
        assembly {
            n := mload(addr)
        }
    }

    // Get the word stored at memory address 'addr' as a 'bytes32'.
    function toBytes32(uint addr) internal pure returns (bytes32 bts) {
        assembly {
            bts := mload(addr)
        }
    }
}

pragma solidity 0.6.4;

/**
 * @title BytesToTypes
 * Copyright (c) 2016-2020 zpouladzade/Seriality
 * @dev The BytesToTypes contract converts the memory byte arrays to the standard solidity types
 * @author [email protected]
 */

library BytesToTypes {
    

    function bytesToAddress(uint _offst, bytes memory _input) internal pure returns (address _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 
    
    function bytesToBool(uint _offst, bytes memory _input) internal pure returns (bool _output) {
        
        uint8 x;
        assembly {
            x := mload(add(_input, _offst))
        }
        x==0 ? _output = false : _output = true;
    }   
        
    function getStringSize(uint _offst, bytes memory _input) internal pure returns(uint size) {
        
        assembly{
            
            size := mload(add(_input,_offst))
            let chunk_count := add(div(size,32),1) // chunk_count = size/32 + 1
            
            if gt(mod(size,32),0) {// if size%32 > 0
                chunk_count := add(chunk_count,1)
            } 
            
             size := mul(chunk_count,32)// first 32 bytes reseves for size in strings
        }
    }

    function bytesToString(uint _offst, bytes memory _input, bytes memory _output) internal pure {

        uint size = 32;
        assembly {
            
            let chunk_count
            
            size := mload(add(_input,_offst))
            chunk_count := add(div(size,32),1) // chunk_count = size/32 + 1
            
            if gt(mod(size,32),0) {
                chunk_count := add(chunk_count,1)  // chunk_count++
            }
               
            for { let index:= 0 }  lt(index , chunk_count) { index := add(index,1) } {
                mstore(add(_output,mul(index,32)),mload(add(_input,_offst)))
                _offst := sub(_offst,32)           // _offst -= 32
            }
        }
    }

    function bytesToBytes32(uint _offst, bytes memory  _input, bytes32 _output) internal pure {
        
        assembly {
            mstore(_output , add(_input, _offst))
            mstore(add(_output,32) , add(add(_input, _offst),32))
        }
    }
    
    function bytesToInt8(uint _offst, bytes memory  _input) internal pure returns (int8 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }
    
    function bytesToInt16(uint _offst, bytes memory _input) internal pure returns (int16 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt24(uint _offst, bytes memory _input) internal pure returns (int24 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt32(uint _offst, bytes memory _input) internal pure returns (int32 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt40(uint _offst, bytes memory _input) internal pure returns (int40 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt48(uint _offst, bytes memory _input) internal pure returns (int48 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt56(uint _offst, bytes memory _input) internal pure returns (int56 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt64(uint _offst, bytes memory _input) internal pure returns (int64 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt72(uint _offst, bytes memory _input) internal pure returns (int72 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt80(uint _offst, bytes memory _input) internal pure returns (int80 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt88(uint _offst, bytes memory _input) internal pure returns (int88 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt96(uint _offst, bytes memory _input) internal pure returns (int96 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }
	
	function bytesToInt104(uint _offst, bytes memory _input) internal pure returns (int104 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }
    
    function bytesToInt112(uint _offst, bytes memory _input) internal pure returns (int112 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt120(uint _offst, bytes memory _input) internal pure returns (int120 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt128(uint _offst, bytes memory _input) internal pure returns (int128 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt136(uint _offst, bytes memory _input) internal pure returns (int136 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt144(uint _offst, bytes memory _input) internal pure returns (int144 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt152(uint _offst, bytes memory _input) internal pure returns (int152 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt160(uint _offst, bytes memory _input) internal pure returns (int160 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt168(uint _offst, bytes memory _input) internal pure returns (int168 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt176(uint _offst, bytes memory _input) internal pure returns (int176 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt184(uint _offst, bytes memory _input) internal pure returns (int184 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt192(uint _offst, bytes memory _input) internal pure returns (int192 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt200(uint _offst, bytes memory _input) internal pure returns (int200 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt208(uint _offst, bytes memory _input) internal pure returns (int208 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt216(uint _offst, bytes memory _input) internal pure returns (int216 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt224(uint _offst, bytes memory _input) internal pure returns (int224 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt232(uint _offst, bytes memory _input) internal pure returns (int232 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt240(uint _offst, bytes memory _input) internal pure returns (int240 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt248(uint _offst, bytes memory _input) internal pure returns (int248 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt256(uint _offst, bytes memory _input) internal pure returns (int256 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

	function bytesToUint8(uint _offst, bytes memory _input) internal pure returns (uint8 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint16(uint _offst, bytes memory _input) internal pure returns (uint16 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint24(uint _offst, bytes memory _input) internal pure returns (uint24 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint32(uint _offst, bytes memory _input) internal pure returns (uint32 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint40(uint _offst, bytes memory _input) internal pure returns (uint40 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint48(uint _offst, bytes memory _input) internal pure returns (uint48 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint56(uint _offst, bytes memory _input) internal pure returns (uint56 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint64(uint _offst, bytes memory _input) internal pure returns (uint64 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint72(uint _offst, bytes memory _input) internal pure returns (uint72 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint80(uint _offst, bytes memory _input) internal pure returns (uint80 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint88(uint _offst, bytes memory _input) internal pure returns (uint88 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint96(uint _offst, bytes memory _input) internal pure returns (uint96 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 
	
	function bytesToUint104(uint _offst, bytes memory _input) internal pure returns (uint104 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint112(uint _offst, bytes memory _input) internal pure returns (uint112 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint120(uint _offst, bytes memory _input) internal pure returns (uint120 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint128(uint _offst, bytes memory _input) internal pure returns (uint128 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint136(uint _offst, bytes memory _input) internal pure returns (uint136 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint144(uint _offst, bytes memory _input) internal pure returns (uint144 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint152(uint _offst, bytes memory _input) internal pure returns (uint152 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint160(uint _offst, bytes memory _input) internal pure returns (uint160 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint168(uint _offst, bytes memory _input) internal pure returns (uint168 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint176(uint _offst, bytes memory _input) internal pure returns (uint176 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint184(uint _offst, bytes memory _input) internal pure returns (uint184 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint192(uint _offst, bytes memory _input) internal pure returns (uint192 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint200(uint _offst, bytes memory _input) internal pure returns (uint200 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint208(uint _offst, bytes memory _input) internal pure returns (uint208 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint216(uint _offst, bytes memory _input) internal pure returns (uint216 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint224(uint _offst, bytes memory _input) internal pure returns (uint224 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint232(uint _offst, bytes memory _input) internal pure returns (uint232 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint240(uint _offst, bytes memory _input) internal pure returns (uint240 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint248(uint _offst, bytes memory _input) internal pure returns (uint248 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function bytesToUint256(uint _offst, bytes memory _input) internal pure returns (uint256 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 
    
}

pragma solidity 0.6.4;

interface ISystemReward {
  function claimRewards(address payable to, uint256 amount) external returns(uint256 actualAmount);
}

pragma solidity 0.6.4;

interface IRelayerHub {
  function isRelayer(address sender) external view returns (bool);
}

pragma solidity 0.6.4;

interface IParamSubscriber {
    function updateParam(string calldata key, bytes calldata value) external;
}

pragma solidity 0.6.4;

interface ILightClient {

  function isHeaderSynced(uint64 height) external view returns (bool);

  function getAppHash(uint64 height) external view returns (bytes32);

  function getSubmitter(uint64 height) external view returns (address payable);

}

pragma solidity 0.6.4;

import "./interface/ISystemReward.sol";
import "./interface/IRelayerHub.sol";
import "./interface/ILightClient.sol";

contract System {

  bool public alreadyInit;

  uint32 public constant CODE_OK = 0;
  uint32 public constant ERROR_FAIL_DECODE = 100;

  uint8 constant public BIND_CHANNELID = 0x01;
  uint8 constant public TRANSFER_IN_CHANNELID = 0x02;
  uint8 constant public TRANSFER_OUT_CHANNELID = 0x03;
  uint8 constant public STAKING_CHANNELID = 0x08;
  uint8 constant public GOV_CHANNELID = 0x09;
  uint8 constant public SLASH_CHANNELID = 0x0b;
  uint16 constant public bscChainID = 0x0060;

  address public constant VALIDATOR_CONTRACT_ADDR = 0x0000000000000000000000000000000000001000;
  address public constant SLASH_CONTRACT_ADDR = 0x0000000000000000000000000000000000001001;
  address public constant SYSTEM_REWARD_ADDR = 0xdBcf32b085ad1F2A437EBa944dC2A4B2e65cA384;
  address public constant LIGHT_CLIENT_ADDR = 0x0000000000000000000000000000000000001003;
  address public constant TOKEN_HUB_ADDR = 0x6A57085487DF84b385b3a8Ea066f87BfD3ad401e;
  address public constant INCENTIVIZE_ADDR=0x0000000000000000000000000000000000001005;
  address public constant RELAYERHUB_CONTRACT_ADDR = 0x14a3B93c16285d4f5A23CeeB2002e22DCC3d3bc4;
  address public constant GOV_HUB_ADDR = 0x0000000000000000000000000000000000001007;
  address public constant TOKEN_MANAGER_ADDR = 0x7Aa27382e5817D1C364bc58c6950f77a14D496DD;
  address public constant CROSS_CHAIN_CONTRACT_ADDR = 0x2Db902ada50bf75206ed9Bd694bDC1C0cD5c1138;


  modifier onlyCoinbase() {
    require(msg.sender == block.coinbase, "the message sender must be the block producer");
    _;
  }

  modifier onlyNotInit() {
    require(!alreadyInit, "the contract already init");
    _;
  }

  modifier onlyInit() {
    require(alreadyInit, "the contract not init yet");
    _;
  }

  modifier onlySlash() {
    require(msg.sender == SLASH_CONTRACT_ADDR, "the message sender must be slash contract");
    _;
  }

  modifier onlyTokenHub() {
    require(msg.sender == TOKEN_HUB_ADDR, "the message sender must be token hub contract");
    _;
  }

  modifier onlyGov() {
    require(msg.sender == GOV_HUB_ADDR, "the message sender must be governance contract");
    _;
  }

  modifier onlyValidatorContract() {
    require(msg.sender == VALIDATOR_CONTRACT_ADDR, "the message sender must be validatorSet contract");
    _;
  }

  modifier onlyCrossChainContract() {
    require(msg.sender == CROSS_CHAIN_CONTRACT_ADDR, "the message sender must be cross chain contract");
    _;
  }

  modifier onlyRelayerIncentivize() {
    require(msg.sender == INCENTIVIZE_ADDR, "the message sender must be incentivize contract");
    _;
  }

  modifier onlyRelayer() {
    require(IRelayerHub(RELAYERHUB_CONTRACT_ADDR).isRelayer(msg.sender), "the msg sender is not a relayer");
    _;
  }

  modifier onlyTokenManager() {
    require(msg.sender == TOKEN_MANAGER_ADDR, "the msg sender must be tokenManager");
    _;
  }

  // Not reliable, do not use when need strong verify
  function isContract(address addr) internal view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
}