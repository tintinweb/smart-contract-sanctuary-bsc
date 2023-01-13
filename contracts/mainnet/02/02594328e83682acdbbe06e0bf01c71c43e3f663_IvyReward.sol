/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

abstract contract Administrable {
    address public admin;
    address public pendingAdmin;

    event SetAdmin(address admin);
    event TransferAdmin(address pendingAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    function _setAdmin(address admin_) internal {
        admin = admin_;
        emit SetAdmin(admin);
    }

    function transferAdmin(address admin_) external onlyAdmin {
        pendingAdmin = admin_;
        emit TransferAdmin(pendingAdmin);
    }

    function acceptAdmin() external {
        require(msg.sender == pendingAdmin);
        _setAdmin(pendingAdmin);
        pendingAdmin = address(0);
    }
}

abstract contract AdminPausable is Administrable {
    bool public paused;

    event Pause();

    modifier mustNotPaused() {
        require(!paused);
        _;
    }

    modifier mustPaused() {
        require(paused);
        _;
    }

    function _pause(bool pause_) internal {
        paused = pause_;
        emit Pause();
    }

    function setPaused(bool pause_) external onlyAdmin {
        _pause(pause_);
    }
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract IvyReward is AdminPausable {
    uint256 public galxeWinnerReward;
    uint256 public quest3WinnerReward;
    uint256 public crossChainRoleWinnerReward;

    address public rewardToken;

    mapping(address => bool) public isGalxeWinnerClaimed;
    mapping(address => bool) public isQuest3WinnerClaimed;
    mapping(address => bool) public isCrossChainRoleWinnerClaimed;

    event SetGalxeWinnerReward(uint256);
    event SetQuest3WinnerReward(uint256);
    event SetCrossChainRoleWinnerReward(uint256);
    event ClaimReward(address, uint256);
    event SetRewardToken(address);

    constructor() {
        _setAdmin(msg.sender);
        _pause(true);
    }

    function setGalxeWinnerReward(uint256 _galxeWinnerReward)
        public
        onlyAdmin
        mustPaused
    {
        galxeWinnerReward = _galxeWinnerReward;
        emit SetGalxeWinnerReward(galxeWinnerReward);
    }

    function setQuest3WinnerReward(uint256 _quest3WinnerReward)
        public
        onlyAdmin
        mustPaused
    {
        quest3WinnerReward = _quest3WinnerReward;
        emit SetQuest3WinnerReward(quest3WinnerReward);
    }

    function setCrossChainRoleWinnerReward(uint256 _crossChainRoleWinnerReward)
        public
        onlyAdmin
        mustPaused
    {
        crossChainRoleWinnerReward = _crossChainRoleWinnerReward;
        emit SetCrossChainRoleWinnerReward(crossChainRoleWinnerReward);
    }

    function setRewardToken(address _rewardToken) public onlyAdmin mustPaused {
        rewardToken = _rewardToken;
        emit SetRewardToken(rewardToken);
    }

    /// @notice Call this function to receive reward
    function claimReward() public mustNotPaused {
        // revert when any exception happens
        uint256 amount;
        if (isGalxeWinner(msg.sender) && !isGalxeWinnerClaimed[msg.sender]) {
            isGalxeWinnerClaimed[msg.sender] = true;
            amount += galxeWinnerReward;
        }
        if (isQuest3Winner(msg.sender) && !isQuest3WinnerClaimed[msg.sender]) {
            isQuest3WinnerClaimed[msg.sender] = true;
            amount += quest3WinnerReward;
        }
        if (
            isCrossChainRoleWinner(msg.sender) &&
            !isCrossChainRoleWinnerClaimed[msg.sender]
        ) {
            isCrossChainRoleWinnerClaimed[msg.sender] = true;
            amount += crossChainRoleWinnerReward;
        }
        require(amount > 0, "no claimable reward");
        bool succ = IERC20(rewardToken).transfer(msg.sender, amount);
        require(succ);
        emit ClaimReward(msg.sender, amount);
    }

    function getReward() public view returns (uint256 amount) {
        if (isGalxeWinner(msg.sender) && !isGalxeWinnerClaimed[msg.sender]) {
            amount += galxeWinnerReward;
        }
        if (isQuest3Winner(msg.sender) && !isQuest3WinnerClaimed[msg.sender]) {
            amount += quest3WinnerReward;
        }
        if (
            isCrossChainRoleWinner(msg.sender) &&
            !isCrossChainRoleWinnerClaimed[msg.sender]
        ) {
            amount += crossChainRoleWinnerReward;
        }
        return amount;
    }

    function isGalxeWinner(address account) public pure returns (bool) {
        if (account == 0x47706c58602B33f876C2495835B65dC8cE603938) {
            return true;
        }
        if (account == 0x48cddC4602Ad1B30C25484F345e9288DeF388bDF) {
            return true;
        }
        if (account == 0xf75729DCA43E96dc38F519d1dbefB950Ae95A507) {
            return true;
        }
        if (account == 0x7a40E4513e337430678F1A0811207C788A7c08D2) {
            return true;
        }
        if (account == 0x17Be284e0e074C70F8A392EbC5b2f58c9CF4c2Bd) {
            return true;
        }
        if (account == 0x83f68939de5b679299De9d72B40A6E4688b6c587) {
            return true;
        }
        if (account == 0x656A41EeBec46A6f3709783c8C93c2E522d2AfEB) {
            return true;
        }
        if (account == 0xdB7959083356A77372601416A8f2F3268e9441ed) {
            return true;
        }
        if (account == 0xE76f1230c61160206306CB55e524d5843bAD697a) {
            return true;
        }
        if (account == 0x21dc8500D0041Ea8D5F701496eBD721388c56911) {
            return true;
        }
        if (account == 0x91E51f176A34820E6c1F3298847B83A3f4cBCAEF) {
            return true;
        }
        if (account == 0xC4f9599Ea2e1b34b874Ef0165d0A00D9e09C535C) {
            return true;
        }
        if (account == 0xfB17d5CD85854B6Bee89e714591DE521F3169dE5) {
            return true;
        }
        if (account == 0xf9DEBDdd523071D46AE12f6Cb303A885C8Ff6566) {
            return true;
        }
        if (account == 0x9C91dDf87FEA79f44d26B1f6FA5F4792199C2028) {
            return true;
        }
        if (account == 0x9527935f215D87F0Be26eaC6d5B953BF00734b6B) {
            return true;
        }
        if (account == 0x2262349C5d566bc3795e8D0D471BA7fDC4F3C748) {
            return true;
        }
        if (account == 0x58605D60E2964Aa36D6cB4da23d9f9dDeC9Bc4f7) {
            return true;
        }
        if (account == 0xCa4Eb9db9D8BC0d7DAe95467D51AE72445E0AAb1) {
            return true;
        }
        if (account == 0xAF694d15d57206CE52894E8E95294747145cd19f) {
            return true;
        }
        if (account == 0xA0e91Ceb142A552FEB99a89560f405c66bbDA8A4) {
            return true;
        }
        if (account == 0xA95E9c54E9260E74e45836E1a2E5fF42ebb7Ad1F) {
            return true;
        }
        if (account == 0xe4eF1Ae74d042fc2155DeCEe38EaC5c8f49569Ad) {
            return true;
        }
        if (account == 0xefc1A9e513742ddcBaB16B569fE8fc032BA63cBc) {
            return true;
        }
        if (account == 0xE9AE9e60AE86844f8ff7562769415c9F448e7fB5) {
            return true;
        }
        if (account == 0xAAC65b462eA64a66D8580380EeF30D7f1ED8B011) {
            return true;
        }
        if (account == 0xD2876A4456C89a57fCE5098027Bc38BA562E2063) {
            return true;
        }
        if (account == 0x792c68eFa4F64c3289D96020e5a2ad5A2d0fEcCa) {
            return true;
        }
        if (account == 0x812581Afb0281044A4E8a8D5605F1bc630f1bc45) {
            return true;
        }
        if (account == 0x69394D9Fb0CF4edaB537804d8eb1639B07471ec4) {
            return true;
        }
        if (account == 0x61D2e75F7FB931fbDB91733dB51ECa59817967D0) {
            return true;
        }
        if (account == 0x45a1FE688c01CCfd4606aC31D1F7b10FE2aa875e) {
            return true;
        }
        if (account == 0x72656CdF1c5Bc08F7D95919e1b31Ca8a88de62c6) {
            return true;
        }
        if (account == 0x93c946c90378DaB4C82B30b65013E73543489909) {
            return true;
        }
        if (account == 0x1a5381D812Fe791a1530b8922235CB9436c2DA40) {
            return true;
        }
        if (account == 0x33c76A0e5C5e850E65FEd930c3805a29bCaD558D) {
            return true;
        }
        if (account == 0x4DFD8736c7B26b09Cc603954ddd0B43bC4C6ad8C) {
            return true;
        }
        if (account == 0x9C9c050D3ABDe165643D82fce2483C6CcF2821Dc) {
            return true;
        }
        if (account == 0x4BCCc335820a48eb9977A8964017865876B067dE) {
            return true;
        }
        if (account == 0xb380275127B3370dA3e77c55BC3133c7ED3E5c2d) {
            return true;
        }
        if (account == 0x0611133571496E814294cD17067f4C14eee7D04f) {
            return true;
        }
        if (account == 0x20BD3Ae9171cf20436a8a7e8027c74Bcc7E2DbC4) {
            return true;
        }
        if (account == 0xCC43db8Eb7f32246843553FdeCBD816D195a26C0) {
            return true;
        }
        if (account == 0xec16F03f3c4d8b9DD4098e50d06C792D39573849) {
            return true;
        }
        if (account == 0xaF02f27AbF8337Fe8C78E9Dd22AB85B4661ff50D) {
            return true;
        }
        if (account == 0x60ed00da69f9F66803e7f2c99E414D3B138BE0D6) {
            return true;
        }
        if (account == 0x22BC858e301C864e898cF06D2f383e70d26CDf5e) {
            return true;
        }
        if (account == 0xf5C9cBc4C3B4113b860975008AB47Ff1228E24b2) {
            return true;
        }
        if (account == 0xd020C29c2d418C758ae9aFf00b8121430054BF45) {
            return true;
        }
        if (account == 0x417B07C4AACD85518a989290E3538beAEF05F79f) {
            return true;
        }
        if (account == 0x9ADFDa71EC02dAD99B8A1fB91c31e83e91eB34E6) {
            return true;
        }
        if (account == 0x074e92b8527587725A0e2b4B41EC85d797481AB5) {
            return true;
        }
        if (account == 0x9e9dfFB991f9C8a29235EEC5BC652BCd31dEd82c) {
            return true;
        }
        if (account == 0x2742059C7962B64bA000FC6Df1F01DF17C6B3a57) {
            return true;
        }
        if (account == 0xab9FA6211DDcdA714Db134804A86b25e270E3491) {
            return true;
        }
        if (account == 0x00409fC839a2Ec2e6d12305423d37Cd011279C09) {
            return true;
        }
        if (account == 0x519290b3641D881a6AB5Df4C1b4494FaF1ccBC64) {
            return true;
        }
        if (account == 0x5615B91b204E2d5A342972b2AEaafb30Ad3D1184) {
            return true;
        }
        if (account == 0xBA7F6544A9D86eBa6Ea7353BcCA2aF79d2D8B5a8) {
            return true;
        }
        if (account == 0x40e8e8af51E1e3Ca765dD1A702c31240FC4243E1) {
            return true;
        }
        if (account == 0x0750505DA0868D1e7b2258d236898193FB2d855A) {
            return true;
        }
        if (account == 0x0715C3329e38790C853F6fFD824f2771a02D37bf) {
            return true;
        }
        if (account == 0x9140421A8C63d7270b1A5db2056917EE57D98456) {
            return true;
        }
        if (account == 0x1234C7506e84335c0e5761a7a6Ff368cdD94CA37) {
            return true;
        }
        if (account == 0xc606c686D99C68799d86f7Bd32F897F82ac51400) {
            return true;
        }
        if (account == 0x429c970f5556b78f2516117d1a7d49b51C2C2278) {
            return true;
        }
        if (account == 0x22b2cCb53963Da600c83191db1cE3f61f92DCf45) {
            return true;
        }
        if (account == 0xf570fBB739bA6d32ee428e85E3B35d2C5aB4a10b) {
            return true;
        }
        if (account == 0xD59Ae975575efa5c43226766A8a162D5A9349800) {
            return true;
        }
        if (account == 0x58d908a3A5931F3b744e3c442aC7624D2b20973e) {
            return true;
        }
        if (account == 0x14507ccFe37ACc38A005c6A15d7BCA463daA91B5) {
            return true;
        }
        if (account == 0x4cbcaEaCa90dA44cE61C15C4FAF9Fa127fAa53A2) {
            return true;
        }
        if (account == 0x6710a1a38295A96084fA64821cf97DA4CB29cb4c) {
            return true;
        }
        if (account == 0x5F05Ed08E67CBd71E5F4819146c5409F405baEe7) {
            return true;
        }
        if (account == 0x72F4a16926841e58aE41Bf31af19b35d1c3610C9) {
            return true;
        }
        if (account == 0x9F1bc79ab1dB00eB43C445b2BdBfA1b82013EF67) {
            return true;
        }
        if (account == 0x757056E3AB3C65c6c8c710F7E6F9A8327Cc6bae7) {
            return true;
        }
        if (account == 0xa9811f9f6B8bCA7f9F91f850A98310e63FBB7326) {
            return true;
        }
        if (account == 0x8943b6c8c565a4a50cdF14Fd1BA48D633ACd1543) {
            return true;
        }
        if (account == 0xF3b32448fcd5ac0c475097efdF55C5f4e8aA8d96) {
            return true;
        }
        if (account == 0x41Cc37f36F34EF240a15e8Ff5D9a12De34cA758b) {
            return true;
        }
        if (account == 0x69155E7cA2E688ccDc247f6c4DDF374b3ae77Bd6) {
            return true;
        }
        if (account == 0x6213aeb0360262f671Ebb6C0093AaEf8b5A251aD) {
            return true;
        }
        if (account == 0xB02fA29BFD054dB5514115533B6faC39DAc75391) {
            return true;
        }
        if (account == 0xCb868ad1b9EfA0632B2a0e8951bD6005779b1D20) {
            return true;
        }
        if (account == 0x91ffee605070D1B8aA4DDD514856De6c6cA3A085) {
            return true;
        }
        if (account == 0x271fd0a67e7366044cE7063a7432cD04D5E8E574) {
            return true;
        }
        if (account == 0x7EA33775F39D009137b92Af815c32366c7685f8D) {
            return true;
        }
        if (account == 0x2C597Df2c120C896E6bD1D1800d99C4Ab7303ad3) {
            return true;
        }
        if (account == 0x7c913BC1E61A2dBbFB5C4f1D63eE218DE53214F3) {
            return true;
        }
        if (account == 0x10bAC83A258Ea7C5A0E4428577Bd3aC802650a3d) {
            return true;
        }
        if (account == 0xB49cC9Ab59F84efe894dbF422DA61a12cc6ef898) {
            return true;
        }
        if (account == 0x3EC883Df3AF5A6cff6e6e58694A70Ef1da97c286) {
            return true;
        }
        if (account == 0xd1d09206638eDc9eD166c0F73d7056441716b0E9) {
            return true;
        }
        if (account == 0xa76930ff06196f7d735D893e93eEc3dDcec35878) {
            return true;
        }
        if (account == 0x2602Bdc6EdB4f54766E1D32A0232535d871FA14C) {
            return true;
        }
        if (account == 0x97568d242AB0233C55D992aA46cD41E7311FCc14) {
            return true;
        }
        if (account == 0xF2C2d3813f204d574aC8574025f3d2De3c2bB2F5) {
            return true;
        }
        if (account == 0xC074a5ad1bA1879d762775dAA76d4BA0b39d1519) {
            return true;
        }
        if (account == 0xBC6D606226130c45bE14BC1EEbcCF3a9DaF4b5Cf) {
            return true;
        }

        return false;
    }

    function isQuest3Winner(address account) public pure returns (bool) {
        if (account == 0x64Cf33d4e93605cf07AdB954fDFF08de7968dE8e) {
            return true;
        }
        if (account == 0x3625EFf632EaB044489a46014dd168cCb5112240) {
            return true;
        }
        if (account == 0xb627B31b6efb1aBe4BabAB17162291FFE2164e69) {
            return true;
        }
        if (account == 0xdbD05ec898cb3b79651c5c6A994C89430b2b2E36) {
            return true;
        }
        if (account == 0x994F96722575B64b27CDBe327498F34Aaa2f0043) {
            return true;
        }
        if (account == 0x2600544F150Db80438004BE4Bbc7114aa21615A9) {
            return true;
        }
        if (account == 0xe4f100b9D50a2fCD41bd475b8a33198779fe5DD7) {
            return true;
        }
        if (account == 0xec8D5D51FD48d32a6b666faaE5799c273BEaB89b) {
            return true;
        }
        if (account == 0x91d708962D843011d580163894553d4fE7415890) {
            return true;
        }
        if (account == 0xCc4f1cb6064A69aC83A5133FFCf09217ae33c2CF) {
            return true;
        }
        if (account == 0x5ec10De94ccb7044cF66aeBD5A1EDC4297ED7198) {
            return true;
        }
        if (account == 0x08Ede5C20c6CB3b5F84f918322126AB207ac6Cd0) {
            return true;
        }
        if (account == 0x5678298b0A0b828242641a202ce132000166dbc4) {
            return true;
        }
        if (account == 0xCd5DfFfdCA595cD5CF3E02011bf04730680295df) {
            return true;
        }
        if (account == 0x5bc40A61Fdb9004970CcF1d1C2d7F3D45E23d8EF) {
            return true;
        }
        if (account == 0xF72390c118188D6706BB303606c06457f198BF79) {
            return true;
        }
        if (account == 0xDe765B9D2A5b5b8E9e952DA5aC3E43B011Cdb289) {
            return true;
        }
        if (account == 0x9deBADcAAE4820092c8Ff7DC741C9ec7D9E95027) {
            return true;
        }
        if (account == 0x922197Fd26290E3AF3dA0C35e7f4F299d95E8741) {
            return true;
        }
        if (account == 0x175d7aC3844aC969c1d17431E59FF057AD17Ee3b) {
            return true;
        }
        if (account == 0xD2876A4456C89a57fCE5098027Bc38BA562E2063) {
            return true;
        }
        if (account == 0x003c9f72c550FaBB7ac70493d5cC9A4fe1702770) {
            return true;
        }
        if (account == 0x41d4a1444b457D211FA8e58e51f819d6C2A4fa82) {
            return true;
        }
        if (account == 0x4b5CE31DCE36E1dab6500366A55a1F4A139dafaD) {
            return true;
        }
        if (account == 0xc836bb138D419107e65d22dbb42377142446924E) {
            return true;
        }
        if (account == 0xbcd6879796b95E5311c5D4542F3eD84A118aD0a1) {
            return true;
        }
        if (account == 0x40901cD53316F78714D8876FEd2546D889c9D7a4) {
            return true;
        }
        if (account == 0x6C80Cb87a44B1fCCB46d05E57bECB8cc720A8539) {
            return true;
        }
        if (account == 0x23296915893ceeD47b13Fd65b91640406FD362bf) {
            return true;
        }
        if (account == 0x3b78637E124f302cA73257Ea6bABC705ac0208dc) {
            return true;
        }
        if (account == 0x6b35366036EAba621Ca654e0b97ECf55CAC8b74C) {
            return true;
        }
        if (account == 0x622372558A8d49A227938f7cd2B5C581a042964E) {
            return true;
        }
        if (account == 0xD92fd328bF6BD103E6b36903dC9a42EcE0DD4E74) {
            return true;
        }
        if (account == 0x09ff330A0AeCE6A675Fba0C50c2b19a67Aa48E8D) {
            return true;
        }
        if (account == 0x8560f7282C3Dd9ba2d0dB6C653e5cE65a055D112) {
            return true;
        }
        if (account == 0x1cae141EC4f5beCD042D8Df35e397b00C26e0E8A) {
            return true;
        }
        if (account == 0xa59b9f413Fbbc19bFcDBC0377Bc9387ecc20B926) {
            return true;
        }
        if (account == 0xa8B1b971968420C0bA4413bCFd1cc4C87AbB3A98) {
            return true;
        }
        if (account == 0xE1d1663892A1dFe82c2Cd11810C9188B8A9B505F) {
            return true;
        }
        if (account == 0x431184fCC6f08F1C886E3864085D574012Ae1262) {
            return true;
        }
        if (account == 0x2904Cd62Abed42916990219Cee643f4A26BC5643) {
            return true;
        }
        if (account == 0x20414830660BD39e6245978452ce4AC188524100) {
            return true;
        }
        if (account == 0x36b8A685BdB5605c8283405c2a9B509E8692e206) {
            return true;
        }
        if (account == 0xb792cF7c490b8aBB3775519b587E866088Db8a60) {
            return true;
        }
        if (account == 0x83662F11FAD03eb94D4Bb5c14B062D04bB66AAc1) {
            return true;
        }
        if (account == 0x21dc8500D0041Ea8D5F701496eBD721388c56911) {
            return true;
        }
        if (account == 0xDBB1eb28026461be645C67183Db8fD3E0D46eEea) {
            return true;
        }
        if (account == 0x479259Cc9F570cDDFd5AF6F694135e05A2d9C00C) {
            return true;
        }
        if (account == 0xBe46853356567E6dFD7dd04db0E3E434fe34337a) {
            return true;
        }
        if (account == 0x216903E23181E35b337d4245BF667c44a124f55E) {
            return true;
        }
        if (account == 0x103Eeb2776A9AD7a8E6C6D39B2dbB2540D13cDbc) {
            return true;
        }
        if (account == 0xDc1540a9C1e113F2aB1270F9bBF1337670B28F8c) {
            return true;
        }
        if (account == 0xf2A376e4cA5aBF44B371abF3E209A37835ae987e) {
            return true;
        }
        if (account == 0xe2FCB8ba7244Bb7B5D23d3C0f10f244Cf60831e5) {
            return true;
        }
        if (account == 0xB2819b8f285675C7c6A805534a39e2aEe8d4f817) {
            return true;
        }
        if (account == 0x196ff3a8d0b1de37873A02AD5218C6631E2D3711) {
            return true;
        }
        if (account == 0xcfC297ace2388C79D9aEC34466f69804AD67Ced4) {
            return true;
        }
        if (account == 0xc442e9C38E8358933964904a55C10A48fE077739) {
            return true;
        }
        if (account == 0xF1541DC2F93d961635E9C4B148eF671f21c30b8D) {
            return true;
        }
        if (account == 0xD125D2D8b1634eda60Aa610Bb86FcAF6D814b070) {
            return true;
        }
        if (account == 0x121734451418CD1C8beE90177C02722626CCBf17) {
            return true;
        }
        if (account == 0xD81de65b0a809BBD0Cf1100f5C75A0F06D0c1d6E) {
            return true;
        }
        if (account == 0x634D766DC62e20D081eE2CB3DEE1F943D6AA7846) {
            return true;
        }
        if (account == 0x5CfA2F21Dbc182115a7d9991a7A7c1aA5EDA5DC0) {
            return true;
        }
        if (account == 0xba9572fbB4A6E85c5F22295515D328F0417b90C9) {
            return true;
        }
        if (account == 0x497b1CE65BA750bad466FAF9E6bb447EED4e3881) {
            return true;
        }
        if (account == 0xD45625AE36F22e5c0E5103E4d62F511fBa1Fe3d2) {
            return true;
        }
        if (account == 0xf75729DCA43E96dc38F519d1dbefB950Ae95A507) {
            return true;
        }
        if (account == 0x0C977Ee39b2280D873d4fb6B5032DeDE2545de0B) {
            return true;
        }
        if (account == 0x42Ef98A77fdAE3fd6cD99620CDc6992487eBe88a) {
            return true;
        }
        if (account == 0x97568d242AB0233C55D992aA46cD41E7311FCc14) {
            return true;
        }
        if (account == 0xA252bd92293B0eb9BEB1C2cF72F794F8a3a54348) {
            return true;
        }
        if (account == 0x4fBE5303bCa958b8f1ee35b5443Aad9aD442e3D7) {
            return true;
        }
        if (account == 0x6dba25204FBB7800c9eeA52cD2e8a4eb667970B5) {
            return true;
        }
        if (account == 0x7F0df4d500412F24695D217e39E0D8dd6329D843) {
            return true;
        }
        if (account == 0x11a8C551Cc77AFfBe51F76cCF59C536a8e552cc4) {
            return true;
        }
        if (account == 0x7d791c27114876f872E04530A104B5e219E2063a) {
            return true;
        }
        if (account == 0x5502CA9c5DF0E937a5243Ade94aCD63c5446c8C8) {
            return true;
        }
        if (account == 0x2E367c87b030A7cC203703BC649f39d4c50D0E81) {
            return true;
        }
        if (account == 0x792d179D5c8AC8Fb6dE2D521FC92071DB1E34321) {
            return true;
        }
        if (account == 0x6E784D345AC6c67bDEEc281043675A7Ac30D19FD) {
            return true;
        }
        if (account == 0x9d9D12E69DE2b3e0dF778Ad2d8975A57d823f6B4) {
            return true;
        }
        if (account == 0x07F1f3F6718Cd80F7043afA66EDC9046FbC3772B) {
            return true;
        }
        if (account == 0x12B0e57797f7eeF121cb99fDF759b513001f08BE) {
            return true;
        }
        if (account == 0x881c393bB89706d411897e64F90235868F2D46aE) {
            return true;
        }
        if (account == 0x6755Fce5d63583E2981e318F8b7a03a9DF226867) {
            return true;
        }
        if (account == 0x01A53b2e2a96EfFb4875076DF9C2c506A7041cF8) {
            return true;
        }
        if (account == 0x06E945e15a90cc8f978767e98602E580013fBb0e) {
            return true;
        }
        if (account == 0xDF11c101D01AfBb04B36723b09D98399C064b30e) {
            return true;
        }
        if (account == 0x14507ccFe37ACc38A005c6A15d7BCA463daA91B5) {
            return true;
        }
        if (account == 0x8a16EDAddE06F1C0C1bF76d303E18916728dbAD6) {
            return true;
        }
        if (account == 0x404F8c820d4671C5c54941D43c727B37CbFdEccc) {
            return true;
        }
        if (account == 0x085bE4633440dd398915eD23542a55F36C6b68AA) {
            return true;
        }
        if (account == 0x17D29587e3e8ddD6697772686dbBEFAeA8B3D7d7) {
            return true;
        }
        if (account == 0x17B72bf643a1c8356D2bB264A42bFCD4dfa3661C) {
            return true;
        }
        if (account == 0x658E0F8A4644719944655b59201bc0C77af9c002) {
            return true;
        }
        if (account == 0x728D943e5f8646CB994D47b47e6Def515B01aE35) {
            return true;
        }
        if (account == 0x0c74f82325D76a9b52D502b0D76CDaF9ACC167dB) {
            return true;
        }
        if (account == 0xE6d1BfafDB59C711a3A806F21B592cEb6FC82910) {
            return true;
        }
        if (account == 0x5534ebB1339cBAd5f5dF6A487C415753949FC977) {
            return true;
        }

        return false;
    }

    function isCrossChainRoleWinner(address account)
        public
        pure
        returns (bool)
    {
        if (account == 0xf2F8bfF6Ec2b77FE7f66fdB27c1465e03d3915F6) {
            return true;
        }
        if (account == 0xc64d769eB79d35246b45813365A99c8e92C694a3) {
            return true;
        }
        if (account == 0xEfce38f31Ebeb9637E85D3487595261FDf6ebeEb) {
            return true;
        }
        if (account == 0xE8b384917Ed2650f06406E7c7f87dD9dF0080fd7) {
            return true;
        }
        if (account == 0xcd0b67a61E5e8F4616c19e421e929813B6D947df) {
            return true;
        }
        if (account == 0x35E6FD7c7E3d1c72a29fcdb5FCabC654f81c4f6c) {
            return true;
        }
        if (account == 0x00FAead453fE210FAcB1EB801fE15e4AFe5d4C44) {
            return true;
        }
        if (account == 0xB63603e6697B6B6AC20D75aB9A8be308b96aE51D) {
            return true;
        }
        if (account == 0xe4eF1Ae74d042fc2155DeCEe38EaC5c8f49569Ad) {
            return true;
        }
        if (account == 0x9C91dDf87FEA79f44d26B1f6FA5F4792199C2028) {
            return true;
        }
        if (account == 0xc9Ea255b552793e2533F666013a8d1D9e36CC206) {
            return true;
        }
        if (account == 0xC9391458C806D8906C8a67e7D9B868CB703A50cf) {
            return true;
        }
        if (account == 0xd1E2b31b15dEE0cC83350051d30b1E156A85f3b9) {
            return true;
        }
        if (account == 0xf5C9cBc4C3B4113b860975008AB47Ff1228E24b2) {
            return true;
        }
        if (account == 0x58605D60E2964Aa36D6cB4da23d9f9dDeC9Bc4f7) {
            return true;
        }
        if (account == 0x2E42192Fa6EefC9281d04bB968d36B038429A806) {
            return true;
        }
        if (account == 0x7ff7c8a4B74a5dA6e8d1a8d1991d9a8CBd6C4335) {
            return true;
        }
        if (account == 0xaBaeE1F1B3Bfd8493e7906e7b6Daa78297DB69Cf) {
            return true;
        }
        if (account == 0x99FDd2a67ba5eC9fb98f451F0e88d0fbEc1eE121) {
            return true;
        }
        if (account == 0x9aC37666237E423611E47683F1E2Ef2054170B5c) {
            return true;
        }
        if (account == 0xA0e91Ceb142A552FEB99a89560f405c66bbDA8A4) {
            return true;
        }
        if (account == 0x9140421A8C63d7270b1A5db2056917EE57D98456) {
            return true;
        }
        if (account == 0x3eCB81dB5fc548ada51931C06a27095D14ebb313) {
            return true;
        }
        if (account == 0x7e49c06A7269E07B38c5513f416Cb9ee0eE7f864) {
            return true;
        }
        if (account == 0x1369b41240A9B0733514b8da09AE3Ec4C815B6E0) {
            return true;
        }
        if (account == 0x9ADFDa71EC02dAD99B8A1fB91c31e83e91eB34E6) {
            return true;
        }
        if (account == 0xb94b4220265419cd8279706b23df25036862D1f8) {
            return true;
        }
        if (account == 0x11925475EBd17C662409d2c0c352f144AB1cA637) {
            return true;
        }
        if (account == 0xefc1A9e513742ddcBaB16B569fE8fc032BA63cBc) {
            return true;
        }
        if (account == 0x2742059C7962B64bA000FC6Df1F01DF17C6B3a57) {
            return true;
        }
        if (account == 0x61D2e75F7FB931fbDB91733dB51ECa59817967D0) {
            return true;
        }
        if (account == 0xfB17d5CD85854B6Bee89e714591DE521F3169dE5) {
            return true;
        }
        if (account == 0xD9b49a81ee72aF3C026a2C144C9Ffd678A78C8b1) {
            return true;
        }
        if (account == 0x4Ab895352356512000FFba26A0A9f81288e2F528) {
            return true;
        }
        if (account == 0x4fBE5303bCa958b8f1ee35b5443Aad9aD442e3D7) {
            return true;
        }

        return false;
    }
}