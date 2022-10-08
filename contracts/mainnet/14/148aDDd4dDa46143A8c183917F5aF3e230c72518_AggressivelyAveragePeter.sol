/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

/**

SPDX-License-Identifier: UNLICENSED

Token:  Aggressively Average Peter
Ticker: AAPE

Website:  https://aape.charity
Twitter:  https://twitter.com/Aapecharity
Telegram: https://t.me/AapeCharity

*************************************************************

Initial Supply:

80% Staking Rewards
 5% Marketing
15% Liquidity

*************************************************************

Tokenomics:

Buy Tax 5%
2% Liquidity
1% Marketing
1% Prize Pot
1% Charity

Sell Tax 10%
2% Liquidity
3% Marketing
4% Prize Pot
1% Charity

*************************************************************

 */


//pragma solidity ^0.6.12;
pragma solidity ^0.7.4;


//import "hardhat/console.sol";

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
        if (a == 0) { return 0; }
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
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);    
    function decimals() external pure returns (uint8);
    function symbol() external pure returns (string memory);
    function name() external pure returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    //constructor(address _owner) public {
    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract AggressivelyAveragePeter is IBEP20, Auth {
    
    using SafeMath for uint256;

    string constant _name = " Aggressively Average Peter";
    string constant _symbol = "AAPE";
    uint8 constant _decimals = 9;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address charityWallet = 0x6E39B451478F8eb02A07D7F663904faD48ff5856; 
    address marketingWallet = 0xC5Cf88d9E81dc818932824064220289F88DA218C; 
    address stakingContract = 0xC5Cf88d9E81dc818932824064220289F88DA218C;

    uint256 _totalSupply = 1 * 10**8 * (10 ** 9);
    uint256 public _maxTxAmount = _totalSupply * 15 / 10000;
    uint256 public _walletMax = _totalSupply * 1 / 100;


    bool public restrictWhales = true;

    mapping (address => uint256) _balances;
    address [] prizeEntries;
    mapping (uint256 => mapping (address => uint256)) _dailyPrizeEntries;

    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isDividendExempt;

    uint256 public _rewardDateTime;
    uint256 rewardDay = 1;    
    uint256 _randomValue = 1;
    uint256 _amountWon = 0;
    address _winner;

    uint256 _liquidityPot = 0;
    uint256 public _prizePot = 0;
    uint256 public _tokensPerTicket =  1000 * (10 ** 9);
    
   

    uint256 public liquidityFee = 2;
    uint256 public marketingFee = 1;
    uint256 public prizeFee = 1;
    uint256 public charityFee = 1;

    uint256 public extraMarketingOnSell = 2;
    uint256 public extraPrizeOnSell = 3;

    uint256 public totalFee = 5;
    uint256 public totalFeeIfSelling = 10;

    address public autoLiquidityReceiver;

    IDEXRouter public router;
    address public pair;


    uint256 public launchedAt;
    bool public tradingOpen = false;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;

    uint256 public swapThreshold = _totalSupply * 5 / 4000;
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () Auth(msg.sender) {

        _rewardDateTime = block.timestamp + 1 days;
        
            
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = uint256(-1);

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[marketingWallet] = true;  
        isFeeExempt[charityWallet] = true;    
        isFeeExempt[stakingContract] = true;    

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[marketingWallet] = true;
        isTxLimitExempt[charityWallet] = true;
        isTxLimitExempt[stakingContract] = true;
        
        totalFee = liquidityFee.add(marketingFee);
        totalFee = totalFee.add(prizeFee);
        totalFee = totalFee.add(charityFee);
        totalFeeIfSelling = totalFee.add(extraMarketingOnSell);
        totalFeeIfSelling = totalFee.add(extraPrizeOnSell);

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function prizePot() external view returns (uint256) { return _prizePot; }
    function getEntries() external view returns (uint256) { return prizeEntries.length; }

    function myTickets(address _address) public view returns (uint256 Tickets) {

        uint256 _myTickets = 0;
        for (uint i = 0; i < prizeEntries.length; i++)
        {
            if (prizeEntries[i] == _address)
            { 
                _myTickets = _myTickets + 1;
            }
        }
        return _myTickets; 
    }

    function getTickets(address _address) public view returns (uint256 Tickets) {
        return  _dailyPrizeEntries[rewardDay][_address]; 
    }


    function getWinner() public view returns(uint256 amountWon, address winner){
        return (_amountWon, _winner);
    }


     function tokensPerTicket() external view returns (uint256) { return _tokensPerTicket; }
     function rewardDateTime() external view returns (uint256) { return _rewardDateTime; }


    function convertToLiquidity() external authorized {
        uint256 _amountToConvert = _prizePot / 4;    
        _liquidityPot = _liquidityPot + _amountToConvert;
        _prizePot = _prizePot - _amountToConvert;
        delete prizeEntries;
        prizeEntries.push(charityWallet);
    }

    function name() external pure override returns (string memory) { return _name; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function getOwner() external view override returns (address) { return owner; }







    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

   

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external  returns (bool) {
        return approve(spender, uint256(-1));
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function changeTxLimit(uint256 newLimit) external authorized {
        _maxTxAmount = newLimit;
    }
    
    function clear() external authorized {
        delete prizeEntries;
        prizeEntries.push(charityWallet);
    }

    function changeWalletLimit(uint256 newLimit) external authorized {
        _walletMax  = newLimit;
    }

    function changeRestrictWhales(bool newValue) external authorized {
       restrictWhales = newValue;
    }
    
    function changeIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function changeStakingContract(address newStakingContract) external authorized {   
        stakingContract = newStakingContract;
    }

     function changeTokensPerTicket(uint256 newTokensPerTicket) external authorized {   
         _tokensPerTicket = newTokensPerTicket;
     }    
    


    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }  

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if(inSwapAndLiquify){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen, "Trading not open yet");
        }

        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");

        if(msg.sender != pair && !inSwapAndLiquify && swapAndLiquifyEnabled && _liquidityPot >= swapThreshold && totalFee > 0) { swapBack(); }

        if(!launched() && recipient == pair) {
            require(_balances[sender] > 0);
            launch();
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if(!isTxLimitExempt[recipient] && restrictWhales)
        {
            require(_balances[recipient].add(amount) <= _walletMax);
        }

        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient] ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(finalAmount);


        emit Transfer(sender, recipient, finalAmount);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }



    function feedRandomness(uint256 randomValue) external authorized {   
        _randomValue = randomValue;
    }   

    
    function randModulus(uint mod) internal returns(uint){
        uint rand = uint(keccak256(abi.encodePacked(
            rewardDay,
            _randomValue,
            block.timestamp, 
            block.difficulty, 
            msg.sender)
        )) % mod;

        rewardDay++;

        return rand;
    }
       

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        if (recipient == stakingContract)
        {
            return amount;
        }
        else
        {
            uint256 feeApplicable = pair == recipient ? totalFeeIfSelling : totalFee;  
            uint256 feeAmount = amount.mul(feeApplicable).div(100);  

            if (block.timestamp >= _rewardDateTime)
            {
                // set next time for tomorrow
                _rewardDateTime = block.timestamp + 1 days;
                //_rewardDateTime = block.timestamp + 2 minutes;

                
                if (prizeEntries.length > 0)
                {      
                    // give reward to lucky winner
                    uint256 index = randModulus(prizeEntries.length);     
                    _amountWon = _prizePot / 4;       
                    _prizePot = _prizePot - _amountWon; 
                    _winner = prizeEntries[index];
                    emit Transfer(_winner, address(this), _amountWon);
                    // clear entries
                    delete prizeEntries;
                    // start again with charity wallet
                    prizeEntries.push(charityWallet);
                    rewardDay = rewardDay + 1;
                }
            }

            if (recipient != address(this))
            {
                uint256 ticketsToAdd = amount / _tokensPerTicket;
                for (uint256 i = 1; i<= ticketsToAdd; i++)
                {
                    prizeEntries.push(recipient); 
                }
                _dailyPrizeEntries[rewardDay][recipient] = _dailyPrizeEntries[rewardDay][recipient] + ticketsToAdd;
            }
            
            // prize pool + liquidity
            uint256 totalPrize = prizeFee;   
            if (feeApplicable == totalFeeIfSelling)
            {
                totalPrize = prizeFee.add(extraPrizeOnSell);
            }
            uint256 prizeAmount = amount.mul(totalPrize).div(100);
            uint256 liquidityAmount = amount.mul(liquidityFee).div(100);
            uint256 totalToContract = prizeAmount + liquidityAmount;

            _prizePot = _prizePot + prizeAmount;
            _liquidityPot = _liquidityPot + liquidityAmount;

            _balances[address(this)] = _balances[address(this)].add(totalToContract);
            emit Transfer(sender, address(this), totalToContract);

            // marketing
            uint256 totalMarketing = marketingFee;   
            if (feeApplicable == totalFeeIfSelling)
            {
                totalMarketing = marketingFee.add(extraMarketingOnSell);
            }          
            uint256 marketingAmount = amount.mul(totalMarketing).div(100);
            _balances[marketingWallet] = _balances[marketingWallet].add(marketingAmount);
            emit Transfer(sender, marketingWallet, marketingAmount);
           
            // charity    
            uint256 charityAmount = amount.mul(charityFee).div(100);
            _balances[marketingWallet] = _balances[charityWallet].add(charityAmount);
            emit Transfer(sender, charityWallet, charityAmount);

            return amount.sub(feeAmount);
        }

    }

    function tradingStatus(bool newStatus) public onlyOwner {
        tradingOpen = newStatus;
    }

    function swapBack() internal lockTheSwap {
        
        uint256 amountToSwap = _liquidityPot.div(2);
        uint256 amountToLiquify = amountToSwap;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance;
        
        uint256 amountBNBLiquidity = amountBNB.div(2);
        

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountToken);

}