/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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
        assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.7;


contract IntegrityPreSale{

    using SafeMath for uint256;
    IBEP20 public token;

    uint256 public rate = 500000000000000000000;    
    address public perSaleOwner;

    mapping(address => bool) public whitelistedAddresses;
    mapping(address => uint256) public boughtAmountBnb;
    
    constructor(address payable _tokenAddress, address _owner) {
        token = IBEP20(_tokenAddress);
        perSaleOwner = _owner; 
        whitelistedAddresses[0x52b23Fc2a5C796B34da4a6f6e2D6aA82333D9dA8] = true;
	whitelistedAddresses[0x07Ca1FFcAA35Fe4EBd6aAE06ee3D73c722D11A0b] = true;
	whitelistedAddresses[0x35e19957EA0B79028C1265A61614d666C040C5bC] = true;
	whitelistedAddresses[0x260d52e77cA0B66dDF8169293E99399C0206a21C] = true;
	whitelistedAddresses[0xe886E64200411125D65c7aE667178Df87434322d] = true;
	whitelistedAddresses[0x3e9f11CB5bD48fEe33b9b91cc2E4422cdC2D7180] = true;
	whitelistedAddresses[0x2ECa2168f4280D70E63c8B7De2a77208aFf380a8] = true;
	whitelistedAddresses[0x23cB55d9317E13281b8428C40dF5A2De963a5b4e] = true;
	whitelistedAddresses[0x8624430D5650e040106539fc01b11F9D89F8f301] = true;
	whitelistedAddresses[0xe31B146307e16d476d58778F18f0A8cA4949CC12] = true;
	whitelistedAddresses[0xF2cC7E6d265D0a4AF639ACE024Ee7dB4017c6C37] = true;
	whitelistedAddresses[0xff501f721f00AF0172a839bE2384Ca9B85A1CCFB] = true;
	whitelistedAddresses[0x763B30dc88B6862C608f04C6EbE7F81C868C7799] = true;
	whitelistedAddresses[0x1B7767E93918C6b70205F50846233720c66b3f14] = true;
	whitelistedAddresses[0x2dCc9D9585dE98869923439f65CbF8bd9F6D7ef2] = true;
	whitelistedAddresses[0x550470D8C83f3Ed49cd2EDb075f2bf3816814fA3] = true;
	whitelistedAddresses[0x71d7739A320821C4ED768E8bB33E95349cDb3CD0] = true;
	whitelistedAddresses[0x68D6E55705b628C7d5509DfEA5aaf8Fe700b809C] = true;
	whitelistedAddresses[0xb38bE023E6199f445270491bB6f68527979eea72] = true;
	whitelistedAddresses[0x5fEbf9Ab1be3B0629FD50260868B4Fa529F0e321] = true;
	whitelistedAddresses[0x5Fae687069a0B4cf4a0A4F4148e2372B625c8126] = true;
	whitelistedAddresses[0xa6B8D8fc09FBdf6B95adC028841395Bce9fd87ED] = true;
	whitelistedAddresses[0x5Bf47b698836a64a266a224fdDD0C9DbF63EDdDd] = true;
	whitelistedAddresses[0x0c3942868F4DDD4053B64655F06FEb0c57814E5C] = true;
	whitelistedAddresses[0xfA3180daB16b3534739CEEB83Ed643aeBae2545a] = true;
	whitelistedAddresses[0x627f4F173D749E8669a761521435C21649ab789d] = true;
	whitelistedAddresses[0x16c61f6b49d58611E44b0Fb9326FC5A27354D838] = true;
	whitelistedAddresses[0xFFf00bfD9D0dB620509b8c2a03F86aF8153368e4] = true;
	whitelistedAddresses[0x45835676cDA122D6BAc1A5b790dbc2CF4FcFE8fF] = true;
	whitelistedAddresses[0x834aA8E29cEE50dc3947bf5b8dB431e818598a6c] = true;
	whitelistedAddresses[0x001C88B61AD7AA69E88A53894718D31a8965f085] = true;
	whitelistedAddresses[0xa89d984Ba4E20319fDa193A07941702EbBCbE714] = true;
	whitelistedAddresses[0x5b96EDacE5B086A4A2642E1E133Ab5e366616bB1] = true;
	whitelistedAddresses[0xDE2c82E3007F901b0b15c980Bc2039065c97C86E] = true;
	whitelistedAddresses[0x2B31735e6fE3826d9C89BE35BE9b46A882B90495] = true;
	whitelistedAddresses[0xa1771FF20de5bc5141F4639396833e31b2679C5F] = true;
	whitelistedAddresses[0x63Bd1718512848e4295DFD5A179Be121A06Ff74C] = true;
	whitelistedAddresses[0x32e16C178e49624E637666d3a7cA45c9C0F03e8E] = true;
	whitelistedAddresses[0xc9b23D6AE4fc7Eef3F1211F5C37F2f8e9c321743] = true;
	whitelistedAddresses[0x0a50c49A7eb5D3df9bb23998eAB7fcC77527a28d] = true;
	whitelistedAddresses[0x334B2CEa98edaD4a9af5952C0901ed4035f05019] = true;
	whitelistedAddresses[0x3B50ff9838684294DdF6a5d2cbF28Cf1ad7a48C1] = true;
	whitelistedAddresses[0xE3B84CA73ed3140bEdfbBCe18BE2D4583f26029D] = true;
	whitelistedAddresses[0xe18af6B95c913fBD3b2167372956d5b922321008] = true;
	whitelistedAddresses[0x28aFD3120a310a5bB4aC09eB7f60E3920E323acd] = true;
	whitelistedAddresses[0x903290Be40343C55e4255CCDC5929772E9889c51] = true;
	whitelistedAddresses[0xA65Da63d6C35bC9f800e70dbf6198194552A0ef5] = true;
	whitelistedAddresses[0xFdE3775f66C6DdAFCE1fe6f02aCBF63D7F57e563] = true;
	whitelistedAddresses[0x2A116Ee0939C19D9886D08EfdAF02eb6656Ce440] = true;
	whitelistedAddresses[0xA7f90d69F81B76156F98dB62D0794d0B9Daef60b] = true;
	whitelistedAddresses[0x3a5E77fb25a277E13A6cCb71B166e4d13f47894c] = true;
	whitelistedAddresses[0x275ADB54864C385D2C9CEBc2eB9c25d0E847891b] = true;
	whitelistedAddresses[0x87a9c7Cc1614f36BA887f7A5FBBcF497Eb8958ED] = true;
	whitelistedAddresses[0x5B6e3B759BeEc0C111A08F2F72eb5162C2Ff530f] = true;
	whitelistedAddresses[0x7073F42AD35FA8832A94b070DE8e8bD9C3e63E83] = true;
	whitelistedAddresses[0x1a3C12461b93fA16b75D97d89D265922e0e9153C] = true;
	whitelistedAddresses[0x9034A03977cfb4939C989B1f2e68Eb1E8326585a] = true;
	whitelistedAddresses[0x7d2c1A3980DC357b5e087e1A7704b7C4B0EA4b19] = true;
	whitelistedAddresses[0x2F5c013d57942E9D0779A36D3bEc97D5de773903] = true;
	whitelistedAddresses[0x3f072Ab1127d0B7b8Ea5AE4601346a7b902bdA62] = true;
	whitelistedAddresses[0x88EBea10530772f3bFD611C48178289bB2F4eD32] = true;
	whitelistedAddresses[0x36536B35c41F16100D211fD85b091B55b5872284] = true;
	whitelistedAddresses[0x57B51C741D740Eba0ED656a47B066d5DF4CB728A] = true;
	whitelistedAddresses[0x6B45915bA99E58719637B371284caAc205CCa367] = true;
	whitelistedAddresses[0x2e26fE636106fEbDe20c05BD399E56B0235233c0] = true;
	whitelistedAddresses[0x69bC73707A9e91A49dac9847369340e6c8545daE] = true;
	whitelistedAddresses[0xa534c099B5399af8870C71b2aDeC932C33B8eEf2] = true;
	whitelistedAddresses[0x9605cB8D28Af80Cd0a0c3a14fE25ba6CC7ed502e] = true;
	whitelistedAddresses[0x4035b31cf8A805B0443E1DEE22628bd03C8Eddf7] = true;
	whitelistedAddresses[0xd298CB12dC8cD6814a2333fa6166de80a124A776] = true;
	whitelistedAddresses[0x9eD5A47d942498A2704BC337c8D5eF937F420dbB] = true;
	whitelistedAddresses[0x5F500fF7bb76b3E6c3477178Fb31C7f723Fa4Fe1] = true;
	whitelistedAddresses[0x5436aB769B813eCcA7F52871A4a801731EcC372d] = true;
	whitelistedAddresses[0xEE91BFd6150E8B045050cE1E13514D13cb9A51E4] = true;
	whitelistedAddresses[0xe3d03600fF1E6b2be79e6Ad0084a65979a67a42a] = true;
	whitelistedAddresses[0xEcF8C9B0e89aBCe927A7b1FB87beCb98c9e7Fd9B] = true;
	whitelistedAddresses[0x57738Db90C1Aee96590D2E7E45129b987Ee16Ad8] = true;
	whitelistedAddresses[0xf98F91a0AeE7ff4540E3b56F02f7DDc38647FA82] = true;
	whitelistedAddresses[0x30E8B61ABB2f48F50Be84b1BF235b3f99708A6bD] = true;
	whitelistedAddresses[0x4b3419B6090b9cfba2d6e235ea32b66e455148F3] = true;
	whitelistedAddresses[0xB146ce99e01C2441c445eA8c3eEC353a448Dfb3f] = true;
	whitelistedAddresses[0x137F986A94647E54B730F91F1e9FE07a68aEEEFb] = true;
	whitelistedAddresses[0x86eC9180D5E4d72C45cE02D584220a7f29Eb781F] = true;
	whitelistedAddresses[0x0bfE83B9FC460ccd4d2F251afd8969867e809842] = true;
	whitelistedAddresses[0x43B88346d735d27eBfC1B5DeB494cdA3F07D7506] = true;
	whitelistedAddresses[0x1063021B56e8E74FeD56251f7A1e8a9Cc4EbafE2] = true;
	whitelistedAddresses[0x3669842cdd5817A3165eA0Bac8BCB4AE60a528c2] = true;
	whitelistedAddresses[0x17F0758e1e78AF1435C790ca335BBb79A42AC2b6] = true;
	whitelistedAddresses[0x368356355FCd95F0E0c7eB07A7250FBA30460684] = true;
	whitelistedAddresses[0xEee749DDC68Fa30b7A6eF1c6EB15BC0449f2057D] = true;
	whitelistedAddresses[0x2D0Fb59DfeAc82A6c5d65a91190a0a0C2e97ABaF] = true;
	whitelistedAddresses[0x8743E8444D40518717FF87e26BC648728699E0ED] = true;
	whitelistedAddresses[0x2ae459E65aaDA9Bc8B7739ED8B633Fc7F77E8405] = true;
	whitelistedAddresses[0xf21F67F9E1C474696fD1D37a6099c0f26E03c5F8] = true;
	whitelistedAddresses[0xA9dd5B122c629C321e7aC143D22f6EB09b969eFd] = true;
	whitelistedAddresses[0x129B7528D11061bdd22a39F641eD8468E443E149] = true;
	whitelistedAddresses[0x9d012CF89e9810a6929DFAfC19ad4a465C3d22ce] = true;
	whitelistedAddresses[0xEBA9b2293EF99154149a170B85ca0f37B772cA9e] = true;
	whitelistedAddresses[0x6Da46A23369EAa4D39ddB93711B3fD386F1370F1] = true;
	whitelistedAddresses[0x612dF39c55eD176fF19de395d2C581b02b6D432D] = true;
	whitelistedAddresses[0x7ee06d78fcc5Dd52B5211Fcbde7501a7C3ea10b1] = true;
	whitelistedAddresses[0x80b5fF20b68fED035b8D42f61678Ad77396Fa151] = true;
	whitelistedAddresses[0x8A8f98db923dCfCb3fBD57F1E51ca84d60429F49] = true;
	whitelistedAddresses[0xa0A729eC876C7d5Ae9E87f2A2d8E66F6A1b0bA8F] = true;
	whitelistedAddresses[0x2A605BfBD689282D41252065ef3680B928669Fa8] = true;
	whitelistedAddresses[0x26C2f169121d3713de9b1Dcd30E2c1BE8FfdF11A] = true;
	whitelistedAddresses[0xD304dAE262F9dE97EF4354D410EA555c352d3a9a] = true;
	whitelistedAddresses[0x86E91e5E3B24D8C155eF9A152e4667fb6953785f] = true;
	whitelistedAddresses[0x701CB582987a3AeA393066f9C4d3feca0457FA43] = true;
	whitelistedAddresses[0x67917E551343ad3A160501Dc491e2ED1b5960bFA] = true;
	whitelistedAddresses[0x41630e2aC489d9d4757957dA564c7aD0591E3862] = true;
	whitelistedAddresses[0x35d1744e8a1ce8eB15B9856D067e1Ba23d6a7034] = true;
	whitelistedAddresses[0x3F2Bc5eDf2f66251E805b794aA22238F1B3091a7] = true;
	whitelistedAddresses[0xAACA48d95caDa2443DE8a6eA26935afc998e6373] = true;
	whitelistedAddresses[0xf9AC4520D52856F514Aa23778B8ad50c34227fD3] = true;
	whitelistedAddresses[0xa2A37ab21E769D8e2AE84cE18F43B945111940aC] = true;
	whitelistedAddresses[0x486700B5C04cC94Aa655EDd0274fd547c553eD48] = true;
	whitelistedAddresses[0xE45A57D7347a0AD6E49509D60d0b9C5D840A87Ef] = true;
	whitelistedAddresses[0x82e693122E9aE3ff0B221D1ba895C21e49f0BC02] = true;
	whitelistedAddresses[0x50f443729042913CC005F02B1436676E0acDc59a] = true;
	whitelistedAddresses[0x59900e1a19D428fFC60C7b20a29AB68CC4cfbdE7] = true;
	whitelistedAddresses[0xe62C6374D23420064A16ac67d18A20c2cd91e97a] = true;
	whitelistedAddresses[0xd2C769E2a9B12815967830E0b41b80bde049b749] = true;
	whitelistedAddresses[0xB0F5CDEa1915d2BbD059cff31b3541E8db5e6002] = true;
	whitelistedAddresses[0xA8f955935fD5c6651457620313B9Ef7121bb8992] = true;
	whitelistedAddresses[0x7990746060947C5F91425405965F3b5cfAbF9106] = true;
	whitelistedAddresses[0x6659A61c615B80ee5bbb751DEb3135B486a1D3A7] = true;
	whitelistedAddresses[0xF228d811E6C4411307F6B500c7397b5b5229eE03] = true;
	whitelistedAddresses[0xf182B54ab446C2e14bF0E6fbc04Dc3B67aC989DF] = true;
	whitelistedAddresses[0x67415963f91f011845d43c5F8A6F5744FC67Ea3d] = true;
	whitelistedAddresses[0xd9c9EAe380654cbf3C38c89D5aCaB9587D8E157c] = true;
	whitelistedAddresses[0x6c428B4a5f1478278399481AC9f1d4F0Fa0d7404] = true;
	whitelistedAddresses[0x297b61d668E64A1327189E2FBaf62dcbf394A750] = true;
	whitelistedAddresses[0x35006Cd5D75863CBc789570Ec8092833C8cE91ff] = true;
	whitelistedAddresses[0x24DC767a3e3975e7179E722cfc79289CC2434360] = true;
	whitelistedAddresses[0x6D7e9ee259a350bC0302f70B3d12962396849F68] = true;
	whitelistedAddresses[0x8E77D31e729a66d7f64E790b9aACF12E929f8F87] = true;
	whitelistedAddresses[0x4941146973e065AF188E5ADC8b8d012C504ddd15] = true;
	whitelistedAddresses[0xfbcf7900B343192e7F536dE96F46cee02deF09f7] = true;
	whitelistedAddresses[0xc8d116eCf4650A8e1a8795002a9834201ED2e8Da] = true;
	whitelistedAddresses[0x6DDcA8D955795872b6674D95C0EB6F197ce569A4] = true;
	whitelistedAddresses[0x6dde6cEAa7B4C6C46a94C329Dd59a2D979d7999d] = true;
	whitelistedAddresses[0x3cCcd8f15A5091288C1636d0168180E004A6661D] = true;
	whitelistedAddresses[0x1Eb111eb2b333EEb1cA07a5f250bc218221328f7] = true;
	whitelistedAddresses[0x2e10DCFEFCdA2f726Af7a3D091ecF0A1D6293188] = true;
	whitelistedAddresses[0x6C15f95C8eC5e3a7cCd19D72AC04A744500e6DD8] = true;
	whitelistedAddresses[0x75509e12097a475a289C06ADB27e80a4DC0D060e] = true;
	whitelistedAddresses[0x7BA8E12CafA1617bAC2E5e09192398876bFcBB8d] = true;
	whitelistedAddresses[0xFc2228182C46b3F250Cb9870F51CC24dfB2452C3] = true;
	whitelistedAddresses[0xE845cDFcc5b98ee55437D7F80f5c03FFa19f582A] = true;
	whitelistedAddresses[0xdF1d05c3E159AeBc0e0C527EAF55b2E7b01D1110] = true;
	whitelistedAddresses[0x8f099706a3AB1c7De7B0dF5922c667214Aab84D0] = true;
	whitelistedAddresses[0x83BBafd5F3C6Cb63b8253134A79e93164a659CF6] = true;
	whitelistedAddresses[0x5CBAC197D5794fB2a6F69A642A8e456A5DC430aD] = true;
	whitelistedAddresses[0x8565d6b93639bCdf3a1d4631198c72124126b0Cd] = true;
	whitelistedAddresses[0x834f60a916492502cf9A963334136c2D98234143] = true;
	whitelistedAddresses[0xF69DD8012106752503f061F6195C28021f761540] = true;
	whitelistedAddresses[0x9D7133c0143Da09c128F88574c134b31F44E8C4b] = true;
	whitelistedAddresses[0x8ecE225F4C2a75b7e120183FB3E00Cc1AdFB01F3] = true;
	whitelistedAddresses[0x8205864f8950206c7fCb28c5DD83314D9f0E70AF] = true;
	whitelistedAddresses[0xF2334830B056b826f1aB4c7C5e13F67AB5aB4012] = true;
	whitelistedAddresses[0x8D6D6430A0E03C08A3B05A295Ba57AA7cF194355] = true;
	whitelistedAddresses[0xc230dd4B0E57244947fb63eFB1bfc3EA332b9A3D] = true;
	whitelistedAddresses[0xb58C499882CfE5Db3F40856C6d897B75EEC53A8e] = true;
	whitelistedAddresses[0x792287D8C490b0817E02dF4dA8c494a60e6f3d79] = true;
	whitelistedAddresses[0x9DE4D3E5C880EEe3561b4928F595CD4D3a995C6e] = true;
	whitelistedAddresses[0xbbdD4b9cd5E4609A3C8775B66c2FaE664eB0edE6] = true;
	whitelistedAddresses[0x06301a89A429120178d7dcaD2F49568bd2a901b1] = true;
	whitelistedAddresses[0x56b26c93267e443886eBDBf72cc764844A62863e] = true;
	whitelistedAddresses[0x84b9bd7d7332b09513A057e36B48b1aAeD94D52a] = true;
	whitelistedAddresses[0x78624bf8Ff566c13C57c57cf842D371eAc41247A] = true;
	whitelistedAddresses[0x7E71F62740E28D36404FCFB57b92BACd3aFf8B58] = true;
	whitelistedAddresses[0xE658fFE7081cE796864C06378dEDd22cB8c36e4D] = true;
	whitelistedAddresses[0x2F06d0bd0bDe0B146B7869ec9682Df6Ff681ef2d] = true;
	whitelistedAddresses[0x578a56240Da193b343ae1fCF626743e106234d3A] = true;
	whitelistedAddresses[0xC95141416EB8876f43AA6446B113fc6E8fBbe3e1] = true;
	whitelistedAddresses[0x83aa804917b7F984CC462f2729297699d10eeCC7] = true;
	whitelistedAddresses[0xBfBD39FFaDeF4D7C194D8638109Ce7ce3B7A343b] = true;
	whitelistedAddresses[0xA7d0F48F35500E36C21E2835897a1Ca61005AD35] = true;
	whitelistedAddresses[0xA14a51940772e4399738AFb9E963A71421e9718C] = true;
	whitelistedAddresses[0xb3e2EFfFD8d40e07d544829Fc6bC1941FBA75217] = true;
	whitelistedAddresses[0x391DeE22EfE97779d289b2E3a9E5722Cc9127721] = true;
	whitelistedAddresses[0xe83F35eaaB332d0767B14aCE6D5bf84f28a5087B] = true;
	whitelistedAddresses[0x6D67A64605A614b795AF0358744eA1d1810AC86E] = true;
	whitelistedAddresses[0x7e786887EbfB180C3d67eF4644d056B06870B719] = true;
	whitelistedAddresses[0x32f45E22f2E7F9D352Ec6a32cf4dAe24EF84D720] = true;
	whitelistedAddresses[0x770ABEFB4B1f627eF2E642b2a5dB52b5359428C3] = true;
	whitelistedAddresses[0x7E332dA781F8efD1ACe3063a05E9f4f75DE45798] = true;
	whitelistedAddresses[0x1B9dD15D6929225De4878F1b0BDB21DFe964Ef07] = true;
	whitelistedAddresses[0xb5c892D2c273687f5d21bbAaad2F11080c707938] = true;
	whitelistedAddresses[0xc6f7E9aEe3896c12AF61C5B554Ba8a68612DD6a9] = true;
	whitelistedAddresses[0x0691d92efacdc8E747E4a175d7664a8F05FAb7A2] = true;
	whitelistedAddresses[0x24eEaFA9a0cDA52675596409791b0999470e6Df4] = true;
	whitelistedAddresses[0xb813c137CaB598070b9206e37CE1132B974c9195] = true;
	whitelistedAddresses[0x5B88AE171482c0b4416aC87C314D4C725DB58231] = true;
	whitelistedAddresses[0x853A6A249676cd87d2d7DABa9B292548D9693acC] = true;
	whitelistedAddresses[0x13D6240A4a332B71f403533FaB10ee7bd205f1b8] = true;
	whitelistedAddresses[0x887CA9F8a3b4Cb01F0aE817e7b0c0D3CEE6B63c3] = true;
	whitelistedAddresses[0xf128298653003c8A4b5A90e8eb8Dc070A60C53A2] = true;
	whitelistedAddresses[0x6883ca7111B467B548f592c936c88ccb6060DA20] = true;
	whitelistedAddresses[0x9184586eA0472ca135Dc84490Cbbb2948bC38eaB] = true;
	whitelistedAddresses[0x0Bd9fF70fa74A7F51278c17144ccac45F1E9f606] = true;
	whitelistedAddresses[0x921FF22C7661564B921196Fe4E4935BbCA9E8503] = true;
	whitelistedAddresses[0x220B0C98502e7ed784af8a7128d6c79e5C60f69a] = true;
	whitelistedAddresses[0x4E6A254f752a05F5f3244F32403E82D380641268] = true;
	whitelistedAddresses[0x7d4AED893b64B19A52C2c081d85fca3031CB4161] = true;
	whitelistedAddresses[0xd90C830A84858Df54Ac2BfcF00498D8c4109A1CA] = true;
	whitelistedAddresses[0x1456f0008DD456A802B241A1A255F013E2d4004d] = true;
	whitelistedAddresses[0xb8AA65Aad8a6F5927Bd81b4e44920dBA2bA1CE96] = true;
	whitelistedAddresses[0xC885B93b389d6F515FcdD7FCA4C7f5fd5D16FFCA] = true;
	whitelistedAddresses[0x2cc8023280FBb312355615cc766253CaF9d9264e] = true;
	whitelistedAddresses[0x83ae28327E7453ec5B2df98dc3440D373745ae98] = true;
	whitelistedAddresses[0x9984128A70C8Ad5e14490D02f118671684b93578] = true;
	whitelistedAddresses[0x727C73158939F0F1fC840185f1Ffd30c20478470] = true;
	whitelistedAddresses[0x982C8cE160241AcbD5C30E2dD0A56aAf6b4f3BaA] = true;
	whitelistedAddresses[0xca5adB7DeFbaB8Cc964e0651C9992200137e4C43] = true;
	whitelistedAddresses[0xDc9723058EBB03874f2A2f9e7a5e87665807966C] = true;
	whitelistedAddresses[0x3679Fe5ac355e22f40F82334CE7123d9b71894C4] = true;
	whitelistedAddresses[0xdf77e53554F5257EC98EA39B40754b39CC83cbA5] = true;
	whitelistedAddresses[0x1aaB5Fb8Fd3d5709597bd3AE59eDCe8e2d16865C] = true;
	whitelistedAddresses[0xA0600f1104B0601C0f2aAF51C38856d04c84F2c7] = true;
	whitelistedAddresses[0xF595b092e9373Dc8e6c29bc68543679A40Aa00A8] = true;
	whitelistedAddresses[0xB643952a9294c6548f305fA238af43254D08F511] = true;
	whitelistedAddresses[0xc4cbE817E58879adB5Dbf8f3FB5fA9E6d6AA3620] = true;
	whitelistedAddresses[0xF2334830B056b826f1aB4c7C5e13F67AB5aB4012] = true;
	whitelistedAddresses[0x38C388a562e3C9a47A51047a2ff16EB9047BE449] = true;
	whitelistedAddresses[0x11a46C0c09b0Cd44b9bd6056b21609a52bF004a9] = true;
	whitelistedAddresses[0x9C0D506Fa80f90Fc3a10E813fB8C4a3Da00f40C9] = true;
	whitelistedAddresses[0xB673773fc860Fc95e96311274535EA3fCD763c46] = true;
	whitelistedAddresses[0xCbe2862a650B374e63e0eC7A28cFa43410703207] = true;
	whitelistedAddresses[0x17A123aea8B09f25E7CF0413263aBD64Ab1cB1c7] = true;
	whitelistedAddresses[0x509Ea1EEdD779E7E10dAD4EB52CEfC9273c7e6cC] = true;
	whitelistedAddresses[0xa4cdfbdEea825B9D58169E72C2A486F42d42127B] = true;
	whitelistedAddresses[0xe7D93b2657d9862Ed28FaA7f26DB3e698eAEBD5e] = true;
	whitelistedAddresses[0x2F4277Adbd3E7129098368D44ccABA112c9b35e6] = true;
	whitelistedAddresses[0xD458d77a13530B958cE3B6fD2Ae5d23FD4E20Ce7] = true;
	whitelistedAddresses[0x2c532fB45F9418eF31a41F3072f443faff441168] = true;
	whitelistedAddresses[0xE7a48f8EA30E0CFC00a20F3964C03bd8D3e06DA6] = true;
	whitelistedAddresses[0x0b136DDa5D64AF573567CC6ce3534cc91f1F8d34] = true;
	whitelistedAddresses[0x185af0C73551FEC32E2b2154c64ABfa4d392c5E7] = true;
	whitelistedAddresses[0x28514C52d04D12A1E4ebA1d98C9605ed99291580] = true;
	whitelistedAddresses[0x40C25AD3b62e9ad5A11Df6ED978C432c5Ddb3A31] = true;
	whitelistedAddresses[0x6Ac6801DDdc817e06201fA48556d3DDe52FD18Ce] = true;
	whitelistedAddresses[0x9CD0Ff5A23a23f6de14a1B6Fe8F09D721Af6104f] = true;
	whitelistedAddresses[0xA546DF9a11D6DF9bF56acB46C65f72C714D84649] = true;
	whitelistedAddresses[0xAAa33bC534d77f84a16DA0C93BF5c19537907244] = true;
	whitelistedAddresses[0xb0d45F2Bb57ED4B679206Ba4bb627B406cd2CE8C] = true;
	whitelistedAddresses[0xfCb0F579B5cFE42A3a5B931C5AF8932F6FBC698c] = true;
	whitelistedAddresses[0xCE55EC76FeDCB3F3814eba91fc1AEeE8f7Ad7C29] = true;
	whitelistedAddresses[0x11986FBAe765B25D9d486999F016ee72AAe5649E] = true;
	whitelistedAddresses[0xB24CC78305fa4B2ed7b09A23552C62Af415bBa60] = true;
	whitelistedAddresses[0xE5839E94f45e97E5Ada0a9fa991389570bc7A13A] = true;
	whitelistedAddresses[0x66eb0e5386c8aF5364358E80D512f3293064cAd6] = true;
	whitelistedAddresses[0x31d4d01132B420A0f8200dC40ADDeb6ce5D361de] = true;
	whitelistedAddresses[0xeB42fe51d2640c72385ecb4b66645EF03cdD9fB8] = true;
	whitelistedAddresses[0x39653cf603E73bE07600Dee9eF01Ce215B948Afc] = true;
	whitelistedAddresses[0x6806419dB23da81AF4eF14833B933330Cee60010] = true;
	whitelistedAddresses[0xC4C139b95A9415371295811ABF617c90B7E5D623] = true;
	whitelistedAddresses[0x6F780FF10A7101eC078505180B499ca171235935] = true;
	whitelistedAddresses[0x66Fd29f32f5E83BCe1e7964D2Ed501432614d44F] = true;
	whitelistedAddresses[0x35cf437Fe5a0Ab92eA192Aa9512c2b6ef65558dc] = true;
	whitelistedAddresses[0x9Ed499f1C6C89819f3cA35423bB69B858E089c56] = true;
	whitelistedAddresses[0x09b5ac8390b393021765eC8d0a167199fF9e88E4] = true;
	whitelistedAddresses[0xBDD21e5EdBe898d6bf3dc20dc324e67b5F353fc7] = true;
	whitelistedAddresses[0x75F4d08FC5FF8751465AC1525cF33344FF0BE8E2] = true;
	whitelistedAddresses[0x78f7Cb98cDCdB21fe877A07Ae18b35aA81759879] = true;
	whitelistedAddresses[0x56335042997Ce36a023d13e46D4193Eee6745b1d] = true;
	whitelistedAddresses[0x1061935F35f5A219cC691A1e4c2D8a030457C6D3] = true;
	whitelistedAddresses[0x2efAbE4b76A5E65D504c7E927E39baEb65085FDd] = true;
	whitelistedAddresses[0xD9fFea6f4ABbe74EeD8d851aF821284042922eCA] = true;
	whitelistedAddresses[0x89C14c0b33A02CAd6c4e11C7F36e05008Ce323cf] = true;
	whitelistedAddresses[0xF49881d302d17698b2A0545851ae1fA5aAd62fa8] = true;
	whitelistedAddresses[0xbB3Cb5Ffc56Ad59cb192333B63C0cfFd745E7D49] = true;
	whitelistedAddresses[0xec18952Bcd149CC244A09e1999B6a9699F9Fb182] = true;
	whitelistedAddresses[0xE6889c21AB623a26Aab2Fc52161FC43D87c3bfe3] = true;
	whitelistedAddresses[0x6572bd40146EfD4dD8B2D8A3fea457319F965935] = true;
	whitelistedAddresses[0x83F32D10C45B8326958f1BF688468b4e7b8FA988] = true;
	whitelistedAddresses[0x23D5D420272dc71735A06D9D8cfa655F68BEE48f] = true;
	whitelistedAddresses[0x535D106A3f06117267d5c745eAA4938FC51e990B] = true;
	whitelistedAddresses[0x7541Cf1304E4f7D39cc4Caf840FEdD959684F71D] = true;
    }


    modifier onlyOwner() {
        require(msg.sender == perSaleOwner, "ONLY_OWNER_CAN_ACCESS_THIS_FUNCTION");
        _;
    }

    modifier isWhitelisted(address _address) {
        require(whitelistedAddresses[_address], "You need to be whitelisted");
        _;
    }   

    function endPreSale() public onlyOwner() {
        uint256 contractTokenBalance = token.balanceOf(address(this));
        token.transfer(msg.sender, contractTokenBalance);
    }

    function buyToken() public payable isWhitelisted(msg.sender){
        uint256 bnbAmountToBuy = msg.value;
        require(boughtAmountBnb[msg.sender] + bnbAmountToBuy <= 2000000000000000000, "it exceeds maximum amount");
        require(bnbAmountToBuy >= 200000000000000000, "MINIMUM BUY : 0.2 BNB");
        require(bnbAmountToBuy <= 2000000000000000000, "MAXIMUM BUY : 2 BNB");

        boughtAmountBnb[msg.sender] += bnbAmountToBuy;

        uint256 tokenAmount = bnbAmountToBuy.mul(rate).div(10**9);

        require(token.balanceOf(address(this)) >= tokenAmount, "INSUFFICIENT_BALANCE_IN_CONTRACT");

        payable(perSaleOwner).transfer(bnbAmountToBuy);

        (bool sent) = token.transfer(msg.sender, tokenAmount);
        require(sent, "FAILED_TO_TRANSFER_TOKENS_TO_BUYER");
        
    }

}