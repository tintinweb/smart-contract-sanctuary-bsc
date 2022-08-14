/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.15;

interface IERC20 {    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
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
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

library Address {    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                 assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Ownable is Context {
    address internal _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }    
    function owner() public view virtual returns (address) {
        return _owner;
    }    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = time;
        emit OwnershipTransferred(_owner, address(0));
    }
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock.");
        require(block.timestamp > _lockTime , "Contract is locked.");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}

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

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero addy");

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
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero addy");

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
        require(owner != address(0), "ERC20: approve from the zero addy");
        require(spender != address(0), "ERC20: approve to the zero addy");

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

abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

contract rad is ERC20Burnable, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    IUniswapV2Router02 public immutable v2Router;
    address public immutable v2Pair;
    uint256 private constant maxUint256 = ~uint256(0);
    uint256 private tax = 5;
    bool private taxOn = false;
    bool private growPot = false;
    bool private inSwap;
    address[] public sellPath = new address[](2);
    // 0x10ED43C718714eb63d5aA57B78B54704E256024E PCS
    // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D Uniswap
    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;        
    mapping (address => bool) private excluded;

    enum Binary{Zero, One}

    struct userRound {
        uint256 tokens;
        Binary choice;
        bool exists;
    }

    struct round {
        uint256 eth;
        uint256 ZeroAmt;
        uint256 OneAmt;
        uint256 totalAmt;
        uint256 expire;  
        uint256 userCount;  
        bool launched;
        Binary choice;
        mapping(address => userRound) user;
    }

    mapping (uint256 => round) public rounds;
    address usdc = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; // USDC
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 public roundDuration = 4 hours;
    uint256 public launchTime;

    constructor() ERC20("radi", "radi", 18) {      

        IUniswapV2Router02 _v2Router = IUniswapV2Router02(routerAddress);
        v2Router = _v2Router;
        v2Pair = IUniswapV2Factory(_v2Router.factory()).createPair(address(this), _v2Router.WETH());

        _approve(msg.sender, routerAddress, maxUint256);
        _approve(address(this), routerAddress, maxUint256);
        sellPath[0] = address(this);
        sellPath[1] = v2Router.WETH();
        _mint(msg.sender, 1e27);
    }

    function _transfer(address from, address to, uint256 amount) internal override  {

        

        // Buy
        if (taxOn && 
            from == v2Pair &&  
            !excluded[to] &&           
            to != owner() && 
            to != address(0) &&
            to != address(0xdead)) {

            uint256 tokenTax = amount.mul(tax).div(100);
            super._transfer(from, to, amount.sub(tokenTax));

            if (tokenTax > 0) {
                super._transfer(from, address(this), tokenTax);    

                // Launch coin.  On Round 0 on first buy.  Will fire only once.
                if (!rounds[0].launched) {
                    rounds[0].launched = true;
                    launchTime = block.timestamp;
                }     

                uint256 _currentRound = currentRound();       

                // Update User Count
                if (!rounds[_currentRound].user[to].exists) {
                    rounds[_currentRound].user[to].exists = true;
                    rounds[_currentRound].userCount = rounds[_currentRound].userCount + 1;
                }

                rounds[_currentRound].user[to].tokens = rounds[_currentRound].user[to].tokens + tokenTax;
                rounds[_currentRound].user[to].choice = calcOneOrZero();

                Binary roundChoice = calcOneOrZeroRound();

                if (roundChoice == Binary.One) {
                    rounds[_currentRound].OneAmt = rounds[_currentRound].OneAmt + tokenTax;
                }
                else {
                    rounds[_currentRound].ZeroAmt = rounds[_currentRound].ZeroAmt + tokenTax;
                }
                rounds[_currentRound].totalAmt = rounds[_currentRound].totalAmt + tokenTax;
                rounds[_currentRound].choice = roundChoice;

                // Set New Round if needed
                if (rounds[_currentRound].expire == 0) {
                    rounds[_currentRound].expire = block.timestamp + roundDuration;
                }

                
            }            
        }
        else {
            super._transfer(from, to, amount);            
        }
    }

    /* 
        Anyone can call this function to grow the Pot.   Gas costs apply of course.
    */
    function growThePot() nonReentrant isHuman public {

        uint256 _currentRound = currentRound();   
        uint256 roundTokens = rounds[_currentRound].totalAmt;

        _approve(msg.sender, routerAddress, roundTokens);
        _approve(address(this), msg.sender, roundTokens);

        IUniswapV2Pair pair = IUniswapV2Pair(v2Pair);
        pair.sync();       

        require(roundTokens > 0, "Nothing to Swap");

        if (roundTokens > 0 && growPot) {            
            uint256 beforeEth = address(this).balance;
            v2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                roundTokens,
                0,
                sellPath,
                address(this),
                block.timestamp
            );     
            uint256 afterEth = address(this).balance.sub(beforeEth);

            rounds[_currentRound].totalAmt = rounds[_currentRound].totalAmt - roundTokens;
            rounds[_currentRound].eth = rounds[_currentRound].eth + afterEth;
        }
    }

    function currentRound() view public returns (uint256 r) {
        r = block.timestamp.sub(launchTime).div(roundDuration);
    }

    function claimWinnerEth(uint256 _round) nonReentrant isHuman external payable {

        require(rounds[_round].expire < block.timestamp && rounds[_round].expire != 0, "Round is still active or not started");
        require(rounds[_round].choice == rounds[_round].user[msg.sender].choice, "You did not win");

        Binary winningChoice = rounds[_round].choice;
        uint256 userRewardPercentage = 0;

        if (winningChoice == Binary.Zero) {
            userRewardPercentage = rounds[_round].user[msg.sender].tokens.div(rounds[_round].ZeroAmt);
        }
        else {
            userRewardPercentage = rounds[_round].user[msg.sender].tokens.div(rounds[_round].OneAmt);
        }

        uint256 userReward = rounds[_round].eth.mul(userRewardPercentage);
        payable(msg.sender).transfer(userReward);
    }

    function calcOneOrZero() view public returns (Binary oneOrZero) {
        address[] memory path = new address[](2);
        path[0] = v2Router.WETH();
        path[1] = usdc;
        uint256 ethInUsd;
        uint256 oneETH = 1e18;
        try v2Router.getAmountsOut(oneETH, path) returns (uint[] memory amounts) {
            ethInUsd = amounts[1];
        }
        catch {
            ethInUsd = block.timestamp;
        } 
        ethInUsd.mod(2) == 0 ? oneOrZero = Binary.Zero : oneOrZero = Binary.One;
    }

    function calcOneOrZeroRound() view public returns (Binary oneOrZero) {
        address[] memory path = new address[](2);
        path[0] = v2Router.WETH();
        path[1] = usdc;
        uint256 ethInUsd;
        // 1 divided by 19
        uint256 oneETH = 526315789473684211;
        try v2Router.getAmountsOut(oneETH, path) returns (uint[] memory amounts) {
            ethInUsd = amounts[1];
        }
        catch {
            ethInUsd = block.timestamp;
        } 
        ethInUsd.mod(2) == 0 ? oneOrZero = Binary.Zero : oneOrZero = Binary.One;
    }

    function setTaxRate(uint256 _val) external onlyOwner {
        require(tax <= 10 && tax > 0, "Tax must be between 1 and 10");
        tax = _val;
    }

    function getTaxRate() public view returns (uint256) {
        return tax;
    }

    function setDuration(uint256 val) external onlyOwner {
        roundDuration = val;
    }

    function toggleTaxOn() external onlyOwner {
        taxOn = !taxOn;
    }

    function getTaxOn() public view returns (bool) {
        return taxOn;
    }

    function togglePot() external onlyOwner {
        growPot = !growPot;
    }

    function getPot() public view returns (bool) {
        return growPot;
    }

    function setExcluded(address _val, bool exclude) external onlyOwner {
        excluded[_val] = exclude;
    }

    receive() external payable {}

    function rescueEth() external payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function rescueTokens(address _stuckToken, uint256 _amount) external onlyOwner {
        IERC20(_stuckToken).transfer(msg.sender, _amount);
    }
}