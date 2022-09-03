// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract SharpeLib{
    uint256[] x_p;
    uint256[] a;
    uint256[] b;
    using SafeMath for int256;
    using SafeMath for uint256;
    using SafeMath for uint112;

    
    event lognumber(
        int256 number
    );
    constructor(){
        x_p = [uint256(0), uint256(15979098296553168), uint256(31995177364263260), uint256(48011255319362456), uint256(64027332151788520), uint256(80043407851430688), uint256(96059482408105696), uint256(112075555811597424), uint256(128091628051619168), uint256(144107699117961808), uint256(160123769000230208), uint256(176139837688016448), uint256(192155905170986720), uint256(208171971438671616), uint256(224770449279324192), uint256(244185369476411264), uint256(264205483347648000), uint256(284225594004743072), uint256(304245701414253184), uint256(324265805542786112), uint256(344285906356982592), uint256(364306003823902016), uint256(384326097910824128), uint256(404939601655622144), uint256(428342547799113984), uint256(452366682937750592), uint256(476390810580774720), uint256(500414930647304896), uint256(524439043057301056), uint256(548463147730543296), uint256(573087490703148480), uint256(600482560497560064), uint256(628510677340723328), uint256(656538778986647040), uint256(685171401007116544), uint256(716561000115112448), uint256(748593068034455936), uint256(780625108611539712), uint256(813264302701927680), uint256(848649918703852672), uint256(884685839422515712), uint256(921330387017320576), uint256(960712981755959808), uint256(1001362006014577792), uint256(1044742258706311040), uint256(1089394987597108352), uint256(1136773252380037120), uint256(1185428978916129536), uint256(1237413468920992768), uint256(1292788380923622144), uint256(1349448453772847104), uint256(1409426617574694144), uint256(1474004753859085312), uint256(1545279078492631296), uint256(1621839149809075200), uint256(1705678980091305728), uint256(1797493920936086272), uint256(1898439751141199616), uint256(2013836380281748224), uint256(2146209923195500800), uint256(2302381201828452096), uint256(2494501711456146432), uint256(2746994583230855168), uint256(3127126613686401024), uint256(4000000000000000000)];
        a = [uint256(2463157317631959040), uint256(2360367704815384576), uint256(2267642450787375360), uint256(2178630991430915328), uint256(2093178760811027968), uint256(2011137951573299968), uint256(1932367203897805824), uint256(1856731309472151040), uint256(1784100929728155392), uint256(1714352327618846208), uint256(1647367112265348352), uint256(1583031995810794496), uint256(1521238561892656640), uint256(1461883045133216000), uint256(1397937012322922752), uint256(1330148795726751744), uint256(1265672436842904576), uint256(1204341313712417280), uint256(1145997575065904128), uint256(1090491654642213248), uint256(1037681813742187520), uint256(987433710293152896), uint256(939619992830948352), uint256(889721137938853632), uint256(838267923113598464), uint256(789780182952243328), uint256(744083609278313856), uint256(701014555187548672), uint256(660419349853361536), uint256(622153659569768192), uint256(583192304331420416), uint256(543903997701853952), uint256(507226663136019712), uint256(472985161569565824), uint256(438834211088547008), uint256(405052120079148224), uint256(373818432824708928), uint256(344940581242606464), uint256(316655596675571392), uint256(289152522487920512), uint256(263973578016067360), uint256(239714576863577504), uint256(216497712581647680), uint256(194469098107870624), uint256(173698916859909952), uint256(154277226880988864), uint256(136226049610349536), uint256(119584616682834496), uint256(103793918043677552), uint256(89515813354994880), uint256(76709437290137152), uint256(64946455634591160), uint256(54017275270618264), uint256(44098604332100920), uint256(35319442125697148), uint256(27569211432791672), uint256(20946470247897496), uint256(15292446856691546), uint256(10569947309685894), uint256(6807968137887293), uint256(3935755016872061), uint256(1905247799007602), uint256(647874538319934), uint256(58814930390776)];
        b = [uint256(0), uint256(1642485327060683), uint256(4609246275833212), uint256(8882798177345275), uint256(14354076530356030), uint256(20920902484632920), uint256(28487579735240364), uint256(36964514642302952), uint256(46267858229718680), uint256(56319168796385456), uint256(67045093946079600), uint256(78377070916024352), uint256(90251044144187680), uint256(102607199083761584), uint256(116980377608161600), uint256(133533268323844608), uint256(150568275887247840), uint256(168000150789988640), uint256(185750982477626880), uint256(203749654476208832), uint256(221931338415042240), uint256(240237024182290080), uint256(258613083641149760), uint256(278819106064226272), uint256(300858707194931264), uint256(322792945374871040), uint256(344562373148158336), uint256(366114770864033664), uint256(387404481502209408), uint256(408391802445231040), uint256(430720067753169728), uint256(454312010715705088), uint256(477364107106729856), uint256(499844980735838912), uint256(523244235322643200), uint256(547451164242317760), uint256(570832486010147136), uint256(593375262037893760), uint256(616378430288738432), uint256(639718911962194304), uint256(661994367588048640), uint256(684344922508525696), uint256(706649665419841920), uint256(728708282999025152), uint256(750407769069758976), uint256(771565660783460608), uint256(792085756278693888), uint256(811812993121659392), uint256(831352616301424512), uint256(849811184144564608), uint256(867092728523720448), uint256(883671787971089792), uint256(899781451783369216), uint256(915108566471112960), uint256(929346955439982848), uint256(942566361023730176), uint256(954470698043510528), uint256(965204520803257984), uint256(974714862196882048), uint256(982788859226251008), uint256(989401788723721472), uint256(994466892453808512), uint256(997920889990016768), uint256(999762953967019776)];
    
    }
    function SharpeToMDF(int256 sharpe) public view returns(int256)
    {
        uint256 x = uint256(sharpe);
        if(sharpe <= 0)
        {
            return 0;
        }
        else if(x >= x_p[64])
        {
            return int256(10 ** 18);
        }
        uint256 finalIdx = 66;
        uint256 low = 0;
        uint256 high = 64;
        while (low <= high)
            {
                uint middle = (low + high) / 2;
                if (x > x_p[middle] && x <= x_p[middle + 1])
                {
                    finalIdx = middle;
                    break;
                }
                else if (x > x_p[middle + 1])
                {
                    low = middle + 1;
                }
                else if (x <= x_p[middle])
                {
                    high = middle - 1;
                }
            }

        return int256(x * a[finalIdx] / 10 ** 18 + b[finalIdx]);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}