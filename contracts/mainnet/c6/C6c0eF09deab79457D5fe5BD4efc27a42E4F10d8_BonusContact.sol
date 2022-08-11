/**
 *Submitted for verification at BscScan.com on 2022-08-11
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

    constructor() { 
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}
contract BonusContact is Ownable
{
    using SafeMath for uint256;

    address[94] public _whiteRewardKeys=[

        0x2113c26Ae4527a8329777fE5A04E9ac8C3e12372,
        0xe699a16a949187aF2EBe6D03A566ED0cbF98093c,
        0x31AB7C2c585Bc1DB87B70c8627bc29713D24845D,
        0xa089510aEFdfB3A41759eB496959Df7636D410d5,
        0x0a41A719D3E345D760597dFD85FbE9D268005D65,
        0x010b6DDb2043F7606e116F272b6e1614456De67C,
        0x9aAF0aD13Efa0Cc5b17ACd985a2A1bfD5c23f8F2,
        0x078bbc385321ada5025C0171eF242AAF0D0fa516,
        0xD661C3fc418Aca7493c238Dd951e7dcD05F362dD,
        0x7C86df659A125024Bcb2A0A470F769B8d1213c9D,
        0x83A71F1A1F3b07d4090947FCeE43aCa26738f9eE,
        0x9C7A7b467A3A0cA6Ba2de0cE44F0F939bd68Bc2D,
        0x5196cF5Ad58111bDc773011b2b7292D2875eA2b3,
        0x4040C7522A8603679abcd61c23B5139dfa1e2bad,
        0x72d6dC4ec1B64C42bE408d474Ca00cc88AdEcDf2,
        0xD7F59c77eC46f85BBe14031398C220156b112FE9,
        0x663Cd5f9aB90B3588BAbb9FBb09064ee03Ad7E6A,
        0x49341e5993e8a47859Cf2B67c69cf422a246E26B,
        0x178fE1291d55c7913A695C2bBc01984e9bB3b0EC,
        0x1A196be7271A6635b73b8b549Ea9e88a4a96747C,
        0xdc47D575E996E0e62Bf45e09CeF705350f427288,
        0x46a6cE038982D0B5374a5720630F31dF9A47bA7a,
        0x693139a0099cC6Cf5c38823a63fF0e01CB1C7AF0,
        0x8f83B8C5B07bD2E406c7CC90D192d13d7eb500C1,
        0x98Af5f6de8308540864702006eb43b7d8A3e1F97,
        0xA0480c158355003b2A8cFC0Bd8050504279A0990,
        0x8047a36e8B47D135588a1fb818c505c0aC9f2768,
        0x5959932F925506AE62b9823F3931DA795dB1B481,
        0x59f52138EB10ad85a1A35A033cc32FDb0aB5e2C6,
        0x2baa6B071f32823c0dB3AD6654977d7DcE2aB783,
        0xB79a9725d1DD165eaF9d05e5dd2a2e64c9F2ba39,
        0xb0809771a6d885592493C974bE6444192fcF2982,
        0x1BDbdeAAc283BA4DbD51607775241a685773d4A9,
        0x741941f093829A3988Fb2fFc96e0aD65900Ce8A6,
        0xc54e702751FFC89052BAF892Fe9C687de6cd224C,
        0xA2569604A4B958EC7e38d2A45A890F6fA42cf3E3,
        0xda821CccC846bB6cf4cB2E5E04AF4765D50704f0,
        0x99Ed077081C8e79913F8bc6E00cc3816B7336335,
        0xE745b30734c872e05Aa0228D9B440F189190cC9c,
        0xD8F5f920406bBb816FF6e77A995dAcdBe6cB17E1,
        0x8c88e648b6617cbddBe9b7d01D18Ed31C60AA58F,
        0xbd644a5b1367E7daF43F64294C67151156C6fA18,
        0x9F9A7B4B8EEB3e3947b0442b524bd71a2E7C8Cee,
        0x4aE6c39003B96BB14bF7CCfDEDD8eD6dCC8863A9,
        0xbD8Ce26e01AE0f073477a760Fff534b68ED695f1,
        0x8E700Cc3553b37D627d64eB242C1f987Aa23F62E,
        0x1f3aC301dc372f9B3de57eeFD4216236BAe26AC5,
        0x76588172896496aAD4253e4e107818Ca6Fec46f8,
        0x0daE33F043076AA344763322C6090480bB4037B4,
        0x02a7467a52C3082132742AC1A0409CfAf17f6bbB,
        0xDe04727e12bE1A7c17E8ab7BC542F44344c03E6F,
        0x87f18F59aB8d06e44D96a86893EbeD9328114DA0,
        0x52A23a1D9A8ce5Ee68f762dc8731A7170eae5815,
        0xa5569CEE4eDEC7d1D8933ae1a520467fE61DFF45,
        0x6F70A91f1792501C881D17993Eaa749ABeaE08FA,
        0x0f2F87E49576bE6BD8D05eD9F8C478a54a700a36,
        0x38f844EC91E7b0DB2754FEEeD6034E6827c77e4c,
        0x727d00369B26eD5BfF44Dab9EE24CFCb8A5E6331,
        0x64d86Ab759AF84E3fda31CB3a15F2c0B1d6a1B2C,
        0xaB01517B1Ed34EdaFaD57C5038101B92336730cA,
        0x46a39b683B7c097f59e336df8cEaDDc6489393F2,
        0x6dC3a938A4279Cb483c53DAbD0178013c60Ed7c5,
        0x76866976A281F25206B5dC2276fFEe4954874A8a,
        0x25501a8d7DAa14e755F1918b81f8D1bf67640559,
        0x5565e551D56509a52783a695c9686e17112158b9,
        0x5f3936F5613B52Db5B849EeC1E27eF2552b65D3d,
        0xdA385B24F4955cc60F7fb4a469658a63fd9c41A4,
        0xd223DeA61F8851d6923e84d079df7158f288DffD,
        0x69E13D349133771c853e9f5C1B04b7830fDc5442,
        0xf4bad1D3Ae6bE990e62e3D1eF1Db6AeFB59277e8,
        0x75698ffFAcb0616b1722Bb2374E2aa522010D2f3,
        0x0cAAb431BC7c5f60e476f9dD0Ad8cD48d27b842F,
        0xB14F547fb099A3b1C87b8b3017244F3dc3f6063A,
        0x6acaB6F8C077B10a6524a872b5D1324f21A17ba2,
        0x77fdc5bc324979FC797dc19C94AE5776dA270Dd2,
        0xCcAf7545e51c7638Dc2a9B6892f15752a898d316,
        0x62AD9d074D578d28a4781bf5D3dEF6A7FB1deE29,
        0xdaF208Bb4889d0e0AC7974dD0618b0A0b0475B63,
        0x112036B0ce4d222600738411806213ADE54D31d3,
        0x335Fb92A11019272C4973D22F26037Ab8ca17206,
        0xa5Cc6ED55ba6a82EB91a81e7dA7d65821Fa308b3,
        0x29d3d3fCe4b1D8a458649EE8a915Bf58883437c1,
        0xD1deAa327337f4EeEdee0643d541e906762E96be,
        0xB2c57eB74764fF00c35365C5096e3A9D993844dc,
        0x2B85106A63b328c2D891e18831807D549ea22683,
        0xDB018d73d052215848838070A8a04efAd3e416B4,
        0x43D25e783D5fE811120bdb64D8281d0522161F48,
        0x3C768F9a6f9dDC28D5DC12a019Ef4A89a261dFe9,
        0xD116E286b039634F4863481AbAdb1871B4E0c2cd,
        0xD6d3922c1a5856E1942Ec8E504B665370f0A7B36,
        0x2c2aD1832a6AF46ceC0d9E813ccF83f49957e25D,
        0xC7d0E7095Ee28B672b7cc6F8AFD8B0e5D0c29950,
        0x61647Be2d7e5892aAccD911d45888B7c57248e29,
        0xCfaE39AeCE2Fd81c205ed2F3FdBb1Df9002a4623

     ];
 
    constructor()
    {
 
    } 
  
    event reward_event(address to,uint256 amount);
    function div_reward(IERC20 _token) public onlyOwner
    {
         
        uint256 amount=_token.balanceOf(address(this)).div(_whiteRewardKeys.length);
        for(uint i=0;i<_whiteRewardKeys.length;i++)
        {
            address to=_whiteRewardKeys[i];
            
            _token.transfer(to,amount);   
           emit reward_event(to,amount);
        }
        
    }
    
    function withdrawal(IERC20 token,address to) public onlyOwner 
    {
        uint256 total=token.balanceOf(address(this));
        token.transfer(to,total);
    }
}