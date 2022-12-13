//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library Randomizer
{
    event Divine(uint32 indexed tokenID, uint32 indexed index, uint32 indexed divineType, uint32 oldValue, uint32 newValue);

    struct RandomData
    {
        uint256 min;
        uint256 max;
        uint256 randomCap;
    }

    // LCG of MMIX by Donald Knuth
    function getNextRandom(uint256 randomNumber) public pure returns(uint256)
    {
        unchecked
        {
            return ((6364136223846793005 * randomNumber + 1442695040888963407) & 18446744073709551615) >> 3;
        }
    }

    function getMintValues(uint256 randomNumber) external pure returns(uint32[8] memory, uint32[8] memory, uint256)
    {
        unchecked
        {
            uint32[8] memory mask;
            uint256 majorsCount;

            {
                uint256[] memory majorProbabilities = new uint256[](3);
                majorProbabilities[0] = 1000;
                majorProbabilities[1] = 400;
                majorProbabilities[2] = 100;

                uint256[] memory majorsMaskOrder = new uint256[](3);
                majorsMaskOrder[0] = 0;
                majorsMaskOrder[1] = 1;
                majorsMaskOrder[2] = 2;

                majorsMaskOrder = shuffleArray(randomNumber, majorsMaskOrder);

                uint256 isGameBonusChanceIncreased;
                for (uint256 i = 0; i < 3; ++i)
                {
                    uint256 maskValue = randomNumber % 1000 <= majorProbabilities[majorsCount] ? 1 : 0;
                    if (maskValue == 0)
                    {
                        break;
                    }

                    if (i == 1 && isGameBonusChanceIncreased == 1 && majorsMaskOrder[i] != 2)
                    {
                        if (randomNumber % 2 == 0)
                        {
                            majorsMaskOrder[i + 1] = majorsMaskOrder[i];
                            majorsMaskOrder[i] = 2;
                        }
                    }

                    mask[majorsMaskOrder[i]] = uint32(maskValue);
                    
                    if (i == 0 && majorsMaskOrder[i] != 2)
                    {
                        isGameBonusChanceIncreased = 1;
                    }
                    else
                    {
                        isGameBonusChanceIncreased = 0;
                    }

                    ++majorsCount;

                    randomNumber = getNextRandom(randomNumber);
                }
            }

            randomNumber = getNextRandom(randomNumber);

            {
                uint256[] memory minorProbabilities = new uint256[](4);
                minorProbabilities[0] = 700;
                minorProbabilities[1] = 350;
                minorProbabilities[2] = 150;
                minorProbabilities[3] = 50;

                uint256[] memory minorsMaskOrder = new uint256[](4);
                minorsMaskOrder[0] = 3;
                minorsMaskOrder[1] = 4;
                minorsMaskOrder[2] = 5;
                minorsMaskOrder[3] = 6;

                minorsMaskOrder = shuffleArray(randomNumber, minorsMaskOrder);

                uint256 minorsCount;
                for (uint256 i = 0; i < 4; ++i)
                {
                    uint256 maskValue = randomNumber % 1000 <= minorProbabilities[minorsCount] ? 1 : 0;
                    if (maskValue == 0)
                    {
                        break;
                    }

                    mask[minorsMaskOrder[i]] = uint32(maskValue);
                    ++minorsCount;

                    randomNumber = getNextRandom(randomNumber);
                }
            }

            randomNumber = getNextRandom(randomNumber);

            (uint32[8] memory values) = finalizeGettingMintValues(randomNumber, mask);

            {
                if (majorsCount == 3 && randomNumber % 100 < 20)
                {
                    majorsCount = 4;
                }
            }

            return (mask, values, majorsCount);
        }
    }

    function finalizeGettingMintValues(uint256 randomNumber, uint32[8] memory mask) public pure returns (uint32[8] memory)
    {
        unchecked
        {
            RandomData[][] memory randomization = getRandomization();

            uint32[8] memory values;
            for (uint256 i = 0; i < 7; ++i)
            {
                if (mask[i] == 1)
                {
                    uint256 randomRoll = randomNumber % 1000;
                    uint256 length = randomization[i].length;
                    for (uint256 j = 0; j < length; ++j)
                    {
                        if (randomRoll <= randomization[i][j].randomCap)
                        {
                            values[i] = uint32(randomization[i][j].min + randomNumber % (randomization[i][j].max - randomization[i][j].min));
                            randomNumber -= values[i];
                            break;
                        }
                    }
                }
            }

            return (values);
        }
    }

    function getUpgradeValue(uint256 randomNumber, uint32[8] memory modifiers, uint256 runeType, uint256 isAddingNewStat) external pure returns(uint256, uint32)
    {
        uint256[] memory indexes;
        if (runeType == 0)
        {
            indexes = new uint256[](4);
            indexes[0] = 3;
            indexes[1] = 4;
            indexes[2] = 5;
            indexes[3] = 6;
        }
        else
        {
            if (isAddingNewStat == 1)
            {
                if (modifiers[2] == 0 && (modifiers[0] == 0 || modifiers[1] == 0))
                {
                    indexes = new uint256[](4);
                    indexes[0] = 0;
                    indexes[1] = 1;
                    indexes[2] = 2;
                    indexes[3] = 2;
                }
                else
                {
                    indexes = new uint256[](3);
                    indexes[0] = 0;
                    indexes[1] = 1;
                    indexes[2] = 2;
                }
            }
            else
            {
                indexes = new uint256[](2);
                indexes[0] = 0;
                indexes[1] = 1;
            }
        }

        indexes = shuffleArray(randomNumber, indexes);

        unchecked
        {
            for (uint256 i = 0; i < indexes.length; ++i)
            {
                if ((modifiers[indexes[i]] == 0 && isAddingNewStat == 1) || (modifiers[indexes[i]] != 0 && isAddingNewStat == 0))
                {
                    return (indexes[i], getValue(randomNumber, indexes[i]));
                }
            }
        }

        return (0, 0);
    }

    function getValue(uint256 randomNumber, uint256 index) public pure returns(uint32)
    {
        RandomData[] memory randomData;
        if (index == 0)
        {
            randomData = new RandomData[](6);
            randomData[0] = RandomData(100, 250, 10);
            randomData[1] = RandomData(80, 100, 100);
            randomData[2] = RandomData(60, 80, 250);
            randomData[3] = RandomData(40, 60, 450);
            randomData[4] = RandomData(20, 40, 700);
            randomData[5] = RandomData(10, 20, 999);
        }
        else if (index == 1)
        {
            randomData = new RandomData[](6);
            randomData[0] = RandomData(100000, 150000, 10);
            randomData[1] = RandomData(80000, 100000, 100);
            randomData[2] = RandomData(60000, 80000, 250);
            randomData[3] = RandomData(40000, 60000, 450);
            randomData[4] = RandomData(20000, 40000, 700);
            randomData[5] = RandomData(10000, 20000, 999);
        }
        else if (index == 2)
        {
            randomData = new RandomData[](1);
            randomData[0] = RandomData(1, 999, 999);
        }
        else if (index == 3)
        {
            randomData = new RandomData[](4);
            randomData[0] = RandomData(200, 300, 50);
            randomData[1] = RandomData(150, 200, 150);
            randomData[2] = RandomData(100, 150, 500);
            randomData[3] = RandomData(10, 100, 999);
        }
        else if (index == 4)
        {
            randomData = new RandomData[](5);
            randomData[0] = RandomData(100, 300, 10);
            randomData[1] = RandomData(80, 100, 100);
            randomData[2] = RandomData(60, 80, 300);
            randomData[3] = RandomData(40, 60, 600);
            randomData[4] = RandomData(10, 40, 999);
        }
        else if (index == 5)
        {
            randomData = new RandomData[](6);
            randomData[0] = RandomData(500, 1000, 10);
            randomData[1] = RandomData(400, 500, 100);
            randomData[2] = RandomData(300, 400, 250);
            randomData[3] = RandomData(200, 300, 450);
            randomData[4] = RandomData(100, 200, 700);
            randomData[5] = RandomData(10, 100, 999);
        }
        else if (index == 6)
        {
            randomData = new RandomData[](5);
            randomData[0] = RandomData(4000, 5000, 50);
            randomData[1] = RandomData(3000, 4000, 150);
            randomData[2] = RandomData(2000, 3000, 350);
            randomData[3] = RandomData(1000, 2000, 600);
            randomData[4] = RandomData(100, 1000, 999);
        }

        unchecked
        {
            uint256 randomRoll = randomNumber % 1000;
            uint256 length = randomData.length;
            for (uint256 i = 0; i < length; ++i)
            {
                if (randomRoll <= randomData[i].randomCap)
                {
                    return uint32(randomData[i].min + randomNumber % (randomData[i].max - randomData[i].min));
                }
            }
        }

        return uint32(randomData[0].min);
    }

    function divine(uint256 randomNumber, uint32[8] memory modifiers, uint32 tokenID, uint32 amount) external returns(uint32[8] memory)
    {
        uint32[8] memory minValues = [uint32(10), 10000, 0, 10, 10, 10, 100, 0];
        uint32[8] memory maxValues = [uint32(100), 100000, 0, 300, 100, 500, 5000, 0];
        uint32[8] memory maxBoostedValues = [uint32(250), 150000, 0, 300, 300, 1000, 5000, 0];

        unchecked
        {
            uint256 attributesAmount;
            if (modifiers[0] > 0) { ++attributesAmount; }
            if (modifiers[1] > 0) { ++attributesAmount; }
            if (modifiers[3] > 0) { ++attributesAmount; }
            if (modifiers[4] > 0) { ++attributesAmount; }
            if (modifiers[5] > 0) { ++attributesAmount; }
            if (modifiers[6] > 0) { ++attributesAmount; }

            if (attributesAmount == 0)
            {
                return modifiers;
            }

            uint256[] memory indexes = new uint256[](attributesAmount);
            uint256 currentAttrIndex = 0;
            for (uint256 i = 0; i < 7; ++i)
            {
                if (modifiers[i] > 0 && i != 2)
                {
                    indexes[currentAttrIndex++] = i;
                }
            }

            for (uint32 i = 0; i < amount; ++i)
            {
                uint256 attrIndex = indexes[randomNumber % attributesAmount];

                randomNumber = getNextRandom(randomNumber);

                uint32 change = uint32(maxValues[attrIndex] * (randomNumber % 1001 + 500) / 10000);

                randomNumber = getNextRandom(randomNumber);

                uint32 oldValue = modifiers[attrIndex];

                if ((randomNumber % 2 == 0 || modifiers[attrIndex] == maxBoostedValues[attrIndex]) && modifiers[attrIndex] != minValues[attrIndex])
                {
                    if (change > modifiers[attrIndex] || modifiers[attrIndex] - change < minValues[attrIndex])
                    {
                        modifiers[attrIndex] = minValues[attrIndex];
                    }
                    else
                    {
                        modifiers[attrIndex] -= change;
                    }
                }
                else
                {
                    if (modifiers[attrIndex] > maxBoostedValues[attrIndex] - change)
                    {
                        modifiers[attrIndex] = maxBoostedValues[attrIndex];
                    }
                    else
                    {
                        modifiers[attrIndex] += change;
                    }
                }

                emit Divine(tokenID, uint32(attrIndex), 0, oldValue, modifiers[attrIndex]);
            }

            return modifiers;
        }
    }

    function getRandomization() public pure returns(RandomData[][] memory)
    {
        unchecked
        {
            RandomData[][] memory randomization = new RandomData[][](7);

            RandomData[] memory temp = new RandomData[](6);
            temp[0] = RandomData(100, 250, 10);
            temp[1] = RandomData(80, 100, 100);
            temp[2] = RandomData(60, 80, 250);
            temp[3] = RandomData(40, 60, 450);
            temp[4] = RandomData(20, 40, 700);
            temp[5] = RandomData(10, 20, 999);

            randomization[0] = temp;

            temp = new RandomData[](6);
            temp[0] = RandomData(100000, 150000, 10);
            temp[1] = RandomData(80000, 100000, 100);
            temp[2] = RandomData(60000, 80000, 250);
            temp[3] = RandomData(40000, 60000, 450);
            temp[4] = RandomData(20000, 40000, 700);
            temp[5] = RandomData(10000, 20000, 999);

            randomization[1] = temp;

            temp = new RandomData[](1);
            temp[0] = RandomData(1, 999, 999);

            randomization[2] = temp;

            temp = new RandomData[](4);
            temp[0] = RandomData(200, 300, 50);
            temp[1] = RandomData(150, 200, 150);
            temp[2] = RandomData(100, 150, 500);
            temp[3] = RandomData(10, 100, 999);

            randomization[3] = temp;
            
            temp = new RandomData[](5);
            temp[0] = RandomData(100, 300, 10);
            temp[1] = RandomData(80, 100, 100);
            temp[2] = RandomData(60, 80, 300);
            temp[3] = RandomData(40, 60, 600);
            temp[4] = RandomData(10, 40, 999);

            randomization[4] = temp;

            temp = new RandomData[](6);
            temp[0] = RandomData(500, 1000, 10);
            temp[1] = RandomData(400, 500, 100);
            temp[2] = RandomData(300, 400, 250);
            temp[3] = RandomData(200, 300, 450);
            temp[4] = RandomData(100, 200, 700);
            temp[5] = RandomData(10, 100, 999);

            randomization[5] = temp;

            temp = new RandomData[](5);
            temp[0] = RandomData(4000, 5000, 50);
            temp[1] = RandomData(3000, 4000, 150);
            temp[2] = RandomData(2000, 3000, 350);
            temp[3] = RandomData(1000, 2000, 600);
            temp[4] = RandomData(100, 1000, 999);

            randomization[6] = temp;

            return randomization;
        }
    }

    function shuffleArray(uint256 randomNumber, uint256[] memory array) public pure returns(uint256[] memory)
    {
        unchecked
        {
            uint256 length = array.length;
            for (uint256 i = 0; i < length; ++i)
            {
                uint256 n = i + randomNumber % (length - i);
                uint256 temp = array[n];
                array[n] = array[i];
                array[i] = temp;
            }

            return array;
        }
    }
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) external pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

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
        uint256 val = value;
        while (val != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(val % 10)));
            val /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) external pure returns (string memory) {
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

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) public pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        uint256 val = value;
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[val & 0xf];
            val >>= 4;
        }
        require(val == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IMore is IERC20 {
    function setModifiers(address account, uint32 reflections, uint32 isAddition, uint32 buyDiscount, uint32 sellDiscount) external;
    function setModifiers(address account1, address account2,
                             uint32 reflections,
                             uint32 buyDiscount1, uint32 sellDiscount1,
                             uint32 buyDiscount2, uint32 sellDiscount2) external;
    function getModifiers(address account1, address account2) external view returns(uint32, uint32, uint32, uint32);
    function getModifiers(address account) external view returns(uint32, uint32);

    function addShares(address account, uint256 difference, uint256 isAddition) external;
    function setBuyTaxReduction(address account, uint256 value) external;
    function setSellTaxReduction(address account, uint256 value) external;

    function buybackAndBurn() external payable;
    function buybackAndLockToLiquidity() external payable;
    function addBNBToLiquidityPot() external payable;

    function isAuthorized(address) external view returns(uint256);

    function prepareReferralSwap(address, uint32, uint16) external returns(uint32, uint16);
    function referrerSystemData() external view returns(uint16, uint16, uint16, uint16, uint96, uint96);
    function lastReferrerTokensAmount() external view returns(uint96);

    function lightningTransfer(address, uint256) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


interface IAgent {
    function delegate(
        uint256 buyPot, uint256 sellPot, uint256 transferPot, uint256 teamPot, uint256 referrerPot, uint256 tokensUsedForReferrerPot
    ) external payable;
    function marketplaceDelegate(uint256 toBuyback, uint256 toMarketing, uint256 toTeam) external payable;
    function notifyTransferListener(address from, address to) external;
    function notifyTransferListener(address from) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface ISaronite {
    function storeSaroniteDouble(address account1, address account2) external;
    function storeSaronite(address account) external;
    function addSaronitePerDay(address, uint256) external;
    function removeSaronitePerDay(address, uint256) external;
    function useSaronite(address, uint256) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IChainlinkVRF {
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestID);
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IMythicTreasures {
    function useItem(address, uint256) external;
    function useItems(address, uint256, uint256) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../Libraries/LibraryRandomizer.sol";
import "../Libraries/LibraryStrings.sol";
import "../Interfaces/IMore.sol";
import "../Interfaces/IAgent.sol";
import "../Interfaces/ISaronite.sol";
import "../Interfaces/IChainlinkVRF.sol";
import "../Interfaces/IMythicTreasures.sol";
import "../Interfaces/ImportsMoreMines.sol";

contract MoreMines
{
    string public name;
    string public symbol;
    string private baseURI;

    mapping(uint256 => address) private Owners;

    mapping(address => uint32[]) public OwnerToIDs;
    mapping(uint256 => uint256) private TokenToArrayIndex;

    mapping(address => uint256) private Balances;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    uint256 public areTransfersEnabled;
    uint256 public isStealingEnabled;

    uint256 public maxBalance;

    uint256[5] public RarityToAmount;

    // 0 reflection multiplier;
    // 1 saronite per day;
    // 2 game passive bonus;

    // 3 buy tax discount;
    // 4 sell tax discount;
    // 5 marketplace fee discount;
    // 6 shield discount;

    // 7 not used;
    mapping (uint256 => uint32[8]) public NftToModifiers;

    struct Properties
    {
        uint32 rarity;
        uint32 shieldEndTime;
        uint32 lastShieldType;
        uint32 lastStealType;
        uint32 lastStealTime;
        uint96 marketOffer;
        uint32 lastOwnerChangeTime;
        uint32 isStealPriceCorrected;
        uint96 upgradesPrice;
        uint96 stealAdditionalPrice;
    }
    mapping(uint256 => Properties) public NftToProperties;
    
    struct SecondaryProperties
    {
        uint32 greaterUpgrades;
        uint32 lesserUpgrades;
        uint32 isReferrer;
        uint32 lastSaroniteCompoundTime;
        uint32 divineUsages;
        uint32 p5;
        uint64 p6;
        uint256 randomNumber;
    }
    mapping(uint256 => SecondaryProperties) public NftToSecondaryProperties;

    mapping(address => uint256) private AccountToLegendaryShieldDiscount;

    uint256 public referrerTagPrice;

    uint256 currentCompoundingIndex;
    uint256[] public Legendaries;

    mapping(address => uint256) public MarketplaceDiscounts;

    IAgent public Agent;
    ISaronite public Saronite;
    IMythicTreasures public MythicTreasures;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    struct RandomRequest
    {
        uint32 requestType;
        uint32 isFullfilled;
        uint32 data1;
        uint32 data2;
        uint128 data3;
    }

    mapping(uint256 => RandomRequest) public RandomRequests;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    struct SupplyData
    {
        uint64 maxMintedLimit; // constant
        uint64 totalSupply;
        uint64 maxFreeMints;
        uint64 totalFreeMints;
    }
    SupplyData public supplyData;

    uint256 public mintShieldTime;

    mapping(uint256 => uint256) public AmountToMintPrice;

    uint256 marketplaceFee;

    uint256 public nextTokenID;

    uint256 public priceRate;

    struct ShieldProperties
    {
        uint32 time;
        uint32 reshieldThreshold;
        uint192 price;
    }
    mapping(uint256 => ShieldProperties) public ShieldTypeToProperties;

    IMore public More;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    // ADD NEW STORAGE FIELDS STARTING FROM HERE

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    function balanceOf(address owner) external view returns(uint256)
    {
        return Balances[owner];
    }

    function getAllOwned(address owner) external view returns(uint32[] memory)
    {
        return OwnerToIDs[owner];
    }

    function ownerOf(uint256 tokenID) external view returns(address)
    {
        require(Owners[tokenID] != address(0), "OO0");
        return Owners[tokenID];
    }

    function tokenURI(uint256 tokenID) external view returns(string memory)
    {
        require(Owners[tokenID] != address(0), "TURI0");

        return string(abi.encodePacked(baseURI, Strings.toString(tokenID), ".jpg"));
    }

    function _mint(address to, uint256 isFree) private returns(uint256)
    {
        uint256 tokenID = nextTokenID++;

        if (isFree == 0)
        {
            require(tokenID < supplyData.totalSupply - supplyData.maxFreeMints + supplyData.totalFreeMints, "_M0");
        }

        _beforeTokenTransfer(address(0), msg.sender, tokenID);

        Balances[to] += 1;
        Owners[tokenID] = to;

        TokenToArrayIndex[tokenID] = uint32(OwnerToIDs[to].length);
        OwnerToIDs[to].push(uint32(tokenID));

        uint32 shieldTimeEnd = uint32(block.timestamp + mintShieldTime);
        NftToProperties[tokenID] = Properties(0, shieldTimeEnd, 1, 0, 0, 0, uint32(block.timestamp), 0, 0, 0);
        NftToSecondaryProperties[tokenID].lastSaroniteCompoundTime = uint32(block.timestamp);

        createRandomRequest(0, uint32(tokenID), 0, 0);

        emit Transfer(address(0), to, tokenID);

        return tokenID;
    }

    function _transfer(address from, address to, uint256 tokenID) private {
        require(Owners[tokenID] == from, "_T0");

        _beforeTokenTransfer(from, to, tokenID);

        Balances[from] -= 1;
        Balances[to] += 1;
        Owners[tokenID] = to;

        uint256 tokenIndex = TokenToArrayIndex[tokenID];
        TokenToArrayIndex[tokenID] = uint32(OwnerToIDs[to].length);
        OwnerToIDs[to].push(uint32(tokenID));

        uint256 lastIndex = OwnerToIDs[from].length - 1;
        if (tokenIndex < lastIndex)
        {
            TokenToArrayIndex[OwnerToIDs[from][lastIndex]] = uint32(tokenIndex);
            OwnerToIDs[from][tokenIndex] = OwnerToIDs[from][lastIndex];
        }
        OwnerToIDs[from].pop();

        emit Transfer(from, to, tokenID);

        _afterTokenTransfer(from, to, tokenID);

        autoCompound();
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    modifier onlyHuman()
    {
        _onlyHuman();
        _;
    }

    function _onlyHuman() private view
    {
        require(tx.origin == msg.sender, "OH0");
    }

    function addSaronitePerDay(address account, uint256 amount) private
    {
        Saronite.addSaronitePerDay(account, amount);
    }

    function removeSaronitePerDay(address account, uint256 amount) private
    {
        Saronite.removeSaronitePerDay(account, amount);
    }

    function transfer(address to, uint256 tokenID) external onlyHuman()
    {
        require(areTransfersEnabled == 1, "T0");
        require(Owners[tokenID] == msg.sender, "T1");

        transferFrom(msg.sender, to, tokenID);
    }

    function transferFrom(address from, address to, uint256 tokenID) private
    {
        _transfer(from, to, tokenID);
        NftToProperties[tokenID].lastOwnerChangeTime = uint32(block.timestamp);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenID) private view
    {
        require(from != to, "BTT0");

        require(Balances[to] < maxBalance, "BTT1");

        require(NftToProperties[tokenID].rarity > 0 || Owners[tokenID] == address(0), "BTT2");

        require(block.timestamp - NftToProperties[tokenID].lastOwnerChangeTime > 60, "BTT3");
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenID) private
    {
        if (NftToModifiers[tokenID][1] > 0)
        {
            if (from != address(0))
            {
                removeSaronitePerDay(from, NftToModifiers[tokenID][1] + NftToModifiers[tokenID][7]);
            }
            
            addSaronitePerDay(to, NftToModifiers[tokenID][1] + NftToModifiers[tokenID][7]);
        }

        if (NftToProperties[tokenID].rarity == 4)
        {
            if (from != address(0))
            {
                AccountToLegendaryShieldDiscount[from] -= NftToModifiers[tokenID][6];
            }

            AccountToLegendaryShieldDiscount[to] += NftToModifiers[tokenID][6];
        }

        updateAccountModifiers(from, to, tokenID);
    }

    function resetAfterStatsChange(address account, uint256 tokenID, uint32[8] memory oldModifiers, uint32[8] memory newModifiers) private
    {
        (uint32 buyDiscount, uint32 sellDiscount) = More.getModifiers(account);

        uint32 reset;
        if ((newModifiers[3] < oldModifiers[3] && newModifiers[3] == buyDiscount)
            || (newModifiers[4] < oldModifiers[4] && newModifiers[4] == sellDiscount)
            || (newModifiers[5] < oldModifiers[5] && newModifiers[5] == MarketplaceDiscounts[account]))
        {
            reset = 1;

            (buyDiscount, sellDiscount, MarketplaceDiscounts[account]) = getNewModifiers(account);
        }
        else
        {
            if (newModifiers[3] > buyDiscount)
            {
                buyDiscount = newModifiers[3];
                reset = 1;
            }

            if (newModifiers[4] > sellDiscount)
            {
                sellDiscount = newModifiers[4];
                reset = 1;
            }

            if (newModifiers[5] > MarketplaceDiscounts[account])
            {
                MarketplaceDiscounts[account] = newModifiers[5];
            }
        }

        if (oldModifiers[1] + oldModifiers[7] > newModifiers[1] + newModifiers[7])
        {
            removeSaronitePerDay(account, oldModifiers[1] + oldModifiers[7] - newModifiers[1] - newModifiers[7]);
        }
        else if (oldModifiers[1] + oldModifiers[7] < newModifiers[1] + newModifiers[7])
        {
            addSaronitePerDay(account, newModifiers[1] + newModifiers[7] - oldModifiers[1] - oldModifiers[7]);
        }

        if (NftToProperties[tokenID].rarity == 4 && oldModifiers[6] != newModifiers[6])
        {
            AccountToLegendaryShieldDiscount[account] -= oldModifiers[6];
            AccountToLegendaryShieldDiscount[account] += newModifiers[6];
        }

        if (reset == 1 || oldModifiers[0] != newModifiers[0])
        {
            uint32 isAddition;
            uint32 reflectionsMultiplierDifference;
            if (newModifiers[0] > oldModifiers[0])
            {
                isAddition = 1;
                reflectionsMultiplierDifference = newModifiers[0] - oldModifiers[0];
            }
            else
            {
                reflectionsMultiplierDifference = oldModifiers[0] - newModifiers[0];
            }

            More.setModifiers(account, reflectionsMultiplierDifference, isAddition, buyDiscount, sellDiscount);
        }
    }

    function updateAccountModifiers(address from, address to, uint256 tokenID) private
    {
        uint32[8] memory modifiers = NftToModifiers[tokenID];

        if (from != to && from != address(0))
        {
            uint32 reset1;
            uint32 reset2;

            (uint32 buyDiscount1, uint32 sellDiscount1, uint32 buyDiscount2, uint32 sellDiscount2) = More.getModifiers(from, to);

            uint32 marketplaceDiscount1 = uint32(MarketplaceDiscounts[from]);
            uint256 marketplaceDiscount2 = MarketplaceDiscounts[to];
            
            if (modifiers[3] == buyDiscount1)
            {
                reset1 = 1;
            }
            if (modifiers[3] > buyDiscount2)
            {
                buyDiscount2 = modifiers[3];
                reset2 = 1;
            }

            if (modifiers[4] == sellDiscount1)
            {
                reset1 = 1;
            }
            if (modifiers[4] > sellDiscount2)
            {
                sellDiscount2 = modifiers[4];
                reset2 = 1;
            }

            if (modifiers[5] == marketplaceDiscount1)
            {
                reset1 = 1;
            }

            if (modifiers[5] > marketplaceDiscount2)
            {
                marketplaceDiscount2 = modifiers[5];
                MarketplaceDiscounts[to] = marketplaceDiscount2;
            }

            if (reset1 == 1)
            {
                (buyDiscount1, sellDiscount1, marketplaceDiscount1) = getNewModifiers(from);
                MarketplaceDiscounts[from] = marketplaceDiscount1;
            }

            if (reset1 + reset2 > 0 || modifiers[0] > 0)
            {
                More.setModifiers(from, to, modifiers[0], buyDiscount1, sellDiscount1, buyDiscount2, sellDiscount2);
            }
        }
        else
        {
            (uint32 buyDiscount, uint32 sellDiscount) = More.getModifiers(to);

            uint32 reset;
            if (modifiers[3] > buyDiscount)
            {
                buyDiscount = modifiers[3];
                reset = 1;
            }

            if (modifiers[4] > sellDiscount)
            {
                sellDiscount = modifiers[4];
                reset = 1;
            }

            if (modifiers[5] > MarketplaceDiscounts[to])
            {
                MarketplaceDiscounts[to] = modifiers[5];
            }

            if (reset == 1 || modifiers[0] > 0)
            {
                More.setModifiers(to, modifiers[0], 1, buyDiscount, sellDiscount);
            }
        }
    }

    function getNewModifiers(address account) public view returns(uint32, uint32, uint32)
    {
        uint32 buyDiscount;
        uint32 sellDiscount;
        uint32 marketplaceDiscount;

        for (uint256 i = 0; i < OwnerToIDs[account].length; ++i)
        {
            uint32[8] storage currentModifiers = NftToModifiers[OwnerToIDs[account][i]];

            if (buyDiscount < currentModifiers[3])
            {
                buyDiscount = currentModifiers[3];
            }
            if (sellDiscount < currentModifiers[4])
            {
                sellDiscount = currentModifiers[4];
            }
            if (marketplaceDiscount < currentModifiers[5])
            {
                marketplaceDiscount = currentModifiers[5];
            }
        }

        return (buyDiscount, sellDiscount, marketplaceDiscount);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    function createRandomRequest(uint32 requestType, uint32 data1, uint32 data2, uint128 data3) private
    {
        RandomRequests[addRandomRequest()] = RandomRequest(requestType, 0, data1, data2, data3);
    }

    function addRandomRequest() private returns(uint256)
    {
        return IChainlinkVRF(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE).requestRandomWords(0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04, 658, 3, 777777, 1);
    }

    function rawFulfillRandomWords(uint256 requestID, uint256[] memory randomWords) external
    {
        require(msg.sender == 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE, "RFRW0");

        fullfillRandomRequest(requestID, randomWords[0]);
    }

    function fullfillRandomRequest(uint256 requestID, uint256 randomNumber) private
    {
        RandomRequests[requestID].isFullfilled = 1;

        uint32 requestType = RandomRequests[requestID].requestType;
        if (requestType == 0)
        {
            finalizeMint(randomNumber, RandomRequests[requestID].data1);
        }
        else if (requestType == 1)
        {
            ameliorate(randomNumber, RandomRequests[requestID].data1, RandomRequests[requestID].data2);
        }
        else if (requestType == 2)
        {
            divine(randomNumber, RandomRequests[requestID].data1, RandomRequests[requestID].data2);
        }
    }

    function finalizeMint(uint256 randomNumber, uint256 tokenID) private
    {
        (uint32[8] memory mask, uint32[8] memory values, uint256 rarity) = Randomizer.getMintValues(randomNumber);

        NftToProperties[tokenID].rarity = uint32(rarity);

        NftToSecondaryProperties[tokenID].randomNumber = randomNumber;

        if (rarity == 4)
        {
            Legendaries.push(tokenID);
        }

        ++RarityToAmount[rarity];

        _updateModifiers(tokenID, mask, values);

        _afterTokenTransfer(address(0), Owners[tokenID], tokenID);
    }
    
    function addSaronite(uint256 tokenID, uint256 amount) private
    {
        NftToModifiers[tokenID][7] += uint32(amount);
        if (NftToModifiers[tokenID][1] > 0)
        {
            addSaronitePerDay(Owners[tokenID], uint32(amount));
        }

        emit SaroniteAdded(tokenID, amount);
    }

    function setMintShieldTime(uint256 newTime) external onlyAuthorized()
    {
        mintShieldTime = newTime;
    }

    function setReferrerTagPrice(uint96 newPrice) external onlyAuthorized()
    {
        referrerTagPrice = newPrice;
    }

    function isReferrer(uint256 tokenID) external view returns(uint256)
    {
        return NftToSecondaryProperties[tokenID].isReferrer;
    }

    function addReferrerTag(uint256 tokenID) external payable
    {
        require(Owners[tokenID] == msg.sender, "ART0");

        if (msg.value != referrerTagPrice)
        {
            MythicTreasures.useItem(msg.sender, 8);
        }
        
        require(NftToSecondaryProperties[tokenID].isReferrer == 0, "ART1");

        NftToSecondaryProperties[tokenID].isReferrer = 1;
        NftToProperties[tokenID].upgradesPrice += uint96(referrerTagPrice);

        emit OtherStateChange(tokenID, 1);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    event SellPlaced(uint256 indexed tokenID, uint256 price, uint256 buyingCost, address indexed owner);
    event Buy(uint256 indexed tokenID, uint256 price, uint256 marketplaceFee, address indexed from, address indexed to);
    event Shielded(uint256 indexed tokenID, uint256 shieldType, uint256 totalPrice, address indexed owner);
    event Steal(uint256 indexed tokenID, uint256 price, uint256 compensation, address indexed from, address indexed to);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Mint(uint256 indexed tokenID, uint256 price, address indexed to);
    event ModifiersChanged(uint256 indexed tokenID, uint32[8] mask, uint32[8] values);
    event SaroniteAdded(uint256 indexed tokenID, uint256 amount);
    event OtherStateChange(uint256 indexed tokenID, uint256 indexed info);

    modifier onlyAuthorized()
    {
        _onlyAuthorized();
        _;
    }

    function _onlyAuthorized() private view
    {
        require(More.isAuthorized(msg.sender) > 0, "onlyAuthorized0");
    }

    function setFees(uint256 newMarketplaceFee) external onlyAuthorized()
    {
        require(newMarketplaceFee >= 500 && newMarketplaceFee <= 10000, "SF0");

        marketplaceFee = newMarketplaceFee;
    }

    function setTotalSupply(uint64 newNonFreeLimit, uint64 newFreeLimit) external onlyAuthorized()
    {
        require(newNonFreeLimit + newFreeLimit <= supplyData.maxMintedLimit);
        supplyData.totalSupply = newNonFreeLimit + newFreeLimit;
        supplyData.maxFreeMints = newFreeLimit;
    }

    function setMintPrices(uint256[] calldata amounts, uint256[] calldata prices) external onlyAuthorized()
    {
        for (uint256 i = 0; i < amounts.length; ++i)
        {
            AmountToMintPrice[amounts[i]] = prices[i];
        }
    }

    function freeMint() external onlyHuman()
    {
        require(supplyData.totalFreeMints < supplyData.maxFreeMints, "FM0");

        MythicTreasures.useItem(msg.sender, 7);

        uint256 tokenID = _mint(msg.sender, 1);

        ++supplyData.totalFreeMints;

        emit Mint(tokenID, 0, msg.sender);
    }

    function mint(uint256 amount) external payable onlyHuman()
    {
        require(gasleft() >= 50000 + 220000 * amount, "M0");

        uint256 mintPrice = AmountToMintPrice[amount];

        require(mintPrice > 0 && msg.value == mintPrice * amount, "M1");

        for (uint i = 0; i < amount; ++i)
        {
            uint256 tokenID = _mint(msg.sender, 0);

            emit Mint(tokenID, mintPrice, msg.sender);
        }
    }

    function _updateModifiers(uint256 tokenID, uint32[8] memory mask, uint32[8] memory values) private
    {
        for (uint256 i = 0; i < 8; ++i)
        {
            if (mask[i] == 1)
            {
                NftToModifiers[tokenID][i] = values[i];
            }
        }

        emit ModifiersChanged(tokenID, mask, values);
    }

    function updateModifiers(uint256 tokenID, uint32[8] calldata mask, uint32[8] calldata values) external onlyAuthorized()
    {
        uint32[8] memory oldModifiers = NftToModifiers[tokenID];

        _updateModifiers(tokenID, mask, values);

        if (mask[0] + mask[1] + mask[3] + mask[4] + mask[5] + mask[7] > 0)
        {
            resetAfterStatsChange(Owners[tokenID], tokenID, oldModifiers, NftToModifiers[tokenID]);
        }
    }

    function setMaxBalance(uint256 newMaxBalance) external onlyAuthorized()
    {
        maxBalance = newMaxBalance;
    }

    function addOrChangeShieldConfig(uint256 shieldType, uint192 price, uint32 time, uint32 reshieldThreshold) external onlyAuthorized()
    {
        require(shieldType < 8 && price > 0 && time > 0 && reshieldThreshold > 0, "AOCGC0");

        ShieldTypeToProperties[shieldType] = ShieldProperties(time, reshieldThreshold, price);
    }

    function setPriceRate(uint256 newRate) external onlyAuthorized()
    {
        priceRate = newRate;
    }

    function setTradingFlags(uint256 newTransferFlag, uint256 newStealingFlag) external onlyAuthorized()
    {
        areTransfersEnabled = newTransferFlag;
        isStealingEnabled = newStealingFlag;
    }

    function getLegendaryShieldDiscount(address account) public view returns(uint256)
    {
        uint256 legendaryShieldDiscount = AccountToLegendaryShieldDiscount[account] / 4;
        if (legendaryShieldDiscount > 2500)
        {
            legendaryShieldDiscount = 2500;
        }

        return legendaryShieldDiscount;
    }

    function getShieldPrice(uint256 tokenID, uint256 shieldType, uint256 isRaw) public view returns(uint256)
    {
        uint256 basePrice = 10 ** 18 * ShieldTypeToProperties[shieldType].price / priceRate / 10000;

        if (isRaw == 1)
        {
            return basePrice;
        }
        
        return basePrice * (10000 - NftToModifiers[tokenID][6] - getLegendaryShieldDiscount(Owners[tokenID])) / 10000;
    }

    function shield(uint256 tokenID, uint256 shieldType) external payable onlyHuman()
    {
        require(Owners[tokenID] == msg.sender && shieldType <= 2, "HG0");
        require(NftToProperties[tokenID].lastStealTime + 86400 <= block.timestamp, "HG1");

        uint256 price = getShieldPrice(tokenID, shieldType, 0);

        require(price > 0, "HG2");

        if (msg.value == 0)
        {
            MythicTreasures.useItem(msg.sender, shieldType);
        }
        else
        {
            require(msg.value == price, "HG3");
        }

        if (NftToProperties[tokenID].shieldEndTime > block.timestamp)
        {
            require(NftToProperties[tokenID].shieldEndTime - block.timestamp <= ShieldTypeToProperties[shieldType].reshieldThreshold, "HG4");
        }

        _shield(tokenID, shieldType, price);
    }

    function _shield(uint256 tokenID, uint256 shieldType, uint256 price) private
    {
        uint32 shieldAdditionalTime = ShieldTypeToProperties[shieldType].time;

        if (NftToProperties[tokenID].shieldEndTime < block.timestamp)
        {
            NftToProperties[tokenID].shieldEndTime = uint32(block.timestamp + shieldAdditionalTime);
        }
        else
        {
            NftToProperties[tokenID].shieldEndTime += uint32(shieldAdditionalTime);
        }

        NftToProperties[tokenID].lastShieldType = uint32(shieldType);

        addSaronite(tokenID, 100 * shieldAdditionalTime / 86400);

        emit Shielded(tokenID, shieldType, price, Owners[tokenID]);
    }

    function getMarketplaceFee(address account) private view returns(uint256)
    {
        return marketplaceFee - MarketplaceDiscounts[account];
    }

    function sell(uint256 tokenID, uint96 price) external
    {
        require(Owners[tokenID] == msg.sender, "SELL0");

        NftToProperties[tokenID].marketOffer = price;

        (uint256 rawBuyPrice, ) = getBuyPrice(address(0), tokenID, 1, 0);

        emit SellPlaced(tokenID, price, rawBuyPrice, msg.sender);
    }

    function getBuyPrice(address account, uint256 tokenID, uint256 isRaw, uint256 isShieldingWithItem) public view returns(uint256, uint256)
    {
        uint256 marketFee = isRaw == 1 ? marketplaceFee : getMarketplaceFee(account);
        uint256 shieldPrice;
        if (isShieldingWithItem == 0 && NftToProperties[tokenID].rarity != 4)
        {
            shieldPrice = getShieldPrice(tokenID, 0, 1);
        }

        return (NftToProperties[tokenID].marketOffer * (10000 + marketFee) / 10000 + shieldPrice, shieldPrice);
    }

    function buy(uint256 tokenID, uint256 isShieldingWithItem) external payable onlyHuman()
    {
        uint96 basePrice = NftToProperties[tokenID].marketOffer;

        require(basePrice > 0 && isShieldingWithItem <= 1, "B0");

        (uint256 price, uint256 shieldPrice) = getBuyPrice(msg.sender, tokenID, 0, isShieldingWithItem);

        if (isShieldingWithItem == 1)
        {
            require(NftToProperties[tokenID].rarity != 4, "B1");
            MythicTreasures.useItem(msg.sender, 0);
        }
        
        require(msg.value == price, "B2");

        uint256 marketplaceFeeValue = price - basePrice;

        sendBNB(Owners[tokenID], basePrice);

        NftToProperties[tokenID].shieldEndTime = 1;
        _shield(tokenID, 1, shieldPrice);

        if (basePrice < getRawStealPrice(tokenID))
        {
            NftToProperties[tokenID].upgradesPrice = 0;
            NftToProperties[tokenID].stealAdditionalPrice = basePrice;
            NftToProperties[tokenID].isStealPriceCorrected = 1;
        }
        
        transferFrom(Owners[tokenID], msg.sender, tokenID);

        NftToProperties[tokenID].marketOffer = 0;

        processBNB();

        emit Buy(tokenID, price, marketplaceFeeValue, Owners[tokenID], msg.sender);
    }

    function getRawStealPrice(uint256 tokenID) private view returns(uint256)
    {
        if (NftToProperties[tokenID].isStealPriceCorrected == 1)
        {
            return NftToProperties[tokenID].upgradesPrice + NftToProperties[tokenID].stealAdditionalPrice;
        }

        return AmountToMintPrice[1] + NftToProperties[tokenID].upgradesPrice + NftToProperties[tokenID].stealAdditionalPrice;
    }

    function getStealPrice(uint256 tokenID, uint256 isShielding, address account) public view returns(uint256, uint256, uint256, uint256)
    {
        uint256 rawShieldPrice;
        if (isShielding == 1)
        {
            rawShieldPrice = getShieldPrice(tokenID, 0, 1);
        }

        uint256 currentStealPrice = getRawStealPrice(tokenID);

        uint256 realCurrentPrice;
        uint256 compensation;
        uint256 additionalPrice;

        if (NftToProperties[tokenID].lastStealType == 0 && NftToProperties[tokenID].lastStealTime > 0 && block.timestamp > NftToProperties[tokenID].lastStealTime + 86400 * 2)
        {
            realCurrentPrice = currentStealPrice * 110 / 100;
            compensation = realCurrentPrice * 105 / 100;
            additionalPrice = currentStealPrice * 10 / 100;
        }
        else
        {
            realCurrentPrice = currentStealPrice;
            compensation = realCurrentPrice * 105 / 100;
        }

        uint256 shieldPrice;
        if (isShielding > 0)
        {
            uint256 percentage = 600 > MarketplaceDiscounts[account] ? 600 - MarketplaceDiscounts[account] : 0;
            shieldPrice = realCurrentPrice * percentage / 10000 + rawShieldPrice;
            if (additionalPrice > 0)
            {
                additionalPrice += realCurrentPrice * 10 / 100;
            }
            else
            {
                additionalPrice = currentStealPrice * 10 / 100;
            }
        }

        uint256 stealPrice = realCurrentPrice * 110 / 100 + shieldPrice;

        return (stealPrice, additionalPrice, shieldPrice, compensation);
    }

    function steal(uint256 tokenID, uint256 isShielding) external payable onlyHuman()
    {
        Properties storage _properties = NftToProperties[tokenID];

        require(isStealingEnabled == 1 && isShielding <= 2, "S0");
        require(_properties.shieldEndTime < block.timestamp, "S1");

        (uint256 stealPrice, uint256 additionalPrice, uint256 shieldPrice, uint256 compensation) = getStealPrice(tokenID, isShielding, msg.sender);

        if (isShielding == 2)
        {
            MythicTreasures.useItem(msg.sender, 0);
        }

        require(msg.value == stealPrice, "S2");

        if (compensation > 0)
        {
            sendBNB(Owners[tokenID], compensation);
        }

        _properties.stealAdditionalPrice += uint96(additionalPrice);
        _properties.lastStealTime = uint32(block.timestamp);
        
        transferFrom(Owners[tokenID], msg.sender, tokenID);

        if (isShielding > 0)
        {
            _properties.lastStealType = 1;
            _shield(tokenID, 0, shieldPrice);
        }
        else
        {
            _properties.lastStealType = 0;
        }

        _properties.marketOffer = 0;

        processBNB();

        emit Steal(tokenID, stealPrice, compensation, Owners[tokenID], msg.sender);
    }

    function processBNB() public
    {
        uint256 balance = address(this).balance;
        if (nextTokenID < 100)
        {
            Agent.marketplaceDelegate{value: balance}(0, balance, 0);
        }
        else
        {
            Agent.marketplaceDelegate{value: balance}(balance / 4, balance / 2, balance / 4);
        }
    }

    function sendBNB(address to, uint256 amount) private returns(bool)
    {
        (bool success, ) = to.call{gas: 5000, value: amount}('');

        return success;
    }

    function autoCompound() public
    {
        uint256 currentIndex = currentCompoundingIndex;
        uint256 length = Legendaries.length;

        if (length < 1)
        {
            return;
        }

        unchecked
        {
            uint256 tokenID = Legendaries[currentIndex];
            uint256 addingSaronite = 100 * (block.timestamp - NftToSecondaryProperties[tokenID].lastSaroniteCompoundTime) / 86400;

            if (addingSaronite > 0)
            {
                addSaronite(tokenID, addingSaronite);
                NftToSecondaryProperties[tokenID].lastSaroniteCompoundTime = uint32(block.timestamp);
            }

            ++currentIndex;

            if (currentIndex == length)
            {
                currentIndex = 0;
            }
        }

        currentCompoundingIndex = currentIndex;
    }

    function getLegendaries() external view returns(uint256[] memory)
    {
        return Legendaries;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    function upgradeToLegendary(uint256 tokenID) external
    {
        require(Owners[tokenID] == msg.sender, "UTL0");
        require(NftToProperties[tokenID].rarity == 3, "UTL1");

        MythicTreasures.useItem(msg.sender, 6);

        --RarityToAmount[NftToProperties[tokenID].rarity];
        ++RarityToAmount[4];

        NftToProperties[tokenID].rarity = 4;

        NftToSecondaryProperties[tokenID].lastSaroniteCompoundTime = uint32(block.timestamp);

        AccountToLegendaryShieldDiscount[msg.sender] += NftToModifiers[tokenID][6];
        Legendaries.push(tokenID);

        emit OtherStateChange(tokenID, 0);
    }

    function useAmeliorateRune(uint256 tokenID, uint32 runeType) external
    {
        require(Owners[tokenID] == msg.sender, "UA0");
        require(runeType <= 1, "UA1");

        MythicTreasures.useItem(msg.sender, runeType + 4);

        require(gasleft() >= 75000);
        createRandomRequest(1, uint32(tokenID), runeType, 0);
    }

    function ameliorate(uint256 randomNumber, uint256 tokenID, uint256 runeType) private
    {
        uint32[8] memory modifiers = NftToModifiers[tokenID];

        uint256 isAddingNewStat = 1;
        if (runeType == 0)
        {
            ++NftToSecondaryProperties[tokenID].lesserUpgrades;

            if (NftToSecondaryProperties[tokenID].lesserUpgrades > 2 ||
                (modifiers[3] > 0 && modifiers[4] > 0 && modifiers[5] > 0 && modifiers[6] > 0))
            {
                isAddingNewStat = 0;
            }
            
            if (NftToSecondaryProperties[tokenID].lesserUpgrades < 3)
            {
                NftToProperties[tokenID].upgradesPrice += uint96(10 ** 18 / 4);
            }
        }
        else if (runeType == 1)
        {
            ++NftToSecondaryProperties[tokenID].greaterUpgrades;

            if (NftToSecondaryProperties[tokenID].greaterUpgrades > 1 ||
                (modifiers[0] > 0 && modifiers[1] > 0 && modifiers[2] > 0))
            {
                isAddingNewStat = 0;
            }
            
            if (NftToSecondaryProperties[tokenID].greaterUpgrades < 2)
            {
                NftToProperties[tokenID].upgradesPrice += uint96(10 ** 18 / 2);
            }
        }

        (uint256 index, uint32 value) = Randomizer.getUpgradeValue(randomNumber, modifiers, runeType, isAddingNewStat);

        if (isAddingNewStat == 1 && runeType == 1)
        {
            ++NftToProperties[tokenID].rarity;
            --RarityToAmount[NftToProperties[tokenID].rarity - 1];
            ++RarityToAmount[NftToProperties[tokenID].rarity];
        }

        uint32 oldValue = modifiers[index];
        NftToModifiers[tokenID][index] = value;

        if (index == 1)
        {
            if (oldValue < value)
            {
                Saronite.addSaronitePerDay(Owners[tokenID], value - oldValue);
            }
            else
            {
                Saronite.removeSaronitePerDay(Owners[tokenID], oldValue - value);
            }
        }
        else
        {
            resetAfterStatsChange(Owners[tokenID], tokenID, modifiers, NftToModifiers[tokenID]);
        }

        emit Randomizer.Divine(uint32(tokenID), uint32(index), uint32(runeType + 1), oldValue, value);
        
        if (isAddingNewStat == 0)
        {
            _shield(tokenID, runeType, 0);
        }
    }

    function useDivineRune(uint256 tokenID, uint256 amount) external
    {
        require(Owners[tokenID] == msg.sender, "UDR0");
        require(amount <= 100, "UDR1");

        MythicTreasures.useItems(msg.sender, 3, amount);

        require(gasleft() >= 75000);
        createRandomRequest(2, uint32(tokenID), uint32(amount), 0);
    }

    function divine(uint256 randomNumber, uint32 tokenID, uint32 amount) private
    {
        uint32[8] memory modifiers = NftToModifiers[tokenID];

        NftToModifiers[tokenID] = Randomizer.divine(randomNumber, modifiers, tokenID, amount);
        ++NftToSecondaryProperties[tokenID].divineUsages;

        resetAfterStatsChange(Owners[tokenID], tokenID, modifiers, NftToModifiers[tokenID]);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    function totalSupply() external view returns(uint256)
    {
        return supplyData.totalSupply;
    }
}