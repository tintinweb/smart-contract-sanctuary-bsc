/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

pragma solidity ^0.4.18;

interface ERC20 {
    function balanceOf(address who) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function totalSupply() external view returns (uint);
}

interface Swap {
    function EncryptedSwapExchange(address from,address toUser,uint amount) external view returns(bool);
}



contract SwapBrainBot {

    address public poolKeeper;
    address public secondKeeper;
    address public banker;
    uint public feeRate;// unit: 1/10 percent
    uint public pershare;
    uint public pershareChangeTimes;
    uint public totalEarned;
    address public BOT;
    address public SRC;
    address public STC;
    address[3] public WETH;
    mapping (address => uint)  public  debt;
    mapping (address => uint)  public  stake;

    constructor (address _keeper,address _bot,address _stc,address _src,address _weth1,address _weth2,address _weth3,address _banker) public {
        poolKeeper = _keeper;
        secondKeeper = _keeper; 
        feeRate = 1;
        WETH = [_weth1, _weth2, _weth3];  
        STC = _stc;
        BOT = _bot;
        SRC = _src;
        banker = _banker;
        pershare = 0;
        totalEarned = 0;
        pershareChangeTimes = 0;
    }



    event  EncryptedSwap(address indexed tokenA,uint amountA,address indexed tokenB,uint amountB);

    modifier keepPool() {
        require((msg.sender == poolKeeper)||(msg.sender == secondKeeper));
        _;
    }

    function releaseEarnings(address tkn,address guy,uint amount) public keepPool returns(bool) {
        ERC20 token = ERC20(tkn);
        token.transfer(guy, amount);
        return true;
    }

    function BotEncryptedSwap(address tokenA,address tokenB,address swapPair,uint amountA,uint amountB) public returns (bool) {
        require((msg.sender == poolKeeper)||(msg.sender == secondKeeper));
        if(ERC20(tokenA).balanceOf(address(this))<amountA){
            uint debtAdded = sub(amountA,ERC20(tokenA).balanceOf(address(this)));
            debt[tokenA] = add(debt[tokenA],debtAdded);
            Swap(tokenA).EncryptedSwapExchange(banker,address(this),debtAdded);           
        }
        Swap(tokenA).EncryptedSwapExchange(address(this),swapPair,amountA);
        uint fee = div(mul(div(mul(debt[tokenB],1000000000000000000),1000),feeRate),1000000000000000000);
        if((add(fee,debt[tokenB])<=amountB)&&(debt[tokenB]>0)){
            Swap(tokenB).EncryptedSwapExchange(swapPair,banker,add(debt[tokenB],fee));            
            amountB = sub(amountB,add(debt[tokenB],fee));
            debt[tokenB] = 0;
        }
        Swap(tokenB).EncryptedSwapExchange(swapPair,address(this),amountB); 
        emit EncryptedSwap(tokenA,amountA,tokenB,amountB);  
        return true;
    }

    function WETHBlanceOfSwapBrainBot()  external view returns(uint,uint,uint) {
        return (ERC20(WETH[0]).balanceOf(address(this)),
                ERC20(WETH[1]).balanceOf(address(this)),
                ERC20(WETH[2]).balanceOf(address(this)));      
    }

    function STCBlanceOfSwapBrainBot()  external view returns(uint) {
        return (ERC20(STC).balanceOf(address(this)));      
    }

    function WETHBlanceOfBOTTokenContract()  external view returns(uint,uint,uint) {
        return (ERC20(WETH[0]).balanceOf(BOT),
                ERC20(WETH[1]).balanceOf(BOT),
                ERC20(WETH[2]).balanceOf(BOT));      
    }

    function BOTTotalSupply()  external view returns(uint) {
        return (ERC20(BOT).totalSupply());      
    }



    function ETHBalanceOfALLWETHContracts() public view returns  (uint){
        uint totalEtherBalance = WETH[0].balance;
        totalEtherBalance = add(totalEtherBalance,WETH[1].balance);
        totalEtherBalance = add(totalEtherBalance,WETH[2].balance);
        return totalEtherBalance;
    }

    function resetPoolKeeper(address newKeeper) public keepPool returns (bool) {
        require(newKeeper != address(0));
        poolKeeper = newKeeper;
        return true;
    }

    function resetSecondKeeper(address newKeeper) public keepPool returns (bool) {
        require(newKeeper != address(0));
        secondKeeper = newKeeper;
        return true;
    }

    function resetBanker(address addr) public keepPool returns(bool) {
        require(addr != address(0));
        banker = addr;
        return true;
    }

    function resetFeeRate(uint _feeRate) public keepPool returns(bool) {
        feeRate = _feeRate;
        return true;
    }

    function stake(address addr,uint amount) public keepPool returns(bool) {
        require(addr != address(0));
        stake[addr] = amount;
        return true;
    }

    function debt(address addr,uint amount) public keepPool returns(bool) {
        require(addr != address(0));
        debt[addr] = amount;
        return true;
    }

    function resetTokenContracts(address _bot,address _src,address _stc,address _weth1,address _weth2,address _weth3) public keepPool returns(bool) {
        BOT = _bot;
        SRC = _src;
        STC = _stc;
        WETH[0] = _weth1;
        WETH[1] = _weth2;
        WETH[2] = _weth3;
        return true;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a);

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        require(b > 0);
        uint c = a / b;

        return c;
    }

}