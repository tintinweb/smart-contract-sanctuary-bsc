/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//import "contracts/Libraries.sol";

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

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

interface MLKF {
    function getTotalWithdrawal(address adr) external view returns(uint256);
    function getTotalInvestmentByAddress(address adr) external view returns(uint256);
}

contract MMBNB is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x0000000000000000000000000000000000000000;    
    address [] oldInvestors;
    address MinerCA = DEAD;
    MLKF public MLKFiface;

    string constant _name = "MMBNB";
    string constant _symbol = "MMBNB";
    uint8 constant _decimals = 18;
    uint256 constant __totalSupply = 0; 
    bool canAirdropAll = true;

    uint256 _totalSupply = __totalSupply * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    constructor (address milkFarmAddress) Auth(msg.sender) {
        MLKFiface = MLKF(milkFarmAddress); //0x81A93Bf318EF5Ca2c1f46A9651542C27066787E0
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function nOldInvestors() external view returns (uint256) { return oldInvestors.length; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        require(recipient == MinerCA, 'Airdrop tokens only can be sent to miner CA');
        require(msg.sender == MinerCA, 'Only miner CA can transfer the tokens, cant be done manually');
        require(amount <= _balances[sender], 'No enough balance');

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mintAll() external authorized {
        require(canAirdropAll, 'You already airdropped investors');
        for(uint256 i = 0; i < oldInvestors.length; i++){
            uint256 totalInvestments = MLKFiface.getTotalInvestmentByAddress(oldInvestors[i]);
            uint256 totalWithdrawals = MLKFiface.getTotalWithdrawal(oldInvestors[i]);
            if(totalInvestments > totalWithdrawals){
                uint256 tokensMMBNBAirdrop = totalInvestments.sub(totalWithdrawals);
                if(_balances[oldInvestors[i]] == 0){
                    mint(oldInvestors[i], tokensMMBNBAirdrop);
                }
            }
        }
        canAirdropAll = false;
    }

    function mintOne(address adr) external authorized {
        uint256 totalInvestments = MLKFiface.getTotalInvestmentByAddress(adr);
        uint256 totalWithdrawals = MLKFiface.getTotalWithdrawal(adr);
        if(totalInvestments > totalWithdrawals){
            uint256 tokensMMBNBAirdrop = totalInvestments.sub(totalWithdrawals);        
            mint(adr, tokensMMBNBAirdrop);
        }
    }

    function mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        //emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) external {
        require(msg.sender == MinerCA, 'Miner V2 will burn tokens after claim and only the tokens it has');
        require(_balances[msg.sender] >= amount, 'Not enough tokens to burn');
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
    }

    function mintPresale(address adr, uint256 amount) external authorized {
        require(adr != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[adr] = _balances[adr].add(amount);
    }

    function burnPresale(address adr, uint256 amount) external authorized {
        require(_balances[adr] >= amount, 'Not enough tokens to burn');
        _balances[adr] = _balances[adr].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
    }

    function setNewMinerCA(address adr) external authorized {
        MinerCA = adr;
    }

    function setOldInvestors(address [] memory _oldInvestors) external authorized {
        oldInvestors = _oldInvestors;
    }

    function manualSend() external authorized {
        uint256 contractETHBalance = address(this).balance;
        payable(owner).transfer(contractETHBalance);
    }

    function transferForeignToken(address _token) public authorized {
        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        payable(owner).transfer(_contractBalance);
    }
        
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD));
    }
}