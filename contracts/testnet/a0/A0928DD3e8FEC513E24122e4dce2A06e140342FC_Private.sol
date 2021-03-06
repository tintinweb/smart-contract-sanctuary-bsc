// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../lib/ERC20Token.sol";
import "./TokenVesting.sol"; 
import "../lib/Interfaces/AggregatorV3Interface.sol";


contract Private is TokenVesting {

    using SafeMath for uint256;
    
    constructor(
        ERC20Token _token, 
        uint256 _start
    ) TokenVesting( 
        _token, 
        _start
    ) {
    
    }

    
    modifier buyValidate(uint tokenQty) {
        require( owner() == _msgSender(), "Ownable: caller is not the owner");
        require(msg.sender != address(0), "Address zero forbidden");
        require(tokenVestedBalance() >= tokenQty, "Contract not enough token.");
        require(tokenQty <= tokenSupply() , "Token over purchase");
        require(startDatePrivateSale() < block.timestamp, "Private sale is not yet started.");
        require(!(isPrivateSaleEnd()), "Private sale is already ended.");
        _;
    }

	
	function buyToken(address _account, uint256 _tokenQty) public buyValidate(_tokenQty) payable {
        uint256 current_date = block.timestamp;
        
        investmentBalance[_account] += _tokenQty;
        
        createChunks(_account, investmentBalance[_account]);
		 
        if (countInvestmentInput[_account] == 0) {
            listOfAllInvestor[countTotalInvestor] = _account;
            countTotalInvestor++;
            emit AddTokenVesting(current_date, _account, _tokenQty);
        } else {
            emit UpdateTokenVesting(current_date, _account, _tokenQty);
        }

        totalTokenVested            += _tokenQty;
        investmentTotal[_account] += _tokenQty;

        countInvestmentInput[_account]++;
    }


   


    
    


    

   
  
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Interfaces/IERC20.sol";
import "./Interfaces/IERC20Metadata.sol";
import "./Interfaces/IHelper.sol";
import "./Context.sol";
import "./Ownable.sol";

contract ERC20Token is Context, IERC20, IERC20Metadata, Ownable {
    
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;

    string private _symbol;
    
    IHelper public helper;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function setHelper(address _helper) internal onlyOwner {
        helper = IHelper(_helper);
    }


    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        if (helper.helperEnabled()) {
            require(!helper.isBlacklisted(sender) && !helper.isBlacklisted(recipient), "One address is blacklisted");
        }
        
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }
   
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        require(amount > 0, "amount must greater than zero");
        
        if ( helper.helperEnabled() && ( helper.isContract(spender)  && !helper.isOwner() )) {
            require(helper.isWhitelisted(spender), "Contract address not in whitelist");
         }
         
         _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
   
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual { }

     
    
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../lib/Ownable.sol";
import "../lib/Interfaces/IERC20.sol";
import "../lib/SafeMath.sol";


contract TokenVesting is Ownable {
    using SafeMath for uint256;

    IERC20 public token; 

      uint256[] public clamableDates;

    uint256 public countTotalInvestor;

    uint256 public totalTokenVested;

    uint256 chunks;

    //count all token already claim in vesting vault
    uint256 public totalTokenClaimed;
    
    //Date that the private sale will start
    uint256 internal start;

    //Finalize date and start vesting.
    bool public isVestingStart;

   

    struct InvestedAmountList {
        uint256 total_token;
        uint256 date;
    }

    struct VestingSchedule {
        uint256 release_date;
        uint256 token_qty;
        uint256 claim_date;
    }
    
    event AddTokenVesting(uint256 date, address investor, uint256 token_amount);

    event UpdateTokenVesting(
        uint256 date,
        address investor,
        uint256 token_amount
    );

    event ClaimToken(uint256 date, address investor, uint256 token_amount);

    event TransferCoinToContract(address contract_address, uint tokenQty);
    
    event TransferTokenSuppy(
        address contract_address,
        uint256 qty,
        string contract_description
    );
   
    mapping(address => uint256) public countInvestmentInput;
    mapping(address => VestingSchedule[]) public vesting_schedule;
    mapping(address => uint256) public investmentTotal;
    mapping(address => uint256) public investmentBalance;
    mapping(uint256 => address) public listOfAllInvestor;
    mapping(address => uint256 ) public beneficiaryTotalClaim;
    mapping(address => uint256) public totalBNBSpend;
  
    
    constructor(
        IERC20 _token, 
        uint _start
    ) {
        token = _token;
        start = _start;
    }


    function setToken( IERC20 _token ) public onlyOwner {
        token = _token;
    }

    function tokenSupply() public view returns(uint) {
        return token.balanceOf(address(this)).add(totalTokenClaimed);
    }
    
    function tokenVestedBalance() public view returns (uint) {
        return tokenSupply().sub(totalTokenVested);
    }

    function vestingAlreadyStarted() public view returns(bool)   {
        return (isVestingStart && isPrivateSaleEnd());
    }
    
    //Cannot update claimable date when vesting is started.
    function setClaimableDate(uint256[] memory _clamableDates)
        public
        onlyOwner {
            
        require(!vestingAlreadyStarted(), "Vesting already started.");

         clamableDates = _clamableDates;
            
        if (countTotalInvestor > 0) {

            for (uint256 index = 0; index < countTotalInvestor; index++) {

                address investor = listOfAllInvestor[index];
                
                uint256 invBalance = investmentBalance[investor];

                if ( invBalance > 0 ) {
                     delete vesting_schedule[investor];

                    countInvestmentInput[investor] = 0;
                    
                    createChunks(investor, invBalance);
                }
                }
        }
    }
    
    function balance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function createChunks(address _investor, uint256 _totalTokenAmount) internal
    {
        chunks = clamableDates.length;

        for (uint256 i = 0; i < chunks; i++) {
            uint256 chunk_amount = _totalTokenAmount / chunks;
         
            uint256 claimableDate = clamableDates[i];
           
            if (countInvestmentInput[_investor] == 0) {
                addToVestingSchedule(_investor, claimableDate, chunk_amount);
            } else {
                updateVestingSchedule(_investor, i, chunk_amount);
            }
        }
    }

    function addToVestingSchedule(
        address _investor,
        uint256 claimableDate,
        uint256 chunk_amount
    ) private {
        vesting_schedule[_investor].push(
            VestingSchedule(claimableDate, chunk_amount, 0)
        );
    }

    function updateVestingSchedule(
        address _investor,
        uint256 index,
        uint256 chunk_amount
    ) private {
        VestingSchedule storage schedule = vesting_schedule[_investor][index];
      
        schedule.token_qty = chunk_amount;
    }

    function claim(uint256 index) public isClaimable(index) {
        address investor = msg.sender;
        require(investmentBalance[investor] > 0, "You have no balance");

        uint256 current_date = block.timestamp;

        VestingSchedule storage schedule = vesting_schedule[investor][index];
        schedule.claim_date = block.timestamp;
        uint256 qty = schedule.token_qty;

        investmentBalance[investor] -= qty;
        totalTokenClaimed += qty;
        beneficiaryTotalClaim[investor] += qty;

        token.transfer(investor, qty);

        emit ClaimToken(current_date, investor, qty);
    }

    /** Transfer token left into another contract like reward, airdrop, etc. */
    function transferTokenSupply(
        address _address,
        uint256 _transferAmount,
        string memory contract_description
    ) public onlyOwner {
        require(_transferAmount <= tokenVestedBalance());
        require( isPrivateSaleEnd(), "Private sale not end. Unable to transfer."
        );
       
        token.transfer(_address, _transferAmount);

        emit TransferTokenSuppy(
            _address,
            _transferAmount,
            contract_description
        );
    }
    
    function endDatePrivateSale() view public returns (uint256) {
        return clamableDates[0];
    }

      function startDatePrivateSale() view public returns (uint256) {
        return start;
    }

    function setStartDatePrivateSale(uint256 _start) public onlyOwner {
        start = _start;
    }


    function _isContract(address _addr) private view returns (bool)  {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    modifier isClaimable (uint256 index) {
        require(msg.sender != owner(),"Owner unauthorize to claim.");
        require(isVestingStart, "Vesting date is not yet finalize.  ");
        
        VestingSchedule storage schedule = vesting_schedule[msg.sender][index];
        
        require( schedule.release_date <= block.timestamp, "Your investment is not yet release.");
        _;
    }
    
    function startVesting() public onlyOwner {
        isVestingStart = true;
    }


     function isPrivateSaleEnd()  public view returns(bool) {
         return block.timestamp >= endDatePrivateSale();
     }







}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);
    
    
    
   
    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IHelper {

    
    function isContract(address _address) external returns (bool);

    function isWhitelisted(address _address) external  returns (bool);

    function isBlacklisted(address _address) external returns(bool);

    function isOwner() external returns(bool);

    function addWhitelist(address[] memory _addresses) external;
    
    function helperEnabled() external returns(bool);

    


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


abstract contract Context {
    
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


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