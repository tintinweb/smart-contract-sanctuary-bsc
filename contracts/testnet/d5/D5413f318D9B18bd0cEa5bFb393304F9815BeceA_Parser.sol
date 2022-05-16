// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Parser {
    //common attribute
    uint constant public LEVEL = 31;
    uint constant public TYPE = 30;
    // avatar attribute
    uint constant public BACKGROUND = 0;
    uint constant public OUTFIT = 1;
    uint constant public WEAPON = 2;
    uint constant public FUR = 3;
    uint constant public HAIR = 4;
    uint constant public EAR = 5;
    uint constant public EYES = 6;
    uint constant public MOUTH = 7;

    //maximum types in an attribute
    uint constant public MAX_TYPE = 3;
    uint constant public MAX_BACKGROUND = 15;
    uint constant public MAX_OUTFIT = 15;
    uint constant public MAX_WEAPON = 15;
    uint constant public MAX_FUR = 15;
    uint constant public MAX_HAIR = 15;
    uint constant public MAX_EAR = 15;
    uint constant public MAX_EYES = 15;
    uint constant public MAX_MOUTH = 15;

    //n_bits
    uint constant public n_bits = 8;
    uint constant public padding = 0xFF;

    //percentage
    uint constant public PERCENTAGE = 1e6;

    // maximum level support
    uint constant public MAX_LEVEL = 10;

    //data storage for random
    //level => index of attribute => type => percentage
    mapping(uint => mapping(uint => mapping(uint => uint))) public attributes;


    event SetDataSuccess(address indexed _delegate, bool success, bytes data);
    // ===================== EXTERNAL FUNCTIONS ====================== //
    function setRateData(address _delegate) external {
        (bool success, bytes memory data) = _delegate.delegatecall(
            abi.encodeWithSignature("setData()")
        );
        require(success, "Parser: init data failed");
        emit SetDataSuccess(_delegate, success, data);
    }

    function info(uint id) external pure returns (
        uint _level,
        uint _type,
        uint _background,
        uint _outfit,
        uint _weapon,
        uint _fur,
        uint _hair,
        uint _ear,
        uint _eyes,
        uint _mouth
    ) {
        _level = id >> (n_bits * LEVEL) & padding;
        _type = (id >> (n_bits * TYPE) & padding) % MAX_TYPE;
        _background = (id >> (n_bits * BACKGROUND) & padding) % MAX_BACKGROUND;
        _outfit = (id >> (n_bits * OUTFIT) & padding) % MAX_OUTFIT;
        _weapon = (id >> (n_bits * WEAPON) & padding) % MAX_WEAPON;
        _fur = (id >> (n_bits * FUR) & padding) % MAX_FUR;
        _hair = (id >> (n_bits * HAIR) & padding) % MAX_HAIR;
        _ear = (id >> (n_bits * EAR) & padding) % MAX_EAR;
        _eyes = (id >> (n_bits * EYES) & padding) % MAX_EYES;
        _mouth = (id >> (n_bits * MOUTH) & padding) % MAX_MOUTH;
    }

    function getTypeProbability(uint _level) internal view returns (uint256[] memory _data, uint sum) {
        _data = new uint256[](MAX_TYPE);
        sum = 0;
        for (uint256 i = 0; i < MAX_TYPE; i++) {
            _data[i] = attributes[_level][TYPE][i] + sum;
            sum += _data[i];
        }
    }

    function getType(uint level, uint rand) internal view returns (uint) {
        (uint256[] memory _probability, uint sum) = getTypeProbability(level);
        uint _r = _computerSeed(rand >> (n_bits * TYPE) & padding) % sum;
        for (uint256 i = 0; i < _probability.length; i++) {
            if (_probability[i] >= _r) {
                return i;
            }
        }
        return 0;
    }

    function getBackgroundProbability(uint _level) internal view returns (uint256[] memory _data, uint sum) {
        _data = new uint256[](MAX_BACKGROUND);
        for (uint256 i = 0; i < MAX_BACKGROUND; i++) {
            _data[i] = attributes[_level][BACKGROUND][i] + sum;
            sum += _data[i];
        }
    }

    function getBackground(uint level, uint rand) internal view returns (uint) {
        (uint256[] memory _probability, uint sum) = getBackgroundProbability(level);
        uint _r = _computerSeed(rand >> (n_bits * BACKGROUND) & padding) % sum;
        for (uint256 i = 0; i < _probability.length; i++) {
            if (_probability[i] >= _r) {
                return i;
            }
        }
        return 0;
    }

    function getOutfitProbability(uint _level) internal view returns (uint256[] memory _data, uint sum) {
        _data = new uint256[](MAX_OUTFIT);
        for (uint256 i = 0; i < MAX_OUTFIT; i++) {
            _data[i] = attributes[_level][OUTFIT][i] + sum;
            sum += _data[i];
        }
    }

    function getOutfit(uint level, uint rand) internal view returns (uint) {
        (uint256[] memory _probability, uint sum) = getOutfitProbability(level);
        uint _r = _computerSeed(rand >> (n_bits * OUTFIT) & padding) % sum;
        for (uint256 i = 0; i < _probability.length; i++) {
            if (_probability[i] >= _r) {
                return i;
            }
        }
        return 0;
    }

    function getFurProbability(uint _level) internal view returns (uint256[] memory _data, uint sum) {
        _data = new uint256[](MAX_FUR);
        for (uint256 i = 0; i < MAX_FUR; i++) {
            _data[i] = attributes[_level][FUR][i] + sum;
            sum += _data[i];}
    }

    function getFur(uint level, uint rand) internal view returns (uint) {
        (uint256[] memory _probability, uint sum) = getFurProbability(level);
        uint _r = _computerSeed(rand >> (n_bits * EYES) & padding) % sum;
        for (uint256 i = 0; i < _probability.length; i++) {
            if (_probability[i] >= _r) {
                return i;
            }
        }
        return 0;
    }

    function getWeaponProbability(uint _level) internal view returns (uint256[] memory _data, uint sum) {
        _data = new uint256[](MAX_WEAPON);
        for (uint256 i = 0; i < MAX_WEAPON; i++) {
            _data[i] = attributes[_level][WEAPON][i] + sum;
            sum += _data[i];
        }
    }

    function getWeapon(uint level, uint rand) internal view returns (uint) {
        (uint256[] memory _probability, uint sum) = getWeaponProbability(level);
        uint _r = _computerSeed(rand >> (n_bits * WEAPON) & padding) % sum;
        for (uint256 i = 0; i < _probability.length; i++) {
            if (_probability[i] >= _r) {
                return i;
            }
        }
        return 0;
    }

    function getHairProbability(uint _level) internal view returns (uint256[] memory _data, uint sum) {
        _data = new uint256[](MAX_HAIR);
        for (uint256 i = 0; i < MAX_HAIR; i++) {
            _data[i] = attributes[_level][HAIR][i] + sum;
            sum += _data[i];
        }
    }

    function getHair(uint level, uint rand) internal view returns (uint) {
        (uint256[] memory _probability, uint sum) = getHairProbability(level);
        uint _r = _computerSeed(rand >> (n_bits * HAIR) & padding) % sum;
        for (uint256 i = 0; i < _probability.length; i++) {
            if (_probability[i] >= _r) {
                return i;
            }
        }
        return 0;
    }

    function getEarProbability(uint _level) internal view returns (uint256[] memory _data, uint sum) {
        _data = new uint256[](MAX_EAR);
        for (uint256 i = 0; i < MAX_EAR; i++) {
            _data[i] = attributes[_level][EAR][i] + sum;
            sum += _data[i];
        }
    }

    function getEar(uint level, uint rand) internal view returns (uint) {
        (uint256[] memory _probability, uint sum) = getEarProbability(level);
        uint _r = _computerSeed(rand >> (n_bits * EAR) & padding) % sum;
        for (uint256 i = 0; i < _probability.length; i++) {
            if (_probability[i] >= _r) {
                return i;
            }
        }
        return 0;
    }

    function getEyesProbability(uint _level) internal view returns (uint256[] memory _data, uint sum) {
        _data = new uint256[](MAX_EYES);
        for (uint256 i = 0; i < MAX_EYES; i++) {
            _data[i] = attributes[_level][EYES][i] + sum;
            sum += _data[i];
        }
    }

    function getEyes(uint level, uint rand) internal view returns (uint) {
        (uint256[] memory _probability, uint sum) = getEyesProbability(level);
        uint _r = _computerSeed(rand >> (n_bits * EYES) & padding) % sum;
        for (uint256 i = 0; i < _probability.length; i++) {
            if (_probability[i] >= _r) {
                return i;
            }
        }
        return 0;
    }

    function getMouthProbability(uint _level) internal view returns (uint256[] memory _data, uint sum) {
        _data = new uint256[](MAX_MOUTH);
        for (uint256 i = 0; i < MAX_MOUTH; i++) {
            _data[i] = attributes[_level][MOUTH][i] + sum;
            sum += _data[i];
        }
    }

    function getMouth(uint level, uint rand) internal view returns (uint) {
        (uint256[] memory _probability, uint sum) = getMouthProbability(level);
        uint _r = _computerSeed(rand >> (n_bits * MOUTH) & padding) % sum;
        for (uint256 i = 0; i < _probability.length; i++) {
            if (_probability[i] >= _r) {
                return i;
            }
        }
        return 0;
    }

    function _computerSeed(uint rand) internal view returns (uint256) {
        uint256 seed =
        uint256(
            keccak256(
                abi.encodePacked(
                    (block.timestamp) + rand,
                    address(msg.sender),
                    blockhash(block.number)
                )
            )
        );
        return seed;
    }

    function compose(
        uint _type,
        uint _background,
        uint _outfit,
        uint _weapon,
        uint _fur,
        uint _hair,
        uint _ear,
        uint _eyes,
        uint _mouth
    ) internal pure returns (uint) {
        uint id = 0;
        id |= (_type & padding) << (n_bits * TYPE);
        id |= (_background & padding) << (n_bits * BACKGROUND);
        id |= (_outfit & padding) << (n_bits * OUTFIT);
        id |= (_weapon & padding) << (n_bits * WEAPON);
        id |= (_hair & padding) << (n_bits * HAIR);
        id |= (_ear & padding) << (n_bits * EAR);
        id |= (_eyes & padding) << (n_bits * EYES);
        id |= (_mouth & padding) << (n_bits * MOUTH);
        id |= (_fur & padding) << (n_bits * FUR);
        return id;
    }

