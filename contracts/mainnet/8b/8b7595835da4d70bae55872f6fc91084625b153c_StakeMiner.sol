/**

 /$$   /$$                                         /$$       /$$      /$$ /$$                    
| $$  /$$/                                        | $$      | $$$    /$$$|__/                    
| $$ /$$/   /$$$$$$   /$$$$$$  /$$$$$$$   /$$$$$$ | $$      | $$$$  /$$$$ /$$ /$$$$$$$   /$$$$$$ 
| $$$$$/   |____  $$ /$$__  $$| $$__  $$ /$$__  $$| $$      | $$ $$/$$ $$| $$| $$__  $$ /$$__  $$
| $$  $$    /$$$$$$$| $$  \__/| $$  \ $$| $$$$$$$$| $$      | $$  $$$| $$| $$| $$  \ $$| $$$$$$$$
| $$\  $$  /$$__  $$| $$      | $$  | $$| $$_____/| $$      | $$\  $ | $$| $$| $$  | $$| $$_____/
| $$ \  $$|  $$$$$$$| $$      | $$  | $$|  $$$$$$$| $$      | $$ \/  | $$| $$| $$  | $$|  $$$$$$$
|__/  \__/ \_______/|__/      |__/  |__/ \_______/|__/      |__/     |__/|__/|__/  |__/ \_______/
https://karnelminer.com/
twitter: @karnel_miner__
 */

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC20/ERC20.sol)
//0x8b7595835da4d70BaE55872f6Fc91084625B153c
pragma solidity  >=0.4.22 <0.9.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
//0x4095ED58782AB8DBe520640b665a37a9D0033d47
import "./USDi.sol";
interface IPancakeRouter02 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}


interface FlashUnstake {
    function iUnstake(address sender, uint amount0, bytes calldata data) external;
}

