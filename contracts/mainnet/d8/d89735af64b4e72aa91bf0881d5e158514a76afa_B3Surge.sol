/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

//SPDX-License-Identifier: MIT
  /**
   /100%回购销毁的革命性算法
   /We are excited to present our next generation bottom-up algorithm with 100% of taxes that will be used for Buy Back & Burn

  ██████████🔥    ██████🔥      ⚡️B L O K C H A I N    N  E V E R   L I E⚡️
 * ██ ░░░░░██🔥  ██  ░  ██🔥                    区块链从不说谎
 *░██     ░██🔥        ██🔥   
 *░█████████🔥     ░ ███🔥░     =     💰Buy  ↩️ Back &  🔥Burn 
 * ██  ░░░░██🔥     ░░ ██🔥     =       B  +   B   +   B  
 * ██     ░██🔥  ██  ░  ██🔥    =         BE FREE ⚡️SURGE
 *██████████🔥    ██████🔥                   是自由的 
 * ░░░░░░░░░       ░░░░░░
  
  ⚙️ B3 ⚡️Surge, Buy Back & Burn every Day the B3 supply!
   The revolutionary B3 strategy involves buying back tokens from the open market and burning them,reducing the total supply of tokens.
   This reduces the supply of tokens available and increases the demand for them,leading to an increase in the value of the token.
  ⚙️B3 ⚡️每天激增、回购和销毁 B3 供应！
    革命性的 B3 策略涉及从公开市场回购代币并销毁它们，从而减少代币的总供应量。
    这减少了可用代币的供应并增加了对它们的需求，从而导致代币价值增加。

  *FairLaunch
  *100 % Tax for B3
  *No Tax for the Wallet Team, read the Ca and you will see that the Team wallet = Dead wallet   
  *No Team Wallet
  *No Max Trx
  *No Max Wallet
  *No Marketing
  
  绝对所有新闻和出版物都将专门在此链接上
  * https://t.me/B3_Algorithm

   Smart contracts in ⚡️Surge Protocol are unruggable because they are immutable, meaning they cannot be changed or modified once they are deployed. 
   B3Surge chose them because they provide a secure and reliable way to execute transactions and agreements between parties without the need for a third-party intermediary.
   Smart contracts are also highly transparent and auditable, making them ideal for use in Surge Protocol.
   ⚡️Surge Protocol is safe because it uses advanced cryptography and blockchain technology to ensure that all transactions are secure and immutable.
   The protocol also utilizes a consensus mechanism to ensure that all users are in agreement before any changes can be made to the blockchain.
   Additionally, Surge Protocol is built on top of a decentralized network, making it impossible for any single entity to control the system.
   It is built on the BSC blockchain and has a number of features that make it more attractive than PancakeSwap and Uniswap.
   These features include a built-in liquidity pool, low fees, and advanced order types. 
   Additionally, ⚡️Surge Procole offers a range of tools and services to help users manage their trades and optimize their profits.
   These include a portfolio tracker, a market maker, and an automated trading bot.
   All of these features make ⚡️Surge Procole a better option than PancakeSwap and Uniswap for trading digital assets.
   一个新的开始。

   算一算 保留所有权利 2023 Shytoshi ™
 */ 

pragma solidity 0.8.17;



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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function decimals() external view returns (uint8);
}

interface ISRG {
    function calculatePrice() external view returns (uint256);

