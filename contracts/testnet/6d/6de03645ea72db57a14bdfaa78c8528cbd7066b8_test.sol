/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

//SPDX-License-Identifier: MIT


pragma solidity ^0.8.17;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface IPancakePair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/** 
 * Contract: Surge Token
 * Developed By: Heisenman
 */

contract test is IERC20, Context, Ownable, ReentrancyGuard {

    event Bought(address indexed from, address indexed to, uint256 amount);
    event Sold(address indexed from, address indexed to, uint256 amount);

    using SafeMath for uint256;
    using SafeMath for uint8;

    // token data
    string constant _name = "test";
    string constant _symbol = "test";
    uint8 constant _decimals = 9;
    uint256 constant _decMultiplier = 10**_decimals;

    // Total Supply
    uint256 public _totalSupply = 10**8*_decMultiplier;

    // balances
    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;

    //Fees
    mapping (address => bool) public isFeeExempt;
    uint256 public sellMul = 95;
    uint256 public buyMul = 95;
    uint256 public constant divisor = 100;

    //Max bag requirements
    mapping (address => bool) public isTxLimitExempt;
    uint256 public maxBag = _totalSupply/100;
    
    //Tax collection
    uint256 public taxBalance = 0;

    //Tax wallets
    address public teamWallet = 0xDa17D158bC42f9C29E626b836d9231bB173bab06;
    address public treasuryWallet = 0x8Cf268d248154014Ce28B9A9AB48b6C8c7062fA0 ;

    // Tax Split
    uint256 public teamShare = 40;
    uint256 public treasuryShare = 60;
    uint256 public shareDivisor = 100;

    //Known Wallets
    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    //trading parameters
    uint256 public liquidity = 5 ether;
    uint256 public liqConst= liquidity.mul(_totalSupply);
    uint256 public tradeOpenTime = 1669205079;

    //trading mappings
    mapping (uint256 => uint256) private vol;
    mapping (uint256 => uint256) private price;
    mapping (address => uint256) private indVol;
    mapping (uint256 => uint256) public buyValue;
    mapping (uint256 => uint256) public sellValue;
    uint256 public totalBuys = 0;
    uint256 public totalSells = 0;
    mapping (uint256 => uint256) public buyTimeStamp;
    mapping (uint256 => uint256) public sellTimeStamp;

    //Volume
    uint256 public totalVolume = 0;

    //Frontrun Gaurd
    bool private frGaurd = false;

    // initialize supply
    constructor(
    ) {
        _balances[address(this)] = _totalSupply;

        isFeeExempt[msg.sender] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[address(0)] = true;

        emit Transfer(address(0), address(this), _totalSupply);
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint).max);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(_balances[DEAD]);
    }

    function changeWalletLimit(uint256 newLimit) external onlyOwner {
        require(newLimit >= _totalSupply/100);
        maxBag  = newLimit;
    }
    
    function changeIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    /** Transfer Function */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    /** Transfer Function */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(sender == msg.sender);
        return _transferFrom(sender, recipient, amount);
    }
    
    /** Internal Transfer */
    function _transferFrom(address sender, address recipient, uint256 amount) internal nonReentrant returns (bool) {
        // make standard checks
        require(recipient != address(0) && recipient != address(this), "transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(isTxLimitExempt[recipient]||_balances[recipient]+amount<= maxBag);
        // subtract from sender
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        // give reduced amount to receiver
        _balances[recipient] = _balances[recipient].add(amount);
        // Transfer Event
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    //tx timeout modifier
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'Deadline EXPIRED');
        _;
    }

    /** Purchases SURGE Tokens and Deposits Them in Sender's Address*/
    function _buy(uint256 minTokenOut, uint256 deadline) public nonReentrant ensure(deadline) payable returns (bool) {
        frGaurd= true;
        // liquidity is set and trade is open
        require(liquidity > 0 && block.timestamp>= tradeOpenTime, 'The token has no liquidity or trading not open');
     
        //remove the buy tax
        uint256 bnbAmount = isFeeExempt[msg.sender] ? msg.value : msg.value.mul(buyMul).div(divisor);
        
        // how much they should purchase?
        uint256 tokensToSend = _balances[address(this)].sub(liqConst.div(bnbAmount.add(liquidity)));
        
        //revert for max bag
        require(_balances[msg.sender] + tokensToSend <= maxBag || isTxLimitExempt[msg.sender],' Max wallet exceeded');

        // revert if under 1
        require(tokensToSend > 1,'Must Buy more than 1 decimal of Surge');

        // revert for slippage
        require(tokensToSend >= minTokenOut,'INSUFFICIENT OUTPUT AMOUNT');

        // transfer the tokens from CA to the buyer
        buy(msg.sender, tokensToSend);

        //update available tax to extract and Liquidity
        uint256 taxAmount = msg.value.sub(bnbAmount);
        taxBalance = taxBalance.add(taxAmount);
        liquidity = liquidity.add(bnbAmount);

        //update volume
        totalVolume += msg.value;
        indVol[msg.sender]+= msg.value;
        vol[block.timestamp]+= msg.value;

        //update buys
        totalBuys +=1;
        buyValue[totalBuys]= msg.value;
        buyTimeStamp[totalBuys] = block.timestamp;

        //update price
        price[block.timestamp] = calculatePrice();

        emit Transfer(address(this), msg.sender, tokensToSend);
        emit Bought(msg.sender, address(this), msg.value);
        return true;
    }
    
    /** Sends Tokens to the buyer Address */
    function buy(address receiver, uint amount) internal {
        _balances[receiver] = _balances[receiver].add(amount);
        _balances[address(this)] = _balances[address(this)].sub(amount);
    }

    /** Sells SURGE Tokens And Deposits the BNB into Seller's Address */
    function _sell(uint256 tokenAmount, uint256 deadline, uint256 minBNBOut) public nonReentrant ensure(deadline) payable returns (bool) {
        
        require(msg.value == 0);

        address seller = msg.sender;
        
        // make sure seller has this balance
        require(_balances[seller] >= tokenAmount, 'cannot sell above token amount');
        
        // how much BNB are these tokens worth?
        uint256 amountBNB = liquidity.sub(liqConst/(_balances[address(this)]+tokenAmount));
        uint256 amountTax = amountBNB.mul(divisor.sub(sellMul)).div(divisor);
        uint256 BNBToSend = amountBNB.sub(amountTax);
        
        //slippage revert
        require(amountBNB >= minBNBOut);

        // send BNB to Seller
        (bool successful,) = isFeeExempt[msg.sender] ? payable(seller).call{value: amountBNB, gas:40000}(""): payable(seller).call{value: BNBToSend, gas:40000}(""); 
        require(successful);

        // subtract full amount from sender
        _balances[seller] = _balances[seller].sub(tokenAmount);

        //add tax allowance to be withdrawn and remove from liq the amount of beans taken by the seller
        taxBalance = isFeeExempt[msg.sender] ? taxBalance : taxBalance.add(amountTax);
        liquidity = liquidity.sub(amountBNB);

        // add tokens back into the contract
        _balances[address(this)]=_balances[address(this)].add(tokenAmount);

        //update volume
        totalVolume += amountBNB.mul(getBNBPrice());
        indVol[msg.sender]+= amountBNB.mul(getBNBPrice());
        vol[block.timestamp]+= amountBNB.mul(getBNBPrice());

        //update Sells
        totalSells +=1;
        sellValue[totalSells]= amountBNB;
        sellTimeStamp[totalSells] = block.timestamp;

        //update price
        price[block.timestamp] = calculatePrice().mul(getBNBPrice());

        emit Transfer(seller, address(this), tokenAmount);
        if(isFeeExempt[msg.sender]){
            emit Sold(address(this), msg.sender,amountBNB);
        }
        
        else{ emit Sold(address(this), msg.sender,BNBToSend);}
        return true;
    }
    
    /** Amount of BNB in Contract */
    function getLiquidity() public view returns(uint256){
        return liquidity;
    }

    /** Returns the value of your holdings before the sell fee */
    function getValueOfHoldings(address holder) public view returns(uint256) {
        return _balances[holder].mul(liquidity).div(_balances[address(this)]).mul(getBNBPrice());
    }

    function changeFees(uint256 newbuyMul, uint256 newsellMul) external onlyOwner {
        require( newbuyMul >= 90 && newsellMul >= 90 && newbuyMul <=100 && newsellMul<= 100, 'Fees are too high');

        buyMul = newbuyMul;
        sellMul = newsellMul;
    }

    function changeTaxDistribution(uint newteamShare, uint newtreasuryShare) external onlyOwner {
        require(newteamShare.add(newtreasuryShare) == 100);

        teamShare = newteamShare;
        treasuryShare = newtreasuryShare;
    }

    function changeFeeReceivers(address newTeamWallet, address newTreasuryWallet) external onlyOwner {
        teamWallet = newTeamWallet;
        treasuryWallet = newTreasuryWallet;
    }

    function withdrawTaxBalance() external nonReentrant() payable onlyOwner {
        (bool temp1,)= payable(teamWallet).call{value:taxBalance.mul(teamShare).div(shareDivisor)}("");
        (bool temp2,)= payable(treasuryWallet).call{value:taxBalance.mul(treasuryShare).div(shareDivisor)}("");
        assert(temp1 && temp2);
        taxBalance = 0; 
    }

    function getTokenAmountOut(uint256 amountBNBIn) external view returns (uint256) {
        require(amountBNBIn<= liquidity,'Amount bigger than liquidity');
        return amountBNBIn.mul(_balances[address(this)]).div(liquidity);
    }

    function getBNBAmountOut(uint256 amountIn) public view returns (uint256) {
        require(amountIn<_balances[address(this)], 'Incorrect input amount');
        return amountIn.mul(liquidity).div(_balances[address(this)]);
    }

    function addLiquidity() external nonReentrant() onlyOwner payable {
        uint256 tokensToAdd= liqConst.mul(msg.value).div(liquidity);
        require(_balances[msg.sender]>= tokensToAdd);

        uint256 oldLiq = liquidity;
        liquidity = liquidity.add(msg.value);
        _balances[address(this)]+= tokensToAdd;
        _balances[msg.sender]-= tokensToAdd;
        liqConst= liqConst.mul(liquidity).div(oldLiq);
    }

    function getMarketCap() external view returns(uint256){
        return (getCirculatingSupply().mul(calculatePrice()).mul(getBNBPrice()));
    }

    address private stablePairAddress = 0x8a1a4C578a8E7DE817D588195f2f89Ad0b591c9f;
    address private stableAddress = 0x64544969ed7EBf5f083679233325356EbE738930;

    function changeStablePair(address newStablePair, address newStableAddress) external{
        stablePairAddress = newStablePair;
        stableAddress = newStableAddress;
    }

   // calculate price based on pair reserves
   function getBNBPrice() public view returns(uint)
   {
    IPancakePair pair = IPancakePair(stablePairAddress);
    IERC20 token1 = pair.token0() == stableAddress? IERC20(pair.token1()):IERC20(pair.token0()); 
    
    (uint Res0, uint Res1,) = pair.getReserves();

    if(pair.token0() != stableAddress){(Res1,Res0,) = pair.getReserves();}
    uint res0 = Res0*10**token1.decimals();
    return(res0/Res1); // return amount of token0 needed to buy token1
   }

    /** Returns the Current Price of the Token */
    function calculatePrice() public view returns (uint256) {
        require(liquidity>0,'No Liquidity');
        return liquidity.div(_balances[address(this)]);
    }

    //volume getters
    function getIndVol(address trader) external view returns (uint256) 
    {
        return indVol[trader];
    }
}