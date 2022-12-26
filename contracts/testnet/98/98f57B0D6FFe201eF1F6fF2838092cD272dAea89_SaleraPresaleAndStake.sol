/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// File: @openzeppelin/contracts/utils/math/SafeMath.sol
library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }


    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

 
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }


    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

 
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)
pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)
pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;


    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

pragma solidity ^0.8.0;
interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

// Salera Dapp application
pragma solidity ^0.8.0;
contract SaleraPresaleAndStake is Ownable {
    using SafeMath for uint256;
    
    struct Plan {
        uint256 daytime;
        uint256 percent;
        uint256 monthday;
        uint256 month;
    }

    Plan[] internal plans;

    struct Deposit {
        uint8 plan;
        uint256 amount;
        uint256 start;
        uint256 end;
        uint256 checkpoint;
        uint256 withdrawn; 
        uint256 investAmount;       
    }

    struct Level{
        uint256 percent;
        uint256 criteria;
    }

    struct LevelPlan {
        uint8 level;
		uint256 bonus;
        uint256 bonuswithdrawal;
		uint8 lock;
        uint256 totalBussiness;
	}

    Level[] internal levels;

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        uint256 withdrawn;
        uint256 totalBonus;
        LevelPlan[] levelPlans;
        address referrer;
        uint8 isActive;
        uint256 usertimestamp;
    }

    mapping (address => User) public users;
    //mapping (address => uint8) public id; // This For maintain number of deposit happen
    mapping(address => address) public upline_referrer;

    bool public started;

    bool public pauseInvestBNB=false;
    bool public pauseInvestUSDT=false;
    bool public pauseStakeWithdrawal=false;
    bool public pauseLevelWithdrawal=false;
    uint256 public count=0;
    uint8 public activeIco=1; // 1=first sell , 2= sencond sell , 3= 3rd sell
    uint256 public activeIcoDays;

    uint256 public icoFirstTokenSell;
    uint256 public icoSecondTokenSell;
    uint256 public icoThirdTokenSell;

    ERC20 tokenUSDT;
    ERC20 tokenSalera;

    address payable public commissionWallet;
    address payable public tokenWallet;
    
    uint256 public minInvestmentDollar=10000000000000000000;

    AggregatorV3Interface internal priceFeed;
    uint8 public usdDecimal;
    //uint256 public usdtBNBPrice;
    uint256 public usdtBNBPrice=301000000000000000000;

    uint256 public tokenDollarRate=12000000000000000;
    address public parentReferrel; // deploayer address is default
    uint256 constant public PLANPER_DIVIDER = 10000;
    uint256 public round1=0;
    uint256 public round2=0;
    uint256 public round3=0;
    uint256  private realeaseTime = 0;

    
    event NewDeposit(address indexed user,address indexed referrer, uint8 plan, uint256 investAmount, uint256 totalToken,uint256 rewardnMothly,string message);                  
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event RefBonusLapsed(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);

    event Newbie(address user);
    event UplineInit(address user,address upline);


    constructor (address payable _wallet,address payable _tokenWallet){
        require(!isContract(_wallet));
        commissionWallet = _wallet;
        tokenWallet =_tokenWallet;

        plans.push(Plan(360, 833,30,1));
        plans.push(Plan(300, 1000,30,1));
        plans.push(Plan(240, 1250,30,1));

        levels.push(Level(1000, 1000));
        levels.push(Level(700, 3500));
        levels.push(Level(300, 15000));
        levels.push(Level(250, 75000));
        levels.push(Level(250, 350000));

        parentReferrel=msg.sender;

        round1 = 72000000 * 10 ** 18;
        round2 = 108000000 * 10 ** 18;
        round3 = 180000000 * 10 ** 18;


        // enable here bnb Rate here
        //priceFeed = AggregatorV3Interface(priceAddress);
        //usdDecimal= priceFeed.decimals();

    }



    function Salera_USDT(address _referrer, uint256 _usdtAmount, uint8 _plan) public {
        if (!started) {
			if (msg.sender == commissionWallet) {
				started = true;
			} else revert("Not started yet");
            _referrer=address(0);
		}
        else{
            if(msg.sender == _referrer)
            {
                _referrer=parentReferrel;
            }
        }

        uint256 tokens =  _usdtAmount.div(tokenDollarRate).mul(1 ether);

        if(activeIco==1){
            uint256 availableSalera = round1.sub(icoFirstTokenSell);
            if(availableSalera<=tokens)
            {
                revert("Round First End");
            }
        }

        if(activeIco==2){

            uint256 availableSalera = round2.sub(icoSecondTokenSell);
            if(availableSalera<=tokens)
            {
                revert("Round Second End");
            }

        }

        if(activeIco==3){
            uint256 availableSalera = round3.sub(icoThirdTokenSell);
            if(availableSalera<=tokens)
            {
                revert("Round Third End");
            }
        
        }

        require(_plan < 3, "Invalid plan");
        require(pauseInvestUSDT==false,"Invest USDT is Pause");
        require(_usdtAmount>=minInvestmentDollar,"Insufficient Fund");
        require(tokenUSDT.allowance(msg.sender, address(this)) >= minInvestmentDollar,"Call Allowance");
        require(tokenUSDT.balanceOf(msg.sender) >= _usdtAmount,"InSufficient USDT Funds..");
        tokenUSDT.transferFrom(msg.sender, address(commissionWallet), _usdtAmount);

        if(upline_referrer[msg.sender] == 0x0000000000000000000000000000000000000000)
        {
            upline_referrer[msg.sender]=_referrer;
        }

        
        
        User storage user = users[msg.sender];
        user.usertimestamp = block.timestamp;
        uint256 startTime = block.timestamp;

        if(activeIco==1){
            realeaseTime=1682058657;

            //activeIcoDays=90 days;
            icoFirstTokenSell=icoFirstTokenSell.add(tokens);
        }
        if(activeIco==2){
            realeaseTime=1682058657;
            //activeIcoDays=60 days;
            icoSecondTokenSell=icoSecondTokenSell.add(tokens);
        }
        if(activeIco==3){
            realeaseTime=1681540200;
            //activeIcoDays=30 days;
            icoThirdTokenSell=icoThirdTokenSell.add(tokens);
        }

        if(user.deposits.length == 0){
            count++;
            emit Newbie(msg.sender);
        }

        user.isActive = 1;
        user.referrer = upline_referrer[msg.sender];

        uint256 rewardMonthly=tokens.mul(plans[_plan].percent).div(PLANPER_DIVIDER);
        //realeaseTime=block.timestamp.add(activeIcoDays);
        uint256 inMonth=plans[_plan].monthday;

        rewardMonthly=rewardMonthly.mul(plans[_plan].month);

        // Initialize Level
        if(user.levelPlans.length == 0){
            for (uint8 i = 0; i < 5; i++) {
                user.levelPlans.push(LevelPlan(i,0,0,0,0));
            }
        }
 
        for (uint256 i = 0; i < plans[_plan].daytime/plans[_plan].monthday; i++) {
            uint256 month=inMonth* (i+1) * 1 days;
            uint256 rtime=realeaseTime.add(month);
            user.deposits.push(Deposit(_plan,rewardMonthly,startTime,rtime,0,0,tokens));
        }
        emit NewDeposit(msg.sender,upline_referrer[msg.sender], _plan,_usdtAmount,tokens,rewardMonthly,"USDT"); 
         
        if (user.referrer != address(0)) {

            address upline = user.referrer;
             uint256 amount=0;
            
            // initialize upline user level
            User storage inituplineuser = users[upline];
            if(inituplineuser.levelPlans.length == 0){
                for (uint8 i = 0; i < 5; i++) {
                    inituplineuser.levelPlans.push(LevelPlan(i,0,0,0,0));
                }
                emit UplineInit(msg.sender,upline);
            }

            for(uint8 i=0;i<5;i++)
            {
                if(upline !=address(0))
                {
                    User storage uplineuser = users[upline];
                   
                    if(i >= 1){
                        if(uplineuser.levelPlans[i-1].totalBussiness >= (levels[i-1].criteria* 1 ether))
                        {
                            amount=_usdtAmount.mul(levels[i].percent) / (PLANPER_DIVIDER);
                            uplineuser.levelPlans[i].bonus= uplineuser.levelPlans[i].bonus.add(amount);
                            uplineuser.levelPlans[i].totalBussiness= uplineuser.levelPlans[i].totalBussiness.add(_usdtAmount);
                            emit RefBonus(upline, msg.sender, i, amount);
                            upline = users[upline].referrer;
                        }
                        else
                        {
                            amount=_usdtAmount.mul(levels[i].percent) / (PLANPER_DIVIDER);
                            uplineuser.levelPlans[i].totalBussiness= uplineuser.levelPlans[i].totalBussiness.add(_usdtAmount);
                            emit RefBonusLapsed(upline, msg.sender, i, amount);
                            upline = users[upline].referrer;
                            continue;
                        }                        
                        
                    }
                    else{

                        amount=_usdtAmount.mul(levels[i].percent) / (PLANPER_DIVIDER);
                        uplineuser.levelPlans[i].bonus= uplineuser.levelPlans[i].bonus.add(amount);
                        uplineuser.levelPlans[i].totalBussiness= uplineuser.levelPlans[i].totalBussiness.add(_usdtAmount);
                        emit RefBonus(upline, msg.sender, i, amount);
                        upline = users[upline].referrer;

                    }
                }
                else break;
            }
        }

    }


    function setPause(
        bool _pauseInvestBNB,
        bool _pauseInvestUSDT,
        bool _pauseStakeWithdrawal,
        bool _pauseLevelWithdrawal
        ) public onlyOwner returns (bool) {
        pauseInvestBNB=_pauseInvestBNB;
        pauseInvestUSDT=_pauseInvestUSDT;
        pauseStakeWithdrawal=_pauseStakeWithdrawal;
        pauseLevelWithdrawal=_pauseLevelWithdrawal;
        return true;
    }

    function UpdateTokenRate(uint256 _tokenDollarRate) public onlyOwner returns (bool) {
        tokenDollarRate=_tokenDollarRate;
        return true;
    }

    function UpdateIcoStage(uint8 _activeIco) public onlyOwner returns (bool) {
        activeIco=_activeIco;
        return true;
    }

    function initToken(address _tokenSalera) public onlyOwner returns (bool) {
       tokenSalera = ERC20(_tokenSalera);
        return true;
    }

    function initUSDT(address _tokenUSDT) public onlyOwner returns (bool) {
       tokenUSDT = ERC20(_tokenUSDT);
        return true;
    }

    function forwardFunds() internal {
        commissionWallet.transfer(msg.value);
    }

    function withdrawDeposite(uint index) public {
        require(pauseStakeWithdrawal==false,"Withdraw is Pause for day");
        User storage user = users[msg.sender];
        require(block.timestamp >= user.deposits[index].end,"Cannot withdraw Funds");
        require(user.deposits[index].checkpoint <= 0,"Fund alredy withdrawal");
        require(user.deposits[index].withdrawn < user.deposits[index].amount,"Fund alredy withdraw");
        require(tokenSalera.allowance(tokenWallet, address(this)) > user.deposits[index].amount,"Call Allowance");
        require(tokenSalera.balanceOf(tokenWallet) >= user.deposits[index].amount,"InSufficient Salera Funds!");
        user.deposits[index].checkpoint = block.timestamp;
        user.deposits[index].withdrawn = user.deposits[index].amount;
        tokenSalera.transferFrom(address(tokenWallet), msg.sender, user.deposits[index].amount);
        emit Withdrawn(msg.sender, user.deposits[index].amount);
    }

    function withdrawLevel(uint index) public {
        require(pauseLevelWithdrawal==false,"Withdraw is Pause for day");
        User storage user = users[msg.sender];
        require(user.isActive==1,"User Not Topup Yet");
        //require(block.timestamp >= user.levelPlans[index].end,"Cannot withdraw Funds");
        //require(user.levelPlans[index].checkpoint <= 0,"Fund alredy withdrawal");
        //require(user.levelPlans[index].withdrawn < user.levelPlans[index].amount,"Fund alredy withdraw");
        uint256 availableSalera=user.levelPlans[index].bonus.sub(user.levelPlans[index].bonuswithdrawal);

        require(tokenSalera.allowance(tokenWallet, address(this)) > availableSalera,"Call Allowance");
        require(tokenSalera.balanceOf(tokenWallet) >= availableSalera,"InSufficient Salera Funds!");
       // user.levelPlans[index].checkpoint = block.timestamp;
        //user.levelPlans[index].withdrawn = user.levelPlans[index].amount;
        user.levelPlans[index].bonuswithdrawal=user.levelPlans[index].bonuswithdrawal.add(availableSalera);
        tokenSalera.transferFrom(address(tokenWallet), msg.sender, availableSalera);
        emit Withdrawn(msg.sender, availableSalera);
    }

    function getDeposits(address _userAddress) public view returns (Deposit[] memory){
        Deposit[] memory deposites = new Deposit[](users[_userAddress].deposits.length);
        for (uint i = 0; i < users[_userAddress].deposits.length; i++) {
          Deposit storage deposite = users[_userAddress].deposits[i];
          deposites[i] = deposite;
        }
        return deposites;
    }

    function getLevelIncome(address _userAddress) public view returns (LevelPlan[] memory){
        LevelPlan[] memory levelIncomes = new LevelPlan[](users[_userAddress].levelPlans.length);
        for (uint i = 0; i < users[_userAddress].levelPlans.length; i++) {
          LevelPlan storage levelIncome = users[_userAddress].levelPlans[i];
          levelIncomes[i] = levelIncome;
        }
        return levelIncomes;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


}