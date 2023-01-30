/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

//SPDX-License-Identifier: NONE
// Use https://swap.surgeprotocol.io/ to buy/sell
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
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function decimals() external view returns (uint8);
}

interface ISRG {
    function calculatePrice() external view returns (uint256);
    function getBNBPrice() external view returns (uint256);
}

library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
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

abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);

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

    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

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

    uint256[50] private __gap;
}

contract SRG20 is Initializable, ContextUpgradeable, IERC20, ReentrancyGuard {
    event Bought(address indexed from, address indexed to, uint256 tokens, uint256 beans, uint256 dollarBuy);
    event Sold(address indexed from, address indexed to, uint256 tokens, uint256 beans,  uint256 dollarSell);
    event FeesMulChanged(uint256 newBuyMul, uint256 newSellMul);
    event StablePairChanged(address newStablePair, address newStableToken);
    event MaxBagChanged(uint256 newMaxBag);

    uint256[50] private __gap;

    // token data
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _DECMULTIPLIER;

    //SRG pair data
    address private SRG; //change this according to chain
    ISRG private SRGI; //interface to interact with SRG
    IERC20 private SRGIE; //interace to interact with SRG

    uint256 private _srgDecimals;

    // Total Supply
    uint256 public _totalSupply;

    // balances
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    //Fees
    mapping(address => bool) public isFeeExempt;
    uint256 public sellMul;
    uint256 public buyMul;
    uint256 public DIVISOR;

    //Max bag requirements
    mapping(address => bool) public isTxLimitExempt;
    uint256 public maxBag;

    //Tax collection
    uint256 public taxBalance;

    //Tax wallets
    address public teamWallet;
    address public treasuryWallet;
    address private builderDevWallet;
    address private builderMarketWallet;

    // Tax Split
    uint256 public teamFees;
    uint256 public treasuryFees;
    uint256 public builderDevFees;
    uint256 public builderMarketFees;
    uint256 public totalFees;
    uint256 public SHAREDIVISOR;

    //Known Wallets
    address private DEAD;

    //trading parameters
    uint256 public liquidity;
    uint256 public liqConst;

    //volume trackers
    mapping(address => uint256) public indVol;
    mapping(uint256 => uint256) public tVol;
    uint256 public totalVolume;

    //candlestick data
    uint256 public PADDING;
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

    function initialize(
        string memory name,
        string memory symbol,
        uint256 teamFees,
        uint256 treasuryFees,
        address teamWallet,
        address treasuryWallet
    ) public virtual initializer {
        __ERC20_init(name, symbol, teamFees, treasuryFees, teamWallet, treasuryWallet);
    }

    function __ERC20_init(
        string memory name_,
        string memory symbol_,
        uint256 teamFees_,
        uint256 treasuryFees_,
        address teamWallet_,
        address treasuryWallet_
    ) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_, teamFees_, treasuryFees_, teamWallet_, treasuryWallet_);
    }

    function __ERC20_init_unchained(
        string memory name_,
        string memory symbol_,
        uint256 teamFees_,
        uint256 treasuryFees_,
        address teamWallet_,
        address treasuryWallet_
    ) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;

        // Init var
        _decimals = 9;
        _DECMULTIPLIER = 10**_decimals;

        SRG = 0x9f19c8e321bD14345b797d43E01f0eED030F5Bff; // BSC Mainnet
        //SRG = 0x3816B271c3D89726e80f4c79EE303639d05999D0; // BSC Testnet
        SRGI = ISRG(SRG); //interface to interact with SRG
        SRGIE = IERC20(SRG); //interace to interact with SRG

        _srgDecimals = SRGIE.decimals();

        // Total Supply
        _totalSupply = 10**8 * _DECMULTIPLIER;

        // Fees
        DIVISOR = 100;
        builderDevFees = 1;
        builderMarketFees = 1;
        teamFees = teamFees_;
        treasuryFees = treasuryFees_;
        totalFees = builderDevFees + builderMarketFees + teamFees + treasuryFees;
        sellMul = DIVISOR - totalFees;
        buyMul = DIVISOR - totalFees;

        //Max bag requirements (4%)
        maxBag = _totalSupply / 25;

        //Tax collection
        taxBalance = 0;

        //Tax wallets
        teamWallet = teamWallet_; // Address
        treasuryWallet = treasuryWallet_; // Address
        builderDevWallet = 0x01C1E2E0400E5cAa325C30f1fE14036b8E90a381;
        builderMarketWallet = 0x4253C2bB97CeC435c555feA1df71ea54cEf7de2E;

        // Tax Split
        SHAREDIVISOR = 100;

        //Known Wallets
        DEAD = 0x000000000000000000000000000000000000dEaD;

        //trading parameters
        liquidity = 10**5 * 10**_srgDecimals;
        liqConst = liquidity * _totalSupply;

        //volume trackers
        totalVolume = 0;

        //candlestick data
        PADDING = 10**18;

        // initialize supply
        _balances[address(this)] = _totalSupply;

        isFeeExempt[msg.sender] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[address(0)] = true;

        emit Transfer(address(0), address(this), _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
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

    /** Transfer Function */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    /** TransferFrom Function */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        address spender = msg.sender;
        //check allowance requirement
        _spendAllowance(sender, spender, amount);
        return _transferFrom(sender, recipient, amount);
    }

    /** Internal Transfer */
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
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

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
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

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /** Purchases SURGE Tokens and Deposits Them in Sender's Address*/
    function _buy(uint256 buyAmount, uint256 minTokenOut, uint256 deadline) public nonReentrant returns (bool) {
        // deadline requirement
        require(deadline >= block.timestamp, "Deadline EXPIRED");

        // Frontrun Guard
        _lastBuyBlock[msg.sender] = block.number;

        // liquidity is set
        require(liquidity > 0, "The token has no liquidity");

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
        processTaxBalance();
        return true;
    }

    /** Sends Tokens to the buyer Address */
    function buy(address receiver, uint256 amount) internal {
        _balances[receiver] = _balances[receiver] + amount;
        _balances[address(this)] = _balances[address(this)] - amount;
    }

    /** Sells SURGE Tokens And Deposits the BNB into Seller's Address */
    function _sell(uint256 tokenAmount, uint256 deadline, uint256 minBNBOut) public nonReentrant returns (bool) {
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
        processTaxBalance();
        return true;
    }

    function processTaxBalance() internal {
        if (taxBalance > 1) {
            bool temp1 = true;
            if (teamWallet != address(0)) {
                temp1 = SRGIE.transfer(
                    teamWallet,
                    (taxBalance * (teamFees * totalFees)) / SHAREDIVISOR
                );
            }

            bool temp2 = true;
            if (treasuryWallet != address(0)) {
                temp2 = SRGIE.transfer(
                    treasuryWallet,
                    (taxBalance * (treasuryFees * totalFees)) / SHAREDIVISOR
                );
            }

            // Builder Dev
            bool temp3 = SRGIE.transfer(
                builderDevWallet,
                (taxBalance * (builderDevFees * totalFees)) / SHAREDIVISOR
            );
            // Builder Marketing
            bool temp4 = SRGIE.transfer(
                builderMarketWallet,
                (taxBalance * (builderMarketFees * totalFees)) / SHAREDIVISOR
            );
            assert(temp1 && temp2 && temp3 && temp4);
            taxBalance = 0;
        }
    }

    /** Amount of liquidity in Contract */
    function getLiquidity() public view returns (uint256) {
        return liquidity;
    }

    /** Returns the value of your holdings before the sell fee */
    function getValueOfHoldings(address holder) public view returns (uint256) {
        return ((_balances[holder] * liquidity) / _balances[address(this)]) * getSRGPrice();
    }

    function getTokenAmountOut(uint256 amountSRGIn) external view returns (uint256) {
        uint256 amountAfter = liqConst / (liquidity - amountSRGIn);
        uint256 amountBefore = liqConst / liquidity;
        return amountAfter - amountBefore;
    }

    function getsrgAmountOut(uint256 amountIn) public view returns (uint256) {
        uint256 srgBefore = liqConst / _balances[address(this)];
        uint256 srgAfter = liqConst / (_balances[address(this)] + amountIn);
        return srgBefore - srgAfter;
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
}