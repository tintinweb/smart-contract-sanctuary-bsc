/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// SPDX-License-Identifier: MIT
/**
 * @title EternalLabsDistributor
 * @author : saad sarwar
 * @website : eternallabs.finance
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
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;

        _status = _NOT_ENTERED;
    }
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IMinter {
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external returns (address);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function totalSupply() external view returns (uint256);
}

interface ISnapshot {
    function earnings(address) external view returns(uint);
}

// for mainst
contract EternalLabsDistributor is Ownable, ReentrancyGuard {

    address public TOKEN = 0x8FC1A944c149762B6b578A06c0de2ABd6b7d2B89;
    address public MINTER = 0xa36c806c13851F8B27780753563fdDAA6566f996;
    address public BOUNTY = 0x07c569b26A820C99A136ec6f7d684db5815b7f43;
    address public STAKER_PROXY = 0x064e21802e8bE26E2ad1a6950fBd93443Fc91d65;
    
    uint public TOTAL_DISTRIBUTED;
    uint public TOTAL_RECEIVED;
    uint public TO_DISTRIBUTE;

    mapping (uint => uint) public tokenDebt;
    mapping (address => bool) public previousEarningsClaimed;
    mapping (address => uint72) public previousEarnings;

    constructor() {
        previousEarnings[0xB91fCE873327A95348496EC4Db71986877eB8963] = 1123320463302017140;
        previousEarnings[0xb18e8a85043E0adaAEBd1E91541f56e3265925c3] = 49987760616939762730;
        previousEarnings[0xC25E87c0824a3549a2b798C16053c3D808E54E42] = 12356525096322188540;
        previousEarnings[0xE13A249781062F8096CAA2604e19A95D8DA85beF] = 11794864864671179970;
        previousEarnings[0x39B1A7452187F3abe148545707D1CC7938228fb5] = 6739922779812102840;
        previousEarnings[0x3F195179eA6202B603490b57A7265FD93c24f553] = 38192895752268582760;
        previousEarnings[0xCA6886946b7A93b987682148FEfcf416DC5F6F86] = 12356525096322188540;
        previousEarnings[0x1eC2a5Ca4D34D601c4936Fc440a422F6C214930c] = 1684080258468930486;
        previousEarnings[0x542A86A9bb33679c8185fF716d90217a8D7dbEB3] = 11794864864671179970;
        previousEarnings[0x9a908DB106003823B289c55D89faC14597e221D1] = 1123320463302017140;
        previousEarnings[0x1fb12cB6aa1BA5bA75eEE98C1779Ba66Df7836D5] = 57289343628402874140;
        previousEarnings[0x424A868821298c91313A673D7aF704B469264b9F] = 561660231651008570;
        previousEarnings[0xB7287cf7734D4d22C6C8e41bC24117541a1e4c1D] = 23589729729342359940;
        previousEarnings[0xB62b82a0aa63889c6d7B27D8eE7D8FDEf3b930ae] = 561660231651008570;
        previousEarnings[0xbc83507c89BF6A8F7A8f576c5b4C17327b7C6790] = 6178262548161094270;
        previousEarnings[0x78eB45661F040B24B509E630300c5e5256866D71] = 1403400215390775405;
        previousEarnings[0x91451eE0501F588D74EDD3d5d372c7cC99793784] = 1684980694953025710;
        previousEarnings[0x10BBAd85b0d79F279EDBb10b3DB5444C2E222C80] = 11233204633020171400;
        previousEarnings[0xA1b342ef9cf077407C261D59BB481DF0b92d5b54] = 6126092669134306570;
        previousEarnings[0xc4f64F53F408296730e0287b38aB9177068D8e4D] = 557469605732195840;
        previousEarnings[0x7252aDdCF940a75c76EF8C016b61b25d171c725F] = 561660231651008570;
        previousEarnings[0x26DC7dDECDa2Dd5b03206a9b78aa9D98Afd7877E] = 7297681120032032106;
        previousEarnings[0x6EE87166Ae581D586c26E594798a5553AC5F077c] = 32014633204107488490;
        previousEarnings[0x9b8ebeC7B2A0c3b603A95D0D5ec73E02a38c0885] = 11233204633020171400;
        previousEarnings[0x84F9F4982F86BD082f7425993985c089683e27b3] = 1123320463302017140;
        previousEarnings[0x0c8dE6c981206F981C4a3C228b4ebd63b79Ea297] = 9548223938067145690;
        previousEarnings[0x11602Fb49Da0d6B7b9cBe7972Be043BA90A3A6c3] = 561660231651008570;
        previousEarnings[0x912e303D92957d508CBd752B2dF7140BeBB29918] = 1123320463302017140;
        previousEarnings[0x65Fc4Ab2D6B93714700148195daa19091767ec19] = 11233204633020171400;
        previousEarnings[0xbB65019b9530Dee14c4C2E41F37964ffea610a8E] = 561660231651008570;
        previousEarnings[0x5037B74c98792f0459aCA77396829467a84641f2] = 1123320463302017140;
        previousEarnings[0xd932A7735AB6de3f1C11FC62cC449393F6418985] = 3298665283380011230;
        previousEarnings[0xC9F40d1c8a84b8AeD12A241e7b99682Fb7A3FE84] = 2246640926604034280;
        previousEarnings[0xf68F4429C559C6081F1dF4583433F37fDF20091F] = 1123320463302017140;
        previousEarnings[0x567C3Cf5A14AA2E8a32589FE3eA38C6680756026] = 12918185327973197110;
        previousEarnings[0x132EAb0241088566749A075EE66fa571F843A6bb] = 561660231651008570;
        previousEarnings[0x0e46A3C234c26483F86bDa515172d50e4279d06c] = 7301583011463111410;
        previousEarnings[0xad6903e27a9C5733Cf602F242b38a3f0715c33Be] = 4712378976257158900;
        previousEarnings[0x8EF1a9508836A39e31DCe4B8F5A7a46122C0c05A] = 561660231651008570;
        previousEarnings[0xcc02008086dc87ff71604BDe983dd91c18d6B8BE] = 2246640926604034280;
        previousEarnings[0xD2175F41cC80CEdE70f61073AaE29cC71e9053BE] = 1123320463302017140;
        previousEarnings[0xA97F7EB14da5568153Ea06b2656ccF7c338d942f] = 605748494526817454;
        previousEarnings[0xCd1B0abBc3E55E91FCC5AEE393525e68478C2952] = 11794864864671179970;
        previousEarnings[0x43F7d4D1C9046D97dF03845eE7a3a45050a8761c] = 2246640926604034280;
        previousEarnings[0x5d33ca97efc658000335260a2E2EE0Dd2986F85b] = 561660231651008570;
        previousEarnings[0x8053eEe5ceE3cEF46ecf3A3b3725630774eD78e4] = 1123320463302017140;
        previousEarnings[0xa6cDA8249f60FCb8B1DDb84DBF53e8bcC91B2098] = 561660231651008570;
        previousEarnings[0xF486FeA942C2394FE03Ed324D67345dF9982725F] = 1123320463302017140;
        previousEarnings[0xE14F8d32d19462dBCDcDa29EBf2224A7F19BF32F] = 561660231651008570;
        previousEarnings[0x725993c8d4A7143A2f0c4D9fFdf81eA8a343E87C] = 1123320463302017140;
        previousEarnings[0x561A7C17ae55a646057E22177dbd41df869D241b] = 561660231651008570;
        previousEarnings[0xB34C4bbe1f628Dc31FEd918eAAa82bCEe3eE5586] = 5616602316510085700;
        previousEarnings[0xB6a54cf853BC69E345595654fAF700dDBd170012] = 1684980694953025710;
        previousEarnings[0x656415F657298Ba86072136Ba9b609BCfe07eBa1] = 11233204633020171400;
        previousEarnings[0x69cC8B631723b33cA2E4b7A93C51b7259Ed82cEf] = 10109884169718154260;
        previousEarnings[0x5BE96CA3D76D78b041B6BE3c34BeC13a82F9fFB8] = 561660231651008570;
        previousEarnings[0x61aae34048cA3cAc55697026999e37896537cA40] = 561660231651008570;
        previousEarnings[0x8FF67D7aAE259f6De5c3C326f653E93c0c7d0bE6] = 1123320463302017140;
        previousEarnings[0xF24BfD02a161960004aEbEB25d3bdA95f19ED7c1] = 561660231651008570;
        previousEarnings[0x1d19C45424f623488827C308B14811933210F828] = 17411467181181265670;
        previousEarnings[0x594e367d301f85dD395983684365Da01B9D33069] = 561660231651008570;
        previousEarnings[0x1883e43acC37A001df3daed5f064C58195735E8d] = 561660231651008570;
        previousEarnings[0x2c117Ab012B66B6f990A921453B3c305051918FB] = 561660231651008570;
        previousEarnings[0xDebb0F092a7138a38c1a0bc73C77Eca88BF3eC21] = 15164826254577231390;
        previousEarnings[0x478cDA6b8f61Ef82B8233962c284A615c7Da6271] = 5054942084859077130;
        previousEarnings[0xc2163626675Ee9162CD68AAdBcc28D797F3966aF] = 10109884169718154260;
        previousEarnings[0xc09fD6C5aE24D4D23874F2Dbf00FE8e8896EE5d7] = 561660231651008570;
        previousEarnings[0xF82e9D2De3e22fda38284484cCc5C1013Fb6b472] = 69084208493074054110;
        previousEarnings[0x49622D56b0a1E758de95E24900C6192F743BbFa5] = 561660231651008570;
        previousEarnings[0x0E6eccDdD1cCF310C47B15BAB8A52523a8A9E861] = 19096447876134291380;
        previousEarnings[0x5122E6C72A1D56c9A387cAe8de948FE89831373a] = 561660231651008570;
        previousEarnings[0x1B7BCcA9d760CC85f482df2F82f4309892fd0fc5] = 1684980694953025710;
        previousEarnings[0xA24bd512D81ab7a949267f14e3085702f2848931] = 23028069497691351370;
        previousEarnings[0x61b395fae2255B7f22Ab9Dd8CB54edE88B66b2D6] = 561660231651008570;
        previousEarnings[0x4b7BCE154aeD501572173Ea661B27d717Bd6562C] = 1684980694953025710;
        previousEarnings[0xDDf8dA887a1D5C07d05A948856b79DaB091efc78] = 1123320463302017140;
        previousEarnings[0x87Ad7427A667A8D9B8a5888BA0e20c47Fef80f97] = 1684980694953025710;
        previousEarnings[0x08bF985299Ac52EcEE8524D7Ccb98d5A2800F355] = 11233204633020171400;
        previousEarnings[0x47a01fCB08c8e7E29EDFe53e5824B79eaF5cF6E2] = 1123320463302017140;
        previousEarnings[0x3281d8f4d78C89Ad8312D001d9d07949CC606E7d] = 3369961389906051420;
        previousEarnings[0x92a099d7680eA2b97518526D552451b9a5Ef96A2] = 5054942084859077130;
        previousEarnings[0x4d9040Fe9d9077D70a6Ca1ea7dE1cAc43775572d] = 2246640926604034280;
        previousEarnings[0xFA8BbCfC0A4EA1a0c405bd72a840E39Ab74a2b14] = 561660231651008570;
        previousEarnings[0x26Cc7cAdB9418728Fd053413534C27b78f935a7f] = 1684980694953025710;
        previousEarnings[0x8ec6C7b616F0433f7102bcBeaB6DaA855616a83C] = 4771860877823334785;
        previousEarnings[0xB9F05B6F38F8ea578686A041C1030ce8B2d2D787] = 561660231651008570;
        previousEarnings[0xAD45F43157DDd8669904DA9b69F243C0BF57B284] = 561660231651008570;
        previousEarnings[0xAF50ED99AD526E3Cfd0BaE803F9052999aCb16b3] = 561660231651008570;
        previousEarnings[0xc85dE71b6EE43be9ed625A3f9EA729ac57d86706] = 561660231651008570;
        previousEarnings[0x824025151d070228308e555FCF694b4cD4b0f6d5] = 561660231651008570;
        previousEarnings[0xa9cF61b2Cd774EC7FfE89889Ef2476540b3eD16A] = 3369961389906051420;
        previousEarnings[0x343781801E1c4CCDdcAA72B2DEbb427fa9c3269F] = 561660231651008570;
        previousEarnings[0xC95718bdA44D182AB68fbc0f35851d0bfE4BFfF4] = 561660231651008570;
        previousEarnings[0x86eB4F98a1927Cab8C397c35F5A6e18792aD3399] = 561660231651008570;
        previousEarnings[0xED0eccdDF45fe869e06DFE89B995BEa54168BF9D] = 1684980694953025710;
        previousEarnings[0x023EdE59e33E2C7bD880fE60FaC227551b8753FA] = 561660231651008570;
        previousEarnings[0xE1E7c2c304D8E9Cae39a7C72A366FdC02e0e8A74] = 5616602316510085700;
        previousEarnings[0x489CAF6518c28804E31CaE58a1429341D739b73f] = 4493281853208068560;
        previousEarnings[0x657fE5Dd633D29B28B23789bE42A24997D079e89] = 29767992277503454210;
        previousEarnings[0x6c1cc9c0f32980Ead12373e5312EE046D00664bE] = 561660231651008570;
        previousEarnings[0xBEBd699f9E724FA864d35b51e51b2Db05bc1A03D] = 561660231651008570;
        previousEarnings[0xe634f3b503920620FcA6452833683803bC8DFc04] = 20219768339436308520;
        previousEarnings[0xaA458b0795f6268b5963106892E9d0977D70Cf37] = 1123320463302017140;
        previousEarnings[0xfbC3042d9e938471985228d0bD40A16D5d72bE9a] = 1123320463302017140;
        previousEarnings[0x189F8245C1C09558caEBF17F9De5515c27f2B050] = 1123320463302017140;
        previousEarnings[0x6843f96d599392C8c12E82026bfdb71428169c4E] = 2808301158255042850;
        previousEarnings[0x773B573a68318Eb5506016981452b249EbCd4443] = 1684980694953025710;
        previousEarnings[0xF7FB15c8f393f462C133BB93F47381B9a7823233] = 561660231651008570;
        previousEarnings[0x1425FCcda44E17a198a8B9bDa242549196745545] = 1123320463302017140;
        previousEarnings[0x3DEa6FCD564F8057d7B50247A0e00844eb2109A4] = 1123320463302017140;
        previousEarnings[0xCEA90fb2e57424efBA761e645e8b6e4e95587A12] = 1684980694953025710;
        previousEarnings[0x798b6A7c6fc0005646B6DAB213FA5E00Dda4CC52] = 561660231651008570;
        previousEarnings[0x60b582F6Fc3d37F160eE01ed1E4a026C6f6f27Dc] = 561660231651008570;
        previousEarnings[0x1F49D2F1eDeb2D023A60aD91c72845003d2Ab95C] = 561660231651008570;
        previousEarnings[0xa525a3eB8dE0eFEAf2a5a5e781466Fb192600a8f] = 11794864864671179970;
        previousEarnings[0xF612af6D4C3f3A32aC0696c557b4f5422C999507] = 47741119690335728450;
        previousEarnings[0xc33E15c9FE58Bbe234Ed0b8b8c1b8108E0F0b48E] = 561660231651008570;
        previousEarnings[0x02e000eE12CD4a5E70D380b45897ee856e75a2aC] = 1123320463302017140;
        previousEarnings[0x87EabB7bE00500132be10c30bff178aB218d83e0] = 561660231651008570;
        previousEarnings[0x208b91fadE3F2a627f2a7Fd95D7eD1F619E01284] = 2808301158255042850;
        previousEarnings[0x71a406509082bd34600009C55fDfdef96315d366] = 2808301158255042850;
        previousEarnings[0x15675a16DF364B4919231EE0367B5bc68B24833F] = 561660231651008570;
        previousEarnings[0xe41395822065dC3535a97116485312B44603b289] = 2808301158255042850;
        previousEarnings[0x7e9378DCf1179fF217219859E86E75b6D08f0703] = 1123320463302017140;
        previousEarnings[0xD123D8D85AFefA686fd87679Fd1CF3e6f0627135] = 561660231651008570;
        previousEarnings[0x94CE1D981e8D5e4472056949A07C7449e9a36f52] = 561660231651008570;
        previousEarnings[0xc3ED6fBc2F0eD7Cf0daDbAe2Ff19e29aC229c7B5] = 1123320463302017140;
        previousEarnings[0x2BD4579690ef84522E2fdCa2db54bF9FEF4cA632] = 561660231651008570;
        previousEarnings[0x22b986B28cb317a17eD4D8E8a348365574b71F9C] = 2808301158255042850;
        previousEarnings[0xC51283E6A879744b272BaeCdAe1036799352Dfe9] = 561660231651008570;
        previousEarnings[0xD64304D96B8Af808E940a75d8e5C5dB664AE54c1] = 561660231651008570;
        previousEarnings[0x15A3e6B5398d7f45b8E3623B24845Fb3a0BAba6E] = 1123320463302017140;
        previousEarnings[0x48d526d7fB3494C453Ff6CB63Dace1A02c8a7F27] = 1123320463302017140;
        previousEarnings[0x29F04971665633F70aA14a9c857A112c1cA63525] = 561660231651008570;
        previousEarnings[0x20f01DCcb5Ab9eBE95889A0FE6271b59EbE2ba38] = 561660231651008570;
        previousEarnings[0x40d95aBe1bC90A7bCe810eD9382de52D93Fb7C7e] = 561660231651008570;
        previousEarnings[0xFD6e41A5b3D0AE8DA966B9ee77d21a1809B4E27C] = 151867870406292627;
        previousEarnings[0x791D4fdb021fB213895b58ef4609630E3fF23242] = 471237897625715890;
        previousEarnings[0x96E725c53561A1b88eEAF2BEa2fe9f7D69C26C7e] = 561660231651008570;
        previousEarnings[0x1A10f4D465e042fc746e2A29f68373B69eCDbF1d] = 561660231651008570;
        previousEarnings[0xA54d21D132515aeb77648922C35c9ddFdbBfb80E] = 561660231651008570;
        previousEarnings[0xE656650ffC714E232392C878EA84429bF455Eb33] = 214120251602991220;
        previousEarnings[0x13c6ED0E05cdc2D4Bd7276f72D400aEc56195a2c] = 561660231651008570;
    }

    function setTokenAddress(address token) public onlyOwner {
        TOKEN = token;
    }

    function setMinterAddress(address minter) public onlyOwner {
        MINTER = minter;
    }

    function setBountyAddress(address bounty) public onlyOwner {
        BOUNTY = bounty;
    }

    function setStakerProxy(address proxy) public onlyOwner {
        STAKER_PROXY = proxy;
    }

    function addDistributionAmount(uint amount) external {
        require(msg.sender == BOUNTY || msg.sender == owner(), "EL: not owner or bounty");
        TOTAL_RECEIVED += amount;
        TO_DISTRIBUTE += amount / IMinter(MINTER).totalSupply();
    }

    function calculateEarnings(uint tokenId) public view returns (uint) {
        require(tokenId > 0 && tokenId <= IMinter(MINTER).totalSupply(), "EL: Invalid token id");
        return TO_DISTRIBUTE - tokenDebt[tokenId];
    }

    function calculateAllEarned() public view returns (uint) {
        uint balance = IMinter(MINTER).balanceOf(msg.sender);
        uint total = 0;
        for (uint index = 0; index < balance; index++) {
            total += TO_DISTRIBUTE - tokenDebt[IMinter(MINTER).tokenOfOwnerByIndex(msg.sender, index)];
        }
        if (!previousEarningsClaimed[msg.sender]) {
            if (previousEarnings[msg.sender] > 0) {
                total += previousEarnings[msg.sender];
            } else {
                total += 413181989188022284;
            }
        }
        return total;
    }

    function claim(uint tokenId) public nonReentrant {
        require(msg.sender == IMinter(MINTER).ownerOf(tokenId), "EL: not your token");
        uint amount = calculateEarnings(tokenId);
        require(amount > 0, "EL: not enough to claim");
        tokenDebt[tokenId] += amount;
        sendTokens(IMinter(MINTER).ownerOf(tokenId), amount);
    }

    function claimAll() public nonReentrant {
        uint balance = IMinter(MINTER).balanceOf(msg.sender);
        require(balance > 0, "EL: Not an Eternal token holder");
        uint total = 0;
        for (uint index = 0; index < balance; index++) {
            uint tokenId = IMinter(MINTER).tokenOfOwnerByIndex(msg.sender, index);
            uint amount = TO_DISTRIBUTE - tokenDebt[tokenId];
            tokenDebt[tokenId] += amount;
            total += amount;
        }
        if (!previousEarningsClaimed[msg.sender]) {
            if (previousEarnings[msg.sender] > 0) {
                total += previousEarnings[msg.sender];
            } else {
                total += 413181989188022284; // the surplus amount of mainst 
            }
            previousEarningsClaimed[msg.sender] = true;
        }
        require(total > 0, "EL: not enough to claim");
        sendTokens(msg.sender, total);
    }

    function sendTokens(address _address, uint amount) internal {
        IBEP20(TOKEN).transfer(_address, amount);
        TOTAL_DISTRIBUTED += amount;
    }

    function establishTokenDebt(uint tokenId) public {
        require(msg.sender == STAKER_PROXY, "EL: not allowed");
        tokenDebt[tokenId] += TO_DISTRIBUTE;
    }

    // emergency withdrawal function in case of any bug or v2
    function withdrawTokens() public onlyOwner() {
        IBEP20(TOKEN).transfer(msg.sender, IBEP20(TOKEN).balanceOf(address(this)));
    }
}