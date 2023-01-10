pragma solidity ^0.8.12;
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';

contract TayarraStorage {
    struct Vars {
        mapping(address => bool) whitelistedAddressesForClaim;
        mapping(address => bool) whitelistedAddressesForPause;
        mapping(address => bool) whitelistedAddressesForFees;
        mapping(address => bool) blacklistedAddresses;
        mapping(address => bool) claimedRewardAddresses;
        mapping(address => bool) nftClaimed;
        mapping(address => bool) presaleRound1Claimed;
        mapping(address => bool) presaleRound2Claimed;
        mapping(address => bool) vipPresaleRound1Claimed;
        mapping(address => bool) vipPresaleRound2Claimed;
        mapping(address => bool) vipPresaleRound3Claimed;
    }

    function vars() internal pure returns(Vars storage ds) {
        bytes32 storagePosition = keccak256("diamond.storage.AccessControlUpgradeable");
        assembly {ds.slot := storagePosition}
        return ds;
    }

    address constant MARKETING_WALLET =        0xe44a66C45C33021E0d2E98Cb3a7368E18e7813F4;
    address constant DEVELOPMENT_WALLET =      0x49B2c763aa0c22d0446b581D551FE58fee29b633;
    address constant LIQUIDITY_WALLET =        0x09b76532bDC76F4a7f3b9b5fA77553b7EcC620B2;

    address constant ROUTER_ADDRESS_MAINNET =  0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant ROUTER_ADDRESS_TESTNET =  0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

    
    uint256 constant MARKETING_TAX_BUY =        3;
    uint256 constant DEVELOPMENT_TAX_BUY =      3;
    uint256 constant LIQUIDITY_TAX_BUY =        0;

    uint256 constant MARKETING_TAX_SELL =       4;
    uint256 constant DEVELOPMENT_TAX_SELL =     3;
    uint256 constant LIQUIDITY_TAX_SELL =       0;

    
    uint256 constant CURRENT_PRESALE_ROUND =     1;
    uint256 constant CURRENT_VIP_PRESALE_ROUND = 1;
}