interface IStakeMiner {
    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);
    event Disburse(bool io);   

    function stakeBalance(address owner) external view returns (uint);
    function isStaking(address owner) external view returns (bool);
    function usdiRecept(address owner) external view returns (uint);
    function timeState(address owner) external view returns (uint);

    function getUSDi() external view returns (address);
    function stake(uint256 amount,address _fiat) external payable;
    
    function unStake(uint256 _amount) external;
    
    function getTotalMint() external view returns(uint);

    function flashUnsTake(uint amount0Out,address to,bytes calldata data) external;

}
contract StakeMiner is Context,IStakeMiner {
    using SafeMath for uint;

    // userAddress => stakingBalance
    mapping (address=>uint256) public override stakeBalance;
    // UserAddress => is itstaked
    mapping (address => bool) public override isStaking;
    // address to usdiamount
    mapping (address => uint256) public override usdiRecept;
    //address to timestap
    mapping (address=>uint256) public override timeState;

    // Team Memebrs
    mapping (address=>bool) private owners;
     // Vote Team Memebrs
    mapping (address=>uint) private votes;
    //address array of stakers
    address[] public stakeHolders;

    IERC20 public usdt;
    IERC20 public pumpD;
    USDi public usdi;

    address private DexAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private wBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private genesis;

    uint public numberVote = 0;
    uint public chargeVote = 100000000000000000000;

    //string public name = "itsTradableFarm";

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));
    bytes4 private constant TFSELECTOR = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    bytes4 private constant MINTSELECTOR = bytes4(keccak256(bytes('mint(address,uint256,uint256)')));
    bytes4 private constant BURNSELECTOR = bytes4(keccak256(bytes('burn(address,uint256)')));

    modifier itsTTeam() {
        require(owners[_msgSender()],"Not A team member");
        _;
    }
    /** 
    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);
    event Disburse(bool io);
    */
    constructor (address _usdt) {
        usdt = IERC20(_usdt);
        //pumpD = IERC20(_pumpD);
        usdi = new USDi();
        owners[_msgSender()] = true;
        genesis = _msgSender();
        
    }
    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'itTradable: TRANSFER_FAILED');
    }
    function _safeTransferFrom(address token,address from, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(TFSELECTOR,from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'itTradable: TRANSFER_FROM_FAILED');
    }
    function _safeMint(address token, address to, uint value,uint tamount) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(MINTSELECTOR, to, value,tamount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'itTradable: MINT_FAILED');
    }
    function _safeBurn(address token, address from, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(BURNSELECTOR, from, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'itTradable: BURN_FAILED');
    }
    function getUSDi() public view override returns (address) {
        return address(usdi);
    }
    function stake(uint256 amount,address _fiat) public payable override {
        require (amount >0, "You cannot stakeZero Tokens");
        uint amount_ = 0;
        if (_fiat == address(usdt)) {
            usdt.transferFrom(_msgSender(),address(this),amount);
            amount_= amount;
        } else if (_fiat == wBNB){
            address[] memory path = new address[](2);
            path[0] = wBNB;
            path[1] = address(usdt);
            IPancakeRouter02(DexAddress).swapExactETHForTokensSupportingFeeOnTransferTokens{value:msg.value}(
                0,
                path,
                address(this),
                block.timestamp
            );
            uint[] memory getAmount = IPancakeRouter02(DexAddress).getAmountsOut(msg.value,path);
            amount_ = getAmount[0]==msg.value?getAmount[1]:getAmount[0];
        } else {
            uint _amount = amount;
            IERC20(_fiat).transferFrom(_msgSender(),address(this),_amount);
            address[] memory path = new address[](3);
            path[0] = _fiat;
            path[1] = wBNB;
            path[2] = address(usdt);
            
            IERC20(_fiat).approve(DexAddress, _amount);
            IPancakeRouter02(DexAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _amount,
                0,
                path,
                address(this),
                block.timestamp
            );
            uint[] memory getAmount = IPancakeRouter02(DexAddress).getAmountsOut(amount,path);
            amount_ = getAmount[0]==_amount?getAmount[2]:getAmount[0];    
        }
            
            timeState[_msgSender()] = block.timestamp;
            isStaking[_msgSender()] = true;
            stakeHolders.push(_msgSender());
            uint recept = calculateRecept(amount_);
            stakeBalance[_msgSender()] += recept;
            _safeMint(address(usdi), _msgSender(), recept,amount_);
            //usdi.mint(_msgSender(),recept,amount);
            emit Stake(_msgSender(),amount_);
            require(recept>=0,"Disburse Error");


    }
    function calculateRecept(uint _amount) private returns (uint) {
        uint amount = _amount;
        uint rewards = amount.mul(5).div(100);
        uint reward_to_holder = rewards.div(2);
        //uint reward_to_team = rewards.sub(reward_to_holder);
        uint recept_owner = 10;//amount.sub(rewards);
        address[] memory stake_h = stakeHolders;
        bool distribut_r = usdi.disburse(reward_to_holder,stake_h,rewards);

        if (distribut_r) {
            emit Disburse(distribut_r);
            return (recept_owner);
            
        } else if (stake_h.length == 1) {
            emit Disburse(true);
            return (recept_owner);
            
        }
        return (0);
        
        
    }
    function unStake(uint _amount) public override {
        uint amount = _amount.sub(1);
        uint userReciept = usdi.balanceOf(_msgSender());
        require(userReciept>=amount,"No USDi available");
  
        uint256 getUsdtAmount = getStakeOutPut(_amount);

        //Burn token
        _safeBurn(address(usdi), _msgSender(),amount);
 
        uint tUSDt = usdt.balanceOf(address(this));
        //uint the amount of usdt to b sent
        //calculateYield(amount,tUSDt,tMinted,_msgSender());
        //Transfer usdt
        require(tUSDt>getUsdtAmount,"Vault Empty");
        
        _safeTransfer(address(usdt), _msgSender(), getUsdtAmount);
        emit Unstake(_msgSender(),getUsdtAmount);
        //usdt.transfer(_msgSender(),getUsdtAmount);


    }
    function getStakeOutPut(uint256 _amount) public  view returns (uint) {
        uint amount = _amount;
        uint tMinted = usdi.getTotalMint();
        //get total USDi
        uint tUSDt = usdt.balanceOf(address(this));
        return calculateYield(amount,tUSDt,tMinted,_msgSender());
    }
    function calculateYield(uint _amount,uint _tUsdt ,uint _tMinted,address _to) private view  returns(uint) {
        //SubTract tMinted from tUSDt
        uint tUSDt = _tUsdt;
        uint tMinted = _tMinted;
        uint amount = _amount;

        uint userStake = usdi.balanceOf(_to);//stakeBalance[_msgSender()];
        uint sharePercnt = userStake.mul(1000).div(tMinted);
        
        uint usdtPlEV = tUSDt.mul(sharePercnt).div(1000);
        uint highDv = usdtPlEV>userStake?usdtPlEV:userStake;
        uint prcIncr = highDv.sub(userStake).mul(1000).div(userStake);
        uint pctIncrDcr = amount.mul(prcIncr).div(1000);
        uint usdtEV = amount.add(pctIncrDcr);

/** 
        uint chInPrc = tUSDt>tMinted?tUSDt.sub(tMinted):0;
        uint divChInPrc = chInPrc.mul(1000).div(tMinted);
        uint pctIncrDcr = amount.mul(divChInPrc).div(1000);
        uint usdtEv = amount.add(pctIncrDcr);
*/        
        return usdtEV;
    }

    function getTotalMint() external view override returns(uint) {
        return usdi.getTotalMint();
    }


    function flashUnsTake(uint amount0Out,address to,bytes calldata data) external override {
        require(data.length>0,"No Request Made");

        uint reserve0 = usdt.balanceOf(address(this));
        uint fee = amount0Out.mul(2).div(100);
        uint reserve1 = reserve0.add(fee);

        if (amount0Out > 0) _safeTransfer(address(usdt), to, amount0Out);
        FlashUnstake(to).iUnstake(to,amount0Out,data);  
        //Repayed
        uint balance0 = usdt.balanceOf(address(this));

        require(balance0>=reserve1,"Loan Requirment Failed");


    }
    function Deposit(uint256 _amount) public  itsTTeam {
        uint amount = _amount;
        if (amount > 0) _safeTransferFrom(address(usdt), _msgSender(), address(this), amount);
    }
    function withdrawal (uint256 _amount) public itsTTeam {
        uint amount = _amount;
        if (amount > 0) _safeTransfer(address(usdt), _msgSender(), amount);
    }
    function addItsTTeam(address newTeam) external itsTTeam {
        owners[newTeam] = true;
    }
    function voteRequirement(uint charge, uint numberV) external  {
        require(_msgSender() == genesis,"Not the Creator");
        chargeVote = charge;
        numberVote += numberV;
    }
    function checkOwner(address team) external view returns(bool){
        return owners[team];
    }
    function voteNewTeam(address newTeam,uint amount) external {
        require(amount>chargeVote,"Not Eligable to Vote");
        require(!owners[newTeam],"Already a team member");
        _safeTransferFrom(address(usdt), _msgSender(),genesis, amount);
        votes[newTeam] +=1;
        if (votes[newTeam]>numberVote) owners[newTeam] = true;

    }
}
contract FLoan is FlashUnstake {
    using SafeMath for uint;
    address private stakerC;
    IERC20 private usdt;
    event log(string message,  uint val);
    constructor(address stake,address _usdt) {
        stakerC = stake;
        usdt = IERC20(_usdt);
    }
    function initStateLoan(uint amount) public {
        bytes memory data = abi.encode("Cash Please");
        uint tokenRecieved = usdt.balanceOf(address(this));
        emit log("Token Amount B4",tokenRecieved);
        IStakeMiner(stakerC).flashUnsTake(amount, address(this), data);
    }
    
    function iUnstake(address sender, uint amount0, bytes calldata data) external override {
        uint fee = 30000000000000000000;
        uint total = amount0.add(fee);
        uint tokenRecieved = usdt.balanceOf(address(this));
        emit log("Token Amount",tokenRecieved);
        usdt.transfer(stakerC, total);
    }
}