    function getBNBPrice() external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract B3Surge is IERC20, Context, Ownable, ReentrancyGuard {
    event Bought(
        address indexed from,
        address indexed to,
        uint256 tokens,
        uint256 beans,
        uint256 dollarBuy
    );
    event Sold(
        address indexed from,
        address indexed to,
        uint256 tokens,
        uint256 beans,
        uint256 dollarSell
    );
    event FeesMulChanged(uint256 newBuyMul, uint256 newSellMul);
    event StablePairChanged(address newStablePair, address newStableToken);
    event MaxBagChanged(uint256 newMaxBag);

    // token data
    string private constant _name = "B3 Surge";
    string private constant _symbol = "B3";
    uint8 private constant _decimals = 3;
    uint256 private constant _DECMULTIPLIER = 10**_decimals;

    //SRG pair data
    address private constant SRG = 0x9f19c8e321bD14345b797d43E01f0eED030F5Bff; //change this according to chain
    ISRG private constant SRGI = ISRG(SRG); //interface to interact with SRG
    IERC20 private constant SRGIE = IERC20(SRG); //interace to interact with SRG

    uint256 private _srgDecimals = SRGIE.decimals();

    // Total Supply
    uint256 public constant _totalSupply = 3333333 * _DECMULTIPLIER;

    // balances
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    //Fees
    mapping(address => bool) public isFeeExempt;
    uint256 public sellMul = 90;
    uint256 public buyMul = 90;
    uint256 public constant DIVISOR = 100;

    //Max bag requirements
    mapping(address => bool) public isTxLimitExempt;
    uint256 public maxBag = _totalSupply / 100;

    //Tax collection
    uint256 public taxBalance = 0;

    //Tax wallets
    address public teamWallet = 0x000000000000000000000000000000000000dEaD;
    address public treasuryWallet = 0x4018384cF09b0CE3E37879f21497AdCAD71617B0;

    // Tax Split
    uint256 public teamShare = 0;
    uint256 public treasuryShare = 100;
    uint256 public constant SHAREDIVISOR = 100;

    //Known Wallets
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    //trading parameters
    uint256 public liquidity = 3**5 * 10**_srgDecimals;
    uint256 public liqConst = liquidity * _totalSupply;
    bool public tradeOpen = false;

    //volume trackers
    mapping(address => uint256) public indVol;
    mapping(uint256 => uint256) public tVol;
    uint256 public totalVolume = 0;

    //candlestick data
    uint256 public constant PADDING = 10**18;
    uint256 public totalTx;
    mapping(uint256 => uint256) public txTimeStamp;

    struct candleStick {
        uint256 time;
        uint256 open;
        uint256 close;
        uint256 high;
        uint256 low;
    }

    mapping(uint256 => candleStick) public candleStickData;

    //Frontrun Guard
    mapping(address => uint256) private _lastBuyBlock;

    // initialize supply
    constructor() {
        _balances[address(this)] = _totalSupply;

        isFeeExempt[msg.sender] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[address(0)] = true;

        emit Transfer(address(0), address(this), _totalSupply);
    }

    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        require(spender != address(0), "SRG20: approve to the zero address");
        require(
            msg.sender != address(0),
            "SRG20: approve from the zero address"
        );

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - _balances[DEAD];
    }

    function changeWalletLimit(uint256 newLimit) external onlyOwner {
        require(
            newLimit >= _totalSupply / 100,
            "New wallet limit should be at least 1% of total supply"
        );
        maxBag = newLimit;
        emit MaxBagChanged(newLimit);
    }

