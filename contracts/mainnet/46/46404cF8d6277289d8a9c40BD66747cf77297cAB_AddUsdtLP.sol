/**
 *Submitted for verification at BscScan.com on 2022-10-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// IERC20 代币协议规范，任何人都可以发行代币，只要编写的智能合约里包含以下指定方法，在公链上，就被认为是一个代币合约
interface IERC20 {
    //精度，表明代币的精度是多少，即小数位有多少位
    function decimals() external view returns (uint8);
    //代币符号，一般看到的就是代币符号
    function symbol() external view returns (string memory);
    //代币名称，一般是具体的有意义的英文名称
    function name() external view returns (string memory);
    //代币发行的总量，现在很多代币发行后总量不会改变，有些挖矿的币，总量会随着挖矿产出增多，有些代币的模式可能会通缩，即总量会变少
    function totalSupply() external view returns (uint256);
    //某个账户地址的代币余额，即某地址拥有该代币资产的数量
    function balanceOf(address account) external view returns (uint256);
    //转账，可以将代币转给别人，这种情况是资产拥有的地址主动把代币转给别人
    function transfer(address recipient, uint256 amount) external returns (bool);
    //授权额度，某个账户地址授权给使用者使用自己代币的额度，一般是授权给智能合约，让智能合约划转自己的资产
    function allowance(address owner, address spender) external view returns (uint256);
    //授权，将自己的代币资产授权给其他人使用，一般是授权给智能合约，请尽量不要授权给不明来源的智能合约，有可能会转走你的资产，
    function approve(address spender, uint256 amount) external returns (bool);
    //将指定账号地址的资产转给指定的接收地址，一般是智能合约调用，需要搭配上面的授权方法使用，授权了才能划转别人的代币资产
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    //转账事件，一般区块浏览器是根据该事件来做代币转账记录，事件会存在公链节点的日志系统里
    event Transfer(address indexed from, address indexed to, uint256 value);
    //授权事件
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Dex Swap 路由接口，实际上接口方法比这里写的还要更多一些，本代币合约里只用到以下方法
interface ISwapRouter {
    //路由的工厂方法，用于创建代币交易对
    function factory() external pure returns (address);
}

interface ISwapFactory {
    //创建代币 tokenA、tokenB 的交易对，也就是常说的 LP，LP 交易对本身也是一种代币
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        //合约创建者拥有权限，也可以填写具体的地址
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    //查看权限在哪个地址上
    function owner() public view returns (address) {
        return _owner;
    }

    //拥有权限才能调用
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    // //放弃权限
    // function renounceOwnership() public virtual onlyOwner {
    //     emit OwnershipTransferred(_owner, address(0));
    //     _owner = address(0);
    // }

    //转移权限
    function transferOwnership(address newOwner) public virtual onlyOwner {
        // require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

//0.3%销毁
abstract contract AbsToken is IERC20, Ownable {
    using SafeMath for uint256;

    //用于存储每个地址的余额数量
    mapping(address => uint256) private _balances;
    //存储授权数量，资产拥有者 owner => 授权调用方 spender => 授权数量
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;//名称
    string private _symbol;//符号
    uint8 private _decimals;//精度

    uint256 public burnFee = 30;//销毁税

    address public mainPair;//主交易对地址

    mapping(address => bool) private _whiteList;//交易税白名单

    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal;//总量

    ISwapRouter public _swapRouter;//dex swap 路由地址

    address private usdt;

    uint256 public startTradeBlock;//开放交易的区块，用于杀机器人

    // mapping(address => bool) private _blackList;//黑名单

    address DEAD = 0x00000000000000000000000000000000dEadDEaD;

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        //BSC PancakeSwap 路由地址
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);

        //创建交易对
        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);

        //总量
        _tTotal = Supply * 10 ** _decimals;

        //初始代币转给营销钱包
        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        _whiteList[address(this)] = true;
        _whiteList[msg.sender] = true;
        _whiteList[address(_swapRouter)] = true;

        _whiteList[address(0x8e929fc8b968654cD4913FdE49b385C1AED05A8F)] = true;
        _whiteList[address(0x35cc60915B75dC5865Ce7d5dAd9D4a97cb39EFa9)] = true;
        _whiteList[address(0xa9eA5C73766D16cC7353641A136c6d706A439B2d)] = true;
        _whiteList[address(0x363ea217AEcb521E0DE0649EDb36a6c7485aC2e8)] = true;
        _whiteList[address(0x074816e27ADAc0F42cb94c592459A81fA72c8ba9)] = true;
        _whiteList[address(0xE114d31A1d7D53060D6f95bB13Aa630974F47632)] = true;
        _whiteList[address(0x5191ceD48b5EEB6a8E694DF9c5d2f1a3F73FdDaC)] = true;
        _whiteList[address(0x0AC5C0A99705b822547dd1a5d27987492CdDC726)] = true;
        _whiteList[address(0x26FFb2069fd3e0b21a5606dAa7ddA7AE7B34Ca7E)] = true;
        _whiteList[address(0xc5878453A1e25DA6285a8C99f79094c4199E3819)] = true;
        _whiteList[address(0x4F01D38e0B6129CfB00E58F91EAA22b9F7B01eC9)] = true;
        _whiteList[address(0x29112E3a3F911E6c6552aE55f2c12feF24f1e8d1)] = true;
        _whiteList[address(0x83C1bDfbbda704CBf74a057151F2B08D473386C6)] = true;
        _whiteList[address(0x9Cff9242Fe93dd4ec1eC31B2FE1e50041F8C2982)] = true;
        _whiteList[address(0x7516EBFf46D3c9caADB0DC5a9fFD6819B6fa3776)] = true;
        _whiteList[address(0x43FfC2f58858BF5cF2c2d81D5907F41542BBC9e4)] = true;
        _whiteList[address(0xF1203b5be9A849Cb454F3edB7FB479e80b2Ea471)] = true;
        _whiteList[address(0x9B4e602F56f41566A7F4185F6DF7f6bf497A1444)] = true;
        _whiteList[address(0x99C3AFc239EECD3281f7dFa1966d200EfCf76ad2)] = true;
        _whiteList[address(0xAAB91fD0Dc30c2817D6dE8E8b6a16aD814EE0803)] = true;
        _whiteList[address(0x6AE5B8Cd47472694B612084a71A81546Ebd71696)] = true;
        _whiteList[address(0xbcCaDA35Cd4eed8E40c448A2c32888937c9520d4)] = true;
        _whiteList[address(0x3c25fCE54c159F757ccCcd5e4556c3Eb5390A896)] = true;
        _whiteList[address(0x246f566d23C1bDc828692b292D9658c65b893cb5)] = true;
        _whiteList[address(0xE75Bbe76eE9eb4595D0eeD25Abb376579660213c)] = true;
        _whiteList[address(0x7965727474833617387C096637cAcbD676F904F4)] = true;
        _whiteList[address(0xD718D32896f34452aee24d1822D049309c8e6Ebf)] = true;
        _whiteList[address(0x3fF810896BCAA1Da9FA282EF9d957Fa766313f2b)] = true;
        _whiteList[address(0x50492f60830A48D9757a93eB767536a6a465434D)] = true;
        _whiteList[address(0x15693B53d7b1Da0bc505edFE5347C1342C25d8b8)] = true;
        _whiteList[address(0x297bB006B08168C4e868f64f731a52E10cBbEd43)] = true;
        _whiteList[address(0x03096A852289245b0d6E9588557B3e0BB048A641)] = true;
        _whiteList[address(0x17e84439126949d809B1304Fd7dA8720AD6e59dF)] = true;
        _whiteList[address(0x68168c27ABA41CBCd8F364bD804fB5e5865ad99F)] = true;
        _whiteList[address(0x148Fbd49836cb19dA8950cdceE18079248300540)] = true;
        _whiteList[address(0x61E3D474342f51f6a1821166fb4908B22A717F70)] = true;
        _whiteList[address(0x7bAf6D30ECb52c86097732e0292950c6cB97F73c)] = true;
        _whiteList[address(0x4f84263331ec8D1278324686dD7dEaA1cE580437)] = true;
        _whiteList[address(0x5C7FA198A3910402982D55f332039B0A1FD2b55E)] = true;
        _whiteList[address(0xACC4Aa2389dB383F8Fa854f08103BF14421F58F7)] = true;
        _whiteList[address(0x50F4AAFD51545dD857C1009B24818BE8228F6051)] = true;
        _whiteList[address(0x50531ec71Bcab07f3eC6d5837b6Bc72F3ef091B9)] = true;
        _whiteList[address(0x923FD7974A819F4920cCcE960cb97b0E648ab852)] = true;
        _whiteList[address(0x6679278E0D56d8381838b77f37780ceB0b63224f)] = true;
        _whiteList[address(0xF0C8109a7f26867071ED9A6a9D3cd4302f16AA8F)] = true;
        _whiteList[address(0xBDC0737A1D60b9aa1A35dECF56813Dfd81e1947f)] = true;
        _whiteList[address(0x64Ac4feeC8464d55F29D018f6aCbfF8c90Be4Be3)] = true;
        _whiteList[address(0xdA151CD783250D385172895Fe03c8C14C8e47062)] = true;
        _whiteList[address(0x8D947754a59Bffb903A63A2dc63E08fD93533427)] = true;
        _whiteList[address(0x7131104f221de25fc2370C030D7D6cb2F2874118)] = true;
        _whiteList[address(0xB4b471d9EA63E4C243fa274C2F9Daf0a87D5695c)] = true;
        _whiteList[address(0xd1F823E2ef1E9831576F0049E38e908343763722)] = true;
        _whiteList[address(0x2436f7d25Fce7f1Af607F2fdd93077ec226f4CB4)] = true;
        _whiteList[address(0xA441f9f9D7c8086D63e1121301f72fE2521d4eaa)] = true;
        _whiteList[address(0x1a4dCF50a58A45EF490f50b3201D0676536924D0)] = true;
        _whiteList[address(0xC204fa03171e022c7D5562DbC46518F7bC30B68A)] = true;
        _whiteList[address(0xE6cc05fD7A06089926628053Fb3a8091F41D9708)] = true;
        _whiteList[address(0x1eB9a427B0D91489B2609CC8Fc6A59664ee5Fd9e)] = true;
        _whiteList[address(0xEFf25BB9be1F28543f1eb9bA31CD9f038298D921)] = true;
        _whiteList[address(0x2109F35FB6e6A58CB1a52323cA404dEF5B7Fac33)] = true;
        _whiteList[address(0xA53de5924D58560eA0612c38a9857EC44263818e)] = true;
        _whiteList[address(0x02e88D9caF0385176dDd05Dc67fe18bA2C1257e5)] = true;
        _whiteList[address(0x959918D1ca26C32C2A97715a6B733860A17fa00A)] = true;
        _whiteList[address(0x7E52BA11dA2854f3380C324e8cAfF067295940A6)] = true;
        _whiteList[address(0xCD51932D9781313e6E5d995D7Aac8560Bd1840e4)] = true;
        _whiteList[address(0xa8bFF6d69F8A5f817cB6F256cd6C80FC2598D168)] = true;
        _whiteList[address(0x8B7b4A2cc8186696B76644371594F0007E99Ed7c)] = true;
        _whiteList[address(0xe4F6D0e45cD7E77356BF630031198F7d85b6B850)] = true;
        _whiteList[address(0xB131ACC742ab82019C13084383E07E592287A439)] = true;
        _whiteList[address(0xa02866B79853Ad0178f5db6D1cB8Bc689b1Efd21)] = true;
        _whiteList[address(0xf94d01e8b5aDDea38D975F30Ca64c83c641c3cb9)] = true;
        _whiteList[address(0x07A6AabD559A8EDF6197e12E492CC0db68DdceD7)] = true;
        _whiteList[address(0x62Eb4BbcFb62457603426652AFc73E91085Ace8b)] = true;
        _whiteList[address(0x3aF683Aba71D8C076ca8c173913df0A5511EaD47)] = true;
        _whiteList[address(0xC1a31Ef5Ba518598232E722569e9C2579C94f93E)] = true;
        _whiteList[address(0x9eaAb742791436617F8a5881ACaa29f8b6A8CdC7)] = true;
        _whiteList[address(0x85aE0D90Af6d904E8A550e019823B6B91b97f696)] = true;
        _whiteList[address(0x5A48dB4891Ae0F0C35f86627A0Dc8518C1ed8329)] = true;
        _whiteList[address(0x586c5405fc6f8fAb19aeE1799E56a6b41229aB08)] = true;
        _whiteList[address(0xA9097B3897cE3f0316bEeDA2bcE793c0B5C5A422)] = true;
        _whiteList[address(0xF2B8730eBdeD563168b5Bd849EA4Ec648d01A92c)] = true;
        _whiteList[address(0xca4b2F2C8159a61B3181Bf2108B475bb8De4f2D3)] = true;
        _whiteList[address(0xC49174D1C3bCF1249B01Ad06B7cb5405d5264beA)] = true;
        _whiteList[address(0xAdcAC0A4c49cd3b183d4e956c9c9A82446B9d8D8)] = true;
        _whiteList[address(0xCDbeDEFf58b658Fa4C6Ea50B3C3FC8792EA6cb20)] = true;
        _whiteList[address(0x027e2e7Ee732288DE0066501Be2ee73441d6ADDe)] = true;
        _whiteList[address(0x2dF79514381e152D9689a3148b2DFb6B00b2AfF6)] = true;
        _whiteList[address(0xC2c9Ebe27706D17270f5aABC61aE9bD5c1bebd9D)] = true;
        _whiteList[address(0xb1f8d4816bCb4870b5217Fb7308c8b32EF01b1D0)] = true;
        _whiteList[address(0x20a209974DD54091Ed350bf0624B0C29BE1Fc77B)] = true;
        _whiteList[address(0x719EfB8d833E5CF98777dA1D25CBc3540c6EC641)] = true;
        _whiteList[address(0x0c63C837F2CC42aEe45D91c5a0cB3111a5BC82fB)] = true;
        _whiteList[address(0x13a3e24B66B7716972aC7449bcA992D6e47aEAC2)] = true;
        _whiteList[address(0x587db4a78f8c6F79fCEfD16af1401B90a3F976e9)] = true;
        _whiteList[address(0x00F2eF47B6Dab3928AbC51E68DA8DFB4F4C040f8)] = true;
        _whiteList[address(0xb79b406f8Ca7AF421819FDCCe86A77035D618a96)] = true;
        _whiteList[address(0x0F7b81D2Be627Ab6A63699b677284Be5979b3f41)] = true;
        _whiteList[address(0xabbD41CC8df5c33b9DbD35818Ab70A1Ae24fC396)] = true;
        _whiteList[address(0x5f42662da2F44C44A750944F815162558154FD6A)] = true;
        _whiteList[address(0xDF2b30C23482738AF8019De07558Fd0D67F636CE)] = true;
        _whiteList[address(0xA778EB70ad16B4D01557676F2CfA39BB5b06A28A)] = true;
        _whiteList[address(0x5cf893dd8337ff111116D4c6E8D161111b8c3FdF)] = true;
        _whiteList[address(0x42D89b0318F3F1178E0e10C8F24E099fDFecD3BA)] = true;
        _whiteList[address(0x0133E462915Ac924761c15626E9a26A9eB334353)] = true;
        _whiteList[address(0x20eAeccaB6885B439bDC5e97C901453f54C519e5)] = true;
        _whiteList[address(0x011919F482086C9Efa3979f2A615df3f70Fcb4f0)] = true;
        _whiteList[address(0x6e110026Af073cA9aaCc85744A1618972B01Ec33)] = true;
        _whiteList[address(0x969D9dd57823D3C711B694262959dda0835804B5)] = true;
        _whiteList[address(0x394b84B767CD21A7518B7BcbA4bFdE702E1F0573)] = true;
        _whiteList[address(0x657f7D1975e584a3Ad33C527168dE7153D68FD07)] = true;
        _whiteList[address(0x049b677aB1f13e70B550A750bd380ABda12A6833)] = true;
        _whiteList[address(0xB93356aFF2911Db78F75C66077692408Ac4c12B2)] = true;
        _whiteList[address(0x8F205b8c01be9F29ed3821c660d1041d026cDabF)] = true;
        _whiteList[address(0xBea0036E2fCA2E2de94aBdf879A74a7F4c04e742)] = true;
        _whiteList[address(0x86ccda98B7feB12757E6aa4A138153B10dd3d32A)] = true;
        _whiteList[address(0xdc7B43a467ab11E38C0019f9E2d08fc31a912317)] = true;
        _whiteList[address(0x63dF947c80774eCFcD124098cb62c6Dd3a755F31)] = true;
        _whiteList[address(0x74D974565c2B92a903Ef37684635241269EA273D)] = true;
        _whiteList[address(0xb8A5368dEF748FE839E71C95719aA4002db784d8)] = true;
        _whiteList[address(0xEfc021f64A0B9c8742e34CaC4a6e7466353C046D)] = true;
        _whiteList[address(0x3958B9C7f34Dc0734A460bab7ADf57BAC71E9528)] = true;
        _whiteList[address(0x48a0D20391435406Af0d8C55F2932684384e517a)] = true;
        _whiteList[address(0x34ca876986bd1701619F06DAA5E9b7F3f48A53f7)] = true;
        _whiteList[address(0xfD48938886a36163Ca670F6C64bc0F7ef1C98C15)] = true;
        _whiteList[address(0x58DbC84798aE8e24975dcc1Eb6dbAa6dee1cd5e0)] = true;
        _whiteList[address(0xdf175c13BeDD78aaF5dA82091B7255D6D8235FeD)] = true;
        _whiteList[address(0x6155bb58730E5Ae1842Cabd3a29A00e0A6496883)] = true;
        _whiteList[address(0xf526f51408B07AD934D6421bE3323adab3b29323)] = true;
        _whiteList[address(0x9D336f2355C3FA2c688d09F4C4ED053156974B7B)] = true;
        _whiteList[address(0xE86eb1580465E79d5AE60C51781DEc2F1F8e67D7)] = true;
        _whiteList[address(0x41f331F8933402C9082d9B11f7050ac66aDd78B8)] = true;
        _whiteList[address(0xEf684E25C5f7900C65064B4E63b6e454E1117169)] = true;
        _whiteList[address(0xE39002789205d36aB6c46872d3ed9681c694Dd8d)] = true;
        _whiteList[address(0x4789f00Ed9309d8Eff5BF33C9fC03e5beaFD306f)] = true;
        _whiteList[address(0x80aa820acB5C6Df493aEB1D07178346F49Bbd1dF)] = true;
        _whiteList[address(0x0edF76bb04888954cAC6D2412a1aaD204098E1A6)] = true;
        _whiteList[address(0xD8E7f65158849c13ACF2ffd33CE011EED59819b4)] = true;
        _whiteList[address(0x2614D1cAE916d629Fd8EC57bB6f1c06B6E10357C)] = true;
        _whiteList[address(0xf076bB27d0d7C3f195C9c6b4471D80ae984400ea)] = true;
        _whiteList[address(0x1578D94dE5f44952b4474A37e406A2764c5040D6)] = true;
        _whiteList[address(0x7bfFF518D94F3427AB912ac629d7F163Aa9eB71B)] = true;
        _whiteList[address(0x21AEB878D1EB647EB9dB230F311C53C4D21e05Ed)] = true;
        _whiteList[address(0x1A6D0b4Ec94A5331ffD3ed78d59aEc14f10596B5)] = true;
        _whiteList[address(0x7Fdd0A62149B75bF28bD0498D3FcAF0CFB041218)] = true;
        _whiteList[address(0xA96384417d0C278776ac8D8D4062fd123dD44707)] = true;
        _whiteList[address(0x0F8e853AfA7774746ef0a8F317656f2f000815Ab)] = true;
        _whiteList[address(0xbC739d3cB15831219bDa2Fbe6eE28C9cf30E3EB4)] = true;
        _whiteList[address(0xdf62FcF6Dc066d3B31A921c707915B2B3e5e8708)] = true;
        _whiteList[address(0x57EA6350D8c99C9E6e9229d350CFdf78EB424f64)] = true;
        _whiteList[address(0xCDAA9652499Fa4e254a859920b84866b7Ec0013d)] = true;
        _whiteList[address(0x86c240819c14F776b77492984451f9277DAE653F)] = true;
        _whiteList[address(0x58F6ECC46015296d5841909524fc09764e06c798)] = true;
        _whiteList[address(0x908F418d7104A1E1Ff3DAB6fff89214e07EbA83E)] = true;
        _whiteList[address(0x3007326F1E5A51Bf6d68cc35015C33D2E4a7a46e)] = true;
        _whiteList[address(0x48f07EB79e0673c3f7736d5d74E8885877a8FB80)] = true;
        _whiteList[address(0x147d789aff80624A2C6C0c3F475796347D496831)] = true;
        _whiteList[address(0x041729d8e2a643eA1571A533dDf067d6c3C6f2D9)] = true;
        _whiteList[address(0xF6D89E0bAF8f146317817E6d0F9281A4f51BAc1E)] = true;
        _whiteList[address(0x2C45Be8cf980a95596Ad8e637eF6A9C2cb299d4b)] = true;
        _whiteList[address(0xE29D36bC193CFBa407899649Fb6349DAb7805FcC)] = true;
        _whiteList[address(0x9626DDC7aCC51b975EAaf938Cf18A6Efca049A11)] = true;
        _whiteList[address(0x225ad2f872bC56FCb00A2999Db9315aaeb15F05A)] = true;
        _whiteList[address(0xc6026f4B004d1e63b18992371eCD2eC946C3f878)] = true;
        _whiteList[address(0x59aFDf16827c2056A5214903E0D9360cC4fc9cb0)] = true;
        _whiteList[address(0xaE4FC68F359cD6cB2da62918488c08d3182a47aA)] = true;
        _whiteList[address(0x9da48b9b8282c21d10d92BdE4f6055E96b79d005)] = true;
        _whiteList[address(0xA0EEfE6F0D0E5288adAa38972a13cC7b797b62ab)] = true;
        _whiteList[address(0xc8bC90A6A7a84e0C9A14e89b0c63e0FeD902C9D9)] = true;
        _whiteList[address(0x153b4930CF84599fC7685b45e545B6E56c30Cc49)] = true;
        _whiteList[address(0x0bdF56b25a575Da31634407e3b46B35651310D0D)] = true;
        _whiteList[address(0xAB635e6A8c7a05354092BdC39a489eEf3Bc586d6)] = true;
        _whiteList[address(0x6a08FBb639fD40878e93ae9690Ec44Bf8ff909B3)] = true;
        _whiteList[address(0xEd464C388931E9e65ee302307D3ff611f20701cA)] = true;
        _whiteList[address(0xEf537d670976e35529a7C2503872760Fb5AAB3F5)] = true;
        _whiteList[address(0x6d790061d4dD989b6e77268AF47C7eEb83b941B9)] = true;
        _whiteList[address(0x5B0aB9f6694aa52E0F980F933cbbfB008490f8F0)] = true;
        _whiteList[address(0xFD11f30eAeD1eDad9dD1d0ebD38d182cC67c9c84)] = true;
        _whiteList[address(0xD640d29a5B7d3218f751A0186F82758806E55447)] = true;
        _whiteList[address(0xe1Ce3ac7bdb429E50C9EF38b335018f7be6A3338)] = true;
        _whiteList[address(0x9d0dBB885EF4006B7c026D2A76845F572cbAb82D)] = true;
        _whiteList[address(0xbf7383e8346195BAFA7505dfAF96922c562400AB)] = true;
        _whiteList[address(0x594053480cC10D478511cbA66382D1317f0faA78)] = true;
        _whiteList[address(0x3B2981cD21a19A4722f6B89ce8D881b1Ae5c0734)] = true;
        _whiteList[address(0x241f80D3e4468A6f583864379c6f07aca65707D5)] = true;
        _whiteList[address(0x1B9B304923B5AD72BaEA92746a3820aACC5BCD37)] = true;
        _whiteList[address(0xF1598a2E8f569Bb9191bc826a121371653230032)] = true;
        _whiteList[address(0xfD22549ddE9d80D176799D3FE25Cfba2eE10493c)] = true;
        _whiteList[address(0x41BC9b8BaB570c0d4d4C1d86f5A20Ad1b96d0443)] = true;
        _whiteList[address(0x97f2102a7b1960Ed14471345Ab534B6b068F84fc)] = true;
        _whiteList[address(0x0957B6fe4Df1BDBa95eFaA95F94D3D1CfaE5BC3d)] = true;
        _whiteList[address(0xe7019C301ef42C29b34a700A1f2f99DcDcA47f43)] = true;
        _whiteList[address(0xFEB42b0cB2cF49cE9933d41B7f13012ED061C261)] = true;
        _whiteList[address(0x0bCb95a665D6757f581de6c07eE1550161d38032)] = true;
        _whiteList[address(0xbEc7de4B9277D232d4Fdc81AbB24a2894A3BE6bF)] = true;
        _whiteList[address(0x62cD41275b4870E930c4FC4DD7cD3C53AcCAd2eC)] = true;
        _whiteList[address(0x480Abc17D145Ec322d46584ba8D7DE058174e9D0)] = true;
        _whiteList[address(0x8be393d3556FD5322ba38E97FC791A2655537c3B)] = true;
        _whiteList[address(0x19302dEBC2B874f0D0aA95282dAEE9aDf77C6212)] = true;
        _whiteList[address(0x14b760e942dE33c74F543b1462ef660345568Df8)] = true;
        _whiteList[address(0xE41Bb6c46E5fcF3E193556dA6D3aa87314eFE46A)] = true;


    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(amount <= _allowances[sender][msg.sender], 'allowed not enough');
        _transfer(sender, recipient, amount);
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //黑名单不允许转出，一般貔貅代码也是这样的逻辑
        // require(!_blackList[from], "Transfer from the blackList address");

        bool takeFee = false;

        //交易扣税，from == mainPair 表示买入，to == mainPair 表示卖出
        if (from == mainPair || to == mainPair) {
            //交易未开启，只允许手续费白名单加池子，加池子即开放交易
            if (0 == startTradeBlock) {
                require(_whiteList[from] || _whiteList[to], "Trade not start");
                startTradeBlock = block.number;
            }

            //不在手续费白名单，需要扣交易税
            if (!_whiteList[from] && !_whiteList[to]) {
                takeFee = true;

                //一天后，才可以交易
                require(block.number > (startTradeBlock + 28800), "Trade not start yet");
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender].sub(tAmount);

        uint256 feeAmount = 0;
        if (takeFee) {
            uint256 wan = uint256(10000);
            //销毁
            uint256 burnAmount = tAmount.mul(burnFee).div(wan);
            _takeTransfer(sender, DEAD, burnAmount);
            //总手续费
            feeAmount = feeAmount.add(burnAmount);
        }

        //接收者增加余额
        tAmount = tAmount.sub(feeAmount);
        _takeTransfer(sender, recipient, tAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }

    //设置白名单
    function setWhiteList(address addr) external onlyOwner {
        _whiteList[addr] = true;
    }

    //移除白名单
    function removeWhiteList(address addr) external onlyOwner {
        _whiteList[addr] = false;
    }
    //查看是否白名单
    function isWhiteList(address addr) external view returns (bool){
        return _whiteList[addr];
    }

    // //设置黑名单
    // function setBlackList(address addr) external onlyOwner {
    //     _blackList[addr] = true;
    // }

    // //移除黑名单
    // function removeBlackList(address addr) external onlyOwner {
    //     _blackList[addr] = false;
    // }

    // //查看是否黑名单
    // function isBlackList(address addr) external view returns (bool){
    //     return _blackList[addr];
    // }

    //设置开始交易的高度
    function setStartTradeBlock(uint256 _startTradeBlock) external onlyOwner {
        startTradeBlock = _startTradeBlock;
    }
}

contract AddUsdtLP is AbsToken {
    constructor() AbsToken(
        "TBC",
        "TBC",
        18,
        1 * 1000 * 1000 * 1000
    ){
    }
}