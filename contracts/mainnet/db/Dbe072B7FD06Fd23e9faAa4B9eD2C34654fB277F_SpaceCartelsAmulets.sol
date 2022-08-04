// SPDX-License-Identifier: No License (None)
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SpaceCartelsAmulets is ERC721, ERC721Enumerable, Ownable {
    string _baseUriString = "ipfs://bafybeigicbujkxoygxeyibhejosygq2bpwwxuykg3blfgzhfvz5lbvk5sq/amulets/";
    enum AmuletType {Rare50, Rare52, Epic75, Epic78, Mythic120, Mythic124}
    struct AmuletData {
        uint dmt_boost;
        string rarity;
        string uri;
    }

    mapping(AmuletType => AmuletData) private _amuletData;
    mapping(uint256 => AmuletType) private _meta;
    mapping(uint => bytes32) private _retrieveSignature;


    function allow(address account, uint256 tokenId, AmuletType amuletType) public onlyOwner returns (bool) {
        _retrieveSignature[tokenId] = signature(account, tokenId, amuletType);
        return true;
    }


    function exist(uint256 tokenId) public view returns (bool){
        return _exists(tokenId);
    }


    function isAllowed(address account, uint256 tokenId, AmuletType amuletType) public view returns (bool) {
        bytes32 sign = signature(msg.sender, tokenId, amuletType);
        return sign == _retrieveSignature[tokenId];
    }


    function mint(uint tokenId, AmuletType amuletType) public {
        require(tokenId < 1000, "token cap reached");
        bytes32 sign = signature(msg.sender, tokenId, amuletType);
        require(sign == _retrieveSignature[tokenId], "invalid signature");
        _meta[tokenId] = amuletType;
        _safeMint(msg.sender, tokenId);
    }

    function signature(address account, uint256 tokenId, AmuletType amuletType) internal pure returns (bytes32){
        return keccak256(abi.encode(account, tokenId, amuletType));
    }


    function getAmuletDmtBoost(uint256 tokenId) external view returns (uint) {
        require(_exists(tokenId), "query for nonexistent NFT");
        return _amuletData[_meta[tokenId]].dmt_boost;
    }


    function getAmuletRarity(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "query for nonexistent NFT");
        return _amuletData[_meta[tokenId]].rarity;
    }

    function getAmuletType(uint ringId) public view returns (uint256) {
        return uint256(_meta[ringId]);
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal
    override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }


    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


    function _baseURI() internal view virtual override returns (string memory) {
        return _baseUriString;
    }

    function setBaseURI(string memory baseURI_) external onlyOwner() {
        _baseUriString = baseURI_;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _amuletData[_meta[tokenId]].uri)) : "";
    }

    constructor() ERC721("Space Cartels Amulets", "SPCAML") {
        _amuletData[AmuletType.Rare50] = AmuletData({
        dmt_boost : 5000,
        rarity : "Rare",
        uri : "0.json"
        });
        _amuletData[AmuletType.Rare52] = AmuletData({
        dmt_boost : 5200,
        rarity : "Rare",
        uri : "1.json"
        });
        _amuletData[AmuletType.Epic75] = AmuletData({
        dmt_boost : 7500,
        rarity : "Epic",
        uri : "2.json"
        });
        _amuletData[AmuletType.Epic78] = AmuletData({
        dmt_boost : 7800,
        rarity : "Epic",
        uri : "3.json"
        });
        _amuletData[AmuletType.Mythic120] = AmuletData({
        dmt_boost : 12000,
        rarity : "Mythic",
        uri : "4.json"
        });
        _amuletData[AmuletType.Mythic124] = AmuletData({
        dmt_boost : 12400,
        rarity : "Mythic",
        uri : "5.json"
        });

        _retrieveSignature[3] = 0x4af1dd7b57e00655578298445d630064b3339db9a7993e244df6dcfa7b24d290;
        _retrieveSignature[5] = 0xe79f0f8f7fbd1b269a643d037db8f1b00e96f0633e8383c68a9a12ab2ffbda30;
        _retrieveSignature[6] = 0xfaf3688988284201e633a51349e3422bcba355e59807105724febee1b871c367;
        _retrieveSignature[9] = 0x3fe2ee9bb240f018b5b533b9faf7f26e1b80d39a5f1fa11ab3daf8c2d389642a;
        _retrieveSignature[10] = 0xaa9b817d9f34e7a0cb76e2f1eac8bee39554cbd855f9bda3588857653957eaa8;
        _retrieveSignature[11] = 0xc8296f3528a077ed1f359aa088678696d9227b7e643d90ae6239dbe18f7a4ac0;
        _retrieveSignature[12] = 0x95bc063fa827eeeaadb76300a7901a0d5c659dbd5f3c4a21aabac26e7ffd9aa9;
        _retrieveSignature[13] = 0x34a0b1b7c5ca04b7f7ec3d9b8b8f82aaff535593886855d5c12bd9bba52b07df;
        _retrieveSignature[15] = 0x03bd8bf9899f86881c123cd53ba276c11466de2a555c8c3b6a0590c1f4f77930;
        _retrieveSignature[16] = 0xa9d626f123467194f095d59c02f277ebb3237d5872a34b065a8e2ddb549feff7;
        _retrieveSignature[17] = 0xc7d39f8efec2e5a117c879194a9fefd9ebe2cfa39900906c4adfd056fff33cde;
        _retrieveSignature[18] = 0x1de19556cd69734afe0f15a32624c96fb0fbd6d52ed2fb0d8733bf99d092a557;
        _retrieveSignature[19] = 0xf528b7aaacf7ce74c9137dceaecaf7936ba39b192fde62b2a11835281ffc515b;
        _retrieveSignature[20] = 0xc921dd037348894f10a5f4724b1ad3f10e40215310474bc252a5941e2319513e;
        _retrieveSignature[21] = 0x827973aa27fb6e11b541e6818abcd6ddbb1e3cfb036bc2bdefa86d7988c1e7fc;
        _retrieveSignature[22] = 0x4307bdda2ac6992c02059b565636b69465b4d91c5081b2bbc021acb573d218cb;
        _retrieveSignature[23] = 0xc32a4ec9bb4f18a6a625aafeeb9e4d390a6155cb15c9e8b1e72f0d1c006c8d9b;
        _retrieveSignature[24] = 0x8a68a4ee8386260f84f43a8e363b7f6372a297cb51eb0808e3ab1f0dd57c7bec;
        _retrieveSignature[25] = 0x96fe99c644f714a10a2d5e37f57088166fa89a341f6d2061ff0919c02eeecbb9;
        _retrieveSignature[26] = 0x6fe3c094c04b7ade3d5f0fb6c3e89cdd307956098a11c88e1d6db7d05cd3efe9;
        _retrieveSignature[27] = 0xb070cbb691b3e84df297e6cbeabebe708c43208c6fdaa538a44cd927d5ed1f96;
        _retrieveSignature[29] = 0x088f14efe60f80a988f958c68689883fe284441f1ce6f1d514e24ed282fbc618;
        _retrieveSignature[30] = 0x084c3c14151f3a7d9f822b06d59b858f499f4efcba33c6019ee6bca48e500751;
        _retrieveSignature[31] = 0x451e059f7f1c832d277dea1823c94952e2992c090989933c980caf0f50199442;
        _retrieveSignature[32] = 0x39d3118ba73a15350264bdbf4e5848bcba2cc95053f490d00927df83716b0432;
        _retrieveSignature[33] = 0x6d30b55d2b23262e32ad5771f4859f83c9e930d0d793d5bd71764b72ede56b1e;
        _retrieveSignature[34] = 0x550ee821be6ca1d28422b300751966b8867574087c7d26fee8d30dafc30801a0;
        _retrieveSignature[35] = 0xf9dd5aff6bf7db230277e9e6c50e732c437331bf73859aca01614760d6f34d22;
        _retrieveSignature[36] = 0x596aa75fbff49f355e6db87c17f82002e235f2a64e2973afd466d491a0590dab;
        _retrieveSignature[38] = 0x994e120521750d424256070c39ee9e1786f05a99dce86f3db1595f82e06b3568;
        _retrieveSignature[39] = 0xb4be6881762eaaf19df597ac582182bab6fe2ba96859a61cfbe9b0477022e293;
        _retrieveSignature[40] = 0xd6bc7a594b8818f34a7ec33e4355dc39fdd40f2c7628662423d7066997f9052c;
        _retrieveSignature[43] = 0x4603491f5159936c7e9bf781af9ebb2307276f5b7b5ea055900d0aa6643c84c5;
        _retrieveSignature[44] = 0x09960e5d0a9b3e14f8a9167c06a5055c41a96b18e1f3b076cbbf859405ff8407;
        _retrieveSignature[45] = 0xc5b181e12574a364866921169096871d0dfb2f93fd743ce17ee7e757c182685f;
        _retrieveSignature[47] = 0xa2487860200bf6a31ec4d498e67a9c21c544b454de3e207e5a3d98ea7d6d3a6a;
        _retrieveSignature[49] = 0x2c293ad774d234af5a235edc2a2b581d991ad56f5bd6e237ce00be942386cd89;
        _retrieveSignature[50] = 0x5374affb90cef7dc87d431235e213297d791f9160289a4e425418c86a91431f3;
        _retrieveSignature[51] = 0xa88c9fc8da330ea1e4242eed659a8d6bddb7785a1a9ee1b8ba4c231ce3879d60;
        _retrieveSignature[53] = 0xd7cfa5cd7f307bbe21e735bdf1a9a48c912aa791a5d0c90b4491d7a0c7e39b5e;
        _retrieveSignature[54] = 0x8cd006a573f01d0b5eeb64845c0f41f6d677afcaf65e605b458131ca53bd49f5;
        _retrieveSignature[57] = 0x89aeb5e7b587316a5203c5a79e33e9e38ece34c5a3d03beeb765b14903fcd517;
        _retrieveSignature[58] = 0x21403ad714db88972dddd56bb623c314bd51c5b7f9d82b0ae4a549d0c82475b6;
        _retrieveSignature[59] = 0xc01d5515ff3455015832914ed5df09860b969fabeca764657a12ad2b2c464752;
        _retrieveSignature[60] = 0x05239542f0262ce55c4e1b951c6f5dcdfce9712c42a541bbd39524a8ce40cb2f;
        _retrieveSignature[61] = 0xb903eaf5270f14ab052111df244fe845a85da0e0a9f2c59fabf323a7b33a935f;
        _retrieveSignature[62] = 0x132f8731de12e7cc35e4572fabe631559af7f6bce8bcf191fe29510096967128;
        _retrieveSignature[64] = 0xf6bc86d5a21dfccd835d480bb7399a86d8880f61ce18913a23b2fb3e094ca2f1;
        _retrieveSignature[65] = 0x18077ef25bcb240e436271612424b6f9a91fc06ea7d7d12c630902e9c4176beb;
        _retrieveSignature[66] = 0x837a636cb8550f5e927996125daafeb95bc47cf98c7276163a9652644f2825a3;
        _retrieveSignature[67] = 0xe74d7838e5e0b503b1944c8aab55316b532d0cd50841f956bb6aa6369550a653;
        _retrieveSignature[68] = 0x729c5163a30cf4cf8968ba49fd61fc0f1c7aa559dbccd2698f54c9743b3cc9ca;
        _retrieveSignature[69] = 0x7c4ee7d15bf56b83cd881d3f5628aca7c18f724da2e000946ecaa8ffa2cb6891;
        _retrieveSignature[70] = 0x51b584d0709579bd058db741c236466b56768b69ddfecb13ea5d15718f529aaf;
        _retrieveSignature[72] = 0x5fa501f11da6f4f612429d826706a6e5790721cdafd9fdcd14ba986e81c5a2c4;
        _retrieveSignature[73] = 0x8a6168f0cb20b33e7513df124290c46bd7287ba30c34743e0af31fcb24966cec;
        _retrieveSignature[76] = 0x70c31c94cc0e3846e841344828987174b8ec41c8ac046028d5467723fcea190a;
        _retrieveSignature[77] = 0x1cf99bb900e74897bec2f3a84a1fb3dc838609d135430292c0244444147598b4;
        _retrieveSignature[80] = 0xc1c5191c00297b7d1452bddb75565f1350742e0ada0258fd88964f27c326b1b2;
        _retrieveSignature[83] = 0x4f3d3889e5463b9ccc58552509c41cc89978e1553c28c6bfcac036c70c81ada4;
        _retrieveSignature[84] = 0xc088b50b259528998cc056e1ec171881f84c9bd55605e28993124e6fabc077af;
        _retrieveSignature[85] = 0x47f8b4260add314f4fcb7c975f43f26b505dffb96b2fb8ae065ba4b2034b5358;
        _retrieveSignature[86] = 0x64760c529eefdd967cc24880c77868844a46efd69dce29f9cb02fe4b638cf9e7;
        _retrieveSignature[87] = 0x086006cce0e11cc984725203d99d676a70662d69cb6de5c56536e5039fd0555c;
        _retrieveSignature[89] = 0x8224ac2f2efae2baefbee8705cc87639bb48813941c263c307f2d88bee23a3ac;
        _retrieveSignature[90] = 0x92253760c7213cd3e15d67bc99e344ec338cc175433bcad14a390eaf7a2b9396;
        _retrieveSignature[91] = 0xbdca6bb25bba16d45a1180716fb302d2b8b8b0779d51a0b13744eaf609da4104;
        _retrieveSignature[92] = 0x26a539421707d59fd86deb2924e38ff7e698aca6bc9417b10cd52f50a0127b41;
        _retrieveSignature[95] = 0x131a8999156496d2d808edc1c4baa1207f2d107556d4e0b955ee104cc2204f44;
        _retrieveSignature[96] = 0x41b7cb26aa518ac848a052df55db1a8858ef2950028e724be259a089b626d366;
        _retrieveSignature[97] = 0xbb89ee5d2456cfba960b13d426de7347e3ce06d35411f18b462b0cc06f739758;
        _retrieveSignature[99] = 0xfe5377a88249a2d2d7b6c1c3f4e13b39e546847cc572fabdfdf8b49b6bd7f10a;
        _retrieveSignature[100] = 0xec67aab6e44a2342cf64b88ca8de4322fb13a9801e78355a924a6c495d78c124;
        _retrieveSignature[101] = 0x1acd4b9ef8a5c425f86fa24f9b63627061737cbe0e43b037275834a819d2533b;
        _retrieveSignature[105] = 0x10db5d717e555c59c4a495eea556610ca8929ec3d560b74ce318eadddad0db5e;
        _retrieveSignature[106] = 0xf3311e4db7840575b085dd79e37019e3ddd58e3f76e60b073055ef2be31a6ac2;
        _retrieveSignature[108] = 0x58838ed335305bafd2f6261865ec9ca3ea66f9f82530e1538e4ac61c63a65fa3;
        _retrieveSignature[109] = 0x9a99bca050f61a344f2a7633bb39cd166e85dc681207b5d1102e555d79e85c3d;
        _retrieveSignature[110] = 0x051ff1e30e75094b35eda759374cf613e822b4d20cd8fd38d706106be95c5eda;
        _retrieveSignature[111] = 0x4e4a3f84b4d5b92c3c59575885f744ce840dd8fab46dd48710e2b53a43cdeb3b;
        _retrieveSignature[112] = 0xdd49a5f24ebaa0935069dd5f8f98d07b72a421e443ac48a71b09404566a7dbe8;
        _retrieveSignature[113] = 0x3bfb17546682fb1ed5a24aa4af401a02433c3df9a8259cdfe65b65f52c5929a8;
        _retrieveSignature[114] = 0x86608cef47d88c1f4e3747bcee9f24dc168d5d0ac378c9e18988d606b1abacb5;
        _retrieveSignature[115] = 0x357cba88c4e341edf1698646351ee68ea36054e26474c0498cbd3bb0132498ad;
        _retrieveSignature[116] = 0x1caa06514f35bdcdcd782e070d7d71a94568fa90649c65675c86234dde1e58ff;
        _retrieveSignature[117] = 0xc2dbe1099655f062f82d78617b19b5385144b23fb11270212b05cc41d3209eb3;
        _retrieveSignature[118] = 0xbf9635738ec50d27cecab6033aff17074c12a869e945e0d065cf09d60dbb094d;
        _retrieveSignature[119] = 0xcd749a8db12b693e87f2bad2fdf38e2079e859e32492ecb566fca59cef094fcf;
        _retrieveSignature[120] = 0x08c567f9dfa4af697dde15ccdfce9bd2e75149e8c5633ef6b9933bbacbe67afc;
        _retrieveSignature[121] = 0xbc644b0b1eb14105f79df81bd68dce70d4f52e0ce6c0031c50fc5d2b4bdad73e;
        _retrieveSignature[123] = 0xbc5fc23063e4d3e53b9c38eba4aa9d4e5512612cbb33620a745ba2a1748619e1;
        _retrieveSignature[124] = 0xcde2126e90b7aad0aba85e1b90179953379764626e642641567e41d7aa278851;
        _retrieveSignature[125] = 0xcb8ea85d9718bc683ef1a0ea80f91ddb46526b5e198596d77cc1c56214148b2c;
        _retrieveSignature[126] = 0x4da5a45900a654593bfaa6da04e2313f856a82c0bc5aa70a2d2f5780f3659c3f;
        _retrieveSignature[128] = 0x9549159884b2df59e09af556fe0d1949794bfb1e4b7a3916036827f8dcbf8daa;
        _retrieveSignature[129] = 0x7c538d755053d1e932c09abcb17ab2d0a45774270eb33cb37c8ca792c0509bc2;
        _retrieveSignature[131] = 0xd92e11657f477bfadd0cd39b80a3128309725f68473dd6e6850188ddadeb6f48;
        _retrieveSignature[132] = 0x457cc1bd149a8488a48ac3c8905debb466f5c13569b2b5eb905f2be5de3d4268;
        _retrieveSignature[133] = 0x1538cd1ede1be9a759f43398de89fe7a777448678c6004775827053edb7a97de;
        _retrieveSignature[134] = 0x763a763e452a4750ce7be455adbe26bdba9832aeb829753fee52b45991e1ec34;
        _retrieveSignature[135] = 0x19bf71f0d509ea67d347ddf0a7b37585ecda6bf248ebb6697285eee945795ad3;
        _retrieveSignature[136] = 0x58703eb6184d7723d74296897cf569d453c3d0555c12f6d28f4b8c19d9d13245;
        _retrieveSignature[137] = 0x91fe0473d98cf6e7387c6725d46c061903c7b0fd5218c7eda84f29be4263a275;
        _retrieveSignature[138] = 0x9df23684071947a27103b535520aaa3b8ded67f9a083cd00e04a24c031828654;
        _retrieveSignature[144] = 0x8ad3a10c8c6b7532e8f508c6a82dfec222f8801098a1a2418aad3450248f49e4;
        _retrieveSignature[145] = 0x46df2eee2a0447dea9136c5ff6ca8c73810b8fb727901335601f46917be70a7d;
        _retrieveSignature[146] = 0x07c055a97a928c99c7ee9c6381431aa14dde0ce41ad6a4dac0d8c25cba87b437;
        _retrieveSignature[147] = 0x8faeca7dabf98187adfa28431cdefb66796fca356fd388aa559b448a36fd5c20;
        _retrieveSignature[148] = 0x2d899129a58847a721716ce5c4df06bcc616116d022eda2e922a6ba291e3d724;
        _retrieveSignature[149] = 0xd1d62a987f0861a5d52eb81ac92d48a734ac9ae43a459efcc4644de65bc148ae;
        _retrieveSignature[150] = 0xec16f7fcfb57c7e990629bdb3454061f1f09bded8b871a8154f2b86d95a4bc9d;
        _retrieveSignature[152] = 0xaf759c30b3e31fabc463ce1deeffe463c72c70081e41fb0cf8559174e3e23ad2;
        _retrieveSignature[153] = 0x54cab4e7d1ec021fb3a2332e6366dea5dd7368dac9ed1b77d7bf28314b0e351b;
        _retrieveSignature[154] = 0xab3fd2770f428e2e2ad8489f782f36b7631188cd424b0cd6afd34846ac4344ca;
        _retrieveSignature[155] = 0x6b5fa6f4a92fc3a3f755b56f9712d1996473f46338ca43c8574b8574dd9c4fd4;
        _retrieveSignature[157] = 0xd165762809f0be42157dcb3ee8307a4918b96785550e4678322bb91b3d72860f;
        _retrieveSignature[158] = 0x0eb9f05e85d10f8d1709f7d17ed13542efcd7f95a98eae376c89c3a7d48be774;
        _retrieveSignature[159] = 0x17f57324a74f6cc99471591ca4dea151d80bff77164f0cdc5a59583e8ab738b7;
        _retrieveSignature[160] = 0x4fc78dac640c76d346f9545a1f3c23e57d6c85f5eeac3dcc80bf2b79f8895cb3;
        _retrieveSignature[161] = 0xa9cfcbf3f40c745a3bef2cbd2f7102e02be6514741b62c4406e9486378e6bb45;
        _retrieveSignature[162] = 0xf1552cf53756378b497acc5a2de7c083fff6cdf8415e158ee73cef7eb3db36d5;
        _retrieveSignature[164] = 0x1fe13517789adacd4b45f2d47392a528925ac24671395df5553ea3fd8f97eebd;
        _retrieveSignature[165] = 0x5e340ac5186006508a85a3c656e05fafb5f4f652b59b36c6156bb6dee398bcb6;
        _retrieveSignature[169] = 0x5e1ed2a306b7ff34601c85eda2ec4c199bd8cc0914336580ddf0e218bdc0da18;
        _retrieveSignature[170] = 0x2da455e2e12e2a515c3895ac9d2ce8b665884c856ef0fb528009dfc9d87fbf4b;
        _retrieveSignature[171] = 0x4affaa8284ab14a894e9e3833f5ad7dda5d02fb54cb00201236f7930622681d1;
        _retrieveSignature[173] = 0x7cfab7a4a5fa4d05db4d8ac0c6d7c918ecbdb49f1b544bbcaf3120b688965fa4;
        _retrieveSignature[175] = 0x0ba1e9a5218ee8e915cef9b0a2c1bd76164529a4d165b0b7be9ccdbd3cd2173b;
        _retrieveSignature[177] = 0xbb92ef0c569ed30fe32aa434cf14973d4b0b21c4fafd4ad68a0d66ac1f936f1c;
        _retrieveSignature[179] = 0xb9a880fe9b0c5d669036fea94503a55f25acb5d9f4dbe13cb41d9cc63dcd55de;
        _retrieveSignature[180] = 0x32a9623793b8d859d5e97d1af776c8c17a2c8eb6ee80955e6bddfb4c7243e273;
        _retrieveSignature[181] = 0x728f09de3f0fe9a2eb9cfb9df135b0bbcbb9dd837d5fa14a7d9e43814723f5c9;
        _retrieveSignature[184] = 0x580f8ca730c65999adbc6544c1aec71c222c24e410f01847d5c9f9ca04155713;
        _retrieveSignature[185] = 0x3939632fe2b8bf7ca83a672b263027b4c8c3c100bbec88d995c02815d5c54462;
        _retrieveSignature[186] = 0x7ffb5402891fbb6749fc87085cb41915a6fe19f227e203548221492c37f272ce;
        _retrieveSignature[187] = 0x31765f5b4e6f83c3bc228e83905a4c933b3f77cc04d3010f4a182105b0b72994;
        _retrieveSignature[188] = 0x94deb49687d2f1c5d0d4017275a288ac43947cd81f9ef430c3146baf30c6f5bf;
        _retrieveSignature[189] = 0xf8dddee274ea88e48e4e1489d75f6361a3afb47b68060cc4683374195a586bd9;
        _retrieveSignature[191] = 0x4acd7e4a64153a98dcdcbea0507fe7e1ae1402e2b8a7fd4b01ba8ce772245a03;
        _retrieveSignature[192] = 0xb030a46d2d1201f086cfcaa0a5a0dda42b4e731a9e7f8b943032d4f9ab2fd8a0;
        _retrieveSignature[193] = 0xcde8376c3463692c22a45b524c30f11260b44eb85f4135a4155b66fc9495f59e;
        _retrieveSignature[194] = 0x2b9ecbcb7305d14b68d09ec245c1c830cfafdecc9345159caef2ff1b5acb5c15;
        _retrieveSignature[195] = 0xc62259586f74a6d9a0858180b5cb4c4c70a46ca02a13508f4547be8abd708b74;
        _retrieveSignature[198] = 0x3e117f2dad7d7ccec52f8732ff244d0cc9c4edfd960bd85ca13d0d4cc015e48a;
        _retrieveSignature[201] = 0xc82b2fc57ff50da4498e3e814e56fb6cf87af2b8d84a873840d799ff31966c38;
        _retrieveSignature[202] = 0x234a07a3cbb532cc3f190c546d641d99e49211c55f646730147bb049a732ae47;
        _retrieveSignature[203] = 0xd944b7d9ba2c90fdc0c10426ebcf5c138f3c6eb2e795f34a3bd73c746fa06e7e;
        _retrieveSignature[204] = 0xee046f3ca17b0989de83a4425b200ccf2d20825aa455ecef1d1e2d3f72e272b4;
        _retrieveSignature[205] = 0xf2c80c8464286c004e30490142f8ebc40d7ba0982893a09ab88808de4cdd25d5;
        _retrieveSignature[206] = 0x3c4276a9c07aec29ccc7fad95188cad1fbd59af420071357aea1d92ac764d6e0;
        _retrieveSignature[208] = 0xeac9b96001272a1ed436b24f4565a581cb34065ab03981b213dad45385568d4a;
        _retrieveSignature[209] = 0x3bc860c1475aca7eb0f1863e09fd9e1830198e6f5870a7b867a7477a95ba0250;
        _retrieveSignature[211] = 0x471f1808789c7cce528755f80761b98cd71e467a77b949e01eb5bccb118fb0ca;
        _retrieveSignature[212] = 0x126ee998171b5aa1f14180855d9c2a87bcbc8537c54d49a73ef45f0b26dfd8fa;
        _retrieveSignature[213] = 0x618a6837a03476fefd5701501239a1f9ad215fa5afb9b6cb9de8998c15dcf4f1;
        _retrieveSignature[214] = 0xe14bbe8d649b9fca644bda20a9bd16a31d47b9e3b3e8f88a3c08b82438fe3efe;
        _retrieveSignature[215] = 0x63b21c5e4d342f6970f86964943ffb5e9f64c65a71f3fed65e0cdc3c678d02e4;
        _retrieveSignature[217] = 0xd492538b9da868202e6c03b9740dccd7e8b3cb4b054bfc7681878b224109dc24;
        _retrieveSignature[219] = 0x319d56677c260cd45abe9edd6e34b8f13b13415c5c07a24f94381dab98dc9983;
        _retrieveSignature[220] = 0x705d81fddca861eecb11ac4205f50cef0c4ea46a0bd43ab616fbc248119ce3c7;
        _retrieveSignature[221] = 0xbf65d548ffd45accd95958cdeb70b8335329882a9e6a70656d159d3b26713a74;
        _retrieveSignature[222] = 0x156d43601c228fd766c68bb4bdcbd430eb0ff4c4194ad86976732b17969c4c58;
        _retrieveSignature[223] = 0x06eb5dd79a9c0eb5233b230f7e210c0d8f6e449042baa27ca60c53afc33d9e15;
        _retrieveSignature[224] = 0xdb0be4c15edba26125f831ed7d7742a11602a3291d494aa8b5b9d72743692504;
        _retrieveSignature[226] = 0x67f4f4341919df0f0b30bfe0b15fe69a1d4567b8c7d08da7da3fbfa73d629a6d;
        _retrieveSignature[227] = 0x41b694511a06b4825377bb6a2e2dcd42ad62399307382ab09cdf41146230557e;
        _retrieveSignature[228] = 0xa90e7e6299e7137270e88cf7cb279fba6b86a55f10947c7cf6c920f93f5a929e;
        _retrieveSignature[230] = 0x95cd8c14b0502b2952f8c8a3e86e2e154ff6fb619383efe3ebac4354b258e678;
        _retrieveSignature[232] = 0x9c37a6c089ea00988c7bd4eaf42ee27adfc45ec5dcb539af06497a4987bdb193;
        _retrieveSignature[233] = 0x00c6be2e3fd83b412057c211602236a2f5418d14dbb17c6ae13feddd7c2b1aaa;
        _retrieveSignature[234] = 0x40d49d97cb8efb4ec08fa93e551300c70057957c778cbf47085e93a73118d883;
        _retrieveSignature[236] = 0xe3a46a0ea858ce217d2aff00a302cbd12cf6da9182ddcb724708230fabd30768;
        _retrieveSignature[238] = 0xc65221f2241d91dc0f100c3da89781e5d273e4fa1bb03d5d4b7e64b816c7584e;
        _retrieveSignature[239] = 0x98ba7b6415464705382134f514c9b6e10f99974d3979d889b37b5a57ffe545f7;
        _retrieveSignature[241] = 0x0e0e87cccbf403c7fc6dcca5061aedcdceaf3462955afb3eed005d1e5f10ed25;
        _retrieveSignature[243] = 0x1dab6e8ba6f07f6317b03a5f80e3b73ac38face44eb4ed919eb05526f4945ee3;
        _retrieveSignature[244] = 0xa5aa84487b5d2995c22d2e6700b116467a9f58a5088318b6700517e6b11481bb;
        _retrieveSignature[245] = 0x8fce52db9b133dfc2a7ed1ac380fa27a5dc4dda30cee7c04be8c27ebb2888656;
        _retrieveSignature[251] = 0xfb35a64d3f856d1824370081c700bd3af97fa5a7e7a9676484c3d1f7baea842c;
        _retrieveSignature[252] = 0x19b148b3cd9a37e646b4b86e16597b31bd436bea38ff0100b84e944d6acbe4e3;
        _retrieveSignature[253] = 0x7a563231ca34c429332026118539da4d64ac8554bafc062c023b2ddc9b8cf119;
        _retrieveSignature[254] = 0x903f18d04c1dacbd519cf20a0d780e81c69e6b46835153d46a3a9384669c767b;
        _retrieveSignature[255] = 0x8902449d2ed2c8a149b306da293cdf160593b1983d2448bc197c23e47b97ebeb;
        _retrieveSignature[257] = 0x4a2e2bda0ea829d7eedb70ceae301dc73f6085434307f81533c5300c9180e813;
        _retrieveSignature[258] = 0x89dede6b1d59e1915000cef72141e03618e7a726e77131eaf29ae19f08ec5029;
        _retrieveSignature[260] = 0x5b0232ca22d456de554c5a0550d9284a303bbcc0b12163ada7b2472ebd11577b;
        _retrieveSignature[261] = 0x032887be777e1051146c9d2ae12b319b2207e872a5f1c1d727f488a421d1c1ba;
        _retrieveSignature[262] = 0x8118550ef76df14b5c4ad77e1315cd84337641485b0d4f81b190654b16c891f6;
        _retrieveSignature[263] = 0xb0d102b54e544cda3f64df7591d658771af01a602e9a9eb30bbe7f178b70e447;
        _retrieveSignature[264] = 0xd44d0d2fcc4337d7088ffb37043a9e7afdddacc583cccb423e6416ccafc847d1;
        _retrieveSignature[265] = 0x85d906dfb2241783a7be4e06295eba135fb4c77e13594eedc6c6af0899966f64;
        _retrieveSignature[266] = 0x90b95b24067d7821175ab58ec26ee6e4f76d6497062ae540afcc27bdea87c25a;
        _retrieveSignature[267] = 0xcc6a69234a04430180f5abd01edb9bda6327e09634ec93733c229e2d1e005260;
        _retrieveSignature[269] = 0x33e5def24a1e2682b2b526143423775fcb45bab0544a19837519e51b3c8f4b8f;
        _retrieveSignature[270] = 0xc79aba6a79957f6166730b8b8648de11de8c68d654caa4665ff31f2106de0d9b;
        _retrieveSignature[272] = 0x712e302969770e1bacd248112b95bb125c33d9c33e1a687ca977e522356cd1b7;
        _retrieveSignature[273] = 0x865746f2c5a53cbf528b7cfe8ae84d56286be641986e2fb3fe28483a1f5a3d9b;
        _retrieveSignature[275] = 0xe399ead1e04ee72f198167e772f44ebbcb43d41b321243d886172258b4d82157;
        _retrieveSignature[276] = 0x7f2a036f146bcafe73027080f090610b382259ea04e94bc601507849649bbed6;
        _retrieveSignature[277] = 0x6132591cf79f840e7b25c4ecd479e6c1550b9f3b249efa4bcf96be490dccd744;
        _retrieveSignature[279] = 0x355a985b74c210d8fac87ae07209da4e0f8827e82c7af85693287fee5109ff72;
        _retrieveSignature[280] = 0x8331550c4e1ee010d6ac6834409b6ec3b37814133ffe9427f99ab3be9df79da5;
        _retrieveSignature[281] = 0xa26804c687d988f54e49abb36a40afb98cb2643b31d46be0fbf31f893bf33865;
        _retrieveSignature[284] = 0xcdf5200fd9633836fe61fe045787d333df386f247e8b86d73e36f34ab3d1428d;
        _retrieveSignature[285] = 0xf55580a1c3bbdea436cebeb4b25d050897032359b67c7170fca822ccb783a0a5;
        _retrieveSignature[286] = 0xd132ed37636ff8c3ee84920a6bdc30f221a6b6b105224e48176f198242573c42;
        _retrieveSignature[287] = 0xd66b4f87c4cd1bc7daada1c555ca054ec64133a16032fa478dc5a1f97e126fe9;
        _retrieveSignature[288] = 0xd807a8f78528d11d2d24e959ceae9c698eaf5efe40a17bca8d9c8621fbdfe55d;
        _retrieveSignature[290] = 0x99107fd3c3c17035936d7750eecd99cbb354df0ffedc80e4bdf6e75f3a5f725c;
        _retrieveSignature[291] = 0xa18ff565f3ec80a54530b1ff4345eb45f21b868cd60c4649dde4359b910768e7;
        _retrieveSignature[292] = 0xcc8036f112db2ed9077b9e3d5747d1965cfb01148f4e8193a26d20056a8df650;
        _retrieveSignature[293] = 0xdc133f7f7b257768cd0ee13f47ad56fc08469e59ab1e8c9f93c49de3423a60e0;
        _retrieveSignature[295] = 0x332f58969d112bb7959ea5b9e7b9522c879ecd06bc0bde1301ac41aabe15f919;
        _retrieveSignature[296] = 0xe4e8fad43291d1cee315f30b0c7ea6033e851cc69c746421f1f603656f975a79;
        _retrieveSignature[299] = 0xe4ad0503cda9051cf9cae9115b9fe83f775a4b2160f699462cff29c423f65bc8;
        _retrieveSignature[300] = 0xea9599efce0b8f2c944f38b1c7686cfe6d08448c25041ca6352b4ccf0c094e67;
        _retrieveSignature[301] = 0x60d102a888aac7989eca255b32f4e79c25a49847e6e67cac06c103e26bd27fca;
        _retrieveSignature[303] = 0x453185c1224287c03b648cd318b50fc599f945f6aae4590b571294f17db820f5;
        _retrieveSignature[304] = 0xf45059e557394abf55c210f355c4893ac413f0b9c5cd19353ff32267ca623657;
        _retrieveSignature[305] = 0x15e0ec4d3d5fadde0c43022e47029675a26974c444844b71f83ff18cdf753fc5;
        _retrieveSignature[306] = 0x7e239782d3545adea2723fb5791cb953c87fcfae45a28c03d5d2643d75cd6ea5;
        _retrieveSignature[307] = 0x7d7a93dd93344b29308652c6fca1d8431027813ddba08c440d2d6557941a1b0e;
        _retrieveSignature[308] = 0xa3d48ff0d2f753916920d96bf13e77e717a28235efc5625eb357f308e4a79267;
        _retrieveSignature[309] = 0x47b8960d08d0dbf5c5da5a5eb63509939c9979fd0e0d76c88fb00ba371f4cbae;
        _retrieveSignature[310] = 0xc134a45bb026327749ddbf47605e163e1257bbf83059575da799b92ccbe5e0fb;
        _retrieveSignature[311] = 0xe62310e0e3585fea387e4f2d0a1029d45ebaea4a120b467fc083131cf6923744;
        _retrieveSignature[313] = 0x7dc619730b7233b9a8cbc9adccf6b3c476904937b7524a1e218724d75e8ced28;
        _retrieveSignature[314] = 0x4bf1ad604867b173b25517f863a28b3c359c3f11f0dbe45fe543bc16b67a961d;
        _retrieveSignature[316] = 0x52ee68e1da915484b4b567ba7b3bcd306f35956fbdd782d9814858ffd027fd41;
        _retrieveSignature[317] = 0x7d2165d0da7c04f34c9df4a8a1c2e70d76ce80f979633619000798c9643f5271;
        _retrieveSignature[319] = 0x3fb8de696e5f69d66c9ad44c699b3c8207f85b16961c01cafe56b4b38ebc45fb;
        _retrieveSignature[320] = 0xc3abe60ca6a45f7f846afdd7bcc18b3413e85e158aaa35a848ef6c834239fed7;
        _retrieveSignature[321] = 0x590b47ca55aa3412422fd074fca875e6c46ecd4e8ec1aa7f81701f549f0fd164;
        _retrieveSignature[322] = 0x786a4ffa4b2f26cdbf35bc017ed8748507af18e82b2948658bd2e118192f20c9;
        _retrieveSignature[323] = 0x8ab4f8de1d27be3bb3c3c0c3529ecdb927deb8e5f8ee15879144d60221b48773;
        _retrieveSignature[324] = 0x9be1b6a1ed4561d4c20a86db58f20391dc56a1b28c989fcd970f86df3fe418bb;
        _retrieveSignature[326] = 0x7ceaeecc2bf416ba4f931009e9f9b6cd788086dff4ce34559dc03c107cce6f39;
        _retrieveSignature[328] = 0xade6736ff4c9e1a36ac556983239cfd55825c5a3edccc58c68ac16694a117e7a;
        _retrieveSignature[329] = 0xc301b866b0df0002fc499a2560fe7e7c4848a9842e347dabd506b12144c2f7ab;
        _retrieveSignature[330] = 0x0621b3b11bafb91ff0fb077bb7d98a4650b839f17518fa68baa656b558dec074;
        _retrieveSignature[331] = 0x697fbe0f602f40cdfda4a2cb9d1aadcd7ddb7dac21fca5784a946287e12b5929;
        _retrieveSignature[332] = 0x49d6d41049bd3cfc1ba269a955547b56c1988b3dcfee63ecdeae994f0168cb9d;
        _retrieveSignature[334] = 0x10663e965fb7176e0c79a1d479281e53e98d7d288a2703ee5eb7768d9b864836;
        _retrieveSignature[335] = 0x9aa4ab47bb0b34fe7189da8ba6810e109cf390665930e5d4a6b3e60aa06a968c;
        _retrieveSignature[336] = 0x4f42f44d4f9a2fecc0bc1ff687fc3118c76d23d8536c3cd5fa427583e45e6b80;
        _retrieveSignature[337] = 0xfa61b08f8ff1a7245dadeb29f5fd14558495d471f2fc83e47b68513a9ba8349e;
        _retrieveSignature[338] = 0x0ae17ace4911c62e15ce1d3b0592dfe6429e208d8d4d29b868a4823d326d36fb;
        _retrieveSignature[339] = 0xce5ad514830fdb894765c8e90773cea7ad7f62f54b8444695ff15cc83b9d2685;
        _retrieveSignature[341] = 0xad0e03178f9a8f86f9379d017c2234cc5636212ebd1c2088b16bc3c48a997e80;
        _retrieveSignature[342] = 0xacabd9b9af49958cf460c10a87a0496682d169b41c3fd861c5a20077471eb1ba;
        _retrieveSignature[344] = 0x5c2625bec0fac60b5d8fcadd94a070fab3764e9d3dac2f1b251a79e09f41a696;
        _retrieveSignature[345] = 0x7d27dc7263fedba0fd6037bd0beee93dff00c20644c81d10c441cf0aab7c8d00;
        _retrieveSignature[348] = 0x9277af7bedc0719ed609a85ffccee1f51018c56957c08400e03d64af341ca8df;
        _retrieveSignature[349] = 0xccfbf8c1cb92590bfca47e401fc606f925b4cb0c6950f3e22bd85abfeba65a10;
        _retrieveSignature[350] = 0x0161ebd85cedf2b9980d8fdf543de1853fb37235fbf42a629d2e69c8716a0068;
        _retrieveSignature[351] = 0xc8eb1c626f98ccec6622968cf29a9e1e6923b40a7414b0942dfff85c5f1cff06;
        _retrieveSignature[354] = 0x9fe438b9e651b5ab31a94b503ca3f5282f1fc32e8d4540736969170fcf3073bb;
        _retrieveSignature[355] = 0x8c5b6fac33added1006d1ef7751de6a0f159dc82b7c1436baeef11a0aa2615c3;
        _retrieveSignature[356] = 0xb6ceecbe4074fcbe3c25c6177f4fd48d5cb3e24a63c86a29aa9485de3bd19938;
        _retrieveSignature[357] = 0x5a6fb66df71f94b5fc254eba7808fc92d804c5878ebb2ef9829234ac5a545edb;
        _retrieveSignature[358] = 0xedf8ac98db9d2d59af9528c73ad16cb2223781acfa8f802945df794aced43eba;
        _retrieveSignature[359] = 0x7849d0a4c4c90ab4fcf8faa87cbd75a0ad1308f48dc98b3178950af42d7e35f9;
        _retrieveSignature[361] = 0x7d43c86985290c7f28808aec645c449babb97f549f25dc7d3bca0f44a38148ba;
        _retrieveSignature[365] = 0xc74571b436b1966278366e2be128e532c855f0b0186f33963475aeec50af38e3;
        _retrieveSignature[368] = 0x54c130425bcc3c18113f0ba5a2a9a8b49383afde10125a0a5071055427fb7753;
        _retrieveSignature[369] = 0xcad5978026737ac2de0f36568ffe234afd74355e2bd9b039fdbc26c800cfeeb8;
        _retrieveSignature[370] = 0x7da1a9d822de9827b6c8a8dc190ec8299419eded5fbf8a343fc0aae64c8a625e;
        _retrieveSignature[372] = 0x681b52bc4f0be32cfea780c3da49b2e340e790536ae05e161d9d92f5b49e995c;
        _retrieveSignature[373] = 0x998abe15c67e1cb125d610b4b6b45c54562e14e648742ff985a9f0505970fc00;
        _retrieveSignature[375] = 0x94a3a4ec460d47263e2321787fb58f8e388c52e1e964522ea747ee1147998eb7;
        _retrieveSignature[376] = 0xd5b20925bea9fe575040bff90eaede8ad0f13f2aa9f1df73c497fbd3e504620d;
        _retrieveSignature[377] = 0xb90965052566fd8f9517d28a9faca2589255c8c79ed431fe4e9eee4f9ba88709;
        _retrieveSignature[379] = 0x0a9e613b9fcd0ea3ac6385bfd4ae7294fd365b55e8992bfcfa6792db1ea1329c;
        _retrieveSignature[380] = 0x83f6542e2e9b93a1539ded260b3016a789da30ad845a77f293a678b5960a3601;
        _retrieveSignature[381] = 0xb8a9fb142eafe7cf22e47730879ea9f65af7a378d393d9c7a963aea385c2e4d9;
        _retrieveSignature[383] = 0x83453588a126ee2665f9d7d32f95bd7fa2f3d70b95313beb67bb05a673bf184d;
        _retrieveSignature[384] = 0x5a022211efd9cedeea13483e665b268bc16ead2c0c87cee78fe2025f1f01474f;
        _retrieveSignature[385] = 0x3d062a5a31baf2069a2c2e4bd842bfd164dacfc902c4dda59f3338b31841faf0;
        _retrieveSignature[386] = 0x3a62953f83378701e48078e622cb01e7873874834eaa13013ac6f7179d9479d6;
        _retrieveSignature[387] = 0xee922007d173d915598b7033e95dc110d3c9f92822c2be674ec3aa7c3e95d463;
        _retrieveSignature[388] = 0x86799c871be1a0dedfe99d2fcca25a2bafa96abeea7e149392d2b37c3f47d1a2;
        _retrieveSignature[389] = 0xd4df69be045c612a90ef81687b1762345e8089cd938ead499ebcb0cb47539f5e;
        _retrieveSignature[390] = 0xa8b2fb467d713cfd773214c1a47fdcd543b00a09f6a14651a47be95ab421bdcd;
        _retrieveSignature[392] = 0x90930fb571a9c6a534681cf882134e4378667fd772beb5a1266f3034c38562d2;
        _retrieveSignature[393] = 0x153fa7328ff0e3c236dae5d8c138624478013ba1c0ccebce7ce462f00c5fe977;
        _retrieveSignature[394] = 0xa54d2b3f682eb1756c21550eedceb964b732292408cd214e3341151c3120b92b;
        _retrieveSignature[395] = 0x63a3c0768ca4ca70c9625136de2ff0c588c1f5a913578b7c1664937e33700529;
        _retrieveSignature[396] = 0x09f075e860918c54f6a4e2cf08d017509ee28e5311098dab111407dd12c9666b;
        _retrieveSignature[397] = 0x100f6e2306eb8761d7397076f6fa48962b95d8068d01226d38447cf05c5ba61c;
        _retrieveSignature[399] = 0xfc9f25213018cf2f46ea16c3bdcfebca775285920ae1541f82243609f5cb06fe;
        _retrieveSignature[400] = 0xc6e1714159d81120e20a68c840fe4e4671a6743ff33d91229261a7378ec2a251;
        _retrieveSignature[401] = 0xd6c3fba9d272cef4555378e5b86f25df612f3f6b3172a15cb9fe94bdaf4eb522;
        _retrieveSignature[402] = 0xbcbb5b23ed861e2f304d69e6fd0c3e1bb3cae15fd03ceb16c70909c733040afb;
        _retrieveSignature[405] = 0x82b41ab91c987bf37270ecb516ce9fa5c0ebb14cdcd0de93a8398b0d69353f90;
        _retrieveSignature[407] = 0xb5b4d9ba82263167b35a2a5ee4248d5c73d77d5fff3de687bbfdf0c2f4b42a4b;
        _retrieveSignature[408] = 0xa7fd82882d6d08169246dc454e8c015d668ff30367d09efae8f0600c19c76f94;
        _retrieveSignature[409] = 0xa86fb82279dbfa867edb7d8a487f268a52ebc9263ff3d8ecab0bc9ea4bd54b81;
        _retrieveSignature[412] = 0xf155a4f3bbcdc5e8ccdc4b3c973ed918cbdcc7df05589d6236b2b0d620887b89;
        _retrieveSignature[414] = 0x42082c0b9daee042d4c007f0f983a758b2b0b3f55275d0bc4ccf0f2579e66e20;
        _retrieveSignature[415] = 0x8590dd00951bf6d9d8d84697f4001e7a5ff62be649e6043674f856a922f53393;
        _retrieveSignature[416] = 0xc51d9cd2e525d76ae32b5dd88fffb8b2720323707aed11714f1a1e39b06474bd;
        _retrieveSignature[417] = 0xd9ffd3f0af336625b64ac496350510738001d8e226464f21f9d8af8dc4d09d87;
        _retrieveSignature[418] = 0xdceaffe12788e34adf68ba44cb7627bba09ce95b78b4b5b1cc92821a3d48cf14;
        _retrieveSignature[419] = 0x3ada921f06c896bfd7891ad310039a873f482b93a5504c8b2934f67f9d44ff94;
        _retrieveSignature[420] = 0x8377d1a3a5736c626e864126986e0575b34ca153cbf1f5c870d40cd850c13264;
        _retrieveSignature[421] = 0xdc7d4e7be1790d3ccee571ddf933c92a2db0c37df49d8486729b9cce138572fb;
        _retrieveSignature[423] = 0xea6dce1d633aae0df53378fc31d776633974131a71bad405aa13f8e0714d4097;
        _retrieveSignature[424] = 0xde51608f5c23e5998c659b7a4eb4b6514f3a9437c7a9d7628f97b9557bc97659;
        _retrieveSignature[425] = 0x2ef87420c7ffa26c2f94b272de674edc0657f16f40ffc46afecee4a62c9357c9;
        _retrieveSignature[427] = 0xb8d12ecc4443c9758a7685f2122268b6498e3fa36eec5c172b6d4fdb58fcdaa6;
        _retrieveSignature[429] = 0xd6a64c0ed2661c628ff26acaae45b242981f81f7c9be371a852cddf3b9c7510e;
        _retrieveSignature[430] = 0xc9aa22ed6c3a20ad4176118c47b44eb0af4fca3c07228aae787adc3d4a142079;
        _retrieveSignature[431] = 0xd9f6cff45e565320cc8fa10693842539eaeda0c422fe1cc779b57818fb331310;
        _retrieveSignature[432] = 0x0441cddef0a99520e356d6d25b908b584c8cd0f38be506457bfd7c2217fcf52e;
        _retrieveSignature[435] = 0x07c05a57469d17e09f69ca1ce5c5880d86554cce3c3a24d6d9ad6109154c35c0;
        _retrieveSignature[436] = 0xdc139c8ca136afabbab45f3c3d25b9bd8f03c716e3c7ae0619fcd2b1b24cb3e1;
        _retrieveSignature[437] = 0x67bc045a125472ddf663f36f2099fac5c003e7eebe6a4515c386fb161c1d5b6e;
        _retrieveSignature[438] = 0x5af6fc75758832561cc4cc2e8df2cd61803e06a17dc553b1c109e0cb384f1209;
        _retrieveSignature[439] = 0x185386dd821bb8b14a924bd66647112d84cf7dbbc8975fb95eef7e0e3672f45d;
        _retrieveSignature[440] = 0x07e7a5b0a5e0999c36d2ef63339ee8ba0b83ab9922102df536da9dd2c0fb39d1;
        _retrieveSignature[441] = 0xaaea26fea49ffad4bd4831cbaadaacdbfba833d2b67fcdf2bd47055417af2d32;
        _retrieveSignature[442] = 0x8c165dd2123cb5e202af575a34d4175d94b8dd6ba36a68c67f451da3594641e7;
        _retrieveSignature[443] = 0xa3ad9b4cb6a337178c555dc81ab9e4531c1f0e62a9820513158209e5ccf9d802;
        _retrieveSignature[445] = 0x72984099959061e7a1fd60b6d7f34df44ca2673ce4d2de5bd79c05e8bfcc97bd;
        _retrieveSignature[447] = 0xaa90aef541dc0e9a2602566456871917cf0bf77dd68feb6b74a174038fc95c26;
        _retrieveSignature[448] = 0xf2cf618758a079acdabcb2fcce4390f128b1b41367ac000a1dfdf6eef296ebe4;
        _retrieveSignature[449] = 0x3d98558ef43acccf0ad162ff9afd2b625d1531ebec57ee7f500daf79b4e8b98b;
        _retrieveSignature[450] = 0x0bd1399723ecd2a6b3645a6abf2d23151bb220ad78df062bc7537b74e17c7653;
        _retrieveSignature[451] = 0xa6d8b46b0ecc584d447de335bb23cac995b0cd29da229581cc4d2e1f8a684ea0;
        _retrieveSignature[452] = 0x6ae72c54e6f4ea3c34418d40095f499a20ce686adad961dba472de30f6928eb3;
        _retrieveSignature[453] = 0xb3e15271536f71fc40caec6823312ce71c70fdc701f6547766d3530a6ad42f3a;
        _retrieveSignature[454] = 0x78d556614e4f8d05225e4071150b1a949e390a740fe27448da5865d90342d79e;
        _retrieveSignature[455] = 0xef78b78c34db6e1475aba0b59029ca7d2d9c25d40cae669564e2e0353951750c;
        _retrieveSignature[456] = 0x14ce234714ee0bd9ce03aacba1888a6657ffe092a84977cbc7e396d0f5823734;
        _retrieveSignature[457] = 0x4fc055fe00031a25ccc5066eb01427a9889392c40234e13b4def2adfaad4277b;
        _retrieveSignature[458] = 0x3839d9ceabfcbea66911bb36309bb5e64e5d2c9213730a741cb66aad01fd11cf;
        _retrieveSignature[459] = 0x530dbb05d2ae67f6a292e7e58baab5cde5c32ea60b5215fafef3b9dbb9a2f1a0;
        _retrieveSignature[460] = 0x387d72f4d55afec7f8086c7ea2fdb23b372ba0437e3cf6c204534725d1ac05ed;
        _retrieveSignature[461] = 0x9f5544a5be65a72829e72823201c7b2b05f248bed138fd9d32e7f17a1028b8e0;
        _retrieveSignature[462] = 0xf4c2d39ee0127147744666ff57485663c95f95ff5738cbca2b37d971552c5ca8;
        _retrieveSignature[463] = 0x6d87d2b24115811d89f3e07935c0b8d8fd5ee2bc10f728b9b83ac42eb026310d;
        _retrieveSignature[464] = 0x904284e8edd4fcd3f8f0b350223d3827377f8412feafef00dfe1779036072120;
        _retrieveSignature[467] = 0x1e41fa8a6c58c9862f3d992bea5431c10d81dc4b52450416ca14acf7ae238f15;
        _retrieveSignature[468] = 0x30bc1b3dcf3524cfe90242bf59372881cb711e9086d82488fd55019235af13ce;
        _retrieveSignature[469] = 0x35e578ee71a23abce1ba484a000257794ef69b28ad069bb6fc686b37c808cc79;
        _retrieveSignature[470] = 0xbd7de72207c89e9d4f9836890239d827b9e70e63016d173cb5ffa217c4229df7;
        _retrieveSignature[471] = 0x4693bce91ce32a60edbcdcabce473eaa2a806e3d21a544dde2d8690f489a46bc;
        _retrieveSignature[472] = 0x3edc396609d853907b40673be0add8177f712fbcef7ab2612a45e7e80699e258;
        _retrieveSignature[473] = 0x122d3204204082252a1132f4c6d8426b33ed00cdfa38d1fb99485ecb4b6130b6;
        _retrieveSignature[474] = 0xfb7d1a13a756e50d7f40f845805812048461b5907d37fdd23c09bc4908a7ea37;
        _retrieveSignature[475] = 0xaf73fe3272f1c2aaf226beacb6edc63ae2b50af7067ee82c37df78b5d35ef714;
        _retrieveSignature[476] = 0x1985e9400c19d8d4bc25d4ef9f991e0eef4043e92d82bf499f7fd06924228452;
        _retrieveSignature[477] = 0x7ecd2238cf627084bd287e224f467874e341d95d10f471ac6177bb9a273b51ec;
        _retrieveSignature[479] = 0x4baad504d207968a1c6f42d9ff2e3f031874660f2ac6861597323e84efcc3b3d;
        _retrieveSignature[480] = 0x0cda96faf0cccddacf8d3e7832eab3ba8ffb8066b5aab32b03f75ae05518b9b2;
        _retrieveSignature[481] = 0x82a9d49189b27a590c721aea46aefbde721768efb2f2ee290079950739956c95;
        _retrieveSignature[482] = 0xa0899276acf10c5934ad1b74b6bee8d085e56538c3c29f299f335b018bb9c325;
        _retrieveSignature[483] = 0x95fbc8f61e57e674effbee2f3d374c41fdc66dea19a9a5d3d4ed4befd33f045d;
        _retrieveSignature[484] = 0x6159cae614527b6a92126fcb278a1e40ad108cbbe89faa5bffeb6442731da7b9;
        _retrieveSignature[485] = 0xa2887d4686959a3646e1b5576ec075d4719ab07b29ee321244d5f8f5c6b94f84;
        _retrieveSignature[487] = 0x7a53757674f7ff1e6490d61e4f31adbfc5bbf704c02527afe31afda0be8d0929;
        _retrieveSignature[488] = 0xa2dbf1d6bfff233da43a16f26929f6497ac6ffe45042aec197377b860a278fbc;
        _retrieveSignature[489] = 0x77714afce5a6f463d9baf01a80f6d968273281a93b9ca2412d14c2799f9fe8e8;
        _retrieveSignature[491] = 0x52f40e53974a7385e567f705a1360b233646cdb9faa9efd4973214cf0bbdb4ab;
        _retrieveSignature[492] = 0xf8e32926bd5440d204a2751b15eb36de1627d3e3ede7e8c82a54da7c4d3816f4;
        _retrieveSignature[493] = 0xdd7b3bd0905c6d2f397d1df877dac2a7d17b91647cfe07bf823dd01043498a92;
        _retrieveSignature[494] = 0x66e987511043e4007c1bd35ca3d4e7d9225185fb38483cd0f5976e876d80b8e0;
        _retrieveSignature[495] = 0x1f6e14474969efee8ce4ab87fe9a691e10b2cd8571ebdad92dc98c709cb485f8;
        _retrieveSignature[497] = 0x4736b6445b3074737cdb1003619c4324be7b3928c8579d955fb0ece437a8795c;
        _retrieveSignature[499] = 0x6ed8a9d3e8d241486867a5867c3ea762543b73f4fd9f0d31c4373bfcb6cc7853;
        _retrieveSignature[500] = 0x05ee49ad135ade65374d6c29a6f1597a79a20a7b95788886093a9b10f4c32387;
        _retrieveSignature[503] = 0x136a7665f3c96386be6cebfab1baf2589830867f1c8faab2323b9ee73354290c;
        _retrieveSignature[504] = 0xea6d11f89c7e9ccfb0a9b1cb92da7d02209dc78b1a7627e22af2397f04d35bad;
        _retrieveSignature[505] = 0xec094f42acc2974dba9b571982f8914d4ddb3d350feefe0d6b930fbc7502debb;
        _retrieveSignature[506] = 0xf77bc496939941e6ac9503d2a7f1530560ea300d554f3095cdd26b5a9db5428a;
        _retrieveSignature[507] = 0x6f11ee3098c87648138ea5c056ad1d6bb2cbc182266131a07375e85fa427011b;
        _retrieveSignature[508] = 0x1c2f2c4e86ffd71353d4397f24c8615a27295f4cf6e9c01770dc85eea91b0d30;
        _retrieveSignature[509] = 0x03091ca75ff1956e57dcd3f36d7628a9794f11c762c3809c046844e360e3f417;
        _retrieveSignature[511] = 0x6002abb1d8e13adb7d3d1d9566a988ce37ee8227418e02f4efbe4ecb04912775;
        _retrieveSignature[513] = 0x881d2ac274fb3e00ee82a00ea16a98878e9355cdb6435c88988d3084b28a0328;
        _retrieveSignature[514] = 0x932a7036d0b7bbd56e7d0edc786e39f6fe5f5a9afe12936326abfafff34c88c7;
        _retrieveSignature[515] = 0x994e4bad6e5b8f3eab77fcbeb161866cf64e5a9c3a02779dbacd45ecaa38199e;
        _retrieveSignature[516] = 0x9746c019aa9f37aaf4d45c441ca8a21c79e7fd1a4e20b5edeb6ba614d810115f;
        _retrieveSignature[518] = 0x40ee51f6d215bb5e44749ffc021644e9e3d6a6c1d2dc08d166fcfc9e79bb1db5;
        _retrieveSignature[519] = 0xcf7f51d099bb2b4826b3d3ab9a44c54e38c52a87a31d549aaa73f0a457259c54;
        _retrieveSignature[520] = 0x92abdf4d6b2ff43614d2a9a12befe25152066c224be1cc7a7683398fd67257b2;
        _retrieveSignature[523] = 0x7d555d1597ffb7c886b2434480d765ae70e22217d3469fb5e6352e549fa883f0;
        _retrieveSignature[524] = 0x3292e24bb168cfdc95528160caf117aa7b0ceff832d2df1f4cb3bee75fec65b7;
        _retrieveSignature[525] = 0x783e9e926147d2092c008c550ec5644da5623f949ca8cf6ef66bc9baf55f9ffe;
        _retrieveSignature[527] = 0xaeb664686646a32f3d3c40d38b8c3399185f1e54ecd37909dcb0d2d68a6e979d;
        _retrieveSignature[530] = 0x5787050ae31c412eb6fb3a7304744f62ed4fab6be48842b38d47ecc54ee9b531;
        _retrieveSignature[532] = 0xe0588c879bad0700175e881dc8bf47257f6cde51828fd4accb8d712ce6bcc57f;
        _retrieveSignature[533] = 0xb701e36ae49408ed402684f4b072745c94731cdb0de1b79986e0ca3b97cd3685;
        _retrieveSignature[534] = 0x728661029fa360d6ff272f209d2c66264e44ec293b740d8d1981b535054bb74b;
        _retrieveSignature[535] = 0x98217be05f10024f0839c4a75b8403d5aff5158cecf5edd43066a44cffcf8489;
        _retrieveSignature[537] = 0xd4626e3d88c4f0ca6c3559970cde274ca24d92ad0bbe9cdf1ef03cf9882d8c45;
        _retrieveSignature[538] = 0x750549f489e0706735eb773ee94cdc11dbc8d2b91b67dd9a1147b9a6a5c9a60d;
        _retrieveSignature[539] = 0x84772966e57209920239780b5187ec0348293de02987140d6a90604179b870a5;
        _retrieveSignature[540] = 0x5016d2f16ccaeebb80c0ac7f61486ff7752b85e7503f89a0301b997ecb87daba;
        _retrieveSignature[541] = 0x1cdef5c806e7d29ca6133acf4ae1ecc605cd6fd1340173a61c6282793eafc9f3;
        _retrieveSignature[542] = 0x31c1fefe98b3652f8dc9a6dace0a0d1bc03649090328f67e248b7b66da4866bd;
        _retrieveSignature[543] = 0xdced62950d91005487b1def1feca26ce3ecf69171bc23e97a74c0c5bc512cb8f;
        _retrieveSignature[544] = 0xef66fbc23b59ed73b3122fed67ec7f7d88513ac99027e352393e82de94482cee;
        _retrieveSignature[545] = 0x5ddf74b15a649d6ea48f6d4d613a4eee3f45cea07e05ade765121bbeed5da38c;
        _retrieveSignature[546] = 0x3dda1d8d4fd5183e477714d2ada3f2014baefdc9737ecdafdda76814b3a319a2;
        _retrieveSignature[547] = 0xae7f53e2cc891c4e66b3c127d0c42e6c7ef69d36df1b52845da731a2d4e7532a;
        _retrieveSignature[550] = 0xf1e1be5ed10b025793376dc2b4fd80d8a01467810278882c5464a53c7d7a85e2;
        _retrieveSignature[551] = 0x0f6fffddb2190ac61cd052f47b6ac1b9e5de6b582c7d1a9d5a84263eb063eb82;
        _retrieveSignature[553] = 0x64fa284936ca50875b1209c71e199ffded10f402205eb4850a1d340db7553c60;
        _retrieveSignature[554] = 0xa9e9818289cb6dde79d0995974ab1fd3fb47301ab7eaa29037594922c12716a0;
        _retrieveSignature[556] = 0x03eed8da854c81b227b11e0836e5224c4381e6643fd48392220cace4c4f22101;
        _retrieveSignature[558] = 0x1ab34ea9258de3953f1e4ba08991cd37925e32f31cb307e3dc7d6a860695e209;
        _retrieveSignature[559] = 0x942203dc1be9638e1faabe9e090607f8376f116af36dd1340b8773c51251d177;
        _retrieveSignature[560] = 0x8e50670ce0f12f0605f3ca008b699fc719c1877b1e3583ba5ab6be2b7968087b;
        _retrieveSignature[561] = 0x820ad02f47ea74cada103ee8efda2d02d4ee2765bcb645d0a86f281e042e13e9;
        _retrieveSignature[562] = 0xa5a6c72676350535857de63ecad12f651b9eafb31f64026c1618a1593994db69;
        _retrieveSignature[563] = 0x8461187243401e39ec7b6584dea6a34f46f5b0073652cb74c314815ace63592a;
        _retrieveSignature[566] = 0x35eba9a27e3b02965278866d494a7eeeb7d420579410d8e8171bc16aba831401;
        _retrieveSignature[567] = 0x77db243f3526c36031f1b955b5de7241d9e591b4989bbce5c91301e3c8676ff5;
        _retrieveSignature[569] = 0xee24b1c89093b3097937116fca9771cd3f5f91be17ebe05e334de40693506b2d;
        _retrieveSignature[570] = 0xb561fbb68824f80adef32a7a40c59e8ec8a87dd48f59e7d68b55af8f0f43bb31;
        _retrieveSignature[571] = 0xe30ebf9049fe49f7cb3a365ecd33a821b02ce3eabac92f00393bf40845e0edc6;
        _retrieveSignature[573] = 0xb2f0dcb905a97e8f53e3baea3708769da79ab48f34d8049e80a29c8e523ffc30;
        _retrieveSignature[574] = 0x53edd037470243ab0380655f1d8086665f3521bc447e32195b94e1360211db0a;
        _retrieveSignature[575] = 0x8db36b79ce1d09208567b75bf3e585196c6af5560850df7de3c09d4c425a2dde;
        _retrieveSignature[576] = 0x14158e0563ea4b76d2de15a9c786dbb4b4f6f8798f2046a57d7efed3f7221ca2;
        _retrieveSignature[578] = 0x1b59506b6917ef0dc5795a08fb507caaa760afffdb0dad2279fd8897510e2f82;
        _retrieveSignature[580] = 0x3711a6c85d3770aa961739910ec45904d3328e949e7d7da331645d6eff56c53d;
        _retrieveSignature[581] = 0x46c716822cfeee018b9f0a44b81242fe3643ac7083e9203b7be3b24ceec7153c;
        _retrieveSignature[582] = 0xcdb383fb7463d8034c72b73a8b5f4f0e75cdc271fbca093b189ca54693ee0462;
        _retrieveSignature[583] = 0x971458401496bb7665a2249f833c1cd1a7a7d7c2a0e3226e06b47f54b2c0034e;
        _retrieveSignature[584] = 0xe0d9db759669b9fb01f8ebb7414c88a526b0ed963db383724405cfd7559a5715;
        _retrieveSignature[585] = 0xf23c1da20717e5935af56fe091da81f04f806ce368244b6a450e5315fd23155f;
        _retrieveSignature[586] = 0x38bf0a5bfd342ba75b5e0a718e23ff1f5214384e20be5c60213989c6c534b08a;
        _retrieveSignature[587] = 0xa9c400b5c64244253ae33a4220dbbbebda9beb96a188b903308175255ea5f56c;
        _retrieveSignature[588] = 0x7795392a965aa46070ff0c3f263e6ca56a90176dbda6a41f835acdad8a13fd4f;
        _retrieveSignature[591] = 0x2d401a3fd187921c9b3c1a22448ffbbd7fa62027a0931df8488cd0341561849e;
        _retrieveSignature[594] = 0x8d19a75832bb6d1a5e30be83d45f3086954d5461d50cfefa5172fcdef390e306;
        _retrieveSignature[595] = 0x9125cb4d1ccf26d4f3cf361c73f73fa0786c4c750776b6a1ed2ec9bbabbf8b03;
        _retrieveSignature[596] = 0x7096368f8ae547274f274ca984336b9c1e0671541fea194fa5950ee04fb8512b;
        _retrieveSignature[597] = 0xabc1e7b7fa2615b53455f2dbc7fb4021b7b861bd275d646701ca3a746afaaaf8;
        _retrieveSignature[598] = 0xcd45471e76d6fb3ad48e1845c9d5a27662e3b5a64bdfc50068b9264946e77fcd;
        _retrieveSignature[599] = 0x4ed082dab9db232820f6a6f57b921d40ec0032b272852b4f8ff29e6f76461d87;
        _retrieveSignature[600] = 0x0b4f8849c885c6c829b46f150fdb71f5b96a7f6100b0973794eba95efe0a9112;
        _retrieveSignature[601] = 0x8ebc59ca13de5c46b26e7506a805c45a75c387580c030ddb06cdd3aee63dbda9;
        _retrieveSignature[602] = 0x34bf30ed203d0f148f2f76e7e21a146556378d8979eb563f2da8483e1b2f3573;
        _retrieveSignature[603] = 0xd06ebedb3cfa7397f4a8644d4f9e8f70c6f856cca409d9a6e7b48edfdd209cd8;
        _retrieveSignature[605] = 0xa4b1983016401313f63b10781fc95bea8e23655ef506f42acc7c11786a39a02f;
        _retrieveSignature[606] = 0x22c13184bd5e07b05db7667d7cd2351f915417f02b9eaa2fe1371546a8e1d8b4;
        _retrieveSignature[608] = 0xd550bb0fcdc08adefabd76f552f91d57865185e7e34d8667190f34d58c680bd2;
        _retrieveSignature[610] = 0xcc5ab7a71dc0afcf2474ea220ad141baaf8154fdeaa191bf193521c53f7073f6;
        _retrieveSignature[611] = 0x84f5ea325a2afa1b307f79527f97e0e1fc43741de092b6c58b9b88128bc8d281;
        _retrieveSignature[613] = 0x175bbbde225634347fbd3f44b44d2b087281a33f6287ffa0db43a09bb044dc96;
        _retrieveSignature[614] = 0x11ff8016721862679d1c97b44f53990043d65505e2d4f0003ce93821c426a760;
        _retrieveSignature[615] = 0xe8625b3d975ef8e0ddf0acb1387f854843fe4d0bef4d69314a4b135131f305eb;
        _retrieveSignature[616] = 0xb27ac90731fa46f609b2022f7c6b4d59c5c3b3fa72c2e6f51384eb27f699edf4;
        _retrieveSignature[618] = 0x11d6f7f871bccb1eccd3b88e60d2de3638654be9260d3e1de82a103470e3d174;
        _retrieveSignature[619] = 0x20f34f2bb7313ee5c2c663361a7f07581c1bb0d6fd065121cab62ab7dc484f49;
        _retrieveSignature[620] = 0xaa012f99d44471c665106fd70c83b081d1b5f6c116a74ddba5ac15df76852411;
        _retrieveSignature[621] = 0x4a9047696053c21225508d604c126952571219b9ccc76fccff1f63aa8fd9c32a;
        _retrieveSignature[622] = 0xc47e522fb8db9da5b44d7622229253208fe2a4c90549f98c9a326211fcfcb663;
        _retrieveSignature[626] = 0xb26ce54d3f32999fd8bfa64915a40b9d47fa53ffedb6fdf4ee66573421287af8;
        _retrieveSignature[627] = 0x71dd6017b65806342fc422d1bc771ea5376ea5d74c7d98f12c818b04e93011c4;
        _retrieveSignature[628] = 0x167e54f3ace354df128dd5e15fc9b4aea71de1dd21f09db52fbbeddaea455bc3;
        _retrieveSignature[630] = 0x92ff73f9742b7c9b48e57d134c6897d6ba2ee446ef28d42910d87e64f4ca3b78;
        _retrieveSignature[631] = 0x1c9888aa54131aea2c486b177cfd0fbb29a38bcbff7b38aec275bb4db4a2aa54;
        _retrieveSignature[632] = 0xf62473bc6571a3f2ced477891a8d45fa33db5c3f38424a267599bf2f248f2fa7;
        _retrieveSignature[633] = 0xa325d049e2c312765a841bb1b21bcc5c0f90b00f774dcad1218f3a6b751a3edc;
        _retrieveSignature[634] = 0x4615a03d44a1f4724814e9d9d367ce5830a3ef4f36331018d6555b6e7c4ae4e9;
        _retrieveSignature[636] = 0xa6ef0ac9e6ed0b96c8fef8b8f8ea5b9ec36d6a243fd573c87bcc21ac2d3c55ea;
        _retrieveSignature[637] = 0x0653ab5a78f8eaed45409494c299bc23a0950785e9350ffd2465ebf7a21d7d35;
        _retrieveSignature[638] = 0x20caf4966ccc4c44f1df98711fb41fda186aa84494cc578464c48484062e67d7;
        _retrieveSignature[639] = 0xe3f310037d9d84c6159ff1314b0305421da129d8c000da8b34e1ad0ab9baa5aa;
        _retrieveSignature[640] = 0xff98f5514dbc324d600e552fbb7d37fd160121bbe62df076c8bb4a44f42ae921;
        _retrieveSignature[641] = 0x42ad914913e5ba3ed80a425ebc795aa1d3d8cb8a3b75bf6ccdbd5b219f083007;
        _retrieveSignature[642] = 0x639b336ff9deebd8dda3c03f3457eb688db116de0189e72350e0b958dd07094f;
        _retrieveSignature[644] = 0xd3e8c1aa71db9cbfcccf66980562e8e76d92dbbf203973e897f85bc3197a8477;
        _retrieveSignature[645] = 0x287c6013eebf4105eebf8d54fb550fbf6588eb3e83495a4a7d1b4acbb9c42cfe;
        _retrieveSignature[646] = 0xc8b89b4d3b76ab0bbb405bdc94900b8117def9fdfc4d4ccebcbe15249ef25920;
        _retrieveSignature[647] = 0x06fcd527628aede606e5b879854ee3e8ae309381725ac99728e68961045c888b;
        _retrieveSignature[649] = 0x3199ac10af057086ac9d85cfcc2a6940d741d5a1842894ffbc358a9271f110ff;
        _retrieveSignature[650] = 0x4606b5ff4f9cf0b5cb331e947681b23576ac34e9d85fe17dcd7f20fdd76d65c6;
        _retrieveSignature[652] = 0xe6b7f955678883860d2ed38740db130354abedf45263b929a979def33430f541;
        _retrieveSignature[653] = 0x95e8b36005035262c3d524b31d5e099418ccacddbdf6e8ccc1e429bc43ed441f;
        _retrieveSignature[655] = 0xdb4bd6f257e49190f1dc24750f4722a903ec75ab6bdf83f0b7c84398fe891018;
        _retrieveSignature[656] = 0x8f9242a58e090722bf231fbc55687338f240962a237a509e93d5c38ee9b91757;
        _retrieveSignature[657] = 0x6f35ad86a768b6095e587319bf159db7b7c694baa10cd884fa067df10849d274;
        _retrieveSignature[658] = 0x06f8028fbef61406533325c03cb44f394d4d7a9cdba0330b81d10c700ca299b1;
        _retrieveSignature[659] = 0x73e777dc6ebd5f530e88c510e1f05668431d968b2ea52595e50a0f508004bf29;
        _retrieveSignature[660] = 0xc0e97288d1899272228688f4a9dfb2b77f1f1ea4f7f1078ccc7ca3df6d940a1a;
        _retrieveSignature[661] = 0x6d2896c2165c33fbdaf80faea0feaba4fdc0c39a2ae20efbe13c3087a0dfdc7c;
        _retrieveSignature[662] = 0x2c562ea3a363065952db6859daa6579741571f0f0b23ca9a980ebfed96c84049;
        _retrieveSignature[663] = 0xc4e33fc07243d6bb9a2d34dab202943a7f2852d2eed3c6ab94ca57bf3d9c227d;
        _retrieveSignature[666] = 0x971e441078fd03218cb5bb495fc864a1ad7315fa53ff6095316450f322042bd4;
        _retrieveSignature[667] = 0x800d8926bea94cfbafa1059151f6c823c8a6b32c15ddbb6f63e5e34b5bc25ce1;
        _retrieveSignature[668] = 0x765f762d63ead9e1ab02d32b347fa0bb1527b4e7dadb353b34fe31691ceaca92;
        _retrieveSignature[669] = 0xaa81637d9c3e52b7d8977275c17bf2fdec3074f1b11622c98d055ff4666b5114;
        _retrieveSignature[671] = 0x5ddc00bafd19922f64dc34e352200fbd23bfa41322c250be3050cd8a096edb92;
        _retrieveSignature[672] = 0x10331b5beb285cd4a32a1ba39401c87d4d8ae329d69a369cff6c393570aa0484;
        _retrieveSignature[673] = 0xc0236da854d778c09a6a05c94f88fb93889727d80754c29073f3d2b7a302bfcc;
        _retrieveSignature[675] = 0xe11e80d1e9921f7fd8aee76713889d3a93c83193875e4170088ba46a2e9b37a6;
        _retrieveSignature[676] = 0x68d545d0e89152e20555156ca0f62fa39fdc6f9f56735a1723d481fea1a0d924;
        _retrieveSignature[678] = 0x802452082ee1681a5efbb89383decff9c290fead8993e14eca8531104aa9ff36;
        _retrieveSignature[679] = 0x939a6a096ef26cebe77503cbca65e429f3797969e083c94c9f4f8f39878e6896;
        _retrieveSignature[680] = 0x5cc401a65ac37851573ff1458b56692ab834d46febe75e0d2ee2bd865278f448;
        _retrieveSignature[681] = 0x1b6fd30b6953a3df2ddd2d57a862fb1b484abdcc115385ea38426172395e0934;
        _retrieveSignature[682] = 0x44cd82161e83c3f2525b26d5bc23119395956ba2e75c5ae81cc2f89888953f83;
        _retrieveSignature[683] = 0x8cec38cc527f27aa429b3a1f3965d2f9e9fc4a9ff2ef6870837299781381f495;
        _retrieveSignature[685] = 0x03cd2a18e0bc372c9d69e767528f68320f5706b1c82ab891185b30d0838139c9;
        _retrieveSignature[686] = 0x720dd2078f6057953cd35bc0a2973d4f38f4ddb132197740d0804ec8151a1840;
        _retrieveSignature[687] = 0xd82fbf8dc41dec94e65e0f41d94b28d899ee7adedf67e49d9ab9592476e5a6c3;
        _retrieveSignature[688] = 0x63acb614fa58bf1f8e3449ed734cbb0a4e1189e5a8139b3b7d04ec3b5f1d5009;
        _retrieveSignature[689] = 0x2a1b13338e2d389d1d31a5fd42b68e80948d363b191b573d1432586568c6194d;
        _retrieveSignature[690] = 0xcd2a67cea4a59cf4fe3f7323bdb229dd450c4a924b592f651ad9db832ecf75b9;
        _retrieveSignature[691] = 0x26d6efb85266cbf766b5a613b56e0c5cb03e5ae23d4b6139a51275ee1e358a09;
        _retrieveSignature[692] = 0xf4541e05eaf98d93b6d927b6382653c622a1a15a9f97d25959063029da629eaa;
        _retrieveSignature[693] = 0x49dbfb532e1330c23b6edd102f7e5b4b7af18cea412518b6b89cde56dfd9595c;
        _retrieveSignature[695] = 0xc1d8d4ae9ac48a59eb070aa188c9ccaca17191552637dffd6ea14a75bdfc07b6;
        _retrieveSignature[697] = 0x7dde106a7494b0aa2cfdfec2ea2fa12429bcf2f37fa8bc7cc1319d6492f6f7a6;
        _retrieveSignature[699] = 0x8842cfe763f5c3d6a6512fd535df83f7be114bd8722f214829ea86d07417c785;
        _retrieveSignature[701] = 0xedb948269ccfcf08744cddc1309db15ca2e641f44ba8ef35acf68fa57cc34451;
        _retrieveSignature[702] = 0xa4612f2ec9309d51d96eb9f5384575c0dd1a708c83369115ada66531db60f0bb;
        _retrieveSignature[703] = 0x7772ebee57aca507c816894a13befe1a41e7ef37cca7fbf61c46ad133e98a817;
        _retrieveSignature[705] = 0xce22ea5f3cb6b4e71ae6a931a96712a8a8914d070c05b18281ffe18aef0f1246;
        _retrieveSignature[706] = 0xb12f7e15d7c3d338cd10db1c456b25d310c013e6b0c200efccf9e225bd183ae7;
        _retrieveSignature[707] = 0xd94c5d6e963d8e871c2acb82bae30afd0be63f9d0b1123328dcd426dc8a61511;
        _retrieveSignature[710] = 0xe679bde53f6bd6464bfa19ae48ad8f7523f753fcbefd41b1243ad5ccea756559;
        _retrieveSignature[712] = 0x5e0746228caf6827e939828261cabe29b42d9bff9de5bd3fadd537b86c703df1;
        _retrieveSignature[713] = 0x0fc1829db4abd2ad4ccdf3e61da19ce604ff9264a58d21d35c1d4cfd91bcf0d7;
        _retrieveSignature[714] = 0xa0dbc566cd500fe06ac759f5a49d98e855261bea0c710bb960c59d28fc6bc185;
        _retrieveSignature[715] = 0xadb980a8434d2a4a8388d777bfaa6e24dbef3deb880e2a58f697db1e2a04a788;
        _retrieveSignature[719] = 0x425414c1c491e169a541adc7dd5a8e72b7da02f0584eda4ef85449ac285bc1e9;
        _retrieveSignature[721] = 0x0f55c9e800ac454b0c3a443f1788f51f470885ff265c9d5c9cedf67bea613039;
        _retrieveSignature[722] = 0x42333b1fa9d06ebb2b0474f7d60a29de09e138bc8448d5238519060247892f5a;
        _retrieveSignature[723] = 0x169000d4dffdc4bf52ea651fef8547c8b8771694d71104e8d0ff8c9ec9e99b2f;
        _retrieveSignature[724] = 0x39a76ab4fda0a35e6936f79d8c47848cd3d25428f8d61e2853ebe376e000f01c;
        _retrieveSignature[726] = 0x149bc4004154dc87f979978ea4fd9ad30150746442b1aaad21d873fca22fcd25;
        _retrieveSignature[727] = 0xfd5a1fe4d3ce272863ce680d82c4883381aeea8109f63f685d04f09496f0823b;
        _retrieveSignature[728] = 0xab3f7976c56a36cb27fae0793711a6f1af72cf4a256dfa0c3d3d198dceab039d;
        _retrieveSignature[729] = 0x5c43b365909bb721a106875304d2e63c641a67de237e7b419bcc919ea6151f46;
        _retrieveSignature[732] = 0x768ed3752e13ab0ed034d37d2993bddc9add1c08186f5a0283d063cffd1a2621;
        _retrieveSignature[733] = 0x96347630963ccd4e79ed5270b20e74059bd52264cdc9ea53e5ab140ba3d312ee;
        _retrieveSignature[734] = 0x5d8882365f4babb76ae45c7bfbe38f489dff0bbafcac89dd713d243e027d9f9d;
        _retrieveSignature[735] = 0x96985c6fd7197d9956308dae647c4997c3292578c7ee2f7d3ebde8e292166364;
        _retrieveSignature[737] = 0x9052d0fbdba0801783b87be9cbb2c08913d3f5e5620823b8c71b3b3abdb747aa;
        _retrieveSignature[738] = 0xff4ac71d833076e81c57da752917a8c8b9ca62a4be8d68149d0cf67c6b060aa4;
        _retrieveSignature[739] = 0x7af12993c3599ce16bbff5d1d598eaea5da305995f0e8a42e86d44e73cbd47af;
        _retrieveSignature[740] = 0x1fd4f3dadc848863c9f791de95005dac915618846420b6dddf20109e1b81242a;
        _retrieveSignature[741] = 0xae66dd9f3e80fcfd5c3efaeffd46643452f9baceda2dabd0447d7b86bbee159c;
        _retrieveSignature[742] = 0xb3b4c7ffcbd7c489254679993ea920843ee4cfa3be5d7031f8945814a18a5801;
        _retrieveSignature[743] = 0x1f10c96a9082f5a7ec9a335e103b52f21783c163da4838c0bae329ddb0d5404f;
        _retrieveSignature[744] = 0x09ef21fb6a1341703b6681903ecaa4aeca7d22278922f9da40de9fab287ba8f0;
        _retrieveSignature[745] = 0xe7684586fcd6e2b4852b7feb254a017036fac69265c01aa0f0be2df68540187a;
        _retrieveSignature[747] = 0xb4e12138c12d1db701f31946646c0fa430f2885bc735f4a45e8ed1d9f6236726;
        _retrieveSignature[748] = 0x92eec2bc106db669fdce4262fb301b0b45a6cdad51eb3b54a970ad709c8afd9e;
        _retrieveSignature[749] = 0xa03fb7d11b0062d28488f6e21af33538148aa0a711111130a77dc7d0ad2083ff;
        _retrieveSignature[752] = 0x11044cd0481989b0f9acf55ff1c556adb831f5feac118371e864d4416bd30b65;
        _retrieveSignature[753] = 0x1199272ea2cd4667a944400d99ebb0035073da8b31ff64f806cbdf4650510ce3;
        _retrieveSignature[754] = 0xbbe4013e5fb9188fcfb4d27a631f97090cc094536b68aa24c3b9988303ea4c0a;
        _retrieveSignature[755] = 0xe8582207dcfcfd284244a4ab364e10dbd1756e1673acf8fd146a9a867636978c;
        _retrieveSignature[758] = 0xbdebf9ba58129c6b578d32d1655505240a5f769b53676ddeb845f5748dbdeffd;
        _retrieveSignature[759] = 0xffbdd30296bce32876be9c39470e18217a01f55810c331ba2f3e1a4bb7200569;
        _retrieveSignature[760] = 0xc6a448f4414deb0b21b9d6924ca38819c993e8760078bf6c21602e871bbe86f4;
        _retrieveSignature[761] = 0x3635b965d2eda38a25781e8427b9248f8b0480cc4ae2d585ee8ee8a6d6706ab0;
        _retrieveSignature[762] = 0xf9bb16888fc51a28ce440afc0cd4e61243d8210a755eded6cd31d88dbdc10b6a;
        _retrieveSignature[763] = 0xdb034d5abf8bd8b44d70388bb436728684f40c0ad3526ae4063af158b9ea586c;
        _retrieveSignature[764] = 0x1c4a6c334e3b8554c71a277bc144d13af56974a1606b1eaf74f6a99831255000;
        _retrieveSignature[765] = 0x318534ce49e00f52ff80aeddb5c6a0af85ea7636f2041d660b771d8602a8b5f9;
        _retrieveSignature[766] = 0x7812c44c86bc53a628caa096965347139688d5f4e61050199de408d84457d2db;
        _retrieveSignature[767] = 0x1300b0889a4c0b5c1675b3ebeb392622bcf6a11c36883ea99ed6e40deb1f7571;
        _retrieveSignature[768] = 0x1a504c7b56ed5182c11c078e0f19a159797f1de6579e18c99965fd312091c19f;
        _retrieveSignature[773] = 0xca5d37dd11289b681070e016b8945e38ecc0c71d5d0cb572df3459b34a5e594e;
        _retrieveSignature[775] = 0x7b296b3d382b17d15ad4be146d2d964d716643684e7b27c752908e2f1904d9fd;
        _retrieveSignature[776] = 0x347e8ce7c7d70ebfc9011642ae15f03334b340f4b328c7f94ad4274e86885c69;
        _retrieveSignature[779] = 0x009f49cfc253b8b4b1723d528797fbf918d15cf8f2f0a098f094467962adef04;
        _retrieveSignature[780] = 0x7e0a4346513eb779f8065a098d7a95ff81e8beb7275f700c5476efea4b6ec5a8;
        _retrieveSignature[781] = 0x7098d65a9c77657fe4d2f18eea0529bfe9191cd24b52a420ab573307a6d28d1e;
        _retrieveSignature[782] = 0x3aeffc2ef076b154a3c1ccbb46685f1ae964b24d063a9db9c0514fc3f4a10d02;
        _retrieveSignature[783] = 0x50d4b8c836e0a2d70bdc94671a8ba11ac30adf718b0fe9ed2c75038ca7e050c1;
        _retrieveSignature[784] = 0x6621b7149d0865f0727b6869c2f49240e6c94b6303f97c2caf64e7d453d45214;
        _retrieveSignature[785] = 0x51c7c92ded14bc2c5d7aa1d16c36fa3f013457760b1d2939c9fc9b11ac6d9270;
        _retrieveSignature[786] = 0x22826bc302092e862e49235c44f2db4aa0524ec51147d5a9c7ddcecde702ed6f;
        _retrieveSignature[787] = 0xb4bc2cbc0640fb9bc43c287f3ee5ed8baa6106ba7a30f0c63c5b54c52a0f0bdf;
        _retrieveSignature[788] = 0x6e4219daa546b7c7340e282ea949cc72a89376ebbd0e5054a9cf16c38a3762d9;
        _retrieveSignature[789] = 0x710da5411ec17bd1448dc4d572a660e0a8dfac5b59c85ba3d2e98e87404e834e;
        _retrieveSignature[790] = 0x5901d66f87e848a00641354909647b591da684501d790bdc9a1f0b50b9804c4b;
        _retrieveSignature[792] = 0x63606d3c60e005bcebe41e9da30a9b88fed2414c50ffc59a4fd30f537d0700fd;
        _retrieveSignature[793] = 0x1da02816a88b74915ea2535e3f463333d25cca477f743b26a1d5e62c846076a8;
        _retrieveSignature[794] = 0xb9faac252f6ee31788ab32c9361e10ded30b235c6fe11238aa97aa7b0f265bf0;
        _retrieveSignature[795] = 0xa731924f45a7127cda8adb3a5601d1a48454d9cddda790a37fbf2a6b1d5512aa;
        _retrieveSignature[796] = 0x9ba59de8392675bf43782747ba6b244a8034a67af873b5980bab0ddb24be7f3a;
        _retrieveSignature[797] = 0xebc90e381ba2ba7de72ffcc0d6fb41fba0619473d147e2d200006262c7fbc191;
        _retrieveSignature[799] = 0xee5dbc4340194e8cba9cea35007d8ac5302c22abafce0bb43c18163cff02e0c0;
        _retrieveSignature[800] = 0xf79a381cdf07a10f39de8867071881b265c2790e99c9be41cdecf1085331ab43;
        _retrieveSignature[801] = 0x193c0c9a76b915b4c7fbf425f0f331cfe45c1d45d329f629f1bb954d0a8b7fc4;
        _retrieveSignature[802] = 0x4d2c0b33abde3eb8ff14881b9835ec931292d327fd260c02221617bafd25fe34;
        _retrieveSignature[805] = 0xf8ef0dcf1c7b823a46d9b87173cea77b647202db65e58facebcf210299db7a36;
        _retrieveSignature[806] = 0x749951698db88f7951036b58218944abadb4e2a9492ed3bc794cd9554b64e803;
        _retrieveSignature[807] = 0xd52d32e071bacba5b9003f2dd16e091db65c654fbcfcd4b340e1341d2bdd513e;
        _retrieveSignature[808] = 0x2ec13b45940a3aa894985d458a5a73f02891ab07ea45802acad1742e4c4a471f;
        _retrieveSignature[809] = 0x975a4c12e68724a33829313a87e83a0f74b9090574ac81a39cb038e1c3f7805f;
        _retrieveSignature[810] = 0x90782dce1c02c08cbd9b5d13d990749df78c7a13e8fe1a87835adde3653859d9;
        _retrieveSignature[811] = 0x056b043d6ac22f1c271f887ddcc5cc0fefb833eff3b80118e84e485a5c4ab11c;
        _retrieveSignature[812] = 0x73b0a55e58271bfe9535136e2519682b20c715fd6080f7e239bd95cba9df4aae;
        _retrieveSignature[813] = 0xca68e79255f192c8323aa15844ec5df2122561c25281adadea56e75ecc18a308;
        _retrieveSignature[815] = 0x2e46358968a468b218f0baec9692b66c512364554102d218dd65c9ffc50ef9bd;
        _retrieveSignature[816] = 0x2d6d49dc35118d958384101d4816abb625051b3c666389e2ba5567d3e920bb06;
        _retrieveSignature[817] = 0x97a458cea0903c6bb42fcf76877a86408a92b462d0cb8ce5c06d74c2cb384bea;
        _retrieveSignature[818] = 0xf3b0de0bdec47d95cbd8f4ea4ba39181899beb40f08babbd31dd0da15c1affbe;
        _retrieveSignature[821] = 0x5af1c15af392f07b6cb053ce746bfe55233aefa69367929a7c8fefc824b05387;
        _retrieveSignature[823] = 0xd7758ae273ccf9b9f793cc4214f83591927f364cb79038b401e2e69cb60b9201;
        _retrieveSignature[824] = 0x6095d52fa80470554264dd3866d8a5415455f2a4b821f8c82286553a6231ea16;
        _retrieveSignature[829] = 0x5eb0d58498230096b6d18a2cff3e38f661502d902395cf557b9557290e7a6d4b;
        _retrieveSignature[830] = 0xa62974860fe8e3ed574e918baf12570f00ec03ada3679ba63ccd0bd5fe3dd6b4;
        _retrieveSignature[831] = 0x27428d16b07e583df6256d8710e43a48d7367a5ca055aaada089f97690b1ff4a;
        _retrieveSignature[835] = 0xb3a06207e6c4d8c2c2f8e3183d91c234ecbaa8536e21c0565fcd184f16c8b0ba;
        _retrieveSignature[838] = 0x018bf8f44b6f8a28274c37db464cc490def0615797bed12d3634178a896a3bd6;
        _retrieveSignature[839] = 0xb1e886c4f1af17c98cd431561be066615fe8ca5c4d6e620699eee6f72801da9e;
        _retrieveSignature[840] = 0x79a13e37d32d3934b2c6608d4a4b456bc38e006bd5d61b24fa0f3400036adbc6;
        _retrieveSignature[841] = 0xfad27d771a1d7c98d7b7ae247fde2df43d349f44791a4f57b8dfcd7beb3f7e09;
        _retrieveSignature[842] = 0x8b48863c4be4b4ca38d520a9e633396e4511cc478a24e555e1215b08b5634fcf;
        _retrieveSignature[843] = 0x177809dd7af51d071129b10b9dd4cf995063a2092d72d8dd643c374d132f0e3a;
        _retrieveSignature[844] = 0xabae89f13faaf6fc0a5483267f1cc50f4bb30a39b46f1e2aa8ebbff3ca6fb018;
        _retrieveSignature[845] = 0xfe403960c6e9ee6db700b97d967cd3818d17c3348ee4b8567cc16eb52b0d6142;
        _retrieveSignature[846] = 0xe5b2acb82d3096906e29d6afc8a834721ce9fc1ff6d9ab7eef212cc4d50c0679;
        _retrieveSignature[847] = 0x266b4f360d3672f2246135a03abbd843c2395298c7a01756911f206d59631583;
        _retrieveSignature[848] = 0x691bed9963a00dc7f9d9f8e653fc7e3b02693c39124d29b425d59b57baf1cd3c;
        _retrieveSignature[850] = 0x81df3410256e95ae2342ff3279d60c51b24ce8a069b21303fe2394388d2fdccd;
        _retrieveSignature[851] = 0x0a10221e49a7257e255eb633c1b4375fceb5f56551bea6c9a1b8a9b1f5fabcfc;
        _retrieveSignature[852] = 0x1c31af6f455b93b0cf68dde94f2647bd4a7ed2bc7528bbba08238e5dc9d0051d;
        _retrieveSignature[854] = 0xafc412400e7025983f0b37315a002a611508d34064818fffc8d37e8370c949ee;
        _retrieveSignature[856] = 0xa16364acb4891a666044bab9c4319559ff2c5988cca16e5b0a479e0e7952a1f4;
        _retrieveSignature[859] = 0xb4b8bbc5a1be4a52f1c76e3b54a90c01527636d1ca21300b41d7fcac8724f714;
        _retrieveSignature[860] = 0x4a7fff4107a8314c6b18a45e5d030b6da2f7205534c13512396c658259e402cb;
        _retrieveSignature[861] = 0x7dcd2a0147c8d2570f75f91dcd870e43192acde808bd149c439101782790cdfc;
        _retrieveSignature[862] = 0x0925533ebdcf19ec97e7f9eeac3abf7ea1bcc6a22cbb694bb7a6dfe709fb2d10;
        _retrieveSignature[864] = 0x55a925cc0f988198303ed1112b7871d233536fe66f30e4f8b72cf83e63d3a1c6;
        _retrieveSignature[865] = 0x89c373a4c3f62054965fe74d1f636ebe0da6a38464165c28dfcdf9e4ae053753;
        _retrieveSignature[869] = 0xfb745f7da7749a4b8538094b2722975f6f96cad29ad3bb948ed08bc61d96d640;
        _retrieveSignature[870] = 0x0ee45f801ac6c614693d835c5f74c22ad7bece52e4bd37abd2f0d1c61744df8d;
        _retrieveSignature[871] = 0xabaa6ed2a25facd01dbb2c50e17331518bb410afeb4c6de4642a93cc93fe2362;
        _retrieveSignature[872] = 0x602a637b08670ff8377071cffd70bc813062e10fd01aac739d2126b68344308d;
        _retrieveSignature[873] = 0x39b05d3982c08b1a1d8ebcac744b6a53ec322ff48eaa5e541e8b9d41aaf0ea75;
        _retrieveSignature[874] = 0x57030b32f0bdbbae60d8b0cf8a2f8944966281145cc03735bae3d5dd18f4c6c1;
        _retrieveSignature[876] = 0x7dd5a08f3a66baa30bd8c1ea113fdf6015d222830906089b1db454576353e1c8;
        _retrieveSignature[877] = 0x2af7ee9f89ee7f0835f539de6319d1dc1f5a8d5572526e11653284835a3515e9;
        _retrieveSignature[878] = 0x73511cea8bd1113e40d00d7d239a79db297730cf97f56d43a31b10bf082b8488;
        _retrieveSignature[881] = 0xb01d23514d3328f06cd4ce53588250bedada748c9474b406050b270a185cc904;
        _retrieveSignature[882] = 0x38d9ba827a661f34a0fbe326e6b701f3bfb094c75a91fe9ddc90b0d328929884;
        _retrieveSignature[883] = 0x6a622a3646f40c48eae56f5663193f0ae3c9f1b4b261b6dcae0941172fe054ba;
        _retrieveSignature[884] = 0x0e25edebf51ab9a9ccbf9bc2648089a07646e6ebaa5303dd4a5a805f402821c8;
        _retrieveSignature[885] = 0x2609bcf9fd00faf825dd448e2e572ef5c2580b2e6b4753e29e0a5d2c90e70de3;
        _retrieveSignature[886] = 0xb956ec38aec569b866bc9c94c2ef2131f0dbbcd2b81dde52e3d3b582c7e64793;
        _retrieveSignature[887] = 0x54cf05fdd815661ecff2f631272620751a02a9d6434e209b7003d54ce499eb44;
        _retrieveSignature[889] = 0x602574f7e4144669a924bf75c694188abca9cac8c98985d68af5f7cb0782286b;
        _retrieveSignature[890] = 0x8af69022b16e6455a554020be36c46e9fa627440010490feffd9e57825a95a2b;
        _retrieveSignature[893] = 0x9a348ea63048948b284ffebbb313fea1f5fa2fa71d0868ee300797fc84d480b0;
        _retrieveSignature[894] = 0x45b570b493e47501377f88effaf8568ef393dec3c38d08413102c757c8dc92e3;
        _retrieveSignature[896] = 0xe42ac5bac9a022b86723bf2b7577a015b3772c294a360b4390c5aaf9894517c5;
        _retrieveSignature[897] = 0x6d879ea0ed9a7db86430c7d9055ecd6061154610917400d3e8f89916646946ff;
        _retrieveSignature[899] = 0x7d80e6ead8a28b081d22f1db7e36875bdd02e72f164f39e60a5b178630ba8922;
        _retrieveSignature[900] = 0x934925e3891e7f2f756bd6d744a7788df5d0206a20f2f53e605b3d26b6675646;
        _retrieveSignature[901] = 0x5f5c18017c8d0b5badbea444f9057ab130703fb1e8301c1d18a9fae440aa9180;
        _retrieveSignature[902] = 0xd3b849da1955925040fb01370925f8d53ceab20b0cebe7d4e334bf0cd1ba78f5;
        _retrieveSignature[905] = 0xb636db7aa42cb1cf82a231afa439a360f3ed7fa00cfa77a5a73b90b75e4d3db7;
        _retrieveSignature[907] = 0xb428361fe412bc673be86d0d7a251bbf6c9a984b8bc2500a05d0fd579996f4bf;
        _retrieveSignature[908] = 0x1109a525523b7b78d37704ab3473d2ec9ee891a1874551701b69b7c7afac4e78;
        _retrieveSignature[909] = 0xa403c3e588db1389ae5c0437501b1c71b781b16ba86599a5632660ebf538614e;
        _retrieveSignature[910] = 0x78b543fcedc5884a1e1bc10182b220ddf339d942f675fd957d8ed94f92289826;
        _retrieveSignature[911] = 0x1bf1842b3bd83239b67ffd9fd3dd8116dd8fa18a2b84d79f726ae720f3e4e43b;
        _retrieveSignature[913] = 0x8dfb0ce522620e241c861606e84908eeca35e9940aae8f5e81ddeac850e80538;
        _retrieveSignature[914] = 0x9ac1f100a7fa24f938d8b2c63ccdd0bce210e74f0f4e28cb765d41693e4d8cd9;
        _retrieveSignature[915] = 0x7d73df5abd2bda3b2d47a488c2e7533f4aa18ba8ad9fcaf7b97bbbe9b6f0fdd4;
        _retrieveSignature[916] = 0x36c60bea8e2bdc589febbac109a76718af1b2b1d53c88f300805cecaef149396;
        _retrieveSignature[917] = 0x89220c40897d3f85bd33190ae87d618ea8621305a573d6293bb31322253cf496;
        _retrieveSignature[918] = 0xf7230889c4824344f3c192fbc99218273e7cd5f84e78d87de19f8629135da7e0;
        _retrieveSignature[919] = 0x47d1ce0d5777c5a2b9cf9774d756c5f8b773ec56d0e355fd42ca8ac2e9e56792;
        _retrieveSignature[921] = 0x16ca7710d0bea93883d80c1fd21010ac8ec98d1c418c5fafaba339766ef58a38;
        _retrieveSignature[922] = 0x8e40d46700f92c2cefc47c7331a1b6e3be40d286de1da9b69e5837324cc9d99f;
        _retrieveSignature[924] = 0x129a8192aea6dc75f31f62137942a0c7091e4c21ea28654d298750c98f73b091;
        _retrieveSignature[925] = 0x353a8304940569533ab34b728d779e8dbb2c31f994af565d4d67ec53014a03a3;
        _retrieveSignature[928] = 0x06072ae3e70ea68e3543b9de795b3425797b46a79d6da3fe365a18044761db77;
        _retrieveSignature[929] = 0x29e5b5375dda8067d1227490b526094f4d71cf395ff409108492320ce6c589b6;
        _retrieveSignature[930] = 0xa6b57e30b911305bd420142ecf7d59c437f76596150ab87bb699952c3e66e14e;
        _retrieveSignature[931] = 0x4baca7e0b0fd27f35c8ccdb9fe4325545b610a0d0a08eb718d094c1f77346c0a;
        _retrieveSignature[933] = 0xaa77bb9cbca2cfbd513e28c8858030f171e20d5ccacbe4a15d8523e91c441bd2;
        _retrieveSignature[934] = 0xd19501aa0e8feedf24cdd632361982d7f6f03b38216a709fc7516cc792af439b;
        _retrieveSignature[935] = 0x53eea7fe5413c83ec17d8fe49b278b53b4f1f11a5faa90e3c1e84a2b3c9c8b96;
        _retrieveSignature[936] = 0xc39e4820fb0f698d6d5cd2db9cd009fbe202ce7d69d26190fe17ee29b55b40a4;
        _retrieveSignature[938] = 0xd6ff658b280afcfb1ad2bcfd1d789279e21de53aa4be99f79aef389be9f661c4;
        _retrieveSignature[940] = 0x21e1b65bf89cd8bb012de3ab16e6eb69a35acb4aa1df3f2081e4fe495f2119fe;
        _retrieveSignature[941] = 0x7141e22c0778288fe76d31b094c3ef0b5892130e0ba56c026473b4b8e630a9a4;
        _retrieveSignature[943] = 0x0ef69f4714083ca83efb45c37c736e2efbaa0a7fc2491329a69e695db76de053;
        _retrieveSignature[945] = 0x4a7e40ec457990d48ed267c9654cc560175a89fa6602c8ef040a0574d681a1c7;
        _retrieveSignature[946] = 0xb6c545747361dbac460b0e4b23390b01c14dbfbfa63f30c04e894e3f71b088f4;
        _retrieveSignature[947] = 0x7af79e661648f9ddf3c93b64bf77975074c469c0205b5c891a15a19b0ba295df;
        _retrieveSignature[948] = 0x28112256490599412dcb4d72b7d8b57265e5966ae368ef44394f01f844822c5e;
        _retrieveSignature[949] = 0xa5eddaa38c4050e3ea787cb87d7d4595925d22fcf070f1c0ad046848e77c30a4;
        _retrieveSignature[950] = 0x7197254b367ffdf4b9ac12b9261be739d42cd935a98459d4b8356103adf0c899;
        _retrieveSignature[951] = 0xa28125bef1663f28011494731664d4728b17eb75ea2bfd4620d444b7e316a471;
        _retrieveSignature[952] = 0xd6e3d16e6010bdbba7b32f0218ea0769a2a0f6f4e902b8afdf0ea95b9e4458b2;
        _retrieveSignature[953] = 0x0ed94302db91b59d2bee5d594ea25ae99bd754daa6756446793169da9ee7b779;
        _retrieveSignature[955] = 0x38043b5248a92137c74b4e26de9bb1c831c822b103cfb1c4950b6a9cf248bc63;
        _retrieveSignature[956] = 0x9ef7eab69dbe9f762cad54c23ea5f354f1bcf23b56ba643c18aed1de486e5251;
        _retrieveSignature[957] = 0x33064ff91352d794a13d3d889344089cbe7bd3c4f91cb8a0099f9e369bf4c858;
        _retrieveSignature[959] = 0x4ff7434591318421208937c12d7c4518d8aa5cbca6d7e10ca5bcf2cf45fa7bc3;
        _retrieveSignature[960] = 0x2c45f511437fb96a7d6b52ed8e9d3c6af05727f849a9a03f52001bcc6546412a;
        _retrieveSignature[961] = 0xd69db2305e2b3975bc91532b15c6bc87114e4b4bb78239b8c095b137c4a9164e;
        _retrieveSignature[962] = 0xd7f811e05aa5799e1a2c282eb11b5b88840eb35789f01b1897e593442907538a;
        _retrieveSignature[963] = 0xf0adbb4f3b3a31f51f6648979687aac5dd4aebbe1e8015fc5a586b76eceb0fbe;
        _retrieveSignature[965] = 0x502da8d10190f7d81d6845075b92c671d7ac61fba455300727f421a74ec7ae3a;
        _retrieveSignature[966] = 0xe0aad50e2afd1be32b03d9e73ebe338900fcc16bef6730ab022510f50bbbef83;
        _retrieveSignature[967] = 0x86aafe51f9099521288f6f2fa54d681990e101738aa84b2bf7f4cc7b4967b2b4;
        _retrieveSignature[968] = 0xff3995e3fc78043fa10530540e7775c97d5caeba6ab8197c05412882b6e33ba2;
        _retrieveSignature[969] = 0x48c4d16f3252caace368d29e47b4318a46233b6cc76cba631fdac070f24f0156;
        _retrieveSignature[970] = 0xc5cb4eed46e5a92de26b11ba86dbd7969acfc3b756e8efda85c12dcb4f2834bb;
        _retrieveSignature[971] = 0xcc6dbc3b52b32d32ee2266dd13e83649c5b35691c1ba0bf2a41106160a984e7e;
        _retrieveSignature[973] = 0xc508424d9bcc33539ffb8dc930fe03347106882c73db95758f02c370697fb742;
        _retrieveSignature[975] = 0x3fad24f79a7c44757fa7da2104ad75073db904f5a4e7e6a12f81968024ae7efb;
        _retrieveSignature[976] = 0x83bc9f41ffcd828934ad80ad3d88674dd9d7cac47d43a5162f0ce15be5b310de;
        _retrieveSignature[978] = 0x4f55e15922185d4ed1109d49a31683fed6381e46daaedd4b9c172acae8f5fe12;
        _retrieveSignature[979] = 0xd7ab51a88c2ce1095a327f6cb5a7308bfeb9292dcea7bbf78a6ead00c95d83d3;
        _retrieveSignature[980] = 0x0befa7477d3232ddd52f9378aa2535ab1a184aa078d6dc2b824fabab5b55cf54;
        _retrieveSignature[982] = 0x4b57c649c8402b73474d64e3df1ee75b8ccfa27c0cb3c4c483028a5d64555009;
        _retrieveSignature[983] = 0x76a28f7b6c2ab35f3a63b03af8d07c26ecbe5f6d62455c8c599f9f268554d922;
        _retrieveSignature[984] = 0x6f6d13896351c59752f5cf42a747779a368fb9bf8b017721b7f8fe10f11534bd;
        _retrieveSignature[986] = 0x213f95c4cbb8103c85dcd194700b6c21bf7dd04998a8e996c76f4dc9ca23e582;
        _retrieveSignature[987] = 0x691e0ff52126816e649a5604b4d4ef8f820efc1f9a1373324cad087357eaa1c0;
        _retrieveSignature[988] = 0x59e4f6992f902486998cb66d818785300b98ab25a36a129426ac1ba19dcd0af0;
        _retrieveSignature[989] = 0x5919d97dc382007bf069f8c3a91a5c57e51c3b0e9b887bc3d618111994949bbb;
        _retrieveSignature[990] = 0xe44137f52c0d2bf8581858b44df6cd21bb219c62ddf809bdee9de283c064ae75;
        _retrieveSignature[992] = 0x44efdbe2ccd04fa24d88c8d3ab3102db43fb4e288a618a7e9d8be0d72ab97f8c;
        _retrieveSignature[993] = 0x5fe1861c5ce628161bcfbefbef7b25d14e8c0400d2dbd7416d7350cdbe4c77fa;
        _retrieveSignature[994] = 0xe963fea29b6341173607ec2e2ad6a3e18a6f8ab0591c9c7d26f25c8d459e2754;
        _retrieveSignature[995] = 0xf92d75ec3d89121c1ab5b0864beb51dcfcd19eb70bc2cd0282286f1fbfe9fefd;
        _retrieveSignature[996] = 0x9e7d473973fd187a7a8aca0c770b56e573ffcfbeb7bc07e6daa6a3acc4b7229a;
        _retrieveSignature[999] = 0xc6d1e62bbe86ff6089db88d40ef1b6c61c0bab06b82d10798302fe03c2349b34;
        _retrieveSignature[1000] = 0xf1dbf8fd02ba319684efc05327c4d90de3a4b3b01a8d69bb371c2867459261ae;

    }


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
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
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
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
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}