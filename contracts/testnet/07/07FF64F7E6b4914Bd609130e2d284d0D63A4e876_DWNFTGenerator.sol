/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

// File: contracts/support/safemath.sol


pragma solidity >=0.4.16 <0.9.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title SafeMath32
 * @dev SafeMath library implemented for uint32
 */
library SafeMath32 {

  function mul(uint32 a, uint32 b) internal pure returns (uint32) {
    if (a == 0) {
      return 0;
    }
    uint32 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint32 a, uint32 b) internal pure returns (uint32) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint32 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint32 a, uint32 b) internal pure returns (uint32) {
    assert(b <= a);
    return a - b;
  }

  function add(uint32 a, uint32 b) internal pure returns (uint32) {
    uint32 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title SafeMath16
 * @dev SafeMath library implemented for uint16
 */
library SafeMath16 {

  function mul(uint16 a, uint16 b) internal pure returns (uint16) {
    if (a == 0) {
      return 0;
    }
    uint16 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint16 a, uint16 b) internal pure returns (uint16) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint16 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint16 a, uint16 b) internal pure returns (uint16) {
    assert(b <= a);
    return a - b;
  }

  function add(uint16 a, uint16 b) internal pure returns (uint16) {
    uint16 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/DWNFTGenerator.sol


pragma solidity >=0.4.16 <0.9.0;


contract DWNFTGenerator {
    using SafeMath for uint256;
    uint256[] internal wr;
    uint256[] private _maxValues = [
        1,
        20,
        6,
        18,
        11,
        18,
        7,
        18,
        15,
        18,
        8,
        20,
        18,
        18,
        16,
        18,
        12,
        11
    ];
    uint256[] internal waifuRarityProb = [47, 83, 95, 99, 100];
    uint256[][] internal waifuDurability = [
        [63, 80],
        [55, 80],
        [30, 60],
        [30, 50],
        [30, 45]
    ];
    uint256[][] internal tractorDurability = [
        [67, 81],
        [58, 72],
        [53, 67],
        [43, 57],
        [38, 52]
    ];
    uint256[] private _places = [
        2,
        2,
        3,
        3,
        4,
        3,
        4,
        3,
        4,
        3,
        4,
        4,
        4,
        3,
        4,
        3,
        4,
        4
    ];

    //Reward amount and winRatio are per field
    uint256[] rewardAmount = [
        8,
        9,
        10,
        12,
        15,
        19,
        24,
        30,
        38,
        44,
        56,
        64,
        80,
        88,
        96,
        112,
        125,
        137
    ];
    uint256[] winRatio = [
        870,
        841,
        813,
        786,
        760,
        735,
        711,
        688,
        666,
        645,
        625,
        606,
        588,
        571,
        555,
        540,
        526,
        513
    ];


    function generateDNA(uint256 _seed)
        external
        view
        returns (uint256)
    {
        uint256 adn = 0;
        uint256 places = 0;
        for (uint256 i = 0; i < _maxValues.length; i++) {
            _seed >>= 1;
            if (i == 8) {
                uint256 prob = (_seed >> 1) % 100;
                if (
                    prob < 10 &&
                    _seed % _maxValues[i] <= 5 &&
                    _seed % _maxValues[i] >= 8
                ) {
                    adn = ((_seed % 4)) * 10**places + adn;
                } else {
                    adn =
                        (((_seed % _maxValues[i]) - 4) + 4) *
                        10**places +
                        adn;
                }
            } else if (
                i == 3 || i == 5 || i == 7 || i == 9 || i == 13 || i == 15
            ) {
                adn = (_seed % _maxValues[i]) * 20 * 10**places + adn;
            } else {
                adn = (_seed % _maxValues[i]) * 10**places + adn;
            }
            places += _places[i];
        }
        return adn + 1;
    }

    function generateWP(uint256 _seed)
        external
        view
        returns (uint8[6] memory)
    {
        uint8[6] memory WPArray;
        uint8 mainWP;
        uint256 rarity;
        _seed >>= 1;
        uint256 prob = _seed % 100;
        _seed >>= 1;
        if (prob < 47) {
            mainWP = uint8(_seed % 34) + 15;
            rarity = 0;
        } else if (prob < 83) {
            mainWP = uint8(_seed % 50) + 50;
            rarity = 1;
        } else if (prob < 95) {
            mainWP = uint8(_seed % 50) + 100;
            rarity = 2;
        } else if (prob < 99) {
            mainWP = uint8(_seed % 50) + 150;
            rarity = 3;
        } else {
            mainWP = uint8(_seed % 51) + 200;
            rarity = 4;
        }
        WPArray = generateSecondaryWP(_seed, rarity);
        WPArray[5] = mainWP;
        shuffleArray(WPArray, _seed);
        return WPArray;
    }

    function generateSecondaryWP(uint256 _seed, uint256 _mainRarity)
        internal
        view
        returns (uint8[6] memory)
    {
        uint8[6] memory secondaryWPArray;
        for (uint256 i = 0; i < 5; i++) {
            _seed >>= 1;
            uint256 prob = _seed % waifuRarityProb[_mainRarity];
            if (prob < waifuRarityProb[0]) {
                secondaryWPArray[i] = uint8(_seed % 35) + 15;
                continue;
            }
            if (prob < waifuRarityProb[1]) {
                secondaryWPArray[i] = uint8(_seed % 50) + 50;
                continue;
            }
            if (prob < waifuRarityProb[2]) {
                secondaryWPArray[i] = uint8(_seed % 50) + 100;
                continue;
            }
            if (prob < waifuRarityProb[3]) {
                secondaryWPArray[i] = uint8(_seed % 50) + 150;
                continue;
            }
            secondaryWPArray[i] = uint8(_seed % 51) + 200;
        }
        return secondaryWPArray;
    }

    function shuffleArray(uint8[6] memory _array, uint256 _seed)
        internal
        pure
        returns (uint8[6] memory)
    {
        for (uint256 i = 0; i < _array.length; i++) {
            uint256 n = i + (_seed % (_array.length - i));
            uint8 temp = _array[n];
            _array[n] = _array[i];
            _array[i] = temp;
        }
        return _array;
    }

    function generateRewardAmount(uint256 _seed, uint256 _fieldId)
        external
        view
        returns (uint256)
    {
        _seed >>= 50;
        uint256 prob = (_seed % 1000);
        if (prob < winRatio[_fieldId]) {
            return rewardAmount[_fieldId];
        } else {
            return 0;
        }
    }

    function generateTractorRarity(uint256 _seed)
        external
        pure
        returns (uint8)
    {
        uint8 rarity;
        _seed >>= 1;
        uint256 prob = _seed % 100;
        if (prob < 47) {
            rarity = 0;
        } else if (prob < 83) {
            rarity = 1;
        } else if (prob < 95) {
            rarity = 2;
        } else if (prob < 99) {
            rarity = 3;
        } else {
            rarity = 4;
        }
        return rarity;
    }

    function generateDurability(
        uint256 _seed,
        uint256 _rarity,
        uint8 _type
    ) external view returns (uint256) {
        _seed >>= 1;
        uint256 durability;
        if (_type == 0) {
            durability =
                waifuDurability[_rarity][1] -
                waifuDurability[_rarity][0] +
                1;
            durability = (_seed % durability) + waifuDurability[_rarity][0];
        } else {
            durability =
                tractorDurability[_rarity][1] -
                tractorDurability[_rarity][0] +
                1;
            durability = (_seed % durability) + tractorDurability[_rarity][0];
        }
        return durability;
    }
}