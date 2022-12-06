/**
 *Submitted for verification at BscScan.com on 2022-12-05
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

// Dapp application
pragma solidity ^0.8.0;

contract SaleraPrivateSale is Ownable {
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
    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        uint256 withdrawn;
        address referrer;
    }

    mapping (address => User) public users;

    ERC20 tokenUSDT;
    ERC20 tokenSLERA;

    bool public started;
    bool public pauseInvestUSDT=false;
    bool public pauseWithdrawal=false;

    uint256 public count;
    address payable public commissionWallet;
    address payable public tokenWallet;
    
    uint256 public minInvestmentDollar=100000000000000000000;



    uint256 public tokenDollarRate=10000000000000000;
    address public parentReferrel; // deploayer address is default

    uint256 constant public PLANPER_DIVIDER = 10000;

    uint256 public privateSaleraSell=0;
    uint256 public privateSaleraSold=0;

    //address private priceAddress = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE; // BNB/USD Mainnet
    address private priceAddress = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526; // BNB/USD Testnet
    //https://docs.chain.link/docs/bnb-chain-addresses/

    event NewDeposit(address indexed user, uint8 plan, uint256 investAmount, uint256 totalToken,uint256 rewardnMothly,string message);                  
    event Withdrawn(address indexed user, uint256 amount);

    constructor (address payable _wallet,address payable _tokenWallet,address _tokenUSDT){
        require(!isContract(_wallet));
        commissionWallet = _wallet;

        plans.push(Plan(360, 833,30,1));

        tokenUSDT = ERC20(_tokenUSDT);
        tokenWallet =_tokenWallet;
        privateSaleraSell= 12000000 * 10 ** 18;

    }
       

    function UpdateRate(uint256 _tokenDollarRate) public onlyOwner returns (bool) {
        tokenDollarRate=_tokenDollarRate;
        return true;
    }


    function initToken(address _tokenSLERA) public onlyOwner returns (bool) {
       tokenSLERA = ERC20(_tokenSLERA);
        return true;
    }

    function initUSDT(address _tokenUSDT) public onlyOwner returns (bool) {
       tokenUSDT = ERC20(_tokenUSDT);
        return true;
    }

    function updateTime(address _user,uint8 index) public onlyOwner returns (bool) {
        User storage user = users[_user];
        uint256 newtime=block.timestamp + 2 minutes;
        user.deposits[index].end=newtime;
        return true;
    }

    function UpdateMinInvestment(uint256 _minInvestmentDollar) public onlyOwner returns (bool) {
        minInvestmentDollar=_minInvestmentDollar;
        return true;
    }


    function setPause(
        bool _pauseInvestUSDT,
        bool _pauseWithdrawal
        ) public onlyOwner returns (bool) {
        pauseInvestUSDT=_pauseInvestUSDT;
        pauseWithdrawal=_pauseWithdrawal;
        return true;
    }

//================INVEST USDT

    function SLERA_USDT(uint256 _usdtAmount, uint8 _plan) public {
        if (!started) {
			if (msg.sender == commissionWallet) {
				started = true;
			} else revert("Not started yet");
		}
        uint256 tokens =  _usdtAmount.div(tokenDollarRate).mul(1 ether);
        uint256 availableSalera = privateSaleraSell.sub(privateSaleraSold);
        if(availableSalera<=tokens)
        {
            revert("Private Sell End");
        }

        require(_plan < 1, "Invalid plan");
        require(pauseInvestUSDT==false,"Invest USDT is Pause");
        require(_usdtAmount>=minInvestmentDollar,"Insufficient Fund");
        require(tokenUSDT.allowance(msg.sender, address(this)) >= minInvestmentDollar,"Call Allowance");
        require(tokenUSDT.balanceOf(msg.sender) >= _usdtAmount,"InSufficient USDT Funds..");
        tokenUSDT.transferFrom(msg.sender, address(commissionWallet), _usdtAmount);
        privateSaleraSold=privateSaleraSold.add(tokens);
 

        
        User storage user = users[msg.sender];
        uint256 startTime = block.timestamp;
        uint256 checkpoint= 0;
        uint256 withdrawn= 0;
        
        if(user.deposits.length == 0){
            count++;
        }

        uint256 rewardMonthly=tokens.mul(plans[_plan].percent).div(PLANPER_DIVIDER);
        // for locking period
        uint256 realeaseTime=block.timestamp;
        uint256 inMonth=plans[_plan].monthday;
        
        rewardMonthly=rewardMonthly.mul(plans[_plan].month);
        
        for (uint256 i = 0; i < plans[_plan].daytime/plans[_plan].monthday; i++) {
            uint256 month=inMonth* (i+1) * 1 days;
            uint256 rtime=realeaseTime.add(month);
            user.deposits.push(Deposit(_plan,rewardMonthly,startTime,rtime,checkpoint,withdrawn,tokens));
        }
        privateSaleraSold=privateSaleraSold.add(tokens);
        emit NewDeposit(msg.sender,_plan,_usdtAmount,tokens,rewardMonthly,"USDT"); 
    }

    function withdraw(uint index) public {
        require(pauseWithdrawal==false,"Withdraw is Pause for day");
        User storage user = users[msg.sender];
        require(block.timestamp >= user.deposits[index].end,"Cannot withdraw Funds");
        require(user.deposits[index].checkpoint <= 0,"Fund alredy withdrawal");
        require(user.deposits[index].withdrawn < user.deposits[index].amount,"Fund alredy withdraw");
        require(tokenSLERA.allowance(tokenWallet, address(this)) > user.deposits[index].amount,"Call Allowance");
        require(tokenSLERA.balanceOf(tokenWallet) >= user.deposits[index].amount,"InSufficient Salera Funds!");
        user.deposits[index].checkpoint = block.timestamp;
        user.deposits[index].withdrawn = user.deposits[index].amount;
        tokenSLERA.transferFrom(address(tokenWallet), msg.sender, user.deposits[index].amount);
        emit Withdrawn(msg.sender, user.deposits[index].amount);
    }



    // send ether to the fund collection wallet
    function forwardFunds() internal {
        commissionWallet.transfer(msg.value);
    }

    function getDeposits(address _userAddress) public view returns (Deposit[] memory){
        Deposit[] memory deposites = new Deposit[](users[_userAddress].deposits.length);
        for (uint i = 0; i < users[_userAddress].deposits.length; i++) {
          Deposit storage deposite = users[_userAddress].deposits[i];
          deposites[i] = deposite;
        }
        return deposites;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}