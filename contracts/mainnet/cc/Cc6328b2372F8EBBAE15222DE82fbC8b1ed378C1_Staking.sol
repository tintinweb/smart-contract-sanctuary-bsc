/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

//Interface for interacting with erc20

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}



interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) view external returns (uint256);
    function decimals() view external returns (uint256);


}

contract Migrate {

    address constant RouterV2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;//addr pancakeRouter
    address constant OldCELL = 0xf3E1449DDB6b218dA2C9463D4594CEccC8934346; // addr old cell token
    address constant Lp = 0x06155034f71811fe0D6568eA8bdF6EC12d04Bed2; // addr old lp token
    address WETH = IUniswapV2Router01(RouterV2).WETH();
    address constant CELL =  0xd98438889Ae7364c7E2A3540547Fad042FB24642;// addr new cell token
    address constant newLp = 0x1c15f4E3fd885a34660829aE692918b4b9C1803d;// addr new lp token v2
    address[] owners = [0x65Def3eA531fD80354Ec11c611Ae4fAa06068F27, 0x2C87D8F4EBcd05bE72EFbbd2fc6C6A000C8af854, 0x122a2121A99a0CFC7104CD5EeAbE7FFfEd7F4da1];
    address payable public marketingAddress = payable(0xC3b8A652e59d59A71b00808c1FB2432857080Ab8);

    struct pairParams{
        address tokenAddr;
    }

    mapping(address => mapping(address => uint)) balanceSender;
    mapping(address => uint) balanceLP;
    mapping(string => pairParams) tokens;


    modifier Owners() {
        bool confirmation;
        for (uint8 i = 0; i < owners.length; i++){
            if(owners[i] == msg.sender){
                confirmation = true;
                break;
            }
        }
        require(confirmation ,"You are not on the list of owners");
        _;
    }



    
    function migrate(uint amountLP) public returns(uint,uint,uint liquidity){

        

        IERC20(Lp).transferFrom(msg.sender,address(this),amountLP);
        IERC20(Lp).approve(RouterV2,amountLP);

        (uint token1,uint token0) = migrateLP(amountLP);
        IERC20(OldCELL).transfer(marketingAddress,token0);
        

        (uint eth,uint cell, ) = IUniswapV2Pair(newLp).getReserves();     
        uint resoult = cell/eth;        
        token0 = resoult * token1;


        balanceSender[msg.sender][OldCELL]= token0;
        balanceSender[msg.sender][WETH]= token1;

        
        IERC20(CELL).approve(RouterV2,token0);
        IERC20(WETH).approve(RouterV2,token1);
       
        
                 
        return IUniswapV2Router01(RouterV2).addLiquidity(
            WETH,
            CELL,
            token1,
            token0,
            0,
            0,
            address(this),
            block.timestamp + 5000
        );
        
        

        }
    


    function migrateLP(uint amountLP) internal returns(uint256 token0,uint256 token1) {

        return IUniswapV2Router01(RouterV2).removeLiquidity(
            OldCELL,
            WETH,
            amountLP,
            1,
            1,
            address(this),
            block.timestamp + 5000
        );

    }

    function addPairV2(string memory tokenName, address tokenAddr) public Owners{
        tokens[tokenName] = pairParams({tokenAddr:tokenAddr});
    }

    function getPair(string memory pair) view public returns (address){
        return tokens[pair].tokenAddr;
    }


    receive () external payable{

    }



}

contract Staking is Migrate{
    
    bool pause;
    uint time;
    uint endTime;
    uint32 txId;
    uint8 constant idNetwork = 56;
    uint32 constant months = 2629743;

    struct Participant{
        address sender;
        uint timeLock;
        string addrCN;
        address token;
        uint sum;
        uint timeUnlock;
        bool staked;
    }


    event staked(
        address owner,
        uint sum,
        uint8 countMonths,
        string addrCN,
        address token,
        uint timeStaking,
        uint timeUnlock,
        uint32 txId,
        uint8 procentage,
        uint8 networkID
    );

    event unlocked(
        address sender,
        uint sumUnlock,
        uint32 txID

    );


    Participant participant;
  
    // consensus information
    mapping(address => uint8) acceptance;
    // information Participant
    mapping(address => mapping(uint32 => Participant)) timeTokenLock;
    
    mapping(uint32 => Participant) checkPart;


    function pauseLock(bool answer) external Owners returns(bool){
        pause = answer;
        return pause;
    }

    function setMarketingAddress(address _addy) external Owners {
    marketingAddress = payable(_addy);
    }


    //@dev calculate months in unixtime
    function timeStaking(uint _time,uint8 countMonths) internal pure returns (uint){
        require(countMonths >=3 , "Minimal month 3");
        require(countMonths <=24 , "Maximal month 24");
        return _time + (months * countMonths);
    }

    function seeAllStaking(address token) view public returns(uint){
        return IERC20(token).balanceOf(address(this));
    }


    function stake(uint _sum,uint8 count,string memory addrCN,uint8 procentage,string memory pairName) public  returns(uint32) {
        require( procentage <= 100,"Max count procent 100");
        require(_sum >= 10 ** IERC20(getPair(pairName)).decimals(),"Minimal stake 1 token");
        require(!pause,"Staking paused");
        require(getPair(pairName) != address(0));
        
    
        uint _timeUnlock = timeStaking(block.timestamp,count);
        //creating a staking participant
        participant = Participant(msg.sender,block.timestamp,addrCN,getPair(pairName),_sum,_timeUnlock,true);

        //identifying a participant by three keys (address, transaction ID, token address)
        timeTokenLock[msg.sender][txId] = participant;
        checkPart[txId] = participant;
        if(getPair(pairName) == Lp){    
            ( , , timeTokenLock[msg.sender][txId].sum) = migrate(_sum);
        }       
        emit staked(msg.sender,_sum,count,addrCN,getPair(pairName),block.timestamp,
            _timeUnlock,txId,procentage,idNetwork); 
        
        txId ++;
        return txId -1;
    }

    function claimFund(uint32 _txID) external {
        require(block.timestamp >= timeTokenLock[msg.sender][_txID].timeUnlock,
           "The time has not yet come" );
        require(timeTokenLock[msg.sender][_txID].staked,"The steak was taken");
        require(msg.sender == timeTokenLock[msg.sender][_txID].sender,"You are not a staker");
        require(timeTokenLock[msg.sender][_txID].timeLock != 0);
        
        if(timeTokenLock[msg.sender][_txID].token == Lp){
            IERC20(newLp).transfer(msg.sender,timeTokenLock[msg.sender][_txID].sum );
        }else{
            IERC20(timeTokenLock[msg.sender][_txID].token).transfer(msg.sender,timeTokenLock[msg.sender][_txID].sum);
        }

        timeTokenLock[msg.sender][_txID].staked = false;
        checkPart[_txID].staked = false;
        emit unlocked(msg.sender,timeTokenLock[msg.sender][_txID].sum,_txID);


    }

   

    function seeStaked (uint32 txID) view public returns(uint timeLock,string memory addrCN,uint sum,uint timeUnlock,bool _staked){
        return (checkPart[txID].timeLock,checkPart[txID].addrCN,checkPart[txID].sum,
                checkPart[txID].timeUnlock,checkPart[txID].staked);
    }
    
   
}