contract TayarraCoin is TayarraStorage, Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, PausableUpgradeable, OwnableUpgradeable {
    
    constructor() {
        _disableInitializers();
    }

    IUniswapV2Router02 uniswapV2Router;
    IUniswapV2Factory uniswapV2Factory;

    function initialize() initializer public {
        __ERC20_init("Tayarra Hub", "THUB");
        __ERC20Burnable_init();
        __Ownable_init();
        uniswapV2Router = IUniswapV2Router02(getPancakeSwapRouterAddress());
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());
    }

    
    receive() external payable {}

    event ClaimReward(uint256 nftReward, uint256 presaleReward, uint256 vipPresaleReward);

    function claimReward()
    public
    returns (uint256, uint256, uint256) {
        require(!isUserBlacklisted(_msgSender()), "You are blacklisted!");
        address[54] memory NFT_WALLETS = [0x057Aff91847Ac9DCD143805C3EA45E73517032B1,0x192c883a93F853D38640B1d7224472Dd71f2769B,0x19a6d28FE9942Ab02E674a4CbD11BA49562366DD,0x2d6305803a4B79B51CD773100Ec1CD40C1f7C397,0x2Db2deb9161F93A2579357E9a84db6A912F0dC58,0x346464ca770DB5D8349b3D1000d59A838e57070e,0x362d614D2cf2F34AFa94563882f60E45AB4A8a4d,0x3bD2bF83f8C77Dd991e1eb591a354A708694A181,0x420EB26eA0a5dB152dfD4a172D543Dbb98f2e514,0x422a3524DBe79f401fb5fCAAF43C8AF3fdd3F408,0x58175D33774aDe676E459448d0Bd0178DBf86544,0x6315C34d8E423c254b0D9eea0e9Ad1C9fD1589Af,0x6E56aC1A6BbFe0aF404c52413E6e60e8038Cb205,0x71619A7f0e077F8dE84027f59207C7c9c93e3eEc,0x74285833ab9054f413028B3B60bC64e1b9105272,0x747446215E3756993B8ED5a5524F810E0dC396b8,0x75c1167E8C67C8E2C7f05e54432a4059e65BCed6,0x80A7FACd872186047CE21A88555Ac9b1F6fd2b97,0x8518869FF07Bb25d43695A82f4D724BE04dBab57,0x88De39ECEa5CC4bF4d504eb29921387426f60E3C,0x8CAc449b052EBB35A3cFAb552709571Ab4c9E81B,0x8D8550B2a087Ea5C38f3ECE4b8b3f7D9bb330FC6,0x9A276F44A5e8DC521E11fd9C60d5b9aDd95A5963,0xA69a93dee2f028B5E62Ca9Bb7C3123839F54d9A1,0xA74f3043d42df45b9B4552EdA77778C389086bAE,0xbdeB4D3BD9E380f6B0A4A70b4b0Adb8394884B54,0xC2D00A14911F1Fd1aff37f5B09907F119B85A4F8,0xc5E7e396bc341265B27e60e494F437AdF6625814,0xC84163844272e3FcEF69BE3A77f35Dc33F9343B1,0xcDb3B54384460a3369C19FAbc386Cb719B2C1d1c,0xd3e39e6601C0e7EcA8e6e2048AA8200da567395A,0xd48A9ED8c06c7593566DbC83DCF37Db7bF456006,0xD620faA3e19D44a07005852b94b74A7Ec3B97Ce2,0xd8Cf2D540FD8Ee4D037a353eE10B93C361E43258,0xDE8a0403e814A894AFaD56649d782e983F68b50e,0xe2F68FD2df23A199CCD2544F9A13ea3a55935a39,0xe5E33C7BeDb8f9D0fd08d43eB3fc853D03472496,0xe67069D42B3802fd45429C42131DE35Cc9B2bf23,0xe6AacB8998b6Ec9A2fd0E7B97390863Bb9eA476d,0xE708dADd5750060a13094aB7eF95fF6f3Cecb4b4,0xEA0d9a8a3d521C7c1F0967b42d0384e84AA62D28,0xebe0794c3502fcAaE993Fc61d63F30D12EabE40F,0xeDC8f75B2C9f4aaBF6AcB709DC8e2bDD8C229792,0xf63bdD734ea8cdc8b43809C6541a2FBBCf056469,0xfB5848736A8c5Fd0ce22F3c460db630E09c383F6,0x2076117bE15A8469745700dA365b81663A9Cb544,0x4ACE00829D7571F39d258fd8c94e809E63595626,0x7Ae6C0B41CB8770531058C685EaB1e8a8b866115,0x7b9C4E5244382c78cE2FFc9fbB489b4361271149,0x9509E95a0d43C7F6cb42Df99BbE73340cfaA98D1,0xE921e3fE109402064C4eDE11862855B7473a1814,0x7863F87084F2a01cb6bD3E003eBbF030Fcb1FFE7,0x7bC8DdA12969F7874685F6604B51371DbA28f250,0xc25e36566868647a679c5e7B2A18F96fFff45a45];
        uint80[54] memory NFT_COIN_AMOUNT = [779301745635910000000,1558603491271820000000,1246882793017460000000,1168952618453870000000,2805486284289280000000,4909600997506230000000,15508104738154600000000,467581047381546000000,77930174563591000000,77930174563591000000,22599750623441400000000,155860349127182000000,77930174563591000000,42316084788029900000000,389650872817955000000,77930174563591000000,155860349127182000000,77930174563591000000,3506857855361600000000,77930174563591000000,1168952618453870000000,233790523690773000000,1168952618453870000000,77930174563591000000,77930174563591000000,1324812967581050000000,155860349127182000000,545511221945137000000,77930174563591000000,1168952618453870000000,779301745635910000000,77930174563591000000,77930174563591000000,77930174563591000000,6779925187032420000000,233790523690773000000,95620324189526200000000,77930174563591000000,857231920199501000000,26418329177057400000000,77930174563591000000,77930174563591000000,77930174563591000000,1168952618453870000000,779301745635910000000,467581047381546000000,467581047381546000000,2961346633416460000000,467581047381546000000,467581047381546000000,467581047381546000000,2493765586034910000000,2493765586034910000000,2493765586034910000000];

        address[29] memory PRESALE_WALLETS = [0x19a6d28FE9942Ab02E674a4CbD11BA49562366DD,0xD9aC63b9fba5cB64f536E232acEe4453dbD53D2D,0x5258D43E3FaA2F6794B31a32B130b6DFA707266f,0x8f1e2D101764CF619f05f3e1B8F1DF2E8C718902,0x2C0f07f859249bB8A8d647a6f167b3b50c9f224C,0x70a5931f13A1308f0B4eAC5F2A492eD84d20027F,0x08B8156CA9fFC05Df441dBCFd30800FEa596B181,0x49B2c763aa0c22d0446b581D551FE58fee29b633,0xD9b133f8C6984B337F5A235A902eA717699A5aFe,0xe44a66C45C33021E0d2E98Cb3a7368E18e7813F4,0x63fB612cfd13FF3096c4239e780D23B2A776824a,0xb7F0c1418C4a7c932f6be5d26DD3B9b57230574F,0xD51D87CA358c6Be3353D44376B739185d3763ECC,0x22C529942B3CEBbb7b28F37338f1d80c4f2F1735,0x541c45812f2ecfA0BFBA77a95ea54c044739231b,0xAF070182F4f9087eB634b333F283F10e9C943166,0x5B0DA1E40359976E433bcb30b7E4D77c544D0A81,0x7ae6586e3A8236A97CAc0FaBF06f85dB7e51d67C,0xaA7db76Daa94638F91D4F8A3311B064A4699a563,0xA18e37419912B70c9f6A4b3F47D86E7a2E73581E,0x392E213b2145945Ac6eaa8BA99fDd1A30AA2A598,0x88De39ECEa5CC4bF4d504eb29921387426f60E3C,0x2F4277Adbd3E7129098368D44ccABA112c9b35e6,0x9Df1fc23ad63170E1BA7c6CB18BC80c8E968EcF3,0x88De39ECEa5CC4bF4d504eb29921387426f60E3C,0x4ACE00829D7571F39d258fd8c94e809E63595626,0x94568c3a1040489C804C04f47fB15AF8c459b3C1,0xB205fB92Fc27870EA54c3A28c9Bb0B546dC3A0Ea,0x3455C0BB63636F82D280aa4053d88d3577292e8d];
        uint80[29] memory PRESALE_COIN_AMOUNT_ROUND_1 = [5496670000000000000000,10993340000000000000000,7695338000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,8794672000000000000000,10993340000000000000000,5496670000000000000000,5496670000000000000000,5496670000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,8794672000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,5496670000000000000000,10993340000000000000000,10993340000000000000000,5496670000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,7695338000000000000000];
        uint80[29] memory PRESALE_COIN_AMOUNT_ROUND_2 = [5496670000000000000000,10993340000000000000000,7695338000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,8794672000000000000000,10993340000000000000000,5496670000000000000000,5496670000000000000000,5496670000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,8794672000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,5496670000000000000000,10993340000000000000000,10993340000000000000000,5496670000000000000000,10993340000000000000000,10993340000000000000000,10993340000000000000000,7695338000000000000000];

        address[11] memory VIP_PRESALE_WALLETS = [0xDE8a0403e814A894AFaD56649d782e983F68b50e,0xa0592cF230B1a16f757e10E2994aff03a2499028,0x8518869FF07Bb25d43695A82f4D724BE04dBab57,0x057Aff91847Ac9DCD143805C3EA45E73517032B1,0x71619A7f0e077F8dE84027f59207C7c9c93e3eEc,0xE708dADd5750060a13094aB7eF95fF6f3Cecb4b4,0x58175D33774aDe676E459448d0Bd0178DBf86544, 0x1074104A6364581C4d8775e84b6128F97164cD8F,0xcDb3B54384460a3369C19FAbc386Cb719B2C1d1c,0xe5E33C7BeDb8f9D0fd08d43eB3fc853D03472496,0x3B9f5a98A83Ef6723c7359B0c8ea8a46c93Ca2a4];
        uint80[11] memory VIP_PRESALE_COIN_AMOUNT_ROUND_1 = [58593348000000000000000,29296674000000000000000,17783081118000000000000,8115178698000000000000,58593348000000000000000,58593348000000000000000,58593348000000000000000,29296674000000000000000,58593348000000000000000,35156008800000000000000,26835753384000000000000];
        uint80[11] memory VIP_PRESALE_COIN_AMOUNT_ROUND_2 = [58593348000000000000000,29296674000000000000000,17783081118000000000000,8115178698000000000000,58593348000000000000000,58593348000000000000000,58593348000000000000000,29296674000000000000000,58593348000000000000000,35156008800000000000000,26835753384000000000000];
        uint80[11] memory VIP_PRESALE_COIN_AMOUNT_ROUND_3 = [60368904000000000000000,30184452000000000000000,18321962364000000000000,8361093204000000000000,60368904000000000000000,60368904000000000000000,60368904000000000000000,30184452000000000000000,60368904000000000000000,36221342400000000000000,27648958032000000000000];

        uint256 nftReward = findNFTReward(_msgSender(), NFT_WALLETS, NFT_COIN_AMOUNT);
        uint256 presaleReward = findPresaleReward(_msgSender(), PRESALE_WALLETS, PRESALE_COIN_AMOUNT_ROUND_1, PRESALE_COIN_AMOUNT_ROUND_2);
        uint256 vipPresaleReward = findVIPPresaleReward(_msgSender(), VIP_PRESALE_WALLETS, VIP_PRESALE_COIN_AMOUNT_ROUND_1, VIP_PRESALE_COIN_AMOUNT_ROUND_2, VIP_PRESALE_COIN_AMOUNT_ROUND_3);
        uint256 total = nftReward + presaleReward + vipPresaleReward;
        if (total > 0) {
            _mint(_msgSender(), total);
        }
        emit ClaimReward(nftReward, presaleReward, vipPresaleReward);
        return (nftReward, presaleReward, vipPresaleReward);
    }

    function findNFTReward(address _addressToCheck, address[54] memory NFT_WALLETS, uint80[54] memory NFT_COIN_AMOUNT) private returns(uint256) {
        for (uint256 i = 0; i < NFT_WALLETS.length; i++) {
            if (NFT_WALLETS[i] == _addressToCheck && !vars().nftClaimed[_addressToCheck]) {
                vars().nftClaimed[_addressToCheck] = true;
                return NFT_COIN_AMOUNT[i];
            }
        }
        return 0;
    }

    function findPresaleReward(address _addressToCheck, address[29] memory PRESALE_WALLETS, uint80[29] memory PRESALE_COIN_AMOUNT_ROUND_1, uint80[29] memory PRESALE_COIN_AMOUNT_ROUND_2) private returns(uint256) {
        for (uint256 i = 0; i < PRESALE_WALLETS.length; i++) {
            if (PRESALE_WALLETS[i] == _addressToCheck) {
                return calculateRewardForPresale(_addressToCheck, i, PRESALE_COIN_AMOUNT_ROUND_1, PRESALE_COIN_AMOUNT_ROUND_2);
            }
        }
        return 0;
    }

    function findVIPPresaleReward(address _addressToCheck, address[11] memory VIP_PRESALE_WALLETS, uint80[11] memory VIP_PRESALE_COIN_AMOUNT_ROUND_1, uint80[11] memory VIP_PRESALE_COIN_AMOUNT_ROUND_2, uint80[11] memory VIP_PRESALE_COIN_AMOUNT_ROUND_3) private returns(uint256) {
        for (uint256 i = 0; i < VIP_PRESALE_WALLETS.length; i++) {
            if (VIP_PRESALE_WALLETS[i] == _addressToCheck) {
                return calculateRewardForVIPPresale(_addressToCheck, i, VIP_PRESALE_COIN_AMOUNT_ROUND_1, VIP_PRESALE_COIN_AMOUNT_ROUND_2, VIP_PRESALE_COIN_AMOUNT_ROUND_3);
            }
        }
        return 0;
    }

    function calculateRewardForPresale(address _addressToCheck, uint256 index, uint80[29] memory PRESALE_COIN_AMOUNT_ROUND_1, uint80[29] memory PRESALE_COIN_AMOUNT_ROUND_2) private returns(uint256) {
        uint256 reward = 0;
        if (!vars().presaleRound1Claimed[_addressToCheck]) {
            reward += PRESALE_COIN_AMOUNT_ROUND_1[index];
            vars().presaleRound1Claimed[_addressToCheck] = true;
        }
        if (!vars().presaleRound2Claimed[_addressToCheck] && CURRENT_PRESALE_ROUND == 2) {
            reward += PRESALE_COIN_AMOUNT_ROUND_2[index];
            vars().presaleRound2Claimed[_addressToCheck] = true;
        }
        return reward;
    }

    function calculateRewardForVIPPresale(address _addressToCheck, uint256 index, uint80[11] memory VIP_PRESALE_COIN_AMOUNT_ROUND_1, uint80[11] memory VIP_PRESALE_COIN_AMOUNT_ROUND_2, uint80[11] memory VIP_PRESALE_COIN_AMOUNT_ROUND_3) private returns(uint256) {
        uint256 reward = 0;
        if (!vars().vipPresaleRound1Claimed[_addressToCheck]) {
            reward += VIP_PRESALE_COIN_AMOUNT_ROUND_1[index];
            vars().vipPresaleRound1Claimed[_addressToCheck] = true;
        }
        if (!vars().vipPresaleRound2Claimed[_addressToCheck] && CURRENT_VIP_PRESALE_ROUND >= 2) {
            reward += VIP_PRESALE_COIN_AMOUNT_ROUND_2[index];
            vars().vipPresaleRound2Claimed[_addressToCheck] = true;
        }
        if (!vars().vipPresaleRound3Claimed[_addressToCheck] && CURRENT_VIP_PRESALE_ROUND == 3) {
            reward += VIP_PRESALE_COIN_AMOUNT_ROUND_3[index];
            vars().vipPresaleRound3Claimed[_addressToCheck] = true;
        }
        return reward;
    }

    function mintWholeCoins(address to, uint256 amount) public onlyOwner {
        _mint(to, amount * 10**decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!isNotPermitted(from, to), "Transfers may not be available at this time using this address.");
        require(!isUserBlacklisted(from) && !isUserBlacklisted(to), "Address is black listed by Owner");

        uint256 marketingFeeBuy = amount * MARKETING_TAX_BUY / 100;
        uint256 developmentFeeBuy = amount * DEVELOPMENT_TAX_BUY / 100;
        uint256 liquidityFeeBuy = amount * LIQUIDITY_TAX_BUY / 100;

        uint256 marketingFeeSell = amount * MARKETING_TAX_SELL / 100;
        uint256 developmentFeeSell = amount * DEVELOPMENT_TAX_SELL / 100;
        uint256 liquidityFeeSell = amount * LIQUIDITY_TAX_SELL / 100;

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }

        if (isPair(from) && (to != owner() || !isUserWhitelistedForFees(to) || !isUserWhitelistedForLaunch(to))) {
            
            _balances[MARKETING_WALLET] += marketingFeeBuy;
            _balances[DEVELOPMENT_WALLET] += developmentFeeBuy;
            _balances[LIQUIDITY_WALLET] += liquidityFeeBuy;

            uint256 remainder = amount - marketingFeeBuy - developmentFeeBuy - liquidityFeeBuy;
            require(remainder + marketingFeeBuy + developmentFeeBuy + liquidityFeeBuy == amount, "tax calculated incorrectly");
            _balances[to] += remainder;
        } else if (isPair(to) && (from != owner() || !isUserWhitelistedForFees(from)) || !isUserWhitelistedForLaunch(from)) {
            
            _balances[MARKETING_WALLET] += marketingFeeSell;
            _balances[DEVELOPMENT_WALLET] += developmentFeeSell;
            _balances[LIQUIDITY_WALLET] += liquidityFeeSell;

            uint256 remainder = amount - marketingFeeSell - developmentFeeSell - liquidityFeeSell;
            require(remainder + marketingFeeSell + developmentFeeSell + liquidityFeeSell == amount, "tax calculated incorrectly");
            _balances[to] += remainder;
        } else {
            
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    
    
    function pause() public whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }

    
    function getBalance() public view returns (uint256) {
        return balanceOf(msg.sender);
    }

    function isNotPermitted(address from, address to) private view returns(bool) {
        if (callerIsOwner() || isUserWhitelistedForPause(_msgSender())
        || isOwner(from) || isOwner(to)
        || isUserWhitelistedForPause(from) || isUserWhitelistedForPause(to)) {
            return false;
        }
        return paused();
    }

    
    function getPancakeSwapRouterAddress() private view returns (address) {
        if (isTestnet()) {
            return ROUTER_ADDRESS_TESTNET;
        }
        return ROUTER_ADDRESS_MAINNET;
    }

    function getRouter() private view returns (IUniswapV2Router02) {
        return uniswapV2Router;
    }

    function getPair() private view returns (address pair) {
        address uniswapPair = uniswapV2Factory.getPair(address(this),uniswapV2Router.WETH()); 
        return uniswapPair;
    }

    function isPair(address _addressToCheck) private view returns (bool) {
        if (_addressToCheck == address(0)) {
            return false;
        }
        return _addressToCheck == getPair();
    }

    
    function getChainId() private view returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }

    function isTestnet() private view returns (bool) {
        return getChainId() == 97;
    }

    function isOwner(address _addressToCheck) private view returns (bool) {
        return _addressToCheck == owner();
    }

    function callerIsOwner() private view returns (bool) {
        return _msgSender() == owner();
    }

    
    function addWhitelistedUser(address _addressToWhitelist) public onlyOwner {
        vars().whitelistedAddressesForClaim[_addressToWhitelist] = true;
    }

    function removeWhitelistedUser(address _addressToWhitelist) public onlyOwner {
        vars().whitelistedAddressesForClaim[_addressToWhitelist] = false;
    }

    function addBlacklistedUser(address _addressToBlacklist) public onlyOwner {
        vars().blacklistedAddresses[_addressToBlacklist] = true;
    }

    function removeBlacklistedUser(address _addressToBlacklist) public onlyOwner {
        vars().blacklistedAddresses[_addressToBlacklist] = false;
    }

    function addPauseWhitelistedUser(address _addressToWhitelist) public onlyOwner {
        vars().whitelistedAddressesForPause[_addressToWhitelist] = true;
    }

    function removePauseWhitelistedUser(address _addressToWhitelist) public onlyOwner {
        vars().whitelistedAddressesForPause[_addressToWhitelist] = false;
    }

    function addFeesWhitelistedUser(address _addressToWhitelist) public onlyOwner {
        vars().whitelistedAddressesForFees[_addressToWhitelist] = true;
    }

    function removeFeesWhitelistedUser(address _addressToWhitelist) public onlyOwner {
        vars().whitelistedAddressesForFees[_addressToWhitelist] = false;
    }

    function addLaunchWhitelistedUser(address _addressToWhitelist) public onlyOwner {
        addPauseWhitelistedUser(_addressToWhitelist);
        addFeesWhitelistedUser(_addressToWhitelist);
    }

    function removeLaunchWhitelistedUser(address _addressToWhitelist) public onlyOwner {
        removePauseWhitelistedUser(_addressToWhitelist);
        removeFeesWhitelistedUser(_addressToWhitelist);
    }

    function isUserWhitelistedForClaim(address _addressToCheck) public view returns(bool) {
        bool userIsWhitelistedForClaim = vars().whitelistedAddressesForClaim[_addressToCheck];
        return userIsWhitelistedForClaim || isOwner(_addressToCheck);
    }

    function isUserWhitelistedForPause(address _addressToCheck) public view returns(bool) {
        bool userIsWhitelistedForPause = vars().whitelistedAddressesForPause[_addressToCheck];
        return userIsWhitelistedForPause || isOwner(_addressToCheck);
    }

    function isUserWhitelistedForFees(address _addressToCheck) public view returns(bool) {
        bool userIsWhitelistedForFees = vars().whitelistedAddressesForFees[_addressToCheck];
        return userIsWhitelistedForFees || isOwner(_addressToCheck);
    }

    function isUserWhitelistedForLaunch(address _addressToCheck) public view returns(bool) {
        bool userIsWhitelistedForPause = vars().whitelistedAddressesForPause[_addressToCheck];
        bool userIsWhitelistedForFees = vars().whitelistedAddressesForFees[_addressToCheck];
        return (userIsWhitelistedForPause && userIsWhitelistedForFees) || isOwner(_addressToCheck);
    }

    function isUserBlacklisted(address _addressToCheck) public view returns(bool) {
        bool userIsBlacklisted = vars().blacklistedAddresses[_addressToCheck];
        return userIsBlacklisted;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20Upgradeable.sol";
import "../../../utils/ContextUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal onlyInitializing {
    }

    function __ERC20Burnable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.5.0;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';

import "./SafeMath.sol";

library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            )))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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

pragma solidity >=0.6.2;

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

pragma solidity >=0.6.6;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}