/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

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

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

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

contract OSCdividend is Ownable
{
    using SafeMath for uint256;
    mapping(address => uint256) public addressToIndexWhiteList;
    uint256 public whiteListLength;
    constructor() {
        for (uint i = 0; i < _whiteRewardKeys.length; i++) {
            addressToIndexWhiteList[_whiteRewardKeys[i]] = i;
            whiteListLength++;
        }
        whiteListLength--;
    }

    address[] public _whiteRewardKeys=[
        address(0),
        0x909fE531F85ae2fF32c15B40038C971658bC49b2,
        0x8E2a6eD263d53Bc4b85A50D20C4E05F43135D56e,
        0x5792158f2736F261B1e99fa5b791FC4C36a84619,
        0xA273B413D7fb33b04b28e045b3A287cffc854335,
        0x72aa32d7854Bab2786fd1cD70F6A95f8dFe0f1de,
        0x6863619A0c73bBee60dF1d0D5818cc944F14eE0F,
        0xa4D95246b924971B3Cd4e8c219F3573FfeD79652,
        0xAB7Ec66BeCa30f31106E8EE6Ad7178Dc1e66E56E,
        0x72AfF08D0cE1a862e9a4515E6d7c4321582751E0,
        0xd09e63cE7A4eE52cfb6ceE655f4C9F602AFfd6eA,
        0x633c842FF541E69D29604C9B17aC61987977AA36,
        0x5Cab309b30F52Df4B38346f9479998900DBfD4a2,
        0xcc6DFF46431daC094b440Ed8F7014AD19Fe5a350,
        0x6Ed16D9537EFdBc54F27Cb388fbD41444A64456C,
        0x32D596A28A57eAaa198285a2FA1C2907dd27D0bf,
        0xB5FB0303ccF80d0f1ef2f87115dDFCDa87EC5A5D,
        0xd640b72ec7DEFF452f495F981e8b7DADD07F2459,
        0x5C2164297379760fa2A64D42ac64b8b8F3E82379,
        0xB431203fe1318a3a0BcCED533C28bA1ab546B397,
        0x0bcE5584E8EBd9c5338D880e77AAB345eD0AD489,
        0x3755bf4ca76d6E7F187BECEcB4A6B3A753104A11,
        0xb09e9BCbb78Ca2179293FD6DB27ABB8AF9a601c3,
        0x77cB9bC3D0Ced93D035653ea9506D3FeDCD78de6,
        0x7012a6Cd5cAbE3c4C9E5Dd69551346837Df736Be,
        0x11eF5e204D5Af4Ac52D4c73F93fbCe1B90a5C3e2,
        0xc491c2397efEd345c031c0c250F7Fe2CA9C66cbB,
        0x987Eb13d4Fb9614dE3fd8aC019bfe048CeEdA039,
        0x0199148A8Abc1770E0B27F6d08153de00607B0a6,
        0x10517939fD20E193E3b8c31F3B1f1EE2FC783243,
        0xF16732818dB36238cF8E56757139C3cBC64a9286,
        0xE96af1E66ceE0F22813367ab1aEd9986DB2ff21d,
        0xb3Ef55226C653c7A3Fe568F427d0C825Bf041852,
        0x2826657102Ba0D639a35788a445172D5678d64A2,
        0x7c2b8981f119b2c3e084002eE0D3d907Ef7A7911,
        0xED33296E617EE76C058D0B6D2583692b27169668,
        0x249008d3C48659ABa94108DB5e979167b1Ebcfc6,
        0x427a870A25108e6cd9FA239CeA2F87b1C11B4a01,
        0xf15ebA3D626E1bf767A51E8b7548F8d5F317A76C,
        0xBddfCb640D5208255025D99a86a743280a23D835,
        0x2d56BF899b38A805405145d23bCa11246420bd8A,
        0x6777CF63A0e7E7aCb071fF963DefB1948a8bbdf7,
        0x517514bd3Daa7C77078C433C5Ae2A49883751C33,
        0xd9280BE076cd30640134D23f168B4782106478c9,
        0x70700c2c77e8633aF3c4eAEb2bA87CAdafC54dC6,
        0x7a2Fa6d28371D7a5A687F01a41d24Ca05a492F2E,
        0xb6Fda61C39F89e5C4B9E318eE68b39dc1bf24EF8,
        0x44b15185c179BcD9836D09Ab524e014106b0f042,
        0x4D4D4d91A78A4bEDb55dAD3043A9cfd253aCfAfD,
        0xaF15b124cF81dD70D53585db93C751B7F7eF2c86,
        0x466c079C9E16D3205863B36581BC58325A4d9355,
        0x5De36847Fdd19640761B4DD662ee78FEb3Baa3d3,
        0xEb431d936352F86d91d75084637def4F89fd66da,
        0xFDcb725608033e514D9B65e7ffF8bF711B08d96C,
        0x3e1AD9E4A8dC600f5090125869Ee34A9cf92440E,
        0x4D983DaF28A98a6196f7b3E797788Bd6B8865607,
        0xCad453cca54D122218d7E73caa4eE7aeed6D4080,
        0x89254cFd0Ce084e6bb254C2A6abBF4B26E3bD8BE,
        0x383150f546DeC822449F7833A158CD777A408F25,
        0xc46454c0B106e511D357E25445b1C22d8530DeD2,
        0x99C8c654388FFdF0F038Ec56612D0E5E0A3ec5Aa,
        0xA31f380081B107fA665dBFbF4fbbf8198B3d23d2,
        0x12110D28D392ba666Af8Fa013F1c46979Dc8957D,
        0x657e8A5D569c215c26768f53e2550D15122887Ed,
        0x57a9f55F4b7d627F99A6486d3Ffb1ce1D70d5947,
        0x449aCF9e68B2A16a0e3277926613a506F3985257,
        0xC4bA0e37cA68fc703eD63afAB90cE7f6EAf4d336,
        0x1566C44B7e44638d385778C8c52A2f5b4C31F8AF,
        0x3f2282Bb2a03a12Fcb674557de4323EAe32aB3eF,
        0xA9A90606463Ce769B9ae13Fbbd2BcDc492dfddF5,
        0x75823A2300f89b2cC90879E4740D8Af7882Bc8b9,
        0x4635a3fB084e28a03272a5Ce7B9c9Bf41B4F139d,
        0xa995279eD521E3F5F9A178681f1DdFf71134e5BC,
        0xdcA1C49FF6f50ACd36D67bEf419e6eE91c92BE3B,
        0x9f730d0fC48eA13A04b6cAF16cE4B74fcC002574,
        0xA3c6f0C34c83Dd0CD297D90737838900e168573d,
        0x67171c166f9a8AD3330AB901fcEA4edE1f7Ffc6f,
        0x4b10438fdE0A7C4b386428c295cb29B85a277495,
        0x62B2bCe1e1f2A4346395c8b3930A7f2953Fdb705,
        0x0b3991287dAF0ed61643b3A627EA147C716669D3,
        0x2171aC55078F70279DE7C186c806e652CAE24780,
        0xf742a57EedDc16eb41c850F57a9B31286D5600FC,
        0x79bb2C025A0FbcB2f7AAdDcc50e35b56b6D055D4,
        0x7b87b84426a683f332E03de63a6df5506729661E,
        0x09C4323cE5e79c07e054502bafd5784A34208e4C,
        0x9b7D28DCB90e7652b048138437e8f374C7Cac8bD,
        0x9c3A45f6D40C8ED1520a2571BC4E4FD808cb9615,
        0x552d4eE4b8b67db6C19C1b2750d8cF6CedC5622A,
        0xb7422f24E84eD2048330FEc2C29f5c279588b0c2,
        0xEB9456904ee85d2b467986722602Fe37b1f3eC74,
        0x9C02F9f96dceCBe7E30C55Cc0E75Afb8C3fA10C6,
        0xDf82dEd48BdBD0989e266E624FCAE659518649d9,
        0x84030e3D8D17C124D1836d7de6b4A46309738444,
        0xB36cc90F272f9a2f3edB0DB5EE87CBcC902c3Efb,
        0x2D65C87D56C282bf5b6CA04aa22c8b1AC96f611b,
        0xDE665A89e9fAB35d644c1Ba051F9e81fB5B23601,
        0x9a87826F069C3D6c052B04Ae839b1D9D589e2d26,
        0x5e95Eb76Bc88597d67c8551ce6974993F0FA7989,
        0x9a8C48D865b8A4b969C098f06798CF4b33D38ef0,
        0x454357B65F416EAe8bf151e25B2A68cECd0DB460,
        0x1bAB022fbeD810b59F7b8D407AfdedD7a48D5682,
        0xf95766DfF78fd43a53c8Ad9Aa03e37625DaB2B22,
        0x28473BbCE324727E9bf5d1cf9f0cdF2f1Bb33A64,
        0x00B74975e73cAe3948e59a572C401ebd3BE76855,
        0xDF93d9D50C727e4Ee5Bc5092d0b49F07372Cd8A9,
        0x5aE21E0d5171B8D0D2aa328Fa034413825E3e7a9,
        0xf8a94Bc59c663eb8809F0AEA8f68DD4f4315DC41,
        0x0d402F421BAa1104320F2054074DEFf1De1Bd1Ba,
        0xBdA65A578699Df0874AC38Ac6223d678d48DE1d8,
        0x46E761E24FEB68a89a1De562CC1669B89D683cE0,
        0x10967cC5EC8D6D424Ee727Bf40615522BB8a75f6,
        0x35C111D1c3DB72DA018C29f6777039D741e23283,
        0xd11c8b3cA59c8153E519505E8203735C64497461,
        0x4C122F73154632508650c658cF5a4c1d2c348A76,
        0xE7524413D6696b9fD3C0fcE2DE4F7f0752043ea4,
        0xd9280BE076cd30640134D23f168B4782106478c9,
        0x20Bf1DA2DE2905DB2721B05768eB25C5c70261bc,
        0x489576c20A8Bc8F01d32dD14c49c44C5c60959a6,
        0x4D9C91F7ED98c447626EA957A3Df4852C79F2CFe,
        0x49cCeCeCAa06337Cbb6FEb2989B19c00D9cd7124,
        0x8c2588E16C01273967FA6013BE51a186E780a590,
        0x2bE22E390ea14ea1C31A5F9d5a9265042C81F7Aa,
        0x5ef6b2Fa02088ee83053D3335c27b2160f4eC835,
        0xE548AF9ab452f14489254CD041ef232d7B80eD1D,
        0xF567a7d96F32C72f0410a9Ddb9aA9EE2964A70AB,
        0x4909a5975567b00994346a91c7De750DDe6CC69e,
        0x28Aeb2b3f131f697AE993D0D6055580eb28E97d7,
        0x5eDeFf2F81f3Be07516B97977014461F0AeC75BF,
        0xC576FF1FB03C6BF5D4B14e3964eee894344A3fC8,
        0x41dEC8eCa98a38C0fFDb3f54cAc8464e7C2d6788,
        0x85Dc19b9Ef85EA899c7363Ca8520d0143380A8a7,
        0x4451798fAC6B5A95ADD2D25f8B16A3718d0cD520,
        0x825b92CD3ba3d63C98dD30b951785c6288b51A23,
        0x59fa97f4AF07450481a6619F5cE8f01141532c87,
        0x9A914A8322988980BD16c2dfB8EbE6d186970dfB,
        0x169D5F8EF643c914b0700913c9e545d646d5434C,
        0xa9B39bfd4f19077e87A164CA09cb1DFB1cd95eF3,
        0xEFd9F172d0f8Aa1B72D4fF3e3168EF6E003404Ca,
        0xf7Cc3D5F4c33e745D18eDC490b433b3162f3EbcB,
        0x144d6d91FdC70D21BE1967FC9e9140d6672DAc41,
        0x5906f5B28467159B8B4F379BD9f74e63F0A997fb,
        0xc7B82A32b2d1465ED7ce8e0ec35C3117EeE36Ea8,
        0xf532E9560d9eC21166f17Ab3d711E79bb63a329A,
        0xe704b0A6fDD4e68c8eF73249e202Ad2eCA7100c1,
        0xA4cE666Ad98103EDB038D722329041b49403B277,
        0x1F13CC9ce40dd4D0996255eDAB1a7Ba61CD1A580,
        0x0637F7389d3264FaFC4052Ff7e630DCb9f8847Fa,
        0x4D5596B55ca15237AEA852B92347925D66D6667f,
        0x3c7B610fB8F3682d2dD7D2Ed28A99F22988203B9,
        0x7Bd96d9D6Da89054B3093FBAD0DeD96138370ca0,
        0xA6Cd143a82822509c6F7973DB270Fb50cd897125,
        0x54C47FF3a695596b3E8E32C250BB605B4B14019b,
        0xa6bd179FF3b2FcB94215cc8ad869683961d896B4,
        0x63E75125fb73b832BB86C1529153e62aE7cc6C0e,
        0x49542C325FCfA7d346ef1760E082CB49Fc86c7f3,
        0x4a3EF43fa737c71D99D7d9849f784DBDCA0Ac6aB,
        0xeEaC6f738A490E23cf594BC73a6a8cF21B278D78,
        0x50714eFe748fdA48B3375Db9C61128C1631929c5,
        0x72ebaE6B11b03D4F7EB6042E036a38176cC96de0,
        0xCA90C73Fc92920dBd00baFd3567Aab169793bfcD,
        0x53F119367abC7bb5293EE3e824C4dA577BADD5fF,
        0x3395C8aE3E86AE7D1C97Ff83Af0331A7913bB195,
        0xFae61F6b09d4Ff608e95E177069c917734D29bBc,
        0x62CD07194928720C2a3884A3FBe89EB5671b5e5d,
        0x9f4377761a0c84c96Eb1B2A082CE5ED36d3a5E73,
        0x321cE9Fed555f2e9B83382Aae533f4FbDc7E7bf7,
        0xC6a0AC080999ad14E7B41E41534aC43A1e420A1B,
        0x95205DA155A9302634C71444C8d6fadC30a292fa,
        0x4D80BC3e2195E0a44c5643914e10aC0F700c4260,
        0xf78a958B7549f2b5C8C10F4A62D4a29e91251a0c,
        0xa265e45f5089D6BBE0ab8DB6b039f1E3650ea8dC,
        0x290e6d3D222795CC003Ca07d5EC0e7b0652a2487,
        0x102842F20377f3609c90E2d00F0e8dEA5A6D342E,
        0x85952dD0bB4939d9f0cb10Cc31fE20eBE38a3145,
        0x2e5BBEBaBa37dB8A1B60E9f5D88A663c0FEB586C,
        0x8316Ec46064c57498A1F033Ebb8C494657983E08,
        0x37ab68363E0AA5e481912DF9f316Ec526f015014,
        0x43672E877a2E07CD02716Bf6f5A5afaefE672f21,
        0x506550ce7C5a7Af02d5A9541BC5A593d652B1525,
        0xaEEC1Db32BD6C5D8b0fcD81aeDe054DA1D6bf372,
        0xcb6ee3D14bE8813a802433b881EC7a55653ED10C,
        0x35C111D1c3DB72DA018C29f6777039D741e23283,
        0xD1b3609Eb9411dF3e2491bd202b517eEB10EA8b4,
        0x51D6a5246D37626b829fCfE618aB84a012693934,
        0x8766B8B540E90cc7BBB7aa8bB1D7D64522fB45A3,
        0xdd2d1E9AF7c57d30eC76bBB752DAd49Cb4dDFb9F,
        0x4ec8A64C9817E60c18307113F74CFBbCE98f8955,
        0x10e3B40a98C45bf5B0f8Bb85a15a746339da74d0,
        0xe00434eC6de5cf02300E3E6FE5a2f06b2Db4a2a3,
        0xcbC4287E8e4Bd426b75dCaE6D72Ddc34EdB5c17B,
        0xaC36AD8e8415fdfad90B13f66935D7A1aC44Bc28,
        0xC44CB5F4D5b20a732CeB6dD795260C4C0C34d05e,
        0xe5daefDa39799d5827650dac67a99B1736c80a92,
        0x153b4385c0474803C9bA77F23ac2955CD35B6C1B,
        0xFBFA54BbDcF968A3966AC3BB52b133cC9De2E5DC,
        0x2eA41a15f1706C89159361cF31cF3B6BFAcC708C,
        0x18E4B0e4cDcC99C40bf7418d25c998c20a8026f0,
        0x93FB927473938bf03462C858C27CeEEf44778BDd,
        0x1f311187f4d0D270804ef33682fE08A946bfb539,
        0xAd39036A79281E5D35b895f44bDdc4a883618cd6,
        0x0668bA0C3469966c92494aEA7368499D6b0d56CA,
        0xDBdc8b9544326304B354d44De9c2CBD6F29Ce65a,
        0xDa2677BFA8164581bB092B709B4707De037DC5F8,
        0x1d86FF80dE4454B1397151573D4905a5Ce193743,
        0x6171cF46FAA6e7547Dfb000C8cd7Da0874aadAA3,
        0xdE8e1520bda88ad7DF4730d9b022251950115B66,
        0x8d0f6F3Fe8AcC1693a9EF4e5A1B4A91DaBA92604,
        0xD7155F31BAE35e11BeF54a521EE0656BD91B80cd,
        0x4598b8D720Ff6AaD8D3a4fcfe0561B2E0f4Ed6b5,
        0x0EA5209078391f10e64Af06CcFB751648903Ff10,
        0x2ef8483bBF3547B9B4A112e88cE9380e59B5f583,
        0x853471a4c06785D8D33a59516f584060a69ccfC6,
        0x25717E92Ea22aC8cd58fA0E20997901108168AD3,
        0x873D628BAaA4606426F02eBF8D1C9D14228F6DCF,
        0x1A5cb5b7D385C069264fFbEE4fdcC9314C23Fa4f,
        0xF8c97069a9a8Ce1092d3fB214fcbf28a7AF6cb23,
        0xdE1e23DE2146bEaA7733656866d682701a76e201,
        0xeeC48F55A6165534043bCE7d3aB5bB6990b02Cd9,
        0x45Be86593500DE4D255E5DB0EF5252D95433831D,
        0xBa0A818FCaf7a8500806b9c04dbFAFc7DF4e4df5,
        0xF5FeC95C75a4147234fC8Cd73AfAAa3e3776C5E4,
        0xa2565E24d6EFeF0FB68448B29AAEa61d2140D2B5,
        0xB2210323ebA058408EC862532c64f617Fe1F17D2,
        0x35dc7Ec5A26F2B532652CA6ce94E2EC8442b13cE,
        0xABA0AE0172C223375c2B8fFE1477668B689Ac7b0,
        0xd0085A6Ae7b8889471377192A8fF982ECe126ec0,
        0x6Aa7FdCDB90f1Fdd5A1f1140C907d86c3463df00,
        0xbeB950286415e279CAC5CdD1951ce1af58bd4273,
        0x15Cb187FCcb6636ED59E33ADbb6E85359815E234,
        0x38212C4505Ed312B3dD2107cF36b8405fC222baa,
        0xDBdAA370e1953AA02b4Fb58Eb21D4401396Fa33E,
        0x599101d8C0d5a0E6cA7500Fc1F4474A98a26B361,
        0xDbD51F6999F7d7934c708008d06023919783Ac22,
        0xF4Ffd788b3309Ada86A0Bf4cC981E010301158F1,
        0xDA375c9AD147cEe1E39Db495d0150E46F4f9f5d0,
        0x2455D9CAC3951BD49543BF81dB0C82003E225E74,
        0xc69159e9728d732C4fD3d114Bbce19DE6beC1240,
        0xf4a21325e64E3524f3Bd9d5597E09ED8524f3107,
        0x161359b1039EA20BD8b70e570696578Bde019945,
        0xE92D05E866F4ADf025FaF43760a970093331226A,
        0x8b3A7844E51F6A87D4D6d6D79f5aa4409746aFf1,
        0xED3F30Ac044D9cF9e566Dc52Dd261c0A9793E50E,
        0x13Afdff52c31AA47Ae5B214278E76ef72c543145,
        0x7F4ee1e84aE9323D7Da729b954aeE04A1AF6FD8d,
        0x09390D8fd87e3609C56a9b627e7F74Cb74696d80,
        0xB7bc76fE9Bf7f98db94CbB6226ef8604CbABE7A0,
        0xdE93EbB79B74b532f7D52A2a020B8236ceD84b55,
        0xff118a56Db6CF35b87B32E2DA43a99B30429f5f8,
        0x0Ca614AbABD3FaBF78Aaa9F2c9fffc955A9000e7,
        0x0519A2767F0B0Ce6432b35d37ecB102852E6FC2e,
        0x3E5FB8D281B5131F68979Ac6A303ACdC73C166AF,
        0xF79022BfddDba7bF8d9c9Fc082d42E090421D00c,
        0x6Bb03eb45a1a9F1CD2aF0864F008806076fB3bCc,
        0xff0ae6ad7785fC59F65B75632012FBD0d3176A33,
        0xC3FaC01F49a08C0B29b00605CE6F48bBF1B1899f,
        0x081f68A7292Db7261e1e4f895E303DAB00A5110A,
        0x15775eBddB9390F09ef7B6C20f93B3B4e28A46af,
        0x17Ff4A70267B57dFB67072d3B06334fA6a9c558D,
        0x25b05A631ce9C69200c51CD03F43c4324FBEe532,
        0x24230aC9Eb3B289822E10dc0F69b3b3Ad072b51F,
        0xE82f8c2c152fd3B1b7362b263a0cd01a2b0d146A,
        0x6A36bAC8781f175A420F4cC8E369C5e9fE7a6FA6,
        0xc14FF56B6f51f6e01ab32850Ad91cA38f325a44A,
        0x4c2bA81A20Af808dd3FEbc8773b394E4DAEa5932,
        0x2F93e9A800C52FE98b1Ffa48eE6105AEEa0aCF6d,
        0xbEC3c04fccE31dB94AE91ceC6e70eB8b31003270,
        0xcCCec9f1438490EC1bCf8556F5d049573d7f520a,
        0xF6B53b20A103BE9e5694624cd56a554b708105F5,
        0xBBc541c36a78C9ee12fD545fc27fD1569e49C56D,
        0xBc6aeF471148d4d52020975887eCeBdf7Bf1224e,
        0x75B099c36E2471C5aDF2eEfc669Ab69b2309a50F,
        0x0BD26aB91294556c98924F076f3F2584661050cB,
        0x154827E4B117F71163C3bB354f8Fea7A6052DF6A,
        0x7F4F3755A62e3Bad3F1AfC0655511023BacbFD2A,
        0x7F61b88D7821C3D2d49956b7ebd99110F818FE04,
        0x836b62EB702e850F0Fc536dBADef5c10321756C1,
        0xD33fEf457D9c26cB6b87b44bdc6938e46C35EF91,
        0x7510E71155F30dcEAe6DB8E14482aB6bD7aC4a3f,
        0x37e6ac56676D80C39DEF9aAD20e2851CE57eec27,
        0x09adB3264fE40f59d146d2eC807f59f50EefB179,
        0x3fe85220CD7847e25934481106A84Ab615aE58E1,
        0x806d4B9660A8B5A1050919d89cCbD9a4F272a08D,
        0xd82a73F29ab96e49070B4FA67B30C02DAB48CFe2,
        0x9d49A929c0b65bCf804f4aA2B4E70A422F4EB9a4,
        0x2b85cfe2D9E23c23b0b8745E76300Bc7439D9E9B,
        0xFB706093118a31984bEF597e0FF4f9A3B750823A,
        0x8AE2f55ec8CCDCD3edd7418c996e9C63aB536aCe,
        0x648c001f4F285E837734D27F7Bb031DC359aC922,
        0x6D0FB16a7f9fEE137B588E66C4Fdd5B566F8934d,
        0xB2695A32522134E7eb86c1EE4b17bB9589E615bd,
        0x55C39BD76AA3a2184c3Ec07E4DF8667b333B5ABA,
        0xddE94820F2ee04c712699eED419eA11cfefa1311,
        0x9Bff4DD5C7fa771044ED3F8f6557eB0daf0c5489,
        0x9285C50176a2307d86f98333e283715A1b409FC6,
        0x8B2544a7057ABA3130077ec0df4e0D496b90f7b5,
        0xE7B0a1F98Ca1b9E8A2259dD7be5A90ec58935582,
        0x5435ce18aFC1674c8D41b8748E3D106946793C59,
        0x97D08c24CA726d6d17215FfD9367a677123a786d,
        0x242380f2A33b594e13F1d26AC593AF89f932E625,
        0xd398ae6BA0C14a4F9bF969F12ce3DEd30f605Fe0,
        0x2adBF05EB2118b808bAfE2Ad25CaF76D09b51Ee9,
        0x9550F30CD4E5518B79537eb549395F563f11209B,
        0x547F14b771526C0b9454e24182f57ac89C71EA75,
        0x0ADa25512B03fac904f715ddbca8b068d3fC94e8,
        0x4fD5223FC3164eB9604968fe367A7D20e28e4fD3,
        0x3f5813b8B742C05B776C9dD033dd7F6282F95F0A,
        0x206132CA0478A728944598FCC39098D31B3B3215,
        0x55bA72da703c24BEB836475a5504F3AbC20a58d5,
        0x6eA094b6223DC37561a1e5aA63a90cf40cC256AD,
        0x6A36bAC8781f175A420F4cC8E369C5e9fE7a6FA6,
        0xfE64c851B502E01074daAb551dc1Ebd0f695bc86,
        0x5EF35fEC8dde4c630332F36c37e8F7F8f05e8912,
        0x07e3441786c5d5dCb5EFAdC839E6E4021c0dE6d5,
        0x31EBB51344716CC6284154EFcbE1c897FA051A37,
        0x37252577b9EE2673298B3eb535798567Bfe83507,
        0xE41e1F6DE304772FEdB209d7fA5db435812cAce4,
        0x11D29aCaCA8921A517729AfEb62eA0a2f0ecB947,
        0x231C4f36d15e78F9Ac57757c5ccF6D1E7efEE91D,
        0x3b50b256775e2632df3a3b06aeDCabda29B1e8fc,
        0xe8c1cb1d1Ad57546F67557f32E294E3E6420B85e,
        0xD3539492b29D9949d9F7d6dF8AE9EC7d9E5d9804,
        0xbC65CFAD3a563618cAd932eCbEdB95e879c1EB3C,
        0x59aeBa80a12349de27e4DC620B20d2DB03b67ad6,
        0x2a133B99b5d04204EbB32F54fafa4194c01C8619,
        0x1cA1Cec2a05981C403D7cc105CDBD838cf126392,
        0x80bbfC3724Bc9A8f959dBff941EB89F263fc2CBD,
        0xc70489939e4ea0998d2Bb4C9ce5D85Edf86CBc2C,
        0xEFD1561D254F807A8c83bB9e9a0c6Cee470162ec,
        0xB5E535688D57711998bF920f1c8CcA75a9075a5F,
        0xC8838F2EB84120042439c3C91E62E673779e2263,
        0x01b6957de690a2C916B30DD39D8b4dC85878928A,
        0xFc333dC50b0dA588cBDBEeC3F79a6f6e1d98F2FA,
        0x1AbB851D7Dd7185fb6f9A0962D71FDD55C90145F,
        0xC9c1792f5Eb30D6FB38cC9476c8E79ad8567b6aa,
        0xE2a5e3A0726c29D45Fd55A0985b461F41C707F8f,
        0xB29c92749bc89e4e4323cB233bbBdB6b9406d2DE,
        0x6f1d8601EF7faFA2743fDC7B28D63134e4Ebb128,
        0x7DCFD423a64Df53AA977Ac587E19fB3727cbcA97,
        0x9f9F6Da98a1F2b081dD33797C83d75770E061b6A,
        0x28Ad2eB9a502276da9f52818207f4666D6736618,
        0xFCc01ABa7b35652B408BcbBE179277b724aC8e53,
        0x5307cB2E6705bb25029C2244adb6a1980cfc6308,
        0xB88DE80259d0Bd4E23f10491631DeD7ffB45F677,
        0x049011ff8817574B0D51acbd91e803296b91664a,
        0x797c9eBeF0e3c61BBC16C8c9D750E85beb3ad32E,
        0x26B471FaCa003859a6856481e6F1b35541588daa,
        0x6e27A627F6cba46ad14341529969D8e2A9AF6Fd2,
        0xBD05f09CB891E76Fb8EEeF6184725D125B2F7Be1,
        0x02dbfe523a8d88bAc2a08Ead3445D97E7bd76653,
        0xA1F1c34e562a83120a9731c157d94E2820327857,
        0x60a98d978dF41F854d1C361F9e059F42F90ef0Fb,
        0xB70dc4cb205D97E09D78801e8Db8e1817c984Cbe,
        0xc884EC0dea74218085659e3F288FeB6a5Db8A691,
        0xca0395323D3eC2837261ECE646Dc6fAFE2091487,
        0x3F2B817D5308347F1dA409e101FBFF1BFEC02A4C,
        0xc055f298Ea0e9E0db976332e51bb51B6e452Ca8F,
        0x9cab6A7673d8613Afe7D6115D58F28E6387A4d69,
        0xA8A0c96D1084cEDE1a8243e2536C114E696FE440,
        0x77A49365f6AC087faF74c77786a0302834FE965D,
        0x296b79D2526Eb91EC6ed423ffDB4EB8F404360aB,
        0xD78Cf1dEEE09fcbDE60883113614fa1CCF5A07A3,
        0xfC8a3dcD897750404A7e5f3285831802Dc355793,
        0xAE86177d831F0836E60ABB8F12524575B203De53,
        0xC64Ed777198c2cF187fCa6930cac018f05BfdB3D,
        0x777EE4F26fD5749bE84668A8274167e55E39fDCC,
        0x99CA3930411E4Abd1caff69A606a82aE3b492358,
        0x816c4346c6C9Da2594C7f0182f0EC3AB0173C9e0,
        0x0D53010AAc49F57DBA1aA6f242be6e7E307e2342,
        0xc9E4414BAB0D141a552EE02898b8ad2992e7382d,
        0xA4c741aDAdd22bCEED77CA860897C7C1f2396cF6,
        0x75B5aF16f74623261574Afe99F3e3C33f4A79F70,
        0x5598EF4b3AEaf3755f6dDC09Bc2550518753B970,
        0x6CB3291E051Ec57642D28177019e63F8C2C84225,
        0x6C1584579cfF743ea298391d0fcC65E7c0B1A311,
        0xdf56dbfd308B17dAb4d804f2BFc7520Eb82d6dE7,
        0x8CA25E583539EbBbd8b99710a641F2CE8518108e,
        0x562A0B7687BDc9a5f9dbAf02aD63D44c35983Fe9,
        0x6FBC923cddA30B74cb95EF9d8972798259bB9641,
        0x66d2f4eA90A1Edd93C012B38CCbb710AA66c50B8,
        0x6c25EC78Ac787422332dd89557C87b9D4223b114,
        0xB2f89485CE036Ac9c5980c0FC21903392f813bc1,
        0xdc810897771B00b6d6350A68E44fF9847ce91bF3,
        0xEa96E25cbB778ECe903B006709980F259378C11E,
        0x7c08448a1D547F4F2f5258701f35D814E36E7883,
        0xF8fFc71C6a052D9eD34B2400Ea3cA6482d0B6186,
        0xAb916445Ff9F90Ae664986a2fb67176D741c562F,
        0x0EA3dC9b140d7b17461FA07A1386983BE45a556c,
        0xedF16BE888cD4054A792cdF01E1E24ca248f33D0,
        0xF62f801D3d07367bC03A9f17B504FB7Ad11Cf30d,
        0xbCb7B160e68760437EF4290E944b296509EfE058,
        0x578fEC23D347883Ce59bC776140Fc02F2351A905,
        0x738E28eC389293Ce8f450c2a9411A77e1b88Cd1c,
        0xE0ebeDDEE7Bb6fb5Ff63E6365f6E45f7ecdf406c,
        0xE480Bad595855D82f80fC591306e22ADd6fA8bFB,
        0xCe0AB026a3AFC7003E56E2a0FBaDbf16dAC36875,
        0xcaF07A6EB948E0Ae95bf086b8a5d13397d7669BD,
        0x40793D897244d8bea3f5876190a6F1c949B2d052,
        0x411dF53C24be103ad0C9Ba8b1a711b5Ba81aee63,
        0x741766856606b7ecC13753eE6e47a0fe20ef814F,
        0x35aE404037eeC189F964C200e50fA234D27D969B,
        0xE2a3116e51D2a48dA1C3D95F82Aeab89237C7fF0,
        0x9A681C88f9dE652F075f4Be942e6cF3c057A5374,
        0x90d22fdCf1e35dC88D5A862Be32665E7af4D8966,
        0xC14FA9D064Cc92bAeB435e3CbB66ef36E69a44C8,
        0xF2AFa1F5Db110c0BcE5BBC78070A1C59ee19179b,
        0x2Ad617D2CfB1f06026a88a724D5a73423730c402,
        0x48F2D6CB0D34F96A0d4b2293dB42EA2872312049,
        0xDB3d71f6B1aa8e601d1f1306a96D32237Da30E26,
        0x7cb98CC04c9DAffA1baFEBbEcDa51335F60248F5,
        0x4BC711e85340FE10BA0845cA8b6d653E507CEa5E,
        0x38B8Af72BC75F0391aAD2Cca1d67025033ADe7f4,
        0x078e440Dc493D151707F605d088706426CBeAc3C,
        0x83332CE73253132ed639F71721a97a0B8535E941,
        0xc477e19b0400CB1Bb50F69CE76AD8602B35E51cd,
        0xF91Ba24b0Ae6A1b021F49B03c7799Ccb664f07f2,
        0x27fEd1b1c8Fa493202AD1C833325454FA79a90eC,
        0x1e0A3173ecf969544522FAC2fDE02B699C516EFa,
        0x9a8728d17742C3d5B62a1a561390A976c1380dc5,
        0x330846839670a0B2473971038f3884dEE5613EE3,
        0x4c68CAb765673219ec1B04eB8881cFB134012d46,
        0x044cb922d8Bc9374f194c64D371C31F06819bc48,
        0xFD3b62fd9Ceb2e021cf1f54802B819CBfcc58C3c,
        0xaa18bFd2419Cf03fb5Cc07684eDeFA4CacBf92C3,
        0x0fa356F87Ecb906A0837bb54c1226B2BC60AB534,
        0x98dffb3c906c8B2bD4Cb2fCDf853972f3A29AF71,
        0xeb8a1ad6FFE80e21Bc80C82c89119Bf07E5034df,
        0x58102503E7eDecf9979bB528e77e87BC62362292,
        0x5ab254bAaF0E5597bD4040A6412e7cdcB629c163,
        0x112A6827e01DbBa3B13c69A72F69Bd202c18b800,
        0xDa2508244B7c5661e7c2e05B3d49b236e38550F8,
        0xbc7E52eb8fA666F53A4Ae06530a5fC8932bfCDf9,
        0xd398ae6BA0C14a4F9bF969F12ce3DEd30f605Fe0,
        0x3Ae7c3E98C1913A3a723A9dA81b48DB273b1C9dc,
        0xd9E418F0e91F70cc5223530818297fcc22BB52e1,
        0x99170519957e7a65068016f8f08e82ab84036a11,
        0x6Fbf9BcB1b97D7D07339f6E6b3F1Cf185411160c,
        0x2906652Fc38708A9B905bcBdd7303320e3F6FD3f,
        0x57D314b90c68EC7188087e9bA226CF07d62d8b4c,
        0xcC3a940B31CA55C43Ebe99E8813582D5eaAf41C8,
        0x2fE3c8c71Cd93ad56045D73975629b1e5dC22f39,
        0xfA513AE3982782d7Dd10A218f80b6dB034E69197,
        0x6c16d7fEA323Ceb0a79353a05f86Dc16A49D41DD,
        0x159A862EcF7A9346c465aA6b908B33Cd6E083553,
        0x3E5560Ba2E201145552b7a52e55EF4dAF5977E84,
        0x1CD89f1De1586C971F20D161C52eb8B4866F684e,
        0x46fa41E97c01043ef169896bb1031955ce7eAF6f,
        0xBc989c24c732d69Ff7b7f89B55f5D3758D1C2fC8,
        0x86090cAcfda1484eF983Bc8c7aEA230BD96D3EaB,
        0xE4d042a145E0756148f12EB26aD3D0De60151633,
        0xC8B15C7aFb95759422c5d5F857a4b09BaeC79c4A,
        0x7d1E7c3Bf4dB9f48fc43d1aF4Cc4b84254d97ec2,
        0x08D389359c869609445b80D25e0ac067F76993Fc,
        0x7E09d903f3d31C6e710d8afDa417e7867a6c4CD3,
        0x1c65b5aB4e5625Dd9d16fBF5372a85F109F2787d,
        0xF8904391f3DF81888a9b8F2c32DD1D52a45F98AE,
        0xad2a6C55808A17Bcf4776b9C27b9F6F9fA86681a,
        0x5F4B97dcf646EFDC9E61179B90eF348F8cC30f15,
        0x5F3E1E2eE56Db51Bd559BD644D482AD1aae9FcbC,
        0x58Eed3A1Ff736fe61B8e27C7E9097c9dE8291BB8,
        0x10b5608c3B47F888BADf2d4418EC8DE79338F502,
        0xeb3f0518C02fD5294e718262d38B2124EA833440,
        0xF6C8F4429F14b3a5E0Be2a7B15dAE45dd8Bf0975,
        0x7258ef88ffE1BDe2c7562624e44e4B6e94bf64A6,
        0xF1c59f75CC6534799De7395628b584cf020cF974,
        0x608c70171CD421b9053b3B355d5eF942d88aBE6e,
        0xf2b5c5d83278e23861AA1F7835057475ee28f92a,
        0xD200fFd8180E37f7334c4EFC3F297452332CB893,
        0xf43aa29C44914D52c1165fB441B8318c823E6614,
        0x564fFdf8D17411CD33a948F5E2E2Ee861186ED85,
        0x0Ef892DFea61cdf4Ca8e0BF9e4387c66B68C3545,
        0x8dF46a44683228342FAdaE2d4e4D2437c47aeb44,
        0xc63d654a7F2E1312a883443fB1B8aD0B02daEae0,
        0x8D94a9080D45Cc231a74234de81bbd21f5B28893,
        0xe103BDd1C45eF77abD0d8cFf1F61160FF537996F,
        0xFcea358ee8aF1B4300F536E02341aE9433D4b452,
        0xE6b2C05E9DEc9377F4e26D4c9c8cF167a777bBa9,
        0x51aEDF3C4007b451c75f0532872AdA5Fe914AFe9,
        0xD77eD7538416a6bA417602818577521Af93D0f89,
        0x6cb2624fb283402195fA17140CbdDE10971C316b,
        0x6889a6f4aC9257b161210a78012F6C5f713950e5,
        0x25032D11e58fD0902d3a73379D2bAE68d0745092,
        0xfBD831DcF3c007D519393a915e39F597bAD13dE0,
        0xB3dC62ed09f1A1bF9BCd02B71e6aeE38Ca3E38C8,
        0xde75432b4b3974963a6A4A2149C3b1cDCEdeb0C2,
        0x5816cc65814500e5bBF29030358acC31E5A32C31,
        0xd9374D874CDa35360b80B6f6c26F77f7A40d53d6,
        0x538d5c7867Ad5182fF432A148250eb7D37a726D2,
        0x8C551080f0a75c5291739179340364a05BeD62Ae,
        0x4D313A2c94fF9894Fe7E1708B6D6088f61dd9562,
        0x5ffB5AacA4AD7eDe5730EC0DA06A75eC8f2B19Cd,
        0xe72bC33D384DB7Cd21C73aa22257B558326312de,
        0x5a5BF812f53870A1e84e1BBd3527a5b4c226E3a1,
        0xE9EeCB4DbbDe7204Cd47f3f65B82fa653B1d73F2,
        0x603E5a651305DD3a002e46752085f870Fd33B7D7,
        0xc04917dDA4dADe841BFFC3c175F226ac0d507AB0,
        0xC5b1128ED3359c9526b99623BDAC58b0D403B7EC,
        0x93AE60828A8d75b7a6052364f3130A2e1c58e191,
        0xe209B2ad46aC42AFc3e9B2533F41486aC9F52a67,
        0xfd5BE84097eaC21EE56416F2AE6B050F03c81751,
        0x7f7d3009213178096546EEbE04456f214154Eed1,
        0x0bC3D88dB52779857599b8412F9678d5593969F6
     ];
 
    event reward_event(address indexed to,uint256 amount);
    event reward_event_white(address indexed to,uint256 amount);
    event operator_white_list(bool flag, address indexed add);
    

    /**
     * Whitelist address management operations
     * _addressList => operate address list
     * _flag => true for add, false for delete
     */
    function operateRewardWhiteList(address[] memory _addressList, bool _flag) public onlyOwner {
        for (uint i = 0; i < _addressList.length; i++) {
            if (_flag && addressToIndexWhiteList[_addressList[i]] == 0) {
                addressToIndexWhiteList[_addressList[i]] = _whiteRewardKeys.length;
                _whiteRewardKeys.push(_addressList[i]);
                whiteListLength++;
                emit operator_white_list(_flag, _addressList[i]);
            } else {
                uint256 index = addressToIndexWhiteList[_addressList[i]];
                if (!_flag && index != 0) {
                    _whiteRewardKeys[index] = address(0);
                    delete addressToIndexWhiteList[_addressList[i]];
                    whiteListLength--;
                    emit operator_white_list(_flag, _addressList[i]);
                }
            }     
        }
    }

    function divRewardWhiteList(IERC20 _token) public onlyOwner
    {
        uint256 amount=_token.balanceOf(address(this)).div(whiteListLength);
        for(uint i=0;i<_whiteRewardKeys.length;i++)
        {
            address to=_whiteRewardKeys[i];
            if (to != address(0)) {
                 _token.transfer(to,amount);   
                emit reward_event_white(to,amount);
            }
        }
    }

    function div_reward(address token_addr,address[] memory addrList,uint256[] memory quantityList) public onlyOwner
    {
        
        IERC20 _token=IERC20(token_addr);
        uint256 total=_token.balanceOf(address(this));
        uint256 quantitySum=0;
        for(uint i=0;i<quantityList.length;i++)
        {
            quantitySum+=quantityList[i];
        }
        require(total>=quantitySum);
 
        for(uint i=0;i<quantityList.length;i++)
        {
            address to=addrList[i];
            uint amount=quantityList[i];
       
            _token.transfer(to,amount);   
           emit reward_event(to,amount);
        } 
    }
  
    function withdrawal(IERC20 token,address to) public onlyOwner 
    {
        uint256 total=token.balanceOf(address(this));
        token.transfer(to,total);
    }

    function balance(IERC20 token) view public returns(uint256)
    {
        uint256 total=token.balanceOf(address(this));
        return total;
    }
}