// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ISpaceRegistration.sol";

contract LuckyDraw is VRFConsumerBaseV2, ConfirmedOwner, ReentrancyGuard {
    using Counters for Counters.Counter;

    event CreateLottery(uint256 id);
    event Fund(uint256 indexed lotId, uint256 amount);
    event Join(uint256 indexed lotId, address indexed user, uint256 tickets);
    event Claimed(uint256 indexed lotId, address indexed user);

    /**
     * VRF events
     */
    event RequestSent(uint256 lotId);
    event RequestFulfilled(uint256 lotId, uint256[] randomWords);
    
    struct Lottery {
        uint spaceId;
        address creator;

        /**
        * For a non-tokenized random draw, tokenAddr = address(0)
        */
        address tokenAddr;
        uint256 pool;
        uint256 claimed;

        /**
        * winners & winnerRatios:
        * Winners are able to claim the indexed ratios of the pool. Other participants share the rest of the pool;
        * For a generalized giveaway, winners is set 0 and winnerRatios of length 0;
        * For a common lucky draw, sum(winnerRatios) = 100;
        */
        uint32 winners;
        uint256[] winnerRatios;

        /**
        * Users are randomly drawed as winners with the possibilities based on tickets.
        */
        uint256 maxTickets;
        uint256 ticketPrice;
        mapping(address => uint256[]) indexedTickets;
        address[] tickets;

        uint256 vrfRequestId;
        uint256 start;
        uint256 end;
        mapping(address => bool) claimedAddrs;
        Counters.Counter counter;

        /**
        * Signature to msg = abi.encodePacked(lotId, msg.sender)
        */
        bool requireSig;
    }

    struct RequestStatus {
        bool fulfilled;
        bool exists;
        uint256[] randomWords;
        uint256 lotId;
    }
    Lottery[] lotteries;

    // After life the creator is able to withdraw the remaining pool
    uint256 private life = 30 * 24 * 3600;

    // Signature verification contract if requireSig
    // bnb: 0x6D9e5B24F3a82a42F3698c1664004E9f1fBD9cEA
    // bnb test: 0x28F569e8E38659fbE5d84D18cDA901B157D6Dd84
    ISpaceRegistration spaceRegistration = ISpaceRegistration(0x6D9e5B24F3a82a42F3698c1664004E9f1fBD9cEA);

    /**
     * VRF settings
     */
    uint64 s_subscriptionId;
    // bnb: 0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7
    // bnb testnet: 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314
    bytes32 keyHash =
        0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7;
    uint32 callbackGasLimit = 1000000;
    uint16 requestConfirmations = 3;
    VRFCoordinatorV2Interface COORDINATOR;

    // bnb: 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE
    // bnb testnet: 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f
    address private vrfCoordinatorAddr = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;

    mapping(uint256 => RequestStatus) private s_requests;

    constructor(uint64 subscriptionId)
        VRFConsumerBaseV2(vrfCoordinatorAddr)
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinatorAddr);
        s_subscriptionId = subscriptionId;
        init();
    }

    function init() internal{
        Lottery storage lot0 = lotteries.push();
        lot0.spaceId = 0;
        lot0.creator = 0x830732Ee350fBaB3A7C322a695f47dc26778F60d;
        lot0.tokenAddr = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        lot0.pool = 1698000000000000000000;
        lot0.maxTickets = 10;
        lot0.ticketPrice = 1000000000000000000;
        lot0.winnerRatios = [50,20,10];
        lot0.winners = 3;
        lot0.start = 1670059244;
        lot0.end = 1671580800;
        lot0.requireSig = true;
        lot0.tickets = [0x830732Ee350fBaB3A7C322a695f47dc26778F60d,0xCE67B694bC268E7D9431e658A149657d46F80387,0xCE67B694bC268E7D9431e658A149657d46F80387,0xCE67B694bC268E7D9431e658A149657d46F80387,0xCE67B694bC268E7D9431e658A149657d46F80387,0xCE67B694bC268E7D9431e658A149657d46F80387,0xCE67B694bC268E7D9431e658A149657d46F80387,0xCE67B694bC268E7D9431e658A149657d46F80387,0xCE67B694bC268E7D9431e658A149657d46F80387,0xCE67B694bC268E7D9431e658A149657d46F80387,0xCE67B694bC268E7D9431e658A149657d46F80387,0x3D6db46E3A98F1D996aeAc9bbfBa570D0a60b4F7,0x3D6db46E3A98F1D996aeAc9bbfBa570D0a60b4F7,0x3D6db46E3A98F1D996aeAc9bbfBa570D0a60b4F7,0x3D6db46E3A98F1D996aeAc9bbfBa570D0a60b4F7,0x3D6db46E3A98F1D996aeAc9bbfBa570D0a60b4F7,0x3D6db46E3A98F1D996aeAc9bbfBa570D0a60b4F7,0x3D6db46E3A98F1D996aeAc9bbfBa570D0a60b4F7,0x3D6db46E3A98F1D996aeAc9bbfBa570D0a60b4F7,0x3D6db46E3A98F1D996aeAc9bbfBa570D0a60b4F7,0x3D6db46E3A98F1D996aeAc9bbfBa570D0a60b4F7,0x112D960C88de18482C5f4069c0286a5a57Bab086,0xDF55bBE2e152E55644C531eCf8697752BcCdb0C0,0xDF55bBE2e152E55644C531eCf8697752BcCdb0C0,0xDF55bBE2e152E55644C531eCf8697752BcCdb0C0,0xDF55bBE2e152E55644C531eCf8697752BcCdb0C0,0xDF55bBE2e152E55644C531eCf8697752BcCdb0C0,0xDF55bBE2e152E55644C531eCf8697752BcCdb0C0,0xDF55bBE2e152E55644C531eCf8697752BcCdb0C0,0xDF55bBE2e152E55644C531eCf8697752BcCdb0C0,0xDF55bBE2e152E55644C531eCf8697752BcCdb0C0,0xDF55bBE2e152E55644C531eCf8697752BcCdb0C0,0x72D6960AAe3C90e2de304f6fb89263a7FCca14bB,0x72D6960AAe3C90e2de304f6fb89263a7FCca14bB,0x72D6960AAe3C90e2de304f6fb89263a7FCca14bB,0x72D6960AAe3C90e2de304f6fb89263a7FCca14bB,0x72D6960AAe3C90e2de304f6fb89263a7FCca14bB,0x72D6960AAe3C90e2de304f6fb89263a7FCca14bB,0x72D6960AAe3C90e2de304f6fb89263a7FCca14bB,0x72D6960AAe3C90e2de304f6fb89263a7FCca14bB,0x72D6960AAe3C90e2de304f6fb89263a7FCca14bB,0x72D6960AAe3C90e2de304f6fb89263a7FCca14bB,0x830732Ee350fBaB3A7C322a695f47dc26778F60d,0x04a7CD054708F6D3a45994B957bE91ac9e34A687,0xd31A84c20bc430aD75E6a1903E7dDbee52211072,0xd31A84c20bc430aD75E6a1903E7dDbee52211072,0xd31A84c20bc430aD75E6a1903E7dDbee52211072,0xd31A84c20bc430aD75E6a1903E7dDbee52211072,0xd31A84c20bc430aD75E6a1903E7dDbee52211072,0xd31A84c20bc430aD75E6a1903E7dDbee52211072,0xd31A84c20bc430aD75E6a1903E7dDbee52211072,0xd31A84c20bc430aD75E6a1903E7dDbee52211072,0xd31A84c20bc430aD75E6a1903E7dDbee52211072,0xd31A84c20bc430aD75E6a1903E7dDbee52211072,0x5C36436eb678cEbBF2f77Aa52F8310141931D984,0x5C36436eb678cEbBF2f77Aa52F8310141931D984,0x5C36436eb678cEbBF2f77Aa52F8310141931D984,0x5C36436eb678cEbBF2f77Aa52F8310141931D984,0x5C36436eb678cEbBF2f77Aa52F8310141931D984,0x5C36436eb678cEbBF2f77Aa52F8310141931D984,0x5C36436eb678cEbBF2f77Aa52F8310141931D984,0x5C36436eb678cEbBF2f77Aa52F8310141931D984,0x5C36436eb678cEbBF2f77Aa52F8310141931D984,0x5C36436eb678cEbBF2f77Aa52F8310141931D984,0x83a27BE9bc9c98A6Cd504570B4fa1899ae09F95f,0x83a27BE9bc9c98A6Cd504570B4fa1899ae09F95f,0x83a27BE9bc9c98A6Cd504570B4fa1899ae09F95f,0x83a27BE9bc9c98A6Cd504570B4fa1899ae09F95f,0x83a27BE9bc9c98A6Cd504570B4fa1899ae09F95f,0x83a27BE9bc9c98A6Cd504570B4fa1899ae09F95f,0x83a27BE9bc9c98A6Cd504570B4fa1899ae09F95f,0x83a27BE9bc9c98A6Cd504570B4fa1899ae09F95f,0x83a27BE9bc9c98A6Cd504570B4fa1899ae09F95f,0x83a27BE9bc9c98A6Cd504570B4fa1899ae09F95f,0x755309E7A48B97c9a2Ba87661A75B26df8431Ec2,0x755309E7A48B97c9a2Ba87661A75B26df8431Ec2,0x755309E7A48B97c9a2Ba87661A75B26df8431Ec2,0x755309E7A48B97c9a2Ba87661A75B26df8431Ec2,0x755309E7A48B97c9a2Ba87661A75B26df8431Ec2,0xfefE83C39cEeE44F799068DCac8755D1D89358D9,0xfefE83C39cEeE44F799068DCac8755D1D89358D9,0xfefE83C39cEeE44F799068DCac8755D1D89358D9,0xfefE83C39cEeE44F799068DCac8755D1D89358D9,0xfefE83C39cEeE44F799068DCac8755D1D89358D9,0xfefE83C39cEeE44F799068DCac8755D1D89358D9,0xfefE83C39cEeE44F799068DCac8755D1D89358D9,0xfefE83C39cEeE44F799068DCac8755D1D89358D9,0xfefE83C39cEeE44F799068DCac8755D1D89358D9,0xfefE83C39cEeE44F799068DCac8755D1D89358D9,0x8202F1fF3A94e199d970919d8D71Ffb434b6F627,0x29dBC979b45B2F45B8BB41f612f80DCD8B2ef446,0xb7985A153FF4C8fc197b859F6f7979B126Aaa315,0x8202F1fF3A94e199d970919d8D71Ffb434b6F627,0x86c16F44BC75851a9E2E16e28366aDD78169fEA9,0x86c16F44BC75851a9E2E16e28366aDD78169fEA9,0x0a3C464FFD7458C5f4EB09a314A00623327957B8,0x0a3C464FFD7458C5f4EB09a314A00623327957B8,0x0a3C464FFD7458C5f4EB09a314A00623327957B8,0x37b3cE4eE95758e41B0E73EA3088eA9c3FdaCd32,0x06a559acEDE9E7872dE280E6b8545Ff5c01c62ab,0xFACb9eE3931231c4AD49787605d0d8637DC21133,0xFACb9eE3931231c4AD49787605d0d8637DC21133,0xFACb9eE3931231c4AD49787605d0d8637DC21133,0xFACb9eE3931231c4AD49787605d0d8637DC21133,0xFACb9eE3931231c4AD49787605d0d8637DC21133,0xFACb9eE3931231c4AD49787605d0d8637DC21133,0xFACb9eE3931231c4AD49787605d0d8637DC21133,0xFACb9eE3931231c4AD49787605d0d8637DC21133,0xFACb9eE3931231c4AD49787605d0d8637DC21133,0xFACb9eE3931231c4AD49787605d0d8637DC21133,0xAefCDA6b2cF4EcC7A7E07099C79a729a7c8b91f7,0xAefCDA6b2cF4EcC7A7E07099C79a729a7c8b91f7,0xAefCDA6b2cF4EcC7A7E07099C79a729a7c8b91f7,0xAefCDA6b2cF4EcC7A7E07099C79a729a7c8b91f7,0xAefCDA6b2cF4EcC7A7E07099C79a729a7c8b91f7,0xAefCDA6b2cF4EcC7A7E07099C79a729a7c8b91f7,0xAefCDA6b2cF4EcC7A7E07099C79a729a7c8b91f7,0xAefCDA6b2cF4EcC7A7E07099C79a729a7c8b91f7,0xAefCDA6b2cF4EcC7A7E07099C79a729a7c8b91f7,0xAefCDA6b2cF4EcC7A7E07099C79a729a7c8b91f7,0x06a559acEDE9E7872dE280E6b8545Ff5c01c62ab,0x06a559acEDE9E7872dE280E6b8545Ff5c01c62ab,0x06a559acEDE9E7872dE280E6b8545Ff5c01c62ab,0x06a559acEDE9E7872dE280E6b8545Ff5c01c62ab,0x06a559acEDE9E7872dE280E6b8545Ff5c01c62ab,0x06a559acEDE9E7872dE280E6b8545Ff5c01c62ab,0x06a559acEDE9E7872dE280E6b8545Ff5c01c62ab,0x06a559acEDE9E7872dE280E6b8545Ff5c01c62ab,0x06a559acEDE9E7872dE280E6b8545Ff5c01c62ab,0xd17a9B2213A8D32145A3b278e5F7CeF22D670c42,0xd17a9B2213A8D32145A3b278e5F7CeF22D670c42,0xd17a9B2213A8D32145A3b278e5F7CeF22D670c42,0x9643af2a187d93fbE2a95B609382AbDaEBa3Ed86,0x9643af2a187d93fbE2a95B609382AbDaEBa3Ed86,0x9643af2a187d93fbE2a95B609382AbDaEBa3Ed86,0x9643af2a187d93fbE2a95B609382AbDaEBa3Ed86,0x9643af2a187d93fbE2a95B609382AbDaEBa3Ed86,0x9643af2a187d93fbE2a95B609382AbDaEBa3Ed86,0x9643af2a187d93fbE2a95B609382AbDaEBa3Ed86,0x9643af2a187d93fbE2a95B609382AbDaEBa3Ed86,0x9643af2a187d93fbE2a95B609382AbDaEBa3Ed86,0x9643af2a187d93fbE2a95B609382AbDaEBa3Ed86,0x3EA8422E956AFEB32C9D9638F5FB04BAdbe09bc1,0x01aC84081621568230be12b4276b92d07d584433,0x01aC84081621568230be12b4276b92d07d584433,0x01aC84081621568230be12b4276b92d07d584433,0x01aC84081621568230be12b4276b92d07d584433,0x01aC84081621568230be12b4276b92d07d584433,0x01aC84081621568230be12b4276b92d07d584433,0x01aC84081621568230be12b4276b92d07d584433,0x01aC84081621568230be12b4276b92d07d584433,0x01aC84081621568230be12b4276b92d07d584433,0x01aC84081621568230be12b4276b92d07d584433,0x21A9062bB9Dd238e200bd2499F2D9549c8C4cAF5,0x21A9062bB9Dd238e200bd2499F2D9549c8C4cAF5,0xe8a718296Edcd56132A2de6045965dDDA8f7176B,0xD3E570C52Fe8B3AbB7f4dC23D9A26eFb12909EfA,0x210635Cc96b9bb56cc9293979dF460212bc5F113,0x194183e414Bbd0C4074A1d08f392cA998b49c3F3,0x194183e414Bbd0C4074A1d08f392cA998b49c3F3,0x87828a9454d1C8CEB58eAcBCCcE91Bb02c423329,0x87828a9454d1C8CEB58eAcBCCcE91Bb02c423329,0x87828a9454d1C8CEB58eAcBCCcE91Bb02c423329,0x87828a9454d1C8CEB58eAcBCCcE91Bb02c423329,0x87828a9454d1C8CEB58eAcBCCcE91Bb02c423329,0x87828a9454d1C8CEB58eAcBCCcE91Bb02c423329,0x87828a9454d1C8CEB58eAcBCCcE91Bb02c423329,0x87828a9454d1C8CEB58eAcBCCcE91Bb02c423329,0x87828a9454d1C8CEB58eAcBCCcE91Bb02c423329,0x87828a9454d1C8CEB58eAcBCCcE91Bb02c423329,0x1c1BE57d27B7B5a697470F1F6F7DFCF38ee5CABE,0x1c1BE57d27B7B5a697470F1F6F7DFCF38ee5CABE,0x1c1BE57d27B7B5a697470F1F6F7DFCF38ee5CABE,0x1c1BE57d27B7B5a697470F1F6F7DFCF38ee5CABE,0x1c1BE57d27B7B5a697470F1F6F7DFCF38ee5CABE,0x1c1BE57d27B7B5a697470F1F6F7DFCF38ee5CABE,0x1c1BE57d27B7B5a697470F1F6F7DFCF38ee5CABE,0x1c1BE57d27B7B5a697470F1F6F7DFCF38ee5CABE,0x1c1BE57d27B7B5a697470F1F6F7DFCF38ee5CABE,0x1c1BE57d27B7B5a697470F1F6F7DFCF38ee5CABE,0xd0118B21a632615d899b02E8472E9457DD98062C,0xd0118B21a632615d899b02E8472E9457DD98062C,0xd0118B21a632615d899b02E8472E9457DD98062C,0xd0118B21a632615d899b02E8472E9457DD98062C,0xd0118B21a632615d899b02E8472E9457DD98062C,0xd0118B21a632615d899b02E8472E9457DD98062C,0xd0118B21a632615d899b02E8472E9457DD98062C,0xd0118B21a632615d899b02E8472E9457DD98062C,0xd0118B21a632615d899b02E8472E9457DD98062C,0xd0118B21a632615d899b02E8472E9457DD98062C,0xc1deEA95Ed5d402d052FA169dF008Faf54C3F837,0xc1deEA95Ed5d402d052FA169dF008Faf54C3F837,0xc1deEA95Ed5d402d052FA169dF008Faf54C3F837,0x3cbAee4F65B64082FD3a5B0D78638Ee11A29A31A,0x3cbAee4F65B64082FD3a5B0D78638Ee11A29A31A,0x3cbAee4F65B64082FD3a5B0D78638Ee11A29A31A,0x3cbAee4F65B64082FD3a5B0D78638Ee11A29A31A,0x3cbAee4F65B64082FD3a5B0D78638Ee11A29A31A];
        for(uint i=0;i<198;i++){
            lot0.indexedTickets[lot0.tickets[i]].push(i);
        }
        lot0.counter = Counters.Counter(198);
        
        Lottery storage lot1 = lotteries.push();
        lot1.spaceId = 0;
        lot1.creator = 0x830732Ee350fBaB3A7C322a695f47dc26778F60d;
        lot1.tokenAddr = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        lot1.pool = 1000000000000000000000;
        lot1.maxTickets = 1;
        lot1.winners = 0;
        lot1.start = 1670059244;
        lot1.end = 1671580800;
        lot1.requireSig = true;
        lot1.tickets = [0x3cbAee4F65B64082FD3a5B0D78638Ee11A29A31A,0xCE67B694bC268E7D9431e658A149657d46F80387,0x04a7CD054708F6D3a45994B957bE91ac9e34A687,0x37b3cE4eE95758e41B0E73EA3088eA9c3FdaCd32,0x24e972604cAF279f0aD9e4AbA677fA90c806b310,0x32573ec9734A1054cd0E35F0e28314e688089138,0x29dBC979b45B2F45B8BB41f612f80DCD8B2ef446,0xD3E570C52Fe8B3AbB7f4dC23D9A26eFb12909EfA,0xcf854C64d51FAcb63E052a1D2286Bb072D14913f,0x755309E7A48B97c9a2Ba87661A75B26df8431Ec2,0x21A9062bB9Dd238e200bd2499F2D9549c8C4cAF5,0x86c16F44BC75851a9E2E16e28366aDD78169fEA9,0x06a559acEDE9E7872dE280E6b8545Ff5c01c62ab,0x0a3C464FFD7458C5f4EB09a314A00623327957B8,0xeFF1105c656e72903Da56B004e89aC0F19b35c20,0x112D960C88de18482C5f4069c0286a5a57Bab086,0x46c2e6EFCeb9B4D7F92e300B8E0580D1943CE29B,0xd0118B21a632615d899b02E8472E9457DD98062C,0x01aC84081621568230be12b4276b92d07d584433,0xfefE83C39cEeE44F799068DCac8755D1D89358D9,0xFACb9eE3931231c4AD49787605d0d8637DC21133,0xAefCDA6b2cF4EcC7A7E07099C79a729a7c8b91f7,0x72D6960AAe3C90e2de304f6fb89263a7FCca14bB,0xDF55bBE2e152E55644C531eCf8697752BcCdb0C0,0x11217Bf4Da72c7b4425a83B4736699eEc7444Ec3,0xd438c8A16ec89a6492D6753f0C2735668e1db5Da,0xC81082690EDC8CDE6D83a7549aa6a74534305372,0xc1deEA95Ed5d402d052FA169dF008Faf54C3F837,0xd17a9B2213A8D32145A3b278e5F7CeF22D670c42,0x5dAb66Cddb79771Ae34F4EaaccBFe1898793d50f,0x5C36436eb678cEbBF2f77Aa52F8310141931D984,0xe078E67186C734CB06DC661Bc32A29F2E4626794,0x3D6db46E3A98F1D996aeAc9bbfBa570D0a60b4F7,0x9643af2a187d93fbE2a95B609382AbDaEBa3Ed86,0x28B07D5bf8c8205b0bF064A5dF5F24bB3B182879,0x87828a9454d1C8CEB58eAcBCCcE91Bb02c423329,0xd31A84c20bc430aD75E6a1903E7dDbee52211072,0x3EA8422E956AFEB32C9D9638F5FB04BAdbe09bc1,0x194183e414Bbd0C4074A1d08f392cA998b49c3F3,0x83a27BE9bc9c98A6Cd504570B4fa1899ae09F95f,0xDCFF316Bcda6674672e6C21A32496Ac61D3B12a0,0xe8a718296Edcd56132A2de6045965dDDA8f7176B,0x6c0cafe6165D1A37659B6f9728dE30969C35cbF2,0x96539455E49b8DE5738f85C2347cf7955775f502,0x102da0207BA3e1b18FcC826Fde188a133e0d27d4,0x8202F1fF3A94e199d970919d8D71Ffb434b6F627];
        for(uint i=0;i<45;i++){
            lot1.indexedTickets[lot1.tickets[i]].push(i);
        }
        lot1.counter = Counters.Counter(45);
        
        Lottery storage lot2 = lotteries.push();
        lot2.spaceId = 0;
        lot2.creator = 0x830732Ee350fBaB3A7C322a695f47dc26778F60d;
        lot2.tokenAddr = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        lot2.pool = 2000000000000000000000;
        lot2.maxTickets = 1;
        lot2.winners = 0;
        lot2.start = 1670059244;
        lot2.end = 1671580800;
        lot2.requireSig = true;
        lot2.tickets = [0x3cbAee4F65B64082FD3a5B0D78638Ee11A29A31A,0xd0118B21a632615d899b02E8472E9457DD98062C,0xCE67B694bC268E7D9431e658A149657d46F80387,0x06a559acEDE9E7872dE280E6b8545Ff5c01c62ab,0x3D6db46E3A98F1D996aeAc9bbfBa570D0a60b4F7,0xd31A84c20bc430aD75E6a1903E7dDbee52211072,0x01aC84081621568230be12b4276b92d07d584433,0x04a7CD054708F6D3a45994B957bE91ac9e34A687,0x83a27BE9bc9c98A6Cd504570B4fa1899ae09F95f,0xD3E570C52Fe8B3AbB7f4dC23D9A26eFb12909EfA,0xcf854C64d51FAcb63E052a1D2286Bb072D14913f,0x46c2e6EFCeb9B4D7F92e300B8E0580D1943CE29B,0x755309E7A48B97c9a2Ba87661A75B26df8431Ec2,0xDF55bBE2e152E55644C531eCf8697752BcCdb0C0];
        for(uint i=0;i<14;i++){
            lot2.indexedTickets[lot2.tickets[i]].push(i);
        }
        lot2.counter = Counters.Counter(14);
    }

    function create(
        uint spaceId,
        address tokenAddr,
        uint256 maxTickets,
        uint256 ticketPrice,
        uint256[] memory winnerRatios,
        uint32 winners,
        uint256 start,
        uint256 end,
        bool requireSig
    ) public {
        require(end > start && end > block.timestamp, "invalid time");
        require(maxTickets > 0, "invalid maxTickets");
        require(winnerRatios.length == winners, "invalid winners");
        if (tokenAddr != address(0)) {
            IERC20 token = IERC20(tokenAddr);
            require(token.totalSupply() > 0, "invalid token");
        }else{
            require(ticketPrice == 0, "invalid token");
        }

        uint256 ratioSum;
        for (uint256 i = 0; i < winners; i++) {
            ratioSum += winnerRatios[i];
        }
        require(ratioSum <= 100, "invalid ratio");

        Lottery storage lot = lotteries.push();
        lot.spaceId = spaceId;
        lot.creator = msg.sender;
        lot.tokenAddr = tokenAddr;
        lot.maxTickets = maxTickets;
        lot.ticketPrice = ticketPrice;
        lot.winnerRatios = winnerRatios;
        lot.winners = winners;
        lot.start = start;
        lot.end = end;
        lot.requireSig = requireSig;

        emit CreateLottery(lotteries.length - 1);
    }

    function fund(uint256 lotId, uint256 amount) public {
        Lottery storage lot = lotteries[lotId];
        require(lot.end > block.timestamp, "invalid time");
        require(lot.tokenAddr != address(0), "invalid token");
        IERC20 token = IERC20(lot.tokenAddr);
        token.transferFrom(msg.sender, address(this), amount);
        lot.pool += amount;

        emit Fund(lotId, amount);
    }

    function join(uint256 lotId, uint256 quantity, bytes memory sig) public {
        Lottery storage lot = lotteries[lotId];
        require(
            lot.start <= block.timestamp && lot.end > block.timestamp,
            "invalid time"
        );
        if(lot.requireSig){
            bytes32 message = keccak256(abi.encodePacked(lotId, msg.sender));
            require(spaceRegistration.verifySignature(lot.spaceId, message, sig), "Sig invalid");
        }

        uint256 currentLen = lot.indexedTickets[msg.sender].length;
        require(
            quantity > 0 && currentLen + quantity <= lot.maxTickets,
            "invalid quantity"
        );

        if(lot.tokenAddr != address(0) && lot.ticketPrice > 0){
            uint256 totalPrice = quantity * lot.ticketPrice;
            IERC20 token = IERC20(lot.tokenAddr);
            token.transferFrom(msg.sender, address(this), totalPrice);
            lot.pool += totalPrice;
            emit Fund(lotId, totalPrice);
        }
        
        uint256[] memory buff = new uint256[](currentLen + quantity);
        // copy current tickets
        for (uint256 i = 0; i < currentLen; i++) {
            buff[i] = lot.indexedTickets[msg.sender][i];
        }
        // add new purchased tickets
        for (uint256 i = 0; i < quantity; i++) {
            buff[currentLen + i] = lot.counter.current();
            lot.tickets.push(msg.sender);
            lot.counter.increment();
        }

        lot.indexedTickets[msg.sender] = buff;
        emit Join(lotId, msg.sender, quantity);
    }

    function draw(uint256 lotId) public {
        Lottery storage lot = lotteries[lotId];
        require(block.timestamp > lot.end, "not available");
        require(lot.vrfRequestId == 0, "drawed");

        lot.vrfRequestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            lot.winners
        );

        s_requests[lot.vrfRequestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false,
            lotId: lotId
        });
        emit RequestSent(lotId);
    }

    function getWinners(uint256 lotId)
        public
        view
        returns (address[] memory result)
    {
        Lottery storage lot = lotteries[lotId];
        if(lot.winners==0){
            return result;
        }
        RequestStatus storage randomRequest = s_requests[lot.vrfRequestId];
        require(randomRequest.fulfilled, "no result");
        result = new address[](lot.winners);
        uint256 currentLen = lot.counter.current();
        for (uint256 i = 0; i < lot.winners; i++) {
            uint256 index = randomRequest.randomWords[i] % currentLen;
            for (uint256 j = 0; j < i; j++) {
                uint256[] storage indexedTickets = lot.indexedTickets[
                    result[j]
                ];
                for (
                    uint256 k = 0;
                    k < indexedTickets.length && indexedTickets[k] <= index;
                    k++
                ) {
                    ++index;
                }
            }

            result[i] = lot.tickets[index];
            currentLen -= lot.indexedTickets[result[i]].length;
        }

        return result;
    }

    function prize(uint256 lotId) public view returns (uint256) {
        Lottery storage lot = lotteries[lotId];
        if (lot.indexedTickets[msg.sender].length == 0 || lot.tokenAddr == address(0) || lot.pool == 0) return 0;
        address[] memory winners = getWinners(lotId);
        uint256 winnerPrizes;
        uint256 winnerTickets;
        for (uint256 i = 0; i < winners.length; i++) {
            if (msg.sender == winners[i]) {
                /**
                * if winner => return
                */
                return (lot.pool * lot.winnerRatios[i]) / 100;
            } else {
                winnerTickets += lot.indexedTickets[winners[i]].length;
                winnerPrizes += (lot.pool * lot.winnerRatios[i]) / 100;
            }
        }
        return
            ((lot.pool - winnerPrizes) *
                lot.indexedTickets[msg.sender].length) /
            (lot.tickets.length - winnerTickets);
    }

    function claim(uint256 lotId) public nonReentrant {
        Lottery storage lot = lotteries[lotId];
        require(
            lot.indexedTickets[msg.sender].length > 0 &&
                !lot.claimedAddrs[msg.sender],
            "invalid user"
        );

        uint256 prizeVal = prize(lotId);
        require(prizeVal > 0 && lot.pool - lot.claimed > prizeVal, "not claimable");

        IERC20 token = IERC20(lot.tokenAddr);
        token.transfer(msg.sender, prizeVal);
        lot.claimed += prizeVal;
        lot.claimedAddrs[msg.sender] = true;

        emit Claimed(lotId, msg.sender);
    }

    function withdraw(uint256 lotId) public onlyOwner {
        Lottery storage lot = lotteries[lotId];
        require(lot.pool - lot.claimed > 0 , "dry");
        require(block.timestamp > lot.end + life || lot.tokenAddr == address(0) , "not available");
        IERC20 token = IERC20(lot.tokenAddr);
        token.transfer(msg.sender, lot.pool - lot.claimed);
        lot.claimed = lot.pool;
    }
    
    function setLife(uint256 _life) external onlyOwner {
        life = (_life);
    }

    function setKeyHash(bytes32 _keyHash) public onlyOwner{
        keyHash = _keyHash;
    }

    function setSpaceRegistration(address addr) public onlyOwner{
        spaceRegistration = ISpaceRegistration(addr);
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        require(!s_requests[_requestId].fulfilled, "fulfilled");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(s_requests[_requestId].lotId, _randomWords);
    }

    function getRequestStatus(uint256 _requestId)
        external
        view
        returns (bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    function tickets(
        uint256 lotId,
        uint256 cursor,
        uint256 length
    ) public view returns (address[] memory) {
        Lottery storage lot = lotteries[lotId];
        require(cursor + length <= lot.counter.current(), "invalid len");

        address[] memory res = new address[](length);
        for (uint256 i = cursor; i < cursor + length; i++) {
            res[i] = lot.tickets[i];
        }
        return res;
    }

    function ticketsByUser(uint256 lotId, address addr)
        public
        view
        returns (uint256[] memory)
    {
        return lotteries[lotId].indexedTickets[addr];
    }

    function lottery(uint256 lotId)
        public
        view
        returns (
            uint spaceId,
            address tokenAddr,
            uint256 pool,
            uint256 maxTickets,
            uint256 ticketPrice,
            uint256[] memory winnerRatio,
            uint256 vrfRequestId,
            uint256 start,
            uint256 end,
            uint256 totalTickets,
            uint256 claimed,
            bool requireSig
        )
    {
        Lottery storage lot = lotteries[lotId];
        RequestStatus storage randomRequest = s_requests[lot.vrfRequestId];
        return (
            lot.spaceId,
            lot.tokenAddr,
            lot.pool,
            lot.maxTickets,
            lot.ticketPrice,
            lot.winnerRatios,
            lot.vrfRequestId,
            lot.start,
            lot.end,
            lot.counter.current(),
            lot.claimed,
            lot.requireSig
        );
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ISpaceRegistration {

    struct SpaceParam{
        string name;
        string logo;
    }

    function spaceParam(uint id) view external returns(SpaceParam memory);

    function checkMerkle(uint id, bytes32 root, bytes32 leaf, bytes32[] calldata _merkleProof) external view returns (bool);

    function verifySignature(uint id, bytes32 message, bytes calldata signature) view external returns(bool);

    function isAdmin(uint id, address addr) view external returns(bool);

    function isCreator(uint id, address addr) view external returns(bool);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
library Counters {
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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ConfirmedOwnerWithProposal.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/OwnableInterface.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is OwnableInterface {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() public view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}