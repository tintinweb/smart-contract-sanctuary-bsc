/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: MIT                                                                               
                                                    
pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}


contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

contract Ownable is Context {
    address private _owner;

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

contract CoinFlip is ERC20, Ownable{
    using SafeMath for uint256;

    address BUSD = 0xb328c07eF2C7ddb1da4f077108120AC14F6BD755;
    IERC20 token;

    // uint256 public  minBet = 1;
    // uint256 public  maxBet = 10;
    // uint256 public  houseEdge = 10;

    struct Game {
        address addr;
        uint amountBet;
        uint8 guess;
        uint8 coin;
        bool winner;
        uint time;
    }

    Game[] lastPlayedGames;

    event GameResult(uint8 side);

    constructor() {
        token = IERC20(BUSD);
    }

    function flipCoin(uint256 amount, uint8 guess) public returns(bool){
        amount = amount * 10 ** 18;
        require(guess == 0 || guess == 1, "Variable 'guess' should be either 0 ('heads') or 1 ('tails')");
        // require(amount >= minBet, "Amount is lower than minimum bet");
        // require(amount <= token.balanceOf(address(this)) * maxBet / 100 , "You cannot bet more than what is available in the jackpot");
        require(amount <= token.balanceOf(msg.sender) - amount, "You balance is too low");
        token.approve(address(this), amount);
        
        uint8 result = uint8(uint256(keccak256(abi.encodePacked(block.difficulty, msg.sender, block.timestamp)))%2);

        bool won;

        if (guess == result) {
            won = true;
            // uint256 win = amount * 2 / 100 * (100 - houseEdge);
            uint256 win = amount * 2;
            token.transfer(msg.sender, win-amount);
        }else{
            token.transferFrom(msg.sender, address(this), amount);  
        }

        emit GameResult(result);

        lastPlayedGames.push(Game(msg.sender, amount, guess, 1, won, block.timestamp));
        return won;
    }

    function getGameCount() public view returns(uint) {
        return lastPlayedGames.length;
    }

    function getGameEntry(uint index) public view returns(address addr, uint amountBet, uint8 guess, uint8 coin, bool winner, uint ethInJackpot) {
        return (
        lastPlayedGames[index].addr,
        lastPlayedGames[index].amountBet,
        lastPlayedGames[index].guess,
        lastPlayedGames[index].coin,
        lastPlayedGames[index].winner,
        lastPlayedGames[index].time
        );
    }

    function destroy() external onlyOwner {
        selfdestruct(payable(owner()));
    }

    function withdraw(uint amount) external onlyOwner {
        require(amount < address(this).balance, "You cannot withdraw more than what is available in the contract");
        payable(owner()).transfer(amount);
    }

    function withdrawBUSD(uint256 amount) external onlyOwner {
            require(amount <= token.balanceOf(address(this)), "You cannot withdraw more than what is available in the contract");
            token.transfer(msg.sender,amount);  
    }

    // function setMinBet(uint256 value) external onlyOwner{
    //     minBet = value;
    // } 

    // function setMaxBet(uint256 value) external onlyOwner{
    //     maxBet = value;
    // } 

    // function setHouseEdge(uint256 value) external onlyOwner{
    //     houseEdge = value;
    // } 

    function getContractBUSDalance() public view returns (uint) {
	    return token.balanceOf(address(this));
	} 

    receive() external payable {}
}