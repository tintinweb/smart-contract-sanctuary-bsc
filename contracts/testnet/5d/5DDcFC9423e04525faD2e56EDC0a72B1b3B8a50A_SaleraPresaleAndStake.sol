/**
 *Submitted for verification at BscScan.com on 2023-02-01
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
    mapping(address => address) public upline_referrer;

    bool public started;

    bool public pauseInvestUSDT=false;
    bool public pauseStakeWithdrawal=false;
    bool public pauseLevelWithdrawal=false;
    bool public isEnableBouns=true;
    uint256 public count=0;
    uint8 public activeRound=0; // 0=private sell , 1= first round , 2= second round, 3= third round, 4= forth round

    uint256 public roundZeroTokenSell;
    uint256 public roundOneTokenSell;
    uint256 public roundTwoTokenSell;
    uint256 public roundThreeTokenSell;
    uint256 public roundFourTokenSell;

    ERC20 tokenUSDT;
    ERC20 tokenSalera;

    address payable public commissionWallet;
    address payable public stakeSaleraWallet;
    address payable public levelUSDTWallet;
    
    uint256 public minInvestmentDollar=10000000000000000000;
    uint256 public minLevelWithdraw=10000000000000000000;

    uint256 public tokenDollarRate=11000000000000000;
    address public parentReferrel; // deploayer address is default

    uint256 public round0=0;
    uint256 public round1=0;
    uint256 public round2=0;
    uint256 public round3=0;
    uint256 public round4=0;

    uint256  private realeaseTime = 0;
    uint256 constant public PLANPER_DIVIDER = 10000;


    event NewDeposit(address indexed user,address indexed referrer, uint8 plan, uint256 investAmount, uint256 totalToken,uint256 rewardnMothly,string message);                  
    event NewDepositPriv(address indexed user, uint8 plan, uint256 investAmount, uint256 totalToken,uint256 rewardnMothly,string message);                  
    event Withdrawn(address indexed user, uint256 amount);
    event WithdrawnLevel(address indexed user, uint256 amount);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event RefBonusLapsed(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event Newbie(address user);
    event UplineInit(address user,address upline);

    constructor (address payable _wallet){

        require(!isContract(_wallet));
        commissionWallet = _wallet;

        plans.push(Plan(300, 100,30,1));
        plans.push(Plan(300, 100,30,1));
        plans.push(Plan(300, 100,30,1));
        plans.push(Plan(240, 100,30,1));
        plans.push(Plan(180, 100,30,1));
        
        levels.push(Level(1000, 500));
        levels.push(Level(700, 1000));
        levels.push(Level(300, 3000));
        levels.push(Level(250, 5000));
        levels.push(Level(250, 5000));

        parentReferrel=msg.sender;

        round0 = 24000000 * 10 ** 18;
        round1 = 90000000 * 10 ** 18;
        round2 = 90000000 * 10 ** 18;
        round3 = 90000000 * 10 ** 18;
        round4 = 90000000 * 10 ** 18;

        realeaseTime=block.timestamp;

    }

    function Salera_USDT(address _referrer, uint256 _usdtAmount) public {

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

            User storage usertmp = users[_referrer];
            if(usertmp.isActive == 0)
            {
                revert("Referrer Acount Not Active ");

            }

        }
        

        uint256 tokens =  _usdtAmount.div(tokenDollarRate).mul(1 ether);

        if(activeRound==0){
             uint256 availableSalera = round0.sub(roundZeroTokenSell);
            if(availableSalera<=tokens)
            {
                revert("Private Round End");
            }
        }
        else if(activeRound==1){
            uint256 availableSalera = round1.sub(roundOneTokenSell);
            if(availableSalera<=tokens)
            {
                revert("Round First End");
            }
        }
        else if(activeRound==2){

            uint256 availableSalera = round2.sub(roundTwoTokenSell);
            if(availableSalera<=tokens)
            {
                revert("Round Second End");
            }
        }
        else if(activeRound==3){
            uint256 availableSalera = round3.sub(roundThreeTokenSell);
            if(availableSalera<=tokens)
            {
                revert("Round Third End");
            }        
        }
        else if(activeRound==4){
            uint256 availableSalera = round4.sub(roundFourTokenSell);
            if(availableSalera<=tokens)
            {
                revert("Round Four End");
            }        
        }
        else
        {
            revert("No Active Round");
        }

        require(pauseInvestUSDT==false,"Invest USDT is Pause");
        require(_usdtAmount>=minInvestmentDollar,"Insufficient Fund");
        require(tokenUSDT.allowance(msg.sender, address(this)) >= minInvestmentDollar,"Call Allowance");
        require(tokenUSDT.balanceOf(msg.sender) >= _usdtAmount,"InSufficient USDT Funds..");
        


        uint256 leveltransfer=_usdtAmount.div(100).mul(25);
        tokenUSDT.transferFrom(msg.sender, address(owner()), _usdtAmount.sub(leveltransfer));
        tokenUSDT.transferFrom(msg.sender, address(levelUSDTWallet), leveltransfer);

        if(upline_referrer[msg.sender] == 0x0000000000000000000000000000000000000000)
        {
            upline_referrer[msg.sender]=_referrer;
        }


        User storage user = users[msg.sender];
        user.usertimestamp = block.timestamp;
        uint256 startTime = block.timestamp;

        uint8 _plan;
        if(activeRound==0){
            roundZeroTokenSell=roundZeroTokenSell.add(tokens);
            _plan = 0;
        }
        else if(activeRound==1){
            roundOneTokenSell=roundOneTokenSell.add(tokens);
            _plan = 1;
        }
        else if(activeRound==2){
            roundTwoTokenSell=roundTwoTokenSell.add(tokens);
            _plan = 2;
        }
        else if(activeRound==3){
            roundThreeTokenSell=roundThreeTokenSell.add(tokens);
            _plan = 3;
        }
        else if(activeRound==4){
            roundFourTokenSell=roundFourTokenSell.add(tokens);
            _plan = 4;
        }
        else
        {
            revert("No Active Round");
        }

        if(user.deposits.length == 0){
            count++;
            emit Newbie(msg.sender);
        }

        user.isActive = 1;
        user.referrer = upline_referrer[msg.sender];

        uint256 rewardMonthly;
        if(activeRound != 0)
        {
            if(isEnableBouns)
            {
                if(_usdtAmount>=1000000000000000000000 && _usdtAmount<5000000000000000000000)
                {
                    uint256 interest=tokens.div(100).mul(5);                
                    rewardMonthly=tokens.add(interest);
                    rewardMonthly=rewardMonthly.div(plans[_plan].daytime/plans[_plan].monthday);
                }
                else if(_usdtAmount>=5000000000000000000000)
                {
                    uint256 interest=tokens.div(100).mul(10);                
                    rewardMonthly=tokens.add(interest);
                    rewardMonthly=rewardMonthly.div(plans[_plan].daytime/plans[_plan].monthday);
                }
                else
                {
                    rewardMonthly=tokens.div(plans[_plan].daytime/plans[_plan].monthday);
                }
            }
            else
            {
                rewardMonthly=tokens.div(plans[_plan].daytime/plans[_plan].monthday);
            }
        }
        else
        {
            rewardMonthly=tokens.div(plans[_plan].daytime/plans[_plan].monthday);
        }

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

                    if(uplineuser.isActive == 1)
                    {
                        if(i==0)
                        {
                            amount=_usdtAmount.mul(levels[i].percent) / (PLANPER_DIVIDER);
                            uplineuser.levelPlans[i].bonus= uplineuser.levelPlans[i].bonus.add(amount);
                            uplineuser.levelPlans[i].totalBussiness= uplineuser.levelPlans[i].totalBussiness.add(_usdtAmount);
                            emit RefBonus(upline, msg.sender, i, amount);
                            upline = users[upline].referrer;
                        }
                        else if(i==1)
                        {
                            if(uplineuser.levelPlans[0].totalBussiness >= (levels[0].criteria* 1 ether))
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
                        else if(i==2)
                        {
                            if(uplineuser.levelPlans[0].totalBussiness >= (levels[0].criteria* 1 ether) && uplineuser.levelPlans[1].totalBussiness >= (levels[1].criteria* 1 ether))
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
                        else if(i==3)
                        {
                            if(uplineuser.levelPlans[0].totalBussiness >= (levels[0].criteria* 1 ether) && uplineuser.levelPlans[1].totalBussiness >= (levels[1].criteria* 1 ether) && uplineuser.levelPlans[2].totalBussiness >= (levels[2].criteria* 1 ether))
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
                        else if(i==4)
                        {
                            if(uplineuser.levelPlans[0].totalBussiness >= (levels[0].criteria* 1 ether) && uplineuser.levelPlans[1].totalBussiness >= (levels[1].criteria* 1 ether) && uplineuser.levelPlans[2].totalBussiness >= (levels[2].criteria* 1 ether) && uplineuser.levelPlans[3].totalBussiness >= (levels[3].criteria* 1 ether))
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
                        else
                        {
                            continue;
                        }

                    }
                    else
                    {
                        continue;
                    }

                }
                else
                {
                    break;
                } 
            }
        }
    
    }


    function Salera(address _referrer, address _userwallet, uint256 _usdtAmount) public onlyOwner
    {
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

            User storage usertmp = users[_referrer];
            if(usertmp.isActive == 0)
            {
                revert("Referrer Acount Not Active ");

            }
        }


        uint256 tokens =  _usdtAmount.div(tokenDollarRate).mul(1 ether);

        if(activeRound==0){
             uint256 availableSalera = round0.sub(roundZeroTokenSell);
            if(availableSalera<=tokens)
            {
                revert("Private Round End");
            }
        }
        else if(activeRound==1){
            uint256 availableSalera = round1.sub(roundOneTokenSell);
            if(availableSalera<=tokens)
            {
                revert("Round First End");
            }
        }
        else if(activeRound==2){

            uint256 availableSalera = round2.sub(roundTwoTokenSell);
            if(availableSalera<=tokens)
            {
                revert("Round Second End");
            }
        }
        else if(activeRound==3){
            uint256 availableSalera = round3.sub(roundThreeTokenSell);
            if(availableSalera<=tokens)
            {
                revert("Round Third End");
            }        
        }
        else if(activeRound==4){
            uint256 availableSalera = round4.sub(roundFourTokenSell);
            if(availableSalera<=tokens)
            {
                revert("Round Four End");
            }        
        }
        else
        {
            revert("No Active Round");
        }

        require(pauseInvestUSDT==false,"Invest USDT is Pause");
        require(_usdtAmount>=minInvestmentDollar,"Insufficient Fund");

        


        if(upline_referrer[_userwallet] == 0x0000000000000000000000000000000000000000)
        {
            upline_referrer[_userwallet]=_referrer;
        }

        User storage user = users[_userwallet];

        user.usertimestamp = block.timestamp;
        uint256 startTime = block.timestamp;
        uint8 _plan;
        if(activeRound==0){
            roundZeroTokenSell=roundZeroTokenSell.add(tokens);
            _plan = 0;
        }
        else if(activeRound==1){
            roundOneTokenSell=roundOneTokenSell.add(tokens);
            _plan = 1;
        }
        else if(activeRound==2){
            roundTwoTokenSell=roundTwoTokenSell.add(tokens);
            _plan = 2;
        }
        else if(activeRound==3){
            roundThreeTokenSell=roundThreeTokenSell.add(tokens);
            _plan = 3;
        }
        else if(activeRound==4){
            roundFourTokenSell=roundFourTokenSell.add(tokens);
            _plan = 4;
        }
        else
        {
            revert("No Active Round");
        }

        if(user.deposits.length == 0){
            count++;
            emit Newbie(_userwallet);
        }

        user.isActive = 1;
        user.referrer = upline_referrer[_userwallet];

        uint256 rewardMonthly;
        if(activeRound != 0)
        {
            if(isEnableBouns)
            {
                if(_usdtAmount>=1000000000000000000000 && _usdtAmount<5000000000000000000000)
                {
                    uint256 interest=tokens.div(100).mul(5);                
                    rewardMonthly=tokens.add(interest);
                    rewardMonthly=rewardMonthly.div(plans[_plan].daytime/plans[_plan].monthday);
                }
                else if(_usdtAmount>=5000000000000000000000)
                {
                    uint256 interest=tokens.div(100).mul(10);                
                    rewardMonthly=tokens.add(interest);
                    rewardMonthly=rewardMonthly.div(plans[_plan].daytime/plans[_plan].monthday);
                }
                else
                {
                    rewardMonthly=tokens.div(plans[_plan].daytime/plans[_plan].monthday);
                }
            }
            else
            {
                rewardMonthly=tokens.div(plans[_plan].daytime/plans[_plan].monthday);
            }
        }
        else
        {
            rewardMonthly=tokens.div(plans[_plan].daytime/plans[_plan].monthday);
        }

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
        emit NewDeposit(_userwallet,upline_referrer[_userwallet], _plan,_usdtAmount,tokens,rewardMonthly,"SRA");

        if (user.referrer != address(0)) {

            address upline = user.referrer;
            uint256 amount=0;
            
            // initialize upline user level
            User storage inituplineuser = users[upline];
            if(inituplineuser.levelPlans.length == 0){
                for (uint8 i = 0; i < 5; i++) {
                    inituplineuser.levelPlans.push(LevelPlan(i,0,0,0,0));
                }
                emit UplineInit(_userwallet,upline);
            }

            for(uint8 i=0;i<5;i++)
            {
                if(upline !=address(0))
                {
                    User storage uplineuser = users[upline];

                    if(uplineuser.isActive == 1)
                    {
                        if(i==0)
                        {
                            amount=_usdtAmount.mul(levels[i].percent) / (PLANPER_DIVIDER);
                            uplineuser.levelPlans[i].bonus= uplineuser.levelPlans[i].bonus.add(amount);
                            uplineuser.levelPlans[i].totalBussiness= uplineuser.levelPlans[i].totalBussiness.add(_usdtAmount);
                            emit RefBonus(upline, _userwallet, i, amount);
                            upline = users[upline].referrer;
                        }
                        else if(i==1)
                        {
                            if(uplineuser.levelPlans[0].totalBussiness >= (levels[0].criteria* 1 ether))
                            {
                                amount=_usdtAmount.mul(levels[i].percent) / (PLANPER_DIVIDER);
                                uplineuser.levelPlans[i].bonus= uplineuser.levelPlans[i].bonus.add(amount);
                                uplineuser.levelPlans[i].totalBussiness= uplineuser.levelPlans[i].totalBussiness.add(_usdtAmount);
                                emit RefBonus(upline, _userwallet, i, amount);
                                upline = users[upline].referrer;
                            }
                            else
                            {
                                amount=_usdtAmount.mul(levels[i].percent) / (PLANPER_DIVIDER);
                                uplineuser.levelPlans[i].totalBussiness= uplineuser.levelPlans[i].totalBussiness.add(_usdtAmount);
                                emit RefBonusLapsed(upline, _userwallet, i, amount);
                                upline = users[upline].referrer;
                                continue;
                            }
                        }
                        else if(i==2)
                        {
                            if(uplineuser.levelPlans[0].totalBussiness >= (levels[0].criteria* 1 ether) && uplineuser.levelPlans[1].totalBussiness >= (levels[1].criteria* 1 ether))
                            {
                                amount=_usdtAmount.mul(levels[i].percent) / (PLANPER_DIVIDER);
                                uplineuser.levelPlans[i].bonus= uplineuser.levelPlans[i].bonus.add(amount);
                                uplineuser.levelPlans[i].totalBussiness= uplineuser.levelPlans[i].totalBussiness.add(_usdtAmount);
                                emit RefBonus(upline, _userwallet, i, amount);
                                upline = users[upline].referrer;
                            }
                            else
                            {
                                amount=_usdtAmount.mul(levels[i].percent) / (PLANPER_DIVIDER);
                                uplineuser.levelPlans[i].totalBussiness= uplineuser.levelPlans[i].totalBussiness.add(_usdtAmount);
                                emit RefBonusLapsed(upline, _userwallet, i, amount);
                                upline = users[upline].referrer;
                                continue;
                            } 
                        }
                        else if(i==3)
                        {
                            if(uplineuser.levelPlans[0].totalBussiness >= (levels[0].criteria* 1 ether) && uplineuser.levelPlans[1].totalBussiness >= (levels[1].criteria* 1 ether) && uplineuser.levelPlans[2].totalBussiness >= (levels[2].criteria* 1 ether))
                            {
                                amount=_usdtAmount.mul(levels[i].percent) / (PLANPER_DIVIDER);
                                uplineuser.levelPlans[i].bonus= uplineuser.levelPlans[i].bonus.add(amount);
                                uplineuser.levelPlans[i].totalBussiness= uplineuser.levelPlans[i].totalBussiness.add(_usdtAmount);
                                emit RefBonus(upline, _userwallet, i, amount);
                                upline = users[upline].referrer;
                            }
                            else
                            {
                                amount=_usdtAmount.mul(levels[i].percent) / (PLANPER_DIVIDER);
                                uplineuser.levelPlans[i].totalBussiness= uplineuser.levelPlans[i].totalBussiness.add(_usdtAmount);
                                emit RefBonusLapsed(upline, _userwallet, i, amount);
                                upline = users[upline].referrer;
                                continue;
                            } 
                        }
                        else if(i==4)
                        {
                            if(uplineuser.levelPlans[0].totalBussiness >= (levels[0].criteria* 1 ether) && uplineuser.levelPlans[1].totalBussiness >= (levels[1].criteria* 1 ether) && uplineuser.levelPlans[2].totalBussiness >= (levels[2].criteria* 1 ether) && uplineuser.levelPlans[3].totalBussiness >= (levels[3].criteria* 1 ether))
                            {
                                amount=_usdtAmount.mul(levels[i].percent) / (PLANPER_DIVIDER);
                                uplineuser.levelPlans[i].bonus= uplineuser.levelPlans[i].bonus.add(amount);
                                uplineuser.levelPlans[i].totalBussiness= uplineuser.levelPlans[i].totalBussiness.add(_usdtAmount);
                                emit RefBonus(upline, _userwallet, i, amount);
                                upline = users[upline].referrer;
                            }
                            else
                            {
                                amount=_usdtAmount.mul(levels[i].percent) / (PLANPER_DIVIDER);
                                uplineuser.levelPlans[i].totalBussiness= uplineuser.levelPlans[i].totalBussiness.add(_usdtAmount);
                                emit RefBonusLapsed(upline, _userwallet, i, amount);
                                upline = users[upline].referrer;
                                continue;
                            } 
                        }
                        else
                        {
                            continue;
                        }
                    }
                    else
                    {
                        continue;
                    }

                    
                }
                else
                {
                    break;
                } 
            }
        }
    }


    function UpdateTokenRate(uint256 _tokenDollarRate) public onlyOwner returns (bool) {
        tokenDollarRate=_tokenDollarRate;
        return true;
    }
    function UpdateReleaseTime(uint256 _utime) public onlyOwner returns (bool)
    {
        realeaseTime = _utime;
        return true;
    }

    function pauseBonus(bool _isEnableBouns) public onlyOwner returns (bool) {
        isEnableBouns = _isEnableBouns;
        return true;
    }

    function UpdateMinTokenLevelWithdraw(uint256 _minLevelWithdraw) public onlyOwner returns (bool) {
        minLevelWithdraw=_minLevelWithdraw;
        return true;
    }
    

    function UpdateRound(uint8 _activeRound) public onlyOwner returns (bool) {
        activeRound=_activeRound;
        return true;
    }

    function UpdateWithdrawalWallet(address payable _stakeSaleraWallet,address payable _levelUSDTWallet) public onlyOwner returns (bool) {
        stakeSaleraWallet = _stakeSaleraWallet;
        levelUSDTWallet = _levelUSDTWallet;
        return true;
    }


    function initSalera(address _tokenSalera) public onlyOwner returns (bool) {
        tokenSalera = ERC20(_tokenSalera);
        return true;
    }

    function initUSDT(address _tokenUSDT) public onlyOwner returns (bool) {
        tokenUSDT = ERC20(_tokenUSDT);
        return true;
    }

    function updateLevelTotalBussiness(address _user,uint8 index,uint256 _totalBussiness) public onlyOwner returns (bool) {
        User storage user = users[_user];
        user.levelPlans[index].totalBussiness = _totalBussiness;
        return true;
    }

    function withdrawDeposite(uint index) public {
        require(pauseStakeWithdrawal==false,"Withdraw is Pause for day");
        User storage user = users[msg.sender];
        require(block.timestamp >= user.deposits[index].end,"Cannot withdraw Funds");
        require(user.deposits[index].checkpoint <= 0,"Fund alredy withdrawal");
        require(user.deposits[index].withdrawn < user.deposits[index].amount,"Fund alredy withdraw");
        require(tokenSalera.allowance(stakeSaleraWallet, address(this)) > user.deposits[index].amount,"Call Allowance");
        require(tokenSalera.balanceOf(stakeSaleraWallet) >= user.deposits[index].amount,"InSufficient Salera Funds!");
        user.deposits[index].checkpoint = block.timestamp;
        user.deposits[index].withdrawn = user.deposits[index].amount;
        tokenSalera.transferFrom(address(stakeSaleraWallet), msg.sender, user.deposits[index].amount);
        emit Withdrawn(msg.sender, user.deposits[index].amount);
    }

    function withdrawLevel(uint index) public {        
        require(pauseLevelWithdrawal==false,"Withdraw is Pause for day");
        User storage user = users[msg.sender];
        require(user.isActive==1,"User Not Topup Yet");
        uint256 availableUSDT=user.levelPlans[index].bonus.sub(user.levelPlans[index].bonuswithdrawal);

        require(tokenUSDT.allowance(levelUSDTWallet, address(this)) > availableUSDT,"Call Allowance");
        require(tokenUSDT.balanceOf(levelUSDTWallet) >= availableUSDT,"InSufficient Account Funds!");
        require(availableUSDT >=minLevelWithdraw ,"InSufficient Income Funds!");

        user.levelPlans[index].bonuswithdrawal=user.levelPlans[index].bonuswithdrawal.add(availableUSDT);
        tokenUSDT.transferFrom(address(levelUSDTWallet), msg.sender, availableUSDT);
        emit WithdrawnLevel(msg.sender, availableUSDT);
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

   

    function updateTime(address _user,uint8 index) public onlyOwner returns (bool) {
        User storage user = users[_user];
        uint256 newtime=block.timestamp + 2 minutes;
        user.deposits[index].end=newtime;
        return true;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}