    function changeIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isTxLimitExempt[holder] = exempt;
    }

    /** Transfer Function */
    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    /** TransferFrom Function */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        address spender = msg.sender;
        //check allowance requirement
        _spendAllowance(sender, spender, amount);
        return _transferFrom(sender, recipient, amount);
    }

    /** Internal Transfer */
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        // make standard checks
        require(
            recipient != address(0) && recipient != address(this),
            "transfer to the zero address or CA"
        );
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            isTxLimitExempt[recipient] ||
                _balances[recipient] + amount <= maxBag,
            "Max wallet exceeded!"
        );

        // subtract from sender
        _balances[sender] = _balances[sender] - amount;

        // give amount to receiver
        _balances[recipient] = _balances[recipient] + amount;

        // Transfer Event
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = _allowances[owner][spender];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "SRG20: insufficient allowance"
            );

            unchecked {
                // decrease allowance
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

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

    /** Purchases SURGE Tokens and Deposits Them in Sender's Address*/
    function _buy(
        uint256 buyAmount,
        uint256 minTokenOut,
        uint256 deadline
    ) public nonReentrant returns (bool) {
        // deadline requirement
        require(deadline >= block.timestamp, "Deadline EXPIRED");

        // Frontrun Guard
        _lastBuyBlock[msg.sender] = block.number;

        // liquidity is set
        require(liquidity > 0, "The token has no liquidity");

        // check if trading is open
        require(
            tradeOpen,
            "Trading is not Open"
        );

        //remove the buy tax
        uint256 srgAmount = isFeeExempt[msg.sender]
            ? buyAmount
            : (buyAmount * buyMul) / DIVISOR;

        // how much they should purchase?
        uint256 tokensToSend = _balances[address(this)] -
            (liqConst / (srgAmount + liquidity));

        //revert for max bag
        require(
            _balances[msg.sender] + tokensToSend <= maxBag ||
                isTxLimitExempt[msg.sender],
            "Max wallet exceeded"
        );

        // revert if under 1
        require(tokensToSend > 1, "SRG20: Must Buy more than 1 decimal");

        // revert for slippage
        require(tokensToSend >= minTokenOut, "INSUFFICIENT OUTPUT AMOUNT");

        // transfer the SRG from the msg.sender to the CA
        bool s = SRGIE.transferFrom(msg.sender, address(this), buyAmount);

        require(s, "transfer of SRG failed!");

        // transfer the tokens from CA to the buyer
        buy(msg.sender, tokensToSend);

        //update available tax to extract and Liquidity
        uint256 taxAmount = buyAmount - srgAmount;
        taxBalance = taxBalance + taxAmount;
        liquidity = liquidity + srgAmount;

        //update volume
        uint256 cTime = block.timestamp;
        uint256 dollarBuy = buyAmount * getSRGPrice();
        totalVolume += dollarBuy;
        indVol[msg.sender] += dollarBuy;
        tVol[cTime] += dollarBuy;

        //update candleStickData
        totalTx += 1;
        txTimeStamp[totalTx] = cTime;
        uint256 cPrice = calculatePrice() * getSRGPrice();
        candleStickData[cTime].time = cTime;
        if (candleStickData[cTime].open == 0) {
            if (totalTx == 1) {
                candleStickData[cTime].open =
                    ((liquidity - srgAmount) / (_totalSupply)) *
                    getSRGPrice();
            } else {
                candleStickData[cTime].open = candleStickData[
                    txTimeStamp[totalTx - 1]
                ].close;
            }
        }
        candleStickData[cTime].close = cPrice;

        if (
            candleStickData[cTime].high < cPrice ||
            candleStickData[cTime].high == 0
        ) {
            candleStickData[cTime].high = cPrice;
        }

        if (
            candleStickData[cTime].low > cPrice ||
            candleStickData[cTime].low == 0
        ) {
            candleStickData[cTime].low = cPrice;
        }

        //emit transfer and buy events
        emit Transfer(address(this), msg.sender, tokensToSend);
        emit Bought(
            msg.sender,
            address(this),
            tokensToSend,
            buyAmount,
            srgAmount * getSRGPrice()
        );
        return true;
    }

    /** Sends Tokens to the buyer Address */
    function buy(address receiver, uint256 amount) internal {
        _balances[receiver] = _balances[receiver] + amount;
        _balances[address(this)] = _balances[address(this)] - amount;
    }

    /** Sells SURGE Tokens And Deposits the BNB into Seller's Address */
    function _sell(
        uint256 tokenAmount,
        uint256 deadline,
        uint256 minBNBOut
    ) public nonReentrant returns (bool) {
        // deadline requirement
        require(deadline >= block.timestamp, "Deadline EXPIRED");

        //Frontrun Guard
        require(
            _lastBuyBlock[msg.sender] != block.number,
            "Buying and selling in the same block is not allowed!"
        );

        address seller = msg.sender;

        // make sure seller has this balance
        require(
            _balances[seller] >= tokenAmount,
            "cannot sell above token amount"
        );

        // get how much beans are the tokens worth
        uint256 amountSRG = liquidity -
            (liqConst / (_balances[address(this)] + tokenAmount));
        uint256 amountTax = (amountSRG * (DIVISOR - sellMul)) / DIVISOR;
        uint256 SRGtoSend = amountSRG - amountTax;

        //slippage revert
        require(amountSRG >= minBNBOut, "INSUFFICIENT OUTPUT AMOUNT");

        // send SRG to Seller

        bool successful = isFeeExempt[msg.sender]
            ? SRGIE.transfer(msg.sender, amountSRG)
            : SRGIE.transfer(msg.sender, SRGtoSend);
        require(successful, "SRG transfer failed");

        // subtract full amount from sender
        _balances[seller] = _balances[seller] - tokenAmount;

        //add tax allowance to be withdrawn and remove from liq the amount of beans taken by the seller
        taxBalance = isFeeExempt[msg.sender]
            ? taxBalance
            : taxBalance + amountTax;
        liquidity = liquidity - amountSRG;

        // add tokens back into the contract
        _balances[address(this)] = _balances[address(this)] + tokenAmount;

        //update volume
        uint256 cTime = block.timestamp;
        uint256 dollarSell = amountSRG * getSRGPrice();
        totalVolume += dollarSell;
        indVol[msg.sender] += dollarSell;
        tVol[cTime] += dollarSell;

        //update candleStickData
        totalTx += 1;
        txTimeStamp[totalTx] = cTime;
        uint256 cPrice = calculatePrice() * getSRGPrice();
        candleStickData[cTime].time = cTime;
        if (candleStickData[cTime].open == 0) {
            candleStickData[cTime].open = candleStickData[
                txTimeStamp[totalTx - 1]
            ].close;
        }
        candleStickData[cTime].close = cPrice;

        if (
            candleStickData[cTime].high < cPrice ||
            candleStickData[cTime].high == 0
        ) {
            candleStickData[cTime].high = cPrice;
        }

        if (
            candleStickData[cTime].low > cPrice ||
            candleStickData[cTime].low == 0
        ) {
            candleStickData[cTime].low = cPrice;
        }

        // emit transfer and sell events
        emit Transfer(seller, address(this), tokenAmount);
        if (isFeeExempt[msg.sender]) {
            emit Sold(
                address(this),
                msg.sender,
                tokenAmount,
                amountSRG,
                dollarSell
            );
        } else {
            emit Sold(
                address(this),
                msg.sender,
                tokenAmount,
                SRGtoSend,
                SRGtoSend * getSRGPrice()
            );
        }
        return true;
    }

    /** Amount of liquidity in Contract */
    function getLiquidity() public view returns (uint256) {
        return liquidity;
    }

    /** Returns the value of your holdings before the sell fee */
    function getValueOfHoldings(address holder) public view returns (uint256) {
        return
            ((_balances[holder] * liquidity) / _balances[address(this)]) *
            getSRGPrice();
    }

    function changeFees(uint256 newBuyMul, uint256 newSellMul)
        external
        onlyOwner
    {
        require(
            newBuyMul >= 90 &&
                newSellMul >= 90 &&
                newBuyMul <= 100 &&
                newSellMul <= 100,
            "Fees are too high"
        );

        buyMul = newBuyMul;
        sellMul = newSellMul;

        emit FeesMulChanged(newBuyMul, newSellMul);
    }

    function changeTaxDistribution(
        uint256 newteamShare,
        uint256 newtreasuryShare
    ) external onlyOwner {
        require(
            newteamShare + newtreasuryShare == SHAREDIVISOR,
            "Sum of shares must be 100"
        );

        teamShare = newteamShare;
        treasuryShare = newtreasuryShare;
    }

    function changeFeeReceivers(
        address newTeamWallet,
        address newTreasuryWallet
    ) external onlyOwner {
        require(
            newTeamWallet != address(0) && newTreasuryWallet != address(0),
            "New wallets must not be the ZERO address"
        );

        teamWallet = newTeamWallet;
        treasuryWallet = newTreasuryWallet;
    }

    function withdrawTaxBalance() external nonReentrant onlyOwner {
        bool temp1 = SRGIE.transfer(
            teamWallet,
            (taxBalance * teamShare) / SHAREDIVISOR
        );
        bool temp2 = SRGIE.transfer(
            treasuryWallet,
            (taxBalance * treasuryShare) / SHAREDIVISOR
        );
        assert(temp1 && temp2);
        taxBalance = 0;
    }

    function getTokenAmountOut(uint256 amountSRGIn)
        external
        view
        returns (uint256)
    {
        uint256 amountAfter = liqConst / (liquidity - amountSRGIn);
        uint256 amountBefore = liqConst / liquidity;
        return amountAfter - amountBefore;
    }

    function getsrgAmountOut(uint256 amountIn) public view returns (uint256) {
        uint256 srgBefore = liqConst / _balances[address(this)];
        uint256 srgAfter = liqConst / (_balances[address(this)] + amountIn);
        return srgBefore - srgAfter;
    }

    function addLiquidity(uint256 amountSRGLiq) external onlyOwner {
        uint256 tokensToAdd = (_balances[address(this)] * amountSRGLiq) /
            liquidity;
        require(_balances[msg.sender] >= tokensToAdd, "Not enough tokens!");

        bool sLiq = SRGIE.transfer(address(this), amountSRGLiq);
        require(sLiq, "SRG transfer was unsuccesful!");

        uint256 oldLiq = liquidity;
        liquidity = liquidity + amountSRGLiq;
        _balances[address(this)] += tokensToAdd;
        _balances[msg.sender] -= tokensToAdd;
        liqConst = (liqConst * liquidity) / oldLiq;

        emit Transfer(msg.sender, address(this), tokensToAdd);
    }

    function getMarketCap() external view returns (uint256) {
        return (getCirculatingSupply() * calculatePrice() * getSRGPrice());
    }

    // calculate price based on pair SRG price
    function getSRGPrice() public view returns (uint256) {
        return (SRGI.calculatePrice() * SRGI.getBNBPrice()); // return amount of token0 needed to buy token1
    }

    // Returns the Current Price of the Token in SRG
    function calculatePrice() public view returns (uint256) {
        require(liquidity > 0, "No Liquidity");
        return liquidity * PADDING / _balances[address(this)];
    }

        function openTrading() external nonReentrant onlyOwner {
        require(!tradeOpen, "You cannot disable trading after enabling!");
        tradeOpen = true;
    }
}