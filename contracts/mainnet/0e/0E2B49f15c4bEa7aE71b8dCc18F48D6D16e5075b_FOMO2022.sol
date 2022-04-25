/**
 *Submitted for verification at BscScan.com on 2022-04-24
*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

/**
 * BEP20 standard interface.
 */
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



library SafeMath {

        function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SM: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SM: addition overflow");
        return c;
    }
  
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SM: multiplication overflow");
        return c;
    }

      function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SM: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    


}



contract FOMO2022 is IBEP20 {
    using SafeMath for uint256;
    address internal owner;
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "FOMO2022";
    string constant _symbol = "FOMO";
    uint8 constant _decimals = 8;

    uint256 _totalSupply = 1000 * 1000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = 50 * 1000000 * (10 ** _decimals);     
    uint256 public _maxWalletToken = 50 * 1000000 * (10 ** _decimals);  


    uint256 ARDTtriggeramount = 2 * 100000 * (10 ** _decimals);
    uint256 public ARDTfeescale = 100 ;
    uint256  tokenquant = 1;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isMaxWalletTokenExempt;

    uint256 public BuyFee = 1; // burned
    uint256 public totalFee = 1; //  burned
    uint256 feeDeNom999  = 1000;
    uint256 public br = 1;

    uint256 public created = 0;  


    
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }


    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

 
    event OwnershipTransferred(address owner);
 

    constructor ()  {

         owner = msg.sender;    
        isFeeExempt[msg.sender] = true;
        isFeeExempt[DEAD] = true;
        isTxLimitExempt[msg.sender] = true;
        isMaxWalletTokenExempt[msg.sender] = true;
        created = 0;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        

    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

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
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance 8f709d3");
        }

        return _transferFrom(sender, recipient, amount);
    }

  
    

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        uint256 RecipientBalance = balanceOf(recipient);
        uint256 SenderBalance = balanceOf(sender);
        uint256 stora = 0;
         uint256 two = 2;
 
        if (recipient != DEAD && !isFeeExempt[sender] && !isFeeExempt[recipient]){
            require(((RecipientBalance + amount) < _maxWalletToken) || ((SenderBalance) < _maxWalletToken),"Transaction too big");
            checkTxLimit(sender, amount);
        }
        _balances[sender] = _balances[sender].sub(amount, "Out of tokens");  
        //Exchange tokens
        uint256 tokensreceived = 0;
 
        tokensreceived = CheckExemptStatus(sender,recipient) ? calcFeeBUY(sender, amount) : amount;
            

        stora =  balanceOf(address(this));

        if (stora > _maxWalletToken.div(two)){
            _balances[address(this)] = _balances[address(this)].sub(stora);
            _balances[address(0)] = _balances[address(0)].add(stora);
            emit Transfer(address(this), address(0), stora);
        }           
        _balances[recipient] = _balances[recipient].add(tokensreceived);
        created=created+1;
        emit Transfer(sender, recipient, tokensreceived);
        return true;
    }
    

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit");
    }
    
    function checkMaxWallet(address sender, uint256 amount) internal view {
        require(amount <= _maxWalletToken || isMaxWalletTokenExempt[sender], "TX Limit");
    }

    function CheckExemptStatus(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }

    function calcFeeBUY(address sender, uint256 amount) internal returns (uint256) {
        uint256 bp = created.mul(br);
        uint256 feeTempvar = amount.mul(BuyFee.add(bp)).div(feeDeNom999);
        _balances[address(this)] = _balances[address(this)].add(feeTempvar);
        emit Transfer(sender, address(this), feeTempvar);
        return amount.sub(feeTempvar);
    
    }


 
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD));
    }

  

}