//    function getProbabilityOfTraits() internal view returns(
//        uint _type,
//        uint _background,
//        uint _outfit,
//        uint _weapon,
//        uint _fur,
//        uint _hair,
//        uint _ear,
//        uint _eyes,
//        uint _mouth
//    ) {
//        _type = attributes[_level][TYPE][_type];
//        _background = attributes[_level][BACKGROUND][_background];
//        _outfit = attributes[_level][OUTFIT][_outfit];
//        _weapon = attributes[_level][WEAPON][_weapon];
//        _fur = attributes[_level][FUR][_fur];
//        _hair = attributes[_level][HAIR][_hair];
//        _ear = attributes[_level][EAR][_ear];
//        _eyes = attributes[_level][EYES][_eyes];
//        _mouth = attributes[_level][MOUTH][_mouth];
//    }

    function getRarityScore(uint id) external view returns (
        uint[9] memory _probability,
        uint _rarityScore
    ) {
        uint _level = id >> (n_bits * LEVEL) & padding;
        uint[] memory _traits = new uint[](9);
        _traits[0] = (id >> (n_bits * TYPE) & padding) % MAX_TYPE;
        _traits[1] = (id >> (n_bits * BACKGROUND) & padding) % MAX_BACKGROUND;
        _traits[2] = (id >> (n_bits * OUTFIT) & padding) % MAX_OUTFIT;
        _traits[3] = (id >> (n_bits * WEAPON) & padding) % MAX_WEAPON;
        _traits[4]= (id >> (n_bits * FUR) & padding) % MAX_FUR;
        _traits[5] = (id >> (n_bits * HAIR) & padding) % MAX_HAIR;
        _traits[6] = (id >> (n_bits * EAR) & padding) % MAX_EAR;
        _traits[7] = (id >> (n_bits * EYES) & padding) % MAX_EYES;
        _traits[8] = (id >> (n_bits * MOUTH) & padding) % MAX_MOUTH;

        _probability[0] = attributes[_level][TYPE][_traits[0]];
        _probability[1] = attributes[_level][BACKGROUND][_traits[1]];
        _probability[2] = attributes[_level][OUTFIT][_traits[2]];
        _probability[3] = attributes[_level][WEAPON][_traits[3]];
        _probability[4] = attributes[_level][FUR][_traits[4]];
        _probability[5] = attributes[_level][HAIR][_traits[5]];
        _probability[6] = attributes[_level][EAR][_traits[6]];
        _probability[7] = attributes[_level][EYES][_traits[7]];
        _probability[8] = attributes[_level][MOUTH][_traits[8]];

        for(uint i = 0; i < _probability.length; i ++) {
            _rarityScore += (PERCENTAGE - _probability[i]) * 10;
        }
    }

    function generateId(uint _level, uint _rand) external view returns (uint id) {
        if (_level > MAX_LEVEL) return 0;
        return compose(
            getType(_level, _rand),
            getBackground(_level, _rand),
            getOutfit(_level, _rand),
            getWeapon(_level, _rand),
            getFur(_level, _rand),
            getHair(_level, _rand),
            getEar(_level, _rand),
            getEyes(_level, _rand),
            getMouth(_level, _rand)
        );
    }
}